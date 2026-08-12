//------------------------------------------------------------------------------
//! @file ExprEmit.cpp
//! @brief Expressions, constant folding, value encoding
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include <algorithm>
#include <cerrno>
#include <cstdlib>

#include "EmitHelpers.h"

#include "slang/ast/expressions/Operator.h"

namespace slang_uhdm {

// § newArray11 — every reference under a `new[...]` array-allocation call is
// NAME-ONLY in golden (`ref_obj (dyn)`, not `ref_obj (p::C::f::dyn)`), size
// expression and copy source alike: Surelog compiles those arguments outside
// any scope, so nothing scopes their names.  The refs are minted by the
// ordinary emitExpr paths, which always scope, so strip afterwards over the
// shapes an allocation size/source can take (repro t3 n_array_ref).
static void stripRefFullNames11(UHDM::any* o, int depth = 0) {
    if (!o || depth > 8)
        return;
    switch (o->UhdmType()) {
        case UHDM::uhdmref_obj:
            ((UHDM::ref_obj*)o)->VpiFullName(std::string());
            return;
        case UHDM::uhdmref_var:
            ((UHDM::ref_var*)o)->VpiFullName(std::string());
            return;
        case UHDM::uhdmoperation:
            if (auto* ops = ((UHDM::operation*)o)->Operands())
                for (auto* op : *ops)
                    stripRefFullNames11(op, depth + 1);
            return;
        case UHDM::uhdmbit_select:
            ((UHDM::bit_select*)o)->VpiFullName(std::string());
            return;
        case UHDM::uhdmmethod_func_call:
            if (auto* as = ((UHDM::method_func_call*)o)->Tf_call_args())
                for (auto* a : *as)
                    stripRefFullNames11(a, depth + 1);
            return;
        default:
            return;
    }
}

// The UHDM typespec CLASS Surelog would build for `t` — the key
// ExprEval::flattenPatternAssignments matches a pattern TYPE key (`int: 0`)
// against (`ttp->UhdmType() == fieldTypes[i]->UhdmType()`).  Only the shapes
// a type key can name are classified; anything else answers
// `uhdmunsupported_typespec`, which makes the caller decline the flatten
// rather than guess.
static UHDM::UHDM_OBJECT_TYPE uhdmTsKindOfType(const Type& t) {
    auto& ct = t.getCanonicalType();
    switch (ct.kind) {
        case SymbolKind::PredefinedIntegerType:
            switch (ct.as<PredefinedIntegerType>().integerKind) {
                case PredefinedIntegerType::Int:
                    return UHDM::uhdmint_typespec;
                case PredefinedIntegerType::Integer:
                    return UHDM::uhdminteger_typespec;
                case PredefinedIntegerType::Byte:
                    return UHDM::uhdmbyte_typespec;
                case PredefinedIntegerType::ShortInt:
                    return UHDM::uhdmshort_int_typespec;
                case PredefinedIntegerType::LongInt:
                    return UHDM::uhdmlong_int_typespec;
                case PredefinedIntegerType::Time:
                    return UHDM::uhdmtime_typespec;
            }
            return UHDM::uhdmunsupported_typespec;
        case SymbolKind::ScalarType:
            return ct.as<ScalarType>().scalarKind == ScalarType::Bit
                       ? UHDM::uhdmbit_typespec
                       : UHDM::uhdmlogic_typespec;
        case SymbolKind::FloatingType:
            return ct.as<FloatingType>().floatKind == FloatingType::ShortReal
                       ? UHDM::uhdmshort_real_typespec
                       : UHDM::uhdmreal_typespec;
        case SymbolKind::EnumType:
            return UHDM::uhdmenum_typespec;
        case SymbolKind::PackedStructType:
        case SymbolKind::UnpackedStructType:
            return UHDM::uhdmstruct_typespec;
        case SymbolKind::StringType:
            return UHDM::uhdmstring_typespec;
        default:
            return UHDM::uhdmunsupported_typespec;
    }
}

// UHDM's ExprEval::size for the typespec Surelog would build for `t` — the
// width adjustOpSize stamps onto a flattened pattern operand.  It is NOT
// slang's bit width: an UNPACKED struct has one (the sum of its members'),
// and a `real` counts 32 bits, not 64 (ExprEval.cpp uhdmreal_typespec).
// Answers -1 for a shape whose width Surelog would call invalid.
static int64_t surelogTsBits(const Type& t) {
    auto& ct = t.getCanonicalType();
    if (ct.isFloating())
        return 32;
    if (ct.isIntegral())
        return (int64_t)ct.getBitWidth();
    if (ct.kind == SymbolKind::UnpackedStructType) {
        int64_t sum = 0;
        for (auto& fm : ct.as<Scope>().members()) {
            if (fm.kind != SymbolKind::Field)
                continue;
            int64_t b = surelogTsBits(fm.getDeclaredType()->getType());
            if (b < 0)
                return -1;
            sum += b;
        }
        return sum;
    }
    if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType) {
        auto& at = ct.as<FixedSizeUnpackedArrayType>();
        int64_t e = surelogTsBits(at.elementType);
        if (e < 0)
            return -1;
        return e * (int64_t)at.range.width();
    }
    return -1;
}

// The value OBJECT a struct-pattern op-75 `rhs` holds for member `mem`
// (declaration index `idx`), or null.  Both shapes a package param's Rhs can
// take are read: the TAGGED listing (match the tagged_pattern whose typespec
// carries the member's name, falling back to the `default:` setter's value —
// which is exactly how Surelog fills an unset member) and the FLATTENED
// positional listing (index by declaration order).
static UHDM::any* patMemberSlot(UHDM::any* rhs, const std::string& mem,
                                int idx) {
    // A param whose whole value is another param (`localparam cfg_s A = B;`)
    // registers a ref_obj chained to B's Rhs — walk the chain to the pattern
    // (BlackParrot `bp_unicore_cfg_p = bp_default_cfg_p`, then
    // `bp_unicore_megaparrot_cfg_p` selecting members off IT).
    for (int g = 0; g < 8 && rhs && rhs->UhdmType() == UHDM::uhdmref_obj; ++g)
        rhs = (UHDM::any*)((UHDM::ref_obj*)rhs)->Actual_group();
    if (!rhs || rhs->UhdmType() != UHDM::uhdmoperation)
        return nullptr;
    auto* op = (UHDM::operation*)rhs;
    if (op->VpiOpType() != 75 || !op->Operands())
        return nullptr;
    auto& ops = *op->Operands();
    UHDM::any* dflt = nullptr;
    bool anyTagged = false;
    for (auto* o : ops) {
        if (o->UhdmType() != UHDM::uhdmtagged_pattern)
            continue;
        anyTagged = true;
        auto* tp = (UHDM::tagged_pattern*)o;
        std::string nm;
        if (tp->Typespec() && tp->Typespec()->Actual_typespec())
            nm = std::string(tp->Typespec()->Actual_typespec()->VpiName());
        if (nm == mem)
            return tp->Pattern();
        if (nm == "default")
            dflt = tp->Pattern();
    }
    if (anyTagged)
        return dflt;
    if (idx >= 0 && idx < (int)ops.size())
        return ops[(size_t)idx];
    return nullptr;
}

// Surelog's substituteAssignedValue reaching THROUGH a struct parameter: a
// package struct-pattern member value written as `OTHER.member` is replaced by
// the value object OTHER's own pattern holds for that member, and a ternary
// over such selects is resolved to the taken branch's object (the
// `(over_p.m == "inv") ? base_p.m : over_p.m` idiom BlackParrot writes ~90
// times per config).  Chains: the answer may itself have come from a previous
// substitution, so `copy_p.m3` lands on `base_p`'s literal.  The lookup runs
// off pkgParamDefRhs, which is registered PER VIEW, so a def-view member value
// resolves against the def listing and an elab one against the elab listing —
// THE LAW, for free.
UHDM::any* UhdmExporter::pkgPatSubstValue(const Expression& expr, int depth) {
    if (depth > 8)
        return nullptr;
    auto& e = stripImplicitConv(expr);
    if (e.kind == ExpressionKind::MemberAccess) {
        auto& ma = e.as<MemberAccessExpression>();
        auto& base = stripImplicitConv(ma.value());
        const Symbol* bs = nullptr;
        if (base.kind == ExpressionKind::NamedValue)
            bs = &base.as<NamedValueExpression>().symbol;
        else if (base.kind == ExpressionKind::HierarchicalValue)
            bs = &base.as<HierarchicalValueExpression>().symbol;
        if (!bs || bs->kind != SymbolKind::Parameter)
            return nullptr;
        auto it = pkgParamDefRhs.find(bs);
        if (it == pkgParamDefRhs.end())
            return nullptr;
        int idx = -1;
        if (ma.member.kind == SymbolKind::Field)
            idx = (int)ma.member.as<FieldSymbol>().fieldIndex;
        return patMemberSlot(it->second, std::string(ma.member.name), idx);
    }
    if (e.kind == ExpressionKind::ConditionalOp) {
        auto& co = e.as<ConditionalExpression>();
        if (co.conditions.size() != 1 || co.conditions[0].pattern)
            return nullptr;
        ASTContext cx(comp.getRoot(), LookupLocation::max);
        ConstantValue pv = cx.tryEval(*co.conditions[0].expr);
        if (!pv || !pv.isInteger() || pv.integer().hasUnknown())
            return nullptr;
        return pkgPatSubstValue(pv.isTrue() ? co.left() : co.right(),
                                depth + 1);
    }
    return nullptr;
}

// True when `e` names a PACKAGE-level variable and the source spells it
// package-QUALIFIED (`p::ch`). Surelog resolves such a reference only as a
// whole: any selector hung off it — `.member`, `.method(...)`, even a
// statement-position call — is DROPPED and the ref_obj alone survives
// (r10apb3 repro 10: `if (p::ch.f(1))`, `p::ch.t();`, `r = p::ch.f(2)` and
// `r = p::ch.x` all collapse to `ref_obj p::ch`, while the identical calls
// through a MODULE-local handle keep their full hier_path shape).
// § blockLocalSameCtrlDepthArgBinds57 — CALL SITE 1 of 3 (the predicate; the
// recorder is StmtEmit.cpp's BlkCtrl57 push, the gate is the bind gate below).
// See UhdmExporter.h's blkCtrlDepth57 for the law and every measured arm cell.
// Three conditions, each one a cell that FAILS without it:
//   (1) the symbol is a plain VARIABLE (b1 g:49 excludes the class property,
//       b1 f:31 the formal — a FormalArgument's parent scope is the
//       subroutine, so (2) already rejects it, and this keeps it explicit);
//   (2) its declaring scope is a STATEMENT BLOCK, not the subroutine body
//       (b1 f:30 `sink(bodyloc)` at depth 1 is golden-bare);
//   (3) that block is UNNAMED (b2 f:24 `nmd::nmdblk`, b3 f:47 `inm::inmv`
//       are golden-bare) and is OPEN at exactly `depth` (b2 f:36, b3 f:64
//       and b4 e1:35 are the depth-MISMATCH cells, all golden-bare).
bool UhdmExporter::blkLocalSameCtrlDepth57(const slang::ast::Symbol& sym) const {
    if (sym.kind != SymbolKind::Variable)
        return false;
    auto* declScope = sym.getParentScope();
    if (!declScope)
        return false;
    auto& declSym = declScope->asSymbol();
    if (declSym.kind != SymbolKind::StatementBlock || !declSym.name.empty())
        return false;
    for (auto it = blkCtrlDepth57.rbegin(); it != blkCtrlDepth57.rend(); ++it)
        if (it->first == (const void*)&declSym)
            return it->second == ctrlBodyDepth28;
    return false;
}

bool UhdmExporter::isPkgQualifiedVarRef(const Expression& e) {
    if (e.kind != ExpressionKind::NamedValue)
        return false;
    auto& nv0 = e.as<NamedValueExpression>();
    if (nv0.symbol.kind != SymbolKind::Variable)
        return false;
    auto* psc0 = nv0.symbol.getParentScope();
    if (!psc0 || psc0->asSymbol().kind != SymbolKind::Package)
        return false;
    // Inside the declaring package the name is written bare and resolves.
    if (pkgViewVarObjs9.count(&nv0.symbol))
        return false;
    std::string pn0(psc0->asSymbol().name);
    return rawText(e.sourceRange).rfind(pn0 + "::", 0) == 0;
}

// § staticScopedCall12 — the identifier token of a simple / parameterized /
// selected name node, used to read the segments of a `::`-scoped name.
static slang::parsing::Token scopedSegId12(const slang::syntax::NameSyntax& n) {
    using SK = slang::syntax::SyntaxKind;
    switch (n.kind) {
        case SK::IdentifierName:
            return n.as<slang::syntax::IdentifierNameSyntax>().identifier;
        case SK::ClassName:
            return n.as<slang::syntax::ClassNameSyntax>().identifier;
        case SK::IdentifierSelectName:
            return n.as<slang::syntax::IdentifierSelectNameSyntax>().identifier;
        default:
            return {};
    }
}

// § staticScopedCall12 — decompose a `::`-scoped name into the FIRST written
// segment and the FINAL identifier, which is all Surelog keeps of it (see the
// law at the call arm).  Returns false when `n` is not a `::` scope.
// `outFirst`/`outLast` are the two identifier texts, `outEnd` the location of
// the final identifier (Surelog's span stops just before it).
static bool splitScopedName12(const slang::syntax::NameSyntax& n,
                              std::string& outFirst, std::string& outLast,
                              slang::SourceLocation& outEnd) {
    if (n.kind != slang::syntax::SyntaxKind::ScopedName)
        return false;
    auto& sn = n.as<slang::syntax::ScopedNameSyntax>();
    if (sn.separator.kind != slang::parsing::TokenKind::DoubleColon)
        return false;
    auto lastTok = scopedSegId12(*sn.right);
    if (!lastTok)
        return false;
    // Left-associative: `a::b::c` is ScopedName(ScopedName(a,b),c).  Walk to
    // the LEFT-most segment; every intermediate one is dropped.
    const slang::syntax::NameSyntax* cur = sn.left;
    for (int g = 0; g < 16; g++) {
        if (cur->kind != slang::syntax::SyntaxKind::ScopedName)
            break;
        auto& s2 = cur->as<slang::syntax::ScopedNameSyntax>();
        if (s2.separator.kind != slang::parsing::TokenKind::DoubleColon)
            return false;
        cur = s2.left;
    }
    auto firstTok = scopedSegId12(*cur);
    if (!firstTok)
        return false;
    outFirst = std::string(firstTok.valueText());
    outLast = std::string(lastTok.valueText());
    outEnd = lastTok.location();
    return true;
}

// § staticScopedRef12 — the `::`-scoped NAME behind an expression's syntax
// node, or null when there is none.  A cast operand carries the PARENTHESES
// (`int'(base::E1)` -> ParenthesizedExpression), so unwrap those first.
static const slang::syntax::NameSyntax* scopedNameSyntax12(
    const slang::syntax::SyntaxNode* n) {
    for (int g = 0; g < 8 && n; g++) {
        if (n->kind == slang::syntax::SyntaxKind::ParenthesizedExpression) {
            n = n->as<slang::syntax::ParenthesizedExpressionSyntax>().expression;
            continue;
        }
        break;
    }
    if (n && n->kind == slang::syntax::SyntaxKind::ScopedName)
        return &n->as<slang::syntax::NameSyntax>();
    return nullptr;
}

// § superMethodCall17 — the `super.<method>` callee syntax, or null.  slang
// binds `super.m(a)` with a NULL thisClass — the lookup resolves straight to
// the base-class SubroutineSymbol — so the receiver survives only in the
// SYNTAX.  Matches EXACTLY `super.<id>`: a deeper `super.a.m()` is Surelog's
// four-way rootName arm (the same split § thisRecvCall11 pins for `this`) and
// is deliberately left alone.  On success `outMethod` is the method
// identifier's range and `outSuper` the `super` keyword's.
static bool superMethodCall17(const slang::syntax::SyntaxNode* n,
                              slang::SourceRange& outSuper,
                              slang::SourceRange& outMethod) {
    if (!n)
        return false;
    if (n->kind == slang::syntax::SyntaxKind::InvocationExpression)
        n = n->as<slang::syntax::InvocationExpressionSyntax>().left;
    if (!n || n->kind != slang::syntax::SyntaxKind::ScopedName)
        return false;
    auto& sn = n->as<slang::syntax::ScopedNameSyntax>();
    if (sn.separator.kind != slang::parsing::TokenKind::Dot)
        return false;
    if (!sn.left || sn.left->kind != slang::syntax::SyntaxKind::SuperHandle)
        return false;
    if (!sn.right || sn.right->kind != slang::syntax::SyntaxKind::IdentifierName)
        return false;
    outSuper = sn.left->sourceRange();
    outMethod = sn.right->sourceRange();
    return true;
}

// § staticScopedRef12 — whether `sym` is declared INSIDE a class (directly or
// through a nested enum/struct scope), which is what makes a `::` reference to
// it a class_scope in Surelog rather than a package_scope.
static bool inClassScope12(const slang::ast::Symbol& sym) {
    const slang::ast::Scope* sc = sym.getParentScope();
    for (int g = 0; g < 8 && sc; g++) {
        auto k = sc->asSymbol().kind;
        if (k == slang::ast::SymbolKind::ClassType)
            return true;
        if (k == slang::ast::SymbolKind::Package ||
            k == slang::ast::SymbolKind::CompilationUnit ||
            k == slang::ast::SymbolKind::InstanceBody ||
            k == slang::ast::SymbolKind::Root)
            return false;
        sc = sc->asSymbol().getParentScope();
    }
    return false;
}

// § staticScopedChainDrops48 — the `::` SCOPE NAME at the root of a chain's
// SYNTAX, or null.  It has to come from the syntax of the WHOLE chain, not from
// the base sub-expression: slang leaves a chained base's `syntax` NULL (measured
// — every `steps>=1` base in t67a printed `syn=-1`), so § scopedNameSyntax12 on
// the base cannot see the `::` at all and the first cut of this law reached
// NOTHING.  `a::b.c.d(x)` parses as InvocationExpression(ScopedName(Dot, ...,
// ScopedName(::, a, b)...)) and `a::b[i]` as ElementSelectExpression over the
// same `::` node, so the walk descends `left` through invocations, selects and
// DOT-separated scoped names and stops at the first DOUBLE-COLON one.
static const slang::syntax::NameSyntax* scopedChainRootName48(
    const slang::syntax::SyntaxNode* n) {
    using SK = slang::syntax::SyntaxKind;
    for (int g = 0; g < 32 && n; g++) {
        switch (n->kind) {
            case SK::ParenthesizedExpression:
                n = n->as<slang::syntax::ParenthesizedExpressionSyntax>()
                        .expression;
                continue;
            case SK::InvocationExpression:
                n = n->as<slang::syntax::InvocationExpressionSyntax>().left;
                continue;
            case SK::ElementSelectExpression:
                n = n->as<slang::syntax::ElementSelectExpressionSyntax>().left;
                continue;
            case SK::ScopedName: {
                auto& sn48 = n->as<slang::syntax::ScopedNameSyntax>();
                if (sn48.separator.kind ==
                    slang::parsing::TokenKind::DoubleColon)
                    return &n->as<slang::syntax::NameSyntax>();
                if (sn48.separator.kind != slang::parsing::TokenKind::Dot)
                    return nullptr;
                n = sn48.left;
                continue;
            }
            default:
                return nullptr;
        }
    }
    return nullptr;
}

// § staticScopedLvalueBad48 — whether this emission really IS an assignment
// TARGET and not merely something emitted while `inLhs` is set.  `inLhs` stays
// true for the whole lvalue subtree, INDEX EXPRESSIONS INCLUDED, and t67e I4
// (`arr[base67::stat.hval] = 3;`) proves the placeholder does NOT reach that
// far: golden puts the READ form there — `ref_obj base67::stat`@46:11-19 as the
// bit_select's vpiIndex — while the lvalue ROOT of the same statement is the
// bit_select itself.  So the gate is the PARENT: only the object the assignment
// hangs its Lhs on becomes `@@BAD_SYMBOL@@`.  A concatenation lvalue
// (`{a, base67::x} = y`) has no golden yet and takes the READ form, which is
// I4's answer rather than a guess.
// NOTE § invalidNewCallFromSyntax55 (predicate half).  GATE: `true` for an
// expression that IS a `new` object-creation in the SOURCE, whether or not slang
// managed to BIND it.
//
// WHY THIS EXISTS.  slang refuses to bind `x = new(...)` in two situations that
// uvm-1.2 hits constantly, and in BOTH it returns `badExpr(comp, nullptr)` — an
// `InvalidExpression` with a NULL child, an EMPTY sourceRange, and the original
// `NewClassExpressionSyntax` still attached (slang attaches syntax to every
// created expression, `Expression::create`'s tail `result->syntax = &syntax;`):
//   (a) the target's type is an ABSTRACT class —
//       slang/source/ast/expressions/AssignmentExpressions.cpp
//       `resolveNewClassTarget`: `if (!isSuperClass && classType->isAbstract) {
//       addDiag(diag::NewVirtualClass); return {nullptr,false}; }`
//   (b) the target's type is NOT A CLASS AT ALL — the same routine's
//       `if (!assignmentTarget || !assignmentTarget->isClass())` ->
//       `diag::NewClassTarget`.
// Both fire inside a GENERIC class's DEFAULT specialization, where the type
// parameter's default is `virtual class uvm_object` / `virtual class
// uvm_component` (case a) or plain `int` (case b, `uvm_built_in_pair
// #(type T1=int, T2=T1)`), and where slang's diagnostics are suppressed — which
// is why the databases still build and the loss is silent.
//
// Surelog never type-checks the construct: it emits the `new` call regardless.
// So did we, for every shape slang BINDS; the whole difference is the bind.
static bool sourceIsNewClassExpr55(const slang::ast::Expression& e) {
    if (e.kind == ExpressionKind::NewClass)
        return true;
    if (e.kind != ExpressionKind::Invalid)
        return false;
    const auto* syn = e.syntax;
    if (!syn || syn->kind != syntax::SyntaxKind::NewClassExpression)
        return false;
    // Only the BARE `new` form.  A SCOPED `new` (`super.new`, `C::new`) reaches
    // this only through paths this pass did not measure, and golden names those
    // "super.new" rather than "new", so they stay unsupported rather than be
    // guessed at.
    const auto& ncs = syn->as<syntax::NewClassExpressionSyntax>();
    return ncs.scopedNew &&
           ncs.scopedNew->kind == syntax::SyntaxKind::ConstructorName;
}

// § typeParamScopedCallRef59 (predicate half) — the `::`-scoped NAME behind an
// expression slang REFUSED TO BIND, or null.
//
// WHY THIS EXISTS.  `<Tparam>::<method>(...)` inside a GENERIC class's DEFAULT
// specialization is unresolvable by construction: the type parameter's default
// is `int` (UVM's `class uvm_registry_common #(type Tregistry=int, type
// Tcreator=int, ...)`), so slang looks `get` up in `int`, finds nothing, and
// returns `badExpr` — an `InvalidExpression` with a NULL child, an EMPTY
// sourceRange, and the original syntax still attached.  Inside a generic class
// slang's diagnostics are suppressed, so the database still builds and the loss
// is SILENT.  Measured: a1_witness reproduces the corpus head in 68 lines and
// slang-uhdm reports exactly `expression kind: Invalid`.
//
// Surelog resolves NOTHING through `::`: its class_scope arm yields a bare
// `ref_obj` named FIRST-SEGMENT `::` FINAL-IDENTIFIER whatever the qualifier
// turns out to be — which is why § staticScopedCall12 already builds exactly
// that object for every shape slang DOES bind, INCLUDING a type parameter bound
// to a class that really has the method (arm a3 S3 / a4 B5+B7: golden and ours
// both `ref_obj Tcreator::get`).  So the whole difference is the BIND, and this
// predicate's only job is to reach the same object from the SYNTAX.
//
// This is deliberately keyed on the SYNTAX being `::`-scoped and NOT on the
// qualifier being a type parameter: arm a4 shows golden emits the identical
// object for all nine bindings a type parameter can take (int, string, bit, a
// virtual class without the method, a class with a NON-static one, `type T`
// with NO DEFAULT, and a `type U = T` chain), and arm a3 shows it does the same
// through a concrete class and a typedef alias.  A qualifier test would have to
// enumerate exactly the set slang fails on, which is the set this predicate
// already IS.
static const slang::syntax::NameSyntax* invalidScopedNameSyntax59(
    const slang::ast::Expression& e) {
    if (e.kind != ExpressionKind::Invalid)
        return nullptr;
    // A CHILD means slang salvaged a sub-expression: the plain unwrap and
    // § droppedCall14 above own those, and this arm must never change a path
    // that already emits something.
    if (e.as<InvalidExpression>().child)
        return nullptr;
    return scopedChainRootName48(e.syntax);
}

static bool assignTargetParent48(const UHDM::BaseClass* p) {
    if (!p)
        return false;
    switch (p->UhdmType()) {
        case UHDM::uhdmassignment:
        case UHDM::uhdmassign_stmt:
        case UHDM::uhdmcont_assign:
            return true;
        default:
            return false;
    }
}

// § staticScopedChainDrops48 — the BASE of a `::`-rooted `.member` / select /
// `.method(...)` CHAIN, or null when there is no such chain.  Surelog's
// expression compiler never resolves THROUGH a `::` scope, so everything hung
// off such a reference — members, element selects, the call and its whole
// argument list — is DISCARDED and the base reference alone survives, in EVERY
// position (t67a/t67b/t67c/t67d, both sides of every cell).  This is the
// CLASS-SCOPE half of the collapse `isPkgQualifiedVarRef` already documents for
// a package-qualified variable; the two share this walk.
//
// THREE gates, each one named by an arm cell that fails without it:
//   * the reference must be WRITTEN with `::` and split by
//     § splitScopedName12 — t67c G9 writes the IDENTICAL chain unqualified
//     (`stat.scope.set_arg(nm)`) from inside the declaring class and golden
//     keeps the full method_func_call/prefix shape there;
//   * the referent must be one the BARE arms already spell `first::last`:
//     declared in a CLASS (§ staticScopedRef12) or a package VARIABLE written
//     with its own package as the first segment (see the second half of this
//     function, and why it is NOT `isPkgQualifiedVarRef`).  t67c G1
//     (`p67::PCFG.a`, a package PARAMETER
//     struct member) keeps a RESOLVED hier_path bound to the parameter and
//     t67b E2 (`p67::PARR[1]`) keeps its bit_select, so a package PARAMETER
//     must not collapse; t67c G10 (`p67::E1.name()`, a package ENUM CONSTANT)
//     is FOLDED to a constant by golden, not collapsed, so it must not either;
//   * there must be at least ONE step — a bare `base67::sint` is
//     § staticScopedRef12's own arm and is already correct.
// A call with a NULL thisClass (`p67::pf67(nm)`, `base67::sfunc()`) is not a
// chain at all: t67b D1..D4 keep their func_call / staticScopedCall12 ref on
// BOTH sides and this walk never reaches them.
const slang::ast::Expression* UhdmExporter::scopedChainDropBase48(
    const slang::ast::Expression& e) {
    using slang::ast::ExpressionKind;
    const slang::ast::Expression* cur = &stripImplicitConv(e);
    int steps48 = 0;
    for (int g = 0; g < 16; g++) {
        if (cur->kind == ExpressionKind::MemberAccess) {
            cur = &stripImplicitConv(
                cur->as<slang::ast::MemberAccessExpression>().value());
            steps48++;
            continue;
        }
        if (cur->kind == ExpressionKind::ElementSelect) {
            cur = &stripImplicitConv(
                cur->as<slang::ast::ElementSelectExpression>().value());
            steps48++;
            continue;
        }
        if (cur->kind == ExpressionKind::RangeSelect) {
            cur = &stripImplicitConv(
                cur->as<slang::ast::RangeSelectExpression>().value());
            steps48++;
            continue;
        }
        if (cur->kind == ExpressionKind::Call) {
            auto& ce48 = cur->as<slang::ast::CallExpression>();
            if (!ce48.thisClass())
                return nullptr;
            cur = &stripImplicitConv(*ce48.thisClass());
            steps48++;
            continue;
        }
        break;
    }
    if (steps48 == 0 || cur->kind != ExpressionKind::NamedValue)
        return nullptr;
    // The chain must be a `::` scope THIS EMITTER can split, because the object
    // the collapse returns is built from that split.
    auto* ns48 = scopedChainRootName48(e.syntax);
    if (!ns48)
        return nullptr;
    std::string f48, l48;
    slang::SourceLocation end48;
    if (!splitScopedName12(*ns48, f48, l48, end48))
        return nullptr;
    auto& nv48 = cur->as<slang::ast::NamedValueExpression>();
    if (inClassScope12(nv48.symbol))
        return cur;
    // The PACKAGE-VARIABLE half, keyed on the FIRST WRITTEN SEGMENT being the
    // declaring package rather than on `isPkgQualifiedVarRef`, whose extra
    // `pkgViewVarObjs9` gate ("inside the declaring package the name is written
    // bare and resolves") is REFUTED for a chain: t67a C12/C13/C14 and t67b
    // E4/E5 write `p67::pkgh...` / `p67::pstruct.a` INSIDE p67 and golden
    // collapses them to `ref_obj p67::pkgh` / `p67::pstruct` exactly as it does
    // from outside (t67c G4).  Reading the qualified name of a package variable
    // through that gate is a SEPARATE residue (t67c G6, § 5 of the README) and
    // is deliberately left alone here — only the CHAIN case moves.
    if (nv48.symbol.kind == slang::ast::SymbolKind::Variable) {
        auto* psc48 = nv48.symbol.getParentScope();
        if (psc48 && psc48->asSymbol().kind == slang::ast::SymbolKind::Package &&
            f48 == std::string(psc48->asSymbol().name))
            return cur;
    }
    return nullptr;
}

// § staticScopedChainDrops48 — the object the collapse returns for a
// CLASS-SCOPED root: § staticScopedRef12's own ref_obj, rebuilt here because
// that arm reads the base sub-expression's syntax and a chained base has none.
// Name = FIRST written segment `::` FINAL `::` identifier (every intermediate
// segment dropped — t67b D5 `p67::base67::stat.scope.set_arg(nm)` -> `p67::stat`),
// span = the scoped name's start up to (NOT including) that final identifier
// (t67a's corpus-shaped C1: `base67::`, 73:7-73:15), UNBOUND (t67d H7 keeps it
// unbound even inside § classArgBind12's window).
UHDM::any* UhdmExporter::scopedChainDropRef48(const slang::ast::Expression& e,
                                              UHDM::BaseClass* parent,
                                              const std::string& prefix) {
    auto* ns48 = scopedChainRootName48(e.syntax);
    if (!ns48)
        return nullptr;
    std::string f48, l48;
    slang::SourceLocation end48;
    if (!splitScopedName12(*ns48, f48, l48, end48))
        return nullptr;
    std::string nm48 = f48 + "::" + l48;
    auto* r48 = s.MakeRef_obj();
    r48->VpiName(nm48);
    r48->VpiFullName(joinRef(prefix, nm48));
    r48->VpiParent(parent);
    setLoc(r48, SourceRange(ns48->sourceRange().start(), end48));
    return r48;
}

// § typeParamScopedCallRef59 — the object.  IDENTICAL in every field to the one
// § staticScopedCall12 builds for the bound case and to the one
// § classPropScopedCallIsRefObj29 builds for a class-property initializer: an
// UNBOUND `ref_obj`, vpiName = FIRST written segment `::` FINAL identifier,
// vpiFullName = the caller's prefix joined to that, span = the scoped name's
// start up to (NOT including) the final identifier — i.e. the qualifier
// `Tregistry::` alone, which is Surelog's class_scope span.
//
// MEASURED SPANS, read off golden rather than derived (arm a2, one spelling per
// row): `Tregistry::get` at 43:21 dumps `line:43:21, endln:43:32` and
// `Tregistry::` is exactly cols 21-31, so the END is the column the final
// identifier STARTS at.  The corpus head agrees to the character:
// `line:14104:24, endln:14104:35` with `get` at column 35.
//
// NOTHING hung off the reference survives — the ARGUMENTS, a `.member` chain, a
// select.  That is not a shortcut: golden drops them too (a2 P9
// `Tregistry::getn(1,"a")` -> one ref_obj `Tregistry::getn`; a2 P10
// `Tregistry::get().ok()` -> one ref_obj `Tregistry::get`; a2 P5
// `Tcreator::create_by_type(Tregistry::get(), nm)` -> ONE ref_obj named
// `Tcreator::create_by_type`, the inner call GONE).  It falls out of building
// the object from the SCOPED NAME alone, which is what Surelog does.
UHDM::any* UhdmExporter::invalidScopedCallRef59(const slang::ast::Expression& e,
                                                UHDM::BaseClass* parent,
                                                const std::string& prefix) {
    auto* ns59 = invalidScopedNameSyntax59(e);
    if (!ns59)
        return nullptr;
    std::string f59, l59;
    slang::SourceLocation end59;
    if (!splitScopedName12(*ns59, f59, l59, end59))
        return nullptr;
    // VERIFIER PROBE (r10uvm59 verify): the ASSIGNMENT-TARGET half.  Golden
    // writes § staticScopedLvalueBad48's `FIRST::@@BAD_SYMBOL@@` over the WHOLE
    // lvalue for a `::` target it cannot resolve, and that does not depend on
    // whether slang bound it: measured on `T::sprop = 3;` inside a generic class
    // (golden `T::@@BAD_SYMBOL@@`@12:7-12:15) and on `nosuchpkg59::sig = 1;`
    // inside an uninstantiated generate block (golden
    // `nosuchpkg59::@@BAD_SYMBOL@@`@6:7-6:23).  Same gate as ExprEmit.cpp:3422.
    // NOTE the second half: § staticScopedLvalueBad48's builder spans
    // `whole.sourceRange`, and an InvalidExpression's sourceRange is EMPTY
    // (that is part of pass 59's own decode), so the placeholder would come out
    // with NO location at all — invisible to uhdm-cmp, which blacklists
    // vpiLineNo/vpiColumnNo, and wrong in the dump.  The SYNTAX range is the
    // whole written lvalue and is what golden's span equals: `T::sprop = 3;`
    // -> 12:7-12:15, `nosuchpkg59::sig = 1;` -> 6:7-6:23.
    if (inLhs && assignTargetParent48(parent)) {
        auto* b59 = scopedLvalueBadRef48(e, parent, prefix);
        if (b59 && e.syntax)
            setLoc(b59, e.syntax->sourceRange());
        return b59;
    }
    std::string nm59 = f59 + "::" + l59;
    auto* r59 = s.MakeRef_obj();
    r59->VpiName(nm59);
    r59->VpiFullName(joinRef(prefix, nm59));
    r59->VpiParent(parent);
    setLoc(r59, SourceRange(ns59->sourceRange().start(), end59));
    return r59;
}

// § staticScopedLvalueBad48 — the ASSIGNMENT-TARGET form of a `::`-written
// reference: Surelog's lvalue resolution fails outright and it writes the
// literal placeholder FIRST-SEGMENT `::@@BAD_SYMBOL@@`, spanning the WHOLE
// written lvalue — not the qualifier-only span the READ form takes.  Measured
// on t67d H1 (`base67::sint = 3;` BARE, no chain: golden
// `base67::@@BAD_SYMBOL@@`@54:7-54:19 where the read form is
// `base67::sint`@54:7-54:15), H3 (`base67::sbits[1] = 1'b1;` a select),
// t67a C9 / t67b D7 / t67b E5 (chains, one to three levels, class-static and
// package-variable alike) and t67d H2/H4 (the package half, whose NAME the
// pre-existing `isPkgQualifiedVarRef` arm already got right).  So the
// placeholder is a property of LVALUE-NESS, not of the chain — which is why
// § staticScopedRef12's own bare arm needed this half too.
UHDM::any* UhdmExporter::scopedLvalueBadRef48(const slang::ast::Expression& whole,
                                              UHDM::BaseClass* parent,
                                              const std::string& prefix) {
    auto* ns48 = scopedChainRootName48(whole.syntax);
    if (!ns48)
        return nullptr;
    std::string f48, l48;
    slang::SourceLocation e48;
    if (!splitScopedName12(*ns48, f48, l48, e48))
        return nullptr;
    std::string nm48 = f48 + "::@@BAD_SYMBOL@@";
    auto* r48 = s.MakeRef_obj();
    r48->VpiName(nm48);
    r48->VpiFullName(joinRef(prefix, nm48));
    r48->VpiParent(parent);
    setLoc(r48, whole.sourceRange);
    return r48;
}

// § classArgBind12 — while a USER subroutine call's ARGUMENTS are emitted,
// a class-method body's refs DO bind their actual.  § classMethodNoBind was
// decoded as "only an if/case CONDITION binds"; t10/t11 show call arguments
// bind too — `sink(f)` / `sink(loc)` / `o.om(f)` / `sink(f + loc)` all carry
// vpiActual to the enclosing method's io_decl or body local, while the same
// names in an assignment stay bare and a CLASS PROPERTY (`sink(prop)`) never
// binds in any position.  SYSTEM calls are the boundary: `$display("%0d", f)`
// binds nothing, so this guard is deliberately NOT applied there.
// A CONCATENATION operand is the one exception measured (t11 `sink({f, loc})`
// leaves both operands bare while `sink(f + loc)` and `sink(-f)` bind both),
// so the depth is a COUNTER the concat arm zeroes rather than a flag — and it
// is kept separate from `classMethodNoBind` itself so the other readers of
// that flag (inheritedNoBind9, the StmtEmit lvalue arms) are untouched.
struct ClassArgBind12 {
    int* p;
    int saved;
    explicit ClassArgBind12(int& d) : p(&d), saved(d) { d = d + 1; }
    ~ClassArgBind12() { *p = saved; }
};
// § superNewFormalBinds28 — the `super.new(...)` argument window.  Kept as a
// separate counter from ClassArgBind12 because the two admit DIFFERENT symbol
// classes: an ordinary call binds formals and body locals, `super.new` binds
// formals alone (t38b `super.new(lb)` / `super.new(p)` stay bare in golden).
struct SuperNewArg28 {
    int* p;
    int saved;
    SuperNewArg28(int& d, bool on) : p(&d), saved(d) {
        if (on) d = d + 1;
    }
    ~SuperNewArg28() { *p = saved; }
};
// § thisRecvCallArgBind38 — the same window, opened only when a predicate says
// so.  The `this.`-rooted call arm (§ thisRecvCall11) never opened one, so the
// arguments of `this.m(f)` stayed bare where every other call form binds them:
// 54 rows of SeqDriver, all of them an INLINE class method whose whole body is
// one such call (uvm_sequence_item / uvm_report_catcher's `uvm_report_*`
// wrappers).  t54a reads all five cells off one golden:
//     this.inner54(y, t);            STATEMENT   -> io_decl:y / io_decl:t
//     return this.inner55(y3);       EXPRESSION  -> BARE (both sides)
//     this.mem54.inner54(y4, t4);    DEEP stmt   -> BARE (both sides)
//     inner54(y2, t2);               control     -> bound (both sides)
//     super.new(nm2);                control     -> bound (both sides)
// so the window needs BOTH gates: STATEMENT position and a DIRECT receiver.
// THE DEEP HALF WAS UNMEASURED BY THE FIRST CUT and it cost more than the law
// won — run on the corpus with the statement gate alone it removed 55 misses
// and added 95 extras (SeqDriver), every one of them a deep call: UVM's TLM
// forwarding macros (`UVM_BLOCKING_GET_IMP(this.m_if, ...)` -> `imp.get(arg)`)
// and uvm_report_catcher's `this.m_modified_report_message.set_id(id)`.  The
// task/function split those extras first suggested was a coincidence of which
// routines happen to be written deep.
struct ClassArgBindIf38 {
    int* p;
    int saved;
    ClassArgBindIf38(int& d, bool on) : p(&d), saved(d) {
        if (on)
            d = d + 1;
    }
    ~ClassArgBindIf38() { *p = saved; }
};
struct ClassArgBindOff12 {
    int* p;
    int saved;
    explicit ClassArgBindOff12(int& d) : p(&d), saved(d) { d = 0; }
    ~ClassArgBindOff12() { *p = saved; }
};
// § classInBodyRecvCallArgNoBind52 — the RECEIVER-QUALIFIED call-argument
// window (see recvCallArgDepth52 in UhdmExporter.h).  It is a SILENCER, the
// mirror of ClassArgBind12: raised around the argument list of every
// EXPRESSION-position `recv.m(args)` our emitter renders as a hier_path, and
// read by the bind gate only when the body is an IN-BODY class method.
struct RecvCallArg52 {
    int* p;
    int saved;
    explicit RecvCallArg52(int& d) : p(&d), saved(d) { d = d + 1; }
    ~RecvCallArg52() { *p = saved; }
};

static void copyLoc(UHDM::BaseClass* dst, const UHDM::BaseClass* src) {
    dst->VpiLineNo(src->VpiLineNo());
    dst->VpiColumnNo(src->VpiColumnNo());
    dst->VpiEndLineNo(src->VpiEndLineNo());
    dst->VpiEndColumnNo(src->VpiEndColumnNo());
}

// The token text of a syntax subtree, trivia dropped. Used where the source
// text of a construct cannot be read as one contiguous slice — a name whose
// components come from a MACRO body plus the file (`CORE0.sig) has no single
// buffer to slice, but its tokens still spell out the expanded text.
static void appendTokenText(const slang::syntax::SyntaxNode& n,
                            std::string& out) {
    for (size_t i = 0; i < n.getChildCount(); i++) {
        if (auto* c = n.childNode(i))
            appendTokenText(*c, out);
        else if (auto t = n.childToken(i))
            out += t.rawText();
    }
}

// True when every name inside a declaration DIMENSION was already resolved
// when the DEFINITION compile built the typespec — i.e. leaves no `ref_obj`
// behind.  A PACKAGE parameter does: packages elaborate before the modules
// that read them, so `logic [pack::W-1:0]` carries a literal bound.  A
// parameter of the enclosing MODULE, or a genvar, does not.  A `$bits(t)` in
// a bound folds at the same compile, so a TYPE name is resolved too.
static bool r9DimNamesResolved(const slang::syntax::SyntaxNode& n,
                               const slang::ast::Scope* scope,
                               bool unitResolves, bool bodyResolves = false) {
    using SK = slang::syntax::SyntaxKind;
    using namespace slang::ast;
    if (n.kind == SK::ScopedName)
        return true; // pkg::W — package-resolved by construction
    if (n.kind == SK::IdentifierName || n.kind == SK::IdentifierSelectName) {
        if (!scope)
            return false;
        std::string_view nm =
            n.kind == SK::IdentifierName
                ? n.as<slang::syntax::IdentifierNameSyntax>()
                      .identifier.valueText()
                : n.as<slang::syntax::IdentifierSelectNameSyntax>()
                      .identifier.valueText();
        auto* sym = scope->lookupName(nm);
        if (!sym)
            return false;
        if (sym->kind == SymbolKind::Genvar)
            return false;
        if (sym->kind != SymbolKind::Parameter &&
            sym->kind != SymbolKind::TypeParameter &&
            sym->kind != SymbolKind::Specparam)
            return true; // a type name, an enum value, a function
        for (auto sc = sym->getParentScope(); sc;
             sc = sc->asSymbol().getParentScope()) {
            auto k = sc->asSymbol().kind;
            if (k == SymbolKind::Package)
                return true;
            // A `$unit`-scope parameter does NOT resolve: Surelog compiles
            // packages before modules (so a package constant IS available to
            // a definition compile) but never substitutes a compilation-unit
            // parameter, so a dimension bound reading one leaves a `ref_obj`
            // in the typespec and `$bits` of that signal stays a
            // sys_func_call.  Measured on `localparam int unsigned W1 = 3;
            // logic [W1-1:0] w;` — `$bits(w)` keeps the call while `$bits(s)`
            // on a plain `logic` folds (Scr1SvTests, 52 first-fails).
            if (k == SymbolKind::CompilationUnit)
                return unitResolves;
            // § elabBitsBodyParamResolves — ...but the ELABORATED listing IS
            // the resolved view: its net/var typespec bounds are folded
            // constants, so `ExprEval::isFullySpecified` answers TRUE there and
            // the same `$bits(<signal>)` that the definition compile left a
            // sys_func_call reduces.  Only a module-BODY parameter flips;
            // `$unit` keeps its own answer (Surelog never substitutes a
            // compilation-unit parameter, in either view).
            if (k == SymbolKind::InstanceBody ||
                k == SymbolKind::GenerateBlock ||
                k == SymbolKind::GenerateBlockArray)
                return bodyResolves;
        }
        return false;
    }
    for (size_t i = 0; i < n.getChildCount(); i++)
        if (auto* c = n.childNode(i))
            if (!r9DimNamesResolved(*c, scope, unitResolves, bodyResolves))
                return false;
    return true;
}

// True when EVERY declaration dimension in the subtree is fully specified.
// This is the syntax-side reading of UHDM `ExprEval::isFullySpecified(tps)`,
// which answers false as soon as the typespec holds a `ref_obj` anywhere —
// and a `ref_obj` gets into a typespec exactly through a dimension bound the
// definition compile could not resolve.
static bool r9DimsLiteral(const slang::syntax::SyntaxNode& n,
                          const slang::ast::Scope* scope,
                          bool unitResolves = true, bool bodyResolves = false) {
    if (n.kind == slang::syntax::SyntaxKind::VariableDimension)
        return r9DimNamesResolved(n, scope, unitResolves, bodyResolves);
    for (size_t i = 0; i < n.getChildCount(); i++)
        if (auto* c = n.childNode(i))
            if (!r9DimsLiteral(*c, scope, unitResolves, bodyResolves))
                return false;
    return true;
}

// Second half of Surelog's def-compile `$bits` test: UHDM's
// `ExprEval::isFullySpecified(tps)` walks the typespec and answers false the
// moment it meets a `ref_obj` — which is how a parameter-dependent dimension
// bound shows up.  Alias chains, struct members and array elements are all
// part of the same typespec, so all three are walked here.
bool UhdmExporter::srlgFullySpecType(const slang::ast::Type& type, int depth) {
    using namespace slang::ast;
    if (depth > 8)
        return false;
    const Type* cur = &type;
    // Every typedef in the chain contributes its own declaration (and its own
    // dimensions) to the typespec.
    while (cur->kind == SymbolKind::TypeAlias) {
        auto& ta = cur->as<TypeAliasType>();
        if (auto* sy = ta.getSyntax())
            if (!r9DimsLiteral(*sy, ta.getParentScope()))
                return false;
        cur = &ta.targetType.getType();
    }
    auto& c = cur->getCanonicalType();
    if (c.kind == SymbolKind::PackedStructType) {
        for (auto& f : c.as<PackedStructType>().membersOfType<FieldSymbol>()) {
            const DeclaredType* dt = f.getDeclaredType();
            const Scope* fsc = f.getParentScope();
            if (auto* ts = dt->getTypeSyntax())
                if (!r9DimsLiteral(*ts, fsc))
                    return false;
            if (auto* ds = dt->getDimensionSyntax())
                for (auto d : *ds)
                    if (!r9DimsLiteral(*d, fsc))
                        return false;
            if (!srlgFullySpecType(f.getType(), depth + 1))
                return false;
        }
        return true;
    }
    if (c.isUnpackedArray() || c.isPackedArray())
        return srlgFullySpecType(*c.getArrayElementType(), depth + 1);
    return true;
}

// True when a declaration bound reads a `$unit`-scope parameter.  Surelog
// never substitutes a compilation-unit parameter, so such a bound stays an
// unfolded operation with a `ref_obj` in EVERY view — the same fact that
// makes `$bits` of such a signal survive (see r9DimNamesResolved).
bool UhdmExporter::syntaxReadsUnitParam(const slang::syntax::SyntaxNode& n,
                                        const slang::ast::Scope* scope) {
    using SK = slang::syntax::SyntaxKind;
    if (unitParamMap.empty() || !scope)
        return false;
    if (n.kind == SK::IdentifierName) {
        auto nm = n.as<slang::syntax::IdentifierNameSyntax>()
                      .identifier.valueText();
        if (auto* sym = scope->lookupName(nm))
            return unitParamMap.count(sym) > 0;
        return false;
    }
    for (size_t i = 0; i < n.getChildCount(); i++)
        if (auto* c = n.childNode(i))
            if (syntaxReadsUnitParam(*c, scope))
                return true;
    return false;
}

// The FIRST `<name>'(...)` size cast under `n`, returned as the cast's own
// type-name node (its span is where Surelog anchors the minted typespec).
// Surelog resolves a cast's type name through the component's type cache: for
// a parameter that carries NO declaration typespec of its own (a COMPUTED
// init — `$clog2(...)`, `A*2`) the lookup MINTS one int_typespec at the first
// cast site, names it after the parameter, hangs a `vpiExpr` ref_obj back on
// it — and that ONE object then serves as the parameter's typespec and as
// every later cast's target.  A LITERAL-init parameter already owns a
// declaration typespec, and its casts mint a SECOND, separate typespec at the
// parameter's name span instead (measured pair: `localparam W = 2` -> ts at
// the decl AND ts at 3:12; `localparam W = $clog2(SZ)` -> ONE ts at the cast).
const slang::syntax::SyntaxNode* UhdmExporter::findParamSizeCast(
    const slang::syntax::SyntaxNode& n, std::string_view name) {
    using SK = slang::syntax::SyntaxKind;
    if (n.kind == SK::CastExpression) {
        auto& ce = n.as<slang::syntax::CastExpressionSyntax>();
        if (ce.left && ce.left->kind == SK::IdentifierName &&
            ce.left->as<slang::syntax::IdentifierNameSyntax>()
                    .identifier.valueText() == name)
            return ce.left;
    }
    for (size_t i = 0; i < n.getChildCount(); i++)
        if (auto* c = n.childNode(i))
            if (auto* r = findParamSizeCast(*c, name))
                return r;
    return nullptr;
}

// How many PACKED dimensions a type declares — Surelog's
// CompileHelper::isMultidimensional reads the same count off the emitted
// typespec's Ranges() (the ParamEmit.cpp copy of this helper carries the
// full note).
static int packedDimCountE(const Type& t) {
    int n = 0;
    const Type* ct = &t.getCanonicalType();
    while (ct->kind == SymbolKind::PackedArrayType) {
        n++;
        ct = &ct->as<PackedArrayType>().elementType.getCanonicalType();
    }
    return n;
}

// Would Surelog's DEFINITION compile fold `$bits(<arg>)`?  `compileBits`
// folds only when `getTypespec()` resolves the argument to a FULLY SPECIFIED
// typespec, and `getTypespec` looks in exactly three places: the built-in
// type keywords, the component's DATA TYPES (typedefs), and its PORTS and
// SIGNALS.  A subroutine formal or local is in none of them, so its `$bits`
// call survives — in the elaborated view too, because UHDM's ExprEval is the
// only thing that re-reduces there and it needs the same typespec.
// Measured on a 33-cell golden matrix across param inits, function bodies,
// initial blocks and cont assigns (r9c3 m2/m3/m4):
//     $bits(w8) [wire [7:0]]      folds   $bits(wp) [wire [OW-1:0]]     keeps
//     $bits(st_t) / $bits(byte_t) folds   $bits(pd_t) [OW-wide member]  keeps
//     $bits(sv.a) / $bits(u8[3:0]) folds  $bits(depth) [function formal] keeps
bool UhdmExporter::srlgBitsFoldArg(const slang::ast::Expression& arg0,
                                   bool elabView) {
    using namespace slang::ast;
    auto& arg = stripImplicitConv(arg0);
    // A TYPE argument always resolves; only full specification is in doubt.
    if (arg.kind == ExpressionKind::DataType)
        return srlgFullySpecType(*arg.type, 0);
    const Expression* root = &arg;
    while (true) {
        auto& r = stripImplicitConv(*root);
        if (r.kind == ExpressionKind::MemberAccess)
            root = &r.as<MemberAccessExpression>().value();
        else if (r.kind == ExpressionKind::ElementSelect)
            root = &r.as<ElementSelectExpression>().value();
        else if (r.kind == ExpressionKind::RangeSelect)
            root = &r.as<RangeSelectExpression>().value();
        else {
            root = &r;
            break;
        }
    }
    const Symbol* sym = nullptr;
    if (root->kind == ExpressionKind::NamedValue)
        sym = &root->as<NamedValueExpression>().symbol;
    else if (root->kind == ExpressionKind::HierarchicalValue)
        sym = &root->as<HierarchicalValueExpression>().symbol;
    if (!sym)
        return false;
    // Ports and signals only. A formal is a FormalArgument, a class property a
    // ClassProperty — neither is reachable from `getTypespec`.
    if (sym->kind != SymbolKind::Net && sym->kind != SymbolKind::Variable)
        return false;
    const Scope* homeBody = nullptr;
    for (auto sc = sym->getParentScope(); sc; sc = sc->asSymbol().getParentScope()) {
        auto k = sc->asSymbol().kind;
        if (k == SymbolKind::Subroutine)
            return false;
        if (k == SymbolKind::InstanceBody) {
            homeBody = sc;
            break;
        }
        if (k == SymbolKind::Package || k == SymbolKind::CompilationUnit)
            break;
    }
    // A PORTLESS module definition does not resolve an UNQUALIFIED typedef
    // name: Surelog's def compile emits the signal as a bare `logic_net` with
    // NO typespec at all, so `ExprEval::isFullySpecified` answers false and
    // `$bits` of that signal — bare or through any member/select chain —
    // stays a `sys_func_call`. Writing the SAME type package-qualified, or
    // giving the module a port list, resolves it and the call folds.
    // Measured as a clean 2x2x2 on one source (probe p21, one struct type
    // reachable three ways x port/no-port):
    //   module wa();            import zz::*; s_t v;  -> KEEPS
    //   module wb(output int o);import zz::*; s_t v;  -> folds
    //   module wc();            u_s_t v ($unit)       -> KEEPS
    //   module wd(output int o);u_s_t v ($unit)       -> folds
    //   module we();            zz::s_t v (qualified) -> folds
    // and cross-checked on p8/p13/p17/p18/p19 (portless + wildcard/`$unit`
    // keep) against p11/p12/p14/p16 (qualified, or ported, fold).
    // HierPathStructTypespec `$bits(hw2reg.status.fifo_depth.d)` in a
    // `module top();` under `import kmac_reg_pkg::*` is the keep side;
    // uhdm2rtlil BitsCallOnStructMember / BitsCallOnSubArray (both
    // `module top(output int o)` with a `pkg::T` declaration) are the fold
    // side.
    if (homeBody) {
        bool hasPort9 = false;
        for (auto& mem9 : homeBody->members())
            if (mem9.kind == SymbolKind::Port ||
                mem9.kind == SymbolKind::MultiPort ||
                mem9.kind == SymbolKind::InterfacePort) {
                hasPort9 = true;
                break;
            }
        if (!hasPort9)
            if (auto* dt9 = sym->getDeclaredType()) {
                auto* tsy9 = dt9->getTypeSyntax();
                bool namedUnqual9 =
                    tsy9 && tsy9->kind == syntax::SyntaxKind::NamedType &&
                    tsy9->as<syntax::NamedTypeSyntax>().name &&
                    tsy9->as<syntax::NamedTypeSyntax>().name->kind !=
                        syntax::SyntaxKind::ScopedName;
                if (namedUnqual9) {
                    // ...only for a typedef the module did NOT declare itself
                    // (a wildcard-imported package one or a `$unit` one);
                    // a module-local typedef resolves in its own scope.
                    auto& at9 = dt9->getType();
                    const Scope* home9 =
                        at9.kind == SymbolKind::TypeAlias ? at9.getParentScope()
                                                          : nullptr;
                    if (home9 && home9 != homeBody &&
                        (home9->asSymbol().kind == SymbolKind::Package ||
                         home9->asSymbol().kind == SymbolKind::CompilationUnit))
                        return false;
                }
            }
    }
    if (auto* dt = sym->getDeclaredType()) {
        const Scope* ssc = sym->getParentScope();
        // The SIGNAL's OWN dimensions are the one place a `$unit` parameter
        // does not resolve: Surelog never substitutes a compilation-unit
        // parameter into a signal declaration, so `logic [W1-1:0] w` keeps a
        // `ref_obj` in its typespec and `$bits(w)` stays a sys_func_call.
        // A TYPEDEF's dimensions are the opposite (they fold at file scope,
        // see buildStructTs) and are walked by srlgFullySpecType with
        // unitResolves left true.
        // § elabBitsBodyParamResolves (r9DimNamesResolved): in the ELABORATED
        // listing a module-body parameter in the signal's own dimensions is
        // already a folded constant, so the call reduces there.
        if (auto* ts = dt->getTypeSyntax())
            if (!r9DimsLiteral(*ts, ssc, /*unitResolves=*/false, elabView))
                return false;
        if (auto* ds = dt->getDimensionSyntax())
            for (auto d : *ds)
                if (!r9DimsLiteral(*d, ssc, /*unitResolves=*/false, elabView))
                    return false;
    }
    return srlgFullySpecType(sym->getDeclaredType()->getType(), 0);
}

// A function that just hands one of its formals back (`f = inp;` /
// `return inp;`). Surelog substitutes such a call for typing purposes, so a
// NESTED call to it carries no formal-ts stamp of its own — the enclosing
// call's stamp falls through to the substituted argument instead. A function
// whose return value is computed (`f = ~inp;`, `f = g(inp);`) keeps the stamp.
static bool isPassThroughFunc(const slang::ast::SubroutineSymbol& sub) {
    using namespace slang::ast;
    const Expression* ret = nullptr;
    std::function<void(const Statement&)> scan = [&](const Statement& st) {
        if (ret)
            return;
        if (st.kind == StatementKind::Return) {
            ret = st.as<ReturnStatement>().expr;
            return;
        }
        if (st.kind == StatementKind::List) {
            for (auto s2 : st.as<StatementList>().list)
                scan(*s2);
            return;
        }
        if (st.kind == StatementKind::Block) {
            scan(st.as<BlockStatement>().body);
            return;
        }
        if (st.kind == StatementKind::ExpressionStatement) {
            auto& e = st.as<ExpressionStatement>().expr;
            if (e.kind == ExpressionKind::Assignment) {
                auto& ae = e.as<AssignmentExpression>();
                auto& lc = ae.left();
                if (lc.kind == ExpressionKind::NamedValue &&
                    &lc.as<NamedValueExpression>().symbol == sub.returnValVar)
                    ret = &ae.right();
            }
        }
    };
    scan(sub.getBody());
    if (!ret)
        return false;
    const Expression* r = ret;
    while (r->kind == ExpressionKind::Conversion &&
           r->as<ConversionExpression>().isImplicit())
        r = &r->as<ConversionExpression>().operand();
    if (r->kind != ExpressionKind::NamedValue)
        return false;
    auto* rs = &r->as<NamedValueExpression>().symbol;
    for (auto a : sub.getArguments())
        if (rs == a)
            return true;
    return false;
}

// The span Surelog gives an rvalue indexed part-select: the WHOLE selector
// text between the brackets. slang's bound bound-expressions drop redundant
// parentheses from their source range (d[(2) +: (4)] -> "2 ... 4"), so take
// the selector syntax node when it is available and fall back to the bound
// expressions otherwise.
static void collectIndexedSelectors(
    const slang::syntax::SyntaxNode& n,
    std::vector<const slang::syntax::SyntaxNode*>& out) {
    if (n.kind == slang::syntax::SyntaxKind::AscendingRangeSelect ||
        n.kind == slang::syntax::SyntaxKind::DescendingRangeSelect) {
        out.push_back(&n);
        return;
    }
    for (size_t i = 0, c = n.getChildCount(); i < c; i++)
        if (auto* ch = n.childNode(i))
            collectIndexedSelectors(*ch, out);
}

static slang::SourceRange rangeSelectorSpan(
    const slang::ast::RangeSelectExpression& rs) {
    slang::SourceRange fallback(rs.left().sourceRange.start(),
                                rs.right().sourceRange.end());
    if (!rs.syntax)
        return fallback;
    std::vector<const slang::syntax::SyntaxNode*> sels;
    collectIndexedSelectors(*rs.syntax, sels);
    if (sels.size() != 1)
        return fallback;
    auto r = sels.front()->sourceRange();
    if (r.start() == slang::SourceLocation::NoLocation ||
        r.end() == slang::SourceLocation::NoLocation)
        return fallback;
    return r;
}

// Stamp vpiInstance on EVERY typespec of a freshly built aggregate CLONE
// tree. Surelog re-elaborates a cast target in the ELABORATED package's
// context, so the whole tree — the anonymous member vectors included — is
// instanced there; our per-member builders stamp only some of them, and the
// ones they do stamp inherit the def object's instance (jeras_union
// op32_t'(ins)). Safe only on a fresh clone tree (castAggCloneCtx).
static void stampCloneTreeInstance(UHDM::typespec* ts, UHDM::instance* inst,
                                   int depth = 0) {
    if (!ts || !inst || depth > 8)
        return;
    ts->Instance(inst);
    if (ts->UhdmType() == UHDM::uhdmlogic_typespec) {
        if (auto* al = ((UHDM::logic_typespec*)ts)->Typedef_alias())
            stampCloneTreeInstance(al->Actual_typespec(), inst, depth + 1);
        return;
    }
    UHDM::VectorOftypespec_member* mems = nullptr;
    if (ts->UhdmType() == UHDM::uhdmstruct_typespec)
        mems = ((UHDM::struct_typespec*)ts)->Members();
    else if (ts->UhdmType() == UHDM::uhdmunion_typespec)
        mems = ((UHDM::union_typespec*)ts)->Members();
    if (!mems)
        return;
    for (auto* m : *mems) {
        if (!m->Typespec())
            continue;
        stampCloneTreeInstance(m->Typespec()->Actual_typespec(), inst,
                               depth + 1);
    }
}

// A selector's source text used inside a hier_path/select NAME drops
// whitespace (mem[i][ 7: 0] -> [7:0]): Surelog normalizes the range in the
// object name even when the source spaced it.
// Surelog's decompiler renders binary arithmetic operators inside index
// text with surrounding single spaces (sram_otp_key_o[2-2] -> [2 - 2]).
// Leaves unary +/- (at `[` or start) and already-spaced text alone; a plain
// literal/identifier index (no operator) is untouched.
static std::string spaceIdxOps(const std::string& in) {
    std::string o;
    for (size_t i = 0; i < in.size(); i++) {
        char c = in[i];
        if ((c == '+' || c == '-' || c == '*' || c == '/') && i > 0 &&
            in[i - 1] != ' ' && in[i - 1] != '[' &&
            !((c == '+' || c == '-') && i + 1 < in.size() && in[i + 1] == ':')) {
            o += ' ';
            o += c;
            if (i + 1 < in.size() && in[i + 1] != ' ')
                o += ' ';
        }
        else
            o += c;
    }
    return o;
}

// A hier_path index that REDUCES renders the reduced value in the path NAME
// (Surelog names the path from the elaborated select):
// bus_if.access[RGGEN_ACCESS_DATA_BIT] -> bus_if.access[0].  Only a
// WILDCARD-IMPORTED package parameter reduces here — a module-local localparam
// index stays an unfolded ref_obj, name and all, and a QUALIFIED pkg::P read
// keeps its text too (measured against Surelog: `access[L]` keeps `L`).
// Returns the empty string when the index does not reduce.
static std::string reducedImportedIdx(
    const Expression& sel, const std::string& rawIdx,
    slang::ast::Compilation& comp,
    const std::map<const slang::ast::Symbol*, UHDM::typespec*>& importedTs) {
    auto& s9 = stripImplicitConv(sel);
    if (s9.kind != ExpressionKind::NamedValue ||
        rawIdx.find("::") != std::string::npos ||
        !importedTs.count(&s9.as<NamedValueExpression>().symbol))
        return {};
    ASTContext ctx9(comp.getRoot(), LookupLocation::max);
    ConstantValue cv9 = ctx9.tryEval(s9);
    if (!cv9 || !cv9.isInteger() || cv9.integer().hasUnknown())
        return {};
    return cv9.integer().toString(slang::LiteralBase::Decimal, false);
}

// True when the enclosing instance's parameter object for `name` carries NO
// typespec — an UNTYPED parameter whose initializer is COMPUTED rather than
// literal (`parameter AW = $clog2(DEPTH)`), for which Surelog stores neither a
// value nor a type.  A gen-scope reduce of such a parameter cannot go through
// a declared type, so it yields the plain unsized 64-bit UINT instead of the
// width-sized, typespec-carrying constant a literal-initialised parameter
// gets (BasicOh: `wr_din[N-1:0]` folds typed, `rd_addr[AW-1:0]` folds bare).
static bool typelessParamObj(const UHDM::BaseClass* from,
                             std::string_view name) {
    const UHDM::BaseClass* w = from;
    while (w && w->UhdmType() != UHDM::uhdmmodule_inst)
        w = w->VpiParent();
    if (!w)
        return false;
    auto* mi = (const UHDM::module_inst*)w;
    if (!mi->Parameters())
        return false;
    for (auto* pp : *mi->Parameters())
        if (pp->UhdmType() == UHDM::uhdmparameter && pp->VpiName() == name)
            return ((const UHDM::parameter*)pp)->Typespec() == nullptr;
    return false;
}

static std::string selName(std::string s) {
    // Surelog strips whitespace ADJACENT to select punctuation ([ ] : and
    // the +:/-: tokens) but keeps single spaces inside arithmetic
    // subexpressions (key[0][i * 32+:32] — IndexedPartSelectInFor).
    std::string o;
    for (size_t i = 0; i < s.size(); i++) {
        char c = s[i];
        if (c == ' ' || c == '\t') {
            size_t j = i;
            while (j < s.size() && (s[j] == ' ' || s[j] == '\t'))
                j++;
            char prev = o.empty() ? '\0' : o.back();
            char next = j < s.size() ? s[j] : '\0';
            bool nextSel = next == '[' || next == ']' || next == ':' ||
                           ((next == '+' || next == '-') && j + 1 < s.size() &&
                            s[j + 1] == ':');
            bool prevSel = prev == '[' || prev == ':';
            if (!nextSel && !prevSel && next != '\0')
                o += ' ';
            i = j - 1;
            continue;
        }
        o += c;
    }
    return o;
}

// § concatIdxDecompile29 (the decoded table and the gate are in the
// declaration comment, include/UhdmExporter.h) — the text between the LAST
// top-level brackets of a select's spelling: `w[3:0]` -> `3:0`,
// `w[1+:2]` -> `1+:2`.  Returns "" when the text has no bracket group.
static std::string lastBracketBody(const std::string& t) {
    size_t close = std::string::npos;
    for (size_t i = t.size(); i-- > 0;)
        if (t[i] == ']') {
            close = i;
            break;
        }
    if (close == std::string::npos)
        return {};
    int depth = 0;
    for (size_t i = close; i-- > 0;) {
        if (t[i] == ']')
            depth++;
        else if (t[i] == '[') {
            if (!depth)
                return t.substr(i + 1, close - i - 1);
            depth--;
        }
    }
    return {};
}

// § concatIdxDecompile29 — the SELECT-element classifier.  Walks a select chain
// down to its base and reports how many element-select levels sit above that
// base, so the three measured select renderings can be told apart:
//   base reached through a MEMBER ACCESS or a HIERARCHICAL name  -> EMPTY
//   one element-select level over a simple name (`w[2]`)         -> EMPTY
//   two or more levels over a simple name (`m[1][2]`)            -> full text
// A range select over a simple name renders its range alone and is handled by
// the caller, which needs the range text rather than a level count.
struct SelBaseInfo {
    bool simpleBase = false;  // the chain bottoms out at a plain local name
    int elemLevels = 0;       // element-select levels above that name
};
static SelBaseInfo selBaseInfo(const Expression& e) {
    SelBaseInfo r;
    const Expression* cur = &stripImplicitConv(e);
    while (true) {
        if (cur->kind == ExpressionKind::ElementSelect) {
            r.elemLevels++;
            cur = &stripImplicitConv(cur->as<ElementSelectExpression>().value());
        }
        else if (cur->kind == ExpressionKind::RangeSelect) {
            cur = &stripImplicitConv(cur->as<RangeSelectExpression>().value());
        }
        else
            break;
    }
    r.simpleBase = cur->kind == ExpressionKind::NamedValue;
    return r;
}

// § concatIdxDecompile29 — one node of Surelog's index decompiler.  Appends this
// node's rendering to `out` and returns TRUE; returns FALSE for a node kind the
// grid did not measure, which aborts the whole index so the caller keeps its
// raw text rather than shipping a guessed spelling.  Rendering the EMPTY STRING
// is a SUCCESS (`return true` with nothing appended) — that is the measured
// behaviour for a hier reference, a bit select, a user call and a cast, and it
// is what leaves golden's bare comma behind.
bool UhdmExporter::idxDecompile(const Expression& e0, std::string& out) {
    auto& e = stripImplicitConv(e0);
    switch (e.kind) {
        // ---- renders as its own written spelling
        case ExpressionKind::IntegerLiteral:
        case ExpressionKind::UnbasedUnsizedIntegerLiteral:
            out += selName(rawText(e.sourceRange));
            return true;
        case ExpressionKind::NamedValue: {
            auto& sym = e.as<NamedValueExpression>().symbol;
            // MEASURED ABSTENTION: a wildcard-imported package parameter is
            // reduced by golden to a SIZED literal (b3_edges o1, `PP` -> `2'd1`),
            // which is neither the identifier nor the decimal value
            // § hierSelPkgParamFold splices for a whole-index fold.  Abstain.
            if (importedParamDefTs.count(&sym))
                return false;
            out += sym.name;
            return true;
        }
        // ---- renders EMPTY: the decompiler has no case for these
        case ExpressionKind::HierarchicalValue:  // u.x            (b3_edges o5)
        case ExpressionKind::MemberAccess:       // rq.addr        (a1_hp2 o3)
            return true;
        case ExpressionKind::Conversion:
            // FIXED AT INTEGRATION (verifier F1, the severest finding, and it
            // made a name STRICTLY WORSE THAN BASE).  This arm returned true
            // (render EMPTY) for EVERY conversion that survived
            // `stripImplicitConv`, on the model that a surviving conversion is
            // a written cast.  FALSE: the strip removes `isImplicit()` =
            // Implicit AND Propagated (ConversionExpression.h:28, enum order
            // Implicit/Propagated/StreamingConcat/Explicit/BitstreamCast), so
            // what survives is any of the OTHER THREE kinds — and slang wraps
            // the string literal of `q.m[{"a_chan_", s}]` (arm v10_str.sv) in
            // exactly such a conversion.  Measured: golden
            // `q.m[{"a_chan_",s}]` (the literal RENDERED), base ONE space off,
            // the un-gated arm shipped `q.m[{,s}]` — the literal DELETED.
            // The one measured EMPTY cell (b3_edges o3, `2'(k)`) is a WRITTEN
            // cast, so the gate is the SYNTAX: only a written CastExpression
            // renders EMPTY; every other surviving conversion ABSTAINS,
            // keeping the whole index's raw text (base behaviour, never
            // worse).  Named real carriers of the string shape (all
            // SLANG_REJECT today): Opentitan tlul xbar_env.sv:79/81/85/87.
            return e.syntax &&
                           e.syntax->kind == syntax::SyntaxKind::CastExpression
                       ? true   // written cast -> EMPTY (b3_edges o3)
                       : false; // anything else -> ABSTAIN (F1)
        case ExpressionKind::Call:
            // A SYSTEM call renders its own spelling ($clog2(4), $signed(k)); a
            // USER call renders EMPTY (a1_hp2 o8, `fx(k)`).  Only a
            // single-argument system call is measured, so a spelling carrying an
            // argument separator or any space abstains rather than guess.
            if (!e.as<CallExpression>().isSystemCall())
                return true;
            {
                std::string t = rawText(e.sourceRange);
                if (t.empty() || t.find(',') != std::string::npos ||
                    t.find(' ') != std::string::npos)
                    return false;
                out += t;
            }
            return true;
        // ---- structural nodes
        case ExpressionKind::Concatenation: {
            out += '{';
            bool first = true;
            for (auto* op : e.as<ConcatenationExpression>().operands()) {
                if (!first)
                    out += ',';  // NO space, whatever the source wrote
                first = false;
                if (!idxDecompile(*op, out))
                    return false;
            }
            out += '}';
            return true;
        }
        case ExpressionKind::Replication: {
            // Surelog holds the repeated part as a CONCATENATION, so it renders
            // with braces of its own and the whole node DOUBLES them:
            // `{2{1'b1}}` -> `{2{{1'b1}}}` (a1_hp2 o7, b3_edges o6).
            auto& r = e.as<ReplicationExpression>();
            out += '{';
            if (!idxDecompile(r.count(), out))
                return false;
            out += '{';
            if (!idxDecompile(r.concat(), out))
                return false;
            out += "}}";
            return true;
        }
        case ExpressionKind::BinaryOp: {
            auto& b = e.as<BinaryExpression>();
            const char* op = nullptr;
            switch (b.op) {
                case BinaryOperator::Add: op = "+"; break;
                case BinaryOperator::Subtract: op = "-"; break;
                case BinaryOperator::Multiply: op = "*"; break;
                case BinaryOperator::Divide: op = "/"; break;
                default: return false;  // unmeasured operator
            }
            if (!idxDecompile(b.left(), out))
                return false;
            out += ' ';
            out += op;
            out += ' ';
            return idxDecompile(b.right(), out);
        }
        case ExpressionKind::UnaryOp: {
            auto& u = e.as<UnaryExpression>();
            if (u.op != UnaryOperator::BitwiseNot)
                return false;  // unmeasured operator
            out += '~';
            return idxDecompile(u.operand(), out);
        }
        case ExpressionKind::ConditionalOp: {
            auto& c = e.as<ConditionalExpression>();
            if (c.conditions.size() != 1 || c.conditions[0].pattern)
                return false;  // unmeasured (pattern / multi-condition) form
            if (!idxDecompile(*c.conditions[0].expr, out))
                return false;
            out += " ? ";
            if (!idxDecompile(c.left(), out))
                return false;
            out += " : ";
            return idxDecompile(c.right(), out);
        }
        // ---- selects: three measured renderings, told apart by the base
        case ExpressionKind::RangeSelect: {
            // The RANGE ALONE, base name dropped (a1_hp2 o4 `w[3:0]` -> `3:0`,
            // b3_edges o2 `w[1+:2]` -> `1+:2`); EMPTY when the base is reached
            // through a member access (a1_hp2 o10 `rq.addr[3:0]`).
            // GATE TIGHTENED AT INTEGRATION (verifier F2): the original test
            // was `simpleBase` alone, which cannot tell `w[3:0]` (range over a
            // plain name -> range alone) from `m[1][3:0]` (range over a
            // MULTI-LEVEL element select -> golden renders it IN FULL, arm
            // v2_sel o1: golden `{1'b1,m[1][3:0]}`, the un-gated arm shipped
            // `{1'b1,3:0}` — the base name LOST, strictly worse than base).
            // Correct gate, verifier-specified: simpleBase AND elemLevels==0;
            // anything else ABSTAINS (whole-index raw text, base behaviour) —
            // the full-text rendering golden uses there is UNMEASURED beyond
            // one cell, so it is not guessed at.
            auto rinfo = selBaseInfo(e);
            if (!rinfo.simpleBase)
                return true;
            if (rinfo.elemLevels != 0)
                return false;  // F2: range over element select -> ABSTAIN
            std::string body = lastBracketBody(rawText(e.sourceRange));
            if (body.empty())
                return false;
            out += selName(body);
            return true;
        }
        case ExpressionKind::ElementSelect: {
            auto info = selBaseInfo(e);
            if (!info.simpleBase)
                return true;  // rq.addr[0] and friends render EMPTY
            if (info.elemLevels < 2)
                return true;  // a single-level bit select renders EMPTY (o5)
            // Two or more levels render in FULL (a1_hp2 o9, `m[1][2]`).
            std::string t = selName(rawText(e.sourceRange));
            if (t.empty())
                return false;
            out += t;
            return true;
        }
        default:
            return false;  // an unmeasured node kind abstains
    }
}

// § concatIdxDecompile29 — THE GATE.  The index's TOP-LEVEL expression must be a
// CONCATENATION; every other index keeps the caller's raw-text rendering.  A
// top-level REPLICATION is deliberately excluded: the grid measured replication
// only as an ELEMENT, never as a whole index.
std::string UhdmExporter::concatIdxText(const Expression& sel) {
    auto& s9 = stripImplicitConv(sel);
    if (s9.kind != ExpressionKind::Concatenation)
        return {};
    std::string out;
    if (!idxDecompile(s9, out))
        return {};
    return out;
}

// § macroExpandedText tail — the SELECT BASE's spelling cut out of the whole
// select's expanded spelling.  A HierarchicalValue produced inside a macro body
// (`RIF.read_data[__i]`, RIF substituted) carries no syntax node of its own, so
// neither `rawText` nor `rawTextExp` can name it; but the enclosing select DOES
// have syntax, and its expanded text minus the final top-level `[...]` group is
// exactly the base. Returns "" when the text has no top-level bracket group.
static std::string selBaseText(const std::string& whole) {
    int depth = 0;
    size_t cut = std::string::npos;
    for (size_t i = 0; i < whole.size(); i++) {
        if (whole[i] == '[') {
            if (depth == 0)
                cut = i;
            depth++;
        }
        else if (whole[i] == ']')
            depth--;
    }
    return cut == std::string::npos ? std::string() : whole.substr(0, cut);
}

// § castTgtDefaultIsLiteral — is the parameter's DECLARED default a literal?
//
// `P'(x)` is resolved by Surelog's DEFINITION compile, which knows only what
// the declaration says: a literal default (`parameter int W = 8`) folds there
// and the cast mints a FRESH valued int_typespec named after W, while a default
// that names another parameter (`parameter int VALUE_WIDTH = BUS_WIDTH`) cannot
// reduce and the cast instead REUSES W's own declaration typespec, stamping the
// vpiExpr ref_obj back onto it.  slang's bound initializer is the ELABORATED
// one — for an instantiated module that is the caller's override expression, so
// reading it flips the verdict on exactly the modules that get instantiated.
// Read the declarator's initializer SYNTAX instead, which is the declaration.
bool UhdmExporter::castTgtDefaultIsLiteral(const ParameterSymbol& ps) {
    auto* syn = ps.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::Declarator)
        return ps.getInitializer() &&
               isLiteralExpr(stripImplicitConv(*ps.getInitializer()));
    auto* init = syn->as<syntax::DeclaratorSyntax>().initializer;
    if (!init || !init->expr)
        return false;
    const syntax::ExpressionSyntax* e = init->expr;
    while (e->kind == syntax::SyntaxKind::ParenthesizedExpression)
        e = e->as<syntax::ParenthesizedExpressionSyntax>().expression;
    switch (e->kind) {
        case syntax::SyntaxKind::IntegerLiteralExpression:
        case syntax::SyntaxKind::IntegerVectorExpression:
        case syntax::SyntaxKind::RealLiteralExpression:
        case syntax::SyntaxKind::TimeLiteralExpression:
        case syntax::SyntaxKind::StringLiteralExpression:
        case syntax::SyntaxKind::UnbasedUnsizedLiteralExpression:
        case syntax::SyntaxKind::NullLiteralExpression:
        case syntax::SyntaxKind::WildcardLiteralExpression:
            return true;
        default:
            return false;
    }
}

const Expression* UhdmExporter::unpackedParamPatternLeaf(const Expression& sel) {
    // Walk the select chain down to the base symbol, recording each
    // selector together with the ARRAY type it indexes.
    std::vector<std::pair<const Expression*, const Type*>> chain;
    const Expression* cur = &stripImplicitConv(sel);
    while (cur->kind == ExpressionKind::ElementSelect) {
        auto& es = cur->as<ElementSelectExpression>();
        auto& base = stripImplicitConv(es.value());
        if (!base.type)
            return nullptr;
        chain.push_back({&es.selector(), &base.type->getCanonicalType()});
        cur = &base;
    }
    if (chain.empty() || cur->kind != ExpressionKind::NamedValue)
        return nullptr;
    auto& bsym = cur->as<NamedValueExpression>().symbol;
    if (bsym.kind != SymbolKind::Parameter)
        return nullptr;
    auto dt = bsym.getDeclaredType();
    const Expression* pat = dt ? dt->getInitializer() : nullptr;
    if (!pat)
        return nullptr;
    pat = &stripImplicitConv(*pat);
    ASTContext ctx(comp.getRoot(), LookupLocation::max);
    for (auto it = chain.rbegin(); it != chain.rend(); ++it) {
        if (pat->kind != ExpressionKind::SimpleAssignmentPattern)
            return nullptr;
        if (it->second->kind != SymbolKind::FixedSizeUnpackedArrayType)
            return nullptr;
        ConstantValue icv = ctx.tryEval(*it->first);
        if (!icv || !icv.isInteger() || icv.integer().hasUnknown())
            return nullptr;
        auto iopt = icv.integer().as<int32_t>();
        if (!iopt)
            return nullptr;
        // The LEFTMOST pattern element takes the range's LEFT index; the
        // rest follow toward the right bound (either direction).
        auto rng = it->second->as<FixedSizeUnpackedArrayType>().range;
        int64_t pos = (int64_t)*iopt - (int64_t)rng.left;
        if (pos < 0)
            pos = -pos;
        auto els = pat->as<SimpleAssignmentPatternExpression>().elements();
        if (pos >= (int64_t)els.size())
            return nullptr;
        pat = &stripImplicitConv(*els[(size_t)pos]);
    }
    return pat;
}

// § srlgUnbasedReduceBail (r10oth2, DIRECTION A = golden FOLDS, we did not).
//
// Models WHEN Surelog's reducer actually gives up on an expression containing an
// unbased-unsized literal ('0 / '1 / 'x / 'z).  Such a literal becomes, in
// Surelog, a `constant` with **VpiSize() == -1** and VpiValue "BIN:0"/"BIN:1"/
// "BIN:X"/"BIN:Z", and only TWO things in UHDM's ExprEval then fail.  Both are
// transcribed from Surelog/third_party/UHDM/templates/ExprEval.cpp:
//
//   (1) THE SHIFTS, and only the shifts, reject an unsized LEFT operand.
//       `case vpiArithLShiftOp: case vpiLShiftOp:` (:3137) and
//       `case vpiArithRShiftOp: case vpiRShiftOp:` (:3050) both open with
//           expr* arg0 = reduceExpr(operands[0], ...);
//           if (arg0 && arg0->UhdmType() == uhdmconstant)
//               if (((constant*)arg0)->VpiSize() == -1) invalidValue = true;
//       The shift AMOUNT (operands[1]) is NOT checked, so `8 << '0` folds while
//       `'0 << 8` does not — measured, arm A2 rows s5 vs r1/s3/s4/s6.
//
//   (2) An UNKNOWN unbased literal poisons any operator that reads its VALUE.
//       `get_value` (:1946) / `get_uvalue` (:2057) parse a vpiBinaryConst with
//       NumUtils::parseBinary and, with `strict` defaulted to TRUE
//       (ExprEval.h:97/99), set invalidValue when the parse fails — which it
//       does for any X or Z digit.  '0 and '1 parse fine and fold.  Measured:
//       `'0 + 1` -> UINT:1, `'X + 1` -> operation (A1 r6 vs r5).
//
// NEITHER failure is syntactic, which is the whole point of the law:
//   * `case vpiConditionOp:` (:3763) reduces the CONDITION, then reduces ONLY
//     THE SELECTED ARM.  An 'X (or an unfoldable shift) in the UNTAKEN arm is
//     never read, so the ternary folds — arm A1 r2/r4, arm A3 n2.  This is
//     exactly why BlackParrotComplex's localparam folds in golden.
//   * `case vpiConcatOp:` (:3882) walks BITS instead of calling get_value, so a
//     concat over 'X folds to a BIN constant with X bits — arm A2 u5.
//
// The walk therefore mirrors the reducer instead of scanning the syntax.  Every
// expression kind NOT modelled here keeps the PRE-r10oth2 answer (bail), so the
// change is a strict NARROWING: it can only ever ADD folds, never remove one.
namespace {
struct SrlgUnbasedRed {
    bool bails = false;    // Surelog's reduce would set invalidValue
    bool unsized = false;  // reduces to a constant with VpiSize() == -1
    bool unknown = false;  // reduces to a value carrying X/Z bits
};
}  // namespace

// True when an unbased-unsized literal is WRITTEN anywhere inside `e`.  Used
// both as the law's precondition and as the conservative default for a shape
// the reduce model does not cover.
static bool srlgHasUnbasedLit(const Expression& e) {
    bool hit = false;
    e.visit(makeVisitor([&](auto& v, const UnbasedUnsizedIntegerLiteral& u) {
        hit = true;
        v.visitDefault(u);
    }));
    return hit;
}

static SrlgUnbasedRed srlgUnbasedReduce(Compilation& comp, const Expression& e0,
                                        int depth) {
    SrlgUnbasedRed r;
    const Expression& e = stripImplicitConv(e0);
    // No unbased literal in this subtree: nothing here can trip either rule,
    // and the whole predicate is only ever consulted on a tree that has one.
    if (!srlgHasUnbasedLit(e))
        return r;
    if (depth > 24) {
        r.bails = true;
        return r;
    }
    auto rec = [&](const Expression& sub) {
        return srlgUnbasedReduce(comp, sub, depth + 1);
    };
    switch (e.kind) {
        case ExpressionKind::UnbasedUnsizedIntegerLiteral: {
            r.unsized = true;
            r.unknown = e.as<UnbasedUnsizedIntegerLiteral>()
                            .getLiteralValue()
                            .isUnknown();
            return r;
        }
        case ExpressionKind::ConditionalOp: {
            auto& co = e.as<ConditionalExpression>();
            // Only the plain single-predicate form is modelled; a pattern
            // condition keeps the pre-r10oth2 answer.
            if (co.conditions.size() != 1 || co.conditions[0].pattern) {
                r.bails = true;
                return r;
            }
            auto& pred = *co.conditions[0].expr;
            // `get_value(invalidValue, cond); if (invalidValue) break;` — an
            // unresolvable condition is itself a bail, and so is one poisoned
            // by rule (2).
            auto pi = rec(pred);
            if (pi.bails || pi.unknown) {
                r.bails = true;
                return r;
            }
            ASTContext cx(comp.getRoot(), LookupLocation::max);
            ConstantValue pv = cx.tryEval(pred);
            if (!pv || !pv.isInteger() || pv.integer().hasUnknown()) {
                r.bails = true;
                return r;
            }
            // ...and then ONLY the selected arm is reduced.  Its shape passes
            // through unchanged — arm A3 c1 proves a size(-1) arm is NOT
            // re-encoded (`((a<b) ? '0 : '1) << 1` still refuses to fold).
            return rec(pv.isTrue() ? co.left() : co.right());
        }
        case ExpressionKind::BinaryOp: {
            auto& be = e.as<BinaryExpression>();
            auto li = rec(be.left());
            auto ri = rec(be.right());
            bool shift = be.op == BinaryOperator::LogicalShiftLeft ||
                         be.op == BinaryOperator::LogicalShiftRight ||
                         be.op == BinaryOperator::ArithmeticShiftLeft ||
                         be.op == BinaryOperator::ArithmeticShiftRight;
            if (shift)
                // Rule (1): the size(-1) test is on operands[0] ONLY.  The
                // amount still goes through get_value, hence ri.unknown.
                r.bails = li.bails || ri.bails || li.unsized || li.unknown ||
                          ri.unknown;
            else
                // Every other binary operator reads both operands' VALUES.
                r.bails = li.bails || ri.bails || li.unknown || ri.unknown;
            return r;  // the result constant is sized and known
        }
        case ExpressionKind::UnaryOp: {
            auto oi = rec(e.as<UnaryExpression>().operand());
            r.bails = oi.bails || oi.unknown;
            return r;
        }
        case ExpressionKind::Concatenation: {
            // Rule (2) does NOT apply here: vpiConcatOp assembles BITS, so X/Z
            // survive into a BIN constant instead of failing a parse.  The
            // unknownness therefore PROPAGATES to the result rather than
            // bailing — arm A2 u5 `{'X, 1'b1}` -> BIN:X1 size 2.
            for (auto* op : e.as<ConcatenationExpression>().operands()) {
                auto oi = rec(*op);
                r.bails = r.bails || oi.bails;
                r.unknown = r.unknown || oi.unknown;
            }
            return r;
        }
        case ExpressionKind::Replication: {
            // vpiMultiConcatOp (:3797) DOES run the repeat COUNT through
            // get_value, so an unknown count bails; the replicated value is
            // assembled bitwise like a concat.
            auto ci = rec(e.as<ReplicationExpression>().count());
            auto vi = rec(e.as<ReplicationExpression>().concat());
            r.bails = ci.bails || ci.unknown || vi.bails;
            r.unknown = vi.unknown;
            return r;
        }
        default:
            // Not modelled — keep the pre-r10oth2 refusal.
            r.bails = true;
            return r;
    }
}

// NOTE (§ srlgFoldNaturalWidth, r10oth4) — the width a NON-PARAMETER concat /
// replication fold lands on.
//
// Surelog's reduce builds the constant at the expression's NATURAL
// (self-determined) width — `case vpiMultiConcatOp` sets
// `c->VpiSize(n * width)` and `case vpiConcatOp` sums its operands, both in
// UHDM/templates/ExprEval.cpp — and only THEN clamps it against the assignment
// target in `CompileHelper::adjustSize`
// (Surelog/src/DesignCompile/CompileHelper.cpp:3949).  THE GATE is
// `natural != target`, and the width it lands on is
//
//     w = (natural > 64) ? natural : min(natural, target)
//
//   * the `> 64` arm is UHDM's `ExprEval::get_value`
//     (UHDM/templates/ExprEval.cpp:1967 `if (expr->VpiSize() > 64)
//     invalidValue = true;` in the vpiBinaryConst case).  adjustSize's entire
//     `if (!invalidValue) { … }` body is then skipped — the trailing
//     `else { c->VpiSize(size); }` belongs to the
//     `vpiUIntConst / else if vpiBinaryConst` chain, NOT to that test — so the
//     producer's natural constant survives completely untouched;
//   * the `min` arm is `c->VpiSize((orig_size < size) ? orig_size : size)` in
//     the int_typespec branch, and `if (orig_size > size)` (which does nothing
//     at all when natural <= target) in the logic_typespec branch.
//
// DIRECTION: REPLACE — we used the TARGET width for both the digit string and
// vpiSize.  A constant's VALUE STRING and vpiDecompile are both Compare fields,
// which is why this gates YosysOldOr's verdict.
// Both sides of 22 cells are tabulated in tools/probe/r10oth4repro/README.md
// (arm `r1_repl.v`, driver `rarm.sh` + `replform.py` + `rtab.sh`).
namespace {
struct SrlgNatFold {
    int32_t width;       // width to emit
    int32_t natural;     // the self-determined width
    slang::SVInt value;  // the value at `natural` bits
    bool valid;          // false => keep the pre-existing target-width path
};
}  // namespace

static SrlgNatFold srlgNaturalFoldWidth(const Expression& expr,
                                        const slang::SVInt& tgtIv, int32_t tgtW,
                                        const ASTContext& ctx) {
    SrlgNatFold r{tgtW, tgtW, tgtIv, false};
    auto& nat = stripImplicitConv(expr);
    if (&nat == &expr || !nat.type || !nat.type->isIntegral())
        return r;
    int32_t natW = (int32_t)nat.type->getBitWidth();
    if (natW <= 0 || natW == tgtW)
        return r;  // no implicit resize happened: nothing to model
    ConstantValue ncv = ctx.tryEval(nat);
    if (!ncv || !ncv.isInteger())
        return r;
    slang::SVInt niv = ncv.integer();
    if ((int32_t)niv.getBitWidth() != natW)
        return r;
    r.natural = natW;
    r.value = niv;
    r.width = (natW > 64) ? natW : (natW < tgtW ? natW : tgtW);
    r.valid = true;
    return r;
}

UHDM::any* UhdmExporter::tryFoldConst(const Expression& expr, const Expression* typedConv,
                                      bool paramCtx) {
    // Surelog's netlist elaboration re-compiles top-view cont_assign
    // expressions with constant reduction. Fold only genuine expressions,
    // not plain literals (evaluating an implicitly-converted literal can
    // also truncate through slang's 32-bit unsized literal type).
    if (stripImplicitConv(expr).kind == ExpressionKind::IntegerLiteral)
        return nullptr;
    // Explicit TYPE casts (logic'/int'...) are re-emitted in TOP modules,
    // never folded; child-instance CAs and size casts still fold.
    //
    // NOTE (r4fold, measured): a top-view cast over a CONST-FUNCTION CALL
    // (int'(get_BA())) sometimes DOES fold to one constant in Surelog's top
    // view — PackedEnumVar folds to UINT:7 — but the condition is a set of
    // ExprEval bail rules, not the call itself. Ablations on one source
    // (only the named line changed) measured THREE independent bails:
    //   1. enum member values written in HEX bail; the SAME enum written in
    //      BINARY folds. Measured by rewriting ONLY the two member literals
    //      of one enum, everything else byte-identical: 3'b000/3'b111 ->
    //      fold, 3'h0/3'h7 -> no fold; and in the other direction
    //      4'h5/4'hA -> no fold, 4'b0101/4'b1010 -> fold. So it is the
    //      literal BASE, not the width, the value, or the typedef.
    //   2. a local the body leaves partly unassigned bails (ReturnEnumArray
    //      assigns out[0] only; PackedEnumVar assigns both -> folds).
    //   3. a part-select/bit-select return off a local bails
    //      (BitSelectPartSelectInFunction, even with a sized argument).
    // Folding on the call alone regressed exactly these three u2r tests
    // (BitSelectPartSelectInFunction, FunctionReturnEnum, ReturnEnumArray).
    // The bail set is now modelled in UhdmExporter::srlgEvalFuncFolds
    // (ParamEmit) and the gate below opens only when all three pass.
    if (!foldTypeCasts) {
        auto& c0 = stripImplicitConv(expr);
        if (c0.kind == ExpressionKind::Conversion && c0.syntax &&
            c0.syntax->kind == syntax::SyntaxKind::CastExpression &&
            isTypeSyntaxKind(
                c0.syntax->as<syntax::CastExpressionSyntax>().left->kind)) {
            bool evalFolds = false;
            auto& op0 = stripImplicitConv(c0.as<ConversionExpression>().operand());
            if (op0.kind == ExpressionKind::Call) {
                auto& cx0 = op0.as<CallExpression>();
                if (!cx0.isSystemCall() && cx0.arguments().empty())
                    if (auto* sub0 =
                            std::get_if<const SubroutineSymbol*>(&cx0.subroutine))
                        evalFolds = *sub0 && srlgEvalFuncFolds(**sub0);
            }
            if (!evalFolds)
                return nullptr;
        }
    }
    // A TYPE cast of a VECTOR-TYPEDEF param (int'(P) where P is a typedef'd
    // packed array) keeps the cast op even in CHILD-instance CAs (Surelog).
    {
        auto& c1 = stripImplicitConv(expr);
        if (c1.kind == ExpressionKind::Conversion && c1.syntax &&
            c1.syntax->kind == syntax::SyntaxKind::CastExpression &&
            isTypeSyntaxKind(
                c1.syntax->as<syntax::CastExpressionSyntax>().left->kind)) {
            auto& op1 = stripImplicitConv(c1.as<ConversionExpression>().operand());
            if (op1.kind == ExpressionKind::NamedValue &&
                op1.as<NamedValueExpression>().symbol.kind ==
                    SymbolKind::Parameter) {
                auto& pt1 = op1.as<NamedValueExpression>().symbol.as<ParameterSymbol>();
                if (auto d1 = pt1.getDeclaredType();
                    d1 && d1->getType().kind == SymbolKind::TypeAlias &&
                    d1->getType().getParentScope() &&
                    d1->getType()
                            .getParentScope()
                            ->asSymbol()
                            .kind == SymbolKind::Package &&
                    pt1.getType().getCanonicalType().kind ==
                        SymbolKind::PackedArrayType &&
                    pt1.getType().getCanonicalType().isIntegral())
                    return nullptr;
            }
        }
    }
    // NOTE (§ srlgUnbasedReduceBail, r10oth2) — this used to refuse EVERY
    // operation containing an unbased-unsized literal, on the strength of the
    // one witness `'0 << 8`.  Golden REFUTES the generalisation: on a
    // purpose-built 12-row golden (tools/probe/r10oth2repro/a1_unbased_fold.v)
    // Surelog's ELABORATED view folds 10 of the 12 and refuses exactly two, and
    // the 21-row a2 / 14-row a3 arms pin the reason to two ExprEval bails —
    // an unsized LEFT shift operand, and get_value on an X/Z binary constant.
    // See srlgUnbasedReduce above for the transcription.
    //
    // GATE, and why every clause is NECESSARY: the precondition (an unbased
    // literal written in the tree, top level one of the four operation kinds)
    // is UNCHANGED, so this is a pure NARROWING — it can only add folds.  The
    // added clause is the reduce model.  Witness for the ADD:
    // BlackParrotComplex's `output_dirs_sparse_lp`, a BinaryOp whose ternary
    // holds `'X` in the UNTAKEN arm; golden's elab view folds it to
    // `UINT:5 size 64 vpiUIntConst` and its DEF view keeps the whole operation
    // — which we ALREADY matched, so the defect was elab-only.
    {
        // Only OPERATIONS over unbased literals can stay unfolded (casts and
        // direct literals still fold — param defaults/size casts re-encode).
        auto k0 = stripImplicitConv(expr).kind;
        if ((k0 == ExpressionKind::BinaryOp || k0 == ExpressionKind::UnaryOp ||
             k0 == ExpressionKind::ConditionalOp ||
             k0 == ExpressionKind::Concatenation) &&
            srlgHasUnbasedLit(expr) &&
            srlgUnbasedReduce(comp, expr, 0).bails)
            return nullptr;
    }
    ASTContext ctx(comp.getRoot(), LookupLocation::max);
    ConstantValue cv = ctx.tryEval(expr);
    if (!cv || !cv.isInteger())
        return nullptr;
    slang::SVInt iv = cv.integer();
    // A CONCAT with x/z bits ({12'h800, 4'b001x, 16'bx...}) still folds — to
    // a full-width BINARY constant preserving the 0/1/x/z bits. Other
    // unknown-valued expressions refuse.
    if (iv.hasUnknown()) {
        if (stripImplicitConv(expr).kind != ExpressionKind::Concatenation)
            return nullptr;
        auto* c = s.MakeConstant();
        int32_t uw = (int32_t)expr.type->getBitWidth();
        slang::SVInt uv = iv;
        bool utrunc = false;
        // § srlgFoldNaturalWidth — an X/Z concat takes the SAME adjustSize
        // clamp as a clean one (arm cell b8_cat_x: golden BIN:001x0000 size 8
        // for `{4'b001x,4'b0000}` into a 20-bit net, where we emitted 20).
        // get_value's parseBinary failure is NOT strict
        // (UHDM/templates/ExprEval.cpp:1975 `if (strict) invalidValue = invalid;`)
        // so an x/z value still reaches the truncating arm — cell b9_cat_x_nar.
        if (!paramCtx) {
            auto nw = srlgNaturalFoldWidth(expr, iv, uw, ctx);
            if (nw.valid) {
                uw = nw.width;
                uv = nw.value;
                utrunc = nw.width < nw.natural;
            }
        }
        c->VpiSize(uw);
        std::string bits;
        for (int32_t i = uw - 1; i >= 0; i--) {
            auto b = uv[i];
            bits += b.isUnknown() ? (b.value == slang::logic_t::Z_VALUE ? 'z' : 'x')
                    : (b.value ? '1' : '0');
        }
        c->VpiValue("BIN:" + bits);
        c->VpiConstType(vpiBinaryConst);
        // § srlgConcatTruncDecompile — see the clean-concat arm below.
        if (paramCtx)
            c->VpiDecompile(std::to_string(uw) + "'b" + bits);
        else if (utrunc)
            c->VpiDecompile(bits);
        return c;
    }
    // A SIZE cast whose OPERAND is a signed non-literal (N'(signed_ref)) folds
    // to a SIGNED constant reinterpreted at the cast width (2'(3) -> -1),
    // carrying a signed logic_typespec and no decompile. A literal operand
    // (3'(31)) stays unsigned, and TYPE casts (int'(x)) are excluded.
    auto& sc = stripImplicitConv(expr);
    bool signedSizeCast = false;
    if (sc.kind == ExpressionKind::Conversion &&
        !sc.as<ConversionExpression>().isImplicit() && sc.type &&
        sc.type->isSigned() && sc.syntax &&
        sc.syntax->kind == syntax::SyntaxKind::CastExpression &&
        !isTypeSyntaxKind(sc.syntax->as<syntax::CastExpressionSyntax>().left->kind)) {
        auto& op = stripImplicitConv(sc.as<ConversionExpression>().operand());
        signedSizeCast = op.kind != ExpressionKind::IntegerLiteral && op.type &&
                         op.type->isSigned();
        // Only a size cast that actually yields a NEGATIVE value (truncation
        // sets the new high bit) reinterprets as signed; a positive result
        // (32'(1)) stays unsigned.
        if (signedSizeCast) {
            int w = (int)sc.type->getBitWidth();
            uint64_t uv = iv.as<uint64_t>().value_or(0);
            if (!(w > 0 && w < 64 && (uv & (1ULL << (w - 1)))))
                signedSizeCast = false;
        }
    }
    if (signedSizeCast) {
        int w = (int)sc.type->getBitWidth();
        uint64_t uv = iv.as<uint64_t>().value_or(0);
        int64_t sv = (int64_t)uv;
        if (w > 0 && w < 64 && (uv & (1ULL << (w - 1))))
            sv = (int64_t)(uv | (~0ULL << w));
        auto* c = s.MakeConstant();
        c->VpiSize(w);
        c->VpiValue("INT:" + std::to_string(sv));
        c->VpiConstType(vpiIntConst);
        auto* rt = s.MakeRef_typespec();
        rt->VpiParent(c);
        c->Typespec(rt);
        // The signed logic_typespec actual is created at the very end of the
        // write phase (Surelog's arena tail).
        pendingSignedCastTs.push_back(rt);
        return c;
    }
    if (iv.isSigned() && iv.isNegative()) {
        // An UNTYPED PARAMETER still folds a negative result — Surelog reduces
        // `parameter E1 = (1 << 8) - (1 << 11)` to INT:-1792 size 64 (and the
        // `int`-typed twin to INT:-1792 size 32). Only non-parameter folds
        // (cont-assign RHS reductions) keep the unfolded operation, which is
        // what this bail was written for.
        if (!typedConv && !paramCtx)
            return nullptr;
        // A SIGNED integral typed param keeps the negative value as a signed
        // INT constant at the type width (integer y = -1 -> INT:-1/32). An
        // UNSIGNED typed param instead re-folds the negative intermediate
        // (logic[17:0] X = ~(15) -> UINT:262128) through its conversion to
        // the unsigned type width. The TARGET (param) type governs — NOT the
        // init expression's self-determined type (~(15) is self-typed int).
        if (typedConv && !(typedConv->type && typedConv->type->isSigned() &&
                           typedConv->type->isIntegral())) {
            ConstantValue cv2 = ctx.tryEval(*typedConv);
            if (!cv2 || !cv2.isInteger())
                return nullptr;
            slang::SVInt iv2 = cv2.integer();
            if (iv2.hasUnknown() || (iv2.isSigned() && iv2.isNegative()))
                return nullptr;
            iv = iv2;
        }
    }
    // A folded CONCAT encodes as full-width binary. An RVALUE fold carries no
    // decompile (StreamOp's cont_assign constants have neither decompile nor
    // location); a PARAMETER value always does — across both corpora the only
    // decompile-less param_assign constants in any golden are empty strings
    // (tools/probe/w4bindec.cpp). rp32_r5p_mdu: localparam M8 = {1'b1,
    // {XLEN-1{1'b0}}} -> 32'b1000...0.
    // A REPLICATION ({N{1'b1}}) folds the same way in a PARAMETER context, and
    // — unlike a plain concat — Surelog keeps the replication's OWN width even
    // when the param is explicitly typed (measured, one source per row, only
    // the named declaration changed):
    //     parameter int A1        = {3{1'b1}} -> BIN:111  size 3
    //     parameter A2            = {3{1'b1}} -> BIN:111  size 3
    //     parameter bit [2:0] A3  = {3{1'b1}} -> BIN:111  size 3
    //     parameter int A4        = {4{1'b1}} -> BIN:1111 size 4
    // (a plain CONCAT into an `int` instead re-signs at 32 — {2'b11,2'b01} ->
    // INT:-3/32 — which is why only the replication form is widened here).
    // § replFoldParamInt32 — and the replication's SIZE is not that width.
    // Surelog reduces `{N{elem}}` through its integer Value, then runs the
    // adjustSize consumer (§ adjustSize, ParamEmit srlgAdjustSize) against the
    // replication's OWN result type, which is plain `int`: the BIN arm of the
    // int branch clamps to `min(literal, target)` = min(w, 32).  Above 64 bits
    // the value no longer fits Surelog's 64-bit SValue, the arm bails, and the
    // true width survives.  The vpiDecompile is written by the PRODUCER before
    // that clamp, so it keeps the `<w>'b` prefix at the full replication width
    // — golden really does carry `40'b1111...` at vpiSize 32.  A plain CONCAT
    // takes no such arm and keeps its full width at every size.  Measured on a
    // purpose-built 20-row golden (tools/probe/r10bpfamtab.py over
    // concat/replication pairs at w=33/36/40/48/64/65, typed and untyped
    // targets, MSB set and clear):
    //     {33{1'b1}} -> size 32      {32'hFFFFFFFF,1'b0}   -> size 33
    //     {40{1'b1}} -> size 32      {39'h..,1'b0}         -> size 40
    //     {64{1'b1}} -> size 32      {63'h..,1'b0}         -> size 64
    //     {65{1'b1}} -> size 65      {64'h..,1'b0}         -> size 65
    //     {12{3'b101}} -> size 32    {{20{1'b1}},{20{1'b0}}} -> size 40
    //     {40{1'b0}} -> size 32      (all-zero: not an MSB rule)
    // and it is independent of the parameter's declared type — `logic [39:0]`,
    // `bit [39:0]`, `longint`, `integer` and untyped all land 32.  BlackConst's
    // `parameter easy = `BSG_EASY(pc, dword_width_gp)` is the 35-bit witness.
    if (stripImplicitConv(expr).kind == ExpressionKind::Concatenation ||
        (paramCtx && stripImplicitConv(expr).kind == ExpressionKind::Replication)) {
        auto* c = s.MakeConstant();
        int32_t w = (int32_t)expr.type->getBitWidth();
        slang::SVInt wv = iv;
        // § srlgFoldNaturalWidth — a NON-PARAMETER concat (the cont_assign
        // fold) is clamped by adjustSize's LOGIC_TYPESPEC arm, which truncates
        // the digits AND the size to the target only when natural > target and
        // does nothing at all otherwise.  So digits and size are both
        // (natural > 64) ? natural : min(natural, target).  The paramCtx path
        // is deliberately untouched: § replFoldParamInt32 above measured it
        // separately and it clamps against the replication's own `int` result
        // type, not the declared parameter type.
        bool trunc9 = false;
        if (!paramCtx) {
            auto nw = srlgNaturalFoldWidth(expr, iv, w, ctx);
            if (nw.valid) {
                w = nw.width;
                wv = nw.value;
                trunc9 = nw.width < nw.natural;
            }
        }
        c->VpiSize(stripImplicitConv(expr).kind == ExpressionKind::Replication &&
                           w > 32 && w <= 64
                       ? 32
                       : w);
        std::string bits;
        for (int32_t i = w - 1; i >= 0; i--)
            bits += (wv[i] == slang::logic_t(1)) ? '1' : '0';
        c->VpiValue("BIN:" + bits);
        c->VpiConstType(vpiBinaryConst);
        // NOTE (§ srlgConcatTruncDecompile, r10oth4) — DIRECTION: ADD.
        // The vpiConcatOp PRODUCER (UHDM/templates/ExprEval.cpp, `c1->VpiValue`
        // / `VpiSize` / `VpiConstType` and nothing else) writes NO vpiDecompile
        // and NO typespec, so a non-parameter concat fold normally has none —
        // which is what we already emitted.  But adjustSize's TRUNCATING arm
        // (`if (orig_size > size) { … c->VpiDecompile(v); … }` in the
        // logic_typespec branch, CompileHelper.cpp) ADDS one, equal to the
        // TRUNCATED bit string and BARE — no `<w>'b` prefix.
        // THE GATE is therefore "the digits were actually truncated", i.e.
        // natural > target AND natural <= 64; the > 64 case never reaches the
        // arm at all.  Witnesses (golden, both sides in the README table):
        // b2_cat_nar 16->8 dc=00001111, b7_cat_repl_nar 9->4 dc=1111,
        // b9_cat_x_nar 8->4 dc=0000; and dc=<NONE> in b1/b3/b4/b5/b6/b8, every
        // one of which is un-truncated.
        if (paramCtx)
            c->VpiDecompile(std::to_string(w) + "'b" + bits);
        else if (trunc9)
            c->VpiDecompile(bits);
        return c;
    }
    // A folded REPLICATION over a SIZED element ({8{2'(1'b1)}}) is Surelog's
    // bit-pattern reduce too: full-width BINARY, but decompiled as the BARE
    // bit string (no `<w>'b` prefix) and carrying an anonymous
    // int_typespec — the replication result type (ContAssignConst out6).
    // A replication over an UNSIZED element keeps the plain decimal fold.
    if (!paramCtx &&
        stripImplicitConv(expr).kind == ExpressionKind::Replication) {
        auto& rp9 = stripImplicitConv(expr).as<ReplicationExpression>();
        auto& cc9 = stripImplicitConv(rp9.concat());
        bool sizedElem9 =
            cc9.type && cc9.type->isIntegral() &&
            cc9.kind != ExpressionKind::UnbasedUnsizedIntegerLiteral;
        if (sizedElem9) {
            auto* c = s.MakeConstant();
            int32_t w = (int32_t)expr.type->getBitWidth();
            int32_t dw = w;
            slang::SVInt wv = iv;
            // § srlgFoldNaturalWidth — THIS IS YosysOldOr's HEAD.  A
            // REPLICATION carries the `word size` int_typespec its
            // vpiMultiConcatOp producer attaches, so adjustSize takes the
            // INT_TYPESPEC arm, which never touches the value string and only
            // does `c->VpiSize((orig_size < size) ? orig_size : size)`.  Hence
            // the digits stay at the FULL replication width while vpiSize is
            // clamped: `assign tag = {dw-1{1'b0}}` with dw=22 into a 20-bit
            // target gives golden BIN with 21 digits at vpiSize 20
            // (or1200_dc_tag.v:99).  A plain concat differs — its producer
            // attaches no typespec, so it takes the logic_typespec arm and its
            // digits DO truncate (arm cell b7_cat_repl_nar proves the split is
            // decided by the TOP-LEVEL operator, not by containing a
            // replication).
            if (!paramCtx) {
                auto nw = srlgNaturalFoldWidth(expr, iv, w, ctx);
                if (nw.valid) {
                    w = nw.width;      // vpiSize: min(natural, target), or natural > 64
                    dw = nw.natural;   // digits: ALWAYS the natural width
                    wv = nw.value;
                }
            }
            c->VpiSize(w);
            std::string bits;
            for (int32_t i = dw - 1; i >= 0; i--)
                bits += (wv[i] == slang::logic_t(1)) ? '1' : '0';
            c->VpiValue("BIN:" + bits);
            c->VpiConstType(vpiBinaryConst);
            c->VpiDecompile(bits);
            auto* rt = s.MakeRef_typespec();
            rt->VpiParent(c);
            rt->Actual_typespec(s.MakeInt_typespec());
            c->Typespec(rt);
            return c;
        }
    }
    std::string digits = iv.toString(LiteralBase::Decimal, /*includeBase*/ false);
    auto* c = s.MakeConstant();
    c->VpiDecompile(digits);
    c->VpiSize((int32_t)expr.type->getBitWidth());
    // A folded comparison/logical result is a 1-bit boolean; Surelog's reduce
    // encodes it as a binary constant, not UINT.
    bool boolFold = false;
    if (auto& folded = stripImplicitConv(expr); folded.kind == ExpressionKind::BinaryOp) {
        auto bop = folded.as<BinaryExpression>().op;
        boolFold = OpInfo::isComparison(bop) || bop == BinaryOperator::LogicalAnd ||
                   bop == BinaryOperator::LogicalOr ||
                   bop == BinaryOperator::LogicalImplication ||
                   bop == BinaryOperator::LogicalEquivalence;
    }
    // Surelog's reduce encodes division results (and anything referencing a
    // param whose value was so encoded) as INT; everything else as UINT.
    if (boolFold) {
        // A comparison/logical result is self-sized 1-bit; Surelog's reduce
        // keeps that width, NOT the assignment target's (1'bx >= r -> size 1,
        // not the [63:0] net width).
        if (auto& fb = stripImplicitConv(expr); fb.type)
            c->VpiSize((int32_t)fb.type->getBitWidth());
        c->VpiValue("BIN:" + digits);
        c->VpiConstType(vpiBinaryConst);
    }
    // A NEGATIVE signed result always encodes as a signed INT (Surelog):
    // integer y = -1 -> INT:-1, never UINT:-1 (which serializes as 0).
    else if (isIntEncoded(expr) || (iv.isSigned() && iv.isNegative())) {
        c->VpiValue("INT:" + digits);
        c->VpiConstType(vpiIntConst);
    }
    else {
        c->VpiValue("UINT:" + digits);
        c->VpiConstType(vpiUIntConst);
    }
    return c;
}

bool UhdmExporter::isIntEncoded(const Expression& e) {
    switch (e.kind) {
        case ExpressionKind::Conversion:
            return e.as<ConversionExpression>().isImplicit() &&
                   isIntEncoded(e.as<ConversionExpression>().operand());
        case ExpressionKind::UnaryOp:
            return isIntEncoded(e.as<UnaryExpression>().operand());
        case ExpressionKind::BinaryOp: {
            auto& be = e.as<BinaryExpression>();
            if (be.op == BinaryOperator::Divide || be.op == BinaryOperator::Mod)
                return true;
            // A signed power (2**n) reduces to a signed (INT) constant.
            if (be.op == BinaryOperator::Power && e.type && e.type->isSigned())
                return true;
            return isIntEncoded(be.left()) || isIntEncoded(be.right());
        }
        case ExpressionKind::NamedValue: {
            auto it = paramIntEnc.find(&e.as<NamedValueExpression>().symbol);
            return it != paramIntEnc.end() && it->second;
        }
        default:
            return false;
    }
}

// § vifClockingPathComponent5 — THE LAW (definition; three call sites, each
// tagged with the same §).
//
// WHAT IS LOST AND WHY.  slang resolves a dotted reference through a VIRTUAL
// INTERFACE with ONE lookup: `Lookup::selectChild`
// (slang/source/ast/Lookup.cpp, the `vit.modport ? vit.modport : &vit.iface`
// arm) hands the WHOLE remaining selector list to `lookupDownward`, and
// `Expression::bindLookupResult` (Expression.cpp, "If we were accessed via a
// virtual interface wrap the result up in a member access expression") then
// wraps the LEAF symbol in a SINGLE MemberAccessExpression over the vif
// expression.  So `vif.cb.data_status` reaches the exporter as
// MemberAccess(member = ClockVar `data_status`, value = NamedValue `vif`): every
// component the source wrote BETWEEN the handle and the leaf — a named CLOCKING
// BLOCK, or a nested interface INSTANCE — is absent from the AST chain, and the
// hier_path built from that chain came out with 2 elements named
// `vif.data_status` where golden has 3 named `vif.cb.data_status`.  This is the
// SVSwitch head (Driver.sv:53).  A REAL interface handle is NOT affected (arm
// a2: module-scope instance, interface port, modport port, `u_mid.m.cb.ds`
// hierarchical — all eleven paths were already byte-identical to golden), which
// is why the law is scoped to the virtual-interface base and to nothing else.
//
// THE GATE, and it is exactly what the code below tests:
//   (1) the accessed VALUE's canonical type is a VirtualInterfaceType;
//   (2) walking UP from the leaf symbol's scope reaches that vif's own interface
//       body through NOTHING BUT named CLOCKING BLOCKs and nested interface
//       INSTANCE bodies (an allowlist: a MODPORT scope, a class, a statement
//       block — anything else — DECLINES, which is what keeps a plain modport
//       member like `vif.reset` at two elements, since a ModportPortSymbol's
//       parent scope IS the modport);
//   (3) at least one such component was collected (else nothing was collapsed);
//   (4) the WRITTEN text immediately before the leaf's name token is EXACTLY
//       `<comp>.` for each recovered component, in order.  The spans are
//       computed by walking BACKWARD from the leaf token, so a space, a comment
//       or an escaped identifier IN THAT WINDOW would make them LIES — the text
//       check is what makes them measurements.
//
// MEASURED, arm a5 (one cell per way of breaking clause (4); every cell's dump
// is quoted in the README) — and it REFUTES two guesses an earlier revision of
// this comment made:
//   * `vif . cb . ds` (spaces around the dots) DECLINES, as designed: the window
//     before `ds` reads " cb", not "cb.".  We then emit the pristine 2-element
//     path, which is still not golden's 3-element one — DECLINING IS NOT BEING
//     RIGHT, it is refusing to guess a span.  README residue R3.
//   * a comment or a NEWLINE *before* the recovered component (`vif./*c*/cb.din`,
//     `vif.\n   cb.din`) FIRES and lands BYTE-IDENTICAL to golden, because the
//     window checked is only `<comp>.` — what sits to the LEFT of the recovered
//     component is never read.  The earlier claim that these are lies was wrong.
//   * a path spelled entirely through a MACRO (`` `CBSEL(vif) `` with body
//     `H.cb.ds`) also FIRES and lands BYTE-IDENTICAL to golden (both tools put
//     every element at the macro CALL site).  The earlier claim that the macro
//     case declines — "residue R4" — is REFUTED; it converges.
// Callers get names + spans and mint the elements themselves, because the three
// hier_path builders differ in what an element is (ref_obj / bit_select comp).
bool UhdmExporter::vifCollapsedComponents5(
    const MemberAccessExpression& ma,
    std::vector<std::pair<std::string, SourceRange>>& out) {
    out.clear();
    const Type* vt = ma.value().type;
    if (!vt)
        return false;
    auto& cvt = vt->getCanonicalType();
    if (cvt.kind != SymbolKind::VirtualInterfaceType)
        return false;
    const Scope* stop = &cvt.as<slang::ast::VirtualInterfaceType>().iface.body;
    // (2) the scope walk: leaf..base order, allowlisted kinds only.
    std::vector<std::string> names;
    const Scope* sc = ma.member.getParentScope();
    bool reached = false;
    for (int g = 0; g < 8 && sc; g++) {
        if (sc == stop) {
            reached = true;
            break;
        }
        auto& ssym = sc->asSymbol();
        if (ssym.kind == SymbolKind::ClockingBlock) {
            if (ssym.name.empty())
                return false;
            names.emplace_back(ssym.name);
            sc = ssym.getParentScope();
            continue;
        }
        if (ssym.kind == SymbolKind::InstanceBody) {
            auto* pi = ssym.as<InstanceBodySymbol>().parentInstance;
            if (!pi || pi->name.empty())
                return false;
            names.emplace_back(pi->name);
            sc = pi->getParentScope();
            continue;
        }
        return false;
    }
    if (!reached || names.empty())
        return false;
    // (4) the spans, walked BACKWARD from the leaf's own name token, and the
    // text check that makes them true.
    auto leafEnd = ma.sourceRange.end();
    if (ma.member.name.empty() || leafEnd == slang::SourceLocation::NoLocation)
        return false;
    auto leafStart = leafEnd - ma.member.name.size();
    if (rawText(SourceRange(leafStart, leafEnd)) != ma.member.name)
        return false;
    auto cursor = leafStart;
    std::vector<std::pair<std::string, SourceRange>> rev;
    for (auto& nm : names) { // names is leaf..base, i.e. the walk-back order
        auto dot = cursor - 1;
        auto start = dot - nm.size();
        if (rawText(SourceRange(start, cursor)) != nm + ".")
            return false;
        rev.emplace_back(nm, SourceRange(start, dot));
        cursor = start;
    }
    out.assign(rev.rbegin(), rev.rend());
    return true;
}

// A dotted interface-member reference (s.req.adr): hier_path whose ref_obj
// elements anchor at their own token; the LAST element carries the
// module-scoped fullname (work@mod.<last>) — Surelog quirk.
UHDM::hier_path* UhdmExporter::buildDottedHierPath(const Expression& expr,
                                                   const std::string& dottedIn,
                                                   UHDM::BaseClass* parent,
                                                   const std::string& prefix) {
    // Bracketed indices containing operators render with decompile-style
    // spacing ([2-2] -> [2 - 2]) — Surelog.
    std::string dotted = dottedIn;
    {
        std::string o9;
        bool inIdx9 = false;
        for (size_t i9 = 0; i9 < dotted.size(); i9++) {
            char c9 = dotted[i9];
            if (c9 == '[')
                inIdx9 = true;
            else if (c9 == ']')
                inIdx9 = false;
            if (inIdx9 &&
                (c9 == '+' || c9 == '-' || c9 == '*' || c9 == '/') &&
                i9 > 0 && dotted[i9 - 1] != ' ' && dotted[i9 - 1] != '[') {
                o9 += ' ';
                o9 += c9;
                if (i9 + 1 < dotted.size() && dotted[i9 + 1] != ' ')
                    o9 += ' ';
            }
            else
                o9 += c9;
        }
        dotted = o9;
    }
    auto* hp = s.MakeHier_path();
    hp->VpiName(dotted);
    hp->VpiFullName(dotted);
    hp->VpiParent(parent);
    setLoc(hp, expr.sourceRange);
    // A dotted path used as a SELECT INDEX (mem[s.req.adr] <= ...) is a READ
    // even inside an lvalue: its base anchors at its own token and its leaf
    // takes the scoped fullname, exactly like any rvalue path.
    bool lhsPath9 = inLhs && !(parent &&
                               parent->UhdmType() == UHDM::uhdmbit_select);
    // this.member: the hier_path spans the `this` token; the this ref
    // anchors at the MEMBER token; the member ref is loc-less with a
    // scope-prefixed fullname.
    if (dotted.rfind("this.", 0) == 0 && dotted.find('.', 5) == std::string::npos) {
        std::string member = dotted.substr(5);
        auto st = expr.sourceRange.start();
        setLoc(hp, SourceRange(st, st + 4));
        auto* elems = s.MakeAnyVec();
        auto* rt = s.MakeRef_obj();
        rt->VpiName("this");
        rt->VpiFullName("this");
        rt->VpiParent(hp);
        setLoc(rt, SourceRange(st + 5, st + 5 + member.size()));
        elems->push_back(rt);
        auto* rm = s.MakeRef_obj();
        rm->VpiName(member);
        rm->VpiFullName(joinRef(prefix, member));
        rm->VpiParent(hp);
        elems->push_back(rm);
        hp->Path_elems(elems);
        return hp;
    }
    auto* elems = s.MakeAnyVec();
    auto exprStart = expr.sourceRange.start();
    // Split into (name, offset) components.
    std::vector<std::pair<std::string, size_t>> parts;
    for (size_t start = 0; start <= dotted.size();) {
        auto dot = dotted.find('.', start);
        if (dot == std::string::npos)
            dot = dotted.size();
        parts.emplace_back(dotted.substr(start, dot - start), start);
        if (dot == dotted.size())
            break;
        start = dot + 1;
    }
    // A gen-scope modport-array member LHS (man[i].req.lck in a genvar for):
    // the BASE component is a variable(genvar)-indexed element. Surelog anchors
    // the hier_path at the BASE-NAME token only, makes the base a bit_select
    // with a genvar index ref that PARENTS AT THE HIER_PATH (not the
    // bit_select), and gives the LEAF the RAW dotted fullname.
    auto varIdxOf = [](const std::string& pn) -> std::string {
        auto lb = pn.find('[');
        if (lb == std::string::npos || pn.empty() || pn.back() != ']')
            return "";
        if (pn.find('[', lb + 1) != std::string::npos)
            return "";
        std::string idx = pn.substr(lb + 1, pn.size() - lb - 2);
        if (idx.empty())
            return "";
        auto isIdentStart = [](char c) {
            return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
        };
        auto isIdentChar = [&](char c) {
            return isIdentStart(c) || (c >= '0' && c <= '9');
        };
        if (!isIdentStart(idx[0]))
            return "";
        for (char ch : idx)
            if (!isIdentChar(ch))
                return "";
        return idx;
    };
    bool genVarBasePath = !parts.empty() && !varIdxOf(parts[0].first).empty();
    if (genVarBasePath) {
        // The hier_path spans the base-name token only.
        auto st0 = exprStart + parts[0].second;
        std::string b0 = parts[0].first.substr(0, parts[0].first.find('['));
        setLoc(hp, SourceRange(st0, st0 + b0.size()));
    }
    std::string dottedSoFar;
    for (size_t i = 0; i < parts.size(); i++) {
        auto& [pname, off] = parts[i];
        // A CONSTANT-indexed component (dly[1]) becomes a bit_select whose name
        // is the array base, fullname the dotted path so far (incl. the index),
        // and vpiIndex a bare constant — Surelog. (Multi-dim / non-constant
        // indices keep the flat ref approximation.)
        auto lb = pname.find('[');
        std::string base = lb == std::string::npos ? pname : pname.substr(0, lb);
        dottedSoFar += (i == 0 ? base : "." + base);
        bool oneConstSel = false;
        std::string idxTxt;
        if (lb != std::string::npos && pname.back() == ']' &&
            pname.find('[', lb + 1) == std::string::npos) {
            idxTxt = pname.substr(lb + 1, pname.size() - lb - 2);
            oneConstSel = !idxTxt.empty() &&
                          idxTxt.find_first_not_of("0123456789") == std::string::npos;
        }
        if (oneConstSel) {
            dottedSoFar += "[" + idxTxt + "]";
            auto* bs = s.MakeBit_select();
            bs->VpiName(base);
            bs->VpiFullName(dottedSoFar);
            bs->VpiParent(hp);
            setLoc(bs, SourceRange(exprStart + off, exprStart + off + base.size()));
            auto* c = s.MakeConstant();
            c->VpiDecompile(idxTxt);
            c->VpiSize(64);
            c->VpiValue("UINT:" + idxTxt);
            c->VpiConstType(vpiUIntConst);
            size_t ioff = off + lb + 1;
            setLoc(c, SourceRange(exprStart + ioff, exprStart + ioff + idxTxt.size()));
            bs->VpiIndex(c);
            elems->push_back(bs);
            continue;
        }
        // A GENVAR/variable-indexed component (man[i]) in a gen-scope
        // modport-array member path: bit_select(base), fullname the raw
        // component (man[i]), with a ref_obj index child that PARENTS AT THE
        // HIER_PATH and carries the scope-prefixed genvar fullname (Surelog).
        if (std::string varIdx = varIdxOf(pname); !varIdx.empty()) {
            dottedSoFar += "[" + varIdx + "]";
            auto* bs = s.MakeBit_select();
            bs->VpiName(base);
            bs->VpiFullName(pname);
            bs->VpiParent(hp);
            setLoc(bs, SourceRange(exprStart + off, exprStart + off + base.size()));
            auto* ir = s.MakeRef_obj();
            ir->VpiName(varIdx);
            ir->VpiFullName(prefix + "." + varIdx);
            ir->VpiParent(hp);
            size_t ioff = off + lb + 1;
            setLoc(ir, SourceRange(exprStart + ioff, exprStart + ioff + varIdx.size()));
            bs->VpiIndex(ir);
            elems->push_back(bs);
            continue;
        }
        auto* r = s.MakeRef_obj();
        r->VpiName(pname);
        // Only the last element of an RVALUE path gets a scoped fullname; the
        // others cache a NAME-ONLY fullname (the dump omits fullname == name,
        // and it blocks the dump-time lazy scoped recompute). A gen-scope
        // modport-array member path gives the LEAF the RAW dotted fullname.
        if (genVarBasePath && i + 1 == parts.size())
            r->VpiFullName(dotted);
        else if (!lhsPath9 && i + 1 == parts.size())
            // A PACKAGE-scope prefix keeps :: down to the leaf
            // (riscv_isa_i_pkg::imm_i_f::imm_11_0 — Surelog).
            r->VpiFullName(joinRef(prefix, pname));
        else
            r->VpiFullName(pname);
        r->VpiParent(hp);
        // Lvalue paths anchor the base ref at the SECOND element's span.
        size_t locIdx = (lhsPath9 && i == 0 && parts.size() > 1) ? 1 : i;
        auto& [lname, loff] = parts[locIdx];
        setLoc(r, SourceRange(exprStart + loff, exprStart + loff + lname.size()));
        elems->push_back(r);
    }
    hp->Path_elems(elems);
    return hp;
}

UHDM::hier_path* UhdmExporter::emitMixedHierPath(const Expression& expr,
                                                 UHDM::BaseClass* parent,
                                                 const std::string& prefix, NetMap& netMap) {
    // Flatten the whole access chain (members + single element-selects) into
    // components, innermost first, then reverse to base..outer order.
    struct Sel {
        const Expression* sel;
        SourceLocation selEnd;
    };
    struct Comp {
        std::string name;
        std::vector<Sel> sels; // one or more element selects on this component
        SourceRange nameSpan;  // the member/base name token
        bool isBase = false;
        // § vifClockingPathComponent5 — a component RECOVERED by this pass (one
        // slang collapsed out of a virtual-interface reference), not one the
        // source's own member chain produced.  It gets NO explicit fullname:
        // golden's intermediate `cb` is bare (`ref_obj: (cb) |vpiName:cb`, arm
        // a4 cell f2), while the LEAF below it still takes the dotted one.
        bool vifIns5 = false;
    };
    std::vector<Comp> comps;
    const Expression* cur = &expr;
    std::vector<Sel> pendingSels; // collected outer-to-inner
    const NamedValueExpression* baseNv = nullptr;
    auto attachSels = [&](Comp& c) {
        // pendingSels are outer-to-inner; the component wants first-dim first.
        for (auto it = pendingSels.rbegin(); it != pendingSels.rend(); ++it)
            c.sels.push_back(*it);
        pendingSels.clear();
    };
    // § vifClockingPathComponent5 — SITE 2 of 3: the member access adjacent to
    // the base, i.e. the one slang may have collapsed a vif's inner scopes into.
    const MemberAccessExpression* innerMa5 = nullptr;
    while (true) {
        if (cur->kind == ExpressionKind::MemberAccess) {
            auto& ma = cur->as<MemberAccessExpression>();
            auto end = cur->sourceRange.end();
            Comp c;
            c.name = std::string(ma.member.name);
            c.nameSpan = SourceRange(end - ma.member.name.size(), end);
            attachSels(c);
            comps.push_back(c);
            innerMa5 = &ma;
            cur = &ma.value();
        }
        else if (cur->kind == ExpressionKind::ElementSelect) {
            auto& es = cur->as<ElementSelectExpression>();
            pendingSels.push_back({&es.selector(), cur->sourceRange.end()});
            cur = &es.value();
        }
        else if (cur->kind == ExpressionKind::NamedValue) {
            baseNv = &cur->as<NamedValueExpression>();
            Comp c;
            c.name = std::string(baseNv->symbol.name);
            c.nameSpan = cur->sourceRange;
            c.isBase = true;
            attachSels(c);
            comps.push_back(c);
            break;
        }
        else {
            return nullptr;
        }
    }
    if (!baseNv)
        return nullptr;
    std::reverse(comps.begin(), comps.end());
    // § vifClockingPathComponent5 — SITE 2 of 3.  Splice the components slang
    // collapsed out of a virtual-interface reference in right after the base, as
    // plain (select-less) components: everything downstream — the hier_path's
    // name, each element's fullname, and `firstMemberSpan` (the lvalue base
    // anchor, which golden puts on the FIRST recovered component) — is then
    // derived from the component list exactly as it is for a written path.
    // THE LIVE CELL HERE IS ARM a4 f2, `varr[0].cb.ds <= 1` — a SELECT ON THE
    // BASE with the collapsed component above it.  MEASURED CORRECTION: an
    // earlier revision of this comment claimed arm a3 cells e1/e3
    // (`vif.cb.din[3] <= 1`, `r = vif.cb.dout[2]`) and THAT IS FALSE — those
    // are `ElementSelect` over `MemberAccess` over a NamedValue base, and the
    // ElementSelect case routes them to the single-dim `chain` arm, not here
    // (this builder is only entered when the chain BOTTOMS OUT in another
    // select).  e1/e3 are still 2-element after this pass; they are README
    // residue R2, deliberately unfixed because their corpus reach is ZERO (the
    // only `.<cb>.<sig>[` sites in either corpus are 12 lines in `ariane`, a
    // test with NO ROW, and they go through a real interface port anyway).
    // The `comps.size() == 2` gate is SITE 1's `chain.size() == 1` in this
    // builder's terms: exactly ONE member access above the base is what a
    // collapsed vif reference looks like, and a longer chain is the
    // `this.vif.cb.sig` shape whose golden is defective (README R1).
    if (comps.size() == 2 && innerMa5) {
        std::vector<std::pair<std::string, SourceRange>> vifComps5;
        if (vifCollapsedComponents5(*innerMa5, vifComps5)) {
            std::vector<Comp> ins5;
            for (auto& vc5 : vifComps5) {
                Comp c5;
                c5.name = vc5.first;
                c5.nameSpan = vc5.second;
                c5.vifIns5 = true;
                ins5.push_back(c5);
            }
            comps.insert(comps.begin() + 1, ins5.begin(), ins5.end());
        }
    }

    std::string dotted;
    for (size_t i = 0; i < comps.size(); ++i) {
        dotted += (i == 0 ? comps[i].name : "." + comps[i].name);
        for (auto& sel : comps[i].sels) {
            // § concatIdxDecompile29 — a CONCATENATION index is decompiled from
            // the tree; every other index keeps its raw text.
            std::string ci29 = concatIdxText(*sel.sel);
            dotted += "[" +
                      (ci29.empty() ? spaceIdxOps(rawText(sel.sel->sourceRange))
                                    : ci29) +
                      "]";
        }
    }

    // A multi-dim element select on the BASE array (group_status[0][0].a)
    // emits one bit_select per dim with simple dotted fullnames and a special
    // loc chain, distinct from the member-select (b.a[0].x) work@-doubled form.
    bool baseSelMode = !comps.empty() && comps[0].isBase && !comps[0].sels.empty();

    if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
        refCollector->insert(&baseNv->symbol);
    auto* hp = s.MakeHier_path();
    hp->VpiName(dotted);
    hp->VpiFullName(dotted);
    hp->VpiParent(parent);
    // A base multi-dim select LVALUE anchors the hier_path at the base name;
    // an RVALUE spans the whole path (a[0][0].min_v).
    setLoc(hp, (baseSelMode && inLhs) ? comps[0].nameSpan : expr.sourceRange);
    auto* elems = s.MakeAnyVec();
    // The first member's name token (used to anchor an lvalue base ref).
    SourceRange firstMemberSpan =
        comps.size() > 1 ? comps[1].nameSpan : comps[0].nameSpan;
    std::string dottedAt;
    for (size_t i = 0; i < comps.size(); ++i) {
        auto& comp = comps[i];
        bool lastMember = i + 1 == comps.size();
        dottedAt += (i == 0 ? comp.name : "." + comp.name);
        if (comp.isBase && baseSelMode) {
            // Base multi-dim element select: one bit_select per dim. Simple
            // dotted fullnames; each bit_select's loc is the base name (first
            // dim) or the prior selector's span (later dims).
            for (size_t k = 0; k < comp.sels.size(); ++k) {
                // § concatIdxDecompile29 — same gate as the `dotted` loop above;
                // the two renderings must agree or the hier_path name and its
                // bit_select fullnames disagree on the same select.
                std::string ci29b = concatIdxText(*comp.sels[k].sel);
                dottedAt += "[" +
                            (ci29b.empty() ? spaceIdxOps(rawText(
                                                 comp.sels[k].sel->sourceRange))
                                           : ci29b) +
                            "]";
                auto* bs = s.MakeBit_select();
                if (k == 0) // only the first dim carries vpiName
                    bs->VpiName(comp.name);
                bs->VpiParent(hp);
                bs->VpiFullName(dottedAt);
                setLoc(bs, k == 0 ? comp.nameSpan : comp.sels[k - 1].sel->sourceRange);
                // Base-select index constants parent to the bit_select when:
                //  - an ELAB cont-assign LHS single-dim select (flash_rsp_o[0]
                //    .ack), or a multi-dim PACKED select whose RHS re-elaborates
                //    (group_status[0][0].a = 1'b1); or
                //  - a re-elaborated RVALUE select into a PACKED array
                //    (int'(a[0][0].min_v)).
                // A multi-dim UNPACKED select (a[0][0].x), a packed LHS with a
                // plain-ref RHS (int_port_signed), and the def view stay
                // unparented.
                bool basePacked = baseNv->symbol.getType().isPackedArray();
                bool doParent =
                    (inLhs && elabContAssignLhs &&
                     (comp.sels.size() == 1 || (basePacked && elabLhsReelab))) ||
                    (!inLhs && reemitting && basePacked);
                bool savedSCP = suppressConstParent;
                if (!doParent)
                    suppressConstParent = true;
                if (auto* ix = emitExpr(*comp.sels[k].sel, bs, prefix, netMap)) {
                    // VARIABLE index refs parent at the HIER_PATH
                    // (ucsbece dll_d[i].valid); constants keep the
                    // bit_select parent.
                    if (((UHDM::any*)ix)->UhdmType() == UHDM::uhdmref_obj)
                        ((UHDM::any*)ix)->VpiParent(hp);
                    bs->VpiIndex((UHDM::expr*)ix);
                }
                suppressConstParent = savedSCP;
                elems->push_back(bs);
            }
        }
        else if (!comp.sels.empty()) {
            auto& sel = comp.sels[0];
            // § concatIdxDecompile29 — same gate as the `dotted` loop above.
            std::string ci29c = concatIdxText(*sel.sel);
            dottedAt += "[" +
                        (ci29c.empty()
                             ? spaceIdxOps(rawText(sel.sel->sourceRange))
                             : ci29c) +
                        "]";
            auto* bs = s.MakeBit_select();
            bs->VpiName(comp.name);
            bs->VpiParent(hp);
            // Lvalue: loc spans member+index, fullname lazily freezes to the
            // work@-prefixed doubled form, index constant parents to the
            // bit_select. Rvalue: loc is the member token only, fullname is the
            // dotted path so far, index constant is unparented.
            if (inLhs && inProcessEmit) {
                setLoc(bs, SourceRange(comp.nameSpan.start(), sel.selEnd));
                (void)bs->VpiFullName();
                // A VARIABLE index ref names itself by the parent chain: the
                // bit_select contributes nothing (UHDM skips a bit_select
                // above a ref_obj) but the enclosing hier_path does, so the
                // index scope is prefix + the whole dotted path.
                if (auto* ix =
                        emitExpr(*sel.sel, bs, prefix + "." + dotted, netMap))
                    bs->VpiIndex((UHDM::expr*)ix);
            }
            else if (inLhs && baseNv->symbol.kind == SymbolKind::Variable &&
                     !lastMember) {
                // A CONT-ASSIGN lvalue select on a struct VARIABLE member
                // array that is FOLLOWED by a further member
                // (assign t.my_array[0].a = ...) behaves like the process
                // lvalue: member+index span with the lazily-frozen doubled
                // fullname (work@<mod>.<dotted>.<name>) — Surelog.
                setLoc(bs, SourceRange(comp.nameSpan.start(), sel.selEnd));
                (void)bs->VpiFullName();
                if (auto* ix =
                        emitExpr(*sel.sel, bs, prefix + "." + dotted, netMap))
                    bs->VpiIndex((UHDM::expr*)ix);
            }
            else if (inLhs) {
                // A CONT-ASSIGN lvalue select anchors at the INDEX and keeps
                // the dotted path as its name (Surelog).
                setLoc(bs, sel.sel->sourceRange);
                bs->VpiFullName(dottedAt);
                if (auto* ix = emitExpr(*sel.sel, bs, prefix, netMap))
                    bs->VpiIndex((UHDM::expr*)ix);
            }
            else if (baseNv->symbol.kind == SymbolKind::Variable &&
                     !lastMember) {
                // An rvalue element-select on a struct VARIABLE member array
                // that is FOLLOWED by a further member (t.my_array[0].a):
                // Surelog keeps the SIMPLE dotted form (t.my_array[0]) at the
                // MEMBER-name span with an UNPARENTED index constant — in a
                // process AND in a cont-assign — unlike the iface/modport
                // doubled index-span form below.
                setLoc(bs, comp.nameSpan);
                bs->VpiFullName(dottedAt);
                bool savedSCP = suppressConstParent;
                // A process context always leaves the index constant
                // unparented; a cont-assign leaves it unparented in the
                // module-compile (def) view and PARENTS it in the
                // re-elaborated instance view.
                suppressConstParent = inProcessEmit || !reemitting;
                if (auto* ix = emitExpr(*sel.sel, bs, prefix, netMap))
                    bs->VpiIndex((UHDM::expr*)ix);
                suppressConstParent = savedSCP;
            }
            else if (inProcessEmit ||
                     baseNv->symbol.kind == SymbolKind::InterfacePort ||
                     baseNv->symbol.kind == SymbolKind::Modport) {
                // PROCESS-context and IFACE-PORT-based rvalues: DOUBLED
                // lazy-frozen fullname (work@<mod>.<dotted>.<name>) anchored
                // at the INDEX span (Surelog).
                setLoc(bs, sel.sel->sourceRange);
                (void)bs->VpiFullName();
                if (auto* ix = emitExpr(*sel.sel, bs, prefix, netMap))
                    bs->VpiIndex((UHDM::expr*)ix);
            }
            else if (lastMember) {
                // A TRAILING select anchors at the index with the doubled
                // lazy name; a select followed by further members keeps the
                // member span and the dotted path (Surelog).
                setLoc(bs, sel.sel->sourceRange);
                (void)bs->VpiFullName();
                if (auto* ix = emitExpr(*sel.sel, bs, prefix, netMap))
                    bs->VpiIndex((UHDM::expr*)ix);
            }
            else {
                setLoc(bs, comp.nameSpan);
                bs->VpiFullName(dottedAt);
                if (auto* ix = emitExpr(*sel.sel, bs, prefix, netMap))
                    bs->VpiIndex((UHDM::expr*)ix);
            }
            elems->push_back(bs);
        }
        else {
            auto* r = s.MakeRef_obj();
            r->VpiName(comp.name);
            (void)r->VpiFullName();
            // § vifClockingPathComponent5 — SITE 2 of 3.  A RECOVERED component
            // stays BARE.  Golden, arm a4 f2 (`varr[0].cb.ds <= 1`):
            //     \_ref_obj: (cb) ... |vpiName:cb            <- NO vpiFullName
            //     \_ref_obj: (varr[0].cb.ds) ... |vpiName:ds  |vpiFullName:...
            // so the dotted fullname belongs to the LEAF only.  This costs
            // nothing in `Compare` (BaseClass::Compare reads VpiType, VpiName,
            // VpiDefName — never VpiFullName) and is here to keep the BYTES
            // converging, which is the instrument GATE 5 uses.
            if (comp.vifIns5) {
                // nothing: no explicit fullname on a recovered component
            }
            else if (baseSelMode && !comp.isBase) {
                // Trailing member of a base-select path: an RVALUE resolves to
                // the struct member's own fullname (work@top.min_v); an LVALUE
                // keeps the dotted path.
                if (!inLhs && lastMember)
                    r->VpiFullName(prefix + "." + comp.name);
                else
                    r->VpiFullName(dottedAt);
            }
            else if (!inLhs && lastMember && !comp.isBase)
                r->VpiFullName(prefix + "." + comp.name);
            r->VpiParent(hp);
            // Lvalue paths anchor the base ref at the first member token.
            if (comp.isBase && inLhs && comps.size() > 1)
                setLoc(r, firstMemberSpan);
            else
                setLoc(r, comp.nameSpan);
            elems->push_back(r);
        }
    }
    hp->Path_elems(elems);
    return hp;
}

// § thisPathSelectErased4 — a member path whose base is the WRITTEN `this`
// keyword renders with EVERY element/range select ERASED.
//
//     foreach (this.data[i])
//     if (pkt.data[i] !== this.data[i])          // SVSwitch Packet.sv:122
//
// Golden, for the two operands of that ONE comparison:
//
//   pkt.data[i]   hier_path (pkt.data[i])  { ref_obj(pkt), bit_select(data)+idx }
//   this.data[i]  hier_path (this.data)    { ref_obj(this), ref_obj(data)      }
//
// Same line, same loop variable, same foreach, same rvalue-in-comparison
// position: the ONLY thing that differs is the receiver. So the gate is the
// written `this` keyword and NOTHING else — the same discriminator r10svs3
// landed (§ thisSuperNewAssignNoStmt3). The measured grid (both arms in
// tools/probe/r10svs4repro, 27 + 13 cells) REFUTES every other candidate:
//
//   * NOT the foreach context, and NOT loop-var-ness: a plain CONSTANT index
//     outside any loop (`this.data[2]`) is erased too, and a for-loop var
//     (`this.data[j]`) is erased, while `pkt.data[j]` on the SAME line keeps.
//   * NOT the array kind: dynamic (`byte data[]`), fixed (`fx[4]`), queue
//     (`q[$]`) and 2-D (`m2[2][3]`) all erase — the 2-D erases BOTH dims and
//     the element is a plain ref_obj, not a var_select.
//   * NOT the syntactic position: rvalue-in-comparison, plain-assignment rhs,
//     call argument, and LVALUE all erase. Position gates only the SPANS
//     (below), which no Compare method reads.
//   * NOT the select depth or select kind: `this.data[k][3]` (bit within the
//     element) and `this.data[k][3:0]` (part select) both erase to `this.data`,
//     and a select BELOW a further member (`this.st[k].fld`) erases to
//     `this.st.fld` with a plain ref_obj in the middle.
//   * `super` behaves IDENTICALLY in golden (`super.data[k]` -> hier_path
//     `super.data`), but slang resolves `super.data` straight to the inherited
//     member and hands us no `super` base at all, so we emit no hier_path there
//     today — a MISSING-SHAPE gap, not an index-presence one. Deliberately out
//     of this predicate; see residue R3.
//
// The cmp-VISIBLE half of the law is exactly two fields, and they are the two
// this head fails on: `hier_path::Compare` reads Path_elems + Root_value +
// VpiName (hier_path.cpp), and `ref_obj::Compare` opens with
// `VpiType() - other->VpiType()`. VpiFullName and every line/column field are
// read by NO Compare method, so the span/name detail below is dump-only —
// reproduced anyway because this is new code and costs nothing.
//
// Golden's span/name shape, position-gated (measured, arm g1 cells c1/c9 and
// arm g2 cells d1/d9):
//   hier_path loc : LVALUE -> the `this` token; otherwise the WHOLE written
//                   expression, index text included.
//   elem[0] `this`: ALWAYS the FIRST MEMBER's name token (never its own).
//   elem[i>0]     : LVALUE -> LOC-LESS with a scope-prefixed fullname;
//                   otherwise its own member-name token with a BARE name.
//
// Returns null unless this really is a select-carrying written-`this` member
// path; the UNINDEXED `this.member` form is deliberately NOT routed here (it is
// already cmp-equal, and its span/fullname shape differs from golden in a
// cmp-invisible way that would move every class test's dump — residue R1).
UHDM::hier_path* UhdmExporter::emitThisPathSelectErased(const Expression& expr,
                                                       UHDM::BaseClass* parent,
                                                       const std::string& prefix) {
    // Peel the whole access chain: members are KEPT, selects are DROPPED.
    struct Mem {
        std::string name;
        SourceRange nameSpan;
    };
    std::vector<Mem> mems; // outer-to-inner
    bool sawSelect = false;
    const Expression* cur = &expr;
    while (true) {
        if (cur->kind == ExpressionKind::MemberAccess) {
            auto& ma = cur->as<MemberAccessExpression>();
            auto end = cur->sourceRange.end();
            mems.push_back({std::string(ma.member.name),
                            SourceRange(end - ma.member.name.size(), end)});
            cur = &ma.value();
        }
        else if (cur->kind == ExpressionKind::ElementSelect) {
            sawSelect = true;
            cur = &cur->as<ElementSelectExpression>().value();
        }
        else if (cur->kind == ExpressionKind::RangeSelect) {
            sawSelect = true;
            cur = &cur->as<RangeSelectExpression>().value();
        }
        else
            break;
    }
    if (!sawSelect || mems.empty())
        return nullptr;
    if (cur->kind != ExpressionKind::NamedValue)
        return nullptr;
    auto& nv = cur->as<NamedValueExpression>();
    // The WRITTEN keyword is the gate. slang names the implicit self variable
    // `this`, and names it that ONLY when the keyword was written (an implicit
    // member reference resolves straight to the member symbol) — BUT THE NAME
    // TEST ALONE IS NOT THE WRITTEN-KEYWORD TEST, and the sentence that said so
    // shipped a latent regression (verifier F1, FIXED AT INTEGRATION): a
    // SystemVerilog ESCAPED IDENTIFIER `\this ` is an ordinary variable whose
    // `symbol.name`, after the escape is stripped, is exactly `this`, and the
    // name test fired the erase law on it at MODULE scope where golden — and
    // our own pristine binary — keep the select intact (arm v3_escaped.sv
    // cells x6/x8: hier_path::VpiName `this.arr[k]` -> `this.arr` and the
    // element bit_select -> ref_obj, BOTH cmp-visible fields flipped from
    // right to wrong).  Inside a class the exposure is nil (slang resolves the
    // NAME `this` to the implicit self even when an escaped member exists, so
    // `\this [k]` does not compile there); the corpus carries zero escaped
    // `\this` (grep-proven).  The fix is the STATED law made literal: the raw
    // source text of the base must BE the keyword — an escaped identifier's
    // raw text starts with a backslash and fails the comparison.  rawText maps
    // macro-expanded locations through getFullyOriginalRange, so a `this`
    // written inside a macro body still reads "this".
    if (nv.symbol.name != "this" || rawText(nv.sourceRange) != "this")
        return nullptr;
    std::reverse(mems.begin(), mems.end()); // base..outer order
    if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
        refCollector->insert(&nv.symbol);
    std::string dotted("this");
    for (auto& m : mems)
        dotted += "." + m.name;
    auto* hp = s.MakeHier_path();
    hp->VpiName(dotted);
    hp->VpiFullName(dotted);
    hp->VpiParent(parent);
    setLoc(hp, inLhs ? cur->sourceRange : expr.sourceRange);
    auto* elems = s.MakeAnyVec();
    {
        auto* rt = s.MakeRef_obj();
        rt->VpiName("this");
        rt->VpiFullName("this");
        rt->VpiParent(hp);
        setLoc(rt, mems.front().nameSpan);
        elems->push_back(rt);
    }
    for (auto& m : mems) {
        auto* r = s.MakeRef_obj();
        r->VpiName(m.name);
        if (inLhs)
            r->VpiFullName(joinRef(prefix, m.name));
        else {
            (void)r->VpiFullName(); // freeze the bare name before parenting
            setLoc(r, m.nameSpan);
        }
        r->VpiParent(hp);
        elems->push_back(r);
    }
    hp->Path_elems(elems);
    return hp;
}

// A property-decl FORMAL reference: property-scoped ref bound to an implicit
// module wire minted at the first use (Surelog leaks formals as module nets).
UHDM::ref_obj* UhdmExporter::emitPropFormalRef(std::string_view nm, SourceRange nr,
                                               UHDM::BaseClass* parent,
                                               const std::string& prefix) {
    if (!propDeclScope)
        return nullptr;
    auto* fsym = propDeclScope->find(nm);
    if (!fsym || fsym->kind != SymbolKind::AssertionPort)
        return nullptr;
    auto* ref = s.MakeRef_obj();
    ref->VpiName(nm);
    if (!bareFormalRefNames)
        ref->VpiFullName(joinRef(prefix, std::string(nm)));
    ref->VpiParent(parent);
    setLoc(ref, nr);
    auto& inet = implicitNetMap[fsym];
    // SAME-NAMED formals of DIFFERENT properties share one module wire
    // (Surelog mints per name: p_S2QED_MAPPED_VAL/SAME_VAL both use inp0).
    if (!inet && implicitNetModule && implicitNetModule->Nets())
        for (auto* n9 : *implicitNetModule->Nets())
            if (n9->VpiName() == nm &&
                n9->UhdmType() == UHDM::uhdmlogic_net) {
                inet = (UHDM::logic_net*)n9;
                break;
            }
    if (!inet && implicitNetModule) {
        inet = s.MakeLogic_net();
        inet->VpiName(nm);
        inet->VpiFullName(implicitNetPrefix + "." + std::string(nm));
        inet->VpiParent(implicitNetModule);
        inet->VpiNetType(1);
        setLoc(inet, nr);
        auto* nets = implicitNetModule->Nets();
        if (!nets) {
            nets = s.MakeNetVec();
            implicitNetModule->Nets(nets);
        }
        nets->push_back(inet);
    }
    if (inet)
        ref->Actual_group(inet);
    return ref;
}

// § fnLocalParamRangeNet — what a SUBROUTINE-LOCAL parameter named inside one
// of that subroutine's OWN declaration type ranges binds to.
//
//     function [width_z-1:0] fshl_u_1;
//        parameter len = ...;
//        reg [len-1:0] result;          // <- this `len`
//
// Surelog compiles a tf declaration's typespec with only the enclosing MODULE
// on the lookup path, so the ref_obj it builds carries no actual and lands in
// the component's late-binding list.  UhdmWriter::lateBinding (UhdmWriter.cpp
// :3294) resolves such a ref by walking its PARENT chain — and a typespec is
// UNPARENTED, so that walk ends immediately and the module-level search decides
// everything (UhdmWriter.cpp:3735-3990, in this order):
//     module NET / ARRAY_NET / VARIABLE of that name -> bound to it
//     module PARAMETER of that name                  -> left DANGLING
//                                                       (`isParam` -> continue)
//     nothing                                        -> an implicit WIRE is
//                                                       MINTED in the module
//                                                       (UhdmWriter.cpp:3985)
// and because the net search runs first, every later reference of that name —
// from any subroutine of the module — binds the SAME net.
//
// Purpose-built goldens, 19 one-shape modules (arms a1/a2):
//   fn-local param in a body-local reg range   -> implicit wire (m1, m10)
//   ...in an io_decl range / the RETURN range  -> implicit wire (m4, m5)
//   ...in TWO ranges / in two FUNCTIONS        -> ONE wire, shared (m6, n7)
//   ...in a TASK                               -> identical (m8)
//   `localparam` spelling                      -> identical (n8)
//   the same name in the fn BODY               -> binds the PARAMETER (n5)
//   fn-local VARIABLE in a range               -> binds the variable (m7)
//   MODULE parameter in a fn range             -> DANGLING (m3, n6)
//   name also declared as a module net         -> binds that net (m9, n4)
UHDM::any* UhdmExporter::fnLocalParamRangeActual(std::string_view nm,
                                                 SourceRange nr) {
    if (nm.empty() || !fnDeclTsSub || !implicitNetModule ||
        implicitNetModule->UhdmType() != UHDM::uhdmmodule_inst)
        return nullptr;
    // Only a name the SUBROUTINE ITSELF declares as a parameter reaches the
    // module-level search this way; anything else either bound already or is
    // a genuine dangler.
    auto* lsym = fnDeclTsSub->find(nm);
    if (!lsym || lsym->kind != SymbolKind::Parameter)
        return nullptr;
    const Scope* modScope = nullptr;
    for (auto sc = fnDeclTsSub->getParentScope(); sc;
         sc = sc->asSymbol().getParentScope())
        if (sc->asSymbol().kind == SymbolKind::InstanceBody) {
            modScope = sc;
            break;
        }
    if (!modScope)
        return nullptr;
    if (auto* msym = modScope->find(nm))
        switch (msym->kind) {
            // A module PARAMETER (or anything else the search treats as one)
            // stops it dead and the reference stays dangling.
            case SymbolKind::Parameter:
            case SymbolKind::TypeParameter:
            case SymbolKind::Specparam:
            case SymbolKind::EnumValue:
            case SymbolKind::TypeAlias:
                return nullptr;
            default:
                break;
        }
    if (auto* nets9 = implicitNetModule->Nets())
        for (auto* n9 : *nets9)
            if (n9->VpiName() == nm)
                return n9;
    if (auto* vars9 = implicitNetModule->Variables())
        for (auto* v9 : *vars9)
            if (v9->VpiName() == nm)
                return v9;
    auto* inet = s.MakeLogic_net();
    inet->VpiName(nm);
    inet->VpiFullName(implicitNetPrefix + "." + std::string(nm));
    inet->VpiParent(implicitNetModule);
    inet->VpiNetType(1);
    setLoc(inet, nr);
    auto* nets9 = implicitNetModule->Nets();
    if (!nets9) {
        nets9 = s.MakeNetVec();
        implicitNetModule->Nets(nets9);
    }
    nets9->push_back(inet);
    return inet;
}

// ---- let declarations / --disable-feature=letexprsubstitution -------------
//
// Surelog gates exactly ONE function on the feature:
// `CompileHelper::compileTfCall` (CompileHelper.cpp:4257).  With substitution
// ON a `let` call is replaced by the declaration's body -- and Surelog
// "inlines" by handing back the SHARED `let_decl` body object itself, formals
// unsubstituted (`ref_obj work@m.x`), so an inlined call and the declaration
// are literally the same objects.  With it OFF the call becomes a `let_expr`
// carrying `Arguments` (the actual argument expressions, `vpiActual` resolved)
// and `Let_decl` (a pointer to the shared declaration).  The `let_decl`
// objects themselves exist in BOTH modes -- measured on a with/without-flag
// golden pair -- so `emitLetDecls()` is unconditional and only the CALL site
// is gated.
//
// slang has no call node to gate: `AssertionInstanceExpression::fromLookup`
// answers a `let` call with the EXPANDED body ("Let declarations expand
// directly to an expression"), so the call is gone by the time the emitter
// runs.  What identifies an expansion is that `Expression::create` REFUSES to
// overwrite the syntax pointer for `InvocationExpression`
// (Expression.cpp:872-881, "for cases like let decls that get expanded in
// place"), so the expansion's `syntax` is the let's own BODY syntax -- the
// same node for every call of that let.  `letBodySyntax` indexes that.
//
// The arguments come out of the expansion, not the call syntax: the call
// syntax is NOT recoverable.  `create`'s ordinary NameSyntax path does the
// overwrite it skips for invocations, so a substituted actual ends up with
// `syntax` (and `sourceRange`, rewritten by `bindPort`) pointing at the
// FORMAL's identifier inside the body, not at the call-site argument.  That
// re-anchoring is what makes the actuals findable: walk the expansion for
// expressions whose syntax is an identifier naming one of the let's formals,
// and that expression IS the bound actual for that formal.
//
// Three shapes this model does not reach, all measured, none in the corpus:
//   * a LITERAL actual (`sum2(a, 4'd3)`) is re-anchored too, and the constant
//     arm reads its spelling out of the source text, so it renders as the
//     formal's own text (`vpiDecompile:y`, size 64, value 0) instead of
//     `4'd3`/size 4.  Only the call syntax carries the literal's spelling and
//     the call syntax is gone;
//   * a formal the body never references has no substituted actual anywhere in
//     the expansion, so it is missing from `Arguments` (Surelog lists it, from
//     the call's argument list);
//   * a `let` nested in another `let`'s body collapses the whole formal chain
//     onto the INNERMOST formal identifier, so the outer call's argument is
//     only found when the two formals happen to share a name (they do in the
//     measured reproducer, `let outer(x) = dbl(x) + 2`).
// An ARGUMENT-LESS let (`let konst = 7;`) is not an expansion at all -- its
// reference is a plain NameSyntax, so `create` does overwrite the syntax and
// the body is inlined in both modes.  Surelog never reaches its own gate for
// that shape either (it segfaults on `let konst = 7; assign o = konst;`,
// verified on this Surelog build), so it stays inlined.

const slang::ast::LetDeclSymbol* UhdmExporter::letDeclFor(const Expression& expr) {
    if (letBodySyntax.empty() || !expr.syntax)
        return nullptr;
    auto it = letBodySyntax.find(expr.syntax);
    return it == letBodySyntax.end() ? nullptr : it->second;
}

namespace {
// Every bound actual in a let expansion, keyed by the formal it was
// substituted for: an expression whose `syntax` is an identifier that names one
// of @a ld's formals sits at a formal position, so it IS that formal's actual.
// A formal read twice keeps the first (the actuals are equal by construction).
struct LetActualFinder
    : public slang::ast::ASTVisitor<LetActualFinder, slang::ast::VisitFlags::Expressions |
                                                         slang::ast::VisitFlags::Bad> {
    const slang::ast::LetDeclSymbol* ld = nullptr;
    std::map<const slang::ast::Symbol*, const slang::ast::Expression*> byFormal;

    template<typename T>
    void handle(const T& t) {
        if constexpr (std::is_base_of_v<slang::ast::Expression, T>) {
            if (t.syntax && t.syntax->kind == slang::syntax::SyntaxKind::IdentifierName) {
                auto nm = t.syntax->template as<slang::syntax::IdentifierNameSyntax>()
                              .identifier.valueText();
                if (!nm.empty()) {
                    if (auto* f = ld->find(nm);
                        f && f->kind == slang::ast::SymbolKind::AssertionPort)
                        byFormal.try_emplace(f, static_cast<const slang::ast::Expression*>(&t));
                }
            }
        }
        if constexpr (std::is_same_v<T, slang::ast::InvalidExpression>) {
            // The default visitor stops at an InvalidExpression, but a `let`
            // whose body reads an UNBOUND formal (the default instance a
            // let_decl is emitted from, and any let nested inside one) is bad
            // all the way up, so its actuals live under the wrapper.
            if (t.child)
                t.child->visit(*this);
            return;
        }
        visitDefault(t);
    }
};
} // namespace

UHDM::any* UhdmExporter::emitLetInlined(const Expression& expr, UHDM::BaseClass* parent) {
    if (noLetSubst)
        return nullptr;
    auto* ld = letDeclFor(expr);
    if (!ld)
        return nullptr;
    auto dit = letDeclMap.find(ld);
    if (dit == letDeclMap.end())
        return nullptr;
    auto* body = dit->second->Expressions();
    if (!body || body->size() != 1)
        return nullptr;
    // Surelog "inlines" by handing back the declaration's OWN body object --
    // `cts->Rhs((expr*)stmt->Expr())` in the gated branch -- so every call of a
    // let is literally the same object as the let_decl's body, formals left
    // UNSUBSTITUTED (`ref_obj x`, not the actual). Measured on the pair: with
    // the flag off, `assign o1 = sum2(a, b);` has `vpiRhs -> operation` whose
    // operands are `ref_obj work@m.x` / `ref_obj work@m.y`.
    //
    // The one thing that DOES vary per call site is vpiParent, and Surelog lets
    // the last writer win -- in the pair the shared body's parent is the last
    // USE, not the let_decl -- so re-point it here too. Not cmp-relevant
    // (uhdm-cmp never reads parents); this is byte identity.
    body->at(0)->VpiParent(parent);
    return body->at(0);
}

UHDM::any* UhdmExporter::emitLetExprCall(const Expression& expr, UHDM::BaseClass* parent,
                                         const std::string& prefix, NetMap& netMap) {
    if (!noLetSubst)
        return nullptr;
    auto* ld = letDeclFor(expr);
    if (!ld)
        return nullptr;
    auto dit = letDeclMap.find(ld);
    if (dit == letDeclMap.end())
        return nullptr;
    // A let whose body is a single formal (`let id(x) = x;`) expands to the
    // actual itself, so the expansion and its own argument are the SAME
    // expression; re-entering emitExpr on it would spin.
    if (!letInFlight.insert(&expr).second)
        return nullptr;

    LetActualFinder f;
    f.ld = ld;
    expr.visit(f);

    // Surelog's un-substituted form: a let_expr carrying the actual arguments
    // and a pointer to the shared let_decl. The body is NOT expanded here --
    // it lives once, on the declaration.
    auto* le = s.MakeLet_expr();
    le->VpiParent(parent);
    setLoc(le, expr.sourceRange);
    auto* args = s.MakeExprVec();
    for (auto* formal : ld->ports) {
        auto ait = f.byFormal.find(formal);
        if (ait == f.byFormal.end())
            continue;
        if (auto* a = emitExpr(*ait->second, le, prefix, netMap))
            args->push_back((UHDM::expr*)a);
    }
    if (!args->empty())
        le->Arguments(args);
    le->Let_decl(dit->second);
    letInFlight.erase(&expr);
    return le;
}

// § r10fsv2 R-c.  An enum declared with NO explicit base type
// (`typedef enum { A, B, C } e;`) is NOT substituted into a struct-pattern
// member: Surelog's reduce leaves the reference unresolved and the element
// stays a ref_obj — which is also why that member leaves NO EvalFunc leftover
// behind (FuncStructVal `NOCType: config_pkg::NOC_TYPE_AXI4_ATOP`; golden has
// 96 leftovers on the 97-member struct, we stamped all 97).  An enum with a
// WRITTEN base (`enum logic [1:0]`) substitutes exactly as before
// (AssignmentPatternInAssignmentPattern's `PhaseSeed`, the r10fsv oracle's
// `noc_e`), so the two are distinguished by the DECLARATION, not by whether
// the enum member itself carries an initializer.
static bool enumBaseIsImplicit(const Symbol& sym) {
    if (sym.kind != SymbolKind::EnumValue)
        return false;
    auto& t = sym.as<EnumValueSymbol>().getType().getCanonicalType();
    if (t.kind != SymbolKind::EnumType)
        return false;
    auto* syn = t.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::EnumType)
        return false;
    return syn->as<syntax::EnumTypeSyntax>().baseType == nullptr;
}

// A PACKAGE struct-pattern parameter's ENUM-CONSTANT member value inlines the
// enum member's OWN literal form — not the BIN-at-member-width a MODULE's own
// pattern uses (the enumFold6 rule).  Surelog substitutes the enum_const
// verbatim, so an implicit member (`PhaseSeed`) becomes INT:0 / decompile "0"
// at the enum's base width and an explicitly based one (`MuBi4True = 4'h6`)
// becomes HEX:6 / decompile "4'h6" at the literal's width — in EVERY view
// (both package views, the importing module's materialized copy, and that
// copy's flattened elab re-emit).  Same substitution the qualified pkg::VALUE
// reference arm in emitExpr already performs; the pattern member paths just
// never reached it.  (AssignmentPatternInAssignmentPattern.)
bool UhdmExporter::enumMemberLiteralForm(const Symbol& sym) {
    if (sym.kind != SymbolKind::EnumValue)
        return false;
    if (auto* ein = sym.as<EnumValueSymbol>().getInitializer())
        return stripImplicitConv(*ein).kind == ExpressionKind::IntegerLiteral;
    return true;
}

UHDM::constant* UhdmExporter::enumMemberSubstConst(const Symbol& sym) {
    if (sym.kind != SymbolKind::EnumValue)
        return nullptr;
    auto& evs = sym.as<EnumValueSymbol>();
    std::string val, dec;
    int32_t sz = 0;
    // The enum's own emitted const, when it already exists.  The FIRST (def)
    // package view is emitted before that package's typedefs, so the map is
    // still empty there — reconstruct the same form from the declaration.
    if (auto eit = enumConstMap.find(&evs);
        eit != enumConstMap.end() &&
        eit->second->UhdmType() == UHDM::uhdmenum_const) {
        auto* src = (UHDM::enum_const*)eit->second;
        val = std::string(src->VpiValue());
        dec = std::string(src->VpiDecompile());
        sz = src->VpiSize();
    }
    else if (auto* ein = evs.getInitializer()) {
        auto& lit = stripImplicitConv(*ein);
        if (lit.kind != ExpressionKind::IntegerLiteral)
            return nullptr;
        std::string raw(rawText(lit.sourceRange));
        auto tk = raw.find('\'');
        if (tk == std::string::npos) {
            val = "UINT:" + raw;
            dec = raw;
            sz = 64;
        }
        else {
            size_t bp = tk + 1;
            if (bp < raw.size() && (raw[bp] == 's' || raw[bp] == 'S'))
                bp++;
            char b = bp < raw.size() ? (char)tolower(raw[bp]) : 'd';
            std::string dg = stripSep(raw.substr(bp + 1));
            // A based-DECIMAL enum init (3'd0) encodes INT, like TypeEmit's
            // enum_const builder.
            val = (b == 'b'   ? "BIN:"
                   : b == 'h' ? "HEX:"
                   : b == 'o' ? "OCT:"
                              : "INT:") +
                  dg;
            dec = stripSep(raw);
            sz = (int32_t)lit.type->getBitWidth();
        }
    }
    else if (auto& cvv = evs.getValue();
             cvv.isInteger() && !cvv.integer().hasUnknown()) {
        dec = cvv.integer().toString(LiteralBase::Decimal, false);
        val = "INT:" + dec;
        sz = (int32_t)evs.getType().getBitWidth();
    }
    // § enumSubstDecBare — a BASED-DECIMAL member (`XV_STD = 4'd4`) loses its
    // base in the SUBSTITUTED copy: golden writes decompile "4" at INT:4 /
    // vpiIntConst / size 4 while the ENUM_CONST object itself keeps `4'd4`.
    // Only the decimal base drops — a BIN member (`PRIV_M = 2'b11`) and a HEX
    // one (`HX_A = 4'h6`) keep their spelling in the substituted copy too
    // (tc.sv negative controls), which is what the vpiIntConst encoding
    // already distinguishes.  Measured in every view: both package views, a
    // module struct-pattern localparam, the importing module's materialized
    // import copy, and an always_ff non-blocking pattern rhs.  Corpus:
    // ibex_cs_registers.sv:690 `xdebugver: XDEBUGVER_STD` — 3 Earlgrey heads
    // (ibex_core, ibex_cs_registers, rv_core_ibex).
    if (val.rfind("INT:", 0) == 0 && dec.find('\'') != std::string::npos)
        dec = val.substr(4);
    if (sz <= 0 || val.empty())
        return nullptr;
    auto* c = s.MakeConstant();
    c->VpiSize(sz);
    c->VpiValue(val);
    c->VpiDecompile(dec);
    c->VpiConstType(val.rfind("BIN:", 0) == 0   ? vpiBinaryConst
                    : val.rfind("HEX:", 0) == 0 ? vpiHexConst
                    : val.rfind("OCT:", 0) == 0 ? vpiOctConst
                    : val.rfind("DEC:", 0) == 0 ? vpiDecConst
                    : val.rfind("INT:", 0) == 0 ? vpiIntConst
                                                : vpiUIntConst);
    return c;
}

// § hierSelPkgParamFold (declaration comment in UhdmExporter.h) — collector.
void UhdmExporter::collectPkgParamFolds(const Expression& e,
                                        std::vector<PkgFoldSub>& out) {
    e.visit(makeVisitor([&](auto& v, const NamedValueExpression& nv) {
        v.visitDefault(nv);
        if (nv.symbol.kind != SymbolKind::Parameter)
            return;
        // The same "declared in a PACKAGE" test § stampFoldedPkgParamTs uses:
        // a module parameter or localparam is still symbolic at the module's
        // definition compile and stays spelled out.
        auto* psc = nv.symbol.getParentScope();
        if (!psc || psc->asSymbol().kind != SymbolKind::Package)
            return;
        auto& dp = nv.symbol.as<ParameterSymbol>();
        auto& cv = dp.getValue();
        if (!cv.isInteger() || cv.integer().hasUnknown())
            return;
        auto sr = nv.sourceRange;
        if (sr.start() == SourceLocation::NoLocation ||
            sr.end() == SourceLocation::NoLocation || sm->isMacroLoc(sr.start()))
            return;
        std::string t;
        if (auto* ini = dp.getInitializer()) {
            auto& si = stripImplicitConv(*ini);
            if (si.kind == ExpressionKind::IntegerLiteral)
                t = stripSep(rawText(si.sourceRange));
        }
        if (t.empty())
            t = cv.integer().toString(LiteralBase::Decimal, false);
        if (!t.empty())
            out.push_back({sr.start(), sr.end(), t});
    }));
}

// § hierSelPkgParamFold — rawText with those substitutions spliced in.
std::string UhdmExporter::rawTextPkgFold(SourceRange range,
                                         const std::vector<PkgFoldSub>& subs) {
    std::string base = rawText(range);
    if (base.empty() || subs.empty())
        return base;
    if (range.start() == SourceLocation::NoLocation ||
        sm->isMacroLoc(range.start()))
        return base;
    auto buf = range.start().buffer();
    size_t r0 = range.start().offset(), r1 = range.end().offset();
    if (r1 - r0 != base.size())
        return base;  // the range was rewritten (macro origin) — leave it
    std::vector<const PkgFoldSub*> in;
    for (auto& s9 : subs) {
        if (s9.b.buffer() != buf || s9.e.buffer() != buf)
            continue;
        if (s9.b.offset() < r0 || s9.e.offset() > r1 ||
            s9.b.offset() >= s9.e.offset())
            continue;
        in.push_back(&s9);
    }
    if (in.empty())
        return base;
    std::sort(in.begin(), in.end(),
              [](const PkgFoldSub* x, const PkgFoldSub* y) {
                  return x->b.offset() < y->b.offset();
              });
    std::string out;
    size_t cur = r0;
    for (auto* s9 : in) {
        size_t a = s9->b.offset(), b = s9->e.offset();
        if (a < cur)
            continue;  // nested/overlapping reads: the outer one already ran
        out += base.substr(cur - r0, a - cur);
        out += s9->txt;
        cur = b;
    }
    out += base.substr(cur - r0);
    return out;
}

// § elabHierSelWidthFold (declaration comment in UhdmExporter.h).
void UhdmExporter::stampFoldedPkgParamTs(UHDM::constant* c, const Symbol& sym,
                                         const std::string& fullName,
                                         bool declTsOnly) {
    if (!c || sym.kind != SymbolKind::Parameter)
        return;
    auto* psc = sym.getParentScope();
    if (!psc || psc->asSymbol().kind != SymbolKind::Package)
        return;
    auto& dp = sym.as<ParameterSymbol>();
    bool implicit9 = true;
    if (auto dt9 = dp.getDeclaredType())
        if (auto* ts9 = dt9->getTypeSyntax())
            implicit9 = ts9->kind == syntax::SyntaxKind::ImplicitType;
    UHDM::typespec* its = nullptr;
    if (!implicit9)
        if (auto poit = pkgParamObj.find(&sym);
            poit != pkgParamObj.end() && poit->second->Typespec())
            its = poit->second->Typespec()->Actual_typespec();
    // § psBoundPkgParamTs31's abstention: an EXPLICITLY typed package parameter
    // whose own typespec is not resolvable here would otherwise get a
    // synthesized int_typespec — a WRONG object where golden has the typedef's
    // logic_typespec (e2_origin.sv c5, `localparam w_t TC = 4'h3;`, whose
    // parameter object carries the right ref_typespec but whose
    // Actual_typespec is still unbound at this point).  Leave it bare.
    if (!its && !implicit9 && declTsOnly)
        return;
    if (!its) {
        auto* its0 = s.MakeInt_typespec();
        if (auto dt = dp.getDeclaredType())
            if (auto tsy = dt->getTypeSyntax()) {
                if (implicit9) {
                    for (auto q9 = dp.getSyntax(); q9; q9 = q9->parent)
                        if (q9->kind == syntax::SyntaxKind::ParameterDeclaration) {
                            setLoc(its0, q9->sourceRange());
                            break;
                        }
                }
                else {
                    if (dp.getType().isSigned())
                        its0->VpiSigned(true);
                    setLoc(its0, tsy->sourceRange());
                }
            }
        its = its0;
    }
    auto* rt = s.MakeRef_typespec();
    rt->VpiFullName(fullName);
    rt->VpiParent(c);
    rt->Actual_typespec(its);
    c->Typespec(rt);
}

UHDM::any* UhdmExporter::emitExpr(const Expression& expr, UHDM::BaseClass* parent,
                                  const std::string& prefix,
                                  NetMap& netMap) {
    // A `let` call, which slang already expanded in place: with substitution ON
    // it becomes the declaration's shared body object, with it OFF a let_expr.
    // Costs one empty-map test on designs that declare no `let`.
    if (!letBodySyntax.empty()) {
        if (auto* le = emitLetExprCall(expr, parent, prefix, netMap))
            return le;
        if (auto* sh = emitLetInlined(expr, parent))
            return sh;
    }
    // `parameter value = (1:2:3)`: Surelog keeps the whole min:typ:max as an
    // operation(vpiMinTypMaxOp=38) over its three arms, UNFOLDED, in the def
    // AND elaborated views alike — it never picks an arm.  The operation spans
    // the ENCLOSING PARENTHESES and its operands stay UNPARENTED (Surelog's
    // constant compile never back-links) — MinTypMax.
    if (expr.kind == ExpressionKind::MinTypMax) {
        auto& mtm9 = expr.as<MinTypMaxExpression>();
        auto* op9 = s.MakeOperation();
        op9->VpiOpType(vpiMinTypMaxOp);
        op9->VpiParent(parent);
        SourceRange sr9 = expr.sourceRange;
        // slang REPLACES a parenthesized expression's syntax pointer with the
        // ParenthesizedExpressionSyntax while leaving sourceRange on the inner
        // node, so check both shapes.
        if (expr.syntax) {
            if (expr.syntax->kind ==
                syntax::SyntaxKind::ParenthesizedExpression)
                sr9 = expr.syntax->sourceRange();
            else if (expr.syntax->parent &&
                     expr.syntax->parent->kind ==
                         syntax::SyntaxKind::ParenthesizedExpression)
                sr9 = expr.syntax->parent->sourceRange();
        }
        setLoc(op9, sr9);
        auto* ov9 = s.MakeAnyVec();
        const Expression* arms9[3] = {&mtm9.min(), &mtm9.typ(), &mtm9.max()};
        bool fcp9 = forceConstParent;
        bool scp9 = suppressConstParent;
        forceConstParent = false;
        suppressConstParent = true;
        for (auto* sub9 : arms9)
            if (auto* e9 = emitExpr(*sub9, op9, prefix, netMap)) {
                e9->VpiParent(nullptr);
                ov9->push_back(e9);
            }
        suppressConstParent = scp9;
        forceConstParent = fcp9;
        op9->Operands(ov9);
        return op9;
    }
    // § staticScopedChainDrops48 — a `::`-rooted chain collapses to its BASE
    // REFERENCE, wherever it stands.  The arm that decided this is t67a C5/C6/
    // C10/C13 against C1..C4: the corpus site
    // (uvm_comparer.svh:156 `uvm_object::__m_uvm_status_container.scope.set_arg
    // (name);`) is a STATEMENT, and a statement rule and an expression rule are
    // indistinguishable there.  Golden collapses the SAME chain as an operand of
    // `+ 1`, as a whole assignment Rhs, as a `$display` argument, as a user
    // call's argument (t67d H7), inside an `if` condition (t67b D8) and in a
    // continuous assign (t67c G7) — so it is an EXPRESSION rule and this hook
    // sits ahead of the whole dispatch rather than in the statement emitter.
    // Reader context is irrelevant: a class method, a package function
    // (t67a C15), a module initial block (t67a C16) and a module function
    // (t67d H8) all collapse, and a TASK call collapses like a function call
    // (t67d H10).
    // The PACKAGE-VARIABLE root re-emits the BASE EXPRESSION so it keeps the
    // object the pre-existing isPkgQualifiedVarRef arm already builds (name,
    // and the vpiActual golden binds in a module — t67c G7's cont_assign) —
    // that half of the collapse is landed law and this pass does not respell
    // it.  A CLASS-SCOPED root cannot go that way: § staticScopedRef12 reads
    // the base sub-expression's syntax and a CHAINED base has NONE, so its
    // object is rebuilt by § scopedChainDropRef48 from the chain's own syntax.
    // The LVALUE form is § staticScopedLvalueBad48 in both cases.
    if (auto* cb48 = scopedChainDropBase48(expr)) {
        if (inLhs && assignTargetParent48(parent)) {
            if (auto* bad48 = scopedLvalueBadRef48(expr, parent, prefix))
                return bad48;
        }
        else if (isPkgQualifiedVarRef(*cb48)) {
            if (auto* base48 = emitExpr(*cb48, parent, prefix, netMap))
                return base48;
        }
        else if (auto* cr48 = scopedChainDropRef48(expr, parent, prefix))
            return cr48;
    }
    switch (expr.kind) {
        case ExpressionKind::Assignment: {
            auto& ae = expr.as<AssignmentExpression>();
            // § outArgLvalue17 — an OUTPUT / INOUT actual is not an assignment
            // in the model, it is the bare lvalue.  slang binds one as a
            // SYNTHESIZED AssignmentExpression carrying the copy-back
            // (`left = <EmptyArgument>`), which the call-argument arm below
            // then renders as operation(vpiAssignmentOp) — Surelog lists the
            // written lvalue and nothing else.  Pinned by t29 (output formal,
            // inout formal, and an INDEXED actual, in statement position and
            // in a while/if condition): golden gives `ref_obj 't'` /
            // `bit_select 'arr'` where we gave an operation at the assignment's
            // span.  A `ref` formal never takes this form — slang passes the
            // actual straight through — so nothing there changes.  UVM's
            // `m_req_fifo.try_get(t)` family is ~620 rows on SeqDriver.
            if (ae.right().kind == ExpressionKind::EmptyArgument)
                return emitExpr(ae.left(), parent, prefix, netMap);
            // An EMBEDDED assignment expression (x = (y = ...) + 1) — one used
            // as an OPERAND or as another assignment's RHS — is an
            // operation(vpiAssignmentOp=82) with [lhs, rhs] operands
            // (paren-inclusive span); a STATEMENT-level assignment (parent is
            // a block/process) stays an assignment object (handled below).
            // A COMPOUND embedded assignment (x = (y *= 2)) takes the same
            // operation(82) — the compound operator itself is NOT encoded —
            // with the value operand extracted from slang's expanded binary
            // (asgn_expr_sv).
            // A CALL ARGUMENT (f((i = 3))) is an operand position too: UHDM's
            // tf_call_args group only accepts exprs, so an `assignment` there
            // is rejected outright ("adding wrong object type (assignment) in
            // a tf_call_args group") and left orphaned.
            bool argCtx9 = false;
            if (parent)
                switch (parent->UhdmType()) {
                    case UHDM::uhdmfunc_call:
                    case UHDM::uhdmtask_call:
                    case UHDM::uhdmmethod_func_call:
                    case UHDM::uhdmmethod_task_call:
                    case UHDM::uhdmsys_func_call:
                    case UHDM::uhdmsys_task_call:
                        argCtx9 = true;
                        break;
                    default:
                        break;
                }
            if (parent &&
                (argCtx9 || parent->UhdmType() == UHDM::uhdmoperation ||
                 parent->UhdmType() == UHDM::uhdmassignment)) {
                const Expression* rhsE = &ae.right();
                if (ae.isCompound() && ae.op) {
                    auto& rc = stripImplicitConv(ae.right());
                    if (rc.kind == ExpressionKind::BinaryOp) {
                        auto& be = rc.as<BinaryExpression>();
                        rhsE = stripImplicitConv(be.left()).kind ==
                                       ExpressionKind::LValueReference
                                   ? &be.right()
                                   : &be.left();
                    }
                }
                auto* op = s.MakeOperation();
                op->VpiOpType(kVpiAssignmentOp);
                op->VpiParent(parent);
                // The span reaches the enclosing parentheses.
                SourceRange sr = expr.sourceRange;
                if (expr.syntax &&
                    expr.syntax->kind == syntax::SyntaxKind::ParenthesizedExpression)
                    sr = expr.syntax->sourceRange();
                setLoc(op, sr);
                auto* operands = s.MakeAnyVec();
                // The LHS ref parents at the ENCLOSING assignment context,
                // not this op.
                UHDM::BaseClass* lhsParent = enclosingAssign ? enclosingAssign : op;
                inLhs = true;
                if (auto* l = emitExpr(ae.left(), lhsParent, prefix, netMap))
                    operands->push_back(l);
                inLhs = false;
                // A DIRECT leaf-constant RHS (z = 99) unparents; a nested op
                // RHS ((z=99)+1) self-parents and its operands parent
                // normally. This op is the enclosing context for the RHS.
                auto* savedEncl = enclosingAssign;
                enclosingAssign = op;
                bool savedS = suppressConstParent;
                if (isLiteralExpr(stripImplicitConv(*rhsE)))
                    suppressConstParent = true;
                if (auto* r = emitExpr(*rhsE, op, prefix, netMap))
                    operands->push_back(r);
                suppressConstParent = savedS;
                enclosingAssign = savedEncl;
                op->Operands(operands);
                return op;
            }
            auto* asn = s.MakeAssignment();
            // NOTE § compoundWriteBack — DECODED FROM SOURCE, NOT IMPLEMENTED.
            // When Surelog's constant-function evaluator EXECUTES a body, it
            // OVERWRITES a compound assignment's LITERAL Rhs constant in the
            // tree with the value it computed.  UHDM
            // templates/ExprEval.cpp::setValueInInstance (~5021, opType tail
            // ~5395):
            //     rhsexp = reduceExpr(st->Rhs())    // the tree's own object
            //     valUI  = get_uvalue(rhsexp)       // read BEFORE any write
            //     c      = any_cast<constant*>(rhsexp)   // === that object
            //     prevRhs= the param_assign holding the LHS's current value
            //     vpiAddOp : c->VpiValue("UINT:" + (valUI + uval(prevRhs)))
            //     vpiSubOp : c->VpiValue("INT:"  + (val(prevRhs) - valI))
            //     vpiMultOp: c->VpiValue("INT:"  + (val(prevRhs) * valI))
            //     vpiDivOp : c->VpiValue("INT:"  + (val(prevRhs) / valI))
            //     ...then a NEW param_assign for the LHS is pushed with Rhs = c
            // Two consequences make the value non-obvious: (1) the variable's
            // stored value object IS the literal, so from the SECOND execution
            // on prevRhs == rhsexp and `a += <lit>` DOUBLES the literal every
            // iteration (L, 2L, 4L, ...); (2) the arithmetic is uint64 masked
            // at the literal's own VpiSize, so a long enough loop WRAPS it to
            // zero.  Confirmed on tools/probe/r10rggen9repro/t7.sv (five
            // shapes: while->4, for5->16, for64->0, for70->0, `b-=2` twice
            // ->0) and it is what makes rggen_or_reducer:30 `list_index += 1`
            // read UINT:0 in golden while the written literal is 1 — the DEF
            // listing's function object is shared across every
            // rggen_or_reducer instance, so the exponent saturates.
            // That single object is the WHOLE-DESIGN cmp head for Rggen.
            // Implementing it means emulating ExprEval's evalStmt (including
            // packed bit-select LHS writes) AND the order/set of evaluations
            // over the whole design — SrlgFold (ParamEmit ~2062) is the
            // starting point but bails on compound assignments and non-
            // NamedValue LHSs today.  Recorded, not guessed.
            //
            // Compound assignments (o += 10) carry the operator as the
            // assignment op type; the Rhs is the value operand (the implicit
            // LValueReference self-reference is dropped).
            const Expression* rhsExpr = &ae.right();
            if (ae.isCompound() && ae.op) {
                asn->VpiOpType(mapBinaryOp(*ae.op));
                auto& rc = stripImplicitConv(ae.right());
                if (rc.kind == ExpressionKind::BinaryOp) {
                    auto& be = rc.as<BinaryExpression>();
                    rhsExpr = stripImplicitConv(be.left()).kind ==
                                      ExpressionKind::LValueReference
                                  ? &be.right()
                                  : &be.left();
                }
            }
            else {
                asn->VpiOpType(kVpiAssignmentOp);
            }
            asn->VpiBlocking(!ae.isNonBlocking());
            asn->VpiParent(parent);
            setLoc(asn, expr.sourceRange);
            inLhs = true;
            if (auto* lhs = emitExpr(ae.left(), asn, prefix, netMap)) {
                asn->Lhs((UHDM::expr*)lhs);
                // A class-handle assignment (bar = new()) re-parents its Lhs
                // ref through an artifact hier_path (weakly-tail only).
                // NOTE § invalidNewCallFromSyntax55 (Lhs half).  GATE widened
                // from `kind == NewClass` to `sourceIsNewClassExpr55`, so the
                // SAME re-parent happens when slang left the `new` UNBOUND.
                // Surelog's rule is a SOURCE rule — it never bound anything —
                // so an unbound `new` must not take a different Lhs shape from
                // a bound one.  DUMP-ONLY at the corpus sites (`vpiParent` is
                // not read by `assignment::Compare`, which compares Rhs then
                // Lhs, and the ref's `Actual_group` is null on BOTH sides
                // there), measured on arm a1 cells C8/C9/C10.
                if (sourceIsNewClassExpr55(stripImplicitConv(*rhsExpr)) &&
                    lhs->UhdmType() == UHDM::uhdmref_obj) {
                    auto* hp = s.MakeHier_path();
                    hp->VpiName(((UHDM::ref_obj*)lhs)->VpiName());
                    hp->VpiFullName(((UHDM::ref_obj*)lhs)->VpiName());
                    hp->VpiParent(asn);
                    auto* elems = s.MakeAnyVec();
                    elems->push_back(lhs);
                    hp->Path_elems(elems);
                    lhs->VpiParent(hp);
                    ((UHDM::ref_obj*)lhs)->Actual_group(nullptr);
                }
            }
            inLhs = false;
            // This assignment is the enclosing context for any embedded
            // assignment expressions in its RHS.
            auto* savedEncl0 = enclosingAssign;
            enclosingAssign = asn;
            auto* rhs = emitExpr(*rhsExpr, asn, prefix, netMap);
            enclosingAssign = savedEncl0;
            // § r10fsv3 S2.  Inside a package subroutine, remember the object
            // this assignment's RHS became: an EvalFunc member leftover whose
            // reduce fails IS this object, shared (never re-emitted).  Only the
            // ELABORATED view's copy is ever the leftover, and it is emitted
            // second, so the plain overwrite lands on the right one.
            if (rhs && pkgScopeInst && currentTf)
                bodyAsgRhsObj[rhsExpr] = rhs;
            // A backslash-padded STRING Rhs stretches the assignment's end
            // column to match (StringWithBackslash).
            if (rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                ((UHDM::constant*)rhs)->VpiConstType() == vpiStringConst &&
                ((UHDM::expr*)rhs)->VpiEndLineNo() == asn->VpiEndLineNo() &&
                ((UHDM::expr*)rhs)->VpiEndColumnNo() > asn->VpiEndColumnNo())
                asn->VpiEndColumnNo(((UHDM::expr*)rhs)->VpiEndColumnNo());
            if (rhs) {
                // In a MODULE FUNCTION body, an unbased-unsized '0/'1/'x RHS
                // takes the LHS width (an always-block leaves it unsized). Only
                // the direct assignment RHS is sized, not '0 as an operation
                // operand. A PACKAGE function body keeps the literal UNSIZED
                // (size -1, '0 decompile) — rp32 enc32 `enc32 = '0;`.
                bool pkgSub9 = false;
                if (currentSubSym)
                    for (auto sc9 = currentSubSym->getParentScope(); sc9;
                         sc9 = sc9->asSymbol().getParentScope())
                        if (sc9->asSymbol().kind == SymbolKind::Package) {
                            pkgSub9 = true;
                            break;
                        }
                // ...and only when the function is CALLED as the direct RHS of
                // a CONTINUOUS assignment: the sizing is Surelog's assignment
                // context reaching through the call into the body, so a call
                // that sits under an operation (`a = f(x) ^ g(y)`) or is the
                // RHS of a PROCEDURAL assignment leaves every literal in the
                // body unsized.  Measured one mutation at a time from
                // func_forloop_onehot (sized) to the same module with the call
                // under a `^` (unsized); Scr1SvTests width2axsize (ternary
                // operand) and mem_read (`<=` RHS) are both unsized in golden.
                // ...and the same sizing reaches the body from a PARAMETER
                // reduction that executes the function (§
                // subEvaluatedFromParamInit).  There the LHS must be the WHOLE
                // variable: `b[0] = '1;` in an executed body keeps `'1`/-1
                // (probe t7), because ExprEval's select arm writes one bit
                // rather than re-sizing the literal.
                bool paramEvalSize9 =
                    currentSubSym && !pkgSub9 &&
                    stripImplicitConv(ae.left()).kind ==
                        ExpressionKind::NamedValue &&
                    subEvaluatedFromParamInit(*currentSubSym);
                // § pkgFuncFillSizedInElab — the package arm of the same rule.
                // The `!pkgSub9` exclusion above was measured on rp32's
                // riscv_isa_i_pkg::enc32, whose only caller multiplies the
                // call into an operation (`(enc32(...) & 32'hff..) | ...`) —
                // i.e. NOT a direct cont-assign rhs — so it never separated
                // "package" from "not called that way".  u.sv/v.sv separate
                // them: a package function that IS a continuous assignment's
                // direct rhs takes the sizing too, but ONLY in the ELABORATED
                // (uhdmtopPackages) copy; the def copy keeps the raw literal.
                // `'x`/`'z` are NOT respelled there (w.sv row E: golden's
                // elaborated wp keeps `'X`/-1 beside an `'1` that became
                // 11111111/8) — Surelog's evaluator sizes a value it can
                // represent, and an unknown fill has none.  The whole-variable
                // LHS gate is the same one the module arm uses.
                bool fillKnown9 = false;
                {
                    auto& ub0 = stripImplicitConv(*rhsExpr);
                    if (ub0.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral)
                        fillKnown9 = !ub0.as<UnbasedUnsizedIntegerLiteral>()
                                          .getLiteralValue()
                                          .isUnknown();
                }
                bool pkgElabSize9 = pkgSub9 && pkgTopEmit && currentSubSym &&
                                    fillKnown9 &&
                                    stripImplicitConv(ae.left()).kind ==
                                        ExpressionKind::NamedValue &&
                                    pkgSubCalledAsContAssignRhs(*currentSubSym);
                if (currentSubSym &&
                    rhs->UhdmType() == UHDM::uhdmconstant &&
                    ((UHDM::expr*)rhs)->VpiSize() == -1 &&
                    ((!pkgSub9 && (subCalledAsContAssignRhs(*currentSubSym) ||
                                   paramEvalSize9)) ||
                     pkgElabSize9) &&
                    stripImplicitConv(*rhsExpr).kind ==
                        ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                    int32_t w = (int32_t)ae.left().type->getBitWidth();
                    if (w > 0) {
                        auto* c = (UHDM::constant*)rhs;
                        std::string v(c->VpiValue());
                        char d = v.empty() ? '0' : v.back();
                        std::string rep((size_t)w, d);
                        c->VpiSize(w);
                        c->VpiValue("BIN:" + rep);
                        c->VpiDecompile(rep);
                    }
                }
                asn->Rhs(rhs);
                // § memberActualLeak (TaskFuncEmit.cpp): Surelog's evaluator,
                // folding a continuous assignment's rhs call, stores the
                // reduced rhs of `v.m = ...` on the STRUCT TYPESPEC's member.
                if (currentSubSym && memberActualLeak(expr)) {
                    const Expression* l0 = &stripImplicitConv(ae.left());
                    if (l0->kind == ExpressionKind::MemberAccess) {
                        auto& ma0 = l0->as<MemberAccessExpression>();
                        const Expression* b0 = &stripImplicitConv(ma0.value());
                        if (b0->kind == ExpressionKind::NamedValue) {
                            auto& bs0 = b0->as<NamedValueExpression>().symbol;
                            auto it0 = netMap.find(&bs0);
                            UHDM::typespec* at0 = nullptr;
                            if (it0 != netMap.end() && it0->second &&
                                it0->second->UhdmType() != UHDM::uhdmref_obj) {
                                auto* v0 = (UHDM::variables*)it0->second;
                                if (auto* rt0 = v0->Typespec())
                                    at0 = rt0->Actual_typespec();
                            }
                            if (at0 &&
                                at0->UhdmType() == UHDM::uhdmstruct_typespec) {
                                auto* mv0 =
                                    ((UHDM::struct_typespec*)at0)->Members();
                                if (mv0)
                                    for (auto* m0 : *mv0)
                                        if (m0->VpiName() == ma0.member.name)
                                            m0->Actual_value((UHDM::expr*)rhs);
                            }
                        }
                    }
                }
            }
            // Intra-assignment delay ("state <= #1 next;").
            if (ae.timingControl && ae.timingControl->kind == TimingControlKind::Delay)
                asn->Delay_control(emitDelayControl(*ae.timingControl, asn));
            return asn;
        }
        case ExpressionKind::ConditionalOp: {
            auto& cond = expr.as<ConditionalExpression>();
            if (cond.conditions.size() != 1 || cond.conditions[0].pattern) {
                noteUnsupported("complex conditional");
                return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiConditionOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            auto* c9 = emitExpr(*cond.conditions[0].expr, op, prefix, netMap);
            if (c9) operands->push_back(c9);
            // Surelog reduces a cont-assign RHS operand by operand and
            // ABANDONS the attempt at the first operand it cannot fold.  A
            // ternary's CONDITION is that first operand, so when it is not
            // constant the branches are never descended into and a func_call
            // in either branch never has its actuals bound to the callee's
            // formals — no formal-typespec ref on the argument refs, in the
            // def view and the elab view alike.  Measured pair:
            //   scr1_mem_axi `assign awsize = force_write ?
            //     width2axsize(core_width) : width2axsize(req_fifo[..])`
            //     -> every actual bare in golden (both views, both instances)
            //   openmsp430 `assign q = one_hot16(rw) & {16{s}}` — the call is
            //     operand 0, reached before anything can abort -> STAMPED
            // This is the same certainly-reached-PREFIX law that governs the
            // in-body stamp (drainBodyOpArgTs): over-stamping invents objects,
            // under-stamping only drops them, so only the ternary — where the
            // abort is unconditional — is modelled here.
            bool savedStop9 = caCondReduceStop;
            if ((contAssignView != 0 || ndaRhsEmit) &&
                (!c9 || c9->UhdmType() != UHDM::uhdmconstant))
                caCondReduceStop = true;
            // § psBoundPkgParamTs31's F1 gate, THE SOURCE HALF (added at
            // integration): golden stamps a fold's ref_typespec on the
            // CONDITION and the FALSE arm of a ternary inside a select bound
            // but leaves the TRUE arm BARE (verifier arms v4_ops.sv o24 — one
            // line, all three positions — and the 24-line minimal witness
            // v3_tern.sv, which the un-gated law flipped from PASS_CMP +
            // DUMP_MATCH to CMP_FAIL).  A walk-up test at the stamp site
            // CANNOT see this: `op->Operands(operands)` is attached at the
            // END of this block, so during operand emission the list is NULL
            // and no positional read of the parent works — measured twice
            // (a pointer test, then a size test; both provably dead).  So the
            // position is recorded WHERE IT IS KNOWN — here, around the
            // true-arm emission — as a stack of op POINTERS so the stamp walk
            // refuses on the exact ancestor (a part_select that itself sits
            // in a true arm must still stamp its own bounds).
            ternTrueArmOps31.push_back(op);
            if (auto* t = emitExpr(cond.left(), op, prefix, netMap))
                operands->push_back(t);
            ternTrueArmOps31.pop_back();
            if (auto* f = emitExpr(cond.right(), op, prefix, netMap))
                operands->push_back(f);
            caCondReduceStop = savedStop9;
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::NamedValue: {
            auto& nv = expr.as<NamedValueExpression>();
            if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                refCollector->insert(&nv.symbol);
            // § shadowedImportParamFold — a module DEF listing's read of a
            // module-scope parameter whose name a wildcard-imported package
            // ALSO declares is the PACKAGE member's value in golden, never a
            // reference: Surelog's getValue is name-keyed and the local
            // declaration does not hide the import from it.  vr.sv rows
            // E1 (for-loop bound) / E2 (procedural) / E3 (continuous) all
            // fold; corpus usbdev.sv:245 `i < NEndpoints` next to
            // `import usbdev_reg_pkg::*`.
            if (defStmtImportScope9 && !inLhs &&
                nv.symbol.kind == SymbolKind::Parameter &&
                nv.symbol.getParentScope() &&
                nv.symbol.getParentScope()->asSymbol().kind !=
                    SymbolKind::Package)
                if (const ParameterSymbol* wq8 = wildcardPkgParamNamed9(
                        defStmtImportScope9, nv.symbol.name))
                    if (auto* c8 = pkgBoundValueConst9(*wq8, parent)) {
                        setLoc(c8, expr.sourceRange);
                        // Golden names the ts ref after the DECLARING module
                        // (`work@vra`); not a cmp-compared field, recorded
                        // here so a later span/name pass has the datum.
                        return c8;
                    }
            // § elabMisevalRefSubst — inside the ELAB Rhs of a parameter
            // Surelog left UNFOLDED (§ elabUnitMisevalNoFold) a reference to a
            // SIBLING parameter of the same body is NOT a reference in the
            // golden: `substituteAssignedValue` still answered it, with that
            // parameter's own elaborated value tree.  Only the enclosing
            // REDUCTION was refused, never the substitution — which is why the
            // unfolded elab tree is the def tree with its parameter leaves
            // replaced.
            //
            // Two shapes, and the golden's object IDS decide between them
            // (probe tools/probe/r10scr12a.cpp prints them):
            //   * the substituted parameter's Rhs is a LEAF (constant/ref_obj)
            //     -> a FRESH object at the USE SITE's span.  scr1_dmi
            //     `DMI_OP_HI = DMI_OP_LO + SCR1_DBG_DMI_OP_WIDTH - 1` carries
            //     constant{INT:0,sz=5}@70:29-38 where DMI_OP_LO's own Rhs is
            //     the same constant @69:29-33 under a DIFFERENT id.
            //   * it is COMPOSITE (an operation) -> the golden reuses THE VERY
            //     OBJECT, so the span is the substituted parameter's own, not
            //     the use site's: `DMI_DATA_LO = DMI_OP_HI + 1` holds
            //     DMI_OP_HI's operation#42090 @70:29-70:70 verbatim, and the
            //     five-deep DMI_* ladder shares one chain of ids.
            // A LEAF also picks up the substituted parameter's own typespec
            // when that parameter is a predefined integer type — the same rule
            // § elabVarRangeMisevalSubst applies one level up (scr1_pipe_tdu
            // `ALLTRIG_W = $clog2(ALLTRIG_NUM+1)` -> ref_obj@77:46-57 typed by
            // ALLTRIG_NUM's int_typespec@76:12-24).  A reference the reducer
            // never resolved ($unit, unitParamNoValue) has nothing to
            // substitute and stays a dangling ref_obj, which is why the
            // SCR1_DBG_* operands of the same ladder survive.
            if (misevalParamRhsScope &&
                nv.symbol.kind == SymbolKind::Parameter &&
                nv.symbol.getParentScope() == misevalParamRhsScope) {
                auto rit9 = paramRhsObj.find(&nv.symbol);
                if (rit9 != paramRhsObj.end() && rit9->second)
                    if (auto* cl9 = cloneUnitParamRhs(
                            (const UHDM::expr*)rit9->second, parent)) {
                        bool leaf9 = cl9->UhdmType() == UHDM::uhdmconstant ||
                                     cl9->UhdmType() == UHDM::uhdmref_obj;
                        if (leaf9)
                            setLoc(cl9, expr.sourceRange);
                        auto& sps9 = nv.symbol.as<ParameterSymbol>();
                        if (leaf9 &&
                            sps9.getType().getCanonicalType().kind ==
                                SymbolKind::PredefinedIntegerType) {
                            auto* its9 = s.MakeInt_typespec();
                            if (auto dt9 = sps9.getDeclaredType())
                                if (auto tsy9 = dt9->getTypeSyntax())
                                    setLoc(its9, tsy9->sourceRange());
                            auto* rt9 = s.MakeRef_typespec();
                            rt9->VpiParent(cl9);
                            if (cl9->UhdmType() == UHDM::uhdmref_obj)
                                rt9->VpiFullName(std::string(
                                    ((UHDM::ref_obj*)cl9)->VpiFullName()));
                            its9->VpiParent(rt9);
                            rt9->Actual_typespec(its9);
                            cl9->Typespec(rt9);
                        }
                        return cl9;
                    }
            }
            // A PACKAGE-QUALIFIED reference to a package VARIABLE written
            // from outside that package (`svunit_pkg::current_tc`) keeps its
            // qualified spelling. READ, it resolves and binds the package's
            // own variable object. As an assignment TARGET, Surelog's
            // resolution fails outright and it emits the literal placeholder
            // `<pkg>::@@BAD_SYMBOL@@`, unbound — measured on class-handle,
            // int, string and logic package vars alike (r10apb3 repro 8), and
            // on ApbSlave's four `svunit_pkg::current_tc = svunit_ut;`.
            if (isPkgQualifiedVarRef(expr)) {
                std::string pn9(nv.symbol.getParentScope()->asSymbol().name);
                std::string nm9 = pn9 + "::" +
                                  (inLhs ? std::string("@@BAD_SYMBOL@@")
                                         : std::string(nv.symbol.name));
                auto* qr9 = s.MakeRef_obj();
                qr9->VpiName(nm9);
                qr9->VpiFullName(joinPath(prefix, nm9));
                qr9->VpiParent(parent);
                setLoc(qr9, expr.sourceRange);
                if (!inLhs)
                    if (auto pa9 = pkgVarObjsAll9.find(&nv.symbol);
                        pa9 != pkgVarObjsAll9.end())
                        qr9->Actual_group(pa9->second);
                return qr9;
            }
            // § staticScopedRef12 — the read half of § staticScopedCall12: a
            // CLASS-scoped `::` reference keeps its written scope in the name.
            // Surelog's class_scope arm never resolves through the scope, so
            // the object is an unbound ref_obj named FIRST-SEGMENT `::`
            // FINAL-IDENTIFIER and spanned only up to (not including) that
            // final identifier.  Measured on t4 (both views) over every symbol
            // kind a class can hold — `base::sv` (static var), `base::LP`
            // (localparam), `base::PP` (parameter), `base::CI` (static const),
            // `base::E1` (enum member: NOT folded to its enum_const),
            // `gen#(int)::gsv` (specialization: parameters dropped) and
            // `p::base::sv` -> `p::sv` (middle segment dropped).  We already
            // emitted a bare ref_obj for all of them; only the name and the
            // span were the written spelling's.  A PACKAGE-scoped reference
            // takes the arm above / the ordinary path (naming there is
            // context-dependent — see the memory note), so this keys strictly
            // on the referenced symbol living inside a CLASS.
            if (auto* ns12 = scopedNameSyntax12(expr.syntax);
                ns12 && inClassScope12(nv.symbol)) {
                std::string f12, l12;
                slang::SourceLocation e12;
                if (splitScopedName12(*ns12, f12, l12, e12)) {
                    // § staticScopedLvalueBad48 — the UNMEASURED LVALUE HALF of
                    // this law.  As an assignment TARGET golden writes
                    // `first::@@BAD_SYMBOL@@` over the WHOLE written name where
                    // the read form is `first::last` over the qualifier alone;
                    // t67d H1 reads both sides of the same declaration
                    // (`base67::sint = 3;` -> `base67::@@BAD_SYMBOL@@`@54:7-19,
                    // `y = base67::sint;` -> `base67::sint`@103:11-19), and the
                    // name — not the span — is what BaseClass::Compare reads.
                    // The package half of the same rule is the pre-existing
                    // `isPkgQualifiedVarRef` arm above (t67d H2), which is why
                    // this one is a class-scope-only addition.
                    if (inLhs && assignTargetParent48(parent))
                        if (auto* bad48 =
                                scopedLvalueBadRef48(expr, parent, prefix))
                            return bad48;
                    std::string nm12 = f12 + "::" + l12;
                    auto* r12 = s.MakeRef_obj();
                    r12->VpiName(nm12);
                    r12->VpiFullName(joinRef(prefix, nm12));
                    r12->VpiParent(parent);
                    setLoc(r12, SourceRange(ns12->sourceRange().start(), e12));
                    return r12;
                }
            }
            auto* ref = s.MakeRef_obj();
            ref->VpiName(nv.symbol.name);
            // A block-local declaration whose type keyword the Verilog-mode
            // lexer hides (`logic` in a `.v` file) compiled to an unbound
            // ref_var, so this reference resolves to nothing and Surelog's
            // netlist elaboration mints an implicit module WIRE for it,
            // LAZILY, at the FIRST reference's span (bind_net_). The ref keeps
            // its block-scoped fullname and binds to that net. UnitElabBlock.
            if (implicitNetModule && vlogHiddenBlockVars.count(&nv.symbol)) {
                ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                ref->VpiParent(parent);
                setLoc(ref, expr.sourceRange);
                UHDM::logic_net* inet9 = nullptr;
                if (auto* nv9 = implicitNetModule->Nets())
                    for (auto* n9 : *nv9)
                        if (n9->VpiName() == nv.symbol.name &&
                            n9->UhdmType() == UHDM::uhdmlogic_net) {
                            inet9 = (UHDM::logic_net*)n9;
                            break;
                        }
                if (!inet9) {
                    inet9 = s.MakeLogic_net();
                    inet9->VpiName(nv.symbol.name);
                    inet9->VpiFullName(implicitNetPrefix + "." +
                                       std::string(nv.symbol.name));
                    inet9->VpiParent(implicitNetModule);
                    inet9->VpiNetType(1);
                    setLoc(inet9, expr.sourceRange);
                    auto* nets9 = implicitNetModule->Nets();
                    if (!nets9) {
                        nets9 = s.MakeNetVec();
                        implicitNetModule->Nets(nets9);
                    }
                    nets9->push_back(inet9);
                }
                ref->Actual_group(inet9);
                return ref;
            }
            auto scope = nv.symbol.getParentScope();
            // § r10fsv3 S7.  Inside a PACKAGE SUBROUTINE BODY an enum-constant
            // reference is SUBSTITUTED: Surelog's ExprEval answers it with the
            // value, as an unsized UINT at size 64 — not the enum's own width
            // and not a symbolic ref (golden FuncStructVal build_config's
            // `(CVA6Cfg.XLEN == 32) ? config_pkg::ModeSv32 : config_pkg::
            // ModeSv39` -> UINT:1 / UINT:8, and the `cfg.MODE_SV ==
            // config_pkg::ModeSv32` compare next to it).  This is the body
            // counterpart of the pkg-param arm below, which chains a param
            // reference to that param's folded constant.
            // Gated on the WRITTEN qualification: an UNQUALIFIED enum-constant
            // read in a package body stays symbolic (rp32 riscv_isa_i_pkg
            // dec32's `ILL`, enc32's `SR`), so only a `pkg::NAME` reference —
            // which Surelog resolves through the package scope — substitutes.
            // § pkgClassEnumFold13 — the substitution reaches an IN-CLASS
            // METHOD of a package class too, where `pkgScopeInst` is null by
            // construction (emitTaskFuncs clears it for a class scope).  The
            // enum-constant NAME does not resolve inside such a body at all
            // (§ enumNoBind13 leaves the bare read unbound), but a WRITTEN
            // `pkg::NAME` still goes through Surelog's package-scope
            // resolution and comes back as the value — measured on
            // r10uvm13repro/t15, whose `p2::ck::inl` folds `p1::PE1`,
            // `p1::PE2` and `p1::PE0` in an assignment, an if condition and a
            // $display argument alike, byte-identical in both views, while
            // the same package's out-of-body `ck::oob` and free `pf` (which
            // already folded) are untouched.  Gated on the class living in a
            // PACKAGE so a module- or $unit-scope class keeps its old path.
            bool pkgClassMethod13 = false;
            if (curSubClassScope9 && !curSubOob9 && currentSubSym)
                for (auto sc13 = currentSubSym->getParentScope(); sc13;
                     sc13 = sc13->asSymbol().getParentScope()) {
                    auto k13 = sc13->asSymbol().kind;
                    if (k13 == SymbolKind::Package) {
                        pkgClassMethod13 = true;
                        break;
                    }
                    if (k13 == SymbolKind::InstanceBody ||
                        k13 == SymbolKind::CompilationUnit)
                        break;
                }
            if (currentTf && (pkgScopeInst || pkgClassMethod13) &&
                nv.symbol.kind == SymbolKind::EnumValue && expr.syntax &&
                expr.syntax->kind == syntax::SyntaxKind::ScopedName) {
                auto& ev9 = nv.symbol.as<EnumValueSymbol>().getValue();
                if (ev9.isInteger() && !ev9.integer().hasUnknown()) {
                    slang::SVInt uv9 = ev9.integer();
                    uv9.setSigned(false);
                    std::string dg9 = uv9.toString(LiteralBase::Decimal, false);
                    auto* ec9 = s.MakeConstant();
                    ec9->VpiDecompile(dg9);
                    ec9->VpiSize(64);
                    ec9->VpiValue("UINT:" + dg9);
                    ec9->VpiConstType(vpiUIntConst);
                    setLoc(ec9, expr.sourceRange);
                    if (parent && parent->UhdmType() == UHDM::uhdmoperation)
                        ec9->VpiParent(parent);
                    return ec9;
                }
            }
            // § r10fsv3 S4.  A package parameter initialised from ANOTHER
            // package's ENUM CONSTANT written scope-qualified
            // (`= config_pkg::WT`, `NOCType: config_pkg::NOC_TYPE_AXI4_ATOP`)
            // keeps an UNFOLDED ref_obj carrying the WRITTEN name in BOTH
            // views — Surelog resolves the constant for the value but leaves
            // the expression symbolic, exactly as it does for a cross-package
            // PARAM ref a few lines below (pkgCrossRefTopFixups).  We used to
            // drop the qualifier and, in the elab view, fold the whole thing
            // to a constant.  Gated on the WRITTEN qualification so a plain
            // imported-name read is untouched.
            if (paramInitPkg && nv.symbol.kind == SymbolKind::EnumValue &&
                expr.syntax &&
                expr.syntax->kind == syntax::SyntaxKind::ScopedName) {
                const Scope* home9 = scope;
                while (home9 && home9->asSymbol().kind != SymbolKind::Package)
                    home9 = home9->asSymbol().getParentScope();
                std::string curPkg9 = prefix;
                if (auto p9 = curPkg9.find("::"); p9 != std::string::npos)
                    curPkg9.resize(p9);
                if (home9 && std::string(home9->asSymbol().name) != curPkg9) {
                    std::string pn9 = std::string(home9->asSymbol().name) +
                                      "::" + std::string(nv.symbol.name);
                    ref->VpiName(pn9);
                    std::string full9 = prefix;
                    if (full9.size() < 2 ||
                        full9.compare(full9.size() - 2, 2, "::") != 0)
                        full9 += "::";
                    ref->VpiFullName(full9 + pn9);
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    return ref;
                }
            }
            if (scope && scope->asSymbol().kind == SymbolKind::Package &&
                nv.symbol.kind == SymbolKind::Parameter) {
                // § pkgParamInClassMethodStaysRef47 — an IN-BODY CLASS METHOD
                // reading a parameter of the class's OWN ENCLOSING PACKAGE keeps
                // an UNFOLDED, UNBOUND ref_obj.  We folded it to a constant.
                //
                // This is the head § pkgInitRefBindsOwnListing47 exposed, and it
                // is the SAME head on SeqDriver, SimpleUVM and Scoreboard
                // (uhdm-cmp, LHS golden(Surelog) / RHS ours):
                //   LHS ref_obj (uvm_pkg::uvm_comparer::compare_field::
                //       UVM_STREAMBITS) 154:15-154:29, parent operation
                //       154:15-154:34, vpiName + vpiFullName and NOTHING else —
                //       no vpiActual, no typespec
                //   RHS constant 4096, size 32, vpiConstType 9
                // Source: `parameter UVM_STREAMBITS = `UVM_MAX_STREAMBITS;` at
                // base/uvm_object_globals.svh:39, read at
                // base/uvm_comparer.svh:154 as `mask >>= (UVM_STREAMBITS-size);`
                //
                // THE ANCESTOR TEST IS THE GATE, and arm t66b is what named it:
                // the SAME class method in package u2 keeps the ref for u2's own
                // `U2_P` (t66b:33) and FOLDS u1's `U1_P` read unqualified after
                // a wildcard import (t66b:28).  Without the ancestor test this
                // law would have moved t66b:28, :44 and :58 — three cells where
                // we already agree with golden — and the regression would have
                // been read as a refutation of the whole law.
                //
                // The cells that must NOT move, every one already equal at HEAD
                // and re-checked after: a class method in a MODULE reading that
                // module's parameter (t66b:68) or its own class localparam
                // (:73) already keeps a ref because `scope` is not a Package and
                // this block is never entered; a class method reading ANOTHER
                // package's parameter, bare (t66b:28/:58) or `::`-qualified
                // (:63), or from a $unit class (:44), folds on both sides; a
                // package FUNCTION body keeps a BOUND ref through the
                // pkgScopeInst arm below (t66a:75); a MODULE body folds
                // (t66a:87); a class PROPERTY initialiser (t66a:36) and a
                // typedef RANGE bound (t66a:33) already keep unbound refs
                // through other paths.
                //
                // Neither `parameter` vs `localparam` nor implicit vs explicit
                // typing is a discriminator — t66a's `L_IMPL` and `P_TYPED`
                // cells keep the ref exactly like the implicit `parameter`, and
                // the position (bare assignment Rhs :48 vs binary operand :42
                // vs shift-assign operand :67) is not one either.  Those were
                // the four candidate keys the uvm site suggested; all four are
                // REFUTED, and only the reader/ancestor pair survives.
                //
                // OUT-OF-BODY methods are excluded (`!curSubOob9`): they are
                // compiled in the home package's scope by a different Surelog
                // entry point and no golden was read for them.
                bool ownPkgClassMethod47 = false;
                if (currentTf && curSubClassScope9 && !curSubOob9 &&
                    currentSubSym)
                    for (auto sc47 = currentSubSym->getParentScope(); sc47;
                         sc47 = sc47->asSymbol().getParentScope()) {
                        if (&sc47->asSymbol() == &scope->asSymbol()) {
                            ownPkgClassMethod47 = true;
                            break;
                        }
                        auto k47 = sc47->asSymbol().kind;
                        if (k47 == SymbolKind::InstanceBody ||
                            k47 == SymbolKind::CompilationUnit)
                            break;
                    }
                if (ownPkgClassMethod47) {
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    return ref;
                }
                // Package-function bodies keep a ref bound to the param's
                // def-view constant.
                if (currentTf && pkgScopeInst) {
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    // § r10fsv3 S3b: the chain is VIEW-LOCAL — the elaborated
                    // listing's body reaches the elaborated param_assign's own
                    // constant (`NrMaxRules` in config_pkg::check_cfg is UINT:16
                    // at size 32 there and size 64 in the def listing).
                    auto pit2 = pkgParamDefRhs.find(&nv.symbol);
                    if (pkgEmitTopView && pit2 != pkgParamDefRhs.end())
                        ref->Actual_group(pit2->second);
                    else if (auto pit = pkgParamConst.find(&nv.symbol);
                             pit != pkgParamConst.end())
                        ref->Actual_group(pit->second);
                    else if (pit2 != pkgParamDefRhs.end())
                        // Non-constant def Rhs (an operation) chains the same
                        // way (Surelog value-ref chaining).
                        ref->Actual_group(pit2->second);
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    return ref;
                }
                // Function-call ARGS keep a pkg-scoped ref (named pkg::P,
                // anchored at the package-qualifier span) bound to the
                // package's def parameter object.
                if (parent && (parent->UhdmType() == UHDM::uhdmfunc_call ||
                               parent->UhdmType() == UHDM::uhdmtask_call)) {
                    // § fcArgBareImportRef — ...only for the QUALIFIED
                    // spelling.  The same parameter read UNQUALIFIED after a
                    // wildcard import is the IMPORTING MODULE's materialized
                    // copy: golden names it BARE, scopes the fullname to the
                    // module, binds NOTHING, and spans the identifier instead
                    // of the (absent) qualifier.  Measured on
                    // tools/probe/r10earl_repro/vi.sv rows A/B, which differ
                    // only in the spelling of one `pick(AVEC, sel_i)` argument:
                    //   A  `pick(AVEC, ...)`       -> name AVEC,
                    //        fullname work@via.AVEC, no Actual, 27:21..27:25
                    //   B  `pick(vip::AVEC, ...)`  -> name vip::AVEC,
                    //        no fullname, Actual = the package parameter,
                    //        28:21..28:26 (the `vip::` qualifier alone)
                    // Corpus: Earlgrey aes_sbox_canright / *_masked /
                    // *_noreuse `aes_mvm(data_i, A2X)` — three AllModules
                    // heads reading `ref_obj 'A2X' vs
                    // 'aes_sbox_canright_pkg::A2X'`.
                    if (rawText(expr.sourceRange).find("::") ==
                        std::string::npos) {
                        ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                        ref->VpiParent(parent);
                        setLoc(ref, expr.sourceRange);
                        return ref;
                    }
                    std::string pn = std::string(scope->asSymbol().name) + "::" +
                                     std::string(nv.symbol.name);
                    ref->VpiName(pn);
                    ref->VpiFullName(pn);
                    ref->VpiParent(parent);
                    if (auto pit2 = pkgDefMap.find(&scope->asSymbol());
                        pit2 != pkgDefMap.end() && pit2->second->Parameters())
                        for (auto* pp2 : *pit2->second->Parameters())
                            if (pp2->VpiName() == nv.symbol.name)
                                ref->Actual_group(pp2);
                    setLoc(ref, SourceRange(expr.sourceRange.start(),
                                            expr.sourceRange.start() +
                                                scope->asSymbol().name.size() + 2));
                    return ref;
                }
                // Module-side references to package params are folded inline
                // to constants carrying the reference's location. STRUCT/UNION
                // typed pkg params stay refs bound to the pkg parameter
                // (Surelog keeps the ref_obj).
                auto& psym = nv.symbol.as<ParameterSymbol>();
                auto ckP = psym.getType().getCanonicalType().kind;
                // ...except inside the value of a MATERIALIZED IMPORT copy of
                // a MULTIDIMENSIONAL package param: that value is cloned from
                // the package's Reduce::No compile, so its operands stay
                // symbolic in both module views. Surelog's clone leaves them
                // ACTUAL-LESS — a bare ref_obj named after the package param,
                // fullname scoped to the importing module (IntegerConcat
                // work@dut.SeedInfoPageSel -> {OwnerInfoPage, CreatorInfoPage}).
                if (pkgElabSymOperands && !paramInitPkg) {
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    return ref;
                }
                // --disable-feature=parametersubstitution (hard no-op without
                // the flag): the whole point of the flag is that THIS
                // reference is not replaced by its value.  The surviving
                // ref_obj is scoped to the referencing instance and bound to
                // the IMPORTING module's materialized parameter, which is what
                // an unqualified `CTRL_RESET` under `import aes_pkg::*`
                // resolves to (ParamNoSubst).
                if (noParamSubst && paramSubstRefused(psym)) {
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    if (auto pit9 = elabParamPa.find(&nv.symbol);
                        pit9 != elabParamPa.end() && pit9->second->Lhs())
                        ref->Actual_group((UHDM::any*)pit9->second->Lhs());
                    return ref;
                }
                // An assignment-pattern package parameter whose target is not a
                // packed vector never acquires a value (patParamNoFold), so a
                // module-side read of it cannot fold to a constant either. The
                // DEF view keeps the bare ref_obj scoped to the importing
                // module (exactly the shape the flag arm above produces); the
                // ELAB view substitutes the pattern's OWN operation tree, which
                // keeps the pattern's source span rather than the reference's
                // (ParamScope: `int VALUE_TEMP = '{default:1}` read from
                // `parameter int VALUE = VALUE_TEMP + 2`).
                // ...and the same DEF-view survival applies to ANY package
                // parameter whose own def Rhs is an operation (concat,
                // cast-of-concat, replication): the module-side read keeps the
                // ref_obj to the materialized import rather than folding
                // (ParamTypespec `parameter P = PartInvDefault`).
                if (patParamNoFold(psym) ||
                    (paramRhsDefView && paramDefRhsIsOp(psym))) {
                    if (patSubstElab && patParamNoFold(psym)) {
                        if (auto* pini = psym.getInitializer()) {
                            bool saved9 = patSubstElab;
                            patSubstElab = false;
                            auto* sub9 = emitExpr(*pini, parent, prefix, netMap);
                            patSubstElab = saved9;
                            if (sub9) {
                                // The substituted pattern OPERATION carries a
                                // ts ref to the SUBSTITUTED param's own elab
                                // typespec (not the reader's) — Surelog
                                // stamps the reduced expression's type.
                                // Bound in patchParamTypespecs, which is where
                                // that clone is minted.
                                if (sub9->UhdmType() == UHDM::uhdmoperation &&
                                    !((UHDM::operation*)sub9)->Typespec()) {
                                    auto* rtS9 = s.MakeRef_typespec();
                                    rtS9->VpiFullName(prefix);
                                    rtS9->VpiParent(sub9);
                                    ((UHDM::operation*)sub9)->Typespec(rtS9);
                                    bindOrParkParamTs(psym, rtS9);
                                }
                                return sub9;
                            }
                        }
                    }
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    return ref;
                }
                // An interface/module PARAMETER DEFAULT that references a
                // struct/union-typed package localparam is FOLDED to that
                // param's VALUE expression (re-emitted in this scope, outer
                // node re-anchored to the reference span) — Surelog inlines
                // aggregate param defaults rather than keeping the ref_obj. A
                // package-to-package init (paramInitPkg) keeps the ref chain.
                // § concatRefNoSubst — ...and so does a reference NESTED IN A
                // CONCATENATION.  Surelog's substituteAssignedValue only ever
                // answers a read the enclosing REDUCE asks about, and the
                // reduce of a concat of >64b struct values fails outright, so
                // every element survives as its own ref_obj — the same
                // ACTUAL-LESS, module-scoped shape a materialized import copy
                // of a multidimensional package param keeps (the
                // pkgElabSymOperands arm above), reached here by the reduce
                // FAILING rather than by never running.  BlackBePipeInt
                // `bp_proc_param_s [max_cfgs-1:0] all_cfgs_gp =
                // {bp_multicore_4_l2e_cfg_p, ... , bp_default_cfg_p}`: golden
                // holds 33 bare-named ref_objs in all EIGHT listings, where we
                // inlined 33 flat op75s into the four module ones.
                bool inConcat9 =
                    parent && parent->UhdmType() == UHDM::uhdmoperation &&
                    ((UHDM::operation*)parent)->VpiOpType() == vpiConcatOp;
                if (inParamInit && !paramInitPkg && inConcat9 &&
                    (ckP == SymbolKind::PackedStructType ||
                     ckP == SymbolKind::UnpackedStructType ||
                     ckP == SymbolKind::PackedUnionType ||
                     ckP == SymbolKind::UnpackedUnionType)) {
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    return ref;
                }
                if (inParamInit && !paramInitPkg &&
                    (ckP == SymbolKind::PackedStructType ||
                     ckP == SymbolKind::UnpackedStructType ||
                     ckP == SymbolKind::PackedUnionType ||
                     ckP == SymbolKind::UnpackedUnionType)) {
                    if (auto* pini = psym.getInitializer()) {
                        auto* folded = emitExpr(*pini, parent, prefix, netMap);
                        if (folded) {
                            // Surelog anchors the folded op at the package
                            // qualifier span (pkg::) of the reference, not the
                            // full pkg::NAME span.
                            setLoc(folded,
                                   SourceRange(expr.sourceRange.start(),
                                               expr.sourceRange.start() +
                                                   scope->asSymbol().name.size() +
                                                   2));
                            return folded;
                        }
                    }
                }
                // ...but a param init IN THE PARAM'S OWN PACKAGE keeps the
                // BARE-named ref (fullname pkg::P) chained to that param's
                // Rhs node IN THIS VIEW — Surelog chains value refs inside a
                // package for aggregates exactly as it does for scalars, in
                // the elaborated listing as well as the def one (PackageType's
                // `parameter bp_proc_param_s [N-1:0] all_cfgs_gp =
                // {bp_inv_cfg_p}`).  Only a MODULE-side read takes the
                // qualified `pkg::P` shape below.
                if (paramInitPkg &&
                    (ckP == SymbolKind::PackedStructType ||
                     ckP == SymbolKind::PackedUnionType)) {
                    std::string curPkg8 = prefix;
                    if (auto p8 = curPkg8.find("::"); p8 != std::string::npos)
                        curPkg8.resize(p8);
                    if (curPkg8 == std::string(scope->asSymbol().name)) {
                        ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                        if (auto rit8 = pkgParamDefRhs.find(&nv.symbol);
                            rit8 != pkgParamDefRhs.end())
                            ref->Actual_group(rit8->second);
                        ref->VpiParent(parent);
                        setLoc(ref, expr.sourceRange);
                        return ref;
                    }
                }
                // § pkgImportParamBareRef — the same struct-typed operand ref
                // inside a PACKAGE's copy of a parameter it IMPORTED from
                // another package is NOT qualified and carries NO actual.
                // bp_be_pkg imports bp_common_pkg's `all_cfgs_gp` (a
                // bp_proc_param_s array whose 33 operands name that package's
                // config params): the declaring package's own row keeps bare
                // names bound through pkgParamDefRhs (the arm above), and the
                // importing package's row REPLAYS that row's TEXT — same bare
                // names, same spans — but binds nothing, because the copy was
                // materialized in a scope that holds none of those parameter
                // objects.  Golden: 33 bare dangling refs in both bp_be_pkg
                // views; ours qualified every one of them and bound it to the
                // declaring package's parameter object, which was the whole
                // design's first Compare failure after the range-actual fix.
                if (pkgImportedParamClone &&
                    (ckP == SymbolKind::PackedStructType ||
                     ckP == SymbolKind::PackedUnionType)) {
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    return ref;
                }
                if (ckP == SymbolKind::PackedStructType ||
                    ckP == SymbolKind::PackedUnionType) {
                    // § structParamBareImportRef — the SAME written-spelling
                    // split § fcArgBareImportRef landed one arm above for
                    // func-call arguments.  A struct/union-typed package
                    // parameter read UNQUALIFIED after a wildcard import is
                    // the IMPORTING MODULE's materialized copy: golden names
                    // it BARE, scopes the fullname to the module, binds
                    // NOTHING, and spans the IDENTIFIER; only the written
                    // `pkg::P` spelling gets the qualified name, the package
                    // parameter as Actual and the qualifier-only span.
                    // Measured on tools/probe/r10earl_repro/vf.sv (all four
                    // header/body-import x port-list module shapes),
                    // vg.sv (the three package-side triggers) and vh.sv
                    // (member-selecting port list) — golden reads
                    //   ref_obj (work@vfa.REQ_DEFAULT) 28:14..28:25
                    //     |vpiName:REQ_DEFAULT  no vpiActual
                    // where we emitted
                    //   ref_obj (vfp::REQ_DEFAULT) 28:14..28:19
                    //     |vpiName:vfp::REQ_DEFAULT |vpiActual: parameter
                    // Corpus: Earlgrey pwrmgr_cdc:118 `assign ... =
                    // PWR_AST_RSP_SYNC_DEFAULT` after `import pwrmgr_pkg::*`.
                    if (rawText(expr.sourceRange).find("::") ==
                        std::string::npos) {
                        ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                        ref->VpiParent(parent);
                        setLoc(ref, expr.sourceRange);
                        return ref;
                    }
                    std::string pn = std::string(scope->asSymbol().name) + "::" +
                                     std::string(nv.symbol.name);
                    ref->VpiName(pn);
                    ref->VpiFullName(pn);
                    ref->VpiParent(parent);
                    if (auto pit2 = pkgDefMap.find(&scope->asSymbol());
                        pit2 != pkgDefMap.end() && pit2->second->Parameters())
                        for (auto* pp2 : *pit2->second->Parameters())
                            if (pp2->VpiName() == nv.symbol.name)
                                ref->Actual_group(pp2);
                    setLoc(ref, SourceRange(expr.sourceRange.start(),
                                            expr.sourceRange.start() +
                                                scope->asSymbol().name.size() + 2));
                    return ref;
                }
                // A PACKAGE param initialized by ANOTHER package's qualified
                // param keeps a doubled-scope ref_obj (pkg::otherpkg::P) bound
                // to that param — Surelog does not fold a cross-package
                // pkg-param ref inside a package init.
                if (paramInitPkg) {
                    std::string curPkg = prefix;
                    if (auto p2 = curPkg.find("::"); p2 != std::string::npos)
                        curPkg.resize(p2);
                    // A SAME-package param ref inside a STRUCT-PATTERN value
                    // FOLDS to a constant (size 64 UINT, ts ref -> the
                    // param's own def ts, parent = its def param_assign) —
                    // Surelog; plain def inits keep the symbolic ref below.
                    if (paramInitDef && inPatternValue &&
                        curPkg == std::string(scope->asSymbol().name)) {
                        auto& cv9 = psym.getValue();
                        if (cv9.isInteger() && !cv9.integer().hasUnknown()) {
                            auto* c9 = s.MakeConstant();
                            std::string dg9 = cv9.integer().toString(
                                LiteralBase::Decimal, false);
                            c9->VpiDecompile(dg9);
                            c9->VpiSize(64);
                            c9->VpiValue("UINT:" + dg9);
                            c9->VpiConstType(vpiUIntConst);
                            setLoc(c9, expr.sourceRange);
                            if (auto cIt9 = pkgParamConst.find(&nv.symbol);
                                cIt9 != pkgParamConst.end())
                                c9->VpiParent(
                                    (UHDM::BaseClass*)cIt9->second
                                        ->VpiParent());
                            auto* rt9 = s.MakeRef_typespec();
                            rt9->VpiFullName(curPkg);
                            rt9->VpiParent(c9);
                            if (auto poIt9 = pkgParamObj.find(&nv.symbol);
                                poIt9 != pkgParamObj.end()) {
                                if (poIt9->second->Typespec())
                                    rt9->Actual_typespec(
                                        poIt9->second->Typespec()
                                            ->Actual_typespec());
                                // § r10fsv2 — the referenced parameter's own
                                // typespec may not exist yet: a param whose
                                // init is itself a param REFERENCE has its
                                // typespec built by the DEFERRED drain, long
                                // after this pattern is emitted
                                // (cva6_config_pkg's `CVA6ConfigDataUserWidth
                                // = CVA6ConfigXlen`, read by FuncStructVal's
                                // `AxiUserWidth` and `FetchUserWidth`
                                // members, where a literal-init sibling like
                                // `CVA6ConfigXlen` binds immediately).  Park
                                // the ref and bind it at the end, off the
                                // SAME parameter object so each view keeps
                                // its own typespec.
                                if (!rt9->Actual_typespec())
                                    // pkgEmitTopView, not pkgTopEmit: the
                                    // latter is set only for the TYPEDEF pass,
                                    // after emitParameters has run.
                                    pkgPatValTsFix.push_back(
                                        {rt9, &nv.symbol, c9, pkgEmitTopView});
                            }
                            c9->Typespec(rt9);
                            return c9;
                        }
                    }
                    // A SAME-package param ref in a DEF-view pkg init stays a
                    // ref_obj (fullname pkg::P) whose actual is the referenced
                    // param's own def Rhs node (Surelog chains value refs).
                    // The ELAB view of a MULTIDIMENSIONAL param takes the same
                    // shape: Surelog compiles it Reduce::No, so nothing folds.
                    if ((paramInitDef || pkgElabSymOperands) &&
                        curPkg == std::string(scope->asSymbol().name)) {
                        ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                        if (auto rit = pkgParamDefRhs.find(&nv.symbol);
                            rit != pkgParamDefRhs.end())
                            ref->Actual_group(rit->second);
                        ref->VpiParent(parent);
                        setLoc(ref, expr.sourceRange);
                        return ref;
                    }
                    if (curPkg != std::string(scope->asSymbol().name)) {
                        std::string pn = std::string(scope->asSymbol().name) +
                                         "::" + std::string(nv.symbol.name);
                        ref->VpiName(pn);
                        ref->VpiParent(parent);
                        std::string full = prefix;
                        if (full.size() < 2 ||
                            full.compare(full.size() - 2, 2, "::") != 0)
                            full += "::";
                        ref->VpiFullName(full + pn);
                        if (auto pit2 = pkgDefMap.find(&scope->asSymbol());
                            pit2 != pkgDefMap.end() && pit2->second->Parameters())
                            for (auto* pp2 : *pit2->second->Parameters())
                                if (pp2->VpiName() == nv.symbol.name)
                                    ref->Actual_group(pp2);
                        // Re-point at the ELAB home-package param once top
                        // packages exist (Surelog's cross-package init ref
                        // reaches the folded elab param, not the def one).
                        pkgCrossRefTopFixups.emplace_back(
                            ref, (const void*)&scope->asSymbol(),
                            std::string(nv.symbol.name));
                        setLoc(ref, expr.sourceRange);
                        return ref;
                    }
                }
                // § defGenProcWildcardPkgParamNoFold19 (r10earl19) — the
                // EXACT INVERSE of the fold laws, and the pass-18
                // discriminator in a fifth container: inside a DEF-view
                // GENERATE-BLOCK PROCESS, a package parameter read written
                // UNQUALIFIED (reached only through a wildcard import) is NOT
                // substituted — Surelog compiles the generate body with no
                // instance context, so the bare name resolves to nothing and
                // stays a symbolic, UNBOUND ref_obj carrying the gen-scope
                // fullname.  A QUALIFIED `pkg::P` read in the SAME process
                // still folds: THE WRITTEN QUALIFIER IS THE DISCRIMINATOR,
                // the same rule § defGenQualPkgCallBinds18 measured for a
                // call and § genCondQualPkgParamFold for a condition.
                // Witness pf19.sv rows 50 (qualified `{p19::QA{1'b1}}`, a
                // folded constant in BOTH views) and 51 (wildcard
                // `{QB{1'b1}}`, `ref_obj QB` in the def view and the constant
                // only in the elab one), measured object-for-object against
                // real Surelog.  Corpus: work@flash_phy_core's whole head —
                // `prog_data_packed = {DataWidth{1'b1}};`
                // (flash_phy_core.sv:190:27) inside an `always_comb` in a
                // `generate else` block, `ref_obj 'DataWidth'` in golden and
                // `constant {ct=9 sz=32 dec=64}` in ours.
                if (defGenProcessEmit &&
                    rawText(expr.sourceRange).find("::") == std::string::npos) {
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    return ref;
                }
                // § genNestedScopePkgParamNoFold24 (r10earl24) — the SECOND
                // no-fold container of the same family, and the pass-23 exit
                // frontier: in an ELABORATED gen scope that is NESTED inside
                // another generate scope, an UNQUALIFIED (wildcard-imported)
                // package-parameter read is NOT substituted either.  Golden
                // keeps the gen-scoped ref_obj and binds it to a FRESH
                // loc-less enum_const carrying the parameter's own value — the
                // same per-ref clone shape § genCaEnumBindsSelectOnly22 mints
                // for an enum constant, because one shared package object
                // cannot serve every elaborated gen instance.
                // Measured (wa24 / wb24, one child instance, both views):
                //   for-gen NESTED in if-gen, cont_assign   -> ref + enum_const
                //   the same read in an always_comb          -> ref + enum_const
                //   if-gen nested in if-gen                  -> ref + enum_const
                //   for-gen nested in for-gen                -> ref + enum_const
                //   the same nested shape in the TOP module  -> ref + enum_const
                //   TOP-LEVEL for-gen body / TOP-LEVEL if-gen-> FOLDS (both)
                //   a QUALIFIED `pkg::P` read, same scope    -> FOLDS (both)
                //   a MODULE localparam, same scope          -> ref, UNBOUND
                // so the discriminators are the NESTING and the missing
                // qualifier, not the generate KIND, not the container and not
                // the child-vs-top instance (the pass-23 trap does not bite
                // here — wb24's t_outer/t_in row measures the same way round).
                // wc24 measures what the clone carries over five spellings:
                // the parameter's own encoding and width (12'h5A0/12,
                // 8'b10100001/8, 7/32, an EXPRESSION init as plain decimal at
                // the declared width) — with ONE difference from the fold
                // below: an UNTYPED pkg param is SIXTY-FOUR bits here
                // (`parameter R_UNT = 12` -> UINT:12 size 64) where
                // § pkgParamFoldWidthAlways lands at 32.
                // Corpus: ibex_cs_registers.sv:795:44 `assign pmp_cfg_we[i] =
                // csr_we_int & ~pmp_cfg[i].lock & (csr_addr ==
                // (CSR_OFF_PMP_CFG + (i[11:0] >> 2)));` inside
                // g_pmp_registers > g_pmp_csrs[i] — both top_earlgrey heads'
                // bisect frontier at pass-23 exit (r=601).
                // SELECT POSITIONS ARE IN, and that is measured, not assumed:
                // the law's first cut excluded them all — on the theory that
                // § selFold9 / § procSelFold9 / § genCaLoopSelIdxFold21 own
                // those positions — and the corpus bisector advanced by
                // exactly ONE cont_assign, to :798:59
                // `csr_wdata_int[(i%4)*PMP_CFG_W+7]`, where golden keeps the
                // ref too.  wd24 then measured all five spellings in one
                // nested gen scope and golden KEEPS + BINDS every one: a
                // bit-select index OPERATION, a BARE bit-select index, both
                // PART-select bounds, an INDEXED-part-select base, and the
                // plain-operand control.  (wb24's `dat[Q_C[3:0]]` row is not a
                // counterexample: a part-select OF the parameter is a
                // different shape entirely — golden emits a part_select NAMED
                // after it, no fold and no ref.)
                if (genNestedScopeEmit24 && !defGenProcessEmit &&
                    (inGenScopeCaRhs || inGenScopeProc) && !inLhs &&
                    !inParamInit && !currentTf &&
                    rawText(expr.sourceRange).find("::") ==
                        std::string::npos) {
                    auto& cvK = psym.getValue();
                    if (cvK.isInteger() && !cvK.integer().hasUnknown()) {
                        std::string dgK =
                            cvK.integer().toString(LiteralBase::Decimal, false);
                        std::string decK = dgK, valK = "UINT:" + dgK;
                        // A BASED-literal init keeps its base encoding, exactly
                        // as the fold below does (wc24 R_HEX / R_BIN).
                        if (auto* piK = psym.getInitializer()) {
                            auto& litK = stripImplicitConv(*piK);
                            if (litK.kind == ExpressionKind::IntegerLiteral) {
                                std::string rawK(rawText(litK.sourceRange));
                                if (auto tK = rawK.find('\'');
                                    tK != std::string::npos) {
                                    size_t bpK = tK + 1;
                                    if (bpK < rawK.size() &&
                                        (rawK[bpK] == 's' || rawK[bpK] == 'S'))
                                        bpK++;
                                    char bK = bpK < rawK.size()
                                                  ? (char)tolower(rawK[bpK])
                                                  : 'd';
                                    std::string dg2K =
                                        stripSep(rawK.substr(bpK + 1));
                                    const char* pfxK = nullptr;
                                    switch (bK) {
                                        case 'b': pfxK = "BIN:"; break;
                                        case 'h': pfxK = "HEX:"; break;
                                        case 'o': pfxK = "OCT:"; break;
                                        case 'd': pfxK = "DEC:"; break;
                                        default: break;
                                    }
                                    if (pfxK) {
                                        valK = std::string(pfxK) + dg2K;
                                        decK = stripSep(rawK);
                                    }
                                }
                            }
                        }
                        bool typedK = false;
                        if (auto dK = psym.getDeclaredType())
                            if (auto tsK = dK->getTypeSyntax())
                                typedK = tsK->kind !=
                                         syntax::SyntaxKind::ImplicitType;
                        auto* ecK = s.MakeEnum_const();
                        ecK->VpiName(std::string(nv.symbol.name));
                        ecK->VpiDecompile(decK);
                        ecK->VpiValue(valK);
                        ecK->VpiSize(typedK
                                         ? (int32_t)psym.getType().getBitWidth()
                                         : 64);
                        ecK->VpiParent(ref);
                        ref->Actual_group(ecK);
                    }
                    // FULLNAME NOTE (measured, deliberately NOT chased): in a
                    // PART-SELECT BOUND golden scopes the read under the select
                    // BASE (`...g_i[0].dat.S_HI`) while the ordinary bound path
                    // keeps a direct name module-scoped, and in an
                    // INDEXED-part-select BASE it is the other way round
                    // (`...g_i[0].S_P`).  A cut that rescoped on inPsBound
                    // fixed the first pair and broke the second; fullname is
                    // not a uhdm-cmp field, so the plain prefix stands and the
                    // two wd24 rows show up as `<absent>` pairs in the
                    // r10earl22a census (the class its own doc says to ignore).
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    ref->VpiParent(parent);
                    setLoc(ref, expr.sourceRange);
                    return ref;
                }
                auto& cv = psym.getValue();
                if (cv.isInteger() && !cv.integer().hasUnknown()) {
                    auto* c = s.MakeConstant();
                    std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
                    c->VpiDecompile(digits);
                    bool typedPkgParam = false;
                    if (auto d0 = psym.getDeclaredType())
                        if (auto t0 = d0->getTypeSyntax())
                            typedPkgParam =
                                t0->kind != syntax::SyntaxKind::ImplicitType;
                    // § pkgParamFoldWidthAlways — a module-side pkg-param fold
                    // is sized by the PARAMETER'S OWN type, typed or not.
                    // Surelog's substituteAssignedValue hands the read the
                    // parameter's value object and adjustSize re-renders it at
                    // that parameter's typespec width; an UNTYPED localparam is
                    // `int`, so it lands at 32, not the 64 this site used to
                    // assume (BlackBePipeInt `localparam dword_width_gp = 64`
                    // read from `reservation.rs1[0+:dword_width_gp]` and
                    // `src1 << word_width_gp` -> golden UINT sz32 both).  The
                    // old typed/untyped split was a narrower reading of the
                    // same law: measured over both corpora x both modes the
                    // unconditional form is byte-identical (dump column
                    // included), so nothing in the corpus ever wanted 64.
                    c->VpiSize((int32_t)psym.getType().getBitWidth());
                    // A pkg param whose init is a CONST-FUNCTION CALL with a
                    // signed return folds INT (Surelog); others fold UINT.
                    bool callSigned9 = false;
                    if (auto* pini9 = psym.getInitializer()) {
                        bool hasCall9 = false;
                        pini9->visit(
                            makeVisitor([&](auto& v9, const CallExpression& cc9) {
                                if (!cc9.isSystemCall())
                                    hasCall9 = true;
                                v9.visitDefault(cc9);
                            }));
                        callSigned9 = hasCall9 && cv.integer().isSigned();
                    }
                    c->VpiValue((callSigned9 ? "INT:" : "UINT:") + digits);
                    c->VpiConstType(callSigned9 ? vpiIntConst : vpiUIntConst);
                    // § castDefaultPatternConcat — Surelog's
                    // substituteAssignedValue hands the read the parameter's
                    // OWN value object, and for an `int'{default:X}` param that
                    // object is defaultPatternAssignment's SIGNED vpiIntConst
                    // (INT:-1 / INT:0), so the read inherits INT and the signed
                    // decimal rendering rather than the unsigned 4294967295.
                    if (castDefaultIntPatternInit(psym)) {
                        std::string sd9 = digits;
                        {
                            uint64_t uv9 =
                                std::strtoull(digits.c_str(), nullptr, 10);
                            uint32_t w9 =
                                (uint32_t)psym.getType().getBitWidth();
                            int64_t iv9 = (int64_t)uv9;
                            if (w9 > 0 && w9 < 64 && ((uv9 >> (w9 - 1)) & 1ULL))
                                iv9 = (int64_t)(uv9 | (~0ULL << w9));
                            sd9 = std::to_string(iv9);
                        }
                        c->VpiValue("INT:" + sd9);
                        c->VpiConstType(vpiIntConst);
                        c->VpiDecompile(sd9);
                    }
                    // A BASED-literal-initialized pkg param keeps its base
                    // encoding in the fold (32'habcd -> HEX:abcd) — Surelog.
                    if (auto* pini8 = psym.getInitializer()) {
                        auto& lit8 = stripImplicitConv(*pini8);
                        if (lit8.kind == ExpressionKind::IntegerLiteral) {
                            std::string raw8(rawText(lit8.sourceRange));
                            auto tick8 = raw8.find('\'');
                            if (tick8 != std::string::npos) {
                                size_t bp8 = tick8 + 1;
                                if (bp8 < raw8.size() &&
                                    (raw8[bp8] == 's' || raw8[bp8] == 'S'))
                                    bp8++;
                                char base8 = bp8 < raw8.size()
                                                 ? (char)tolower(raw8[bp8])
                                                 : 'd';
                                std::string dg8 = stripSep(raw8.substr(bp8 + 1));
                                switch (base8) {
                                    case 'b':
                                        c->VpiValue("BIN:" + dg8);
                                        c->VpiConstType(vpiBinaryConst);
                                        break;
                                    case 'h':
                                        c->VpiValue("HEX:" + dg8);
                                        c->VpiConstType(vpiHexConst);
                                        break;
                                    case 'o':
                                        c->VpiValue("OCT:" + dg8);
                                        c->VpiConstType(vpiOctConst);
                                        break;
                                    case 'd':
                                        // A based-DECIMAL init (2'd1) keeps its
                                        // DEC encoding in the fold too (Surelog:
                                        // vpiDecConst, decompile "2'd1"), unlike
                                        // a bare decimal which is UINT.
                                        c->VpiValue("DEC:" + dg8);
                                        c->VpiConstType(vpiDecConst);
                                        break;
                                    default:
                                        break;
                                }
                                if (base8 == 'b' || base8 == 'h' ||
                                    base8 == 'o' || base8 == 'd')
                                    c->VpiDecompile(stripSep(raw8));
                            }
                        }
                    }
                    // Enum-origin pkg params fold in the enum literal's
                    // source HEX form module-side too (Surelog).
                    if (typedPkgParam)
                        enumOriginHexRecode(c, psym.getInitializer());
                    setLoc(c, expr.sourceRange);
                    // A PROCEDURAL bit-select INDEX fold reading an imported
                    // param parents at the select and carries a ts ref to the
                    // param's def typespec, named by the SELECT (Surelog;
                    // cs_registers csr_rdata_int[CSR_MSTATUS_MIE_BIT]).
                    bool procSelFold9 = inProcessEmit && !inParamInit && parent &&
                                        parent->UhdmType() ==
                                            UHDM::uhdmbit_select;
                    // A PROCEDURAL PART-select RANGE fold reading an imported
                    // param carries the ts ref too, but scopes it at the
                    // MODULE and re-parents the constant at the param's own
                    // param_assign — the range bound is resolved through the
                    // parameter, not through the select (Surelog;
                    // cs_registers csr_rdata_int[HI:LO]).
                    bool procPsFold9 = inProcessEmit && !inParamInit && parent &&
                                       parent->UhdmType() ==
                                           UHDM::uhdmpart_select;
                    // The SAME bit-select index rule outside a process — a
                    // cont-assign RHS select (`assign o = access[W];`) and a
                    // task/function BODY select (rggen_register_common
                    // get_mask's `access[RGGEN_ACCESS_DATA_BIT]`) both parent
                    // the fold at the select and name the ts ref after it.
                    // The non-process fold binds its OWN clone of the imported
                    // param's typespec (one per reference — Surelog), unlike
                    // the process fold, which shares the def object.
                    bool selFold9 = !inProcessEmit && !inParamInit && parent &&
                                    parent->UhdmType() == UHDM::uhdmbit_select;
                    // § elabConnSelFoldNoTs21 (LANDED r10earl21; the note
                    // below is pass 20's decode, kept because it names the
                    // trap).  qa20.sv is the 2x2 (written
                    // `pkg::P` vs wildcard-imported x def listing vs
                    // ELABORATED view) of one child instantiated twice as
                    // `.e(v[PI])` / `.e(v[qa20_pkg::PI])`: golden stamps the
                    // ref_typespec on exactly ONE of the four — the DEF
                    // listing's UNQUALIFIED row — and leaves the ELABORATED
                    // one bare, where § selFold9 stamps it.  That is BOTH
                    // top_earlgrey heads (def: and top:, r=-1, one object:
                    // u_rv_core_ibex > u_core > if_stage_i's
                    // `.instr_pmp_err_i ( pmp_req_err[PMP_I] )`,
                    // ibex_core.sv:394:47).  The carve-out written as
                    // `selFold9 && !moduleDefEmit && parent->VpiParent() is a
                    // port` KILLS THE DEF ROW TOO: the def listing's port
                    // High_conn is minted AFTER emitModuleDef has popped its
                    // DefEmitGuard, so moduleDefEmit reads FALSE there — the
                    // same deferred-mint trap ModuleEmit's DefNetViewGuard
                    // exists to patch.  Pass 21 wants a def-view marker that
                    // survives to the connection mint (or a High_conn guard
                    // of its own), not another parent test.
                    // THE MARKER IS § elabConnEmit21, set by emitInstance
                    // around the elaborated child port's HighConn actual —
                    // the twin of the def listing's § defRefModConn.  Only
                    // the ts STAMP is suppressed: golden's elab constant
                    // still parents at the bit_select, so § selFold9 itself
                    // stays true and only this derived flag is gated.
                    bool selFoldTs21 = selFold9 && !elabConnEmit21;
                    if ((parent && parent->UhdmType() == UHDM::uhdmoperation) ||
                        procSelFold9 || selFold9)
                        c->VpiParent(parent);
                    // A DEF param-init SYS-FUNC-CALL argument fold reading an
                    // imported param ($clog2(DATA_WIDTH) with DATA_WIDTH an
                    // imported pkg param) also carries the ts ref, AND
                    // re-parents the constant at the imported param's own
                    // package param_assign (Surelog; simple_package).
                    bool sysFuncArgFold =
                        inParamInit && paramInitDef && !paramInitPkg && parent &&
                        parent->UhdmType() == UHDM::uhdmsys_func_call;
                    // A def-view cont-assign fold that READS an IMPORTED param
                    // carries a ref_typespec to the imported param's def
                    // typespec (module-named, instanced at the package) — the
                    // fold is a resolved copy of a typed param (Surelog).
                    // A PROCEDURAL operand fold reading an IMPORTED param
                    // likewise carries the ts ref (scoped at the enclosing
                    // statement block) — the fold resolves a typed param
                    // materialized into this module (Surelog; PartSelectInFor
                    // for (int i = 0; i < NumRegsKey; i++)).
                    bool procOpFold9 = inProcessEmit && !inParamInit && parent &&
                                       parent->UhdmType() ==
                                           UHDM::uhdmoperation;
                    // A TASK/FUNCTION-BODY operand fold reading an IMPORTED
                    // param carries the same ts ref, scoped at the SUBROUTINE
                    // (`prefix` is already the tf fullname here — Surelog;
                    // DefaultPatternInt's `for (int i = 0; i < CNT; i++)`
                    // inside function ASSIGN_VADDR gives ref_typespec
                    // work@top.ASSIGN_VADDR -> the package's int_typespec).
                    // inProcessEmit is set only for always/initial blocks, so
                    // a body statement needs its own gate. Deliberately does
                    // NOT extend the untyped-materialized-import VpiSize rule
                    // below: that one was measured on a process witness only.
                    bool tfOpFold9 = currentTf && !inProcessEmit &&
                                     !inParamInit && parent &&
                                     parent->UhdmType() == UHDM::uhdmoperation;
                    // A PROCEDURAL operand fold reading an UNTYPED param that
                    // this module MATERIALIZED from an import reads the
                    // materialized copy, whose own param_assign already folded
                    // at the param's TYPE width (ParamEmit's defUntypedImport
                    // rule: 32 for a plain `parameter p1 = 1;`). So the read
                    // inherits 32, not the untyped 64 that a package-scope
                    // fold would carry — PackageNet `v = p1 + p2;`.
                    // § defParamInitImportOpFold — the SAME inheritance for a
                    // DEF param-init OPERATION operand: `localparam
                    // etag_width_p = dword_width_gp - page_offset_width_gp`
                    // reads two untyped wildcard-imported package localparams,
                    // and golden's module DEF listing folds both operands at
                    // 32, the width their materialized copies already carry —
                    // the same rule the procedural witness gave, now measured
                    // on a param-init one (BlackBePipeInt etag/vtag/ptag/dtag/
                    // icache_ctag_width_p).  Same UNQUALIFIED-read gate: the
                    // materialized copy is what an import-resolved name binds.
                    bool defParamInitOpFold9 =
                        inParamInit && paramInitDef && !paramInitPkg && parent &&
                        parent->UhdmType() == UHDM::uhdmoperation;
                    // § ndaOpFoldTs — a NET-DECL-ASSIGN RHS operand fold reads
                    // the same materialized import copy and carries the same ts
                    // ref, module-scoped.  The procedural / param-init / direct
                    // cont-assign witnesses above all measured one shape of the
                    // one law (Surelog stamps the resolved copy's typespec on
                    // every fold of a materialized import); a `wire [W-1:0] x =
                    // ... dword_width_gp ...;` operand had no gate at all.
                    // BlackBePipeInt pc_sext_li @15779:8 / shamt / final_src1 /
                    // final_src2: golden constant UINT sz32 + ref_typespec
                    // (fullname work@bp_be_pipe_int) -> the package's
                    // int_typespec, ours bare.
                    bool ndaOpFold9 = ndaRhsEmit && !inParamInit &&
                                      !inProcessEmit && !currentTf && parent &&
                                      parent->UhdmType() == UHDM::uhdmoperation;
                    // ...and so does an INDEXED PART-SELECT WIDTH fold, the
                    // ips sibling of selFold9's bit_select rule but scoped by
                    // the MODULE (`work@bp_be_pipe_int`), not the select:
                    // BlackBePipeInt `src2[0+:rv64_shamtw_width_gp]` @15786:64.
                    bool ipsWidFold9 = !inParamInit && parent &&
                                       parent->UhdmType() ==
                                           UHDM::uhdmindexed_part_select;
                    // § caPartSelBoundFoldTs — and so does a CONT-ASSIGN
                    // PART-SELECT RANGE-BOUND fold.  § procPsFold9 is this
                    // same rule inside a process; outside one the bound
                    // arithmetic (`ping_sel[NAlerts-1:0]`) puts an OPERATION
                    // between the folded constant and the select, so neither
                    // that flag nor § selFold9's bit_select test fires and the
                    // constant came out bare.  The ts ref is named after the
                    // SELECT, exactly like the bit-select rule.  3 Earlgrey
                    // heads, all `ref_typespec '' :0:0` vs <null>:
                    // alert_handler_ping_timer:140 (plain part_select) and
                    // pwrmgr / pwrmgr_fsm at pwrmgr_fsm:99 (the same select
                    // nested in a hier_path).  Witness
                    // tools/probe/r10earl_repro/vo.sv rows A and D; row F
                    // (`$clog2(vop::LW)`) is the negative control — a bound
                    // fold under a SYS-FUNC CALL carries no stamp in golden,
                    // which is why the parent must be the select itself or an
                    // operation DIRECTLY under it.
                    const UHDM::any* psOwner9 = nullptr;
                    if (!inParamInit && !inProcessEmit && !currentTf &&
                        !ndaRhsEmit && parent) {
                        if (parent->UhdmType() == UHDM::uhdmpart_select)
                            psOwner9 = parent;
                        else if (parent->UhdmType() == UHDM::uhdmoperation &&
                                 parent->VpiParent() &&
                                 parent->VpiParent()->UhdmType() ==
                                     UHDM::uhdmpart_select)
                            psOwner9 = parent->VpiParent();
                    }
                    bool caPsOpFold9 = psOwner9 != nullptr;
                    // § caOpFoldTs (r10earl14) — the DEF-view cont-assign rule
                    // right below fires only when the fold's parent IS the
                    // cont_assign (`assign x = P;`).  It is not a parent test
                    // at all: golden stamps EVERY fold of an unqualified
                    // imported package parameter that a def-view cont-assign
                    // RHS reduces, however deep the operation tree above it.
                    // § procOpFold9 / § tfOpFold9 / § ndaOpFold9 are the same
                    // law already recorded for the process, subroutine-body
                    // and net-decl-assign contexts; the plain cont-assign one
                    // was the hole.  Witness wd.sv, DEF listing of work@wdnp,
                    // one row per operation depth:
                    //   R1 `{NB{req_i}} & buf_alloc`  count two ops deep
                    //   R5 `NB + 8'h1`                operand one op deep
                    //   R6 `{NB{req_i}}`              count one op deep
                    //   R4 `.par_ni({PD{1'b1}})`      a PORT-CONNECTION actual
                    //   R2 `{ML{req_i}}`              module localparam — the
                    //      negative control: it never folds at all
                    // Corpus, both `ref_typespec '' :0:0` vs <null> heads:
                    // flash_phy_rd.sv:130 `{NumBuf{req_i}} & buf_alloc` and
                    // rstmgr.sv:139 `.rst_parent_ni({PowerDomains{1'b1}})`.
                    // ELAB-view datum, measured and deliberately NOT taken:
                    // golden stamps there too (fullname = the instance), but
                    // the direct-parent rule has excluded contAssignView == 2
                    // since it was decoded, so this arm keeps the def-only
                    // gate and the elab half stays an open note.
                    // OPEN (measured, not implemented): the PORT-CONNECTION
                    // actual of a def-listing child instance takes the SAME
                    // stamp — wd.sv row R4
                    // (`wdsub #(.W(PD)) u_sub (.par_ni({PD{1'b1}}))`) reads
                    // ref_typespec(work@wdnp) -> the package int_typespec in
                    // golden and <null> in ours, and that is the whole rstmgr
                    // head (`.rst_parent_ni({PowerDomains{1'b1}})`,
                    // rstmgr.sv:139:21).  The obvious gate — walk up to a
                    // `port` under `moduleDefEmit` — was BUILT AND MEASURED
                    // AS A NO-OP: the fold never sees a port above it there,
                    // so the def-listing port high_conn is emitted through a
                    // path that does not park the actual under the port
                    // before descending (or outside the moduleDefEmit guard).
                    // Find the emission site first; do not re-run the gate.
                    bool caOpFold9 = false;
                    if (!inParamInit && !inProcessEmit && !currentTf &&
                        !ndaRhsEmit && contAssignView == 1 && parent &&
                        parent->UhdmType() == UHDM::uhdmoperation) {
                        const UHDM::any* up9 = parent;
                        for (int g9 = 0;
                             g9 < 32 && up9 &&
                             up9->UhdmType() == UHDM::uhdmoperation;
                             ++g9)
                            up9 = up9->VpiParent();
                        caOpFold9 =
                            up9 && up9->UhdmType() == UHDM::uhdmcont_assign;
                    }
                    // § refModConnOpFoldTs (r10earl15) — THE PORT-CONNECTION
                    // HALF of § caOpFoldTs, and the answer to pass 14's
                    // MEASURED NEGATIVE above.  The parent walk was the wrong
                    // question: a def-listing child instance's High_conn
                    // actual is emitted from ModuleEmit's ref_module loop,
                    // which sets § defRefModConn around its emitExpr call and
                    // hands the PORT as `parent` only at the top level — an
                    // operation actual (`{PD{1'b1}}`) descends with the
                    // OPERATION as parent and the port never appears above it
                    // (the operation is minted unparented until the loop
                    // stores it).  So gate on the CONTEXT FLAG, not the tree.
                    // Witness wd.sv row R4
                    // (`wdsub #(.W(PD)) u_sub (.par_ni({PD{1'b1}}))`), whose
                    // golden ref_typespec(work@wdnp) -> the package int_typespec
                    // is byte-identical to the R1/R6 cont-assign stamps.
                    // Corpus: rstmgr.sv:139:21
                    // `.rst_parent_ni({PowerDomains{1'b1}})`.
                    bool rmConnOpFold9 =
                        !inParamInit && !inProcessEmit && !currentTf &&
                        !ndaRhsEmit && defRefModConn && parent &&
                        parent->UhdmType() == UHDM::uhdmoperation;
                    if ((procOpFold9 || defParamInitOpFold9) && !typedPkgParam &&
                        psym.getType().getCanonicalType().isIntegral() &&
                        importedParamDefTs.count(&nv.symbol) &&
                        rawText(expr.sourceRange).find("::") ==
                            std::string::npos)
                        c->VpiSize((int32_t)psym.getType().getBitWidth());
                    if ((parent &&
                         parent->UhdmType() == UHDM::uhdmcont_assign &&
                         contAssignView != 2) ||
                        // A DEF param-init OPERATION operand fold reading an
                        // imported param carries the ts ref too (Surelog).
                        (inParamInit && paramInitDef && !paramInitPkg &&
                         parent &&
                         parent->UhdmType() == UHDM::uhdmoperation) ||
                        procOpFold9 || tfOpFold9 || sysFuncArgFold ||
                        procSelFold9 || procPsFold9 || selFoldTs21 ||
                        ndaOpFold9 ||
                        ipsWidFold9 || caPsOpFold9 || caOpFold9 ||
                        rmConnOpFold9)
                        // Only a param MATERIALIZED into this module (read
                        // through an import, i.e. UNQUALIFIED) carries the ts
                        // ref; a QUALIFIED pkg::P read folds bare (the def ts
                        // belongs to another module's import — Surelog,
                        // BSOPPS*InGenForOfSubmodule).
                        // § caPartSelBoundFoldTs stamps BOTH spellings: vo.sv
                        // row C (`v_i[vop::PW-1:0]`) carries the same ts ref
                        // as row A's bare read, so the qualified exclusion —
                        // measured on a bit-select / pattern context — does
                        // not reach a part-select range bound.
                        if (auto tit = importedParamDefTs.find(&nv.symbol);
                            tit != importedParamDefTs.end() &&
                            (caPsOpFold9 ||
                             rawText(expr.sourceRange).find("::") ==
                                 std::string::npos)) {
                            auto* rt = s.MakeRef_typespec();
                            if (procSelFold9 || selFold9)
                                rt->VpiFullName(
                                    ((UHDM::bit_select*)parent)->VpiFullName());
                            else if (caPsOpFold9) {
                                // § caPartSelBoundFoldTs — named after the
                                // SELECT.  A plain part_select already carries
                                // the instance-qualified fullname
                                // (`work@voa.v_i`); one nested in a hier_path
                                // carries only the dotted path text, so the
                                // instance prefix and the select's own member
                                // name bracket it
                                // (`work@voa.st.addr[2 - 1:1].addr`).
                                auto* ps9 = (const UHDM::part_select*)psOwner9;
                                std::string fn9(ps9->VpiFullName());
                                if (fn9.empty())
                                    fn9 = prefix;
                                else if (fn9.compare(0, prefix.size(), prefix) != 0)
                                    fn9 = prefix + "." + fn9 + "." +
                                          std::string(ps9->VpiName());
                                rt->VpiFullName(fn9);
                            }
                            else
                                rt->VpiFullName(prefix);
                            rt->VpiParent(c);
                            // A CONT-ASSIGN fold binds its OWN clone of the
                            // imported param's typespec (Surelog mints one per
                            // reference); other folds share the def object.
                            bool caFold9 =
                                ((parent &&
                                  parent->UhdmType() == UHDM::uhdmcont_assign &&
                                  contAssignView != 2) ||
                                 selFold9 ||
                                 // § caOpFoldTs — a nested-operation fold is
                                 // the same cont-assign fold, so it takes the
                                 // same per-reference typespec clone.
                                 caOpFold9) &&
                                nv.symbol.kind == SymbolKind::Parameter;
                            if (caFold9) {
                                std::string savedPfx9 = syntaxRefPrefix;
                                syntaxRefPrefix = prefix;
                                auto* cl9 = makeParamTs(
                                    nv.symbol.as<ParameterSymbol>(), true);
                                syntaxRefPrefix = savedPfx9;
                                cl9->Instance(tit->second->Instance());
                                cl9->VpiParent(rt);
                                rt->Actual_typespec(cl9);
                            }
                            else
                                rt->Actual_typespec(tit->second);
                            c->Typespec(rt);
                            // The imported-param sys-func fold re-parents the
                            // folded constant at the pkg param's param_assign;
                            // so does a cont-assign fold.
                            // ...but a bit-select fold keeps the SELECT as
                            // its parent (set above), not the pkg param_assign.
                            // § caOpFoldTs deliberately does NOT re-parent:
                            // golden re-parents only the REPLICATION-COUNT
                            // flavour (wd.sv R1/R4/R6 sit under the pkg
                            // param_assign, R5's arithmetic operand stays
                            // under its operation), and vpiParent is not a
                            // uhdm-cmp field, so the split is recorded here
                            // rather than implemented.
                            if ((sysFuncArgFold || (caFold9 && !caOpFold9) ||
                                 procPsFold9) &&
                                !selFold9)
                                if (auto cIt = pkgParamConst.find(&nv.symbol);
                                    cIt != pkgParamConst.end() &&
                                    cIt->second->VpiParent())
                                    c->VpiParent(cIt->second->VpiParent());
                        }
                    // § qualPkgParamFoldTs — the QUALIFIED half of the same
                    // law.  The gate right above says "only a param
                    // MATERIALIZED into this module carries the ts ref; a
                    // QUALIFIED pkg::P read folds bare"; that was measured on
                    // BSOPPS*InGenForOfSubmodule, where the reading module
                    // ALSO imports the package, so the def ts it would name
                    // belongs to another module's import copy.  When the
                    // read is a DEF-view PARAM-INIT OPERATION operand, golden
                    // DOES stamp — and it names the PACKAGE parameter's OWN
                    // declaration typespec (§ stampFoldedPkgParamTs's object),
                    // module-scoped, NOT the materialized copy's.
                    // Measured on th.sv, all four corpus spellings, in the
                    // module DEF listing and only there: a replication COUNT
                    // (`{thp::NPeriph{1'b1}}`), both operands of an arithmetic
                    // op (`thp::Base - 4*thp::Sz`), and both arms of a ternary
                    // — with a module-LOCAL localparam read as the negative
                    // control (no stamp on either side).  th.sv was measured
                    // BOTH WAYS: with and without `module th import thp::*;`,
                    // golden stamps the SAME package-side int_typespec, so the
                    // materialized copy does not suppress it (pinmux writes
                    // `import pinmux_reg_pkg::*` AND reads
                    // `pinmux_reg_pkg::NMioPeriphOut` qualified).
                    // 5 Earlgrey heads (ranked residue (1)):
                    // alert_handler_ping_timer:140, dm_csrs:91, dm_mem:65,
                    // flash_phy_pkg:43, pinmux:54.
                    // DISTINGUISHER, measured as a REGRESSION and then gated:
                    // u2r BitSelectOfParameterPassedToSubmoduleInGenForOf-
                    // Submodule writes `localparam pinmux_pkg::target_cfg_t
                    // PinmuxTargetCfg = '{dio_pad_type:
                    // {pinmux_pkg::NDioPads{prim_pad_wrapper_pkg::B}}};` and
                    // golden leaves THAT replication count bare.  The
                    // difference is the ASSIGNMENT-PATTERN context: a fold
                    // under a tagged_pattern / op75 member value is not
                    // stamped, a direct param-init operand is.  (The earlier
                    // reading of that test — "a QUALIFIED read folds bare
                    // whenever the param is materialized somewhere" — is
                    // wrong: pinmux imports its package and still stamps.)
                    bool inPatternFold9 = false;
                    for (const UHDM::any* a9 = parent; a9; a9 = a9->VpiParent()) {
                        if (a9->UhdmType() == UHDM::uhdmtagged_pattern ||
                            (a9->UhdmType() == UHDM::uhdmoperation &&
                             ((const UHDM::operation*)a9)->VpiOpType() == 75)) {
                            inPatternFold9 = true;
                            break;
                        }
                        if (a9->UhdmType() == UHDM::uhdmparam_assign)
                            break;
                    }
                    if (defParamInitOpFold9 && !c->Typespec() &&
                        !inPatternFold9 &&
                        rawText(expr.sourceRange).find("::") !=
                            std::string::npos)
                        stampFoldedPkgParamTs(c, nv.symbol, prefix);
                    // § psBoundPkgParamTs31 (r10earl31) — A PACKAGE-PARAMETER
                    // FOLD THAT LANDS IN A part_select's RANGE, on EITHER
                    // BOUND, CARRIES A ref_typespec TO THE PARAMETER'S OWN
                    // DECLARATION TYPESPEC — in every scope, at every
                    // operation depth, whatever the spelling.
                    //
                    // THE HEAD: Earlgrey_0_1/default, dm_csrs.sv:408
                    // `abstractauto_d.autoexecdata = 12'(dmi_req_i.data[
                    // dm::DataCount-1:0]);` — golden's folded `4'h2` carries
                    // ref_typespec(work@dm_csrs.csr_read_write.dmi_req_i.data
                    // [4'h2 - 1:0].data) -> logic_typespec 25:14-25:25 (the
                    // localparam's OWN `logic [3:0]` in dm_pkg.sv), ours was
                    // bare, and expr::Compare reads Typespec() before any
                    // constant field, so this was the row's whole head.
                    //
                    // WHY THE EXISTING RULES DO NOT REACH IT (both measured,
                    // e1_psbound.sv):
                    //   * § caPartSelBoundFoldTs's psOwner9 excludes
                    //     inProcessEmit / currentTf, and its walk is one
                    //     operation deep — dm_csrs.sv:409's bound
                    //     (`dm::ProgBufSize-1+16`) is TWO deep.
                    //   * every stamping arm above needs
                    //     importedParamDefTs.count(sym), i.e. the param must be
                    //     MATERIALIZED by an import.  dm_csrs.sv has NO import
                    //     at all, so a qualified-only read is invisible there;
                    //     e1 o11 shows even the CONT-ASSIGN bound stays bare
                    //     without one, while golden stamps it.
                    //
                    // STATED GATE == CODE GATE.  The gate is exactly: this is a
                    // package-parameter fold (the enclosing `if` at the top of
                    // this block), the constant is still BARE, and walking up
                    // through OPERATIONS ONLY reaches a part_select.  Nothing
                    // else — no context flag, no view test, no import test, and
                    // NO TEXT TEST (e4 k3 stamps a MACRO-written bound, so a
                    // rawText("::") test would have missed it, and a `work@`
                    // test would have keyed on a character a legal ESCAPED
                    // identifier can contain — e4 k2 selects through `\d@x `).
                    // The operation-only walk is what abstains on golden's
                    // measured negatives: a bound under a SYS-FUNC CALL
                    // (e1 o8 / vo.sv row F) stops at the sys_func_call, and a
                    // bit_select INDEX, an indexed-part-select BASE, an
                    // assignment RHS, a replication count, a concat element, a
                    // case item and an if/for condition (e3 p1..p14) all stop
                    // somewhere else — golden leaves every one of them BARE.
                    if (!c->Typespec()) {
                        const UHDM::any* up31 = parent;
                        bool ternTrueArm31 = false;
                        for (int g31 = 0; g31 < 32 && up31 &&
                                          up31->UhdmType() ==
                                              UHDM::uhdmoperation;
                             ++g31) {
                            // GATE ADDED AT INTEGRATION (verifier F1, the one
                            // finding that kept its verdict at "PASS with a
                            // required follow-up"): golden does NOT treat a
                            // CONDITIONAL's operands alike.  On
                            // `(cond ? T : F)` inside a select bound golden
                            // stamps the CONDITION and the FALSE arm but
                            // leaves the TRUE arm (operand index 1) BARE —
                            // measured on TWO spellings (v4_ops.sv o24, all
                            // three positions of one line, and the 24-line
                            // minimal witness v3_tern.sv, which the un-gated
                            // law flipped from PASS_CMP + DUMP_MATCH to
                            // CMP_FAIL).  The refusal is STRUCTURAL, matching
                            // the law's own no-text-test discipline: refuse
                            // when the walk passes through the TRUE arm of a
                            // vpiConditionOp (VpiOpType 32).
                            //
                            // POSITION CANNOT BE READ FROM THE PARENT: this
                            // code runs while the ancestor operations are
                            // MID-CONSTRUCTION — `op->Operands(operands)` is
                            // attached only after ALL operands are emitted,
                            // so the parent's list is NULL here (measured
                            // twice: a pointer test, then a size test; both
                            // provably dead).  The ConditionalOp arm instead
                            // pushes itself on ternTrueArmOps31 around its
                            // TRUE-arm emission; a hop found in that stack IS
                            // a ternary whose true arm we are inside —
                            // pointer identity, so a part_select that itself
                            // sits in a true arm (a real shape,
                            // `c ? d[X-1:0] : e`) still stamps its bounds.
                            // This is also consistent with the campaign's old
                            // fold rule that vpiConditionOp reduces only the
                            // SELECTED arm.  Zero corpus reach today (no
                            // corpus file writes a ternary inside select
                            // brackets — grep-proven by the verifier), so the
                            // gate changes no gate number.
                            auto* op31 =
                                (const UHDM::operation*)up31;
                            if (op31->VpiOpType() == 32) {
                                for (const UHDM::any* t31 : ternTrueArmOps31)
                                    if (t31 == up31) {
                                        ternTrueArm31 = true;
                                        break;
                                    }
                            }
                            up31 = up31->VpiParent();
                        }
                        if (!ternTrueArm31 && up31 &&
                            up31->UhdmType() == UHDM::uhdmpart_select) {
                            // The ref_typespec is named after THE SELECT, and a
                            // PLAIN select already carries the whole scoped
                            // name this rule needs — `work@e1.blk.d` in a named
                            // block, `work@e1.d` in an unnamed one,
                            // `work@e1.f1.w` in a function body,
                            // `work@e4.gblk[0].ginner.d` in an elaborated gen
                            // scope, `work@e4child.blk@1.d@x` for an ESCAPED
                            // signal name — so it is used VERBATIM.
                            // DO NOT rebuild it as `prefix + "." + name`: that
                            // form was BUILT AND MEASURED WRONG.  `prefix` is
                            // not the statement's scope here — the emitter
                            // descends into a range through the SELECT, so a
                            // bound one operation deep already carries the
                            // select's own fullname as its prefix and the
                            // rebuild doubled the last component
                            // (`work@e1.blk.d.d`, 8 arm cells, e1 + e4).
                            // A select nested in a HIER_PATH is the exception:
                            // its fullname is only the dotted path text
                            // (`dmi_req_i.data[4'h2 - 1:0]`), so the scope
                            // prefix and the select's own member name bracket it
                            // — `work@dm_csrs.csr_read_write.dmi_req_i.data[
                            // 4'h2 - 1:0].data`, e4 k4 one struct level deeper,
                            // and e1 o12/o13 hold that form at ZERO operation
                            // depth and on the RIGHT bound.  The hier_path test
                            // is STRUCTURAL, not a text test, for the reason
                            // given above.
                            auto* ps31 = (const UHDM::part_select*)up31;
                            std::string nm31(ps31->VpiName());
                            std::string fn31(ps31->VpiFullName());
                            bool hier31 =
                                ps31->VpiParent() &&
                                ps31->VpiParent()->UhdmType() ==
                                    UHDM::uhdmhier_path;
                            std::string full31 = prefix;
                            if (fn31.empty()) {
                                if (!nm31.empty())
                                    full31 = prefix + "." + nm31;
                            }
                            else if (hier31)
                                // GUARD ADDED AT INTEGRATION (verifier F2): a
                                // hier_path select's OWN fullname can already
                                // carry the instance prefix — a select inside a
                                // PORT CONNECTION arrives here with
                                // `work@v5.u1.a.o.a[...]`, and the un-guarded
                                // `prefix + "." + fn31` minted a SECOND stamp
                                // named `work@v5.work@v5.u1...`-style (one of
                                // the two copies got the def-view prefix
                                // doubled; arm v5_hier.sv:26).  The
                                // pre-existing arm at the `fn9.compare` site
                                // already had exactly this guard; the new
                                // branch inherits it.  vpiFullName is compared
                                // nowhere, but a NEW object with a WRONG name
                                // is the defect class this pass fixed twice
                                // before delivery — it does not get to ship a
                                // third.
                                full31 = (fn31.compare(0, prefix.size(),
                                                       prefix) == 0
                                              ? fn31
                                              : prefix + "." + fn31) +
                                         (nm31.empty() ? "" : "." + nm31);
                            else
                                full31 = fn31;
                            stampFoldedPkgParamTs(c, nv.symbol, full31,
                                                  /*declTsOnly=*/true);
                        }
                    }
                    return c;
                }
                ref->VpiFullName(std::string(scope->asSymbol().name) + "::" +
                                 std::string(nv.symbol.name));
            }
            else {
                // A PACKAGE enum-const reference in a module expression folds
                // to a constant carrying the enum const's own encoding, at
                // the reference's span.
                if (nv.symbol.kind == SymbolKind::EnumValue) {
                    bool inPkg = false;
                    for (auto sc2 = nv.symbol.getParentScope(); sc2;
                         sc2 = sc2->asSymbol().getParentScope()) {
                        if (sc2->asSymbol().kind == SymbolKind::Package) {
                            inPkg = true;
                            break;
                        }
                        if (sc2->asSymbol().kind == SymbolKind::InstanceBody)
                            break;
                    }
                    // An IMPORTED (unqualified) enum value keeps its ref bound
                    // to the enum const (materialized like an imported param);
                    // only a QUALIFIED pkg::VALUE reference folds to a constant.
                    // (expr.syntax can be null — test the raw text.)
                    // NOTE § caBareEnumFold — TRIED AND REVERTED, r10rggen9.
                    // The bare form DOES fold as the direct Rhs of a
                    // cont-assign: golden's elab `assign register_if.status =
                    // RGGEN_OKAY;` (rggen_register_common:104) is a LOC-LESS
                    // BIN:00 size 2 constant, and tools/probe/r10rggen9repro/
                    // ta.sv reproduces it (bare -> loc-less BIN constant,
                    // qualified -> constant at the written span; the LHS —
                    // interface signal or plain net — is irrelevant).  But it
                    // is a VIEW-SPLIT rule and we cannot express it yet:
                    // golden keeps the ref_obj in the DEF listing
                    // (work@rggen_register_common.RGGEN_OKAY, which is the
                    // whole-design cmp head the moment we fold there) AND the
                    // Rggen ELAB gen tree still shows golden objects of BOTH
                    // shapes, so our single cont_assign object shared across
                    // views cannot satisfy both.  Folding unconditionally moved
                    // the census the wrong way (11 rows golden-constant became
                    // 16 rows golden-ref_obj); gating on !moduleDefEmit
                    // restored the head but changed nothing (662 either way).
                    // The prerequisite is per-view cont_assign objects for this
                    // module, not a better predicate here.
                    if (inPkg &&
                        rawText(expr.sourceRange).find("::") ==
                            std::string::npos)
                        inPkg = false;
                    // Only MODULE contexts fold; interfaces keep the ref.
                    if (inPkg) {
                        const UHDM::BaseClass* pw = parent;
                        while (pw && pw->UhdmType() != UHDM::uhdmmodule_inst &&
                               pw->UhdmType() != UHDM::uhdminterface_inst &&
                               pw->UhdmType() != UHDM::uhdmpackage)
                            pw = pw->VpiParent();
                        if (!pw || pw->UhdmType() != UHDM::uhdmmodule_inst)
                            inPkg = false;
                    }
                    if (inPkg) {
                        if (auto eit2 = enumConstMap.find(&nv.symbol);
                            eit2 != enumConstMap.end() &&
                            eit2->second->UhdmType() == UHDM::uhdmenum_const) {
                            auto* src = (UHDM::enum_const*)eit2->second;
                            auto* c = s.MakeConstant();
                            c->VpiDecompile(src->VpiDecompile());
                            c->VpiSize(src->VpiSize());
                            std::string_view v = src->VpiValue();
                            c->VpiValue(std::string(v));
                            // § enumSubstIntConst30 — THE vpiConstType OF A
                            // SUBSTITUTED ENUM LITERAL IS DERIVED FROM THE
                            // enum_const'S OWN VALUE-ENCODING PREFIX, and an
                            // `INT:` value is vpiIntConst (7), NEVER
                            // vpiUIntConst (9).  This chain was missing its
                            // `INT:` arm and fell through to vpiUIntConst, so
                            // every implicit-valued package enum member folded
                            // to a SELF-INCONSISTENT object: value `INT:0`,
                            // vpiConstType 9.  vpi_user.h:491,493 —
                            // 7 = vpiIntConst, 9 = vpiUIntConst.
                            //
                            // MEASURED (tools/probe/r10earl30repro §3): golden
                            // holds ZERO (INT:, 9) constants in ANY arm, and
                            // its (INT:, 7) count equals our (INT:, 9) count
                            // one for one — 16/16 on g3_base, 7/7 on g5_scope.
                            // The grid says neither the CONTEXT (comparison
                            // operand, cont-assign, assignment RHS, select
                            // index, concat element, case item), nor the SCOPE
                            // (module body, function, task, always_ff, named
                            // block, generate-if), nor the VIEW (def and elab
                            // both), nor the enum BASE TYPE (logic [2:0],
                            // logic [7:0], signed, bit, int, byte, no base)
                            // discriminates: all of them read 7 in golden.
                            // What DOES discriminate is the MEMBER'S OWN
                            // WRITTEN FORM, and it is already carried in the
                            // value: an implicit or based member encodes `INT:`
                            // (-> 7) while an UNSIZED-DECIMAL member
                            // (`Z1 = 1`) encodes `UINT:` at size 64 (-> 9,
                            // which the fallthrough already got right and which
                            // g3_base's J0/J1 cells confirm MATCHED golden
                            // before this change).
                            //
                            // The same law is already written out at
                            // `enumMemberSubstConst` (ExprEmit ~3141, the
                            // struct-pattern/parameter substitution) and at
                            // ParamEmit ~12642 (an enum-typed parameter's RHS);
                            // this call site and ModuleEmit ~23806 were the two
                            // that never got it.  Corpus head: Earlgrey_0_1
                            // dm_csrs.sv:389 `cmderr_q == dm::CmdErrNone`.
                            c->VpiConstType(v.rfind("BIN:", 0) == 0   ? vpiBinaryConst
                                            : v.rfind("HEX:", 0) == 0 ? vpiHexConst
                                            : v.rfind("OCT:", 0) == 0 ? vpiOctConst
                                            : v.rfind("DEC:", 0) == 0 ? vpiDecConst
                                            : v.rfind("INT:", 0) == 0 ? vpiIntConst
                                                                      : vpiUIntConst);
                            setLoc(c, expr.sourceRange);
                            if (!suppressConstParent && parent &&
                                parent->UhdmType() == UHDM::uhdmoperation)
                                c->VpiParent(parent);
                            return c;
                        }
                    }
                }
                // A MODULE parameter referenced inside an elaborated GEN-BLOCK
                // function folds to its value (the gen block is a concrete
                // instance), unlike a plain-module function which keeps the ref
                // (tfContext). Carries the param's type as a ref_typespec.
                // ELAB gen-scope CA LHS select bounds fold PARAM refs to
                // typed constants (base-scoped ts ref -> the param's int ts
                // at its decl type span — Surelog).
                if (genCaLhsParamFold && inPsBound &&
                    nv.symbol.kind == SymbolKind::Parameter) {
                    // A TYPELESS parameter object reduces to the plain
                    // unsized UINT — no width, no typespec (see
                    // typelessParamObj; BasicOh `ram[rd_addr[AW-1:0]]`).
                    if (typelessParamObj(parent, nv.symbol.name)) {
                        auto& psT = nv.symbol.as<ParameterSymbol>();
                        auto& cvT = psT.getValue();
                        if (cvT.isInteger() && !cvT.integer().hasUnknown()) {
                            auto* cT = s.MakeConstant();
                            std::string dT = cvT.integer().toString(
                                LiteralBase::Decimal, false);
                            cT->VpiDecompile(dT);
                            cT->VpiSize(64);
                            cT->VpiValue("UINT:" + dT);
                            cT->VpiConstType(vpiUIntConst);
                            cT->VpiParent(parent);
                            setLoc(cT, expr.sourceRange);
                            return cT;
                        }
                    }
                    // RHS select bounds fold to a USE-SITE constant whose
                    // parent is the param's own param_assign; ts ref scopes
                    // at the enclosing INSTANCE (Surelog).
                    // Only for a TYPED parameter (genscope_cells' `parameter
                    // int CounterWidth`), whose declared type is what the
                    // reduce goes through; an UNTYPED one takes the ordinary
                    // use-site shape below — operation parent, select-base
                    // scope (BasicOh oh_memory_dp `rd_reg[N-1:0]`).
                    bool typedPar9 = false;
                    if (auto dt9 =
                            nv.symbol.as<ParameterSymbol>().getDeclaredType())
                        if (auto tsn9 = dt9->getTypeSyntax())
                            typedPar9 =
                                tsn9->kind != syntax::SyntaxKind::ImplicitType;
                    if (!inLhs && typedPar9) {
                        // § genCaOwnSymFirst — THIS instance's own symbol
                        // before the location+name scan.  Every instance of a
                        // parameterized module registers its elaborated
                        // constant at the same declaration, so the scan hands
                        // back whichever instance was emitted FIRST: Rggen's
                        // block_1 register-file decoder (ADDRESS_WIDTH 7)
                        // folded `i_address[WIDTH-1:LSB]` with block_0's
                        // WIDTH 8 while its own END_ADDRESS was correctly 5
                        // bits wide.  Same failure mode § genProcParamFold
                        // fixed in the process path (pass 7); the scan stays
                        // as the fallback for bodies that share symbols with
                        // the def view.
                        const UHDM::constant* ownEc9 = nullptr;
                        if (auto oit9 = elabParamConst.find(&nv.symbol);
                            oit9 != elabParamConst.end() && oit9->second)
                            ownEc9 = oit9->second;
                        for (auto& [esym, econ] : elabParamConst)
                            if (ownEc9 ? econ == ownEc9
                                       : (esym->location == nv.symbol.location &&
                                          esym->name == nv.symbol.name)) {
                                auto* c2 = s.MakeConstant();
                                c2->VpiDecompile(econ->VpiDecompile());
                                c2->VpiSize(econ->VpiSize());
                                c2->VpiValue(std::string(econ->VpiValue()));
                                c2->VpiConstType(econ->VpiConstType());
                                c2->VpiParent((UHDM::any*)econ->VpiParent());
                                setLoc(c2, expr.sourceRange);
                                auto* rt2 = s.MakeRef_typespec();
                                std::string ipfx = prefix;
                                for (int k2 = 0; k2 < 2; k2++)
                                    if (auto dpos = ipfx.rfind('.');
                                        dpos != std::string::npos)
                                        ipfx.resize(dpos);
                                rt2->VpiFullName(ipfx);
                                rt2->VpiParent(c2);
                                auto* it2 = s.MakeInt_typespec();
                                // § genCaFoldTsSignedFromParam24 (r10earl24) —
                                // the clone's ts carries the PARAMETER'S OWN
                                // signedness, not an unconditional signed int.
                                // The neighbouring § itsR arm four hundred
                                // lines down already keys on
                                // `psF.getType().isSigned()` and its comment
                                // says so ("keeps the signedness flag ... the
                                // same rule the parameter's own typespec
                                // follows"); this arm predates that measurement
                                // and disagreed with it.  Corpus: the
                                // top_earlgrey bisect frontier after this
                                // pass's laws 1-2, ibex_cs_registers.sv:965:56
                                // `mhpmcounter_we[31:MHPMCounterNum+3]` inside
                                // g_mcountinhibit_reduced — golden's
                                // int_typespec at the `int unsigned` type
                                // syntax has vpiSigned 0, ours had 1.
                                if (nv.symbol.as<ParameterSymbol>()
                                        .getType()
                                        .isSigned())
                                    it2->VpiSigned(true);
                                if (auto dtF =
                                        nv.symbol.as<ParameterSymbol>()
                                            .getDeclaredType())
                                    if (auto tsnF = dtF->getTypeSyntax())
                                        setLoc(it2, tsnF->sourceRange());
                                rt2->Actual_typespec(it2);
                                c2->Typespec(rt2);
                                return c2;
                            }
                    }
                    // § genCaLpPaCopy — a MODULE LOCALPARAM never reaches
                    // elabParamConst (that map holds only overridable port
                    // params), but it does have an elaborated param_assign,
                    // and Surelog's reduce hands back THAT constant verbatim:
                    // rggen_address_decoder's `localparam int LSB =
                    // $clog2(BUS_WIDTH) - 3` reads back INT:2 (a signed int
                    // expression result) and `localparam bit [WIDTH-LSB-1:0]
                    // BEGIN_ADDRESS` reads back BIN `6'b000000` through a
                    // bit_typespec — where the generic arm below mints a
                    // UINT-at-width decimal and an int_typespec.  Same law as
                    // § genProcParamFold's paSrc9 copy, one context over: a
                    // gen-scope CONT-ASSIGN select bound instead of a
                    // gen-scope process.  Keyed by THIS instance's own symbol,
                    // never a location+name scan (44 sibling instances carry
                    // different widths).  rp32_r5p_alu's `int unsigned XLOG`,
                    // whose pa Rhs IS the UINT the generic arm builds, is
                    // unchanged by the copy.
                    if (!inLhs && !elabParamConst.count(&nv.symbol))
                        if (auto pit8 = elabParamPa.find(&nv.symbol);
                            pit8 != elabParamPa.end() && pit8->second)
                            if (auto* pr8 = pit8->second->Rhs();
                                pr8 &&
                                pr8->UhdmType() == UHDM::uhdmconstant) {
                                auto* src8 = (UHDM::constant*)pr8;
                                auto* c8 = s.MakeConstant();
                                c8->VpiDecompile(src8->VpiDecompile());
                                c8->VpiSize(src8->VpiSize());
                                c8->VpiValue(std::string(src8->VpiValue()));
                                c8->VpiConstType(src8->VpiConstType());
                                c8->VpiParent(parent);
                                setLoc(c8, expr.sourceRange);
                                auto* rt8 = s.MakeRef_typespec();
                                rt8->VpiFullName(prefix);
                                rt8->VpiParent(c8);
                                // The pa Rhs constant's OWN ts ref may not be
                                // resolved yet (a def-view share or an elab
                                // pattern substitution binds it later), so fall
                                // back to the parameter's own typespec — the
                                // same object that ref ends up naming.
                                if (auto* srt8 = src8->Typespec();
                                    srt8 && srt8->Actual_typespec())
                                    rt8->Actual_typespec(
                                        srt8->Actual_typespec());
                                else
                                    bindOrParkParamTs(
                                        nv.symbol.as<ParameterSymbol>(), rt8);
                                c8->Typespec(rt8);
                                return c8;
                            }
                    auto& psF = nv.symbol.as<ParameterSymbol>();
                    auto& cvF = psF.getValue();
                    // A param with NO elaborated twin in elabParamConst (a
                    // localparam computed during elaboration — `localparam int
                    // unsigned XLOG = $clog2(XLEN)`) folds on the RHS exactly
                    // as on the LHS: a use-site constant parented at the bound
                    // operation, ts ref scoped by the SELECT BASE (boundPfx
                    // already hands that in as `prefix` under
                    // genCaLhsParamFold) and typed by the param's own declared
                    // type — signedness included, unlike the LHS arm's always
                    // -signed int (rp32_r5p_alu shf_mux_shared's
                    // `mux_op2[XLOG-1:0]`).
                    if (!inLhs && cvF.isInteger() &&
                        !cvF.integer().hasUnknown()) {
                        auto* c = s.MakeConstant();
                        std::string dR =
                            cvF.integer().toString(LiteralBase::Decimal, false);
                        c->VpiDecompile(dR);
                        c->VpiSize((int32_t)psF.getType().getBitWidth());
                        c->VpiValue("UINT:" + dR);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(parent);
                        setLoc(c, expr.sourceRange);
                        auto* rtR = s.MakeRef_typespec();
                        rtR->VpiFullName(prefix);
                        rtR->VpiParent(c);
                        auto* itsR = s.MakeInt_typespec();
                        // A TYPED param's ts spans its type syntax and keeps
                        // the signedness flag; an UNTYPED one spans the whole
                        // parameter declaration and carries none — the same
                        // rule the parameter's own typespec follows (BasicOh
                        // oh_memory_dp `rdata[N-1:0]`).
                        bool typedR = false;
                        if (auto dtR = psF.getDeclaredType())
                            if (auto tsnR = dtR->getTypeSyntax();
                                tsnR && tsnR->kind !=
                                            syntax::SyntaxKind::ImplicitType) {
                                typedR = true;
                                setLoc(itsR, tsnR->sourceRange());
                                if (psF.getType().isSigned())
                                    itsR->VpiSigned(true);
                            }
                        if (!typedR)
                            for (auto qR = nv.symbol.getSyntax(); qR;
                                 qR = qR->parent)
                                if (qR->kind ==
                                    syntax::SyntaxKind::ParameterDeclaration) {
                                    setLoc(itsR, qR->sourceRange());
                                    break;
                                }
                        rtR->Actual_typespec(itsR);
                        c->Typespec(rtR);
                        return c;
                    }
                    if (inLhs && cvF.isInteger() &&
                        !cvF.integer().hasUnknown()) {
                        auto* c = s.MakeConstant();
                        std::string dF =
                            cvF.integer().toString(LiteralBase::Decimal, false);
                        c->VpiDecompile(dF);
                        c->VpiSize((int32_t)psF.getType().getBitWidth());
                        c->VpiValue("UINT:" + dF);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(parent);
                        setLoc(c, expr.sourceRange);
                        auto* rtF = s.MakeRef_typespec();
                        rtF->VpiFullName(prefix);
                        rtF->VpiParent(c);
                        auto* itsF = s.MakeInt_typespec();
                        // Same typed/untyped shape as the RHS arm above.
                        bool typedF = false;
                        if (auto dtF = psF.getDeclaredType())
                            if (auto tsnF = dtF->getTypeSyntax();
                                tsnF && tsnF->kind !=
                                            syntax::SyntaxKind::ImplicitType) {
                                typedF = true;
                                setLoc(itsF, tsnF->sourceRange());
                                itsF->VpiSigned(true);
                            }
                        if (!typedF)
                            for (auto qF = nv.symbol.getSyntax(); qF;
                                 qF = qF->parent)
                                if (qF->kind ==
                                    syntax::SyntaxKind::ParameterDeclaration) {
                                    setLoc(itsF, qF->sourceRange());
                                    break;
                                }
                        rtF->Actual_typespec(itsF);
                        c->Typespec(rtF);
                        return c;
                    }
                }
                // ...and OUTSIDE a select bound the same fold runs on every
                // PLAIN module-param read of an ELAB gen-scope cont_assign
                // (BasicOh oh_dsync `assign dout = (DELAY & sync_pipe[SYNCPIPE])
                // | (~DELAY & sync_pipe[SYNCPIPE-1])` folds all four reads).
                // The constant is UINT at the parameter's own width and carries
                // a ref_typespec onto an int_typespec shaped like the
                // parameter's: TYPED spans its type syntax and keeps the
                // signedness flag, UNTYPED spans the whole parameter
                // declaration and carries none.  Scope is the gen scope for a
                // plain operand, the SELECT BASE inside a bit_select index.
                if (genCaLhsParamFold && !inPsBound && callArgDepth == 0 &&
                    nv.symbol.kind == SymbolKind::Parameter) {
                    bool outerParam8 = false;
                    for (auto sc8 = nv.symbol.getParentScope(); sc8;
                         sc8 = sc8->asSymbol().getParentScope()) {
                        auto sk8 = sc8->asSymbol().kind;
                        if (sk8 == SymbolKind::GenerateBlock ||
                            sk8 == SymbolKind::GenerateBlockArray)
                            break;
                        if (sk8 == SymbolKind::InstanceBody) {
                            outerParam8 = true;
                            break;
                        }
                    }
                    auto& ps8 = nv.symbol.as<ParameterSymbol>();
                    auto& cv8 = ps8.getValue();
                    if (outerParam8 && cv8.isInteger() &&
                        !cv8.integer().hasUnknown()) {
                        bool bare8 = typelessParamObj(parent, nv.symbol.name);
                        // § genCaLpPaCopy (plain-operand half) — the same
                        // verbatim copy of the LOCALPARAM's own elaborated
                        // param_assign Rhs constant that the select-bound arm
                        // above takes.  rggen_address_decoder:34
                        // `i_address[WIDTH-1:LSB] == BEGIN_ADDRESS` has one of
                        // each: LSB in the bound, BEGIN_ADDRESS as the plain
                        // operand, and golden reads both back through the
                        // parameter's own encoding and typespec (BIN
                        // `6'b000000` / bit_typespec, not UINT:0 /
                        // int_typespec).  Port params keep their existing
                        // shape — they have an elabParamConst twin.
                        if (!bare8 && !elabParamConst.count(&nv.symbol))
                            if (auto pit7 = elabParamPa.find(&nv.symbol);
                                pit7 != elabParamPa.end() && pit7->second)
                                if (auto* pr7 = pit7->second->Rhs();
                                    pr7 &&
                                    pr7->UhdmType() == UHDM::uhdmconstant) {
                                    auto* src7 = (UHDM::constant*)pr7;
                                    auto* c7 = s.MakeConstant();
                                    c7->VpiDecompile(src7->VpiDecompile());
                                    c7->VpiSize(src7->VpiSize());
                                    c7->VpiValue(
                                        std::string(src7->VpiValue()));
                                    c7->VpiConstType(src7->VpiConstType());
                                    c7->VpiParent(parent);
                                    setLoc(c7, expr.sourceRange);
                                    auto* rt7 = s.MakeRef_typespec();
                                    rt7->VpiFullName(genCaSelBasePfx.empty()
                                                         ? prefix
                                                         : genCaSelBasePfx);
                                    rt7->VpiParent(c7);
                                    if (auto* srt7 = src7->Typespec();
                                        srt7 && srt7->Actual_typespec())
                                        rt7->Actual_typespec(
                                            srt7->Actual_typespec());
                                    else
                                        bindOrParkParamTs(ps8, rt7);
                                    c7->Typespec(rt7);
                                    return c7;
                                }
                        auto* c8 = s.MakeConstant();
                        std::string d8 =
                            cv8.integer().toString(LiteralBase::Decimal, false);
                        c8->VpiDecompile(d8);
                        c8->VpiSize(bare8
                                        ? 64
                                        : (int32_t)ps8.getType().getBitWidth());
                        c8->VpiValue("UINT:" + d8);
                        c8->VpiConstType(vpiUIntConst);
                        c8->VpiParent(parent);
                        setLoc(c8, expr.sourceRange);
                        if (bare8)
                            return c8;
                        auto* rt8 = s.MakeRef_typespec();
                        rt8->VpiFullName(genCaSelBasePfx.empty()
                                             ? prefix
                                             : genCaSelBasePfx);
                        rt8->VpiParent(c8);
                        auto* its8 = s.MakeInt_typespec();
                        bool typed8 = false;
                        if (auto dt8 = ps8.getDeclaredType())
                            if (auto tsn8 = dt8->getTypeSyntax();
                                tsn8 && tsn8->kind !=
                                            syntax::SyntaxKind::ImplicitType) {
                                typed8 = true;
                                setLoc(its8, tsn8->sourceRange());
                                its8->VpiSigned(
                                    ps8.getType().getCanonicalType().isSigned());
                            }
                        if (!typed8)
                            for (auto q8 = nv.symbol.getSyntax(); q8;
                                 q8 = q8->parent)
                                if (q8->kind ==
                                    syntax::SyntaxKind::ParameterDeclaration) {
                                    setLoc(its8, q8->sourceRange());
                                    break;
                                }
                        its8->VpiParent(rt8);
                        rt8->Actual_typespec(its8);
                        c8->Typespec(rt8);
                        return c8;
                    }
                }
                // A FOR-generate gen-scope CA RHS folds MODULE-param refs in
                // select bounds to typed constants too (the gen instance is
                // concrete) — but NOT inside a function-call ARGUMENT, which
                // Surelog re-emits symbolically (read_remux's two i[OFF-1:0]
                // part-selects: the plain one folds, the call arg keeps the
                // ref).
                // § genCaLoopSelIdxFold21 / § genCaChildLoopSelFold21: a
                // SELECT operand position — a part-select bound, a bit-select
                // index written as an operation (which rescopes the prefix at
                // the select base, hence selIdxScopeDepth), or a bare
                // bit-select index (parent IS the select).
                bool caLoopSelPos21 =
                    inPsBound || selIdxScopeDepth > 0 ||
                    (parent && parent->UhdmType() == UHDM::uhdmbit_select);
                if ((genCaLoopParamFold ||
                     (genCaChildLoopFold21 && caLoopSelPos21)) &&
                    (!inLhs || inPsBound) && callArgDepth == 0 &&
                    nv.symbol.kind == SymbolKind::Parameter) {
                    bool outerParam9 = false;
                    for (auto sc9 = nv.symbol.getParentScope(); sc9;
                         sc9 = sc9->asSymbol().getParentScope()) {
                        auto sk9 = sc9->asSymbol().kind;
                        if (sk9 == SymbolKind::GenerateBlock ||
                            sk9 == SymbolKind::GenerateBlockArray)
                            break;
                        if (sk9 == SymbolKind::InstanceBody) {
                            outerParam9 = true;
                            break;
                        }
                    }
                    auto& psL9 = nv.symbol.as<ParameterSymbol>();
                    auto& cvL9 = psL9.getValue();
                    // OUTSIDE a select bound Surelog hands back the module
                    // param's OWN elaborated constant (parented at its
                    // param_assign, typespec named at the module); inside a
                    // bound it mints a use-site constant scoped by the select
                    // base. Skip the fold when that shared constant is not
                    // available.
                    UHDM::param_assign* pa9 = nullptr;
                    const UHDM::module_inst* mi9 = nullptr;
                    if (!inPsBound) {
                        const UHDM::BaseClass* mw9 = parent;
                        while (mw9 &&
                               mw9->UhdmType() != UHDM::uhdmmodule_inst)
                            mw9 = mw9->VpiParent();
                        mi9 = (const UHDM::module_inst*)mw9;
                        if (mi9 && mi9->Param_assigns())
                            for (auto* pax9 : *mi9->Param_assigns())
                                if (auto* l9 = pax9->Lhs();
                                    l9 &&
                                    l9->UhdmType() == UHDM::uhdmparameter &&
                                    ((UHDM::parameter*)l9)->VpiName() ==
                                        nv.symbol.name) {
                                    pa9 = pax9;
                                    break;
                                }
                    }
                    // § genCaLoopSelIdxFold21 — the SELECT-INDEX half of the
                    // law above, and the reason the fold went missing in a
                    // NON-TOP instance.  qd21.sv (`assign r[i] =
                    // q[NUM_REQS-1-i];` in a for-generate of a CHILD module)
                    // is golden's use-site form — constant {sz=32 dec=2}
                    // parented at the index operation with a ref_typespec
                    // named after the SELECT BASE — while we emitted a bare
                    // `ref_obj NUM_REQS`, because the shared-constant branch
                    // found no param_assign to re-parent at and the whole
                    // fold was then skipped.  qe21.sv measures the same five
                    // operand positions in a TOP module, where the walk DOES
                    // find the param_assign: golden uses the USE-SITE form in
                    // every select row there too, so the shared form is at
                    // most a vpiParent/fullname detail (neither is a uhdm-cmp
                    // field) and this stays purely ADDITIVE — it only folds
                    // where we used to leave a ref.  Corpus: the surviving
                    // top_earlgrey pair at ibex_prefetch_buffer.sv:89:59,
                    // `rdata_outstanding_q[NUM_REQS-1-i]` in gen_rd_rev.
                    if (outerParam9 && (inPsBound || pa9 || caLoopSelPos21) &&
                        cvL9.isInteger() && !cvL9.integer().hasUnknown()) {
                        auto* c9 = s.MakeConstant();
                        std::string dL9 = cvL9.integer().toString(
                            LiteralBase::Decimal, false);
                        c9->VpiDecompile(dL9);
                        c9->VpiSize((int32_t)psL9.getType().getBitWidth());
                        c9->VpiValue("UINT:" + dL9);
                        c9->VpiConstType(vpiUIntConst);
                        setLoc(c9, expr.sourceRange);
                        std::string tsName9 = prefix;
                        if (pa9) {
                            c9->VpiParent(pa9);
                            if (mi9)
                                tsName9 = mi9->VpiFullName();
                        }
                        else
                            c9->VpiParent(parent);
                        auto* rtL9 = s.MakeRef_typespec();
                        rtL9->VpiFullName(tsName9);
                        rtL9->VpiParent(c9);
                        auto* itsL9 = s.MakeInt_typespec();
                        // A TYPED param's typespec spans its type syntax and
                        // carries the signedness flag; an UNTYPED one spans
                        // the whole parameter declaration and carries none
                        // (same rule as the param's own typespec).
                        bool typed9 = false;
                        if (auto dtL9 = psL9.getDeclaredType())
                            if (auto tsnL9 = dtL9->getTypeSyntax();
                                tsnL9 && tsnL9->kind !=
                                             syntax::SyntaxKind::ImplicitType) {
                                typed9 = true;
                                setLoc(itsL9, tsnL9->sourceRange());
                                itsL9->VpiSigned(
                                    psL9.getType().getCanonicalType().isSigned());
                            }
                        if (!typed9)
                            for (auto q9 = nv.symbol.getSyntax(); q9;
                                 q9 = q9->parent)
                                if (q9->kind ==
                                    syntax::SyntaxKind::ParameterDeclaration) {
                                    setLoc(itsL9, q9->sourceRange());
                                    break;
                                }
                        itsL9->VpiParent(rtL9);
                        rtL9->Actual_typespec(itsL9);
                        c9->Typespec(rtL9);
                        return c9;
                    }
                }
                // Gen-scope instance CONNS fold genvar/localparam refs that
                // live in a GenerateBlock to their per-index UINT constants.
                // ...except inside a RANGED part_select's bounds, which Surelog
                // leaves as trees (see inPsRangeBound).
                if (genvarConnFold && !inPsRangeBound &&
                    nv.symbol.kind == SymbolKind::Parameter) {
                    bool genLocal = false;
                    for (auto sc9 = nv.symbol.getParentScope(); sc9;
                         sc9 = sc9->asSymbol().getParentScope()) {
                        auto k9 = sc9->asSymbol().kind;
                        if (k9 == SymbolKind::GenerateBlock ||
                            k9 == SymbolKind::GenerateBlockArray) {
                            genLocal = true;
                            break;
                        }
                        if (k9 == SymbolKind::InstanceBody)
                            break;
                    }
                    auto& cv9 = nv.symbol.as<ParameterSymbol>().getValue();
                    if (genLocal && cv9.isInteger() &&
                        !cv9.integer().hasUnknown()) {
                        auto* c = s.MakeConstant();
                        std::string d9 =
                            cv9.integer().toString(LiteralBase::Decimal, false);
                        c->VpiDecompile(d9);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + d9);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(parent);
                        setLoc(c, expr.sourceRange);
                        return c;
                    }
                }
                if (nv.symbol.kind == SymbolKind::Parameter &&
                    (currentSubSym || inGenScopeProc)) {
                    bool inGenFn = inGenScopeProc;
                    for (auto gsc = currentSubSym ? currentSubSym->getParentScope()
                                                  : nullptr;
                         gsc && !inGenFn; gsc = gsc->asSymbol().getParentScope()) {
                        auto gk = gsc->asSymbol().kind;
                        if (gk == SymbolKind::GenerateBlock ||
                            gk == SymbolKind::GenerateBlockArray) {
                            inGenFn = true;
                            break;
                        }
                        if (gk == SymbolKind::InstanceBody)
                            break;
                    }
                    // A gen-scope PROCESS folds only MODULE params (declared
                    // in the InstanceBody), NOT gen-block-local genvars /
                    // localparams — those keep their existing handling (folding
                    // the genvar regressed async_reset_partsel/simple_generate).
                    // And it folds them only inside SELECT BOUNDS
                    // (i*DATA_WIDTH +: DATA_WIDTH, simple_always_ifelse) —
                    // plain statement expressions keep the scoped ref
                    // (hier_path for-init PMPNumRegions-1).
                    // ...and NOT under an unpacked-array var_select's INDEX,
                    // whose sub-select bounds Surelog's reduce never reaches:
                    // BasicOh oh_memory_dp's `ram[wr_addr[AW-1:0]][i]` holds
                    // its ref_obj(AW) where the same module's own
                    // `sync_pipe[SYNCPIPE-1:0]` (and simple_always_ifelse's
                    // `data[i*DATA_WIDTH +: DATA_WIDTH]`) fold.
                    // § genProcParamFold — ...and it folds them in EVERY
                    // position of the process EXCEPT inside a for-stmt.  The
                    // "only inside select bounds" reading came from a
                    // for-INIT counter-example (PMPNumRegions-1); a
                    // purpose-built golden that puts ONE parameter in five
                    // positions of one gen-scope process
                    // (r10rggen7repro/t9.sv: bare assignment Rhs, binary
                    // operand, indexed-part-select bound, if condition, for
                    // header+body) folds the first four and keeps the ref in
                    // the for-stmt — header and body alike.  Rggen
                    // rggen_bit_field:259 `value <= INITIAL_VALUE;` is the
                    // bare-Rhs shape, ~670 gen-tree vectors.
                    // § genProcParamFold — ...and a TF-CALL ARGUMENT joins the
                    // for-stmt exception: Surelog's reduce does not descend
                    // into call actuals either.  Purpose-built golden
                    // r10scr14repro/t6.sv puts ONE module parameter in six
                    // positions of one gen-scope process — bare Rhs, binary
                    // operand and indexed-part-select bound all fold, while
                    // `fn(W)`, `fn(W / 8)` and `tk(W)` every one keep
                    // ref_obj(W).  Scr1SvTests scr1_memory_tb_axi:229
                    // `mem_read(araddr[gi], 2**arsize[gi], W_DATA/8)` inside
                    // the `rw_if` generate loop is the corpus shape.
                    // § genProcParamFoldQualCallArg20 (r10earl20) — the
                    // call-actual exception is the UNQUALIFIED-call exception.
                    // r10scr14repro/t6.sv measured `fn(W)` / `tk(W)` keeping
                    // ref_obj(W) and concluded "Surelog's reduce does not
                    // descend into call actuals"; every callee in that file is
                    // module-local.  pu20.sv puts the same parameter under
                    // four calls in one elab gen-scope process and golden
                    // folds it under the three written `pu20_pkg::pf(...)` /
                    // `pu20_pkg::pi(...)` and keeps the ref under the
                    // WILDCARD-IMPORTED, unqualified `pf(...)` — the callee's
                    // home is not the discriminator, THE WRITTEN QUALIFIER IS
                    // (pass 18 § defGenQualPkgCallBinds18, pass 19 laws 3-4,
                    // now a fourth container).  Corpus: work@prim_prince
                    // :116:67, `prim_cipher_pkg::sbox4_64bit(
                    // data_state[NumRoundsHalf], ...)`.
                    // § genProcParamFoldTopGenOnly20 (r10earl20) — the fold is
                    // a TOP-LEVEL gen scope's privilege.  pv20.sv puts the
                    // same module parameter in an always_comb of a flat
                    // if-generate, a flat for-generate, an if-generate NESTED
                    // in a for-generate and an if-generate NESTED in an
                    // if-generate: golden folds the two flat ones and keeps
                    // `ref_obj IDX` in both nested ones, loop or no loop, so
                    // the discriminator is the GENERATE NESTING DEPTH and not
                    // the loop.  (A named_begin inside the process is a
                    // STATEMENT block and does not count — `p_if` folds.)
                    // Corpus: work@prim_prince folds :116:67 in the flat
                    // `gen_middle_d64` and keeps :150:20 in `gen_bwd_d64`,
                    // which is nested inside `gen_bwd_pass`.
                    bool nestedGenBlk20 = false;
                    if (currentGenBlkScope)
                        for (auto sc20 =
                                 currentGenBlkScope->asSymbol().getParentScope();
                             sc20; sc20 = sc20->asSymbol().getParentScope()) {
                            auto sk20 = sc20->asSymbol().kind;
                            if (sk20 == SymbolKind::GenerateBlock) {
                                nestedGenBlk20 = true;
                                break;
                            }
                            if (sk20 != SymbolKind::GenerateBlockArray)
                                break;
                        }
                    if (inGenScopeProc && !currentSubSym &&
                        (varSelIdxDepth > 0 || procForAllDepth9 > 0 ||
                         (callArgDepth > 0 && !qualCallArg20) ||
                         nestedGenBlk20 || inAssertEmit9))
                        inGenFn = false;
                    if (inGenScopeProc && !currentSubSym) {
                        bool moduleParam = false;
                        for (auto sc0 = nv.symbol.getParentScope(); sc0;
                             sc0 = sc0->asSymbol().getParentScope()) {
                            auto sk = sc0->asSymbol().kind;
                            if (sk == SymbolKind::GenerateBlock ||
                                sk == SymbolKind::GenerateBlockArray)
                                break;
                            if (sk == SymbolKind::InstanceBody) {
                                moduleParam = true;
                                break;
                            }
                        }
                        if (!moduleParam)
                            inGenFn = false;
                    }
                    auto& psym = nv.symbol.as<ParameterSymbol>();
                    auto& cv = psym.getValue();
                    if (inGenFn && cv.isInteger() && !cv.integer().hasUnknown()) {
                        auto* c = s.MakeConstant();
                        std::string digits =
                            cv.integer().toString(LiteralBase::Decimal, false);
                        c->VpiDecompile(digits);
                        c->VpiSize((int32_t)psym.getType().getBitWidth());
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        setLoc(c, expr.sourceRange);
                        if (!suppressConstParent && parent &&
                            parent->UhdmType() == UHDM::uhdmoperation)
                            c->VpiParent(parent);
                        // In a gen-scope PROCESS bound fold, the constant
                        // claims the param's ELAB param_assign as parent and
                        // scopes its ts ref at the MODULE (generate_test
                        // result[i*W +: W]).
                        bool genPsBound9 = inGenScopeProc && !currentSubSym;
                        // § genProcParamFold — the folded constant is a COPY
                        // of the parameter's own ELABORATED param_assign Rhs
                        // constant, encoding and all: `parameter bit [3:0] IV`
                        // overridden with `4'ha` reads back HEX:a / 4'ha /
                        // size 4 in the process, not the UINT-at-width decimal
                        // fold (repro t8.sv / t9.sv; Rggen rggen_bit_field
                        // INITIAL_VALUE gives 4'h0, 8'h00, 2'h0, 2'b00 …
                        // straight from each instance's override).  The copy
                        // also takes that constant's typespec, which is how a
                        // `bit`-typed param reaches a bit_typespec instead of
                        // the int_typespec built below.
                        UHDM::constant* paSrc9 = nullptr;
                        if (genPsBound9 && prefix != selectBasePrefix) {
                            UHDM::param_assign* paHit9 = nullptr;
                            // THIS instance's own symbol first.  The
                            // location+name scan below is a fallback for
                            // bodies that share symbols with the def view; it
                            // must never supply the ENCODING, because every
                            // instance of a parameterized module registers a
                            // param_assign at the same declaration and the
                            // scan would hand back a sibling instance's width
                            // (Rggen: 44 rggen_bit_field instances whose
                            // INITIAL_VALUE is 1, 2, 4 or 8 bits wide).
                            if (auto eit9 = elabParamPa.find(&nv.symbol);
                                eit9 != elabParamPa.end() && eit9->second) {
                                paHit9 = eit9->second;
                                if (auto* pr9 = paHit9->Rhs();
                                    pr9 && pr9->UhdmType() ==
                                               UHDM::uhdmconstant)
                                    paSrc9 = (UHDM::constant*)pr9;
                            }
                            if (!paHit9)
                                for (auto& [esym9, epa9] : elabParamPa)
                                    if (epa9 &&
                                        esym9->location == nv.symbol.location &&
                                        esym9->name == nv.symbol.name) {
                                        paHit9 = epa9;
                                        break;
                                    }
                            // An OPERAND keeps the operation as its parent
                            // (Surelog's last writer); a whole-expression fold
                            // claims the param_assign.
                            if (paHit9 &&
                                !(parent && parent->UhdmType() ==
                                                UHDM::uhdmoperation))
                                c->VpiParent((UHDM::any*)paHit9);
                        }
                        if (paSrc9) {
                            c->VpiValue(paSrc9->VpiValue());
                            c->VpiConstType(paSrc9->VpiConstType());
                            c->VpiSize(paSrc9->VpiSize());
                            c->VpiDecompile(paSrc9->VpiDecompile());
                            // ...and the typespec follows the PARAMETER's own
                            // declared type, not the int_typespec the generic
                            // arm below mints: `parameter bit [3:0] IV` reads
                            // back through a bit_typespec.  The param
                            // constant's own ts ref is not resolved yet at
                            // this point, so build it from the declaration.
                        }
                        UHDM::typespec* declTs9 = nullptr;
                        if (paSrc9 && psym.getDeclaredType() &&
                            psym.getDeclaredType()->getTypeSyntax() &&
                            psym.getDeclaredType()
                                    ->getTypeSyntax()
                                    ->kind != syntax::SyntaxKind::ImplicitType)
                            declTs9 = makeTypespec(psym);
                        // SL carries the folded param's type as a ref_typespec
                        // whose fullname is the enclosing (function) scope.
                        UHDM::typespec* its = declTs9;
                        bool locSet9 = declTs9 != nullptr;
                        if (!its)
                            its = s.MakeInt_typespec();
                        if (genPsBound9 && !locSet9) {
                            // Full parameter-declaration span (28:5-29).
                            for (auto q9 = psym.getSyntax(); q9;
                                 q9 = q9->parent)
                                if (syntax::ParameterDeclarationBaseSyntax::
                                        isKind(q9->kind)) {
                                    setLoc(its, q9->sourceRange());
                                    locSet9 = true;
                                    break;
                                }
                        }
                        if (!locSet9)
                            if (auto dt = psym.getDeclaredType())
                                if (auto tsy = dt->getTypeSyntax())
                                    setLoc(its, tsy->sourceRange());
                        auto* rt = s.MakeRef_typespec();
                        rt->VpiParent(c);
                        std::string rpfx9 = prefix;
                        if (genPsBound9 && currentGenBlkScope &&
                            prefix != selectBasePrefix) {
                            int drop9 = 0;
                            for (auto w9 = &currentGenBlkScope->asSymbol();
                                 w9;) {
                                if (w9->kind == SymbolKind::GenerateBlock) {
                                    auto* pp9 = w9->getParentScope();
                                    if (pp9 && pp9->asSymbol().kind ==
                                                   SymbolKind::
                                                       GenerateBlockArray) {
                                        drop9++;
                                        w9 = &pp9->asSymbol();
                                    }
                                    else if (!w9->name.empty())
                                        drop9++;
                                }
                                else if (w9->kind ==
                                         SymbolKind::InstanceBody)
                                    break;
                                auto* pp9 = w9->getParentScope();
                                if (!pp9)
                                    break;
                                w9 = &pp9->asSymbol();
                            }
                            for (int d9 = 0; d9 < drop9; d9++)
                                if (auto dp9 = rpfx9.rfind('.');
                                    dp9 != std::string::npos)
                                    rpfx9.resize(dp9);
                        }
                        rt->VpiFullName(rpfx9);
                        rt->Actual_typespec(its);
                        c->Typespec(rt);
                        return c;
                    }
                }
                // DEF-view gen-block PROCEDURAL refs stay BARE (name only, no
                // fullname) — Surelog re-emits always-body statements
                // symbolically. (Continuous-assign / condition refs, emitted
                // outside defGenProcessEmit, keep their scoped fullname.)
                if (!defGenProcessEmit)
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                // § superNewFormalBinds28 — inside a `super.new` argument list
                // a reference to one of the CONSTRUCTOR'S OWN FORMALS binds;
                // everything else there (body locals, class properties) keeps
                // the classMethodNoBind silence, so the carve-out is written
                // as a symbol-kind test rather than as another arg-bind depth.
                bool superNewFormal28 =
                    superNewArgDepth28 > 0 &&
                    nv.symbol.kind == SymbolKind::FormalArgument;
                // § controlBodyNoBind28 — both binding windows are TOP-LEVEL
                // only.  curSubClassScope9 is used rather than
                // classMethodNoBind because an if/case CONDITION clears the
                // latter mid-body, which is exactly the case this must still
                // silence when the `if` itself sits inside a loop or arm.
                // ...and only for an IN-BODY class method: an out-of-body
                // definition is compiled in the home package's scope and binds
                // everywhere already (curSubOob9), which is why
                // uvm_component::lookup's `comp = top;` inside an `if` body —
                // an out-of-body definition — binds in golden while t38d's
                // in-body twin binds nothing at any depth.
                // § blockLocalSameCtrlDepthArgBinds57 — CALL SITE 3 of 3 (the
                // carve-out).  GATE: inside the § classArgBind12 window
                // (classArgBindDepth12 > 0 — which for an in-body class method
                // is STATEMENT POSITION only, § classInBodyBareCallArgStmtOnly53,
                // and which SYSTEM calls and CONCATENATION operands never enter)
                // a reference to a variable declared in an UNNAMED statement
                // block open at the SAME ctrlBodyDepth28 lifts § 28's silence.
                // DIRECTION: ADD (a vpiActual that was absent).  It lifts ONLY
                // § controlBodyNoBind28 — classMethodNoBind, unitSubNoBind9 and
                // § classInBodyRecvCallArgNoBind52 all still apply, so the
                // EXPRESSION-position and receiver-qualified cells stay bare.
                // The corpus head it clears is uvm-1.2 uvm_registry.svh:265
                // `uvm_report_fatal("FCTTYP", msg, UVM_NONE);` inside
                // `if (!$cast(create,obj)) begin string msg; ... end` — where
                // golden's ONLY extra line over ours is that argument's
                // `|vpiActual: \_string_var (…::create::msg)`.
                bool blkLocalArgBind57 =
                    classArgBindDepth12 > 0 &&
                    blkLocalSameCtrlDepth57(nv.symbol);
                bool ctrlBodyNoBind28 = curSubClassScope9 && !curSubOob9 &&
                                        ctrlBodyDepth28 > 0 &&
                                        !blkLocalArgBind57;
                // NOTE § classInBodyRecvCallArgNoBind52 — GATE: an IN-BODY
                // class method (curSubClassScope9 && !curSubOob9) inside the
                // ARGUMENT LIST of a RECEIVER-QUALIFIED, EXPRESSION-position
                // call (recvCallArgDepth52 > 0).  DIRECTION: SUPPRESS.
                // curSubClassScope9 rather than classMethodNoBind for exactly
                // the reason § controlBodyNoBind28 gives one line up: an
                // if/case CONDITION clears classMethodNoBind mid-body, and the
                // condition is where the corpus head lives
                // (`if (!pool.exists(key))`, uvm-1.2 uvm_pool.svh:87).  The
                // OUT-OF-BODY half is measured, not assumed — arm a2's ob52
                // writes the identical bodies after `endclass` and golden
                // binds all nine of its arguments.
                bool recvCallArgNoBind52 =
                    curSubClassScope9 && !curSubOob9 && recvCallArgDepth52 > 0;
                if (((classMethodNoBind && classArgBindDepth12 == 0) ||
                     unitSubNoBind9 || ctrlBodyNoBind28 ||
                     recvCallArgNoBind52) &&
                    !superNewFormal28) {
                    // Class-method body outside an if/case condition, or a
                    // `$unit`-scope subroutine body: no actual of any kind
                    // (see classMethodNoBind / unitSubNoBind9).
                }
                else if (suppressRefActual) {
                    // § genCaSysCallArgBinds22 (r10earl22) — a ref NESTED
                    // INSIDE a SYSTEM FUNCTION CALL's argument (i.e. the
                    // argument is an expression, not the ref itself) in an ELAB
                    // gen-scope cont_assign RHS BINDS, regardless of the LHS.
                    // Surelog re-elaborates the call's actuals, the same reason
                    // the size-cast carve-out below exists for processes, so
                    // the suppression that governs the rest of the RHS does not
                    // reach into a compound argument.
                    // qf22.sv writes ibex_multdiv_fast.sv:147 verbatim in a
                    // child instance and reproduces the corpus row for row:
                    //   assign mult1_res = $signed({mult1_sign_a,mult1_op_a})*
                    //                      $signed({mult1_sign_b,mult1_op_b});
                    // all four concat operands BOUND in golden, none in ours.
                    // qe22.sv separates the candidate features: the module-LHS
                    // row `assign my = $signed({s1,v1})` binds in golden too
                    // (so it is NOT § genCaOpDeepBindGenLocal20's gen-local-LHS
                    // rule reaching further), while the plain operation rows
                    // `assign oy = mult1_res ^ pv_res` and `assign my2 =
                    // v1 ^ 4'h5` stay unbound (so it is not a blanket module-
                    // LHS bind either).  qd22.sv is the TOP-module control,
                    // where all of these already bind through the unsuppressed
                    // path — THE LAW IS A CHILD-INSTANCE GAP, which is why five
                    // passes of top-module witnesses never saw it.
                    // THE `parent != sys_func_call` TEST IS THE COUNTER-
                    // WITNESS'S: three lines below the head, golden leaves
                    // `assign mac_res_signed = $signed(summand1) +
                    // $signed(summand2) + $signed(summand3);` (:151) and
                    // `assign mac_res_ext = $unsigned(mac_res_signed);` (:153)
                    // COMPLETELY UNBOUND — same gen scope, same `$signed`, but
                    // the argument is a BARE REF and the LHS is a MODULE-level
                    // signal.  A bare argument under a GEN-LOCAL LHS does bind
                    // (qe22 `assign r1 = $signed(v1)`), and that half is
                    // § genCaOpDeepBindGenLocal20's walk descending through the
                    // call — see the deep20 extension in ModuleEmit.
                    if (!defGenProcessEmit && inGenScopeCaRhs &&
                        sysCallArgDepth22 > 0 && !ref->Actual_group() &&
                        parent && parent->UhdmType() != UHDM::uhdmsys_func_call)
                        if (auto sit22 = netMap.find(&nv.symbol);
                            sit22 != netMap.end())
                            ref->Actual_group(sit22->second);
                    // ELAB gen-scope process refs to gen-block / stmt-block
                    // LOCALS still bind (module-level signals stay unbound);
                    // the DEF view binds nothing, and CA-suppress contexts
                    // keep their own rules.
                    if (!defGenProcessEmit && inGenScopeProc &&
                        !genScopeProcInLoop) {
                        // Stmt-block locals (loop vars) always bind;
                        // gen-block locals bind only OUTSIDE for-loop bodies
                        // (refs escaping a for stay unbound — Surelog).
                        auto ps0 = nv.symbol.getParentScope();
                        auto pk0 = ps0 ? ps0->asSymbol().kind
                                       : SymbolKind::Unknown;
                        if (pk0 == SymbolKind::StatementBlock ||
                            pk0 == SymbolKind::GenerateBlock) {
                            // NET-kind locals (driven regs -> nets) stay
                            // unbound in processes; VAR locals bind ONLY when
                            // they belong to the SAME gen scope as the
                            // process — refs to OUTER-scope gen locals stay
                            // unbound (Surelog).
                            bool sameScope0g =
                                pk0 != SymbolKind::GenerateBlock ||
                                !currentGenBlkScope ||
                                nv.symbol.getParentScope() ==
                                    currentGenBlkScope;
                            if (auto it0 = netMap.find(&nv.symbol);
                                sameScope0g && it0 != netMap.end() &&
                                it0->second->UhdmType() !=
                                    UHDM::uhdmlogic_net &&
                                it0->second->UhdmType() !=
                                    UHDM::uhdmstruct_net)
                                ref->Actual_group(it0->second);
                        }
                        // A ref that is the OPERAND of a size-cast op (op 67)
                        // binds even for module-level signals (Surelog
                        // re-elaborates the cast).
                        else if (parent &&
                                 parent->UhdmType() == UHDM::uhdmoperation &&
                                 ((UHDM::operation*)parent)->VpiOpType() ==
                                     vpiCastOp) {
                            if (auto it0 = netMap.find(&nv.symbol);
                                it0 != netMap.end())
                                ref->Actual_group(it0->second);
                        }
                    }
                    // A for-GENERATE gen-scope process (blk2/blk3 in prefix)
                    // ALSO binds a plain self-name ref to its OWN gen-block
                    // VARIABLE local (integer/logic/reg-var — NOT a net):
                    // `assert(i == b)` in blk2's always. The ref must be a
                    // top-level process statement (procForDepth==0): refs that
                    // ESCAPE a procedural for stay unbound, and NET locals
                    // (carryadd/simple_generate wires) never bind. Outer-scope
                    // gen locals also stay unbound.
                    if (!defGenProcessEmit && inGenScopeProc &&
                        genScopeProcInLoop && procForDepth == 0 &&
                        !ref->Actual_group()) {
                        auto* ps0 = nv.symbol.getParentScope();
                        if (ps0 &&
                            ps0->asSymbol().kind == SymbolKind::GenerateBlock &&
                            (!currentGenBlkScope ||
                             ps0 == currentGenBlkScope)) {
                            if (auto it0 = netMap.find(&nv.symbol);
                                it0 != netMap.end() &&
                                it0->second->UhdmType() !=
                                    UHDM::uhdmlogic_net &&
                                it0->second->UhdmType() !=
                                    UHDM::uhdmstruct_net &&
                                it0->second->UhdmType() !=
                                    UHDM::uhdmarray_net)
                                ref->Actual_group(it0->second);
                        }
                    }
                    // Gen-scope process ref: net/var refs stay unbound
                    // (Surelog), but an enum-const ref still binds — SL mints
                    // a FRESH loc-less enum_const per ref (parented to the
                    // ref) carrying the value, since the shared package const
                    // can't be reused across elaborated gen-block instances.
                    // DEF-view gen-block processes leave even enum refs
                    // fully unbound — and so does a gen-scope CONT-ASSIGN
                    // RHS, but ONLY for a `$unit`-scope enum.  The
                    // compilation unit is compiled before any instance and
                    // its enum consts are not reachable from the generate
                    // block's scope map, while a MODULE-local or PACKAGE
                    // enum still binds its fresh clone there — u2r
                    // MultirangesStartNotFromZero (module enum `Dirs` read
                    // in `for` gen-scope CAs) and hier_path (package
                    // `ibex_pkg::PMP_MODE_TOR` read in a gen-scope CA) are
                    // the two REGRESSION-DERIVED discriminators; Scr1SvTests'
                    // `assign core_resp = axi_reinit ? SCR1_MEM_RESP_NOTRDY :
                    // rcvd_resp` inside `if (SCR1_AXI_RESP_BP == 1)` reads a
                    // $unit enum and is bare in both elab instances (golden
                    // binds no $unit enum const inside any generate scope).
                    bool unitEnumSym9 = false;
                    if (nv.symbol.kind == SymbolKind::EnumValue)
                        for (auto sc9 = nv.symbol.getParentScope(); sc9;
                             sc9 = sc9->asSymbol().getParentScope()) {
                            auto k9 = sc9->asSymbol().kind;
                            if (k9 == SymbolKind::CompilationUnit) {
                                unitEnumSym9 = true;
                                break;
                            }
                            if (k9 == SymbolKind::Package ||
                                k9 == SymbolKind::InstanceBody ||
                                k9 == SymbolKind::GenerateBlock ||
                                k9 == SymbolKind::Subroutine)
                                break;
                        }
                    // § genCaEnumBindsSelectOnly22 (r10earl22) — the law pass
                    // 21 decoded as § genCaEnumConstNoBind21 and could not
                    // land, now with the missing quarter of its 2x2 measured
                    // (qa22.sv: one design, nine gen-scope rows over a
                    // wildcard-imported package enum plus three module-level
                    // controls).  IN A GEN-SCOPE CONT-ASSIGN RHS AN ENUM-CONST
                    // REF BINDS ONLY WHEN (a) THE REF IS IN A SELECT POSITION —
                    // part-select bound, bit-select index, or inside an index
                    // OPERATION — OR (b) THE CONT-ASSIGN'S LHS IS ITSELF A
                    // SELECT.  Everything else stays UNBOUND in golden, and
                    // qa22's plain-LHS rows say so in every spelling: a ternary
                    // BRANCH value (`c ? E_A : E_B`, :61:30/:61:36), the
                    // ternary's own COMPARISON CONDITION (:61:23), a bare
                    // comparison with no ternary (:62:23), a branch one
                    // operation deeper (:68:22/:28/:35) and the same comparison
                    // in a FOR-generate (:72:23) — while the part-select bounds
                    // (:63/:64), the bit-select index (:65) and all three
                    // MODULE-level controls (:55/:56/:57) bind.
                    //
                    // (b) IS WHAT PASS 21 WAS MISSING, and both of its
                    // counter-witnesses have a SELECT LHS:
                    //   hier_path                  region_start_addr[r] = ..
                    //                              region_addr_mask[r][b] = ..
                    //   MultirangesStartNotFromZero io_fwd_link_li[i][e_e:w_e]
                    // where the Earlgrey head and every qa22 no-bind row assign
                    // a PLAIN NAME.  Pass 21's blanket widening removed the
                    // binds from both of those and that is exactly the two u2r
                    // rows it regressed.  (A first cut of this pass claimed
                    // hier_path leaves :91:59 unbound; that came from a census
                    // script that stopped scanning at the ref's own
                    // `|vpiParent: \_operation:` line — uhdm-cmp says golden
                    // binds it.  MEASURE THE MEASURER.)
                    //
                    // Corpus head: top_earlgrey at ibex_id_stage.sv:911:45,
                    // `assign instr_type_wb_o = ~lsu_req_dec ? WB_INSTR_OTHER
                    // : ...` inside gen_stall_mem — plain-name LHS.
                    // The $unit carve-out below survives untouched: a $unit
                    // enum never binds in a gen-scope CA RHS, select position
                    // or not (Scr1SvTests).
                    // The flattened var_select path (an element select THEN a
                    // range, `x[i][e_e:w_e]`) sets neither inPsBound nor
                    // selIdxScopeDepth — it emits the bounds with the
                    // part_select itself as parent — so the parent test has to
                    // name those three types as well.
                    bool caEnumSelPos22 =
                        inPsBound || selIdxScopeDepth > 0 ||
                        (parent &&
                         (parent->UhdmType() == UHDM::uhdmbit_select ||
                          parent->UhdmType() == UHDM::uhdmpart_select ||
                          parent->UhdmType() ==
                              UHDM::uhdmindexed_part_select ||
                          parent->UhdmType() == UHDM::uhdmvar_select));
                    if (nv.symbol.kind == SymbolKind::EnumValue &&
                        !defGenProcessEmit &&
                        !(inGenScopeCaRhs &&
                          (unitEnumSym9 ||
                           !(caEnumSelPos22 || genCaLhsSelect22 ||
                             genCaLhsGenLocal23)))) {
                        if (auto eit = enumConstMap.find(&nv.symbol);
                            eit != enumConstMap.end() &&
                            eit->second->UhdmType() == UHDM::uhdmenum_const) {
                            auto* shared = (UHDM::enum_const*)eit->second;
                            auto* ec = s.MakeEnum_const();
                            ec->VpiName(shared->VpiName());
                            ec->VpiValue(std::string(shared->VpiValue()));
                            // § genCaSelEnumPlainDecompile22 — the fresh clone
                            // minted for the SELECT-POSITION survivor of
                            // § genCaEnumBindsSelectOnly22 carries the PLAIN
                            // DECIMAL decompile, not the declaration's sized
                            // literal: qa22 :63/:64/:65 are `2`/`2`/`1` in
                            // golden where the shared consts they clone read
                            // `2'd2`/`3'd2`/`2'd1`, and u2r
                            // MultirangesStartNotFromZero's `e_e` part-select
                            // bound is INT:2 decompile `2` at size 3.  The
                            // SELECT-POSITION test is load-bearing, not just
                            // inGenScopeCaRhs: hier_path's LHS-select survivor
                            // at dut.sv:91:59 is a plain comparison operand and
                            // golden keeps the sized `2'b01` there.  The
                            // gen-scope PROCESS clones this site also mints are
                            // untouched either way.
                            std::string dec22(shared->VpiDecompile());
                            if (inGenScopeCaRhs && caEnumSelPos22) {
                                std::string_view vv22 = shared->VpiValue();
                                auto cp22 = vv22.find(':');
                                if (cp22 != std::string_view::npos)
                                    dec22 = std::string(vv22.substr(cp22 + 1));
                            }
                            ec->VpiDecompile(dec22);
                            ec->VpiSize(shared->VpiSize());
                            ec->VpiParent(ref);
                            ref->Actual_group(ec);
                        }
                    }
                    // ELAB gen-instance refs to an ACTIVE for-loop iterator
                    // bind its int_var (hier_path `for (int r=...)`); the
                    // def view leaves them unbound.
                    if (!defGenProcessEmit && !ref->Actual_group() &&
                        activeForVars.count(&nv.symbol)) {
                        if (auto lit9 = netMap.find(&nv.symbol);
                            lit9 != netMap.end())
                            ref->Actual_group(lit9->second);
                    }
                    // Gen-local var refs bind ONLY when the var lives in an
                    // ANCESTOR gen scope of the emitting block (nested
                    // if-gen branch reading the for-scope's local —
                    // generate_test unit_result). Same-scope refs stay
                    // unbound (a blanket bind demoted 10 tests: carryadd,
                    // forgen02, gen_test1/4/7, MemoryInGenblock,
                    // simple_generate, ...).
                    if (!defGenProcessEmit && !ref->Actual_group() &&
                        currentGenBlkScope) {
                        auto* ps9s = nv.symbol.getParentScope();
                        // A gen-local VARIABLE wired to a CHILD-instance
                        // connection in this gen scope binds
                        // (generate_test unit_result -> adder_inst conns);
                        // unconnected gen locals stay unbound (gen_test7,
                        // genvar_loop_decl_3, iface_gen_delay_struct).
                        bool connUse9 = false;
                        if (genScopeProcInLoop && ps9s &&
                            nv.symbol.kind == SymbolKind::Variable &&
                            nv.symbol.getDeclaredType() &&
                            nv.symbol.getDeclaredType()
                                    ->getType()
                                    .getCanonicalType()
                                    .kind !=
                                SymbolKind::PredefinedIntegerType &&
                            ps9s->asSymbol().kind ==
                                SymbolKind::GenerateBlock) {
                            for (auto& gm9 : ps9s->members()) {
                                if (gm9.kind != SymbolKind::Instance &&
                                    gm9.kind != SymbolKind::GenerateBlock)
                                    continue;
                                std::function<void(const Scope&)> scanC9 =
                                    [&](const Scope& sc9) {
                                        for (auto& im9 : sc9.members()) {
                                            if (im9.kind ==
                                                SymbolKind::GenerateBlock) {
                                                scanC9((const Scope&)
                                                           im9.as<
                                                               GenerateBlockSymbol>());
                                                continue;
                                            }
                                            if (im9.kind !=
                                                SymbolKind::Instance)
                                                continue;
                                            for (auto pc9 :
                                                 im9.as<InstanceSymbol>()
                                                     .getPortConnections()) {
                                                auto* ce9 =
                                                    connectionExpr(*pc9);
                                                if (!ce9)
                                                    continue;
                                                ce9->visit(makeVisitor(
                                                    [&](auto& v9,
                                                        const NamedValueExpression&
                                                            nv9) {
                                                        if (&nv9.symbol ==
                                                            &nv.symbol)
                                                            connUse9 = true;
                                                        v9.visitDefault(nv9);
                                                    }));
                                            }
                                        }
                                    };
                                scanC9(*ps9s);
                                break;
                            }
                            if (connUse9)
                                if (auto nit9 = netMap.find(&nv.symbol);
                                    nit9 != netMap.end())
                                    ref->Actual_group(nit9->second);
                        }
                    }
                    // § genIfMisevalUnitParamBind — an ELAB gen-scope PROCESS
                    // ref to a `$unit` PARAMETER binds the design-level
                    // parameter, where the SAME name read from a gen-scope
                    // CONT-ASSIGN stays unbound (the CA path sets
                    // noUnitParamActual).  Scr1SvTests' mtvec_base_ro_rw is
                    // the whole design's only gen-scope $unit-param reader
                    // and it measures both halves: the two always_ff refs to
                    // SCR1_MTVEC_BASE_WR_BITS carry vpiActual, the CA's
                    // SCR1_CSR_MTVEC_BASE_ZERO_BITS / _RO_BITS do not.
                    if (!defGenProcessEmit && inGenScopeProc &&
                        !noUnitParamActual && !ref->Actual_group())
                        if (auto uit9 = unitParamMap.find(&nv.symbol);
                            uit9 != unitParamMap.end())
                            ref->Actual_group(uit9->second);
                    // NOTE (r10scr12, MEASURED — NOT IMPLEMENTED)
                    // § genScopeProcParamSubst — the sibling rule for a
                    // MODULE parameter: an ELAB gen-scope PROCESS read of one
                    // is not a reference in the golden at all, it is
                    // SUBSTITUTED by the parameter's value.  Scr1SvTests
                    // scr1_tapc_shift_reg:62 `shift_reg <= SCR1_RESET_VALUE;`
                    // inside `begin : dr_shift_reg` is the whole design's
                    // first uhdm-cmp failure after this pass:
                    //   golden constant{UINT:0,sz=1}@62:30-46, ts ref ->
                    //     SCR1_RESET_VALUE's own logic_typespec@11:17-39, and
                    //     VpiParent = the parameter's elab param_assign (the
                    //     Surelog re-parenting quirk — a substituted value
                    //     keeps the param_assign it was cloned from);
                    //   ours ref_obj named under the gen scope
                    //     (...i_bypass_reg.dr_shift_reg.SCR1_RESET_VALUE).
                    // The span is the USE SITE, so it is a fresh constant, not
                    // the param_assign's own Rhs object.  Note the CONTRAST
                    // with the $unit arm just above, which BINDS rather than
                    // substitutes — the split is module-param vs $unit-param,
                    // not process vs cont-assign.
                }
                else if (auto it = [&] {
                             auto i = netMap.find(&nv.symbol);
                             // Re-emitted instance views of a SHARED def use
                             // cloned body symbols; match the def net by
                             // name + decl location instead.
                             if (i == netMap.end() &&
                                 (reemitting || elabContAssignLhs))
                                 for (i = netMap.begin(); i != netMap.end();
                                      ++i)
                                     if (i->first->name == nv.symbol.name &&
                                         i->first->location ==
                                             nv.symbol.location)
                                         break;
                             return i;
                         }();
                         it != netMap.end() &&
                         // ELAB gen-scope CA RHS refs nested inside a select
                         // INDEX stay UNBOUND: Surelog names them under the
                         // select base (work@m.genblk1[0].man_rdt.rsp_off),
                         // a hier path that resolves to nothing, so it never
                         // attaches an actual (read_remux).
                         !(inGenScopeCaRhs && selIdxScopeDepth > 0) &&
                         // § fnLocalParamInitBare — a SUBROUTINE-LOCAL
                         // parameter is only in scope inside that
                         // subroutine's BODY.  Its own (and its siblings')
                         // INITIALIZER is compiled as part of the enclosing
                         // module, where the name resolves to nothing and the
                         // ref is not even registered for late binding — so
                         // it stays DANGLING, whether it names a sibling
                         // fn-local param or a module parameter (arms a2/n1,
                         // a2/n2; FuncIoTypespec's `parameter len = (ilen >=
                         // olen) ? ilen : olen`).  The body reference to the
                         // same name binds normally, which is exactly the
                         // currentSubSym split.
                         !(nv.symbol.kind == SymbolKind::Parameter &&
                           nv.symbol.getParentScope() &&
                           nv.symbol.getParentScope()->asSymbol().kind ==
                               SymbolKind::Subroutine &&
                           currentSubSym !=
                               &nv.symbol.getParentScope()
                                    ->asSymbol()
                                    .as<SubroutineSymbol>())) {
                    ref->Actual_group(it->second);
                    // Whole ref: may be re-pointed to a select object if this
                    // variable is written via a select elsewhere in the body.
                    if (selTrackActive) {
                        selWholeRefs.push_back(
                            {ref, &nv.symbol, selScopeChain()});
                        if (inLhs)
                            selWholeWrittenVars.insert(&nv.symbol);
                    }
                }
                // A GEN-SCOPE cont-assign RHS reference to a `$unit`-scope
                // ENUM CONSTANT stays UNBOUND.  The compilation unit is
                // compiled before any instance, so a generate block's scope
                // map cannot reach its enum consts — where the SAME
                // reference written in a module-level cont-assign binds the
                // shared enum_const, and a MODULE/PACKAGE enum binds even
                // inside the gen scope (u2r MultirangesStartNotFromZero /
                // hier_path).  Scr1SvTests is the measurement: of golden's
                // 621 enum-const bindings, ZERO sit inside a generate scope,
                // and scr1_mem_axi's `assign core_resp = axi_reinit ?
                // SCR1_MEM_RESP_NOTRDY : rcvd_resp;` (inside `if
                // (SCR1_AXI_RESP_BP == 1) begin : axi_resp_bp`) is bare in
                // the def view and in both elab instances, while
                // scr1_pipe_hdu's module-level `... ? SCR1_CSR_RESP_ER :
                // SCR1_CSR_RESP_OK` binds both.  The ternary is NOT the
                // discriminator — those hdu/exu/core_top ternary branches
                // bind — the generate scope plus the $unit home is.
                else if (inGenScopeCaRhs &&
                         nv.symbol.kind == SymbolKind::EnumValue && [&] {
                             for (auto sc9 = nv.symbol.getParentScope(); sc9;
                                  sc9 = sc9->asSymbol().getParentScope()) {
                                 auto k9 = sc9->asSymbol().kind;
                                 if (k9 == SymbolKind::CompilationUnit)
                                     return true;
                                 if (k9 == SymbolKind::Package ||
                                     k9 == SymbolKind::InstanceBody ||
                                     k9 == SymbolKind::GenerateBlock ||
                                     k9 == SymbolKind::Subroutine)
                                     return false;
                             }
                             return false;
                         }()) {
                    // no actual of any kind
                }
                // LAW C on the reference side: an OUT-OF-BODY method body is
                // compiled in the home PACKAGE's scope, so a CLASS-scope enum
                // constant is not visible from it.  Golden never binds one
                // there — the package-listing copy of the body leaves the ref
                // bare, and the class-view copy binds an implicit `logic_net`
                // Surelog mints for the unresolved name (r10uvm7/c6: `E0`
                // inside `function int C::oobIf` is null in pkg:p1's listing
                // and logic_net in class:C, while the in-class twin `inlIf` is
                // bare in both).  We stamped the real enum_const in every view
                // — 368 rows of SeqDriver's DEFPKG residue, SEQ_TYPE_REQ /
                // SEQ_TYPE_LOCK in uvm_sequencer_base's extern methods.  The
                // implicit-net half is NOT implemented (ranked residue).
                else if (curSubOob9 && nv.symbol.kind == SymbolKind::EnumValue &&
                         [&] {
                             for (auto sc8 = nv.symbol.getParentScope(); sc8;
                                  sc8 = sc8->asSymbol().getParentScope()) {
                                 auto k8 = sc8->asSymbol().kind;
                                 if (k8 == SymbolKind::ClassType)
                                     return true;
                                 if (k8 == SymbolKind::Package ||
                                     k8 == SymbolKind::InstanceBody ||
                                     k8 == SymbolKind::CompilationUnit)
                                     return false;
                             }
                             return false;
                         }()) {
                    // no actual of any kind
                }
                // § enumNoBind13 — two further contexts in which Surelog
                // resolves an enum-constant NAME to nothing at all.  Both are
                // byte-identical on purpose-built pairs in BOTH views
                // (r10uvm12repro/t13, r10uvm13repro/t14).
                //
                // (a) IN-CLASS METHOD BODY, at EVERY position.  The arm at
                //     the head of this chain already covers the plain ones,
                //     but neither carve-out that suspends classMethodNoBind
                //     extends to enum constants: not StmtEmit's if/case
                //     CONDITION toggle and not § classArgBind12's USER-call
                //     ARGUMENT depth.  t14 measures all four in one method —
                //     `if (m == PE1)`, `sink(PE1)`, `if (r == KE1)` and
                //     `sink(KE1)` are bare in golden while the io_decl and
                //     local-var refs beside them bind.  Package enum and the
                //     class's OWN enum behave alike, so the gate is the
                //     stable curSubClassScope9/curSubOob9 pair (LAW C's half,
                //     which a condition cannot toggle off) rather than
                //     classMethodNoBind.  An OUT-OF-BODY method is excluded:
                //     it is compiled in the home package's scope and binds a
                //     PACKAGE enum there (t13 `k::oob`'s `r = PE1`), with the
                //     class-scope half already handled by the arm above.
                //
                // (b) IMPORT-CLONE BODY.  A package that wildcard-imports
                //     another carries a CLONE of that package's whole listing
                //     (§ collectPkgTfListing).  Surelog compiles the clone
                //     bodies without the home package's symbol table, so no
                //     enum name in one resolves: t13's `p2::pkgf` (`pv = PE1`)
                //     and `p2::k::oob` (`r = PE1`) are bare, while `p2::q` —
                //     p2's OWN function reading the SAME imported PE1 — binds
                //     the enum_const, which is why the discriminator is the
                //     clone and not the enum's home package.  SeqDriver
                //     measures 1005 of its 1327 over-binds in adpcm_pkg's
                //     clone of uvm_pkg, split evenly over the def and elab
                //     package views.  A WRITTEN qualification is unaffected:
                //     `p1::PE1` folds to a constant inside the clone exactly
                //     as it does at home (that arm returns long before here).
                else if (nv.symbol.kind == SymbolKind::EnumValue &&
                         ((curSubClassScope9 && !curSubOob9) ||
                          pkgImportCloneEmit)) {
                    // no actual of any kind
                }
                // § genCaEnumConstNoBind21 MEASURED NEGATIVE — gating THIS
                // arm on `inGenScopeCaRhs` too was built and REVERTED in gate
                // round 1: u2r hier_path (`(csr_pmp_cfg_i[r].mode ==
                // PMP_MODE_TOR) ? ...` in g_addr_exp1) and
                // MultirangesStartNotFromZero both went CMP_EQUAL ->
                // CMP_NOTEQUAL, and golden BINDS the enum_const in both.  The
                // law lives in the § suppressRefActual arm alone: a gen-scope
                // CA RHS silences its enum read only when the whole RHS is
                // already in suppress mode (no bindable ref), which is
                // exactly what separates qh21.sv's rows from these two.
                else if (auto eit = enumConstMap.find(&nv.symbol); eit != enumConstMap.end())
                    ref->Actual_group(eit->second);
                else if (auto uit = unitParamMap.find(&nv.symbol);
                         uit != unitParamMap.end())
                    // $unit params bind the design-level parameter.
                    ref->Actual_group(uit->second);

                else if (nv.symbol.kind == SymbolKind::EnumValue)
                    // Anonymous-enum const built later in the deferred pass.
                    pendingEnumRefs.push_back({ref, &nv.symbol});
                else if (funcRetRefs && &nv.symbol == funcRetSym) {
                    funcRetRefs->push_back(ref);
                    // The function's RETURN NAME obeys the same "a whole ref
                    // re-points at the block's first select of the same
                    // variable" law every other variable does — Surelog's
                    // scope map holds one object per name and the bare refs
                    // bind whatever it holds at the end of the body.
                    // Purpose-built goldens /tmp/r10yoo_p{k,l,m}, functions
                    // f1/f2/f3/g1/g2: with `one_hot16[binary] = 1'b1` in the
                    // body EVERY bare `one_hot16` ref (before it, after it,
                    // LHS or RHS) binds that bit_select; with no select at all
                    // they bind the return logic_var; two selects bind the
                    // FIRST; and a select on a LOCAL variable leaves the
                    // return name alone (openmsp430 one_hot16/one_hot8).
                    if (selTrackActive) {
                        selWholeRefs.push_back(
                            {ref, &nv.symbol, selScopeChain()});
                        if (inLhs)
                            selWholeWrittenVars.insert(&nv.symbol);
                    }
                }
                else if (implicitNetModule &&
                         (nv.symbol.kind == SymbolKind::Iterator ||
                          (nv.symbol.kind == SymbolKind::Parameter &&
                           nv.symbol.getParentScope() &&
                           (nv.symbol.getParentScope()->asSymbol().kind ==
                                SymbolKind::StatementBlock ||
                            isTaskScopeParam9(nv.symbol))))) {
                    // Surelog can't resolve block-scoped localparams, nor a
                    // foreach loop variable (its declaration is implicit),
                    // nor a TASK-scope parameter (it is a body statement, not
                    // a scope member -- see tfBodyPa9): refs bind an implicit
                    // module wire minted at the first reference.
                    auto& inet = implicitNetMap[&nv.symbol];
                    if (!inet) {
                        inet = s.MakeLogic_net();
                        inet->VpiName(nv.symbol.name);
                        inet->VpiFullName(implicitNetPrefix + "." +
                                          std::string(nv.symbol.name));
                        inet->VpiParent(implicitNetModule);
                        inet->VpiNetType(1);
                        setLoc(inet, expr.sourceRange);
                        auto* nets = implicitNetModule->Nets();
                        if (!nets) {
                            nets = s.MakeNetVec();
                            implicitNetModule->Nets(nets);
                        }
                        nets->push_back(inet);
                    }
                    ref->Actual_group(inet);
                }
                // ...but a PACKAGE-scope subroutine has no module to hang that
                // implicit wire on, and there Surelog binds the foreach LOOP
                // VARIABLE OBJECT itself.  Narrow on purpose (repro q3, one
                // `foreach (a[i]) s = s + a[i] + i` compiled four ways): the
                // ELABORATED package listing binds its int_var, while the
                // un-elaborated listing — where the loop variable is an
                // unresolved ref_var — binds nothing, a class method binds
                // nothing (classMethodNoBind already preempts this arm), and
                // a module body keeps the implicit-wire arm above.  Only the
                // resolved loop-variable arm registers an object, so the
                // un-elaborated views find nothing here.
                else if (nv.symbol.kind == SymbolKind::Iterator) {
                    if (auto lvi9 = foreachLoopVarObjs9.find(&nv.symbol);
                        lvi9 != foreachLoopVarObjs9.end())
                        ref->Actual_group(lvi9->second);
                }
            }
            // ...and a PACKAGE-level variable of the package being emitted is
            // visible to every body inside it (svunit_pkg::svunit_version
            // read from svunit_testrunner::report).
            if (!ref->Actual_group() && nv.symbol.kind == SymbolKind::Variable)
                if (auto pv9 = pkgViewVarObjs9.find(&nv.symbol);
                    pv9 != pkgViewVarObjs9.end())
                    ref->Actual_group(pv9->second);
            // An OUT-OF-BODY class method is compiled in the home PACKAGE's
            // scope, where the class's own properties are invisible: Surelog
            // leaves the reference unbound and a module that HOISTS the
            // method (see emitImportArtifacts) binds it to a module net of
            // the same name -- minting an implicit wire at this FIRST
            // reference when the module declares none. Record in emission
            // order; that IS the mint order (ApbSlave success@78:17
            // error_count@91:5 running@150:3 test_count@151:3).
            if (inClassBodyEmit && !ref->Actual_group()) {
                auto* csc9 = nv.symbol.getParentScope();
                if (csc9 && csc9->asSymbol().kind == SymbolKind::ClassType) {
                    const Symbol* hp9 = nullptr;
                    if (auto* ps9 = csc9->asSymbol().getParentScope();
                        ps9 && ps9->asSymbol().kind == SymbolKind::Package)
                        hp9 = &ps9->asSymbol();
                    classPropRefs.push_back({ref, std::string(nv.symbol.name),
                                             expr.sourceRange, hp9});
                }
            }
            ref->VpiParent(parent);
            if (rawText(SourceRange(expr.sourceRange.start(), expr.sourceRange.start() + 1)) ==
                "\\")
                setLoc(ref, nameSpan(expr.sourceRange.start(), nv.symbol.name));
            else
                setLoc(ref, expr.sourceRange);
            return ref;
        }
        case ExpressionKind::UnaryOp: {
            auto& ue = expr.as<UnaryExpression>();
            int32_t opType = mapUnaryOp(ue.op);
            if (!opType) {
                noteUnsupported("unary op: " + std::string(toString(ue.op)));
                return nullptr;
            }
            // Surelog cannot compile an ATTRIBUTE on an inc/dec operator
            // (asgn_expr_sv): a POSTFIX attributed op (y (* foo *) ++)
            // collapses the WHOLE expression to an unsupported_expr anchored
            // at the operand token; a PREFIX attributed op (++ (* foo *) z)
            // keeps the operation but its OPERAND becomes the
            // unsupported_expr. Payload: the raw source LINE.
            {
                bool attrPost = false, attrPre = false;
                if (expr.syntax) {
                    if ((ue.op == UnaryOperator::Postincrement ||
                         ue.op == UnaryOperator::Postdecrement) &&
                        syntax::PostfixUnaryExpressionSyntax::isKind(
                            expr.syntax->kind))
                        attrPost = !expr.syntax
                                        ->as<syntax::PostfixUnaryExpressionSyntax>()
                                        .attributes.empty();
                    else if ((ue.op == UnaryOperator::Preincrement ||
                              ue.op == UnaryOperator::Predecrement) &&
                             syntax::PrefixUnaryExpressionSyntax::isKind(
                                 expr.syntax->kind))
                        attrPre = !expr.syntax
                                       ->as<syntax::PrefixUnaryExpressionSyntax>()
                                       .attributes.empty();
                }
                if (attrPost || attrPre) {
                    auto mkUnsup = [&](UHDM::BaseClass* par) {
                        auto* ux = s.MakeUnsupported_expr();
                        ux->VpiParent(par);
                        setLoc(ux, ue.operand().sourceRange);
                        // The raw source line holding the statement,
                        // whitespace included, newline excluded.
                        auto text = sm->getSourceText(
                            ue.operand().sourceRange.start().buffer());
                        size_t off = ue.operand().sourceRange.start().offset();
                        size_t ls = off;
                        while (ls > 0 && text[ls - 1] != '\n')
                            ls--;
                        size_t le = off;
                        while (le < text.size() && text[le] != '\n' &&
                               text[le] != '\r')
                            le++;
                        ux->VpiValue("STRING:" +
                                     std::string(text.substr(ls, le - ls)));
                        return ux;
                    };
                    if (attrPost)
                        return mkUnsup(parent);
                    auto* op0 = s.MakeOperation();
                    op0->VpiOpType(opType);
                    op0->VpiParent(parent);
                    setLoc(op0, expr.sourceRange);
                    auto* opnds0 = s.MakeAnyVec();
                    opnds0->push_back(mkUnsup(op0));
                    op0->Operands(opnds0);
                    return op0;
                }
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opType);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            // A unary op DIRECTLY under a sys_func_call arg anchors at the
            // OPERATOR token only (BitsCallOnExpression's $bits(~dr_q)).
            if (parent && parent->UhdmType() == UHDM::uhdmsys_func_call)
                op->VpiEndColumnNo(op->VpiColumnNo() + 1);
            auto* operands = s.MakeAnyVec();
            // Def-view param inits, cont-assigns AND process bodies leave a
            // DIRECT-literal unary operand unparented (~(15), -1, a = -4);
            // binary operands and nested expressions (~A[3]) keep the
            // normal rules.
            bool savedS = suppressConstParent, savedF = forceConstParent;
            // A unary op that is itself a CALL ARGUMENT (f_int(-1), $bits(~x))
            // leaves its literal operand unparented in BOTH views: Surelog
            // builds the operand with compileConst (no VpiParent) and the arg
            // is never re-parented by a clone.
            bool callArgUnary =
                parent && (parent->UhdmType() == UHDM::uhdmfunc_call ||
                           parent->UhdmType() == UHDM::uhdmsys_func_call);
            // A TASK/FUNCTION BODY is compiled once and never deep-cloned, so
            // its unary literal operands keep compileConst's null parent too
            // (func_tern_hint's `? -1 :`).
            // A REAL literal operand behaves like the integer/string cases:
            // Surelog's compileConst leaves a unary real-literal operand
            // unparented in the def/non-cloned view too (isLiteralExpr omits
            // RealLiteral, so add it here). realexpr's `-1.17`.
            bool unaryLitOperand =
                isLiteralExpr(ue.operand()) ||
                stripImplicitConv(ue.operand()).kind ==
                    ExpressionKind::RealLiteral;
            if ((paramInitDef || inProcessEmit || inGenScopeProc ||
                 defGenProcessEmit || inParamInit || callArgUnary ||
                 currentTf) &&
                unaryLitOperand) {
                suppressConstParent = true;
                forceConstParent = false;
            }
            if (auto* e = emitExpr(ue.operand(), op, prefix, netMap))
                operands->push_back(e);
            suppressConstParent = savedS;
            forceConstParent = savedF;
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::BinaryOp: {
            auto& be = expr.as<BinaryExpression>();
            int32_t opType = mapBinaryOp(be.op);
            if (!opType) {
                noteUnsupported("binary op: " + std::string(toString(be.op)));
                return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opType);
            op->VpiParent(parent);
            setLocCompact(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* l = emitExpr(be.left(), op, prefix, netMap))
                operands->push_back(l);
            if (auto* r = emitExpr(be.right(), op, prefix, netMap))
                operands->push_back(r);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::IntegerLiteral: {
            auto& il = expr.as<IntegerLiteral>();
            auto* c = s.MakeConstant();
            std::string raw = rawTextLit(expr);
            // Spaced based literals (8'd 3) re-lex compactly; the span
            // shrinks by the removed whitespace.
            size_t spc = basedLiteralSpaceCount(raw);
            if (spc) {
                std::string comp;
                comp.reserve(raw.size());
                for (size_t i = 0; i < raw.size(); i++) {
                    comp += raw[i];
                    if (raw[i] != '\'')
                        continue;
                    size_t j = i + 1;
                    if (j < raw.size() && (raw[j] == 's' || raw[j] == 'S'))
                        comp += raw[j++];
                    if (j < raw.size()) {
                        char b = (char)tolower(raw[j]);
                        if (b == 'd' || b == 'h' || b == 'b' || b == 'o') {
                            comp += raw[j++];
                            while (j < raw.size() &&
                                   (raw[j] == ' ' || raw[j] == '\t'))
                                j++;
                        }
                    }
                    i = j - 1;
                }
                raw = comp;
            }
            // Digit-separator underscores (4'b001x, xxxx_xxxx) are removed in
            // both the decompile and the value (Surelog quirk).
            if (raw.find('\'') != std::string::npos)
                raw.erase(std::remove(raw.begin(), raw.end(), '_'), raw.end());
            c->VpiDecompile(raw);
            c->VpiSize((int32_t)expr.type->getBitWidth());
            if (spc)
                setLoc(c, SourceRange(expr.sourceRange.start(),
                                      expr.sourceRange.end() - spc));
            else
                setLoc(c, expr.sourceRange);
            // Surelog parents constants only as operation operands and
            // bit_select indices (not assignment sides or select ranges);
            // re-elaborated contexts also parent part_select bounds.
            if (forceConstParent ||
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select ||
                  parent->UhdmType() == UHDM::uhdmcase_item ||
                  parent->UhdmType() == UHDM::uhdmimmediate_assert ||
                  ((reemitting || genCaLhsReelab) &&
                   parent->UhdmType() == UHDM::uhdmpart_select))))
                c->VpiParent(parent);

            auto tick = raw.find('\'');
            if (tick == std::string::npos) {
                // Bare decimal literals: Surelog encodes as 64-bit UINT —
                // UNLESS the digits do not fit 64 bits.  compileConst's
                // `largeInt` (more than 20 digits, or exactly 20 that
                // overflow uint64) routes them through the BASED-literal
                // arm with the default 'd base instead: vpiDecConst, size
                // -1, source text verbatim, no folding
                // (LargeConst 147573952589676412928 / 2^64).
                std::string dg9 = raw;
                dg9.erase(std::remove(dg9.begin(), dg9.end(), '_'), dg9.end());
                bool large9 = dg9.size() > 20;
                if (!large9 && dg9.size() == 20) {
                    errno = 0;
                    char* endp9 = nullptr;
                    strtoull(dg9.c_str(), &endp9, 10);
                    large9 = errno == ERANGE || (endp9 && *endp9 != '\0');
                }
                if (large9) {
                    c->VpiSize(-1);
                    c->VpiValue("DEC:" + dg9);
                    c->VpiConstType(vpiDecConst);
                }
                else {
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + raw);
                    c->VpiConstType(vpiUIntConst);
                }
            }
            else {
                // Unsized based literals: -1, EXCEPT the four forms Surelog's
                // grammar gives dedicated tokens to.  `CompileExpression.cpp`
                // handles `slIntConst` generically (size = the digits before
                // the tick, or -1 when there are none), but `'b0 'B0 'b1 'B1`
                // never reach it: paNumber_Tickb0/Tickb1 (and their Scalar_
                // twins) are separate parse nodes that hard-code VpiSize(0)
                // and a normalised lowercase decompile.  `'0 '1 'x 'z` have
                // their own tokens too and keep -1 (handled in the
                // UnbasedUnsizedIntegerLiteral case).  This is a grammar rule,
                // not a context rule -- it fires in every position, which is
                // why the earlier bare-continuous-assign guess also worked:
                // its literal happened to be `'b0`.  (BasicOh: `<= 'b0` is 0
                // while the neighbouring `<= 'd0` is -1.)
                if (tick == 0) {
                    bool tickBinDigit =
                        raw.size() == 3 && (raw[1] == 'b' || raw[1] == 'B') &&
                        (raw[2] == '0' || raw[2] == '1');
                    if (tickBinDigit)
                        c->VpiDecompile(std::string("'b") + raw[2]);
                    c->VpiSize(tickBinDigit ? 0 : -1);
                }
                size_t basePos = tick + 1;
                if (basePos < raw.size() && (raw[basePos] == 's' || raw[basePos] == 'S'))
                    basePos++;
                char base = basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
                std::string digits = raw.substr(basePos + 1);
                // Surelog quirk: a 1-bit 'x' value (1'bx) formats uppercase in
                // both the decompile and the value; 1-bit 'z' and multi-bit
                // x/z stay lowercase.
                if (expr.type->getBitWidth() == 1 && digits.size() == 1 &&
                    (digits[0] == 'x' || digits[0] == 'X')) {
                    digits = "X";
                    std::string dec = raw;
                    dec.back() = 'X';
                    c->VpiDecompile(dec);
                }
                switch (base) {
                    case 'b':
                        c->VpiValue("BIN:" + digits);
                        c->VpiConstType(vpiBinaryConst);
                        break;
                    case 'h':
                        c->VpiValue("HEX:" + digits);
                        c->VpiConstType(vpiHexConst);
                        break;
                    case 'o':
                        c->VpiValue("OCT:" + digits);
                        c->VpiConstType(vpiOctConst);
                        break;
                    default:
                        c->VpiValue("DEC:" + digits);
                        c->VpiConstType(vpiDecConst);
                        break;
                }
                // A signed based literal (1'sb1) carries an int_typespec ref
                // in the weaklyReferenced tail. When the literal is the WHOLE
                // RHS of a continuous assignment, Surelog emits a PLAIN
                // int_typespec (no vpiSigned) parented to its ref_typespec;
                // in expression-operand contexts it stays signed and parentless.
                if (tick + 1 < raw.size() &&
                    (raw[tick + 1] == 's' || raw[tick + 1] == 'S')) {
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiParent(c);
                    auto* its = s.MakeInt_typespec();
                    // A signed literal coerced to an UNSIGNED continuous-assign
                    // target (assign w = 1'sb1; w a plain wire) yields a PLAIN
                    // int_typespec parented to its ref_typespec (Surelog). In
                    // every other context (expression operands, signed targets)
                    // the typespec stays signed and parentless.
                    // Only a BINARY-based literal loses it: clearing vpiSigned
                    // is `adjustSize`'s vpiBinaryConst arm (CompileHelper.cpp
                    // 4013, `if (!signedLhs) itps->VpiSigned(false)`), and a
                    // 'sd / 'sh / 'so literal takes the plain size branch
                    // instead, keeping its signed typespec (LargeConst's
                    // `assign b = 'sd147573952589676412928`).
                    bool unsignedContAssign =
                        parent &&
                        parent->UhdmType() == UHDM::uhdmcont_assign &&
                        implicitConvTargetSigned == 0 && base == 'b';
                    if (unsignedContAssign)
                        its->VpiParent(rt);
                    else
                        its->VpiSigned(true);
                    rt->Actual_typespec(its);
                    c->Typespec(rt);
                }
            }
            (void)il;
            return c;
        }
        case ExpressionKind::RealLiteral: {
            auto& rl = expr.as<RealLiteral>();
            auto* c = s.MakeConstant();
            c->VpiDecompile(rawText(expr.sourceRange));
            c->VpiSize(64);
            char buf[64];
            snprintf(buf, sizeof(buf), "%f", rl.getValue());
            c->VpiValue(std::string("REAL:") + buf);
            // A real literal in an ELAB PARAM INIT decompiles %f (the
            // param-fold form, realexpr); the def view and expression
            // literals keep the source text.
            if (inParamInit && !paramInitDef)
                c->VpiDecompile(buf);
            c->VpiConstType(vpiRealConst);
            setLoc(c, expr.sourceRange);
            if (forceConstParent ||
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select)))
                c->VpiParent(parent);
            return c;
        }
        // § timeLitUintConst — a TIME literal (`5ns`) is an UNSIGNED constant,
        // never a real one: Surelog reduces it with the fixed unit table in
        // § srlgTimeLitVal and stores UINT / vpiUIntConst / vpiSize 64 with NO
        // vpiDecompile at all (CompileExpression.cpp paTime_literal sets only
        // those three).  Location is the literal's own span.  Before this the
        // kind was noteUnsupported'd, so every time literal in the corpus
        // emitted NOTHING (InterfaceModPort's `parameter setup_time = 5ns`:
        // golden had a valued param_assign Rhs constant, we had no Rhs).
        // The GATE is the expression kind alone — there is no narrower one to
        // find here, because the previous behaviour was "emit nothing", not
        // "emit something else".
        case ExpressionKind::TimeLiteral: {
            auto* c = s.MakeConstant();
            c->VpiSize(64);
            c->VpiValue("UINT:" + std::to_string(
                                      srlgTimeLitVal(rawText(expr.sourceRange))));
            c->VpiConstType(vpiUIntConst);
            setLoc(c, expr.sourceRange);
            if (forceConstParent ||
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select)))
                c->VpiParent(parent);
            return c;
        }
        // `null` (a class/chandle handle literal): Surelog's vpiNullConst,
        // carrying the same UINT:0 / vpiSize 64 / vpiDecompile "0" payload
        // every unsized integral constant of its does — the CONST TYPE is the
        // only thing that says "null" (uvm_object::create's `return null;`,
        // which emitted no vpiCondition at all before this).
        case ExpressionKind::NullLiteral: {
            auto* c = s.MakeConstant();
            c->VpiDecompile("0");
            c->VpiSize(64);
            c->VpiValue("UINT:0");
            c->VpiConstType(vpiNullConst);
            setLoc(c, expr.sourceRange);
            if (forceConstParent ||
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select)))
                c->VpiParent(parent);
            return c;
        }
        case ExpressionKind::StringLiteral: {
            auto& sl = expr.as<StringLiteral>();
            (void)sl;
            auto* c = s.MakeConstant();
            std::string raw = rawText(expr.sourceRange);
            // Surelog stores the RAW source characters (escapes like \n stay
            // as backslash+n), not the interpreted value; size follows suit.
            std::string inner = raw;
            // A MACRO-QUOTED literal (`"_NAME_`" in svunit's SVTEST) has no
            // quoted source text of its own: the range maps back into the
            // macro BODY, so rawText yields the unexpanded definition line.
            // slang has already done the substitution — take its raw value
            // and re-quote. Surelog spans the EXPANDED text from the same
            // start column.
            bool macroQuoted9 =
                inner.size() < 2 || inner.front() != '"' || inner.back() != '"';
            if (macroQuoted9) {
                inner = std::string(sl.getRawValue());
                if (inner.size() >= 2 && inner.front() == '"' &&
                    inner.back() == '"')
                    inner = inner.substr(1, inner.size() - 2);
                raw = "\"" + inner + "\"";
            }
            else
                inner = inner.substr(1, inner.size() - 2);
            c->VpiDecompile(raw);
            c->VpiSize((int32_t)(inner.size() * 8));
            c->VpiValue("STRING:" + inner);
            c->VpiConstType(vpiStringConst);
            setLoc(c, expr.sourceRange);
            if (macroQuoted9)
                setLoc(c, SourceRange(expr.sourceRange.start(),
                                      expr.sourceRange.start() +
                                          (inner.size() + 2)));
            // Surelog's end column counts each backslash DOUBLED-ESCAPED
            // (+2 per source backslash) — ASSIGNMENT Rhs only
            // (StringWithBackslash); sys-call args keep the source span
            // (display_lm).
            if (parent && parent->UhdmType() == UHDM::uhdmassignment)
                if (auto nbs9 = std::count(inner.begin(), inner.end(), '\\'))
                    c->VpiEndColumnNo(c->VpiEndColumnNo() +
                                      (int32_t)nbs9 * 2);
            if (forceConstParent ||
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select ||
                  parent->UhdmType() == UHDM::uhdmcase_item)))
                c->VpiParent(parent);
            return c;
        }
        case ExpressionKind::Conversion: {
            auto& conv = expr.as<ConversionExpression>();
            if (conv.isImplicit())
                return emitExpr(conv.operand(), parent, prefix, netMap);
            // Nested casts (int'($clog2(X)'(X))) lose the INNER conversion's
            // syntax; the outer emission passes it down via castSynOverride.
            const syntax::SyntaxNode* effCastSyn = expr.syntax;
            if ((!effCastSyn ||
                 effCastSyn->kind != syntax::SyntaxKind::CastExpression) &&
                castSynOverride)
                effCastSyn = castSynOverride;
            castSynOverride = nullptr;
            // A COMPILER-INSERTED string conversion of a string literal (the
            // implicit string context of {NAME, "efgh"}) carries no cast
            // syntax — Surelog emits the bare string constant, no cast op.
            if (expr.type && expr.type->isString() &&
                stripImplicitConv(conv.operand()).kind == ExpressionKind::StringLiteral &&
                (!effCastSyn ||
                 effCastSyn->kind != syntax::SyntaxKind::CastExpression))
                return emitExpr(stripImplicitConv(conv.operand()), parent, prefix,
                                netMap);
            // A cast around a streaming concat is dropped (Surelog emits the
            // stream operation directly).
            if (stripImplicitConv(conv.operand()).kind == ExpressionKind::Streaming)
                return emitExpr(stripImplicitConv(conv.operand()), parent, prefix,
                                netMap);
            // Explicit cast: operation(vpiCastOp) with a typespec ref.
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiCastOp);
            op->VpiParent(parent);
            // A cast whose operand is a SPACE-stripped based literal (96'(96'h
            // 4c52...)) shrinks its end column by the removed whitespace, just
            // as the inner literal's span does (Surelog re-lexes compactly).
            {
                SourceRange opr9 = expr.sourceRange;
                if (size_t sp9 = basedLiteralSpaceCount(rawText(opr9)))
                    opr9 = SourceRange(opr9.start(), opr9.end() - sp9);
                setLoc(op, opr9);
            }
            // An INNER signed'(x)/unsigned'(x) under a size cast is merged
            // into the conversion by slang — re-materialize it as a
            // $signed/$unsigned sys_func_call operand (static_cast_simple).
            auto wrapSignCast9 = [&](UHDM::any* e0) -> UHDM::any* {
                if (!e0 || e0->UhdmType() == UHDM::uhdmsys_func_call)
                    return e0;
                if (!effCastSyn ||
                    effCastSyn->kind != syntax::SyntaxKind::CastExpression)
                    return e0;
                auto& ce0 = effCastSyn->as<syntax::CastExpressionSyntax>();
                const syntax::SyntaxNode* r0 = ce0.right;
                while (r0 &&
                       r0->kind == syntax::SyntaxKind::ParenthesizedExpression)
                    r0 = r0->as<syntax::ParenthesizedExpressionSyntax>()
                             .expression;
                if (!r0 ||
                    r0->kind != syntax::SyntaxKind::SignedCastExpression)
                    return e0;
                auto& scs0 = r0->as<syntax::SignedCastExpressionSyntax>();
                auto* sc0 = s.MakeSys_func_call();
                sc0->VpiName("$" + std::string(scs0.signing.valueText()));
                sc0->VpiParent(op);
                setLoc(sc0, r0->sourceRange());
                // If the syntax-less inner conversion emitted a generic
                // cast op, unwrap it — the call's argument is the bare
                // operand (Surelog).
                UHDM::any* arg0 = e0;
                if (e0->UhdmType() == UHDM::uhdmoperation &&
                    ((UHDM::operation*)e0)->VpiOpType() == vpiCastOp &&
                    ((UHDM::operation*)e0)->Operands() &&
                    ((UHDM::operation*)e0)->Operands()->size() == 1)
                    arg0 = (*((UHDM::operation*)e0)->Operands())[0];
                auto* args0 = s.MakeAnyVec();
                ((UHDM::any*)arg0)->VpiParent(sc0);
                args0->push_back(arg0);
                sc0->Tf_call_args(args0);
                return (UHDM::any*)sc0;
            };
            UHDM::typespec* cts = nullptr;
            // Size casts ("4'(x)") carry an integer_typespec at the size
            // literal; type casts use the target type's typespec.
            if (effCastSyn && effCastSyn->kind == syntax::SyntaxKind::SignedCastExpression) {
                // signed'(x)/unsigned'(x) -> a $signed/$unsigned
                // sys_func_call wrapping the operand (static_cast_simple).
                auto& scs9 = effCastSyn->as<syntax::SignedCastExpressionSyntax>();
                auto* sc9 = s.MakeSys_func_call();
                std::string kw9(scs9.signing.valueText());
                sc9->VpiName("$" + kw9);
                sc9->VpiParent(parent);
                setLoc(sc9, effCastSyn->sourceRange());
                // Skip the syntax-less reinterpret conversion slang nests
                // under the sign cast.
                const Expression* inner9 = &conv.operand();
                while (inner9->kind == ExpressionKind::Conversion &&
                       (inner9->as<ConversionExpression>().isImplicit() ||
                        !inner9->syntax || inner9->syntax == effCastSyn ||
                        inner9->syntax->kind ==
                            syntax::SyntaxKind::SignedCastExpression))
                    inner9 = &inner9->as<ConversionExpression>().operand();
                if (auto* a9 = emitExpr(*inner9, sc9, prefix, netMap)) {
                    auto* args9 = s.MakeAnyVec();
                    args9->push_back(a9);
                    sc9->Tf_call_args(args9);
                }
                return sc9;
            }
            bool deferredCast = false;
            if (effCastSyn && effCastSyn->kind == syntax::SyntaxKind::CastExpression) {
                auto& cesyn = effCastSyn->as<syntax::CastExpressionSyntax>();
                // A DEF-view gen-block PROCEDURAL cast whose target is written
                // as a bare IDENTIFIER is UNRESOLVED: Surelog compiles the
                // generate body without instance context, so an imported
                // typedef name (`rggen_access'(0)` inside an `always_ff` in a
                // `generate if`) becomes an unsupported_typespec NAMED as
                // written, exactly like the def-view gen CONT-ASSIGN path
                // already emits (emitSyntaxExpr's CastExpression arm) and like
                // the sibling parameter-WIDTH rule below.  The elaborated view
                // still resolves to the real typespec.
                if (defGenProcessEmit &&
                    cesyn.left->kind == syntax::SyntaxKind::IdentifierName) {
                    auto lrU = cesyn.left->sourceRange();
                    auto* utsU = s.MakeUnsupported_typespec();
                    utsU->VpiName(std::string(rawText(lrU)));
                    setLoc(utsU, lrU);
                    cts = utsU;
                }
                if (cts) {
                    // Bound above; the shared ref_typespec wrap emits it.
                }
                else if (cesyn.left->kind == syntax::SyntaxKind::IntegerLiteralExpression) {
                    if (reemitting) {
                        // Created at the end of the write phase.
                        auto* rt0 = s.MakeRef_typespec();
                        rt0->VpiFullName(prefix);
                        rt0->VpiParent(op);
                        auto lr = cesyn.left->sourceRange();
                        pendingCastTs.push_back(
                            {rt0, sm->getLineNumber(lr.start()),
                             sm->getColumnNumber(lr.start()),
                             sm->getLineNumber(lr.end()), sm->getColumnNumber(lr.end()),
                             "INT:" + rawText(lr), nullptr, "", nullptr,
                             pkgScopeInst ? pkgScopeInst : importedInitPkgInst});
                        op->Typespec(rt0);
                        deferredCast = true;
                    }
                    else {
                        auto* its = s.MakeInteger_typespec();
                        setLoc(its, cesyn.left->sourceRange());
                        its->VpiValue("INT:" + rawText(cesyn.left->sourceRange()));
                        // A package-scope size cast's integer_typespec carries
                        // vpiInstance = the package (Surelog) — and so does a
                        // MODULE-view copy of an imported package param's init.
                        if (pkgScopeInst)
                            its->Instance(pkgScopeInst);
                        else if (importedInitPkgInst)
                            its->Instance(importedInitPkgInst);
                        cts = its;
                    }
                }
                else if (isTypeSyntaxKind(cesyn.left->kind)) {
                    // Type casts: re-emitted contexts defer the target-type
                    // typespec to the end of the write phase; otherwise fall
                    // through to the fallback below.
                    if (reemitting) {
                        auto* rt0 = s.MakeRef_typespec();
                        rt0->VpiFullName(prefix);
                        rt0->VpiParent(op);
                        auto lr = cesyn.left->sourceRange();
                        pendingCastTs.push_back({rt0, sm->getLineNumber(lr.start()),
                                                 sm->getColumnNumber(lr.start()),
                                                 sm->getLineNumber(lr.end()),
                                                 sm->getColumnNumber(lr.end()), "",
                                                 nullptr, prefix, expr.type});
                        op->Typespec(rt0);
                        deferredCast = true;
                    }
                }
                else if (expr.type && expr.type->kind == SymbolKind::TypeAlias &&
                         typedefTs.count(expr.type)) {
                    // A cast to a NAMED typedef (my_struct'(a)): the shared
                    // typedef typespec is the cast target. In a $UNIT
                    // function body, a VECTOR-typedef cast gets a FRESH
                    // clone with a Typedef_alias ref instead.
                    cts = typedefTs[expr.type];
                    if (cts->UhdmType() == UHDM::uhdmlogic_typespec) {
                        auto ps0 = currentSubSym ? currentSubSym->getParentScope()
                                                 : nullptr;
                        // A cast written inside a function of the typedef's OWN
                        // package (riscv_isa_i_pkg's `imm_i_f = imm_t'(...)`)
                        // mints the same fresh self-named clone: Surelog
                        // re-elaborates the cast target per (function, view)
                        // rather than sharing the package's typedef object.
                        bool homePkgSub0 = false;
                        if (ps0 && ps0->asSymbol().kind == SymbolKind::Package)
                            for (auto sc0 = expr.type->getParentScope(); sc0;
                                 sc0 = sc0->asSymbol().getParentScope())
                                if (sc0->asSymbol().kind ==
                                    SymbolKind::Package) {
                                    homePkgSub0 = sc0 == ps0;
                                    break;
                                }
                        // $UNIT function bodies AND module-scope cast sites
                        // both mint the fresh self-named clone (Surelog).
                        if (!currentSubSym || homePkgSub0 ||
                            (ps0 &&
                             ps0->asSymbol().kind == SymbolKind::CompilationUnit)) {
                            auto& ta2 = expr.type->as<TypeAliasType>();
                            const syntax::SyntaxNode* tSyn2 = nullptr;
                            if (auto asyn2 = ta2.getSyntax())
                                if (asyn2->kind ==
                                    syntax::SyntaxKind::TypedefDeclaration)
                                    tSyn2 = asyn2->as<
                                                    syntax::TypedefDeclarationSyntax>()
                                                .type;
                            // A $UNIT (file-level) typedef's cast clone FOLDS
                            // its bounds in every view — Surelog compiles the
                            // compilation unit before any module, so
                            // `typedef logic [`XLEN-2:0] t; ... t'(x)` reaches
                            // the cast site already reduced (Scr1SvTests
                            // type_scr1_csr_mcause_ec_v; purpose-built golden).
                            // A module-local or imported-package typedef keeps
                            // the symbolic tree.
                            bool homeUnit0 = false;
                            if (auto hs0 = expr.type->getParentScope())
                                homeUnit0 = hs0->asSymbol().kind ==
                                            SymbolKind::CompilationUnit;
                            bypassTypedefShare = true;
                            bool savedTf2 = tfContext;
                            // The home-package clone's bounds follow the VIEW:
                            // the def package's stay symbolic, the top
                            // package's fold (rp32 imm_t 32-1 vs 31).
                            tfContext =
                                homePkgSub0 ? !pkgTopEmit : !homeUnit0;
                            auto* cl2 = makeTypespec(ta2, tSyn2);
                            tfContext = savedTf2;
                            bypassTypedefShare = false;
                            cl2->VpiName(ta2.name);
                            if (homePkgSub0)
                                cl2->Instance(cts->Instance());
                            auto* art2 = s.MakeRef_typespec();
                            art2->VpiFullName(std::string(ta2.name));
                            art2->VpiParent(cl2);
                            art2->Actual_typespec(cts);
                            ((UHDM::logic_typespec*)cl2)->Typedef_alias(art2);
                            cts = cl2;
                        }
                    }
                    // A cast to a pkg UNION typedef (op32_t'(ins)) binds ONE
                    // FRESH union clone tree shared by all views' cast sites:
                    // threaded work@-scoped member refs, per-member struct
                    // clones, fresh folded vector twins and member enum
                    // clones (Surelog re-elaborates the cast target —
                    // jeras_union).
                    else if (!currentSubSym &&
                             cts->UhdmType() == UHDM::uhdmunion_typespec &&
                             expr.type->getCanonicalType().kind ==
                                 SymbolKind::PackedUnionType) {
                        if (auto cu9 = castUnionClone.find(expr.type);
                            cu9 != castUnionClone.end())
                            cts = cu9->second;
                        else {
                            auto& ta2 = expr.type->as<TypeAliasType>();
                            std::string unm(ta2.name);
                            for (auto sc9 = ta2.getParentScope(); sc9;
                                 sc9 = sc9->asSymbol().getParentScope())
                                if (sc9->asSymbol().kind ==
                                    SymbolKind::Package) {
                                    unm = std::string(sc9->asSymbol().name) +
                                          "::" + unm;
                                    break;
                                }
                            bool savedSCMRP9 = structCloneMemberRefParent;
                            structCloneMemberRefParent = true;
                            castAggCloneCtx = true;
                            auto* ucl = buildUnionTs(
                                expr.type->getCanonicalType()
                                    .as<PackedUnionType>(),
                                true, prefix + "." + unm, ".");
                            castAggCloneCtx = false;
                            structCloneMemberRefParent = savedSCMRP9;
                            ucl->VpiName(unm);
                            ucl->VpiLineNo(cts->VpiLineNo());
                            ucl->VpiColumnNo(cts->VpiColumnNo());
                            ucl->VpiEndLineNo(cts->VpiEndLineNo());
                            ucl->VpiEndColumnNo(cts->VpiEndColumnNo());
                            // The re-elaborated cast target belongs to the
                            // ELABORATED package family, not the def object
                            // it was cloned from (jeras_union op32_t'(ins)).
                            auto* hi9 = homePkgInstOf(ta2);
                            if (!hi9)
                                hi9 = (UHDM::instance*)cts->Instance();
                            stampCloneTreeInstance(ucl, hi9);
                            castUnionClone[expr.type] = ucl;
                            cts = ucl;
                        }
                    }
                    // A cast to a PACKED-ARRAY-of-struct typedef
                    // (my_struct_array'(a)) mints a FRESH clone in the elab
                    // pass: same name/span/Instance/ranges, but its own
                    // ELEMENT struct clone whose member refs nest through the
                    // array alias (work@top.my_struct_array.my_struct.x) —
                    // the shared module typedef object is left untouched
                    // (Surelog).
                    else if (reemitting &&
                             cts->UhdmType() ==
                                 UHDM::uhdmpacked_array_typespec) {
                        auto* oldPat = (UHDM::packed_array_typespec*)cts;
                        const Type* leaf9 = &expr.type->getCanonicalType();
                        const Type* named9 = nullptr;
                        while (leaf9->getCanonicalType().kind ==
                               SymbolKind::PackedArrayType) {
                            named9 = &leaf9->getCanonicalType()
                                          .as<PackedArrayType>()
                                          .elementType;
                            leaf9 = &named9->getCanonicalType();
                        }
                        if (named9 && named9->kind == SymbolKind::TypeAlias &&
                            leaf9->kind == SymbolKind::PackedStructType &&
                            oldPat->Elem_typespec() &&
                            oldPat->Elem_typespec()->Actual_typespec() &&
                            oldPat->Elem_typespec()
                                    ->Actual_typespec()
                                    ->UhdmType() == UHDM::uhdmstruct_typespec) {
                            auto* rt0 = s.MakeRef_typespec();
                            rt0->VpiFullName(prefix);
                            rt0->VpiParent(op);
                            pendingCastAggTs.push_back(
                                {rt0, oldPat, expr.type, prefix});
                            op->Typespec(rt0);
                            deferredCast = true;
                        }
                    }
                }
                // A PACKAGE-scope PARENTHESIZED parameter width
                // ((dev_addr_width_gp)'('h0_0000)) mints NO cast typespec at
                // all: Surelog reuses the referenced parameter's own
                // declaration int_typespec as the cast target — the sibling of
                // the module-scope paren-param rule below — and the
                // pkg-scope cast-typespec rule then stamps vpiInstance = the
                // package ON THAT SHARED OBJECT. The visible consequence is a
                // parameter whose typespec is instanced while every untouched
                // sibling's stays null (BlackBePipeInt bp_common_pkg
                // dev_addr_width_gp; uhdm-dump never prints vpiInstance, so
                // this is Compare-only). The shared ts also gains the module
                // rule's loc-less vpiExpr ref_obj bound back to the parameter.
                else if (pkgScopeInst && !pkgScopeParamTs.empty() &&
                         cesyn.left->kind ==
                             syntax::SyntaxKind::ParenthesizedExpression &&
                         [&] {
                             const syntax::ExpressionSyntax* in9 = cesyn.left;
                             while (in9->kind == syntax::SyntaxKind::
                                                     ParenthesizedExpression)
                                 in9 = in9->as<syntax::
                                                   ParenthesizedExpressionSyntax>()
                                           .expression;
                             if (in9->kind != syntax::SyntaxKind::IdentifierName)
                                 return false;
                             auto it9 = pkgScopeParamTs.find(std::string(
                                 in9->as<syntax::IdentifierNameSyntax>()
                                     .identifier.valueText()));
                             if (it9 == pkgScopeParamTs.end())
                                 return false;
                             cts = it9->second.first;
                             cts->Instance(pkgScopeInst);
                             if (cts->UhdmType() == UHDM::uhdmint_typespec &&
                                 !((UHDM::int_typespec*)cts)->Cast_to_expr()) {
                                 auto* pobj9 = it9->second.second;
                                 auto* r9 = s.MakeRef_obj();
                                 r9->VpiName(pobj9->VpiName());
                                 r9->VpiFullName(
                                     std::string(pobj9->VpiFullName()) + "." +
                                     std::string(pobj9->VpiName()));
                                 r9->VpiParent(cts);
                                 r9->Actual_group(pobj9);
                                 ((UHDM::int_typespec*)cts)->Cast_to_expr(r9);
                             }
                             return true;
                         }()) {
                    // cts bound in the predicate above.
                }
                else if (currentScope || castBindScope) {
                    // Non-literal cast sizes: integer_typespec carrying the
                    // freshly-bound size expression as vpiExpr (parented at
                    // the cast operation, name-only call spans). Parens
                    // anchor at the inner expression. Re-emitted contexts
                    // create the ts at the end of the write phase.
                    // A PACKAGE parameter's init has no currentScope of its
                    // own (emitParameters only sets one for typespec work), so
                    // castBindScope stands in — without it a package-scope
                    // `(A+B)'(x)` fell through to the catch-all logic_typespec
                    // (BlackBePipeInt bp_common_pkg host_base_addr_gp, the
                    // whole-design Compare's first unequal pair).
                    const Scope& bindSc9 =
                        currentScope ? *currentScope : *castBindScope;
                    const syntax::ExpressionSyntax* leftSyn = cesyn.left;
                    while (leftSyn->kind == syntax::SyntaxKind::ParenthesizedExpression)
                        leftSyn = leftSyn->as<syntax::ParenthesizedExpressionSyntax>()
                                      .expression;
                    ASTContext bctx(bindSc9, LookupLocation::max);
                    auto& sizeExpr = Expression::bind(*cesyn.left, bctx);
                    auto lr = leftSyn->sourceRange();
                    // DEF-view gen-block PROCEDURAL casts keep the size
                    // SYMBOLIC: an unfolded parameter width P'(x) becomes an
                    // unsupported_typespec named P at the cast-site token (no
                    // value) — Surelog can't resolve the type in the def view.
                    // cts is set here so the param-fold branches below (all
                    // gated on !cts) are skipped, and the shared ref_typespec
                    // wrap emits it.
                    if (defGenProcessEmit) {
                        auto* uts = s.MakeUnsupported_typespec();
                        uts->VpiName(std::string(rawText(lr)));
                        setLoc(uts, lr);
                        cts = uts;
                    }
                    // A cast sized by a $UNIT (compilation-unit) parameter is
                    // the same shape in EVERY view: Surelog's type compiler
                    // cannot resolve a file-scope parameter as a type, so it
                    // falls through to the catch-all and mints an
                    // unsupported_typespec NAMED after the parameter at the
                    // cast-site token — never the param's own int_typespec.
                    // The parameter keeps its ordinary declaration-site
                    // typespec (purpose-built golden: literal-init `ZB'(0)`
                    // and computed-init `CB'(a)` both take this shape;
                    // Scr1SvTests SCR1_CSR_MTVEC_BASE_ZERO_BITS'(0)).
                    if (!cts) {
                        auto& seU9 = stripImplicitConv(sizeExpr);
                        if (seU9.kind == ExpressionKind::NamedValue &&
                            seU9.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter)
                            if (auto* usc9 = seU9.as<NamedValueExpression>()
                                                 .symbol.getParentScope();
                                usc9 && usc9->asSymbol().kind ==
                                            SymbolKind::CompilationUnit) {
                                auto* uts9 = s.MakeUnsupported_typespec();
                                uts9->VpiName(std::string(rawText(lr)));
                                setLoc(uts9, lr);
                                cts = uts9;
                            }
                    }
                    // A BARE parameter width (XLEN'(x)) mints the named
                    // int_typespec in RE-EMITTED (elab) contexts too — same
                    // shape as the def view below, NOT a deferred
                    // integer_typespec + Expr (Surelog; rp32_r5p_mouse
                    // shf_val).
                    {
                        auto& seCore0 = stripImplicitConv(sizeExpr);
                        if (!cts && !defGenProcessEmit && reemitting &&
                            seCore0.kind == ExpressionKind::NamedValue &&
                            seCore0.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter &&
                            cesyn.left->kind ==
                                syntax::SyntaxKind::IdentifierName) {
                            auto& psym0 =
                                seCore0.as<NamedValueExpression>().symbol;
                            auto* its0 = s.MakeInt_typespec();
                            its0->VpiName(psym0.name);
                            // ...unless the parameter is one whose ONLY
                            // typespec IS the cast's (castSizeParamTs: a
                            // COMPUTED-init module parameter, so Surelog has
                            // no value to fold at definition compile).  Then
                            // the elaborated cast copies the shape the
                            // parameter itself took — anchored at the cast,
                            // value-less, carrying the vpiExpr ref_obj — the
                            // same "elab follows the def decision" rule
                            // patchParamTypespecs applies to the parameter.
                            // scr1_pipe_ifu SCR1_IFU_Q_FREE_H_W /
                            // SCR1_IFU_Q_FREE_W_W (`= $clog2(...)`, cast at
                            // 449:27): golden's 3 elaborated cont-assign
                            // copies carry Cast_to_expr, and int_typespec::
                            // Compare chases it, so the folded-value form
                            // below reports as `<null> vs ref_obj`.
                            auto cs9 = castSizeStampedTs.find(&psym0);
                            if (cs9 != castSizeStampedTs.end() &&
                                cs9->second->Cast_to_expr()) {
                                auto* dts9 = cs9->second;
                                its0->VpiFile(dts9->VpiFile());
                                its0->VpiLineNo(dts9->VpiLineNo());
                                its0->VpiColumnNo(dts9->VpiColumnNo());
                                its0->VpiEndLineNo(dts9->VpiEndLineNo());
                                its0->VpiEndColumnNo(dts9->VpiEndColumnNo());
                                auto* dr9 =
                                    (UHDM::ref_obj*)dts9->Cast_to_expr();
                                auto* r9 = s.MakeRef_obj();
                                r9->VpiName(dr9->VpiName());
                                r9->VpiFullName(dr9->VpiFullName());
                                r9->Actual_group(dr9->Actual_group());
                                r9->VpiParent(its0);
                                its0->Cast_to_expr(r9);
                            }
                            // § castTypedParamDeclTs — the stamp above only
                            // reaches a target that OWES its typespec to the
                            // cast (an UNTYPED localparam, castSizeParamTs).
                            // A target written WITH a type keyword already has
                            // a declaration int_typespec, and when its default
                            // cannot fold at definition compile
                            // (§ castTgtDefaultIsLiteral) the elaborated cast
                            // REUSES that object exactly as the def view does
                            // one arm below — UNNAMED, at the type-keyword
                            // span, carrying the same vpiExpr ref_obj (which
                            // keeps its DEF-scoped `work@<mod>.P.P` fullname in
                            // the elab view).  scr1_pipe_tdu `localparam int
                            // unsigned ALLTRIG_W = $clog2(ALLTRIG_NUM+1)` used
                            // as `ALLTRIG_W'(ALLTRIG_NUM)` at 322:56 is the
                            // measurement: golden int_typespec@77:12-24 +
                            // vpiExpr, ours a fresh `(ALLTRIG_W)`@77:25 UINT:2,
                            // and int_typespec::Compare reads both the name and
                            // the Cast_to_expr.  Its untyped sibling
                            // scr1_pipe_ifu SCR1_IFU_Q_FREE_H_W is the other
                            // half of the matrix and stays on the stamp arm.
                            // The def-ts lookup carries the § paramCastTsBySyntax
                            // fallback: `psym0` is the ELAB instance's symbol
                            // and coincides with the def body's only for the
                            // instance whose body slang shares.
                            else if (UHDM::int_typespec* dts0 = nullptr;
                                     [&] {
                                         auto psc0 = psym0.getParentScope();
                                         if (!psc0 ||
                                             psc0->asSymbol().kind !=
                                                 SymbolKind::InstanceBody ||
                                             castTgtDefaultIsLiteral(
                                                 psym0.as<ParameterSymbol>()))
                                             return false;
                                         auto dit0 = defMap.find(
                                             &psc0->asSymbol()
                                                  .as<InstanceBodySymbol>()
                                                  .getDefinition());
                                         if (dit0 == defMap.end())
                                             return false;
                                         UHDM::typespec* t0 = nullptr;
                                         if (auto pit0 =
                                                 dit0->second.paramTs.find(&psym0);
                                             pit0 != dit0->second.paramTs.end())
                                             t0 = pit0->second;
                                         else if (psym0.getSyntax())
                                             if (auto sit0 =
                                                     dit0->second.paramTsSyn.find(
                                                         psym0.getSyntax());
                                                 sit0 !=
                                                 dit0->second.paramTsSyn.end())
                                                 t0 = sit0->second;
                                         if (!t0 ||
                                             t0->UhdmType() !=
                                                 UHDM::uhdmint_typespec)
                                             return false;
                                         dts0 = (UHDM::int_typespec*)t0;
                                         return true;
                                     }()) {
                                its0->VpiName("");
                                its0->VpiFile(dts0->VpiFile());
                                its0->VpiLineNo(dts0->VpiLineNo());
                                its0->VpiColumnNo(dts0->VpiColumnNo());
                                its0->VpiEndLineNo(dts0->VpiEndLineNo());
                                its0->VpiEndColumnNo(dts0->VpiEndColumnNo());
                                auto* r0 = s.MakeRef_obj();
                                if (auto* dr0 =
                                        (UHDM::ref_obj*)dts0->Cast_to_expr()) {
                                    r0->VpiName(dr0->VpiName());
                                    r0->VpiFullName(dr0->VpiFullName());
                                    r0->Actual_group(dr0->Actual_group());
                                }
                                else {
                                    r0->VpiName(psym0.name);
                                    r0->VpiFullName(std::string(psym0.name) +
                                                    "." +
                                                    std::string(psym0.name));
                                }
                                r0->VpiParent(its0);
                                its0->Cast_to_expr(r0);
                            }
                            else {
                                setLoc(its0, SourceRange(psym0.location,
                                                         psym0.location));
                                auto& pv0 =
                                    psym0.as<ParameterSymbol>().getValue();
                                if (pv0.isInteger() &&
                                    !pv0.integer().hasUnknown())
                                    its0->VpiValue(
                                        "UINT:" +
                                        pv0.integer().toString(
                                            LiteralBase::Decimal, false));
                            }
                            // A PACKAGE-scope cast target carries vpiInstance
                            // = the package, like every other arm here
                            // (BlackBePipeInt dev_addr_width_gp, 12 golden
                            // copies of the named cast typespec, all stamped).
                            if (pkgScopeInst)
                                its0->Instance(pkgScopeInst);
                            else if (importedInitPkgInst)
                                its0->Instance(importedInitPkgInst);
                            cts = its0;
                        }
                    }
                    // § castQualPkgWidthElabBareTs27 (r10earl27) — A CAST WIDTH
                    // WRITTEN QUALIFIED (`pkg::P'(x)`) MINTS THE SAME BARE
                    // int_typespec IN THE ELABORATED VIEW AS IN THE DEF VIEW.
                    // The def arm two blocks below ("A PACKAGE-scoped parameter
                    // width mints a BARE int_typespec: no name, no loc, just
                    // the folded UINT value") was never reachable from a
                    // re-emitted context, because the `pendingCastTs` fallback
                    // right below returns first and defers an
                    // integer_typespec AT THE WRITTEN SPAN.  That was the
                    // PASS-26 EXIT FRONTIER: bis27 depth 7,
                    // tlul_adapter_host.sv:90:16 `a_size: top_pkg::TL_SZW'(
                    // WordSize)` inside `assign tl_o = '{...}` of the
                    // elaborated tl_adapter_host_i_ibex, LHS(golden) = a
                    // LOC-LESS int_typespec {UINT:2} / RHS(ours) = an
                    // integer_typespec at :90:16 (same UINT:2 value — the KIND
                    // is the whole difference, and typespec::Compare reads
                    // VpiType).
                    // THE GRID (qj27.sv — a child instance so both views
                    // exist, every cast operand a PORT so no cast folds away;
                    // LHS(golden) first, both views of each row):
                    //   pkg::TL_SZW' (int, computed init)   int_ts LOC-LESS
                    //   pkg::USZW'   (int unsigned, literal) int_ts LOC-LESS
                    //   TL_SZW'      (same param, UNQUAL)   int_ts @ the pkg
                    //                                       DECLARATION
                    //   MSZW'        (module localparam)    int_ts @ its decl
                    //   PSZW'        (module parameter)     int_ts @ its decl
                    //   2'           (literal width)        integer_ts @ the
                    //                                       WRITTEN SPAN
                    // and ours already agreed on every row but the two
                    // QUALIFIED ones, in the ELAB view only — the def view was
                    // byte-identical on all six.  So the discriminator is the
                    // WRITTEN QUALIFICATION, not the parameter's declared
                    // signedness and not its initializer's literalness; the
                    // struct-assignment-pattern context (the corpus shape) and
                    // a plain cont_assign measure identically.
                    // qi27.sv is the single-row reproduction of the corpus
                    // frontier; qh27.sv is the NEGATIVE witness that sent this
                    // pass to the elab view — it puts the same seven spellings
                    // in a TOP module, where the def view is all there is and
                    // every row already agreed.
                    if (!cts && !defGenProcessEmit && reemitting &&
                        cesyn.left->kind == syntax::SyntaxKind::ScopedName) {
                        auto& seQ27 = stripImplicitConv(sizeExpr);
                        if (seQ27.kind == ExpressionKind::NamedValue &&
                            seQ27.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter) {
                            auto& pq27 =
                                seQ27.as<NamedValueExpression>().symbol;
                            if (auto pc27 = pq27.getParentScope();
                                pc27 && pc27->asSymbol().kind ==
                                            SymbolKind::Package) {
                                auto* itq27 = s.MakeInt_typespec();
                                auto& pvq27 =
                                    pq27.as<ParameterSymbol>().getValue();
                                if (pvq27.isInteger() &&
                                    !pvq27.integer().hasUnknown())
                                    itq27->VpiValue(
                                        "UINT:" +
                                        pvq27.integer().toString(
                                            LiteralBase::Decimal, false));
                                cts = itq27;
                            }
                        }
                    }
                    if (!cts && !defGenProcessEmit && reemitting) {
                        auto* rt0 = s.MakeRef_typespec();
                        rt0->VpiFullName(prefix);
                        rt0->VpiParent(op);
                        pendingCastTs.push_back({rt0, sm->getLineNumber(lr.start()),
                                                 sm->getColumnNumber(lr.start()),
                                                 sm->getLineNumber(lr.end()),
                                                 sm->getColumnNumber(lr.end()), "",
                                                 &sizeExpr, prefix});
                        op->Typespec(rt0);
                        // Nested size casts (8'(4'(x))): the inner
                        // conversion lost its syntax — pass it down.
                        {
                            const Expression* c1p9 = &conv.operand();
                            while (c1p9->kind == ExpressionKind::Conversion &&
                                   c1p9->as<ConversionExpression>().isImplicit())
                                c1p9 = &c1p9->as<ConversionExpression>()
                                            .operand();
                            if (c1p9->kind == ExpressionKind::Conversion &&
                                !c1p9->as<ConversionExpression>().isImplicit() &&
                                (!c1p9->syntax ||
                                 c1p9->syntax->kind !=
                                     syntax::SyntaxKind::CastExpression)) {
                                const syntax::ExpressionSyntax* rs9 =
                                    effCastSyn
                                        ->as<syntax::CastExpressionSyntax>()
                                        .right->expression;
                                while (rs9 && rs9->kind ==
                                                  syntax::SyntaxKind::
                                                      ParenthesizedExpression)
                                    rs9 = rs9->as<syntax::
                                                      ParenthesizedExpressionSyntax>()
                                              .expression;
                                if (rs9 &&
                                    rs9->kind ==
                                        syntax::SyntaxKind::CastExpression)
                                    castSynOverride = rs9;
                            }
                        }
                        auto* operandsD = s.MakeAnyVec();
                        if (auto* e = emitExpr(conv.operand(), op, prefix, netMap))
                            operandsD->push_back(wrapSignCast9(e));
                        castSynOverride = nullptr;
                        op->Operands(operandsD);
                        return op;
                    }
                    // A BARE parameter width (P'(x)) mints a fresh NAMED
                    // int_typespec carrying the param's folded value, at a
                    // zero-width span on the param name token (per cast site).
                    // ...but only when the width is a DEF-COMPILE constant.
                    // The fresh typespec carries the folded value, so Surelog
                    // can only build it when the parameter's own initializer
                    // is a literal; a param-DEPENDENT width (`localparam W =
                    // NrDevices > 1 ? $clog2(NrDevices) : 1`) has no value at
                    // definition compile, and Surelog falls back to REUSING
                    // the parameter's own typespec with a vpiExpr ref_obj —
                    // the shape the parenthesized branch below builds.
                    // Measured on one source per row (param port vs
                    // localparam, plain always vs generate, literal vs
                    // param-dependent init): only the initializer's literalness
                    // moves it. AlwaysNoElab (dependent -> reuse) vs
                    // size_cast_param / rp32_r5p_* (`= 16` -> fresh).
                    // § castTgtDefaultIsLiteral — "the initializer" is the cast
                    // target's OWN DECLARED DEFAULT, not the value it ends up
                    // with: Surelog decides this at DEFINITION compile, where
                    // no instance override exists yet.  Reading slang's bound
                    // initializer instead reads the OVERRIDE and inverts the
                    // verdict for every instantiated module — Rggen's five
                    // `P'(x)` sites split exactly on the declared default
                    // (matrix in the paren-cast note below).
                    // ...and only for a width declared in THIS module body: a
                    // PACKAGE parameter keeps the fresh valued typespec even
                    // with a computed init (Kmac sha3_pkg::KeccakCountW =
                    // $clog2(KeccakEntries+1)), because package elaboration
                    // has already resolved it.
                    auto& seCore = stripImplicitConv(sizeExpr);
                    bool litWidthParam9 = true;
                    if (seCore.kind == ExpressionKind::NamedValue &&
                        seCore.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter) {
                        auto& wp9 = seCore.as<NamedValueExpression>()
                                        .symbol.as<ParameterSymbol>();
                        auto* wsc9 = wp9.getParentScope();
                        if (wsc9 &&
                            wsc9->asSymbol().kind == SymbolKind::InstanceBody)
                            litWidthParam9 = castTgtDefaultIsLiteral(wp9);
                    }
                    if (!cts && litWidthParam9 &&
                        seCore.kind == ExpressionKind::NamedValue &&
                        seCore.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter &&
                        cesyn.left->kind == syntax::SyntaxKind::IdentifierName) {
                        auto& psym = seCore.as<NamedValueExpression>().symbol;
                        auto* its = s.MakeInt_typespec();
                        its->VpiName(psym.name);
                        setLoc(its, SourceRange(psym.location, psym.location));
                        auto& pv = psym.as<ParameterSymbol>().getValue();
                        if (pv.isInteger() && !pv.integer().hasUnknown())
                            its->VpiValue(
                                "UINT:" +
                                pv.integer().toString(LiteralBase::Decimal, false));
                        // A PACKAGE-scope cast target carries vpiInstance =
                        // the package (BlackBePipeInt bp_common_pkg
                        // `dev_addr_width_gp'('h0_bff?)`: all 12 golden copies
                        // of this named typespec are stamped, and a null one
                        // is what typespec::Compare reported as `LHS=package
                        // RHS=<null>`).
                        if (pkgScopeInst)
                            its->Instance(pkgScopeInst);
                        else if (importedInitPkgInst)
                            its->Instance(importedInitPkgInst);
                        cts = its;
                    }
                    // A PACKAGE-scoped parameter width (pkg::P'(x)) mints a
                    // BARE int_typespec: no name, no loc, just the folded
                    // UINT value.
                    if (!cts && seCore.kind == ExpressionKind::NamedValue &&
                        seCore.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter &&
                        cesyn.left->kind == syntax::SyntaxKind::ScopedName) {
                        auto& psym = seCore.as<NamedValueExpression>().symbol;
                        if (auto psc = psym.getParentScope();
                            psc && psc->asSymbol().kind == SymbolKind::Package) {
                            auto* its = s.MakeInt_typespec();
                            auto& pv = psym.as<ParameterSymbol>().getValue();
                            if (pv.isInteger() && !pv.integer().hasUnknown())
                                its->VpiValue(
                                    "UINT:" +
                                    pv.integer().toString(LiteralBase::Decimal, false));
                            cts = its;
                        }
                    }
                    // A PARENTHESIZED parameter width ((P)'(x)) reuses the
                    // param's own int_typespec as the cast target; that ts
                    // gains a loc-less vpiExpr ref_obj with a param-doubled
                    // fullname (work@top.P.P) bound to the def parameter.
                    //
                    // The predicate below is NOT the paren test its name
                    // claims — it fires for any module-param cast that reaches
                    // here, i.e. for every target the literal-default arm above
                    // did NOT already serve.  What sorts the two is the CAST
                    // TARGET's own DECLARED default (§ castTgtDefaultIsLiteral),
                    // not the cast form; the golden matrix over Rggen's five
                    // `P'(x)` sites (r10rggen5, all five now agreeing):
                    //   rggen_register_common  VALUE_WIDTH  = BUS_WIDTH  (ref)
                    //       cast @106 (cont_assign)  STAMP  (this arm)
                    //   rggen_external_register VALUE_WIDTH = BUS_WIDTH  (ref)
                    //       cast @73  (cont_assign)  STAMP  (this arm)
                    //   rggen_apb_bridge     ADDRESS_WIDTH = 16      (literal)
                    //       cast @22  (cont_assign)  fresh valued ts, no stamp
                    //   rggen_adapter_common ADDRESS_WIDTH = 8       (literal)
                    //       cast @50  (function body) fresh valued ts, no stamp
                    //   rggen_address_decoder WIDTH        = 8       (literal)
                    //       cast @25  (function body) fresh valued ts, no stamp
                    // i.e. a LITERAL-default target folds its width at def
                    // compile and keeps no reference, while a target whose
                    // default is another PARAMETER cannot reduce there and
                    // keeps the ref_obj — in every module that writes the cast.
                    // The consequence is visible on BOTH sides of the object:
                    // the shared declaration typespec gains the ref_obj, and
                    // the cast site itself shows the param's UNNAMED
                    // declaration ts instead of a fresh one named after it.
                    // Only for a function DIRECTLY in the module: a function
                    // inside an elaborated GENERATE block builds a FRESH
                    // integer_typespec at the cast site instead (its params
                    // fold), so skip the param-reuse there.
                    bool inGenBlockFn = false;
                    if (currentSubSym)
                        for (auto gsc = currentSubSym->getParentScope(); gsc;
                             gsc = gsc->asSymbol().getParentScope()) {
                            auto gk = gsc->asSymbol().kind;
                            if (gk == SymbolKind::GenerateBlock ||
                                gk == SymbolKind::GenerateBlockArray) {
                                inGenBlockFn = true;
                                break;
                            }
                            if (gk == SymbolKind::InstanceBody)
                                break;
                        }
                    if (!cts && !inGenBlockFn &&
                        seCore.kind == ExpressionKind::NamedValue &&
                        seCore.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter) {
                        auto& psym = seCore.as<NamedValueExpression>().symbol;
                        if (auto psc = psym.getParentScope();
                            psc && psc->asSymbol().kind == SymbolKind::InstanceBody) {
                            auto dit = defMap.find(
                                &psc->asSymbol().as<InstanceBodySymbol>().getDefinition());
                            if (dit != defMap.end()) {
                                auto pit = dit->second.paramTs.find(&psym);
                                if (pit != dit->second.paramTs.end() &&
                                    pit->second->UhdmType() == UHDM::uhdmint_typespec) {
                                    auto* ipts = (UHDM::int_typespec*)pit->second;
                                    if (!ipts->Cast_to_expr()) {
                                        UHDM::parameter* pobj = nullptr;
                                        if (dit->second.mod && dit->second.mod->Parameters())
                                            for (auto* pp : *dit->second.mod->Parameters())
                                                if (pp->VpiName() == psym.name)
                                                    pobj = (UHDM::parameter*)pp;
                                        auto* r = s.MakeRef_obj();
                                        r->VpiName(psym.name);
                                        r->VpiParent(ipts);
                                        if (pobj) {
                                            r->VpiFullName(
                                                std::string(pobj->VpiFullName()) + "." +
                                                std::string(psym.name));
                                            r->Actual_group(pobj);
                                        }
                                        ipts->Cast_to_expr(r);
                                    }
                                    cts = ipts;
                                }
                            }
                        }
                    }
                    // In an elaborated gen-block function, a bare param cast
                    // width folds to a SIZED integer_typespec (direct UINT
                    // VpiValue), not a vpiExpr constant — the gen block is a
                    // concrete instance so the width is known.
                    if (!cts && inGenBlockFn &&
                        seCore.kind == ExpressionKind::NamedValue &&
                        seCore.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter) {
                        auto& pv = seCore.as<NamedValueExpression>()
                                       .symbol.as<ParameterSymbol>()
                                       .getValue();
                        if (pv.isInteger() && !pv.integer().hasUnknown()) {
                            auto* its = s.MakeInteger_typespec();
                            setLoc(its, lr);
                            its->VpiValue(
                                "UINT:" +
                                pv.integer().toString(LiteralBase::Decimal, false));
                            cts = its;
                        }
                    }
                    if (!cts) {
                        auto* its = s.MakeInteger_typespec();
                        setLoc(its, lr);
                        bool savedCS = inCastSize;
                        inCastSize = true;
                        if (auto* e = emitExpr(sizeExpr, op, prefix, netMap))
                            setCastSizeTsExpr(its, e);
                        inCastSize = savedCS;
                        // A package-scope size cast's integer_typespec carries
                        // vpiInstance = the package, exactly like the
                        // literal-width arm above; typespec::Compare chases
                        // Instance(), so a missing stamp reports as
                        // `LHS=package RHS=<null>`.
                        if (pkgScopeInst)
                            its->Instance(pkgScopeInst);
                        else if (importedInitPkgInst)
                            its->Instance(importedInitPkgInst);
                        cts = its;
                    }
                }
            }
            if (deferredCast) {
                // Nested size casts (8'(4'(x))) lose the INNER conversion's
                // syntax in deferred (reemit) contexts too — pass it down.
                {
                    const Expression* c1p = &conv.operand();
                    while (c1p->kind == ExpressionKind::Conversion &&
                           c1p->as<ConversionExpression>().isImplicit())
                        c1p = &c1p->as<ConversionExpression>().operand();
                    if (c1p->kind == ExpressionKind::Conversion &&
                        !c1p->as<ConversionExpression>().isImplicit() &&
                        (!c1p->syntax ||
                         c1p->syntax->kind !=
                             syntax::SyntaxKind::CastExpression) &&
                        effCastSyn &&
                        effCastSyn->kind ==
                            syntax::SyntaxKind::CastExpression) {
                        const syntax::ExpressionSyntax* rsynD =
                            effCastSyn->as<syntax::CastExpressionSyntax>()
                                .right->expression;
                        while (rsynD &&
                               rsynD->kind ==
                                   syntax::SyntaxKind::ParenthesizedExpression)
                            rsynD =
                                rsynD->as<syntax::ParenthesizedExpressionSyntax>()
                                    .expression;
                        if (rsynD &&
                            rsynD->kind == syntax::SyntaxKind::CastExpression)
                            castSynOverride = rsynD;
                    }
                }
                auto* operandsD = s.MakeAnyVec();
                if (auto* e = emitExpr(conv.operand(), op, prefix, netMap))
                    operandsD->push_back(wrapSignCast9(e));
                castSynOverride = nullptr;
                op->Operands(operandsD);
                return op;
            }
            if (!cts && effCastSyn &&
                effCastSyn->kind == syntax::SyntaxKind::CastExpression) {
                auto it2 = castTsCache.find(
                    effCastSyn->as<syntax::CastExpressionSyntax>().left);
                if (it2 != castTsCache.end())
                    cts = it2->second;
            }
            // A NESTED-cast operand emits FIRST (its typespec precedes the
            // outer's in the arena), with the inner CastExpression syntax
            // recovered from the outer's parenthesized operand.
            UHDM::any* nestedOperand = nullptr;
            // (Runs regardless of cts — a size-in-size nest 8'(4'(x)) has
            // cts already built for the OUTER but the inner still needs its
            // syntax passed down — static_cast_simple u3/u4/u5.)
            if (effCastSyn &&
                effCastSyn->kind == syntax::SyntaxKind::CastExpression) {
                const Expression* c1p = &conv.operand();
                while (c1p->kind == ExpressionKind::Conversion &&
                       c1p->as<ConversionExpression>().isImplicit())
                    c1p = &c1p->as<ConversionExpression>().operand();
                auto& c1 = *c1p;
                if (c1.kind == ExpressionKind::Conversion &&
                    !c1.as<ConversionExpression>().isImplicit() &&
                    (!c1.syntax ||
                     c1.syntax->kind != syntax::SyntaxKind::CastExpression)) {
                    const syntax::ExpressionSyntax* rsyn =
                        effCastSyn->as<syntax::CastExpressionSyntax>()
                            .right->expression;
                    while (rsyn &&
                           rsyn->kind == syntax::SyntaxKind::ParenthesizedExpression)
                        rsyn = rsyn->as<syntax::ParenthesizedExpressionSyntax>()
                                   .expression;
                    if (rsyn && rsyn->kind == syntax::SyntaxKind::CastExpression) {
                        castSynOverride = rsyn;
                        nestedOperand = emitExpr(c1, op, prefix, netMap);
                        castSynOverride = nullptr;
                    }
                }
            }
            if (!cts) {
                auto& ct = expr.type->getCanonicalType();
                if (ct.kind == SymbolKind::PredefinedIntegerType &&
                    ct.as<PredefinedIntegerType>().integerKind ==
                        PredefinedIntegerType::Byte) {
                    auto* bts = s.MakeByte_typespec();
                    bts->VpiSigned(ct.isSigned());
                    cts = bts;
                }
                else if (ct.kind == SymbolKind::PredefinedIntegerType) {
                    auto* its = s.MakeInt_typespec();
                    its->VpiSigned(ct.isSigned());
                    cts = its;
                }
                // A cast to the two-state scalar keyword (`bit'(x)`) mints a
                // BIT typespec, not the catch-all logic one: Surelog's type
                // compiler keeps the written 2-state kind (Scr1SvTests
                // scr1_mem_axi `bit'(SCR1_AXI_REQ_BP)`; purpose-built golden
                // r10scr5_a is byte-identical with this arm).
                else if (effCastSyn &&
                         effCastSyn->kind ==
                             syntax::SyntaxKind::CastExpression &&
                         effCastSyn->as<syntax::CastExpressionSyntax>()
                                 .left->kind ==
                             syntax::SyntaxKind::BitType) {
                    auto* bts = s.MakeBit_typespec();
                    if (ct.isSigned())
                        bts->VpiSigned(true);
                    cts = bts;
                }
                // § stringCastKeepsStringTypespec26 — and neither does the
                // STRING keyword fall into the catch-all: Surelog compiles the
                // written `paString_type` node into a string_typespec like any
                // other string declaration, so `string'(x)` carries one at the
                // keyword's own span.  Purpose-built t36e measures a string
                // cast in a package FUNCTION body (the shape that was wrong),
                // one at MODULE scope (already right through another path) and
                // the three keyword-cast negative controls `int'`/`logic'`/
                // `bit'`, which keep their own arms.  uvm_printer.svh:1189's
                // `string'(knobs.separator[0])` is the first failing pair of
                // Scoreboard (default) and SimpleUVM (both modes) once
                // § packageVarAutomaticIsDataDeclShape26 lands.
                else if (effCastSyn &&
                         effCastSyn->kind ==
                             syntax::SyntaxKind::CastExpression &&
                         effCastSyn->as<syntax::CastExpressionSyntax>()
                                 .left->kind ==
                             syntax::SyntaxKind::StringType) {
                    cts = s.MakeString_typespec();
                }
                else {
                    auto* lts = s.MakeLogic_typespec();
                    cts = lts;
                }
                if (effCastSyn && effCastSyn->kind == syntax::SyntaxKind::CastExpression)
                    setLoc(cts, effCastSyn->as<syntax::CastExpressionSyntax>().left->sourceRange());
                // A package-scope TYPE cast's target typespec carries
                // vpiInstance = the package, exactly like the size-cast
                // integer_typespec above (ParamCast def-view int'(...)):
                // typespec::Compare chases Instance(), so a missing stamp
                // reports as `failLhs=package failRhs=<null>`.
                if (pkgScopeInst)
                    cts->Instance(pkgScopeInst);
                else if (importedInitPkgInst)
                    cts->Instance(importedInitPkgInst);
            }
            auto* rt = s.MakeRef_typespec();
            // DEF-view gen procedural casts keep the ref_typespec BARE.
            if (!defGenProcessEmit) {
                // A package-qualified prefix ("pkg::") drops its trailing
                // separator on a cast op's ref_typespec fullname (Surelog
                // names it "pkg", not "pkg::").
                std::string tsp = prefix;
                if (tsp.size() >= 2 &&
                    tsp.compare(tsp.size() - 2, 2, "::") == 0)
                    tsp.resize(tsp.size() - 2);
                rt->VpiFullName(tsp);
            }
            rt->VpiParent(op);
            rt->Actual_typespec(cts);
            // Re-elaborated contexts parent the cast typespec at its ref — as
            // does an imported param's module-view init copy. A shared cast
            // UNION clone re-parents at every cast ref (last-writer, Surelog).
            bool castUnion9 = false;
            for (auto& [ct9, cu9] : castUnionClone)
                if (cu9 == cts)
                    castUnion9 = true;
            if (reemitting || castUnion9 ||
                (importedInitPkgInst &&
                 cts->UhdmType() == UHDM::uhdminteger_typespec))
                cts->VpiParent(rt);
            op->Typespec(rt);
            auto* operands = s.MakeAnyVec();
            // $UNIT-function bodies leave DIRECT formal refs under a cast
            // unbound (Surelog quirk).
            bool unitFnCast = false;
            if (currentSubSym)
                if (auto ps0 = currentSubSym->getParentScope();
                    ps0 && ps0->asSymbol().kind == SymbolKind::CompilationUnit)
                    unitFnCast = stripImplicitConv(conv.operand()).kind ==
                                 ExpressionKind::NamedValue;
            bool savedSRA = suppressRefActual;
            if (unitFnCast)
                suppressRefActual = true;
            if (nestedOperand)
                operands->push_back(nestedOperand);
            else if (auto* e = emitExpr(conv.operand(), op, prefix, netMap))
                operands->push_back(wrapSignCast9(e));
            suppressRefActual = savedSRA;
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::Call: {
            auto& call = expr.as<CallExpression>();
            if (!call.isSystemCall()) {
                bool callStmtCtx0 = callStmtContext;
                callStmtContext = false;
                auto& sub = *std::get<const SubroutineSymbol*>(call.subroutine);
                // § superMethodCall17 — `super.<m>(args)` is a
                // METHOD_FUNC_CALL named after the method, located at the
                // METHOD TOKEN, whose vpiPrefix is an UNPARENTED string
                // constant "super" spanning the keyword — and it carries NO
                // vpiFunction / vpiTask link.  Surelog reaches it through
                // compileTfCall's `paImplicit_class_handle` arm with
                // rootName="super", the same arm § thisRecvCall11 decoded for
                // `this`; slang binds the call straight to the base-class
                // subroutine with a NULL thisClass, so we had been emitting a
                // plain func_call (or, once a dotted receiver got involved, a
                // hier_path) named after the method but spanning the whole
                // written call.  A TASK takes the same method_func_call shape
                // — there is no method_task_call in this arm.  Pinned by the
                // purpose-built t27 pair (void function / int function in an
                // assignment rhs / bit function in an `if` condition / task /
                // no-argument call, def AND elab views); UVM's
                // `super.do_print(printer);` family is ~230 rows on SeqDriver
                // alone.
                {
                    slang::SourceRange spRng17, mRng17;
                    if (superMethodCall17(expr.syntax, spRng17, mRng17)) {
                        bool savedSC17 = callStmtContext;
                        callStmtContext = false;
                        auto* mfc17 = s.MakeMethod_func_call();
                        mfc17->VpiName(sub.name);
                        mfc17->VpiParent(parent);
                        setLoc(mfc17, mRng17);
                        auto* pc17 = s.MakeConstant();
                        pc17->VpiValue("STRING:super");
                        pc17->VpiDecompile("super");
                        pc17->VpiSize(5);
                        pc17->VpiConstType(vpiStringConst);
                        setLoc(pc17, spRng17);
                        mfc17->Prefix(pc17);
                        auto* ma17 = s.MakeAnyVec();
                        {
                            // § classArgBind12 — a USER call's arguments bind
                            // their actual even inside a class method.
                            // § blockLocalSameCtrlDepthArgBinds57 — THE §53 GATE,
                            // ADDED AT INTEGRATION (verifier FINDING 2: the same
                            // defect as the § classCallNoLink12 site above, in
                            // the `super.<m>()` window, LATENT with 0 corpus
                            // reach today but proved on arm v4_superexpr.sv —
                            // `super.bv(r1);` in STATEMENT position is golden
                            // BOUND, while `i1 = super.bm(r1)`, the same call as
                            // an OPERAND, and `return super.bm(r1d)` are all
                            // golden BARE and were binding.  Its `this.iv(r2)` /
                            // `o.bv(r3)` siblings are already correct because
                            // § classInBodyRecvCallArgNoBind52 windows them.
                            // `callStmtCtx0`, not the member, which this arm
                            // clears.
                            ClassArgBindIf38 cab17(
                                classArgBindDepth12,
                                callStmtCtx0 ||
                                    !(curSubClassScope9 && !curSubOob9));
                            // § writtenCallArgs16 — only the actuals WRITTEN
                            // at the call site.
                            for (auto arg17 : writtenArgs16(call)) {
                                bool fs17 = forceConstParent;
                                if (isLiteralExpr(*arg17))
                                    forceConstParent = true;
                                if (auto* a17 =
                                        emitExpr(*arg17, mfc17, prefix, netMap))
                                    ma17->push_back(a17);
                                forceConstParent = fs17;
                            }
                        }
                        if (!ma17->empty())
                            mfc17->Tf_call_args(ma17);
                        callStmtContext = savedSC17;
                        return mfc17;
                    }
                }
                // § staticScopedCall12 — a STATIC CLASS METHOD reached through
                // `::` (`uvm_config_db#(T)::get(...)`, `process::self()`,
                // `uvm_coreservice_t::get()`) is not a call in the golden at
                // all: Surelog's class_scope arm yields a bare `ref_obj` whose
                // name is the FIRST written segment plus the FINAL identifier
                // joined by `::`, with the ARGUMENTS DROPPED and no vpiFunction
                // / vpiTask link.  Measured on purpose-built pairs (t1-t3,
                // both views): `base::sf(3)` -> ref_obj `base::sf`,
                // `p::base::sf(2)` -> `p::sf` (the middle segment is dropped),
                // `gen#(int)::gf(3)` -> `gen::gf` (the parameter list is
                // dropped), `alias_t::sf(5)` -> `alias_t::sf` (the written
                // spelling, never the aliased class), and a nested
                // `base::sf(base::sf(6))` collapses to ONE ref_obj.  The span
                // runs from the start of the scoped name to just BEFORE the
                // final identifier — i.e. it covers `base::` / `p::base::` /
                // `gen#(int)::`.  A PACKAGE-qualified call (`p::pf(2)`) is a
                // different arm entirely and keeps its func_call and its
                // arguments (t3), so this keys on the subroutine's parent
                // scope being a CLASS.
                //
                // Until now every one of these was DROPPED outright by the
                // `noteUnsupported("user function call")` fallback when the
                // class was a specialization or compiled late (1604 hits on
                // SeqDriver alone) and mis-shaped as a func_call otherwise.
                if (auto pscS = sub.getParentScope();
                    pscS && pscS->asSymbol().kind == SymbolKind::ClassType &&
                    !call.thisClass() && expr.syntax) {
                    const slang::syntax::SyntaxNode* cs = expr.syntax;
                    if (cs->kind == syntax::SyntaxKind::InvocationExpression)
                        cs = cs->as<syntax::InvocationExpressionSyntax>().left;
                    if (auto* ns12 = scopedNameSyntax12(cs)) {
                        std::string f12, l12;
                        slang::SourceLocation e12;
                        if (splitScopedName12(*ns12, f12, l12, e12)) {
                            std::string nm12 = f12 + "::" + l12;
                            // § classScopeCallOfOutOfBodyMethodIsFuncCall26 —
                            // the ref_obj below is the DEGRADED form, and what
                            // degrades is a NAME LOOKUP: Surelog's class_scope
                            // arm (CompileExpression.cpp:5273) asks
                            // getTaskFunc("<Class>::<f>") first and, when that
                            // finds a task_func, emits a REAL call — a
                            // func_call/task_call named with the written
                            // qualifier, spanning the CLASS-NAME TOKEN alone,
                            // carrying vpiFunction/vpiTask and the arguments —
                            // falling through to compileExpression's bare
                            // ref_obj only when it does not (:5375).
                            // getTaskFunc keys on the LITERAL name, and the
                            // only declaration that registers a task_func
                            // called `Class::f` is an OUT-OF-BODY definition
                            // (`function extern_c::get(); ... endfunction`, the
                            // body of an `extern` prototype) — an in-body
                            // method is registered as plain `f` inside the
                            // class, so its qualified lookup always misses.
                            // Measured both directions on the purpose-built
                            // t36d pair (one class with an in-body static
                            // getter, one with an extern prototype + out-of-
                            // body body, each called const and non-const at
                            // package scope): golden gives the in-body arm a
                            // ref_obj and the extern arm a func_call, in BOTH
                            // views.  This is also exactly the set the earlier
                            // "measured and rejected" note at the bound-call
                            // arm below could not explain: golden's five
                            // qualified names are uvm_root::get and
                            // uvm_{reg,reg_field,mem}::get_max_size — every
                            // one an `extern static function` with an
                            // out-of-body body — while uvm_coreservice_t::get,
                            // whose 143 call sites that note minted wrongly,
                            // is defined IN BODY.  uvm_top's initializer
                            // (`const uvm_root uvm_top = uvm_root::get();`) is
                            // the UVM-4's second distinguisher on that object.
                            if (uint32_t(sub.outOfBlockIndex) != 0u) {
                                bool isFn26 = sub.subroutineKind ==
                                              SubroutineKind::Function;
                                UHDM::task_func* tf26 = nullptr;
                                if (auto it26 = subMap.find(&sub);
                                    it26 != subMap.end())
                                    tf26 = it26->second.tf;
                                UHDM::tf_call* c26 =
                                    isFn26 ? (UHDM::tf_call*)s.MakeFunc_call()
                                           : (UHDM::tf_call*)s.MakeTask_call();
                                c26->VpiName(nm12);
                                c26->VpiParent(parent);
                                setLoc(c26, nameSpan(ns12->sourceRange().start(),
                                                     f12));
                                if (tf26) {
                                    if (isFn26)
                                        ((UHDM::func_call*)c26)->Function(
                                            (UHDM::function*)tf26);
                                    else
                                        ((UHDM::task_call*)c26)->Task(
                                            (UHDM::task*)tf26);
                                }
                                else
                                    pendingScopedCallBind26.push_back(
                                        {c26, &sub});
                                auto* a26 = s.MakeAnyVec();
                                for (auto arg26 : writtenArgs16(call))
                                    if (auto* e26 = emitExpr(*arg26, c26, prefix,
                                                             netMap))
                                        a26->push_back(e26);
                                if (!a26->empty())
                                    c26->Tf_call_args(a26);
                                return c26;
                            }
                            auto* r12 = s.MakeRef_obj();
                            r12->VpiName(nm12);
                            r12->VpiFullName(joinRef(prefix, nm12));
                            r12->VpiParent(parent);
                            setLoc(r12,
                                   SourceRange(ns12->sourceRange().start(), e12));
                            return r12;
                        }
                    }
                }
                // Class METHOD calls (bar.set(4)): a method_func_call at the
                // method token, with an UNBOUND receiver ref as vpiPrefix.
                if (auto psc0 = sub.getParentScope();
                    psc0 && psc0->asSymbol().kind == SymbolKind::ClassType &&
                    call.thisClass()) {
                    // ...but only as a STATEMENT. In EXPRESSION position the
                    // same call is a hier_path named "<recv>.<method>" whose
                    // elements are the receiver ref_obj and the
                    // method_func_call — the identical statement/expression
                    // split Surelog's built-in method path already takes (see
                    // the `stmtCtx` arm below). Measured on ApbSlave
                    // (`svunit_ut.start();` -> method_func_call,
                    // `svunit_ut.get_error_count()` in an initializer ->
                    // hier_path) and on a purpose-built golden where every
                    // receiver kind — formal, body local, class property,
                    // module signal — takes the hier_path form in an argument
                    // list (r10apb2 repro 6).
                    auto& recv0 = stripImplicitConv(*call.thisClass());
                    // A method reached through a PACKAGE-QUALIFIED handle
                    // collapses to the handle reference alone, arguments and
                    // all (isPkgQualifiedVarRef).
                    if (isPkgQualifiedVarRef(recv0))
                        return emitExpr(recv0, parent, prefix, netMap);
                    // § callParenSpan11 — slang's CallExpression range stops
                    // at the callee name when the call takes no arguments
                    // (`h.first` for `h.first()`); Surelog's hier_path runs
                    // through the closing paren.  Take the invocation SYNTAX
                    // range when it starts at the same place and reaches
                    // further, which is exactly the `()` case.
                    SourceRange callRng11 = expr.sourceRange;
                    if (expr.syntax) {
                        auto sr11 = expr.syntax->sourceRange();
                        if (sr11.start() == callRng11.start() &&
                            sr11.end() > callRng11.end())
                            callRng11 = sr11;
                    }
                    // § deepRecvCall11 — the two arms below only ever knew a
                    // receiver that is ONE bare name; a DOTTED or INDEXED
                    // receiver (`m.l.doit()`, `m.la[2].get()`, `q[0].get()`)
                    // fell through to the flat method_func_call in both
                    // positions, which is wrong in both.  Flatten the receiver
                    // into its written segments so the two shapes golden
                    // actually builds can be produced (repro t2, both views):
                    //   EXPRESSION  hier_path `<recv>.<method>` whose elements
                    //     are one NAME-ONLY ref_obj per plain segment, a
                    //     bit_select (bare name, fullname = the written path
                    //     through the index, vpiIndex the index) per indexed
                    //     segment, and the method_func_call last;
                    //   STATEMENT   Surelog's compileTfCall reads only the
                    //     FIRST TWO names — the call is named after segment 1
                    //     with segment 0 as the (scoped) vpiPrefix, and the
                    //     method's own arguments are dropped; an INDEX on
                    //     segment 1 becomes the call's single vpiArgument.
                    // The single-segment forms keep their existing arms
                    // untouched: `q[0].doit();` (one indexed segment, in
                    // statement position) already matched golden.
                    struct RSeg11 {
                        std::string name;
                        const Expression* idx;   // ElementSelect selector
                        const Expression* node;  // written span of the segment
                        SourceRange nameRng;
                    };
                    std::vector<RSeg11> segs11;
                    {
                        const Expression* cur11 = &recv0;
                        bool ok11 = true;
                        while (ok11) {
                            if (cur11->kind == ExpressionKind::ElementSelect) {
                                auto& es11 =
                                    cur11->as<ElementSelectExpression>();
                                auto* base11 = &stripImplicitConv(es11.value());
                                std::string nm11;
                                if (base11->kind == ExpressionKind::NamedValue)
                                    nm11 = std::string(
                                        base11->as<NamedValueExpression>()
                                            .symbol.name);
                                else if (base11->kind ==
                                         ExpressionKind::MemberAccess)
                                    nm11 = std::string(
                                        base11->as<MemberAccessExpression>()
                                            .member.name);
                                else {
                                    ok11 = false;
                                    break;
                                }
                                auto ne11 = base11->sourceRange.end();
                                segs11.push_back(
                                    {nm11, &es11.selector(), cur11,
                                     SourceRange(ne11 - nm11.size(), ne11)});
                                if (base11->kind ==
                                    ExpressionKind::MemberAccess) {
                                    cur11 = &stripImplicitConv(
                                        base11->as<MemberAccessExpression>()
                                            .value());
                                    continue;
                                }
                                break;
                            }
                            if (cur11->kind == ExpressionKind::MemberAccess) {
                                auto& ma11 =
                                    cur11->as<MemberAccessExpression>();
                                std::string nm11(ma11.member.name);
                                auto ne11 = cur11->sourceRange.end();
                                segs11.push_back(
                                    {nm11, nullptr, cur11,
                                     SourceRange(ne11 - nm11.size(), ne11)});
                                cur11 = &stripImplicitConv(ma11.value());
                                continue;
                            }
                            if (cur11->kind == ExpressionKind::NamedValue) {
                                segs11.push_back(
                                    {std::string(
                                         cur11->as<NamedValueExpression>()
                                             .symbol.name),
                                     nullptr, cur11, cur11->sourceRange});
                                break;
                            }
                            ok11 = false;
                        }
                        if (!ok11)
                            segs11.clear();
                        else
                            std::reverse(segs11.begin(), segs11.end());
                    }
                    // § thisRecvCall11 — a `this.`-rooted receiver is NOT a
                    // path segment for Surelog.  `compileTfCall` hands the
                    // whole `paImplicit_class_handle` form to
                    // `compileComplexFuncCall` (CompileExpression.cpp :5154),
                    // which sets rootName="this" and then splits FOUR ways on
                    // what follows the first name — read off the source and
                    // pinned by repro t4:
                    //   `this.m(args)`            -> method_func_call named
                    //     after the METHOD, vpiPrefix a STRING constant
                    //     "this" (the `List_of_arguments` arm compiles the
                    //     handle itself as the prefix expression);
                    //   `this.a.m()` / `this.a[i].m()` in STATEMENT position
                    //     -> the `paConstant_bit_select` arm:
                    //     `fcall->VpiName(rootName)` — the call is literally
                    //     NAMED "this", located at the FIRST name after it,
                    //     prefix the same string constant, and the method's
                    //     own arguments ride it;
                    //   `this.a.m()` in EXPRESSION position -> the
                    //     `slStringConst` arm, which is a one-line MOCKUP:
                    //     a bare constant carrying only VpiDecompile("this")
                    //     — no value, no size, no const type;
                    //   `this.a[i].m()` in EXPRESSION position -> the
                    //     select arm's fallback hier_path: ref_obj "this"
                    //     located at the first name, then one ref_obj per
                    //     remaining name INCLUDING the method (never a
                    //     method_func_call), indices dropped from the name.
                    // This matters at scale because UVM's TLM ports and
                    // exports are generated by `UVM_GET_IMP(this.m_if, ...)`
                    // and friends: the first cut of deepRecvCall11 built a
                    // 3-element hier_path for every one of their forwarding
                    // methods, +2011 elements on SeqDriver where golden's
                    // whole delta was +838.
                    bool thisRoot11 =
                        !segs11.empty() && segs11[0].name == "this";
                    // `super.`-rooted is the same Surelog arm with
                    // rootName="super" but is NOT measured here, so it keeps
                    // the pre-existing flat form rather than guessing.
                    bool superRoot11 =
                        !segs11.empty() && segs11[0].name == "super";
                    // Both `this` constants are UNPARENTED in golden.
                    auto thisConst11 = [&]() {
                        auto* c11 = s.MakeConstant();
                        c11->VpiValue("STRING:this");
                        c11->VpiDecompile("this");
                        c11->VpiSize(4);
                        c11->VpiConstType(vpiStringConst);
                        setLoc(c11, segs11[0].nameRng);
                        return c11;
                    };
                    if (thisRoot11) {
                        bool idxed11 = false;
                        for (size_t i11 = 1; i11 < segs11.size(); i11++)
                            idxed11 |= segs11[i11].idx != nullptr;
                        auto mSpan11 =
                            nameSpan(call.thisClass()->sourceRange.end() + 1,
                                     sub.name);
                        if (!callStmtCtx0 && segs11.size() > 1 && !idxed11) {
                            auto* c11 = s.MakeConstant();
                            c11->VpiDecompile("this");
                            setLoc(c11, callRng11);
                            return c11;
                        }
                        if (!callStmtCtx0 && segs11.size() > 1) {
                            auto* hp11 = s.MakeHier_path();
                            std::string nm11 = "this";
                            for (size_t i11 = 1; i11 < segs11.size(); i11++)
                                nm11 += "." + segs11[i11].name;
                            nm11 += "." + std::string(sub.name);
                            hp11->VpiName(nm11);
                            hp11->VpiFullName(nm11);
                            hp11->VpiParent(parent);
                            setLoc(hp11, callRng11);
                            auto* el11 = s.MakeAnyVec();
                            auto mkRef11 = [&](const std::string& n11,
                                               SourceRange r11) {
                                auto* r = s.MakeRef_obj();
                                r->VpiName(n11);
                                r->VpiFullName(n11);  // name-only
                                r->VpiParent(hp11);
                                setLoc(r, r11);
                                el11->push_back(r);
                            };
                            mkRef11("this", segs11[1].nameRng);
                            for (size_t i11 = 1; i11 < segs11.size(); i11++)
                                mkRef11(segs11[i11].name, segs11[i11].nameRng);
                            mkRef11(std::string(sub.name), mSpan11);
                            hp11->Path_elems(el11);
                            return hp11;
                        }
                        auto* mfc11 = s.MakeMethod_func_call();
                        if (segs11.size() > 1) {
                            mfc11->VpiName("this");
                            setLoc(mfc11, segs11[1].nameRng);
                        }
                        else {
                            mfc11->VpiName(sub.name);
                            setLoc(mfc11, mSpan11);
                        }
                        mfc11->VpiParent(parent);
                        mfc11->Prefix(thisConst11());
                        auto* ma11 = s.MakeAnyVec();
                        {
                            // § thisRecvCallArgBind38 — a STATEMENT-position
                            // DIRECT `this.m(f)` binds its arguments like any
                            // other call; the expression form and every DEEP
                            // `this.<member>.m(f)` leave them bare.
                            ClassArgBindIf38 cab38(
                                classArgBindDepth12,
                                callStmtCtx0 && segs11.size() == 1);
                            // § writtenCallArgs16 — only the actuals WRITTEN at
                            // the call site; a defaulted formal is slang's, not
                            // Surelog's.
                            for (auto arg : writtenArgs16(call)) {
                                bool fs11 = forceConstParent;
                                if (isLiteralExpr(*arg))
                                    forceConstParent = true;
                                if (auto* a11 =
                                        emitExpr(*arg, mfc11, prefix, netMap))
                                    ma11->push_back(a11);
                                forceConstParent = fs11;
                            }
                        }
                        if (!ma11->empty())
                            mfc11->Tf_call_args(ma11);
                        return mfc11;
                    }
                    bool deepRecv11 =
                        !superRoot11 &&
                        (segs11.size() > 1 ||
                         (segs11.size() == 1 && segs11[0].idx != nullptr));
                    if (!callStmtCtx0 && deepRecv11) {
                        auto& recvE11 = *call.thisClass();
                        std::string recvTx11 = rawText(recvE11.sourceRange);
                        std::string dotted11 =
                            recvTx11 + "." + std::string(sub.name);
                        auto* hp11 = s.MakeHier_path();
                        hp11->VpiName(dotted11);
                        hp11->VpiFullName(dotted11);
                        hp11->VpiParent(parent);
                        setLoc(hp11, callRng11);
                        auto* elems11 = s.MakeAnyVec();
                        for (auto& sg11 : segs11) {
                            if (!sg11.idx) {
                                auto* r11 = s.MakeRef_obj();
                                r11->VpiName(sg11.name);
                                r11->VpiFullName(sg11.name);  // name-only
                                r11->VpiParent(hp11);
                                setLoc(r11, sg11.nameRng);
                                elems11->push_back(r11);
                                continue;
                            }
                            auto* bs11 = s.MakeBit_select();
                            bs11->VpiName(sg11.name);
                            bs11->VpiFullName(
                                rawText(sg11.node->sourceRange));
                            bs11->VpiParent(hp11);
                            setLoc(bs11, sg11.nameRng);
                            // The index of a hier_path element is UNPARENTED
                            // in golden (unlike the statement form's argument,
                            // which parents at the call).
                            bool fsx11 = forceConstParent;
                            bool ssx11 = suppressConstParent;
                            forceConstParent = false;
                            suppressConstParent = true;
                            if (auto* ix11 =
                                    emitExpr(*sg11.idx, bs11, prefix, netMap))
                                bs11->VpiIndex((UHDM::expr*)ix11);
                            forceConstParent = fsx11;
                            suppressConstParent = ssx11;
                            elems11->push_back(bs11);
                        }
                        auto* mfc11 = s.MakeMethod_func_call();
                        mfc11->VpiName(sub.name);
                        mfc11->VpiParent(hp11);
                        setLoc(mfc11, nameSpan(recvE11.sourceRange.end() + 1,
                                               sub.name));
                        auto* margs11 = s.MakeAnyVec();
                        {
                            // NOTE § classInBodyRecvCallArgNoBind52 — SITE 4,
                            // the DEEP-RECEIVER arm (`bool deepRecv11` just
                            // above).  THE MISS pass 52's own integration
                            // recorded: `grep -n MakeHier_path src/ExprEmit.cpp`
                            // inside the Call case returns FIVE mints, FOUR
                            // under `!callStmtCtx0`, and pass 52 windowed
                            // THREE.  This one mints a hier_path AND emits call
                            // arguments, so a two-segment receiver never reached
                            // the law.  SAME GATE, unchanged:
                            //   curSubClassScope9 && !curSubOob9 &&
                            //   recvCallArgDepth52 > 0
                            // Arm a4, BOTH SIDES: `if (mid.leaf.m53(f) == 0)`
                            // IN BODY is golden NONE / ours io_decl, while the
                            // OUT-OF-BODY twin `f1_ob_cond_deep` and the PACKAGE
                            // twin `f1_pk_cond_deep` are io_decl in golden and
                            // are left untouched by `!curSubOob9` /
                            // `curSubClassScope9`.
                            RecvCallArg52 rca52D(recvCallArgDepth52);
                            // § writtenCallArgs16 — only the actuals WRITTEN at
                            // the call site; a defaulted formal is slang's, not
                            // Surelog's.
                            for (auto arg : writtenArgs16(call)) {
                                bool fs11 = forceConstParent;
                                if (isLiteralExpr(*arg))
                                    forceConstParent = true;
                                if (auto* a11 =
                                        emitExpr(*arg, mfc11, prefix, netMap))
                                    margs11->push_back(a11);
                                forceConstParent = fs11;
                            }
                        }
                        if (!margs11->empty())
                            mfc11->Tf_call_args(margs11);
                        elems11->push_back(mfc11);
                        hp11->Path_elems(elems11);
                        return hp11;
                    }
                    if (callStmtCtx0 && deepRecv11 && segs11.size() > 1) {
                        auto& sg0 = segs11[0];
                        auto& sg1 = segs11[1];
                        auto* mfc11 = s.MakeMethod_func_call();
                        mfc11->VpiName(sg1.name);
                        mfc11->VpiParent(parent);
                        setLoc(mfc11, sg1.nameRng);
                        auto* pr11 = s.MakeRef_obj();
                        pr11->VpiName(sg0.name);
                        pr11->VpiFullName(joinRef(prefix, sg0.name));
                        pr11->VpiParent(mfc11);
                        setLoc(pr11, sg0.nameRng);
                        mfc11->Prefix(pr11);
                        if (sg1.idx) {
                            auto* margs11 = s.MakeAnyVec();
                            bool fs11 = forceConstParent;
                            if (isLiteralExpr(*sg1.idx))
                                forceConstParent = true;
                            if (auto* a11 =
                                    emitExpr(*sg1.idx, mfc11, prefix, netMap))
                                margs11->push_back(a11);
                            forceConstParent = fs11;
                            if (!margs11->empty())
                                mfc11->Tf_call_args(margs11);
                        }
                        return mfc11;
                    }
                    if (!callStmtCtx0 &&
                        recv0.kind == ExpressionKind::NamedValue) {
                        std::string rn0(
                            recv0.as<NamedValueExpression>().symbol.name);
                        std::string dotted0 = rn0 + "." + std::string(sub.name);
                        auto* hp0 = s.MakeHier_path();
                        hp0->VpiName(dotted0);
                        hp0->VpiFullName(dotted0);
                        hp0->VpiParent(parent);
                        setLoc(hp0, callRng11);
                        auto* elems0 = s.MakeAnyVec();
                        auto* r0 = s.MakeRef_obj();
                        r0->VpiName(rn0);
                        r0->VpiFullName(rn0); // name-only (dump omits)
                        r0->VpiParent(hp0);
                        setLoc(r0, call.thisClass()->sourceRange);
                        elems0->push_back(r0);
                        auto* mfc0 = s.MakeMethod_func_call();
                        mfc0->VpiName(sub.name);
                        mfc0->VpiParent(hp0);
                        setLoc(mfc0, nameSpan(
                                         call.thisClass()->sourceRange.end() + 1,
                                         sub.name));
                        auto* margs0 = s.MakeAnyVec();
                        // NOTE § classInBodyRecvCallArgNoBind52 — SITE 1 of 3,
                        // the one-name-receiver CLASS-METHOD call in
                        // EXPRESSION position (arm a2 ib_cond_hnd_formal
                        // `if (h.um52(f) == 0)`: golden NONE, ours bound
                        // before this law).  GATE: in-body class method.
                        RecvCallArg52 rca52(recvCallArgDepth52);
                        // § writtenCallArgs16 — only the actuals WRITTEN at
                        // the call site; a defaulted formal is slang's, not
                        // Surelog's.
                        for (auto arg : writtenArgs16(call)) {
                            bool fs0 = forceConstParent;
                            if (isLiteralExpr(*arg))
                                forceConstParent = true;
                            if (auto* a0 = emitExpr(*arg, mfc0, prefix, netMap))
                                margs0->push_back(a0);
                            forceConstParent = fs0;
                        }
                        if (!margs0->empty())
                            mfc0->Tf_call_args(margs0);
                        elems0->push_back(mfc0);
                        hp0->Path_elems(elems0);
                        // § hierCallArgTakesBase39 — remember that THIS
                        // two-element hier_path is a CLASS-method call, so the
                        // design-final pass can hand its arguments the base's
                        // own actual without also catching a built-in
                        // associative-array method of the identical shape (see
                        // classRecvCallHp39 in UhdmExporter.h).
                        classRecvCallHp39.insert(hp0);
                        return hp0;
                    }
                    auto* mfc = s.MakeMethod_func_call();
                    mfc->VpiName(sub.name);
                    mfc->VpiParent(parent);
                    auto& recv = *call.thisClass();
                    setLoc(mfc, nameSpan(recv.sourceRange.end() + 1, sub.name));
                    auto* rb = &stripImplicitConv(recv);
                    // A call through an ELEMENT SELECT (`q[i].report();`)
                    // still carries a prefix — Surelog drops the index and
                    // names the prefix after the selected object alone, at
                    // the bare identifier span (ApbSlave
                    // `list_of_testcases[i].report()`).
                    while (rb->kind == ExpressionKind::ElementSelect)
                        rb = &stripImplicitConv(
                            rb->as<ElementSelectExpression>().value());
                    if (rb->kind == ExpressionKind::NamedValue) {
                        auto* pr = s.MakeRef_obj();
                        pr->VpiName(rb->as<NamedValueExpression>().symbol.name);
                        pr->VpiFullName(joinRef(
                            prefix, rb->as<NamedValueExpression>().symbol.name));
                        pr->VpiParent(mfc);
                        setLoc(pr, rb->sourceRange);
                        mfc->Prefix(pr);
                    }
                    auto* margs = s.MakeAnyVec();
                    {
                        ClassArgBind12 cab12(classArgBindDepth12);
                        // § writtenCallArgs16 — only the actuals WRITTEN at
                        // the call site; a defaulted formal is slang's, not
                        // Surelog's.
                        for (auto arg : writtenArgs16(call)) {
                            bool fs2 = forceConstParent;
                            if (isLiteralExpr(*arg))
                                forceConstParent = true;
                            if (auto* a2 = emitExpr(*arg, mfc, prefix, netMap))
                                margs->push_back(a2);
                            forceConstParent = fs2;
                        }
                    }
                    if (!margs->empty())
                        mfc->Tf_call_args(margs);
                    return mfc;
                }
                // A HIERARCHICALLY-QUALIFIED user call in EXPRESSION position
                // (`$display(blk.f())`, `i.f()`, `top.i.blk.f()`,
                // `foo_1.bar(3)`) is NOT a resolved func_call in Surelog's
                // model: it is a hier_path named after the whole dotted text,
                // over ONE name-only ref_obj per prefix name plus a
                // method_func_call at the final name, carrying the arguments
                // and NO function link — the same expression/statement split
                // the class-method and built-in-method paths take above.
                // Measured on HierPathInterfBlock (all six dotted forms —
                // gen-block, interface, and `top.`-rooted — take it, while
                // the undotted `f()` stays a linked func_call) and on
                // InterfaceFuncCall. STATEMENT position keeps the flat forms
                // below.
                if (!callStmtCtx0) {
                    std::string rawH = rawText(expr.sourceRange);
                    std::string calleeH = rawH.substr(0, rawH.find('('));
                    while (!calleeH.empty() &&
                           (calleeH.back() == ' ' || calleeH.back() == '\t' ||
                            calleeH.back() == '\n' || calleeH.back() == '\r'))
                        calleeH.pop_back();
                    // Plain dotted identifiers only: a select or a
                    // package/class scope in the path is a different shape.
                    bool plainH =
                        !calleeH.empty() &&
                        calleeH.find('.') != std::string::npos &&
                        calleeH.find(':') == std::string::npos &&
                        calleeH.find_first_of("[] \t\n\r") == std::string::npos;
                    std::vector<std::string> namesH;
                    if (plainH)
                        for (size_t p0 = 0;;) {
                            auto d0 = calleeH.find('.', p0);
                            if (d0 == std::string::npos) {
                                namesH.push_back(calleeH.substr(p0));
                                break;
                            }
                            namesH.push_back(calleeH.substr(p0, d0 - p0));
                            p0 = d0 + 1;
                        }
                    // The last name must be the called subroutine itself.
                    if (plainH && namesH.size() > 1 &&
                        namesH.back() == std::string(sub.name)) {
                        auto* hpH = s.MakeHier_path();
                        hpH->VpiName(calleeH);
                        hpH->VpiFullName(calleeH);
                        hpH->VpiParent(parent);
                        setLoc(hpH, expr.sourceRange);
                        auto* elemsH = s.MakeAnyVec();
                        auto posH = expr.sourceRange.start();
                        for (size_t i0 = 0; i0 + 1 < namesH.size(); i0++) {
                            auto* r0 = s.MakeRef_obj();
                            r0->VpiName(namesH[i0]);
                            r0->VpiFullName(namesH[i0]); // name-only
                            r0->VpiParent(hpH);
                            setLoc(r0,
                                   SourceRange(posH, posH + namesH[i0].size()));
                            elemsH->push_back(r0);
                            posH = posH + namesH[i0].size() + 1;
                        }
                        auto* mfcH = s.MakeMethod_func_call();
                        mfcH->VpiName(sub.name);
                        mfcH->VpiParent(hpH);
                        setLoc(mfcH,
                               SourceRange(posH, posH + namesH.back().size()));
                        auto* argsH = s.MakeAnyVec();
                        // NOTE § classInBodyRecvCallArgNoBind52 — SITE 2 of 3,
                        // the DOTTED-PATH call in EXPRESSION position (two or
                        // more receiver names).  GATE: in-body class method.
                        RecvCallArg52 rca52H(recvCallArgDepth52);
                        // § writtenCallArgs16 — only the actuals WRITTEN at
                        // the call site; a defaulted formal is slang's, not
                        // Surelog's.
                        for (auto arg : writtenArgs16(call)) {
                            bool fsH = forceConstParent;
                            if (isLiteralExpr(*arg))
                                forceConstParent = true;
                            if (auto* aH = emitExpr(*arg, mfcH, prefix, netMap))
                                argsH->push_back(aH);
                            forceConstParent = fsH;
                        }
                        if (!argsH->empty())
                            mfcH->Tf_call_args(argsH);
                        elemsH->push_back(mfcH);
                        hpH->Path_elems(elemsH);
                        return hpH;
                    }
                }
                // INTERFACE method calls through a port (ha_intf.summ2(a,b)):
                // a method_func_call at the method token whose vpiPrefix is a
                // bare (unbound) receiver ref; args bind normally; NO function
                // link (iface_method_call — Surelog).
                if (auto psc1 = sub.getParentScope();
                    psc1 &&
                    psc1->asSymbol().kind == SymbolKind::InstanceBody &&
                    psc1->asSymbol()
                            .as<InstanceBodySymbol>()
                            .getDefinition()
                            .definitionKind == DefinitionKind::Interface) {
                    std::string raw1 = rawText(expr.sourceRange);
                    auto dot1 = raw1.find_last_of('.');
                    if (dot1 != std::string::npos) {
                        std::string recv1 = raw1.substr(0, dot1);
                        auto* mfc = s.MakeMethod_func_call();
                        mfc->VpiName(sub.name);
                        mfc->VpiParent(parent);
                        auto mstart1 = expr.sourceRange.start() + (dot1 + 1);
                        setLoc(mfc, SourceRange(mstart1,
                                                mstart1 + sub.name.size()));
                        auto* pr = s.MakeRef_obj();
                        pr->VpiName(recv1);
                        pr->VpiFullName(joinRef(prefix, recv1));
                        pr->VpiParent(mfc);
                        setLoc(pr, SourceRange(expr.sourceRange.start(),
                                               expr.sourceRange.start() +
                                                   dot1));
                        mfc->Prefix(pr);
                        auto* margs = s.MakeAnyVec();
                        // § writtenCallArgs16 — only the actuals WRITTEN at
                        // the call site; a defaulted formal is slang's, not
                        // Surelog's.
                        for (auto arg : writtenArgs16(call)) {
                            bool fs2 = forceConstParent;
                            if (isLiteralExpr(*arg))
                                forceConstParent = true;
                            if (auto* a2 = emitExpr(*arg, mfc, prefix, netMap))
                                margs->push_back(a2);
                            forceConstParent = fs2;
                        }
                        if (!margs->empty())
                            mfc->Tf_call_args(margs);
                        return mfc;
                    }
                }
                auto it = subMap.find(&sub);
                // § elabInstCallDefSub — ANY call in an ELAB instance body
                // binds the shared DEF function (the elab view lists it and
                // Surelog's kept func_call points at it) rather than an empty
                // shell.  slang gives every instance body its own
                // SubroutineSymbol, so only the FIRST instance — the one
                // emitModuleDef compiled the definition from — was in subMap;
                // every further instance minted a nameless shell, which also
                // left `si.argTs` empty and therefore dropped the formal-
                // typespec stamp on every actual (the stamp block requires
                // `argIdx < si.argTs.size()`).  Rggen: 252 `rggen_bit_field`
                // instances, 251 of them binding a shell — the single largest
                // gen-tree cluster (717 census lines).  The param-init arm
                // this generalises was the same law seen through one context.
                // Repro r10rggen8repro/t1.sv: `leaf` instantiated three times,
                // golden binds `work@leaf.mix` and stamps `logic_typespec@10:5`
                // in ALL three, ours only in u0.
                if (it == subMap.end() && !(inParamInit && paramInitDef))
                    if (auto psc9 = sub.getParentScope();
                        psc9 && psc9->asSymbol().kind == SymbolKind::InstanceBody) {
                        auto dit9 = defSubByName.find(std::make_pair(
                            (const Symbol*)&psc9->asSymbol()
                                .as<InstanceBodySymbol>()
                                .getDefinition(),
                            std::string(sub.name)));
                        if (dit9 != defSubByName.end())
                            it = subMap.find(dit9->second);
                    }
                if (it == subMap.end()) {
                    // Calls seen before the def fill (param inits): create a
                    // shell now; emitTaskFuncs fills it later.
                    auto pscope = sub.getParentScope();
                    if (pscope && (pscope->asSymbol().kind == SymbolKind::InstanceBody ||
                                   pscope->asSymbol().kind == SymbolKind::Package)) {
                        SubInfo shell;
                        shell.tf = sub.subroutineKind == SubroutineKind::Function
                                       ? (UHDM::task_func*)s.MakeFunction()
                                       : (UHDM::task_func*)s.MakeTask();
                        shell.tf->VpiName(sub.name);
                        tfShells.insert(shell.tf);
                        it = subMap.emplace(&sub, shell).first;
                    }
                    else if (pscope && pscope->asSymbol().kind ==
                                           SymbolKind::GenerateBlock) {
                        // Def-view gen contents compile before the gen
                        // function exists: a name-only, unlinked call.
                        auto* fc0 = sub.subroutineKind == SubroutineKind::Function
                                        ? (UHDM::tf_call*)s.MakeFunc_call()
                                        : (UHDM::tf_call*)s.MakeTask_call();
                        fc0->VpiName(sub.name);
                        fc0->VpiParent(parent);
                        setLoc(fc0, expr.sourceRange);
                        return fc0;
                    }
                    // § classCallNoLink12 — an IMPLICIT-`this` call to a class
                    // method that this view has not emitted yet.  Every other
                    // scope kind above had a fallback; a CLASS had none, so
                    // the whole call — arguments and all — was DROPPED (the
                    // `unsupported constructs` summary's "user function call":
                    // 931 hits on SeqDriver after § staticScopedCall12, in 777
                    // distinct source lines, `uvm_report_info` / `m_trigger`
                    // / `exec_func` and friends).  Surelog never links a class
                    // method call anyway — t6's `bm(1)` / `xm(2)` (inherited
                    // and out-of-body) are both plain `func_call`s carrying
                    // their arguments and NO vpiFunction — so the unresolved
                    // case emits exactly what the resolved one does.
                    else if (pscope &&
                             pscope->asSymbol().kind == SymbolKind::ClassType) {
                        // ALWAYS a func_call, even when the callee is a TASK:
                        // Surelog is single-pass, so a name it has not seen yet
                        // has no kind to go on and it defaults to func_call.
                        // t8 pins the whole three-way split in ONE class —
                        // `early(a)` (task, already declared) -> task_call +
                        // vpiTask, `efun(a)` (function) -> func_call +
                        // vpiFunction, `lateT(a)` (task declared BELOW the
                        // caller) -> func_call with NO link.
                        auto* fc0 = (UHDM::tf_call*)s.MakeFunc_call();
                        fc0->VpiName(sub.name);
                        fc0->VpiParent(parent);
                        // § callParenSpan11 — a no-arg call's slang range stops
                        // at the callee name; the written invocation runs
                        // through the closing paren.
                        SourceRange cr12 = expr.sourceRange;
                        if (expr.syntax) {
                            auto sr12 = expr.syntax->sourceRange();
                            if (sr12.start() == cr12.start() &&
                                sr12.end() > cr12.end())
                                cr12 = sr12;
                        }
                        setLoc(fc0, cr12);
                        auto* cargs = s.MakeAnyVec();
                        // § blockLocalSameCtrlDepthArgBinds57 — THE §53 GATE,
                        // ADDED AT INTEGRATION (verifier FINDING 1, a SHIPPED
                        // over-fire with real corpus reach).  This window was
                        // opened UNGATED, which was harmless while
                        // § controlBodyNoBind28 suppressed every block-local
                        // binding at depth > 0 — and stopped being harmless the
                        // moment pass 57 carved §28 open for block-locals in an
                        // argument list.  § classInBodyBareCallArgStmtOnly53
                        // restricts that window to STATEMENT position for an
                        // in-body class method, and only the site below (grep
                        // `ClassArgBindIf38 cab12`) was applying it.
                        // WITNESS in the corpus, uvm_pkg.sv 75319-75322 inside
                        // `foreach (m_regs_by_offset[i]) begin uvm_reg rg = …`:
                        //   `get_reg_map_info(rg)` at 75321:46 is EXPRESSION
                        //      position -> golden BARE, we bound it (over-fire)
                        //   `m.add_reg(rg, …)` at 75322:15 is STATEMENT
                        //      position -> golden BINDS, and so do we (correct)
                        // 4 over-fired vpiActual edges out of 345 new bindings,
                        // on BuildUVMPkg in both modes, and NOT cmp-visible —
                        // no gate the pass ran could see it.  This branch is
                        // § classCallNoLink12, reached when the callee is not yet
                        // in `subMap`: `get_reg_map_info` is `extern virtual`
                        // DEFINED OUT-OF-BODY BELOW ITS CALLER, which is why the
                        // in-body arm's gate never applied.  Arm v3_exprsib.sv
                        // cells D8a/D8c/D8d (callee declared BELOW, in operand
                        // and nested-call position) are the witnesses; D1a/D1b
                        // (callee above) are the positive controls.
                        // `callStmtCtx0`, NOT the member `callStmtContext`,
                        // which is cleared at the top of this `case`.
                        ClassArgBindIf38 cab12(
                            classArgBindDepth12,
                            callStmtCtx0 || !(curSubClassScope9 && !curSubOob9));
                        // § writtenCallArgs16 — only the actuals WRITTEN at
                        // the call site; a defaulted formal is slang's, not
                        // Surelog's.
                        for (auto arg : writtenArgs16(call)) {
                            if (arg->kind == ExpressionKind::Assignment) {
                                auto& ae0 = arg->as<AssignmentExpression>();
                                if (ae0.right().kind ==
                                    ExpressionKind::EmptyArgument)
                                    arg = &ae0.left();
                            }
                            if (auto* a0 = emitExpr(*arg, fc0, prefix, netMap))
                                cargs->push_back(a0);
                        }
                        if (!cargs->empty())
                            fc0->Tf_call_args(cargs);
                        return fc0;
                    }
                    // A DPI import declared at COMPILATION-UNIT scope is not
                    // in the model at all (see emitTaskFuncs), so its calls
                    // carry their ARGUMENTS but NO vpiFunction link
                    // (DelayAssign; the same import inside a module binds
                    // normally).
                    else if (pscope &&
                             pscope->asSymbol().kind ==
                                 SymbolKind::CompilationUnit &&
                             (sub.flags & MethodFlags::DPIImport) !=
                                 MethodFlags::None) {
                        auto* fc0 = sub.subroutineKind == SubroutineKind::Function
                                        ? (UHDM::tf_call*)s.MakeFunc_call()
                                        : (UHDM::tf_call*)s.MakeTask_call();
                        fc0->VpiName(sub.name);
                        fc0->VpiParent(parent);
                        setLoc(fc0, expr.sourceRange);
                        auto* uargs = s.MakeAnyVec();
                        // § writtenCallArgs16 — only the actuals WRITTEN at
                        // the call site; a defaulted formal is slang's, not
                        // Surelog's.
                        for (auto arg : writtenArgs16(call)) {
                            // Output args come wrapped as
                            // Assignment(lval, Empty) — unwrap as the bound
                            // path does.
                            if (arg->kind == ExpressionKind::Assignment) {
                                auto& ae0 = arg->as<AssignmentExpression>();
                                if (ae0.right().kind ==
                                    ExpressionKind::EmptyArgument)
                                    arg = &ae0.left();
                            }
                            if (auto* a0 = emitExpr(*arg, fc0, prefix, netMap))
                                uargs->push_back(a0);
                        }
                        if (!uargs->empty())
                            fc0->Tf_call_args(uargs);
                        return fc0;
                    }
                    else {
                        noteUnsupportedAt("user function call",
                                          expr.sourceRange.start());
                        return nullptr;
                    }
                }
                auto& si = it->second;
                // A module that IMPORTS a package binds the package's
                // ELABORATED twin, whose return/formal typespecs are the
                // FOLDED elab typedefs (Surelog; rp32 dec32). Calls emitted
                // INSIDE a package keep their own view's object.
                UHDM::task_func* siTf = si.tf;
                if (!curPkgEmitSym)
                    if (auto eit9 = pkgElabSubTf.find(&sub);
                        eit9 != pkgElabSubTf.end() && eit9->second)
                        siTf = eit9->second;
                bool isFunc = sub.subroutineKind == SubroutineKind::Function;
                // An IN-CLASS body calling a method it INHERITED from a base
                // class: Surelog compiles the class body knowing only that
                // class's OWN methods, so the name falls through to the
                // generic call form — a func_call with no binding, even when
                // the callee is a task. A call to a method of the SAME class
                // still binds its task/function (ClassFsm: `from_state_00`
                // calls `next_state_transition` from baseFsm as an unbound
                // func_call, while `main_comb` calls its sibling
                // `from_state_00` as a bound task_call).
                //
                // The same fall-through catches an OUT-OF-BODY definition
                // calling a method of ITS OWN class: Surelog compiles that
                // body in the home PACKAGE's scope, so no class method is in
                // scope at all (LAW C, golden r10uvm7/c2 — `function int
                // C::oobCallsInl(); return inl(); endfunction` leaves `inl`
                // unbound and renders a task call `inlt()` as a func_call,
                // while the byte-identical in-class twin in c1 binds both).
                // This is the SeqDriver head: UVM's big classes
                // (uvm_component, uvm_reg, uvm_mem, uvm_reg_map) are
                // extern-declared throughout, so golden leaves 3595 of its
                // 8560 func_calls unbound where we bound all but 193.
                //
                // An EXPLICITLY QUALIFIED static call (`uvm_root::get()`)
                // is the exception in both shapes: the qualifier is its own
                // lookup and always resolves (golden binds all 23 of them,
                // from package, module and class-method sites alike).
                bool qualCall9 = false;
                if (auto* csyn9 = expr.syntax) {
                    if (auto* iv9 =
                            csyn9->as_if<syntax::InvocationExpressionSyntax>())
                        csyn9 = iv9->left;
                    qualCall9 =
                        csyn9 &&
                        csyn9->kind == syntax::SyntaxKind::ScopedName;
                }
                bool inheritedNoBind9 = false;
                if (currentSubSym && curSubClassScope9 && !qualCall9)
                    if (auto* callee9 = sub.getParentScope())
                        if (auto* caller9 = currentSubSym->getParentScope())
                            inheritedNoBind9 =
                                callee9->asSymbol().kind ==
                                    SymbolKind::ClassType &&
                                caller9->asSymbol().kind ==
                                    SymbolKind::ClassType &&
                                (curSubOob9
                                     ? true
                                     : (classMethodNoBind &&
                                        &callee9->asSymbol() !=
                                            &caller9->asSymbol()));
                // LAW C's fall-back arm: a class lookup that fails does not
                // stop there — Surelog keeps walking OUT to the enclosing
                // package/module and binds a free subroutine of the same
                // name if one exists.  UVM leans on this everywhere:
                // `uvm_report_warning(...)` inside a uvm_root method resolves
                // in slang to the INHERITED uvm_report_object method, but
                // golden binds `uvm_pkg::uvm_report_warning`, the package
                // function (640 objects in SeqDriver, all
                // callee=pkg:uvm_pkg).  The fall-back keeps the call's own
                // kind, so a package TASK found this way stays a task_call.
                if (inheritedNoBind9) {
                    const Scope* osc9 = currentSubSym->getParentScope();
                    while (osc9 && osc9->asSymbol().kind ==
                                       SymbolKind::ClassType)
                        osc9 = osc9->asSymbol().getParentScope();
                    const Symbol* fb9 = nullptr;
                    if (osc9 &&
                        (osc9->asSymbol().kind == SymbolKind::Package ||
                         osc9->asSymbol().kind == SymbolKind::InstanceBody))
                        if (auto* f9 = osc9->find(sub.name);
                            f9 && f9->kind == SymbolKind::Subroutine)
                            fb9 = f9;
                    if (fb9)
                        if (auto fit9 = subMap.find(fb9);
                            fit9 != subMap.end() && fit9->second.tf) {
                            siTf = fit9->second.tf;
                            if (!curPkgEmitSym)
                                if (auto e8 = pkgElabSubTf.find(fb9);
                                    e8 != pkgElabSubTf.end() && e8->second)
                                    siTf = e8->second;
                            isFunc = fb9->as<SubroutineSymbol>()
                                         .subroutineKind ==
                                     SubroutineKind::Function;
                            inheritedNoBind9 = false;
                        }
                }
                // § defGenCallNoBind — a call inside a DEF-view generate-block
                // PROCESS takes the same generic form. Surelog stmt-ifies a
                // def-view generate body from SYNTAX, with no symbol table to
                // resolve the callee against, so the call comes out as a bare
                // func_call carrying only vpiName — no vpiFunction, and NOT a
                // task_call even when the callee is a task. The def-view gen
                // CONT-ASSIGN path already emits from syntax (TypeEmit's
                // module-compile arm) and was therefore already right; the
                // process path re-emits the AST and was binding.
                // Repro r10rggen7repro/t2.sv (function) + t3.sv (task): both
                // shapes, module-level sibling bound in the same module.
                // Rggen: rggen_adapter_common:89 get_local_address.
                // § defGenQualPkgCallBinds18 (r10earl18) CORRECTS the law
                // above: the no-bind rule is the UNQUALIFIED rule.  fc18.sv
                // puts six calls in one def-view gen_if — cont-assign and
                // always_comb x qualified package / wildcard-imported package
                // / module-local — and golden binds vpiFunction on exactly the
                // two QUALIFIED rows.  The `isFunc = true` coercion below is
                // untouched, so the bind is taken only when the callee really
                // is a function (a coerced task_call would be a bad cast).
                const bool realIsFunc18 = isFunc;
                if (inheritedNoBind9 || defGenProcessEmit)
                    isFunc = true;
                UHDM::tf_call* fc = isFunc ? (UHDM::tf_call*)s.MakeFunc_call()
                                           : (UHDM::tf_call*)s.MakeTask_call();
                // Reachability bookkeeping for the in-body operation-arg
                // stamp (drainBodyOpArgTs): a call emitted OUTSIDE any
                // task/func body is a live ENTRY POINT into `sub`. A call
                // that constant-folded away never reaches here at all, which
                // is exactly the distinction Surelog draws.
                // The DEF-view cont-assign (contAssignView == 1) keeps the
                // call Surelog's ELAB view folds away, so it is not evidence
                // of reachability — only the elab/top view counts.
                // (What the entry point reaches from there is NOT every call
                // the bodies contain but what the evaluator runs — the drain
                // closes over § evalReachedCallees instead.)
                // § liveCallEntryIsContAssignRhs (r10earl6) — and an entry
                // point is only the shape Surelog's evaluator actually runs
                // from: a call that IS the whole rhs of a continuous
                // assignment.  This is the SAME trigger
                // § subCalledAsContAssignRhs already records for the fill-size
                // rule ("assign a = f(x)" evaluates f; "assign a = f(x) ^
                // g(y)", a ternary operand and a procedural rhs do not), and
                // the stamp obeys it too.  Measured on pp.sv, one file, five
                // rows: golden stamps EVERY operation actual inside
                // FuncArgs' `pow_a` (whose only caller is `assign out1 =
                // pow_a(inp, 3);`) and NOT ONE anywhere in pp.sv, where the
                // identical package function, the identical MODULE-local
                // function and even a byte-for-byte copy of pow_a itself are
                // all called as operands of a `^`.  11 Earlgrey AllModules
                // heads + 2 TopPackages — the biggest remaining class —
                // are aes_sbox_canright_pkg's aes_mul_gf2p4, called only
                // from always_comb bodies.
                // § parensLessFuncRefIsRefObj — SITE 2 of 2 of this pass's
                // parentheses law, and the SVSwitch head § parensLessCallIsPathRefObj
                // uncovered.  A RECEIVER-LESS reference to a FUNCTION written
                // WITHOUT an argument list (`cal_fcs`, SVSwitch Packet.sv:65 /
                // :77 / :91) is not a call to Surelog either: it is a plain
                // scope-scoped `ref_obj` spanning the NAME TOKEN, with no
                // vpiFunction bind.  The identical call WITH parens — even
                // EMPTY parens, `zero()` — stays a func_call, and a TASK in
                // statement position (`void_t;`) stays a task_call whether or
                // not the parens are written.  All seven cells measured side by
                // side on ONE golden in arm s7_recvless.sv; `realIsFunc18` is
                // the gate that keeps tasks out (`isFunc` is coerced to true
                // above for the def-gen / no-bind paths and would mis-classify
                // a task_call here).
                // The liveCalledSubs bookkeeping above is deliberately LEFT
                // RUNNING before this early return: reachability is a property
                // of the call site, not of the object class we emit for it.
                // THE TEST IS ON THE SOURCE TEXT, NOT ON expr.syntax — see
                // § parensLessSyntaxKindRefuted at the site-1 comment: inside a
                // CAST the syntax pointer is not the invocation, and this exact
                // site is where that cost four u2r rows.  The gate is the
                // TIGHTEST form of the observation: the call's whole source text
                // is EXACTLY the subroutine name, so `zero()` (empty parens),
                // `one(4)` and `pkg::f` are all excluded.
                // STATEMENT-POSITION GATE, ADDED AT INTEGRATION (the verifier's
                // F1, and it was a REGRESSION from a cell that already matched
                // golden).  `realIsFunc18` keeps TASKS out but nothing kept
                // STATEMENTS out, and the law is about EXPRESSION position: a
                // parens-less FUNCTION called as a whole statement (`zero;`) is
                // a `func_call` in golden, exactly as `zero();` is.  Arm
                // v1_stmtfunc.sv cell 1 is the witness (golden and pristine both
                // `func_call: (zero) 15:5-15:9`; without this clause we emitted
                // `ref_obj: (work@sf::g::zero)`).  s7_recvless measured a
                // parens-less TASK in statement position and a parens-less
                // FUNCTION in expression position — the product cell was the
                // empty square of the grid, and it was the only one with no
                // guard.  `callStmtCtx0` and NOT `callStmtContext`: the flag is
                // saved and CLEARED at the top of this `case` (grep
                // `callStmtCtx0 = callStmtContext`), so by here the member is
                // always false and reading it would be a guard that cannot fire.
                if (realIsFunc18 && !callStmtCtx0 &&
                    rawText(expr.sourceRange) == sub.name) {
                    auto* rf9 = s.MakeRef_obj();
                    rf9->VpiName(sub.name);
                    rf9->VpiFullName(joinRef(prefix, std::string(sub.name)));
                    rf9->VpiParent(parent);
                    setLoc(rf9,
                           nameSpan(expr.sourceRange.start(), sub.name));
                    return rf9;
                }
                fc->VpiName(sub.name);
                fc->VpiParent(parent);
                // Param-init calls and LHS bit-select INDEX calls
                // (intermediate[depth2Index(1)] = ...) anchor at the name.
                if (inParamInit || inLhs)
                    setLoc(fc, nameSpan(expr.sourceRange.start(), sub.name));
                else
                    setLoc(fc, expr.sourceRange);
                // Package functions: qualified calls carry the scoped name
                // and anchor at the package-name token only.
                // § defGenQualPkgCallBinds18 — and the WRITTEN QUALIFIER is
                // also what decides whether a def-view gen-block call binds.
                bool qualPkgCall18 = false;
                UHDM::function* boundClone = nullptr;
                if (auto ps2 = sub.getParentScope();
                    ps2 && ps2->asSymbol().kind == SymbolKind::Package) {
                    std::string pkgName(ps2->asSymbol().name);
                    std::string raw = rawText(expr.sourceRange);
                    // A call QUALIFIED through an IMPORTING package
                    // (P::f() where P imports f from its home package): carry
                    // the written qualifier, anchor at it, and bind P's CLONE
                    // (not the shared home function) — no module Task_funcs.
                    std::string wqual;
                    if (auto qp = raw.find("::"); qp != std::string::npos)
                        wqual = raw.substr(0, qp);
                    const PackageSymbol* qpkg =
                        (!wqual.empty() && wqual != pkgName) ? comp.getPackage(wqual)
                                                             : nullptr;
                    if (qpkg && isFunc) {
                        auto cit = importCopyFunc.find({qpkg, &sub});
                        if (cit != importCopyFunc.end())
                            boundClone = cit->second;
                    }
                    if (raw.rfind(pkgName + "::", 0) == 0) {
                        fc->VpiName(pkgName + "::" + std::string(sub.name));
                        setLoc(fc, nameSpan(expr.sourceRange.start(), pkgName));
                        qualPkgCall18 = true;
                    }
                    else if (boundClone) {
                        fc->VpiName(wqual + "::" + std::string(sub.name));
                        setLoc(fc, nameSpan(expr.sourceRange.start(), wqual));
                        qualPkgCall18 = true;
                    }
                    else if (currentScope && siTf) {
                        // Import-resolved call: the module lists the shared
                        // package function in its own Task_funcs; a call from
                        // a GEN-SCOPE conn also registers at the enclosing
                        // instance body.
                        auto& v2 = importedTfCalls[currentScope];
                        bool have9 = false;
                        for (auto& pr9 : v2)
                            if (pr9.first == siTf)
                                have9 = true;
                        if (!have9)
                            v2.push_back({siTf, expr.sourceRange});
                    }
                }
                // NOT DONE, measured and rejected: naming a static class call
                // with its written qualifier (`fc->VpiName("uvm_root::get")`).
                // Golden carries exactly 5 such names (uvm_root::get,
                // uvm_{reg,reg_field,mem}::get_max_size,
                // uvm_pkg::m_uvm_string_queue_join = 23 objects in SeqDriver)
                // and every one of them sits in a PACKAGE-scope variable
                // initializer or a package body — inside a class method
                // Surelog renders the same spelling as something other than a
                // named func_call (its method_func_call count runs 428 above
                // ours).  Qualifying unconditionally MINTED 290 wrong names
                // (uvm_coreservice_t::get alone 143, golden 0), so the rule is
                // NOT "qualified spelling keeps the qualifier"; decode where
                // the other spelling goes before trying again.
                if ((inheritedNoBind9 || defGenProcessEmit) &&
                    !(qualPkgCall18 && realIsFunc18)) {
                    // name only — no vpiFunction / vpiTask (§ defGenCallNoBind,
                    // narrowed to the UNQUALIFIED case by
                    // § defGenQualPkgCallBinds18)
                }
                else if (isFunc)
                    ((UHDM::func_call*)fc)->Function(
                        boundClone ? boundClone : (UHDM::function*)siTf);
                else
                    ((UHDM::task_call*)fc)->Task((UHDM::task*)siTf);
                auto* args = s.MakeAnyVec();
                size_t argIdx = 0;
                // slang materialises a DEFAULTED formal as a full argument
                // expression (located at the declaration's default). Surelog
                // lists only the arguments actually WRITTEN — probe-verified
                // for tasks and functions at every arity (r10apb3 repro 9),
                // and the reason ApbSlave's `write(addr, data)` carries two
                // arguments, not five.
                size_t nWritten9 = call.arguments().size();
                // A NAMED-ARGUMENT call (`f(.b(x), .a(y))`) stamps NO
                // formal-typespec ref on any actual: Surelog binds a named
                // actual through the connection's own name lookup and never
                // writes the formal's typespec back onto it, where the
                // positional form does.  EvalFuncNamed is the discriminator
                // pair in one design — `simple_minus(.value2(value2),
                // .value1(value1))` leaves both ref actuals bare in every
                // listing, while u2r NestedCallsOfTheSameFunction's
                // positional `aes_mul2(aes_mul2(x))` stamps both the nested
                // call and the `x` ref with the same `int` formal.
                bool namedArgs9 = false;
                if (auto* isy9 =
                        expr.syntax
                            ? expr.syntax->as_if<syntax::InvocationExpressionSyntax>()
                            : nullptr) {
                    nWritten9 =
                        isy9->arguments ? isy9->arguments->parameters.size() : 0;
                    if (isy9->arguments)
                        for (auto* pa9 : isy9->arguments->parameters)
                            if (pa9->kind == syntax::SyntaxKind::NamedArgument)
                                namedArgs9 = true;
                }
                callArgDepth++;
                // § genProcParamFoldQualCallArg20 — see UhdmExporter.h.  The
                // qualifier is read off the WRITTEN syntax (the same test
                // qualCall9 uses above), not off the callee's home scope: a
                // WILDCARD-imported package function called unqualified keeps
                // its arguments symbolic (pu20.sv row Q2) exactly like a
                // module-local one.
                bool savedQCA20 = qualCallArg20;
                {
                    auto* qsyn20 = expr.syntax;
                    if (qsyn20)
                        if (auto* iv20 = qsyn20->as_if<
                                syntax::InvocationExpressionSyntax>())
                            qsyn20 = iv20->left;
                    qualCallArg20 =
                        qsyn20 &&
                        qsyn20->kind == syntax::SyntaxKind::ScopedName;
                }
                // NOTE § classInBodyBareCallArgStmtOnly53 — GATE: inside an
                // IN-BODY class method (curSubClassScope9 && !curSubOob9) the
                // § classArgBind12 window opens for a BARE (receiver-less) call
                // in STATEMENT POSITION ONLY (callStmtCtx0).  DIRECTION:
                // SUPPRESS (the window simply is not opened; nothing else
                // changes, and classArgBindDepth12 has exactly one reader).
                //
                // § classArgBind12 was decoded from `sink(f);` and
                // `if (sink(f))` and had an UNMEASURED HALF: every other
                // EXPRESSION spelling.  Arm a4's ib53 reads nine cells off ONE
                // golden — line numbers are a4/dut.sv:
                //   51 `self53(f);`             STATEMENT      golden io_decl
                //   52 `if (self53(f) == 0)`    if-CONDITION   golden io_decl
                //   54 `loc = self53(f);`       r-value        golden NONE
                //   55 `loc = self53(f) + 1;`   operand        golden NONE
                //   56 `loc = self53(self53(f))` nested        golden NONE
                //   57 `while (self53(f) == 99)` while-COND    golden NONE
                //   63 `return self53(f) + loc` return         golden NONE
                // The if-CONDITION cell still binds with the window CLOSED,
                // because StmtEmit's if/if_else/case arms clear
                // `classMethodNoBind` outright ("condition refs DO bind") —
                // and the WHILE condition, which does not clear it, is exactly
                // the cell that shows this is the right mechanism rather than a
                // second condition carve-out.
                // The OUT-OF-BODY twins (a4 ob53, all seven) and the PACKAGE
                // twins (a4 pk_all) are golden io_decl and keep the window.
                ClassArgBindIf38 cab12(
                    classArgBindDepth12,
                    callStmtCtx0 || !(curSubClassScope9 && !curSubOob9));
                for (auto arg : call.arguments()) {
                    if (argIdx >= nWritten9)
                        break;
                    // Output args come wrapped as Assignment(lval, Empty).
                    if (arg->kind == ExpressionKind::Assignment) {
                        auto& ae = arg->as<AssignmentExpression>();
                        if (ae.right().kind == ExpressionKind::EmptyArgument)
                            arg = &ae.left();
                    }
                    // Direct literal args are parented at the call.
                    bool forceSaved = forceConstParent;
                    if (isLiteralExpr(*arg))
                        forceConstParent = true;
                    auto* a = emitExpr(*arg, fc, prefix, netMap);
                    forceConstParent = forceSaved;
                    // An UNBASED-UNSIZED literal arg ('1): the def-view
                    // cont-assign copy stays bare (no formal-ts ref); the elab
                    // copy folds to the formal's width (repeated digit BIN).
                    bool unbasedArg =
                        stripImplicitConv(*arg).kind ==
                        ExpressionKind::UnbasedUnsizedIntegerLiteral;
                    if (unbasedArg && contAssignView == 2 && a &&
                        a->UhdmType() == UHDM::uhdmconstant && arg->type) {
                        logic_t ab = stripImplicitConv(*arg)
                                         .as<UnbasedUnsizedIntegerLiteral>()
                                         .getLiteralValue();
                        if (!ab.isUnknown()) {
                            int32_t w = (int32_t)arg->type->getBitWidth();
                            std::string digits((size_t)w, ab.value ? '1' : '0');
                            auto* ac = (UHDM::constant*)a;
                            ac->VpiDecompile(digits);
                            ac->VpiSize(w);
                            ac->VpiValue("BIN:" + digits);
                        }
                    }
                    // The ELAB view of a param-init func_call Surelog keeps
                    // SYMBOLIC still has its actuals FOLDED (elaboration
                    // substitutes param refs by value, and evalFunc's arg
                    // binding then stamps the formal's typespec onto the
                    // in-tree constant): func_upto's kept F(A_CONST, B_CONST)
                    // carries two UINT constants, not A_CONST/B_CONST refs.
                    bool elabParamArgFold = false;
                    if (inParamInit && !paramInitDef && !paramInitPkg &&
                        isFunc && !currentTf && callArgDepth == 1 && a &&
                        a->UhdmType() == UHDM::uhdmref_obj) {
                        auto& ba9 = stripImplicitConv(*arg);
                        if (ba9.kind == ExpressionKind::NamedValue &&
                            ba9.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter) {
                            auto& psy9 = ba9.as<NamedValueExpression>()
                                             .symbol.as<ParameterSymbol>();
                            auto& pv9 = psy9.getValue();
                            // Reduce::No on the ENCLOSING multidimensional
                            // parameter does not stop instance parameter
                            // binding: a reference whose parameter already
                            // HOLDS an elaborated constant is still replaced by
                            // it (probe t8: `bit [3:0][15:0] Q2 = g2(N, W)`
                            // substitutes the port param N AND the plain
                            // localparam W).  What it cannot do is REDUCE — so
                            // a reference to a parameter whose own Rhs stayed a
                            // func_call is left as the ref_obj (FuncInModule
                            // `get_offset_list(SUB_N_LIST_P)`).
                            bool refSymCall9 = false;
                            if (elabMdimParamInit) {
                                auto rit9 = paramRhsObj.find(&psy9);
                                refSymCall9 =
                                    rit9 != paramRhsObj.end() && rit9->second &&
                                    rit9->second->UhdmType() ==
                                        UHDM::uhdmfunc_call;
                            }
                            if (!refSymCall9 && pv9.isInteger() &&
                                !pv9.integer().hasUnknown()) {
                                auto* c9 = s.MakeConstant();
                                // A MULTIDIMENSIONAL parameter has no folded
                                // constant of its own to hand over (its own
                                // param_assign Rhs stayed symbolic, Reduce::No),
                                // so evalFunc materialises the value it computed
                                // for the binding as a plain BIN vector at the
                                // parameter's width — measured on
                                // `int R5 = hbad(R3)` with
                                // `bit [3:0][15:0] R3` (r10fim probe t5): a
                                // 64-digit BIN, against `bit [63:0] R4`'s
                                // INT/UINT hand-over one line below.
                                if (packedDimCountE(psy9.getType()) > 1) {
                                    int32_t w9 =
                                        (int32_t)psy9.getType().getBitWidth();
                                    if (w9 <= 0)
                                        w9 = (int32_t)pv9.integer().getBitWidth();
                                    auto wv9 =
                                        pv9.integer().resize((bitwidth_t)w9);
                                    std::string bits9;
                                    for (int32_t i9 = w9 - 1; i9 >= 0; i9--)
                                        bits9 += wv9[i9] == logic_t(1) ? '1' : '0';
                                    c9->VpiDecompile(bits9);
                                    c9->VpiSize(w9);
                                    c9->VpiValue("BIN:" + bits9);
                                    c9->VpiConstType(vpiBinaryConst);
                                }
                                else {
                                    std::string dg9 = pv9.integer().toString(
                                        LiteralBase::Decimal, false);
                                    c9->VpiDecompile(dg9);
                                    c9->VpiSize(
                                        (int32_t)pv9.integer().getBitWidth());
                                    c9->VpiValue("UINT:" + dg9);
                                    c9->VpiConstType(vpiUIntConst);
                                }
                                c9->VpiParent(fc);
                                setLoc(c9, arg->sourceRange);
                                a = c9;
                                elabParamArgFold = true;
                            }
                        }
                    }
                    if (a) {
                        // Function call arg refs carry a typespec ref to the
                        // formal's typespec (tasks don't; procedural-context
                        // calls don't either).
                        bool refArg = a->UhdmType() == UHDM::uhdmref_obj ||
                                      a->UhdmType() == UHDM::uhdmbit_select ||
                                      a->UhdmType() == UHDM::uhdmpart_select ||
                                      a->UhdmType() == UHDM::uhdmindexed_part_select;
                        // A SYS-call arg counts too: ExprEval::evalFunc stamps
                        // the formal's typespec onto every actual BEFORE it
                        // discovers it cannot evaluate the body, so the stamp
                        // survives on a call that stays symbolic
                        // (const_func: negate($floor(W / X))).
                        bool otherArg = a->UhdmType() == UHDM::uhdmconstant ||
                                        a->UhdmType() == UHDM::uhdmfunc_call ||
                                        a->UhdmType() == UHDM::uhdmsys_func_call ||
                                        a->UhdmType() == UHDM::uhdmoperation;
                        // A nested call to a PASS-THROUGH function (its return
                        // value IS one of its formals) is substituted by
                        // Surelog for typing, so the call node itself carries
                        // no formal-ts ref (the stamp falls through to the
                        // substituted argument) — const_arg_loop's
                        // operation1(pass_through(A), a). A computed nested
                        // return (flip = ~inp) keeps the stamp (const_fold_func).
                        if (a->UhdmType() == UHDM::uhdmfunc_call) {
                            auto& ncall = stripImplicitConv(*arg);
                            if (ncall.kind == ExpressionKind::Call &&
                                !ncall.as<CallExpression>().isSystemCall())
                                if (auto nsub = std::get_if<const SubroutineSymbol*>(
                                        &ncall.as<CallExpression>().subroutine))
                                    if (*nsub && isPassThroughFunc(**nsub))
                                        otherArg = false;
                        }
                        // Only outermost-call CONSTANT/operation args carry
                        // formal-ts refs (REF args carry them at any nesting
                        // depth); def-view PACKAGE function bodies never do
                        // (top pkg copies re-attach them), while MODULE
                        // function bodies attach like any other context.
                        // Formals of a PREDEFINED integer type (int i) keep
                        // 64-bit constants and take no in-function ts ref;
                        // VECTOR formals ([3:0] inp) size their constant args
                        // and carry the ts ref even inside function bodies.
                        bool intFormal =
                            arg->type && arg->type->getCanonicalType().kind ==
                                             SymbolKind::PredefinedIntegerType;
                        // A ref arg that names a PARAMETER/localparam (its
                        // referent is a param, not a net/var) carries no
                        // formal-ts stamp in module/elab context — Surelog
                        // stamps only net/var refs, part-selects and constants
                        // (const_arg_loop: operationN(A,...) A refs are bare).
                        bool paramRef = false;
                        {
                            const Expression& baseArg = stripImplicitConv(*arg);
                            if (baseArg.kind == ExpressionKind::NamedValue) {
                                auto sk =
                                    baseArg.as<NamedValueExpression>().symbol.kind;
                                paramRef = (sk == SymbolKind::Parameter ||
                                            sk == SymbolKind::EnumValue);
                                // ...but the DEF-view param object itself has
                                // its OWN typespec ref REBOUND to the formal's
                                // typespec: Surelog's argument binding writes
                                // through the parameter's ts ref, so the LAST
                                // cont-assign call taking the param as a direct
                                // actual wins.  Procedural calls never rebind.
                                // § elabParamTsRebind: the rebound typespec is
                                // remembered per DECLARATION so every elab
                                // instance but the first can inherit it (see
                                // the note on defParamTsRebound).
                                if (contAssignView == 1 && isFunc && !currentTf &&
                                    sk == SymbolKind::Parameter &&
                                    argIdx < si.argTs.size() &&
                                    si.argTs[argIdx].first) {
                                    auto& psym9 =
                                        baseArg.as<NamedValueExpression>().symbol;
                                    auto dpit = defParamTsRef.find(&psym9);
                                    if (dpit != defParamTsRef.end() && dpit->second) {
                                        dpit->second->Actual_typespec(
                                            si.argTs[argIdx].first);
                                        if (auto* dsy9 = psym9.getSyntax())
                                            defParamTsRebound[dsy9] =
                                                si.argTs[argIdx].first;
                                    }
                                }
                                // ...and in the ELAB view of a parameter
                                // initializer the same binding writes through
                                // to whatever the reference RESOLVES to.  When
                                // the referenced parameter's own Rhs stayed a
                                // symbolic func_call (no value to hand over),
                                // that call IS the resolved object, so it —
                                // not the bare ref actual — ends up carrying
                                // the formal's typespec: FuncInModule's
                                // `get_sub_n_list(N)` Rhs picks up the
                                // `bit [N-1:0][15:0] sub_n_list` typespec of
                                // get_offset_list, the formal SUB_N_LIST_P is
                                // passed to one line below.
                                // Only when the actual STAYED a reference: an
                                // argument the elaborator replaced by the
                                // parameter's value carries the stamp on that
                                // constant instead (NEXT_N's OFFSET_LIST arg),
                                // and get_offset_list's own Rhs call is left
                                // bare in the golden.
                                if (inParamInit && !paramInitDef && isFunc &&
                                    !currentTf && !elabParamArgFold &&
                                    a->UhdmType() == UHDM::uhdmref_obj &&
                                    sk == SymbolKind::Parameter &&
                                    argIdx < si.argTs.size() &&
                                    si.argTs[argIdx].first) {
                                    auto rit = paramRhsObj.find(
                                        &baseArg.as<NamedValueExpression>().symbol);
                                    if (rit != paramRhsObj.end() && rit->second &&
                                        rit->second->UhdmType() ==
                                            UHDM::uhdmfunc_call) {
                                        auto* fcp = (UHDM::func_call*)rit->second;
                                        if (!fcp->Typespec()) {
                                            std::string tsPfx = prefix;
                                            if (tsPfx.size() >= 2 &&
                                                tsPfx.compare(tsPfx.size() - 2, 2,
                                                              "::") == 0)
                                                tsPfx.resize(tsPfx.size() - 2);
                                            auto* rtp = s.MakeRef_typespec();
                                            rtp->VpiFullName(tsPfx);
                                            rtp->VpiParent(fcp);
                                            rtp->Actual_typespec(
                                                si.argTs[argIdx].first);
                                            fcp->Typespec(rtp);
                                        }
                                    }
                                }
                            }
                        }
                        // A func-arg part-SELECT rooted at a PARAMETER (the
                        // folded genvar i[OFF-1:0] in an elab gen-scope, or any
                        // localparam-rooted select) carries no formal-ts stamp:
                        // Surelog stamps net/var-rooted part-selects but leaves
                        // param-rooted ones bare, mirroring the bare direct
                        // param-ref rule (read_remux occurrence-1 arg).
                        bool paramRootSel = false;
                        {
                            const Expression* cur = &stripImplicitConv(*arg);
                            bool sawSel = false;
                            while (cur) {
                                if (cur->kind == ExpressionKind::ElementSelect) {
                                    cur = &cur->as<ElementSelectExpression>()
                                               .value();
                                    sawSel = true;
                                }
                                else if (cur->kind ==
                                         ExpressionKind::RangeSelect) {
                                    cur = &cur->as<RangeSelectExpression>()
                                               .value();
                                    sawSel = true;
                                }
                                else if (cur->kind ==
                                         ExpressionKind::MemberAccess) {
                                    cur = &cur->as<MemberAccessExpression>()
                                               .value();
                                    sawSel = true;
                                }
                                else
                                    break;
                            }
                            if (sawSel && cur &&
                                cur->kind == ExpressionKind::NamedValue) {
                                auto rk =
                                    cur->as<NamedValueExpression>().symbol.kind;
                                paramRootSel = (rk == SymbolKind::Parameter ||
                                                rk == SymbolKind::Genvar ||
                                                rk == SymbolKind::EnumValue);
                            }
                        }
                        // DEF-view cont-assign CONCAT args ({a,b}) carry no
                        // formal-ts ref (patterns '{0,1} keep theirs).
                        bool defOpArg = contAssignView == 1 &&
                                        a->UhdmType() == UHDM::uhdmoperation &&
                                        ((UHDM::operation*)a)->VpiOpType() ==
                                            vpiConcatOp;
                        // A STRUCT/UNION-typed formal's arg ref carries no
                        // formal-ts stamp in pkg fn bodies (Surelog;
                        // jeras_union dec32's imm_b_f(op)).
                        bool structFormal9 =
                            argIdx < si.argTs.size() && si.argTs[argIdx].first &&
                            (si.argTs[argIdx].first->UhdmType() ==
                                 UHDM::uhdmstruct_typespec ||
                             si.argTs[argIdx].first->UhdmType() ==
                                 UHDM::uhdmunion_typespec);
                        // A call NESTED UNDER AN OPERATION inside a
                        // NET-DECL-ASSIGN RHS stamps nothing on its arg refs.
                        // Measured, three calls to the same function in one
                        // module (/tmp/r10yoo_pq):
                        //   wire x = oh(rw);            nda, call IS the RHS
                        //                               -> STAMPED
                        //   wire y = oh(rw) & {16{s}};  nda, call under an op
                        //                               -> bare
                        //   assign q = oh(rw) & {16{s}};explicit CA, same shape
                        //                               -> STAMPED (elab view;
                        //                               the def view is bare)
                        // openmsp430's `wire [15:0] irq_acc_all =
                        // one_hot16(irq_num) & {16{...}}` is the second row —
                        // 6 of YosysOldOpen's 14 remaining vectors.
                        bool ndaOpCallArg9 =
                            ndaRhsEmit && parent &&
                            parent->UhdmType() == UHDM::uhdmoperation;
                        // § r10fsv3 S8.  Same left-to-right abort the
                        // siblingCallArg9 rule below models, one step earlier:
                        // an actual that Surelog cannot reduce stops the
                        // formal-ts stamping for every actual AFTER it, not
                        // just for nested calls.  A member/element SELECT
                        // rooted at the enclosing subroutine's own FORMAL
                        // (`range_check(Cfg.NonIdempotentAddrBase[k],
                        // Cfg.NonIdempotentLength[k], address)` in
                        // FuncStructVal's is_inside_*_regions) is exactly such
                        // an actual, and golden leaves the trailing `address`
                        // bare because of it — while
                        // NestedCallsOfTheSameFunction's `aes_mul2(x)`, whose
                        // formal re-pass is the FIRST actual, is stamped.
                        bool precUnreduced9 = false;
                        {
                            int pi9 = 0;
                            for (auto pa9 : call.arguments()) {
                                if (pi9++ >= (int)argIdx)
                                    break;
                                const Expression* c9 = &stripImplicitConv(*pa9);
                                bool sawSel9 = false;
                                while (true) {
                                    if (c9->kind == ExpressionKind::MemberAccess)
                                        c9 = &stripImplicitConv(
                                            c9->as<MemberAccessExpression>()
                                                .value());
                                    else if (c9->kind ==
                                             ExpressionKind::ElementSelect)
                                        c9 = &stripImplicitConv(
                                            c9->as<ElementSelectExpression>()
                                                .value());
                                    else
                                        break;
                                    sawSel9 = true;
                                }
                                if (sawSel9 &&
                                    c9->kind == ExpressionKind::NamedValue &&
                                    c9->as<NamedValueExpression>().symbol.kind ==
                                        SymbolKind::FormalArgument)
                                    precUnreduced9 = true;
                            }
                        }
                        // § pkgBodyArgTsCalledAsCaRhs (r10earl6) — the
                        // ELABORATED package copy re-attaches its body's
                        // formal-ts refs only for a function Surelog's
                        // evaluator actually RAN, and that is the same
                        // § pkgSubCalledAsContAssignRhs trigger the fill-size
                        // rule uses: a call that IS the whole rhs of a
                        // continuous assignment.  pp.sv reads both halves in
                        // one file — a package function reached only as an
                        // operand of a `^` (and aes_sbox_canright_pkg's
                        // aes_mul_gf2p4, reached only from always_comb
                        // bodies) carries NO stamp anywhere in golden, while
                        // u.sv/w.sv's directly-called package functions do.
                        // ...and a PARAMETER INITIALISER runs the body too —
                        // EvalFunc's `localparam log2RATIO4 =
                        // prim_util_pkg::vbits(RATIO)` is the regression that
                        // proved it (the first cut, cont-assign-only, moved
                        // that test from CMP_EQUAL to CMP_NOTEQUAL).
                        bool pkgBodyEvald9 =
                            !currentSubSym ||
                            pkgSubCalledAsContAssignRhs(*currentSubSym) ||
                            pkgSubEvaluatedFromParamInit(*currentSubSym);
                        bool argCtxOk =
                            !ndaOpCallArg9 && !precUnreduced9 &&
                            (currentTf ? ((pkgTopEmit && !structFormal9 &&
                                          pkgBodyEvald9 &&
                                          !(intFormal &&
                                            a->UhdmType() ==
                                                UHDM::uhdmoperation)) ||
                                         (!pkgScopeInst && callArgDepth == 1 &&
                                          a->UhdmType() == UHDM::uhdmconstant &&
                                          !intFormal))
                                      : (!inLhs && !defOpArg && !portInitCtx &&
                                         (!paramRef || elabParamArgFold) &&
                                         !paramRootSel &&
                                         !(intFormal &&
                                           a->UhdmType() ==
                                               UHDM::uhdmoperation) &&
                                         (refArg || callArgDepth == 1)));
                        // Pkg-scoped param refs (pkg::P) carry no formal ts.
                        bool pkgScopedRef =
                            a->UhdmType() == UHDM::uhdmref_obj &&
                            std::string(((UHDM::ref_obj*)a)->VpiName()).find("::") !=
                                std::string::npos;
                        // A string-literal actual on a STRING formal carries
                        // no formal-ts ref at all (FuncArgsByName).
                        bool strFormalConst =
                            a->UhdmType() == UHDM::uhdmconstant && arg->type &&
                            arg->type->isString();
                        // A MODULE function body's nested call also stamps an
                        // OPERATION actual with the formal's typespec — but
                        // only when the body is REACHED: Surelog's post-elab
                        // pass descends into a function through a func_call
                        // that survived constant reduction, so a function
                        // whose every call folded away keeps its body bare.
                        // FuncArgs is the discriminator pair, one shape twice:
                        //   assign out1 = pow_a(inp, 3) -> call kept -> the
                        //     body's `pow_a(base, exp - 1)` stamps `exp - 1`
                        //   assign out2 = pow_b(2, 2)   -> folds to a constant
                        //     -> the identical `pow_b(base, exp - 1)` is bare
                        // Reachability is only known once the whole design is
                        // emitted, so the stamp is parked (drainBodyOpArgTs).
                        // ...and only when no SIBLING actual of the same call
                        // is itself a user call. Surelog reduces the actuals
                        // left to right and a nested call it cannot evaluate
                        // aborts the attempt before the operation actual is
                        // stamped: const_fold_func's `pow_flip_a(flip(base),
                        // exp - 1)` is bare even though pow_flip_a IS reached
                        // (assign out4 = pow_flip_a(flip(inp), 3) survives),
                        // while FuncArgs' `pow_a(base, exp - 1)` — same shape
                        // minus the nested flip() — is stamped.
                        bool siblingCallArg9 = false;
                        for (auto sa9 : call.arguments()) {
                            auto& sl9 = stripImplicitConv(*sa9);
                            if (sl9.kind == ExpressionKind::Call &&
                                !sl9.as<CallExpression>().isSystemCall())
                                siblingCallArg9 = true;
                        }
                        bool bodyOpArg9 =
                            isFunc && !inProcessEmit && currentTf &&
                            currentSubSym && !pkgTopEmit && !pkgScopeInst &&
                            !propDeclScope && !inLhs && !portInitCtx &&
                            !argCtxOk && callArgDepth == 1 && !intFormal &&
                            !siblingCallArg9 &&
                            a->UhdmType() == UHDM::uhdmoperation &&
                            ((UHDM::operation*)a)->VpiOpType() != vpiConcatOp &&
                            argIdx < si.argTs.size() && si.argTs[argIdx].first;
                        if (bodyOpArg9) {
                            auto* rtb = s.MakeRef_typespec();
                            rtb->VpiFullName(prefix);
                            rtb->VpiParent((UHDM::expr*)a);
                            rtb->Actual_typespec(si.argTs[argIdx].first);
                            pendingBodyOpArgTs.push_back(
                                {rtb, (UHDM::expr*)a, currentSubSym, &sub});
                        }
                        // A LITERAL constant actual of a DEF-view
                        // PARAM-INITIALIZER call carries no formal-ts ref: the
                        // definition compile never runs evalFunc, so nothing
                        // binds an actual to a formal there.  Measured on one
                        // purpose-built golden (r10evfn probe 1/2) across all
                        // the spellings the emitter can reach — a call to the
                        // package's OWN function (p1::Z = f(3,4)), to a
                        // wildcard-IMPORTED one (p2::X = f(1,2)), named-
                        // argument forms of both (f(.b(4),.a(3))), and a
                        // module localparam calling an imported function
                        // (`localparam int L = f(9,4)`): every def-view actual
                        // bare.  The ELAB view is the opposite and keeps the
                        // stamp on a call that survives reduction
                        // (const_func_block_var `localparam res =
                        // operation(4)`, whose body localparams defeat the
                        // fold): the elaborator DID bind the argument.  Ours
                        // stamped in both views whenever the callee happened
                        // to be emitted already, which is emission order, not
                        // a Surelog rule.
                        bool paramInitLit9 =
                            inParamInit && !currentTf && !elabParamArgFold &&
                            paramInitDef &&
                            a->UhdmType() == UHDM::uhdmconstant;
                        // A call inside a GEN-SCOPE process is a procedural
                        // call exactly like a module-level one and binds no
                        // formal typespec onto its actuals.  Surelog draws no
                        // distinction; ours did, because inProcessEmit is set
                        // only around emitModuleDef's process loop and the
                        // gen_scope loop (ModuleEmit emitGenScope) sets
                        // inGenScopeProc instead — so every always block
                        // written inside a `generate` escaped the procedural
                        // bar.  Scr1SvTests' scr1_memory_tb_axi is the
                        // measurement: its `mem_read(araddr[gi], ...)` and
                        // `mem_write(awready[gi] ? ... , wdata[gi], ...)` sit
                        // in generate-scope always blocks and golden leaves
                        // every actual bare, while the SAME design's
                        // module-level `is_compliance(test_file)` in a plain
                        // always block is bare on both sides already.
                        if (isFunc && !inProcessEmit && !inGenScopeProc &&
                            !caCondReduceStop && argCtxOk && !pkgScopedRef &&
                            !strFormalConst && !paramInitLit9 && !namedArgs9 &&
                            // A PROPERTY-DECL body's call args carry no
                            // formal-ts stamp (mriscv s2qed reg_map(inp1)).
                            !propDeclScope &&
                            // § classPropInit29 — nor do a CLASS-PROPERTY
                            // INITIALIZER's (t39a `int b_call = pkgf39(2)`:
                            // golden's actual is a bare constant).  Surelog
                            // compiles a class body with Reduce::No and never
                            // binds actual to formal there.
                            !classPropInitCtx29 &&
                            // § defOnlyNoArgTs — a module DEFINITION that is
                            // never elaborated (unreferenced, or instantiated
                            // only inside a non-taken generate branch) gets its
                            // AllModules listing from the definition compile
                            // alone, and Surelog's actual-to-formal binding is
                            // an ELABORATION step: golden leaves every call
                            // argument in such a listing BARE.  Measured on
                            // tools/probe/r10earl_repro/vl.sv, which emits the
                            // identical body twice — once in a module reached
                            // only through `if (Impl == 1)` with Impl 0, once
                            // in a module that IS instantiated: golden stamps
                            // the formal's typespec on `finv(mid)` in the
                            // second and not in the first, and nothing else in
                            // the two listings differs.  vj.sv/vk.sv are the
                            // negative controls (every argument kind, and the
                            // no-direction-keyword formal / two-declarator
                            // actual spellings aes_sbox_canright uses, all
                            // stamped and all cmp-EQUAL when instantiated).
                            // Corpus: Earlgrey aes_sbox_canright,
                            // aes_sbox_canright_masked and
                            // aes_sbox_canright_masked_noreuse — the SBoxImpl
                            // generate arm nobody takes.
                            !defOnlyDefEmit &&
                            !(unbasedArg && contAssignView == 1) &&
                            (refArg || otherArg) &&
                            (argIdx < si.argTs.size() || elabParamArgFold)) {
                            auto* r = (UHDM::expr*)a;
                            auto* rt = s.MakeRef_typespec();
                            // Constant args (param-init context) name the
                            // enclosing scope; refs name themselves.
                            std::string argFull = prefix;
                            if (a->UhdmType() == UHDM::uhdmref_obj)
                                argFull = ((UHDM::ref_obj*)a)->VpiFullName();
                            else if (a->UhdmType() == UHDM::uhdmbit_select)
                                argFull = ((UHDM::bit_select*)a)->VpiFullName();
                            else if (a->UhdmType() == UHDM::uhdmpart_select)
                                argFull = ((UHDM::part_select*)a)->VpiFullName();
                            else if (a->UhdmType() == UHDM::uhdmindexed_part_select)
                                argFull =
                                    ((UHDM::indexed_part_select*)a)->VpiFullName();
                            rt->VpiFullName(argFull);
                            rt->VpiParent(r);
                            if (argIdx < si.argTs.size()) {
                                auto [ats, bareKey] = si.argTs[argIdx];
                                // § pkgFormalTsElabTwin — the FORMAL typespec
                                // stamped on the actual must come from the
                                // package's ELABORATED twin, the same object
                                // siTf already resolves for the call itself.
                                // si.argTs is filled by the FIRST emission of
                                // the subroutine, which is the package's DEF
                                // listing, and typespec::Compare recurses
                                // Instance(), so binding the def copy makes
                                // package::Compare read {top=0} against
                                // golden's {top=1} — a head with NOTHING
                                // visible in a dump (the two package copies
                                // are text-identical).  Measured on
                                // tools/probe/r10earl_repro/vm.sv row D
                                // (`vmp::fy(mid2, vmp::TBL)` in a module with
                                // NO import) with the new who-links-this-
                                // package probe tools/probe/r10earl11p.cpp:
                                // golden's chain ref_obj 'mid2' ->
                                // ref_typespec -> logic_typespec -> package
                                // {top=1}, ours {top=0}.  Rows A/B (the same
                                // call in a module that DOES wildcard-import
                                // the package) already reached the twin, which
                                // is why this survived so long.  Corpus:
                                // Earlgrey aes / aes_prng / prim_prince
                                // through prim_cipher_pkg::sbox4_64bit
                                // (aes_prng.sv:61).
                                if (siTf && siTf != si.tf && siTf->Io_decls() &&
                                    argIdx < siTf->Io_decls()->size())
                                    if (auto* rte9 =
                                            (*siTf->Io_decls())[argIdx]->Typespec())
                                        if (auto* ate9 = rte9->Actual_typespec())
                                            ats = ate9;
                                if (ats)
                                    rt->Actual_typespec(ats);
                                else if (bareKey)
                                    pendingIoTs.push_back({rt, bareKey});
                            }
                            else if (isFunc)
                                // The callee's io_decls do not exist yet
                                // (param_assigns precede Task_funcs): read the
                                // formal's typespec off the bound function in
                                // the write phase.
                                pendingCallArgTs.push_back(
                                    {rt, ((UHDM::func_call*)fc)->Function(),
                                     argIdx});
                            r->Typespec(rt);
                            // A constant arg carrying a formal-ts ref sizes at
                            // the formal's width (loop(2) -> UINT:2 size 4) —
                            // VECTOR formals only (int formals keep 64).
                            // A STRING formal has no bit width at all: the
                            // literal keeps compileConst's 8-bits-per-char
                            // size (FuncArgsByName `.match_type_pair("a")`
                            // -> size 8, not 0).  The literal's OWN type is
                            // `bit[7:0]`, so only the FORMAL's type answers
                            // this.
                            if (a->UhdmType() == UHDM::uhdmconstant && arg->type &&
                                !intFormal && !arg->type->isString() &&
                                !stripImplicitConv(*arg).type->isString()) {
                                auto* ac9 = (UHDM::constant*)a;
                                ac9->VpiSize(
                                    (int32_t)arg->type->getBitWidth());
                                // SIGNED formals re-encode the converted
                                // value (1 -> 1'sb1 = -1) as INT (Surelog).
                                if (arg->type->isSigned()) {
                                    ASTContext sctx9(comp.getRoot(),
                                                     LookupLocation::max);
                                    ConstantValue cv9 = sctx9.tryEval(*arg);
                                    if (cv9 && cv9.isInteger() &&
                                        !cv9.integer().hasUnknown()) {
                                        auto iv9 = cv9.integer();
                                        iv9.setSigned(true);
                                        if (iv9.isNegative()) {
                                            std::string d9 = iv9.toString(
                                                LiteralBase::Decimal, false);
                                            ac9->VpiValue("INT:" + d9);
                                            ac9->VpiDecompile(d9);
                                            ac9->VpiConstType(vpiIntConst);
                                        }
                                    }
                                }
                            }
                        }
                        args->push_back(a);
                    }
                    argIdx++;
                }
                callArgDepth--;
                qualCallArg20 = savedQCA20;
                if (!args->empty())
                    fc->Tf_call_args(args);
                return fc;
            }
            bool stmtCtx = callStmtContext;
            callStmtContext = false;
            std::string name = std::string(call.getSubroutineName());
            // Built-in METHOD calls (e.first(), arr.size(): no leading $)
            // become hier_path shapes - not yet supported.
            if (name.empty() || name[0] != '$') {
                // Built-in METHOD call (e.first(), s.putc(...)): hier_path
                // [receiver ref (name-only), method_func_call named by the
                // method] — Surelog's folded shape.
                // Surelog's compileTfCall resolves `<name>.<method>(args)`
                // by its FIRST identifier. Inside a function, the receiver
                // `myFunc1` of `myFunc1.push_back('{i,i})` IS the function,
                // so the whole thing compiles to a plain func_call to
                // myFunc1 carrying the METHOD's arguments — the queue method
                // is dropped (CrossFunc). Gated on the receiver being this
                // function's own return variable, the only receiver that
                // names a subroutine.
                if (!call.arguments().empty() && funcRetSym) {
                    auto& rcv0 = stripImplicitConv(*call.arguments()[0]);
                    if (rcv0.kind == ExpressionKind::NamedValue &&
                        &rcv0.as<NamedValueExpression>().symbol == funcRetSym) {
                        auto* ps0 = funcRetSym->getParentScope();
                        if (ps0 &&
                            ps0->asSymbol().kind == SymbolKind::Subroutine) {
                            auto& fsub0 =
                                ps0->asSymbol().as<SubroutineSymbol>();
                            auto* fc0 = s.MakeFunc_call();
                            fc0->VpiName(fsub0.name);
                            fc0->VpiParent(parent);
                            setLoc(fc0, expr.sourceRange);
                            if (auto sit0 = subMap.find(&fsub0);
                                sit0 != subMap.end())
                                fc0->Function(
                                    (UHDM::function*)sit0->second.tf);
                            auto* fargs = s.MakeAnyVec();
                            for (size_t ai = 1; ai < call.arguments().size();
                                 ai++)
                                if (auto* a2 = emitExpr(*call.arguments()[ai],
                                                        fc0, prefix, netMap))
                                    fargs->push_back(a2);
                            if (!fargs->empty())
                                fc0->Tf_call_args(fargs);
                            return fc0;
                        }
                    }
                }
                if (!call.arguments().empty()) {
                    auto* recv = call.arguments()[0];
                    std::string recvText = rawText(recv->sourceRange);
                    // The receiver text may itself be DOTTED
                    // (`frame.multicast.constraint_mode(0)` -> receiver
                    // `frame.multicast`); Surelog models the dotted path one
                    // name per element.
                    std::vector<std::string> dots;
                    for (size_t p0 = 0;;) {
                        auto d0 = recvText.find('.', p0);
                        if (d0 == std::string::npos) {
                            dots.push_back(recvText.substr(p0));
                            break;
                        }
                        dots.push_back(recvText.substr(p0, d0 - p0));
                        p0 = d0 + 1;
                    }
                    // STATEMENT context (b.putc(2,"x");): a flat
                    // method_func_call with an unbound receiver Prefix.
                    // Surelog's statement-call path reads only the FIRST TWO
                    // names of the dotted call: the call is named after
                    // name[1] with name[0] as the Prefix, and when more names
                    // follow, the ARGUMENT LIST (which belongs to the last
                    // name) is dropped entirely — measured on
                    // `o.cn.constraint_mode(0);` -> method_func_call(cn)
                    // prefix o, no args, and `t.sub.m(4);` ->
                    // method_func_call(sub) prefix t, no args.
                    if (stmtCtx && !recvText.empty()) {
                        bool deep0 = dots.size() > 1;
                        const std::string& callNm0 = deep0 ? dots[1] : name;
                        const std::string& recvNm0 = dots[0];
                        auto* mfc = s.MakeMethod_func_call();
                        mfc->VpiName(callNm0);
                        mfc->VpiParent(parent);
                        auto mStart = recv->sourceRange.start() +
                                      (deep0 ? recvNm0.size() + 1
                                             : recvText.size() + 1);
                        setLoc(mfc, SourceRange(mStart, mStart + callNm0.size()));
                        auto* pr = s.MakeRef_obj();
                        pr->VpiName(recvNm0);
                        pr->VpiFullName(joinRef(prefix, recvNm0));
                        pr->VpiParent(mfc);
                        setLoc(pr, SourceRange(recv->sourceRange.start(),
                                               recv->sourceRange.start() +
                                                   recvNm0.size()));
                        mfc->Prefix(pr);
                        if (!deep0) {
                            auto* margs = s.MakeAnyVec();
                            // § builtinMethodArgBinds28 — a BUILT-IN method's
                            // arguments are an ordinary § classArgBind12
                            // window: `m_stack.push_back(s)` binds `s` to the
                            // method's io_decl (and a body local to its var)
                            // while the RECEIVER and a class PROPERTY stay
                            // bare and `$display`'s arguments never bind.
                            // t38e measures all five cells; the missing window
                            // was the head of the Scoreboard/SimpleUVM
                            // package-listing residue after the first two laws
                            // (269 elements, uvm_scope_stack::set).
                            ClassArgBind12 cab28(classArgBindDepth12);
                            for (size_t ai = 1; ai < call.arguments().size(); ai++) {
                                bool fs2 = forceConstParent;
                                if (isLiteralExpr(*call.arguments()[ai]))
                                    forceConstParent = true;
                                if (auto* a2 = emitExpr(*call.arguments()[ai], mfc,
                                                        prefix, netMap))
                                    margs->push_back(a2);
                                forceConstParent = fs2;
                            }
                            if (!margs->empty())
                                mfc->Tf_call_args(margs);
                        }
                        return mfc;
                    }
                    if (!recvText.empty()) {
                        // An ARRAY-MANIPULATION method carrying a `with`
                        // clause (`q.find() with (item > 1)`) reads
                        // differently from a plain built-in: the iteration
                        // expression rides the method_func_call as vpiWith
                        // (parented, like every operand, at the STATEMENT),
                        // the hier_path is named after the ARRAY ALONE
                        // instead of `<array>.<method>`, and the receiver
                        // ref_obj gains its scoped fullname. The `with` is
                        // the whole discriminator: `q.sum() with (item)` is
                        // named `q`, the identical `q.sum()` is named
                        // `q.sum`, and so are size/min (r10apb3 repro 7).
                        const Expression* withExpr9 = nullptr;
                        if (call.isSystemCall())
                            withExpr9 =
                                std::get<CallExpression::SystemCallInfo>(
                                    call.subroutine)
                                    .getIteratorInfo()
                                    .first;
                        // § parensLessCallIsPathRefObj — SITE 1 of 1.  THE
                        // PARENTHESES ARE THE WHOLE DISCRIMINATOR.  A built-in
                        // method written WITHOUT an argument list (`data.size`,
                        // `s.len`, `e.name`, `q.pop_front`) is NOT a call to
                        // Surelog at all: the last path element of the enclosing
                        // hier_path is a REF_OBJ named for the method, carrying
                        // the ordinary § prefix-scoped fullname, and the
                        // hier_path SPAN runs to the END OF THE METHOD NAME.
                        // The identical method WITH parens (`data.size()`) keeps
                        // the method_func_call element and the span slang gives.
                        // slang's own range for the parens-less form covers only
                        // the RECEIVER (`data`, 48:17-48:21 where golden spans
                        // 48:17-48:26), so the span must be rebuilt from the
                        // method token, not taken from expr.sourceRange.
                        // Arms s1/s2/s3/s4/s6 in tools/probe/r10svs2repro;
                        // s1 pairs the witness with its parens-ful positive
                        // control on one golden.
                        // THE TEST IS ON THE SOURCE TEXT, NOT ON expr.syntax.
                        // § parensLessSyntaxKindRefuted — a syntax-kind test
                        // (`expr.syntax->kind != InvocationExpression`) READS
                        // FALSE-POSITIVE INSIDE A CAST and cost this pass four
                        // u2r rows: `int'(mubi4_hi_value())` (FunctionReturnEnum),
                        // `int'(iota('1))` (BitSelectPartSelectInFunction),
                        // `int'(get_1s())` (FunctionWithOverriddenParameter) and
                        // `int'(get_BA())` (ReturnEnumArray) all carry WRITTEN
                        // parens — `iota('1)` even carries an ARGUMENT — yet
                        // their CallExpression's syntax pointer is NOT the
                        // InvocationExpressionSyntax, so all four were
                        // mis-classified parens-less and all four went
                        // CMP_EQUAL -> CMP_NOTEQUAL.  This is the same
                        // unreliability Expression.cpp:872-881 documents for
                        // let-decl expansion.  expr.sourceRange, by contrast, is
                        // exact in both regimes and IS the anomaly that
                        // identifies the parens-less form: for `data.size()` it
                        // spans the whole call (25:21-25:32) while for the
                        // parens-less `data.size` it collapses onto the RECEIVER
                        // ALONE (16:21-16:25 == recvText).  That equality is the
                        // gate, and it is deliberately the TIGHT direction: a
                        // receiver whose own text contains a `(` reads
                        // parens-ful and keeps the pre-existing behaviour.
                        bool parensLess9 =
                            !withExpr9 &&
                            rawText(expr.sourceRange) == recvText;
                        auto mStart9 = recv->sourceRange.end() + 1;
                        auto* hp = s.MakeHier_path();
                        std::string dotted =
                            withExpr9 ? recvText : recvText + "." + name;
                        hp->VpiName(dotted);
                        hp->VpiFullName(dotted);
                        hp->VpiParent(parent);
                        // slang's call range stops at the `)` of the method;
                        // Surelog's runs through the with-clause's own `)`.
                        setLoc(hp,
                               withExpr9
                                   ? SourceRange(expr.sourceRange.start(),
                                                 withExpr9->sourceRange.end() + 1)
                               : parensLess9
                                   ? SourceRange(expr.sourceRange.start(),
                                                 mStart9 + name.size())
                                   : expr.sourceRange);
                        auto* elems = s.MakeAnyVec();
                        // ONE ref_obj per dotted name (o.cn.constraint_mode ->
                        // ref_obj o, ref_obj cn, method_func_call
                        // constraint_mode).
                        auto nmStart0 = recv->sourceRange.start();
                        for (auto& dn0 : dots) {
                            auto* r0 = s.MakeRef_obj();
                            r0->VpiName(dn0);
                            // name-only (dump omits) unless the with-clause
                            // form, which scopes it.
                            r0->VpiFullName(withExpr9 ? joinRef(prefix, dn0)
                                                      : dn0);
                            r0->VpiParent(hp);
                            setLoc(r0, SourceRange(nmStart0, nmStart0 + dn0.size()));
                            elems->push_back(r0);
                            nmStart0 = nmStart0 + dn0.size() + 1;
                        }
                        // § parensLessCallIsPathRefObj — the class swap.  A
                        // parens-less built-in has NO arguments by construction,
                        // so nothing below this point (args, iterator, `with`)
                        // can apply; the element is emitted and the path closed
                        // here.  The fullname is the ORDINARY § prefix join, and
                        // that is what makes golden's three different fullname
                        // regimes fall out with no extra rule: scope-scoped in a
                        // for-condition / rvalue / $display argument
                        // (work@cx::f::size), ARRAY-scoped inside an index of
                        // that array (work@cx::f::bytes::size), and NAME-ONLY
                        // inside a `new[...]` size (golden `ref_obj: (size)`).
                        // Measured cell by cell in arm s4.
                        if (parensLess9) {
                            auto* rq9 = s.MakeRef_obj();
                            rq9->VpiName(name);
                            rq9->VpiFullName(joinRef(prefix, name));
                            rq9->VpiParent(hp);
                            setLoc(rq9,
                                   SourceRange(mStart9, mStart9 + name.size()));
                            elems->push_back(rq9);
                            hp->Path_elems(elems);
                            return hp;
                        }
                        auto* mfc = s.MakeMethod_func_call();
                        mfc->VpiName(name);
                        mfc->VpiParent(hp);
                        auto mStart = recv->sourceRange.end() + 1;
                        setLoc(mfc, SourceRange(mStart, mStart + name.size()));
                        UHDM::ref_obj* iterArg9 = nullptr;
                        // § arrayMethodIterArg — the ITERATOR NAME written in
                        // the method's own parens (`q.unique( cb_ ) with (...)`)
                        // is compiled by Surelog as an ordinary call ARGUMENT:
                        // a ref_obj named after it, parented at the
                        // method_func_call, whose fullname is scoped through
                        // the ARRAY (…::<array>::<iter>).  slang models the
                        // same token as the iterator VARIABLE of the with
                        // clause, so it never reaches call.arguments() — read
                        // it back off the invocation's argument syntax, which
                        // is also what distinguishes the written form from the
                        // implicit `item` (empty parens emit nothing).
                        if (withExpr9 && expr.syntax) {
                            // `q.m(it) with (…)` parses as an
                            // ArrayOrRandomizeMethodExpression wrapping the
                            // invocation.
                            const syntax::SyntaxNode* mi9 = expr.syntax;
                            if (mi9->kind == syntax::SyntaxKind::
                                                 ArrayOrRandomizeMethodExpression)
                                mi9 = mi9->as<syntax::ArrayOrRandomizeMethodExpressionSyntax>()
                                          .method;
                            const syntax::ArgumentListSyntax* al9 = nullptr;
                            if (mi9 &&
                                mi9->kind ==
                                    syntax::SyntaxKind::InvocationExpression)
                                al9 = mi9->as<syntax::InvocationExpressionSyntax>()
                                          .arguments;
                            if (al9 && !al9->parameters.empty()) {
                                auto ar9 = al9->parameters[0]->sourceRange();
                                auto* ia9 = s.MakeRef_obj();
                                ia9->VpiName(std::string(rawText(ar9)));
                                ia9->VpiFullName(
                                    joinRef(joinRef(prefix, recvText),
                                            std::string(rawText(ar9))));
                                ia9->VpiParent(mfc);
                                setLoc(ia9, ar9);
                                iterArg9 = ia9;
                            }
                        }
                        if (withExpr9)
                            if (auto* w9 =
                                    emitExpr(*withExpr9, parent, prefix, netMap))
                                mfc->With(w9);
                        // Extra method args (past the receiver); literal args
                        // parent at the method call.
                        auto* margs = s.MakeAnyVec();
                        if (iterArg9)
                            margs->push_back(iterArg9);
                        // NOTE § classInBodyRecvCallArgNoBind52 — SITE 3 of 3,
                        // the BUILT-IN method on a receiver in EXPRESSION
                        // position.  THIS IS THE CORPUS HEAD'S SITE:
                        // `if (!pool.exists(key))` in uvm-1.2 uvm_pool.svh:87
                        // inside `function T uvm_pool::get(KEY key)`, whose
                        // class body ends at line 232 (IN BODY).  GATE:
                        // in-body class method.  Arm a2 ib_cond_builtin_formal
                        // is the same shape read on one golden, both sides.
                        RecvCallArg52 rca52B(recvCallArgDepth52);
                        for (size_t ai = 1; ai < call.arguments().size(); ai++) {
                            bool fs2 = forceConstParent;
                            if (isLiteralExpr(*call.arguments()[ai]))
                                forceConstParent = true;
                            if (auto* a2 =
                                    emitExpr(*call.arguments()[ai], mfc, prefix, netMap))
                                margs->push_back(a2);
                            forceConstParent = fs2;
                        }
                        if (!margs->empty())
                            mfc->Tf_call_args(margs);
                        elems->push_back(mfc);
                        hp->Path_elems(elems);
                        return hp;
                    }
                }
                noteUnsupportedAt("system method call: " + name, expr.sourceRange.start());
                return nullptr;
            }
            // $bits folds to a constant for a type/var/member argument, but
            // Surelog keeps it a sys_func_call when the argument is an
            // expression ($bits(~x)) or a parameter ($bits(P), override-
            // dependent).
            bool bitsKeep = false;
            if (!call.arguments().empty()) {
                auto& a0 = *call.arguments()[0];
                bitsKeep = a0.kind == ExpressionKind::UnaryOp ||
                           a0.kind == ExpressionKind::BinaryOp ||
                           a0.kind == ExpressionKind::ConditionalOp ||
                           (a0.kind == ExpressionKind::NamedValue &&
                            a0.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter &&
                            // A LOCALPARAM can't be overridden — its $bits
                            // folds in the ELAB re-emit (def keeps the call).
                            !(reemitting && a0.as<NamedValueExpression>()
                                                .symbol.as<ParameterSymbol>()
                                                .isLocalParam()));
                // ...and so does an argument whose typespec Surelog's def
                // compile either cannot find or cannot fully specify. Only the
                // shapes `getTypespec` handles are judged here; anything else
                // (a concatenation, a cast, a call) keeps the old behaviour.
                bool namedArg = a0.kind == ExpressionKind::NamedValue &&
                                a0.as<NamedValueExpression>().symbol.kind !=
                                    SymbolKind::Parameter;
                if (!bitsKeep &&
                    (namedArg || a0.kind == ExpressionKind::DataType ||
                     a0.kind == ExpressionKind::MemberAccess ||
                     a0.kind == ExpressionKind::ElementSelect ||
                     a0.kind == ExpressionKind::RangeSelect ||
                     a0.kind == ExpressionKind::HierarchicalValue))
                    // § elabBitsBodyParamResolves — the ELAB listing's own
                    // net/var typespec bounds are folded, so a $bits of a
                    // signal whose declaration dims name a module-body
                    // parameter reduces THERE while the def listing keeps the
                    // call.  Gated to the elaborated cont-assign / net-decl-
                    // assign emission, the only elab-only expression views this
                    // site sees (BlackBePipeInt pc_sext_li's three $bits(pc)
                    // over `wire [vaddr_width_p-1:0] pc` -> golden UINT:39).
                    bitsKeep = !srlgBitsFoldArg(
                        a0, /*elabView=*/ndaRhsEmit || contAssignView == 2);
            }
            // ...and the DEF listing of a PACKAGE never folds it at all.
            // Surelog compiles that view without elaborating the package, so
            // NOTHING reduces there: `2+3` keeps its vpiAddOp, a read of
            // another package param substitutes that param's Rhs unreduced,
            // and every system call — $clog2 included — stays a
            // sys_func_call. Measured on a 8-row package golden (/tmp probe
            // p3: literal / 2+3 / P*2 / $bits(t) / $clog2(9) / P+$bits(t) /
            // ternary-over-$bits / ternary-over-param): the def listing folds
            // NONE of them, the topPackages copy folds ALL of them. $bits was
            // the only one we still folded there (PackageEval, AllPackageSignal).
            if (curPkgEmitSym && !pkgEmitTopView)
                bitsKeep = true;
            if (name == "$bits" && !bitsKeep) {
                bool localParamArg =
                    !call.arguments().empty() &&
                    call.arguments()[0]->kind == ExpressionKind::NamedValue &&
                    call.arguments()[0]
                            ->as<NamedValueExpression>()
                            .symbol.kind == SymbolKind::Parameter;
                ASTContext qctx(comp.getRoot(), LookupLocation::max);
                auto cv = qctx.tryEval(expr);
                // Root-context evaluation is slang's answer, not Surelog's:
                // it refuses a select/member-access rooted at a PORT (there is
                // no instance to read from), while `compileBits` only ever
                // needed the argument's TYPESPEC — which `srlgBitsFoldArg`
                // already certified fully specified. Fall back to the static
                // width so the fold decision and the fold agree
                // (HierPathPackedStruct's `$bits(a.pair[0])`).
                std::optional<uint64_t> staticBits9;
                if (!cv && !call.arguments().empty()) {
                    auto& a9 = stripImplicitConv(*call.arguments()[0]);
                    if ((a9.kind == ExpressionKind::MemberAccess ||
                         a9.kind == ExpressionKind::ElementSelect ||
                         a9.kind == ExpressionKind::RangeSelect) &&
                        a9.type && a9.type->isIntegral() &&
                        a9.type->getBitWidth() > 0)
                        staticBits9 = a9.type->getBitWidth();
                }
                if (staticBits9) {
                    auto* c = s.MakeConstant();
                    std::string digits = std::to_string(*staticBits9);
                    c->VpiDecompile(digits);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    if (!localParamArg)
                        setLoc(c, expr.sourceRange);
                    if (forceConstParent ||
                        (!suppressConstParent && parent &&
                         (parent->UhdmType() == UHDM::uhdmoperation ||
                          parent->UhdmType() == UHDM::uhdmbit_select ||
                          parent->UhdmType() == UHDM::uhdmcase_item)))
                        c->VpiParent(parent);
                    return c;
                }
                if (cv && cv.isInteger()) {
                    auto* c = s.MakeConstant();
                    std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
                    c->VpiDecompile(digits);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    // The elab localparam-$bits fold is loc-less.
                    if (!localParamArg)
                        setLoc(c, expr.sourceRange);
                    if (forceConstParent ||
                        (!suppressConstParent && parent &&
                         (parent->UhdmType() == UHDM::uhdmoperation ||
                          parent->UhdmType() == UHDM::uhdmbit_select ||
                          parent->UhdmType() == UHDM::uhdmcase_item)))
                        c->VpiParent(parent);
                    return c;
                }
            }
            auto* sc = s.MakeSys_func_call();
            sc->VpiName(name);
            sc->VpiParent(parent);
            // Conversion/query functions keep name-token-only spans in
            // expression contexts; other sys calls span the whole call. A
            // CLOCKING-EVENT argument also forces the name-only span.
            static const std::set<std::string> kNameOnlyFuncs = {"$signed", "$unsigned"};
            bool clockingArg = false;
            for (auto arg : call.arguments())
                if (arg->kind == ExpressionKind::ClockingEvent)
                    clockingArg = true;
            if (clockingArg)
                setLoc(sc, nameSpan(expr.sourceRange.start(), name));
            else if (stmtCtx || (!kNameOnlyFuncs.count(name) && !inCastSize))
                setLoc(sc, expr.sourceRange);
            else
                setLoc(sc, SourceRange(expr.sourceRange.start(),
                                       expr.sourceRange.start() + name.size()));
            auto* args = s.MakeAnyVec();
            callArgDepth++;
            sysCallArgDepth22++;  // § genCaSysCallArgBinds22
            for (auto arg : call.arguments()) {
                // An output arg ($readmemh(f, mem)) binds as an Assignment;
                // golden lists just the target ref (an assignment object would
                // poison the tf_call_args group).
                const Expression* argE = arg;
                if (argE->kind == ExpressionKind::Assignment)
                    argE = &argE->as<AssignmentExpression>().left();
                // ELAB param inits compile with Reduce::Yes, so an OPERATION
                // argument of a sys call ExprEval cannot itself evaluate
                // ($floor(W / X)) still folds to a 64-bit vpiIntConst —
                // anchored, like every Surelog post-reduce constant, at the
                // expression's FIRST CHILD node (the leftmost leaf).
                auto& argS = stripImplicitConv(*argE);
                // A TYPE argument of a query call Surelog did not fold.
                // `compileTfCallArguments` runs the type through
                // `compileExpression`, which turns an integer ATOM keyword
                // into the matching `*_var` carrying nothing but the
                // enclosing instance's fullname, and a TYPEDEF name into a
                // plain ref_obj.  (`logic` / `bit` / an inline `logic [3:0]`
                // come back as `unsupported_expr` holding the whole source
                // line — not reproduced.)  Measured on a 12-type golden
                // matrix; NonSynthError, InterpElab1.
                if (argS.kind == ExpressionKind::DataType && argS.type) {
                    UHDM::any* tv = nullptr;
                    const Type& at = *argS.type;
                    if (at.kind == SymbolKind::TypeAlias) {
                        auto* r0 = s.MakeRef_obj();
                        r0->VpiName(std::string(at.name));
                        // joinPath, not a bare '.': in a PACKAGE the prefix is
                        // already '::'-terminated (`test_pkg::t_test`, not
                        // `test_pkg::.t_test` -- PackageEval's $bits argument).
                        r0->VpiFullName(joinPath(prefix, at.name));
                        tv = r0;
                    }
                    else if (at.kind == SymbolKind::PredefinedIntegerType) {
                        UHDM::variables* v0 = nullptr;
                        switch (at.as<PredefinedIntegerType>().integerKind) {
                            case PredefinedIntegerType::Int:
                                v0 = s.MakeInt_var(); break;
                            case PredefinedIntegerType::Integer:
                                v0 = s.MakeInteger_var(); break;
                            case PredefinedIntegerType::Byte:
                                v0 = s.MakeByte_var(); break;
                            case PredefinedIntegerType::ShortInt:
                                v0 = s.MakeShort_int_var(); break;
                            case PredefinedIntegerType::LongInt:
                                v0 = s.MakeLong_int_var(); break;
                            case PredefinedIntegerType::Time:
                                v0 = s.MakeTime_var(); break;
                        }
                        if (v0)
                            v0->VpiFullName(prefix);
                        tv = v0;
                    }
                    if (tv) {
                        tv->VpiParent(sc);
                        setLoc(tv, argS.sourceRange);
                        args->push_back(tv);
                    }
                    continue;
                }
                // § elabMisevalArgNoFold — ...but a parameter whose ELAB Rhs
                // Surelog left UNFOLDED does not fold its call ARGUMENTS
                // either: the refusal is the whole reduction, top to leaf.
                // scr1_pipe_tdu `ALLTRIG_W = $clog2(ALLTRIG_NUM+1)` keeps
                // op24(subst(ALLTRIG_NUM), UINT:1)@77:46-59 where every other
                // elab param collapses the same argument to a constant.
                if (inParamInit && !paramInitDef && !misevalParamRhsScope &&
                    (argS.kind == ExpressionKind::BinaryOp ||
                     argS.kind == ExpressionKind::UnaryOp)) {
                    ASTContext fctx(comp.getRoot(), LookupLocation::max);
                    if (auto fcv = fctx.tryEval(argS);
                        fcv && fcv.isInteger() && !fcv.integer().hasUnknown()) {
                        const Expression* leaf = &argS;
                        while (true) {
                            auto& l0 = stripImplicitConv(*leaf);
                            if (l0.kind == ExpressionKind::BinaryOp)
                                leaf = &l0.as<BinaryExpression>().left();
                            else if (l0.kind == ExpressionKind::UnaryOp)
                                leaf = &l0.as<UnaryExpression>().operand();
                            else {
                                leaf = &l0;
                                break;
                            }
                        }
                        auto* fc0 = s.MakeConstant();
                        std::string dg0 =
                            fcv.integer().toString(LiteralBase::Decimal, false);
                        fc0->VpiDecompile(dg0);
                        fc0->VpiSize(64);
                        fc0->VpiValue("INT:" + dg0);
                        fc0->VpiConstType(vpiIntConst);
                        fc0->VpiParent(sc);
                        setLoc(fc0, leaf->sourceRange);
                        args->push_back(fc0);
                        continue;
                    }
                }
                // System-call direct literal args parent to the call.
                bool forceSaved = forceConstParent;
                if (isLiteralExpr(*argE))
                    forceConstParent = true;
                if (auto* a = emitExpr(*argE, sc, prefix, netMap))
                    args->push_back(a);
                forceConstParent = forceSaved;
            }
            callArgDepth--;
            sysCallArgDepth22--;  // § genCaSysCallArgBinds22
            if (!args->empty())
                sc->Tf_call_args(args);
            return sc;
        }
        case ExpressionKind::Concatenation: {
            auto& ce = expr.as<ConcatenationExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiConcatOp);
            op->VpiParent(parent);
            // A CONTINUOUS-assign LVALUE concat ({a,b} = ...) is located at
            // its FIRST operand (Surelog quirk); procedural LHS concats and
            // rvalue concats span the whole braces.
            if (inLhs && parent && parent->UhdmType() == UHDM::uhdmcont_assign &&
                !ce.operands().empty())
                setLoc(op, ce.operands()[0]->sourceRange);
            else
                setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            // § classArgBind12 — a concat operand does NOT pick up the
            // call-argument binding: inside a class method `sink({f, loc})`
            // leaves both operands bare where `sink(f + loc)` binds both (t11).
            ClassArgBindOff12 cabOff12(classArgBindDepth12);
            // Direct literal operands of a concat are unparented in
            // module-compile context, parented in re-elaborated (instance)
            // context. Nested expressions keep the normal rules.
            for (auto o : ce.operands()) {
                bool saved = suppressConstParent, savedF = forceConstParent;
                // A string-literal operand hidden behind a compiler cast
                // ({NAME,"efgh"}) counts as a direct literal too.
                const Expression* olit = o;
                while (olit->kind == ExpressionKind::Conversion)
                    olit = &olit->as<ConversionExpression>().operand();
                if (!reemitting && !importedParamClone &&
                    isLiteralExpr(*olit)) {
                    suppressConstParent = true;
                    // PARAM concat inits unparent literal operands (the force
                    // flag would re-parent them) — package and module alike.
                    if (inParamInit)
                        forceConstParent = false;
                }
                if (auto* e = emitExpr(*o, op, prefix, netMap))
                    operands->push_back(e);
                suppressConstParent = saved;
                forceConstParent = savedF;
            }
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::Replication: {
            auto& re = expr.as<ReplicationExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiMultiConcatOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            // A DIRECT literal repeat count is unparented in module-compile
            // context (nested expression constants keep normal rules).
            bool saved = suppressConstParent;
            if (!reemitting && isLiteralExpr(re.count()))
                suppressConstParent = true;
            auto* cnt = emitExpr(re.count(), op, prefix, netMap);
            suppressConstParent = saved;
            if (cnt)
                operands->push_back(cnt);
            if (auto* inner = emitExpr(re.concat(), op, prefix, netMap))
                operands->push_back(inner);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::UnbasedUnsizedIntegerLiteral: {
            auto& ul = expr.as<UnbasedUnsizedIntegerLiteral>();
            auto* c = s.MakeConstant();
            std::string raw = rawText(expr.sourceRange);
            // 'x/'z uppercase their digit in the decompile ('x -> 'X).
            for (auto& ch : raw)
                if (ch == 'x' || ch == 'z')
                    ch = (char)toupper(ch);
            c->VpiDecompile(raw);
            c->VpiSize(-1);
            logic_t bit = ul.getLiteralValue();
            std::string digit = bit.isUnknown() ? (bit.value == logic_t::X_VALUE ? "X" : "Z")
                                                : (bit.value ? "1" : "0");
            c->VpiValue("BIN:" + digit);
            c->VpiConstType(vpiBinaryConst);
            setLoc(c, expr.sourceRange);
            if (forceConstParent ||
                (!suppressConstParent && parent &&
                 (parent->UhdmType() == UHDM::uhdmoperation ||
                  parent->UhdmType() == UHDM::uhdmbit_select)))
                c->VpiParent(parent);
            return c;
        }
        case ExpressionKind::ElementSelect: {
            auto& es = expr.as<ElementSelectExpression>();
            // § thisPathSelectErased4 — SITE 1 of 3. A select whose base chain
            // bottoms out at the WRITTEN `this` keyword erases the select
            // entirely: `this.data[i]` is the hier_path `this.data` with two
            // PLAIN ref_obj elements. This is the SVSwitch:122 head, and it must
            // run BEFORE every arm below (the mixed builder, the single-dim
            // `chain` arm and the nested-select arm all mint bit_select /
            // var_select elements carrying the index).
            if (auto* thp = emitThisPathSelectErased(expr, parent, prefix))
                return thp;
            // Selects on member access become hier_paths whose last element
            // is the select object (lazily-frozen fullname).
            const Expression* esBottom = &es.value();
            while (esBottom->kind == ExpressionKind::MemberAccess)
                esBottom = &esBottom->as<MemberAccessExpression>().value();
            // A member-access select whose base threads through MULTIPLE
            // element selects (a[0][0].x[2]) routes through the mixed hier-path
            // builder, which emits one bit_select per base dim; the single-dim
            // path below handles only a NamedValue base (a[0].x[2]).
            if (es.value().kind == ExpressionKind::MemberAccess &&
                esBottom->kind == ExpressionKind::ElementSelect) {
                if (auto* hp = emitMixedHierPath(expr, parent, prefix, netMap))
                    return hp;
            }
            if (es.value().kind == ExpressionKind::MemberAccess &&
                esBottom->kind == ExpressionKind::NamedValue) {
                std::vector<const Expression*> chain;
                const Expression* base = &es.value();
                while (base->kind == ExpressionKind::MemberAccess) {
                    chain.push_back(base);
                    base = &base->as<MemberAccessExpression>().value();
                }
                auto& bnv = base->as<NamedValueExpression>();
                auto* hp = s.MakeHier_path();
                std::string dotted(bnv.symbol.name);
                for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2)
                    dotted +=
                        "." + std::string((*it2)->as<MemberAccessExpression>().member.name);
                std::string idxTxt9 = rawText(es.selector().sourceRange);
                // § concatIdxDecompile29 — THE EARLGREY SITE.  A CONCATENATION
                // index is decompiled from the tree; every other index keeps its
                // raw text and its existing § hierSelPkgParamFold reduction (the
                // two are mutually exclusive: that fold fires only on a bare
                // NamedValue index).
                std::string ci29d = concatIdxText(es.selector());
                if (!ci29d.empty())
                    idxTxt9 = ci29d;
                else if (auto red9 = reducedImportedIdx(es.selector(), idxTxt9,
                                                        comp, importedParamDefTs);
                         !red9.empty())
                    idxTxt9 = red9;
                dotted += "[" + idxTxt9 + "]";
                hp->VpiName(dotted);
                hp->VpiFullName(dotted);
                hp->VpiParent(parent);
                setLoc(hp, expr.sourceRange);
                // The FIRST member token (member adjacent to the base): a
                // cont-assign LVALUE anchors the base ref here and spans its
                // bit_select member..index (Surelog), unlike an rvalue which
                // keeps base/selector spans.
                SourceRange firstMemTok = base->sourceRange;
                if (!chain.empty()) {
                    auto& fm = chain.back()->as<MemberAccessExpression>();
                    auto e = chain.back()->sourceRange.end();
                    firstMemTok = SourceRange(e - fm.member.name.size(), e);
                }
                auto* elems = s.MakeAnyVec();
                {
                    auto* r = s.MakeRef_obj();
                    r->VpiName(bnv.symbol.name);
                    (void)r->VpiFullName();
                    r->VpiParent(hp);
                    setLoc(r, (inLhs && !chain.empty()) ? firstMemTok
                                                        : base->sourceRange);
                    elems->push_back(r);
                }
                for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2) {
                    auto& ma = (*it2)->as<MemberAccessExpression>();
                    bool last = *it2 == chain.front();
                    if (!last) {
                        auto* r = s.MakeRef_obj();
                        r->VpiName(ma.member.name);
                        (void)r->VpiFullName();
                        r->VpiParent(hp);
                        auto end = (*it2)->sourceRange.end();
                        setLoc(r, SourceRange(end - ma.member.name.size(), end));
                        elems->push_back(r);
                    }
                    else {
                        auto* bs2 = s.MakeBit_select();
                        bs2->VpiName(ma.member.name);
                        bs2->VpiParent(hp);
                        if (inLhs) {
                            auto mEnd = (*it2)->sourceRange.end();
                            SourceRange mTok(mEnd - ma.member.name.size(), mEnd);
                            setLoc(bs2, SourceRange(mTok.start(),
                                                    expr.sourceRange.end()));
                        }
                        else
                            setLoc(bs2, es.selector().sourceRange);
                        (void)bs2->VpiFullName();
                        if (auto* ix = emitExpr(es.selector(), bs2, prefix, netMap))
                            bs2->VpiIndex((UHDM::expr*)ix);
                        elems->push_back(bs2);
                    }
                }
                hp->Path_elems(elems);
                return hp;
            }
            // Nested element selects (unpacked arrays) flatten to a
            // var_select with one index per dimension, base-prefixed refs.
            if (es.value().kind == ExpressionKind::ElementSelect) {
                std::vector<const Expression*> sels;
                const Expression* base = &expr;
                while (base->kind == ExpressionKind::ElementSelect) {
                    sels.push_back(&base->as<ElementSelectExpression>().selector());
                    base = &base->as<ElementSelectExpression>().value();
                }
                if (base->kind == ExpressionKind::NamedValue) {
                    auto& nv2 = base->as<NamedValueExpression>();
                    if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                        refCollector->insert(&nv2.symbol);
                    auto* vs = s.MakeVar_select();
                    vs->VpiName(nv2.symbol.name);
                    std::string baseFull = joinRef(prefix, nv2.symbol.name);
                    // A port HIGH-CONN select carries no written fullname:
                    // UHDM computes it through the port and the instance
                    // (<inst>.<port>.<sig>), and only skips the port name for
                    // a bit_select child.
                    if (!parent || parent->UhdmType() != UHDM::uhdmport)
                        vs->VpiFullName(baseFull);
                    vs->VpiParent(parent);
                    setLoc(vs, expr.sourceRange);
                    auto* idxs = s.MakeExprVec();
                    bool savedFCP = forceConstParent;
                    varSelIdxDepth++;
                    for (auto it2 = sels.rbegin(); it2 != sels.rend(); ++it2) {
                        forceConstParent = isLiteralExpr(**it2);
                        if (auto* ix = emitExpr(**it2, vs, baseFull, netMap))
                            idxs->push_back((UHDM::expr*)ix);
                    }
                    varSelIdxDepth--;
                    forceConstParent = savedFCP;
                    vs->Exprs(idxs);
                    return vs;
                }
                // Nested selects whose leaf is a member access (bar.l[2][1])
                // -> hier_path with a var_select last element.
                if (base->kind == ExpressionKind::MemberAccess) {
                    std::vector<const Expression*> chain;
                    const Expression* mbase = base;
                    while (mbase->kind == ExpressionKind::MemberAccess) {
                        chain.push_back(mbase);
                        mbase = &mbase->as<MemberAccessExpression>().value();
                    }
                    if (mbase->kind == ExpressionKind::NamedValue) {
                        auto& bnv = mbase->as<NamedValueExpression>();
                        if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                            refCollector->insert(&bnv.symbol);
                        auto* hp = s.MakeHier_path();
                        std::string dotted(bnv.symbol.name);
                        for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2)
                            dotted += "." +
                                      std::string(
                                          (*it2)->as<MemberAccessExpression>().member.name);
                        for (auto it2 = sels.rbegin(); it2 != sels.rend(); ++it2) {
                            // § concatIdxDecompile29 — same gate as the other
                            // hier_path name sites (arm b1_sites o1/o4,
                            // `z.g[{1'b0,k[0]}][3]`, is THIS site).
                            std::string ci29e = concatIdxText(**it2);
                            dotted += "[" +
                                      (ci29e.empty() ? rawText((*it2)->sourceRange)
                                                     : ci29e) +
                                      "]";
                        }
                        hp->VpiName(dotted);
                        hp->VpiFullName(dotted);
                        hp->VpiParent(parent);
                        // Lvalue hier_paths anchor the base ref and last elem
                        // at the FINAL member's name span (Surelog quirk).
                        auto& frontMa = chain.front()->as<MemberAccessExpression>();
                        auto memEnd = chain.front()->sourceRange.end();
                        SourceRange memSpan(memEnd - frontMa.member.name.size(), memEnd);
                        setLoc(hp, expr.sourceRange);
                        auto* elems = s.MakeAnyVec();
                        {
                            auto* r = s.MakeRef_obj();
                            r->VpiName(bnv.symbol.name);
                            (void)r->VpiFullName();
                            r->VpiParent(hp);
                            setLoc(r, inLhs ? memSpan : mbase->sourceRange);
                            elems->push_back(r);
                        }
                        for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2) {
                            auto& ma = (*it2)->as<MemberAccessExpression>();
                            bool last = *it2 == chain.front();
                            if (!last) {
                                auto* r = s.MakeRef_obj();
                                r->VpiName(ma.member.name);
                                (void)r->VpiFullName();
                                r->VpiParent(hp);
                                auto end = (*it2)->sourceRange.end();
                                setLoc(r, SourceRange(end - ma.member.name.size(), end));
                                elems->push_back(r);
                                continue;
                            }
                            auto* vs = s.MakeVar_select();
                            vs->VpiName(ma.member.name);
                            vs->VpiParent(hp);
                            (void)vs->VpiFullName();
                            setLoc(vs, inLhs ? SourceRange(memSpan.start(),
                                                           expr.sourceRange.end())
                                             : expr.sourceRange);
                            auto* idxs = s.MakeExprVec();
                            bool savedFCP = forceConstParent;
                            for (auto it3 = sels.rbegin(); it3 != sels.rend(); ++it3) {
                                forceConstParent = isLiteralExpr(**it3);
                                if (auto* ix = emitExpr(**it3, vs, dotted, netMap))
                                    idxs->push_back((UHDM::expr*)ix);
                            }
                            forceConstParent = savedFCP;
                            vs->Exprs(idxs);
                            elems->push_back(vs);
                        }
                        hp->Path_elems(elems);
                        return hp;
                    }
                }
            }
            // Element select over a DOTTED interface-member path
            // (sub.req.arr[i]): hier_path with a final bit_select element.
            {
                const Expression* bb = &stripImplicitConv(es.value());
                while (bb->kind == ExpressionKind::MemberAccess ||
                       bb->kind == ExpressionKind::ElementSelect) {
                    if (bb->kind == ExpressionKind::MemberAccess)
                        bb = &bb->as<MemberAccessExpression>().value();
                    else
                        bb = &bb->as<ElementSelectExpression>().value();
                }
                if (bb->kind == ExpressionKind::ArbitrarySymbol ||
                    bb->kind == ExpressionKind::HierarchicalValue ||
                    (bb->kind == ExpressionKind::NamedValue &&
                     stripImplicitConv(es.value()).kind !=
                         ExpressionKind::NamedValue)) {
                    std::string wholeExp9 = rawTextExpr(expr);
                    std::string baseDotted = rawTextExpr(es.value());
                    if (baseDotted.empty())
                        baseDotted = selBaseText(wholeExp9);
                    if (baseDotted.find('.') != std::string::npos) {
                        std::string selText =
                            spaceIdxOps(selName(wholeExp9));
                        if (auto red9 = reducedImportedIdx(
                                es.selector(),
                                rawText(es.selector().sourceRange), comp,
                                importedParamDefTs);
                            !red9.empty() && !selText.empty() &&
                            selText.back() == ']') {
                            auto ob9 = selText.rfind('[');
                            if (ob9 != std::string::npos)
                                selText = selText.substr(0, ob9 + 1) + red9 + "]";
                        }
                        auto* hp = s.MakeHier_path();
                        hp->VpiName(selText);
                        hp->VpiFullName(selText);
                        hp->VpiParent(parent);
                        setLoc(hp, expr.sourceRange);
                        auto* elems = s.MakeAnyVec();
                        auto exprStart = es.value().sourceRange.start();
                        std::vector<std::pair<std::string, size_t>> comps;
                        for (size_t st = 0; st <= baseDotted.size();) {
                            auto dot = baseDotted.find('.', st);
                            if (dot == std::string::npos)
                                dot = baseDotted.size();
                            comps.emplace_back(baseDotted.substr(st, dot - st), st);
                            if (dot == baseDotted.size())
                                break;
                            st = dot + 1;
                        }
                        // A gen-scope PROCESS re-emits every indexed leading
                        // component as a bit_select with a symbolic index ref
                        // (`top.blk1.blk2[x].blk3[y].c[0]` in prefix), exactly
                        // like the pure-hier_path path — the interface-member
                        // cases (sub.req.arr[i]) keep the flat ref_obj chain.
                        std::string dottedSoFar2;
                        for (size_t ci = 0; ci + 1 < comps.size(); ci++) {
                            auto& [cn, co] = comps[ci];
                            auto lb2 = cn.find('[');
                            std::string cbase =
                                lb2 == std::string::npos ? cn : cn.substr(0, lb2);
                            dottedSoFar2 += (ci == 0 ? cbase : "." + cbase);
                            std::string cidx;
                            if (inGenScopeProc && lb2 != std::string::npos &&
                                cn.back() == ']' &&
                                cn.find('[', lb2 + 1) == std::string::npos) {
                                std::string ix = cn.substr(lb2 + 1,
                                                           cn.size() - lb2 - 2);
                                auto isIdS = [](char c) {
                                    return (c >= 'a' && c <= 'z') ||
                                           (c >= 'A' && c <= 'Z') || c == '_';
                                };
                                bool simple = !ix.empty() && isIdS(ix[0]);
                                for (char ch : ix)
                                    if (!(isIdS(ch) || (ch >= '0' && ch <= '9')))
                                        simple = false;
                                if (simple)
                                    cidx = ix;
                            }
                            if (!cidx.empty()) {
                                dottedSoFar2 += "[" + cidx + "]";
                                auto* bs3 = s.MakeBit_select();
                                bs3->VpiName(cbase);
                                bs3->VpiFullName(dottedSoFar2);
                                bs3->VpiParent(hp);
                                setLoc(bs3, SourceRange(exprStart + co,
                                                        exprStart + co +
                                                            cbase.size()));
                                auto* ir3 = s.MakeRef_obj();
                                ir3->VpiName(cidx);
                                ir3->VpiFullName(prefix + "." + cidx);
                                ir3->VpiParent(hp);
                                size_t io3 = co + lb2 + 1;
                                setLoc(ir3, SourceRange(exprStart + io3,
                                                        exprStart + io3 +
                                                            cidx.size()));
                                bs3->VpiIndex(ir3);
                                elems->push_back(bs3);
                                continue;
                            }
                            auto* r2 = s.MakeRef_obj();
                            r2->VpiName(cn);
                            r2->VpiFullName(cn); // name-only (dump omits)
                            r2->VpiParent(hp);
                            setLoc(r2, SourceRange(exprStart + co,
                                                   exprStart + co + cn.size()));
                            elems->push_back(r2);
                        }
                        std::string lastName =
                            comps.empty() ? std::string{} : comps.back().first;
                        size_t lastOff = comps.empty() ? 0 : comps.back().second;
                        auto* bs2 = s.MakeBit_select();
                        bs2->VpiName(lastName);
                        // Surelog anchors the leaf select at its INDEX and
                        // freezes the doubled lazy fullname. In a gen-scope
                        // process the frozen name is the SCOPE prefix + the raw
                        // path display + the leaf name (prefix re-doubling).
                        bs2->VpiParent(hp);
                        if (inGenScopeProc)
                            bs2->VpiFullName(prefix + "." + selText + "." +
                                             lastName);
                        else
                            (void)bs2->VpiFullName();
                        setLoc(bs2, es.selector().sourceRange);
                        if (auto* ix2 = emitExpr(es.selector(), bs2, prefix, netMap)) {
                            // A genvar TRAILING index (c[j]) freezes the same
                            // doubled fullname as the leaf (Surelog): scope
                            // prefix + raw display + the index name.
                            if (inGenScopeProc &&
                                ix2->UhdmType() == UHDM::uhdmref_obj)
                                ((UHDM::ref_obj*)ix2)
                                    ->VpiFullName(
                                        prefix + "." + selText + "." +
                                        std::string(
                                            ((UHDM::ref_obj*)ix2)->VpiName()));
                            bs2->VpiIndex((UHDM::expr*)ix2);
                        }
                        elems->push_back(bs2);
                        hp->Path_elems(elems);
                        return hp;
                    }
                }
            }
            if (es.value().kind != ExpressionKind::NamedValue) {
                noteUnsupported("element select base");
                return nullptr;
            }
            auto& nv = es.value().as<NamedValueExpression>();
            if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                refCollector->insert(&nv.symbol);
            auto* bs = s.MakeBit_select();
            bs->VpiName(nv.symbol.name);
            bs->VpiFullName(joinRef(prefix, nv.symbol.name));
            bs->VpiParent(parent);
            // A QUALIFIED select of a PACKAGE parameter (pkg::A[0]) names
            // itself pkg::A (fullname==name, omitted by the dump) and parents
            // at the package's def parameter object. An UNQUALIFIED read of
            // the same param (wildcard/explicit import, `V[i]`) is a read of
            // the copy MATERIALIZED into this scope: bare name, prefix-joined
            // fullname, parented where it appears (Surelog;
            // DefaultPatternInt `ASSIGN_VADDR[i] = V[i]` -> VpiName V,
            // work@top.ASSIGN_VADDR.V at the assignment). Same qualified-vs-
            // imported discriminator the fold rules above use — NOT a general
            // pkg:: strip (see the naming-is-context-dependent dead end).
            if (nv.symbol.kind == SymbolKind::Parameter &&
                rawText(es.value().sourceRange).find("::") !=
                    std::string::npos) {
                if (auto psc2 = nv.symbol.getParentScope();
                    psc2 && psc2->asSymbol().kind == SymbolKind::Package) {
                    std::string pn2 = std::string(psc2->asSymbol().name) + "::" +
                                      std::string(nv.symbol.name);
                    bs->VpiName(pn2);
                    bs->VpiFullName(pn2);
                    if (auto pit2 = pkgDefMap.find(&psc2->asSymbol());
                        pit2 != pkgDefMap.end() && pit2->second->Parameters())
                        for (auto* pp2 : *pit2->second->Parameters())
                            if (pp2->VpiName() == nv.symbol.name)
                                bs->VpiParent(pp2);
                }
            }
            // A bit-select write re-points whole refs when the base is a
            // function formal (io_decl), OR a logic_net written by a BLOCKING
            // procedural assignment in this body: prim_secded's blocking
            // `data_o[i] = ...` makes every whole data_o ref (incl. the earlier
            // whole write) alias the first data_o[57] bit_select (Surelog). A
            // NONBLOCKING bit-write keeps the net (asicworld_serial_crc,
            // unpacked_array_shift_ff); local vars keep their own binding.
            if (auto nit = netMap.find(&nv.symbol); nit != netMap.end()) {
                bool doNote = nit->second->UhdmType() == UHDM::uhdmio_decl;
                if (!doNote && inLhs &&
                    nit->second->UhdmType() == UHDM::uhdmlogic_net && parent &&
                    parent->UhdmType() == UHDM::uhdmassignment &&
                    ((UHDM::assignment*)parent)->VpiBlocking())
                    doNote = true;
                if (doNote)
                    noteSelectObj(&nv.symbol, bs);
            }
            // The FUNCTION RETURN NAME is not in netMap (its object is minted
            // by drainFuncRet), but a bit-select write on it re-points the
            // body's bare refs exactly the same way — see the law at the
            // funcRetRefs push site (openmsp430 one_hot16/one_hot8).
            else if (funcRetSym && &nv.symbol == funcRetSym && inLhs)
                noteSelectObj(&nv.symbol, bs);
            // Surelog anchors rvalue bit_selects at the index expression,
            // but lvalue ones span the whole select.
            // PARAM-INIT selects span the WHOLE select (func_upto's
            // localparam !(SWAPS[0]) chains); other RHS selects keep the
            // selector span.
            setLoc(bs, (inLhs || inParamInit) ? expr.sourceRange
                                              : es.selector().sourceRange);
            // ELAB gen-scope CONN index FOLD: an index OPERATION that is
            // constant after genvar substitution (CC[i+1] in a for-generate
            // body) collapses to ONE UINT constant spanning the FIRST source
            // token of the index expression (Surelog folds the whole subtree).
            if (genvarConnFold &&
                stripImplicitConv(es.selector()).kind != ExpressionKind::NamedValue &&
                !isLiteralExpr(es.selector())) {
                ASTContext gcx8(comp.getRoot(), LookupLocation::max);
                if (auto iv8 = gcx8.tryEval(es.selector());
                    iv8 && iv8.isInteger() && !iv8.integer().hasUnknown()) {
                    auto* c8 = s.MakeConstant();
                    std::string d8 =
                        iv8.integer().toString(LiteralBase::Decimal, false);
                    c8->VpiDecompile(d8);
                    c8->VpiSize(64);
                    c8->VpiValue("UINT:" + d8);
                    c8->VpiConstType(vpiUIntConst);
                    c8->VpiParent(bs);
                    auto st8 = es.selector().sourceRange.start();
                    std::string braw8(rawText(es.selector().sourceRange));
                    size_t tok8 = 0;
                    while (tok8 < braw8.size() &&
                           (isalnum((unsigned char)braw8[tok8]) ||
                            braw8[tok8] == '_' || braw8[tok8] == '$'))
                        tok8++;
                    if (!tok8)
                        tok8 = d8.size();
                    setLoc(c8, SourceRange(st8, st8 + tok8));
                    bs->VpiIndex(c8);
                    return bs;
                }
            }
            // Refs nested in index OPERATIONS scope by the base name;
            // direct index refs stay module-scoped.
            std::string idxPrefix = prefix;
            bool idxRescoped = false;
            if (stripImplicitConv(es.selector()).kind != ExpressionKind::NamedValue) {
                idxPrefix = prefix + "." + std::string(nv.symbol.name);
                idxRescoped = true;
            }
            if (idxRescoped)
                selIdxScopeDepth++;
            // An ELAB gen-scope CA fold inside this index scopes its typespec
            // ref at the SELECT BASE (see genCaSelBasePfx) — for a DIRECT
            // index ref too, which idxPrefix leaves module-scoped.
            std::string savedSelB9 = genCaSelBasePfx;
            if (genCaLhsParamFold)
                genCaSelBasePfx = joinRef(prefix, nv.symbol.name);
            auto* ix = emitExpr(es.selector(), bs, idxPrefix, netMap);
            genCaSelBasePfx = savedSelB9;
            if (idxRescoped)
                selIdxScopeDepth--;
            if (ix)
                bs->VpiIndex((UHDM::expr*)ix);
            return bs;
        }
        case ExpressionKind::RangeSelect: {
            auto& rs = expr.as<RangeSelectExpression>();
            // § thisPathSelectErased4 — SITE 2 of 3. A RANGE select erases the
            // same way an element select does (`this.data[k][3:0]` -> the
            // hier_path `this.data`), measured as grid cell d5.
            if (auto* thp = emitThisPathSelectErased(expr, parent, prefix))
                return thp;
            // Range select of an element select (x[0][1:0]) flattens to a
            // var_select whose leading indices are the element selectors and
            // whose final index is the (indexed_)part_select.
            if (rs.value().kind == ExpressionKind::ElementSelect) {
                std::vector<const Expression*> sels;
                const Expression* base = &rs.value();
                while (base->kind == ExpressionKind::ElementSelect) {
                    sels.push_back(&base->as<ElementSelectExpression>().selector());
                    base = &base->as<ElementSelectExpression>().value();
                }
                if (base->kind == ExpressionKind::NamedValue) {
                    auto& nvb = base->as<NamedValueExpression>();
                    if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                        refCollector->insert(&nvb.symbol);
                    auto* vs = s.MakeVar_select();
                    vs->VpiName(nvb.symbol.name);
                    std::string baseFull = joinRef(prefix, nvb.symbol.name);
                    vs->VpiFullName(baseFull);
                    vs->VpiParent(parent);
                    setLoc(vs, expr.sourceRange);
                    auto* idxs = s.MakeExprVec();
                    bool savedFCP = forceConstParent;
                    for (auto it2 = sels.rbegin(); it2 != sels.rend(); ++it2) {
                        // Only literal indices force-parent; select indices
                        // (part_select) keep their own bound rules.
                        forceConstParent = isLiteralExpr(**it2);
                        if (auto* ix = emitExpr(**it2, vs, baseFull, netMap))
                            idxs->push_back((UHDM::expr*)ix);
                    }
                    forceConstParent = savedFCP;
                    // Final selector: a part_select (or indexed_part_select).
                    SourceRange selRange(rs.left().sourceRange.start(),
                                         rs.right().sourceRange.end());
                    bool constSel = false;
                    {
                        ASTContext cctx(comp.getRoot(), LookupLocation::max);
                        constSel = (rs.left().kind == ExpressionKind::IntegerLiteral ||
                                    cctx.tryEval(rs.left())) &&
                                   (rs.right().kind == ExpressionKind::IntegerLiteral ||
                                    cctx.tryEval(rs.right()));
                    }
                    if (rs.getSelectionKind() == RangeSelectionKind::Simple) {
                        auto* ps = s.MakePart_select();
                        ps->VpiName(nvb.symbol.name);
                        ps->VpiDefName(nvb.symbol.name);
                        // The part_select repeats the base name, so its own
                        // fullname DOUBLES it; bound refs inside the ranges
                        // scope through THAT (UHDM ComputeFullName only skips
                        // a bit_select/indexed_part_select/hier_path parent).
                        std::string psFull =
                            baseFull + "." + std::string(nvb.symbol.name);
                        ps->VpiFullName(psFull);
                        ps->VpiParent(vs);
                        setLoc(ps, selRange);
                        if (constSel)
                            ps->VpiConstantSelect(true);
                        // A range endpoint that IS a literal stays unparented;
                        // a constant nested in an endpoint OPERATION keeps its
                        // operation parent (Surelog).
                        bool savedSup = suppressConstParent;
                        suppressConstParent = isLiteralExpr(rs.left());
                        if (auto* l = emitExpr(rs.left(), ps, psFull, netMap))
                            ps->Left_range((UHDM::expr*)l);
                        suppressConstParent = isLiteralExpr(rs.right());
                        if (auto* r = emitExpr(rs.right(), ps, psFull, netMap))
                            ps->Right_range((UHDM::expr*)r);
                        suppressConstParent = savedSup;
                        idxs->push_back(ps);
                    }
                    else {
                        auto* ips = s.MakeIndexed_part_select();
                        ips->VpiName(nvb.symbol.name);
                        ips->VpiDefName(nvb.symbol.name);
                        ips->VpiFullName(baseFull + "." + std::string(nvb.symbol.name));
                        ips->VpiParent(vs);
                        setLoc(ips, selRange);
                        ips->VpiIndexedPartSelectType(
                            rs.getSelectionKind() == RangeSelectionKind::IndexedUp ? 1 : 2);
                        // An INDEXED part-select is "constant" on its WIDTH
                        // alone — the base is allowed to vary — exactly like
                        // the whole-variable form below; only the SIMPLE
                        // part_select above needs both bounds.  Scr1SvTests
                        // scr1_dp_memory `ram_block[addrb][i*8 +: 8]`: golden
                        // stamps vpiConstantSelect:1 with `i*8` as the base,
                        // and that single missing flag was the design-echo
                        // head (49 of 93 vectors) — the ONE vpiConstantSelect
                        // of 343 that differed across the whole database.
                        {
                            ASTContext wctx9(comp.getRoot(), LookupLocation::max);
                            if (rs.right().kind == ExpressionKind::IntegerLiteral ||
                                wctx9.tryEval(rs.right()))
                                ips->VpiConstantSelect(true);
                        }
                        bool savedSup = suppressConstParent;
                        suppressConstParent = isLiteralExpr(rs.left());
                        if (auto* b = emitExpr(rs.left(), ips, baseFull, netMap))
                            ips->Base_expr((UHDM::expr*)b);
                        suppressConstParent = isLiteralExpr(rs.right());
                        if (auto* w = emitExpr(rs.right(), ips, baseFull, netMap))
                            ips->Width_expr((UHDM::expr*)w);
                        suppressConstParent = savedSup;
                        idxs->push_back(ips);
                    }
                    vs->Exprs(idxs);
                    return vs;
                }
            }
            // A member-path whose LAST member carries element-select(s) THEN a
            // range (keymgr_key_i.key[0][i * 32+:32]) -> hier_path whose last
            // element is a var_select (SL model): the member name, the leading
            // element indices, and a final (indexed_)part_select index named by
            // the member (fullname DOUBLED). (IndexedPartSelectInFor)
            if (rs.value().kind == ExpressionKind::ElementSelect) {
                std::vector<const Expression*> esels;
                const Expression* eb = &rs.value();
                while (eb->kind == ExpressionKind::ElementSelect) {
                    esels.push_back(&eb->as<ElementSelectExpression>().selector());
                    eb = &eb->as<ElementSelectExpression>().value();
                }
                std::vector<const Expression*> mchain;
                const Expression* mb = eb;
                while (mb->kind == ExpressionKind::MemberAccess) {
                    mchain.push_back(mb);
                    mb = &mb->as<MemberAccessExpression>().value();
                }
                if (!mchain.empty() && mb->kind == ExpressionKind::NamedValue &&
                    (mb->as<NamedValueExpression>().symbol.kind ==
                         SymbolKind::Variable ||
                     mb->as<NamedValueExpression>().symbol.kind ==
                         SymbolKind::Net)) {
                    auto& bnv = mb->as<NamedValueExpression>();
                    if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                        refCollector->insert(&bnv.symbol);
                    std::string selText = spaceIdxOps(selName(rawText(expr.sourceRange)));
                    auto* hp = s.MakeHier_path();
                    hp->VpiName(selText);
                    hp->VpiFullName(selText);
                    hp->VpiParent(parent);
                    setLoc(hp, expr.sourceRange);
                    auto* elems = s.MakeAnyVec();
                    {
                        auto* r = s.MakeRef_obj();
                        r->VpiName(bnv.symbol.name);
                        (void)r->VpiFullName();
                        r->VpiParent(hp);
                        // An LVALUE hier_path anchors its base ref at the
                        // FIRST MEMBER's name token (Surelog) — the same
                        // second-element anchor the dotted-name paths use.
                        SourceRange bSpan9 = mb->sourceRange;
                        if (inLhs) {
                            auto& m09 =
                                mchain.back()->as<MemberAccessExpression>();
                            auto m0e9 = mchain.back()->sourceRange.end();
                            auto m0s9 = m0e9 - m09.member.name.size();
                            bSpan9 = SourceRange(m0s9, m0e9);
                        }
                        setLoc(r, bSpan9);
                        elems->push_back(r);
                    }
                    // mchain is outer..inner; iterate base-first (reverse).
                    for (auto it2 = mchain.rbegin(); it2 != mchain.rend(); ++it2) {
                        auto& ma = (*it2)->as<MemberAccessExpression>();
                        bool last = *it2 == mchain.front();
                        std::string memName(ma.member.name);
                        auto memEnd = (*it2)->sourceRange.end();
                        if (!last) {
                            auto* r = s.MakeRef_obj();
                            r->VpiName(memName);
                            (void)r->VpiFullName();
                            r->VpiParent(hp);
                            setLoc(r, SourceRange(memEnd - memName.size(), memEnd));
                            elems->push_back(r);
                            continue;
                        }
                        std::string selFull9 = joinRef(prefix, selText);
                        SourceRange rngSpan9(rs.left().sourceRange.start(),
                                             rs.right().sourceRange.end());
                        bool widthConst9 = false;
                        {
                            ASTContext wctx(comp.getRoot(), LookupLocation::max);
                            widthConst9 =
                                rs.right().kind == ExpressionKind::IntegerLiteral ||
                                (bool)wctx.tryEval(rs.right());
                        }
                        if (inLhs) {
                            // LVALUE shape (Surelog's hier_path branch of
                            // compileSelectExpression):
                            //   field[i]        -> bit_select(field, i)
                            //   field[i][j]...  -> var_select(field, [i,j..])
                            //   ...[hi:lo]      -> a SEPARATE, UNNAMED
                            //                      (indexed_)part_select ELEMENT
                            // The trailing range is never an index of the
                            // select — only an RVALUE read folds it in as the
                            // var_select's last index (the form below, kept
                            // for keymgr_key_i.key[0][i*32+:32]).
                            UHDM::any* sel9 = nullptr;
                            SourceRange selSpan9(
                                memEnd - memName.size(),
                                rs.value().sourceRange.end());
                            bool savedFCP9 = forceConstParent;
                            if (esels.size() == 1) {
                                auto* bs = s.MakeBit_select();
                                bs->VpiName(memName);
                                bs->VpiFullName(selFull9 + "." + memName);
                                bs->VpiParent(hp);
                                setLoc(bs, selSpan9);
                                forceConstParent = isLiteralExpr(*esels[0]);
                                if (auto* ix =
                                        emitExpr(*esels[0], bs, prefix, netMap))
                                    bs->VpiIndex((UHDM::expr*)ix);
                                sel9 = bs;
                            }
                            else {
                                auto* vs = s.MakeVar_select();
                                vs->VpiName(memName);
                                vs->VpiFullName(selFull9 + "." + memName);
                                vs->VpiParent(hp);
                                setLoc(vs, selSpan9);
                                auto* ix9 = s.MakeExprVec();
                                for (auto it3 = esels.rbegin();
                                     it3 != esels.rend(); ++it3) {
                                    forceConstParent = isLiteralExpr(**it3);
                                    if (auto* ix =
                                            emitExpr(**it3, vs, prefix, netMap))
                                        ix9->push_back((UHDM::expr*)ix);
                                }
                                vs->Exprs(ix9);
                                sel9 = vs;
                            }
                            forceConstParent = savedFCP9;
                            elems->push_back(sel9);
                            // The trailing range's bounds parent to their
                            // (indexed_)part_select only in the ELABORATED
                            // re-emission of the cont-assign LHS; the def view
                            // leaves them unparented (Surelog).
                            bool savedSup9 = suppressConstParent;
                            bool savedFC9 = forceConstParent;
                            suppressConstParent = true;
                            auto bound9 = [&](const Expression& e9) {
                                forceConstParent =
                                    elabContAssignLhs && isLiteralExpr(e9);
                            };
                            if (rs.getSelectionKind() ==
                                RangeSelectionKind::Simple) {
                                auto* ps = s.MakePart_select();
                                ps->VpiFullName(selFull9);
                                ps->VpiParent(hp);
                                setLoc(ps, rngSpan9);
                                if (widthConst9)
                                    ps->VpiConstantSelect(true);
                                bound9(rs.left());
                                if (auto* l = emitExpr(rs.left(), ps, selFull9,
                                                       netMap))
                                    ps->Left_range((UHDM::expr*)l);
                                bound9(rs.right());
                                if (auto* r2 = emitExpr(rs.right(), ps, selFull9,
                                                        netMap))
                                    ps->Right_range((UHDM::expr*)r2);
                                elems->push_back(ps);
                            }
                            else {
                                auto* ips = s.MakeIndexed_part_select();
                                ips->VpiFullName(selFull9);
                                ips->VpiParent(hp);
                                setLoc(ips, rngSpan9);
                                ips->VpiIndexedPartSelectType(
                                    rs.getSelectionKind() ==
                                            RangeSelectionKind::IndexedUp
                                        ? 1
                                        : 2);
                                if (widthConst9)
                                    ips->VpiConstantSelect(true);
                                bound9(rs.left());
                                if (auto* b = emitExpr(rs.left(), ips, selFull9,
                                                       netMap))
                                    ips->Base_expr((UHDM::expr*)b);
                                bound9(rs.right());
                                if (auto* w = emitExpr(rs.right(), ips, selFull9,
                                                       netMap))
                                    ips->Width_expr((UHDM::expr*)w);
                                elems->push_back(ips);
                            }
                            suppressConstParent = savedSup9;
                            forceConstParent = savedFC9;
                            continue;
                        }
                        auto* vs = s.MakeVar_select();
                        vs->VpiName(memName);
                        std::string vsFull =
                            joinRef(prefix, selText) + "." + memName;
                        vs->VpiFullName(vsFull);
                        vs->VpiParent(hp);
                        setLoc(vs, SourceRange(memEnd - memName.size(),
                                               expr.sourceRange.end()));
                        auto* idxs = s.MakeExprVec();
                        bool savedFCP = forceConstParent;
                        for (auto it3 = esels.rbegin(); it3 != esels.rend(); ++it3) {
                            forceConstParent = isLiteralExpr(**it3);
                            if (auto* ix = emitExpr(**it3, vs, prefix, netMap))
                                idxs->push_back((UHDM::expr*)ix);
                        }
                        forceConstParent = savedFCP;
                        SourceRange selRange(rs.left().sourceRange.start(),
                                             rs.right().sourceRange.end());
                        std::string dblFull = vsFull + "." + memName;
                        bool widthConst = false;
                        {
                            ASTContext wctx(comp.getRoot(), LookupLocation::max);
                            widthConst =
                                rs.right().kind == ExpressionKind::IntegerLiteral ||
                                (bool)wctx.tryEval(rs.right());
                        }
                        bool savedSup = suppressConstParent;
                        if (rs.getSelectionKind() == RangeSelectionKind::Simple) {
                            auto* ps = s.MakePart_select();
                            ps->VpiName(memName);
                            ps->VpiDefName(memName);
                            ps->VpiFullName(dblFull);
                            ps->VpiParent(vs);
                            setLoc(ps, selRange);
                            if (widthConst)
                                ps->VpiConstantSelect(true);
                            suppressConstParent = true;
                            if (auto* l = emitExpr(rs.left(), ps, dblFull, netMap))
                                ps->Left_range((UHDM::expr*)l);
                            if (auto* r2 = emitExpr(rs.right(), ps, dblFull, netMap))
                                ps->Right_range((UHDM::expr*)r2);
                            suppressConstParent = savedSup;
                            idxs->push_back(ps);
                        }
                        else {
                            auto* ips = s.MakeIndexed_part_select();
                            ips->VpiName(memName);
                            ips->VpiDefName(memName);
                            ips->VpiFullName(dblFull);
                            ips->VpiParent(vs);
                            setLoc(ips, selRange);
                            ips->VpiIndexedPartSelectType(
                                rs.getSelectionKind() == RangeSelectionKind::IndexedUp
                                    ? 1
                                    : 2);
                            if (widthConst)
                                ips->VpiConstantSelect(true);
                            suppressConstParent = isLiteralExpr(rs.left());
                            if (auto* b = emitExpr(rs.left(), ips, dblFull, netMap))
                                ips->Base_expr((UHDM::expr*)b);
                            suppressConstParent = true; // width unparented (SL)
                            if (auto* w = emitExpr(rs.right(), ips, dblFull, netMap))
                                ips->Width_expr((UHDM::expr*)w);
                            suppressConstParent = savedSup;
                            idxs->push_back(ips);
                        }
                        vs->Exprs(idxs);
                        elems->push_back(vs);
                    }
                    hp->Path_elems(elems);
                    return hp;
                }
            }
            // Range select of a member access (a.b[0+:8]) becomes a hier_path
            // whose last element is an (indexed_)part_select.
            const Expression* rsBottom = &stripImplicitConv(rs.value());
            while (rsBottom->kind == ExpressionKind::MemberAccess)
                rsBottom = &stripImplicitConv(
                    rsBottom->as<MemberAccessExpression>().value());
            if (stripImplicitConv(rs.value()).kind == ExpressionKind::MemberAccess &&
                rsBottom->kind == ExpressionKind::NamedValue) {
                std::vector<const Expression*> chain;
                const Expression* base = &stripImplicitConv(rs.value());
                while (base->kind == ExpressionKind::MemberAccess) {
                    chain.push_back(base);
                    base = &stripImplicitConv(base->as<MemberAccessExpression>().value());
                }
                if (base->kind == ExpressionKind::NamedValue) {
                    auto& bnv = base->as<NamedValueExpression>();
                    if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                        refCollector->insert(&bnv.symbol);
                    // § vifClockingPathComponent5 — SITE 3 of 3, the RANGE
                    // select over a collapsed vif reference
                    // (`vif.cb.din[3:0] <= 4'h5`, arm a3 cell e2).  Same gate as
                    // SITE 1: ONE member access above the base.
                    std::vector<std::pair<std::string, SourceRange>> vifComps5;
                    if (chain.size() == 1)
                        vifCollapsedComponents5(
                            chain.front()->as<MemberAccessExpression>(), vifComps5);
                    auto* hp = s.MakeHier_path();
                    std::string dotted(bnv.symbol.name);
                    for (auto& vc5 : vifComps5)
                        dotted += "." + vc5.first;
                    for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2)
                        dotted += "." +
                                  std::string(
                                      (*it2)->as<MemberAccessExpression>().member.name);
                    // § elabHierSelWidthFold (EmitHelpers selWidthParamFold):
                    // an indexed width that names a parameter is substituted by
                    // its value BEFORE the select is decompiled.
                    auto wf9 = rs.getSelectionKind() == RangeSelectionKind::Simple
                                   ? SelWidthFold{}
                                   : selWidthParamFold(rs.right());
                    // § hierSelPkgParamFold — the bound text renders the
                    // package parameters this select reads at their VALUES
                    // (vo.sv rows D/E/F); a module-scope one stays spelled
                    // out (row G).
                    std::vector<PkgFoldSub> pf9;
                    collectPkgParamFolds(rs, pf9);
                    std::string selText =
                        wf9.ok
                            ? spaceIdxOps(selName(rawTextPkgFold(
                                  SourceRange(rs.left().sourceRange.start(),
                                              rs.left().sourceRange.end()),
                                  pf9))) +
                                  (rs.getSelectionKind() ==
                                           RangeSelectionKind::IndexedUp
                                       ? "+:"
                                       : "-:") +
                                  wf9.text
                            : spaceIdxOps(selName(rawTextPkgFold(
                                  SourceRange(rs.left().sourceRange.start(),
                                              rs.right().sourceRange.end()),
                                  pf9)));
                    dotted += "[" + selText + "]";
                    hp->VpiName(dotted);
                    hp->VpiFullName(dotted);
                    hp->VpiParent(parent);
                    setLoc(hp, expr.sourceRange);
                    auto* elems = s.MakeAnyVec();
                    {
                        auto* r = s.MakeRef_obj();
                        r->VpiName(bnv.symbol.name);
                        (void)r->VpiFullName();
                        r->VpiParent(hp);
                        // Surelog spans the base ref from the FIRST member
                        // name's start (the select anchor), not the base's own
                        // token, keeping only its own length.
                        SourceRange bsr9 = base->sourceRange;
                        if (inLhs && !chain.empty()) {
                            // § vifClockingPathComponent5 — SITE 3 of 3.  With a
                            // recovered component the anchor is that component's
                            // WHOLE token, not "the first member's start plus the
                            // base's own length": golden's a3 e2 base ref is
                            // 43:9-11, i.e. exactly the two columns of `cb`.
                            if (!vifComps5.empty()) {
                                bsr9 = vifComps5.front().second;
                            }
                            else {
                            auto& fma9 =
                                (*chain.rbegin())->as<MemberAccessExpression>();
                            auto fst9 = (*chain.rbegin())->sourceRange.end() -
                                        fma9.member.name.size();
                            bsr9 = SourceRange(
                                fst9, fst9 + bnv.symbol.name.size());
                            }
                        }
                        setLoc(r, bsr9);
                        elems->push_back(r);
                    }
                    // § vifClockingPathComponent5 — SITE 3 of 3: the recovered
                    // components, bare ref_objs at their own token (same shape as
                    // SITE 1's).
                    for (auto& vc5 : vifComps5) {
                        auto* r = s.MakeRef_obj();
                        r->VpiName(vc5.first);
                        (void)r->VpiFullName();
                        r->VpiParent(hp);
                        setLoc(r, vc5.second);
                        elems->push_back(r);
                    }
                    for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2) {
                        auto& ma = (*it2)->as<MemberAccessExpression>();
                        bool last = *it2 == chain.front();
                        if (!last) {
                            auto* r = s.MakeRef_obj();
                            r->VpiName(ma.member.name);
                            (void)r->VpiFullName();
                            r->VpiParent(hp);
                            auto end = (*it2)->sourceRange.end();
                            setLoc(r, SourceRange(end - ma.member.name.size(), end));
                            elems->push_back(r);
                            continue;
                        }
                        SourceRange elemLoc(
                            (*it2)->sourceRange.end() - ma.member.name.size(),
                            rs.right().sourceRange.end());
                        bool constSel = false;
                        // § hierSelConstWidthSuffices17 (r10earl17).  For the
                        // INDEXED form the base may be a variable and the
                        // select is still vpiConstantSelect — "constant width
                        // suffices", the rule the plain (non-hier) indexed
                        // emitter below and the two var_select emitters above
                        // already use (widthConst9 / widthConst).  THIS site
                        // was the only one demanding both ends, and that made
                        // `tl_i.a_data[8*i+:8]` inside a for-loop
                        // (tlul_adapter_sram.sv:163) read false where golden
                        // reads true — the head of FOUR AllModules entries
                        // (tlul_adapter_sram plus hmac / spi_device / usbdev,
                        // which re-enter it through a ref_module) once
                        // § pkgBoundMintTsTopInstance17 cleared the pointer
                        // ahead of it.  The SIMPLE arm keeps the both-ends
                        // rule: a `[a:b]` select has no width to be constant.
                        bool constSelIdx17 = false;
                        {
                            ASTContext cctx(comp.getRoot(), LookupLocation::max);
                            bool lc17 = rs.left().kind ==
                                            ExpressionKind::IntegerLiteral ||
                                        (bool)cctx.tryEval(rs.left());
                            constSelIdx17 = rs.right().kind ==
                                                ExpressionKind::IntegerLiteral ||
                                            (bool)cctx.tryEval(rs.right());
                            constSel = lc17 && constSelIdx17;
                        }
                        if (rs.getSelectionKind() == RangeSelectionKind::Simple) {
                            auto* ps = s.MakePart_select();
                            ps->VpiName(ma.member.name);
                            // A procedural WRITE names the select (Surelog);
                            // a read leaves it bare.
                            if (inLhs)
                                ps->VpiDefName(ma.member.name);
                            ps->VpiParent(hp);
                            // A READ's select keeps the hier text as its
                            // fullname; a write freezes the lazy chain name.
                            if (inLhs)
                                (void)ps->VpiFullName();
                            else
                                ps->VpiFullName(dotted);
                            setLoc(ps, elemLoc);
                            if (constSel)
                                ps->VpiConstantSelect(true);
                            bool sup = suppressConstParent;
                            suppressConstParent = true;
                            if (auto* l = emitExpr(rs.left(), ps, prefix, netMap))
                                ps->Left_range((UHDM::expr*)l);
                            if (auto* r2 = emitExpr(rs.right(), ps, prefix, netMap))
                                ps->Right_range((UHDM::expr*)r2);
                            suppressConstParent = sup;
                            elems->push_back(ps);
                        }
                        else {
                            auto* ips = s.MakeIndexed_part_select();
                            ips->VpiName(ma.member.name);
                            ips->VpiParent(hp);
                            // The indexed form carries the dotted select
                            // string as its fullname and stops BEFORE the ']'.
                            ips->VpiFullName(dotted);
                            setLoc(ips, SourceRange(elemLoc.start(),
                                                    rs.right().sourceRange.end()));
                            ips->VpiIndexedPartSelectType(
                                rs.getSelectionKind() == RangeSelectionKind::IndexedUp ? 1
                                                                                       : 2);
                            if (constSelIdx17)  // § hierSelConstWidthSuffices17
                                ips->VpiConstantSelect(true);
                            bool sup = suppressConstParent;
                            suppressConstParent = isLiteralExpr(rs.left());
                            if (auto* b = emitExpr(rs.left(), ips, prefix, netMap))
                                ips->Base_expr((UHDM::expr*)b);
                            suppressConstParent = isLiteralExpr(rs.right());
                            // § elabHierSelWidthFold: the substituted width is
                            // the parameter's VALUE, sized by that parameter's
                            // own type, carried UNPARENTED at the reference's
                            // span (golden).  A MODULE localparam never reached
                            // a fold arm here at all and survived as a ref_obj.
                            if (wf9.ok) {
                                auto* wc9 = s.MakeConstant();
                                wc9->VpiDecompile(wf9.text);
                                wc9->VpiSize(wf9.size);
                                wc9->VpiValue("UINT:" + wf9.text);
                                wc9->VpiConstType(vpiUIntConst);
                                setLoc(wc9, rs.right().sourceRange);
                                stampFoldedPkgParamTs(wc9, *wf9.sym, prefix);
                                ips->Width_expr(wc9);
                            }
                            else if (auto* w = emitExpr(rs.right(), ips, prefix,
                                                        netMap))
                                ips->Width_expr((UHDM::expr*)w);
                            suppressConstParent = sup;
                            elems->push_back(ips);
                        }
                    }
                    hp->Path_elems(elems);
                    return hp;
                }
            }
            // Range select over a DOTTED interface-member path
            // (sub.req.adr[A:B]): hier_path whose final element is the
            // (indexed_)part_select named by the last component.
            {
                const Expression* bb = &stripImplicitConv(rs.value());
                while (bb->kind == ExpressionKind::MemberAccess ||
                       bb->kind == ExpressionKind::ElementSelect) {
                    if (bb->kind == ExpressionKind::MemberAccess)
                        bb = &bb->as<MemberAccessExpression>().value();
                    else
                        bb = &bb->as<ElementSelectExpression>().value();
                }
                if (bb->kind == ExpressionKind::ArbitrarySymbol ||
                    bb->kind == ExpressionKind::HierarchicalValue ||
                    (bb->kind == ExpressionKind::NamedValue &&
                     stripImplicitConv(rs.value()).kind !=
                         ExpressionKind::NamedValue)) {
                    std::string baseDotted = rawTextExpr(rs.value());
                    if (baseDotted.empty())
                        baseDotted = selBaseText(rawTextExpr(expr));
                    if (baseDotted.find('.') != std::string::npos) {
                        // Surelog's decompiler renders the part-select NAME from
                        // the bound exprs: binary operators get surrounding
                        // SPACES ([ADR-1] -> [ADR - 1]), and a bound that is
                        // itself a hier/dotted reference (sub.OFF) is DROPPED
                        // (empty). The indexed (+:/-:) form keeps the raw
                        // space-stripped text.
                        auto spaceOps9 = [](const std::string& in) {
                            std::string o;
                            for (size_t i = 0; i < in.size(); i++) {
                                char c = in[i];
                                if ((c == '+' || c == '-' || c == '*' ||
                                     c == '/') &&
                                    i > 0 && in[i - 1] != ' ' && in[i - 1] != '[') {
                                    o += ' ';
                                    o += c;
                                    if (i + 1 < in.size() && in[i + 1] != ' ')
                                        o += ' ';
                                }
                                else
                                    o += c;
                            }
                            return o;
                        };
                        auto renderBound9 = [&](const Expression& b) -> std::string {
                            std::string raw = rawText(b.sourceRange);
                            if (raw.find('.') != std::string::npos)
                                return std::string();
                            return spaceOps9(raw);
                        };
                        // § elabHierSelWidthFold (EmitHelpers
                        // selWidthParamFold) — same law on the dotted-BASE
                        // shape.
                        auto wf9 =
                            rs.getSelectionKind() == RangeSelectionKind::Simple
                                ? SelWidthFold{}
                                : selWidthParamFold(rs.right());
                        std::string selText;
                        if (rs.getSelectionKind() == RangeSelectionKind::Simple)
                            selText = selName(baseDotted) + "[" +
                                      renderBound9(rs.left()) + ":" +
                                      renderBound9(rs.right()) + "]";
                        else if (stripImplicitConv(rs.left()).kind ==
                                 ExpressionKind::NamedValue)
                            selText = selName(rawText(expr.sourceRange));
                        else if (wf9.ok)
                            selText =
                                selName(baseDotted) + "[" +
                                spaceOps9(selName(std::string(
                                    rawText(rs.left().sourceRange)))) +
                                (rs.getSelectionKind() ==
                                         RangeSelectionKind::IndexedUp
                                     ? "+:"
                                     : "-:") +
                                wf9.text + "]";
                        else
                            // An ARITHMETIC indexed base decompiles with
                            // operator spacing (sub.src[i*8+:8] ->
                            // sub.src[i * 8+:8]); the +:/-: token and the
                            // width stay tight (Surelog).
                            selText =
                                selName(baseDotted) + "[" +
                                spaceOps9(selName(std::string(
                                    rawText(rs.left().sourceRange)))) +
                                (rs.getSelectionKind() ==
                                         RangeSelectionKind::IndexedUp
                                     ? "+:"
                                     : "-:") +
                                selName(std::string(
                                    rawText(rs.right().sourceRange))) +
                                "]";
                        auto* hp = s.MakeHier_path();
                        hp->VpiName(selText);
                        hp->VpiFullName(selText);
                        hp->VpiParent(parent);
                        setLoc(hp, expr.sourceRange);
                        auto* elems = s.MakeAnyVec();
                        auto exprStart = rs.value().sourceRange.start();
                        std::vector<std::pair<std::string, size_t>> comps;
                        for (size_t st = 0; st <= baseDotted.size();) {
                            auto dot = baseDotted.find('.', st);
                            if (dot == std::string::npos)
                                dot = baseDotted.size();
                            comps.emplace_back(baseDotted.substr(st, dot - st), st);
                            if (dot == baseDotted.size())
                                break;
                            st = dot + 1;
                        }
                        // AST selectors aligned with the dotted TEXT components
                        // (base..outer). A component written `name[expr]` with
                        // a NON-constant index is still a bit_select carrying
                        // the BOUND index reference — the same shape the
                        // select-less sibling path builds — not a flat ref_obj
                        // named after the raw text (Scr1SvTests scr1_mem_axi
                        // `req_fifo[req_proc_ptr].axi_addr[1:0]`; purpose-built
                        // golden r10scr5_f).
                        std::vector<const Expression*> compSel;
                        {
                            std::vector<const Expression*> revs;
                            const Expression* pend = nullptr;
                            const Expression* c9 = &stripImplicitConv(rs.value());
                            while (true) {
                                if (c9->kind == ExpressionKind::MemberAccess) {
                                    revs.push_back(pend);
                                    pend = nullptr;
                                    c9 = &stripImplicitConv(
                                        c9->as<MemberAccessExpression>().value());
                                }
                                else if (c9->kind == ExpressionKind::ElementSelect) {
                                    pend = &c9->as<ElementSelectExpression>()
                                                .selector();
                                    c9 = &stripImplicitConv(
                                        c9->as<ElementSelectExpression>().value());
                                }
                                else {
                                    revs.push_back(pend);
                                    break;
                                }
                            }
                            compSel.assign(revs.rbegin(), revs.rend());
                        }
                        for (size_t ci = 0; ci + 1 < comps.size(); ci++) {
                            auto& [cn, co] = comps[ci];
                            // An indexed component (a[0]) is a bit_select.
                            auto lb2 = cn.find('[');
                            auto rb2 = cn.find(']');
                            if (lb2 != std::string::npos &&
                                rb2 == cn.size() - 1 && rb2 > lb2 + 1 &&
                                cn.find_first_not_of("0123456789", lb2 + 1) != rb2 &&
                                ci < compSel.size() && compSel[ci] &&
                                compSel[ci]->kind == ExpressionKind::NamedValue) {
                                std::string bn = cn.substr(0, lb2);
                                auto* bsv = s.MakeBit_select();
                                bsv->VpiName(bn);
                                bsv->VpiFullName(cn);
                                bsv->VpiParent(hp);
                                setLoc(bsv, SourceRange(exprStart + co,
                                                        exprStart + co + bn.size()));
                                // The index ref parents at the HIER_PATH.
                                if (auto* ix =
                                        emitExpr(*compSel[ci], hp, prefix, netMap))
                                    bsv->VpiIndex((UHDM::expr*)ix);
                                elems->push_back(bsv);
                                continue;
                            }
                            if (lb2 != std::string::npos && rb2 != std::string::npos &&
                                rb2 > lb2 + 1 &&
                                cn.find_first_not_of("0123456789", lb2 + 1) == rb2) {
                                std::string bn = cn.substr(0, lb2);
                                std::string ix = cn.substr(lb2 + 1, rb2 - lb2 - 1);
                                auto* bsm = s.MakeBit_select();
                                bsm->VpiName(bn);
                                // Surelog names the element by its INDEXED
                                // text (a[0]), not the bare base name.
                                bsm->VpiFullName(cn);
                                bsm->VpiParent(hp);
                                setLoc(bsm, SourceRange(exprStart + co,
                                                        exprStart + co + bn.size()));
                                auto* cix = s.MakeConstant();
                                cix->VpiDecompile(ix);
                                cix->VpiSize(64);
                                cix->VpiValue("UINT:" + ix);
                                cix->VpiConstType(vpiUIntConst);
                                size_t dOff = co + lb2 + 1;
                                setLoc(cix, SourceRange(exprStart + dOff,
                                                        exprStart + dOff + ix.size()));
                                bsm->VpiIndex(cix);
                                elems->push_back(bsm);
                                continue;
                            }
                            auto* r2 = s.MakeRef_obj();
                            r2->VpiName(cn);
                            r2->VpiFullName(cn); // name-only (dump omits)
                            r2->VpiParent(hp);
                            // An LVALUE path anchors its BASE ref at the FIRST
                            // member name's start (the select anchor), keeping
                            // only its own length — Surelog, same as the
                            // MemberAccess builder above.
                            size_t co2 = co;
                            if (inLhs && ci == 0 && comps.size() > 2 &&
                                rs.getSelectionKind() !=
                                    RangeSelectionKind::Simple)
                                co2 = comps[1].second;
                            setLoc(r2, SourceRange(exprStart + co2,
                                                   exprStart + co2 + cn.size()));
                            elems->push_back(r2);
                        }
                        std::string lastName =
                            comps.empty() ? std::string{} : comps.back().first;
                        size_t lastOff = comps.empty() ? 0 : comps.back().second;
                        // The part_select span stops at the LAST bound's end
                        // (before the ']'), matching Surelog — not the whole
                        // expr end.
                        SourceRange selLoc(exprStart + lastOff,
                                           rs.right().sourceRange.end());
                        bool constSel = false;
                        {
                            ASTContext cctx(comp.getRoot(), LookupLocation::max);
                            constSel =
                                (rs.left().kind == ExpressionKind::IntegerLiteral ||
                                 cctx.tryEval(rs.left())) &&
                                (rs.right().kind == ExpressionKind::IntegerLiteral ||
                                 cctx.tryEval(rs.right()));
                        }
                        bool sup = suppressConstParent;
                        if (rs.getSelectionKind() == RangeSelectionKind::Simple) {
                            auto* ps2 = s.MakePart_select();
                            ps2->VpiName(lastName);
                            ps2->VpiFullName(selText);
                            ps2->VpiParent(hp);
                            setLoc(ps2, selLoc);
                            if (constSel)
                                ps2->VpiConstantSelect(true);
                            suppressConstParent = isLiteralExpr(rs.left());
                            if (auto* l = emitExpr(rs.left(), ps2, prefix, netMap))
                                ps2->Left_range((UHDM::expr*)l);
                            suppressConstParent = isLiteralExpr(rs.right());
                            if (auto* r3 = emitExpr(rs.right(), ps2, prefix, netMap))
                                ps2->Right_range((UHDM::expr*)r3);
                            elems->push_back(ps2);
                        }
                        else {
                            auto* ips2 = s.MakeIndexed_part_select();
                            ips2->VpiName(lastName);
                            // A procedural WRITE freezes the select's scoped
                            // (member-doubled) name and carries vpiDefName; a
                            // READ keeps the bare hier text (Surelog).
                            bool wrSel9 =
                                inLhs && stripImplicitConv(rs.left()).kind !=
                                             ExpressionKind::NamedValue;
                            if (wrSel9) {
                                ips2->VpiDefName(lastName);
                                ips2->VpiFullName(prefix + "." + selText + "." +
                                                  lastName);
                            }
                            else
                                ips2->VpiFullName(selText);
                            ips2->VpiParent(hp);
                            setLoc(ips2, selLoc);
                            ips2->VpiIndexedPartSelectType(
                                rs.getSelectionKind() == RangeSelectionKind::IndexedUp
                                    ? 1
                                    : 2);
                            // An indexed part-select's WIDTH is always constant;
                            // Surelog marks vpiConstantSelect on the width alone
                            // (a dynamic base still yields a constant select).
                            bool widthConst = false;
                            {
                                ASTContext wctx(comp.getRoot(), LookupLocation::max);
                                widthConst =
                                    rs.right().kind == ExpressionKind::IntegerLiteral ||
                                    (bool)wctx.tryEval(rs.right());
                            }
                            if (widthConst)
                                ips2->VpiConstantSelect(true);
                            suppressConstParent = isLiteralExpr(rs.left());
                            // A dynamic BASE ref is named through the select
                            // itself (work@top.a[0].source[base-:2].base) —
                            // Surelog scopes it by the hier-path element. A
                            // ref one level DEEPER (inside an arithmetic base
                            // op) also picks up the select's own name, since
                            // ComputeFullName only skips a select DIRECTLY
                            // above the ref (sub.src[i * 8+:8].src.i).
                            std::string bPfx9 = prefix + "." + selText;
                            if (stripImplicitConv(rs.left()).kind !=
                                ExpressionKind::NamedValue)
                                bPfx9 += "." + lastName;
                            if (auto* b2 = emitExpr(rs.left(), ips2, bPfx9,
                                                    netMap))
                                ips2->Base_expr((UHDM::expr*)b2);
                            suppressConstParent = isLiteralExpr(rs.right());
                            // § elabHierSelWidthFold (see the name render
                            // above): the substituted width is the parameter's
                            // VALUE, sized by that parameter's own type — a
                            // MODULE localparam (`vaddr_width_p`) never reached
                            // a fold arm at all and stayed a ref_obj, and a
                            // PACKAGE one folded at the wrong width before
                            // § pkgParamFoldWidthAlways.  Golden carries the
                            // constant UNPARENTED at the reference's span.
                            if (wf9.ok) {
                                auto* wc9 = s.MakeConstant();
                                wc9->VpiDecompile(wf9.text);
                                wc9->VpiSize(wf9.size);
                                wc9->VpiValue("UINT:" + wf9.text);
                                wc9->VpiConstType(vpiUIntConst);
                                setLoc(wc9, rs.right().sourceRange);
                                stampFoldedPkgParamTs(wc9, *wf9.sym, prefix);
                                ips2->Width_expr(wc9);
                            }
                            else if (auto* w2 = emitExpr(rs.right(), ips2, prefix,
                                                         netMap))
                                ips2->Width_expr((UHDM::expr*)w2);
                            elems->push_back(ips2);
                        }
                        suppressConstParent = sup;
                        hp->Path_elems(elems);
                        return hp;
                    }
                }
            }
            if (rs.value().kind != ExpressionKind::NamedValue) {
                noteUnsupported("range select base");
                return nullptr;
            }
            auto& nv = rs.value().as<NamedValueExpression>();
            if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                refCollector->insert(&nv.symbol);
            if (rs.getSelectionKind() != RangeSelectionKind::Simple) {
                auto* ips = s.MakeIndexed_part_select();
                ips->VpiName(nv.symbol.name);
                ips->VpiDefName(nv.symbol.name);
                ips->VpiFullName(joinRef(prefix, nv.symbol.name));
                ips->VpiParent(parent);
                // An indexed part-select write re-points whole refs only when
                // the base is a net (module reg); local vars keep their binding.
                if (auto nit = netMap.find(&nv.symbol);
                    nit != netMap.end() && nit->second->UhdmType() == UHDM::uhdmlogic_net)
                    noteSelectObj(&nv.symbol, ips);
                // Lvalue selects span the whole expression.
                if (inLhs)
                    setLoc(ips, expr.sourceRange);
                else
                    setLoc(ips, rangeSelectorSpan(rs));
                ips->VpiIndexedPartSelectType(
                    rs.getSelectionKind() == RangeSelectionKind::IndexedUp ? 1 : 2);
                // Constant width suffices (the base may be a variable).
                {
                    ASTContext cctx(comp.getRoot(), LookupLocation::max);
                    if (rs.right().kind == ExpressionKind::IntegerLiteral ||
                        cctx.tryEval(rs.right()))
                        ips->VpiConstantSelect(true);
                }
                // Refs nested in OPERATIONS scope by the base name; DIRECT
                // refs stay module-scoped. Only DIRECT literal bounds
                // suppress constant parents.
                auto savedSel = selectBasePrefix;
                std::string basePfx = prefix + "." + std::string(nv.symbol.name);
                auto boundPfx = [&](const Expression& e) -> const std::string& {
                    return stripImplicitConv(e).kind == ExpressionKind::NamedValue ? prefix
                                                                                   : basePfx;
                };
                bool savedSup = suppressConstParent;
                selectBasePrefix = basePfx;
                bool savedPsB9 = inPsBound;
                inPsBound = true;
                // ELAB gen-scope CONN bounds FOLD: base -> INT at the
                // first-token span, width -> UINT at the value width
                // (generate_test .a(data_in[i*W +: W])).
                if (genvarConnFold) {
                    ASTContext gcx9(comp.getRoot(), LookupLocation::max);
                    UHDM::expr* bf9 = nullptr;
                    UHDM::expr* wf9 = nullptr;
                    if (auto bv9 = gcx9.tryEval(rs.left());
                        bv9 && bv9.isInteger() &&
                        !bv9.integer().hasUnknown()) {
                        auto* c9 = s.MakeConstant();
                        std::string d9 = bv9.integer().toString(
                            LiteralBase::Decimal, false);
                        c9->VpiDecompile(d9);
                        c9->VpiSize(64);
                        c9->VpiValue("INT:" + d9);
                        c9->VpiConstType(vpiIntConst);
                        auto st9 = rs.left().sourceRange.start();
                        // Span = the FIRST source token of the base expr
                        // (the `i` of i*W), regardless of digit count.
                        std::string braw9(rawText(rs.left().sourceRange));
                        size_t tok9 = 0;
                        while (tok9 < braw9.size() &&
                               (isalnum((unsigned char)braw9[tok9]) ||
                                braw9[tok9] == '_' || braw9[tok9] == '$'))
                            tok9++;
                        if (!tok9)
                            tok9 = d9.size();
                        setLoc(c9, SourceRange(st9, st9 + tok9));
                        bf9 = c9;
                    }
                    if (auto wv9 = gcx9.tryEval(rs.right());
                        wv9 && wv9.isInteger() &&
                        !wv9.integer().hasUnknown()) {
                        auto* c9 = s.MakeConstant();
                        std::string d9 = wv9.integer().toString(
                            LiteralBase::Decimal, false);
                        c9->VpiDecompile(d9);
                        // A BARE (unsized) decimal width literal keeps
                        // Surelog's 64-bit unsized encoding; a width that
                        // comes from a typed expression (a param ref, a
                        // sized literal) is sized by its own type
                        // (YosysRiscv `[8*(2*i+1-1) +: 8]` vs generate_test
                        // `[i*W +: W]`).
                        bool bareW9 = false;
                        if (stripImplicitConv(rs.right()).kind ==
                            ExpressionKind::IntegerLiteral) {
                            std::string rw9(rawText(
                                stripImplicitConv(rs.right()).sourceRange));
                            bareW9 = rw9.find('\'') == std::string::npos;
                        }
                        c9->VpiSize(bareW9
                                        ? 64
                                        : (int32_t)rs.right()
                                              .type->getBitWidth());
                        c9->VpiValue("UINT:" + d9);
                        c9->VpiConstType(vpiUIntConst);
                        setLoc(c9, rs.right().sourceRange);
                        wf9 = c9;
                    }
                    if (bf9 && wf9) {
                        ips->Base_expr(bf9);
                        ips->Width_expr(wf9);
                        inPsBound = savedPsB9;
                        suppressConstParent = savedSup;
                        selectBasePrefix = savedSel;
                        return ips;
                    }
                }
                suppressConstParent = isLiteralExpr(rs.left());
                if (auto* b = emitExpr(rs.left(), ips, boundPfx(rs.left()), netMap))
                    ips->Base_expr((UHDM::expr*)b);
                suppressConstParent = isLiteralExpr(rs.right());
                if (auto* w = emitExpr(rs.right(), ips, boundPfx(rs.right()), netMap))
                    ips->Width_expr((UHDM::expr*)w);
                inPsBound = savedPsB9;
                suppressConstParent = savedSup;
                selectBasePrefix = savedSel;
                return ips;
            }
            auto* psel = s.MakePart_select();
            psel->VpiName(nv.symbol.name);
            psel->VpiDefName(nv.symbol.name);
            psel->VpiParent(parent);
            // Simple (constant) part-select writes do NOT re-point whole refs.
            // Fullname is frozen from the parent chain (matches Surelog's
            // lazily-computed values, incl. the doubled name under a
            // bit_select index). A PARAM-init part-select of a param
            // (WidthRatio[DepthW:0]) scopes explicitly by the module prefix.
            if (inParamInit)
                psel->VpiFullName(joinRef(prefix, nv.symbol.name));
            else if (prefix.find('[') != std::string::npos)
                // Under a gen-scope-array path the lazy parent-chain walk
                // drops the [idx] segment; cache the explicit path.
                psel->VpiFullName(joinRef(prefix, nv.symbol.name));
            else if (defGenProcessEmit)
                // Def-view gen-branch processes: the lazy walk stops at the
                // instance and drops the gen-block segments; cache the branch
                // path (jeras_tcb_gpio que[DLY-2:0]).
                psel->VpiFullName(joinRef(prefix, nv.symbol.name));
            else
                (void)psel->VpiFullName();
            setLoc(psel, expr.sourceRange);
            bool constSel = false;
            {
                ASTContext cctx(comp.getRoot(), LookupLocation::max);
                constSel = (rs.left().kind == ExpressionKind::IntegerLiteral ||
                            cctx.tryEval(rs.left())) &&
                           (rs.right().kind == ExpressionKind::IntegerLiteral ||
                            cctx.tryEval(rs.right()));
            }
            if (constSel)
                psel->VpiConstantSelect(true);
            // Part-select writes DO re-point later whole refs (subbytes:
            // next_data_reg = data_reg_128 binds the [31:24] part_select) —
            // but only TOP-LEVEL LHS selects count as writes; a select
            // nested in another select's INDEX is a read
            // (issue326_packed_mem's mem[write_ptr[..]] <= ...).
            {
                bool wr9 = parent &&
                           (parent->UhdmType() == UHDM::uhdmassignment ||
                            parent->UhdmType() == UHDM::uhdmcont_assign);
                // Only BLOCKING procedural writes repoint (subbytes `=`);
                // nonblocking `<=` keeps the net (unpacked_array_shift_ff).
                if (wr9 && parent->UhdmType() == UHDM::uhdmassignment &&
                    !((UHDM::assignment*)parent)->VpiBlocking())
                    wr9 = false;
                bool savedInLhs9 = inLhs;
                if (!wr9)
                    inLhs = false;
                noteSelectObj(&nv.symbol, psel);
                inLhs = savedInLhs9;
            }
            // Refs nested in bound OPERATIONS scope by the base name; in a
            // function/task body EVERY bound ref (incl. bare params) scopes by
            // the base name (Surelog's doubled part-select-bound fullname).
            std::string basePfx = prefix + "." + std::string(nv.symbol.name);
            auto boundPfx = [&](const Expression& e) -> const std::string& {
                // Function/task bodies AND param inits scope EVERY bound ref
                // by the base name (Surelog's doubled part-select fullname);
                // elab gen-CA LHS folds scope by the base too.
                if (currentSubSym || inParamInit || genCaLhsParamFold)
                    return basePfx;
                return stripImplicitConv(e).kind == ExpressionKind::NamedValue ? prefix
                                                                               : basePfx;
            };
            // Param-init bound constants are unparented.
            bool savedSup2 = suppressConstParent;
            if (inParamInit)
                suppressConstParent = true;
            bool savedF2 = forceConstParent;
            if (inParamInit)
                forceConstParent = false;
            inPsBound = true;
            bool savedPsR = inPsRangeBound;
            inPsRangeBound = true;
            if (auto* l = emitExpr(rs.left(), psel, boundPfx(rs.left()), netMap))
                psel->Left_range((UHDM::expr*)l);
            if (auto* r = emitExpr(rs.right(), psel, boundPfx(rs.right()), netMap))
                psel->Right_range((UHDM::expr*)r);
            inPsRangeBound = savedPsR;
            inPsBound = false;
            suppressConstParent = savedSup2;
            forceConstParent = savedF2;
            return psel;
        }
        case ExpressionKind::MemberAccess: {
            // NOTE (HierPathEval, design-root-class triage): when the BASE is a
            // packed-struct CONSTANT, golden's VALUE cannot be reproduced here.
            // UHDM's ExprEval::hierarchicalSelector (ExprEval.cpp, the
            // `constant` + `struct_typespec` arm) accumulates the member offset
            // `from` in DECLARATION order starting at bit 0 — the FIRST member
            // at the LSB — which is the reverse of SV packed-struct layout. For
            // `struct packed {logic a; pad_type_e dio_pad_type;} TargetCfg = 2`,
            // golden reads `TargetCfg.dio_pad_type` as bit 1 = 1 where slang
            // (correctly) gives bit 0 = 0. That wrong value then flips a
            // generate condition INSIDE slang's own elaboration (the true arm
            // instantiates a module we never see), so the divergence is not
            // reachable from the exporter: it would take slang adopting
            // Surelog's layout. HierPathEval is blocked on that, not on naming.
            //
            // § thisPathSelectErased4 — SITE 3 of 3. A select BELOW a further
            // member (`this.st[k].fld`) reaches emitExpr as a MemberAccess, and
            // golden erases that select too — the hier_path is `this.st.fld`
            // with a PLAIN ref_obj where the bit_select would have been (grid
            // cells d1/d7/d8). This must run before the emitMixedHierPath arm
            // just below, which is what mints that bit_select today.
            if (auto* thp = emitThisPathSelectErased(expr, parent, prefix))
                return thp;
            // p.hi -> hier_path with unbound ref elements: base ref has
            // name only; member refs carry module-scoped fullnames.
            std::vector<const Expression*> chain;
            const Expression* base = &expr;
            while (base->kind == ExpressionKind::MemberAccess) {
                chain.push_back(base);
                base = &base->as<MemberAccessExpression>().value();
            }
            // A member reached through a PACKAGE-QUALIFIED variable collapses
            // to the base reference alone (isPkgQualifiedVarRef).
            if (isPkgQualifiedVarRef(stripImplicitConv(*base)))
                return emitExpr(stripImplicitConv(*base), parent, prefix,
                                netMap);
            // A member whose base chain threads through element selects
            // (b.a[0].x, a[0][0].min_v) -> hier_path with bit_select elements
            // for each selected member.
            if (base->kind == ExpressionKind::ElementSelect) {
                if (auto* hp = emitMixedHierPath(expr, parent, prefix, netMap))
                    return hp;
            }
            // Struct-member access on an interface-port member (s.req.adr):
            // the base chain bottoms out at an ArbitrarySymbol — a dotted
            // hier_path over the whole expression.
            if (base->kind == ExpressionKind::ArbitrarySymbol ||
                base->kind == ExpressionKind::HierarchicalValue) {
                std::string dotted = rawText(expr.sourceRange);
                if (dotted.find('.') != std::string::npos)
                    return buildDottedHierPath(expr, dotted, parent, prefix);
            }
            // Member access threading an ELEMENT SELECT over an interface
            // array (s[0].req.wdt): dotted hier_path (a[i] components become
            // bit_selects in the builder... approximate with refs).
            if (base->kind == ExpressionKind::ElementSelect) {
                auto& esb = base->as<ElementSelectExpression>();
                auto& ebv = stripImplicitConv(esb.value());
                if (ebv.kind == ExpressionKind::ArbitrarySymbol ||
                    ebv.kind == ExpressionKind::HierarchicalValue) {
                    std::string dotted = rawText(expr.sourceRange);
                    if (dotted.find('.') != std::string::npos)
                        return buildDottedHierPath(expr, dotted, parent, prefix);
                }
            }
            if (base->kind != ExpressionKind::NamedValue) {
                noteUnsupported("member access base");
                return nullptr;
            }
            auto& nv = base->as<NamedValueExpression>();
            if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                refCollector->insert(&nv.symbol);
            // A PARAM-INIT read of a STRUCT-PARAM member (localparam N = Info.x,
            // and the same path re-emitted at an instance param connection or a
            // $clog2 arg): Surelog anchors the base ref at the MEMBER token span
            // and leaves the leaf ref BARE (no scoped fullname) — the same
            // span/name convention it uses for an LVALUE path.
            bool paramInitStructMember =
                inParamInit && !chain.empty() &&
                nv.symbol.kind == SymbolKind::Parameter &&
                nv.symbol.getType().getCanonicalType().kind ==
                    SymbolKind::PackedStructType;
            // § vifClockingPathComponent5 — SITE 1 of 3.  The components slang
            // collapsed out of a virtual-interface reference, recovered and
            // spliced in between the base and the leaf.  `chain.size() == 1` is
            // part of the gate — BUT THE RATIONALE THIS COMMENT ORIGINALLY GAVE
            // FOR IT WAS FALSE, and the verifier's cell refuted it at
            // integration (its F1): golden's defect is specific to the WRITTEN
            // `this` KEYWORD (`this.vif.cb.sig` -> golden emits `this.vif.cb`,
            // dropping the leaf; arm a4 cell f1), NOT to chain length.  For a
            // vif held by ANOTHER OBJECT (`ho.h.cb.ds`, verifier arm
            // v3_handle.sv) golden is perfectly well-formed — 4 elements — and
            // this gate OVER-DECLINES it.  Priced: 635 `X.Y.<cb>.<id>` source
            // sites across the corpora, ZERO in any test with a CMP row today
            // (all SLANG_REJECT / no-row / never-compiled library), which is
            // why no gate moves — but it becomes the live population the
            // moment Opentitan/Ibex/SimpleInterface stop being SLANG_REJECT.
            // Ranked R1b in the README, above R1: widening this gate needs the
            // longer-chain recovery MEASURED, not assumed, with the
            // this-keyword cell as its negative control.
            std::vector<std::pair<std::string, SourceRange>> vifComps5;
            if (chain.size() == 1)
                vifCollapsedComponents5(chain.front()->as<MemberAccessExpression>(),
                                        vifComps5);
            auto* hp = s.MakeHier_path();
            std::string dotted(nv.symbol.name);
            for (auto& vc5 : vifComps5)
                dotted += "." + vc5.first;
            for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2)
                dotted += "." + std::string((*it2)->as<MemberAccessExpression>().member.name);
            hp->VpiName(dotted);
            hp->VpiFullName(dotted);
            hp->VpiParent(parent);
            // this.member: the hier_path spans the `this` token only, and the
            // member ref is loc-less with a scope-prefixed fullname.
            bool thisPath = nv.symbol.name == "this";
            if (thisPath)
                setLoc(hp, base->sourceRange);
            else
                setLoc(hp, expr.sourceRange);
            // A PKG-QUALIFIED param base (pkg::P.member): the hier_path is
            // named by the MODULE prefix, and the base ref carries the
            // qualified name, spans the pkg-qualifier token, and binds the
            // pkg's def parameter object (Surelog).
            bool pkgQualBase9 = false;
            std::string pkgQualNm9;
            if (nv.symbol.kind == SymbolKind::Parameter &&
                rawText(base->sourceRange).find("::") != std::string::npos)
                if (auto psc9 = nv.symbol.getParentScope();
                    psc9 && psc9->asSymbol().kind == SymbolKind::Package) {
                    pkgQualBase9 = true;
                    pkgQualNm9 = std::string(psc9->asSymbol().name);
                    hp->VpiName("");
                    hp->VpiFullName(prefix);
                }
            auto* elems = s.MakeAnyVec();
            {
                auto* r = s.MakeRef_obj();
                if (pkgQualBase9)
                    r->VpiName(pkgQualNm9 + "::" + std::string(nv.symbol.name));
                else
                    r->VpiName(nv.symbol.name);
                // Freeze the lazily-computed fullname before parenting
                // (Surelog's refs cache name-only fullnames).
                (void)r->VpiFullName();
                r->VpiParent(hp);
                if (pkgQualBase9) {
                    setLoc(r, SourceRange(base->sourceRange.start(),
                                          base->sourceRange.start() +
                                              (pkgQualNm9.size() + 2)));
                    if (auto poIt9 = pkgParamObj.find(&nv.symbol);
                        poIt9 != pkgParamObj.end())
                        r->Actual_group(poIt9->second);
                    elems->push_back(r);
                }
                else {
                // Lvalue paths (and param-init struct-member reads) anchor the
                // base ref at the FIRST member's token span.
                if ((inLhs || paramInitStructMember) && !chain.empty()) {
                    // § vifClockingPathComponent5 — SITE 1 of 3.  With a
                    // recovered component spliced in, the FIRST member is that
                    // component, not the leaf: golden puts BOTH the base ref and
                    // the `cb` ref on the `cb` token (a1 c1, `vif.cb.ds <= 1`).
                    if (!vifComps5.empty()) {
                        setLoc(r, vifComps5.front().second);
                    }
                    else {
                    auto& fm = *chain.back();
                    auto end = fm.sourceRange.end();
                    setLoc(r, SourceRange(
                                  end - fm.as<MemberAccessExpression>().member.name.size(),
                                  end));
                    }
                }
                else {
                    setLoc(r, base->sourceRange);
                }
                elems->push_back(r);
                }
            }
            // § vifClockingPathComponent5 — SITE 1 of 3.  The recovered
            // components are plain ref_objs at their own name token with a
            // NAME-ONLY fullname, in BOTH positions: golden's intermediate `cb`
            // is bare (`ref_obj (cb)`) whether the path is an lvalue (a1 c1) or
            // an rvalue (a1 c3), and only the LEAF ever takes a scoped fullname.
            for (auto& vc5 : vifComps5) {
                auto* r = s.MakeRef_obj();
                r->VpiName(vc5.first);
                (void)r->VpiFullName();
                r->VpiParent(hp);
                setLoc(r, vc5.second);
                elems->push_back(r);
            }
            for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2) {
                auto& ma = (*it2)->as<MemberAccessExpression>();
                auto* r = s.MakeRef_obj();
                r->VpiName(ma.member.name);
                (void)r->VpiFullName();
                // Only the last member of an rvalue path gets a fullname; a
                // param-init struct-member read leaves the leaf BARE (lvalue).
                if (!inLhs && !paramInitStructMember && *it2 == chain.front())
                    // A PACKAGE-scope prefix keeps :: down to the leaf
                    // (riscv_isa_i_pkg::enc32::opc — Surelog).
                    r->VpiFullName(joinRef(prefix, ma.member.name));
                r->VpiParent(hp);
                // Pkg-qualified param member refs bind the typespec_member
                // of the param's def struct/union ts (Surelog).
                if (pkgQualBase9) {
                    if (auto poQ9 = pkgParamObj.find(&nv.symbol);
                        poQ9 != pkgParamObj.end() &&
                        poQ9->second->Typespec() &&
                        poQ9->second->Typespec()->Actual_typespec()) {
                        auto* atsQ9 =
                            poQ9->second->Typespec()->Actual_typespec();
                        UHDM::VectorOftypespec_member* mems9 = nullptr;
                        if (atsQ9->UhdmType() == UHDM::uhdmstruct_typespec)
                            mems9 =
                                ((UHDM::struct_typespec*)atsQ9)->Members();
                        else if (atsQ9->UhdmType() ==
                                 UHDM::uhdmunion_typespec)
                            mems9 = ((UHDM::union_typespec*)atsQ9)->Members();
                        if (mems9)
                            for (auto* tm9 : *mems9)
                                if (tm9->VpiName() == ma.member.name) {
                                    r->Actual_group(tm9);
                                    break;
                                }
                    }
                }
                if (thisPath && *it2 == chain.front()) {
                    r->VpiFullName(joinRef(prefix, ma.member.name));
                }
                else {
                    auto end = (*it2)->sourceRange.end();
                    setLoc(r, SourceRange(end - ma.member.name.size(), end));
                }
                elems->push_back(r);
            }
            hp->Path_elems(elems);
            return hp;
        }
        case ExpressionKind::SimpleAssignmentPattern: {
            auto& ap = expr.as<SimpleAssignmentPatternExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiAssignmentPatternOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            bool wasInPattern = inAssignPattern;
            inAssignPattern = true;
            for (auto el : ap.elements()) {
                if (auto* e = emitExpr(*el, op, prefix, netMap)) {
                    // Re-emitted OUTERMOST patterns size their FIRST operand;
                    // NESTED patterns ('{'{0,..},..}) keep every element 64.
                    if (reemitting) {
                        if (operands->empty() && !wasInPattern)
                            ((UHDM::expr*)e)->VpiSize((int32_t)el->type->getBitWidth());
                    }
                    // Outermost bare-decimal elements: a direct var initializer
                    // (suppressConstParent) resizes each to the element type; a
                    // func-arg / param-default pattern keeps 64 and leaves the
                    // element UNparented. Nested-pattern elements always keep 64.
                    else if (!wasInPattern && e->UhdmType() == UHDM::uhdmconstant) {
                        if (suppressConstParent) {
                            if (((UHDM::expr*)e)->VpiSize() == 64)
                                ((UHDM::expr*)e)->VpiSize((int32_t)el->type->getBitWidth());
                        }
                        else {
                            ((UHDM::expr*)e)->VpiParent(nullptr);
                        }
                    }
                    operands->push_back(e);
                }
            }
            inAssignPattern = wasInPattern;
            // A re-emitted (elab) PACKED-VECTOR (or UNPACKED-ARRAY) param
            // pattern stores its operands reversed from source order and flags
            // vpiReordered (Surelog); the def view keeps source order.
            // Each nesting level reorders per its OWN range direction: a
            // DESCENDING unpacked range ([1:0]) reverses LSB-first + flags
            // vpiReordered; an ascending [N] (== [0:N-1]) keeps source order.
            bool isUnpackedArr =
                expr.type && expr.type->getCanonicalType().kind ==
                                 SymbolKind::FixedSizeUnpackedArrayType;
            bool descUnpacked =
                isUnpackedArr && expr.type->getCanonicalType()
                                         .as<FixedSizeUnpackedArrayType>()
                                         .range.left >
                                     expr.type->getCanonicalType()
                                         .as<FixedSizeUnpackedArrayType>()
                                         .range.right;
            // A SINGLE-operand packed pattern whose operand is a nested op
            // still runs the level logic (the stamp below reaches its mid —
            // param_packed_array_subst).
            bool nestedOpsPre9 = false;
            for (auto* o9 : *operands)
                if (o9->UhdmType() == UHDM::uhdmoperation) {
                    nestedOpsPre9 = true;
                    break;
                }
            if (inParamInit && !paramInitDef && expr.type &&
                ((expr.type->isIntegral() &&
                  !expr.type->getCanonicalType().isScalar()) ||
                 isUnpackedArr) &&
                (operands->size() > 1 ||
                 (nestedOpsPre9 && !isUnpackedArr))) {
                // § pkgPatternNoReorderConst — the reorder above is a MODULE
                // rule.  Inside a PACKAGE only a ref_obj-headed operand list
                // ever reorders; a CONSTANT- or PATTERN-headed one keeps
                // SOURCE ORDER in BOTH listings.  That is the same golden
                // § applyPkgParamPatternReorder already cites (`v_t [3:0]
                // arr_v = {8'd1,...}` and `cfg_t [3:0] arr_lit =
                // {'{default:1}}` stay in source order while `e_t [1:0]
                // arr_e = {E0,E1}` reverses) — the ref_obj case is handled
                // there, from the typespec's ranges, so this site owns only
                // the module shapes.  Re-measured on
                // tools/probe/r10earl_repro/vn.sv: golden carries ZERO
                // vpiReordered marks in the whole file, where we reversed
                // both `logic [3:0][3:0] PAT = '{4'h1,4'h2,4'h3,4'h4}` and
                // `logic [7:0] FLT = '{1'b1,1'b0,...}` in the TopPackages
                // view.  Corpus: prim_cipher_pkg's PRINCE_SHIFT_ROWS64 family
                // (aes / aes_prng AllModules + prim_cipher_pkg TopPackages).
                // NOTE the recursive module law § multiDimPatternReorderRec
                // (ParamEmit ~788, witness BlackParrotComplex `bit [1:0][4:0]
                // [4:0] StrictXY`) is a MODULE path and is untouched.
                bool pkgConstHeaded9 =
                    paramInitPkg && !operands->empty() &&
                    (*operands)[0]->UhdmType() != UHDM::uhdmref_obj;
                if ((!isUnpackedArr || descUnpacked) &&
                    operands->size() > 1 && !pkgConstHeaded9) {
                    std::reverse(operands->begin(), operands->end());
                    op->VpiReordered(1);
                }
                if (!isUnpackedArr) {
                    // NESTED packed patterns: the op carries NO size at any
                    // level; instead the OUTERMOST op stamps vpiSize =
                    // total-bits / innermost-vector-bits on its FIRST and
                    // LAST direct operand ops only (ParameterPackedArray,
                    // 3 Surelog probes). Flat (constant-operand, top-level)
                    // patterns keep VpiSize(1).
                    bool nestedOps9 = false;
                    for (auto* o9 : *operands)
                        if (o9->UhdmType() == UHDM::uhdmoperation) {
                            nestedOps9 = true;
                            break;
                        }
                    // § pkgVecPatternNoSize — third face of the same
                    // package/module split as § pkgPatternNoReorderConst and
                    // § pkgVecPatternNoTs: a PACKAGE's surviving elab pattern
                    // op is a verbatim twin of its def-listing op — no
                    // reorder, no typespec ref and NO vpiSize — so the flat
                    // VpiSize(1) stamp (measured on a MODULE param list,
                    // ParameterPackedArray) must not run there.  vn.sv PAT /
                    // FLT / DFL: golden prints no size field on any of the
                    // six package-listing ops.
                    if (!nestedOps9 && !wasInPattern && !paramInitPkg)
                        op->VpiSize(1);
                    else if (nestedOps9 && !wasInPattern) {
                        auto& pct9 = expr.type->getCanonicalType();
                        int32_t tot9 = 0;
                        if (pct9.kind == SymbolKind::PackedArrayType) {
                            const Type* lv9 = &pct9;
                            while (lv9->getCanonicalType()
                                       .as<PackedArrayType>()
                                       .elementType.getCanonicalType()
                                       .kind == SymbolKind::PackedArrayType)
                                lv9 = &lv9->getCanonicalType()
                                           .as<PackedArrayType>()
                                           .elementType;
                            int32_t iw9 = (int32_t)lv9->getCanonicalType()
                                              .getBitWidth();
                            if (iw9 > 0)
                                tot9 = (int32_t)pct9.getBitWidth() / iw9;
                        }
                        if (tot9 >= 1) {
                            if (operands->front()->UhdmType() ==
                                UHDM::uhdmoperation)
                                ((UHDM::expr*)operands->front())
                                    ->VpiSize(tot9);
                            if (operands->back()->UhdmType() ==
                                UHDM::uhdmoperation)
                                ((UHDM::expr*)operands->back())
                                    ->VpiSize(tot9);
                        }
                    }
                }
                // Unpacked-array leaf elements size to the element width
                // (int -> 32) and parent to the op (the def view left them 64
                // and unparented); packed vectors keep op VpiSize(1).
                if (isUnpackedArr) {
                    auto& elemT = expr.type->getCanonicalType()
                                      .as<FixedSizeUnpackedArrayType>()
                                      .elementType;
                    bool elemIsArray = elemT.getCanonicalType().kind ==
                                       SymbolKind::FixedSizeUnpackedArrayType;
                    const Type* leaf = &elemT.getCanonicalType();
                    while (leaf->getCanonicalType().kind ==
                           SymbolKind::FixedSizeUnpackedArrayType)
                        leaf = &leaf->getCanonicalType()
                                    .as<FixedSizeUnpackedArrayType>()
                                    .elementType;
                    // A NESTED op whose elements are themselves sub-arrays gets
                    // vpiSize = leaf width (the outermost carries the
                    // array_typespec instead; the innermost, whose elements are
                    // leaf constants, gets nothing).
                    if (wasInPattern && elemIsArray && leaf->isIntegral())
                        op->VpiSize((int32_t)leaf->getBitWidth());
                    for (auto* o : *operands) {
                        // Only the OUTERMOST pattern's direct leaf elements
                        // resize (int -> 32); nested-pattern leaves keep 64.
                        if (!wasInPattern && elemT.isIntegral() &&
                            o->UhdmType() == UHDM::uhdmconstant &&
                            ((UHDM::expr*)o)->VpiSize() == 64)
                            ((UHDM::expr*)o)->VpiSize((int32_t)elemT.getBitWidth());
                        o->VpiParent(op);
                    }
                }
            }
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::ReplicatedAssignmentPattern: {
            // '{N{a, b}} -> vpiMultiAssignmentPatternOp(count const, concat of
            // the replicated elements).
            auto& rap = expr.as<ReplicatedAssignmentPatternExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiMultiAssignmentPatternOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            // In a PLAIN def cont-assign context the operands stay unparented
            // at 64 bits; init/re-emit contexts parent them (count at 32).
            bool plainCtx =
                !reemitting && !suppressConstParent && !forceConstParent;
            bool sup0 = suppressConstParent;
            if (plainCtx)
                suppressConstParent = true;
            auto* operands = s.MakeAnyVec();
            if (auto* c = emitExpr(rap.count(), op, prefix, netMap)) {
                // The replication count is a 32-bit constant in INIT
                // contexts only (plain/re-emitted CAs keep 64).
                if (sup0 && c->UhdmType() == UHDM::uhdmconstant &&
                    ((UHDM::expr*)c)->VpiSize() == 64)
                    ((UHDM::expr*)c)->VpiSize(32);
                operands->push_back(c);
            }
            auto* inner = s.MakeOperation();
            inner->VpiOpType(vpiConcatOp);
            inner->VpiParent(op);
            if (!rap.elements().empty())
                setLoc(inner, SourceRange(rap.elements().front()->sourceRange.start(),
                                          rap.elements().front()->sourceRange.end()));
            auto* innerOps = s.MakeAnyVec();
            for (auto el : rap.elements())
                if (auto* e = emitExpr(*el, inner, prefix, netMap))
                    innerOps->push_back(e);
            inner->Operands(innerOps);
            operands->push_back(inner);
            op->Operands(operands);
            if (plainCtx)
                suppressConstParent = sup0;
            return op;
        }
        case ExpressionKind::StructuredAssignmentPattern: {
            auto& ap = expr.as<StructuredAssignmentPatternExpression>();
            // ---- LAW castDefaultPatternConcat (r10sing4) ----
            // Surelog has NO assignment-pattern node for a CAST'd pattern.
            // `T'{...}` is compiled as operation(vpiCastOp) — carrying a ts ref
            // to T — over ONE operation(vpiConcatOp) whose operands are the
            // pattern items in SOURCE order, each key spelled as a bare ref_obj
            // in front of its value; the `default` keyword becomes a ref_obj
            // named "default" with vpiStructMember set (CompileExpression.cpp
            // :3605, paArray_member_label).  Only the UNCAST `'{...}` takes the
            // vpiAssignmentPatternOp + tagged_pattern shape.  Measured on a
            // 13-row golden matrix (int / byte / v8_t / struct casts x
            // default / named-member / positional keys, plus the uncast twins,
            // which stay op75 byte-identical to what we already emit).
            //
            // Then RESOLVED views run Surelog's CompileHelper::
            // defaultPatternAssignment (CompileHelper.cpp:3301, vpiCastOp arm),
            // read verbatim: when the cast target is an int_typespec and the
            // concat's FIRST operand is named "default", the whole tree becomes
            // ONE 32-bit constant — signed: get_value(value)==1 ? INT:-1 :
            // INT:0; unsigned: UINT:UINT_MAX / UINT:0.  Every OTHER cast target
            // (byte / integer / shortint / logic / struct) has no arm and stays
            // an unfolded cast tree in EVERY view — measured: int'{default:1}
            // -> -1, int'{default:0} -> 0, int'{default:2|3|4|1'bx|-1} -> 0
            // (the equality is against 1, not against LSB or non-zero),
            // int'{default:32'd1|1'b1|'1} -> -1, and byte/integer/shortint/
            // time/logic/struct casts unfolded throughout.
            //
            // Scope: DEFAULT-only keys over a PREDEFINED-INTEGER cast target.
            // Named/positional keys and typedef/struct cast targets keep the
            // old op75 shape (they need the full cast-typespec machinery; both
            // were already unequal, so leaving them costs nothing).
            {
                const syntax::DataTypeSyntax* castSyn9 = nullptr;
                if (expr.syntax &&
                    expr.syntax->kind ==
                        syntax::SyntaxKind::AssignmentPatternExpression)
                    castSyn9 = expr.syntax
                                   ->as<syntax::AssignmentPatternExpressionSyntax>()
                                   .type;
                const syntax::AssignmentPatternSyntax* patSyn9 = nullptr;
                if (castSyn9)
                    patSyn9 = &*expr.syntax
                                   ->as<syntax::AssignmentPatternExpressionSyntax>()
                                   .pattern;
                if (castSyn9 && patSyn9 && ap.defaultSetter &&
                    ap.memberSetters.empty() && ap.typeSetters.empty() &&
                    ap.indexSetters.empty() && expr.type &&
                    expr.type->getCanonicalType().kind ==
                        SymbolKind::PredefinedIntegerType) {
                    auto& pit9 = expr.type->getCanonicalType()
                                     .as<PredefinedIntegerType>();
                    UHDM::typespec* cts9 = nullptr;
                    switch (pit9.integerKind) {
                        case PredefinedIntegerType::Integer:
                            cts9 = s.MakeInteger_typespec();
                            break;
                        case PredefinedIntegerType::Int:
                            cts9 = s.MakeInt_typespec();
                            break;
                        case PredefinedIntegerType::ShortInt:
                            cts9 = s.MakeShort_int_typespec();
                            break;
                        case PredefinedIntegerType::LongInt:
                            cts9 = s.MakeLong_int_typespec();
                            break;
                        case PredefinedIntegerType::Byte:
                            cts9 = s.MakeByte_typespec();
                            break;
                        case PredefinedIntegerType::Time:
                            cts9 = s.MakeTime_typespec();
                            break;
                        default:
                            break;
                    }
                    if (cts9) {
                        setLoc(cts9, castSyn9->sourceRange());
                        // Every signed integer-atom typespec carries vpiSigned
                        // (Surelog stamps it from the type, cast site included).
                        if (expr.type->isSigned()) {
                            switch (cts9->UhdmType()) {
                                case UHDM::uhdmint_typespec:
                                    ((UHDM::int_typespec*)cts9)->VpiSigned(true);
                                    break;
                                case UHDM::uhdminteger_typespec:
                                    ((UHDM::integer_typespec*)cts9)
                                        ->VpiSigned(true);
                                    break;
                                case UHDM::uhdmshort_int_typespec:
                                    ((UHDM::short_int_typespec*)cts9)
                                        ->VpiSigned(true);
                                    break;
                                case UHDM::uhdmlong_int_typespec:
                                    ((UHDM::long_int_typespec*)cts9)
                                        ->VpiSigned(true);
                                    break;
                                case UHDM::uhdmbyte_typespec:
                                    ((UHDM::byte_typespec*)cts9)
                                        ->VpiSigned(true);
                                    break;
                                default:
                                    break;
                            }
                        }
                        // A PACKAGE-scope cast typespec carries vpiInstance =
                        // the package (Instance() IS compared by uhdm-cmp).
                        // The MODULE-view copy of an imported package param's
                        // init does NOT: golden's module-side clone of the
                        // cast typespec is instance-less, unlike the size-cast
                        // arm's (measured on DefaultPatternAssign's
                        // work@lower / work@top.upper_u.lower_u copies).
                        if (pkgScopeInst)
                            cts9->Instance(pkgScopeInst);
                        auto* cop9 = s.MakeOperation();
                        cop9->VpiOpType(vpiCastOp);
                        cop9->VpiParent(parent);
                        setLoc(cop9, expr.sourceRange);
                        std::string cpfx9 = prefix;
                        if (cpfx9.size() >= 2 &&
                            cpfx9.compare(cpfx9.size() - 2, 2, "::") == 0)
                            cpfx9.resize(cpfx9.size() - 2);
                        auto* crt9 = s.MakeRef_typespec();
                        crt9->VpiFullName(cpfx9);
                        crt9->VpiParent(cop9);
                        crt9->Actual_typespec(cts9);
                        cop9->Typespec(crt9);
                        // The concat spans `{ .. }` — the pattern syntax minus
                        // its leading apostrophe (Surelog re-lexes the brace).
                        auto* ccat9 = s.MakeOperation();
                        ccat9->VpiOpType(vpiConcatOp);
                        ccat9->VpiParent(cop9);
                        {
                            auto pr9 = patSyn9->sourceRange();
                            setLoc(ccat9,
                                   SourceRange(pr9.start() + 1, pr9.end()));
                        }
                        auto* cro9 = s.MakeRef_obj();
                        cro9->VpiName("default");
                        cro9->VpiFullName(joinRef(prefix, "default"));
                        cro9->VpiStructMember(true);
                        cro9->VpiParent(ccat9);
                        if (patSyn9->kind ==
                            syntax::SyntaxKind::StructuredAssignmentPattern)
                            for (auto item9 :
                                 patSyn9->as<syntax::StructuredAssignmentPatternSyntax>()
                                     .items) {
                                if (item9->kind !=
                                    syntax::SyntaxKind::AssignmentPatternItem)
                                    continue;
                                auto& ai9 =
                                    item9->as<syntax::AssignmentPatternItemSyntax>();
                                if (rawText(ai9.key->sourceRange()) ==
                                    "default") {
                                    setLoc(cro9, ai9.key->sourceRange());
                                    break;
                                }
                            }
                        auto* cops9 = s.MakeAnyVec();
                        cops9->push_back(cro9);
                        bool sup9 = suppressConstParent, fcp9 = forceConstParent;
                        suppressConstParent = true;
                        forceConstParent = false;
                        UHDM::any* cval9 =
                            emitExpr(*ap.defaultSetter, ccat9, prefix, netMap);
                        suppressConstParent = sup9;
                        forceConstParent = fcp9;
                        if (cval9) {
                            // Surelog's concat operand constant is UNparented
                            // (compileConst never back-links) — every other
                            // operand keeps its parent.
                            if (cval9->UhdmType() == UHDM::uhdmconstant)
                                ((UHDM::any*)cval9)->VpiParent(nullptr);
                            else
                                ((UHDM::any*)cval9)->VpiParent(ccat9);
                            cops9->push_back(cval9);
                        }
                        ccat9->Operands(cops9);
                        auto* copsOuter9 = s.MakeAnyVec();
                        copsOuter9->push_back(ccat9);
                        cop9->Operands(copsOuter9);
                        // defaultPatternAssignment's vpiCastOp arm: int only,
                        // and only in a RESOLVED view.  Surelog reduces a
                        // parameter init exactly where it elaborates it, so the
                        // four param views split in PAIRS (measured on the
                        // DefaultPatternAssign source, all four listings):
                        //   package DEF   -> unfolded      module DEF   -> unf.
                        //   package ELAB  -> FOLDED        module ELAB  -> FOLD
                        //   import-copy DEF  -> FOLDED  (the copy is
                        //                               materialized already
                        //                               elaborated)
                        //   import-copy ELAB -> unfolded (a clone_tree of the
                        //                               package's own DEF row)
                        // i.e. resolved <=> paramInitDef == importedParamClone.
                        bool resolved9 =
                            inParamInit && (paramInitDef == importedParamClone);
                        if (resolved9 &&
                            cts9->UhdmType() == UHDM::uhdmint_typespec && cval9 &&
                            cval9->UhdmType() == UHDM::uhdmconstant) {
                            std::string sv9(
                                ((UHDM::constant*)cval9)->VpiValue());
                            auto cpos9 = sv9.find(':');
                            bool isOne9 = false;
                            if (cpos9 != std::string::npos) {
                                errno = 0;
                                char* end9 = nullptr;
                                unsigned long long uv9 = std::strtoull(
                                    sv9.c_str() + cpos9 + 1, &end9, 10);
                                isOne9 = (errno == 0 && end9 &&
                                          *end9 == '\0' && uv9 == 1ULL);
                            }
                            auto* fc9 = s.MakeConstant();
                            fc9->VpiParent(parent);
                            fc9->VpiSize(32);
                            if (expr.type->isSigned()) {
                                fc9->VpiValue(isOne9 ? "INT:-1" : "INT:0");
                                fc9->VpiDecompile(isOne9 ? "-1" : "0");
                                fc9->VpiConstType(vpiIntConst);
                            }
                            else {
                                fc9->VpiValue(isOne9 ? "UINT:4294967295"
                                                     : "UINT:0");
                                fc9->VpiDecompile(isOne9 ? "4294967295" : "0");
                                fc9->VpiConstType(vpiUIntConst);
                            }
                            castDefaultFoldC = fc9;
                            return fc9;
                        }
                        return cop9;
                    }
                }
            }
            // The flatten target is consumed by THIS pattern only — nested
            // emits get it back explicitly, per member, below.
            const UHDM::typespec* patFlatTs = this->patFlatTs;
            const bool patFlatAdjust = this->patFlatAdjust;
            this->patFlatTs = nullptr;
            this->patFlatAdjust = false;
            // R10E27_PATDBG=1 prints one line per STRUCTURED assignment
            // pattern reaching this case, with the four inputs that pick the
            // branch (view, flatten target, adjust flag, setter counts).  The
            // pass-27 nested-default law was found here: the corpus row and
            // qm27's rows show flat=1 adj=0 for a NESTED pattern where the
            // top-level one reads flat=1 adj=1, so the member-width sizing
            // pass was simply never propagated into the recursion.
            static const bool patDbg27 = getenv("R10E27_PATDBG");
            if (patDbg27) {
                // ...and the two ORDERS the two paths use: slang's
                // `memberSetters` (what the generic loop below emits) beside
                // the struct's own field scope (what the flatten indexes).
                // Printing both is what settled the pass-27 order question:
                // they are NOT always the same list in a different order.
                std::string ms27, fl27;
                for (auto& m27 : ap.memberSetters)
                    ms27 += std::string(m27.member->name) + ",";
                if (expr.type && expr.type->getCanonicalType().isStruct())
                    for (auto& f27 :
                         expr.type->getCanonicalType().as<Scope>().members())
                        if (f27.kind == SymbolKind::Field)
                            fl27 += std::string(f27.name) + ",";
                fprintf(stderr, "PATORD %u:%u setters=[%s] fields=[%s]\n",
                        (unsigned)sm->getLineNumber(expr.sourceRange.start()),
                        (unsigned)sm->getColumnNumber(expr.sourceRange.start()),
                        ms27.c_str(), fl27.c_str());
            }
            if (patDbg27)
                fprintf(stderr,
                        "PATDBG %u:%u reemit=%d flat=%d adj=%d mem=%d dflt=%d "
                        "type=%d\n",
                        (unsigned)sm->getLineNumber(expr.sourceRange.start()),
                        (unsigned)sm->getColumnNumber(expr.sourceRange.start()),
                        (int)reemitting, (int)(patFlatTs != nullptr),
                        (int)patFlatAdjust, (int)ap.memberSetters.size(),
                        (int)(ap.defaultSetter != nullptr),
                        (int)ap.typeSetters.size());
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiAssignmentPatternOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            // A NESTED pattern (member setter of an outer pattern): no
            // first-operand VpiSize, and a BARE ts ref to the member's
            // typedef struct typespec (Surelog).
            bool nestedPat = parent && parent->UhdmType() == UHDM::uhdmoperation &&
                             ((UHDM::operation*)parent)->VpiOpType() ==
                                 vpiAssignmentPatternOp;
            // The ARM of a CONDITIONAL operation gets the same bare ts ref.
            // Surelog compiles a `? :` with an explicit expected type and
            // stamps each arm's pattern with the target's typespec; a pattern
            // written DIRECTLY as the cont-assign Rhs gets none (measured
            // side by side: `assign out = flag ? '{..} : '{..}` tags both
            // arms, `assign out2 = '{..}` tags nothing). CondOpPattern.
            bool condArmPat = parent && parent->UhdmType() == UHDM::uhdmoperation &&
                              ((UHDM::operation*)parent)->VpiOpType() ==
                                  vpiConditionOp;
            if ((nestedPat || condArmPat) && reemitting && expr.type) {
                UHDM::typespec* mts = nullptr;
                if (auto tit = pkgTopTypedefTs.find(
                        (const Symbol*)&expr.type->getCanonicalType());
                    tit != pkgTopTypedefTs.end())
                    mts = tit->second;
                if (!mts && expr.type->kind == SymbolKind::TypeAlias) {
                    if (auto tit2 = pkgTopTypedefTs.find(
                            &expr.type->as<TypeAliasType>());
                        tit2 != pkgTopTypedefTs.end())
                        mts = tit2->second;
                    if (!mts)
                        if (auto tit3 = typedefTs.find(expr.type);
                            tit3 != typedefTs.end())
                            mts = tit3->second;
                }
                if (mts) {
                    auto* rt = s.MakeRef_typespec();
                    rt->Actual_typespec(mts);
                    op->Typespec(rt);
                }
            }
            // ---- Surelog's ExprEval::flattenPatternAssignments ----
            // A STRUCT-typed pattern that carries a TYPE key (`int: 0`) or a
            // `default:` key is not merely untagged when it is re-emitted: it
            // is REBUILT, one operand per struct MEMBER, in member-declaration
            // order.  A member with no setter takes a fresh copy of the
            // default value, a type key claims the FIRST member whose typespec
            // has the same UHDM kind, and a member value that is itself a
            // tagged pattern is flattened recursively against that member's
            // typespec (which it then carries as a nameless ts ref).
            // Runs only where `patFlatTs` names the target struct typespec —
            // the cont_assign RHS and the unpacked-struct declaration
            // initializer, the two sites that call the flatten in Surelog.
            // PatternOrder / AssignRhsFlat.
            // § patFlatMemberOnly27 (r10earl27) — ...AND A PATTERN WITH ONLY
            // MEMBER SETTERS IS FLATTENED THE SAME WAY.  The gate used to
            // require a TYPE key or a DEFAULT setter, so a plain
            // `'{m_a: x, m_b: y}` fell through to the generic loop below,
            // which emits slang's `memberSetters` in WRITTEN order and never
            // recurses `patFlatTs` into a member's own pattern.  Both of those
            // are visible, and both were the pass-27 frontier in turn:
            //   ORDER (qk27.sv, a child instance, LHS(golden) first) — a
            //   SHUFFLED `'{m_a, m_d, m_c, m_b}` reduces to
            //   [a@38, b@41, c@40, d@39] in golden and reduced to
            //   [a@38, d@39, c@40, b@41] for us; the tagged (def) form keeps
            //   the WRITTEN order on BOTH sides, and a pattern written in
            //   declaration order, or POSITIONALLY, measures equal either way.
            //   Corpus: tlul_adapter_host.sv:84 writes a_mask before a_source
            //   where tlul_pkg::tl_h2d_t declares a_source, a_address, a_mask,
            //   so bis27 read Operands[4] as LHS(golden) ref_obj 'tl_source'
            //   @92:16 / RHS(ours) ref_obj 'tl_be' @91:16, vectors the SAME
            //   SIZE.
            //   NESTING (qm27.sv) — a MEMBER VALUE that is itself
            //   `'{default:'0}` expands to ONE OPERAND PER MEMBER of that
            //   member's struct, each default folded at the member's own width:
            //   golden `[UINT 0/7, UINT 0/1, UINT 0/8]` where we emitted the
            //   single written `'0` (BIN, size 1).  A SIZED default (`1'b0`)
            //   stays BIN 1'b0 on all three, `'1` becomes UINT 127/1/255, and
            //   `'{u_en: 1'b1, default: '0}` interleaves correctly in
            //   declaration order — every one of those is what this flatten
            //   already does, which is why the fix is the GATE and not new
            //   code.  The NON-nested `'{default:'0}` was already right (it
            //   satisfied the old gate) and is the control that proves the
            //   two paths only differed in reachability.
            if (reemitting && patFlatTs &&
                patFlatTs->UhdmType() == UHDM::uhdmstruct_typespec &&
                (!ap.typeSetters.empty() || ap.defaultSetter ||
                 !ap.memberSetters.empty()) &&
                ap.indexSetters.empty() && expr.type &&
                expr.type->getCanonicalType().isStruct()) {
                auto* sts9 = (const UHDM::struct_typespec*)patFlatTs;
                std::vector<const Symbol*> fields9;
                for (auto& fm9 : expr.type->getCanonicalType()
                                     .as<Scope>()
                                     .members())
                    if (fm9.kind == SymbolKind::Field)
                        fields9.push_back(&fm9);
                const UHDM::VectorOftypespec_member* mems9 = sts9->Members();
                if (mems9 && mems9->size() == fields9.size() &&
                    !fields9.empty()) {
                    std::vector<const Expression*> slots9(fields9.size(),
                                                          nullptr);
                    bool ok9 = true;
                    for (auto& st9 : ap.memberSetters) {
                        auto it9 = std::find(fields9.begin(), fields9.end(),
                                             st9.member.get());
                        if (it9 == fields9.end()) {
                            ok9 = false;
                            break;
                        }
                        slots9[(size_t)(it9 - fields9.begin())] =
                            st9.expr.get();
                    }
                    // A type key matches on the UHDM typespec KIND of the
                    // member, first match wins (Surelog compares
                    // `ttp->UhdmType() == fieldTypes[i]->UhdmType()`).
                    for (auto& st9 : ap.typeSetters) {
                        auto kk9 = uhdmTsKindOfType(*st9.type.get());
                        if (kk9 == UHDM::uhdmunsupported_typespec) {
                            ok9 = false;
                            break;
                        }
                        bool hit9 = false;
                        for (size_t i9 = 0; i9 < mems9->size(); i9++) {
                            auto* mrt9 = (*mems9)[i9]->Typespec();
                            auto* mts9 =
                                mrt9 ? mrt9->Actual_typespec() : nullptr;
                            if (mts9 && mts9->UhdmType() == kk9) {
                                slots9[i9] = st9.expr.get();
                                hit9 = true;
                                break;
                            }
                        }
                        if (!hit9) {
                            ok9 = false;
                            break;
                        }
                    }
                    for (auto& sl9 : slots9)
                        if (!sl9) {
                            if (!ap.defaultSetter) {
                                ok9 = false;
                                break;
                            }
                            sl9 = ap.defaultSetter;
                        }
                    if (ok9) {
                        // A NESTED flattened pattern carries the member
                        // typespec it was flattened against; the OUTERMOST one
                        // does not (UhdmWriter copies only the flattened
                        // operand vector back onto the original op).
                        if (nestedPat && !op->Typespec()) {
                            auto* frt9 = s.MakeRef_typespec();
                            frt9->Actual_typespec(
                                (UHDM::typespec*)patFlatTs);
                            op->Typespec(frt9);
                        }
                        auto* fops9 = s.MakeAnyVec();
                        for (size_t i9 = 0; i9 < slots9.size(); i9++) {
                            auto* mrt9 = (*mems9)[i9]->Typespec();
                            this->patFlatTs =
                                mrt9 ? mrt9->Actual_typespec() : nullptr;
                            if (auto* e9 =
                                    emitExpr(*slots9[i9], op, prefix, netMap)) {
                                // § patFlatDefaultFillMemberWidth27 (r10earl27)
                                // — AN UNSIZED `default:` FILL IS RE-ENCODED
                                // UINT AT THE MEMBER'S OWN WIDTH.  The fill has
                                // no width of its own (emitExpr gives BIN
                                // `'0` at size -1); the member lends it one,
                                // and Surelog's reduce then writes the DECIMAL
                                // value.  qm27.sv, LHS(golden) first, on
                                // tl_a_user_t-shaped {7,1,8} members:
                                //   `'{default: '0}`    UINT:0   at 7 / 1 / 8
                                //                       decompile "0"
                                //   `'{default: '1}`    UINT:127 / 1 / 255
                                //   `'{default: 1'b0}`  BIN 1'b0 size 1 on ALL
                                //                       THREE — a SIZED default
                                //                       keeps its own encoding
                                //   `'{u_en: 1'b1, default: '0}` interleaves:
                                //                       UINT:0/7, BIN 1'b1,
                                //                       UINT:0/8
                                // which is the same split ParamEmit ~5240
                                // already implements for a struct PARAMETER's
                                // pattern ("a BASED/SIZED literal setter keeps
                                // its own source encoding; anything else folds
                                // to UINT at the member width").
                                // CORPUS: tlul_adapter_host.sv:95
                                // `a_user: '{default:'0}` — bis27 read
                                // `rel=97 VECTOR SIZE 3 vs 1` there, then
                                // LHS(golden) constant {ct=9 sz=7 dec=0} /
                                // RHS(ours) {ct=3 sz=1 dec='0}.
                                // SCOPE — deliberately the DEFAULT setter only.
                                // An unsized literal written as a NAMED member
                                // value is the UNMEASURED HALF (no witness row
                                // varies it), so it keeps the old shape until
                                // one does.
                                if (ap.defaultSetter &&
                                    slots9[i9] == ap.defaultSetter &&
                                    e9->UhdmType() == UHDM::uhdmconstant &&
                                    stripImplicitConv(*slots9[i9]).kind ==
                                        ExpressionKind::
                                            UnbasedUnsizedIntegerLiteral) {
                                    logic_t fb9 =
                                        stripImplicitConv(*slots9[i9])
                                            .as<UnbasedUnsizedIntegerLiteral>()
                                            .getLiteralValue();
                                    int64_t fw9 = surelogTsBits(
                                        fields9[i9]->getDeclaredType()
                                            ->getType());
                                    if (!fb9.isUnknown() && fw9 > 0 &&
                                        fw9 <= 4096) {
                                        slang::SVInt fv9(
                                            (slang::bitwidth_t)fw9, 0, false);
                                        if (fb9.value)
                                            fv9.setAllOnes();
                                        std::string fd9 = fv9.toString(
                                            LiteralBase::Decimal, false);
                                        auto* fc9 = (UHDM::constant*)e9;
                                        fc9->VpiSize((int32_t)fw9);
                                        fc9->VpiValue("UINT:" + fd9);
                                        fc9->VpiConstType(vpiUIntConst);
                                        fc9->VpiDecompile(fd9);
                                    }
                                }
                                fops9->push_back(e9);
                            }
                            this->patFlatTs = nullptr;
                        }
                        // expandPatternAssignment's untagged arm walks the
                        // flattened operands calling adjustOpSize, and STOPS
                        // at the first one its reduce cannot value — so the
                        // member width lands on every leading constant plus
                        // the one operand that stopped the walk.
                        if (patFlatAdjust)
                            for (size_t i9 = 0; i9 < fops9->size() &&
                                                i9 < fields9.size();
                                 i9++) {
                                int64_t bw9 = surelogTsBits(
                                    fields9[i9]->getDeclaredType()->getType());
                                if (bw9 >= 0)
                                    ((UHDM::expr*)(*fops9)[i9])
                                        ->VpiSize((int32_t)bw9);
                                // § patFlatAdjustStopsAtUnvaluable27
                                // (r10earl27) — "the one operand that stopped
                                // the walk" is the first one Surelog's REDUCE
                                // CANNOT VALUE, which is NOT the same as the
                                // first non-constant: a member value that is a
                                // constant-FOLDABLE OPERATION is valued fine
                                // and the walk carries on past it.  The pair
                                // that measures it, LHS(golden) first:
                                //   qi27 `'{a_size: pkg::TL_SZW'(WordSize),
                                //          a_mask: be_i, a_data: wdata_i}`
                                //     [0] the op67 CAST (foldable)  size 2 both
                                //     [1] ref_obj be_i             size 4 /
                                //                                  NONE
                                //     [2] ref_obj wdata_i          none both
                                //   qk27 `'{m_a: a_i, ...}` (all ref_objs)
                                //     [0] ref_obj a_i              size 2 both
                                //     [1..3]                       none both
                                // so golden stamps ONE operand past the cast
                                // and stops, and stamps nothing past a bare
                                // ref — exactly "every leading VALUABLE operand
                                // plus the one that stopped the walk".  The old
                                // is-a-constant test broke at the cast and left
                                // be_i unsized, which was the qi27 head after
                                // laws 1-3.
                                ASTContext vctx9(comp.getRoot(),
                                                 LookupLocation::max);
                                auto vv9 = vctx9.tryEval(*slots9[i9]);
                                if (!vv9 || !vv9.isInteger() ||
                                    vv9.integer().hasUnknown())
                                    break;
                            }
                        op->Operands(fops9);
                        // Tell the caller this vector is ALREADY in
                        // member-declaration order (§ patFlatDidOrder27).  Only
                        // the OUTERMOST pattern reports — a nested flatten's
                        // vector is not the one the caller holds.
                        if (!nestedPat)
                            patFlatDidOrder27 = true;
                        return op;
                    }
                }
            }
            auto* operands = s.MakeAnyVec();
            // Tag key locations come from the pattern item syntax, matched
            // to member setters by name.
            const syntax::StructuredAssignmentPatternSyntax* psyn = nullptr;
            if (expr.syntax &&
                expr.syntax->kind == syntax::SyntaxKind::AssignmentPatternExpression) {
                const syntax::AssignmentPatternSyntax* pat =
                    expr.syntax->as<syntax::AssignmentPatternExpressionSyntax>().pattern;
                if (pat && pat->kind == syntax::SyntaxKind::StructuredAssignmentPattern)
                    psyn = &pat->as<syntax::StructuredAssignmentPatternSyntax>();
            }
            for (auto& setter : ap.memberSetters) {
                // An ENUM-CONSTANT member value folds to its VALUE in a
                // MODULE's own struct-pattern localparam, in BOTH views:
                // Surelog's reduce resolves the enum member to a BIN constant
                // at the MEMBER width, spanning the reference, where an
                // ordinary expression member value would keep its ref. rp32's
                // wrappers: `localparam isa_t ISA = '{spec: RV32I, priv:
                // MODES_NONE}` -> 23'b01000000000000000000000 / 4'b0000. The
                // DEF view leaves the constant unparented and untyped inside
                // its tagged_pattern; the tag-dropping elab re-emit parents it
                // at the operation. Package params (paramInitPkg /
                // importedParamClone) keep their paramInitElabFold behaviour.
                UHDM::constant* enumFold6 = nullptr;
                if (!paramInitPkg && !importedParamClone && setter.expr->type &&
                    setter.expr->type->isIntegral()) {
                    auto& ev6 = stripImplicitConv(*setter.expr);
                    if (ev6.kind == ExpressionKind::NamedValue &&
                        ev6.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::EnumValue) {
                        ASTContext ectx6(comp.getRoot(), LookupLocation::max);
                        if (auto ecv6 = ectx6.tryEval(*setter.expr);
                            ecv6 && ecv6.isInteger() &&
                            !ecv6.integer().hasUnknown()) {
                            auto eiv6 = ecv6.integer();
                            int32_t ew6 =
                                (int32_t)setter.expr->type->getBitWidth();
                            std::string eb6;
                            for (int32_t b6 = ew6 - 1; b6 >= 0; b6--)
                                eb6 += (eiv6[b6] == slang::logic_t(1)) ? '1'
                                                                       : '0';
                            enumFold6 = s.MakeConstant();
                            setLoc(enumFold6, setter.expr->sourceRange);
                            enumFold6->VpiSize(ew6);
                            enumFold6->VpiValue("BIN:" + eb6);
                            enumFold6->VpiConstType(vpiBinaryConst);
                            enumFold6->VpiDecompile(std::to_string(ew6) + "'b" +
                                                    eb6);
                        }
                    }
                }
                // ...and the substitution is NOT package-only.  Measured on a
                // 4-member probe over {module-local enum, imported package
                // enum} x {member wider / narrower / equal to the enum, an
                // IMPLICIT enum member} (r10ece probes b and c, byte-identical
                // results for both enum origins): the enum member's own
                // literal form is what lands, always.  `E0 = 3'b101` into a
                // 4-bit member is BIN:101 / "3'b101" at size 3, `E2 = 3'h7`
                // into a 2-bit member is HEX:7 / "3'h7" at size 3, and an
                // implicit `E1` is INT:6 / "6" at the enum's base width — the
                // BIN-at-member-width enumFold6 form below is right only when
                // the two widths coincide, which is why rp32 (whose enum
                // members are $bits(isa_spec_t)-wide concats read into
                // same-width members) never showed it.
                //   The substitution needs a LITERAL form to substitute, and
                // at a MODULE site that is the whole gate: rp32's `RV32I =
                // {RV_32I, RV_NONE}` has none, enumConstMap holds its SOURCE
                // TEXT as the decompile, and handing that back regressed
                // rp32_r5p_alu/_wbu to `{RV_32I,RV_NONE}` where the golden
                // wants the 23'b0100... bit string.  So an
                // expression-initialized member keeps the BIN-at-member-width
                // enumFold6 fold below.  A PACKAGE site is unguarded — its
                // shapes were measured with the map form and are landed.
                // EnumConstElab / rp32_r5p_alu.
                UHDM::constant* pkgEnumFold6 = nullptr;
                {
                    bool pkgSite7 =
                        paramInitPkg || importedParamClone || pkgEnumSubstPat;
                    auto& ev7 = stripImplicitConv(*setter.expr);
                    if (ev7.kind == ExpressionKind::NamedValue &&
                        !enumBaseIsImplicit(
                            ev7.as<NamedValueExpression>().symbol) &&
                        (pkgSite7 ||
                         enumMemberLiteralForm(
                             ev7.as<NamedValueExpression>().symbol)))
                        pkgEnumFold6 = enumMemberSubstConst(
                            ev7.as<NamedValueExpression>().symbol);
                    if (pkgEnumFold6)
                        setLoc(pkgEnumFold6, setter.expr->sourceRange);
                }
                // Re-emitted (instance) patterns drop the tags: operands are
                // the raw values, and the first one carries VpiSize.
                if (reemitting) {
                    // ...and the package enum-literal substitution wins
                    // over the module BIN form here too.
                    if (pkgEnumFold6) {
                        pkgEnumFold6->VpiParent(op);
                        operands->push_back(pkgEnumFold6);
                        continue;
                    }
                    if (enumFold6) {
                        enumFold6->VpiParent(op);
                        operands->push_back(enumFold6);
                        continue;
                    }
                    if (auto* e = emitExpr(*setter.expr, op, prefix, netMap)) {
                        if (operands->empty() && !nestedPat)
                            ((UHDM::expr*)e)->VpiSize(
                                (int32_t)setter.expr->type->getBitWidth());
                        // A CONCAT value that folded re-encodes BINARY at the
                        // member width with a BARE ts ref (Surelog).
                        if (((UHDM::any*)e)->UhdmType() ==
                                UHDM::uhdmconstant &&
                            stripImplicitConv(*setter.expr).kind ==
                                ExpressionKind::Concatenation &&
                            setter.expr->type) {
                            ASTContext bctx8(comp.getRoot(),
                                             LookupLocation::max);
                            if (auto bcv8 = bctx8.tryEval(*setter.expr);
                                bcv8 && bcv8.isInteger() &&
                                !bcv8.integer().hasUnknown()) {
                                auto biv8 = bcv8.integer();
                                int32_t w8 = (int32_t)setter.expr->type
                                                 ->getBitWidth();
                                std::string bits8;
                                for (int32_t i8 = w8 - 1; i8 >= 0; i8--)
                                    bits8 +=
                                        (biv8[i8] == slang::logic_t(1))
                                            ? '1'
                                            : '0';
                                auto* bc8 = (UHDM::constant*)e;
                                bc8->VpiValue("BIN:" + bits8);
                                bc8->VpiConstType(vpiBinaryConst);
                                bc8->VpiSize(w8);
                                bc8->VpiDecompile("");
                                if (auto* brt8 = bc8->Typespec())
                                    brt8->VpiFullName("");
                            }
                        }
                        operands->push_back(e);
                    }
                    continue;
                }
                auto* tp = s.MakeTagged_pattern();
                tp->VpiParent(op);
                // A tagged-pattern value containing a SPACE-stripped based
                // literal (Prefix: 96'(96'h 4c52...)) shrinks its end column
                // by the removed whitespace (Surelog re-lexes compactly).
                {
                    SourceRange tpr9 = setter.expr->sourceRange;
                    if (size_t sp9 = basedLiteralSpaceCount(rawText(tpr9)))
                        tpr9 = SourceRange(tpr9.start(), tpr9.end() - sp9);
                    setLoc(tp, tpr9);
                }
                bool savedPV2 = inPatternValue;
                inPatternValue = true;
                // The pattern value parents at the OPERATION — except a
                // literal value in a def CONT-ASSIGN, which stays unparented.
                bool savedS2 = suppressConstParent, savedF2 = forceConstParent;
                if ((paramInitDef || defRefModConn) &&
                    isLiteralExpr(*setter.expr)) {
                    suppressConstParent = true;
                    forceConstParent = false;
                }
                // A REPLICATION member value ({NDioPads{B}}) folds to the
                // repeated bit pattern: a BIN constant at the member width with
                // a BARE ts ref (Surelog). emitExpr would otherwise keep the
                // op-34 multiconcat operation, so pre-build the folded constant.
                // Only a PACKAGE param's pattern folds this way (in the package
                // views and in an importing module's copy of it); a MODULE's OWN
                // localparam pattern keeps the replication op in its def view
                // (BSOPPS*InGenForOfSubmodule work@top.PinmuxTargetCfg).
                UHDM::any* preE = nullptr;
                if (paramInitDef && (paramInitPkg || importedParamClone) &&
                    stripImplicitConv(*setter.expr).kind ==
                        ExpressionKind::Replication &&
                    setter.expr->type) {
                    ASTContext rctx7(comp.getRoot(), LookupLocation::max);
                    if (auto rcv7 = rctx7.tryEval(*setter.expr);
                        rcv7 && rcv7.isInteger() &&
                        !rcv7.integer().hasUnknown()) {
                        auto riv7 = rcv7.integer();
                        int32_t rw7 =
                            (int32_t)setter.expr->type->getBitWidth();
                        std::string rbits7;
                        for (int32_t bi7 = rw7 - 1; bi7 >= 0; bi7--)
                            rbits7 += (riv7[bi7] == slang::logic_t(1)) ? '1'
                                                                       : '0';
                        auto* rc7 = s.MakeConstant();
                        // DEF view leaves the folded pattern constant UNPARENTED
                        // with a BARE (nameless) ts ref (Surelog).
                        setLoc(rc7, setter.expr->sourceRange);
                        rc7->VpiDecompile(rbits7);
                        rc7->VpiSize(rw7);
                        rc7->VpiValue("BIN:" + rbits7);
                        rc7->VpiConstType(vpiBinaryConst);
                        auto* rrt7 = s.MakeRef_typespec();
                        rrt7->VpiParent(rc7);
                        rrt7->VpiFullName("");
                        rrt7->Actual_typespec(s.MakeInt_typespec());
                        rc7->Typespec(rrt7);
                        preE = rc7;
                    }
                }
                // A TYPE-CAST member value (RVC: bit'(CVA6ConfigCExtEn)) folds
                // the same way, in BOTH package views — but to a BARE constant:
                // BIN at the member width with NO decompile and NO ts ref.
                // Surelog's reduce resolves the cast to a value and the cast
                // typespec is not carried onto the member (FuncStructValSimple).
                if (!preE && paramInitDef && (paramInitPkg || importedParamClone) &&
                    setter.expr->type && setter.expr->type->isIntegral()) {
                    auto& cv7 = stripImplicitConv(*setter.expr);
                    if (cv7.kind == ExpressionKind::Conversion && cv7.syntax &&
                        cv7.syntax->kind == syntax::SyntaxKind::CastExpression &&
                        isTypeSyntaxKind(cv7.syntax
                                             ->as<syntax::CastExpressionSyntax>()
                                             .left->kind)) {
                        ASTContext tctx7(comp.getRoot(), LookupLocation::max);
                        if (auto tcv7 = tctx7.tryEval(*setter.expr);
                            tcv7 && tcv7.isInteger() &&
                            !tcv7.integer().hasUnknown()) {
                            auto tiv7 = tcv7.integer();
                            int32_t tw7 =
                                (int32_t)setter.expr->type->getBitWidth();
                            std::string tb7;
                            for (int32_t bi7 = tw7 - 1; bi7 >= 0; bi7--)
                                tb7 += (tiv7[bi7] == slang::logic_t(1)) ? '1'
                                                                        : '0';
                            auto* tc7 = s.MakeConstant();
                            setLoc(tc7, setter.expr->sourceRange);
                            tc7->VpiSize(tw7);
                            tc7->VpiValue("BIN:" + tb7);
                            tc7->VpiConstType(vpiBinaryConst);
                            preE = tc7;
                        }
                    }
                }
                // § patMemberSizeCastDef (r10earl5) — and a SIZE cast
                // (`WakeUpPeris'(1'b1)`, `8'(1'b1)`) folds in the DEF view too,
                // but to a UINT constant at the CAST's OWN width with no
                // decompile and no ts ref — NOT the BIN-at-member-width the
                // type-cast arm above builds.  Measured on jj.sv, one row per
                // spelling, DEF listing beside TOP listing:
                //     member logic [15:0]   DEF                 TOP(flattened)
                //     WakeUpPeris'(1'b1)  UINT:1 sz16 dec ''  UINT:1 sz16 dec ''
                //     16'(1'b1)           UINT:1 sz16 dec ''  UINT:1 sz16 dec ''
                //     8'(1'b1)            UINT:1 sz 8 dec ''  UINT:1 sz16 dec ''
                //     WakeUpPeris'(HwRstReqs) UINT:2 sz16     UINT:2 sz16
                // — the 8'( ) row is what separates the two widths: the DEF
                // view keeps the CAST's width, the elaborated view re-sizes to
                // the MEMBER (§ patMemberCastNoDecomp, ParamEmit).  Earlgrey
                // pwrmgr_pkg.sv:156 is the corpus witness and this is the
                // AllPackages head "constant 156:14 {ct=9 sz=16 dec=}".
                // The <=64 CEILING is a REGRESSION-derived distinguisher, not a
                // guess: u2r ImportedDoubleCastedParameter's `Prefix:
                // 96'(96'h 4c52_5443_5f4d_4f52_4001_0001)` keeps the whole
                // vpiCastOp tree in golden.  jj.sv's `16'(16'h1)` row folds, so
                // a BASED-LITERAL operand is NOT the blocker — the width is
                // (Surelog's ExprEval answers in 64 bits).
                if (!preE && paramInitDef &&
                    (paramInitPkg || importedParamClone) && setter.expr->type &&
                    setter.expr->type->isIntegral()) {
                    auto& sc7 = stripImplicitConv(*setter.expr);
                    if (sc7.kind == ExpressionKind::Conversion && sc7.syntax &&
                        sc7.syntax->kind == syntax::SyntaxKind::CastExpression &&
                        !isTypeSyntaxKind(sc7.syntax
                                              ->as<syntax::CastExpressionSyntax>()
                                              .left->kind) &&
                        sc7.type && sc7.type->isIntegral() &&
                        sc7.type->getBitWidth() <= 64) {
                        ASTContext sctx7(comp.getRoot(), LookupLocation::max);
                        if (auto scv7 = sctx7.tryEval(sc7);
                            scv7 && scv7.isInteger() &&
                            !scv7.integer().hasUnknown()) {
                            auto siv7 = scv7.integer();
                            siv7.setSigned(false);
                            auto* sc7c = s.MakeConstant();
                            setLoc(sc7c, setter.expr->sourceRange);
                            sc7c->VpiSize((int32_t)sc7.type->getBitWidth());
                            sc7c->VpiValue(
                                "UINT:" +
                                siv7.toString(LiteralBase::Decimal, false));
                            sc7c->VpiConstType(vpiUIntConst);
                            preE = sc7c;
                        }
                    }
                }
                // § r10fsv2 L4 — a SIZE CAST over a CONCAT (`1024'({64'h0,
                // 64'h0})`).  Surelog's reduce folds the CONCAT first and then
                // decides on the cast, in two arms measured on FuncStructVal's
                // six such members (both package views agree) and reproduced
                // by tools/probe/r10fsv_memleft.sv's `C_cast1` / `C_cast2`:
                //   * the concat FITS 64 bits — the cast folds too, to a UINT
                //     constant at the CAST width with an EMPTY decompile.  The
                //     value is lost (golden stores UINT:0 for `1024'({64'h8000_
                //     0000})` as well as for the oracle's `128'({64'h3})`) —
                //     the mask ExprEval applies is built by a shift that wraps
                //     at every multiple of 64, so it comes out zero.
                //   * the concat is WIDER than 64 bits — the cast OPERATION
                //     survives, but its concat operand is replaced by a single
                //     BIN constant at the concat's own width (decompile empty),
                //     spanning the concat.
                // Both arms feed § r10fsv2 L1: these element objects ARE the
                // EvalFunc leftovers of the members that read them.
                const Expression* castCat4 = nullptr;
                if (paramInitDef && (paramInitPkg || importedParamClone) &&
                    setter.expr->type && setter.expr->type->isIntegral() &&
                    setter.expr->type->getBitWidth() > 64) {
                    auto& cc4 = stripImplicitConv(*setter.expr);
                    if (cc4.kind == ExpressionKind::Conversion && cc4.syntax &&
                        cc4.syntax->kind ==
                            syntax::SyntaxKind::CastExpression &&
                        !isTypeSyntaxKind(
                            cc4.syntax->as<syntax::CastExpressionSyntax>()
                                .left->kind)) {
                        auto& in4 = stripImplicitConv(
                            cc4.as<ConversionExpression>().operand());
                        if (in4.kind == ExpressionKind::Concatenation &&
                            in4.type && in4.type->isIntegral()) {
                            if (in4.type->getBitWidth() <= 64) {
                                if (!preE) {
                                    auto* zc4 = s.MakeConstant();
                                    setLoc(zc4, setter.expr->sourceRange);
                                    zc4->VpiSize((int32_t)setter.expr->type
                                                     ->getBitWidth());
                                    zc4->VpiValue("UINT:0");
                                    zc4->VpiConstType(vpiUIntConst);
                                    preE = zc4;
                                }
                            }
                            else
                                castCat4 = &in4;
                        }
                    }
                }
                // ELAB package view that KEEPS the tagged tree: Surelog's
                // reduce still runs over each member value, so a value written
                // as an EXPRESSION collapses to one BIN constant at the member
                // width, spanning the whole expression and left UNPARENTED and
                // untyped (ValueSize `addr: {SeedBank, 2'b11}` -> BIN:0011).
                // A value that is already a literal is untouched — PAssignType's
                // `manual_operation: '0` keeps its unsized '0 form.
                // A member whose value is itself a PATTERN keeps its nested
                // tagged tree (Surelog reduces leaf expressions, not the
                // pattern structure) — GenIfIfaceParamStructField `'{HSK:
                // '{DLY: 1}}`.
                bool nestedPatVal6 = false;
                {
                    auto& sv6 = stripImplicitConv(*setter.expr);
                    nestedPatVal6 =
                        sv6.kind == ExpressionKind::StructuredAssignmentPattern ||
                        sv6.kind == ExpressionKind::SimpleAssignmentPattern ||
                        sv6.kind == ExpressionKind::ReplicatedAssignmentPattern;
                }
                // A PACKAGE struct-pattern param's ENUM-CONSTANT member value
                // inlines the enum member's OWN literal form — not the
                // BIN-at-member-width the module rule (enumFold6) uses.
                // Surelog substitutes the enum_const verbatim, so an implicit
                // member (`PhaseSeed`) becomes INT:0 / decompile "0" and an
                // explicitly based one (`MuBi4True = 4'h6`) becomes HEX:6 /
                // decompile "4'h6", both at the enum's base width, and in
                // EVERY view (both package views, and an importing module's
                // materialized copy).  Same substitution the qualified
                // pkg::VALUE reference arm in emitExpr already performs — the
                // pattern member path just never reached it.
                // (AssignmentPatternInAssignmentPattern.)
                if (!preE && pkgEnumFold6)
                    preE = pkgEnumFold6;
                if (!preE && enumFold6)
                    preE = enumFold6;
                // RULE 1 (r9psc, ParamSubstituteComplex): in the module DEF
                // view a member setter that is a BARE parameter reference is
                // replaced by the referenced parameter's own Rhs constant
                // OBJECT — shared, so it keeps that param's span, parent
                // (its own param_assign) and typespec.  Surelog's
                // substituteAssignedValue hands back the value object itself;
                // a reference NESTED in a concat/operation is left alone
                // because the enclosing reduce fails.
                if (!preE && paramInitDef && paramRhsDefView) {
                    auto& bv1 = stripImplicitConv(*setter.expr);
                    const Symbol* bs1 = nullptr;
                    if (bv1.kind == ExpressionKind::NamedValue)
                        bs1 = &bv1.as<NamedValueExpression>().symbol;
                    else if (bv1.kind == ExpressionKind::HierarchicalValue)
                        bs1 = &bv1.as<HierarchicalValueExpression>().symbol;
                    if (bs1 && bs1->kind == SymbolKind::Parameter)
                        if (auto it1 = defParamRhsConst.find(bs1);
                            it1 != defParamRhsConst.end() && it1->second) {
                            // A COPY, not the object itself: Surelog's
                            // substitution deep-copies the value expression
                            // (the golden carries two constants and two
                            // ref_typespecs at `1'b0`'s span), and sharing one
                            // node under two parents is what uhdm-cmp's
                            // visited memo reads as a mismatch.  Everything
                            // else — span, parent (the SOURCE param_assign)
                            // and the bound typespec — is carried over.
                            auto* sc1 = it1->second;
                            auto* cc1 = s.MakeConstant();
                            cc1->VpiValue(std::string(sc1->VpiValue()));
                            cc1->VpiDecompile(std::string(sc1->VpiDecompile()));
                            cc1->VpiSize(sc1->VpiSize());
                            cc1->VpiConstType(sc1->VpiConstType());
                            cc1->VpiParent(sc1->VpiParent());
                            cc1->VpiFile(sc1->VpiFile());
                            cc1->VpiLineNo(sc1->VpiLineNo());
                            cc1->VpiColumnNo(sc1->VpiColumnNo());
                            cc1->VpiEndLineNo(sc1->VpiEndLineNo());
                            cc1->VpiEndColumnNo(sc1->VpiEndColumnNo());
                            if (auto* srt1 = sc1->Typespec()) {
                                auto* nrt1 = s.MakeRef_typespec();
                                nrt1->VpiFullName(
                                    std::string(srt1->VpiFullName()));
                                nrt1->VpiParent(cc1);
                                nrt1->Actual_typespec(
                                    (UHDM::typespec*)srt1->Actual_typespec());
                                cc1->Typespec(nrt1);
                            }
                            preE = cc1;
                        }
                }
                // A PACKAGE struct-pattern member VALUE written as a MEMBER
                // SELECT of ANOTHER struct-pattern parameter substitutes that
                // parameter's OWN value object for the member — verbatim, so
                // the constant keeps the SOURCE literal's span, size and
                // encoding rather than anything derived from the reference
                // site.  Measured on a purpose-built two-package golden and on
                // BlackBePipeInt: `copy_p.m0: base_p.m0` -> base_p's `1`
                // (UINT:1 sz64 at the literal), and the BlackParrot
                // `(over_p.m == "inv") ? base_p.m : over_p.m` idiom resolves
                // the ternary and substitutes the TAKEN branch's object,
                // chaining through an already-substituted parameter
                // (`merged_p.m3` -> `copy_p.m3` -> `base_p`'s `4`).  Both
                // package listings do it, each off its own view's objects
                // (pkgPatSubstValue).
                //
                // RESIDUE (byte-identity only, not cmp): Surelog SHARES the
                // one object across every user; we copy it, exactly as RULE 1
                // above does and for the same reason — one node under two
                // parents is what uhdm-cmp's visited memo reads as a mismatch.
                if (!preE && (paramInitPkg || importedParamClone) &&
                    !nestedPatVal6 && !isLiteralExpr(*setter.expr)) {
                    if (auto* sv4 = pkgPatSubstValue(*setter.expr, 0))
                        if (sv4->UhdmType() == UHDM::uhdmconstant) {
                            auto* sc4 = (UHDM::constant*)sv4;
                            auto* cc4 = s.MakeConstant();
                            cc4->VpiValue(std::string(sc4->VpiValue()));
                            cc4->VpiDecompile(std::string(sc4->VpiDecompile()));
                            cc4->VpiSize(sc4->VpiSize());
                            cc4->VpiConstType(sc4->VpiConstType());
                            cc4->VpiParent(sc4->VpiParent());
                            cc4->VpiFile(sc4->VpiFile());
                            cc4->VpiLineNo(sc4->VpiLineNo());
                            cc4->VpiColumnNo(sc4->VpiColumnNo());
                            cc4->VpiEndLineNo(sc4->VpiEndLineNo());
                            cc4->VpiEndColumnNo(sc4->VpiEndColumnNo());
                            if (auto* srt4 = sc4->Typespec()) {
                                auto* nrt4 = s.MakeRef_typespec();
                                nrt4->VpiFullName(
                                    std::string(srt4->VpiFullName()));
                                nrt4->VpiParent(cc4);
                                nrt4->Actual_typespec(
                                    (UHDM::typespec*)srt4->Actual_typespec());
                                cc4->Typespec(nrt4);
                            }
                            preE = cc4;
                        }
                }
                // A PACKAGE struct-pattern member VALUE written as an
                // ARITHMETIC EXPRESSION or a SYSTEM CALL reduces to a DECIMAL
                // constant in BOTH package listings — Surelog evaluates each
                // member setter while the pattern structure itself survives.
                // Three measured details (purpose-built 6-member package
                // golden; BlackBePipeInt `dcache_features` is the corpus
                // case): the size is always 64, NOT the member's own width;
                // the encoding is `reduceExpr`'s per-operator answer
                // (sub/mult/div -> signed vpiIntConst, everything else UINT);
                // and the span is the TOP-LEVEL operator's LEFT operand alone
                // (`N*2-1` -> INT:9 at `N * 2`, `(1<<E0)|(1<<E1)|(1<<E2)` ->
                // UINT:7 at the first two terms), or the whole expression for
                // a call.  Concats, replications, casts, bare param refs and
                // enum members have their own arms above/below.
                if (!preE && paramInitPkg && !nestedPatVal6 &&
                    setter.expr->type && setter.expr->type->isIntegral() &&
                    !isLiteralExpr(*setter.expr)) {
                    auto& pv5 = stripImplicitConv(*setter.expr);
                    bool sysCall5 = pv5.kind == ExpressionKind::Call &&
                                    pv5.as<CallExpression>().isSystemCall();
                    if (pv5.kind == ExpressionKind::BinaryOp || sysCall5) {
                        ASTContext pc5(comp.getRoot(), LookupLocation::max);
                        if (auto pcv5 = pc5.tryEval(*setter.expr);
                            pcv5 && pcv5.isInteger() &&
                            !pcv5.integer().hasUnknown()) {
                            std::string dg5 = pcv5.integer().toString(
                                LiteralBase::Decimal, false);
                            bool int5 = srlgRedIntSyn(pv5.syntax);
                            auto* pc5c = s.MakeConstant();
                            setLoc(pc5c,
                                   pv5.kind == ExpressionKind::BinaryOp
                                       ? pv5.as<BinaryExpression>()
                                             .left()
                                             .sourceRange
                                       : pv5.sourceRange);
                            pc5c->VpiDecompile(dg5);
                            pc5c->VpiSize(64);
                            pc5c->VpiValue((int5 ? "INT:" : "UINT:") + dg5);
                            pc5c->VpiConstType(int5 ? vpiIntConst
                                                    : vpiUIntConst);
                            preE = pc5c;
                        }
                    }
                }
                if (!preE && paramInitElabFold && !nestedPatVal6 &&
                    setter.expr->type && !isLiteralExpr(*setter.expr) &&
                    setter.expr->type->isIntegral()) {
                    ASTContext fctx6(comp.getRoot(), LookupLocation::max);
                    if (auto fcv6 = fctx6.tryEval(*setter.expr);
                        fcv6 && fcv6.isInteger() &&
                        !fcv6.integer().hasUnknown()) {
                        auto fiv6 = fcv6.integer();
                        int32_t fw6 = (int32_t)setter.expr->type->getBitWidth();
                        std::string fb6;
                        for (int32_t b6 = fw6 - 1; b6 >= 0; b6--)
                            fb6 += (fiv6[b6] == slang::logic_t(1)) ? '1' : '0';
                        auto* fc6 = s.MakeConstant();
                        setLoc(fc6, setter.expr->sourceRange);
                        fc6->VpiSize(fw6);
                        fc6->VpiValue("BIN:" + fb6);
                        fc6->VpiConstType(vpiBinaryConst);
                        preE = fc6;
                    }
                }
                if (auto* e = preE ? preE
                                   : emitExpr(*setter.expr, op, prefix,
                                              netMap)) {
                    // § signCastReduce9 — a SIGNEDNESS cast (`unsigned'(X)`,
                    // `signed'(X)`) reaches UHDM as a $unsigned/$signed
                    // sys_func_call, and Surelog's reduce over a PACKAGE
                    // param's pattern hands back the ARGUMENT whenever that
                    // argument is already a constant: the call node is dropped
                    // and the argument survives verbatim — its own span, its
                    // 64-bit UINT encoding and its typespec ref — still
                    // parented at the now unreferenced (and, in the golden,
                    // unlocated) call.  A function BODY compiles with
                    // Reduce::No, so the same cast keeps its call there:
                    // golden FuncStructVal collapses all ~20 `unsigned'()`
                    // members of `cva6_config_pkg::cva6_cfg` (including
                    // literal args, `NrNonIdempotentRules: unsigned'(2)`)
                    // while `cfg.NrRgprPorts = unsigned'(2)` inside
                    // build_config keeps its sys_func_call.
                    if ((paramInitPkg || importedParamClone) &&
                        ((UHDM::any*)e)->UhdmType() ==
                            UHDM::uhdmsys_func_call) {
                        auto* sfc9 = (UHDM::sys_func_call*)e;
                        std::string sn9(sfc9->VpiName());
                        if ((sn9 == "$unsigned" || sn9 == "$signed") &&
                            sfc9->Tf_call_args() &&
                            sfc9->Tf_call_args()->size() == 1 &&
                            (*sfc9->Tf_call_args())[0]->UhdmType() ==
                                UHDM::uhdmconstant) {
                            sfc9->VpiFile("");
                            sfc9->VpiLineNo(0);
                            sfc9->VpiColumnNo(0);
                            sfc9->VpiEndLineNo(0);
                            sfc9->VpiEndColumnNo(0);
                            e = (*sfc9->Tf_call_args())[0];
                        }
                    }
                    // A CONCAT pattern value that folded re-encodes BINARY at
                    // the member width with a BARE ts ref (Surelog).
                    if (paramInitDef &&
                        ((UHDM::any*)e)->UhdmType() == UHDM::uhdmconstant &&
                        stripImplicitConv(*setter.expr).kind ==
                            ExpressionKind::Concatenation &&
                        setter.expr->type) {
                        ASTContext bctx9(comp.getRoot(), LookupLocation::max);
                        if (auto bcv9 = bctx9.tryEval(*setter.expr);
                            bcv9 && bcv9.isInteger() &&
                            !bcv9.integer().hasUnknown()) {
                            auto biv9 = bcv9.integer();
                            int32_t w9 =
                                (int32_t)setter.expr->type->getBitWidth();
                            std::string bits9;
                            for (int32_t i9 = w9 - 1; i9 >= 0; i9--)
                                bits9 += (biv9[i9] == slang::logic_t(1))
                                             ? '1'
                                             : '0';
                            auto* bc9 = (UHDM::constant*)e;
                            bc9->VpiValue("BIN:" + bits9);
                            bc9->VpiConstType(vpiBinaryConst);
                            bc9->VpiSize(w9);
                            bc9->VpiDecompile("");
                            if (auto* brt9 = bc9->Typespec())
                                brt9->VpiFullName("");
                        }
                    }
                    // § r10fsv2 L4, wide arm: the surviving cast operation's
                    // CONCAT operand collapses to one BIN constant at the
                    // concat's own width, decompile empty.
                    if (castCat4 && e->UhdmType() == UHDM::uhdmoperation) {
                        auto* co4 = (UHDM::operation*)e;
                        ASTContext ctx4(comp.getRoot(), LookupLocation::max);
                        if (auto ccv4 = ctx4.tryEval(*castCat4);
                            ccv4 && ccv4.isInteger() &&
                            !ccv4.integer().hasUnknown() && co4->Operands() &&
                            co4->Operands()->size() == 1) {
                            auto civ4 = ccv4.integer();
                            int32_t cw4 =
                                (int32_t)castCat4->type->getBitWidth();
                            std::string cb4;
                            cb4.reserve((size_t)cw4);
                            for (int32_t bi4 = cw4 - 1; bi4 >= 0; bi4--)
                                cb4 += (civ4[bi4] == slang::logic_t(1)) ? '1'
                                                                        : '0';
                            auto* bc4 = s.MakeConstant();
                            setLoc(bc4, castCat4->sourceRange);
                            bc4->VpiParent(co4);
                            bc4->VpiSize(cw4);
                            bc4->VpiValue("BIN:" + cb4);
                            bc4->VpiConstType(vpiBinaryConst);
                            (*co4->Operands())[0] = bc4;
                        }
                    }
                    // A MODULE-view copy of an imported param's pattern parents
                    // its member-value constant at the TAGGED_PATTERN and names
                    // that value's ts ref with the module prefix; the package
                    // views leave both bare (Surelog, BSOPPS*/TSPWRIS def
                    // views of work@<mod>.<imported param>).
                    if (importedParamClone && paramInitDef &&
                        e->UhdmType() == UHDM::uhdmconstant) {
                        auto* mc9 = (UHDM::constant*)e;
                        if (!mc9->VpiParent())
                            mc9->VpiParent(tp);
                        if (auto* mrt9 = mc9->Typespec();
                            mrt9 && mrt9->VpiFullName().empty()) {
                            std::string tsPfx9 = prefix;
                            if (tsPfx9.size() >= 2 &&
                                tsPfx9.compare(tsPfx9.size() - 2, 2, "::") == 0)
                                tsPfx9.resize(tsPfx9.size() - 2);
                            mrt9->VpiFullName(tsPfx9);
                            mrt9->VpiParent(mc9);
                        }
                    }
                    tp->Pattern((UHDM::expr*)e);
                }
                suppressConstParent = savedS2;
                forceConstParent = savedF2;
                inPatternValue = savedPV2;
                // Tag: a string_typespec named by the member key.
                auto* sts = s.MakeString_typespec();
                sts->VpiName(setter.member->name);
                sts->VpiParent(tp);
                if (psyn) {
                    for (auto item : psyn->items) {
                        if (item->kind != syntax::SyntaxKind::AssignmentPatternItem)
                            continue;
                        auto& it2 = item->as<syntax::AssignmentPatternItemSyntax>();
                        if (rawText(it2.key->sourceRange()) == setter.member->name) {
                            setLoc(sts, it2.key->sourceRange());
                            break;
                        }
                    }
                }
                auto* rt = s.MakeRef_typespec();
                {
                    std::string tsPfx8 = prefix;
                    if (tsPfx8.size() >= 2 &&
                        tsPfx8.compare(tsPfx8.size() - 2, 2, "::") == 0)
                        tsPfx8.resize(tsPfx8.size() - 2);
                    rt->VpiFullName(tsPfx8);
                }
                rt->VpiParent(tp);
                rt->Actual_typespec(sts);
                tp->Typespec(rt);
                operands->push_back(tp);
            }
            // TYPE keys ('{int: 0}): a tagged_pattern spanning the VALUE whose
            // tag is a typespec of the KEYED TYPE'S OWN class (int_typespec
            // for `int`, not the string_typespec a member key gets), located
            // at the type keyword.  Surelog matches such a key to a member by
            // typespec class when it flattens; in the un-flattened def view
            // the tag survives verbatim (AssignRhsFlat).  A key whose class we
            // cannot name is dropped rather than guessed.
            for (auto& setter : ap.typeSetters) {
                if (reemitting)
                    break;
                UHDM::typespec* kts9 = nullptr;
                bool ksgn9 = setter.type->isSigned();
                switch (uhdmTsKindOfType(*setter.type.get())) {
                    case UHDM::uhdmint_typespec: {
                        auto* t9 = s.MakeInt_typespec();
                        if (ksgn9)
                            t9->VpiSigned(true);
                        kts9 = t9;
                        break;
                    }
                    case UHDM::uhdminteger_typespec: {
                        auto* t9 = s.MakeInteger_typespec();
                        if (ksgn9)
                            t9->VpiSigned(true);
                        kts9 = t9;
                        break;
                    }
                    case UHDM::uhdmbyte_typespec: {
                        auto* t9 = s.MakeByte_typespec();
                        if (ksgn9)
                            t9->VpiSigned(true);
                        kts9 = t9;
                        break;
                    }
                    case UHDM::uhdmshort_int_typespec: {
                        auto* t9 = s.MakeShort_int_typespec();
                        if (ksgn9)
                            t9->VpiSigned(true);
                        kts9 = t9;
                        break;
                    }
                    case UHDM::uhdmlong_int_typespec: {
                        auto* t9 = s.MakeLong_int_typespec();
                        if (ksgn9)
                            t9->VpiSigned(true);
                        kts9 = t9;
                        break;
                    }
                    case UHDM::uhdmlogic_typespec:
                        kts9 = s.MakeLogic_typespec();
                        break;
                    case UHDM::uhdmbit_typespec:
                        kts9 = s.MakeBit_typespec();
                        break;
                    case UHDM::uhdmreal_typespec:
                        kts9 = s.MakeReal_typespec();
                        break;
                    case UHDM::uhdmshort_real_typespec:
                        kts9 = s.MakeShort_real_typespec();
                        break;
                    default:
                        break;
                }
                if (!kts9)
                    continue;
                auto* tp = s.MakeTagged_pattern();
                tp->VpiParent(op);
                setLoc(tp, setter.expr->sourceRange);
                bool sup9 = suppressConstParent, fcp9 = forceConstParent;
                suppressConstParent = true;
                forceConstParent = false;
                if (auto* e9 = emitExpr(*setter.expr.get(), op, prefix, netMap))
                    tp->Pattern((UHDM::expr*)e9);
                suppressConstParent = sup9;
                forceConstParent = fcp9;
                if (psyn)
                    for (auto item : psyn->items) {
                        if (item->kind !=
                            syntax::SyntaxKind::AssignmentPatternItem)
                            continue;
                        auto& it9 =
                            item->as<syntax::AssignmentPatternItemSyntax>();
                        if (it9.expr && it9.expr->sourceRange() ==
                                            setter.expr->sourceRange) {
                            setLoc(kts9, it9.key->sourceRange());
                            break;
                        }
                    }
                auto* rt9 = s.MakeRef_typespec();
                {
                    std::string tsPfx9 = prefix;
                    if (tsPfx9.size() >= 2 &&
                        tsPfx9.compare(tsPfx9.size() - 2, 2, "::") == 0)
                        tsPfx9.resize(tsPfx9.size() - 2);
                    rt9->VpiFullName(tsPfx9);
                }
                rt9->VpiParent(tp);
                rt9->Actual_typespec(kts9);
                tp->Typespec(rt9);
                operands->push_back(tp);
            }
            // Index setters ('{0:1, 3:1}): tagged_pattern with a string_typespec
            // tag named by the (source-text) index key.
            for (auto& setter : ap.indexSetters) {
                if (reemitting) {
                    if (auto* e = emitExpr(*setter.expr, op, prefix, netMap)) {
                        if (operands->empty())
                            ((UHDM::expr*)e)->VpiSize(
                                (int32_t)setter.expr->type->getBitWidth());
                        operands->push_back(e);
                    }
                    continue;
                }
                auto* tp = s.MakeTagged_pattern();
                tp->VpiParent(op);
                setLoc(tp, setter.expr->sourceRange);
                bool sup0 = suppressConstParent, fcp0 = forceConstParent;
                suppressConstParent = true;
                forceConstParent = false;
                if (auto* e = emitExpr(*setter.expr, op, prefix, netMap))
                    tp->Pattern((UHDM::expr*)e);
                suppressConstParent = sup0;
                forceConstParent = fcp0;
                // Numeric index tag: an integer_typespec carrying the index
                // value (INT), located at the index span.
                auto* its = s.MakeInteger_typespec();
                setLoc(its, setter.index->sourceRange);
                {
                    ASTContext ictx(comp.getRoot(), LookupLocation::max);
                    ConstantValue icv = ictx.tryEval(*setter.index);
                    if (icv && icv.isInteger())
                        its->VpiValue(
                            "INT:" + icv.integer().toString(LiteralBase::Decimal, false));
                }
                auto* rt = s.MakeRef_typespec();
                {
                    std::string tsPfx8 = prefix;
                    if (tsPfx8.size() >= 2 &&
                        tsPfx8.compare(tsPfx8.size() - 2, 2, "::") == 0)
                        tsPfx8.resize(tsPfx8.size() - 2);
                    rt->VpiFullName(tsPfx8);
                }
                rt->VpiParent(tp);
                rt->Actual_typespec(its);
                tp->Typespec(rt);
                operands->push_back(tp);
            }
            // Default setter ('{default: X}): tagged_pattern with a
            // string_typespec named "default" at the keyword span.
            if (ap.defaultSetter) {
                if (reemitting) {
                    if (auto* e = emitExpr(*ap.defaultSetter, op, prefix, netMap)) {
                        if (operands->empty())
                            ((UHDM::expr*)e)->VpiSize(
                                (int32_t)ap.defaultSetter->type->getBitWidth());
                        operands->push_back(e);
                    }
                }
                else {
                    auto* tp = s.MakeTagged_pattern();
                    tp->VpiParent(op);
                    setLoc(tp, ap.defaultSetter->sourceRange);
                    bool sup0 = suppressConstParent, fcp0 = forceConstParent;
                    suppressConstParent = true;
                    forceConstParent = false;
                    if (auto* e = emitExpr(*ap.defaultSetter, op, prefix, netMap)) {
                        // PKG def pattern constants size at INT width
                        // (Surelog).
                        if (!paramInitDef && prefix.size() >= 2 &&
                            prefix.compare(prefix.size() - 2, 2, "::") == 0 &&
                            ((UHDM::any*)e)->UhdmType() == UHDM::uhdmconstant)
                            ((UHDM::constant*)e)->VpiSize(32);
                        // A `'{default: L}` against a non-vector INTEGRAL
                        // target keeps its pattern op (patNoFoldTarget), and
                        // in every RESOLVED view its inner constant is sized
                        // at min(target width, literal width, 32).  The
                        // resolved views are the ELAB view of any container
                        // and the DEF view of a MATERIALIZED IMPORT copy; the
                        // DEF view of a module-LOCAL pattern param keeps the
                        // 64-bit unsized-literal default.  Measured on a
                        // 6-point probe that varied target and literal
                        // independently: int/1 -> 32, byte/1 -> 8,
                        // shortint/1 -> 16, longint/1 -> 32,
                        // longint/64'd1 -> 32 (so the cap is 32, not the
                        // literal), int/8'd1 -> 8 (so a NARROWER literal
                        // still wins).
                        else if (inParamInit &&
                                 (!paramInitDef || importedParamClone) &&
                                 ((UHDM::any*)e)->UhdmType() ==
                                     UHDM::uhdmconstant &&
                                 expr.type && [&] {
                                     auto& ct9 =
                                         expr.type->getCanonicalType();
                                     return ct9.isIntegral() &&
                                            ct9.kind !=
                                                SymbolKind::PackedArrayType &&
                                            ct9.kind !=
                                                SymbolKind::PackedStructType &&
                                            ct9.kind !=
                                                SymbolKind::PackedUnionType;
                                 }()) {
                            int32_t w9 = (int32_t)expr.type->getBitWidth();
                            int32_t cur9 = ((UHDM::expr*)e)->VpiSize();
                            if (w9 > 32)
                                w9 = 32;
                            if (cur9 > 0 && cur9 < w9)
                                w9 = cur9;
                            ((UHDM::constant*)e)->VpiSize(w9);
                        }
                        tp->Pattern((UHDM::expr*)e);
                    }
                    suppressConstParent = sup0;
                    forceConstParent = fcp0;
                    auto* sts = s.MakeString_typespec();
                    sts->VpiName("default");
                    sts->VpiParent(tp);
                    if (psyn) {
                        for (auto item : psyn->items) {
                            if (item->kind != syntax::SyntaxKind::AssignmentPatternItem)
                                continue;
                            auto& it2 = item->as<syntax::AssignmentPatternItemSyntax>();
                            if (rawText(it2.key->sourceRange()) == "default") {
                                setLoc(sts, it2.key->sourceRange());
                                break;
                            }
                        }
                    }
                    auto* rt = s.MakeRef_typespec();
                    // PKG-scoped pattern ts refs drop the trailing '::'.
                    std::string tsPfx9 = prefix;
                    if (tsPfx9.size() >= 2 &&
                        tsPfx9.compare(tsPfx9.size() - 2, 2, "::") == 0)
                        tsPfx9.resize(tsPfx9.size() - 2);
                    rt->VpiFullName(tsPfx9);
                    rt->VpiParent(tp);
                    rt->Actual_typespec(sts);
                    tp->Typespec(rt);
                    operands->push_back(tp);
                }
            }
            // Surelog lists tagged operands in SOURCE order — a default
            // setter can come FIRST ('{default: 1, 31:0}, assignment-pattern
            // j) while the setter groups above emit it last. Re-sort tagged
            // operands by source location.
            if (!reemitting && operands->size() > 1) {
                bool allTagged9 = true;
                for (auto* o9 : *operands)
                    if (o9->UhdmType() != UHDM::uhdmtagged_pattern ||
                        !((UHDM::tagged_pattern*)o9)->VpiLineNo()) {
                        allTagged9 = false;
                        break;
                    }
                if (allTagged9)
                    std::stable_sort(
                        operands->begin(), operands->end(),
                        [](UHDM::any* a, UHDM::any* b) {
                            auto* ta = (UHDM::tagged_pattern*)a;
                            auto* tb = (UHDM::tagged_pattern*)b;
                            return ta->VpiLineNo() != tb->VpiLineNo()
                                       ? ta->VpiLineNo() < tb->VpiLineNo()
                                       : ta->VpiColumnNo() < tb->VpiColumnNo();
                        });
            }
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::HierarchicalValue: {
            // Cross-instance references (u1.cnt) share the member-access
            // hier_path shape; elements come from the dotted source text.
            std::string raw = rawText(expr.sourceRange);
            // MACRO-SPLICED path (`assign o = `CORE0.wb_writeback_en;` with
            // `define CORE0 nyuzi.core_gen[0].core`): the head components live
            // in the macro-body buffer and the tail in the file, so there is
            // no contiguous slice and rawText() returns "". Surelog prints the
            // EXPANDED dotted text and lays each element out at the invocation
            // column plus its offset inside the expansion — which is exactly
            // where each expanded TOKEN already maps (macroInvLineCol). So
            // rebuild the display text from the name syntax and take every
            // element span from its own token instead of from `raw` offsets.
            std::vector<const syntax::NameSyntax*> nameParts9;
            if (expr.syntax && syntax::NameSyntax::isKind(expr.syntax->kind)) {
                std::function<void(const syntax::NameSyntax*)> fl0 =
                    [&](const syntax::NameSyntax* n) {
                        if (!n)
                            return;
                        if (n->kind == syntax::SyntaxKind::ScopedName) {
                            auto& sc = n->as<syntax::ScopedNameSyntax>();
                            fl0(sc.left);
                            fl0(sc.right);
                        }
                        else
                            nameParts9.push_back(n);
                    };
                fl0(&expr.syntax->as<syntax::NameSyntax>());
            }
            bool tokLoc9 = false;
            if (raw.find('.') == std::string::npos && nameParts9.size() >= 2) {
                raw.clear();
                for (size_t i0 = 0; i0 < nameParts9.size(); i0++) {
                    if (i0)
                        raw += '.';
                    appendTokenText(*nameParts9[i0], raw);
                }
                tokLoc9 = true;
            }
            // SYMBOLIC base index (STAGE[i-1].C): SL re-lexes with spaces
            // and emits a bit_select element whose index comes from the
            // selector SYNTAX, refs doubled through the hier display name.
            const syntax::ExpressionSyntax* baseSelSyn = nullptr;
            if (expr.syntax &&
                expr.syntax->kind == syntax::SyntaxKind::ScopedName) {
                auto& scn0 = expr.syntax->as<syntax::ScopedNameSyntax>();
                if (scn0.left->kind ==
                    syntax::SyntaxKind::IdentifierSelectName) {
                    auto& isn0 =
                        scn0.left->as<syntax::IdentifierSelectNameSyntax>();
                    if (isn0.selectors.size() == 1 &&
                        isn0.selectors[0]->selector &&
                        isn0.selectors[0]->selector->kind ==
                            syntax::SyntaxKind::BitSelect) {
                        const syntax::ExpressionSyntax* bsel0 =
                            isn0.selectors[0]
                                ->selector
                                ->as<syntax::BitSelectSyntax>()
                                .expr;
                        if (bsel0->kind !=
                            syntax::SyntaxKind::IntegerLiteralExpression)
                            baseSelSyn = bsel0;
                    }
                }
            }
            // A gen-LOCALPARAM identifier index (foo[PREV].temp) FOLDS in
            // the display name; the bit_select index is a use-site constant
            // claiming the localparam's param_assign as parent + a
            // gen-scope-named ts ref sharing the drain int ts (gen_test4).
            const slang::ast::ParameterSymbol* lpFoldPs9 = nullptr;
            UHDM::param_assign* lpFoldPa9 = nullptr;
            UHDM::constant* lpFoldC9 = nullptr;
            std::string lpFoldIdn9, lpFoldScope9;
            if (baseSelSyn &&
                baseSelSyn->kind == syntax::SyntaxKind::IdentifierName) {
                // A gen-scope PROCESS (always/assert in a gen block — prefix)
                // never folds an identifier base index: Surelog re-emits the
                // whole bit_select chain symbolically, so a localparam index
                // `blk3[y]` stays a ref_obj(y) exactly like a genvar `blk3[j]`.
                // Only cont_assign / declaration contexts fold (gen_test4/5).
                if (!inGenScopeProc) {
                    std::string idn9(
                        baseSelSyn->as<syntax::IdentifierNameSyntax>()
                            .identifier.valueText());
                    std::string scope9 = prefix;
                    while (true) {
                        auto it9 = genLpFoldByPath.find(scope9 + "." + idn9);
                        if (it9 != genLpFoldByPath.end()) {
                            lpFoldPs9 = it9->second.ps;
                            lpFoldPa9 = it9->second.pa;
                            lpFoldC9 = it9->second.c;
                            lpFoldIdn9 = idn9;
                            lpFoldScope9 = scope9;
                            break;
                        }
                        auto d9 = scope9.rfind('.');
                        if (d9 == std::string::npos)
                            break;
                        scope9.resize(d9);
                    }
                }
                // A BARE-IDENTIFIER base index that is NOT a folded gen
                // localparam (a genvar: netgen[i].out inside `router[i]`, or
                // ANY identifier index in a gen-scope process) is NOT doubled
                // through the hier display — Surelog emits a plain ref_obj
                // index carrying the enclosing SCOPE-prefixed name
                // (work@top.router[1].i), the same shape the 3+-component
                // genvar-indexed form uses. Only an index EXPRESSION
                // (STAGE[i-1].C) re-emits from syntax with doubled refs.
                baseSelSyn = nullptr;
            }
            auto spaceOps = [](const std::string& t) {
                std::string o;
                for (size_t i2 = 0; i2 < t.size(); i2++) {
                    char ch = t[i2];
                    if ((ch == '+' || ch == '-' || ch == '*' || ch == '/') &&
                        i2 > 0 && t[i2 - 1] != ' ' && t[i2 - 1] != '[') {
                        o += ' ';
                        o += ch;
                        if (i2 + 1 < t.size() && t[i2 + 1] != ' ')
                            o += ' ';
                    }
                    else
                        o += ch;
                }
                return o;
            };
            // ANY bracketed index containing an operator renders with
            // decompile-style spacing ([2-2] -> [2 - 2]) — Surelog.
            bool opIdx9 = false;
            {
                size_t lb9 = raw.find('[');
                while (lb9 != std::string::npos && !opIdx9) {
                    size_t rb9 = raw.find(']', lb9);
                    if (rb9 == std::string::npos)
                        break;
                    for (size_t k9 = lb9 + 1; k9 < rb9; k9++) {
                        char c9 = raw[k9];
                        if (c9 == '+' || c9 == '-' || c9 == '*' ||
                            c9 == '/') {
                            opIdx9 = true;
                            break;
                        }
                    }
                    lb9 = raw.find('[', rb9);
                }
            }
            if (baseSelSyn || opIdx9)
                raw = spaceOps(raw);
            std::vector<std::pair<std::string, size_t>> parts;
            {
                size_t pos = 0;
                while (pos <= raw.size()) {
                    size_t dot = raw.find('.', pos);
                    if (dot == std::string::npos)
                        dot = raw.size();
                    parts.emplace_back(raw.substr(pos, dot - pos), pos);
                    if (dot == raw.size())
                        break;
                    pos = dot + 1;
                }
            }
            // The DISPLAY text may be re-lexed with spaces around index
            // operators (STAGE[i-1] -> STAGE[i - 1]); every SPAN must still be
            // measured on the ORIGINAL source text, so keep a parallel split.
            std::vector<std::pair<std::string, size_t>> srcParts;
            {
                std::string rawSrc =
                    tokLoc9 ? raw : rawText(expr.sourceRange);
                size_t pos = 0;
                while (pos <= rawSrc.size()) {
                    size_t dot = rawSrc.find('.', pos);
                    if (dot == std::string::npos)
                        dot = rawSrc.size();
                    srcParts.emplace_back(rawSrc.substr(pos, dot - pos), pos);
                    if (dot == rawSrc.size())
                        break;
                    pos = dot + 1;
                }
                if (srcParts.size() != parts.size())
                    srcParts = parts;
            }
            if (parts.size() < 2) {
                noteUnsupported("hierarchical reference form");
                return nullptr;
            }
            // Collect the per-component select syntax by flattening the
            // dotted ScopedName chain. A DEEPER indexed component
            // (steps[step].outer[i].inner[CHUNK-1]) whose index is a
            // genvar/expression is a bit_select in Surelog, exactly like the
            // constant-indexed and single-component base forms; the index
            // comes from this selector syntax. Only used when the whole path's
            // BASE is itself indexed (the gen-scope-array hier family).
            std::vector<const syntax::ExpressionSyntax*> compSel(parts.size(),
                                                                 nullptr);
            bool baseIndexed9 =
                !parts.empty() &&
                parts[0].first.find('[') != std::string::npos;
            if (baseIndexed9 && expr.syntax) {
                std::vector<const syntax::NameSyntax*> nameParts;
                std::function<void(const syntax::NameSyntax*)> fl9 =
                    [&](const syntax::NameSyntax* n) {
                        if (!n)
                            return;
                        if (n->kind == syntax::SyntaxKind::ScopedName) {
                            auto& sc = n->as<syntax::ScopedNameSyntax>();
                            fl9(sc.left);
                            fl9(sc.right);
                        }
                        else
                            nameParts.push_back(n);
                    };
                if (syntax::NameSyntax::isKind(expr.syntax->kind))
                    fl9(&expr.syntax->as<syntax::NameSyntax>());
                if (nameParts.size() == parts.size()) {
                    for (size_t i9 = 0; i9 < nameParts.size(); i9++) {
                        if (nameParts[i9]->kind ==
                            syntax::SyntaxKind::IdentifierSelectName) {
                            auto& isn =
                                nameParts[i9]
                                    ->as<syntax::IdentifierSelectNameSyntax>();
                            if (isn.selectors.size() == 1 &&
                                isn.selectors[0]->selector &&
                                isn.selectors[0]->selector->kind ==
                                    syntax::SyntaxKind::BitSelect)
                                compSel[i9] =
                                    isn.selectors[0]
                                        ->selector
                                        ->as<syntax::BitSelectSyntax>()
                                        .expr;
                        }
                    }
                }
            }
            auto* hp = s.MakeHier_path();
            std::string disp9 = raw;
            if (lpFoldPs9) {
                auto p9 = disp9.find("[" + lpFoldIdn9 + "]");
                if (p9 != std::string::npos)
                    disp9 = disp9.substr(0, p9 + 1) +
                            std::string(lpFoldC9->VpiDecompile()) +
                            disp9.substr(p9 + 1 + lpFoldIdn9.size());
            }
            hp->VpiName(disp9);
            hp->VpiFullName(disp9);
            hp->VpiParent(parent);
            setLoc(hp, expr.sourceRange);
            auto* elems = s.MakeAnyVec();
            auto exprStart = expr.sourceRange.start();
            // Element spans normally come from `exprStart + <offset in raw>`,
            // valid only while the whole path is one contiguous slice. For a
            // macro-spliced path each component anchors at its OWN token.
            if (tokLoc9 && nameParts9.size() != parts.size())
                tokLoc9 = false;
            auto partStart = [&](size_t i9) {
                return tokLoc9 ? nameParts9[i9]->getFirstToken().location()
                               : exprStart + srcParts[i9].second;
            };
            std::string dottedSoFar;
            bool genVarBaseEmitted = false;
            for (size_t i = 0; i < parts.size(); i++) {
                auto& [pname, dispOff] = parts[i];
                (void)dispOff;
                // This component's anchor location, measured on the ORIGINAL
                // (unspaced) source text; every span below is an offset
                // INSIDE the component, taken from here.
                const auto cStart = partStart(i);
                dottedSoFar += (i == 0 ? pname : "." + pname);
                // A gen-block / array index element (gen_blk[0]) is a
                // bit_select: name-only ref + a bare UINT index constant.
                auto lb = pname.find('[');
                auto rb = pname.find(']');
                if (lpFoldPs9 && lb != std::string::npos &&
                    rb != std::string::npos && rb > lb + 1 &&
                    pname.substr(lb + 1, rb - lb - 1) == lpFoldIdn9) {
                    std::string base = pname.substr(0, lb);
                    auto* bs = s.MakeBit_select();
                    bs->VpiName(base);
                    bs->VpiParent(hp);
                    bs->VpiFullName(
                        base + "[" + std::string(lpFoldC9->VpiDecompile()) +
                        "]");
                    setLoc(bs, SourceRange(cStart, cStart + base.size()));
                    auto* c9 = s.MakeConstant();
                    c9->VpiDecompile(lpFoldC9->VpiDecompile());
                    c9->VpiSize(lpFoldC9->VpiSize());
                    c9->VpiValue(std::string(lpFoldC9->VpiValue()));
                    c9->VpiConstType(lpFoldC9->VpiConstType());
                    c9->VpiParent(lpFoldPa9);
                    size_t idOff9 = lb + 1;
                    setLoc(c9,
                           SourceRange(cStart + idOff9,
                                       cStart + idOff9 +
                                           lpFoldIdn9.size()));
                    auto* rt9 = s.MakeRef_typespec();
                    rt9->VpiFullName(lpFoldScope9);
                    rt9->VpiParent(c9);
                    c9->Typespec(rt9);
                    for (auto& gl9 : pendingGenLpTs)
                        if (gl9.ps == lpFoldPs9 && !gl9.hierIdxRt) {
                            gl9.hierIdxRt = rt9;
                            break;
                        }
                    bs->VpiIndex(c9);
                    elems->push_back(bs);
                    continue;
                }
                if (lb != std::string::npos && rb != std::string::npos && rb > lb + 1 &&
                    pname.find_first_not_of("0123456789", lb + 1) == rb) {
                    std::string base = pname.substr(0, lb);
                    std::string idx = pname.substr(lb + 1, rb - lb - 1);
                    auto* bs = s.MakeBit_select();
                    bs->VpiName(base);
                    bs->VpiParent(hp);
                    bs->VpiFullName(dottedSoFar);
                    setLoc(bs, SourceRange(cStart, cStart + base.size()));
                    auto* c = s.MakeConstant();
                    c->VpiDecompile(idx);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + idx);
                    c->VpiConstType(vpiUIntConst);
                    size_t digitOff = lb + 1;
                    setLoc(c, SourceRange(cStart + digitOff, cStart + digitOff + idx.size()));
                    bs->VpiIndex(c);
                    elems->push_back(bs);
                    continue;
                }
                // SYMBOLIC base index: bit_select named by the base,
                // fullname keeps the spaced index; the index emits from
                // syntax with refs doubled through the hier display.
                if (i == 0 && baseSelSyn && lb != std::string::npos &&
                    rb != std::string::npos && rb > lb + 1) {
                    std::string base = pname.substr(0, lb);
                    auto* bs = s.MakeBit_select();
                    bs->VpiName(base);
                    bs->VpiParent(hp);
                    bs->VpiFullName(pname);
                    setLoc(bs, SourceRange(cStart, cStart + base.size()));
                    std::string savedPfx = syntaxRefPrefix;
                    std::string savedSep = syntaxRefSep;
                    syntaxRefPrefix = prefix + "." + raw;
                    syntaxRefSep = ".";
                    if (auto* ix = emitSyntaxExpr(*baseSelSyn, hp))
                        bs->VpiIndex((UHDM::expr*)ix);
                    syntaxRefPrefix = savedPfx;
                    syntaxRefSep = savedSep;
                    elems->push_back(bs);
                    continue;
                }
                // A GENVAR/variable-indexed BASE component (man[i].req.lck in a
                // genvar for): bit_select(base), raw component fullname, with a
                // ref_obj index child that PARENTS AT THE HIER_PATH and carries
                // the scope-prefixed genvar fullname (Surelog). Distinct from
                // the constant-index and symbolic-doubled-index forms above.
                // The i==0 base uses its raw component fullname; a DEEPER
                // (i>0) genvar/expression-indexed component of a base-indexed
                // gen-scope-array path carries the cumulative dotted fullname
                // (steps[step].outer[i]) — both are bit_selects.
                // In a gen-scope PROCESS every indexed component is a
                // bit_select regardless of whether the path BASE is indexed
                // (`blk1.blk2[i].b` in prefix: `blk2[i]`/`blk3[j]` are middle
                // components under a bare `blk1` base) — Surelog re-emits the
                // full symbolic chain there.
                if ((i == 0 || baseIndexed9 || inGenScopeProc) &&
                    lb != std::string::npos &&
                    rb != std::string::npos && rb > lb + 1) {
                    std::string idx = pname.substr(lb + 1, rb - lb - 1);
                    auto isIdentStart = [](char c) {
                        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
                               c == '_';
                    };
                    bool simpleId = !idx.empty() && isIdentStart(idx[0]);
                    for (char ch : idx)
                        if (!(isIdentStart(ch) || (ch >= '0' && ch <= '9')))
                            simpleId = false;
                    if (simpleId) {
                        std::string base = pname.substr(0, lb);
                        auto* bs = s.MakeBit_select();
                        bs->VpiName(base);
                        bs->VpiParent(hp);
                        bs->VpiFullName(i == 0 ? pname : dottedSoFar);
                        setLoc(bs, SourceRange(cStart, cStart + base.size()));
                        auto* ir = s.MakeRef_obj();
                        ir->VpiName(idx);
                        ir->VpiFullName(prefix + "." + idx);
                        ir->VpiParent(hp);
                        // An ENUM-CONSTANT selector
                        // (peripheral_io_bus[IO_ONES].write_en) binds its
                        // enum_const as vpiActual — Surelog resolves the
                        // selector like any other name reference, and
                        // uhdm-cmp reads the link. Deferred: the enum's
                        // typespec (and so its enum_const) is minted after
                        // the def view that first references it
                        // (InterfArrayBind).
                        if (currentScope)
                            if (auto* isym9 = currentScope->find(idx))
                                if (isym9->kind == SymbolKind::EnumValue)
                                    pendingEnumIdxRefs.emplace_back(ir, isym9);
                        size_t idOff = lb + 1;
                        setLoc(ir, SourceRange(cStart + idOff,
                                               cStart + idOff + idx.size()));
                        bs->VpiIndex(ir);
                        elems->push_back(bs);
                        genVarBaseEmitted = true;
                        continue;
                    }
                    // Deeper EXPRESSION index (inner[CHUNK - 1]): bit_select
                    // whose index emits from the selector syntax, refs doubled
                    // through the hier display (prefix + raw), like the base
                    // symbolic-index form above.
                    if (baseIndexed9 && i > 0 && compSel[i]) {
                        std::string base = pname.substr(0, lb);
                        auto* bs = s.MakeBit_select();
                        bs->VpiName(base);
                        bs->VpiParent(hp);
                        bs->VpiFullName(dottedSoFar);
                        setLoc(bs, SourceRange(cStart, cStart + base.size()));
                        std::string savedPfx = syntaxRefPrefix;
                        std::string savedSep = syntaxRefSep;
                        syntaxRefPrefix = prefix + "." + raw;
                        syntaxRefSep = ".";
                        if (auto* ix = emitSyntaxExpr(*compSel[i], hp))
                            bs->VpiIndex((UHDM::expr*)ix);
                        syntaxRefPrefix = savedPfx;
                        syntaxRefSep = savedSep;
                        elems->push_back(bs);
                        genVarBaseEmitted = true;
                        continue;
                    }
                }
                auto* r = s.MakeRef_obj();
                r->VpiName(pname);
                (void)r->VpiFullName();
                // Only the last element of an rvalue path gets a fullname.
                if (!inLhs && i + 1 == parts.size())
                    r->VpiFullName(prefix + "." + pname);
                r->VpiParent(hp);
                // A DOTTED hier_path leaf in a gen-scope process stays
                // UNBOUND — Surelog never attaches the target var to the
                // final ref of a `blk1.a` / `top.blk1.a` path (prefix); only
                // a PLAIN self-name ref (the NamedValue path above) binds its
                // integer_var. (for_decl_shadow's `gen.x` refs live inside a
                // procedural for, so this leaf-bind never applied to them.)
                // Lvalue paths anchor the base ref at the SECOND element.
                size_t locIdx = (inLhs && i == 0 && parts.size() > 1) ? 1 : i;
                auto& lname = srcParts[locIdx].first;
                auto lStart = partStart(locIdx);
                setLoc(r, SourceRange(lStart, lStart + lname.size()));
                elems->push_back(r);
            }
            // Module-CA LHS hier into a GEN scope: the hier_path spans only
            // the BASE elem and the LAST elem carries the raw dotted
            // fullname (hierdefparam `assign bar[0].a = ...`).
            {
                bool genTgt9 = false;
                auto& hsym9 =
                    expr.as<HierarchicalValueExpression>().symbol;
                for (auto sc9 = hsym9.getParentScope(); sc9;
                     sc9 = sc9->asSymbol().getParentScope()) {
                    if (sc9->asSymbol().kind == SymbolKind::GenerateBlock) {
                        genTgt9 = true;
                        break;
                    }
                    if (sc9->asSymbol().kind == SymbolKind::InstanceBody)
                        break;
                }
                // Also applies through an INDEXED iface-array base
                // (assign m[0].req = ... — iface_array_struct_whole).
                bool idxBase9 =
                    !parts.empty() &&
                    parts[0].first.find('[') != std::string::npos;
                // An RVALUE gen-scope-array hier READ (steps[step].outer[i]
                // .inner[CHUNK-1].temp / steps[WIDTH].outer[0].val) spans the
                // WHOLE path and gives its leaf the elab prefix fullname — so
                // the raw-leaf/base-endln override is LHS-only. (For the LHS
                // gen-target/iface-array drive man[i].req.lck it still fires.)
                (void)genVarBaseEmitted;
                // Only a CONT-ASSIGN lvalue freezes the raw dotted path onto
                // its leaf; a PROCEDURAL write (gen.x = 0 inside an initial)
                // leaves every element name-only — Surelog computes the ref
                // name lazily and the hier_path parent contributes nothing.
                bool caLhs9 =
                    parent && parent->UhdmType() == UHDM::uhdmcont_assign;
                if (inLhs && caLhs9 && (genTgt9 || idxBase9) &&
                    !elems->empty()) {
                    auto* fe9 = (UHDM::expr*)elems->front();
                    hp->VpiEndLineNo(fe9->VpiEndLineNo());
                    hp->VpiEndColumnNo(fe9->VpiEndColumnNo());
                    auto* le9 = elems->back();
                    if (le9->UhdmType() == UHDM::uhdmref_obj)
                        ((UHDM::ref_obj*)le9)->VpiFullName(raw);
                }

            }
            hp->Path_elems(elems);
            return hp;
        }
        case ExpressionKind::Inside: {
            // a inside {A, B, ...}: an operation (vpiInsideOp) whose operands
            // are the LHS followed by the flattened set members.
            auto& ie = expr.as<InsideExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiInsideOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* l = emitExpr(ie.left(), op, prefix, netMap))
                operands->push_back(l);
            for (auto* rle : ie.rangeList())
                if (auto* e = emitExpr(*rle, op, prefix, netMap))
                    operands->push_back(e);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::ValueRange: {
            // A range set member ([4:7]): operation(vpiListOp) of the two
            // bounds (the enclosing inside-op comes from the item/expr level).
            auto& vr = expr.as<ValueRangeExpression>();
            auto* ol = s.MakeOperation();
            ol->VpiOpType(vpiListOp);
            ol->VpiParent(parent);
            setLoc(ol, expr.sourceRange);
            auto* bounds = s.MakeAnyVec();
            bool fcp2 = forceConstParent;
            // Case-inside members leave their bounds unparented (caller sets
            // suppressConstParent); a standalone `inside {[a:b]}` forces them.
            if (!suppressConstParent)
                forceConstParent = true;
            if (auto* l = emitExpr(vr.left(), ol, prefix, netMap))
                bounds->push_back(l);
            if (auto* r = emitExpr(vr.right(), ol, prefix, netMap))
                bounds->push_back(r);
            forceConstParent = fcp2;
            ol->Operands(bounds);
            return ol;
        }
        case ExpressionKind::TaggedUnion: {
            // `un = tagged v1 (85)`: a tagged_pattern named after the union
            // MEMBER, located at the `tagged` KEYWORD alone (not the whole
            // expression), carrying the value expression as vpiPattern.  The
            // pattern's literal stays UNPARENTED — Surelog compiles it through
            // its constant path, which never back-links (TaggedPattern).
            auto& tu = expr.as<TaggedUnionExpression>();
            auto* tp = s.MakeTagged_pattern();
            tp->VpiName(std::string(tu.member.name));
            tp->VpiParent(parent);
            SourceRange tr9 = expr.sourceRange;
            if (expr.syntax &&
                expr.syntax->kind == syntax::SyntaxKind::TaggedUnionExpression)
                tr9 = expr.syntax->as<syntax::TaggedUnionExpressionSyntax>()
                          .tagged.range();
            setLoc(tp, tr9);
            if (tu.valueExpr) {
                bool fcp9 = forceConstParent;
                forceConstParent = false;
                bool scp9 = suppressConstParent;
                suppressConstParent = true;
                if (auto* pv = emitExpr(*tu.valueExpr, tp, prefix, netMap))
                    tp->Pattern(pv);
                suppressConstParent = scp9;
                forceConstParent = fcp9;
            }
            return tp;
        }
        case ExpressionKind::EmptyArgument:
            // An omitted optional call argument ($readmemh(file, mem, ,)):
            // dropped (golden lists only the present args).
            return nullptr;
        case ExpressionKind::Streaming: {
            // Streaming concatenation: a SLICED stream ({ << 8 {x} }) folds to
            // a plain CONCAT over the operands (full span); an unsliced one
            // ({<<{x}}) keeps a stream operation (vpiStreamRLOp for <<),
            // anchored at the first operand's span.
            auto& sc2 = expr.as<StreamingConcatenationExpression>();
            bool sliced = sc2.getSliceSize() > 1;
            // The inner {..} concat: located at the FULL streaming span
            // (Surelog swaps the spans).
            auto* cc = s.MakeOperation();
            cc->VpiOpType(vpiConcatOp);
            setLoc(cc, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            for (auto& strm : sc2.streams())
                if (auto* e = emitExpr(*strm.operand, cc, prefix, netMap))
                    operands->push_back(e);
            cc->Operands(operands);
            // A stream operation (vpiStreamRLOp) wrapping the concat, located
            // at the {..} operand braces; a sliced stream ({ << 8 {x} }) adds
            // the slice-size constant as the FIRST operand.
            auto* op = s.MakeOperation();
            // << (right-to-left, sliceSize > 0) -> vpiStreamRLOp; >> -> LR.
            op->VpiOpType(sc2.getSliceSize() > 0 ? vpiStreamRLOp : vpiStreamLROp);
            op->VpiParent(parent);
            if (!sc2.streams().empty()) {
                auto fr = sc2.streams().front().operand->sourceRange;
                auto lr = sc2.streams().back().operand->sourceRange;
                setLoc(op, SourceRange(fr.start() - 1, lr.end() + 1));
            }
            else
                setLoc(op, expr.sourceRange);
            auto* outer = s.MakeAnyVec();
            // An explicit slice size (either direction) emits as a LOCATED,
            // UNPARENTED first operand (token parsed from the source text —
            // the streaming often reaches here with null syntax).
            {
                std::string raw = rawText(expr.sourceRange);
                auto p1 = raw.find("<<");
                if (p1 == std::string::npos)
                    p1 = raw.find(">>");
                if (p1 != std::string::npos) {
                    size_t q = p1 + 2;
                    while (q < raw.size() && isspace((unsigned char)raw[q]))
                        q++;
                    size_t st2 = q;
                    while (q < raw.size() && !isspace((unsigned char)raw[q]) &&
                           raw[q] != '{')
                        q++;
                    if (q > st2) {
                        std::string digits = raw.substr(st2, q - st2);
                        auto* c = s.MakeConstant();
                        c->VpiDecompile(digits);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        // The elab re-emit parents the slice const at the op.
                        if (reemitting)
                            c->VpiParent(op);
                        setLoc(c, SourceRange(expr.sourceRange.start() + st2,
                                              expr.sourceRange.start() + q));
                        outer->push_back(c);
                    }
                }
            }
            cc->VpiParent(op);
            outer->push_back(cc);
            op->Operands(outer);
            return op;
        }
        case ExpressionKind::ArbitrarySymbol: {
            std::string dotted = rawText(expr.sourceRange);
            // A bare interface reference (no dot) is a plain ref_obj.
            if (dotted.find('.') == std::string::npos) {
                auto* r = s.MakeRef_obj();
                r->VpiName(dotted);
                r->VpiParent(parent);
                setLoc(r, expr.sourceRange);
                // A SCOPE name handed to a system call ($dumpvars(0, tb_UART))
                // is not a value, so Surelog's netlist elaboration cannot bind
                // it and leaks an implicit module WIRE at the reference span,
                // exactly as it does for an unbindable `disable` label
                // (StmtEmit) or a property formal (emitPropFormalRef). The ref
                // binds to that net. AssertTempError / AssertDelayError.
                auto& sy9 = *expr.as<ArbitrarySymbolExpression>().symbol;
                if (implicitNetModule && parent &&
                    (parent->UhdmType() == UHDM::uhdmsys_func_call ||
                     parent->UhdmType() == UHDM::uhdmsys_task_call)) {
                    auto& inet = implicitNetMap[&sy9];
                    if (!inet) {
                        inet = s.MakeLogic_net();
                        inet->VpiName(dotted);
                        inet->VpiFullName(implicitNetPrefix + "." + dotted);
                        inet->VpiParent(implicitNetModule);
                        inet->VpiNetType(1);
                        setLoc(inet, expr.sourceRange);
                        auto* nets9 = implicitNetModule->Nets();
                        if (!nets9) {
                            nets9 = s.MakeNetVec();
                            implicitNetModule->Nets(nets9);
                        }
                        nets9->push_back(inet);
                    }
                    r->Actual_group(inet);
                }
                return r;
            }
            // Interface-port member access (sub.sig): a hier_path with one
            // ref_obj element per dotted component.
            return buildDottedHierPath(expr, dotted, parent, prefix);
        }
        // § newArray11 — `d = new[n];` / `d = new[n](src);` is the SAME
        // method_func_call named "new" the class form uses, but LOCATED (over
        // the whole `new[...]` text) and UNPARENTED, with the size expression
        // as the first vpiArgument and the copy source, when written, as the
        // second (a name-only ref_obj).  There was no arm, so the assignment
        // came out with no Rhs at all — 22 UVM source sites, including the
        // `uvm_field_array_*` macro bodies that expand once per field.
        // Repro t3 n_array / n_array_copy.
        case ExpressionKind::NewArray: {
            auto& nae = expr.as<NewArrayExpression>();
            auto* mfc = s.MakeMethod_func_call();
            mfc->VpiName("new");
            setLoc(mfc, expr.sourceRange);
            auto* nargs = s.MakeAnyVec();
            {
                bool fs9 = forceConstParent;
                if (isLiteralExpr(nae.sizeExpr()))
                    forceConstParent = true;
                if (auto* a9 = emitExpr(nae.sizeExpr(), mfc, prefix, netMap))
                    nargs->push_back(a9);
                forceConstParent = fs9;
            }
            if (auto* ie9 = nae.initExpr())
                if (auto* a9 = emitExpr(*ie9, mfc, prefix, netMap))
                    nargs->push_back(a9);
            if (!nargs->empty())
                mfc->Tf_call_args(nargs);
            stripRefFullNames11(mfc);
            return mfc;
        }
        // § copyClassIsNewCall4 — the SHALLOW-COPY constructor `pkt = new gpkt`
        // is a method_func_call named "new" carrying the copied handle as its
        // ONE argument, shaped exactly like the `new()` and `new[n]` arms
        // either side of it.  We had NO arm for it at all, so emitExpr returned
        // null and the assignment lost its whole Rhs; golden (SVSwitch
        // Driver.sv:38) has:
        //
        //   method_func_call: (new), id:1447                 <- LOC-LESS
        //   |vpiParent:  assignment 38:6-38:20
        //   |vpiArgument: ref_obj (work@Driver::start::gpkt) 38:16-38:20
        //   |vpiName:new
        //
        // LOC-LESS is measured, not assumed: the dump prints no line/endln on
        // golden's node, and it is the same convention as the `new()` arm (the
        // `new[n]` arm above DOES setLoc — the difference is that NewArray's
        // golden carries a span, which is why the two arms differ here).  The
        // argument keeps its scope-prefixed fullname (golden prints
        // vpiFullName), so `stripRefFullNames11` — which the NewArray arm calls
        // — is deliberately NOT called here.
        case ExpressionKind::CopyClass: {
            auto& cce = expr.as<CopyClassExpression>();
            auto* mfc = s.MakeMethod_func_call();
            mfc->VpiName("new");
            mfc->VpiParent(parent);
            auto* nargs = s.MakeAnyVec();
            if (auto* a9 = emitExpr(cce.sourceExpr(), mfc, prefix, netMap))
                nargs->push_back(a9);
            if (!nargs->empty())
                mfc->Tf_call_args(nargs);
            return mfc;
        }
        case ExpressionKind::NewClass: {
            // bar = new(): a loc-less method_func_call named "new" — or
            // "super.new" for a base-constructor chain-up. Constructor
            // ARGUMENTS ride it as vpiArgument and bind normally (ApbSlave
            // `super.new(name)` -> io_decl, `new(name)` -> the module net).
            auto& nce = expr.as<NewClassExpression>();
            auto* mfc = s.MakeMethod_func_call();
            mfc->VpiName(nce.isSuperClass ? "super.new" : "new");
            mfc->VpiParent(parent);
            if (auto* cc9 = nce.constructorCall();
                cc9 && cc9->kind == ExpressionKind::Call) {
                auto* nargs9 = s.MakeAnyVec();
                // § superNewFormalBinds28 — a `super.new` argument list is a
                // binding window for the constructor's own FORMALS only.
                SuperNewArg28 sna28(superNewArgDepth28, nce.isSuperClass);
                // § writtenCallArgs16, the constructor arm.  A `new(...)`
                // carries its actual list on the NewClassExpression's own
                // syntax, not on an InvocationExpressionSyntax, so the shared
                // helper cannot read it: count here.  `uvm_domain::new(name)`
                // against `uvm_phase::new(name, phase_type=UVM_PHASE_SCHEDULE,
                // parent=null)` is the residual `Args/SIZE 2 vs 3` block.
                size_t nw9 = cc9->as<CallExpression>().arguments().size();
                if (auto* nsy9 =
                        nce.syntax
                            ? nce.syntax->as_if<syntax::NewClassExpressionSyntax>()
                            : nullptr)
                    nw9 = nsy9->argList ? nsy9->argList->parameters.size() : 0;
                size_t ai9 = 0;
                for (auto arg9 : cc9->as<CallExpression>().arguments()) {
                    if (ai9++ >= nw9)
                        break;
                    bool fs9 = forceConstParent;
                    if (isLiteralExpr(*arg9))
                        forceConstParent = true;
                    if (auto* a9 = emitExpr(*arg9, mfc, prefix, netMap))
                        nargs9->push_back(a9);
                    forceConstParent = fs9;
                }
                if (!nargs9->empty())
                    mfc->Tf_call_args(nargs9);
            }
            return mfc;
        }
        case ExpressionKind::AssertionInstance: {
            // A named-property instantiation (down_n(8'd3)): property_inst
            // with constant args parented at an artifact func_call.
            auto& aie = expr.as<AssertionInstanceExpression>();
            // Spans the whole instantiation, shrunk by any whitespace Surelog
            // compacts out of spaced based literals (8'd 3 -> 8'd3).
            SourceRange pir =
                expr.syntax ? expr.syntax->sourceRange() : expr.sourceRange;
            pir = SourceRange(pir.start(),
                              pir.end() - basedLiteralSpaceCount(rawText(pir)));
            // A BARE named-property reference (`assert property (p_reset);` —
            // the name with NO argument list at all) is not instantiated by
            // Surelog: the property expression stays a plain ref_obj naming
            // the property and bound (vpiActual) to the module's own
            // property_decl (PropBinding). Only a PARENTHESISED instantiation
            // -- `p(a,b)` or even the empty `p()` (mriscv_bind_sva
            // p_S2QED_SAME_STATE()) -- becomes a property_inst.
            if (auto pdit = propertyDeclMap.find(&aie.symbol);
                pdit != propertyDeclMap.end() &&
                rawText(pir).find('(') == std::string::npos) {
                auto* pr = s.MakeRef_obj();
                pr->VpiName(aie.symbol.name);
                pr->VpiFullName(joinRef(prefix, std::string(aie.symbol.name)));
                pr->VpiParent(parent);
                pr->Actual_group(pdit->second);
                setLoc(pr, pir);
                return pr;
            }
            // ---- the ACTUAL list, read from the call SYNTAX --------------
            //
            // Surelog lists only the actuals the call SUPPLIES: a formal left
            // to its default (`clk = $inferred_clock`) contributes no
            // vpiArgument at all, where slang's argument map holds an entry
            // for every formal.  The syntax also carries the two things the
            // bound form loses -- which positions were left EMPTY, and which
            // actual is an EVENT expression.
            const syntax::ArgumentListSyntax* argList9 = nullptr;
            if (expr.syntax &&
                expr.syntax->kind == syntax::SyntaxKind::InvocationExpression)
                argList9 =
                    expr.syntax->as<syntax::InvocationExpressionSyntax>().arguments;
            struct Act9 {
                const syntax::PropertyExprSyntax* syn;
                SourceRange range;
            };
            std::vector<Act9> acts9;
            bool namedArgs9 = false;
            if (argList9)
                for (auto* a9 : argList9->parameters) {
                    if (a9->kind == syntax::SyntaxKind::EmptyArgument)
                        acts9.push_back({nullptr, a9->sourceRange()});
                    else if (a9->kind == syntax::SyntaxKind::OrderedArgument) {
                        const syntax::PropertyExprSyntax* oe9 =
                            &*a9->as<syntax::OrderedArgumentSyntax>().expr;
                        acts9.push_back({oe9, oe9->sourceRange()});
                    }
                    else
                        namedArgs9 = true;
                }
            std::span<const AssertionPortSymbol* const> formals9;
            if (aie.symbol.kind == SymbolKind::Property)
                formals9 = aie.symbol.as<PropertySymbol>().ports;
            else if (aie.symbol.kind == SymbolKind::Sequence)
                formals9 = aie.symbol.as<SequenceSymbol>().ports;
            auto actualFor9 =
                [&](size_t i) -> const AssertionInstanceExpression::ActualArg* {
                if (i >= formals9.size())
                    return nullptr;
                for (auto& t9 : aie.arguments)
                    if (std::get<0>(t9) == formals9[i])
                        return &std::get<1>(t9);
                return nullptr;
            };
            auto emitActual9 = [&](size_t i,
                                   UHDM::BaseClass* par) -> UHDM::any* {
                auto* av9 = actualFor9(i);
                if (!av9)
                    return nullptr;
                bool ss9 = suppressConstParent, fs9 = forceConstParent;
                suppressConstParent = true;
                forceConstParent = false;
                UHDM::any* out9 = nullptr;
                if (auto* pe9 = std::get_if<const Expression*>(av9))
                    out9 = emitExpr(**pe9, par, prefix, netMap);
                else if (auto* tc9 = std::get_if<const TimingControl*>(av9))
                    out9 = emitEventExpr(**tc9, par, prefix, netMap);
                else if (auto* ax9 = std::get_if<const AssertionExpr*>(av9)) {
                    // An EVENT-expression actual (`posedge clk1`) binds as a
                    // ClockingAssertionExpr whose controlled expression is
                    // deliberately invalid (slang:
                    // ClockingAssertionExpr::fromSyntax(SignalEventExpression)):
                    // it IS just the clocking event, so emit that.
                    if ((*ax9)->kind == AssertionExprKind::Clocking &&
                        (*ax9)->as<ClockingAssertionExpr>().expr.bad())
                        out9 = emitEventExpr(
                            (*ax9)->as<ClockingAssertionExpr>().clocking, par,
                            prefix, netMap);
                    else
                        out9 = emitAssertionExpr(**ax9, par, prefix, netMap);
                }
                suppressConstParent = ss9;
                forceConstParent = fs9;
                return out9;
            };
            // An actual that is an EVENT expression (`posedge clk1`) cannot be
            // parsed by `property_list_of_arguments`, so Surelog's parser falls
            // through to the SEQUENCE rule: the instantiation becomes a
            // sequence_inst, and -- because `event_expression` itself admits
            // `a , b` -- each run of consecutive actuals is swallowed by ONE
            // greedy event_expression and comes out as a LEFT-NESTED chain of
            // vpiListOp binary operations.  An empty positional actual is not
            // an event_expression, so it breaks the run and contributes a
            // 64-bit integer constant 0 of its own.
            auto edgeArg9 =
                [](const syntax::PropertyExprSyntax* p9) -> bool {
                if (!p9)
                    return false;
                const syntax::SyntaxNode* n9 = p9;
                if (n9->kind == syntax::SyntaxKind::SimplePropertyExpr)
                    n9 = n9->as<syntax::SimplePropertyExprSyntax>().expr;
                return n9 &&
                       n9->kind == syntax::SyntaxKind::SignalEventExpression &&
                       n9->as<syntax::SignalEventExpressionSyntax>()
                           .edge.valid();
            };
            bool seqRoute9 = false;
            if (argList9 && !namedArgs9)
                for (auto& a9 : acts9)
                    if (edgeArg9(a9.syn))
                        seqRoute9 = true;

            if (seqRoute9) {
                auto* si = s.MakeSequence_inst();
                si->VpiName(aie.symbol.name);
                si->VpiParent(parent);
                setLoc(si, pir);
                // Every ref under a sequence_inst is scoped through the
                // ASSERT LABEL (work@m.a2.p_triggers.a), not the bare
                // property name the property_inst arm uses.
                std::string sprefix9 =
                    joinRef(prefix, std::string(aie.symbol.name));
                std::function<void(UHDM::any*)> rename9 = [&](UHDM::any* o9) {
                    if (!o9)
                        return;
                    if (o9->UhdmType() == UHDM::uhdmref_obj) {
                        auto* r9 = (UHDM::ref_obj*)o9;
                        r9->VpiFullName(sprefix9 + "." +
                                        std::string(r9->VpiName()));
                        return;
                    }
                    if (o9->UhdmType() == UHDM::uhdmoperation)
                        if (auto* ops9 = ((UHDM::operation*)o9)->Operands())
                            for (auto* c9 : *ops9)
                                rename9(c9);
                };
                auto* args9 = s.MakeAnyVec();
                size_t i9 = 0;
                while (i9 < acts9.size()) {
                    if (!acts9[i9].syn) {
                        auto* c9 = s.MakeConstant();
                        c9->VpiDecompile("0");
                        c9->VpiSize(64);
                        c9->VpiValue("INT:0");
                        c9->VpiConstType(vpiIntConst);
                        setLoc(c9, acts9[i9].range);
                        args9->push_back(c9);
                        i9++;
                        continue;
                    }
                    size_t lo9 = i9;
                    while (i9 < acts9.size() && acts9[i9].syn)
                        i9++;
                    // A literal actual stays UNPARENTED inside the fold, like
                    // every other Surelog constant operand.
                    auto reparent9 = [](UHDM::any* o9, UHDM::BaseClass* p9) {
                        if (o9 && o9->UhdmType() != UHDM::uhdmconstant)
                            o9->VpiParent(p9);
                    };
                    UHDM::any* acc9 = emitActual9(lo9, si);
                    rename9(acc9);
                    for (size_t j9 = lo9 + 1; j9 < i9; j9++) {
                        auto* op9 = s.MakeOperation();
                        op9->VpiOpType(vpiListOp);
                        op9->VpiParent(si);
                        setLoc(op9, SourceRange(acts9[lo9].range.start(),
                                                acts9[j9].range.end()));
                        auto* ops9 = s.MakeAnyVec();
                        if (acc9) {
                            reparent9(acc9, op9);
                            ops9->push_back(acc9);
                        }
                        if (auto* e9 = emitActual9(j9, op9)) {
                            reparent9(e9, op9);
                            rename9(e9);
                            ops9->push_back(e9);
                        }
                        op9->Operands(ops9);
                        acc9 = op9;
                    }
                    if (acc9) {
                        reparent9(acc9, si);
                        args9->push_back(acc9);
                    }
                }
                // vpiArgument on a sequence_inst IS this group vector.
                if (!args9->empty())
                    si->Named_event_sequence_expr_groups(args9);
                return si;
            }

            auto* pi = s.MakeProperty_inst();
            pi->VpiName(aie.symbol.name);
            setLoc(pi, pir);
            auto* fcArt = s.MakeFunc_call();
            fcArt->VpiName(aie.symbol.name);
            fcArt->VpiParent(parent);
            setLoc(fcArt, pir);
            auto* args = s.MakeAnyVec();
            auto pushActual9 = [&](UHDM::any* a) {
                if (!a)
                    return;
                a->VpiParent(fcArt);
                // A REF actual parents at the property_inst and is
                // scoped by the PROPERTY NAME (p_X.cpu0_rs1i), not
                // the assertion prefix (Surelog — mriscv assume
                // property(p_S2QED_MAPPED_VAL(cpu0_rs1i,...))).
                if (a->UhdmType() == UHDM::uhdmref_obj) {
                    auto* ra = (UHDM::ref_obj*)a;
                    ra->VpiParent(pi);
                    ra->VpiFullName(std::string(aie.symbol.name) + "." +
                                    std::string(ra->VpiName()));
                }
                args->push_back(a);
            };
            if (argList9 && !namedArgs9) {
                for (size_t i9 = 0; i9 < acts9.size(); i9++)
                    if (acts9[i9].syn)
                        pushActual9(emitActual9(i9, fcArt));
            }
            else {
                for (auto& [port, actual] : aie.arguments) {
                    (void)port;
                    if (auto* pe = std::get_if<const Expression*>(&actual)) {
                        bool ss = suppressConstParent;
                        bool fs = forceConstParent;
                        suppressConstParent = true;
                        forceConstParent = false;
                        pushActual9(emitExpr(**pe, fcArt, prefix, netMap));
                        suppressConstParent = ss;
                        forceConstParent = fs;
                    }
                }
            }
            if (!args->empty()) {
                pi->VpiArguments(args);
                fcArt->Tf_call_args(args);
            }
            return pi;
        }
        case ExpressionKind::ClockingEvent: {
            // A clocking-event argument ($fell(a, @(posedge clk))): the edge
            // operation over the clock signal.
            auto& ce = expr.as<ClockingEventExpression>();
            return emitEventExpr(ce.timingControl, parent, prefix, netMap);
        }
        case ExpressionKind::Invalid: {
            // slang wraps some valid sub-expressions in Invalid nodes (e.g.
            // size-cast operand shells); unwrap when a child exists.
            auto& iv2 = expr.as<InvalidExpression>();
            bool stmtCtx14 = callStmtContext;
            callStmtContext = false;
            // A let-decl FORMAL binds Invalid the same way a property formal
            // does, but Surelog leaks NO module net for it: the let_decl body
            // is compiled with late binding off, so the formal stays a bare
            // ref_obj (`work@m.sum2.x`, no vpiActual).
            if (letDeclScope) {
                std::string nm;
                SourceRange nr = expr.sourceRange;
                if (nr.start() != SourceLocation::NoLocation && nr.start().valid())
                    nm = rawText(nr);
                if (nm.empty() && expr.syntax &&
                    expr.syntax->kind == syntax::SyntaxKind::IdentifierName) {
                    nm = std::string(expr.syntax->as<syntax::IdentifierNameSyntax>()
                                         .identifier.valueText());
                    nr = expr.syntax->sourceRange();
                }
                if (!nm.empty()) {
                    auto* fsym = letDeclScope->find(nm);
                    if (fsym && fsym->kind == SymbolKind::AssertionPort) {
                        auto* ref = s.MakeRef_obj();
                        ref->VpiName(nm);
                        ref->VpiFullName(joinRef(prefix, nm));
                        ref->VpiParent(parent);
                        setLoc(ref, nr);
                        return ref;
                    }
                }
            }
            // Property-decl FORMAL refs bind Invalid (untyped formals): a
            // property-scoped ref bound to an implicit module wire minted at
            // the first use.
            if (propDeclScope) {
                std::string nm;
                SourceRange nr = expr.sourceRange;
                if (nr.start() != SourceLocation::NoLocation)
                    nm = rawText(nr);
                if (nm.empty() && expr.syntax &&
                    expr.syntax->kind == syntax::SyntaxKind::IdentifierName) {
                    nm = std::string(expr.syntax->as<syntax::IdentifierNameSyntax>()
                                         .identifier.valueText());
                    nr = expr.syntax->sourceRange();
                }
                if (!nm.empty())
                    if (auto* ref = emitPropFormalRef(nm, nr, parent, prefix))
                        return ref;
                // A FORMAL-indexed select (cpu0_reg[num], cpu1_reg[
                // reg_map(num)]) types as Invalid too: a bit_select named by
                // the base, SPANNING THE INDEX, its index the formal ref or
                // a func_call whose formal-ref args scope through the
                // bit_select name (Surelog — mriscv s2qed
                // p_S2QED_SAME_REG_N_STATE).
                {
                    const syntax::ExpressionSyntax* idxSyn = nullptr;
                    std::string baseNm;
                    if (expr.syntax &&
                        expr.syntax->kind ==
                            syntax::SyntaxKind::ElementSelectExpression) {
                        auto& ese = expr.syntax
                                        ->as<syntax::ElementSelectExpressionSyntax>();
                        if (ese.select && ese.select->selector &&
                            ese.select->selector->kind ==
                                syntax::SyntaxKind::BitSelect)
                            idxSyn = ese.select->selector
                                         ->as<syntax::BitSelectSyntax>()
                                         .expr;
                        if (ese.left->kind == syntax::SyntaxKind::IdentifierName)
                            baseNm = std::string(
                                ese.left->as<syntax::IdentifierNameSyntax>()
                                    .identifier.valueText());
                    }
                    else if (expr.syntax &&
                             expr.syntax->kind ==
                                 syntax::SyntaxKind::IdentifierSelectName) {
                        auto& isn = expr.syntax
                                        ->as<syntax::IdentifierSelectNameSyntax>();
                        baseNm = std::string(isn.identifier.valueText());
                        if (isn.selectors.size() == 1 &&
                            isn.selectors[0]->selector &&
                            isn.selectors[0]->selector->kind ==
                                syntax::SyntaxKind::BitSelect)
                            idxSyn = isn.selectors[0]
                                         ->selector
                                         ->as<syntax::BitSelectSyntax>()
                                         .expr;
                    }
                    if (idxSyn && !baseNm.empty()) {
                        auto* bs = s.MakeBit_select();
                        bs->VpiName(baseNm);
                        bs->VpiFullName(joinRef(prefix, baseNm));
                        bs->VpiParent(parent);
                        setLoc(bs, idxSyn->sourceRange());
                        UHDM::any* ix = nullptr;
                        if (idxSyn->kind == syntax::SyntaxKind::IdentifierName)
                            ix = emitPropFormalRef(
                                idxSyn->as<syntax::IdentifierNameSyntax>()
                                    .identifier.valueText(),
                                idxSyn->sourceRange(), bs, prefix);
                        else if (idxSyn->kind ==
                                 syntax::SyntaxKind::InvocationExpression) {
                            auto& inv9 =
                                idxSyn->as<syntax::InvocationExpressionSyntax>();
                            auto* fc9 = s.MakeFunc_call();
                            if (inv9.left->kind ==
                                syntax::SyntaxKind::IdentifierName)
                                fc9->VpiName(
                                    inv9.left
                                        ->as<syntax::IdentifierNameSyntax>()
                                        .identifier.valueText());
                            fc9->VpiParent(bs);
                            setLoc(fc9, idxSyn->sourceRange());
                            for (auto& [subK9, subI9] : subMap)
                                if (subI9.tf &&
                                    subI9.tf->VpiName() == fc9->VpiName() &&
                                    subI9.tf->UhdmType() ==
                                        UHDM::uhdmfunction) {
                                    fc9->Function((UHDM::function*)subI9.tf);
                                    break;
                                }
                            if (inv9.arguments &&
                                !inv9.arguments->parameters.empty()) {
                                auto* args9 = s.MakeAnyVec();
                                for (auto a9 : inv9.arguments->parameters) {
                                    if (a9->kind !=
                                        syntax::SyntaxKind::OrderedArgument)
                                        continue;
                                    const syntax::SyntaxNode* ae9 =
                                        a9->as<syntax::OrderedArgumentSyntax>()
                                            .expr;
                                    if (ae9->kind == syntax::SyntaxKind::
                                                         SimplePropertyExpr)
                                        ae9 = ae9->as<
                                                  syntax::
                                                      SimplePropertyExprSyntax>()
                                                  .expr;
                                    if (ae9->kind == syntax::SyntaxKind::
                                                         SimpleSequenceExpr)
                                        ae9 = ae9->as<
                                                  syntax::
                                                      SimpleSequenceExprSyntax>()
                                                  .expr;
                                    if (ae9->kind ==
                                        syntax::SyntaxKind::IdentifierName)
                                        if (auto* ar9 = emitPropFormalRef(
                                                ae9->as<syntax::
                                                            IdentifierNameSyntax>()
                                                    .identifier.valueText(),
                                                ae9->sourceRange(), fc9,
                                                joinRef(prefix, baseNm)))
                                            args9->push_back(ar9);
                                }
                                if (!args9->empty())
                                    fc9->Tf_call_args(args9);
                            }
                            ix = fc9;
                        }
                        if (ix) {
                            bs->VpiIndex((UHDM::expr*)ix);
                            return bs;
                        }
                    }
                }
            }
            // § droppedCall14 (expression half) — a call on a handle whose
            // type is an unspecialized type PARAMETER leaves the RECEIVER as
            // the Invalid node's child, so the plain unwrap below would emit a
            // bare ref where the reference tool emits the whole dotted call
            // (`first.convert2string()` inside a `$sformat` argument).  Only a
            // BARE reference child is such a receiver: a COMPOUND child (the
            // `&&` one of whose operands was dropped, an assignment) starts at
            // the same column and must keep the plain unwrap, or the whole
            // operation collapses into the call.
            if (iv2.child && stmtSyntax14 &&
                (iv2.child->kind == ExpressionKind::NamedValue ||
                 iv2.child->kind == ExpressionKind::MemberAccess ||
                 iv2.child->kind == ExpressionKind::HierarchicalValue) &&
                iv2.child->sourceRange.start().valid())
                if (auto* cs14 = findDroppedCallAt14(
                        *stmtSyntax14, iv2.child->sourceRange.start()))
                    if (auto* r14 = emitDroppedCall14(*cs14, parent, prefix,
                                                      netMap, stmtCtx14))
                        return r14;
            if (iv2.child)
                return emitExpr(*iv2.child, parent, prefix, netMap);
            // NOTE § invalidNewCallFromSyntax55 (emit half).  GATE:
            // `sourceIsNewClassExpr55` — an Invalid node with NO child whose
            // syntax is a bare-`new` NewClassExpression (see that predicate for
            // the two slang branches that produce it and the source citation).
            // Placed AFTER the child unwrap and immediately BEFORE the
            // unsupported note, so it can only ever turn a `return nullptr` into
            // an object: no path that already emitted anything changes shape.
            //
            // The object is EXACTLY the one the bound `case NewClass` arm builds
            // for a plain `new`: a LOC-LESS `method_func_call` named "new",
            // parented at the assignment, arguments as `vpiArgument`.  Golden
            // (arm a1, cells C8/C9/C10/C11) carries no vpiFunction, no prefix and
            // no location on it — `rhsAt=0:0-0:0` — and the argument is a
            // NAME-ONLY `ref_obj` with no `vpiActual`, spanning the argument
            // identifier alone.  slang bound nothing here, so there is no symbol
            // to bind the argument to and the name-only ref is not a compromise:
            // it is what golden holds.
            // GATE (the measurement that made it necessary): our side emitted an
            // `assignment` with a NULL Rhs at 7 uvm-1.2 sites in SimpleUVM
            // (uvm_registry.svh 66/207/208, uvm_pair.svh 67/72,
            // uvm_random_stimulus.svh 101, uvm_pool.svh 307), and
            // `uvm_registry.svh:207`'s was the whole-design cmp HEAD of
            // SimpleUVM and Scoreboard.
            if (sourceIsNewClassExpr55(expr)) {
                const auto& ncs55 =
                    expr.syntax->as<syntax::NewClassExpressionSyntax>();
                auto* mfc55 = s.MakeMethod_func_call();
                mfc55->VpiName("new");
                mfc55->VpiParent(parent);
                if (ncs55.argList && !ncs55.argList->parameters.empty()) {
                    auto* args55 = s.MakeAnyVec();
                    for (auto a55 : ncs55.argList->parameters) {
                        const syntax::SyntaxNode* ae55 = nullptr;
                        if (a55->kind == syntax::SyntaxKind::OrderedArgument)
                            ae55 = a55->as<syntax::OrderedArgumentSyntax>().expr;
                        // An OrderedArgument's `expr` is a PropertyExprSyntax in
                        // slang's grammar; the ordinary-expression case arrives
                        // wrapped in SimplePropertyExpr / SimpleSequenceExpr, as
                        // the § droppedCall14 arm above already has to unwrap.
                        if (ae55 &&
                            ae55->kind == syntax::SyntaxKind::SimplePropertyExpr)
                            ae55 = ae55->as<syntax::SimplePropertyExprSyntax>().expr;
                        if (ae55 &&
                            ae55->kind == syntax::SyntaxKind::SimpleSequenceExpr)
                            ae55 = ae55->as<syntax::SimpleSequenceExprSyntax>().expr;
                        if (ae55 &&
                            ae55->kind == syntax::SyntaxKind::IdentifierName) {
                            std::string an55(
                                ae55->as<syntax::IdentifierNameSyntax>()
                                    .identifier.valueText());
                            auto* ar55 = s.MakeRef_obj();
                            ar55->VpiName(an55);
                            ar55->VpiFullName(joinRef(prefix, an55));
                            ar55->VpiParent(mfc55);
                            setLoc(ar55, ae55->sourceRange());
                            args55->push_back(ar55);
                            continue;
                        }
                        // Any other actual shape is NOT guessed at: it is
                        // NOTED, so a dropped argument can never be silent (a
                        // dropped one would also fail cmp on the arg-vector
                        // size, which is how it would be found).
                        noteUnsupportedAt(
                            "unbound new() argument shape: " +
                                std::string(ae55 ? toString(ae55->kind)
                                                 : toString(a55->kind)),
                            a55->sourceRange().start());
                    }
                    if (!args55->empty())
                        mfc55->Tf_call_args(args55);
                }
                return mfc55;
            }
            // § typeParamScopedCallRef59 (emit half) — a `::`-scoped reference
            // slang refused to bind becomes the SAME bare unbound `ref_obj`
            // § staticScopedCall12 builds for the bound case: name = FIRST
            // written segment `::` FINAL identifier, span = the scoped name's
            // start up to (NOT including) that final identifier, UNBOUND (no
            // vpiActual), with the arguments and everything else hung off the
            // reference DROPPED.  Placed AFTER the child unwrap, AFTER
            // § droppedCall14 and AFTER § invalidNewCallFromSyntax55, and
            // immediately BEFORE the unsupported note, so it can only ever turn
            // a `return nullptr` into an object.
            //
            // MEASURED, cell for cell (arm a2, thirteen positions of ONE
            // spelling): golden emits this object in assignment-RHS, bare
            // STATEMENT, if-CONDITION, call-ARGUMENT, RETURN, binary-OPERAND,
            // for-body, class-PROPERTY-initializer and instance-method position,
            // with and without parentheses (`Tregistry::sprop`), with and
            // without arguments (`Tregistry::getn(1,"a")`), and it DROPS both a
            // chain hung off the call (`Tregistry::get().ok()` -> ONE ref_obj)
            // and a NESTED type-parameter call used as an argument
            // (`Tcreator::create_by_type(Tregistry::get(), nm)` -> ONE ref_obj
            // named `Tcreator::create_by_type`; the inner one is GONE).  The
            // argument drop is not a compromise — it is what golden holds, and
            // it falls out of building the object from the SCOPED NAME alone.
            if (auto* r59 = invalidScopedCallRef59(expr, parent, prefix))
                return r59;
            noteUnsupportedAt("expression kind: Invalid",
                              expr.syntax ? expr.syntax->sourceRange().start()
                                          : expr.sourceRange.start());
            return nullptr;
        }
        default:
            noteUnsupportedAt("expression kind: " + std::string(toString(expr.kind)),
                              expr.sourceRange.start());
            return nullptr;
    }
}

} // namespace slang_uhdm
