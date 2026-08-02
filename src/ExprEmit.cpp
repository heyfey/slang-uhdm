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

// True when `e` names a PACKAGE-level variable and the source spells it
// package-QUALIFIED (`p::ch`). Surelog resolves such a reference only as a
// whole: any selector hung off it — `.member`, `.method(...)`, even a
// statement-position call — is DROPPED and the ref_obj alone survives
// (r10apb3 repro 10: `if (p::ch.f(1))`, `p::ch.t();`, `r = p::ch.f(2)` and
// `r = p::ch.x` all collapse to `ref_obj p::ch`, while the identical calls
// through a MODULE-local handle keep their full hier_path shape).
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
                               bool unitResolves) {
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
            if (k == SymbolKind::InstanceBody ||
                k == SymbolKind::GenerateBlock ||
                k == SymbolKind::GenerateBlockArray)
                return false;
        }
        return false;
    }
    for (size_t i = 0; i < n.getChildCount(); i++)
        if (auto* c = n.childNode(i))
            if (!r9DimNamesResolved(*c, scope, unitResolves))
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
                          bool unitResolves = true) {
    if (n.kind == slang::syntax::SyntaxKind::VariableDimension)
        return r9DimNamesResolved(n, scope, unitResolves);
    for (size_t i = 0; i < n.getChildCount(); i++)
        if (auto* c = n.childNode(i))
            if (!r9DimsLiteral(*c, scope, unitResolves))
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
bool UhdmExporter::srlgBitsFoldArg(const slang::ast::Expression& arg0) {
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
    for (auto sc = sym->getParentScope(); sc; sc = sc->asSymbol().getParentScope()) {
        auto k = sc->asSymbol().kind;
        if (k == SymbolKind::Subroutine)
            return false;
        if (k == SymbolKind::InstanceBody || k == SymbolKind::Package ||
            k == SymbolKind::CompilationUnit)
            break;
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
        if (auto* ts = dt->getTypeSyntax())
            if (!r9DimsLiteral(*ts, ssc, /*unitResolves=*/false))
                return false;
        if (auto* ds = dt->getDimensionSyntax())
            for (auto d : *ds)
                if (!r9DimsLiteral(*d, ssc, /*unitResolves=*/false))
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
    // Expressions CONTAINING unbased-unsized literals ('0 << 8) never fold:
    // Surelog's folded model re-emits the operation.
    {
        bool hasUnbased = false;
        expr.visit(makeVisitor([&](auto& v, const UnbasedUnsizedIntegerLiteral& u) {
            hasUnbased = true;
            v.visitDefault(u);
        }));
        // Only OPERATIONS over unbased literals stay unfolded (casts and
        // direct literals still fold — param defaults/size casts re-encode).
        auto k0 = stripImplicitConv(expr).kind;
        if (hasUnbased &&
            (k0 == ExpressionKind::BinaryOp || k0 == ExpressionKind::UnaryOp ||
             k0 == ExpressionKind::ConditionalOp ||
             k0 == ExpressionKind::Concatenation))
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
        c->VpiSize((int32_t)expr.type->getBitWidth());
        std::string bits;
        for (int32_t i = (int32_t)expr.type->getBitWidth() - 1; i >= 0; i--) {
            auto b = iv[i];
            bits += b.isUnknown() ? (b.value == slang::logic_t::Z_VALUE ? 'z' : 'x')
                    : (b.value ? '1' : '0');
        }
        c->VpiValue("BIN:" + bits);
        c->VpiConstType(vpiBinaryConst);
        c->VpiDecompile(std::to_string((int32_t)expr.type->getBitWidth()) + "'b" +
                        bits);
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
    if (stripImplicitConv(expr).kind == ExpressionKind::Concatenation ||
        (paramCtx && stripImplicitConv(expr).kind == ExpressionKind::Replication)) {
        auto* c = s.MakeConstant();
        int32_t w = (int32_t)expr.type->getBitWidth();
        c->VpiSize(w);
        std::string bits;
        for (int32_t i = w - 1; i >= 0; i--)
            bits += (iv[i] == slang::logic_t(1)) ? '1' : '0';
        c->VpiValue("BIN:" + bits);
        c->VpiConstType(vpiBinaryConst);
        if (paramCtx)
            c->VpiDecompile(std::to_string(w) + "'b" + bits);
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
            c->VpiSize(w);
            std::string bits;
            for (int32_t i = w - 1; i >= 0; i--)
                bits += (iv[i] == slang::logic_t(1)) ? '1' : '0';
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
    while (true) {
        if (cur->kind == ExpressionKind::MemberAccess) {
            auto& ma = cur->as<MemberAccessExpression>();
            auto end = cur->sourceRange.end();
            Comp c;
            c.name = std::string(ma.member.name);
            c.nameSpan = SourceRange(end - ma.member.name.size(), end);
            attachSels(c);
            comps.push_back(c);
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

    std::string dotted;
    for (size_t i = 0; i < comps.size(); ++i) {
        dotted += (i == 0 ? comps[i].name : "." + comps[i].name);
        for (auto& sel : comps[i].sels)
            dotted += "[" + spaceIdxOps(rawText(sel.sel->sourceRange)) + "]";
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
                dottedAt += "[" + spaceIdxOps(rawText(comp.sels[k].sel->sourceRange)) + "]";
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
            dottedAt += "[" + spaceIdxOps(rawText(sel.sel->sourceRange)) + "]";
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
            if (baseSelMode && !comp.isBase) {
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
    switch (expr.kind) {
        case ExpressionKind::Assignment: {
            auto& ae = expr.as<AssignmentExpression>();
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
                if (stripImplicitConv(*rhsExpr).kind == ExpressionKind::NewClass &&
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
                if (currentSubSym && !pkgSub9 &&
                    rhs->UhdmType() == UHDM::uhdmconstant &&
                    ((UHDM::expr*)rhs)->VpiSize() == -1 &&
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
            if (auto* c = emitExpr(*cond.conditions[0].expr, op, prefix, netMap))
                operands->push_back(c);
            if (auto* t = emitExpr(cond.left(), op, prefix, netMap))
                operands->push_back(t);
            if (auto* f = emitExpr(cond.right(), op, prefix, netMap))
                operands->push_back(f);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::NamedValue: {
            auto& nv = expr.as<NamedValueExpression>();
            if (refCollector && (!inProcessEmit || callArgDepth > 0 || inLhs))
                refCollector->insert(&nv.symbol);
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
            if (scope && scope->asSymbol().kind == SymbolKind::Package &&
                nv.symbol.kind == SymbolKind::Parameter) {
                // Package-function bodies keep a ref bound to the param's
                // def-view constant.
                if (currentTf && pkgScopeInst) {
                    ref->VpiFullName(joinRef(prefix, nv.symbol.name));
                    if (auto pit = pkgParamConst.find(&nv.symbol);
                        pit != pkgParamConst.end())
                        ref->Actual_group(pit->second);
                    else if (auto pit2 = pkgParamDefRhs.find(&nv.symbol);
                             pit2 != pkgParamDefRhs.end())
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
                if (ckP == SymbolKind::PackedStructType ||
                    ckP == SymbolKind::PackedUnionType) {
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
                                poIt9 != pkgParamObj.end() &&
                                poIt9->second->Typespec())
                                rt9->Actual_typespec(
                                    poIt9->second->Typespec()
                                        ->Actual_typespec());
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
                auto& cv = psym.getValue();
                if (cv.isInteger() && !cv.integer().hasUnknown()) {
                    auto* c = s.MakeConstant();
                    std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
                    c->VpiDecompile(digits);
                    // TYPED pkg params fold at the type width; untyped at 64.
                    bool typedPkgParam = false;
                    if (auto d0 = psym.getDeclaredType())
                        if (auto t0 = d0->getTypeSyntax())
                            typedPkgParam =
                                t0->kind != syntax::SyntaxKind::ImplicitType;
                    c->VpiSize(typedPkgParam
                                   ? (int32_t)psym.getType().getBitWidth()
                                   : 64);
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
                    if ((parent && parent->UhdmType() == UHDM::uhdmoperation) ||
                        procSelFold9)
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
                    if (procOpFold9 && !typedPkgParam &&
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
                        procSelFold9 || procPsFold9)
                        // Only a param MATERIALIZED into this module (read
                        // through an import, i.e. UNQUALIFIED) carries the ts
                        // ref; a QUALIFIED pkg::P read folds bare (the def ts
                        // belongs to another module's import — Surelog,
                        // BSOPPS*InGenForOfSubmodule).
                        if (auto tit = importedParamDefTs.find(&nv.symbol);
                            tit != importedParamDefTs.end() &&
                            rawText(expr.sourceRange).find("::") ==
                                std::string::npos) {
                            auto* rt = s.MakeRef_typespec();
                            if (procSelFold9)
                                rt->VpiFullName(
                                    ((UHDM::bit_select*)parent)->VpiFullName());
                            else
                                rt->VpiFullName(prefix);
                            rt->VpiParent(c);
                            // A CONT-ASSIGN fold binds its OWN clone of the
                            // imported param's typespec (Surelog mints one per
                            // reference); other folds share the def object.
                            bool caFold9 =
                                parent &&
                                parent->UhdmType() == UHDM::uhdmcont_assign &&
                                contAssignView != 2 &&
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
                            if (sysFuncArgFold || caFold9 || procPsFold9)
                                if (auto cIt = pkgParamConst.find(&nv.symbol);
                                    cIt != pkgParamConst.end() &&
                                    cIt->second->VpiParent())
                                    c->VpiParent(cIt->second->VpiParent());
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
                            c->VpiConstType(v.rfind("BIN:", 0) == 0   ? vpiBinaryConst
                                            : v.rfind("HEX:", 0) == 0 ? vpiHexConst
                                            : v.rfind("OCT:", 0) == 0 ? vpiOctConst
                                            : v.rfind("DEC:", 0) == 0 ? vpiDecConst
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
                        for (auto& [esym, econ] : elabParamConst)
                            if (esym->location == nv.symbol.location &&
                                esym->name == nv.symbol.name) {
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
                if (genCaLoopParamFold && (!inLhs || inPsBound) &&
                    callArgDepth == 0 &&
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
                    if (outerParam9 && (inPsBound || pa9) &&
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
                    if (inGenScopeProc && !currentSubSym &&
                        (!inPsBound || varSelIdxDepth > 0))
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
                        if (genPsBound9 && prefix != selectBasePrefix)
                            for (auto& [esym9, epa9] : elabParamPa)
                                if (esym9->location == nv.symbol.location &&
                                    esym9->name == nv.symbol.name) {
                                    c->VpiParent((UHDM::any*)epa9);
                                    break;
                                }
                        // SL carries the folded param's type as a ref_typespec
                        // whose fullname is the enclosing (function) scope.
                        auto* its = s.MakeInt_typespec();
                        bool locSet9 = false;
                        if (genPsBound9) {
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
                if (classMethodNoBind) {
                    // Class-method body outside an if/case condition: no
                    // actual of any kind (see classMethodNoBind).
                }
                else if (suppressRefActual) {
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
                    // fully unbound.
                    if (nv.symbol.kind == SymbolKind::EnumValue &&
                        !defGenProcessEmit) {
                        if (auto eit = enumConstMap.find(&nv.symbol);
                            eit != enumConstMap.end() &&
                            eit->second->UhdmType() == UHDM::uhdmenum_const) {
                            auto* shared = (UHDM::enum_const*)eit->second;
                            auto* ec = s.MakeEnum_const();
                            ec->VpiName(shared->VpiName());
                            ec->VpiValue(std::string(shared->VpiValue()));
                            ec->VpiDecompile(shared->VpiDecompile());
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
                         !(inGenScopeCaRhs && selIdxScopeDepth > 0)) {
                    ref->Actual_group(it->second);
                    // Whole ref: may be re-pointed to a select object if this
                    // variable is written via a select elsewhere in the body.
                    if (selTrackActive) {
                        selWholeRefs.push_back({ref, &nv.symbol});
                        if (inLhs)
                            selWholeWrittenVars.insert(&nv.symbol);
                    }
                }
                else if (auto eit = enumConstMap.find(&nv.symbol); eit != enumConstMap.end())
                    ref->Actual_group(eit->second);
                else if (auto uit = unitParamMap.find(&nv.symbol);
                         uit != unitParamMap.end())
                    // $unit params bind the design-level parameter.
                    ref->Actual_group(uit->second);

                else if (nv.symbol.kind == SymbolKind::EnumValue)
                    // Anonymous-enum const built later in the deferred pass.
                    pendingEnumRefs.push_back({ref, &nv.symbol});
                else if (funcRetRefs && &nv.symbol == funcRetSym)
                    funcRetRefs->push_back(ref);
                else if (implicitNetModule &&
                         (nv.symbol.kind == SymbolKind::Iterator ||
                          (nv.symbol.kind == SymbolKind::Parameter &&
                           nv.symbol.getParentScope() &&
                           nv.symbol.getParentScope()->asSymbol().kind ==
                               SymbolKind::StatementBlock))) {
                    // Surelog can't resolve block-scoped localparams, nor a
                    // foreach loop variable (its declaration is implicit):
                    // refs bind an implicit module wire minted at the first
                    // reference.
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
                            bypassTypedefShare = true;
                            bool savedTf2 = tfContext;
                            // The home-package clone's bounds follow the VIEW:
                            // the def package's stay symbolic, the top
                            // package's fold (rp32 imm_t 32-1 vs 31).
                            tfContext = homePkgSub0 ? !pkgTopEmit : true;
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
                else if (currentScope) {
                    // Non-literal cast sizes: integer_typespec carrying the
                    // freshly-bound size expression as vpiExpr (parented at
                    // the cast operation, name-only call spans). Parens
                    // anchor at the inner expression. Re-emitted contexts
                    // create the ts at the end of the write phase.
                    const syntax::ExpressionSyntax* leftSyn = cesyn.left;
                    while (leftSyn->kind == syntax::SyntaxKind::ParenthesizedExpression)
                        leftSyn = leftSyn->as<syntax::ParenthesizedExpressionSyntax>()
                                      .expression;
                    ASTContext bctx(*currentScope, LookupLocation::max);
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
                            setLoc(its0,
                                   SourceRange(psym0.location, psym0.location));
                            auto& pv0 = psym0.as<ParameterSymbol>().getValue();
                            if (pv0.isInteger() && !pv0.integer().hasUnknown())
                                its0->VpiValue(
                                    "UINT:" + pv0.integer().toString(
                                                  LiteralBase::Decimal, false));
                            cts = its0;
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
                            litWidthParam9 =
                                wp9.getInitializer() &&
                                isLiteralExpr(
                                    stripImplicitConv(*wp9.getInitializer()));
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
                            its->Expr((UHDM::expr*)e);
                        inCastSize = savedCS;
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
                    if (!callStmtCtx0 &&
                        recv0.kind == ExpressionKind::NamedValue) {
                        std::string rn0(
                            recv0.as<NamedValueExpression>().symbol.name);
                        std::string dotted0 = rn0 + "." + std::string(sub.name);
                        auto* hp0 = s.MakeHier_path();
                        hp0->VpiName(dotted0);
                        hp0->VpiFullName(dotted0);
                        hp0->VpiParent(parent);
                        setLoc(hp0, expr.sourceRange);
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
                        for (auto arg : call.arguments()) {
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
                    for (auto arg : call.arguments()) {
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
                        for (auto arg : call.arguments()) {
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
                // A PARAM-INIT call in an ELAB instance body: bind the shared
                // DEF function (the elab view lists it; Surelog's kept
                // func_call points at it) rather than an empty shell.
                if (it == subMap.end() && inParamInit && !paramInitDef)
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
                    else {
                        noteUnsupported("user function call");
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
                UHDM::tf_call* fc = isFunc ? (UHDM::tf_call*)s.MakeFunc_call()
                                           : (UHDM::tf_call*)s.MakeTask_call();
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
                    }
                    else if (boundClone) {
                        fc->VpiName(wqual + "::" + std::string(sub.name));
                        setLoc(fc, nameSpan(expr.sourceRange.start(), wqual));
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
                if (isFunc)
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
                if (auto* isy9 =
                        expr.syntax
                            ? expr.syntax->as_if<syntax::InvocationExpressionSyntax>()
                            : nullptr)
                    nWritten9 =
                        isy9->arguments ? isy9->arguments->parameters.size() : 0;
                callArgDepth++;
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
                    if (inParamInit && !paramInitDef && !paramInitPkg && isFunc &&
                        !currentTf && callArgDepth == 1 && a &&
                        a->UhdmType() == UHDM::uhdmref_obj) {
                        auto& ba9 = stripImplicitConv(*arg);
                        if (ba9.kind == ExpressionKind::NamedValue &&
                            ba9.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter) {
                            auto& pv9 = ba9.as<NamedValueExpression>()
                                            .symbol.as<ParameterSymbol>()
                                            .getValue();
                            if (pv9.isInteger() && !pv9.integer().hasUnknown()) {
                                std::string dg9 = pv9.integer().toString(
                                    LiteralBase::Decimal, false);
                                auto* c9 = s.MakeConstant();
                                c9->VpiDecompile(dg9);
                                c9->VpiSize((int32_t)pv9.integer().getBitWidth());
                                c9->VpiValue("UINT:" + dg9);
                                c9->VpiConstType(vpiUIntConst);
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
                                // actual wins (the elab param keeps its
                                // declared ts). Procedural calls never rebind.
                                if (contAssignView == 1 && isFunc && !currentTf &&
                                    sk == SymbolKind::Parameter &&
                                    argIdx < si.argTs.size() &&
                                    si.argTs[argIdx].first) {
                                    auto dpit = defParamTsRef.find(
                                        &baseArg.as<NamedValueExpression>().symbol);
                                    if (dpit != defParamTsRef.end() && dpit->second)
                                        dpit->second->Actual_typespec(
                                            si.argTs[argIdx].first);
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
                        bool argCtxOk =
                            currentTf ? ((pkgTopEmit && !structFormal9 &&
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
                                         (refArg || callArgDepth == 1));
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
                        if (isFunc && !inProcessEmit && argCtxOk && !pkgScopedRef &&
                            !strFormalConst &&
                            // A PROPERTY-DECL body's call args carry no
                            // formal-ts stamp (mriscv s2qed reg_map(inp1)).
                            !propDeclScope &&
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
                        auto* hp = s.MakeHier_path();
                        std::string dotted =
                            withExpr9 ? recvText : recvText + "." + name;
                        hp->VpiName(dotted);
                        hp->VpiFullName(dotted);
                        hp->VpiParent(parent);
                        // slang's call range stops at the `)` of the method;
                        // Surelog's runs through the with-clause's own `)`.
                        setLoc(hp, withExpr9
                                       ? SourceRange(expr.sourceRange.start(),
                                                     withExpr9->sourceRange.end() + 1)
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
                        auto* mfc = s.MakeMethod_func_call();
                        mfc->VpiName(name);
                        mfc->VpiParent(hp);
                        auto mStart = recv->sourceRange.end() + 1;
                        setLoc(mfc, SourceRange(mStart, mStart + name.size()));
                        if (withExpr9)
                            if (auto* w9 =
                                    emitExpr(*withExpr9, parent, prefix, netMap))
                                mfc->With(w9);
                        // Extra method args (past the receiver); literal args
                        // parent at the method call.
                        auto* margs = s.MakeAnyVec();
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
                noteUnsupported("system method call: " + name);
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
                    bitsKeep = !srlgBitsFoldArg(a0);
            }
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
                        r0->VpiFullName(prefix + "." + std::string(at.name));
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
                if (inParamInit && !paramInitDef &&
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
                dotted += "[" + rawText(es.selector().sourceRange) + "]";
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
                        for (auto it2 = sels.rbegin(); it2 != sels.rend(); ++it2)
                            dotted += "[" + rawText((*it2)->sourceRange) + "]";
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
                    std::string baseDotted = rawText(es.value().sourceRange);
                    if (baseDotted.find('.') != std::string::npos) {
                        std::string selText = spaceIdxOps(selName(rawText(expr.sourceRange)));
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
                        if (constSel)
                            ips->VpiConstantSelect(true);
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
                    auto* hp = s.MakeHier_path();
                    std::string dotted(bnv.symbol.name);
                    for (auto it2 = chain.rbegin(); it2 != chain.rend(); ++it2)
                        dotted += "." +
                                  std::string(
                                      (*it2)->as<MemberAccessExpression>().member.name);
                    std::string selText = spaceIdxOps(selName(rawText(SourceRange(
                        rs.left().sourceRange.start(), rs.right().sourceRange.end()))));
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
                            auto& fma9 =
                                (*chain.rbegin())->as<MemberAccessExpression>();
                            auto fst9 = (*chain.rbegin())->sourceRange.end() -
                                        fma9.member.name.size();
                            bsr9 = SourceRange(
                                fst9, fst9 + bnv.symbol.name.size());
                        }
                        setLoc(r, bsr9);
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
                        {
                            ASTContext cctx(comp.getRoot(), LookupLocation::max);
                            constSel = (rs.left().kind == ExpressionKind::IntegerLiteral ||
                                        cctx.tryEval(rs.left())) &&
                                       (rs.right().kind == ExpressionKind::IntegerLiteral ||
                                        cctx.tryEval(rs.right()));
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
                            if (constSel)
                                ips->VpiConstantSelect(true);
                            bool sup = suppressConstParent;
                            suppressConstParent = isLiteralExpr(rs.left());
                            if (auto* b = emitExpr(rs.left(), ips, prefix, netMap))
                                ips->Base_expr((UHDM::expr*)b);
                            suppressConstParent = isLiteralExpr(rs.right());
                            if (auto* w = emitExpr(rs.right(), ips, prefix, netMap))
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
                    std::string baseDotted = rawText(rs.value().sourceRange);
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
                        std::string selText;
                        if (rs.getSelectionKind() == RangeSelectionKind::Simple)
                            selText = selName(baseDotted) + "[" +
                                      renderBound9(rs.left()) + ":" +
                                      renderBound9(rs.right()) + "]";
                        else if (stripImplicitConv(rs.left()).kind ==
                                 ExpressionKind::NamedValue)
                            selText = selName(rawText(expr.sourceRange));
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
                        for (size_t ci = 0; ci + 1 < comps.size(); ci++) {
                            auto& [cn, co] = comps[ci];
                            // An indexed component (a[0]) is a bit_select.
                            auto lb2 = cn.find('[');
                            auto rb2 = cn.find(']');
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
                            if (auto* w2 = emitExpr(rs.right(), ips2, prefix, netMap))
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
            auto* hp = s.MakeHier_path();
            std::string dotted(nv.symbol.name);
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
                    auto& fm = *chain.back();
                    auto end = fm.sourceRange.end();
                    setLoc(r, SourceRange(
                                  end - fm.as<MemberAccessExpression>().member.name.size(),
                                  end));
                }
                else {
                    setLoc(r, base->sourceRange);
                }
                elems->push_back(r);
                }
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
                if ((!isUnpackedArr || descUnpacked) &&
                    operands->size() > 1) {
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
                    if (!nestedOps9 && !wasInPattern)
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
                UHDM::constant* pkgEnumFold6 = nullptr;
                if (paramInitPkg || importedParamClone || pkgEnumSubstPat) {
                    auto& ev7 = stripImplicitConv(*setter.expr);
                    if (ev7.kind == ExpressionKind::NamedValue)
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
                for (auto arg9 : cc9->as<CallExpression>().arguments()) {
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
            if (iv2.child)
                return emitExpr(*iv2.child, parent, prefix, netMap);
            noteUnsupported("expression kind: Invalid");
            return nullptr;
        }
        default:
            noteUnsupported("expression kind: " + std::string(toString(expr.kind)));
            return nullptr;
    }
}

} // namespace slang_uhdm
