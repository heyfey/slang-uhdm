//------------------------------------------------------------------------------
//! @file ParamEmit.cpp
//! @brief Parameters, param_assigns, deferred param typespecs, packages
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include <charconv>
#include <functional>

#include "UhdmExporter.h"

#include "EmitHelpers.h"

#include "slang/ast/EvalContext.h"

namespace slang_uhdm {

// adjustSize's `orig_size == -1` tail (EmitHelpers slAdjustBinConst) applied
// to an UNPACKED-ARRAY parameter's ELABORATED assignment-pattern operands:
// every unsized `'1` operand re-encodes as the ELEMENT width filled with ones
// (`int unsigned A[N] = '{'1,'1}` -> UINT:4294967295 size 32).  It reaches
// through a `'{N{'1}}` replication's inner concat as well.  The DEF view keeps
// the bare `'1` — this runs on the elab object only (ParamArrayUnsizedPattern).
static void elabUnsizedPatternFold(UHDM::operation* opr, int32_t elemWidth) {
    if (!opr || elemWidth <= 0)
        return;
    std::function<void(UHDM::operation*)> walk = [&](UHDM::operation* o) {
        if (!o->Operands())
            return;
        for (auto* x : *o->Operands()) {
            if (x->UhdmType() == UHDM::uhdmoperation) {
                walk((UHDM::operation*)x);
                continue;
            }
            if (x->UhdmType() != UHDM::uhdmconstant)
                continue;
            auto* c = (UHDM::constant*)x;
            if (c->VpiSize() != -1 || c->VpiConstType() != vpiBinaryConst)
                continue;
            std::string_view v = c->VpiValue();
            if (v.rfind("BIN:", 0) != 0)
                continue;
            SLAdjustedConst adj;
            if (!slAdjustBinConst(v.substr(4), -1, false, elemWidth, false,
                                  adj))
                continue;
            c->VpiDecompile(adj.digits);
            c->VpiSize(adj.size);
            c->VpiValue(adj.prefix + adj.digits);
            c->VpiConstType(adj.constType);
        }
    };
    walk(opr);
}

// Surelog accumulates an unpacked-array parameter's vpiSize inside
// compileRanges (CompileExpression.cpp:4053/4030): the dimension product is
// multiplied in ONLY when the bound reduces — and the elaborated package copy
// / import copy evaluates with a NULL instance, so a bound that NAMES anything
// never reduces and the size stays at compileRanges' initial 1.  Pure literal
// arithmetic still reduces.  Measured, one source, package + importing module:
// `A3[3]` -> 3, `D[CNT]` -> 1, `E[CNT-1]` -> 1, `F[2+1]` -> 3 (the `[CNT]`
// row is DefaultPatternInt's first-fail).
static bool unpackedDimsAllLiteral(const Symbol& sym) {
    auto* dsyn = sym.getSyntax();
    if (!dsyn || dsyn->kind != syntax::SyntaxKind::Declarator)
        return false;
    std::function<bool(const syntax::SyntaxNode*)> named =
        [&](const syntax::SyntaxNode* n) -> bool {
        if (!n)
            return false;
        switch (n->kind) {
            case syntax::SyntaxKind::IdentifierName:
            case syntax::SyntaxKind::IdentifierSelectName:
            case syntax::SyntaxKind::ScopedName:
            case syntax::SyntaxKind::ClassName:
                return true;
            default:
                break;
        }
        for (size_t i = 0, c = n->getChildCount(); i < c; i++)
            if (named(n->childNode(i)))
                return true;
        return false;
    };
    for (auto dim : dsyn->as<syntax::DeclaratorSyntax>().dimensions)
        if (named(dim))
            return false;
    return true;
}

static bool containsUserCall(const Expression& e) {
    bool found = false;
    e.visit(makeVisitor([&](auto& v, const CallExpression& c) {
        if (!c.isSystemCall())
            found = true;
        v.visitDefault(c);
    }));
    return found;
}

// A query call the ELABORATED view keeps symbolic because UHDM's ExprEval
// cannot reduce it either.  `$size` over a TYPE reaches ExprEval as the bare
// `*_var` object Surelog's `compileTfCallArguments` built for the type
// keyword, and `reduceExpr`'s `$size` handler sizes only `logic_net` /
// `logic_var` / `array_net` / `array_var` argument objects — so it gives up
// and the `sys_func_call` survives into the instance view.  `$size` over a
// TYPEDEF NAME does reduce (its argument is a ref_obj the evaluator resolves),
// so only the keyword form is excluded.  NonSynthError `parameter S =
// $size(int)`; measured against a 12-type golden matrix.
static bool srlgElabUnreducibleCall(const Expression& e) {
    auto& s0 = stripImplicitConv(e);
    if (s0.kind != ExpressionKind::Call)
        return false;
    auto& ce = s0.as<CallExpression>();
    if (!ce.isSystemCall() || ce.getSubroutineName() != "$size" ||
        ce.arguments().empty())
        return false;
    auto& a0 = stripImplicitConv(*ce.arguments()[0]);
    return a0.kind == ExpressionKind::DataType && a0.type &&
           a0.type->kind != SymbolKind::TypeAlias;
}

// ---------------------------------------------------------------------------
// --disable-feature=parametersubstitution
//
// Surelog gates exactly one function on this flag:
// CompileHelper::substituteAssignedValue (CompileExpression.cpp:83) walks a
// candidate `param_assign` Rhs and answers false when the tree contains a
// `vpiAssignmentPatternOp` or `vpiConcatOp` operation.  Every caller
// (CompileExpression's four name-resolution arms, NetlistElaboration,
// DesignElaboration, UhdmWriter) reads it as "may I replace this reference by
// the parameter's value?", so with the flag off a pattern- or concat-valued
// parameter is never inlined and stays a `ref_obj`.
//
// The rest of the observable delta is downstream of that one refusal: an
// expression that reads an un-inlinable parameter no longer reduces to a
// constant, so the parameter IT initializes has no value either, and so on.
// `NoParamSubs` shows all three levels at once — `X = '{0,1}` is refused,
// `.P(~X)` therefore stays an operation, and `assign a = P` therefore keeps
// its `ref_obj` instead of collapsing to a constant.
//
// A reference that IS still substitutable resolves to whatever the referenced
// Rhs holds, which under this flag is frequently another reference:
// `prim_subreg #(.RESVAL(RESVAL))` inside `prim_subreg_shadow` emits a
// `ref_obj` named CTRL_RESET (the parent's un-inlinable value) anchored at the
// re-pass site.  That is `noSubstSourceExpr`'s hop loop.
static bool containsPatternOrConcat(const Expression& e) {
    bool found = false;
    e.visit(makeVisitor(
        [&](auto& v, const SimpleAssignmentPatternExpression& x) {
            found = true;
            v.visitDefault(x);
        },
        [&](auto& v, const StructuredAssignmentPatternExpression& x) {
            found = true;
            v.visitDefault(x);
        },
        [&](auto& v, const ReplicatedAssignmentPatternExpression& x) {
            found = true;
            v.visitDefault(x);
        },
        [&](auto& v, const ConcatenationExpression& x) {
            found = true;
            v.visitDefault(x);
        }));
    return found;
}

bool UhdmExporter::cliOverridden(const ParameterSymbol& ps) const {
    if (cliParams.empty() || cliParams.find(std::string(ps.name)) == cliParams.end())
        return false;
    // Surelog's `module->getParameter(name)` looks the name up in the top
    // instance's DEFINITION, so the parameter must be declared by that
    // definition's body -- not inherited from a package import, and not
    // declared in a nested generate scope.
    for (auto* sc = ps.getParentScope(); sc; sc = sc->asSymbol().getParentScope()) {
        auto& sym = sc->asSymbol();
        if (sym.kind == SymbolKind::InstanceBody)
            return cliTopDefs.count(&sym.as<InstanceBodySymbol>().getDefinition()) != 0;
        if (sym.kind == SymbolKind::Package || sym.kind == SymbolKind::CompilationUnit)
            return false;
    }
    return false;
}

// ExprBuilder::fromString + UhdmWriter, reproduced from a measured 12-value
// pair matrix (Surelog alone, one `parameter A = 1;` top, -PA=<value>):
//
//   5        -> decompile "5"       size 64  UINT:5      vpiUIntConst
//   0        -> decompile "0"       size 64  UINT:0      vpiUIntConst
//   -3       -> decompile "-3"      size 64  INT:-3      vpiIntConst
//   1.5      -> decompile "1.500000" size 64 REAL:1.500000  vpiRealConst
//   4'b1010  -> decompile "4'b1010" size 4   BIN:1010    vpiBinaryConst
//   1'b1     -> decompile "1'b1"    size 1   BIN:1       vpiBinaryConst
//   'b101    -> decompile "'b101"   size 0   BIN:101     vpiBinaryConst
//   8'hFF    -> decompile "8'hFF"   size 8   HEX:FF      vpiHexConst
//   16'd300  -> decompile "300"     size 16  UINT:300    vpiUIntConst
//   'd7_200  -> decompile "7200"    size 0   UINT:7200   vpiUIntConst
//   /blah    -> decompile "/blah"   size 40  STRING:/blah  vpiStringConst
//   hello    -> decompile "hello"   size 40  STRING:hello  vpiStringConst
//
// Two rules are worth naming because they are not guessable. The DECIMAL base
// is not a "based literal" at all once parsed: `16'd300` and `'d7_200` come
// back as plain unsigned numbers whose decompile is the NUMBER (separators
// gone, size prefix gone), while b/o/h keep the source spelling verbatim. And
// the size is whatever integer precedes the apostrophe -- ABSENT means 0, not
// 32 and not 64; only a value with no apostrophe at all is 64 wide.
//
// RANKED RESIDUE (0 corpus tests, same matrix). Surelog builds the DEF view
// before elaboration, so the def-view param_assign Rhs keeps the DECLARATION's
// typespec whatever the -P value is; slang re-TYPES the parameter from the
// override, so an UNTYPED `parameter A = 1;` given a value of another type
// diverges there and only there:
//   -PA=1.5 / -PA=hello  -> golden int_typespec, ours real_/string_typespec
//   -PA=4'b1010 / 8'hFF / 16'd300 / 'd7_200 / 1'b1
//                        -> golden bare int_typespec, ours int_typespec+range
// Every value whose type agrees with the declaration default's (plain decimals
// on an untyped or int param, a string on a string param) is cmp-equal, which
// is why all four corpus tests convert. Closing it means deriving the def-view
// typespec from the DECLARATION DEFAULT expression instead of ps.getType()
// throughout makeParamTs -- deep, and worth nothing until a test needs it.
UHDM::constant* UhdmExporter::cliOverrideConst(const std::string& raw) {
    auto* c = s.MakeConstant();
    auto tick = raw.find('\'');
    auto sized = [&]() -> int32_t {
        // StringUtils::rtrim_until(value, '\'') then parseInt32, 0 on failure.
        int32_t sz = 0;
        std::string pre = raw.substr(0, tick);
        if (!pre.empty() && pre.find_first_not_of("0123456789") == std::string::npos &&
            pre.size() < 10)
            sz = (int32_t)std::stol(pre);
        return sz;
    };
    if (tick != std::string::npos) {
        // base char: the one after the apostrophe, skipping a signed marker.
        // NOT case-folded, deliberately: Surelog's switch has lowercase labels
        // only, so `8'HFF` falls through to the BINARY default exactly as an
        // unrecognised base would.
        char base = 'b';
        if (tick + 1 < raw.size())
            base = raw[tick + 1];
        if ((base == 's' || base == 'S') && tick + 2 < raw.size())
            base = raw[tick + 2];
        // fromString drops the size+base prefix, then the `_` separators.
        size_t dstart = raw.find_first_of("sS") != std::string::npos ? tick + 3 : tick + 2;
        std::string digits = dstart <= raw.size() ? raw.substr(dstart) : std::string();
        digits.erase(std::remove(digits.begin(), digits.end(), '_'), digits.end());
        c->VpiSize(sized());
        switch (base) {
            case 'h':
                c->VpiConstType(vpiHexConst);
                c->VpiValue("HEX:" + digits);
                c->VpiDecompile(raw);
                break;
            case 'o':
                c->VpiConstType(vpiOctConst);
                c->VpiValue("OCT:" + digits);
                c->VpiDecompile(raw);
                break;
            case 'd': {
                // Decimal is re-rendered as a NUMBER, losing the prefix.
                if (digits.find('.') != std::string::npos) {
                    char buf[64];
                    snprintf(buf, sizeof(buf), "%f", strtod(digits.c_str(), nullptr));
                    c->VpiConstType(vpiRealConst);
                    c->VpiSize(64);
                    c->VpiValue(std::string("REAL:") + buf);
                    c->VpiDecompile(buf);
                    break;
                }
                bool neg = !raw.empty() && raw[0] == '-';
                if (digits.empty() ||
                    digits.find_first_not_of("0123456789") != std::string::npos) {
                    // parseUint64/parseInt64 refuse: fromString falls back to a
                    // string Value holding the WHOLE original argument.
                    c->VpiConstType(vpiStringConst);
                    c->VpiSize((int32_t)(raw.size() * 8));
                    c->VpiValue("STRING:" + raw);
                    c->VpiDecompile(raw);
                    break;
                }
                c->VpiConstType(neg ? vpiIntConst : vpiUIntConst);
                c->VpiValue((neg ? "INT:-" : "UINT:") + digits);
                c->VpiDecompile((neg ? "-" : "") + digits);
                break;
            }
            default:
                c->VpiConstType(vpiBinaryConst);
                c->VpiValue("BIN:" + digits);
                c->VpiDecompile(raw);
                break;
        }
        return c;
    }
    bool numeric = !raw.empty();
    size_t i0 = (raw[0] == '-' || raw[0] == '+') ? 1 : 0;
    bool dot = false, digit = false;
    for (size_t i = i0; i < raw.size() && numeric; i++) {
        if (raw[i] == '.') {
            if (dot)
                numeric = false;
            dot = true;
        }
        else if (isdigit((unsigned char)raw[i]))
            digit = true;
        else
            numeric = false;
    }
    numeric = numeric && digit;
    if (numeric && dot) {
        char buf[64];
        snprintf(buf, sizeof(buf), "%f", strtod(raw.c_str(), nullptr));
        c->VpiConstType(vpiRealConst);
        c->VpiSize(64);
        c->VpiValue(std::string("REAL:") + buf);
        c->VpiDecompile(buf);
        return c;
    }
    if (numeric) {
        bool neg = raw[0] == '-';
        c->VpiConstType(neg ? vpiIntConst : vpiUIntConst);
        c->VpiSize(64);
        c->VpiValue((neg ? "INT:" : "UINT:") + raw);
        c->VpiDecompile(raw);
        return c;
    }
    c->VpiConstType(vpiStringConst);
    c->VpiSize((int32_t)(raw.size() * 8));
    c->VpiValue("STRING:" + raw);
    c->VpiDecompile(raw);
    return c;
}

bool UhdmExporter::paramSubstRefused(const ParameterSymbol& ps) {
    if (!noParamSubst)
        return false;
    if (auto it = substRefusedCache.find(&ps); it != substRefusedCache.end())
        return it->second;
    // Provisional entry: a self-referential default answers "substitutable"
    // rather than recursing.
    substRefusedCache[&ps] = false;
    bool refused = false;
    if (auto* init = ps.getInitializer())
        refused = containsPatternOrConcat(*init);
    substRefusedCache[&ps] = refused;
    return refused;
}

bool UhdmExporter::paramValueUnavailable(const ParameterSymbol& ps) {
    if (!noParamSubst)
        return false;
    if (auto it = valueUnavailCache.find(&ps); it != valueUnavailCache.end())
        return it->second;
    if (!valueUnavailInFlight.insert(&ps).second)
        return false;
    bool bad = paramSubstRefused(ps);
    if (!bad)
        if (auto* init = ps.getInitializer())
            bad = exprValueUnavailable(*init);
    valueUnavailInFlight.erase(&ps);
    valueUnavailCache[&ps] = bad;
    return bad;
}

bool UhdmExporter::exprValueUnavailable(const Expression& e) {
    if (!noParamSubst)
        return false;
    bool bad = false;
    e.visit(makeVisitor(
        [&](auto& v, const NamedValueExpression& x) {
            if (x.symbol.kind == SymbolKind::Parameter &&
                paramValueUnavailable(x.symbol.as<ParameterSymbol>()))
                bad = true;
            v.visitDefault(x);
        },
        [&](auto& v, const HierarchicalValueExpression& x) {
            if (x.symbol.kind == SymbolKind::Parameter &&
                paramValueUnavailable(x.symbol.as<ParameterSymbol>()))
                bad = true;
            v.visitDefault(x);
        }));
    return bad;
}

// An assignment pattern collapses to a constant ONLY against a packed-VECTOR
// target (Surelog's expandPatternAssignment).  `logic [3:0] V = '{default:1}`
// and a typedef of one fold; `int P = '{default:1}` does not — nor do the
// packed-struct/union and unpacked-array targets, which the fold gate in
// emitParameters already refuses by their own clauses.  This helper names the
// targets whose non-folding PROPAGATES: an integer atom has no members, so a
// reader can only read the whole (valueless) parameter.  A packed STRUCT
// pattern param is deliberately excluded — a MEMBER read of one (V_STR.a + 1)
// does fold in the golden.
// The PARAMETER a bare reference names, or null when the expression is not a
// plain (non-selected, non-nested) parameter read.
static const ParameterSymbol* bareParamRef(const Expression& e) {
    const Expression& se = stripImplicitConv(e);
    const Symbol* sym = nullptr;
    if (se.kind == ExpressionKind::NamedValue)
        sym = &se.as<NamedValueExpression>().symbol;
    else if (se.kind == ExpressionKind::HierarchicalValue)
        sym = &se.as<HierarchicalValueExpression>().symbol;
    if (!sym || sym->kind != SymbolKind::Parameter)
        return nullptr;
    return &sym->as<ParameterSymbol>();
}

// NOTE (r9psc, ParamSubstituteComplex): Surelog's substitute-then-reduce hands
// back the referenced parameter's own value CONSTANT OBJECT, so any fold that
// reads a parameter inherits that constant's LITERAL FORM (VpiConstType +
// VpiDecompile) — only the SIZE is re-stamped by the reading context.  Walk
// bare parameter references down to the literal that produced the value; a
// CONDITIONAL operator is walked too because reduceExpr returns the SELECTED
// branch's object verbatim (`IS_XLEN64 = (XLEN==32) ? 1'b0 : 1'b1` reduces to
// the `1'b1` constant, BIN size 1 — not a UINT at 64).
static const Expression* srlgLitFormSrc(Compilation& comp, const Expression& e,
                                        int depth = 0) {
    if (depth > 8)
        return nullptr;
    const Expression& se = stripImplicitConv(e);
    if (se.kind == ExpressionKind::IntegerLiteral)
        return &se;
    if (auto* p = bareParamRef(se)) {
        if (auto* init = p->getInitializer())
            return srlgLitFormSrc(comp, *init, depth + 1);
        return nullptr;
    }
    if (se.kind == ExpressionKind::ConditionalOp) {
        auto& co = se.as<ConditionalExpression>();
        if (co.conditions.size() != 1 || co.conditions[0].pattern)
            return nullptr;
        ASTContext cx(comp.getRoot(), LookupLocation::max);
        ConstantValue pv = cx.tryEval(*co.conditions[0].expr);
        if (!pv || !pv.isInteger() || pv.integer().hasUnknown())
            return nullptr;
        return srlgLitFormSrc(comp,
                              pv.integer().as<uint64_t>().value_or(0) != 0
                                  ? co.left()
                                  : co.right(),
                              depth + 1);
    }
    return nullptr;
}

static bool patNoFoldTarget(const Type& t) {
    const Type& ct = t.getCanonicalType();
    return ct.isIntegral() && ct.kind != SymbolKind::PackedArrayType &&
           ct.kind != SymbolKind::PackedStructType &&
           ct.kind != SymbolKind::PackedUnionType;
}

bool UhdmExporter::patParamNoFold(const ParameterSymbol& ps) {
    if (auto it = patNoFoldCache.find(&ps); it != patNoFoldCache.end())
        return it->second;
    if (!patNoFoldInFlight.insert(&ps).second)
        return false;
    bool bad = false;
    if (auto* init = ps.getInitializer()) {
        auto& si = stripImplicitConv(*init);
        bool isPat = si.kind == ExpressionKind::SimpleAssignmentPattern ||
                     si.kind == ExpressionKind::StructuredAssignmentPattern ||
                     si.kind == ExpressionKind::ReplicatedAssignmentPattern;
        bad = (isPat && patNoFoldTarget(ps.getType())) ||
              (!isPat && patNoFoldTarget(ps.getType()) && exprPatNoFold(*init));
    }
    patNoFoldInFlight.erase(&ps);
    patNoFoldCache[&ps] = bad;
    return bad;
}

bool UhdmExporter::exprPatNoFold(const Expression& e) {
    bool bad = false;
    e.visit(makeVisitor(
        [&](auto& v, const NamedValueExpression& x) {
            if (x.symbol.kind == SymbolKind::Parameter &&
                patParamNoFold(x.symbol.as<ParameterSymbol>()))
                bad = true;
            v.visitDefault(x);
        },
        [&](auto& v, const HierarchicalValueExpression& x) {
            if (x.symbol.kind == SymbolKind::Parameter &&
                patParamNoFold(x.symbol.as<ParameterSymbol>()))
                bad = true;
            v.visitDefault(x);
        }));
    return bad;
}

bool UhdmExporter::exprElabParamUnreduced(const Expression& e) {
    auto chk = [&](const Symbol& sym) {
        if (sym.kind != SymbolKind::Parameter)
            return false;
        // AGGREGATE params are the exception, exactly as in paramDefRhsIsOp:
        // Surelog reduces a whole-struct read to its packed value even though
        // the param's own elab Rhs stays an assignment-pattern operation
        // (uhdm2rtlil StructLocalParam / StructParameter).
        switch (sym.getDeclaredType()->getType().getCanonicalType().kind) {
            case SymbolKind::PackedStructType:
            case SymbolKind::UnpackedStructType:
            case SymbolKind::PackedUnionType:
            case SymbolKind::UnpackedUnionType:
            case SymbolKind::FixedSizeUnpackedArrayType:
                return false;
            default:
                break;
        }
        auto it = elabParamPa.find(&sym);
        if (it == elabParamPa.end() || !it->second)
            return false;
        auto* r = it->second->Rhs();
        return r && r->UhdmType() != UHDM::uhdmconstant;
    };
    bool bad = false;
    e.visit(makeVisitor(
        [&](auto& v, const NamedValueExpression& x) {
            if (chk(x.symbol))
                bad = true;
            v.visitDefault(x);
        },
        [&](auto& v, const HierarchicalValueExpression& x) {
            if (chk(x.symbol))
                bad = true;
            v.visitDefault(x);
        }));
    return bad;
}

void UhdmExporter::bindOrParkParamTs(const ParameterSymbol& p,
                                     UHDM::ref_typespec* rt) {
    if (auto it = elabParamOwnTs.find(&p); it != elabParamOwnTs.end())
        rt->Actual_typespec(it->second);
    else
        pendingSubstOpTs.push_back({&p, rt});
}

bool UhdmExporter::paramDefRhsIsOp(const ParameterSymbol& ps) {
    auto* init = ps.getInitializer();
    if (!init)
        return false;
    // An AGGREGATE-typed parameter is the exception: Surelog INLINES a
    // struct/union param default at the reference (see the `inParamInit` arm in
    // emitExpr) instead of leaving the ref_obj, so `parameter p::cfg_t CFG =
    // p::CFG_DEF` folds even though CFG_DEF's own Rhs is a pattern operation
    // (uhdm2rtlil iface_scalar_localparam and its three siblings).
    switch (ps.getType().getCanonicalType().kind) {
        case SymbolKind::PackedStructType:
        case SymbolKind::UnpackedStructType:
        case SymbolKind::PackedUnionType:
        case SymbolKind::UnpackedUnionType:
            return false;
        default:
            break;
    }
    const Expression* e = &stripImplicitConv(*init);
    // 3'({3'h1}) — an explicit size/type cast wrapping a concatenation keeps
    // the whole vpiCastOp tree, so look through the cast.
    for (int g = 0; g < 8 && e->kind == ExpressionKind::Conversion &&
                    !e->as<ConversionExpression>().isImplicit();
         ++g)
        e = &stripImplicitConv(e->as<ConversionExpression>().operand());
    switch (e->kind) {
        case ExpressionKind::Concatenation:
        case ExpressionKind::Replication:
        case ExpressionKind::SimpleAssignmentPattern:
        case ExpressionKind::StructuredAssignmentPattern:
        case ExpressionKind::ReplicatedAssignmentPattern:
            return true;
        default:
            return false;
    }
}

const Expression& UhdmExporter::noSubstSourceExpr(const Expression& e,
                                                  const ParameterSymbol** hopped) {
    const Expression* cur = &stripImplicitConv(e);
    if (hopped)
        *hopped = nullptr;
    for (int hop = 0; hop < 8; hop++) {
        const Symbol* sym = nullptr;
        if (cur->kind == ExpressionKind::NamedValue)
            sym = &cur->as<NamedValueExpression>().symbol;
        else if (cur->kind == ExpressionKind::HierarchicalValue)
            sym = &cur->as<HierarchicalValueExpression>().symbol;
        if (!sym || sym->kind != SymbolKind::Parameter)
            break;
        auto& p = sym->as<ParameterSymbol>();
        // Surelog refuses to inline THIS one: the reference is the answer.
        if (paramSubstRefused(p))
            break;
        auto* init = p.getInitializer();
        if (!init)
            break;
        if (hopped)
            *hopped = &p;
        cur = &stripImplicitConv(*init);
    }
    return *cur;
}

// How many PACKED dimensions a parameter's type declares — the count Surelog's
// CompileHelper::isMultidimensional reads off the emitted logic/bit/
// packed_array typespec's `Ranges()`. `logic [19:0]` is 1, `logic [1:0][W-1:0]`
// is 2, a plain scalar 0.
static int packedDimCount(const Type& t) {
    int n = 0;
    const Type* ct = &t.getCanonicalType();
    while (ct->kind == SymbolKind::PackedArrayType) {
        n++;
        ct = &ct->as<PackedArrayType>().elementType.getCanonicalType();
    }
    return n;
}

// Whether the OUTERMOST packed range of a parameter's type runs downwards
// ([1:0]) — Surelog's CompileHelper::isDecreasingRange, which decides whether
// an elab pattern/concat Rhs gets its operands reversed.
static bool firstPackedRangeDecreasing(const Type& t) {
    const Type& ct = t.getCanonicalType();
    if (ct.kind != SymbolKind::PackedArrayType)
        return false;
    auto r = ct.as<PackedArrayType>().range;
    return r.left > r.right;
}

// Surelog's constant-function evaluator BAILS on a function whose body declares
// a LOCALPARAM at any block level: the elab param_assign then keeps a symbolic
// Rhs instead of the folded value (const_func_block_var). Plain block variables,
// named blocks and loops fold fine — the lifetime (static vs automatic) does
// NOT matter (asym_ram_sdp_*_wider's static `log2` folds).
static bool subroutineDeclaresParam(const Scope& sc) {
    for (auto& m : sc.members()) {
        if (m.kind == SymbolKind::Parameter || m.kind == SymbolKind::TypeParameter)
            return true;
        if (m.kind == SymbolKind::StatementBlock &&
            subroutineDeclaresParam(m.as<StatementBlockSymbol>()))
            return true;
    }
    return false;
}

// ---------------------------------------------------------------------------
// Surelog's ExprEval::evalStmt reduces an ASSIGNMENT's Rhs with pexpr = the
// ASSIGNMENT itself; in that context a bit/part SELECT of a FUNCTION-SCOPE
// object (formal arg or body variable) does NOT resolve to the value evalFunc
// stored for it, so the select stays symbolic. Operators that consume their
// operands through the SHARED invalidValue flag (&&, ||, &, |, ^, ~, !, ==, *,
// -, <<, ?:, and a select whose INDEX is such a select) then mark the whole
// evaluation invalid and the call stays a func_call. vpiAddOp and concat use
// LOCAL flags, so `x[i] + y[i]` / `{x[i],y[i]}` still fold, and a BARE select
// Rhs (`F = D[0]`) folds because setValueInInstance re-reduces with pexpr=null.
// The refusal is EXECUTION-dependent: the same statement inside a loop that
// never runs does not defeat the fold (func_upto: `for (i=LO; i+SPAN<HI; ...)`
// only has a live body for HI=2/LO=0/SPAN=1, which is exactly the 512 of 2144
// instances where Surelog keeps the func_call).
static const ValueSymbol* selectRootSym(const Expression& e) {
    const Expression* p = &e;
    for (int guard = 0; guard < 16; guard++) {
        switch (p->kind) {
            case ExpressionKind::ElementSelect:
                p = &p->as<ElementSelectExpression>().value();
                break;
            case ExpressionKind::RangeSelect:
                p = &p->as<RangeSelectExpression>().value();
                break;
            case ExpressionKind::MemberAccess:
                p = &p->as<MemberAccessExpression>().value();
                break;
            case ExpressionKind::Conversion:
                p = &p->as<ConversionExpression>().operand();
                break;
            case ExpressionKind::NamedValue:
                return &p->as<NamedValueExpression>().symbol;
            default:
                return nullptr;
        }
    }
    return nullptr;
}

static bool isFuncScopeValue(const ValueSymbol& sym, const SubroutineSymbol& sub) {
    if (sym.kind != SymbolKind::Variable && sym.kind != SymbolKind::FormalArgument)
        return false;
    const Scope* sc = sym.getParentScope();
    for (int guard = 0; sc && guard < 8; guard++) {
        auto& ss = sc->asSymbol();
        if (&ss == (const Symbol*)&sub)
            return true;
        if (ss.kind != SymbolKind::StatementBlock)
            return false;
        sc = ss.getParentScope();
    }
    return false;
}

static bool poisonsEvalFunc(const Expression& e, const SubroutineSymbol& sub) {
    bool found = false;
    std::function<void(const Expression&, bool)> walk = [&](const Expression& x,
                                                            bool poisonCtx) {
        if (found)
            return;
        switch (x.kind) {
            case ExpressionKind::ElementSelect: {
                auto& es = x.as<ElementSelectExpression>();
                if (poisonCtx) {
                    if (auto* rs = selectRootSym(es.value()))
                        if (isFuncScopeValue(*rs, sub)) {
                            found = true;
                            return;
                        }
                }
                walk(es.value(), poisonCtx);
                walk(es.selector(), true);
                return;
            }
            case ExpressionKind::RangeSelect: {
                auto& rs2 = x.as<RangeSelectExpression>();
                if (poisonCtx) {
                    if (auto* rs = selectRootSym(rs2.value()))
                        if (isFuncScopeValue(*rs, sub)) {
                            found = true;
                            return;
                        }
                }
                walk(rs2.value(), poisonCtx);
                walk(rs2.left(), true);
                walk(rs2.right(), true);
                return;
            }
            case ExpressionKind::BinaryOp: {
                auto& b = x.as<BinaryExpression>();
                bool p = poisonCtx || b.op != BinaryOperator::Add;
                walk(b.left(), p);
                walk(b.right(), p);
                return;
            }
            case ExpressionKind::UnaryOp: {
                auto& u = x.as<UnaryExpression>();
                bool p = poisonCtx || u.op != UnaryOperator::Plus;
                walk(u.operand(), p);
                return;
            }
            case ExpressionKind::ConditionalOp: {
                auto& c = x.as<ConditionalExpression>();
                for (auto& cond : c.conditions)
                    walk(*cond.expr, true);
                walk(c.left(), true);
                walk(c.right(), true);
                return;
            }
            case ExpressionKind::Concatenation: {
                for (auto* op : x.as<ConcatenationExpression>().operands())
                    walk(*op, poisonCtx);
                return;
            }
            case ExpressionKind::Replication: {
                auto& r = x.as<ReplicationExpression>();
                walk(r.count(), poisonCtx);
                walk(r.concat(), poisonCtx);
                return;
            }
            case ExpressionKind::Conversion:
                walk(x.as<ConversionExpression>().operand(), poisonCtx);
                return;
            case ExpressionKind::Assignment: {
                auto& a = x.as<AssignmentExpression>();
                walk(a.left(), poisonCtx);
                walk(a.right(), poisonCtx);
                return;
            }
            default:
                return;
        }
    };
    walk(e, false);
    return found;
}

// A for loop whose stop condition is FALSE on entry (evaluated with the
// initializers applied) never runs, so nothing in its body can defeat the fold.
static bool forLoopCanRun(const ForLoopStatement& fl, Compilation& comp) {
    if (!fl.stopExpr)
        return true;
    ASTContext actx(comp.getRoot(), LookupLocation::max);
    EvalContext ec(actx, EvalFlags::IsScript);
    ec.pushEmptyFrame();
    for (auto* lv : fl.loopVars) {
        ConstantValue iv = lv->getInitializer() ? lv->getInitializer()->eval(ec)
                                                : ConstantValue();
        if (!iv)
            return true;
        ec.createLocal(lv, std::move(iv));
    }
    for (auto* init : fl.initializers) {
        if (init->kind == ExpressionKind::Assignment) {
            auto& lhs = init->as<AssignmentExpression>().left();
            if (lhs.kind == ExpressionKind::NamedValue) {
                auto& vs = lhs.as<NamedValueExpression>().symbol;
                if (!ec.findLocal(&vs))
                    ec.createLocal(&vs, vs.getType().getDefaultValue());
            }
        }
        if (!init->eval(ec))
            return true;
    }
    ConstantValue cv = fl.stopExpr->eval(ec);
    if (!cv || !cv.isInteger() || cv.integer().hasUnknown())
        return true;
    return cv.isTrue();
}

static bool stmtPoisonsEvalFunc(const Statement& st, const SubroutineSymbol& sub,
                                Compilation& comp) {
    switch (st.kind) {
        case StatementKind::List:
            for (auto* s : st.as<StatementList>().list)
                if (stmtPoisonsEvalFunc(*s, sub, comp))
                    return true;
            return false;
        case StatementKind::Block:
            return stmtPoisonsEvalFunc(st.as<BlockStatement>().body, sub, comp);
        case StatementKind::ExpressionStatement: {
            auto& e = st.as<ExpressionStatement>().expr;
            if (e.kind == ExpressionKind::Assignment)
                return poisonsEvalFunc(e, sub);
            return false;
        }
        case StatementKind::Conditional: {
            auto& cs = st.as<ConditionalStatement>();
            // The CONDITION is reduced with pexpr=null (selects resolve there),
            // so only the TAKEN branch matters when the condition folds.
            int taken = -1;
            if (cs.conditions.size() == 1 && !cs.conditions[0].pattern) {
                ASTContext actx(comp.getRoot(), LookupLocation::max);
                EvalContext ec(actx, EvalFlags::IsScript);
                ec.pushEmptyFrame();
                ConstantValue cv = cs.conditions[0].expr->eval(ec);
                if (cv && cv.isInteger() && !cv.integer().hasUnknown())
                    taken = cv.isTrue() ? 0 : 1;
            }
            if (taken != 1 && stmtPoisonsEvalFunc(cs.ifTrue, sub, comp))
                return true;
            if (taken != 0 && cs.ifFalse &&
                stmtPoisonsEvalFunc(*cs.ifFalse, sub, comp))
                return true;
            return false;
        }
        case StatementKind::ForLoop: {
            auto& fl = st.as<ForLoopStatement>();
            if (!forLoopCanRun(fl, comp))
                return false;
            return stmtPoisonsEvalFunc(fl.body, sub, comp);
        }
        case StatementKind::WhileLoop:
            return stmtPoisonsEvalFunc(st.as<WhileLoopStatement>().body, sub, comp);
        case StatementKind::DoWhileLoop:
            return stmtPoisonsEvalFunc(st.as<DoWhileLoopStatement>().body, sub, comp);
        case StatementKind::RepeatLoop:
            return stmtPoisonsEvalFunc(st.as<RepeatLoopStatement>().body, sub, comp);
        case StatementKind::ForeverLoop:
            return stmtPoisonsEvalFunc(st.as<ForeverLoopStatement>().body, sub, comp);
        case StatementKind::ForeachLoop:
            return stmtPoisonsEvalFunc(st.as<ForeachLoopStatement>().body, sub, comp);
        case StatementKind::Case: {
            auto& cst = st.as<CaseStatement>();
            for (auto& item : cst.items)
                if (stmtPoisonsEvalFunc(*item.stmt, sub, comp))
                    return true;
            if (cst.defaultCase)
                return stmtPoisonsEvalFunc(*cst.defaultCase, sub, comp);
            return false;
        }
        default:
            return false;
    }
}

static bool subroutinePoisonsEvalFunc(const SubroutineSymbol& sub, Compilation& comp) {
    return stmtPoisonsEvalFunc(sub.getBody(), sub, comp);
}

// ---------------------------------------------------------------------------
// srlgEvalFuncBails: the THREE measured ExprEval bail rules that decide whether
// Surelog's top-view `int'(f())` cast folds to one constant (see the r4fold
// NOTE in ExprEmit.cpp for the ablation that produced them).
// ---------------------------------------------------------------------------

// Peel packed/unpacked array wrappers down to the (possibly enum) element type.
static const Type& peelToElem(const Type& t) {
    const Type* c = &t.getCanonicalType();
    for (int g = 0; g < 8 && c->isArray(); g++)
        if (auto* e = c->getArrayElementType())
            c = &e->getCanonicalType();
        else
            break;
    return *c;
}

// Bail 1: an enum whose member literals are written in a NON-BINARY base.
// Measured on one source with only the two member literals changed:
// 3'b000/3'b111 -> fold, 3'h0/3'h7 -> no fold; 4'h5/4'hA -> no fold,
// 4'b0101/4'b1010 -> fold. Auto-numbered members (no literal) never bail.
static bool enumHasBasedNonBinaryMember(const Type& t) {
    auto& el = peelToElem(t);
    if (!el.isEnum())
        return false;
    for (auto& ev : el.as<EnumType>().values()) {
        auto* dsyn = ev.getSyntax();
        if (!dsyn || dsyn->kind != syntax::SyntaxKind::Declarator)
            continue;
        auto* init = dsyn->as<syntax::DeclaratorSyntax>().initializer;
        if (!init || init->expr->kind != syntax::SyntaxKind::IntegerVectorExpression)
            continue;
        auto b = init->expr->as<syntax::IntegerVectorExpressionSyntax>().base;
        if (b && b.numericFlags().base() != LiteralBase::Binary)
            return true;
    }
    return false;
}

// Bail 2 helper: the constant element indices a body assigns into `var`, or
// "whole" when any assignment writes the variable outright.
struct LocalCoverage {
    bool whole = false;
    std::set<int32_t> elems;
};

static void collectLocalWrites(const Statement& st,
                               std::map<const Symbol*, LocalCoverage>& cov,
                               Compilation& comp) {
    st.visit(makeVisitor([&](auto& v, const AssignmentExpression& ax) {
        auto& lhs = stripImplicitConv(ax.left());
        if (lhs.kind == ExpressionKind::NamedValue) {
            cov[&lhs.as<NamedValueExpression>().symbol].whole = true;
        }
        else if (lhs.kind == ExpressionKind::ElementSelect) {
            auto& es = lhs.as<ElementSelectExpression>();
            auto& base = stripImplicitConv(es.value());
            if (base.kind == ExpressionKind::NamedValue) {
                auto& e = cov[&base.as<NamedValueExpression>().symbol];
                ASTContext actx(comp.getRoot(), LookupLocation::max);
                ConstantValue iv = actx.tryEval(es.selector());
                if (iv && iv.isInteger() && !iv.integer().hasUnknown()) {
                    if (auto i32 = iv.integer().as<int32_t>())
                        e.elems.insert(*i32);
                    else
                        e.whole = true;
                }
                else
                    e.whole = true;
            }
            else if (auto* rs = selectRootSym(es.value()))
                // A nested select (result[0][1:0]) leaves the outer element
                // only partly written — record nothing, so the coverage check
                // below sees it as unassigned.
                (void)cov[rs];
        }
        else if (auto* rs = selectRootSym(lhs))
            (void)cov[rs];
        v.visitDefault(ax);
    }));
}

// Bail 3: the RETURN expression is a bit/part-select off a function-scope
// local (BitSelectPartSelectInFunction, even with a sized argument).
static bool returnsSelectOfLocal(const Statement& st, const SubroutineSymbol& sub) {
    bool bad = false;
    st.visit(makeVisitor([&](auto& v, const ReturnStatement& rs) {
        if (rs.expr) {
            auto& re = stripImplicitConv(*rs.expr);
            if (re.kind == ExpressionKind::ElementSelect ||
                re.kind == ExpressionKind::RangeSelect)
                if (auto* root = selectRootSym(re))
                    if (isFuncScopeValue(*root, sub))
                        bad = true;
        }
        v.visitDefault(rs);
    }));
    return bad;
}

// True when Surelog's ExprEval REDUCES this const function to one constant.
bool UhdmExporter::srlgEvalFuncFolds(const SubroutineSymbol& sub) {
    auto& body = sub.getBody();
    if (subroutinePoisonsEvalFunc(sub, comp))
        return false;
    if (returnsSelectOfLocal(body, sub))
        return false;
    if (enumHasBasedNonBinaryMember(sub.getReturnType()))
        return false;
    // Bail 2: every function-scope local must be FULLY written. An unwritten
    // local, or a packed/unpacked array with only some elements assigned
    // (ReturnEnumArray writes out[0] but not out[1]), bails.
    std::map<const Symbol*, LocalCoverage> cov;
    collectLocalWrites(body, cov, comp);
    for (auto& m : sub.members()) {
        if (m.kind != SymbolKind::Variable)
            continue;
        auto& vs = m.as<VariableSymbol>();
        if (vs.name == sub.name) // the implicit return variable
            continue;
        if (enumHasBasedNonBinaryMember(vs.getType()))
            return false;
        auto it = cov.find(&m);
        if (it == cov.end())
            return false;
        if (it->second.whole)
            continue;
        auto& ct = vs.getType().getCanonicalType();
        if (!ct.isArray())
            return false;
        auto fr = ct.getFixedRange();
        for (int32_t i = std::min(fr.left, fr.right);
             i <= std::max(fr.left, fr.right); i++)
            if (!it->second.elems.count(i))
                return false;
    }
    return true;
}

// ---------------------------------------------------------------------------
// EvalFunc member-assignment leftovers
//
// `ExprEval::setValueInInstance` (UHDM ExprEval.cpp ~5074 and ~5385) has one
// arm for a hier_path LHS: it decodes the path to the `typespec_member` object
// and calls `Actual_value(rhs)` on it.  The member belongs to the SHARED
// struct typespec, so evaluating a const function that writes its result
// member by member leaves the produced constants ON THE TYPEDEF.
//
// FuncStructValSimple's `build_config_func` is the shape: a fn-scope local of
// the return struct type, three `cfg.<member> = <expr>` writes, `return cfg`.
// Golden (measured with tools/probe/r9fsvs.cpp, which prints object identity
// the abbreviated uhdm-dump hides) stamps
//   config_pkg::cva6_cfg_t in uhdmtopPackages   -> stamped
//   work@top.CVA6Cfg's own struct ts copy       -> stamped
//   config_pkg::cva6_cfg_t in uhdmallPackages   -> CLEAN
// i.e. every view that resolved the typedef after elaboration, never the def
// package listing.  Encoding follows the ASSIGNMENT RHS, not the member type:
//   `= 32`                      -> UINT:32  size 64  (plain literal fold)
//   `= <ternary>`               -> INT:2    size 64  (ExprEval's
//                                  vpiConditionOp arm always re-wraps INT/64)
//   `= CVA6Cfg.PMPCfgRstVal`    -> the CALLER's own 1024-bit BIN constant,
//                                  size = member width, carrying a ts ref
// The VALUES are the caller's, so they come from slicing the parameter value
// slang already folded for the call — no second evaluator is needed.
const std::vector<UhdmExporter::SrlgMemLeft>*
UhdmExporter::srlgEvalFuncMemberLeftovers(const SubroutineSymbol& sub) {
    if (auto it = memLeftCache.find(&sub); it != memLeftCache.end())
        return it->second.empty() ? nullptr : &it->second;
    std::vector<SrlgMemLeft> out;
    // An empty cache entry means "measured, does not qualify".
    memLeftCache[&sub];
    auto fail = [&]() -> const std::vector<SrlgMemLeft>* {
        memLeftCache[&sub].clear();
        return nullptr;
    };
    auto& rt = sub.getReturnType().getCanonicalType();
    if (rt.kind != SymbolKind::PackedStructType)
        return fail();
    // The fn-scope local the body builds and returns.
    const Symbol* local = nullptr;
    {
        const Expression* retExpr = nullptr;
        sub.getBody().visit(makeVisitor([&](auto& v, const ReturnStatement& r) {
            if (r.expr)
                retExpr = r.expr;
            v.visitDefault(r);
        }));
        if (!retExpr)
            return fail();
        auto& re = stripImplicitConv(*retExpr);
        if (re.kind != ExpressionKind::NamedValue)
            return fail();
        local = &re.as<NamedValueExpression>().symbol;
        if (local->kind != SymbolKind::Variable ||
            &local->as<VariableSymbol>().getType().getCanonicalType() != &rt)
            return fail();
    }
    // Every top-level statement must be a `<local>.<member> = <expr>` write
    // (declaration of the local and the return are already accounted for).
    // Anything else — a loop, a nested call, a whole-struct assignment — is
    // outside the modelled subset.
    bool bad = false;
    std::map<std::string, SrlgMemLeftEnc> enc;
    sub.getBody().visit(makeVisitor([&](auto& v, const AssignmentExpression& a) {
        auto& lhs = stripImplicitConv(a.left());
        if (lhs.kind != ExpressionKind::MemberAccess) {
            // The implicit `<fnname> = <expr>` return write is allowed only
            // through the ReturnStatement form handled above.
            bad = true;
            v.visitDefault(a);
            return;
        }
        auto& ma = lhs.as<MemberAccessExpression>();
        auto& base = stripImplicitConv(ma.value());
        if (base.kind != ExpressionKind::NamedValue ||
            &base.as<NamedValueExpression>().symbol != local) {
            bad = true;
            v.visitDefault(a);
            return;
        }
        auto& rhs = stripImplicitConv(a.right());
        SrlgMemLeftEnc e = SrlgMemLeftEnc::Uint;
        if (rhs.kind == ExpressionKind::ConditionalOp)
            e = SrlgMemLeftEnc::Int;
        else if (rhs.kind == ExpressionKind::MemberAccess ||
                 rhs.kind == ExpressionKind::Concatenation) {
            // Only the WIDE (>64b) member-copy shape is measured: it reuses
            // the caller's own BIN constant.  A narrow copy has no golden yet,
            // so keep it on the plain UINT fold.
            e = ma.type->getBitWidth() > 64 ? SrlgMemLeftEnc::Bin
                                           : SrlgMemLeftEnc::Uint;
        }
        enc[std::string(ma.member.name)] = e;
        v.visitDefault(a);
    }));
    if (bad || enc.empty())
        return fail();
    for (auto& f : rt.as<PackedStructType>().membersOfType<FieldSymbol>()) {
        auto it = enc.find(std::string(f.name));
        if (it == enc.end())
            return fail(); // a member the body never writes: unmodelled
        out.push_back({std::string(f.name), it->second});
    }
    if (out.size() != enc.size())
        return fail();
    memLeftCache[&sub] = out;
    return &memLeftCache[&sub];
}

const SubroutineSymbol* UhdmExporter::memLeftInitCall(const Expression& init) {
    auto& si = stripImplicitConv(init);
    if (si.kind != ExpressionKind::Call)
        return nullptr;
    auto& ce = si.as<CallExpression>();
    if (ce.isSystemCall())
        return nullptr;
    auto* sub = std::get_if<const SubroutineSymbol*>(&ce.subroutine);
    if (!sub || !*sub)
        return nullptr;
    return srlgEvalFuncMemberLeftovers(**sub) ? *sub : nullptr;
}

static UHDM::constant* makeMemLeftConst(UHDM::Serializer& s,
                                        const FieldSymbol& fld,
                                        const slang::SVInt& whole,
                                        SrlgMemLeftEnc enc) {
    uint64_t w = fld.getType().getBitWidth();
    if (w == 0 || fld.bitOffset + w > whole.getBitWidth())
        return nullptr;
    slang::SVInt slice = whole.slice((int32_t)(fld.bitOffset + w - 1),
                                     (int32_t)fld.bitOffset);
    if (slice.hasUnknown())
        return nullptr;
    auto* c = s.MakeConstant();
    if (enc == SrlgMemLeftEnc::Bin) {
        std::string bits;
        bits.reserve((size_t)w);
        for (int64_t i = (int64_t)w - 1; i >= 0; i--)
            bits += (slice[(int32_t)i] == slang::logic_t(1)) ? '1' : '0';
        c->VpiValue("BIN:" + bits);
        c->VpiDecompile(bits);
        c->VpiSize((int32_t)w);
        c->VpiConstType(vpiBinaryConst);
        // The caller's wide constant carries a ts ref to a bare int_typespec
        // (golden: `ref_typespec -> int_typespec` with no range).
        auto* rt = s.MakeRef_typespec();
        rt->VpiParent(c);
        rt->Actual_typespec(s.MakeInt_typespec());
        c->Typespec(rt);
        return c;
    }
    std::string dg = slice.toString(LiteralBase::Decimal, false);
    c->VpiDecompile(dg);
    c->VpiSize(64);
    if (enc == SrlgMemLeftEnc::Int) {
        c->VpiValue("INT:" + dg);
        c->VpiConstType(vpiIntConst);
    }
    else {
        c->VpiValue("UINT:" + dg);
        c->VpiConstType(vpiUIntConst);
    }
    return c;
}

// `<param>.<member>` where <param>'s value came from a member-by-member const
// function: returns the leftover encoding recorded for that member.
std::optional<SrlgMemLeftEnc> UhdmExporter::memLeftReadEnc(
    const Expression& e) {
    auto& se = stripImplicitConv(e);
    if (se.kind != ExpressionKind::MemberAccess)
        return std::nullopt;
    auto& ma = se.as<MemberAccessExpression>();
    auto& base = stripImplicitConv(ma.value());
    if (base.kind != ExpressionKind::NamedValue)
        return std::nullopt;
    auto& bs = base.as<NamedValueExpression>().symbol;
    if (bs.kind != SymbolKind::Parameter)
        return std::nullopt;
    auto* pin = bs.as<ParameterSymbol>().getInitializer();
    if (!pin)
        return std::nullopt;
    auto* sub = memLeftInitCall(*pin);
    if (!sub)
        return std::nullopt;
    auto* lo = srlgEvalFuncMemberLeftovers(*sub);
    if (!lo)
        return std::nullopt;
    for (auto& m : *lo)
        if (m.name == ma.member.name)
            return m.enc;
    return std::nullopt;
}

bool UhdmExporter::memLeftIntRead(const Expression& init) {
    auto e = memLeftReadEnc(init);
    return e && *e == SrlgMemLeftEnc::Int;
}

// Surelog's DESIGN elaboration runs long before the EvalFunc leftovers exist,
// so a generate condition reading an override that resolves through one never
// folds and the instance is emitted with NO gen_scope_array at all — golden's
// `work@top.u1` (INPUT_WIDTH = CVA6Cfg.INSTR_PER_FETCH = 2) carries none, even
// though `INPUT_WIDTH == 2` selects `leaf_node`.
bool UhdmExporter::memLeftGenScopeBlocked(const InstanceBodySymbol& body) {
    for (auto& mem : body.members()) {
        if (mem.kind != SymbolKind::Parameter)
            continue;
        auto& ps = mem.as<ParameterSymbol>();
        if (!isOverriddenParam(ps))
            continue;
        if (auto* pin = ps.getInitializer())
            if (memLeftReadEnc(*pin))
                return true;
    }
    return false;
}

// Stamps the recorded leftovers onto every struct typespec reachable from the
// ELABORATED views (uhdmtopPackages / uhdmtopModules).  The def-package
// listing is never walked, which is exactly the split golden shows.
void UhdmExporter::stampEvalFuncLeftovers(UHDM::design* d) {
    for (auto& [sv, up] : memLeftStructVars) {
        if (!sv->Typespec() || sv->Typespec()->Actual_typespec())
            continue;
        if (up->Typespec() && up->Typespec()->Actual_typespec())
            sv->Typespec()->Actual_typespec(
                up->Typespec()->Actual_typespec());
    }
    if (memLeftStamps.empty())
        return;
    std::set<const UHDM::struct_typespec*> done;
    auto stamp = [&](UHDM::typespec* ts) {
        if (!ts || ts->UhdmType() != UHDM::uhdmstruct_typespec)
            return;
        auto* sts = (UHDM::struct_typespec*)ts;
        if (!sts->Members() || !done.insert(sts).second)
            return;
        for (auto& st : memLeftStamps) {
            if (sts->Members()->size() != st.names.size())
                continue;
            bool match = true;
            for (size_t i = 0; i < st.names.size(); i++)
                if ((*sts->Members())[i]->VpiName() != st.names[i]) {
                    match = false;
                    break;
                }
            if (!match)
                continue;
            for (size_t i = 0; i < st.names.size(); i++) {
                auto* tm = (*sts->Members())[i];
                if (!tm->Actual_value())
                    tm->Actual_value(st.values[i]);
            }
            return;
        }
    };
    auto tsOf = [](UHDM::ref_typespec* rt) -> UHDM::typespec* {
        return rt ? rt->Actual_typespec() : nullptr;
    };
    if (auto* tp = d->TopPackages())
        for (auto* p : *tp) {
            if (p->Typespecs())
                for (auto* t : *p->Typespecs())
                    stamp(t);
            if (p->Parameters())
                for (auto* pa : *p->Parameters())
                    if (pa->UhdmType() == UHDM::uhdmparameter)
                        stamp(tsOf(((UHDM::parameter*)pa)->Typespec()));
        }
    std::function<void(UHDM::module_inst*)> walk = [&](UHDM::module_inst* m) {
        if (m->Parameters())
            for (auto* pa : *m->Parameters())
                if (pa->UhdmType() == UHDM::uhdmparameter)
                    stamp(tsOf(((UHDM::parameter*)pa)->Typespec()));
        if (m->Modules())
            for (auto* sub : *m->Modules())
                walk(sub);
    };
    if (auto* tm = d->TopModules())
        for (auto* m : *tm)
            walk(m);
}

// Surelog INLINES a foldable const function's body, so the folded constant is
// encoded by the same rules a plain expression fold uses — driven by the RETURN
// assignment's expression kind: a CONCAT body ({..}) folds full-width BIN, a
// comparison/logical body folds BIN with DECIMAL digits, a TERNARY body folds
// signed INT, everything else UINT.
enum class ConstCallEnc { Uint, BoolBin, ConcatBin, Int };

static ConstCallEnc constCallEncoding(const SubroutineSymbol& sub) {
    ConstCallEnc enc = ConstCallEnc::Uint;
    auto classify = [&](const Expression& rhs) {
        auto& se = stripImplicitConv(rhs);
        if (se.kind == ExpressionKind::Concatenation)
            enc = ConstCallEnc::ConcatBin;
        // A TERNARY body reduces through ExprEval's vpiConditionOp arm, which
        // unconditionally re-wraps the selected branch as `INT:<val>` at size
        // 64 with vpiIntConst (UHDM ExprEval.cpp, reduceExpr vpiConditionOp)
        // — EvalFunc's vbits vs its loop-bodied log2/log2_2 siblings.
        else if (se.kind == ExpressionKind::ConditionalOp)
            enc = ConstCallEnc::Int;
        else if (se.kind == ExpressionKind::BinaryOp) {
            auto bop = se.as<BinaryExpression>().op;
            if (OpInfo::isComparison(bop) || bop == BinaryOperator::LogicalAnd ||
                bop == BinaryOperator::LogicalOr ||
                bop == BinaryOperator::LogicalImplication ||
                bop == BinaryOperator::LogicalEquivalence)
                enc = ConstCallEnc::BoolBin;
            // ExprEval's `-` / `*` / `/` / `%` arms build their result with a
            // hardcoded `INT:` + vpiIntConst at size 64 (UHDM ExprEval.cpp
            // vpiSubOp/vpiMultOp/vpiDivOp/vpiModOp) — only `+` decides
            // signedness from its operands, and it comes out unsigned unless
            // one of them was already signed.  That constant survives only
            // when the return variable has no width of its own to re-encode
            // it at, i.e. for a PREDEFINED-integer return — the same seam the
            // width rule below rides.  `function integer num_out` with
            // `num_out = num_out * 2` folds INT:4 (EvalFuncCont); `function
            // [31:0] pow2` with `pow2 = 2 * pow2` still folds UINT
            // (RepeatStmt, measured as a regression and re-gated).
            else if (sub.getReturnType().isPredefinedInteger() &&
                     (bop == BinaryOperator::Subtract ||
                      bop == BinaryOperator::Multiply ||
                      bop == BinaryOperator::Divide ||
                      bop == BinaryOperator::Mod))
                enc = ConstCallEnc::Int;
            else
                enc = ConstCallEnc::Uint;
        }
        else
            enc = ConstCallEnc::Uint;
    };
    sub.getBody().visit(makeVisitor([&](auto& v, const AssignmentExpression& a) {
        auto& lhs = a.left();
        if (sub.returnValVar && lhs.kind == ExpressionKind::NamedValue &&
            &lhs.as<NamedValueExpression>().symbol ==
                (const Symbol*)sub.returnValVar)
            classify(a.right());
        v.visitDefault(a);
    }));
    // A `return <expr>;` body carries no assignment to the return var, so the
    // visitor above never sees it; classify the TERNARY case here (the only
    // encoding ExprEval forces regardless of the branch expressions).
    sub.getBody().visit(makeVisitor([&](auto& v, const ReturnStatement& r) {
        if (r.expr && stripImplicitConv(*r.expr).kind ==
                          ExpressionKind::ConditionalOp)
            enc = ConstCallEnc::Int;
        v.visitDefault(r);
    }));
    return enc;
}

// A bare typespec of a predefined integer type, located at the declaring
// symbol's type keyword. Surelog's copy carries no vpiSigned (the io_decl /
// local typespec it hands back is the unsigned-looking one) — PreprocFunc.
UHDM::typespec* UhdmExporter::predefIntTypespec(const Type& ct,
                                                const Symbol& sym) {
    if (ct.kind != SymbolKind::PredefinedIntegerType)
        return nullptr;
    UHDM::typespec* ts = nullptr;
    switch (ct.as<PredefinedIntegerType>().integerKind) {
        case PredefinedIntegerType::Integer:
            ts = s.MakeInteger_typespec();
            break;
        case PredefinedIntegerType::Int:
            ts = s.MakeInt_typespec();
            break;
        case PredefinedIntegerType::ShortInt:
            ts = s.MakeShort_int_typespec();
            break;
        case PredefinedIntegerType::LongInt:
            ts = s.MakeLong_int_typespec();
            break;
        case PredefinedIntegerType::Byte:
            ts = s.MakeByte_typespec();
            break;
        case PredefinedIntegerType::Time:
            ts = s.MakeTime_typespec();
            break;
        default:
            return nullptr;
    }
    if (auto* dt = sym.getDeclaredType())
        if (auto* tsyn = dt->getTypeSyntax())
            setLoc(ts, tsyn->sourceRange());
    return ts;
}

// ---------------------------------------------------------------------------
// Surelog's constant-function evaluator (UHDM ExprEval) does NOT model LRM
// expression widths: every intermediate value is a 64-bit word, and `>>`/`>>>`
// are BOTH ((uint64_t)val0 >> val1) on that word (ExprEval reduceExpr,
// vpiRShiftOp), while a ternary reduces to `INT:<selected branch>` — a SIGNED
// 64-bit constant. So a signed-negative operand that the LRM would have
// coerced to a NARROWER UNSIGNED type is SIGN-EXTENDED to 64 bits before the
// shift, making the shift read as arithmetic:
//     func = {(inp == 0 ? -1 : func(inp - 1)) >> 2};   // func_tern_hint
// LRM: the ternary is 32-bit UNSIGNED (one arm is func's unsigned 31-bit
// return), so -1 >> 2 = 0x3FFFFFFF. Surelog: (uint64_t)-1 >> 2 = 0x3FFF..FF,
// masked to the 31-bit return width (evalFunc masks the func value to the
// return logic_typespec's size) = 0x7FFFFFFF — and every recursion level
// re-masks, so the whole A/B/C/D chain sits one bit off.
// srlgFoldCall replays that 64-bit model over the narrow statement subset
// where it can matter; it returns nullopt for anything it does not model, so
// slang's LRM value stays authoritative for every other fold.

// Is this parameter's own DECLARED default a string literal (parameter X =
// "FOO")? Surelog types such a parameter from the module DEFINITION, so the
// answer must not depend on an instance override — hence the declarator
// syntax rather than getInitializer(), which an override replaces.
static bool declaredStringLiteralParam(const ParameterSymbol& ps) {
    if (auto* dsyn = ps.getSyntax())
        if (auto* decl = dsyn->as_if<syntax::DeclaratorSyntax>())
            return decl->initializer &&
                   decl->initializer->expr->kind ==
                       syntax::SyntaxKind::StringLiteralExpression;
    return false;
}

// int64 view of a slang constant under Surelog's get_value(): a SIGNED value
// keeps its sign (INT:), an unsigned one is zero-extended (UINT:).
static std::optional<int64_t> srlgWord(const ConstantValue& cv) {
    if (!cv.isInteger())
        return std::nullopt;
    const SVInt& iv = cv.integer();
    if (iv.hasUnknown() || iv.getBitWidth() > 64)
        return std::nullopt;
    if (iv.isSigned()) {
        if (auto v = iv.as<int64_t>())
            return *v;
        return std::nullopt;
    }
    if (auto v = iv.as<uint64_t>())
        return (int64_t)*v;
    return std::nullopt;
}

// Does Surelog give this type a logic_typespec whose width MASKS the value on
// function return / formal-arg binding? A predefined integer (integer/int/...)
// gets an int_typespec and is NOT masked (evalFunc only masks logic_typespec).
static bool srlgMaskWidth(const Type& t, uint64_t& w) {
    if (!t.isIntegral() || t.isPredefinedInteger() || t.isEnum())
        return false;
    auto& ct = t.getCanonicalType();
    if (ct.kind != SymbolKind::ScalarType && ct.kind != SymbolKind::PackedArrayType)
        return false;
    w = t.getBitWidth();
    return w > 0 && w < 64;
}

class SrlgFold {
public:
    // Replays Surelog's 64-bit fold of a user function call; nullopt when the
    // body (or any operand) falls outside the modelled subset.
    std::optional<int64_t> call(const SubroutineSymbol& sub,
                                std::span<const Expression* const> args) {
        std::vector<int64_t> argv;
        for (auto* a : args) {
            auto v = evalExpr(*a);
            if (!v)
                return std::nullopt;
            argv.push_back(*v);
        }
        return invoke(sub, argv);
    }

    // The expression whose value the OUTERMOST frame actually returned (the
    // last executed `<retvar> = ...` / `return ...`). Surelog's EvalFunc hands
    // the caller that expression's own constant object, so its encoding — not
    // the function's return type — governs the inlined fold.
    const Expression* resultSource() const { return topRetSrc; }

private:
    std::map<const Symbol*, int64_t> env;
    const Symbol* retVar = nullptr;
    const Expression* retSrc = nullptr;
    const Expression* topRetSrc = nullptr;
    int depth = 0;
    bool bad = false;

    static int64_t maskTo(int64_t v, uint64_t w, bool sgn) {
        uint64_t mask = (1ull << w) - 1;
        uint64_t t = (uint64_t)v & mask;
        if (sgn && ((t >> (w - 1)) & 1))
            t |= ~mask;
        return (int64_t)t;
    }

    std::optional<int64_t> invoke(const SubroutineSymbol& sub,
                                  const std::vector<int64_t>& argv) {
        auto formals = sub.getArguments();
        if (bad || ++depth > 64 || !sub.returnValVar ||
            formals.size() != argv.size()) {
            bad = true;
            depth--;
            return std::nullopt;
        }
        auto savedEnv = env;
        auto* savedRet = retVar;
        auto* savedSrc = retSrc;
        env.clear();
        retSrc = nullptr;
        retVar = (const Symbol*)sub.returnValVar;
        for (size_t i = 0; i < formals.size(); i++) {
            if (formals[i]->direction != ArgumentDirection::In) {
                bad = true;
                break;
            }
            int64_t v = argv[i];
            uint64_t fw = 0;
            if (srlgMaskWidth(formals[i]->getType(), fw))
                v = maskTo(v, fw, formals[i]->getType().isSigned());
            env[formals[i]] = v;
        }
        std::optional<int64_t> out;
        if (!bad) {
            bool returned = false;
            evalStmt(sub.getBody(), returned);
            auto it = env.find(retVar);
            if (!bad && it != env.end()) {
                int64_t v = it->second;
                uint64_t rw = 0;
                if (srlgMaskWidth(sub.getReturnType(), rw))
                    v = (int64_t)((uint64_t)v & ((1ull << rw) - 1));
                out = v;
            }
            else
                bad = true;
        }
        if (depth == 1 && !bad)
            topRetSrc = retSrc;
        env = savedEnv;
        retVar = savedRet;
        retSrc = savedSrc;
        depth--;
        return bad ? std::nullopt : out;
    }

    void evalStmt(const Statement& st, bool& returned) {
        if (bad || returned)
            return;
        switch (st.kind) {
            case StatementKind::Empty:
                return;
            case StatementKind::List:
                for (auto* s2 : st.as<StatementList>().list) {
                    evalStmt(*s2, returned);
                    if (bad || returned)
                        return;
                }
                return;
            case StatementKind::Block:
                evalStmt(st.as<BlockStatement>().body, returned);
                return;
            case StatementKind::VariableDeclaration: {
                auto& vs = st.as<VariableDeclStatement>().symbol;
                if (auto* init = vs.getInitializer()) {
                    if (auto v = evalExpr(*init))
                        env[&vs] = *v;
                    else
                        bad = true;
                }
                return;
            }
            case StatementKind::ExpressionStatement: {
                auto& e = st.as<ExpressionStatement>().expr;
                if (e.kind != ExpressionKind::Assignment) {
                    bad = true;
                    return;
                }
                auto& asn = e.as<AssignmentExpression>();
                auto& lhs = stripImplicitConv(asn.left());
                if (asn.isCompound() || lhs.kind != ExpressionKind::NamedValue) {
                    bad = true;
                    return;
                }
                if (auto v = evalExpr(asn.right())) {
                    auto& tsym = lhs.as<NamedValueExpression>().symbol;
                    env[&tsym] = *v;
                    if (&tsym == retVar)
                        retSrc = &asn.right();
                }
                else
                    bad = true;
                return;
            }
            case StatementKind::Return: {
                auto* re = st.as<ReturnStatement>().expr;
                if (!re) {
                    bad = true;
                    return;
                }
                if (auto v = evalExpr(*re)) {
                    env[retVar] = *v;
                    retSrc = re;
                    returned = true;
                }
                else
                    bad = true;
                return;
            }
            case StatementKind::Conditional: {
                auto& cs = st.as<ConditionalStatement>();
                if (cs.conditions.size() != 1 || cs.conditions[0].pattern) {
                    bad = true;
                    return;
                }
                auto c = evalExpr(*cs.conditions[0].expr);
                if (!c) {
                    bad = true;
                    return;
                }
                if (*c != 0)
                    evalStmt(cs.ifTrue, returned);
                else if (cs.ifFalse)
                    evalStmt(*cs.ifFalse, returned);
                return;
            }
            default:
                bad = true;
                return;
        }
    }

    std::optional<int64_t> evalExpr(const Expression& e) {
        if (bad)
            return std::nullopt;
        switch (e.kind) {
            case ExpressionKind::Conversion: {
                auto& cv = e.as<ConversionExpression>();
                if (!cv.isImplicit()) // vpiCastOp: not modelled
                    break;
                return evalExpr(cv.operand());
            }
            case ExpressionKind::IntegerLiteral:
                return srlgWord(ConstantValue(e.as<IntegerLiteral>().getValue()));
            case ExpressionKind::NamedValue: {
                auto& sym = e.as<NamedValueExpression>().symbol;
                auto it = env.find(&sym);
                if (it != env.end())
                    return it->second;
                if (sym.kind == SymbolKind::Parameter)
                    return srlgWord(sym.as<ParameterSymbol>().getValue());
                break;
            }
            case ExpressionKind::UnaryOp: {
                auto& uo = e.as<UnaryExpression>();
                auto v = evalExpr(uo.operand());
                if (!v)
                    break;
                switch (uo.op) {
                    case UnaryOperator::Plus:
                        return *v;
                    case UnaryOperator::Minus:
                        return -*v;
                    case UnaryOperator::LogicalNot:
                        return *v == 0 ? 1 : 0;
                    default:
                        break;
                }
                break;
            }
            case ExpressionKind::ConditionalOp: {
                auto& co = e.as<ConditionalExpression>();
                if (co.conditions.size() != 1 || co.conditions[0].pattern)
                    break;
                auto c = evalExpr(*co.conditions[0].expr);
                if (!c)
                    break;
                // Surelog reduces the ternary to INT:<selected branch>, keeping
                // that branch's SIGNEDNESS (no LRM common type).
                return evalExpr(*c != 0 ? co.left() : co.right());
            }
            case ExpressionKind::Concatenation: {
                // A 1-element concat passes the value through; a wider one
                // needs Surelog's per-operand VpiSize model (not replayed).
                auto ops = e.as<ConcatenationExpression>().operands();
                if (ops.size() == 1)
                    return evalExpr(*ops[0]);
                break;
            }
            case ExpressionKind::Call: {
                auto& ce = e.as<CallExpression>();
                if (ce.isSystemCall())
                    break;
                if (auto sp = std::get_if<const SubroutineSymbol*>(&ce.subroutine))
                    return call(**sp, ce.arguments());
                break;
            }
            case ExpressionKind::BinaryOp: {
                auto& bo = e.as<BinaryExpression>();
                auto l = evalExpr(bo.left());
                if (!l)
                    break;
                auto r = evalExpr(bo.right());
                if (!r)
                    break;
                uint64_t ul = (uint64_t)*l, ur = (uint64_t)*r;
                switch (bo.op) {
                    case BinaryOperator::Add:
                        return (int64_t)(ul + ur);
                    case BinaryOperator::Subtract:
                        return (int64_t)(ul - ur);
                    case BinaryOperator::Multiply:
                        return (int64_t)(ul * ur);
                    case BinaryOperator::Divide:
                        if (*r == 0 || *l < 0 || *r < 0)
                            break;
                        return *l / *r;
                    case BinaryOperator::Mod:
                        if (*r == 0 || *l < 0 || *r < 0)
                            break;
                        return *l % *r;
                    case BinaryOperator::BinaryAnd:
                        return (int64_t)(ul & ur);
                    case BinaryOperator::BinaryOr:
                        return (int64_t)(ul | ur);
                    case BinaryOperator::BinaryXor:
                        return (int64_t)(ul ^ ur);
                    case BinaryOperator::LogicalAnd:
                        return (*l != 0 && *r != 0) ? 1 : 0;
                    case BinaryOperator::LogicalOr:
                        return (*l != 0 || *r != 0) ? 1 : 0;
                    case BinaryOperator::Equality:
                        return *l == *r ? 1 : 0;
                    case BinaryOperator::Inequality:
                        return *l != *r ? 1 : 0;
                    case BinaryOperator::GreaterThan:
                        return *l > *r ? 1 : 0;
                    case BinaryOperator::GreaterThanEqual:
                        return *l >= *r ? 1 : 0;
                    case BinaryOperator::LessThan:
                        return *l < *r ? 1 : 0;
                    case BinaryOperator::LessThanEqual:
                        return *l <= *r ? 1 : 0;
                    // vpiRShiftOp and vpiArithRShiftOp share ExprEval's
                    // ((uint64_t)val0 >> val1) — the 64-bit word is what
                    // decides whether the sign bit propagates.
                    case BinaryOperator::LogicalShiftRight:
                    case BinaryOperator::ArithmeticShiftRight:
                        if (ur >= 64)
                            break;
                        return (int64_t)(ul >> ur);
                    case BinaryOperator::LogicalShiftLeft:
                    case BinaryOperator::ArithmeticShiftLeft:
                        if (ur >= 64)
                            break;
                        return (int64_t)(ul << ur);
                    default:
                        break;
                }
                break;
            }
            default:
                break;
        }
        bad = true;
        return std::nullopt;
    }
};

// Surelog's 64-bit fold can only DIVERGE from the LRM fold where a `>>`/`>>>`
// left operand is NARROWER than 64 bits (so the LRM shifts within that width)
// yet holds a SIGNED subexpression, whose negative value Surelog sign-extends
// to 64 bits before shifting. Its own LRM signedness is irrelevant: a signed
// `-1 >> 2` zero-fills at 32 bits per the LRM but propagates the sign bit
// through Surelog's 64-bit word just the same. Gate the replay on that shape.
static bool hasSignExtendedShift(const SubroutineSymbol& sub) {
    bool found = false;
    sub.getBody().visit(makeVisitor([&](auto& v, const BinaryExpression& b) {
        if (b.op == BinaryOperator::LogicalShiftRight ||
            b.op == BinaryOperator::ArithmeticShiftRight) {
            auto& lhs = stripImplicitConv(b.left());
            if (lhs.type->isIntegral() && lhs.type->getBitWidth() < 64) {
                lhs.visit(makeVisitor(
                    [&](auto& v2, std::derived_from<Expression> auto& sub2) {
                        if (sub2.type->isIntegral() && sub2.type->isSigned())
                            found = true;
                        v2.visitDefault(sub2);
                    }));
            }
        }
        v.visitDefault(b);
    }));
    return found;
}

// A module that IMPORTS (via wildcard or explicit import) and REFERENCES a
// package parameter materializes it as a module-local parameter (Surelog sets
// vpiImported = the package name). A QUALIFIED reference (pkg::P) with no
// import does NOT materialize it (ParameterColonReference, PkgParamAsFunctionArg).
static void collectImportedParams(
    const Scope& body, std::vector<const ParameterSymbol*>& out,
    std::map<const ParameterSymbol*, std::string>& srcOut,
    const std::function<bool(SourceLocation, SourceLocation)>& locLess,
    std::map<const ParameterSymbol*, std::pair<size_t, size_t>>* rankOut =
        nullptr) {
    std::set<const Symbol*> wildcardPkgs; // packages wildcard-imported
    std::set<const Symbol*> explicitSyms; // explicitly imported symbols
    // Surelog materializes imports ONE IMPORT ITEM AT A TIME, in source order
    // (CompileModule::collectModuleObjects_ walks paPackage_import_item during
    // the FUNCTION pass and calls CompileHelper::importPackage per item). Each
    // call appends to the module's Parameters / Param_assigns vectors, so the
    // IMPORT-ITEM index is the PRIMARY order key of every materialized param —
    // not the package's declaration order and not the name.
    //   `import p::N;` (object_name set) contributes exactly N.
    //   `import p::*;` contributes ALL of p's params: the Parameters vec walks
    //   p's getParameterMap() (std::map -> NAME order) while the Param_assigns
    //   vec walks p's getParamAssignVec() (a vector -> DECLARATION order).
    // So the two vectors share the item key and differ only in the tie-break.
    // Witnessed on a purpose-built matrix where import order, name order and
    // package-declaration order are all distinct (w1: `import p::M; p::A;
    // p::Z` over a package declaring Z,M,A -> golden lists M,A,Z in BOTH
    // vectors), plus a wildcard control (w2: golden Parameters AQ,MQ,ZQ vs
    // Param_assigns ZQ,MQ,AQ) and a mixed 2-package case (w3: `pb::MB;
    // pa::*; pb::ZB` -> Parameters MB,MA,ZA,ZB / Param_assigns MB,ZA,MA,ZB).
    // Kmac's `import sha3_pkg::KeccakCountW; import sha3_pkg::KeccakRate;`
    // is the corpus instance; simple_package's lone `import my_pkg::*` is the
    // wildcard one. The two goldens never disagreed — one is per-item, the
    // other is within-item.
    std::map<const ParameterSymbol*, std::pair<size_t, size_t>> rank;
    size_t item9 = 0;
    // Rank a package's transitively-exported params (declaration order),
    // first import item wins (Surelog re-imports, we dedup).
    std::function<void(const Symbol*, std::set<const Symbol*>&, size_t&)>
        rankPkg = [&](const Symbol* pkgSym, std::set<const Symbol*>& vis,
                      size_t& sub) {
            if (!pkgSym || !vis.insert(pkgSym).second)
                return;
            for (auto& pm : pkgSym->as<PackageSymbol>().members()) {
                if (pm.kind == SymbolKind::Parameter)
                    rank.emplace(&pm.as<ParameterSymbol>(),
                                 std::make_pair(item9, sub++));
                else if (pm.kind == SymbolKind::WildcardImport)
                    rankPkg(pm.as<WildcardImportSymbol>().getPackage(), vis,
                            sub);
            }
        };
    for (auto& m : body.members()) {
        if (m.kind == SymbolKind::WildcardImport) {
            if (auto* p = m.as<WildcardImportSymbol>().getPackage()) {
                wildcardPkgs.insert(p);
                std::set<const Symbol*> vis;
                size_t sub = 0;
                rankPkg(p, vis, sub);
                item9++;
            }
        }
        else if (m.kind == SymbolKind::ExplicitImport) {
            if (auto* imp = m.as<ExplicitImportSymbol>().importedSymbol()) {
                explicitSyms.insert(imp);
                if (imp->kind == SymbolKind::Parameter)
                    rank.emplace(&imp->as<ParameterSymbol>(),
                                 std::make_pair(item9, (size_t)0));
                item9++;
            }
        }
    }
    if (rankOut)
        *rankOut = rank;
    if (wildcardPkgs.empty() && explicitSyms.empty())
        return;
    std::set<const Symbol*> seen;
    std::vector<const ParameterSymbol*> found;
    auto v = makeVisitor([&](auto& vis, const NamedValueExpression& nv) {
        if (nv.symbol.kind == SymbolKind::Parameter) {
            auto sc = nv.symbol.getParentScope();
            bool imported = explicitSyms.count(&nv.symbol) ||
                            (sc && wildcardPkgs.count(&sc->asSymbol()));
            if (imported && seen.insert(&nv.symbol).second)
                found.push_back(&nv.symbol.as<ParameterSymbol>());
        }
        vis.visitDefault(nv);
    });
    for (auto& m : body.members()) {
        if (m.kind == SymbolKind::ContinuousAssign)
            m.as<ContinuousAssignSymbol>().getAssignment().visit(v);
        else if (m.kind == SymbolKind::ProceduralBlock)
            m.as<ProceduralBlockSymbol>().getBody().visit(v);
        // A module parameter whose DEFAULT references an imported package
        // param (parameter x = PkgParam) materializes it too. For an
        // OVERRIDDEN param the bound initializer is the override expression,
        // so re-bind the declaration default to keep the pkg ref visible.
        else if (m.kind == SymbolKind::Parameter) {
            auto& ps9 = m.as<ParameterSymbol>();
            const Expression* init = ps9.getInitializer();
            if (isOverriddenParam(ps9)) {
                if (auto* dsyn = paramDefaultSyn(ps9)) {
                    ASTContext actx(body, LookupLocation::max);
                    auto* di9 = &Expression::bind(*dsyn, actx);
                    if (!di9->bad())
                        init = di9;
                }
            }
            if (init)
                init->visit(v);
        }
        // A child INSTANCE param override referencing an imported param
        // (#(.P(AddrSpace + ...))) materializes it too (Surelog).
        else if (m.kind == SymbolKind::Instance) {
            auto& ci = m.as<InstanceSymbol>();
            for (auto& cm : ci.body.members())
                if (cm.kind == SymbolKind::Parameter)
                    if (auto* init2 = cm.as<ParameterSymbol>().getInitializer())
                        init2->visit(v);
            // A PORT CONNECTION whose actual references an imported param
            // (.region_attrs_i(HwDataAttr)) materializes it in THIS module too.
            for (auto* pc : ci.getPortConnections())
                if (pc)
                    if (auto* pe = pc->getExpression())
                        pe->visit(v);
        }
    }
    // Surelog's allModules def is the ELABORATED unique instance: a module
    // whose OWN port is driven (by its instantiator) with an imported package
    // param materializes that param into the def too (the connected value flows
    // into the child's elaborated instance). Scan this body's parent-instance
    // port connections for imported params (the visitor gates on this body's
    // own wildcard/explicit imports, so only params the child imports match).
    if (body.asSymbol().kind == SymbolKind::InstanceBody)
        if (auto* pi = body.asSymbol()
                           .as<InstanceBodySymbol>()
                           .parentInstance)
            for (auto* pc : pi->getPortConnections())
                if (pc)
                    if (auto* pe = pc->getExpression())
                        pe->visit(v);
    // A NET/VARIABLE declaration whose TYPE RANGE references an imported param
    // (logic [$bits(P)-1:0] x, or logic [P-1:0] y) materializes it too — the
    // range keeps a symbolic ref even when the width folds to a constant.
    // Resolve identifiers against the MODULE scope (body).
    std::function<void(const syntax::SyntaxNode&)> scanDeclRange =
        [&](const syntax::SyntaxNode& sn) {
            if (sn.kind == syntax::SyntaxKind::IdentifierName) {
                auto nm = std::string(
                    sn.as<syntax::IdentifierNameSyntax>().identifier.valueText());
                // Explicit imports first, then each wildcard-imported package.
                const Symbol* hit = nullptr;
                for (auto* es : explicitSyms)
                    if (es->name == nm && es->kind == SymbolKind::Parameter) {
                        hit = es;
                        break;
                    }
                if (!hit)
                    for (auto* pkgSym : wildcardPkgs)
                        if (auto* sym = pkgSym->as<PackageSymbol>().find(nm))
                            if (sym->kind == SymbolKind::Parameter) {
                                hit = sym;
                                break;
                            }
                if (hit && seen.insert(hit).second)
                    found.push_back(&hit->as<ParameterSymbol>());
            }
            for (size_t i = 0; i < sn.getChildCount(); i++)
                if (auto* cn = sn.childNode(i))
                    scanDeclRange(*cn);
        };
    std::set<const syntax::SyntaxNode*> scannedDecls;
    for (auto& m : body.members()) {
        if (m.kind != SymbolKind::Variable && m.kind != SymbolKind::Net)
            continue;
        // The member's syntax is the DECLARATOR; the TYPE (with its range
        // dimensions) lives on the enclosing DataDeclaration/NetDeclaration.
        const syntax::SyntaxNode* dsyn = m.getSyntax();
        if (dsyn && dsyn->parent)
            dsyn = dsyn->parent;
        if (dsyn && scannedDecls.insert(dsyn).second)
            scanDeclRange(*dsyn);
    }
    // A wildcard-imported TYPEDEF whose range references an imported param
    // (typedef logic [SramAw-1:0] t;) materializes that param too — the
    // module lists the typedef and its range keeps a symbolic ref to the
    // param, even when the only use ($bits(t)) folds to a constant.
    std::function<void(const syntax::SyntaxNode&, const Scope&)> scanTd =
        [&](const syntax::SyntaxNode& sn, const Scope& psc) {
            if (sn.kind == syntax::SyntaxKind::IdentifierName) {
                auto nm = sn.as<syntax::IdentifierNameSyntax>().identifier.valueText();
                if (auto* sym = psc.find(std::string(nm)))
                    if (sym->kind == SymbolKind::Parameter && sym->getParentScope() &&
                        wildcardPkgs.count(&sym->getParentScope()->asSymbol()) &&
                        seen.insert(sym).second)
                        found.push_back(&sym->as<ParameterSymbol>());
            }
            for (size_t i = 0; i < sn.getChildCount(); i++)
                if (auto* cn = sn.childNode(i))
                    scanTd(*cn, psc);
        };
    for (auto* pkgSym : wildcardPkgs) {
        auto& psc = pkgSym->as<PackageSymbol>();
        for (auto& pm : psc.members())
            if (pm.kind == SymbolKind::TypeAlias)
                if (auto* tsyn = pm.getSyntax();
                    tsyn && tsyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                    scanTd(*tsyn->as<syntax::TypedefDeclarationSyntax>().type, psc);
    }
    // STRUCTURAL materialization: a wildcard import `import P::*` materializes
    // ALL of P's transitively-EXPORTED parameters — P's own declared params
    // PLUS the params P itself wildcard-imported (re-export) — regardless of
    // whether any is referenced here. Surelog tags each with vpiImported = P
    // (the immediately-imported package). BitSelectOfParameterPassedToSubmodule
    // re-exports NDioPads through pinmux_pkg into work@top with
    // vpiImported=pinmux_pkg. The srcOut map carries P's name so the emitter
    // can override the param's home-scope name for the re-export case.
    std::function<void(const Symbol*, std::set<const Symbol*>&,
                       std::vector<const ParameterSymbol*>&)>
        collectPkgParams = [&](const Symbol* pkgSym,
                               std::set<const Symbol*>& vis,
                               std::vector<const ParameterSymbol*>& acc) {
            if (!vis.insert(pkgSym).second)
                return;
            auto& psc = pkgSym->as<PackageSymbol>();
            for (auto& pm : psc.members()) {
                if (pm.kind == SymbolKind::Parameter)
                    acc.push_back(&pm.as<ParameterSymbol>());
                else if (pm.kind == SymbolKind::WildcardImport)
                    if (auto* q = pm.as<WildcardImportSymbol>().getPackage())
                        collectPkgParams(q, vis, acc);
            }
        };
    for (auto* pkgSym : wildcardPkgs) {
        std::set<const Symbol*> vis;
        std::vector<const ParameterSymbol*> acc;
        collectPkgParams(pkgSym, vis, acc);
        for (auto* pp : acc)
            if (seen.insert(pp).second) {
                found.push_back(pp);
                // vpiImported = the immediately-imported package P (the home
                // scope may be a deeper package for re-exported params).
                if (pp->getParentScope() &&
                    &pp->getParentScope()->asSymbol() != pkgSym)
                    srcOut[pp] = std::string(pkgSym->name);
            }
    }
    // An EXPLICIT `import p::N;` materializes N on the same no-reference-
    // required terms as the wildcard pass above: importPackage is driven by
    // the IMPORT ITEM, and its param loops only filter by object_name — they
    // never ask whether anything uses the name. Witnessed on a module whose
    // `import pu::AU;` is never referenced: the golden still lists AU in both
    // module vectors.
    for (auto& m : body.members())
        if (m.kind == SymbolKind::ExplicitImport)
            if (auto* imp = m.as<ExplicitImportSymbol>().importedSymbol();
                imp && imp->kind == SymbolKind::Parameter)
                if (seen.insert(imp).second)
                    found.push_back(&imp->as<ParameterSymbol>());
    // Surelog orders materialized imported params by IMPORT ITEM (source
    // order of the `import` statements), then — inside a wildcard item — by
    // the package's DECLARATION order, never by reference-discovery order.
    // The rank map above carries both keys; the locLess fallback only covers
    // a param no import item claims (defensive: should not happen).
    std::stable_sort(
        found.begin(), found.end(),
        [&](const ParameterSymbol* a, const ParameterSymbol* b) {
            auto ra = rank.find(a), rb = rank.find(b);
            bool ha = ra != rank.end(), hb = rb != rank.end();
            if (ha != hb)
                return ha;
            if (ha)
                return ra->second < rb->second;
            return locLess(a->location, b->location);
        });
    out.insert(out.end(), found.begin(), found.end());
}

void UhdmExporter::emitParameters(const Scope& body, UHDM::scope* m, const std::string& prefix,
                                  NetMap& netMap, bool topView, DefInfo* di, bool inPackage,
                                  bool topShareTs, bool funcScope) {
    // Elaborated module/interface params are clone_tree copies in Surelog, so
    // their unpacked-dim "N-1" op parents its synthetic 1 (see elabParamDim).
    bool savedEpd = elabParamDim;
    elabParamDim = topView && !inPackage && !funcScope;
    struct EpdRestore {
        bool& f;
        bool v;
        ~EpdRestore() { f = v; }
    } epdRestore{elabParamDim, savedEpd};
    auto* params = s.MakeAnyVec();
    auto* passigns = s.MakeParam_assignVec();
    std::vector<const ParameterSymbol*> paramSyms;
    for (auto& member0 : body.members())
        if (member0.kind == SymbolKind::Parameter)
            paramSyms.push_back(&member0.as<ParameterSymbol>());
    // PACKAGES materialize imported params too (pinmux_pkg lists NDioPads
    // with vpiImported — BitSelectOfParameterPassedToSubmodule).
    // srcImp maps a re-exported materialized param to the immediately-imported
    // package name (its vpiImported), overriding its home-scope name.
    std::map<const ParameterSymbol*, std::string> srcImp;
    // Import-item rank of each materialized imported param (see
    // collectImportedParams): {import item index, tie-break within the item}.
    std::map<const ParameterSymbol*, std::pair<size_t, size_t>> impRank9;
    if (!funcScope) {
        collectImportedParams(body, paramSyms, srcImp,
                              [this](SourceLocation a, SourceLocation b) {
                                  return srcOrderLess(a, b);
                              },
                              &impRank9);
        // MATERIALIZED IMPORTS LEAD, in import-item order; body-declared
        // params follow in source order. Not a location coincidence:
        // CompileModule runs CollectType::FUNCTION (which calls importPackage
        // per paPackage_import_item) strictly BEFORE CollectType::DEFINITION
        // (which compiles paParameter_declaration / paParameter_port_list), so
        // every materialized copy is pushed onto the module's vectors before
        // the first local param exists. The old rule sorted BOTH groups by
        // source location, which agrees whenever the package is declared ahead
        // of the module but scrambles the imports among themselves the moment
        // the import statements are not in package-declaration order (Kmac).
        auto rank9 = [&](const ParameterSymbol* p)
            -> std::pair<int, std::pair<size_t, size_t>> {
            if (auto it = impRank9.find(p);
                it != impRank9.end() && p->getParentScope() != &body)
                return {0, it->second};
            return {1, {0, 0}};
        };
        std::stable_sort(paramSyms.begin(), paramSyms.end(),
                         [&](const ParameterSymbol* a,
                             const ParameterSymbol* b) {
                             auto ra = rank9(a), rb = rank9(b);
                             if (ra.first != rb.first)
                                 return ra.first < rb.first;
                             if (ra.first == 0)
                                 return ra.second < rb.second;
                             return srcOrderLess(a->location, b->location);
                         });
    }
    // A materialized package parameter's emitted {param_assign, Rhs constant},
    // keyed by its symbol: a LATER module param whose default is a bare ref to
    // it (parameter logic[..] P = X) clones this constant in the ELAB view
    // (ParameterFromPkg* family).
    std::map<const Symbol*, std::pair<UHDM::param_assign*, UHDM::constant*>>
        pkgRefSrc;
    // param_assigns of PARAMETER-PORT-LIST params (for the elab reorder).
    std::set<const UHDM::any*> portPa9;
    // ELAB param_assigns of -P command-line overrides, restamped at the end.
    std::vector<std::pair<UHDM::param_assign*, std::string>> cliRestamp;
    // Tag every param_assign pushed while emitting a PARAMETER-PORT-LIST
    // param (the pushes happen at several sites, so mark by loop iteration).
    size_t paMark9 = 0;
    bool paMarkPort9 = false;
    auto flushPaTag9 = [&]() {
        for (size_t i9 = paMark9; i9 < passigns->size(); i9++)
            if (paMarkPort9)
                portPa9.insert((const UHDM::any*)(*passigns)[i9]);
        paMark9 = passigns->size();
    };
    for (auto* psPtr : paramSyms) {
        const Symbol& member = *psPtr;
        auto& ps = *psPtr;
        // Imported = the param belongs to ANOTHER scope (a package), not the
        // body being emitted (a package emitting its own params is NOT that).
        bool isImported = ps.getParentScope() != &body;
        flushPaTag9();
        paMarkPort9 = !isImported && ps.isPortParam();
        // The package instance a materialized param's typespec is INSTANCED at.
        // For a package view (inPackage), a param DECLARED here instances at
        // this package (m); a re-exported IMPORTED param (pinmux_pkg's
        // materialized NDioPads) instances at its HOME package
        // (prim_pad_wrapper_pkg), not the re-exporting one — Surelog
        // (BitSelectOfParameterPassedToSubmodule).
        auto pkgTsInstance = [&]() -> UHDM::instance* {
            if (inPackage && isImported && ps.getParentScope()) {
                if (auto pit = pkgDefMap.find(&ps.getParentScope()->asSymbol());
                    pit != pkgDefMap.end())
                    return (UHDM::instance*)pit->second;
            }
            return (UHDM::instance*)m;
        };
        // ...and the home package it reaches is the ELABORATED (top) one in
        // BOTH views — Surelog's cross-package instance links land on the
        // elaborated package. The def-package pass runs before top packages
        // exist, so record those for the post-build re-point.
        auto stampPkgTsInst = [&](UHDM::typespec* ts9) {
            if (inPackage && isImported && ps.getParentScope()) {
                const void* home9 = &ps.getParentScope()->asSymbol();
                if (auto tit9 = pkgTopMap.find(home9); tit9 != pkgTopMap.end()) {
                    ts9->Instance(tit9->second);
                    return;
                }
                if (auto pit9 = pkgDefMap.find(home9); pit9 != pkgDefMap.end()) {
                    ts9->Instance(pit9->second);
                    pkgImportTsTopFixups.emplace_back(ts9, home9);
                    return;
                }
            }
            ts9->Instance(pkgTsInstance());
        };
        // Instance overrides: the bound initializer's syntax is the
        // override expression at the instantiation, not the declaration
        // default. Both views keep DEFAULT-derived values; the instance
        // param_assign carries the folded override.
        const syntax::ExpressionSyntax* defaultSyn = paramDefaultSyn(ps);
        const Expression* boundInit = ps.getInitializer();
        bool overridden = isOverriddenParam(ps);
        // A -P command-line override. slang binds it exactly like an
        // instantiation override (the initializer's syntax comes from a
        // `<command-line>` buffer), so isOverriddenParam says true -- but
        // Surelog's cmdline path is a DIFFERENT one that neither stamps
        // vpiOverriden nor keeps the parameter's typespec. See cliParams.
        bool cliOv = cliOverridden(ps);
        // A required (override-only) param has NO declaration default; Surelog
        // leaves it valueless/typespec-less in the def view.
        bool hasDefault = defaultSyn != nullptr;
        // The default, bound in this scope (used for values in both views).
        const Expression* defaultInit = hasDefault ? boundInit : nullptr;
        if (overridden) {
            ASTContext actx(body, LookupLocation::max);
            defaultInit = &Expression::bind(*defaultSyn, actx);
            // A bare assignment PATTERN ('{...}) cannot bind without a target
            // type — re-bind with the param's own type so pattern defaults
            // keep their Rhs (tagged-pattern op) instead of silently dropping.
            if (defaultInit->bad())
                defaultInit = &Expression::bindRValue(
                    ps.getType(), *defaultSyn, defaultSyn->sourceRange(), actx);
            if (defaultInit->bad())
                defaultInit = nullptr;
        }
        // An UNTYPED param whose default is a DECIMAL-BASED sized literal
        // (parameter reposo = 4'd0) carries NO typespec at all (unlike 'b/'h
        // literals): def-view Rhs keeps 4'd0 with a DANGLING module-named ts
        // ref, and the ELAB Rhs folds to a plain int constant (mriscv
        // MEMORY_INTERFACE states; fsm's 3'b001 and param_test's 8'hAA keep
        // their int_typespec).
        bool decBasedInit = false;
        if (defaultInit) {
            auto& dl0 = stripImplicitConv(*defaultInit);
            if (dl0.kind == ExpressionKind::IntegerLiteral) {
                std::string rawL0 = rawTextLit(dl0);
                auto tk0 = rawL0.find('\'');
                if (tk0 != std::string::npos) {
                    auto bp0 = tk0 + 1;
                    if (bp0 < rawL0.size() &&
                        (rawL0[bp0] == 's' || rawL0[bp0] == 'S'))
                        bp0++;
                    decBasedInit = bp0 < rawL0.size() &&
                                   (rawL0[bp0] == 'd' || rawL0[bp0] == 'D');
                }
            }
        }
        auto* up = s.MakeParameter();
        up->VpiName(ps.name);
        up->VpiFullName(joinPath(prefix, ps.name));
        up->VpiParent(m);
        setLoc(up, SourceRange(ps.location, ps.location + ps.name.size()));
        if (isImported) {
            // Re-exported materialized params carry the IMMEDIATELY-imported
            // package name (srcImp), not their deeper home scope.
            auto siIt = srcImp.find(&ps);
            up->VpiImported(siIt != srcImp.end()
                                ? siIt->second
                                : std::string(ps.getParentScope()->asSymbol().name));
        }

        // Surelog reports vpiLocalParam by the WRITTEN keyword, not slang's
        // LRM-derived local flag: a module-BODY `parameter` (local per LRM
        // when the module has an ANSI header) is a real parameter to Surelog.
        // Packages and function scopes follow the keyword the same way.
        bool isLocal = ps.isLocalParam();
        for (auto q = ps.getSyntax(); q; q = q->parent) {
            if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                isLocal = q->as<syntax::ParameterDeclarationSyntax>().keyword.valueText() ==
                          "localparam";
                break;
            }
        }
        bool typedParam = false;
        if (auto declared = ps.getDeclaredType()) {
            if (auto tsyn = declared->getTypeSyntax())
                typedParam = tsyn->kind != syntax::SyntaxKind::ImplicitType;
        }
        // An imported param's type syntax may not resolve from the importing
        // module; fall back to a definite integral kind (int/scalar/vector).
        // An IMPLICITLY-typed imported param (parameter W = 48) is NOT promoted:
        // it follows the untyped rules (default int_typespec) exactly as it
        // does in its home package — otherwise a bare vector-canonical value
        // would emit a spurious logic[31:0] typespec (fail_detect_width).
        bool implicitImportDecl = false;
        if (auto d0i = ps.getDeclaredType())
            if (auto ts0i = d0i->getTypeSyntax())
                implicitImportDecl =
                    ts0i->kind == syntax::SyntaxKind::ImplicitType;
        if (isImported && !typedParam && !implicitImportDecl) {
            auto& ct0 = ps.getType().getCanonicalType();
            typedParam = ct0.kind == SymbolKind::PredefinedIntegerType ||
                         ct0.kind == SymbolKind::ScalarType ||
                         (ct0.kind == SymbolKind::PackedArrayType && ct0.isIntegral());
        }
        bool wantTs = false;
        // Untyped `parameter P = $bits(...)`: folds like a literal in BOTH
        // views and carries the declaration's implicit int_typespec (set with
        // wantTs below; also drives the ELAB constant's width).
        bool bitsFoldInit = false;
        // Set when this parameter's only typespec comes from a `P'(x)` size
        // cast (see the wantTs block below). Once it HAS a typespec its ELAB
        // fold is width-typed by it exactly like a $bits fold: size 32, with a
        // ts ref on the folded constant.
        bool castSizeFold = false;
        if (isLocal)
            up->VpiLocalParam(true);
        // Function-scope, explicitly-TYPED, and ranged (localparam [7:0] X)
        // localparams are valued and typed like module non-local params.
        // All parameters — including plain local untyped ones (localparam
        // IDLE = 2'b00) — carry a value/typespec (Surelog); the inner
        // literalInit/wantTs gates decide the exact encoding.
        // A PACKAGE-ORIGIN parameter whose default is an explicit TYPE cast
        // (`parameter int NumAgents = int'(NumAgentsIdx)`) folds to a plain
        // constant in every view EXCEPT the unelaborated DEF package one:
        // Surelog's package elaboration runs its evaluator over the cast,
        // while the def view keeps the vpiCastOp tree (whose own cast
        // typespec then carries vpiInstance = the package). Measured on
        // ParamCast: def package keeps the op byte-for-byte; elab package
        // and BOTH materialized module views carry UINT:3 / size 32.
        bool pkgTypeCastFold9 =
            (inPackage ? topView : isImported) && defaultInit && [&] {
                const Expression* c9 = &stripImplicitConv(*defaultInit);
                return c9->kind == ExpressionKind::Conversion &&
                       !c9->as<ConversionExpression>().isImplicit() &&
                       c9->syntax &&
                       c9->syntax->kind == syntax::SyntaxKind::CastExpression &&
                       isTypeSyntaxKind(
                           c9->syntax->as<syntax::CastExpressionSyntax>()
                               .left->kind);
            }();
        // An ELAB-pkg param with a COMPUTED init (Y+1, g(4)) still carries
        // its evaluated value and an int ts (Surelog folds package elabs).
        bool pkgElabComputed = false;
        if (true) {
            // Params with non-literal initializers carry no value string.
            // Values derive from the DEFAULT initializer even when
            // overridden.
            bool literalInit = false;
            if (defaultInit)
                literalInit = isLiteralExpr(*defaultInit);
            ConstantValue dcv;
            if (overridden && defaultInit) {
                ASTContext actx(body, LookupLocation::max);
                dcv = actx.tryEval(*defaultInit);
            }
            const ConstantValue& cv = overridden ? dcv : ps.getValue();
            bool unknownDefault = cv.isInteger() && cv.integer().hasUnknown();
            if (literalInit && unknownDefault && defaultInit) {
                // 'x/'z defaults: BIN value with UPPERCASE digits.
                std::string raw = rawText(stripImplicitConv(*defaultInit).sourceRange);
                auto tick = raw.find('\'');
                if (tick != std::string::npos) {
                    std::string digits = stripSep(raw.substr(tick + 1));
                    for (auto& ch : digits)
                        ch = (char)toupper(ch);
                    up->VpiValue("BIN:" + digits);
                }
            }
            // An unbased-unsized default ('0/'1/'x/'z) carries a BIN:<bit>
            // parameter value, not a decimal UINT. (Coercion to int can clear
            // the value's unknown flag, so this handles X/Z here rather than
            // relying on the unknownDefault path above.)
            bool unbasedInit =
                defaultInit && stripImplicitConv(*defaultInit).kind ==
                                   ExpressionKind::UnbasedUnsizedIntegerLiteral;
            if (unbasedInit) {
                logic_t bit = stripImplicitConv(*defaultInit)
                                  .as<UnbasedUnsizedIntegerLiteral>()
                                  .getLiteralValue();
                std::string d = bit.isUnknown()
                                    ? (bit.value == logic_t::X_VALUE ? "X" : "Z")
                                    : (bit.value ? "1" : "0");
                up->VpiValue("BIN:" + d);
            }
            pkgElabComputed = inPackage && topView && !literalInit &&
                              !unbasedInit && defaultInit && cv.isInteger() &&
                              !cv.integer().hasUnknown() && [&] {
                                  // Only inits that FOLD in the elab view:
                                  // binary ops and const-function calls.
                                  // Concats/patterns keep their operation
                                  // and carry no param value (Surelog).
                                  const Expression* d9 =
                                      &stripImplicitConv(*defaultInit);
                                  while (d9->kind == ExpressionKind::Conversion)
                                      d9 = &d9->as<ConversionExpression>()
                                                .operand();
                                  if (d9->kind == ExpressionKind::BinaryOp ||
                                      containsUserCall(*defaultInit))
                                      return true;
                                  // A QUALIFIED pkg-param ref init
                                  // (ctrl_pkg::Banks) also folds (value
                                  // carried; loc = the qualifier span).
                                  if (d9->kind == ExpressionKind::NamedValue &&
                                      d9->as<NamedValueExpression>()
                                              .symbol.kind ==
                                          SymbolKind::Parameter &&
                                      (rawText(d9->sourceRange).find("::") !=
                                           std::string::npos ||
                                       // ...and a WILDCARD-imported one, which
                                       // is written bare.
                                       [&] {
                                           auto sc9 =
                                               d9->as<NamedValueExpression>()
                                                   .symbol.getParentScope();
                                           return sc9 &&
                                                  sc9->asSymbol().kind ==
                                                      SymbolKind::Package;
                                       }()))
                                      return true;
                                  return false;
                              }();
            // A MODULE param whose default is a bare/qualified reference to a
            // PACKAGE param carries the folded value too (Surelog) — but an
            // AGGREGATE value never inlines on the parameter object (it lives
            // only in the param_assign Rhs op; BSOPPS work@top.TargetCfg).
            bool modPkgRefFold9 =
                !inPackage && !literalInit && !unbasedInit && defaultInit &&
                ps.getType().getCanonicalType().kind !=
                    SymbolKind::PackedStructType &&
                ps.getType().getCanonicalType().kind !=
                    SymbolKind::PackedUnionType &&
                ps.getType().getCanonicalType().kind !=
                    SymbolKind::UnpackedStructType &&
                ps.getType().getCanonicalType().kind !=
                    SymbolKind::UnpackedUnionType &&
                cv.isInteger() && !cv.integer().hasUnknown() && [&] {
                    const Expression* d8 = &stripImplicitConv(*defaultInit);
                    while (d8->kind == ExpressionKind::Conversion)
                        d8 = &d8->as<ConversionExpression>().operand();
                    if (d8->kind != ExpressionKind::NamedValue)
                        return false;
                    auto& sy8 = d8->as<NamedValueExpression>().symbol;
                    if (sy8.kind != SymbolKind::Parameter)
                        return false;
                    auto sc8 = sy8.getParentScope();
                    return sc8 && sc8->asSymbol().kind == SymbolKind::Package;
                }();
            if (!unbasedInit && (literalInit || pkgElabComputed ||
                                 modPkgRefFold9 || pkgTypeCastFold9) &&
                cv.isInteger() && !cv.integer().hasUnknown()) {
                auto& iv = cv.integer();
                bool neg = (iv.isSigned() && iv.isNegative()) ||
                           (pkgElabComputed && iv.isSigned() && defaultInit &&
                            containsUserCall(*defaultInit));
                std::string digits = iv.toString(LiteralBase::Decimal, false);
                std::string value = (neg ? "INT:" : "UINT:") + digits;
                // Based-literal initializers keep their base encoding — a
                // pkg-param REFERENCE inherits the referenced param's.
                const Expression* encSrc9 = defaultInit;
                if (defaultInit) {
                    auto& r9 = stripImplicitConv(*defaultInit);
                    if (r9.kind == ExpressionKind::NamedValue &&
                        r9.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter)
                        if (auto* pi9 = r9.as<NamedValueExpression>()
                                            .symbol.as<ParameterSymbol>()
                                            .getInitializer())
                            encSrc9 = pi9;
                }
                if (auto init0 = encSrc9) {
                    auto& lit = stripImplicitConv(*init0);
                    if (lit.kind == ExpressionKind::IntegerLiteral) {
                        std::string raw = rawTextLit(lit);
                        auto tick = raw.find('\'');
                        if (tick != std::string::npos) {
                            size_t basePos = tick + 1;
                            if (basePos < raw.size() &&
                                (raw[basePos] == 's' || raw[basePos] == 'S'))
                                basePos++;
                            char base = basePos < raw.size() ? (char)tolower(raw[basePos])
                                                             : 'd';
                            std::string litDigits = stripSep(raw.substr(basePos + 1));
                            switch (base) {
                                case 'b':
                                    value = "BIN:" + litDigits;
                                    break;
                                case 'h':
                                    value = "HEX:" + litDigits;
                                    break;
                                case 'o':
                                    value = "OCT:" + litDigits;
                                    break;
                                default:
                                    value = "DEC:" + litDigits;
                                    break;
                            }
                        }
                    }
                }
                up->VpiValue(value);
            }
            // Real params carry a REAL:<%f> value.
            if (defaultInit && cv.isReal()) {
                char buf[64];
                snprintf(buf, sizeof(buf), "%f", (double)cv.real());
                up->VpiValue(std::string("REAL:") + buf);
            }
            // String params carry a STRING:<text> value.
            if (defaultInit && literalInit && cv.isString())
                up->VpiValue("STRING:" + cv.str());
            // The value mirrors the INIT LITERAL's kind, not the param type:
            // a REAL literal keeps REAL:%f even on an integral param (p1);
            // an INT literal keeps UINT even on a real param (p3) — realexpr.
            if (defaultInit) {
                auto& il9 = stripImplicitConv(*defaultInit);
                if (il9.kind == ExpressionKind::RealLiteral && !cv.isReal()) {
                    char buf9[64];
                    snprintf(buf9, sizeof(buf9), "%f",
                             il9.as<RealLiteral>().getValue());
                    up->VpiValue(std::string("REAL:") + buf9);
                }
                else if (il9.kind == ExpressionKind::IntegerLiteral &&
                         cv.isReal())
                    up->VpiValue("UINT:" +
                                 std::string(rawText(il9.sourceRange)));
                // A STRING-literal init on an (implicitly) integral param
                // keeps STRING:<text> (const_func: parameter OUTPUT = "FOO").
                else if (il9.kind == ExpressionKind::StringLiteral &&
                         !cv.isString())
                    up->VpiValue(
                        "STRING:" +
                        std::string(il9.as<StringLiteral>().getValue()));
            }
            // Untyped params carry a typespec only for LITERAL initializers;
            // computed values ($clog2(W), 2**S) get none. Typed and ranged
            // params always do.
            auto& ctw = ps.getType().getCanonicalType();
            // Typed/ranged params always carry a typespec (its range/type is
            // independent of the value); only an untyped literal is gated on a
            // known value.
            bool realLit =
                defaultInit && stripImplicitConv(*defaultInit).kind ==
                                   ExpressionKind::RealLiteral;
            // An implicitly-typed param carrying an explicit SIGNING keyword
            // (localparam signed Y = $floor(W / X)) always gets its
            // int_typespec — located at the signing keyword — even when the
            // init is COMPUTED (Surelog; const_func Y/Z).
            bool signedImplicitTs = false;
            if (auto ds9 = ps.getDeclaredType())
                if (auto ts9 = ds9->getTypeSyntax())
                    if (ts9->kind == syntax::SyntaxKind::ImplicitType)
                        signedImplicitTs =
                            ts9->as<syntax::ImplicitTypeSyntax>()
                                .signing.valid() &&
                            ts9->as<syntax::ImplicitTypeSyntax>()
                                .dimensions.empty();
            // ...and so does an UNTYPED param initialized by `$bits(...)`.
            // Surelog's DEFINITION compile evaluates $bits (the width of a
            // type or of a fixed-width signal is known without elaboration)
            // and stores the result like a literal, with the declaration's
            // implicit int_typespec. Measured over a 10-system-call matrix
            // ($clog2 $size $high $signed $unsigned ... on both literal and
            // param arguments): $bits is the ONLY one that folds there — the
            // rest stay `sys_func_call` in the def view and carry no
            // typespec in either. BitsLogic / BitComplex.
            if (defaultInit && !typedParam && ctw.isIntegral()) {
                auto& sb9 = stripImplicitConv(*defaultInit);
                if (sb9.kind == ExpressionKind::Call &&
                    sb9.as<CallExpression>().isSystemCall() &&
                    sb9.as<CallExpression>().getSubroutineName() == "$bits" &&
                    ps.getValue().isInteger() &&
                    !ps.getValue().integer().hasUnknown())
                    bitsFoldInit = true;
            }
            wantTs = (ctw.isIntegral() || ctw.isFloating() || ctw.isStruct() ||
                      (ctw.isString() && (typedParam || literalInit))) &&
                     (typedParam || isRangedUntypedParam(ps) ||
                      signedImplicitTs || pkgElabComputed || bitsFoldInit ||
                      ((literalInit || realLit) && !unknownDefault &&
                       !decBasedInit));
            // A COMPUTED-init module parameter still ends up with an
            // int_typespec when its name is used as a CAST SIZE somewhere in
            // the module: Surelog's type lookup for `P'(x)` mints one at the
            // FIRST cast site and caches it under P, so the parameter and
            // every cast share that single object (scr1_pipe_ifu
            // SCR1_IFU_QUEUE_ADR_W: declared 81:12, typespec anchored 428:24 —
            // the first `SCR1_IFU_QUEUE_ADR_W'(`). Only for the no-typespec
            // case: a LITERAL-init parameter keeps its declaration typespec
            // and the cast mints a separate one (ExprEmit's litWidthParam9).
            if (!wantTs && !inPackage && !isImported && !typedParam &&
                defaultInit && ctw.isIntegral() && !unknownDefault) {
                if (auto* bsy = body.asSymbol().getSyntax())
                    if (auto* cl = findParamSizeCast(*bsy, ps.name)) {
                        wantTs = true;
                        castSizeFold = true;
                        castSizeParamTs[&ps] = cl;
                    }
            }
        }
        if (auto declared0 = ps.getDeclaredType()) {
            if (auto tsyn0 = declared0->getTypeSyntax()) {
                // Surelog flags vpiSigned only when the declaration carries an
                // explicit `parameter`/`localparam` keyword (parameter int P,
                // or #(parameter int W)). The bare ANSI form #(int x = 0) omits
                // the keyword and gets no vpiSigned (its signedness lives on the
                // int_typespec actual instead).
                bool hasKeyword = false;
                for (auto q = ps.getSyntax(); q; q = q->parent) {
                    if (syntax::ParameterDeclarationBaseSyntax::isKind(q->kind)) {
                        hasKeyword = q->as<syntax::ParameterDeclarationBaseSyntax>()
                                         .keyword.kind != parsing::TokenKind::Unknown;
                        break;
                    }
                }
                if (tsyn0->kind != syntax::SyntaxKind::ImplicitType &&
                    ps.getType().getCanonicalType().isSigned() && hasKeyword &&
                    // ENUM-typed params carry no vpiSigned (Surelog).
                    ps.getType().getCanonicalType().kind != SymbolKind::EnumType &&
                    // TYPEDEF-typed params (localparam int4_t P) carry no
                    // vpiSigned either — Surelog never resolves an alias's
                    // signedness onto the parameter object (typedef_param).
                    declared0->getType().kind != SymbolKind::TypeAlias)
                    up->VpiSigned(true);
            }
        }
        UHDM::ref_typespec* prt = nullptr;
        // The unpacked-array param's own array_typespec, captured so the
        // elab-view folded pattern op can SHARE it (Surelog points the op's ts
        // ref at the SAME array_typespec object).
        UHDM::array_typespec* paramArrayTs = nullptr;
        // In the ELAB view Surelog builds the param_assign RHS's typespec
        // clone BEFORE the parameter's own, so the parameter's clone is
        // created behind this closure (forced at the end of the param).
        std::function<UHDM::array_typespec*()> paramArrTs =
            [&paramArrayTs]() { return paramArrayTs; };
        bool hasParamArrTs = false;
        // An ELAB MULTIDIM-vector param whose init is a LITERAL carries NO ts
        // ref on the folded Rhs (Surelog); scalar/1-D ones keep it, and both
        // keep the DEF-view one on the unsized literal. First measured on a
        // MATERIALIZED IMPORT (`logic [7:0][3:0] X = 32'habcd` read through
        // an import), but the import is not the discriminator — the DIMENSION
        // COUNT is. Probe pair on a plain module parameter, one source each
        // (/tmp/r9tsfin/r2 vs r3, Surelog -elabuhdm):
        //   parameter bit [4:0]      C = '1 -> elab ts ref present
        //   parameter bit [4:0][4:0] C = '1 -> elab NO ts
        // and r1 — a 1-D range whose bound is a SYMBOLIC struct-param member
        // — keeps the ts, so bound resolvability is not it either.
        // The LITERAL restriction is load-bearing: `logic [7:0][3:0] P = X`,
        // a multidim param defaulted from a PKG-PARAM REFERENCE, keeps its
        // elab ts (u2r ParameterFromPkgOnParameterPortList / *InNestedModule)
        // — only a literal fold drops it.
        // NoReducTypespec's `bit [Cfg.A-1:0][Cfg.B-1:0] Connectivity = '1`
        // reaches the fold through the ranged-untyped site and the literal
        // site depending on the view, so both consult this one flag.
        bool elabMultiDimNoTs9 = false;
        if (topView && !inPackage && boundInit &&
            ps.getType().getCanonicalType().kind ==
                SymbolKind::PackedArrayType &&
            ps.getType().getCanonicalType().isIntegral() &&
            ps.getType()
                    .getCanonicalType()
                    .as<PackedArrayType>()
                    .elementType.getCanonicalType()
                    .kind == SymbolKind::PackedArrayType) {
            auto k6 = stripImplicitConv(*boundInit).kind;
            elabMultiDimNoTs9 =
                k6 == ExpressionKind::IntegerLiteral ||
                k6 == ExpressionKind::UnbasedUnsizedIntegerLiteral ||
                k6 == ExpressionKind::RealLiteral ||
                k6 == ExpressionKind::StringLiteral;
        }
        if (wantTs) {
            // The actual typespec object is created late (after the instance
            // ports) to match Surelog's arena order; the ref is patched then.
            prt = s.MakeRef_typespec();
            prt->VpiFullName(joinPath(prefix, ps.name));
            prt->VpiParent(up);
            // A -P override runs `p->setTypespec(nullptr)` +
            // `param->Typespec(nullptr)` on the DEFINITION's Parameter, so no
            // view of it carries a typespec. The ref is still built (the
            // param_assign Rhs's own typespec, which the DEF view KEEPS, is
            // derived alongside it) -- it is simply not attached.
            if (!cliOv)
                up->Typespec(prt);
        }
        // An UNPACKED-ARRAY param (int X [1:0]) is not isIntegral, so the
        // wantTs path skips it. Surelog gives it an array_typespec (unpacked
        // range + Elem_typespec) plus the element's signedness/size and the
        // unpacked-dim range ON the parameter (shared range object).
        else if (ps.getType().getCanonicalType().kind ==
                 SymbolKind::FixedSizeUnpackedArrayType) {
            const Type* leaf = &ps.getType().getCanonicalType();
            while (leaf->getCanonicalType().kind ==
                   SymbolKind::FixedSizeUnpackedArrayType)
                leaf = &leaf->getCanonicalType()
                            .as<FixedSizeUnpackedArrayType>()
                            .elementType;
            std::string afull = joinPath(prefix, ps.name);
            // Unpacked-dim range, parented to the param and SHARED with the
            // array_typespec (Surelog uses one range object for both).
            // BOTH views: dims referencing an OVERRIDDEN param keep SYMBOLIC
            // bounds, bare refs scoped through the param
            // (param_array_wildcard — elab uses op11 with the elab-scoped
            // ref name too).
            std::string dimPrefix9;
            {
                bool ovr9 = false;
                bool pkgDimSym9 = false;
                if (auto dsyn9 = ps.getSyntax();
                    dsyn9 && dsyn9->kind == syntax::SyntaxKind::Declarator) {
                    for (auto dim9 :
                         dsyn9->as<syntax::DeclaratorSyntax>().dimensions) {
                        std::function<void(const syntax::SyntaxNode&)> scan9 =
                            [&](const syntax::SyntaxNode& sn9) {
                                if (sn9.kind ==
                                    syntax::SyntaxKind::IdentifierName) {
                                    auto nm9 =
                                        sn9.as<syntax::IdentifierNameSyntax>()
                                            .identifier.valueText();
                                    if (auto* hit9 =
                                            body.find(std::string(nm9));
                                        hit9 &&
                                        hit9->kind ==
                                            SymbolKind::Parameter &&
                                        isOverriddenParam(*hit9))
                                        ovr9 = true;
                                }
                                for (size_t i9 = 0;
                                     i9 < sn9.getChildCount(); i9++)
                                    if (auto* cn9 = sn9.childNode(i9))
                                        scan9(*cn9);
                            };
                        scan9(*dim9);
                        // A SIZE-style dim naming a parameter ([CNT]) keeps
                        // the bound symbolic in BOTH views whether or not that
                        // parameter is overridable — Surelog compiles the
                        // declaration's own text (ParamArrayUnsizedPattern,
                        // DefaultPatternModule). PACKAGE params are excluded:
                        // there only the DEF view stays symbolic (and scopes
                        // the ref with '::'), the elaborated package folds it
                        // (DefaultPatternInt) — that split is the next block.
                        if (!ovr9 && inPackage && !topView && dim9->specifier &&
                            dim9->specifier->kind ==
                                syntax::SyntaxKind::RangeDimensionSpecifier)
                            if (auto* bs7 =
                                    dim9->specifier
                                        ->as<syntax::RangeDimensionSpecifierSyntax>()
                                        .selector->as_if<syntax::BitSelectSyntax>();
                                bs7 && bs7->expr &&
                                bs7->expr->kind ==
                                    syntax::SyntaxKind::IdentifierName) {
                                auto nm7 =
                                    bs7->expr->as<syntax::IdentifierNameSyntax>()
                                        .identifier.valueText();
                                if (auto* hit7 = body.find(std::string(nm7));
                                    hit7 && hit7->kind == SymbolKind::Parameter)
                                    pkgDimSym9 = true;
                            }
                        // ...and the RANGE spelling of the same dim
                        // ([0:NStraps-1]) — same DEF-package-only rule,
                        // same '::'-scoped ref (PackageEval).
                        if (!ovr9 && inPackage && !topView && dim9->specifier &&
                            dim9->specifier->kind ==
                                syntax::SyntaxKind::RangeDimensionSpecifier)
                            if (auto* rs7 =
                                    dim9->specifier
                                        ->as<syntax::RangeDimensionSpecifierSyntax>()
                                        .selector->as_if<syntax::RangeSelectSyntax>())
                            {
                                const syntax::ExpressionSyntax* bd7[2] = {
                                    rs7->left, rs7->right};
                                for (int bi7 = 0; bi7 < 2; bi7++) {
                                    if (!bd7[bi7] ||
                                        bd7[bi7]->kind !=
                                            syntax::SyntaxKind::SubtractExpression)
                                        continue;
                                    auto& sb7 =
                                        bd7[bi7]->as<syntax::BinaryExpressionSyntax>();
                                    if (sb7.left->kind !=
                                            syntax::SyntaxKind::IdentifierName ||
                                        sb7.right->kind !=
                                            syntax::SyntaxKind::IntegerLiteralExpression)
                                        continue;
                                    auto nm6 =
                                        sb7.left->as<syntax::IdentifierNameSyntax>()
                                            .identifier.valueText();
                                    if (auto* hit6 = body.find(std::string(nm6));
                                        hit6 && hit6->kind == SymbolKind::Parameter)
                                        pkgDimSym9 = true;
                                }
                            }
                        if (!ovr9 && !inPackage && dim9->specifier &&
                            dim9->specifier->kind ==
                                syntax::SyntaxKind::RangeDimensionSpecifier)
                            if (auto* bs8 =
                                    dim9->specifier
                                        ->as<syntax::RangeDimensionSpecifierSyntax>()
                                        .selector->as_if<syntax::BitSelectSyntax>();
                                bs8 && bs8->expr &&
                                bs8->expr->kind ==
                                    syntax::SyntaxKind::IdentifierName) {
                                auto nm8 =
                                    bs8->expr->as<syntax::IdentifierNameSyntax>()
                                        .identifier.valueText();
                                if (auto* hit8 = body.find(std::string(nm8));
                                    hit8 && hit8->kind == SymbolKind::Parameter)
                                    ovr9 = true;
                            }
                    }
                }
                if (ovr9)
                    dimPrefix9 = afull;
                else if (pkgDimSym9)
                    dimPrefix9 = afull + "::";
            }
            std::string savedDfo9 = dimFoldOwner;
            dimFoldOwner = afull;
            // A MATERIALIZED IMPORT is a clone_tree copy like the elab view,
            // so its dim op parents the synthetic 1 too (DefaultPatternInt).
            bool savedEpd9 = elabParamDim;
            elabParamDim = elabParamDim || isImported;
            auto* prng = buildUnpackedRanges(ps, up, dimPrefix9);
            elabParamDim = savedEpd9;
            dimFoldOwner = savedDfo9;
            if (prng)
                up->Ranges(prng);
            // An UNPACKED-ARRAY parameter's vpiSize is 1 only in the view that
            // still holds the compile-time shape — the DEF package listing and
            // a MODULE-LOCAL localparam. The ELABORATED package copy and every
            // MATERIALIZED IMPORT copy instead carry the array's ELEMENT COUNT.
            // Measured, one source: pkg `int unsigned A3[3] / logic[7:0] B2[2]
            // / int unsigned C1[1]` -> defPkg 1/1/1, topPkg 3/2/1, module
            // import copies 3/2/1; the same module's own `localparam int
            // unsigned L4[4]` stays 1 in BOTH module views (Kmac KeccakRate).
            int32_t arrSize9 = 1;
            // ...and only when every unpacked dim is a LITERAL expression:
            // see unpackedDimsAllLiteral (a `[CNT]` bound never reduces for
            // Surelog's instance-less evaluation, so the size stays 1).
            if (((inPackage && topView) || (!inPackage && isImported)) &&
                unpackedDimsAllLiteral(ps)) {
                auto& uat9 = ps.getType().getCanonicalType();
                if (uat9.kind == SymbolKind::FixedSizeUnpackedArrayType) {
                    auto w9 = uat9.as<FixedSizeUnpackedArrayType>().range.width();
                    if (w9 > 0)
                        arrSize9 = (int32_t)w9;
                }
            }
            up->VpiSize(arrSize9);
            up->VpiSigned(leaf->isSigned());
            auto* art = s.MakeRef_typespec();
            art->VpiFullName(afull);
            art->VpiParent(up);
            up->Typespec(art);
            hasParamArrTs = true;
            if (topView && !inPackage &&
                m->UhdmType() == UHDM::uhdmmodule_inst) {
                // ELAB clone: OWN range objects, parented at the ref_typespec
                // that holds it (the def view keeps the compile-time shape:
                // parent = the parameter, ranges shared with it). Minted after
                // the instance's net/port typespecs unless the folded-pattern
                // path needs it sooner.
                auto mk = [this, psp = &ps, afull, art,
                           dimPrefix9]() -> UHDM::array_typespec* {
                    if (auto* ex = art->Actual_typespec())
                        return (UHDM::array_typespec*)ex;
                    // The clone's own "N-1" dim op parents its synthetic 1
                    // (elab shape) even when minted in the write phase, and
                    // its bounds stay symbolic when the def's did.
                    bool saved = elabParamDim;
                    elabParamDim = true;
                    auto* ats = makeUnpackedArrayParamTs(*psp, afull, art,
                                                         nullptr, true, dimPrefix9);
                    elabParamDim = saved;
                    art->Actual_typespec(ats);
                    return ats;
                };
                paramArrTs = mk;
                pendingElabArrayTs.push_back([mk]() { mk(); });
            }
            else {
                paramArrayTs = makeUnpackedArrayParamTs(ps, afull, up, prng);
                art->Actual_typespec(paramArrayTs);
                // Record the MODULE DEF view's object so the elab view's
                // folded `'{default:X}` array_expr can point at it (see
                // defParamArrayTs).
                if (!inPackage && !isImported &&
                    m->UhdmType() == UHDM::uhdmmodule_inst)
                    if (auto* dsyn0 = ps.getSyntax())
                        defParamArrayTs.emplace(dsyn0, paramArrayTs);
            }
        }
        params->push_back(up);
        if (funcScope)
            netMap[&member] = up;

        UHDM::ref_typespec* rhsRt = nullptr;
        // The Rhs constant captured for pkgRefSrc, and a flag suppressing the
        // deferred ts patch when a pkg-ref clone binds its own (pkg-located) ts.
        UHDM::constant* rhsConstForMap = nullptr;
        bool pkgRefFold = false;
        auto* pa = s.MakeParam_assign();
        if (topView)
            elabParamPa[&member] = pa;
        pa->VpiParent(m);
        if (auto syn = ps.getSyntax())
            setLoc(pa, syn->sourceRange());
        pa->Lhs(up);
        // ELAB view: `parameter DEBUG = Cfg.NoSlvPorts` — an init that
        // READS a struct param's MEMBER — reduces against that param's
        // ELABORATED Rhs. Surelog's reduceExpr walks the hier_path into
        // the base parameter's own elab value and hands back the member
        // slot verbatim: the flattened op75's operand (already at the
        // member width), or, when the base's elab Rhs is a whole-struct
        // CONSTANT ('0), that constant unchanged. The result carries the
        // READ's span and nothing else — no typespec.
        // The DEF view keeps the symbolic hier_path (a parameter PORT has
        // no value there), which is what the fold-chain guard below still
        // covers. Probe matrix (base init form x view,
        // /tmp/r9tsfin/q1..q4, Surelog -elabuhdm):
        //   port param = '0        -> def hier_path, elab INT:0 size 96
        //   port param overridden  -> def hier_path, elab UINT:5 size 32
        //                             (NoReducTypespec)
        //   body param = '{x:16}   -> BOTH views fold (own fold path)
        //   body param = cast'(16) -> BOTH views keep the hier_path
        //                             (u2r *OfInstanceInitializedBy-
        //                             StructMember, unchanged)
        // ...and only for the parameter's OWN declared init: an OVERRIDE
        // ACTUAL that reads a struct member (#(.PadType(TargetCfg.dio_pad_type)))
        // keeps the symbolic hier_path at the override site — Surelog folds
        // the declaration, never the connection (u2r ParameterPassedTo*,
        // ParameterFromPkg*, the ovMemberInitParam model below).
        if (topView && !inPackage && !overridden && boundInit) {
            auto& si6 = stripImplicitConv(*boundInit);
            if (si6.kind == ExpressionKind::MemberAccess) {
                auto& mae6 = si6.as<MemberAccessExpression>();
                auto& base6 = stripImplicitConv(mae6.value());
                const UHDM::constant* src6 = nullptr;
                if (base6.kind == ExpressionKind::NamedValue &&
                    base6.as<NamedValueExpression>().symbol.kind ==
                        SymbolKind::Parameter &&
                    base6.as<NamedValueExpression>()
                            .symbol.getType()
                            .getCanonicalType()
                            .kind == SymbolKind::PackedStructType) {
                    auto& bsym6 = base6.as<NamedValueExpression>().symbol;
                    if (auto bit6 = elabParamPa.find(&bsym6);
                        bit6 != elabParamPa.end() && bit6->second) {
                        auto* brhs6 = bit6->second->Rhs();
                        if (brhs6 &&
                            brhs6->UhdmType() == UHDM::uhdmconstant)
                            src6 = (const UHDM::constant*)brhs6;
                        else if (brhs6 &&
                                 brhs6->UhdmType() ==
                                     UHDM::uhdmoperation &&
                                 ((UHDM::operation*)brhs6)->VpiOpType() ==
                                     75) {
                            int mi6 = 0, want6 = -1;
                            for (auto& f6 :
                                 bsym6.getType()
                                     .getCanonicalType()
                                     .as<PackedStructType>()
                                     .membersOfType<FieldSymbol>()) {
                                if (&f6 == &mae6.member) {
                                    want6 = mi6;
                                    break;
                                }
                                mi6++;
                            }
                            auto* ops6 =
                                ((UHDM::operation*)brhs6)->Operands();
                            if (want6 >= 0 && ops6 &&
                                want6 < (int)ops6->size() &&
                                (*ops6)[want6]->UhdmType() ==
                                    UHDM::uhdmconstant)
                                src6 =
                                    (const UHDM::constant*)(*ops6)[want6];
                        }
                    }
                }
                if (src6) {
                    auto* c6 = s.MakeConstant();
                    c6->VpiValue(src6->VpiValue());
                    c6->VpiDecompile(src6->VpiDecompile());
                    c6->VpiSize(src6->VpiSize());
                    c6->VpiConstType(src6->VpiConstType());
                    c6->VpiParent(pa);
                    setLoc(c6, si6.sourceRange);
                    // RULE 6 (r9psc): the member SLOT of a flattened pattern
                    // is a bare value — no decompile — but a param_assign Rhs
                    // constant always carries one, so the reduce re-renders it
                    // from the binary value, and the slot's own typespec (the
                    // member type, minted by the flatten) rides along.  A slot
                    // that had neither (the plain UINT member fold behind
                    // `parameter DEBUG = Cfg.NoSlvPorts`) still gets neither.
                    if (c6->VpiDecompile().empty() &&
                        c6->VpiConstType() == vpiBinaryConst) {
                        std::string_view bv6 = c6->VpiValue();
                        if (bv6.rfind("BIN:", 0) == 0)
                            c6->VpiDecompile(std::to_string(c6->VpiSize()) +
                                             "'b" + std::string(bv6.substr(4)));
                    }
                    if (auto* st6 = src6->Typespec();
                        st6 && st6->Actual_typespec()) {
                        auto* rt6 = s.MakeRef_typespec();
                        rt6->VpiFullName(st6->VpiFullName());
                        rt6->VpiParent(c6);
                        auto* act6 = (UHDM::typespec*)st6->Actual_typespec();
                        // RULE 6b (r9tdclone): when the READING param is
                        // declared with the same NAMED vector typedef, the
                        // slot's typespec only LOOKS like the right answer.
                        // Surelog gives the constant the PARAM's own
                        // alias-clone chain (`work@top.FpFmtMask.fmt_logic_t`),
                        // whose alias target keeps the shared typedef object's
                        // module instance — where the slot's copy is
                        // instance-free (it was cloned for the flattened
                        // pattern, which carries no instance anywhere). Both
                        // print the same; only typespec::Compare's Instance()
                        // recursion separates them.
                        if (!act6->VpiName().empty() && ps.getDeclaredType() &&
                            ps.getDeclaredType()->getType().kind ==
                                SymbolKind::TypeAlias)
                            if (auto t6 = typedefTs.find(
                                    &ps.getDeclaredType()->getType());
                                t6 != typedefTs.end() && t6->second &&
                                t6->second->Instance() &&
                                t6->second->VpiName() == act6->VpiName())
                                if (auto* pc6 = copyNamedVecTs(t6->second, rt6)) {
                                    auto* pa6 = s.MakeRef_typespec();
                                    pa6->VpiFullName(
                                        joinPath(prefix, ps.name) + "." +
                                        std::string(t6->second->VpiName()));
                                    pa6->VpiParent(pc6);
                                    pa6->Actual_typespec(t6->second);
                                    pc6->Typedef_alias(pa6);
                                    act6 = pc6;
                                }
                        rt6->Actual_typespec(act6);
                        c6->Typespec(rt6);
                    }
                    pa->Rhs(c6);
                    passigns->push_back(pa);
                    if (prt)
                        pendingParamTs.push_back(
                            {&ps, up, prt, nullptr, typedParam});
                    continue;
                }
            }
        }
        // DEF-view materialized IMPORTED vector-typedef param: the param_assign
        // Lhs is a SEPARATE parameter clone with its own ts clone chain
        // (Surelog).
        UHDM::parameter* upLhs9 = nullptr;
        UHDM::ref_typespec* prtLhs9 = nullptr;
        if (!topView && !inPackage && isImported && prt) {
            bool wantLhsClone9 = false;
            if (auto dLhs = ps.getDeclaredType()) {
                // Vector-typedef materialized imports (its home typedef) and
                // plain TYPED materialized imports both clone.
                if (dLhs->getType().kind == SymbolKind::TypeAlias &&
                    ps.getType().getCanonicalType().kind ==
                        SymbolKind::PackedArrayType &&
                    ps.getType().getCanonicalType().isIntegral() &&
                    dLhs->getType().getParentScope() == ps.getParentScope())
                    wantLhsClone9 = true;
                else if (auto tsy9 = dLhs->getTypeSyntax();
                         tsy9 &&
                         tsy9->kind != syntax::SyntaxKind::ImplicitType)
                    wantLhsClone9 = true;
                // A plain UNTYPED integral import (parameter W = 48) ALSO gets a
                // separate def-view Lhs clone (Surelog; fail_detect_width). The
                // implicit type canonicalizes to a packed logic vector, so no
                // packed-array exclusion here (the TypeAlias vector case is
                // handled by the first branch above).
                else if (auto tsy9b = dLhs->getTypeSyntax();
                         tsy9b &&
                         tsy9b->kind == syntax::SyntaxKind::ImplicitType &&
                         ps.getType().getCanonicalType().isIntegral())
                    wantLhsClone9 = true;
            }
            if (wantLhsClone9) {
                upLhs9 = s.MakeParameter();
                upLhs9->VpiName(up->VpiName());
                upLhs9->VpiFullName(up->VpiFullName());
                upLhs9->VpiLineNo(up->VpiLineNo());
                upLhs9->VpiColumnNo(up->VpiColumnNo());
                upLhs9->VpiEndLineNo(up->VpiEndLineNo());
                upLhs9->VpiEndColumnNo(up->VpiEndColumnNo());
                upLhs9->VpiImported(std::string(up->VpiImported()));
                upLhs9->VpiValue(std::string(up->VpiValue()));
                if (up->VpiSigned())
                    upLhs9->VpiSigned(true);
                if (up->VpiLocalParam())
                    upLhs9->VpiLocalParam(true);
                upLhs9->VpiParent(pa);
                prtLhs9 = s.MakeRef_typespec();
                prtLhs9->VpiFullName(std::string(prt->VpiFullName()));
                prtLhs9->VpiParent(upLhs9);
                upLhs9->Typespec(prtLhs9);
                pa->Lhs(upLhs9);
            }
        }
        // Function-scope params parent at their param_assign.
        if (funcScope)
            up->VpiParent(pa);
        // A UNIQUIFIED (multi-param-def) instance also marks params whose
        // VALUE differs from the default-eval as overriden — a DERIVED
        // param ('1 sized by an overridden typedef width) counts
        // (ParameterOfParametrizedTypeInSubmodule Y). Single-instance
        // defparam targets stay unmarked (hierdefparam).
        bool derivedOv9 = false;
        if (topView && !overridden && hasDefault && defaultInit &&
            !inPackage && isMultiParamDef(body)) {
            // Derived = the declared type resolves through a TYPEDEF whose
            // target references an OVERRIDDEN param of this body.
            if (auto od9 = ps.getDeclaredType()) {
                auto& dt9o = od9->getType();
                if (dt9o.kind == SymbolKind::TypeAlias) {
                    std::string tgt9;
                    if (auto asyn9 = dt9o.as<TypeAliasType>().getSyntax())
                        tgt9 = std::string(rawText(asyn9->sourceRange()));
                    if (!tgt9.empty())
                        for (auto& om9 : body.members()) {
                            if (om9.kind != SymbolKind::Parameter ||
                                !isOverriddenParam(om9))
                                continue;
                            auto p9 = tgt9.find(om9.name);
                            while (p9 != std::string::npos) {
                                bool lb9 =
                                    p9 == 0 ||
                                    (!isalnum((unsigned char)tgt9[p9 - 1]) &&
                                     tgt9[p9 - 1] != '_');
                                size_t e9 = p9 + om9.name.size();
                                bool rb9 =
                                    e9 >= tgt9.size() ||
                                    (!isalnum((unsigned char)tgt9[e9]) &&
                                     tgt9[e9] != '_');
                                if (lb9 && rb9) {
                                    derivedOv9 = true;
                                    break;
                                }
                                p9 = tgt9.find(om9.name, p9 + 1);
                            }
                            if (derivedOv9)
                                break;
                        }
                }
            }
        }
        if (topView && !cliOv &&
            (overridden || derivedOv9 || (!hasDefault && boundInit)))
            pa->VpiOverriden(true);
        // The ELAB Rhs of a -P'd parameter is fromString's constant, built from
        // the raw command-line STRING with no reference to the declared type.
        // The DEF view keeps the declaration default untouched. Applied after
        // the loop (the Rhs is set on many different paths) by RE-STAMPING the
        // constant the ordinary path produced, which keeps Surelog's span (the
        // declaration default's) without having to re-derive it.
        if (topView && cliOv)
            cliRestamp.emplace_back(pa, std::string(ps.name));
        // A module-scope typed localparam whose init element-selects an
        // UNPACKED-ARRAY param (localparam int C = Arr[Idx]) CLAIMS the
        // selected operand of the array's ELAB pattern op: that operand
        // constant gets a ts ref (module-scoped fullname) to a fresh
        // int_typespec at the claiming param's declared-type span (Surelog;
        // ModuleInstantiationAndIndirectParams — module-level twin of the
        // gen-scope adopter in ModuleEmit).
        if (topView && !inPackage && !overridden && defaultInit &&
            ps.getType().getCanonicalType().kind ==
                SymbolKind::PredefinedIntegerType) {
            auto& se0 = stripImplicitConv(*defaultInit);
            if (se0.kind == ExpressionKind::ElementSelect) {
                auto& es0 = se0.as<ElementSelectExpression>();
                auto& bv = stripImplicitConv(es0.value());
                if (bv.kind == ExpressionKind::NamedValue &&
                    bv.as<NamedValueExpression>().symbol.kind ==
                        SymbolKind::Parameter) {
                    auto& rp =
                        bv.as<NamedValueExpression>().symbol.as<ParameterSymbol>();
                    auto oit = elabArrayPatternOp.find(&rp);
                    auto& rpt = rp.getType().getCanonicalType();
                    ASTContext ec0(comp.getRoot(), LookupLocation::max);
                    ConstantValue iv = ec0.tryEval(es0.selector());
                    if (oit != elabArrayPatternOp.end() && iv && iv.isInteger() &&
                        rpt.kind == SymbolKind::FixedSizeUnpackedArrayType) {
                        auto* op0 = oit->second;
                        int64_t ix = iv.integer().as<int64_t>().value_or(-1);
                        auto rng = rpt.as<FixedSizeUnpackedArrayType>().range;
                        int32_t lo = std::min(rng.left, rng.right);
                        int64_t pos = ix - lo;
                        if (op0->VpiReordered() != 1 && op0->Operands() &&
                            ix >= 0 && pos >= 0 &&
                            pos < (int64_t)op0->Operands()->size()) {
                            auto* opnd = (*op0->Operands())[pos];
                            if (opnd->UhdmType() == UHDM::uhdmconstant &&
                                !((UHDM::constant*)opnd)->Typespec()) {
                                auto* ort = s.MakeRef_typespec();
                                std::string tsPfx = prefix;
                                if (tsPfx.size() >= 2 &&
                                    tsPfx.compare(tsPfx.size() - 2, 2, "::") == 0)
                                    tsPfx.resize(tsPfx.size() - 2);
                                ort->VpiFullName(tsPfx);
                                ort->VpiParent(opnd);
                                auto* oits = s.MakeInt_typespec();
                                oits->VpiSigned(true);
                                SourceRange otr(ps.location, ps.location);
                                if (auto od = ps.getDeclaredType())
                                    if (auto otsyn = od->getTypeSyntax())
                                        otr = otsyn->getFirstToken().range();
                                setLoc(oits, otr);
                                oits->VpiParent(ort);
                                ort->Actual_typespec(oits);
                                ((UHDM::constant*)opnd)->Typespec(ort);
                            }
                        }
                    }
                }
            }
        }
        // Instance view of an override: folded constant, base-encoded and
        // override-site-anchored for literal overrides; expression overrides
        // anchor at the DEFAULT initializer.
        // A NO-DEFAULT param bound to an EXPRESSION (.Width(A+B)) also folds
        // directly here — the cont-assign backpatch (noDefOvPa) only shares
        // LITERAL overrides, so an expression bind would otherwise get NO Rhs.
        bool noDefExprOv =
            !hasDefault && topView && boundInit &&
            stripImplicitConv(*boundInit).kind != ExpressionKind::IntegerLiteral;
        // A NO-DEFAULT param positionally/named overridden by an integer
        // LITERAL in a MULTIPARAM def: Surelog's uniquified elab param_assign
        // carries a LOC-LESS folded UINT constant directly (an untyped one at
        // width 64, no typespec; a typed one at its type width with typespec).
        bool noDefLitMP =
            !hasDefault && topView && boundInit && isMultiParamDef(body) &&
            stripImplicitConv(*boundInit).kind == ExpressionKind::IntegerLiteral;
        // ELAB view of a PACKED-STRUCT param OVERRIDDEN by a bare REFERENCE to
        // a (local)param whose own init is an assignment PATTERN
        // (`bus_if #(C) bus()`, `localparam p::cfg_t C = '{...}`): Surelog does
        // NOT fold the aggregate to one packed constant — it re-emits the
        // REFERENCED param's pattern as the flat op75 (per-member operands at
        // their own source spans/encodings, nested member patterns kept as
        // nested op75s), anchored at the OVERRIDE-SITE span and tagged with the
        // instance-scoped struct typespec. Keeping the operation form also
        // makes the modport port-view retain the param_assign (an aggregate
        // value cannot inline on the parameter object).
        // iface_wholestruct_param / iface_cfg_param_def_pass.
        const Expression* structOvPat = nullptr;
        SourceRange structOvLoc;
        // ...and the SAME rule for an UNPACKED-struct param, but ONLY when the
        // override actual is written UNQUALIFIED (a localparam of the
        // instantiating module, or a wildcard-imported package param
        // materialized there). A `pkg::NAME`-QUALIFIED actual resolves straight
        // to the package's own already-built param_assign Rhs and Surelog
        // SHARES that tree verbatim: no outer struct ts, no member-op size, and
        // the package's own (bare) member ts refs — which is what the
        // structRefOv arm further down emits (iface_struct_field_param_width
        // `tif #(p::CFG_PER)`). Unqualified instead re-emits at the instance:
        // outer op ts, member ops sized at the member width, instance-scoped ts
        // fullnames — i.e. exactly the packed shape (InterfaceParamOverrideProp
        // `tif #(CFG_OVR)`).
        bool unpStructOvRef9 = false;
        if (topView && overridden && boundInit &&
            (ps.getType().getCanonicalType().kind ==
                 SymbolKind::PackedStructType ||
             ps.getType().getCanonicalType().kind ==
                 SymbolKind::UnpackedStructType)) {
            bool unpacked9 = ps.getType().getCanonicalType().kind ==
                             SymbolKind::UnpackedStructType;
            auto& bi8 = stripImplicitConv(*boundInit);
            const Symbol* rs8 = nullptr;
            if (bi8.kind == ExpressionKind::NamedValue)
                rs8 = &bi8.as<NamedValueExpression>().symbol;
            else if (bi8.kind == ExpressionKind::HierarchicalValue)
                rs8 = &bi8.as<HierarchicalValueExpression>().symbol;
            bool qualified9 =
                rawText(bi8.sourceRange).find("::") != std::string::npos;
            if (rs8 && rs8->kind == SymbolKind::Parameter &&
                !(unpacked9 && qualified9))
                if (auto* rin8 = rs8->as<ParameterSymbol>().getInitializer()) {
                    auto& si8 = stripImplicitConv(*rin8);
                    if (si8.kind ==
                            ExpressionKind::StructuredAssignmentPattern ||
                        si8.kind == ExpressionKind::SimpleAssignmentPattern) {
                        structOvPat = &si8;
                        structOvLoc = bi8.sourceRange;
                        unpStructOvRef9 = unpacked9;
                    }
                }
        }
        // A module struct param DEFAULTED from a bare reference to a
        // PACKAGE struct param (`parameter target_cfg_t TargetCfg =
        // DefaultTargetCfg`) substitutes that param's pattern the same way in
        // the ELAB view — as the FLAT op75 over the reference's own span (the
        // DEF view keeps the plain ref_obj). BSOPPS*.
        if (!structOvPat && topView && !inPackage && !overridden &&
            ps.getType().getCanonicalType().kind ==
                SymbolKind::PackedStructType &&
            ps.getParentScope() == &body && ps.getInitializer()) {
            auto& bi7 = stripImplicitConv(*ps.getInitializer());
            if (bi7.kind == ExpressionKind::NamedValue) {
                auto& rs7 = bi7.as<NamedValueExpression>().symbol;
                if (rs7.kind == SymbolKind::Parameter && rs7.getParentScope() &&
                    rs7.getParentScope()->asSymbol().kind == SymbolKind::Package)
                    if (auto* rin7 = rs7.as<ParameterSymbol>().getInitializer()) {
                        auto& si7 = stripImplicitConv(*rin7);
                        if (si7.kind ==
                                ExpressionKind::StructuredAssignmentPattern ||
                            si7.kind == ExpressionKind::SimpleAssignmentPattern) {
                            structOvPat = &si7;
                            structOvLoc = bi7.sourceRange;
                        }
                    }
            }
        }
        // An instance param OVERRIDE whose actual is a LOCALPARAM initialized
        // from a struct-param MEMBER (.Depth(N), N = Info.x) keeps a SYMBOLIC
        // hier_path Rhs (re-emit of N's init) at the override-site span, rather
        // than folding to the connected value (Surelog).
        const ParameterSymbol* ovMemberInitParam = nullptr;
        if (topView && overridden && boundInit) {
            auto& bi = stripImplicitConv(*boundInit);
            const Symbol* refSym = nullptr;
            if (bi.kind == ExpressionKind::NamedValue)
                refSym = &bi.as<NamedValueExpression>().symbol;
            else if (bi.kind == ExpressionKind::HierarchicalValue)
                refSym = &bi.as<HierarchicalValueExpression>().symbol;
            // Only a NON-overridden localparam holds a genuine member-init in
            // its declared init; an OVERRIDDEN param's getInitializer() returns
            // the override expression (e.g. PadType=TargetCfg.dio_pad_type),
            // which Surelog folds at the connection instead of re-emitting.
            if (refSym && refSym->kind == SymbolKind::Parameter &&
                !isOverriddenParam(refSym->as<ParameterSymbol>()))
                if (auto* pin =
                        refSym->as<ParameterSymbol>().getInitializer()) {
                    auto& si = stripImplicitConv(*pin);
                    if (si.kind == ExpressionKind::MemberAccess) {
                        auto& mb = stripImplicitConv(
                            si.as<MemberAccessExpression>().value());
                        if (mb.kind == ExpressionKind::NamedValue &&
                            mb.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter &&
                            mb.as<NamedValueExpression>()
                                    .symbol.getType()
                                    .getCanonicalType()
                                    .kind == SymbolKind::PackedStructType)
                            ovMemberInitParam =
                                &refSym->as<ParameterSymbol>();
                    }
                }
        }
        // --disable-feature=parametersubstitution (hard no-op without the
        // flag): this parameter's value cannot be computed any more, so the
        // ELAB param_assign keeps the SYMBOLIC expression Surelog failed to
        // reduce instead of a folded constant.  Placed ahead of every fold
        // rule below because the flag disables the substitution those rules
        // are built on, not their result.
        // ...except for a parameter whose own declared value is an AGGREGATE
        // pattern (a packed struct/union or an unpacked array): Surelog's
        // only pattern-related gate is `expandPatternAssignment`, and for an
        // aggregate target that expansion is a no-op — the elab Rhs is the
        // same flattened `op75` with or without the flag (ParamComplexVerilator
        // `init_val`, ParamNoSubst `CTRL_RESET`, both byte-identical across
        // the pair).  Only a PACKED-VECTOR target actually collapses to one
        // constant when substitution is on (NoParamSubs `logic [1:0] X`), so
        // only that one needs the un-collapsed form here.
        bool ownAggPattern9 = false;
        if (noParamSubst && paramSubstRefused(ps) && boundInit) {
            auto& oi9 = stripImplicitConv(*boundInit);
            auto ck9 = ps.getType().getCanonicalType().kind;
            ownAggPattern9 =
                (oi9.kind == ExpressionKind::SimpleAssignmentPattern ||
                 oi9.kind == ExpressionKind::StructuredAssignmentPattern ||
                 oi9.kind == ExpressionKind::ReplicatedAssignmentPattern) &&
                (ck9 == SymbolKind::PackedStructType ||
                 ck9 == SymbolKind::PackedUnionType ||
                 ck9 == SymbolKind::FixedSizeUnpackedArrayType);
        }
        if (noParamSubst && topView && boundInit && !ownAggPattern9 &&
            paramValueUnavailable(ps)) {
            auto& raw9 = stripImplicitConv(*boundInit);
            const ParameterSymbol* hop9 = nullptr;
            auto& src9 = noSubstSourceExpr(raw9, &hop9);
            bool savedPI9 = inParamInit, savedPD9 = paramInitDef;
            inParamInit = true;
            paramInitDef = false;
            auto* rhs9 = (UHDM::expr*)emitExpr(src9, pa, prefix, netMap);
            inParamInit = savedPI9;
            paramInitDef = savedPD9;
            if (rhs9) {
                // A reference resolved through the hop loop is re-anchored at
                // the reference site (Surelog stamps the compiled result with
                // the current node's location).
                if (&src9 != &raw9)
                    setLoc(rhs9, raw9.sourceRange);
                rhs9->VpiParent(pa);
                // Surelog's substituted result is a CLONE of the hopped-through
                // parameter's own Rhs: it keeps that parameter's param_assign
                // as its parent, its scope in the fullname, and its declared
                // typespec — only the location is re-stamped at the re-pass
                // site (ParamNoSubst `prim_subreg #(.RESVAL(RESVAL))`).
                if (hop9 && rhs9->UhdmType() == UHDM::uhdmref_obj) {
                    auto* ro9 = (UHDM::ref_obj*)rhs9;
                    if (auto hit9 = elabParamPa.find(hop9);
                        hit9 != elabParamPa.end() && hit9->second->Lhs()) {
                        auto* hlhs9 = hit9->second->Lhs();
                        ro9->VpiParent(hit9->second);
                        if (hlhs9->UhdmType() == UHDM::uhdmparameter) {
                            auto* hp9 = (UHDM::parameter*)hlhs9;
                            std::string hf9(hp9->VpiFullName());
                            if (auto d9 = hf9.rfind('.');
                                d9 != std::string::npos)
                                ro9->VpiFullName(hf9.substr(0, d9 + 1) +
                                                 std::string(ro9->VpiName()));
                            if (!ro9->Typespec())
                                if (auto* hrt9 = hp9->Typespec()) {
                                    auto* nrt9 = s.MakeRef_typespec();
                                    nrt9->VpiFullName(
                                        std::string(ro9->VpiFullName()));
                                    nrt9->VpiParent(ro9);
                                    nrt9->Actual_typespec(
                                        hrt9->Actual_typespec());
                                    noSubstRefTs.emplace_back(nrt9, hrt9);
                                    ro9->Typespec(nrt9);
                                }
                        }
                    }
                }
                // An un-reduced PATTERN Rhs carries the parameter's own
                // typespec (Surelog tags the operation it could not expand)
                // and parents its operands, unlike the def-view form.
                UHDM::ref_typespec* opRt9 = nullptr;
                if (rhs9->UhdmType() == UHDM::uhdmoperation &&
                    ((UHDM::operation*)rhs9)->VpiOpType() ==
                        vpiAssignmentPatternOp) {
                    auto* op9 = (UHDM::operation*)rhs9;
                    op9->VpiSize(0);
                    if (auto* ops9 = op9->Operands())
                        for (auto* o9 : *ops9)
                            if (!o9->VpiParent())
                                o9->VpiParent(op9);
                    if (prt && !op9->Typespec()) {
                        opRt9 = s.MakeRef_typespec();
                        std::string tsPfx9 = prefix;
                        if (tsPfx9.size() >= 2 &&
                            tsPfx9.compare(tsPfx9.size() - 2, 2, "::") == 0)
                            tsPfx9.resize(tsPfx9.size() - 2);
                        opRt9->VpiFullName(tsPfx9);
                        opRt9->VpiParent(op9);
                        op9->Typespec(opRt9);
                    }
                }
                pa->Rhs(rhs9);
                passigns->push_back(pa);
                if (prt) {
                    if (!inPackage) {
                        pendingParamTs.push_back(
                            {&ps, up, prt, opRt9, typedParam});
                    }
                    else {
                        auto* its9 = makeParamTs(ps, typedParam);
                        if (typedParam)
                            stampPkgTsInst(its9);
                        prt->Actual_typespec(its9);
                        if (typedParam || isRangedUntypedParam(ps))
                            its9->VpiParent(up);
                    }
                }
                continue;
            }
        }
        if (topView && (overridden || noDefExprOv || noDefLitMP) &&
            !structOvPat) {
            auto& cvo = ps.getValue();
            // An override actual that CONCATENATES a struct-typed parameter
            // (.init({init_val})) is NOT folded: Surelog substitutes the
            // referenced parameter with its own assignment pattern, flattened
            // to one operand per struct member, and leaves the concatenation
            // in place. The substituted op is parented at the REFERENCED
            // param's param_assign (Surelog builds it while elaborating that
            // assign) and carries its own module-scoped struct typespec clone.
            // ParamConcat / ParamComplex / ParamComplexVerilator.
            if (boundInit) {
                auto& cc9 = stripImplicitConv(*boundInit);
                const ParameterSymbol* csp9 = nullptr;
                const Expression* cref9 = nullptr;
                const Expression* cpat9 = nullptr;
                if (cc9.kind == ExpressionKind::Concatenation &&
                    cc9.as<ConcatenationExpression>().operands().size() == 1) {
                    auto& el9 = stripImplicitConv(
                        *cc9.as<ConcatenationExpression>().operands()[0]);
                    const Symbol* rs9 = nullptr;
                    if (el9.kind == ExpressionKind::NamedValue)
                        rs9 = &el9.as<NamedValueExpression>().symbol;
                    else if (el9.kind == ExpressionKind::HierarchicalValue)
                        rs9 = &el9.as<HierarchicalValueExpression>().symbol;
                    if (rs9 && rs9->kind == SymbolKind::Parameter &&
                        rs9->as<ParameterSymbol>()
                                .getType()
                                .getCanonicalType()
                                .kind == SymbolKind::PackedStructType) {
                        if (auto* ri9 =
                                rs9->as<ParameterSymbol>().getInitializer()) {
                            auto& si9 = stripImplicitConv(*ri9);
                            if (si9.kind == ExpressionKind::
                                                StructuredAssignmentPattern ||
                                si9.kind ==
                                    ExpressionKind::SimpleAssignmentPattern) {
                                csp9 = &rs9->as<ParameterSymbol>();
                                cref9 = &el9;
                                cpat9 = &si9;
                            }
                        }
                    }
                }
                if (csp9) {
                    auto* cop9 = s.MakeOperation();
                    cop9->VpiOpType(vpiConcatOp);
                    cop9->VpiParent(pa);
                    setLoc(cop9, cc9.sourceRange);
                    auto* pop9 = s.MakeOperation();
                    pop9->VpiOpType(75);
                    if (auto pit9 = elabParamPa.find(csp9);
                        pit9 != elabParamPa.end())
                        pop9->VpiParent(pit9->second);
                    else
                        pop9->VpiParent(cop9);
                    setLoc(pop9, cref9->sourceRange);
                    // The struct ts clone and its member refs scope at the
                    // REFERENCING module (prefix minus this instance).
                    std::string modPfx9 = prefix;
                    if (auto d9 = modPfx9.rfind('.'); d9 != std::string::npos)
                        modPfx9.resize(d9);
                    else
                        modPfx9.clear();
                    auto* crt9 = s.MakeRef_typespec();
                    crt9->VpiParent(pop9);
                    crt9->VpiFullName(modPfx9);
                    {
                        std::string savedPfx9 = syntaxRefPrefix;
                        syntaxRefPrefix = modPfx9;
                        structCloneMemberRefParent = true;
                        auto* scl9 = makeParamTs(*csp9, /*typedParam=*/true,
                                                 /*parentBounds=*/true);
                        structCloneMemberRefParent = false;
                        syntaxRefPrefix = savedPfx9;
                        crt9->Actual_typespec(scl9);
                        scl9->VpiParent(crt9);
                    }
                    pop9->Typespec(crt9);
                    ASTContext mctx9(comp.getRoot(), LookupLocation::max);
                    auto* mops9 = s.MakeAnyVec();
                    for (auto& fld9 : csp9->getType()
                                          .getCanonicalType()
                                          .as<PackedStructType>()
                                          .membersOfType<FieldSymbol>()) {
                        const Expression* se9 = nullptr;
                        if (cpat9->kind ==
                            ExpressionKind::StructuredAssignmentPattern) {
                            auto& ap9 =
                                cpat9->as<StructuredAssignmentPatternExpression>();
                            for (auto& ms9 : ap9.memberSetters)
                                if (ms9.member == &fld9) {
                                    se9 = ms9.expr;
                                    break;
                                }
                            if (!se9)
                                se9 = ap9.defaultSetter;
                        }
                        if (!se9)
                            continue;
                        // A BASED/SIZED literal setter keeps its own source
                        // encoding; anything else (an unbased '1, a param ref)
                        // folds to UINT at the member width.
                        if (stripImplicitConv(*se9).kind ==
                            ExpressionKind::IntegerLiteral) {
                            if (auto* e9 = emitExpr(*se9, pop9, prefix, netMap)) {
                                ((UHDM::any*)e9)->VpiParent(pop9);
                                mops9->push_back((UHDM::any*)e9);
                            }
                            continue;
                        }
                        ConstantValue mv9 = mctx9.tryEval(*se9);
                        if (mv9 && mv9.isInteger() &&
                            !mv9.integer().hasUnknown()) {
                            slang::SVInt uv9 = mv9.integer();
                            uv9.setSigned(false);
                            std::string dg9 =
                                uv9.toString(LiteralBase::Decimal, false);
                            auto* c9 = s.MakeConstant();
                            c9->VpiDecompile(dg9);
                            c9->VpiSize((int32_t)fld9.getType().getBitWidth());
                            c9->VpiValue("UINT:" + dg9);
                            c9->VpiConstType(vpiUIntConst);
                            c9->VpiParent(pop9);
                            setLoc(c9, se9->sourceRange);
                            mops9->push_back(c9);
                        }
                    }
                    pop9->Operands(mops9);
                    auto* cops9 = s.MakeAnyVec();
                    cops9->push_back(pop9);
                    cop9->Operands(cops9);
                    pa->Rhs(cop9);
                    passigns->push_back(pa);
                    if (prt) {
                        if (!inPackage) {
                            pendingParamTs.push_back(
                                {&ps, up, prt, nullptr, typedParam});
                        }
                        else {
                            auto* its9 = makeParamTs(ps, typedParam);
                            if (typedParam)
                                stampPkgTsInst(its9);
                            prt->Actual_typespec(its9);
                            if (typedParam || isRangedUntypedParam(ps))
                                its9->VpiParent(up);
                        }
                    }
                    continue;
                }
            }
            // UNBASED-UNSIZED override actuals (#(.VALUE('0)) etc.,
            // unbased_unsized_param sp13..sp16): the pa Rhs constant keeps
            // the unbased encoding with a LOCATED declared-type ts; the
            // child's reading cont_assign later CLAIMS the same object
            // ('0/'x/'z) or copies it ('1).
            if (boundInit) {
                auto& ub9 = stripImplicitConv(*boundInit);
                if (ub9.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                    logic_t bit9 = ub9.as<UnbasedUnsizedIntegerLiteral>()
                                       .getLiteralValue();
                    auto* c9 = s.MakeConstant();
                    if (bit9.isUnknown()) {
                        std::string d9 =
                            bit9.value == logic_t::X_VALUE ? "X" : "Z";
                        c9->VpiDecompile("'b" + d9);
                        c9->VpiSize(-1);
                        c9->VpiValue("BIN:" + d9);
                        c9->VpiConstType(vpiBinaryConst);
                    }
                    else if (bit9.value == 0) {
                        c9->VpiDecompile("'b0");
                        c9->VpiSize(64);
                        c9->VpiValue("BIN:0");
                        c9->VpiConstType(vpiBinaryConst);
                    }
                    else {
                        slang::SVInt ones9(
                            (slang::bitwidth_t)ps.getType().getBitWidth(), 0,
                            false);
                        ones9 = ~ones9;
                        std::string d9 =
                            ones9.toString(LiteralBase::Decimal, false);
                        c9->VpiDecompile(d9);
                        c9->VpiSize((int32_t)ps.getType().getBitWidth());
                        c9->VpiValue("UINT:" + d9);
                        c9->VpiConstType(vpiUIntConst);
                    }
                    c9->VpiParent(pa);
                    auto* rt9 = s.MakeRef_typespec();
                    std::string tsPfx9 = prefix;
                    if (tsPfx9.size() >= 2 &&
                        tsPfx9.compare(tsPfx9.size() - 2, 2, "::") == 0)
                        tsPfx9.resize(tsPfx9.size() - 2);
                    rt9->VpiFullName(tsPfx9);
                    rt9->VpiParent(c9);
                    if (prt) {
                        // Bound below (patchParamTypespecs) to the param's own
                        // elab ts object; copies of this constant clone it.
                        unbasedOvTsRef[&ps] = rt9;
                    }
                    else {
                        auto* lts9 = s.MakeLogic_typespec();
                        if (auto dt9 = ps.getDeclaredType())
                            if (auto tsy9 = dt9->getTypeSyntax())
                                setLoc(lts9, tsy9->sourceRange());
                        rt9->Actual_typespec(lts9);
                    }
                    c9->Typespec(rt9);
                    pa->Rhs(c9);
                    elabParamConst[&ps] = c9;
                    unbasedOvConst[&ps] = c9;
                    passigns->push_back(pa);
                    if (prt)
                        pendingParamTs.push_back(
                            {&ps, up, prt, nullptr, typedParam});
                    continue;
                }
            }
            // An override ACTUAL that reads a parameter through a HIERARCHICAL
            // member path (#(.SYS_DAT(s.CFG.BUS.DAT))) keeps the SYMBOLIC
            // hier_path Rhs at the override-site span: Surelog's reduce never
            // crosses the interface-member hop (iface_param_2level). vpiExpr
            // aliases the ENCLOSING instance's interface-port LowConn ref.
            const Expression* ovHierInit = nullptr;
            if (boundInit) {
                auto& bi7 = stripImplicitConv(*boundInit);
                const Expression* b7 = &bi7;
                while (b7->kind == ExpressionKind::MemberAccess)
                    b7 = &stripImplicitConv(
                        b7->as<MemberAccessExpression>().value());
                if (b7 != &bi7 &&
                    b7->kind == ExpressionKind::HierarchicalValue &&
                    b7->as<HierarchicalValueExpression>().symbol.kind ==
                        SymbolKind::Parameter)
                    ovHierInit = &bi7;
            }
            if (ovHierInit) {
                auto* he = (UHDM::expr*)emitExpr(*ovHierInit, pa, prefix, netMap);
                if (he && he->UhdmType() == UHDM::uhdmhier_path) {
                    auto* hp = (UHDM::hier_path*)he;
                    std::string hn(hp->VpiName());
                    if (auto d0 = hn.find('.'); d0 != std::string::npos)
                        hn.resize(d0);
                    std::string up0 = prefix;
                    if (auto d1 = up0.rfind('.'); d1 != std::string::npos)
                        up0.resize(d1);
                    else
                        up0.clear();
                    if (!up0.empty() && !hn.empty())
                        if (auto lit =
                                ifacePortLowConnByPath.find(up0 + "." + hn);
                            lit != ifacePortLowConnByPath.end())
                            hp->Root_value(lit->second);
                }
                pa->Rhs(he);
                passigns->push_back(pa);
                if (prt)
                    pendingParamTs.push_back(
                        {&ps, up, prt, nullptr, typedParam});
                continue;
            }
            if (ovMemberInitParam) {
                auto* init = ovMemberInitParam->getInitializer();
                // Re-emitting the referenced localparam's member-init path
                // (Info.x): flag the param-init context so the hier_path uses
                // the lvalue-style base span + bare leaf (Surelog).
                inParamInit = true;
                auto* he = (UHDM::expr*)emitExpr(*init, pa, prefix, netMap);
                inParamInit = false;
                if (he && he->UhdmType() == UHDM::uhdmhier_path) {
                    auto* hp = (UHDM::hier_path*)he;
                    if (boundInit)
                        setLoc(hp, boundInit->sourceRange);
                    // ref_typespec scoped to N's owning module (work@top.Info.x),
                    // actual = N's own (int) typespec.
                    std::string npfx = prefix;
                    if (auto dp = npfx.rfind('.'); dp != std::string::npos)
                        npfx.resize(dp);
                    else
                        npfx.clear();
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiFullName(npfx.empty()
                                        ? std::string(hp->VpiName())
                                        : npfx + "." + std::string(hp->VpiName()));
                    rt->VpiParent(hp);
                    auto* its = s.MakeInt_typespec();
                    if (auto dt = ovMemberInitParam->getDeclaredType())
                        if (auto* tsyn = dt->getTypeSyntax())
                            setLoc(its, tsyn->sourceRange());
                    if (ovMemberInitParam->getType().isSigned())
                        its->VpiSigned(true);
                    rt->Actual_typespec(its);
                    hp->Typespec(rt);
                }
                pa->Rhs(he);
                passigns->push_back(pa);
                if (prt) {
                    if (!inPackage) {
                        pendingParamTs.push_back(
                            {&ps, up, prt, nullptr, typedParam});
                    }
                    else {
                        auto* its = makeParamTs(ps, typedParam);
                        if (typedParam)
                            stampPkgTsInst(its);
                        prt->Actual_typespec(its);
                        if (typedParam || isRangedUntypedParam(ps))
                            its->VpiParent(up);
                    }
                }
                continue;
            }
            // An instance param OVERRIDE whose actual READS a parameter that
            // did NOT reduce (its own elab Rhs is still an operation — the
            // r9c7 no-fold pattern family) keeps that parameter's SUBSTITUTED
            // expression tree as its Rhs, re-anchored at the override-site
            // span, instead of folding to a value.  A REDUCIBLE actual still
            // folds, at the DEFAULT's span.  Measured on a probe pairing both:
            // `sink #(.SVAL(USE), .SVAL2(PLAIN))` with `int PAT =
            // '{default:1}; int USE = PAT + 2; int PLAIN = 3` — .SVAL keeps
            // the whole add-op tree (ts-ref'd to USE's typespec, at the parent
            // instance's prefix), .SVAL2 folds to `3`.  This is the gap the
            // ordinary fold gate in emitParameters never sees, because the
            // override path emits its Rhs here.
            const ParameterSymbol* ovUnreduced9 = nullptr;
            if (topView && overridden && boundInit && !inPackage) {
                auto& bi6 = stripImplicitConv(*boundInit);
                const Symbol* rs6 = nullptr;
                if (bi6.kind == ExpressionKind::NamedValue)
                    rs6 = &bi6.as<NamedValueExpression>().symbol;
                else if (bi6.kind == ExpressionKind::HierarchicalValue)
                    rs6 = &bi6.as<HierarchicalValueExpression>().symbol;
                if (rs6 && rs6->kind == SymbolKind::Parameter &&
                    rs6->as<ParameterSymbol>().getInitializer() &&
                    exprElabParamUnreduced(bi6))
                    ovUnreduced9 = &rs6->as<ParameterSymbol>();
            }
            if (ovUnreduced9) {
                // The substituted tree lives in the OVERRIDING (parent)
                // instance's scope, so it is emitted with that prefix.
                std::string ppfx6 = prefix;
                if (auto d6 = ppfx6.rfind('.'); d6 != std::string::npos)
                    ppfx6.resize(d6);
                bool sPI6 = inParamInit, sPD6 = paramInitDef,
                     sPS6 = patSubstElab;
                inParamInit = true;
                paramInitDef = false;
                patSubstElab = true;
                auto* he6 = (UHDM::expr*)emitExpr(
                    *ovUnreduced9->getInitializer(), pa, ppfx6, netMap);
                inParamInit = sPI6;
                paramInitDef = sPD6;
                patSubstElab = sPS6;
                if (he6) {
                    setLoc(he6, boundInit->sourceRange);
                    if (he6->UhdmType() == UHDM::uhdmoperation &&
                        !((UHDM::operation*)he6)->Typespec()) {
                        auto* rt6 = s.MakeRef_typespec();
                        rt6->VpiFullName(ppfx6);
                        rt6->VpiParent(he6);
                        ((UHDM::operation*)he6)->Typespec(rt6);
                        bindOrParkParamTs(*ovUnreduced9, rt6);
                    }
                    pa->Rhs(he6);
                    passigns->push_back(pa);
                    if (prt)
                        pendingParamTs.push_back(
                            {&ps, up, prt, nullptr, typedParam});
                    continue;
                }
            }
            // A LOGIC-VECTOR param OVERRIDDEN by an AGGREGATE actual — an
            // assignment pattern, directly or through parameter refs
            // (`#(.RESVAL(CTRL_RESET))` with `parameter ctrl_reg_t
            // CTRL_RESET = '{...}` against `parameter logic [31:0] RESVAL`):
            // Surelog's CompileHelper::expandPatternAssignment flattens the
            // pattern into ONE constant sized by the TARGET typespec, spanned
            // at the OVERRIDE SITE, decompiled `<width>'d<value>` and carrying
            // NO vpiConstType, NO typespec and NO parent (CompileHelper.cpp
            // ~5321, the uhdmlogic_typespec arm).
            // PAssignType / ParamNoSubst / TypespecExpr.
            const Expression* patOv9 = nullptr;
            SourceRange patOv9Loc;
            // The ACTUAL must itself be STRUCT-typed: a pattern written on a
            // plain vector param (`parameter logic [1:0] X = '{1,1}`) has
            // already collapsed to a scalar constant by the time Surelog
            // reaches the override, so that case keeps the ordinary
            // UINT-at-the-default-site fold (u2r
            // PatternAsParameterOfInstance / NestedParamSubstitution).
            if (boundInit && overridden &&
                ps.getType().getCanonicalType().kind ==
                    SymbolKind::PackedArrayType &&
                ps.getType().getCanonicalType().isIntegral() &&
                stripImplicitConv(*boundInit).type &&
                stripImplicitConv(*boundInit)
                        .type->getCanonicalType()
                        .kind == SymbolKind::PackedStructType) {
                auto& bi9 = stripImplicitConv(*boundInit);
                const Expression* org9 = &bi9;
                for (int h9 = 0;
                     h9 < 8 && org9->kind == ExpressionKind::NamedValue; h9++) {
                    auto& sy9 = org9->as<NamedValueExpression>().symbol;
                    if (sy9.kind != SymbolKind::Parameter)
                        break;
                    // Only a param carrying its OWN declared pattern
                    // substitutes. Re-passing an already-OVERRIDDEN parameter
                    // one level down (`prim_subreg #(.RESVAL(RESVAL))` inside
                    // prim_subreg_shadow) keeps the CHILD's declared default
                    // instead — Surelog never re-expands through the hop.
                    if (isOverriddenParam(sy9.as<ParameterSymbol>()))
                        break;
                    auto* in9 = sy9.as<ParameterSymbol>().getInitializer();
                    if (!in9)
                        break;
                    org9 = &stripImplicitConv(*in9);
                }
                if (org9->kind ==
                        ExpressionKind::StructuredAssignmentPattern ||
                    org9->kind == ExpressionKind::SimpleAssignmentPattern) {
                    patOv9 = org9;
                    patOv9Loc = bi9.sourceRange;
                }
            }
            if (patOv9 && cvo.isInteger() && !cvo.integer().hasUnknown()) {
                slang::SVInt uv9 = cvo.integer();
                uv9.setSigned(false);
                std::string dg9 = uv9.toString(LiteralBase::Decimal, false);
                int32_t w9 = (int32_t)ps.getType().getBitWidth();
                auto* c9 = s.MakeConstant();
                c9->VpiDecompile(std::to_string(w9) + "'d" + dg9);
                c9->VpiSize(w9);
                c9->VpiValue("UINT:" + dg9);
                setLoc(c9, patOv9Loc);
                pa->Rhs(c9);
                if (topView)
                    elabParamConst[&ps] = c9;
                passigns->push_back(pa);
                if (prt) {
                    if (!inPackage) {
                        pendingParamTs.push_back(
                            {&ps, up, prt, nullptr, typedParam});
                    }
                    else {
                        auto* its9 = makeParamTs(ps, typedParam);
                        if (typedParam)
                            stampPkgTsInst(its9);
                        prt->Actual_typespec(its9);
                        if (typedParam || isRangedUntypedParam(ps))
                            its9->VpiParent(up);
                    }
                }
                continue;
            }
            if (cvo.isInteger()) {
                auto& iv = cvo.integer();
                std::string digits = iv.toString(LiteralBase::Decimal, false);
                auto* c = s.MakeConstant();
                // An untyped param whose DECLARED default is a string literal
                // is a string param to Surelog (makeParamTs' string_typespec).
                // When such a param is overridden by a REFERENCE that itself
                // resolves to a string literal, the elab Rhs is a STRING
                // constant carrying that text: STRING:<t> with decompile <t>
                // and size 8*len, exactly like any other string constant. The
                // rule reads as "value only, no size, no decompile" on
                // ParamFile alone because BOTH sides there default to the
                // EMPTY string, and uhdm-dump prints neither an empty
                // decompile nor a zero size; ParamFileOverr's
                // `-PSRAMInitFile=/blah` is the same path with a non-empty
                // text and shows /blah + 40.
                bool strRefOv8 = false;
                std::string strRefTxt8;
                if (!typedParam && boundInit &&
                    stripImplicitConv(*boundInit).kind !=
                        ExpressionKind::StringLiteral &&
                    declaredStringLiteralParam(ps)) {
                    const Expression* org7 = &stripImplicitConv(*boundInit);
                    for (int h7 = 0;
                         h7 < 8 && org7->kind == ExpressionKind::NamedValue;
                         h7++) {
                        auto& sy7 = org7->as<NamedValueExpression>().symbol;
                        if (sy7.kind != SymbolKind::Parameter)
                            break;
                        auto* in7 = sy7.as<ParameterSymbol>().getInitializer();
                        if (!in7)
                            break;
                        org7 = &stripImplicitConv(*in7);
                    }
                    if (org7->kind == ExpressionKind::StringLiteral) {
                        strRefTxt8 = std::string(
                            org7->as<StringLiteral>().getValue());
                        strRefOv8 = true;
                        c->VpiValue("STRING:" + strRefTxt8);
                        c->VpiConstType(vpiStringConst);
                        c->VpiSize((int32_t)(strRefTxt8.size() * 8));
                        c->VpiDecompile(strRefTxt8);
                    }
                }
                if (!strRefOv8)
                    c->VpiDecompile(digits);
                // A GENERATE-containing child is uniquified by Surelog's
                // elaboration: its overrides encode UINT at the value width
                // even for untyped params. INTERFACE instances do the same.
                bool genChild = m->UhdmType() == UHDM::uhdminterface_inst;
                for (auto& mb0 : body.members())
                    if (mb0.kind == SymbolKind::GenerateBlock ||
                        mb0.kind == SymbolKind::GenerateBlockArray) {
                        genChild = true;
                        break;
                    }
                // A definition instantiated with MULTIPLE DISTINCT parameter
                // values is uniquified by Surelog: its untyped overrides encode
                // UINT at the value width (like the gen/interface case) rather
                // than INT/size-1.
                if (isMultiParamDef(body))
                    genChild = true;
                // Children INSTANTIATED INSIDE a gen scope are uniquified
                // too (generate_test adder_inst) — UINT at the width.
                if (!genChild &&
                    body.asSymbol().kind == SymbolKind::InstanceBody &&
                    body.asSymbol().as<InstanceBodySymbol>().parentInstance)
                    if (auto psc9 = body.asSymbol()
                                        .as<InstanceBodySymbol>()
                                        .parentInstance->getParentScope();
                        psc9 &&
                        (psc9->asSymbol().kind == SymbolKind::GenerateBlock ||
                         psc9->asSymbol().kind ==
                             SymbolKind::GenerateBlockArray))
                        genChild = true;
                // A VECTOR-TYPEDEF param's literal override keeps its SOURCE
                // base form (384'b1 -> BIN:1, binary const) — Surelog.
                bool vecAliasOv8 = false;
                if (typedParam && boundInit && ps.getDeclaredType() &&
                    (ps.getDeclaredType()->getType().kind ==
                         SymbolKind::TypeAlias ||
                     // WIDE (>64-bit) direct-vector params too: the int64
                     // fold would overflow — keep the source base form.
                     ps.getType().getBitWidth() > 64) &&
                    ps.getType().getCanonicalType().kind ==
                        SymbolKind::PackedArrayType &&
                    stripImplicitConv(*boundInit).kind ==
                        ExpressionKind::IntegerLiteral) {
                    std::string raw8(
                        rawText(stripImplicitConv(*boundInit).sourceRange));
                    auto tick8 = raw8.find('\'');
                    if (tick8 != std::string::npos && tick8 + 1 < raw8.size()) {
                        size_t bp8 = tick8 + 1;
                        if (raw8[bp8] == 's' || raw8[bp8] == 'S')
                            bp8++;
                        char base8 = (char)tolower((unsigned char)raw8[bp8]);
                        std::string dg8 = stripSep(raw8.substr(bp8 + 1));
                        if (base8 == 'b' || base8 == 'h' || base8 == 'o') {
                            c->VpiValue((base8 == 'b'   ? "BIN:"
                                         : base8 == 'h' ? "HEX:"
                                                        : "OCT:") +
                                        dg8);
                            c->VpiConstType(base8 == 'b'   ? vpiBinaryConst
                                            : base8 == 'h' ? vpiHexConst
                                                           : vpiOctConst);
                            c->VpiSize((int32_t)iv.getBitWidth());
                            c->VpiDecompile(stripSep(raw8));
                            vecAliasOv8 = true;
                        }
                    }
                }
                // A STRING-literal override keeps STRING:<text> with the bare
                // text decompile at the value width (const_func #("BAR")).
                bool strOv8 = false;
                if (boundInit && stripImplicitConv(*boundInit).kind ==
                                     ExpressionKind::StringLiteral) {
                    std::string txt8(stripImplicitConv(*boundInit)
                                         .as<StringLiteral>()
                                         .getValue());
                    c->VpiValue("STRING:" + txt8);
                    c->VpiConstType(vpiStringConst);
                    c->VpiSize((int32_t)iv.getBitWidth());
                    c->VpiDecompile(txt8);
                    strOv8 = true;
                }
                // An override whose value ORIGINATES in a bit-pattern
                // expression (a concat/replication, however many param hops
                // and struct-member selects away) keeps that BINARY encoding:
                // BIN at the value width with a sized-binary decompile. A
                // value that traces back to a plain integer stays UINT
                // (Surelog: BSOPPS* .PadType(TargetCfg.dio_pad_type[k]) with
                // '{dio_pad_type: {N{B}}} vs ParameterPassedToSubmodule* with
                // TargetCfg = 1).
                std::function<bool(const Expression&, int)> bitPatOrigin =
                    [&](const Expression& e0, int d0) -> bool {
                    if (d0 > 8)
                        return false;
                    auto& e8 = stripImplicitConv(e0);
                    switch (e8.kind) {
                        case ExpressionKind::Replication:
                        case ExpressionKind::Concatenation:
                            return true;
                        case ExpressionKind::MemberAccess:
                            return bitPatOrigin(
                                e8.as<MemberAccessExpression>().value(), d0 + 1);
                        case ExpressionKind::ElementSelect:
                            return bitPatOrigin(
                                e8.as<ElementSelectExpression>().value(), d0 + 1);
                        case ExpressionKind::RangeSelect:
                            return bitPatOrigin(
                                e8.as<RangeSelectExpression>().value(), d0 + 1);
                        case ExpressionKind::StructuredAssignmentPattern: {
                            auto& ap8 =
                                e8.as<StructuredAssignmentPatternExpression>();
                            for (auto& ms8 : ap8.memberSetters)
                                if (ms8.expr && bitPatOrigin(*ms8.expr, d0 + 1))
                                    return true;
                            return ap8.defaultSetter &&
                                   bitPatOrigin(*ap8.defaultSetter, d0 + 1);
                        }
                        case ExpressionKind::SimpleAssignmentPattern: {
                            for (auto* el8 :
                                 e8.as<SimpleAssignmentPatternExpression>()
                                     .elements())
                                if (el8 && bitPatOrigin(*el8, d0 + 1))
                                    return true;
                            return false;
                        }
                        case ExpressionKind::NamedValue: {
                            auto& sy8 = e8.as<NamedValueExpression>().symbol;
                            if (sy8.kind != SymbolKind::Parameter)
                                return false;
                            if (auto* in8 =
                                    sy8.as<ParameterSymbol>().getInitializer())
                                return bitPatOrigin(*in8, d0 + 1);
                            return false;
                        }
                        default:
                            return false;
                    }
                };
                bool enumOv8 = false;
                if (typedParam && !vecAliasOv8 && !strOv8 &&
                    ps.getType().getCanonicalType().kind ==
                        SymbolKind::EnumType &&
                    boundInit && bitPatOrigin(*boundInit, 0) &&
                    iv.getBitWidth() <= 64) {
                    int32_t w6 = (int32_t)iv.getBitWidth();
                    std::string bits6;
                    for (int32_t i6 = w6 - 1; i6 >= 0; i6--)
                        bits6 += (iv[i6] == slang::logic_t(1)) ? '1' : '0';
                    c->VpiValue("BIN:" + bits6);
                    c->VpiConstType(vpiBinaryConst);
                    c->VpiSize(w6);
                    c->VpiDecompile(std::to_string(w6) + "'b" + bits6);
                    enumOv8 = true;
                }
                // A typed VECTOR param override whose value ORIGINATES in a
                // BASED hex/bin/oct literal — directly (#(.Q(8'hcd))) or
                // through parameter refs (#(.P(PP)) with PP = 8'hab) — keeps
                // that base encoding at the param width with the origin's
                // sized decompile (Surelog; rp32_r5p_mouse_soc_simple_top
                // cpu.IFU_RST <- soc IFU_RST = 32'h8000_0000).
                bool srcBaseOv8 = false;
                // An UNTYPED param overridden by a based literal WIDER than
                // 64 bits keeps that spelling too: the decimal fold below
                // cannot represent it (LargeHexString's 36864-bit
                // `.INIT_i(36864'h…)` folds to garbage without this).
                bool wideBaseOv8 = !typedParam && iv.getBitWidth() > 64;
                if (((typedParam &&
                      ps.getType().getCanonicalType().kind ==
                          SymbolKind::PackedArrayType &&
                      iv.getBitWidth() <= 64) ||
                     wideBaseOv8) &&
                    !vecAliasOv8 && !strOv8 && !enumOv8 && boundInit) {
                    const Expression* org8 = &stripImplicitConv(*boundInit);
                    for (int h8 = 0;
                         h8 < 8 && org8->kind == ExpressionKind::NamedValue;
                         h8++) {
                        auto& sy9 = org8->as<NamedValueExpression>().symbol;
                        if (sy9.kind != SymbolKind::Parameter)
                            break;
                        auto* in9 = sy9.as<ParameterSymbol>().getInitializer();
                        if (!in9)
                            break;
                        org8 = &stripImplicitConv(*in9);
                    }
                    if (org8->kind == ExpressionKind::IntegerLiteral) {
                        std::string raw9(rawText(org8->sourceRange));
                        auto tick9 = raw9.find('\'');
                        if (tick9 != std::string::npos) {
                            size_t bp9 = tick9 + 1;
                            if (bp9 < raw9.size() &&
                                (raw9[bp9] == 's' || raw9[bp9] == 'S'))
                                bp9++;
                            char base9 = bp9 < raw9.size()
                                             ? (char)tolower(raw9[bp9])
                                             : 'd';
                            if (base9 == 'h' || base9 == 'b' || base9 == 'o') {
                                std::string dg9 =
                                    stripSep(raw9.substr(bp9 + 1));
                                c->VpiValue((base9 == 'h'   ? "HEX:"
                                             : base9 == 'b' ? "BIN:"
                                                            : "OCT:") +
                                            dg9);
                                c->VpiConstType(base9 == 'h' ? vpiHexConst
                                                : base9 == 'b'
                                                    ? vpiBinaryConst
                                                    : vpiOctConst);
                                c->VpiSize((int32_t)iv.getBitWidth());
                                c->VpiDecompile(stripSep(raw9));
                                srcBaseOv8 = true;
                            }
                        }
                    }
                }
                // A param OVERRIDE whose bound expression is a BIT- or
                // PART-SELECT encodes BINARY at the SELECT's own width with a
                // based decompile — the same rule a select DEFAULT follows,
                // and in every declaration form. Measured on one source:
                //   sub #(.A(V8[0]), .B(V8[3:0]), .C(V8[2]))  (A=`bit`,
                //   B=`bit [3:0]`, C untyped, V8 = 8'h25)
                //   -> BIN:1 "1'b1" / BIN:0101 "4'b0101" / BIN:1 "1'b1",
                // where the same instance overridden with plain literals keeps
                // the literal's own base instead.
                bool selOv8 = false;
                if (!vecAliasOv8 && !strOv8 && !enumOv8 && !srcBaseOv8 &&
                    boundInit) {
                    // The origin is followed THROUGH parameter references the
                    // way srcBaseOv8 follows a based literal: ElabCParam's
                    // `.Depth(ReqDepth)` inherits the 4-bit BIN encoding of the
                    // select that produced ReqDepth one instance up.
                    const Expression* bo8 = &stripImplicitConv(*boundInit);
                    for (int h8 = 0;
                         h8 < 8 && bo8->kind == ExpressionKind::NamedValue;
                         h8++) {
                        auto& sy8 = bo8->as<NamedValueExpression>().symbol;
                        if (sy8.kind != SymbolKind::Parameter)
                            break;
                        auto* in8 = sy8.as<ParameterSymbol>().getInitializer();
                        if (!in8)
                            break;
                        bo8 = &stripImplicitConv(*in8);
                    }
                    auto& bs8 = *bo8;
                    const Expression* bb8 =
                        bs8.kind == ExpressionKind::ElementSelect
                            ? &bs8.as<ElementSelectExpression>().value()
                        : bs8.kind == ExpressionKind::RangeSelect
                            ? &bs8.as<RangeSelectExpression>().value()
                            : nullptr;
                    if ((bs8.kind == ExpressionKind::ElementSelect ||
                         bs8.kind == ExpressionKind::RangeSelect) &&
                        bb8 && bb8->type && bb8->type->isIntegral() &&
                        bs8.type && bs8.type->getBitWidth() > 0 &&
                        bs8.type->getBitWidth() <= 64) {
                        int32_t w8 = (int32_t)bs8.type->getBitWidth();
                        slang::SVInt wv8 = iv.resize((slang::bitwidth_t)w8);
                        std::string bits8;
                        for (int32_t i8 = w8 - 1; i8 >= 0; i8--)
                            bits8 += (wv8[i8] == slang::logic_t(1)) ? '1' : '0';
                        c->VpiValue("BIN:" + bits8);
                        c->VpiConstType(vpiBinaryConst);
                        c->VpiSize(w8);
                        c->VpiDecompile(std::to_string(w8) + "'b" + bits8);
                        selOv8 = true;
                    }
                }
                // A param OVERRIDE whose actual resolves (through param refs)
                // to a MULTIDIMENSIONAL packed param encodes BINARY at the
                // FORMAL's width — and the bits come from Surelog's UNREDUCED
                // concat, where every operand contributes its OWN declared
                // width, so an `int` element is 32 bits wide there and the
                // formal's low W bits are NOT the SV-correct packed value.
                // Measured, one source: `logic [1:0][1:0] MD = {A, B}` with
                // `int A=1, B=2` driving `parameter logic [3:0] p` gives
                // BIN:0010 size 4, decompile "0010" — BARE, no size prefix —
                // where the same instance driven by a 1-D concat param
                // (logic [3:0] CC = {2'b01, 2'b10}) keeps CC's own "4'b0110".
                bool mdConcatOv8 = false;
                if (!vecAliasOv8 && !strOv8 && !enumOv8 && !srcBaseOv8 &&
                    !selOv8 && !strRefOv8 && typedParam && boundInit &&
                    ps.getType().getCanonicalType().isPackedArray()) {
                    const Expression* mo8 = &stripImplicitConv(*boundInit);
                    const ParameterSymbol* orig8 = nullptr;
                    for (int h8 = 0;
                         h8 < 8 && mo8->kind == ExpressionKind::NamedValue;
                         h8++) {
                        auto& sy8 = mo8->as<NamedValueExpression>().symbol;
                        if (sy8.kind != SymbolKind::Parameter)
                            break;
                        auto& mp8 = sy8.as<ParameterSymbol>();
                        if (packedDimCount(mp8.getType()) > 1) {
                            orig8 = &mp8;
                            break;
                        }
                        auto* in8 = mp8.getInitializer();
                        if (!in8)
                            break;
                        mo8 = &stripImplicitConv(*in8);
                    }
                    uint64_t fw8 = ps.getType().getBitWidth();
                    const Expression* oi8 =
                        orig8 ? orig8->getInitializer() : nullptr;
                    if (oi8 && fw8 > 0 && fw8 <= 64) {
                        auto& oc8 = stripImplicitConv(*oi8);
                        std::span<const Expression* const> ops8;
                        if (oc8.kind == ExpressionKind::Concatenation)
                            ops8 = oc8.as<ConcatenationExpression>().operands();
                        else if (oc8.kind ==
                                 ExpressionKind::SimpleAssignmentPattern)
                            ops8 = oc8.as<SimpleAssignmentPatternExpression>()
                                       .elements();
                        std::string wide8;
                        bool ok8 = !ops8.empty();
                        ASTContext mctx8(comp.getRoot(), LookupLocation::max);
                        for (auto* oe8 : ops8) {
                            if (!oe8 || !oe8->type || !oe8->type->isIntegral()) {
                                ok8 = false;
                                break;
                            }
                            ConstantValue ov8 = mctx8.tryEval(*oe8);
                            uint64_t ow8 = oe8->type->getBitWidth();
                            if (!ov8.isInteger() ||
                                ov8.integer().hasUnknown() || ow8 == 0 ||
                                ow8 > 256) {
                                ok8 = false;
                                break;
                            }
                            SVInt rv8 =
                                ov8.integer().resize((slang::bitwidth_t)ow8);
                            for (int64_t i8 = (int64_t)ow8 - 1; i8 >= 0; i8--)
                                wide8 +=
                                    (rv8[(int32_t)i8] == slang::logic_t(1))
                                        ? '1'
                                        : '0';
                        }
                        if (ok8 && wide8.size() >= fw8) {
                            std::string bits8 =
                                wide8.substr(wide8.size() - (size_t)fw8);
                            c->VpiValue("BIN:" + bits8);
                            c->VpiConstType(vpiBinaryConst);
                            c->VpiSize((int32_t)fw8);
                            c->VpiDecompile(bits8);
                            mdConcatOv8 = true;
                        }
                    }
                }
                // Typed params fold UINT at the type width; untyped INT at
                // size -1.
                if (vecAliasOv8 || strOv8 || enumOv8 || srcBaseOv8 ||
                    selOv8 || strRefOv8 || mdConcatOv8) {
                }
                else if (typedParam && iv.getBitWidth() > 64) {
                    // WIDE values overflow the decimal fold — encode HEX at
                    // the value width with a sized-hex decompile (Surelog).
                    std::string hx8 = iv.toString(LiteralBase::Hex, false);
                    c->VpiValue("HEX:" + hx8);
                    c->VpiConstType(vpiHexConst);
                    c->VpiSize((int32_t)iv.getBitWidth());
                    c->VpiDecompile(std::to_string(iv.getBitWidth()) + "'h" +
                                    hx8);
                }
                // An override actual that READS a member-leftover struct
                // parameter resolves through the constant stamped on the
                // typespec_member, so it inherits THAT constant's encoding: an
                // INT-encoded (ternary-produced) leftover keeps vpiIntConst at
                // the target width (FuncStructValSimple work@top.u1
                // INPUT_WIDTH: INT:2/ct 7, where a plain typed override would
                // give UINT:2/ct 9).
                else if (boundInit && memLeftIntRead(*boundInit)) {
                    c->VpiValue("INT:" + digits);
                    c->VpiConstType(vpiIntConst);
                    c->VpiSize((int32_t)iv.getBitWidth());
                }
                // A RANGED untyped param (parameter [0:0] REG_ALU) folds its
                // override like a typed one: UINT at the declared width
                // (mriscv ALU_beq #(.REG_ALU(REG_ALU))).
                else if (typedParam || genChild || isRangedUntypedParam(ps)) {
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    // An untyped NO-DEFAULT param has no width source; Surelog's
                    // uniquified override folds it at the 64-bit default width.
                    c->VpiSize((noDefLitMP && !typedParam &&
                                !isRangedUntypedParam(ps))
                                   ? 64
                                   : (int32_t)iv.getBitWidth());
                }
                // An untyped param overridden by a bare REFERENCE to another
                // param (dut #(width) dut1 with `parameter width = 16`):
                // Surelog copies the referenced param's already-evaluated
                // Value, which carries its type width — UINT at that width,
                // not the unsized INT a literal override folds to
                // (OneNetRange).
                else if (overridden && boundInit &&
                         stripImplicitConv(*boundInit).kind ==
                             ExpressionKind::NamedValue &&
                         stripImplicitConv(*boundInit)
                                 .as<NamedValueExpression>()
                                 .symbol.kind == SymbolKind::Parameter) {
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiSize((int32_t)iv.getBitWidth());
                }
                else {
                    // Surelog's untyped-parameter override
                    // (NetlistElaboration.cpp:405): the instance Value is
                    // stamped verbatim — UINT for a non-negative integer,
                    // size 64 — and `adjustSize` then runs with the
                    // PARAMETER's own typespec.  That typespec is the
                    // int_typespec Surelog derives from a PLAIN LITERAL
                    // default, so the override folds at the DEFAULT
                    // literal's width with the value MASKED to it
                    // (`parameter a = 1'b1` overridden with 4 -> UINT:0
                    // size 1; `parameter a = 1` -> UINT:4 size 32).  An
                    // EXPRESSION default and a DECIMAL-based literal
                    // default (decBasedInit) carry no typespec at all, so
                    // adjustSize is a no-op there and the constant keeps
                    // the Value's own encoding.
                    // ...and only for a BARE-DECIMAL override actual, which
                    // is what Surelog turns into the simple 64-bit unsigned
                    // Value.  A BASED actual ('d7_200) builds an LValue
                    // instead, whose uhdmValue is the unsized INT this falls
                    // through to (ParameterWithUnderscoreValue).
                    // ...and an ARITHMETIC actual over bare-decimal / parameter
                    // leaves reduces to the same simple unsigned Value, so it
                    // takes the same adjustSize path (BasicOh
                    // `oh_bin2gray #(.N(AW+1))` -> golden UINT:6 size 32, not
                    // the unsized INT a based actual leaves behind).
                    bool bareDecOv8 = false;
                    if (overridden && boundInit) {
                        auto& bo8 = stripImplicitConv(*boundInit);
                        if (bo8.kind == ExpressionKind::IntegerLiteral)
                            bareDecOv8 =
                                rawText(bo8.sourceRange).find('\'') ==
                                std::string_view::npos;
                        else if (bo8.kind == ExpressionKind::BinaryOp ||
                                 bo8.kind == ExpressionKind::UnaryOp)
                            bareDecOv8 =
                                rawText(bo8.sourceRange).find('\'') ==
                                std::string_view::npos;
                    }
                    int32_t dw8 = -1;
                    if (bareDecOv8 && !decBasedInit && defaultInit) {
                        auto& dl8 = stripImplicitConv(*defaultInit);
                        if (dl8.kind == ExpressionKind::IntegerLiteral &&
                            dl8.type && dl8.type->isIntegral() &&
                            dl8.type->getBitWidth() > 0 &&
                            dl8.type->getBitWidth() <= 64)
                            dw8 = (int32_t)dl8.type->getBitWidth();
                    }
                    if (dw8 > 0) {
                        slang::SVInt mv8 = iv.resize((slang::bitwidth_t)dw8);
                        mv8.setSigned(false);
                        std::string md8 =
                            mv8.toString(LiteralBase::Decimal, false);
                        c->VpiValue("UINT:" + md8);
                        c->VpiDecompile(md8);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiSize(dw8);
                    }
                    else if (bareDecOv8 && defaultInit) {
                        // No parameter typespec at all: adjustSize returns
                        // immediately and the Value's own 64-bit UINT stands
                        // (BlackParrotSkipParam `.lg_max_val_lp(10)` over a
                        // `($clog2(...))` default -> UINT:10 size 64).
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiSize(64);
                    }
                    else {
                        c->VpiValue("INT:" + digits);
                        c->VpiConstType(vpiIntConst);
                        c->VpiSize(-1);
                    }
                }
                c->VpiParent(pa);
                if (defaultInit)
                    setLoc(c, stripImplicitConv(*defaultInit).sourceRange);
                if (wantTs) {
                    auto* rt = s.MakeRef_typespec();
                    std::string tsPrefix = prefix;
                    if (tsPrefix.size() >= 2 &&
                        tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                        tsPrefix.resize(tsPrefix.size() - 2);
                    // Vector-typedef override Rhs ts refs are NAMELESS
                    // (Surelog).
                    if (!vecAliasOv8)
                        rt->VpiFullName(tsPrefix);
                    rt->VpiParent(c);
                    c->Typespec(rt);
                    rhsRt = rt;
                }
                pa->Rhs(c);
                if (topView)
                    elabParamConst[&ps] = c;
                passigns->push_back(pa);
                if (prt) {
                    if (!inPackage) {
                        pendingParamTs.push_back({&ps, up, prt, rhsRt, typedParam});
                    }
                    else {
                        auto* its = makeParamTs(ps, typedParam);
                        // Surelog instances the ts at the package only for
                        // TYPED params; untyped ones stay Instance-less.
                        if (typedParam)
                            stampPkgTsInst(its);
                        if (rhsRt)
                            rhsRt->Actual_typespec(its);
                        prt->Actual_typespec(its);
                        if (typedParam || isRangedUntypedParam(ps))
                            its->VpiParent(up);
                    }
                }
                continue;
            }
            // A REAL param OVERRIDE folds to the TRUNCATED integer value
            // (Surelog: real p = 0 with #(1.0) -> UINT:1 size 32) at the
            // default's site, carrying a ts ref to the param's real_typespec.
            else if (cvo.isReal()) {
                int64_t rv = (int64_t)cvo.real();
                std::string digits = std::to_string(rv);
                auto* c = s.MakeConstant();
                c->VpiDecompile(digits);
                c->VpiSize(32);
                c->VpiValue("UINT:" + digits);
                c->VpiConstType(vpiUIntConst);
                c->VpiParent(pa);
                if (defaultInit)
                    setLoc(c, stripImplicitConv(*defaultInit).sourceRange);
                if (wantTs) {
                    auto* rt = s.MakeRef_typespec();
                    std::string tsPrefix = prefix;
                    if (tsPrefix.size() >= 2 &&
                        tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                        tsPrefix.resize(tsPrefix.size() - 2);
                    rt->VpiFullName(tsPrefix);
                    rt->VpiParent(c);
                    c->Typespec(rt);
                    rhsRt = rt;
                }
                pa->Rhs(c);
                if (topView)
                    elabParamConst[&ps] = c;
                passigns->push_back(pa);
                if (prt) {
                    if (!inPackage) {
                        pendingParamTs.push_back(
                            {&ps, up, prt, rhsRt, typedParam});
                    }
                    else {
                        auto* its = makeParamTs(ps, typedParam);
                        if (typedParam)
                            stampPkgTsInst(its);
                        if (rhsRt)
                            rhsRt->Actual_typespec(its);
                        prt->Actual_typespec(its);
                        if (typedParam || isRangedUntypedParam(ps))
                            its->VpiParent(up);
                    }
                }
                continue;
            }
        }
        // A NO-DEFAULT param carries no direct Rhs (the bound initializer is
        // the override expression); the ELAB param_assign later SHARES the
        // cont-assign fold constant (noDefOvPa backpatch).
        if (!hasDefault && topView && boundInit) {
            noDefOvPa[&member].push_back(pa);
            // ...and if no CA fold ever claims it, synthesize the Rhs from the
            // override literal itself (drainNoDefOvRhs).
            if (!pa->Rhs())
                noDefOvRhsFallback.push_back({pa, &ps, prefix});
        }
        if (auto init0 = (overridden      ? defaultInit
                          : (!hasDefault) ? nullptr
                                          : ps.getInitializer())) {
            const Expression* init = init0;
            while (init->kind == ExpressionKind::Conversion &&
                   init->as<ConversionExpression>().isImplicit())
                init = &init->as<ConversionExpression>().operand();
            UHDM::any* rhs = nullptr;
            // A struct parameter initialized by a MEMBER-BY-MEMBER const
            // function does NOT fold to a constant: Surelog's EvalFunc hands
            // back the function's own struct_var, and the VALUE lives in the
            // leftovers stamped on the struct typespec's members (see
            // srlgEvalFuncMemberLeftovers).  So the elab param_assign Rhs is a
            // bare struct_var carrying a ts ref to the param's struct
            // typespec, and we record the per-member constants for the stamp
            // pass (FuncStructValSimple work@top.CVA6Cfg).
            if (topView && !inPackage) {
                if (auto* mlSub = memLeftInitCall(*init)) {
                    auto& mst = ps.getType().getCanonicalType();
                    auto* leftovers = srlgEvalFuncMemberLeftovers(*mlSub);
                    if (leftovers &&
                        mst.kind == SymbolKind::PackedStructType &&
                        ps.getValue().isInteger() &&
                        !ps.getValue().integer().hasUnknown()) {
                        auto& whole = ps.getValue().integer();
                        SrlgMemLeftStamp st9;
                        bool ok9 = true;
                        size_t li9 = 0;
                        for (auto& f9 :
                             mst.as<PackedStructType>().membersOfType<FieldSymbol>()) {
                            if (li9 >= leftovers->size()) {
                                ok9 = false;
                                break;
                            }
                            auto* c9 = makeMemLeftConst(s, f9, whole,
                                                        (*leftovers)[li9].enc);
                            if (!c9) {
                                ok9 = false;
                                break;
                            }
                            // SPAN residue (dump-match only, cmp ignores
                            // locations): golden gives each leftover the span
                            // of the object it reused — the fn body's own
                            // literal (42:23) for `= 32`, the CALLER's read
                            // site (79:22) for the ternary, the caller's own
                            // pattern constant (28:21) for the wide member
                            // copy.  We park all three at the call.
                            setLoc(c9, init->sourceRange);
                            st9.names.push_back(std::string(f9.name));
                            st9.values.push_back(c9);
                            li9++;
                        }
                        if (ok9 && !st9.names.empty()) {
                            memLeftStamps.push_back(st9);
                            auto* sv9 = s.MakeStruct_var();
                            setLoc(sv9, init->sourceRange);
                            auto* svrt9 = s.MakeRef_typespec();
                            svrt9->VpiParent(sv9);
                            sv9->Typespec(svrt9);
                            memLeftStructVars.emplace_back(sv9, up);
                            rhs = sv9;
                        }
                    }
                }
            }
            // A localparam whose init is a single-argument SYSTEM function call
            // ($clog2(Depth)) of an OVERRIDDEN param that resolves (through the
            // override chain) to a member-init localparam (N = Info.x) keeps a
            // SYMBOLIC sys_func_call in the elab view, with the arg substituted
            // by the member-init hier_path (Surelog does not fold it).
            std::function<const ParameterSymbol*(const ParameterSymbol*, int)>
                resolveMemberInit = [&](const ParameterSymbol* p,
                                        int depth) -> const ParameterSymbol* {
                if (depth > 8)
                    return nullptr;
                auto* pin = p->getInitializer();
                if (!pin)
                    return nullptr;
                auto& si = stripImplicitConv(*pin);
                if (si.kind == ExpressionKind::MemberAccess) {
                    auto& mb = stripImplicitConv(
                        si.as<MemberAccessExpression>().value());
                    if (mb.kind == ExpressionKind::NamedValue &&
                        mb.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter &&
                        mb.as<NamedValueExpression>()
                                .symbol.getType()
                                .getCanonicalType()
                                .kind == SymbolKind::PackedStructType)
                        return p;
                    return nullptr;
                }
                const Symbol* rs = nullptr;
                if (si.kind == ExpressionKind::NamedValue)
                    rs = &si.as<NamedValueExpression>().symbol;
                else if (si.kind == ExpressionKind::HierarchicalValue)
                    rs = &si.as<HierarchicalValueExpression>().symbol;
                if (rs && rs->kind == SymbolKind::Parameter)
                    return resolveMemberInit(&rs->as<ParameterSymbol>(),
                                             depth + 1);
                return nullptr;
            };
            const ParameterSymbol* clogMemberInit = nullptr;
            const CallExpression* clogCall = nullptr;
            if (topView && init->kind == ExpressionKind::Call &&
                init->as<CallExpression>().isSystemCall() &&
                init->as<CallExpression>().arguments().size() == 1) {
                auto& a0 = stripImplicitConv(
                    *init->as<CallExpression>().arguments()[0]);
                const Symbol* rs = nullptr;
                if (a0.kind == ExpressionKind::NamedValue)
                    rs = &a0.as<NamedValueExpression>().symbol;
                else if (a0.kind == ExpressionKind::HierarchicalValue)
                    rs = &a0.as<HierarchicalValueExpression>().symbol;
                if (rs && rs->kind == SymbolKind::Parameter)
                    if ((clogMemberInit = resolveMemberInit(
                             &rs->as<ParameterSymbol>(), 0)))
                        clogCall = &init->as<CallExpression>();
            }
            // `'{default: X}` on an unpacked-array parameter EXPANDS — outside
            // the declaring scope's DEFINITION view — into an array_expr with
            // one folded element constant per element, each at the default
            // value's own span and the ELEMENT type's width (Surelog;
            // DefaultPatternModule/DefaultPatternInt).  The copies an IMPORT
            // makes parent their constants at the array_expr; the elaborator's
            // own object leaves them unparented and, for a MODULE-local param,
            // tags the array_expr with the param's array_typespec.
            if ((topView || isImported) &&
                ps.getType().getCanonicalType().kind ==
                    SymbolKind::FixedSizeUnpackedArrayType) {
                auto& dp8 = stripImplicitConv(*init);
                const Expression* dexp8 = nullptr;
                if (dp8.kind == ExpressionKind::StructuredAssignmentPattern) {
                    auto& sap8 = dp8.as<StructuredAssignmentPatternExpression>();
                    if (sap8.defaultSetter && sap8.memberSetters.empty() &&
                        sap8.typeSetters.empty() && sap8.indexSetters.empty())
                        dexp8 = sap8.defaultSetter;
                }
                auto& uat8 =
                    ps.getType().getCanonicalType().as<FixedSizeUnpackedArrayType>();
                const Type* uel8 = &uat8.elementType;
                if (dexp8 && uel8->getCanonicalType().isIntegral()) {
                    ASTContext dctx8(comp.getRoot(), LookupLocation::max);
                    ConstantValue dcv8 = dctx8.tryEval(*dexp8);
                    if (dcv8 && dcv8.isInteger() &&
                        !dcv8.integer().hasUnknown()) {
                        std::string dd8 =
                            dcv8.integer().toString(LiteralBase::Decimal, false);
                        // An UNSIZED `'1` default is adjustSize's orig_size==-1
                        // tail (EmitHelpers slAdjustBinConst): the element's
                        // width filled with ones, not the literal's bare 1
                        // (ParamArrayUnsizedPattern: `int unsigned A[N] =
                        // '{default: '1}` -> UINT:4294967295 size 32).
                        if (auto& du8 = stripImplicitConv(*dexp8);
                            du8.kind ==
                            ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                            logic_t lb8 =
                                du8.as<UnbasedUnsizedIntegerLiteral>()
                                    .getLiteralValue();
                            SLAdjustedConst adj8;
                            if (!lb8.isUnknown() &&
                                slAdjustBinConst(lb8.value ? "1" : "0", -1,
                                                 false,
                                                 (int32_t)uel8->getBitWidth(),
                                                 false, adj8) &&
                                adj8.prefix == "UINT:")
                                dd8 = adj8.digits;
                        }
                        auto* ae8 = s.MakeArray_expr();
                        ae8->VpiParent(pa);
                        auto* xv8 = s.MakeExprVec();
                        for (uint32_t i8 = 0; i8 < uat8.range.width(); i8++) {
                            auto* c8 = s.MakeConstant();
                            c8->VpiDecompile(dd8);
                            c8->VpiSize((int32_t)uel8->getBitWidth());
                            c8->VpiValue("UINT:" + dd8);
                            c8->VpiConstType(vpiUIntConst);
                            setLoc(c8, dexp8->sourceRange);
                            if (isImported)
                                c8->VpiParent(ae8);
                            xv8->push_back(c8);
                        }
                        ae8->Exprs(xv8);
                        if (topView && !inPackage && !isImported) {
                            auto* rt8 = s.MakeRef_typespec();
                            std::string tsPfx8 = prefix;
                            if (tsPfx8.size() >= 2 &&
                                tsPfx8.compare(tsPfx8.size() - 2, 2, "::") == 0)
                                tsPfx8.resize(tsPfx8.size() - 2);
                            rt8->VpiFullName(tsPfx8);
                            rt8->VpiParent(ae8);
                            // Surelog points this ref at the MODULE DEF view's
                            // array_typespec, not a fresh clone
                            // (defParamArrayTs) — the sharing is what lets the
                            // UHDM elaborator bind the def-view unpacked dim's
                            // ref_obj under this instance's scope.
                            UHDM::array_typespec* shared8 = nullptr;
                            if (auto* dsyn8 = ps.getSyntax())
                                if (auto it8 = defParamArrayTs.find(dsyn8);
                                    it8 != defParamArrayTs.end())
                                    shared8 = it8->second;
                            rt8->Actual_typespec(
                                shared8 ? shared8
                                        : makeUnpackedArrayParamTs(
                                              ps, tsPfx8, rt8, nullptr, true,
                                              tsPfx8));
                            ae8->Typespec(rt8);
                        }
                        rhs = ae8;
                    }
                }
            }
            // A MATERIALIZED IMPORTED param whose home default is an explicit
            // TYPE cast folds identically in BOTH module views: the folded
            // constant keeps the cast's whole span and a ts ref to its own
            // fresh copy of the param's declared typespec. The def view never
            // reaches the topView fold chain below, and the elab view would
            // reach it only as an `importedFold` BARE constant (the shape
            // measured for size-cast/concat imports) — a type cast is neither.
            // ParamCast: work@otp_ctrl.NumAgents is UINT:3/size 32 with the
            // 10:12 `int` typespec in allModules and topModules alike.
            if (!rhs && pkgTypeCastFold9 && !inPackage && isImported &&
                ps.getValue().isInteger() &&
                !ps.getValue().integer().hasUnknown()) {
                auto& iv9 = ps.getValue().integer();
                bool neg9 = iv9.isSigned() && iv9.isNegative();
                std::string dg9 = iv9.toString(LiteralBase::Decimal, false);
                auto* c9 = s.MakeConstant();
                c9->VpiDecompile(dg9);
                c9->VpiSize((int32_t)ps.getType().getBitWidth());
                c9->VpiValue((neg9 ? "INT:" : "UINT:") + dg9);
                c9->VpiConstType(neg9 ? vpiIntConst : vpiUIntConst);
                c9->VpiParent(pa);
                setLoc(c9, init->sourceRange);
                if (wantTs) {
                    auto* rt9 = s.MakeRef_typespec();
                    std::string tsp9 = prefix;
                    if (tsp9.size() >= 2 &&
                        tsp9.compare(tsp9.size() - 2, 2, "::") == 0)
                        tsp9.resize(tsp9.size() - 2);
                    rt9->VpiFullName(tsp9);
                    rt9->VpiParent(c9);
                    c9->Typespec(rt9);
                    rhsRt = rt9;
                }
                rhs = c9;
            }
            if (!rhs && topView) {
                if (init->kind == ExpressionKind::IntegerLiteral) {
                    forceConstParent = true;
                    rhs = emitExpr(*init, pa, prefix, netMap);
                    forceConstParent = false;
                    // A REAL param initialized with an INTEGER literal keeps
                    // the literal's natural width (localparam real p3 = 123 ->
                    // UINT:123 size 32), NOT the real's 64-bit width (Surelog).
                    if (rhs) {
                        if (ps.getType().getCanonicalType().isFloating())
                            ((UHDM::constant*)rhs)
                                ->VpiSize(
                                    (int32_t)init->type->getBitWidth());
                        else
                            ((UHDM::constant*)rhs)
                                ->VpiSize(
                                    (int32_t)ps.getType().getBitWidth());
                    }
                    // ...and the value is TRUNCATED to that width, because
                    // Surelog re-sizes the elaborated literal through
                    // `adjustSize`'s vpiUIntConst arm (`uval &=
                    // getMask(size)`, CompileHelper.cpp:3991): `parameter
                    // [3:0] e = 20` is UINT:4 in the elab view and `parameter
                    // [2:1] a = 10` is UINT:2, while both keep the raw literal
                    // at size 64 in the definition view. Only the UINT
                    // encoding re-encodes; a based literal keeps its own form.
                    if (rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                        !ps.getType().getCanonicalType().isFloating()) {
                        auto* cm9 = (UHDM::constant*)rhs;
                        std::string_view mv9 = cm9->VpiValue();
                        int32_t msz9 = cm9->VpiSize();
                        if (mv9.rfind("UINT:", 0) == 0 && msz9 > 0 &&
                            msz9 < 64) {
                            uint64_t uv9 = 0;
                            auto [pe9, ec9] = std::from_chars(
                                mv9.data() + 5, mv9.data() + mv9.size(), uv9);
                            if (ec9 == std::errc() &&
                                pe9 == mv9.data() + mv9.size()) {
                                uint64_t mk9 = (1ull << msz9) - 1;
                                if ((uv9 & mk9) != uv9) {
                                    std::string dg9 =
                                        std::to_string(uv9 & mk9);
                                    cm9->VpiValue("UINT:" + dg9);
                                    cm9->VpiDecompile(dg9);
                                }
                            }
                        }
                    }
                    // A SIGNED-BINARY literal whose SIGN BIT is set re-encodes
                    // as a decimal INT at the target width. Measured, one
                    // source per row, only the named declaration changed:
                    //   parameter [1:0] F1 = 1'sb1    -> INT:3   size 2
                    //   parameter [1:0] F2 = 2'sb10   -> INT:2   size 2
                    //   parameter       F3 = 2'sb10   -> INT:2   size 2
                    //   parameter int   H3 = 4'sb1010 -> INT:-6  size 32
                    //   parameter [3:0] G3 = 4'sb0101 -> BIN:0101 (positive)
                    //   parameter [3:0] G1 = 4'shA    -> HEX:A    (hex base)
                    // A SIGNED target sign-extends and prints signed; an
                    // UNSIGNED one instead shows Surelog's widening quirk
                    // `(pattern << k) | ((1 << k) - 1)` for k = targetWidth -
                    // literalWidth — measured at [5:0]=2'sb10 -> 47,
                    // [7:0]=1'sb1 -> 255, [4:0]=3'sb101 -> 23; k = 0 leaves the
                    // pattern alone.
                    if (rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                        !ps.getType().getCanonicalType().isFloating()) {
                        std::string raw6(rawText(init->sourceRange));
                        auto tk6 = raw6.find('\'');
                        bool sgnBin6 = false;
                        if (tk6 != std::string::npos && tk6 + 2 < raw6.size() &&
                            (raw6[tk6 + 1] == 's' || raw6[tk6 + 1] == 'S'))
                            sgnBin6 = tolower(raw6[tk6 + 2]) == 'b';
                        auto lv6 = init->as<IntegerLiteral>().getValue();
                        uint64_t lw6 = lv6.getBitWidth();
                        if (sgnBin6 && lw6 > 0 && lw6 <= 64 &&
                            !lv6.hasUnknown() &&
                            lv6[(int32_t)lw6 - 1] == slang::logic_t(1)) {
                            uint64_t pat6 =
                                lv6.as<uint64_t>().value_or(0) &
                                (lw6 == 64 ? ~0ull : ((1ull << lw6) - 1));
                            uint64_t tw6 = ps.getType().getBitWidth();
                            if (tw6 == 0 || tw6 > 64)
                                tw6 = lw6;
                            bool sgnTgt6 = typedParam && ps.getType().isSigned();
                            std::string dg6;
                            if (sgnTgt6) {
                                int64_t sv6 =
                                    (int64_t)(pat6 | (lw6 == 64
                                                          ? 0
                                                          : (~0ull << lw6)));
                                if (tw6 < 64)
                                    sv6 = (int64_t)((uint64_t)sv6 &
                                                    ((1ull << tw6) - 1));
                                if (tw6 < 64 &&
                                    ((uint64_t)sv6 >> (tw6 - 1)) & 1)
                                    sv6 = (int64_t)((uint64_t)sv6 |
                                                    (~0ull << tw6));
                                dg6 = std::to_string(sv6);
                            }
                            else {
                                uint64_t k6 = tw6 > lw6 ? tw6 - lw6 : 0;
                                uint64_t uv6 = (pat6 << k6) |
                                               (k6 ? ((1ull << k6) - 1) : 0);
                                if (tw6 < 64)
                                    uv6 &= (1ull << tw6) - 1;
                                dg6 = std::to_string(uv6);
                            }
                            auto* c6 = (UHDM::constant*)rhs;
                            c6->VpiValue("INT:" + dg6);
                            c6->VpiConstType(vpiIntConst);
                            c6->VpiDecompile(dg6);
                            c6->VpiSize((int32_t)tw6);
                            // The re-encoded constant's ts ref binds a FRESH
                            // BARE int_typespec (signed per the param type),
                            // not the param's own ranged declaration typespec
                            // (SignedBinConst: `parameter [1:0] p1 = 1'sb1`
                            // folds INT:3 whose actual is a bare int_typespec,
                            // while the parameter object keeps its [1:0] one).
                            signedBinFoldParams.insert(&ps);
                        }
                        // A NON-NEGATIVE signed-binary literal (MSB 0) needs
                        // no re-encoding -- the sign extension is a no-op, so
                        // the BIN value and the literal width both stand --
                        // but it went through the SAME signed evaluation, and
                        // Surelog's rebuilt constant loses the `s` from its
                        // decompile and binds the bare int_typespec all the
                        // same (probe: `parameter [3:0] G3 = 4'sb0101` ->
                        // BIN:0101 "4'b0101" int_typespec; GenCase/GenCaseStmt
                        // `parameter bit signed x_1sb0 = 1'sb0`).
                        else if (sgnBin6 && lw6 > 0 && lw6 <= 64 &&
                                 !lv6.hasUnknown()) {
                            auto* c6 = (UHDM::constant*)rhs;
                            std::string dc6(c6->VpiDecompile());
                            auto tk7 = dc6.find('\'');
                            if (tk7 != std::string::npos && tk7 + 1 < dc6.size() &&
                                (dc6[tk7 + 1] == 's' || dc6[tk7 + 1] == 'S')) {
                                dc6.erase(tk7 + 1, 1);
                                c6->VpiDecompile(dc6);
                            }
                            signedBinFoldParams.insert(&ps);
                        }
                    }
                }
                // Symbolic sys_func_call ($clog2(Info.x)) of a member-init
                // param: re-emit the call with the argument substituted by the
                // member-init hier_path (Surelog keeps it unfolded).
                else if (clogMemberInit && clogCall) {
                    auto* sc = s.MakeSys_func_call();
                    sc->VpiName(std::string(clogCall->getSubroutineName()));
                    sc->VpiParent(pa);
                    setLoc(sc, init->sourceRange);
                    // The substituted member-init path (Info.x) uses the
                    // param-init lvalue-style base span + bare leaf (Surelog).
                    inParamInit = true;
                    auto* he = (UHDM::expr*)emitExpr(
                        *clogMemberInit->getInitializer(), sc, prefix, netMap);
                    inParamInit = false;
                    if (he && he->UhdmType() == UHDM::uhdmhier_path) {
                        auto* hp = (UHDM::hier_path*)he;
                        setLoc(hp, clogCall->arguments()[0]->sourceRange);
                        auto* rt = s.MakeRef_typespec();
                        rt->VpiFullName(prefix.empty()
                                            ? std::string(hp->VpiName())
                                            : prefix + "." +
                                                  std::string(hp->VpiName()));
                        rt->VpiParent(hp);
                        auto* its = s.MakeInt_typespec();
                        if (auto dt = clogMemberInit->getDeclaredType())
                            if (auto* tsyn = dt->getTypeSyntax())
                                setLoc(its, tsyn->sourceRange());
                        if (clogMemberInit->getType().isSigned())
                            its->VpiSigned(true);
                        rt->Actual_typespec(its);
                        hp->Typespec(rt);
                    }
                    if (he) {
                        auto* args = s.MakeAnyVec();
                        args->push_back(he);
                        sc->Tf_call_args(args);
                    }
                    rhs = sc;
                }
                // A TYPED STRING param whose init is NON-literal (a concat)
                // folds to a STRING constant in the ELAB view (the DEF view
                // keeps the operation); a plain string literal re-emits
                // (StringAssignment).
                else if (ps.getType().getCanonicalType().isString() &&
                         stripImplicitConv(*init).kind !=
                             ExpressionKind::StringLiteral &&
                         !containsUserCall(*init)) {
                    ASTContext sctx(comp.getRoot(), LookupLocation::max);
                    ConstantValue scv = sctx.tryEval(*init0);
                    if (scv && scv.isString()) {
                        std::string sv = scv.str();
                        auto* c = s.MakeConstant();
                        c->VpiSize((int32_t)(sv.size() * 8));
                        c->VpiValue("STRING:" + sv);
                        c->VpiConstType(vpiStringConst);
                        c->VpiDecompile(sv);
                        c->VpiParent(pa);
                        setLoc(c, init->sourceRange);
                        if (wantTs) {
                            auto* rt = s.MakeRef_typespec();
                            std::string tsPrefix = prefix;
                            if (tsPrefix.size() >= 2 &&
                                tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                                tsPrefix.resize(tsPrefix.size() - 2);
                            rt->VpiFullName(tsPrefix);
                            rt->VpiParent(c);
                            c->Typespec(rt);
                            rhsRt = rt;
                        }
                        moduleStringParamConst[&member] = c;
                        rhs = c;
                    }
                }
                // ELAB-pkg CONST-FUNCTION-CALL init (Z = g(4)) folds to the
                // evaluated value: size 32, INT/UINT by the value's sign,
                // whole-init span, ts ref patched to the param ts (Surelog).
                else if (pkgElabComputed && containsUserCall(*init) &&
                         ps.getValue().isInteger() &&
                         !ps.getValue().integer().hasUnknown()) {
                    auto& iv2 = ps.getValue().integer();
                    std::string digits =
                        iv2.toString(LiteralBase::Decimal, false);
                    bool sgn2 = iv2.isSigned();
                    auto* c = s.MakeConstant();
                    c->VpiDecompile(digits);
                    c->VpiSize(32);
                    c->VpiValue((sgn2 ? "INT:" : "UINT:") + digits);
                    c->VpiConstType(sgn2 ? vpiIntConst : vpiUIntConst);
                    c->VpiParent(pa);
                    setLoc(c, init->sourceRange);
                    if (wantTs) {
                        auto* rt = s.MakeRef_typespec();
                        std::string tsPrefix = prefix;
                        if (tsPrefix.size() >= 2 &&
                            tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                            tsPrefix.resize(tsPrefix.size() - 2);
                        rt->VpiFullName(tsPrefix);
                        rt->VpiParent(c);
                        c->Typespec(rt);
                        rhsRt = rt;
                    }
                    rhs = c;
                }
                // A STRING-literal init on an (implicitly) INTEGRAL param
                // re-emits the string constant in the elab view, decompiled
                // WITHOUT quotes (const_func e1) — not the UINT fold.
                else if (stripImplicitConv(*init).kind ==
                             ExpressionKind::StringLiteral &&
                         !ps.getType().getCanonicalType().isString()) {
                    forceConstParent = true;
                    rhs = emitExpr(*init, pa, prefix, netMap);
                    forceConstParent = false;
                    if (rhs && rhs->UhdmType() == UHDM::uhdmconstant) {
                        auto* rc = (UHDM::constant*)rhs;
                        std::string_view v0 = rc->VpiValue();
                        if (v0.rfind("STRING:", 0) == 0)
                            rc->VpiDecompile(std::string(v0.substr(7)));
                    }
                }
                // A TYPED string param never folds (the elab Rhs re-emits the
                // string constant, decompiled without quotes). Pkg CONCAT
                // inits keep the operation in both views.
                else if (!ps.getType().getCanonicalType().isString() &&
                         !srlgElabUnreducibleCall(*init) &&
                         !(inPackage && [&] {
                             // A pkg param whose init is a concatenation — or
                             // an explicit size/type cast wrapping one, e.g.
                             // 3'({3'({3'h1})}) — keeps the operation in the
                             // elab view (Surelog leaves the cast/concat tree
                             // unfolded rather than reducing it to a constant).
                             const Expression* e = &stripImplicitConv(*init);
                             while (e->kind == ExpressionKind::Conversion &&
                                    !e->as<ConversionExpression>().isImplicit())
                                 e = &stripImplicitConv(
                                     e->as<ConversionExpression>().operand());
                             return e->kind == ExpressionKind::Concatenation;
                         }()) &&
                         // A materialized IMPORTED param's concat init keeps
                         // the operation in the elab view too (Surelog).
                         !(isImported && stripImplicitConv(*init).kind ==
                                             ExpressionKind::Concatenation) &&
                         // A NESTED assignment pattern ('{'{1,0,0,0}}) keeps
                         // its operation in the elab view (not folded).
                         !([&] {
                             auto& si = stripImplicitConv(*init);
                             if (si.kind != ExpressionKind::SimpleAssignmentPattern)
                                 return false;
                             for (auto* el : si.as<SimpleAssignmentPatternExpression>()
                                                 .elements())
                                 if (stripImplicitConv(*el).kind ==
                                     ExpressionKind::SimpleAssignmentPattern)
                                     return true;
                             return false;
                         }()) &&
                         // A MODULE struct-typed param never folds its RHS
                         // (patterns keep the op forms; casts keep the cast
                         // op). A PACKAGE struct param keeps only PATTERN ops
                         // (other pkg inits still fold — Surelog).
                         !([&] {
                             auto ck9 = ps.getType().getCanonicalType().kind;
                             if (ck9 != SymbolKind::PackedStructType &&
                                 ck9 != SymbolKind::PackedUnionType)
                                 return false;
                             if (!inPackage)
                                 return true;
                             auto k = stripImplicitConv(*init).kind;
                             return k == ExpressionKind::StructuredAssignmentPattern ||
                                    k == ExpressionKind::SimpleAssignmentPattern;
                         }()) &&
                         // An assignment pattern reduces to a constant ONLY
                         // against a packed-VECTOR target.  Surelog's
                         // expandPatternAssignment collapses '{...} for
                         // `logic [3:0] V = '{default:1}` (and for a typedef
                         // of one), but `int P = '{default:1}` keeps its
                         // vpiAssignmentPatternOp in EVERY view — the pattern
                         // never becomes a value.  Measured on a purpose-built
                         // 8-row golden that varied ONLY the target type
                         // (int / logic[3:0] / typedef-of-vector / packed
                         // struct / unpacked array): int and the aggregates
                         // keep the op, the two vectors fold.  The struct/
                         // union and nested-pattern clauses above already
                         // cover their rows; this one adds the integer-atom
                         // (and any other non-vector) target.
                         !([&] {
                             auto& si9 = stripImplicitConv(*init);
                             if (si9.kind !=
                                     ExpressionKind::SimpleAssignmentPattern &&
                                 si9.kind !=
                                     ExpressionKind::StructuredAssignmentPattern &&
                                 si9.kind !=
                                     ExpressionKind::ReplicatedAssignmentPattern)
                                 return false;
                             return ps.getType().getCanonicalType().kind !=
                                    SymbolKind::PackedArrayType;
                         }()) &&
                         // ...and the non-value PROPAGATES: `int R = P + 1`
                         // reading such a P keeps its vpiAddOp, with the
                         // pattern op substituted in as the operand (same
                         // golden).  Only the whole-parameter read propagates
                         // (patNoFoldTarget), never a struct MEMBER read.
                         !exprPatNoFold(*init) &&
                         // DEF view: a BARE reference to a parameter whose own
                         // def Rhs is an operation keeps the ref_obj. Surelog
                         // substitutes the referenced Rhs and then reduces; an
                         // operation Rhs makes the reduce fail, so the
                         // reference survives. Measured on a golden that read
                         // five package params (pattern / cast-of-concat /
                         // concat / plain int / module-local cast-concat) from
                         // module parameters: only the PLAIN-int read folded.
                         // The ELAB view folds all of them, hence !topView.
                         !(!topView && !inPackage && [&] {
                             auto& si8 = stripImplicitConv(*init);
                             const Symbol* sy8 = nullptr;
                             if (si8.kind == ExpressionKind::NamedValue)
                                 sy8 = &si8.as<NamedValueExpression>().symbol;
                             else if (si8.kind ==
                                      ExpressionKind::HierarchicalValue)
                                 sy8 = &si8.as<HierarchicalValueExpression>()
                                            .symbol;
                             return sy8 &&
                                    sy8->kind == SymbolKind::Parameter &&
                                    paramDefRhsIsOp(sy8->as<ParameterSymbol>());
                         }()) &&
                         // An init reading a struct-param MEMBER keeps the
                         // hier_path (Info.x) in BOTH views (Surelog).
                         !([&] {
                             auto& si = stripImplicitConv(*init);
                             if (si.kind != ExpressionKind::MemberAccess)
                                 return false;
                             auto& base = stripImplicitConv(
                                 si.as<MemberAccessExpression>().value());
                             return base.kind == ExpressionKind::NamedValue &&
                                    base.as<NamedValueExpression>().symbol.kind ==
                                        SymbolKind::Parameter &&
                                    base.as<NamedValueExpression>()
                                            .symbol.getType()
                                            .getCanonicalType()
                                            .kind == SymbolKind::PackedStructType;
                         }()) &&
                         !containsUserCall(*init) &&
                         (rhs = [&]() -> UHDM::any* {
                              // A PACKAGE-ORIGIN parameter whose init is an
                              // explicit TYPE cast (parameter int NumAgents =
                              // int'(NumAgentsIdx)) FOLDS in every view but
                              // the DEF package one: Surelog re-elaborates
                              // the package and its evaluator reduces the
                              // cast, while the unelaborated def view keeps
                              // the vpiCastOp tree. tryFoldConst refuses type
                              // casts by default (foldTypeCasts) because a
                              // top-module cont-assign re-emits them — that
                              // rule is about CA reduction, not package
                              // parameter elaboration.
                              bool savedFTC9 = foldTypeCasts;
                              if (pkgTypeCastFold9)
                                  foldTypeCasts = true;
                              auto* r9 = tryFoldConst(
                                  *init, typedParam ? init0 : nullptr,
                                  /*paramCtx*/ true);
                              foldTypeCasts = savedFTC9;
                              return r9;
                          }())) {
                    bool partSelectFold = false;
                    ((UHDM::constant*)rhs)->VpiParent(pa);
                    // A materialized IMPORTED param whose default folds from a
                    // NON-literal operation (cast/concat) yields a BARE folded
                    // constant in the module view: no loc, no typespec ref
                    // (Surelog). A simple-literal import (int W = 4) keeps
                    // them, but that init takes the IntegerLiteral branch
                    // above, not this fold path.
                    // ...but a plain param REFERENCE default (AsyncOn =
                    // other_pkg::AsyncOn) is not such an operation: its elab
                    // module fold keeps the reference span and the ts ref,
                    // exactly like the def-view copy (LogicArrayParam).
                    // ...and neither is a SYSTEM function call ($clog2(N)):
                    // the elab module copy of such an import keeps the CALL
                    // SPAN and the ts ref, matching its def-view copy
                    // (IntegerConcat pkg::InfoPageW).
                    bool importedFold =
                        isImported && topView && !inPackage &&
                        stripImplicitConv(*init).kind !=
                            ExpressionKind::NamedValue &&
                        !(stripImplicitConv(*init).kind ==
                              ExpressionKind::Call &&
                          stripImplicitConv(*init)
                              .as<CallExpression>()
                              .isSystemCall());
                    // Typed params fold at the type width; a size-cast value
                    // (32'(ONE)) at the cast width; other untyped values at 64.
                    auto& scv = stripImplicitConv(*init);
                    bool sizeCastVal =
                        scv.kind == ExpressionKind::Conversion &&
                        !scv.as<ConversionExpression>().isImplicit() && scv.type &&
                        scv.syntax &&
                        scv.syntax->kind == syntax::SyntaxKind::CastExpression &&
                        !isTypeSyntaxKind(
                            scv.syntax->as<syntax::CastExpressionSyntax>().left->kind);
                    // A DEF-view materialized UNTYPED integral import folds at
                    // the param's TYPE width (Surelog: 32 for a plain int
                    // import), matching its elab view — not the 64-bit default.
                    bool defUntypedImport =
                        !topView && !inPackage && isImported && !typedParam &&
                        ps.getType().getCanonicalType().isIntegral() &&
                        ps.getDeclaredType() &&
                        ps.getDeclaredType()->getTypeSyntax() &&
                        ps.getDeclaredType()->getTypeSyntax()->kind ==
                            syntax::SyntaxKind::ImplicitType;
                    // A RANGED-UNTYPED localparam ([HI:LO] A_CONST = A_VAL)
                    // whose default FOLDS in the elab view carries its value at
                    // the (per-instance) RANGE width, with a ts ref to a fresh
                    // int_typespec located at the range span — exactly like the
                    // OVERRIDDEN ranged case (A_VAL above). The DEF view keeps
                    // the unfolded ref_obj, so this only fires under topView.
                    bool rangedFold =
                        topView && !inPackage && isRangedUntypedParam(ps);
                    // An UNTYPED param whose default is a CONCAT
                    // ({(A) > (B) ? (A) : (B)}, the classic `max()` macro)
                    // folds at the concat's OWN self-determined width — not
                    // the 64-bit untyped default — and, unlike a concat fold
                    // in a cont-assign/statement (bare, no decompile), the
                    // param_assign Rhs form carries a based-binary decompile
                    // (Surelog).
                    // A REPLICATION default keeps its own width in EVERY
                    // declaration form (typed, ranged or bare) — see the
                    // measured table on tryFoldConst's concat branch — so it
                    // takes the concat encoding unconditionally.
                    bool concatFold = (!typedParam && !defUntypedImport &&
                                       !rangedFold && !sizeCastVal &&
                                       scv.kind == ExpressionKind::Concatenation) ||
                                      scv.kind == ExpressionKind::Replication;
                    // An ELAB-view fold whose source is a PARAMETER REFERENCE
                    // — bare (width_b = width_a), qualified (Y = pkg1::X) or
                    // SELECTED (a = x[0]) — is sized at the param's own TYPE
                    // width, not the 64-bit unsized-literal default. Surelog
                    // re-types its elaborated param constants (an untyped int
                    // param's elab Rhs constant is size 32 where its DEF one is
                    // 64), and a fold that READS one inherits that size.
                    // Literal-arithmetic folds keep 64 — only reads of an
                    // already-elaborated constant carry the narrower size.
                    bool elabRefFold9 =
                        topView && !typedParam && !defUntypedImport &&
                        !rangedFold && !sizeCastVal && !concatFold &&
                        ps.getType().getCanonicalType().isIntegral() && [&] {
                            const Expression* r9 = &scv;
                            for (;;) {
                                if (r9->kind == ExpressionKind::Conversion) {
                                    r9 = &stripImplicitConv(
                                        r9->as<ConversionExpression>()
                                            .operand());
                                    continue;
                                }
                                if (r9->kind == ExpressionKind::ElementSelect) {
                                    r9 = &stripImplicitConv(
                                        r9->as<ElementSelectExpression>()
                                            .value());
                                    continue;
                                }
                                if (r9->kind == ExpressionKind::RangeSelect) {
                                    r9 = &stripImplicitConv(
                                        r9->as<RangeSelectExpression>().value());
                                    continue;
                                }
                                break;
                            }
                            return r9->kind == ExpressionKind::NamedValue &&
                                   r9->as<NamedValueExpression>().symbol.kind ==
                                       SymbolKind::Parameter;
                        }();
                    // A COMPARISON/LOGICAL init keeps its self-determined
                    // 1-bit width and takes a BASED decompile, never the
                    // untyped 64-bit default. Measured, one source per row:
                    //   parameter D1     = (3 == 3) -> BIN:1 size 1 "1'b1"
                    //   parameter D2     = (3 >  4) -> BIN:0 size 1 "1'b0"
                    //   parameter bit D3 = (3 == 3) -> BIN:1 size 1 "1'b1"
                    // An `int` target instead re-signs the 1-bit result to
                    // INT:-1 size 32, so predefined integers are excluded.
                    bool boolInit9 =
                        scv.kind == ExpressionKind::BinaryOp &&
                        ps.getType().getCanonicalType().kind !=
                            SymbolKind::PredefinedIntegerType &&
                        [&] {
                            auto bop9 = scv.as<BinaryExpression>().op;
                            return OpInfo::isComparison(bop9) ||
                                   bop9 == BinaryOperator::LogicalAnd ||
                                   bop9 == BinaryOperator::LogicalOr ||
                                   bop9 == BinaryOperator::LogicalImplication ||
                                   bop9 == BinaryOperator::LogicalEquivalence;
                        }();
                    if (!concatFold && !boolInit9)
                        ((UHDM::constant*)rhs)
                            ->VpiSize(typedParam || defUntypedImport ||
                                              rangedFold || elabRefFold9 ||
                                              bitsFoldInit || castSizeFold
                                          ? (int32_t)ps.getType().getBitWidth()
                                      : sizeCastVal ? (int32_t)scv.type->getBitWidth()
                                                    : 64);
                    if (boolInit9) {
                        auto* cb9 = (UHDM::constant*)rhs;
                        std::string_view bv9 = cb9->VpiValue();
                        if (bv9.rfind("BIN:", 0) == 0)
                            cb9->VpiDecompile(std::to_string(cb9->VpiSize()) +
                                              "'b" + std::string(bv9.substr(4)));
                    }
                    if (concatFold) {
                        auto* cc9 = (UHDM::constant*)rhs;
                        std::string_view cv9 = cc9->VpiValue();
                        if (cv9.rfind("BIN:", 0) == 0 && !cc9->VpiDecompile().size())
                            cc9->VpiDecompile(std::to_string(cc9->VpiSize()) + "'b" +
                                              std::string(cv9.substr(4)));
                    }
                    // SUBSTITUTION FORM (r9psc, ParamSubstituteComplex):
                    // Surelog's reduce hands back a constant OBJECT rather than
                    // a fresh number, so a fold whose value came from
                    // substitution inherits that object's LITERAL FORM
                    // (VpiConstType + VpiValue + VpiDecompile).  Two sources:
                    //  * a CONDITIONAL operator — reduceExpr returns the
                    //    SELECTED branch verbatim, so `localparam IS_XLEN64 =
                    //    (XLEN == 32) ? 1'b0 : 1'b1` is BIN:1 / "1'b1" size 1,
                    //    NOT the untyped 64-bit UINT default (an untyped param
                    //    gets no adjustSize, so the literal's width stands too);
                    //  * a BARE parameter reference — substituteAssignedValue
                    //    returns the referenced param's own param_assign Rhs,
                    //    already emitted for this view (`localparam bit RVF =
                    //    IS_XLEN64` -> BIN:1 / "1'b1").  Only the FORM is
                    //    adopted; the width stays whatever this declaration's
                    //    own rule computed (elabRefFold9 et al).
                    if (topView && !concatFold && !boolInit9 && rhs &&
                        rhs->UhdmType() == UHDM::uhdmconstant) {
                        const UHDM::constant* sub9 = nullptr;
                        if (scv.kind == ExpressionKind::ConditionalOp) {
                            if (const Expression* lf9 =
                                    srlgLitFormSrc(comp, scv))
                                if (auto* le9 =
                                        emitExpr(*lf9, pa, prefix, netMap);
                                    le9 && le9->UhdmType() ==
                                               UHDM::uhdmconstant)
                                    sub9 = (const UHDM::constant*)le9;
                        }
                        else if (auto* bp9 = bareParamRef(scv)) {
                            if (auto bit9 = elabParamPa.find(bp9);
                                bit9 != elabParamPa.end() && bit9->second)
                                if (auto* br9 = bit9->second->Rhs();
                                    br9 &&
                                    br9->UhdmType() == UHDM::uhdmconstant)
                                    sub9 = (const UHDM::constant*)br9;
                        }
                        if (sub9 && !sub9->VpiDecompile().empty()) {
                            auto* rc9 = (UHDM::constant*)rhs;
                            if (!typedParam && rc9->VpiSize() == 64)
                                rc9->VpiSize(sub9->VpiSize());
                            rc9->VpiConstType(sub9->VpiConstType());
                            rc9->VpiValue(std::string(sub9->VpiValue()));
                            rc9->VpiDecompile(std::string(sub9->VpiDecompile()));
                        }
                    }
                    // ELAB-pkg computed BinaryOp init folds at the LEFT
                    // operand's span, sized 32, with a ts ref patched to the
                    // param's int ts (Surelog).
                    if (pkgElabComputed && !typedParam && wantTs) {
                        auto* rt = s.MakeRef_typespec();
                        std::string tsPrefix = prefix;
                        if (tsPrefix.size() >= 2 &&
                            tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                            tsPrefix.resize(tsPrefix.size() - 2);
                        rt->VpiFullName(tsPrefix);
                        rt->VpiParent((UHDM::constant*)rhs);
                        ((UHDM::constant*)rhs)->Typespec(rt);
                        rhsRt = rt;
                    }
                    // A PARENTHESIZED default (localparam W = (X-1)) folds to a
                    // constant spanning the parens, not the inner expression.
                    SourceRange rhsLoc = init->sourceRange;
                    if (!overridden)
                        if (auto* dsyn = paramDefaultSyn(ps))
                            if (dsyn->kind ==
                                syntax::SyntaxKind::ParenthesizedExpression)
                                rhsLoc = dsyn->sourceRange();
                    if (!importedFold)
                        setLoc((UHDM::constant*)rhs, rhsLoc);
                    // ELAB-pkg computed BinaryOp init folds at the LEFT
                    // operand's span, sized 32 (Surelog).
                    {
                        const Expression* se9 = &scv;
                        while (se9->kind == ExpressionKind::Conversion)
                            se9 = &se9->as<ConversionExpression>().operand();
                        if (pkgElabComputed &&
                            se9->kind == ExpressionKind::BinaryOp) {
                            setLoc((UHDM::constant*)rhs,
                                   se9->as<BinaryExpression>().left().sourceRange);
                            if (!typedParam)
                                ((UHDM::constant*)rhs)->VpiSize(32);
                        }
                        // A QUALIFIED pkg-param ref init folds at the
                        // QUALIFIER span (pkg:: incl. colons) — Surelog.
                        else if (pkgElabComputed &&
                                 se9->kind == ExpressionKind::NamedValue) {
                            std::string rq9(rawText(se9->sourceRange));
                            auto qp9 = rq9.rfind("::");
                            if (qp9 != std::string::npos) {
                                auto st9 = se9->sourceRange.start();
                                setLoc((UHDM::constant*)rhs,
                                       SourceRange(st9, st9 + qp9 + 2));
                            }
                        }
                    }
                    // A SUBTRACT or MULTIPLY init (W - 19, DReqDepth * 2) folds
                    // signed (INT). Measured per operator on one source, only
                    // the operator changed: `*` `/` `-` reduce to INT, `+` and
                    // `<<` to UINT — in every declaration form (untyped,
                    // `int`, `bit [7:0]`).
                    if (scv.kind == ExpressionKind::BinaryOp &&
                        (scv.as<BinaryExpression>().op == BinaryOperator::Subtract ||
                         scv.as<BinaryExpression>().op == BinaryOperator::Multiply)) {
                        auto* rc1 = (UHDM::constant*)rhs;
                        std::string_view v1 = rc1->VpiValue();
                        if (v1.rfind("UINT:", 0) == 0) {
                            rc1->VpiValue("INT:" + std::string(v1.substr(5)));
                            rc1->VpiConstType(vpiIntConst);
                        }
                    }
                    // An assignment-pattern default ('{0,1}) folds to a
                    // based-decimal (2'd1) constant with NO typespec ref.
                    auto& sinit = stripImplicitConv(*init);
                    bool isPattern =
                        sinit.kind == ExpressionKind::SimpleAssignmentPattern ||
                        sinit.kind == ExpressionKind::StructuredAssignmentPattern ||
                        sinit.kind == ExpressionKind::ReplicatedAssignmentPattern;
                    if (isPattern && typedParam) {
                        auto* c = (UHDM::constant*)rhs;
                        std::string v(c->VpiValue());
                        std::string digits =
                            v.find(':') != std::string::npos ? v.substr(v.find(':') + 1) : v;
                        c->VpiDecompile(std::to_string((int32_t)ps.getType().getBitWidth()) +
                                        "'d" + digits);
                        c->VpiConstType(0);
                    }
                    // A typed-param unbased-unsized default folds at the type
                    // width (Surelog quirk): '0 -> BIN:0/<width>'b0, '1 ->
                    // UINT:<all-ones>/decimal, 'x/'z -> BIN:X/Z.
                    if (sinit.kind ==
                            ExpressionKind::UnbasedUnsizedIntegerLiteral &&
                        typedParam) {
                        logic_t bit = sinit.as<UnbasedUnsizedIntegerLiteral>()
                                          .getLiteralValue();
                        auto* c = (UHDM::constant*)rhs;
                        int32_t w = (int32_t)ps.getType().getBitWidth();
                        // A PACKAGE param's degenerate fill keeps the RAW
                        // source decompile ('0), where a module param's is
                        // re-decompiled at the type width (<w>'b0). Measured
                        // on one source carrying the same struct- and
                        // vector-typed '0/'1 pair in a package and in a
                        // module: only the DEGENERATE fills differ; '1
                        // decompiles as the all-ones decimal in both
                        // (FuncStructValSimple cva6_cfg_empty).
                        if (bit.isUnknown()) {
                            std::string d = bit.value == logic_t::X_VALUE ? "X" : "Z";
                            c->VpiValue("BIN:" + d);
                            c->VpiConstType(vpiBinaryConst);
                            c->VpiDecompile(inPackage
                                                ? "'" + std::string(1, (char)std::tolower(d[0]))
                                                : std::to_string(w) + "'b" + d);
                        }
                        else if (bit.value == 0) {
                            c->VpiValue("BIN:0");
                            c->VpiConstType(vpiBinaryConst);
                            c->VpiDecompile(inPackage ? "'0"
                                                      : std::to_string(w) + "'b0");
                        }
                        else {
                            slang::SVInt ones((slang::bitwidth_t)w, 0, false);
                            ones = ~ones;
                            std::string digits = ones.toString(LiteralBase::Decimal, false);
                            c->VpiValue("UINT:" + digits);
                            c->VpiConstType(vpiUIntConst);
                            c->VpiDecompile(digits);
                        }
                        // The DEGENERATE fills ('0/'x/'z, ConstType BIN) are the
                        // SAME constant object Surelog shares into the reading
                        // cont-assign (bare stub, parent = that CA). '1 (UINT)
                        // instead gets a FRESH fold at the read, so it is not
                        // recorded here.
                        if (topView && (bit.isUnknown() || bit.value == 0))
                            unbasedSharedPaConst[&ps] = c;
                    }
                    // A BIT- or PART-SELECT init folds to BINARY at the
                    // SELECT's OWN width with a based decompile, in EVERY
                    // declaration form. Measured, one source per row, only the
                    // declaration changed (V8 = `bit [7:0] 8'h22`):
                    //   bit [3:0] W1 = V8[3:0]  -> BIN:0010     size 4
                    //   bit [7:0] W3 = V8[3:0]  -> BIN:0010     size 4
                    //   bit [3:0] U3 = V8[7:0]  -> BIN:00100010 size 8
                    //   bit       U4 = V8[1]    -> BIN:1        size 1
                    //   parameter U7 = V8[3:0]  -> BIN:0010     size 4
                    //   int       U8 = V8[3:0]  -> BIN:0010     size 4
                    // so the target TYPE width never enters. The one exception
                    // is the `int` re-signing quirk: an `int` param whose
                    // selected value has its top bit set adjusts to a 32-bit
                    // signed INT instead (`int P3 = V[0]` with V[0]==1 ->
                    // INT:-1 size 32), the same adjust a plain concat gets.
                    // ...but only over a PACKED base. Indexing an UNPACKED
                    // array param (ArrayParam[IndexParam], int ArrayParam[2])
                    // is an element READ, not a bit slice, and keeps the plain
                    // UINT encoding (ModuleInstantiationAndIndirectParams).
                    if ((sinit.kind == ExpressionKind::ElementSelect ||
                         sinit.kind == ExpressionKind::RangeSelect) &&
                        topView && [&] {
                            const Expression* b9 =
                                sinit.kind == ExpressionKind::ElementSelect
                                    ? &sinit.as<ElementSelectExpression>().value()
                                    : &sinit.as<RangeSelectExpression>().value();
                            return b9->type && b9->type->isIntegral();
                        }()) {
                        auto* c = (UHDM::constant*)rhs;
                        int32_t w = sinit.type ? (int32_t)sinit.type->getBitWidth()
                                               : c->VpiSize();
                        std::string v(c->VpiValue());
                        std::string digits = v.find(':') != std::string::npos
                                                 ? v.substr(v.find(':') + 1)
                                                 : v;
                        // ...and only for a SIGNED one: `int unsigned` has no
                        // sign bit to adjust, so its top-bit-set select keeps
                        // the plain BIN fold (LargeHex
                        // `parameter int unsigned ReqDepthOK = DReqDepth[0+:4]`
                        // -> BIN:1111 "4'b1111" size 4, not UINT:15 size 32).
                        bool signAdjust =
                            ps.getType().getCanonicalType().kind ==
                                SymbolKind::PredefinedIntegerType &&
                            ps.getType().isSigned();
                        if (w > 0 && !digits.empty() &&
                            digits.find_first_not_of("0123456789") ==
                                std::string::npos) {
                            slang::SVInt sv2 =
                                slang::SVInt::fromString(std::string_view(digits));
                            slang::SVInt wv =
                                sv2.resize((slang::bitwidth_t)w);
                            std::string bits;
                            for (int32_t bi = w - 1; bi >= 0; bi--)
                                bits += (wv[bi] == slang::logic_t(1)) ? '1' : '0';
                            if (!(signAdjust && bits[0] == '1')) {
                                c->VpiSize(w);
                                c->VpiValue("BIN:" + bits);
                                c->VpiConstType(vpiBinaryConst);
                                c->VpiDecompile(std::to_string(w) + "'b" + bits);
                                moduleParamFoldConst[&member] = c;
                                // The FRESH loc-less logic_typespec (folded
                                // bare-UINT bounds) belongs to the CONT-ASSIGN
                                // that SHARES this constant, not to the fold
                                // itself: measured on one source carrying two
                                // identical `bit [3:0] W = V8[3:0]` params of
                                // which a cont_assign reads only one — the read
                                // one's constant reparents to the cont_assign
                                // and takes the bare typespec, the unread one
                                // keeps the param's own bit_typespec.
                                bool sharedByCa9 = false;
                                for (auto& m9 : body.members()) {
                                    if (m9.kind != SymbolKind::ContinuousAssign)
                                        continue;
                                    m9.as<ContinuousAssignSymbol>()
                                        .getAssignment()
                                        .visit(makeVisitor(
                                            [&](auto& v9,
                                                const NamedValueExpression& nv9) {
                                                if (&nv9.symbol == &member)
                                                    sharedByCa9 = true;
                                                v9.visitDefault(nv9);
                                            }));
                                }
                                if (sharedByCa9 && typedParam) {
                                    auto* rt = s.MakeRef_typespec();
                                    rt->VpiFullName(prefix);
                                    rt->VpiParent(c);
                                    c->Typespec(rt);
                                    auto fr = ps.getType()
                                                  .getCanonicalType()
                                                  .getFixedRange();
                                    pendingPartSelFoldTs.push_back(
                                        {rt, fr.left, fr.right});
                                    partSelectFold = true;
                                }
                            }
                        }
                    }
                    // A REPLICATION fold never points at the parameter's own
                    // declared typespec: Surelog gives the folded constant a
                    // FRESH, LOC-LESS one built from the param's type — a
                    // packed vector becomes a logic_typespec whose range holds
                    // the FOLDED bounds as bare UINT constants (`bit [7:0]` ->
                    // logic_typespec[7:0], ElabCParam; `logic [NumAlerts-1:0]`
                    // -> logic_typespec[2:0], BitSelect), and an `int` becomes
                    // an UNSIGNED int_typespec (ParamMultiConcat; the param's
                    // own int_typespec carries vpiSigned, this one does not).
                    bool replFoldTs = false;
                    if (scv.kind == ExpressionKind::Replication &&
                        (typedParam || rangedFold) && wantTs && !isPattern &&
                        !partSelectFold && !importedFold) {
                        auto& rct = ps.getType().getCanonicalType();
                        UHDM::ref_typespec* rt = nullptr;
                        auto mkRef = [&]() {
                            rt = s.MakeRef_typespec();
                            std::string tsPfx = prefix;
                            if (tsPfx.size() >= 2 &&
                                tsPfx.compare(tsPfx.size() - 2, 2, "::") == 0)
                                tsPfx.resize(tsPfx.size() - 2);
                            rt->VpiFullName(tsPfx);
                            rt->VpiParent((UHDM::constant*)rhs);
                            ((UHDM::constant*)rhs)->Typespec(rt);
                        };
                        if (rct.kind == SymbolKind::PackedArrayType &&
                            rct.isIntegral()) {
                            mkRef();
                            auto fr = rct.getFixedRange();
                            pendingPartSelFoldTs.push_back({rt, fr.left, fr.right});
                            replFoldTs = true;
                        }
                        else if (rct.kind == SymbolKind::PredefinedIntegerType) {
                            mkRef();
                            rt->Actual_typespec(s.MakeInt_typespec());
                            replFoldTs = true;
                        }
                    }
                    // Typed-param (non-pattern) folds carry a ts ref to the
                    // param; a RANGED-UNTYPED elab fold carries the SAME ts ref
                    // shape (fullname = instance prefix, actual = range
                    // int_typespec) so its folded value is width-typed.
                    // ...except a MULTIDIM range (elabMultiDimNoTs9).
                    if ((typedParam || rangedFold || bitsFoldInit ||
                         castSizeFold) &&
                        wantTs &&
                        !isPattern && !partSelectFold && !replFoldTs &&
                        !importedFold && !elabMultiDimNoTs9) {
                        auto* rt = s.MakeRef_typespec();
                        std::string tsPrefix = prefix;
                        if (tsPrefix.size() >= 2 &&
                            tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                            tsPrefix.resize(tsPrefix.size() - 2);
                        rt->VpiFullName(tsPrefix);
                        rt->VpiParent((UHDM::constant*)rhs);
                        ((UHDM::constant*)rhs)->Typespec(rt);
                        rhsRt = rt;
                    }
                }
            }
            if (!rhs) {
                // A DEF-view NESTED pattern leaves leaf constants UNPARENTED
                // (only the nested pattern operations self-parent), so it does
                // NOT force the const parent.
                bool nestedPat = false;
                {
                    auto& si = stripImplicitConv(*init);
                    if (si.kind == ExpressionKind::SimpleAssignmentPattern)
                        for (auto* el : si.as<SimpleAssignmentPatternExpression>()
                                            .elements())
                            if (stripImplicitConv(*el).kind ==
                                ExpressionKind::SimpleAssignmentPattern)
                                nestedPat = true;
                }
                // Struct-typed param pattern RHS (Surelog 3-object model):
                // ELAB view: a FLAT op-75 (per-member folded constants) whose
                // ts ref (rhsRt) binds the elab param clone in
                // patchParamTypespecs. DEF view: emitExpr's tagged_pattern op
                // plus a ts ref to a FRESH def clone (deferred to
                // drainDefParamTs, scoped work@<mod>.<ty>.<member>).
                bool structPat = false;
                // NOTE (r9psc, ParamSubstituteComplex — RESIDUE, still
                // CMP_NOTEQUAL both modes).  All six substitution rules
                // r9papiap decoded are now landed (rules 1-4 at the flatten
                // site below and in ExprEmit's tagged_pattern arm, rule 5 here,
                // rule 6 on the MemberAccess fold near the top of this
                // function), plus two the test needed on top of them: every
                // flattened operand is re-sized to the member width, and a fold
                // that came out of SUBSTITUTION keeps the substituted
                // constant's literal form.  The REACHABLE design dump is now
                // BYTE-IDENTICAL to the golden in BOTH modes (uhdm-dump, lines
                // 2..weaklyReferenced, 0 diff).
                //
                // What still blocks it is NOT a value: it is typespec IDENTITY
                // in the ELAB view, which uhdm-cmp reaches only through
                // typespec::Compare's Instance() recursion (uhdm-dump
                // abbreviates an already-visited object, which is exactly why
                // the dumps agree).  Bisected with a per-vector comparer
                // (compare each Parameters[i]/Param_assigns[i] pair under its
                // OWN CompareContext — the shared m_visited memo is keyed on
                // the LHS pointer, so a whole-design compare is direction-
                // asymmetric and reports only the container):
                //   TOP0.Param_assigns[0]/[9]/[10]  lhs=null rhs=module_inst
                //   TOP0.Param_assigns[11]          lhs=ref_typespec rhs=null
                // i.e. inside the op75's struct_typespec clone, our member
                // logic_typespec's Typedef_alias resolves to the module's
                // SHARED `fmt_logic_t` typedef (which carries vpiInstance),
                // where Surelog's clone chain resolves to an instance-free
                // per-reference copy that itself carries a further alias ref
                // (`work@top.fmt_logic_t`).  Closing it means modelling
                // Surelog's typedef alias-CLONE chain for a vector typedef used
                // as a struct member — cross-cutting (buildStructTs's
                // direct-vector-typedef member arm + patchParamTypespecs'
                // opClone), not a ParamSubstituteComplex-local fix, and it is
                // ranked as its own cluster rather than forced here.
                // RULE 5 (r9psc, ParamSubstituteComplex): `parameter S2 = S1`
                // where S1 is a struct-pattern parameter of the SAME struct
                // type substitutes S1's whole pattern in the ELAB view — the
                // flatten then runs over the SUBSTITUTED pattern, anchored at
                // S1's own span, so S2's Rhs is a second flat op75 identical
                // to S1's (`parameter fpu_features_t Features = FPU_FEATURES`).
                // patSubstElab does the same job for patNoFoldTarget types,
                // which deliberately EXCLUDE packed structs (1236970: a
                // whole-struct read reduces even off a pattern Rhs), so the
                // substitution has to happen here, on the flatten side.
                const Expression* structRefPat9 = nullptr;
                if (topView && !inPackage && !structOvPat &&
                    ps.getType().getCanonicalType().kind ==
                        SymbolKind::PackedStructType)
                    if (auto* rp9 = bareParamRef(*init))
                        if (auto* ri9 = rp9->getInitializer()) {
                            auto& rs9 = stripImplicitConv(*ri9);
                            if ((rs9.kind ==
                                     ExpressionKind::StructuredAssignmentPattern ||
                                 rs9.kind ==
                                     ExpressionKind::SimpleAssignmentPattern) &&
                                rp9->getType().getCanonicalType().kind ==
                                    SymbolKind::PackedStructType &&
                                &rp9->getType().getCanonicalType() ==
                                    &ps.getType().getCanonicalType())
                                structRefPat9 = &rs9;
                        }
                // WIDTH RULE: a PACKAGE struct-pattern param whose struct bit
                // width EXCEEDS 64 keeps the tagged_pattern tree in the ELAB
                // view too (Surelog's package def and elab views are byte-
                // identical: kmac_pkg::A 96b ImportedDoubleCastedParameter,
                // pinmux_pkg::DefaultTargetCfg ~72b BSOPPS). A <=64b package
                // struct param still flat-folds to the packed op75 constant
                // (PatternAssignmentOfStructParam 4b,
                // StructParameterInitializedWithPatternAndReferenced 4b). Our
                // wide fold otherwise mints a BOGUS UINT:0 constant (int64
                // overflow of a >64b decimal) — the gate removes it.
                bool structWidePkg = false;
                // ...and the SCOPED-REFERENCE case of the same "tagged tree
                // survives the elab view" behaviour, which (unlike the width
                // and symbolic-dim rules) still REDUCES each member value.
                bool structNoScopedRefPkg = false;
                {
                    auto& pctS = ps.getType().getCanonicalType();
                    auto k0 = structOvPat  ? structOvPat->kind
                              : structRefPat9
                                  ? structRefPat9->kind
                                  : stripImplicitConv(*init).kind;
                    structPat = (pctS.kind == SymbolKind::PackedStructType ||
                                 (unpStructOvRef9 &&
                                  pctS.kind == SymbolKind::UnpackedStructType)) &&
                                (k0 == ExpressionKind::StructuredAssignmentPattern ||
                                 k0 == ExpressionKind::SimpleAssignmentPattern);
                    // The rule follows the PACKAGE ORIGIN of the struct param:
                    // it applies in its home package (inPackage) AND when the
                    // param is MATERIALIZED into an importing module/package
                    // (isImported) — kmac_pkg::A viewed in work@top keeps the
                    // tagged tree too. A module-LOCAL struct param still flat-
                    // folds.
                    if (structPat && (inPackage || isImported) &&
                        ps.getType().getBitWidth() > 64)
                        structWidePkg = true;
                    // SYMBOLIC-DIM RULE: a struct whose member carries a
                    // PARAMETER-DEPENDENT packed dimension
                    // (pad_type_e [NDioPads-1:0] m) never flattens in either
                    // HOME-PACKAGE view — Surelog leaves that pattern op
                    // untyped (no struct ts ref) and therefore never runs its
                    // flatten pass on it, so the elaborated package view is
                    // byte-identical to the def view (BSOPPS*, TSPWRIS). A
                    // fixed-dim member struct (logic [3:0] addr) still folds
                    // flat in the elab package view. The importing MODULE
                    // views are unaffected — they flatten either way.
                    if (structPat && inPackage &&
                        structHasSymbolicMemberDim(pctS))
                        structWidePkg = true;
                    // SCOPED-REFERENCE RULE: the flatten pass runs off the
                    // package-scope RESOLUTION of the parameter. `pkg::NAME`
                    // somewhere in the sources reduces the package's own
                    // elaborated param_assign in place; a wildcard-imported
                    // unqualified read (PAssignType/ParamNoSubst) or no read at
                    // all (ValueSize) never reaches that path, so the elab
                    // package view keeps the tagged_pattern tree — with each
                    // member VALUE still folded (see the topView fold below).
                    // Measured on one source varying only the reference form.
                    if (structPat && inPackage && !structWidePkg &&
                        ps.getParentScope() &&
                        !hasScopedPkgRef(ps.getParentScope()->asSymbol().name,
                                         ps.name)) {
                        structWidePkg = true;
                        structNoScopedRefPkg = true;
                    }
                }
                // The DEF view of an INTERFACE struct param keeps the TAGGED
                // form (emitExpr tagged_pattern op: constant size 64 + a ts ref
                // to the member's string_typespec) — same as a module localparam
                // pattern default; it does NOT fold to the flat op75. Only the
                // ELAB (topView) view flattens. (Previously this DEF case took
                // the flat op75 branch below, emitting a bare member constant +
                // an op-level struct ts ref — which mismatched Surelog. Falling
                // through to emitExpr with paramInitDef restores the tags.)
                // NOTE follow-on (iface_cfg_param_def_pass, still DIFF): the ELAB
                // override RHS (work@top.bus.CFG) should re-emit as an op75 at
                // the override-connection site (constant at the value source),
                // the reader's `32'(s.CFG.DAT)` must stay a hier_path cast op
                // (Surelog does NOT fold interface-port struct-param reads), and
                // the modport port-view needs its own override param_assign.
                // ...EXCEPT when the interface is instantiated as an ARRAY
                // (bus_if #(C) arr[1:0] ()). Surelog's array-instance path
                // re-reduces the DEFINITION's parameter defaults, so the def
                // view flat-folds too — with a BARE op ts ref (no parent, no
                // fullname) instead of the elab clone's scoped one.
                // (iface_array_elem_cfg_param.)
                bool ifaceArrayDefFold = false;
                if (structPat && !topView && !structWidePkg) {
                    const InstanceBodySymbol* ob0 = nullptr;
                    for (auto* sc0 = ps.getParentScope(); sc0;) {
                        auto& ss0 = sc0->asSymbol();
                        if (ss0.kind == SymbolKind::InstanceBody) {
                            ob0 = &ss0.as<InstanceBodySymbol>();
                            break;
                        }
                        sc0 = ss0.getParentScope();
                    }
                    if (ob0 && ob0->getDefinition().definitionKind ==
                                   DefinitionKind::Interface &&
                        defInstantiatedAsArray(ob0->getDefinition()))
                        ifaceArrayDefFold = true;
                }
                if (structPat && (topView || ifaceArrayDefFold) &&
                    !structWidePkg) {
                    auto& pctS = ps.getType().getCanonicalType();
                    // An OVERRIDE by a param REFERENCE substitutes the
                    // REFERENCED param's pattern, anchored at the override site.
                    auto& sinitK = structOvPat    ? *structOvPat
                                   : structRefPat9 ? *structRefPat9
                                                   : stripImplicitConv(*init);
                    auto* op2 = s.MakeOperation();
                    op2->VpiOpType(75);
                    op2->VpiParent(pa);
                    setLoc(op2, structOvPat      ? structOvLoc
                                : structRefPat9 ? structRefPat9->sourceRange
                                                : init->sourceRange);
                    // --disable-feature=parametersubstitution: an IMPORTED
                    // aggregate param's elab Rhs is Surelog's clone of the
                    // PACKAGE assign, which carries no typespec; the
                    // module-scoped one is minted by expandPatternAssignment,
                    // and that is precisely the call the flag gates off
                    // (ParamNoSubst CTRL_RESET).  A module-LOCAL aggregate
                    // param is compiled in the module and keeps its typespec
                    // either way (ParamComplexVerilator init_val, measured
                    // byte-identical across the flag pair).
                    // A MATERIALIZED IMPORT copy whose pattern has a NESTED
                    // struct member carries NO outer typespec either: Surelog's
                    // flatten tags the member ops it mints (each with a BARE ts
                    // ref) and leaves the copy's own head untagged. A FLAT
                    // pattern (scalar members only) still gets the outer ts
                    // (ParamNoSubst aes_pkg::CTRL_RESET vs
                    // GenIfIfaceParamStructField / GenForIfaceLocalparamNestedGen
                    // p::CFG_DEF, whose cfg_t nests hsk_t/bus_t).
                    bool impNestedPat9 = false;
                    if (isImported && !inPackage && topView && !structOvPat &&
                        sinitK.kind ==
                            ExpressionKind::StructuredAssignmentPattern)
                        for (auto& ms9 :
                             sinitK.as<StructuredAssignmentPatternExpression>()
                                 .memberSetters) {
                            auto& sk9 = stripImplicitConv(*ms9.expr);
                            if (sk9.kind ==
                                    ExpressionKind::StructuredAssignmentPattern ||
                                sk9.kind ==
                                    ExpressionKind::SimpleAssignmentPattern) {
                                impNestedPat9 = true;
                                break;
                            }
                        }
                    if (!(noParamSubst && isImported && paramSubstRefused(ps)) &&
                        !impNestedPat9) {
                        auto* rt = s.MakeRef_typespec();
                        if (!ifaceArrayDefFold)
                            rt->VpiParent(op2);
                        op2->Typespec(rt);
                        rhsRt = rt; // -> elab param clone (patchParamTypespecs)
                    }
                    auto* opnds = s.MakeAnyVec();
                    ASTContext ectx(comp.getRoot(), LookupLocation::max);
                    // The UNPACKED sibling (unpStructOvRef9) reaches the exact
                    // same shape; only the field-list scope differs.
                    const Scope& fsc9 =
                        pctS.kind == SymbolKind::PackedStructType
                            ? (const Scope&)pctS.as<PackedStructType>()
                            : (const Scope&)pctS.as<UnpackedStructType>();
                    // expandPatternAssignment's untagged arm walks the operands
                    // in member order calling adjustOpSize, and RETURNS as soon
                    // as one does not reduce to a value — a member whose value
                    // is itself an assignment PATTERN is exactly that.  So the
                    // members AFTER the first pattern-valued one are never
                    // resized and keep their own source width (the nested
                    // member itself still gets sized: adjustOpSize runs before
                    // the invalidValue check).  -1 = the walk completes.
                    int nestBailK = -1;
                    if (sinitK.kind ==
                        ExpressionKind::StructuredAssignmentPattern) {
                        auto& apK =
                            sinitK.as<StructuredAssignmentPatternExpression>();
                        int fiK = 0;
                        for (auto& fld0 : fsc9.membersOfType<FieldSymbol>()) {
                            const Expression* se0 = nullptr;
                            for (auto& ms0 : apK.memberSetters)
                                if (ms0.member == &fld0) {
                                    se0 = ms0.expr;
                                    break;
                                }
                            if (!se0)
                                se0 = apK.defaultSetter;
                            if (se0) {
                                auto& sv0 = stripImplicitConv(*se0);
                                if (sv0.kind ==
                                        ExpressionKind::
                                            StructuredAssignmentPattern ||
                                    sv0.kind ==
                                        ExpressionKind::
                                            SimpleAssignmentPattern) {
                                    nestBailK = fiK;
                                    break;
                                }
                            }
                            fiK++;
                        }
                    }
                    int fiK9 = -1;
                    for (auto& fld : fsc9.membersOfType<FieldSymbol>()) {
                        fiK9++;
                        const Expression* se = nullptr;
                        if (sinitK.kind ==
                            ExpressionKind::StructuredAssignmentPattern) {
                            auto& ap =
                                sinitK.as<StructuredAssignmentPatternExpression>();
                            for (auto& ms : ap.memberSetters)
                                if (ms.member == &fld) {
                                    se = ms.expr;
                                    break;
                                }
                            if (!se)
                                se = ap.defaultSetter;
                        }
                        if (!se)
                            continue;
                        // A NESTED struct-pattern member is KEPT as a nested
                        // op75 in the ELAB view — Surelog does NOT fold the
                        // inner pattern. Recurse via the reemitting path, which
                        // builds the op with a BARE ts ref to the member's
                        // typedef struct typespec and leaf constants at their
                        // source encoding (based literals keep width; an
                        // unbased int leaf keeps its 64-bit default size).
                        {
                            auto& seN = stripImplicitConv(*se);
                            const Type& fct = fld.getType().getCanonicalType();
                            // A VECTOR member with its own DEFAULT pattern
                            // ('{default: '1} on a logic [1:0]) is kept the
                            // same way, sized at the member width — the
                            // tagged_pattern survives the fold
                            // (TaggedPatternLogic).
                            bool vecPat9 =
                                fct.kind != SymbolKind::PackedStructType &&
                                fct.isIntegral() &&
                                seN.kind == ExpressionKind::
                                                StructuredAssignmentPattern &&
                                seN.as<StructuredAssignmentPatternExpression>()
                                    .memberSetters.empty() &&
                                seN.as<StructuredAssignmentPatternExpression>()
                                        .defaultSetter != nullptr;
                            if ((seN.kind ==
                                     ExpressionKind::StructuredAssignmentPattern ||
                                 seN.kind ==
                                     ExpressionKind::SimpleAssignmentPattern) &&
                                (fct.kind == SymbolKind::PackedStructType ||
                                 (unpStructOvRef9 &&
                                  fct.kind == SymbolKind::UnpackedStructType) ||
                                 vecPat9)) {
                                bool savedRe = reemitting;
                                // A VECTOR member's default pattern KEEPS its
                                // tagged_pattern — reemitting would strip it
                                // down to the bare value.
                                reemitting = !vecPat9;
                                bool savedPES = pkgEnumSubstPat;
                                pkgEnumSubstPat = inPackage || isImported;
                                // The member value sits INSIDE a pattern (op2
                                // was built by hand, so emitExpr cannot see
                                // it): a nested pattern keeps every element at
                                // its source width instead of sizing its first
                                // operand to the element type — Surelog never
                                // recurses adjustOpSize into a member op.
                                bool savedPatK = inAssignPattern;
                                inAssignPattern = true;
                                auto* ne = emitExpr(seN, op2, prefix, netMap);
                                inAssignPattern = savedPatK;
                                pkgEnumSubstPat = savedPES;
                                reemitting = savedRe;
                                if (ne) {
                                    ((UHDM::any*)ne)->VpiParent(op2);
                                    // An OVERRIDE-SUBSTITUTED pattern's nested
                                    // member op is SIZED at the member width
                                    // and its struct ts ref carries the
                                    // instance-scoped fullname (Surelog,
                                    // iface_wholestruct_param). A plain DEFAULT
                                    // fold leaves both bare (iface_cfg_mem).
                                    if (vecPat9 &&
                                        ne->UhdmType() == UHDM::uhdmoperation)
                                        ((UHDM::operation*)ne)
                                            ->VpiSize((int32_t)fld.getType()
                                                          .getBitWidth());
                                    if (structOvPat && !vecPat9 &&
                                        ne->UhdmType() == UHDM::uhdmoperation) {
                                        auto* nop = (UHDM::operation*)ne;
                                        // An UNPACKED member type has no
                                        // getBitWidth(); Surelog still sizes
                                        // the member op at the struct's
                                        // bit-stream width (32 for a lone
                                        // `int unsigned`).
                                        uint64_t mw9 =
                                            fld.getType().getBitWidth();
                                        if (mw9 == 0)
                                            mw9 = fld.getType()
                                                      .getBitstreamWidth();
                                        nop->VpiSize((int32_t)mw9);
                                        if (auto* nrt = nop->Typespec()) {
                                            std::string tsP = prefix;
                                            if (tsP.size() >= 2 &&
                                                tsP.compare(tsP.size() - 2, 2,
                                                            "::") == 0)
                                                tsP.resize(tsP.size() - 2);
                                            nrt->VpiFullName(tsP);
                                            nrt->VpiParent(nop);
                                        }
                                    }
                                    opnds->push_back(ne);
                                }
                                continue;
                            }
                        }
                        // A LITERAL setter keeps its source encoding (1'b1 ->
                        // BIN, parented at the op via emitExpr); non-literal
                        // setters fold to UINT at the member width.
                        if (stripImplicitConv(*se).kind ==
                                ExpressionKind::IntegerLiteral) {
                            if (auto* e2 = emitExpr(*se, op2, prefix, netMap)) {
                                ((UHDM::expr*)e2)->VpiParent(op2);
                                // EVERY flattened operand is re-sized to the
                                // MEMBER width — Surelog's
                                // expandPatternAssignment calls adjustOpSize on
                                // each one, which OVERWRITES the size (the
                                // model decoded in 1b0be9d for the >64b bail).
                                // The literal's own ENCODING is untouched, so a
                                // narrower based literal keeps its decompile and
                                // bit string while widening: `IntFmtMask: 4'b1111`
                                // into a 5-bit member is BIN:1111 / "4'b1111" at
                                // size 5 (ParamSubstituteComplex RV64D_Xsflt).
                                // ...unless the walk already bailed on an
                                // earlier pattern-valued member — operands PAST
                                // the bail index keep their own width, the
                                // bailing operand itself IS resized because
                                // adjustOpSize runs before the invalidValue
                                // check (GenForStructParamBound).
                                if (e2->UhdmType() == UHDM::uhdmconstant &&
                                    (nestBailK < 0 || fiK9 <= nestBailK))
                                    ((UHDM::constant*)e2)
                                        ->VpiSize((int32_t)fld.getType()
                                                      .getBitWidth());
                                opnds->push_back(e2);
                            }
                            continue;
                        }
                        // An ENUM-MEMBER setter of a PACKAGE-ORIGIN struct
                        // param keeps the enum member's OWN literal form in
                        // the flattened elab view too (enumMemberSubstConst),
                        // not the UINT-at-member-width fold below.  A
                        // MODULE-LOCAL struct param is left alone here — its
                        // enum members already follow the BIN rule
                        // (enumFold6).
                        if (inPackage || isImported) {
                            auto& sev8 = stripImplicitConv(*se);
                            if (sev8.kind == ExpressionKind::NamedValue) {
                                if (auto* ec8 = enumMemberSubstConst(
                                        sev8.as<NamedValueExpression>()
                                            .symbol)) {
                                    ec8->VpiParent(op2);
                                    setLoc(ec8, se->sourceRange);
                                    opnds->push_back(ec8);
                                    continue;
                                }
                            }
                        }
                        // RULE 4 (r9psc, ParamSubstituteComplex): a CONCAT
                        // setter that contains an OPERATION element does NOT
                        // fold.  Surelog's reduce of the concat fails on the
                        // operation, so the vpiConcatOp SURVIVES the flatten
                        // (sized at the member width by adjustOpSize) with each
                        // element reduced on its own: an operation element
                        // becomes a UINT at the unsized 64, a bare parameter
                        // reference its literal form (rule 2), a literal is
                        // kept.  Measured on the single-axis probe and on
                        // `IntFmtMask: {XFVEC && XF8, XFVEC && (XF16 ||
                        // XF16ALT), 1'b1, 1'b1}`.
                        {
                            auto& cc9 = stripImplicitConv(*se);
                            bool opElem9 = false;
                            if (cc9.kind == ExpressionKind::Concatenation)
                                for (auto* el9 :
                                     cc9.as<ConcatenationExpression>()
                                         .operands()) {
                                    auto k9 = stripImplicitConv(*el9).kind;
                                    if (k9 == ExpressionKind::BinaryOp ||
                                        k9 == ExpressionKind::UnaryOp ||
                                        k9 == ExpressionKind::ConditionalOp) {
                                        opElem9 = true;
                                        break;
                                    }
                                }
                            if (opElem9) {
                                auto* cop9 = s.MakeOperation();
                                cop9->VpiOpType(33);
                                cop9->VpiParent(op2);
                                setLoc(cop9, se->sourceRange);
                                cop9->VpiSize(
                                    (int32_t)fld.getType().getBitWidth());
                                auto* cel9 = s.MakeAnyVec();
                                for (auto* el9 :
                                     cc9.as<ConcatenationExpression>()
                                         .operands()) {
                                    auto& sel9 = stripImplicitConv(*el9);
                                    if (sel9.kind ==
                                        ExpressionKind::IntegerLiteral) {
                                        if (auto* le9 = emitExpr(*el9, cop9,
                                                                 prefix,
                                                                 netMap)) {
                                            ((UHDM::expr*)le9)->VpiParent(cop9);
                                            cel9->push_back(le9);
                                        }
                                        continue;
                                    }
                                    ConstantValue ev9 = ectx.tryEval(*el9);
                                    if (!ev9 || !ev9.isInteger() ||
                                        ev9.integer().hasUnknown())
                                        continue;
                                    slang::SVInt uv9 = ev9.integer();
                                    uv9.setSigned(false);
                                    auto* ec9 = s.MakeConstant();
                                    ec9->VpiParent(cop9);
                                    // Surelog's reduce anchors an operation's
                                    // folded value at its LEFTMOST leaf.
                                    const Expression* lm9 = &sel9;
                                    for (int g9 = 0; g9 < 8; g9++) {
                                        if (lm9->kind == ExpressionKind::BinaryOp)
                                            lm9 = &stripImplicitConv(
                                                lm9->as<BinaryExpression>()
                                                    .left());
                                        else if (lm9->kind ==
                                                 ExpressionKind::UnaryOp)
                                            lm9 = &stripImplicitConv(
                                                lm9->as<UnaryExpression>()
                                                    .operand());
                                        else
                                            break;
                                    }
                                    setLoc(ec9, lm9->sourceRange);
                                    // A bare parameter reference keeps the
                                    // referenced param's literal form at ITS
                                    // OWN width; anything else is the plain
                                    // unsized-64 UINT reduce.
                                    const Expression* lf9 =
                                        bareParamRef(*el9)
                                            ? srlgLitFormSrc(comp, *el9)
                                            : nullptr;
                                    if (lf9) {
                                        if (auto* pe9 = emitExpr(*lf9, cop9,
                                                                 prefix,
                                                                 netMap);
                                            pe9 && pe9->UhdmType() ==
                                                       UHDM::uhdmconstant) {
                                            auto* pc9 = (UHDM::constant*)pe9;
                                            pc9->VpiParent(cop9);
                                            setLoc(pc9, el9->sourceRange);
                                            pc9->VpiSize(
                                                (int32_t)el9->type
                                                    ->getBitWidth());
                                            cel9->push_back(pc9);
                                            continue;
                                        }
                                    }
                                    std::string dg9 = uv9.toString(
                                        LiteralBase::Decimal, false);
                                    ec9->VpiDecompile(dg9);
                                    ec9->VpiSize(64);
                                    ec9->VpiValue("UINT:" + dg9);
                                    ec9->VpiConstType(vpiUIntConst);
                                    cel9->push_back(ec9);
                                }
                                cop9->Operands(cel9);
                                opnds->push_back(cop9);
                                continue;
                            }
                        }
                        ConstantValue cvm = ectx.tryEval(*se);
                        if (cvm && cvm.isInteger() && !cvm.integer().hasUnknown()) {
                            auto* c2 = s.MakeConstant();
                            slang::SVInt uvm = cvm.integer();
                            uvm.setSigned(false);
                            // A REPLICATION setter ({NDioPads{B}}) folds to the
                            // repeated bit pattern in the elab view too — the
                            // SAME BIN constant the def view builds (decompile
                            // = the bits), plus an INSTANCE-scoped ts ref to a
                            // bare int_typespec (Surelog, BSOPPS*InGenFor).
                            if (stripImplicitConv(*se).kind ==
                                ExpressionKind::Replication) {
                                int32_t w7 =
                                    (int32_t)fld.getType().getBitWidth();
                                std::string bits7;
                                for (int32_t i7 = w7 - 1; i7 >= 0; i7--)
                                    bits7 += (uvm[i7] == slang::logic_t(1))
                                                 ? '1'
                                                 : '0';
                                c2->VpiDecompile(bits7);
                                c2->VpiSize(w7);
                                c2->VpiValue("BIN:" + bits7);
                                c2->VpiConstType(vpiBinaryConst);
                                std::string tsP7 = prefix;
                                if (tsP7.size() >= 2 &&
                                    tsP7.compare(tsP7.size() - 2, 2, "::") == 0)
                                    tsP7.resize(tsP7.size() - 2);
                                auto* rrt7 = s.MakeRef_typespec();
                                rrt7->VpiParent(c2);
                                rrt7->VpiFullName(tsP7);
                                rrt7->Actual_typespec(s.MakeInt_typespec());
                                c2->Typespec(rrt7);
                            }
                            // A CONCAT setter re-encodes BINARY at the member
                            // width with a BARE ts ref (Surelog).
                            else if (stripImplicitConv(*se).kind ==
                                     ExpressionKind::Concatenation) {
                                int32_t w8 =
                                    (int32_t)fld.getType().getBitWidth();
                                std::string bits8;
                                for (int32_t i8 = w8 - 1; i8 >= 0; i8--)
                                    bits8 += (uvm[i8] == slang::logic_t(1))
                                                 ? '1'
                                                 : '0';
                                c2->VpiSize(w8);
                                c2->VpiValue("BIN:" + bits8);
                                c2->VpiConstType(vpiBinaryConst);
                                // RULE 3 (r9psc): a concat whose elements are
                                // ALL bare parameter references carries a ts
                                // ref to the MEMBER's own typespec — Surelog's
                                // substitution replaces every element with a
                                // typed constant, so the reduced concat keeps
                                // the member type.  A concat MIXING references
                                // and literals reduces to the same value with
                                // NO typespec at all.
                                bool allRefs8 = true;
                                for (auto* el8 :
                                     stripImplicitConv(*se)
                                         .as<ConcatenationExpression>()
                                         .operands())
                                    if (!bareParamRef(*el8)) {
                                        allRefs8 = false;
                                        break;
                                    }
                                if (allRefs8) {
                                    std::string tsP8 = prefix;
                                    if (tsP8.size() >= 2 &&
                                        tsP8.compare(tsP8.size() - 2, 2,
                                                     "::") == 0)
                                        tsP8.resize(tsP8.size() - 2);
                                    // The member's OWN typespec, built the way
                                    // buildStructTs builds it (from the
                                    // StructUnionMember type syntax, which is
                                    // what makes it a fresh alias clone rather
                                    // than the module's shared typedef object —
                                    // the shared one carries an Instance the
                                    // golden's member clone does not).
                                    const syntax::SyntaxNode* mts8 = nullptr;
                                    for (auto p8 = fld.getSyntax(); p8;
                                         p8 = p8->parent)
                                        if (p8->kind == syntax::SyntaxKind::
                                                            StructUnionMember) {
                                            mts8 = p8->as<
                                                       syntax::
                                                           StructUnionMemberSyntax>()
                                                       .type;
                                            break;
                                        }
                                    auto* rrt8 = s.MakeRef_typespec();
                                    rrt8->VpiParent(c2);
                                    rrt8->VpiFullName(tsP8);
                                    auto* mtsp8 = makeTypespec(fld, mts8);
                                    // makeTypespec hands back the MODULE's
                                    // shared typedef object for an aliased
                                    // member type, and that one carries a
                                    // vpiInstance the golden's per-reference
                                    // copy does not — Surelog clones the
                                    // typespec at every reference.  Copy the
                                    // compared fields (name/vector/signed/
                                    // ranges/alias) and drop the instance; a
                                    // DeepClone would recurse forever through
                                    // the self-referential Typedef_alias.
                                    if (auto* cl8 = mtsp8 && mtsp8->Instance()
                                                        ? copyNamedVecTs(mtsp8,
                                                                         rrt8)
                                                        : nullptr) {
                                        cl8->Typedef_alias(
                                            mtsp8->Typedef_alias());
                                        // ...and the copy is one LINK of an
                                        // alias CHAIN, not a detached twin.
                                        // Surelog copies the member's alias
                                        // clone AND its alias target, so the
                                        // slot's typespec carries a
                                        // Typedef_alias to a SECOND
                                        // instance-free copy
                                        // (`work@top.fmt_logic_t`), not to the
                                        // shared object.  Missing it compares
                                        // `failLhs=ref_typespec failRhs=null`
                                        // through the reading param's Rhs
                                        // constant (r9tdclone;
                                        // ParamSubstituteComplex's
                                        // `FpFmtMask: {RVF, RVD, ...}`).
                                        if (!cl8->Typedef_alias() &&
                                            !cl8->VpiName().empty()) {
                                            auto* ar8 = s.MakeRef_typespec();
                                            ar8->VpiFullName(
                                                tsP8 + "." +
                                                std::string(mtsp8->VpiName()));
                                            ar8->VpiParent(cl8);
                                            ar8->Actual_typespec(
                                                copyNamedVecTs(mtsp8, ar8));
                                            cl8->Typedef_alias(ar8);
                                        }
                                        mtsp8 = cl8;
                                    }
                                    rrt8->Actual_typespec(mtsp8);
                                    c2->Typespec(rrt8);
                                }
                            }
                            // RULE 2 (r9psc): a BARE parameter-reference setter
                            // folds to a constant carrying the REFERENCED
                            // param's literal form (VpiConstType +
                            // VpiDecompile), re-sized to the member width:
                            // `bit XFVEC = 1'b0` read by `EnableVectors: XFVEC`
                            // is BIN:0 / "1'b0" at size 1, not UINT:0.
                            else if (const Expression* lf2 =
                                         bareParamRef(*se)
                                             ? srlgLitFormSrc(comp, *se)
                                             : nullptr) {
                                int32_t w2 =
                                    (int32_t)fld.getType().getBitWidth();
                                auto* pe2 = emitExpr(*lf2, op2, prefix, netMap);
                                if (pe2 &&
                                    pe2->UhdmType() == UHDM::uhdmconstant) {
                                    auto* pc2 = (UHDM::constant*)pe2;
                                    if (std::string_view(pc2->VpiValue())
                                            .rfind("BIN:", 0) == 0) {
                                        std::string bits2;
                                        for (int32_t i2 = w2 - 1; i2 >= 0; i2--)
                                            bits2 +=
                                                (uvm[i2] == slang::logic_t(1))
                                                    ? '1'
                                                    : '0';
                                        pc2->VpiValue("BIN:" + bits2);
                                    }
                                    pc2->VpiSize(w2);
                                    pc2->VpiParent(op2);
                                    setLoc(pc2, se->sourceRange);
                                    opnds->push_back(pc2);
                                    continue;
                                }
                                std::string dg2 =
                                    uvm.toString(LiteralBase::Decimal, false);
                                c2->VpiDecompile(dg2);
                                c2->VpiSize(w2);
                                c2->VpiValue("UINT:" + dg2);
                                c2->VpiConstType(vpiUIntConst);
                            }
                            else {
                                std::string dg = uvm.toString(
                                    LiteralBase::Decimal, false);
                                c2->VpiDecompile(dg);
                                c2->VpiSize(
                                    (int32_t)fld.getType().getBitWidth());
                                c2->VpiValue("UINT:" + dg);
                                c2->VpiConstType(vpiUIntConst);
                            }
                            c2->VpiParent(op2);
                            setLoc(c2, se->sourceRange);
                            opnds->push_back(c2);
                        }
                    }
                    op2->Operands(opnds);
                    rhs = op2;
                }
                // A >64b struct param MATERIALIZED into an importing MODULE
                // keeps the TAGGED tree in the module DEF view (and in both
                // home-package views), but its ELAB view STRIPS the
                // tagged_pattern wrappers: the op75's direct operands are the
                // member VALUE expressions themselves, re-emitted as-is (a
                // size cast stays an op67 over the source constant) and sized
                // to the member width (ImportedDoubleCastedParameter
                // kmac_pkg::A).
                //
                // ...but only UP TO the first member WIDER than 64 bits.
                // Surelog's expandPatternAssignment walks the flattened
                // operands in member order, calling adjustOpSize (which
                // OVERWRITES the operand's size with the member width) and
                // then a per-bit loop whose `shift = csize-1-i` makes it
                // `return result` — the ORIGINAL, unflattened op — as soon as
                // a member is >64b. So:
                //   * bail (some member >64b): NO outer typespec, and every
                //     operand PAST the bailing one keeps its own size;
                //   * complete walk (all members <=64b): the FLATTENED op is
                //     returned, carrying a BARE ref_typespec (no parent, no
                //     fullname) -> the struct typespec, with every operand at
                //     its member width.
                // Probe matrix over member widths x member forms
                // (/tmp/r9tsfin/p1..p4, one source each, Surelog -elabuhdm):
                //   96          -> bail; cast op stays 96, no ts
                //   32          -> flat; bare ts, member 32
                //   32,32,32    -> flat; bare ts, members 32  (NoReducTypespec)
                //   96,32       -> bail; op 96 + plain const still 64, no ts
                // The last row is why the earlier "only member ops are
                // re-sized" note read as a rule: it is the BAILED half of this
                // one. kmac_pkg::A (96b member) and flash_req_t (171b member)
                // both sit on the bail side, which is why they never showed it.
                if (!rhs && structPat && topView && structWidePkg &&
                    isImported && !inPackage) {
                    auto& pctW = ps.getType().getCanonicalType();
                    auto& sinitW = stripImplicitConv(*init);
                    if (sinitW.kind ==
                        ExpressionKind::StructuredAssignmentPattern) {
                        auto& apW =
                            sinitW.as<StructuredAssignmentPatternExpression>();
                        auto* opW = s.MakeOperation();
                        opW->VpiOpType(75);
                        opW->VpiParent(pa);
                        setLoc(opW, init->sourceRange);
                        auto* opndW = s.MakeAnyVec();
                        bool okW = true;
                        // Index of the first member Surelog's walk cannot get
                        // past, or -1 when the walk completes.  TWO causes,
                        // both from expandPatternAssignment's untagged arm
                        // (CompileHelper.cpp ~5238): the per-bit loop's
                        // `shift = csize-1-i` returns as soon as a member is
                        // WIDER than 64 bits, and `get_uvalue` on an operand
                        // that does not reduce to a value sets invalidValue,
                        // which returns on the very next line.  A member whose
                        // value is itself an assignment PATTERN (a nested
                        // struct member, `'{HSK: '{1, 1'b0}, DAT: 32}`) is
                        // exactly that second case.  Either way adjustOpSize
                        // has ALREADY resized the bailing operand, so the bail
                        // index is INCLUSIVE.
                        int bailW = -1;
                        {
                            int fiW = 0;
                            for (auto& fld0 : pctW.as<PackedStructType>()
                                                  .membersOfType<FieldSymbol>()) {
                                if (fld0.getType().getBitWidth() > 64) {
                                    bailW = fiW;
                                    break;
                                }
                                const Expression* se0 = nullptr;
                                for (auto& ms0 : apW.memberSetters)
                                    if (ms0.member == &fld0) {
                                        se0 = ms0.expr;
                                        break;
                                    }
                                if (!se0)
                                    se0 = apW.defaultSetter;
                                if (se0) {
                                    auto& sv0 = stripImplicitConv(*se0);
                                    if (sv0.kind ==
                                            ExpressionKind::
                                                StructuredAssignmentPattern ||
                                        sv0.kind ==
                                            ExpressionKind::
                                                SimpleAssignmentPattern ||
                                        sv0.kind ==
                                            ExpressionKind::
                                                ReplicatedAssignmentPattern) {
                                        bailW = fiW;
                                        break;
                                    }
                                }
                                fiW++;
                            }
                        }
                        int fiW = -1;
                        for (auto& fld : pctW.as<PackedStructType>()
                                             .membersOfType<FieldSymbol>()) {
                            fiW++;
                            // Operands past the bail point are never touched.
                            bool sizeW = bailW < 0 || fiW <= bailW;
                            const Expression* se = nullptr;
                            for (auto& ms : apW.memberSetters)
                                if (ms.member == &fld) {
                                    se = ms.expr;
                                    break;
                                }
                            if (!se)
                                se = apW.defaultSetter;
                            if (!se) {
                                okW = false;
                                break;
                            }
                            // A REPLICATION member value keeps the SAME folded
                            // BIN constant the def view built (Surelog reuses
                            // the resolved value; only casts stay unfolded) —
                            // with an instance-scoped ts ref to a bare
                            // int_typespec. BSOPPS (72b pinmux_pkg).
                            if (stripImplicitConv(*se).kind ==
                                    ExpressionKind::Replication &&
                                se->type) {
                                ASTContext rctxW(comp.getRoot(),
                                                 LookupLocation::max);
                                if (auto rcvW = rctxW.tryEval(*se);
                                    rcvW && rcvW.isInteger() &&
                                    !rcvW.integer().hasUnknown()) {
                                    auto rivW = rcvW.integer();
                                    int32_t rwW =
                                        (int32_t)se->type->getBitWidth();
                                    std::string rbW;
                                    for (int32_t bW = rwW - 1; bW >= 0; bW--)
                                        rbW += (rivW[bW] == slang::logic_t(1))
                                                   ? '1'
                                                   : '0';
                                    auto* rcW = s.MakeConstant();
                                    rcW->VpiDecompile(rbW);
                                    rcW->VpiSize(rwW);
                                    rcW->VpiValue("BIN:" + rbW);
                                    rcW->VpiConstType(vpiBinaryConst);
                                    rcW->VpiParent(opW);
                                    setLoc(rcW, se->sourceRange);
                                    std::string tsPW = prefix;
                                    if (tsPW.size() >= 2 &&
                                        tsPW.compare(tsPW.size() - 2, 2,
                                                     "::") == 0)
                                        tsPW.resize(tsPW.size() - 2);
                                    auto* rrtW = s.MakeRef_typespec();
                                    rrtW->VpiParent(rcW);
                                    rrtW->VpiFullName(tsPW);
                                    rrtW->Actual_typespec(s.MakeInt_typespec());
                                    rcW->Typespec(rrtW);
                                    opndW->push_back(rcW);
                                    continue;
                                }
                            }
                            // An ENUM-MEMBER field value keeps the enum
                            // member's OWN literal form here too — the
                            // FLATTENED elab re-emit of a materialized package
                            // struct param is the fourth view of the same
                            // substitution (enumMemberSubstConst).
                            if (auto& sev9 = stripImplicitConv(*se);
                                sev9.kind == ExpressionKind::NamedValue) {
                                if (auto* ec9 = enumMemberSubstConst(
                                        sev9.as<NamedValueExpression>()
                                            .symbol)) {
                                    ec9->VpiParent(opW);
                                    setLoc(ec9, se->sourceRange);
                                    opndW->push_back(ec9);
                                    continue;
                                }
                            }
                            // An UNBASED-UNSIZED member value ('0) is the one
                            // payload Surelog RESOLVES in the elab view: a
                            // decimal UINT constant at the member width (the
                            // def view keeps the '0 form). Casts and folded
                            // bit patterns are re-emitted as they stand.
                            // TypedefStructParamWithRangeInSubmodule.
                            if (stripImplicitConv(*se).kind ==
                                ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                                ASTContext uctx(comp.getRoot(),
                                                LookupLocation::max);
                                if (auto ucv = uctx.tryEval(*se);
                                    ucv && ucv.isInteger() &&
                                    !ucv.integer().hasUnknown()) {
                                    auto uiv = ucv.integer();
                                    uiv.setSigned(false);
                                    std::string ud = uiv.toString(
                                        LiteralBase::Decimal, false);
                                    auto* uc = s.MakeConstant();
                                    uc->VpiDecompile(ud);
                                    uc->VpiSize(
                                        (int32_t)fld.getType().getBitWidth());
                                    uc->VpiValue("UINT:" + ud);
                                    uc->VpiConstType(vpiUIntConst);
                                    uc->VpiParent(opW);
                                    setLoc(uc, se->sourceRange);
                                    opndW->push_back(uc);
                                    continue;
                                }
                            }
                            bool savedRe = reemitting;
                            reemitting = true;
                            // The re-emitted size-cast typespecs belong to the
                            // HOME package (vpiInstance), like every other
                            // module-view copy of an imported param's init.
                            auto* savedImpW = importedInitPkgInst;
                            if (ps.getParentScope())
                                if (auto pitW = pkgDefMap.find(
                                        &ps.getParentScope()->asSymbol());
                                    pitW != pkgDefMap.end())
                                    importedInitPkgInst =
                                        (UHDM::instance*)pitW->second;
                            // The member value is being emitted INSIDE a
                            // pattern (the flattened op75 was built by hand
                            // here, so emitExpr cannot see it): a NESTED
                            // pattern keeps every element at 64 instead of
                            // sizing its first operand to the element type.
                            bool savedPatW = inAssignPattern;
                            inAssignPattern = true;
                            auto* me = emitExpr(*se, opW, prefix, netMap);
                            inAssignPattern = savedPatW;
                            importedInitPkgInst = savedImpW;
                            reemitting = savedRe;
                            if (!me) {
                                okW = false;
                                break;
                            }
                            me->VpiParent(opW);
                            // adjustOpSize overwrites the operand size with the
                            // member width whatever the operand is — an op or a
                            // plain constant alike (the constant half only ever
                            // shows on the non-bailed side, hence the p2/p3
                            // probes).
                            if (sizeW) {
                                if (me->UhdmType() == UHDM::uhdmoperation)
                                    ((UHDM::operation*)me)->VpiSize(
                                        (int32_t)fld.getType().getBitWidth());
                                else if (me->UhdmType() == UHDM::uhdmconstant)
                                    ((UHDM::constant*)me)->VpiSize(
                                        (int32_t)fld.getType().getBitWidth());
                            }
                            opndW->push_back(me);
                        }
                        if (okW && !opndW->empty()) {
                            opW->Operands(opndW);
                            // A COMPLETE walk returns the flattened op, which
                            // carries the bare struct ts ref; a bailed one
                            // returns the untagged original.
                            if (bailW < 0) {
                                auto* rtW = s.MakeRef_typespec();
                                opW->Typespec(rtW);
                                rhsRt = rtW;
                            }
                            rhs = opW;
                        }
                    }
                }
                // ELAB (topView) view of a materialized UNPACKED-ARRAY-of-packed-
                // struct param: Surelog FOLDS the '{'{...}} pattern. The outer op
                // carries the param's array_typespec; the array element struct is
                // ABSORBED (its members become the op's direct operands); each
                // member value folds recursively — a struct whose fields are all
                // scalar collapses to a constant, a struct with a sub-struct field
                // stays an op75 tagged with that struct's typespec. (Refuses any
                // shape it cannot fold exactly, leaving the baseline pattern.)
                bool structArrShape9 = false;
                if (auto& pctA9 = ps.getType().getCanonicalType();
                    pctA9.kind == SymbolKind::FixedSizeUnpackedArrayType) {
                    const Type* lf9a = &pctA9;
                    while (lf9a->getCanonicalType().kind ==
                           SymbolKind::FixedSizeUnpackedArrayType)
                        lf9a = &lf9a->getCanonicalType()
                                    .as<FixedSizeUnpackedArrayType>()
                                    .elementType;
                    structArrShape9 =
                        lf9a->getCanonicalType().kind ==
                            SymbolKind::PackedStructType &&
                        init &&
                        stripImplicitConv(*init).kind ==
                            ExpressionKind::SimpleAssignmentPattern;
                }
                if (!rhs && topView && !inPackage && hasParamArrTs &&
                    structArrShape9) {
                    std::string pfxA = prefix;
                    if (pfxA.size() >= 2 &&
                        pfxA.compare(pfxA.size() - 2, 2, "::") == 0)
                        pfxA.resize(pfxA.size() - 2);
                    if (auto* aop = foldUnpackedStructArrayPattern(
                            *init, ps.getType(), paramArrTs(), pfxA, pa, prefix,
                            netMap)) {
                        rhs = aop;
                    }
                }
                // ELAB OVERRIDDEN unpacked VECTOR-array param: the Rhs folds
                // to ONE wide BIN constant of the OVERRIDE bits at the
                // DEFAULT span, nameless ts ref -> the array_typespec.
                // Surelog ZERO-extends sized 'b literals (17'bx -> 16 zeros
                // + x), so fold TEXTUALLY from the override syntax and bail
                // on any non-'b leaf (param_array_wildcard).
                if (!rhs && topView && !inPackage && overridden &&
                    hasParamArrTs && boundInit && boundInit->syntax &&
                    defaultSyn) {
                    const Type* lf9 = &ps.getType().getCanonicalType();
                    bool isArr9 =
                        lf9->kind == SymbolKind::FixedSizeUnpackedArrayType;
                    while (lf9->getCanonicalType().kind ==
                           SymbolKind::FixedSizeUnpackedArrayType)
                        lf9 = &lf9->getCanonicalType()
                                   .as<FixedSizeUnpackedArrayType>()
                                   .elementType;
                    if (isArr9 && lf9->getCanonicalType().isPackedArray()) {
                        std::string bits9;
                        std::function<bool(const syntax::SyntaxNode&)> fold9 =
                            [&](const syntax::SyntaxNode& sn9) -> bool {
                            if (sn9.kind == syntax::SyntaxKind::
                                                ConcatenationExpression) {
                                for (auto* el9 :
                                     sn9.as<syntax::ConcatenationExpressionSyntax>()
                                         .expressions)
                                    if (!fold9(*el9))
                                        return false;
                                return true;
                            }
                            if (sn9.kind == syntax::SyntaxKind::
                                                IntegerVectorExpression) {
                                std::string t9(rawText(sn9.sourceRange()));
                                auto q9 = t9.find('\'');
                                if (q9 == std::string::npos || q9 == 0)
                                    return false;
                                size_t sz9 =
                                    (size_t)atoi(t9.substr(0, q9).c_str());
                                if (!sz9 || q9 + 1 >= t9.size() ||
                                    (char)tolower(t9[q9 + 1]) != 'b')
                                    return false;
                                std::string dg9;
                                for (char ch9 : t9.substr(q9 + 2))
                                    if (ch9 != '_' && ch9 != ' ')
                                        dg9 += (char)tolower(ch9);
                                if (dg9.empty() || dg9.size() > sz9)
                                    return false;
                                bits9 +=
                                    std::string(sz9 - dg9.size(), '0') + dg9;
                                return true;
                            }
                            return false;
                        };
                        if (fold9(*boundInit->syntax) && !bits9.empty()) {
                            auto* c9 = s.MakeConstant();
                            c9->VpiDecompile(std::to_string(bits9.size()) +
                                             "'b" + bits9);
                            c9->VpiSize((int32_t)bits9.size());
                            c9->VpiValue("BIN:" + bits9);
                            c9->VpiConstType(vpiBinaryConst);
                            setLoc(c9, defaultSyn->sourceRange());
                            auto* rt9 = s.MakeRef_typespec();
                            rt9->VpiParent(c9);
                            rt9->Actual_typespec(paramArrTs());
                            c9->Typespec(rt9);
                            rhs = c9;
                        }
                    }
                }
                // DEF-view TYPEDEF-typed param whose default is an UNQUALIFIED
                // ref to an imported pkg param (materialized in this module)
                // keeps an UNBOUND ref_obj Rhs (Surelog), not a fold. A param
                // typed by a DIRECT vector (logic [7:0][3:0] P = X) still
                // folds (ParameterFromPkg* distinguisher).
                if (!rhs && !topView && !inPackage && ps.getDeclaredType() &&
                    ps.getDeclaredType()->getType().kind ==
                        SymbolKind::TypeAlias) {
                    auto& sref9 = stripImplicitConv(*init);
                    if (sref9.kind == ExpressionKind::NamedValue &&
                        sref9.as<NamedValueExpression>().symbol.kind ==
                            SymbolKind::Parameter &&
                        sref9.syntax &&
                        sref9.syntax->kind ==
                            syntax::SyntaxKind::IdentifierName) {
                        auto& rsym9 = sref9.as<NamedValueExpression>().symbol;
                        if (auto rsc9 = rsym9.getParentScope();
                            rsc9 && rsc9->asSymbol().kind ==
                                        SymbolKind::Package &&
                            std::find(paramSyms.begin(), paramSyms.end(),
                                      (const ParameterSymbol*)&rsym9) !=
                                paramSyms.end()) {
                            auto* ro9 = s.MakeRef_obj();
                            ro9->VpiName(rsym9.name);
                            ro9->VpiFullName(
                                joinPath(prefix, std::string(rsym9.name)));
                            ro9->VpiParent(pa);
                            setLoc(ro9, init->sourceRange);
                            rhs = ro9;
                        }
                    }
                }
                // A MODULE localparam initialized by a DIRECT const-call
                // (localparam A = func(0)) folds in the ELAB view; the def view
                // keeps the func_call (Surelog).
                // A body-declared `parameter` folds the same way — the
                // localparam keyword is not the distinguisher, the ELAB view is
                // (FuncCase: `parameter p = num_operands(DIVSQRT)` in module
                // top folds to UINT:2 in the top view, func_call in the def).
                if (!rhs && topView && !inPackage) {
                    auto& icc9 = stripImplicitConv(*init);
                    const SubroutineSymbol* csub9 = nullptr;
                    if (icc9.kind == ExpressionKind::Call &&
                        !icc9.as<CallExpression>().isSystemCall())
                        if (auto sp9 = std::get_if<const SubroutineSymbol*>(
                                &icc9.as<CallExpression>().subroutine))
                            csub9 = *sp9;
                    // An ARGUMENT Surelog cannot itself reduce to a constant
                    // (a system call outside ExprEval's repertoire — $floor,
                    // $ceil, ... as opposed to $bits/$clog2/$size/$signed)
                    // makes EvalFunc report an invalid value, so the call
                    // stays a func_call in the elab view too (const_func:
                    // localparam signed Z = negate($floor(W / X))).
                    bool unevalArg9 = false;
                    if (csub9)
                        for (auto* a9 : icc9.as<CallExpression>().arguments())
                            a9->visit(makeVisitor(
                                [&](auto& vis9, const CallExpression& ce9) {
                                    static const std::set<std::string>
                                        kEvalSys = {"$bits",  "$size",
                                                    "$high",  "$low",
                                                    "$left",  "$right",
                                                    "$clog2", "$signed",
                                                    "$unsigned"};
                                    if (ce9.isSystemCall() &&
                                        !kEvalSys.count(std::string(
                                            ce9.getSubroutineName())))
                                        unevalArg9 = true;
                                    vis9.visitDefault(ce9);
                                }));
                    // A function whose body declares a LOCALPARAM defeats
                    // Surelog's const evaluator — the call stays symbolic
                    // (const_func_block_var). Lifetime is irrelevant.
                    if (csub9 && !unevalArg9 && !subroutineDeclaresParam(*csub9) &&
                        !subroutinePoisonsEvalFunc(*csub9, comp)) {
                        auto& pv9 = ps.getValue();
                        if (pv9.isInteger() &&
                            !pv9.integer().hasUnknown()) {
                            auto iv9 = pv9.integer();
                            // Surelog's 64-bit fold model (srlgFold) beats the
                            // LRM value where a sign-extended `>>` is in play.
                            if (hasSignExtendedShift(*csub9)) {
                                SrlgFold sf9;
                                if (auto wv9 = sf9.call(
                                        *csub9,
                                        icc9.as<CallExpression>().arguments()))
                                    iv9 = SVInt(64, (uint64_t)*wv9, false);
                            }
                            // A RANGED-UNTYPED localparam const-call fold
                            // ([HI:LO] C_CONST = F(..)) folds like A_CONST: UINT
                            // at the (per-instance) RANGE width with a ts ref to
                            // the range int_typespec — NOT the BIN value form a
                            // plain untyped localparam takes.
                            if (isRangedUntypedParam(ps)) {
                                std::string digits9 =
                                    iv9.toString(LiteralBase::Decimal, false);
                                auto* c9 = s.MakeConstant();
                                c9->VpiDecompile(digits9);
                                c9->VpiSize(
                                    (int32_t)ps.getType().getBitWidth());
                                c9->VpiValue("UINT:" + digits9);
                                c9->VpiConstType(vpiUIntConst);
                                c9->VpiParent(pa);
                                setLoc(c9, icc9.sourceRange);
                                if (wantTs) {
                                    auto* rt = s.MakeRef_typespec();
                                    std::string tsPfx9 = prefix;
                                    if (tsPfx9.size() >= 2 &&
                                        tsPfx9.compare(tsPfx9.size() - 2, 2,
                                                       "::") == 0)
                                        tsPfx9.resize(tsPfx9.size() - 2);
                                    rt->VpiFullName(tsPfx9);
                                    rt->VpiParent(c9);
                                    c9->Typespec(rt);
                                    rhsRt = rt;
                                }
                                rhs = c9;
                            }
                            // An explicitly-TYPED integral localparam
                            // (localparam int unsigned M = F(..)) folds at the
                            // PARAM's width, BIN-encoded (evalFunc hands back
                            // the masked bit vector) and carrying the param's
                            // own typespec ref — ArrayExprFuncArg MAX_VADDR.
                            else if (typedParam && wantTs &&
                                     ps.getType().getCanonicalType().kind ==
                                         SymbolKind::PredefinedIntegerType) {
                                int32_t w8 =
                                    (int32_t)ps.getType().getBitWidth();
                                auto wv8 = iv9.resize((slang::bitwidth_t)w8);
                                std::string bits8;
                                for (int32_t i8 = w8 - 1; i8 >= 0; i8--)
                                    bits8 +=
                                        wv8[i8] == slang::logic_t(1) ? '1' : '0';
                                auto* c8 = s.MakeConstant();
                                c8->VpiDecompile(std::to_string(w8) + "'b" +
                                                 bits8);
                                c8->VpiSize(w8);
                                c8->VpiValue("BIN:" + bits8);
                                c8->VpiConstType(vpiBinaryConst);
                                c8->VpiParent(pa);
                                setLoc(c8, icc9.sourceRange);
                                auto* rt8 = s.MakeRef_typespec();
                                std::string tsPfx8 = prefix;
                                if (tsPfx8.size() >= 2 &&
                                    tsPfx8.compare(tsPfx8.size() - 2, 2, "::") == 0)
                                    tsPfx8.resize(tsPfx8.size() - 2);
                                rt8->VpiFullName(tsPfx8);
                                rt8->VpiParent(c8);
                                c8->Typespec(rt8);
                                rhsRt = rt8;
                                rhs = c8;
                            }
                            else {
                            // Surelog sizes the inlined fold at the FUNCTION
                            // RETURN type's width; a PREDEFINED-integer return
                            // (`function integer log2`) carries no explicit
                            // width, so it takes the untyped 64-bit default
                            // ([30:0]/[7:0] returns keep 31/8).
                            auto& rty9 = csub9->getReturnType();
                            int32_t w9 = rty9.isPredefinedInteger()
                                             ? 64
                                             : (int32_t)rty9.getBitWidth();
                            if (w9 <= 0)
                                w9 = (int32_t)iv9.getBitWidth();
                            auto enc9 = constCallEncoding(*csub9);
                            std::string digits9 =
                                iv9.toString(LiteralBase::Decimal, false);
                            auto* c9 = s.MakeConstant();
                            if (enc9 == ConstCallEnc::ConcatBin) {
                                auto wv9 = iv9.resize((slang::bitwidth_t)w9);
                                std::string bits9;
                                for (int32_t i9 = w9 - 1; i9 >= 0; i9--)
                                    bits9 += wv9[i9] == slang::logic_t(1)
                                                 ? '1'
                                                 : '0';
                                c9->VpiDecompile(std::to_string(w9) + "'b" +
                                                 bits9);
                                c9->VpiValue("BIN:" + bits9);
                                c9->VpiConstType(vpiBinaryConst);
                            }
                            else if (enc9 == ConstCallEnc::BoolBin) {
                                c9->VpiDecompile(std::to_string(w9) + "'b" +
                                                 digits9);
                                c9->VpiValue("BIN:" + digits9);
                                c9->VpiConstType(vpiBinaryConst);
                            }
                            else if (enc9 == ConstCallEnc::Int) {
                                c9->VpiDecompile(digits9);
                                c9->VpiValue("INT:" + digits9);
                                c9->VpiConstType(vpiIntConst);
                            }
                            else {
                                c9->VpiDecompile(digits9);
                                c9->VpiValue("UINT:" + digits9);
                                c9->VpiConstType(vpiUIntConst);
                            }
                            c9->VpiSize(w9);
                            // ...unless the EXECUTED return assignment handed
                            // back a FORMAL ARGUMENT. EvalFunc binds a formal
                            // to a constant carrying the FORMAL's typespec, and
                            // `<retvar> = <formal>` returns that very object —
                            // so the fold takes the formal's encoding (signed
                            // INT at its own width) plus a ts ref to its
                            // typespec, not the function-return default.
                            // Measured on the same `function integer log2;
                            // input integer value; if (value<2) log2 = value;
                            // else begin ... log2 = res; end` body in two
                            // callers:
                            //   log2(1) -> value  branch: INT:1 size 32 + an
                            //              integer_typespec ref (PreprocFunc)
                            //   log2(4) -> res    branch: UINT:2 size 64, no ts
                            //              (asym_ram_sdp_*_wider)
                            // so it is the EXECUTED path, not the source order,
                            // and a computed LOCAL does not carry a typespec.
                            // SrlgFold replays the execution; it bails (nullopt)
                            // on the loop-bodied branch, which is exactly the
                            // case that must keep the default encoding.
                            const Symbol* irs9 = nullptr;
                            if (rty9.isPredefinedInteger()) {
                                SrlgFold rsf9;
                                if (rsf9.call(*csub9,
                                              icc9.as<CallExpression>()
                                                  .arguments()))
                                    if (auto* rsrc9 = rsf9.resultSource()) {
                                        auto& rse9 = stripImplicitConv(*rsrc9);
                                        if (rse9.kind ==
                                            ExpressionKind::NamedValue) {
                                            auto& rsy9 =
                                                rse9.as<NamedValueExpression>()
                                                    .symbol;
                                            if (rsy9.kind ==
                                                    SymbolKind::FormalArgument &&
                                                rsy9.getDeclaredType() &&
                                                rsy9.getDeclaredType()
                                                    ->getType()
                                                    .getCanonicalType()
                                                    .isPredefinedInteger())
                                                irs9 = &rsy9;
                                        }
                                    }
                            }
                            if (irs9) {
                                auto& ity9 = irs9->getDeclaredType()
                                                 ->getType()
                                                 .getCanonicalType();
                                c9->VpiSize((int32_t)ity9.getBitWidth());
                                c9->VpiDecompile(digits9);
                                if (ity9.isSigned()) {
                                    c9->VpiValue("INT:" + digits9);
                                    c9->VpiConstType(vpiIntConst);
                                }
                                else {
                                    c9->VpiValue("UINT:" + digits9);
                                    c9->VpiConstType(vpiUIntConst);
                                }
                                // The ts ref rides on the FOLD, not on the
                                // param declaration: an untyped localparam
                                // (wantTs false) still carries it.
                                if (auto* lts9 =
                                        predefIntTypespec(ity9, *irs9)) {
                                    auto* rt9 = s.MakeRef_typespec();
                                    std::string tsPfx9 = prefix;
                                    if (tsPfx9.size() >= 2 &&
                                        tsPfx9.compare(tsPfx9.size() - 2, 2,
                                                       "::") == 0)
                                        tsPfx9.resize(tsPfx9.size() - 2);
                                    rt9->VpiFullName(tsPfx9);
                                    rt9->VpiParent(c9);
                                    rt9->Actual_typespec(lts9);
                                    c9->Typespec(rt9);
                                }
                            }
                            c9->VpiParent(pa);
                            setLoc(c9, icc9.sourceRange);
                            rhs = c9;
                            }
                        }
                    }
                }
                forceConstParent = !nestedPat;
                inParamInit = true;
                // A wide (>64b) PACKAGE struct-pattern param's ELAB view is
                // byte-identical to its DEF view (tagged_pattern tree); drive
                // emitExpr down the def path for it (WIDTH RULE).
                paramInitDef = !topView || structWidePkg;
                paramInitElabFold = topView && structNoScopedRefPkg;
                paramInitPkg = inPackage;
                // Surelog compiles a MULTIDIMENSIONAL package parameter's value
                // with Reduce::No (CompileHelper::isMultidimensional gates the
                // reduce on the typespec carrying more than one packed range),
                // so its ELAB Rhs keeps the very same symbolic operand tree the
                // def view has — no operand folds to a constant (IntegerConcat).
                // ...and a MATERIALIZED IMPORT copy of such a param is cloned
                // from that unreduced package Rhs, so BOTH module views carry
                // the same symbolic (and reordered) operand tree — the module
                // copy never re-folds the operands (IntegerConcat
                // work@dut.SeedInfoPageSel).
                pkgElabSymOperands = ((inPackage && topView) ||
                                      (!inPackage && isImported)) &&
                                     packedDimCount(ps.getType()) > 1;
                importedParamClone = isImported && !inPackage;
                bool savedSuppP = suppressConstParent;
                if (!topView && nestedPat)
                    suppressConstParent = true;
                // ELAB (topView) view of an UNPACKED-struct typed param: Surelog
                // FOLDS the elab default to the flat op form (each struct level
                // is an op75 tagged with its struct_typespec; the leaf scalar is
                // a bare constant), rather than the DEF tagged_pattern shape.
                // Re-emit in `reemitting` mode to drop the tags; the outer op's
                // struct ts ref is attached below (structOp -> rhsRt). The DEF
                // view keeps the tagged form (paramInitDef).
                // The elab default may reach us as a struct assignment pattern
                // OR as a NamedValue reference to a struct-valued (local)param
                // that emitExpr folds into the pattern op — both fold flat.
                bool elabUnpStructPat = false;
                if (topView && !inPackage && typedParam && !rhs) {
                    auto& sk0 = stripImplicitConv(*init);
                    elabUnpStructPat =
                        ps.getType().getCanonicalType().kind ==
                            SymbolKind::UnpackedStructType &&
                        (sk0.kind == ExpressionKind::StructuredAssignmentPattern ||
                         sk0.kind == ExpressionKind::SimpleAssignmentPattern ||
                         sk0.kind == ExpressionKind::NamedValue);
                }
                bool savedReemit0 = reemitting;
                if (elabUnpStructPat)
                    reemitting = true;
                auto* savedImpInst0 = importedInitPkgInst;
                if (!inPackage && isImported && ps.getParentScope())
                    if (auto pit0 =
                            pkgDefMap.find(&ps.getParentScope()->asSymbol());
                        pit0 != pkgDefMap.end())
                        importedInitPkgInst = (UHDM::instance*)pit0->second;
                // LAZY ternary. Surelog's elab reduce evaluates only the
                // CONDITION and SUBSTITUTES the selected branch, then reduces
                // that branch; the untaken branch and the ternary itself are
                // gone from the elab Rhs. When the selected branch does NOT
                // reduce — 8/A with A == 0, a division by zero ExprEval
                // refuses — the branch OPERATION survives as the Rhs with its
                // operands reduced. slang instead evaluates the whole ternary
                // to 'x, so the generic fold above declined and we re-emitted
                // the entire ternary tree (CondOpLazyEval B; its sibling C,
                // whose branch is the literal 1, folds through the normal
                // path and never reaches here).
                const Expression* emitInit9 = init;
                bool lazyTernary9 = false;
                if (!rhs && topView && typedParam && !inPackage) {
                    const Expression* sel9 = &stripImplicitConv(*init);
                    for (int g9 = 0;
                         g9 < 32 && sel9->kind == ExpressionKind::ConditionalOp;
                         ++g9) {
                        auto& co9 = sel9->as<ConditionalExpression>();
                        if (co9.conditions.size() != 1 ||
                            co9.conditions[0].pattern)
                            break;
                        ASTContext cc9(comp.getRoot(), LookupLocation::max);
                        ConstantValue pv9 = cc9.tryEval(*co9.conditions[0].expr);
                        if (!pv9 || !pv9.isInteger() ||
                            pv9.integer().hasUnknown())
                            break;
                        sel9 = &stripImplicitConv(pv9.isTrue() ? co9.left()
                                                               : co9.right());
                        lazyTernary9 = true;
                    }
                    if (lazyTernary9 &&
                        sel9->kind != ExpressionKind::ConditionalOp)
                        emitInit9 = sel9;
                    else
                        lazyTernary9 = false;
                }
                // A DEF-view MATERIALIZED IMPORT copy whose init is a SYSTEM
                // function call ($clog2(N)) folds to the evaluated constant:
                // the copy is already resolved, so Surelog reduces it in BOTH
                // module views, keeping the call span, the param's type width
                // and a ts ref to the copy's own typespec. A module-LOCAL
                // localparam with the SAME init keeps its sys_func_call in the
                // def view — measured on one source (pkg p2::W = $clog2(N)
                // imported into top2, which also declares `localparam int LW =
                // $clog2(N)`: defMod folds W, leaves LW a sys_func_call).
                if (!rhs && !topView && !inPackage && isImported &&
                    stripImplicitConv(*init).kind == ExpressionKind::Call &&
                    stripImplicitConv(*init).as<CallExpression>().isSystemCall() &&
                    ps.getValue().isInteger() &&
                    !ps.getValue().integer().hasUnknown()) {
                    auto& sv7 = ps.getValue().integer();
                    std::string dg7 = sv7.toString(LiteralBase::Decimal, false);
                    bool neg7 = sv7.isSigned() && sv7.isNegative();
                    auto* c7 = s.MakeConstant();
                    c7->VpiDecompile(dg7);
                    c7->VpiSize((int32_t)ps.getType().getBitWidth());
                    c7->VpiValue((neg7 ? "INT:" : "UINT:") + dg7);
                    c7->VpiConstType(neg7 ? vpiIntConst : vpiUIntConst);
                    c7->VpiParent(pa);
                    setLoc(c7, init->sourceRange);
                    auto* rt7 = s.MakeRef_typespec();
                    std::string tsPfx7 = prefix;
                    if (tsPfx7.size() >= 2 &&
                        tsPfx7.compare(tsPfx7.size() - 2, 2, "::") == 0)
                        tsPfx7.resize(tsPfx7.size() - 2);
                    rt7->VpiFullName(tsPfx7);
                    rt7->VpiParent(c7);
                    c7->Typespec(rt7);
                    rhsRt = rt7;
                    rhs = c7;
                }
                if (!rhs) {
                    bool savedPSE9 = patSubstElab;
                    bool savedPRD9 = paramRhsDefView;
                    patSubstElab = topView;
                    paramRhsDefView = !topView && !inPackage;
                    rhs = emitExpr(*emitInit9, pa, prefix, netMap);
                    patSubstElab = savedPSE9;
                    paramRhsDefView = savedPRD9;
                }
                importedInitPkgInst = savedImpInst0;
                reemitting = savedReemit0;
                // A DEF-view materialized UNTYPED integral import's Rhs constant
                // is sized at the param's type width (Surelog: 32 for a plain
                // int import) — matching its elab view, not the 64-bit default.
                if (!topView && !inPackage && isImported && !typedParam && rhs &&
                    rhs->UhdmType() == UHDM::uhdmconstant &&
                    ps.getType().getCanonicalType().isIntegral() &&
                    ps.getDeclaredType() &&
                    ps.getDeclaredType()->getTypeSyntax() &&
                    ps.getDeclaredType()->getTypeSyntax()->kind ==
                        syntax::SyntaxKind::ImplicitType)
                    ((UHDM::constant*)rhs)
                        ->VpiSize((int32_t)ps.getType().getBitWidth());
                suppressConstParent = savedSuppP;
                // An UNPACKED-ARRAY package parameter's assignment-pattern
                // element REDUCES in EVERY view (Surelog compiles the element
                // expressions Reduce::Yes even for the def listing): a computed
                // element (1344/MsgWidth) becomes an unparented INT constant
                // anchored at the BinaryOp's LEFT-operand span — the same
                // "* / - fold signed, at the left span" family the
                // pkgElabComputed folds follow. Kmac sha3_pkg::KeccakRate.
                //
                // The element constant's vpiSize is view-dependent, and it is
                // the SAME size for computed and literal elements — only the
                // const type differs (a computed element is INT, a literal
                // keeps its own UINT/BIN encoding):
                //   def package / elab package / def-module import copy -> 64
                //     (Surelog's 64-bit expression word, unwidened)
                //   ELABORATED INSTANCE view -> the array ELEMENT type width
                //     (the elaborator re-reduces the pattern against the
                //     declared element type, which is also where the op gains
                //     its array_typespec ref)
                // Measured on a 5-param witness whose element types are
                // int unsigned / longint unsigned / byte / logic[11:0] /
                // shortint: the instance view reads 32/64/8/12/16 while every
                // other view reads 64 across the board.
                int32_t elemSz9 = 64;
                if (topView && !inPackage &&
                    ps.getType().getCanonicalType().kind ==
                        SymbolKind::FixedSizeUnpackedArrayType) {
                    auto& et9 = ps.getType()
                                    .getCanonicalType()
                                    .as<FixedSizeUnpackedArrayType>()
                                    .elementType;
                    if (et9.isIntegral() && et9.getBitWidth() > 0)
                        elemSz9 = (int32_t)et9.getBitWidth();
                }
                if (rhs && rhs->UhdmType() == UHDM::uhdmoperation &&
                    (inPackage || isImported) &&
                    ps.getType().getCanonicalType().kind ==
                        SymbolKind::FixedSizeUnpackedArrayType) {
                    auto* pop9 = (UHDM::operation*)rhs;
                    auto& pin9 = stripImplicitConv(*init);
                    std::span<const Expression* const> pel9;
                    if (pin9.kind == ExpressionKind::SimpleAssignmentPattern)
                        pel9 = pin9.as<SimpleAssignmentPatternExpression>()
                                   .elements();
                    if (pop9->VpiOpType() == vpiAssignmentPatternOp &&
                        pop9->Operands() &&
                        pop9->Operands()->size() == pel9.size()) {
                        ASTContext pctx9(comp.getRoot(), LookupLocation::max);
                        for (size_t i9 = 0; i9 < pel9.size(); i9++) {
                            // A LITERAL element already folded on the ordinary
                            // path; only its width needs the view's size (it
                            // keeps its own const type — golden's UINT:5 at
                            // size 8 for a `byte` array's literal element).
                            if ((*pop9->Operands())[i9]->UhdmType() ==
                                UHDM::uhdmconstant) {
                                ((UHDM::constant*)(*pop9->Operands())[i9])
                                    ->VpiSize(elemSz9);
                                continue;
                            }
                            if ((*pop9->Operands())[i9]->UhdmType() !=
                                UHDM::uhdmoperation)
                                continue;
                            auto& pe9 = stripImplicitConv(*pel9[i9]);
                            // A STRUCT/UNION element keeps its tagged-pattern
                            // operation in every view (a packed struct is
                            // integral in slang, so its value would otherwise
                            // fold to a bare constant and lose the member
                            // tree) — StructArrayParameterInitializedBy
                            // PatternPassedAsPort.
                            if (!pe9.type)
                                continue;
                            auto pk9 = pe9.type->getCanonicalType().kind;
                            if (pk9 == SymbolKind::PackedStructType ||
                                pk9 == SymbolKind::UnpackedStructType ||
                                pk9 == SymbolKind::PackedUnionType ||
                                pk9 == SymbolKind::UnpackedUnionType)
                                continue;
                            ConstantValue pv9 = pctx9.tryEval(pe9);
                            if (!pv9.isInteger() ||
                                pv9.integer().hasUnknown())
                                continue;
                            SVInt sv9 = pv9.integer();
                            sv9.setSigned(true);
                            std::string dg9 =
                                sv9.toString(LiteralBase::Decimal, false);
                            auto* pc9 = s.MakeConstant();
                            pc9->VpiDecompile(dg9);
                            pc9->VpiSize(elemSz9);
                            pc9->VpiValue("INT:" + dg9);
                            pc9->VpiConstType(vpiIntConst);
                            setLoc(pc9, pe9.kind == ExpressionKind::BinaryOp
                                            ? pe9.as<BinaryExpression>()
                                                  .left()
                                                  .sourceRange
                                            : pe9.sourceRange);
                            (*pop9->Operands())[i9] = pc9;
                        }
                    }
                }
                // Surelog reverses the operands of an elab package parameter's
                // concat / assignment-pattern Rhs when the parameter's first
                // packed range DECREASES ([1:0]) and the operands are still
                // symbolic (the `(*operands)[0] is a ref_obj` guard in
                // CompileHelper), marking the operation vpiReordered. The DEF
                // view is built from the unreduced, unreordered expression and
                // keeps source order (IntegerConcat).
                if (pkgElabSymOperands && rhs &&
                    rhs->UhdmType() == UHDM::uhdmoperation &&
                    firstPackedRangeDecreasing(ps.getType())) {
                    auto* opd9 = (UHDM::operation*)rhs;
                    int ot9 = opd9->VpiOpType();
                    if ((ot9 == vpiConcatOp || ot9 == vpiAssignmentPatternOp) &&
                        opd9->Operands() && !opd9->Operands()->empty() &&
                        (*opd9->Operands())[0]->UhdmType() ==
                            UHDM::uhdmref_obj) {
                        opd9->VpiReordered(true);
                        std::reverse(opd9->Operands()->begin(),
                                     opd9->Operands()->end());
                    }
                }
                pkgElabSymOperands = false;
                paramInitPkg = false;
                paramInitDef = false;
                paramInitElabFold = false;
                importedParamClone = false;
                inParamInit = false;
                forceConstParent = false;
                // The substituted branch is REDUCED in place: its param refs
                // fold to their elaborated values (A -> UINT:0 at the param's
                // own type width, at the ref's span, parented at the
                // operation) while literal operands keep their unsized 64-bit
                // form.
                if (lazyTernary9 && rhs &&
                    rhs->UhdmType() == UHDM::uhdmoperation) {
                    auto* opl9 = (UHDM::operation*)rhs;
                    if (opl9->Operands())
                        for (auto*& o9 : *opl9->Operands()) {
                            if (o9->UhdmType() != UHDM::uhdmref_obj)
                                continue;
                            auto* r9 = (UHDM::ref_obj*)o9;
                            const ParameterSymbol* src9 = nullptr;
                            for (auto& mem9 : body.members())
                                if (mem9.kind == SymbolKind::Parameter &&
                                    mem9.name == r9->VpiName())
                                    src9 = &mem9.as<ParameterSymbol>();
                            if (!src9)
                                continue;
                            auto& cvl9 = src9->getValue();
                            if (!cvl9.isInteger() ||
                                cvl9.integer().hasUnknown())
                                continue;
                            std::string dgl9 = cvl9.integer().toString(
                                LiteralBase::Decimal, false);
                            auto* cl9 = s.MakeConstant();
                            cl9->VpiDecompile(dgl9);
                            cl9->VpiSize(
                                (int32_t)src9->getType().getBitWidth());
                            cl9->VpiValue("UINT:" + dgl9);
                            cl9->VpiConstType(vpiUIntConst);
                            cl9->VpiParent(opl9);
                            cl9->VpiFile(r9->VpiFile());
                            cl9->VpiLineNo(r9->VpiLineNo());
                            cl9->VpiColumnNo(r9->VpiColumnNo());
                            cl9->VpiEndLineNo(r9->VpiEndLineNo());
                            cl9->VpiEndColumnNo(r9->VpiEndColumnNo());
                            o9 = cl9;
                        }
                }
                // Elab typed-param op init with UNKNOWN param-ref operands:
                // the refs fold to their BIN:X/Z constants and the op gains a
                // ts ref (patched to the param's typespec).
                if (topView && typedParam && rhs &&
                    rhs->UhdmType() == UHDM::uhdmoperation) {
                    auto* opr = (UHDM::operation*)rhs;
                    bool anyUnknown = false;
                    if (opr->Operands())
                        for (auto*& o2 : *opr->Operands()) {
                            if (o2->UhdmType() != UHDM::uhdmref_obj)
                                continue;
                            auto* r2 = (UHDM::ref_obj*)o2;
                            for (auto* pp : *params) {
                                if (pp->VpiName() != r2->VpiName())
                                    continue;
                                std::string_view pv =
                                    ((UHDM::parameter*)pp)->VpiValue();
                                if (pv.rfind("BIN:", 0) == 0 &&
                                    pv.find_first_of("XZxz") !=
                                        std::string_view::npos) {
                                    auto* c2 = s.MakeConstant();
                                    std::string digs(pv.substr(4));
                                    c2->VpiDecompile("'b" + digs);
                                    c2->VpiSize(-1);
                                    c2->VpiValue(std::string(pv));
                                    c2->VpiConstType(vpiBinaryConst);
                                    c2->VpiParent(opr);
                                    c2->VpiLineNo(r2->VpiLineNo());
                                    c2->VpiColumnNo(r2->VpiColumnNo());
                                    c2->VpiEndLineNo(r2->VpiEndLineNo());
                                    c2->VpiEndColumnNo(r2->VpiEndColumnNo());
                                    o2 = c2;
                                    anyUnknown = true;
                                }
                                break;
                            }
                        }
                    // A PACKED-ARRAY typed param's ASSIGNMENT-PATTERN op ('{..})
                    // also carries a ts ref to the param's typespec (Surelog),
                    // even when all its operands are known literals. A
                    // CONCATENATION init ({a,b}) does NOT (PkgParamAsFunctionArg).
                    bool packedArrayOp =
                        ps.getType().getCanonicalType().isPackedArray() &&
                        opr->VpiOpType() == vpiAssignmentPatternOp;
                    // An UNPACKED-array param's elab-view pattern op also gets a
                    // ts ref, but its actual is a FRESH array_typespec (not the
                    // deferred/patched param typespec) — built inline here.
                    // ONLY when the array's leaf element is a simple integral
                    // (int X[1:0]='{0,1}): a STRUCT/UNION-element array
                    // ('{'{phase:1'b1}}) keeps its nested tagged-pattern ops and
                    // Surelog attaches NO typespec to the outer op.
                    // ...and only in an INSTANCE (top-module) view: the
                    // ELABORATED PACKAGE copy of an unpacked-array param
                    // carries NO typespec on its pattern op, exactly like the
                    // def package listing and the def-module import copy.
                    // Measured, one source: pkg `int unsigned PA[3]='{1,2,3}`
                    // + `parameter int X[2]='{0,1}` on a submodule — ts appears
                    // on topMod PA and topMod.u X only, on neither package view
                    // nor either def-module copy (Kmac KeccakRate).
                    // A REPLICATED pattern (`'{N{'1}}`, op 76) is the same
                    // elab object as the flat one: Surelog gives it the very
                    // same array_typespec ref (ParamArrayUnsizedPattern).
                    bool unpackedArrayOp = false;
                    if (!inPackage &&
                        ps.getType().getCanonicalType().kind ==
                            SymbolKind::FixedSizeUnpackedArrayType &&
                        (opr->VpiOpType() == vpiAssignmentPatternOp ||
                         opr->VpiOpType() == vpiMultiAssignmentPatternOp)) {
                        const Type* uleaf = &ps.getType().getCanonicalType();
                        while (uleaf->getCanonicalType().kind ==
                               SymbolKind::FixedSizeUnpackedArrayType)
                            uleaf = &uleaf->getCanonicalType()
                                         .as<FixedSizeUnpackedArrayType>()
                                         .elementType;
                        auto lk = uleaf->getCanonicalType().kind;
                        unpackedArrayOp =
                            lk != SymbolKind::PackedStructType &&
                            lk != SymbolKind::UnpackedStructType &&
                            lk != SymbolKind::PackedUnionType &&
                            lk != SymbolKind::UnpackedUnionType;
                        if (unpackedArrayOp && uleaf->isIntegral()) {
                            elabUnsizedPatternFold(
                                opr, (int32_t)uleaf->getBitWidth());
                            // A replication COUNT that is a bare param
                            // reference folds too — to that param's value at
                            // its own width, carrying a ts ref to a FRESH bare
                            // int_typespec (Surelog reduces the count before
                            // it writes the op).
                            if (opr->VpiOpType() ==
                                    vpiMultiAssignmentPatternOp &&
                                opr->Operands() && !opr->Operands()->empty()) {
                                auto& rp9 = stripImplicitConv(*init);
                                const Expression* cnt9 =
                                    rp9.kind == ExpressionKind::
                                                    ReplicatedAssignmentPattern
                                        ? &stripImplicitConv(
                                              rp9.as<
                                                     ReplicatedAssignmentPatternExpression>()
                                                  .count())
                                        : nullptr;
                                auto*& op09 = (*opr->Operands())[0];
                                if (cnt9 &&
                                    cnt9->kind == ExpressionKind::NamedValue &&
                                    op09->UhdmType() == UHDM::uhdmref_obj) {
                                    auto& cs9 = cnt9->as<NamedValueExpression>()
                                                    .symbol;
                                    ASTContext cx9(comp.getRoot(),
                                                   LookupLocation::max);
                                    ConstantValue cv9 = cx9.tryEval(*cnt9);
                                    if (cs9.kind == SymbolKind::Parameter &&
                                        cv9 && cv9.isInteger() &&
                                        !cv9.integer().hasUnknown()) {
                                        std::string cd9 =
                                            cv9.integer().toString(
                                                LiteralBase::Decimal, false);
                                        auto* cc9 = s.MakeConstant();
                                        cc9->VpiDecompile(cd9);
                                        cc9->VpiSize(
                                            (int32_t)cs9.as<ParameterSymbol>()
                                                .getType()
                                                .getBitWidth());
                                        cc9->VpiValue("UINT:" + cd9);
                                        cc9->VpiConstType(vpiUIntConst);
                                        cc9->VpiParent(opr);
                                        cc9->VpiLineNo(op09->VpiLineNo());
                                        cc9->VpiColumnNo(op09->VpiColumnNo());
                                        cc9->VpiEndLineNo(
                                            op09->VpiEndLineNo());
                                        cc9->VpiEndColumnNo(
                                            op09->VpiEndColumnNo());
                                        std::string cpx9 = prefix;
                                        if (cpx9.size() >= 2 &&
                                            cpx9.compare(cpx9.size() - 2, 2,
                                                         "::") == 0)
                                            cpx9.resize(cpx9.size() - 2);
                                        auto* crt9 = s.MakeRef_typespec();
                                        crt9->VpiFullName(cpx9);
                                        crt9->VpiParent(cc9);
                                        auto* cit9 = s.MakeInt_typespec();
                                        if (cs9.as<ParameterSymbol>()
                                                .getType()
                                                .isSigned())
                                            cit9->VpiSigned(true);
                                        crt9->Actual_typespec(cit9);
                                        cit9->VpiParent(crt9);
                                        cc9->Typespec(crt9);
                                        op09 = cc9;
                                    }
                                }
                            }
                        }
                    }
                    // A materialized IMPORTED vector-typedef param's elab
                    // CONCAT op also carries a ts ref (own clone pair).
                    bool importedConcatOp =
                        isImported && typedParam &&
                        ps.getType().getCanonicalType().isPackedArray() &&
                        opr->VpiOpType() == vpiConcatOp;
                    // An UNPACKED-struct typed param's elab assignment-pattern
                    // op carries a ts ref to the param's struct typespec
                    // (Surelog folds the elab default, tagging the outer op with
                    // the struct_typespec at the instance-scoped fullname). The
                    // PACKED-struct case is handled by the flat op75 branch
                    // above; here the op keeps its (reemitted) folded operands.
                    //
                    // ...but only when the value comes from the param's OWN
                    // DEFAULT. An unpacked-struct param OVERRIDDEN by a bare
                    // REFERENCE to another (package local)param — tif
                    // #(p::CFG_PER) — instead takes Surelog's VERBATIM copy of
                    // the referenced param's own Rhs tree: the outer pattern op
                    // carries NO typespec at all (only the nested member ops
                    // keep theirs), and it spans the REFERENCED param's
                    // initializer. Distinguisher: iface_struct_field_param_width
                    // (overridden by p::CFG_PER -> no outer ts, op@pkg-init
                    // span) vs iface_nested_param_field (plain `tif s()`,
                    // default p::CFG_DEF -> outer ts at the default span).
                    // ...and only for a QUALIFIED (`pkg::NAME`) actual — an
                    // UNQUALIFIED one re-emits at the instance and took the
                    // flat op75 branch above (unpStructOvRef9), which already
                    // owns this op's span and typespec.
                    bool structRefOv = false;
                    if (overridden && !unpStructOvRef9) {
                        auto& ov0 = stripImplicitConv(*init);
                        structRefOv =
                            ov0.kind == ExpressionKind::NamedValue &&
                            ov0.as<NamedValueExpression>().symbol.kind ==
                                SymbolKind::Parameter;
                    }
                    bool structOp =
                        !inPackage && !structRefOv && !unpStructOvRef9 &&
                        ps.getType().getCanonicalType().kind ==
                            SymbolKind::UnpackedStructType &&
                        opr->VpiOpType() == vpiAssignmentPatternOp;
                    // Same rule for the SPAN: the copied tree keeps the
                    // referenced param's initializer source range.
                    if (structRefOv &&
                        ps.getType().getCanonicalType().kind ==
                            SymbolKind::UnpackedStructType &&
                        opr->VpiOpType() == vpiAssignmentPatternOp) {
                        auto& ov1 = stripImplicitConv(*init);
                        if (auto* rin = ov1.as<NamedValueExpression>()
                                            .symbol.as<ParameterSymbol>()
                                            .getInitializer())
                            setLoc(opr, rin->sourceRange);
                    }
                    if ((anyUnknown || packedArrayOp || unpackedArrayOp ||
                         importedConcatOp || structOp || lazyTernary9) &&
                        !(opr->Typespec() &&
                          opr->Typespec()->Actual_typespec())) {
                        auto* rt = s.MakeRef_typespec();
                        std::string tsPrefix = prefix;
                        if (tsPrefix.size() >= 2 &&
                            tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                            tsPrefix.resize(tsPrefix.size() - 2);
                        rt->VpiFullName(tsPrefix);
                        rt->VpiParent(opr);
                        opr->Typespec(rt);
                        if (unpackedArrayOp)
                            // The OP's clone names its element ref by the
                            // holding ref_typespec's own fullname (the
                            // instance prefix), not the parameter's.
                            rt->Actual_typespec(makeUnpackedArrayParamTs(
                                ps, tsPrefix, rt, nullptr, true, tsPrefix));
                        else
                            rhsRt = rt;
                    }
                    // Record the elab pattern op so a gen-scope localparam that
                    // element-selects this array param can adopt its operand.
                    if (unpackedArrayOp)
                        elabArrayPatternOp[&ps] = opr;
                }
            }
            if (rhs) {
                pa->Rhs(rhs);
                paramRhsObj[&member] = rhs;
                // A DEF-view param_assign is a DEEP-CLONED object at
                // elaboration, so Surelog re-parents its Rhs at the
                // param_assign. Our fold/emit fallback leaves a bare constant
                // for a MODULE param whose default is a pkg-param ref
                // (P = X, P_INSTANCE = P_PKG). Package-param Rhs constants
                // (which are SHARED into reading cont_assigns and re-parented
                // there) and constants some later arm still parents are left
                // alone: only claim a still-bare DEF-view MODULE Rhs here.
                if (!topView && !inPackage &&
                    rhs->UhdmType() == UHDM::uhdmconstant && !rhs->VpiParent())
                    rhs->VpiParent(pa);
                // An IMPORTED param's def-view copy is a materialized (already
                // resolved) param: its bare-decimal RHS folds to the type width
                // (int -> 32), exactly like the elab view — NOT the package
                // def's raw 64-bit bare decimal (Surelog sizes the copy, not
                // the source literal).
                if (isImported && !topView && typedParam &&
                    rhs->UhdmType() == UHDM::uhdmconstant)
                    ((UHDM::constant*)rhs)
                        ->VpiSize((int32_t)ps.getType().getBitWidth());
                // The ELAB (top-view) MODULE copy of a TYPED param re-emits
                // the param's RESOLVED VALUE, so a BASED-DECIMAL default
                // loses its base form: 2'd1 becomes a plain int constant
                // (INT:1, decompile "1"). Other bases keep their source
                // encoding; the DEF view AND the package views keep DEC
                // (Surelog; cs_registers CSR_MISA_MXL / ibex_pkg,
                // rp32_r5p_mouse ST0-ST3).
                if (topView && (typedParam || (decBasedInit && !wantTs)) &&
                    !inPackage && rhs->UhdmType() == UHDM::uhdmconstant) {
                    auto* rc9 = (UHDM::constant*)rhs;
                    std::string_view v9 = rc9->VpiValue();
                    if (v9.rfind("DEC:", 0) == 0) {
                        std::string dg9(v9.substr(4));
                        rc9->VpiValue("INT:" + dg9);
                        rc9->VpiConstType(vpiIntConst);
                        rc9->VpiDecompile(dg9);
                    }
                }
                if (inPackage && !topView && rhs->UhdmType() == UHDM::uhdmconstant)
                    pkgParamConst[&member] = (UHDM::constant*)rhs;
                if (inPackage && !topView)
                    pkgParamObj[&member] = up;
                // Registered per VIEW: the top-view pass overwrites with its
                // elab Rhs so view-local refs chain within their own view.
                if (inPackage)
                    pkgParamDefRhs[&member] = rhs;
                // ELAB pkg typed-param whose init chain (through same-pkg
                // param refs) lands on an ENUM VALUE folds in the enum
                // literal's source HEX form (8'hCC / HEX:CC) — Surelog.
                if (topView && (inPackage || isImported) && typedParam &&
                    rhs->UhdmType() == UHDM::uhdmconstant)
                    if (!enumOriginHexRecode((UHDM::constant*)rhs, init))
                        // ...and the same chaining for a plain param
                        // reference that lands on a BASED literal.
                        paramOriginBaseRecode((UHDM::constant*)rhs, init);
                // Literal inits of typed params carry the param typespec
                // (patched late together with the param ref).
                // Unknown ('x/'z) defaults: uppercase digits and a BARE
                // (never-patched) ts ref on the Rhs constant.
                if (rhs->UhdmType() == UHDM::uhdmconstant) {
                    auto* rc = (UHDM::constant*)rhs;
                    std::string_view v0 = rc->VpiValue();
                    if (v0.rfind("BIN:", 0) == 0 &&
                        (v0.find_first_of("xXzZ") != std::string_view::npos)) {
                        // (emitExpr already uppercased the value/decompile.)
                        // Elab-view unbased-unsized 'x/'z decompiles with an
                        // explicit 'b base ('x -> 'bX); the def view keeps the
                        // bare 'X (Surelog quirk).
                        if (topView &&
                            stripImplicitConv(*init).kind ==
                                ExpressionKind::UnbasedUnsizedIntegerLiteral)
                            rc->VpiDecompile("'b" + std::string(v0.substr(4)));
                        if (!topView && !wantTs && !rc->Typespec()) {
                            auto* brt = s.MakeRef_typespec();
                            std::string tsPrefix = prefix;
                            if (tsPrefix.size() >= 2 &&
                                tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                                tsPrefix.resize(tsPrefix.size() - 2);
                            brt->VpiFullName(tsPrefix);
                            brt->VpiParent(rc);
                            rc->Typespec(brt);
                        }
                    }
                    // A DEC-BASED untyped default (4'd0) keeps its source form
                    // in the DEF view but its ts ref is DANGLING (fullname
                    // only, never patched) — mriscv MEMORY_INTERFACE.
                    if (decBasedInit && !typedParam && !topView && !wantTs &&
                        !rc->Typespec()) {
                        auto* brt = s.MakeRef_typespec();
                        std::string tsPrefix = prefix;
                        if (tsPrefix.size() >= 2 &&
                            tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                            tsPrefix.resize(tsPrefix.size() - 2);
                        brt->VpiFullName(tsPrefix);
                        brt->VpiParent(rc);
                        rc->Typespec(brt);
                    }
                }
                // Elab-view string constants decompile WITHOUT quotes (the
                // def view keeps them).
                if (topView && rhs->UhdmType() == UHDM::uhdmconstant &&
                    ((UHDM::constant*)rhs)->VpiConstType() == vpiStringConst) {
                    auto* rc = (UHDM::constant*)rhs;
                    std::string d(rc->VpiDecompile());
                    if (d.size() >= 2 && d.front() == '"' && d.back() == '"')
                        rc->VpiDecompile(d.substr(1, d.size() - 2));
                }
                if (auto& sik = stripImplicitConv(*init);
                    // The ELAB MULTIDIM-vector literal Rhs carries no ts ref
                    // (elabMultiDimNoTs9, measured above). This site used to
                    // spell the same test with an extra `isImported`; the
                    // import was never the discriminator.
                    !elabMultiDimNoTs9 &&
                    wantTs && rhs->UhdmType() == UHDM::uhdmconstant &&
                    (sik.kind == ExpressionKind::IntegerLiteral ||
                     sik.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral ||
                     sik.kind == ExpressionKind::RealLiteral ||
                     sik.kind == ExpressionKind::StringLiteral ||
                     // A TYPED param folded from a PKG-param ref carries the
                     // ts too (Surelog).
                     (typedParam && sik.kind == ExpressionKind::NamedValue &&
                      sik.as<NamedValueExpression>().symbol.getParentScope() &&
                      sik.as<NamedValueExpression>()
                              .symbol.getParentScope()
                              ->asSymbol()
                              .kind == SymbolKind::Package) ||
                     // A DEF-view SYSTEM-CALL initializer that constant-folds
                     // ($bits over a fixed-width signal) carries the ts ref
                     // too: Surelog's definition compile stores the folded
                     // value against the parameter's OWN declared typespec,
                     // the same object the parameter's ref points at. Only
                     // the folding calls reach here — $clog2 of a literal
                     // stays a sys_func_call in the def view and never
                     // becomes a constant (BitsHierPath, PackDataType).
                     (!topView && !inPackage && !isImported &&
                      sik.kind == ExpressionKind::Call &&
                      sik.as<CallExpression>().isSystemCall()))) {
                    auto* rt = s.MakeRef_typespec();
                    std::string tsPrefix = prefix;
                    if (tsPrefix.size() >= 2 &&
                        tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                        tsPrefix.resize(tsPrefix.size() - 2);
                    // An OVERRIDDEN vector-typedef param's elab Rhs ts ref is
                    // NAMELESS (Surelog).
                    bool vecAliasOv9 =
                        overridden && ps.getDeclaredType() &&
                        ps.getDeclaredType()->getType().kind ==
                            SymbolKind::TypeAlias &&
                        ps.getType().getCanonicalType().kind ==
                            SymbolKind::PackedArrayType;
                    if (!vecAliasOv9)
                        rt->VpiFullName(tsPrefix);
                    rt->VpiParent((UHDM::constant*)rhs);
                    ((UHDM::constant*)rhs)->Typespec(rt);
                    rhsRt = rt;
                }
                // A TYPED module param whose default is a BARE reference to a
                // materialized package parameter Y (parameter logic[..] P = X):
                // in the ELAB view Surelog does NOT re-fold — it CLONES Y's
                // folded constant (Y's value/encoding/size), parents it at Y's
                // param_assign, and gives its ts ref Y's package-located
                // typespec (NOT a fresh bare recompute). ParameterFromPkg*.
                if (topView && !inPackage && typedParam &&
                    rhs->UhdmType() == UHDM::uhdmconstant) {
                    auto& sref = stripImplicitConv(*init);
                    if (sref.kind == ExpressionKind::NamedValue) {
                        auto& ysym =
                            sref.as<NamedValueExpression>().symbol;
                        if (ysym.kind == SymbolKind::Parameter &&
                            ysym.getParentScope() &&
                            ysym.getParentScope()->asSymbol().kind ==
                                SymbolKind::Package) {
                            UHDM::param_assign* ypa = nullptr;
                            UHDM::constant* yc = nullptr;
                            for (auto& [msym, rec] : pkgRefSrc)
                                if (msym->location == ysym.location &&
                                    msym->name == ysym.name) {
                                    ypa = rec.first;
                                    yc = rec.second;
                                    break;
                                }
                            if (ypa && yc && rhsRt) {
                                auto* rc = (UHDM::constant*)rhs;
                                rc->VpiValue(std::string(yc->VpiValue()));
                                rc->VpiConstType(yc->VpiConstType());
                                rc->VpiSize(yc->VpiSize());
                                rc->VpiDecompile(
                                    std::string(yc->VpiDecompile()));
                                rc->VpiParent(ypa);
                                auto* yts = makeParamTs(
                                    ysym.as<ParameterSymbol>(), true);
                                if (ysym.getParentScope())
                                    if (auto pit = pkgDefMap.find(
                                            &ysym.getParentScope()
                                                 ->asSymbol());
                                        pit != pkgDefMap.end())
                                        yts->Instance(
                                            (UHDM::instance*)pit->second);
                                rhsRt->Actual_typespec(yts);
                                pkgRefFold = true;
                            }
                        }
                    }
                }
            }
            if (rhs && rhs->UhdmType() == UHDM::uhdmconstant)
                rhsConstForMap = (UHDM::constant*)rhs;
            // DEFPARAM'd param (value differs from the declared-default
            // eval, but the initializer is still the default): Surelog keeps
            // the DEFAULT value on the parameter and puts the DEFPARAM value
            // in the param_assign Rhs (hierdefparam: UINT:44 / Rhs 42).
            if (!inPackage && !overridden && hasDefault && defaultInit &&
                rhs && rhs->UhdmType() == UHDM::uhdmconstant) {
                auto& cvd9 = ps.getValue();
                if (cvd9.isInteger() && !cvd9.integer().hasUnknown() &&
                    ps.getType().getCanonicalType().isIntegral()) {
                ASTContext dctx9(body, LookupLocation::max);
                auto dv9 = dctx9.tryEval(*defaultInit);
                if (dv9 && dv9.isInteger() &&
                    !dv9.integer().hasUnknown() &&
                    dv9.integer() != cvd9.integer()) {
                    std::string cd9 = cvd9.integer().toString(
                        LiteralBase::Decimal, false);
                    std::string dd9 = dv9.integer().toString(
                        LiteralBase::Decimal, false);
                    if (topView) {
                        auto* rc9 = (UHDM::constant*)rhs;
                        rc9->VpiDecompile(cd9);
                        rc9->VpiValue("UINT:" + cd9);
                    }
                    up->VpiValue("UINT:" + dd9);
                }
                }
            }
        }
        // ELAB view: a param_assign Rhs that SURVIVES as an operation carries a
        // ts ref to the parameter's own elab typespec.  Only the r9c7 no-fold
        // family reaches this shape for a non-vector integral atom (an
        // assignment pattern against int/byte/shortint/longint, and the
        // arithmetic that reads one), and Surelog stamps every such reduced
        // expression — the op75 pattern itself AND the op24 that consumes it.
        // Aggregates and packed vectors bind their op ts through their own
        // clone paths above (mintParamOpClones / the vector-typedef arm), so
        // they are excluded here.  A MATERIALIZED IMPORT copy is excluded too:
        // its elab pattern op carries NO ts ref (probe: p1::PKGP imported into
        // m2 keeps a bare op75 in m2's elab view, while m1's own LOCP gets the
        // ref) — the stamp belongs to the module that DECLARED the param.
        // Probe: `int PAT = '{default:1}` / `int USE = PAT + 2` in a module
        // and a package, all four views.
        auto* paRhs9 = pa->Rhs();
        if (topView && !inPackage && !isImported && !rhsRt && paRhs9 &&
            paRhs9->UhdmType() == UHDM::uhdmoperation &&
            !((UHDM::operation*)paRhs9)->Typespec() && [&] {
                auto& ct9 = ps.getType().getCanonicalType();
                return ct9.isIntegral() &&
                       ct9.kind != SymbolKind::PackedArrayType &&
                       ct9.kind != SymbolKind::PackedStructType &&
                       ct9.kind != SymbolKind::PackedUnionType;
            }()) {
            auto* rtOp9 = s.MakeRef_typespec();
            rtOp9->VpiFullName(prefix);
            rtOp9->VpiParent(paRhs9);
            ((UHDM::operation*)paRhs9)->Typespec(rtOp9);
            rhsRt = rtOp9;
        }
        passigns->push_back(pa);
        // DEF-view aggregate-typedef params (typedef struct/union/enum T; then
        // parameter T P) defer their ts binding past emitTypedefs so they can
        // SHARE the named typedef typespec (drainDefParamTs).
        bool deferAggTs = false;
        if (auto dAgg = ps.getDeclaredType()) {
            auto& dtAgg = dAgg->getType();
            auto ckAgg = dtAgg.getCanonicalType().kind;
            deferAggTs = dtAgg.kind == SymbolKind::TypeAlias &&
                         (ckAgg == SymbolKind::PackedStructType ||
                          ckAgg == SymbolKind::PackedUnionType ||
                          ckAgg == SymbolKind::EnumType ||
                          // A local VECTOR typedef param defers too so its DEF
                          // ts SHARES the typedef's logic_typespec (drained
                          // past emitTypedefs) instead of the int_typespec
                          // fallback; the ELAB view keeps its aliased clone.
                          (ckAgg == SymbolKind::PackedArrayType &&
                           dtAgg.getCanonicalType().isIntegral()));
        }
        if (prt) {
            if (topView && !inPackage) {
                // A pkg-ref clone already bound its Rhs ts to the pkg-located
                // typespec; keep the deferred patch off that ref.
                pendingParamTs.push_back(
                    {&ps, up, prt, pkgRefFold ? nullptr : rhsRt, typedParam});
            }
            else if (deferAggTs) {
                pendingDefParamTs.push_back({&ps, up, prt, rhsRt, typedParam, m,
                                             &member, di, inPackage,
                                             joinPath(prefix, ps.name)});
                // The def-Lhs parameter clone drains its OWN ts clone chain.
                if (upLhs9 && prtLhs9)
                    pendingDefParamTs.push_back(
                        {&ps, upLhs9, prtLhs9, nullptr, typedParam, m, &member,
                         nullptr, inPackage, joinPath(prefix, ps.name)});
            }
            else {
                // $bits(SIGNAL) bounds scope their refs through the param
                // and bind this view's nets; currentScope lets a FIXED-width
                // $bits fold even in the def pre-pass.
                std::string savedPfx2 = syntaxRefPrefix;
                const Scope* savedCS = currentScope;
                syntaxRefPrefix = joinPath(prefix, ps.name);
                if (!currentScope)
                    currentScope = ps.getParentScope();
                auto* its = makeParamTs(ps, typedParam);
                stampCastSizeParamTs(ps, up, its);
                currentScope = savedCS;
                syntaxRefPrefix = savedPfx2;
                bool untypedImport = !inPackage && isImported && !typedParam;
                // Expose a param DECLARED in this package by name: a later
                // paren-param size cast in the same package REUSES this very
                // object as its cast typespec (pkgScopeParamTs).
                if (inPackage && !isImported && its &&
                    its->UhdmType() == UHDM::uhdmint_typespec)
                    pkgScopeParamTs[std::string(ps.name)] = {its, up};
                if (inPackage && typedParam)
                    stampPkgTsInst(its);
                else if (!inPackage && isImported && ps.getParentScope()) {
                    // An imported param's typespec is INSTANCED at its package —
                    // but ONLY for TYPED imports. An UNTYPED import (parameter
                    // W = 48) keeps its int_typespec Instance-less, exactly as
                    // it is in its home package (Surelog; fail_detect_width).
                    // ...and the package it reaches is the ELABORATED (top)
                    // one — Surelog's cross-view instance links land on the
                    // elab package, and UHDM's Compare follows
                    // typespec->vpiInstance, so binding the DEF view drags the
                    // UNELABORATED param constants into the comparison
                    // (cs_registers: 64-bit def vs 32-bit elab pkg params).
                    if (typedParam) {
                        const void* home3 = &ps.getParentScope()->asSymbol();
                        if (auto tit = pkgTopMap.find(home3);
                            tit != pkgTopMap.end())
                            its->Instance((UHDM::instance*)tit->second);
                        else if (auto pit = pkgDefMap.find(home3);
                                 pit != pkgDefMap.end()) {
                            its->Instance((UHDM::instance*)pit->second);
                            pkgImportTsTopFixups.emplace_back(its, home3);
                        }
                    }
                    // Remember it so a def-view fold that READS this imported
                    // param can carry a ref_typespec to it.
                    importedParamDefTs[&ps] = its;
                }
                if (di)
                    di->paramTs[&member] = its;
                // Remember the DEF param's own ts ref: a cont-assign function
                // call taking this param as a direct actual REBINDS it to the
                // formal's typespec (Surelog).
                if (di && !inPackage)
                    defParamTsRef[&member] = prt;
                if (rhsRt) {
                    // An untyped import's Rhs constant ref binds its OWN fresh
                    // int_typespec (Surelog builds a distinct typespec per ref,
                    // not the shared param ts).
                    if (!inPackage && isImported) {
                        std::string savedPfxR = syntaxRefPrefix;
                        syntaxRefPrefix = joinPath(prefix, ps.name);
                        auto* itsR = makeParamTs(ps, typedParam);
                        syntaxRefPrefix = savedPfxR;
                        itsR->Instance(its->Instance());
                        itsR->VpiParent(rhsRt);
                        rhsRt->Actual_typespec(itsR);
                    }
                    else
                        rhsRt->Actual_typespec(its);
                }
                prt->Actual_typespec(its);
                // An untyped import's param-ref int_typespec is parented at its
                // ref_typespec (Surelog); typed/ranged params handle this via the
                // VpiParent(up) rule below.
                if (untypedImport && !its->VpiParent())
                    its->VpiParent(prt);
                if (prtLhs9 && !prtLhs9->Actual_typespec()) {
                    // The Lhs clone gets its OWN fresh ts (pkg-Instanced,
                    // parented at the clone's ref) — Surelog.
                    std::string savedPfxL = syntaxRefPrefix;
                    syntaxRefPrefix = joinPath(prefix, ps.name);
                    auto* itsL = makeParamTs(ps, typedParam);
                    syntaxRefPrefix = savedPfxL;
                    // ...at the ELABORATED home package, like the param's own
                    // ts above: Compare follows vpiInstance, so a def-view
                    // link pulls the unelaborated package in behind it.
                    if (!inPackage && isImported && typedParam && ps.getParentScope()) {
                        const void* homeL = &ps.getParentScope()->asSymbol();
                        if (auto titL = pkgTopMap.find(homeL);
                            titL != pkgTopMap.end())
                            itsL->Instance((UHDM::instance*)titL->second);
                        else if (auto pitL = pkgDefMap.find(homeL);
                                 pitL != pkgDefMap.end()) {
                            itsL->Instance((UHDM::instance*)pitL->second);
                            pkgImportTsTopFixups.emplace_back(itsL, homeL);
                        }
                    }
                    itsL->VpiParent(prtLhs9);
                    prtLhs9->Actual_typespec(itsL);
                }
                bool signedImplicit = false;
                if (auto d0 = ps.getDeclaredType())
                    if (auto t0 = d0->getTypeSyntax())
                        if (t0->kind == syntax::SyntaxKind::ImplicitType)
                            signedImplicit =
                                t0->as<syntax::ImplicitTypeSyntax>().signing.valid() &&
                                t0->as<syntax::ImplicitTypeSyntax>().dimensions.empty();
                // A MATERIALIZED IMPORT's typespec parents at its
                // ref_typespec, not the parameter (that form is for the
                // param's HOME scope) — Surelog.
                if (isImported && !inPackage) {
                    if (!its->VpiParent())
                        its->VpiParent(prt);
                }
                else if (typedParam || isRangedUntypedParam(ps) ||
                         signedImplicit)
                    its->VpiParent(up);
            }
        }
        // Record this param's {param_assign, Rhs constant} so a later module
        // param whose default is a bare ref to it can clone the fold.
        if (rhsConstForMap)
            pkgRefSrc[&member] = {pa, rhsConstForMap};
        // ...and the DEF-view constant separately: a struct-pattern param
        // declared LATER in the same module SHARES it as its member setter
        // (r9psc rule 1).
        if (!topView && !inPackage && rhsConstForMap)
            defParamRhsConst[&member] = rhsConstForMap;
        // A DEGENERATE unbased fill ('x/'z) reaches its BIN Rhs constant via the
        // fallback emitExpr path (not the fold arm above), so it is recorded
        // here: Surelog shares this SAME object into the reading cont-assign.
        // ('0 was already recorded in the fold arm; '1/UINT is excluded.)
        if (topView && rhsConstForMap && !unbasedSharedPaConst.count(&ps)) {
            if (auto* pinU = ps.getInitializer()) {
                auto& siU = stripImplicitConv(*pinU);
                if (siU.kind ==
                    ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                    slang::logic_t bU =
                        siU.as<UnbasedUnsizedIntegerLiteral>()
                            .getLiteralValue();
                    if (bU.isUnknown() || bU.value == 0)
                        unbasedSharedPaConst[&ps] = rhsConstForMap;
                }
            }
        }
    }
    flushPaTag9();
    // Type parameters (parameter type T = ...) emit as UHDM type_parameter
    // objects under vpiParameter. Surelog locates the DEF-view type_parameter
    // at its name token and leaves the ELAB-view one unlocated (instance type
    // params fold to id-only). The typespec Actual is the resolved default
    // (def) or override (elab) type, built from the param's own targetType.
    for (auto& member0 : body.members()) {
        if (member0.kind != SymbolKind::TypeParameter)
            continue;
        auto& tps = member0.as<TypeParameterSymbol>();
        auto* tp = s.MakeType_parameter();
        tp->VpiName(tps.name);
        tp->VpiFullName(joinPath(prefix, tps.name));
        tp->VpiParent(m);
        if (!topView)
            setLoc(tp, SourceRange(tps.location, tps.location + tps.name.size()));
        auto* rt = s.MakeRef_typespec();
        rt->VpiParent(tp);
        rt->VpiFullName(joinPath(prefix, tps.name));
        std::string savedPfx = syntaxRefPrefix;
        const Scope* savedCS = currentScope;
        syntaxRefPrefix = joinPath(prefix, tps.name);
        if (!currentScope)
            currentScope = tps.getParentScope();
        UHDM::typespec* its = nullptr;
        // The def view shows the DECLARATION default; the elab view shows this
        // instance's resolved (possibly overridden) type. The borrowed def-view
        // instance body may carry an override AND its cloned type-param symbol
        // can lose its declarator syntax, so read the default straight from the
        // module's parameter-port-list syntax.
        const syntax::DataTypeSyntax* defTypeSyn = nullptr;
        if (!topView) {
            const syntax::SyntaxNode* msyn =
                tps.getParentScope() ? tps.getParentScope()->asSymbol().getSyntax()
                                     : nullptr;
            if (auto* mds = msyn ? msyn->as_if<syntax::ModuleDeclarationSyntax>()
                                 : nullptr) {
                if (auto* ppl = mds->header->parameters)
                    for (auto* decl : ppl->declarations)
                        if (auto* tpd = decl->as_if<
                                syntax::TypeParameterDeclarationSyntax>())
                            for (auto* d : tpd->declarators)
                                if (d->name.valueText() == tps.name && d->assignment)
                                    defTypeSyn = d->assignment->type;
            }
        }
        if (defTypeSyn) {
            its = makeTypeParamDefaultTs(*defTypeSyn, body);
            // Surelog parents the def-view default typespec at the type param
            // (it is shared with the port typedefs via ref_typespec).
            if (its)
                its->VpiParent(tp);
        }
        else if (topView &&
                 tps.targetType.getType().kind == SymbolKind::TypeAlias) {
            // An elab type_parameter resolved to a TYPEDEF carries its OWN
            // bare-named CLONE of the typedef ts (parented at the type
            // param), not the shared module typedef object (Surelog).
            auto& ta9 = tps.targetType.getType().as<TypeAliasType>();
            const syntax::SyntaxNode* tgt9 = nullptr;
            if (auto asyn9 = ta9.getSyntax();
                asyn9 && asyn9->kind == syntax::SyntaxKind::TypedefDeclaration)
                tgt9 = asyn9->as<syntax::TypedefDeclarationSyntax>().type;
            // ...unless the override names a PACKAGE typedef: Surelog resolves
            // `pkg::T` to the object that package already built (qualified
            // name, package vpiInstance, typedef span) and both the type
            // parameter and every signal it types point at that ONE object
            // (TypeParamOverride). Only a MODULE-local typedef gets a clone.
            if (auto* hsc9 = ta9.getParentScope();
                hsc9 && hsc9->asSymbol().kind == SymbolKind::Package) {
                if (auto t9 = pkgTopTypedefTs.find((const void*)&ta9);
                    t9 != pkgTopTypedefTs.end() && t9->second)
                    its = t9->second;
                else if (auto d9 = typedefTs.find((const Symbol*)&ta9);
                         d9 != typedefTs.end())
                    its = d9->second;
            }
            bool sharedPkgTs9 = its != nullptr;
            if (!its && ta9.getCanonicalType().kind == SymbolKind::EnumType)
                its = (UHDM::typespec*)buildEnumTs(
                    ta9.getCanonicalType().as<EnumType>(), tgt9,
                    std::string(ta9.name));
            else if (!its) {
                bypassTypedefShare = true;
                its = makeTypespec(ta9, tgt9);
                bypassTypedefShare = false;
            }
            if (its && !sharedPkgTs9) {
                its->VpiName(ta9.name);
                its->VpiParent(tp);
            }
            else if (!its)
                its = makeTypespec(tps);
        }
        else
            its = makeTypespec(tps);
        currentScope = savedCS;
        syntaxRefPrefix = savedPfx;
        if (its)
            rt->Actual_typespec(its);
        tp->Typespec(rt);
        // Remember the elab-view resolved typespec so the port variable typed
        // by this type param can SHARE it (Surelog uses one object).
        if (topView && its)
            typeParamElabTs[&tps] = its;
        // Remember the def-view DEFAULT typespec so every type-param-typed
        // port's vpiTypedef (all views) can SHARE this one object (Surelog).
        if (!topView && its && defTypeSyn &&
            body.asSymbol().kind == SymbolKind::InstanceBody)
            typeParamDefaultTs[{(const void*)&body.asSymbol()
                                    .as<InstanceBodySymbol>()
                                    .getDefinition(),
                                std::string(tps.name)}] = its;
        params->push_back(tp);
    }
    // MATERIALIZED imported params: the Parameters vec and the Param_assigns
    // vec share the IMPORT-ITEM key and differ only in the tie-break INSIDE
    // one item — Surelog's importPackage walks the package's
    // getParameterMap() (std::map, NAME order) for Parameters and its
    // getParamAssignVec() (a vector, DECLARATION order) for Param_assigns.
    // An EXPLICIT `import p::N` item contributes one param, so the tie-break
    // is invisible there and only the item order shows (Kmac). A WILDCARD
    // item contributes the whole package, so the two vectors genuinely
    // disagree (simple_package: Parameters ADDR_WIDTH,DATA_WIDTH vs
    // Param_assigns DATA_WIDTH,ADDR_WIDTH).
    // paramSyms is already in (item, declaration) order, so the materialized
    // slots below are grouped by item; re-sorting them by (item, name) keeps
    // the groups and only reorders within each.
    {
        std::map<std::string_view, size_t> matItem9;
        for (auto* ps9 : paramSyms)
            if (ps9->getParentScope() != &body) {
                size_t it9 = 0;
                if (auto r9 = impRank9.find(ps9); r9 != impRank9.end())
                    it9 = r9->second.first;
                matItem9.emplace(ps9->name, it9);
            }
        if (!matItem9.empty()) {
            std::vector<size_t> idx9;
            std::vector<UHDM::any*> mats9;
            for (size_t i9 = 0; i9 < params->size(); i9++)
                if ((*params)[i9]->UhdmType() == UHDM::uhdmparameter &&
                    matItem9.count(
                        ((UHDM::parameter*)(*params)[i9])->VpiName())) {
                    idx9.push_back(i9);
                    mats9.push_back((*params)[i9]);
                }
            std::stable_sort(
                mats9.begin(), mats9.end(),
                [&](UHDM::any* a, UHDM::any* b) {
                    std::string_view na = ((UHDM::parameter*)a)->VpiName();
                    std::string_view nb = ((UHDM::parameter*)b)->VpiName();
                    size_t ia = matItem9[na], ib = matItem9[nb];
                    if (ia != ib)
                        return ia < ib;
                    return na < nb;
                });
            for (size_t k9 = 0; k9 < idx9.size(); k9++)
                (*params)[idx9[k9]] = mats9[k9];
        }
    }
    // The ELABORATED instance assigns its PARAMETER-PORT-LIST params first
    // (they are resolved from the instantiation) and the rest — materialized
    // imported params included — after, in source-location order. BODY params
    // stay in plain location order in both views, so an imported param
    // declared earlier still leads (ParameterFromPkgInNestedModule) — Surelog
    // (ParameterFromPkgOnParameterPortList).
    //
    // ...EXCEPT that an IMPLICIT (keyword-less) port param is re-created LAST,
    // behind the body params. rp32_r5p_mdu's elab view lists M8@37, M1@39
    // (body localparams) and only then XLEN@23 (the sole port-list param),
    // while its Parameters vec and its DEF view both keep declaration order.
    // Decoded by scanning EVERY golden in both corpora for a Param_assigns
    // vector out of source order (tools/probe/w4rord.cpp) and correlating the
    // hits with the port-list syntax:
    //   demote, keyword-less  — r5p_mdu `#( int unsigned XLEN = 32 )`;
    //                           r5p_hamster `#( isa_ext_t XTEN = ..., ... )`
    //                           (NOP@309 leads all 8 port params); tcb_gpio
    //                           `#( int unsigned GW = 32 )` (DLY@39 before
    //                           GW@25, in the elaborated instance).
    //   keep,   keyword-ful   — r5p_mouse (3 `localparam` + 7 `parameter`
    //                           entries, body localparams from line 57),
    //                           LocalParam's `parameter invert = 0`,
    //                           ParameterOfSizeOfParametrizedPortInSubmodule's
    //                           `parameter int X = 15`, and every other
    //                           module in either corpus.
    // Nothing else in either corpus demotes: the remaining order anomalies are
    // macro-expansion locations (BlackConst's `easy` reports the macro's
    // line 12) or the materialized-imported-package pattern above.
    if (topView && !inPackage && !portPa9.empty() &&
        portPa9.size() < passigns->size()) {
        // Rank 0: port-list pa's (resolved at instantiation, first). Rank 1:
        // body pa's. Rank 2: IMPLICIT (keyword-less) module port-list pa's —
        // the late substitution re-creates them last. An EXPLICIT
        // `parameter`/`localparam` entry keeps its port-first slot whatever
        // its override (LocalParam's literal no-op .invert(0) keeps it with
        // the Overriden stamp; ParameterOfSizeOfParametrizedPortInSubmodule's
        // value-changing X(5) likewise). Interfaces keep port-first too.
        // (This replaces a no-op-NAME-reference-override predicate calibrated
        // on jeras_tcb_gpio alone: tcb_gpio's demoted GW is keyword-less, so
        // the override form was never the distinguisher — the corpus scan
        // above finds no keyword-ful demotion anywhere in either corpus.)
        auto implicitPort9 = [&](UHDM::param_assign* pa9) -> bool {
            if (m->UhdmType() != UHDM::uhdmmodule_inst || !pa9->Lhs())
                return false;
            for (auto& mb9 : body.members()) {
                if (mb9.kind != SymbolKind::Parameter ||
                    mb9.name != std::string_view(pa9->Lhs()->VpiName()))
                    continue;
                return isImplicitPortParam(mb9.as<ParameterSymbol>());
            }
            return false;
        };
        auto rank9 = [&](UHDM::param_assign* pa9) -> int {
            if (!portPa9.count(pa9))
                return 1;
            if (implicitPort9(pa9))
                return 2;
            return 0;
        };
        std::stable_sort(passigns->begin(), passigns->end(),
                         [&](UHDM::param_assign* a9, UHDM::param_assign* b9) {
                             return rank9(a9) < rank9(b9);
                         });
    }
    // -P command-line overrides: re-stamp the ELAB Rhs with fromString's own
    // constant (see cliOverrideConst) and drop its typespec -- Surelog's
    // cmdline path stores a raw Value that never sees the declared type.
    for (auto& [pa9, name9] : cliRestamp) {
        auto* src9 = cliOverrideConst(cliParams.find(name9)->second);
        auto* rhs9 = pa9->Rhs();
        if (rhs9 && rhs9->UhdmType() == UHDM::uhdmconstant) {
            auto* rc9 = (UHDM::constant*)rhs9;
            rc9->VpiConstType(src9->VpiConstType());
            rc9->VpiSize(src9->VpiSize());
            rc9->VpiValue(std::string(src9->VpiValue()));
            rc9->VpiDecompile(std::string(src9->VpiDecompile()));
            rc9->Typespec(nullptr);
        }
        else {
            src9->VpiParent(pa9);
            if (rhs9) {
                src9->VpiFile(std::string(rhs9->VpiFile()));
                src9->VpiLineNo(rhs9->VpiLineNo());
                src9->VpiColumnNo(rhs9->VpiColumnNo());
                src9->VpiEndLineNo(rhs9->VpiEndLineNo());
                src9->VpiEndColumnNo(rhs9->VpiEndColumnNo());
            }
            pa9->Rhs(src9);
        }
    }
    if (!params->empty())
        m->Parameters(params);
    if (!passigns->empty())
        m->Param_assigns(passigns);
}

UHDM::array_typespec* UhdmExporter::makeUnpackedArrayParamTs(
    const ParameterSymbol& ps, const std::string& elemFull,
    UHDM::BaseClass* parent, UHDM::VectorOfrange* sharedRanges,
    bool elabClone, const std::string& dimRefPrefix) {
    const Type* leaf = &ps.getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
        leaf = &leaf->getCanonicalType().as<FixedSizeUnpackedArrayType>().elementType;
    // Element typespec (int_typespec for int/..., logic_typespec else) at the
    // declared-type keyword span.
    SourceRange typeR(ps.location, ps.location);
    if (auto declared = ps.getDeclaredType())
        if (auto tsyn = declared->getTypeSyntax())
            typeR = tsyn->getFirstToken().range();
    UHDM::typespec* elemTs = nullptr;
    // A struct/union/enum element type references the SHARED typedef typespec
    // (Surelog), not a fresh logic_typespec — when it has been materialized.
    if (auto lit = typedefTs.find(leaf);
        lit != typedefTs.end() &&
        (lit->second->UhdmType() == UHDM::uhdmstruct_typespec ||
         lit->second->UhdmType() == UHDM::uhdmunion_typespec ||
         lit->second->UhdmType() == UHDM::uhdmenum_typespec))
        elemTs = lit->second;
    if (elemTs) {
        // shared typedef keeps its own parent/loc
    }
    else if (leaf->getCanonicalType().kind == SymbolKind::PredefinedIntegerType) {
        auto* its = s.MakeInt_typespec();
        its->VpiSigned(leaf->isSigned());
        // An integer-atom element spans its WHOLE type syntax, signing
        // included (`int unsigned` -> both keywords) — Surelog.
        SourceRange iR = typeR;
        if (auto declared0 = ps.getDeclaredType())
            if (auto tsyn0 = declared0->getTypeSyntax())
                iR = tsyn0->sourceRange();
        setLoc(its, iR);
        elemTs = its;
    }
    else {
        auto* lts = s.MakeLogic_typespec();
        setLoc(lts, typeR);
        // A packed-VECTOR element (logic [31:0]) spans the full type syntax
        // and carries its packed range with literal-folded bounds
        // (param_array_wildcard).
        if (auto declared9 = ps.getDeclaredType()) {
            if (auto tsyn9 = declared9->getTypeSyntax()) {
                if (auto* its9 = tsyn9->as_if<syntax::IntegerTypeSyntax>();
                    its9 && !its9->dimensions.empty() &&
                    leaf->getCanonicalType().isPackedArray()) {
                    setLoc(lts, tsyn9->sourceRange());
                    auto cr9 =
                        leaf->getCanonicalType().as<PackedArrayType>().range;
                    auto* dim9 = its9->dimensions[0];
                    auto* rng9 = s.MakeRange();
                    rng9->VpiParent(lts);
                    setLoc(rng9, dim9->sourceRange());
                    const syntax::ExpressionSyntax* ls9 = nullptr;
                    const syntax::ExpressionSyntax* rs9 = nullptr;
                    if (dim9->specifier &&
                        dim9->specifier->kind ==
                            syntax::SyntaxKind::RangeDimensionSpecifier)
                        if (auto* rsel9 =
                                dim9->specifier
                                    ->as<syntax::RangeDimensionSpecifierSyntax>()
                                    .selector
                                    ->as_if<syntax::RangeSelectSyntax>()) {
                            ls9 = rsel9->left;
                            rs9 = rsel9->right;
                        }
                    auto mkc9 = [&](int64_t v9,
                                    const syntax::ExpressionSyntax* es9) {
                        auto* c9 = s.MakeConstant();
                        c9->VpiParent(rng9);
                        std::string d9 = std::to_string(v9);
                        c9->VpiDecompile(d9);
                        c9->VpiSize(64);
                        c9->VpiValue("UINT:" + d9);
                        c9->VpiConstType(vpiUIntConst);
                        if (es9)
                            setLoc(c9, es9->sourceRange());
                        return c9;
                    };
                    rng9->Left_expr(mkc9(cr9.left, ls9));
                    rng9->Right_expr(mkc9(cr9.right, rs9));
                    auto* rv9 = s.MakeRangeVec();
                    rv9->push_back(rng9);
                    lts->Ranges(rv9);
                }
            }
        }
        elemTs = lts;
    }
    auto* ats = s.MakeArray_typespec();
    ats->VpiParent(parent);
    // loc: type-start .. FIRST unpacked-dim end (Surelog; the flat ts holds
    // every dim as a range but its span stops at the first).
    SourceLocation aEnd = ps.location + ps.name.size();
    if (auto dsyn = ps.getSyntax();
        dsyn && dsyn->kind == syntax::SyntaxKind::Declarator)
        if (auto& dims = dsyn->as<syntax::DeclaratorSyntax>().dimensions; !dims.empty())
            aEnd = dims[0]->sourceRange().end();
    setLoc(ats, SourceRange(typeR.start(), aEnd));
    // Ranges: reuse the shared range objects if given, else build fresh.
    std::string savedDfo8 = dimFoldOwner;
    dimFoldOwner = elemFull;
    UHDM::VectorOfrange* rsrc =
        sharedRanges ? sharedRanges : buildUnpackedRanges(ps, ats, dimRefPrefix);
    dimFoldOwner = savedDfo8;
    if (rsrc) {
        auto* atsR = s.MakeRangeVec();
        for (auto* r0 : *rsrc)
            atsR->push_back(r0);
        ats->Ranges(atsR);
    }
    auto* ert = s.MakeRef_typespec();
    ert->VpiFullName(elemFull);
    ert->VpiParent(ats);
    ert->Actual_typespec(elemTs);
    ats->Elem_typespec(ert);
    // An elaboration clone owns its element typespec, so that clone points
    // back at the ref holding it; a SHARED typedef ts keeps its own parent.
    if (elabClone && elemTs && !elemTs->VpiParent())
        elemTs->VpiParent(ert);
    // A PACKAGE param's freshly minted element typespec links to its home
    // package in every view (Surelog; DefaultPatternInt).
    if (elemTs && !elemTs->Instance() && !elemTs->VpiName().length())
        if (auto* hi8 = homePkgInstOf(ps))
            elemTs->Instance(hi8);
    return ats;
}

UHDM::operation* UhdmExporter::foldUnpackedStructArrayPattern(
    const Expression& init, const Type& arrType, UHDM::typespec* arrTs,
    const std::string& tsFullName, UHDM::any* parent, const std::string& prefix,
    NetMap& netMap, bool connFold) {
    auto& pctA = arrType.getCanonicalType();
    if (pctA.kind != SymbolKind::FixedSizeUnpackedArrayType)
        return nullptr;
    const Type* leafA = &pctA;
    while (leafA->getCanonicalType().kind ==
           SymbolKind::FixedSizeUnpackedArrayType)
        leafA = &leafA->getCanonicalType()
                     .as<FixedSizeUnpackedArrayType>()
                     .elementType;
    if (leafA->getCanonicalType().kind != SymbolKind::PackedStructType)
        return nullptr;
    auto& sinitA = stripImplicitConv(init);
    if (sinitA.kind != ExpressionKind::SimpleAssignmentPattern)
        return nullptr;
    // struct_typespec lookup for a (possibly typedef'd) type.
    auto lookupStructTs = [&](const Type& t) -> UHDM::typespec* {
        if (t.kind == SymbolKind::TypeAlias) {
            if (auto it = typedefTs.find(&t.as<TypeAliasType>());
                it != typedefTs.end())
                return it->second;
            if (auto it =
                    pkgTopTypedefTs.find((const void*)&t.as<TypeAliasType>());
                it != pkgTopTypedefTs.end())
                return it->second;
        }
        const Symbol* canon = (const Symbol*)&t.getCanonicalType();
        if (auto it = pkgTopTypedefTs.find((const void*)canon);
            it != pkgTopTypedefTs.end())
            return it->second;
        if (auto it = typedefTs.find(canon); it != typedefTs.end())
            return it->second;
        return nullptr;
    };
    // Recursive value fold. Returns nullptr on any unfoldable shape.
    std::function<UHDM::any*(const Expression&, const Type&, UHDM::any*)>
        foldField = [&](const Expression& e, const Type& ft,
                        UHDM::any* par) -> UHDM::any* {
        auto& ce = stripImplicitConv(e);
        auto& ctf = ft.getCanonicalType();
        if (ctf.kind == SymbolKind::PackedStructType &&
            ce.kind == ExpressionKind::StructuredAssignmentPattern) {
            bool hasStructMember = false;
            for (auto& f2 : ctf.as<PackedStructType>().membersOfType<FieldSymbol>())
                if (f2.getType().getCanonicalType().kind ==
                    SymbolKind::PackedStructType) {
                    hasStructMember = true;
                    break;
                }
            if (!hasStructMember)
                return nullptr; // all-scalar multi/complex struct: bail
            auto& ap2 = ce.as<StructuredAssignmentPatternExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(75);
            op->VpiParent(par);
            setLoc(op, e.sourceRange);
            // In the instance-CONNECTION flavour every nested member op is
            // sized to its own struct width (the param_assign flavour, which
            // re-uses the definition-view objects, leaves them sizeless).
            if (connFold)
                op->VpiSize((int32_t)ctf.getBitWidth());
            if (auto* sts = lookupStructTs(ft)) {
                auto* rt = s.MakeRef_typespec();
                rt->VpiParent(op);
                rt->Actual_typespec(sts);
                op->Typespec(rt);
            }
            auto* opn = s.MakeAnyVec();
            for (auto& f2 :
                 ctf.as<PackedStructType>().membersOfType<FieldSymbol>()) {
                const Expression* se2 = nullptr;
                for (auto& ms : ap2.memberSetters)
                    if (ms.member == &f2) {
                        se2 = ms.expr;
                        break;
                    }
                if (!se2)
                    se2 = ap2.defaultSetter;
                if (!se2)
                    return nullptr;
                auto* fv = foldField(*se2, f2.getType(), op);
                if (!fv)
                    return nullptr;
                opn->push_back(fv);
            }
            op->Operands(opn);
            return op;
        }
        // scalar / literal leaf: re-emit the source constant.
        return emitExpr(e, par, prefix, netMap);
    };
    auto& apA = sinitA.as<SimpleAssignmentPatternExpression>();
    auto& elemA = pctA.as<FixedSizeUnpackedArrayType>().elementType;
    auto* aop = s.MakeOperation();
    aop->VpiOpType(75);
    aop->VpiParent(parent);
    setLoc(aop, init.sourceRange);
    if (arrTs) {
        auto* rtA = s.MakeRef_typespec();
        rtA->VpiParent(aop);
        rtA->VpiFullName(tsFullName);
        rtA->Actual_typespec(arrTs);
        aop->Typespec(rtA);
    }
    auto* aopn = s.MakeAnyVec();
    bool ok = true;
    for (auto* el : apA.elements()) {
        auto& ee = stripImplicitConv(*el);
        auto& ect = elemA.getCanonicalType();
        if (ee.kind != ExpressionKind::StructuredAssignmentPattern ||
            ect.kind != SymbolKind::PackedStructType) {
            ok = false;
            break;
        }
        auto& eap = ee.as<StructuredAssignmentPatternExpression>();
        for (auto& f2 : ect.as<PackedStructType>().membersOfType<FieldSymbol>()) {
            const Expression* se2 = nullptr;
            for (auto& ms : eap.memberSetters)
                if (ms.member == &f2) {
                    se2 = ms.expr;
                    break;
                }
            if (!se2)
                se2 = eap.defaultSetter;
            if (!se2) {
                ok = false;
                break;
            }
            auto* fv = foldField(*se2, f2.getType(), aop);
            if (!fv) {
                ok = false;
                break;
            }
            aopn->push_back(fv);
        }
        if (!ok)
            break;
    }
    if (!ok || aopn->empty())
        return nullptr;
    aop->Operands(aopn);
    return aop;
}

bool UhdmExporter::isRangedUntypedParam(const ParameterSymbol& ps) {
    if (auto declared = ps.getDeclaredType())
        if (auto tsyn = declared->getTypeSyntax())
            if (tsyn->kind == syntax::SyntaxKind::ImplicitType)
                return !tsyn->as<syntax::ImplicitTypeSyntax>().dimensions.empty() &&
                       ps.getType().getCanonicalType().isPackedArray();
    return false;
}

// Collect the names Surelog resolves through getObject in an INSTANCE context
// (see paramNameIsRead): any name carrying a SELECT anywhere, plus a name
// that is the WHOLE Rhs of a continuous assign.
static void collectSrlgReadNames(const syntax::SyntaxNode& n,
                                 std::map<std::string_view, int>& out) {
    if (n.kind == syntax::SyntaxKind::ContinuousAssign) {
        for (auto* a : n.as<syntax::ContinuousAssignSyntax>().assignments)
            if (a && a->kind == syntax::SyntaxKind::AssignmentExpression) {
                auto* r = a->as<syntax::BinaryExpressionSyntax>().right.get();
                if (r && r->kind == syntax::SyntaxKind::IdentifierName)
                    out[r->as<syntax::IdentifierNameSyntax>()
                            .identifier.valueText()]++;
            }
    }
    if (n.kind == syntax::SyntaxKind::IdentifierSelectName)
        out[n.as<syntax::IdentifierSelectNameSyntax>().identifier.valueText()]++;
    else if (n.kind == syntax::SyntaxKind::ElementSelectExpression) {
        auto* l = n.as<syntax::ElementSelectExpressionSyntax>().left.get();
        if (l && l->kind == syntax::SyntaxKind::IdentifierName)
            out[l->as<syntax::IdentifierNameSyntax>().identifier.valueText()]++;
    }
    for (size_t i = 0, e = n.getChildCount(); i < e; i++)
        if (auto* c = n.childNode(i))
            collectSrlgReadNames(*c, out);
}

// Surelog's elaboration REWRITES a parameter's value typespec the first time
// the parameter's NAME is resolved through getObject in an instance context:
// CompileHelper::setRange (CompileHelper.cpp:5417) replaces the constant's
// ref with a FRESH loc-less logic_typespec whose single range is the Value's
// folded [lr:rr] as BARE UINT constants. A parameter that never reaches
// getObject keeps the located declaration typespec (with the unreduced bound
// expression) in the ELAB view too.
//
// Which reads reach it was measured on a 10-shape ablation (probes 13/14/16
// plus the UnsizedElabComp / ConstantRange / wildcard_eq goldens):
//   `assign z = P[0]`        -> bare    `assign w = P`           -> bare
//   `if (P[0])` gen cond     -> bare    `if (P == '1)` gen cond  -> LOCATED
//   `assign o = a == P`      -> LOCATED `assign o = a ==? P`     -> LOCATED
//   `sub #(.SP(P))`          -> LOCATED never read               -> LOCATED
//   localparam vs parameter, known vs x/z value: no effect.
// So exactly two shapes reach getObject with a constant result: a SELECTED
// reference (anywhere, including a generate condition), and a whole-name
// reference that IS the entire Rhs of a continuous assign. A whole name
// buried in a larger expression — gen-condition comparison or a CA operand
// beside a net — does not.
//
// Modelled on the SYNTAX, not the AST: the reads that matter include
// elaboration-time ones slang has already folded away (generate conditions
// of both taken and untaken branches).
bool UhdmExporter::paramNameIsRead(const ParameterSymbol& ps) {
    auto* syn = ps.getSyntax();
    if (!syn)
        return false;
    const syntax::SyntaxNode* decl = nullptr;
    for (const syntax::SyntaxNode* q = syn->parent; q; q = q->parent)
        if (q->kind == syntax::SyntaxKind::ModuleDeclaration ||
            q->kind == syntax::SyntaxKind::InterfaceDeclaration ||
            q->kind == syntax::SyntaxKind::ProgramDeclaration)
            decl = q;
    if (!decl)
        return false;
    auto it = declIdentCounts.find(decl);
    if (it == declIdentCounts.end()) {
        std::map<std::string_view, int> reads;
        collectSrlgReadNames(*decl, reads);
        it = declIdentCounts.emplace(decl, std::move(reads)).first;
    }
    return it->second.count(ps.name) != 0;
}

// The SAME getObject/setRange rewrite, reached the other way: Surelog REDUCES
// a continuous assign's RHS, and the reduction resolves every name it meets
// through getObject — so a parameter read ANYWHERE inside a cont-assign RHS
// that folds to a constant takes the bare loc-less typespec, not only one that
// IS the whole RHS (paramNameIsRead's syntax rule).  A RHS that cannot reduce
// (any net/variable operand) never gets there, which is why the earlier
// ablation read `assign o = a == P` as "LOCATED": the blocker was the NET
// operand, not the operand position.  Measured on `parameter [3:0] X = 5`,
// one cont-assign per row (probe r9hilo p2/p3):
//   assign o = X;          bare     assign o = nn == X;      LOCATED
//   assign o = $high(X);   bare     assign o = nn + X;       LOCATED
//   assign o = $bits(X);   bare     always @* r = X;         LOCATED
//   assign o = X + 1;      bare     parameter q = $high(X);  LOCATED
//   assign o = {X, 1'b0};  bare
bool UhdmExporter::paramCaFoldRead(const ParameterSymbol& ps) {
    const Scope* body = nullptr;
    for (auto* sc = ps.getParentScope(); sc;
         sc = sc->asSymbol().getParentScope())
        if (sc->asSymbol().kind == SymbolKind::InstanceBody) {
            body = sc;
            break;
        }
    if (!body)
        return false;
    auto it = caFoldReadNames.find(body);
    if (it == caFoldReadNames.end()) {
        std::set<std::string_view> names;
        for (auto& m : body->members()) {
            if (m.kind != SymbolKind::ContinuousAssign)
                continue;
            auto& asn = m.as<ContinuousAssignSymbol>().getAssignment();
            if (asn.kind != ExpressionKind::Assignment)
                continue;
            auto& rhs = asn.as<AssignmentExpression>().right();
            ASTContext ctx(comp.getRoot(), LookupLocation::max);
            if (!ctx.tryEval(rhs))
                continue;
            rhs.visit(makeVisitor([&](auto& v, const NamedValueExpression& nv) {
                if (nv.symbol.kind == SymbolKind::Parameter)
                    names.insert(nv.symbol.name);
                v.visitDefault(nv);
            }));
        }
        it = caFoldReadNames.emplace(body, std::move(names)).first;
    }
    return it->second.count(ps.name) != 0;
}

// Peel selects / member-access / conversions of an initializer down to its
// root value symbol (the named/hierarchical reference the value flows from).
static const Symbol* paramInitRootSym(const Expression& e) {
    const Expression* cur = &e;
    while (cur) {
        switch (cur->kind) {
            case ExpressionKind::NamedValue:
                return &cur->as<NamedValueExpression>().symbol;
            case ExpressionKind::HierarchicalValue:
                return &cur->as<HierarchicalValueExpression>().symbol;
            case ExpressionKind::ElementSelect:
                cur = &cur->as<ElementSelectExpression>().value();
                break;
            case ExpressionKind::RangeSelect:
                cur = &cur->as<RangeSelectExpression>().value();
                break;
            case ExpressionKind::MemberAccess:
                cur = &cur->as<MemberAccessExpression>().value();
                break;
            case ExpressionKind::Conversion:
                cur = &cur->as<ConversionExpression>().operand();
                break;
            default:
                return nullptr;
        }
    }
    return nullptr;
}

// An enum-typed parameter whose value ORIGINATES (through param hops / member
// selects) in a package DIFFERENT from the enum's home instances its clone at
// the value-origin package (Surelog: the pinmux TargetCfg.dio_pad_type family).
// Follows the override initializer to its root value symbol; recurses through
// an overridden PARAMETER root; otherwise returns the package that homes the
// root symbol's declared (aggregate/enum) typedef. Returns null for the common
// case (literal override, or same-package value), leaving the home instance.
static const Symbol* enumParamValueOriginPkg(const ParameterSymbol& ps,
                                             int depth) {
    if (depth > 8)
        return nullptr;
    if (!isOverriddenParam(ps))
        return nullptr;
    const Expression* init = ps.getInitializer();
    if (!init)
        return nullptr;
    const Symbol* root = paramInitRootSym(*init);
    if (!root)
        return nullptr;
    // The value flows from another overridden parameter: recurse to ITS origin.
    if (root->kind == SymbolKind::Parameter &&
        isOverriddenParam(root->as<ParameterSymbol>()))
        if (auto* r =
                enumParamValueOriginPkg(root->as<ParameterSymbol>(), depth + 1))
            return r;
    // Otherwise the origin is the package that homes the root symbol's declared
    // named typedef (a struct/enum whose home differs from the enum's own).
    if (auto* dt = root->getDeclaredType())
        if (dt->getType().kind == SymbolKind::TypeAlias)
            for (auto* sc = dt->getType().getParentScope(); sc;
                 sc = sc->asSymbol().getParentScope())
                if (sc->asSymbol().kind == SymbolKind::Package)
                    return &sc->asSymbol();
    return nullptr;
}

// A parameter that owes its typespec to a `P'(x)` size cast: Surelog's minted
// object is NAMED after the parameter, anchored at the cast's type-name span,
// and carries a vpiExpr ref_obj (name doubled into the fullname: `W.W`) bound
// back to the parameter. Both views build their own object, so both are
// stamped; ExprEmit's cast path reaches this one through defMap.paramTs and
// reuses it rather than minting an integer_typespec of its own.
void UhdmExporter::stampCastSizeParamTs(const ParameterSymbol& ps,
                                        UHDM::parameter* up,
                                        UHDM::typespec* its) {
    auto cit = castSizeParamTs.find(&ps);
    if (cit == castSizeParamTs.end() || !its ||
        its->UhdmType() != UHDM::uhdmint_typespec)
        return;
    auto* ic9 = (UHDM::int_typespec*)its;
    setLoc(ic9, cit->second->sourceRange());
    ic9->VpiName(ps.name);
    if (!ic9->Cast_to_expr()) {
        auto* r9 = s.MakeRef_obj();
        r9->VpiName(ps.name);
        r9->VpiFullName(std::string(ps.name) + "." + std::string(ps.name));
        r9->VpiParent(ic9);
        if (up)
            r9->Actual_group(up);
        ic9->Cast_to_expr(r9);
    }
}

UHDM::typespec* UhdmExporter::makeParamTs(const ParameterSymbol& ps, bool typedParam,
                                          bool parentBounds) {
    SourceRange tr(ps.location, ps.location + ps.name.size());
    if (typedParam) {
        if (auto declared = ps.getDeclaredType())
            if (auto tsyn = declared->getTypeSyntax()) {
                // An UNTYPED param forced to typedParam (the imported-integral
                // fallback) still locates its typespec at the DECLARATION span,
                // like a normal untyped param — not the empty implicit-type span.
                if (tsyn->kind == syntax::SyntaxKind::ImplicitType) {
                    for (auto q = ps.getSyntax(); q; q = q->parent)
                        if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                            tr = q->sourceRange();
                            break;
                        }
                }
                else
                    tr = trimTypeSigning(tsyn, tsyn->sourceRange());
            }
    }
    else {
        for (auto q = ps.getSyntax(); q; q = q->parent) {
            if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                tr = q->sourceRange();
                break;
            }
        }
        // A ranged untyped param (parameter [0:0] X) locates its int_typespec
        // at the packed-range span, not the whole declaration; a SIGNED
        // implicit param (localparam unsigned P) at the signing keyword.
        if (auto declared = ps.getDeclaredType()) {
            if (auto tsyn = declared->getTypeSyntax()) {
                if (tsyn->kind == syntax::SyntaxKind::ImplicitType) {
                    auto& imp = tsyn->as<syntax::ImplicitTypeSyntax>();
                    if (!imp.dimensions.empty())
                        tr = SourceRange(imp.dimensions[0]->sourceRange().start(),
                                         imp.dimensions.back()->sourceRange().end());
                    else if (imp.signing.valid())
                        tr = imp.signing.range();
                }
            }
        }
    }
    // The typespec class follows the declared integer kind (integer -> an
    // integer_typespec, etc.); untyped params default to int_typespec.
    UHDM::typespec* its = nullptr;
    bool sharedAggTs = false;
    bool sgn = ps.getType().getCanonicalType().isSigned();
    if (typedParam) {
        auto& ct = ps.getType().getCanonicalType();
        if (ct.kind == SymbolKind::PredefinedIntegerType) {
            switch (ct.as<PredefinedIntegerType>().integerKind) {
                case PredefinedIntegerType::Integer: {
                    auto* t = s.MakeInteger_typespec();
                    t->VpiSigned(sgn);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::ShortInt: {
                    auto* t = s.MakeShort_int_typespec();
                    t->VpiSigned(sgn);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::LongInt: {
                    auto* t = s.MakeLong_int_typespec();
                    t->VpiSigned(sgn);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::Byte: {
                    auto* t = s.MakeByte_typespec();
                    t->VpiSigned(sgn);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::Time:
                    its = s.MakeTime_typespec();
                    break;
                default:
                    break;
            }
        }
    }
    // A real (real/shortreal) param is a real_typespec — typed OR an untyped
    // param inferred real from its literal (localparam p = 123.45).
    if (!its && ps.getType().getCanonicalType().isFloating())
        its = s.MakeReal_typespec();
    // A TYPED string param (parameter string N) is a LOCATED string_typespec.
    if (typedParam && !its && ps.getType().getCanonicalType().isString())
        its = s.MakeString_typespec();
    // A typed logic/bit scalar param is a logic/bit_typespec, not an
    // int_typespec.
    if (typedParam && !its) {
        auto& ct = ps.getType().getCanonicalType();
        if (ct.kind == SymbolKind::ScalarType && ct.isFourState()) {
            auto* t = s.MakeLogic_typespec();
            if (sgn)
                t->VpiSigned(true);
            its = t;
        }
        else if (ct.kind == SymbolKind::ScalarType) {
            auto* t = s.MakeBit_typespec();
            if (sgn)
                t->VpiSigned(true);
            its = t;
        }
        // A typed packed logic/bit VECTOR written directly (parameter logic
        // [31:0] X) builds a logic_typespec with its range via makeTypespec. A
        // typedef'd type (NamedType syntax) would make makeTypespec bail, so
        // it stays on the int_typespec default.
        else if (ct.kind == SymbolKind::PackedArrayType && ct.isIntegral()) {
            auto* tsyn = ps.getDeclaredType() ? ps.getDeclaredType()->getTypeSyntax() : nullptr;
            if (tsyn && syntax::IntegerTypeSyntax::isKind(tsyn->kind))
                its = makeTypespec(ps);
            // A param typed by a VECTOR TYPEDEF (parameter my_type_t Y) uses a
            // NAMED clone of the typedef's logic_typespec with a Typedef_alias
            // ref to the shared typedef ts (Surelog), not a bare int_typespec.
            // (Only once emitTypedefs has populated typedefTs — the def
            // pre-pass falls back and is patched later.)
            else if (auto d0 = ps.getDeclaredType();
                     d0 && d0->getType().kind == SymbolKind::TypeAlias) {
                auto& taSym = d0->getType().as<TypeAliasType>();
                // A UNIQUIFIED instance body owns its OWN TypeAlias symbols,
                // which are NOT the ones typedefTs holds (it holds the DEF
                // body's, seen once at emitTypedefs). The elab child SHARES
                // the def typedef object (see the isTop-removed listing), so
                // fall back to it BY NAME when the per-instance symbol misses
                // (ParameterOfParametrizedTypeInSubmodule u_sub_5/u_sub_10 Y).
                UHDM::typespec* sharedTd = nullptr;
                if (auto tit = typedefTs.find(&taSym); tit != typedefTs.end())
                    sharedTd = tit->second;
                else if (auto* psc = ps.getParentScope();
                         psc &&
                         psc->asSymbol().kind == SymbolKind::InstanceBody) {
                    auto& defsym = psc->asSymbol()
                                       .as<InstanceBodySymbol>()
                                       .getDefinition();
                    if (auto dit = defMap.find(&defsym); dit != defMap.end())
                        for (auto* td : dit->second.typedefs)
                            if (td->VpiName() == taSym.name) {
                                sharedTd = td;
                                break;
                            }
                }
                if (sharedTd &&
                    sharedTd->UhdmType() == UHDM::uhdmlogic_typespec) {
                    const syntax::SyntaxNode* tgtSyn = nullptr;
                    if (auto asyn = taSym.getSyntax())
                        if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tgtSyn =
                                asyn->as<syntax::TypedefDeclarationSyntax>().type;
                    bypassTypedefShare = true;
                    // Keep the typedef clone's parametrized range SYMBOLIC
                    // ([X-1:0], not folded to [19:0]) — Surelog keeps the X-1
                    // operation on the alias clone in both views.
                    bool savedTf2 = tfContext;
                    tfContext = true;
                    auto* cl = makeTypespec(taSym, tgtSyn);
                    tfContext = savedTf2;
                    bypassTypedefShare = false;
                    auto* art = s.MakeRef_typespec();
                    // Package-scoped alias refs join with '::'; module-scoped
                    // with '.' (Surelog). Context comes from the REF PREFIX,
                    // not the symbol's home scope — a materialized imported
                    // param lives in the pkg but is emitted module-side.
                    bool psPkg = ps.getParentScope() &&
                                 ps.getParentScope()->asSymbol().kind ==
                                     SymbolKind::Package &&
                                 syntaxRefPrefix.rfind(
                                     std::string(
                                         ps.getParentScope()->asSymbol().name),
                                     0) == 0;
                    art->VpiFullName(syntaxRefPrefix.empty()
                                         ? std::string(taSym.name)
                                         : syntaxRefPrefix +
                                               (psPkg ? "::" : ".") +
                                               std::string(taSym.name));
                    art->VpiParent(cl);
                    // An IMPORTED vector typedef in MODULE context aliases to
                    // a SECOND bare clone (pkg-Instanced, no alias) — not the
                    // pkg's qualified ts; both clones Instance at the def pkg
                    // (Surelog).
                    // Only the MATERIALIZED IMPORTED param itself (ps lives in
                    // the typedef's home pkg) gets the second clone; a module
                    // param merely TYPED by the imported typedef aliases the
                    // qualified pkg ts directly (Surelog).
                    const Symbol* tdHome9 = nullptr;
                    if (auto hs9 = taSym.getParentScope();
                        hs9 && hs9->asSymbol().kind == SymbolKind::Package &&
                        !psPkg && ps.getParentScope() == hs9)
                        tdHome9 = &hs9->asSymbol();
                    if (tdHome9 && pkgDefMap.count(tdHome9)) {
                        bypassTypedefShare = true;
                        tfContext = true;
                        auto* clB = makeTypespec(taSym, tgtSyn);
                        tfContext = savedTf2;
                        bypassTypedefShare = false;
                        clB->VpiName(taSym.name);
                        clB->VpiParent(art);
                        clB->Instance((UHDM::instance*)pkgDefMap[tdHome9]);
                        art->Actual_typespec(clB);
                    }
                    else
                        art->Actual_typespec(sharedTd);
                    // ANY module-context clone of a pkg typedef Instances at
                    // the def pkg (Surelog).
                    if (auto hsI9 = taSym.getParentScope();
                        hsI9 && !psPkg &&
                        hsI9->asSymbol().kind == SymbolKind::Package &&
                        pkgDefMap.count(&hsI9->asSymbol()))
                        cl->Instance(
                            (UHDM::instance*)pkgDefMap[&hsI9->asSymbol()]);
                    ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
                    cl->VpiName(taSym.name);
                    its = cl;
                    if (tgtSyn)
                        tr = tgtSyn->sourceRange();
                }
            }
        }
        // An ENUM-typedef-typed param (parameter pad_type_e P) binds the
        // SHARED enum typespec (def view: the def object; elab: the top
        // object) — not a fresh int_typespec (Surelog).
        else if (ct.kind == SymbolKind::EnumType) {
            if (auto d0 = ps.getDeclaredType();
                d0 && d0->getType().kind == SymbolKind::TypeAlias) {
                auto& taSym = d0->getType().as<TypeAliasType>();
                if (defViewParamTs) {
                    if (auto tit = typedefTs.find(&taSym);
                        tit != typedefTs.end()) {
                        its = tit->second;
                        sharedAggTs = true;
                    }
                }
                else {
                    // ELAB: a FRESH enum clone — base ref MODULE-scoped
                    // (work@top.my_pkg::get_e), pkg-Instanced, spanning the
                    // whole typedef; parent = the prt ref (caller).
                    std::string aliasNm(taSym.name);
                    const Symbol* homePkg9 = nullptr;
                    if (auto sc9 = taSym.getParentScope();
                        sc9 && sc9->asSymbol().kind == SymbolKind::Package) {
                        homePkg9 = &sc9->asSymbol();
                        aliasNm = std::string(homePkg9->name) + "::" + aliasNm;
                    }
                    // Base ref scopes through the PARAM's full name
                    // (work@top.GetWhat.my_pkg::get_e — Surelog).
                    const syntax::SyntaxNode* eSyn9 = nullptr;
                    if (auto dS9 = taSym.getSyntax();
                        dS9 &&
                        dS9->kind == syntax::SyntaxKind::TypedefDeclaration)
                        eSyn9 =
                            dS9->as<syntax::TypedefDeclarationSyntax>().type;
                    auto* ecl = buildEnumTs(ct.as<EnumType>(), eSyn9,
                                            syntaxRefPrefix.empty()
                                                ? aliasNm
                                                : syntaxRefPrefix + "." +
                                                      aliasNm);
                    ecl->VpiName(aliasNm);
                    if (auto dS9 = taSym.getSyntax())
                        setLoc(ecl, dS9->sourceRange());
                    if (homePkg9)
                        if (auto pit9 = pkgDefMap.find(homePkg9);
                            pit9 != pkgDefMap.end()) {
                            // The enum clone's OWN Instance is the VALUE-ORIGIN
                            // package when the override value flows in from a
                            // different package (Surelog: pinmux
                            // TargetCfg.dio_pad_type -> PadType clone instanced
                            // at pinmux, not prim_pad_wrapper); the base actual
                            // keeps the enum's HOME package in both cases.
                            UHDM::instance* enumInst = pit9->second;
                            if (auto* origin =
                                    enumParamValueOriginPkg(ps, 0);
                                origin && origin != homePkg9)
                                if (auto oit = pkgDefMap.find(origin);
                                    oit != pkgDefMap.end())
                                    enumInst = oit->second;
                            ecl->Instance(enumInst);
                            // The base actual is REF-parented and
                            // pkg-Instanced (Surelog).
                            if (ecl->Base_typespec() &&
                                ecl->Base_typespec()->Actual_typespec()) {
                                ecl->Base_typespec()
                                    ->Actual_typespec()
                                    ->VpiParent(ecl->Base_typespec());
                                ecl->Base_typespec()
                                    ->Actual_typespec()
                                    ->Instance(pit9->second);
                            }
                        }
                    its = ecl;
                    sharedAggTs = true; // caller skips setLoc; parent set below
                }
            }
        }
        // A struct/union-typed param carries a FRESH aggregate typespec clone
        // (named by the typedef, located at the struct/union body), not an
        // int_typespec. Member refs scope through the calling context
        // (syntaxRefPrefix: the elab param clone uses work@top.P.<ty>.<m>).
        else if (ct.kind == SymbolKind::PackedStructType ||
                 ct.kind == SymbolKind::PackedUnionType ||
                 ct.kind == SymbolKind::UnpackedStructType) {
            std::string alias;
            const Symbol* aliasPkg = nullptr;
            if (auto d0 = ps.getDeclaredType())
                if (d0->getType().kind == SymbolKind::TypeAlias) {
                    alias = std::string(d0->getType().name);
                    // A PACKAGE-scoped typedef names the clone p::cfg_t and
                    // instances it at the package (Surelog).
                    for (auto sc2 = d0->getType().getParentScope(); sc2;
                         sc2 = sc2->asSymbol().getParentScope())
                        if (sc2->asSymbol().kind == SymbolKind::Package) {
                            aliasPkg = &sc2->asSymbol();
                            alias = std::string(aliasPkg->name) + "::" + alias;
                            break;
                        }
                }
            std::string memberScope = alias;
            if (!syntaxRefPrefix.empty() && !alias.empty())
                memberScope = syntaxRefPrefix + "." + alias;
            its = ct.kind == SymbolKind::PackedStructType
                      ? (UHDM::typespec*)buildStructTs(ct.as<PackedStructType>(), true,
                                                       memberScope)
                      : ct.kind == SymbolKind::UnpackedStructType
                      ? (UHDM::typespec*)buildStructTs(
                            ct.as<UnpackedStructType>(), false, memberScope)
                      : (UHDM::typespec*)buildUnionTs(ct.as<PackedUnionType>(), true,
                                                      memberScope);
            its->VpiName(alias);
            if (aliasPkg) {
                // A param-ts CLONE reaches the ELABORATED (top) home package
                // when one exists — Surelog's cross-scope instance links land
                // on the elaborated package (whose typedefs carry the FOLDED
                // member bounds), not the def-view one. Package-owned
                // typespecs keep their own view's package (set by the caller).
                UHDM::package* homePkg0 = nullptr;
                if (auto tit0 = pkgTopMap.find(aliasPkg); tit0 != pkgTopMap.end())
                    homePkg0 = tit0->second;
                else if (auto dit0 = pkgDefMap.find(aliasPkg);
                         dit0 != pkgDefMap.end())
                    homePkg0 = dit0->second;
                if (homePkg0) {
                    its->Instance(homePkg0);
                    // Fresh member-actual clones carry the package Instance
                    // too (shared package typespecs already have it).
                    if (auto* mems = ((UHDM::struct_typespec*)its)->Members())
                        for (auto* tm : *mems)
                            if (tm->Typespec() &&
                                tm->Typespec()->Actual_typespec() &&
                                !tm->Typespec()->Actual_typespec()->Instance())
                                tm->Typespec()->Actual_typespec()->Instance(
                                    homePkg0);
                }
            }
            if (auto* csyn = ct.getSyntax())
                tr = csyn->sourceRange();
        }
    }
    // An untyped param initialized with a string literal (parameter X = "FOO")
    // is a bare (unlocated) string_typespec, not an int_typespec.
    bool stringParam = false;
    if (!its && !typedParam) {
        bool strLit = false;
        if (auto init = ps.getInitializer();
            init && stripImplicitConv(*init).kind == ExpressionKind::StringLiteral)
            strLit = true;
        // An OVERRIDDEN port parameter's initializer is the OVERRIDE
        // expression, so the literal test above misses it. Surelog types the
        // parameter from the module DEFINITION's default, which lives on the
        // declarator syntax and is override-independent (ParamFile).
        if (!strLit && declaredStringLiteralParam(ps))
            strLit = true;
        if (strLit) {
            its = s.MakeString_typespec();
            stringParam = true;
        }
    }
    UHDM::int_typespec* intTs = nullptr;
    if (!its) {
        intTs = s.MakeInt_typespec();
        // Untyped parameters carry no signedness flag — EXCEPT one written
        // with an explicit signing keyword (localparam signed Y), whose
        // int_typespec spans that keyword and does carry it (const_func).
        bool signKw9 = false;
        if (auto d9 = ps.getDeclaredType())
            if (auto t9 = d9->getTypeSyntax())
                if (t9->kind == syntax::SyntaxKind::ImplicitType)
                    signKw9 = t9->as<syntax::ImplicitTypeSyntax>()
                                  .signing.valid() &&
                              t9->as<syntax::ImplicitTypeSyntax>()
                                  .dimensions.empty();
        if (typedParam || signKw9)
            intTs->VpiSigned(sgn);
        its = intTs;
    }
    // An UNTYPED param inferred REAL keeps its real_typespec LOC-LESS
    // (realexpr p4); typed real params locate at the type token.
    bool untypedReal9 =
        !typedParam && ps.getType().getCanonicalType().isFloating();
    if (!stringParam && !sharedAggTs && !untypedReal9)
        setLoc(its, tr);
    // A ranged untyped param (parameter [0:0] X) carries the packed range on
    // its int_typespec, with located UINT bounds.
    bool explicitRange = false;
    if (!typedParam && intTs) {
        if (auto declared = ps.getDeclaredType()) {
            if (auto tsyn = declared->getTypeSyntax()) {
                if (tsyn->kind == syntax::SyntaxKind::ImplicitType) {
                    auto& imp = tsyn->as<syntax::ImplicitTypeSyntax>();
                    if (!imp.dimensions.empty() &&
                        ps.getType().getCanonicalType().isPackedArray()) {
                        auto* dim = imp.dimensions[0];
                        auto crange = ps.getType().getCanonicalType().getFixedRange();
                        const syntax::ExpressionSyntax* lsyn = nullptr;
                        const syntax::ExpressionSyntax* rsyn = nullptr;
                        if (dim->specifier &&
                            dim->specifier->kind ==
                                syntax::SyntaxKind::RangeDimensionSpecifier) {
                            auto& sel = *dim->specifier
                                             ->as<syntax::RangeDimensionSpecifierSyntax>()
                                             .selector;
                            if (auto* rss = sel.as_if<syntax::RangeSelectSyntax>()) {
                                lsyn = rss->left;
                                rsyn = rss->right;
                            }
                        }
                        auto* r = s.MakeRange();
                        r->VpiParent(its);
                        setLoc(r, dim->sourceRange());
                        auto mkB = [&](int64_t v,
                                       const syntax::ExpressionSyntax* es)
                            -> UHDM::expr* {
                            // A NAMED bound ([HI:LO]) stays a symbolic ref
                            // scoped through the param (work@evil.A_VAL.HI) —
                            // Surelog keeps it in both views. Literal bounds
                            // fold to UINT constants.
                            if (es &&
                                es->kind ==
                                    syntax::SyntaxKind::IdentifierName) {
                                auto* r0 = s.MakeRef_obj();
                                std::string bn(
                                    es->as<syntax::IdentifierNameSyntax>()
                                        .identifier.valueText());
                                r0->VpiName(bn);
                                if (!syntaxRefPrefix.empty())
                                    r0->VpiFullName(syntaxRefPrefix + "." + bn);
                                r0->VpiParent(r);
                                setLoc(r0, es->sourceRange());
                                return (UHDM::expr*)r0;
                            }
                            // A bound reading a `$unit` parameter
                            // (`localparam [SCR1_GPR_FIELD_WIDTH-1:0] X`)
                            // stays the unfolded op tree: Surelog cannot
                            // substitute a compilation-unit parameter, so it
                            // never reduces the range (Scr1SvTests
                            // SCR1_MPRF_ZERO_ADDR).
                            if (es &&
                                syntaxReadsUnitParam(*es, ps.getParentScope()))
                                if (auto* e9 = emitSyntaxExpr(*es, r))
                                    return (UHDM::expr*)e9;
                            auto* c = s.MakeConstant();
                            c->VpiDecompile(std::to_string(v));
                            c->VpiSize(64);
                            c->VpiValue("UINT:" + std::to_string(v));
                            c->VpiConstType(vpiUIntConst);
                            c->VpiParent(r);
                            if (es)
                                setLoc(c, es->sourceRange());
                            return (UHDM::expr*)c;
                        };
                        r->Left_expr(mkB(crange.left, lsyn));
                        r->Right_expr(mkB(crange.right, rsyn));
                        auto* rv = s.MakeRangeVec();
                        rv->push_back(r);
                        intTs->Ranges(rv);
                        explicitRange = true;
                    }
                }
            }
        }
    }
    // Untyped params with based-literal inits gain a bare [w-1:0] range
    // (loc-less, value-only INT constants).
    if (!typedParam && !explicitRange) {
        if (auto init = ps.getInitializer()) {
            auto& lit = stripImplicitConv(*init);
            if (lit.kind == ExpressionKind::IntegerLiteral &&
                rawTextLit(lit).find('\'') != std::string::npos) {
                auto* r = s.MakeRange();
                r->VpiParent(its);
                auto mkBound = [&](int64_t v) {
                    auto* c = s.MakeConstant();
                    c->VpiValue("INT:" + std::to_string(v));
                    // Write-phase (instance) param ts bounds are parented.
                    if (parentBounds)
                        c->VpiParent(r);
                    return c;
                };
                r->Left_expr(mkBound((int64_t)lit.type->getBitWidth() - 1));
                r->Right_expr(mkBound(0));
                auto* rv = s.MakeRangeVec();
                rv->push_back(r);
                if (intTs)
                    intTs->Ranges(rv);
            }
        }
    }
    return its;
}

// A LOC-LESS bare logic_typespec clone of a vector param's packed range;
// bound constants carry ONLY the UINT value (parented at the range when
// parentBounds).
UHDM::typespec* UhdmExporter::makeBareVecParamTs(const ParameterSymbol& ps,
                                                 bool parentBounds) {
    auto& ct = ps.getType().getCanonicalType();
    if (!ct.isPackedArray())
        return nullptr;
    auto& pat = ct.as<PackedArrayType>();
    auto* lts = s.MakeLogic_typespec();
    auto* r = s.MakeRange();
    r->VpiParent(lts);
    auto mk = [&](int64_t v) {
        auto* c = s.MakeConstant();
        c->VpiValue("UINT:" + std::to_string(v));
        if (parentBounds)
            c->VpiParent(r);
        return c;
    };
    r->Left_expr(mk(pat.range.left));
    r->Right_expr(mk(pat.range.right));
    auto* rv = s.MakeRangeVec();
    rv->push_back(r);
    lts->Ranges(rv);
    return lts;
}

// The instance body a symbol is declared in (nullptr for package/$unit
// params); generate blocks resolve to their enclosing instance.
static const InstanceBodySymbol* paramOwnerBody(const Symbol& sym) {
    for (auto* sc = sym.getParentScope(); sc;) {
        auto& ss = sc->asSymbol();
        if (ss.kind == SymbolKind::InstanceBody)
            return &ss.as<InstanceBodySymbol>();
        sc = ss.getParentScope();
    }
    return nullptr;
}

// Surelog builds an aggregate param's ELAB pattern-op typespec clone while it
// ELABORATES the param assign — before the instance's own net/port typespecs
// are written. Minting it here (right after the instance's params are emitted)
// puts it in that arena slot; patchParamTypespecs then reuses the clone.
void UhdmExporter::mintParamOpClones(size_t lo, size_t hi) {
    for (size_t i = lo; i < hi && i < pendingParamTs.size(); i++) {
        auto& [ps, up, prt, rhsRt, typedParam] = pendingParamTs[i];
        auto& pct = ps->getType().getCanonicalType();
        if (pct.kind != SymbolKind::PackedStructType &&
            pct.kind != SymbolKind::PackedUnionType)
            continue;
        if (!rhsRt || !rhsRt->VpiParent() ||
            rhsRt->VpiParent()->UhdmType() != UHDM::uhdmoperation)
            continue;
        if (paramOpClones.count(rhsRt))
            continue;
        std::string savedPfx = syntaxRefPrefix;
        std::string full(prt->VpiFullName());
        auto dot = full.rfind('.');
        syntaxRefPrefix = dot == std::string::npos ? full : full.substr(0, dot);
        structCloneMemberRefParent = true;
        paramOpCloneCtx = true;
        auto* opClone = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
        paramOpCloneCtx = false;
        structCloneMemberRefParent = false;
        rhsRt->Actual_typespec(opClone);
        opClone->VpiParent(rhsRt);
        if (rhsRt->VpiFullName().empty())
            rhsRt->VpiFullName(syntaxRefPrefix);
        syntaxRefPrefix = savedPfx;
        paramOpClones[rhsRt] = opClone;
    }
}

// Elab Rhs for an overridden NO-DEFAULT param that no cont-assign fold
// claimed (see noDefOvRhsFallback for the measured shapes).  Runs before the
// param typespecs are patched so a typed constant's ts ref joins the ordinary
// noDefOvTsRef sharing.
void UhdmExporter::drainNoDefOvRhs() {
    if (noDefOvRhsFallback.empty())
        return;
    auto pending = std::move(noDefOvRhsFallback);
    noDefOvRhsFallback.clear();
    for (auto& f : pending) {
        // A CA fold already shared its constant here — that object wins.
        if (f.pa->Rhs())
            continue;
        auto* init0 = f.ps->getInitializer();
        if (!init0)
            continue;
        auto& ovc = stripImplicitConv(*init0);
        if (ovc.kind != ExpressionKind::IntegerLiteral)
            continue;
        bool typed = false;
        if (auto dt = f.ps->getDeclaredType())
            if (auto tsyn = dt->getTypeSyntax())
                typed = tsyn->kind != syntax::SyntaxKind::ImplicitType;
        std::string raw = stripSep(std::string(rawText(ovc.sourceRange)));
        auto tick = raw.find('\'');
        auto* c = s.MakeConstant();
        if (tick != std::string::npos) {
            // A BASED literal keeps its own base, digits and WRITTEN size.
            size_t basePos = tick + 1;
            if (basePos < raw.size() &&
                (raw[basePos] == 's' || raw[basePos] == 'S'))
                basePos++;
            char base = basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
            std::string digits =
                basePos + 1 < raw.size() ? raw.substr(basePos + 1) : std::string();
            c->VpiDecompile(raw);
            std::string szTxt = raw.substr(0, tick);
            int32_t w = 0;
            if (!szTxt.empty() &&
                szTxt.find_first_not_of("0123456789") == std::string::npos)
                w = (int32_t)strtol(szTxt.c_str(), nullptr, 10);
            if (!w)
                w = (int32_t)f.ps->getType().getBitWidth();
            c->VpiSize(w);
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
        }
        else {
            auto& cv = f.ps->getValue();
            if (!cv.isInteger() || cv.integer().hasUnknown())
                continue;
            auto& iv = cv.integer();
            std::string digits = iv.toString(LiteralBase::Decimal, false);
            c->VpiDecompile(digits);
            c->VpiValue("UINT:" + digits);
            c->VpiConstType(vpiUIntConst);
            // Typed: the folded value's own width; untyped: Surelog's 64.
            c->VpiSize(typed ? (int32_t)iv.getBitWidth() : 64);
        }
        c->VpiParent(f.pa);
        if (typed) {
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(f.prefix);
            rt->VpiParent(c);
            c->Typespec(rt);
            noDefOvTsRef[f.ps].push_back(rt);
        }
        f.pa->Rhs(c);
    }
}

void UhdmExporter::patchParamTypespecs(size_t lo, size_t hi,
                                       const InstanceBodySymbol* ownBody,
                                       bool descendants) {
    for (size_t i = lo; i < hi && i < pendingParamTs.size(); i++) {
        auto& [ps, up, prt, rhsRt, typedParam] = pendingParamTs[i];
        if (ownBody) {
            // Package/$unit params ride with the instance that pulled them in.
            auto* ob = paramOwnerBody(*ps);
            bool own = !ob || ob == ownBody;
            if (own == descendants)
                continue;
        }
        // The ELAB param ts is a FRESH clone (Surelog: parented at the elab
        // ref below; struct/union clones also carry vpiInstance -> the module).
        // A struct-pattern param's ELAB OP ts (rhsRt on an operation) binds its
        // OWN module-scoped clone (created FIRST — Surelog tail order), with
        // member leaf ts parented at the member refs.
        std::string savedPfx2 = syntaxRefPrefix;
        bool aggParam = ps->getType().getCanonicalType().kind ==
                            SymbolKind::PackedStructType ||
                        ps->getType().getCanonicalType().kind ==
                            SymbolKind::PackedUnionType;
        UHDM::typespec* opClone = nullptr;
        if (auto oit = paramOpClones.find(rhsRt);
            rhsRt && oit != paramOpClones.end())
            opClone = oit->second; // minted at elaboration (mintParamOpClones)
        else if (aggParam && rhsRt && rhsRt->VpiParent() &&
                 rhsRt->VpiParent()->UhdmType() == UHDM::uhdmoperation) {
            std::string full(prt->VpiFullName());
            auto dot = full.rfind('.');
            syntaxRefPrefix = dot == std::string::npos ? full : full.substr(0, dot);
            structCloneMemberRefParent = true;
            paramOpCloneCtx = true;
            opClone = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
            paramOpCloneCtx = false;
            structCloneMemberRefParent = false;
            rhsRt->Actual_typespec(opClone);
            opClone->VpiParent(rhsRt);
            if (rhsRt->VpiFullName().empty())
                rhsRt->VpiFullName(syntaxRefPrefix);
        }
        // A param typed by a PACKAGE typedef shares the pkg's TOP typespec
        // (no clone); module-local aggregate typedefs get the fresh clone C.
        UHDM::typespec* its = nullptr;
        bool sharedPkgTs = false;
        // An ALIAS-OF-ALIAS vector typedef param (typedef int8_t char_t)
        // binds the SHARED module typedef ts in the elab view too; Surelog's
        // param-scoped clones stay orphaned (typedef_param ch).
        if (ps->getDeclaredType()) {
            auto& dtA = ps->getDeclaredType()->getType();
            if (dtA.kind == SymbolKind::TypeAlias &&
                dtA.getCanonicalType().kind == SymbolKind::PackedArrayType &&
                dtA.getCanonicalType().isIntegral() &&
                dtA.as<TypeAliasType>().targetType.getType().kind ==
                    SymbolKind::TypeAlias)
                if (auto titA = typedefTs.find(&dtA); titA != typedefTs.end()) {
                    its = titA->second;
                    sharedPkgTs = true; // shared: keeps its own parent
                }
        }
        if (aggParam) {
            if (auto d0 = ps->getDeclaredType()) {
                auto& dt0 = d0->getType();
                if (dt0.kind == SymbolKind::TypeAlias) {
                    auto& taSym = dt0.as<TypeAliasType>();
                    // Only QUALIFIED (pkg::T) params share; a wildcard-
                    // imported BARE name gets the fresh clone (Surelog).
                    bool qualified0 = false;
                    if (auto* tsyn0 = d0->getTypeSyntax();
                        tsyn0 && tsyn0->kind == syntax::SyntaxKind::NamedType)
                        qualified0 =
                            tsyn0->as<syntax::NamedTypeSyntax>().name->kind ==
                            syntax::SyntaxKind::ScopedName;
                    // An INTERFACE instance's aggregate parameter never shares
                    // the package typespec: Surelog clones the whole struct
                    // family per interface VIEW (iface_cfg_mem).
                    bool ifaceOwner0 = false;
                    if (auto* ob0 = paramOwnerBody(*ps))
                        ifaceOwner0 = ob0->getDefinition().definitionKind ==
                                      DefinitionKind::Interface;
                    if (auto sc = taSym.getParentScope();
                        qualified0 && !ifaceOwner0 && sc &&
                        sc->asSymbol().kind == SymbolKind::Package) {
                        if (auto tit = pkgTopTypedefTs.find(&taSym);
                            tit != pkgTopTypedefTs.end()) {
                            its = tit->second;
                            sharedPkgTs = true;
                        }
                    }
                }
            }
        }
        if (!its) {
            syntaxRefPrefix = std::string(prt->VpiFullName());
            if (aggParam)
                structCloneMemberRefParent = true;
            its = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
            structCloneMemberRefParent = false;
            stampCastSizeParamTs(*ps, up, its);
            if (aggParam)
                attachFoldedBoundMeta(its, (UHDM::instance*)its->Instance());
            if (its->UhdmType() == UHDM::uhdmstruct_typespec ||
                its->UhdmType() == UHDM::uhdmunion_typespec) {
                // A $UNIT-level struct typedef clone is Instanced at the
                // DESIGN (struct_param_dim test_struct_t), not the module.
                bool unitTd9 = false;
                // A PACKAGE-scoped struct/union typedef clone stays Instanced
                // at its home PACKAGE (makeParamTs' aliasPkg link), even when
                // used as a module param's type — Surelog keeps the pkg
                // instance in both views (5-level-hierarchy family). Only
                // MODULE-LOCAL typedef clones (no package/unit home) take the
                // instantiating module instance. unitTd9 keys on the
                // IMMEDIATE typedef scope; pkgTd9 on ANY package ancestor.
                bool pkgTd9 = false;
                if (ps->getDeclaredType()) {
                    auto& dtT9 = ps->getDeclaredType()->getType();
                    if (dtT9.kind == SymbolKind::TypeAlias) {
                        auto& taT9 = dtT9.as<TypeAliasType>();
                        if (auto* isc9 = taT9.getParentScope())
                            unitTd9 = isc9->asSymbol().kind ==
                                      SymbolKind::CompilationUnit;
                        for (auto* scT9 = taT9.getParentScope(); scT9;
                             scT9 = scT9->asSymbol().getParentScope())
                            if (scT9->asSymbol().kind == SymbolKind::Package) {
                                pkgTd9 = true;
                                break;
                            }
                    }
                }
                if (unitTd9)
                    its->Instance((UHDM::instance*)(UHDM::BaseClass*)d);
                else if (!pkgTd9 || !its->Instance()) {
                    // A MODULE-LOCAL struct/union typedef clone INHERITS the
                    // shared typedef object's instance — the DEF-view
                    // module_inst — instead of taking the module instance this
                    // clone is being written into. Surelog clones the def-view
                    // typespec and the clone keeps the original's vpiInstance;
                    // the two views are NOT interchangeable to uhdm-cmp
                    // (module_inst::Compare tests vpiTopModule, and a module
                    // with generate constructs has Gen_stmts in the def view
                    // where the elaborated one has Gen_scope_arrays), so the
                    // elab pointer is a hard failure the dump never shows
                    // (r9tdclone, ParamSubstituteComplex). Same shape as the
                    // pkgTd9 rule right above: a package typedef's clone keeps
                    // the package instance rather than the instantiating one.
                    UHDM::instance* shInst9 = nullptr;
                    if (ps->getDeclaredType()) {
                        auto& dtS9 = ps->getDeclaredType()->getType();
                        if (dtS9.kind == SymbolKind::TypeAlias)
                            if (auto tS9 = typedefTs.find(&dtS9);
                                tS9 != typedefTs.end() && tS9->second &&
                                tS9->second->Instance())
                                shInst9 =
                                    (UHDM::instance*)tS9->second->Instance();
                    }
                    if (shInst9)
                        its->Instance(shInst9);
                    else if (auto* par = up->VpiParent())
                        its->Instance((UHDM::instance*)par);
                }
            }
            // A fresh ELAB enum clone of a MODULE-scoped named enum typedef
            // (localparam enum_e P) carries vpiInstance = this module instance,
            // like the struct/union clones above (Surelog). Package-scoped
            // params are Instanced at their package below.
            if (its->UhdmType() == UHDM::uhdmenum_typespec && !its->Instance() &&
                ps->getParentScope() &&
                ps->getParentScope()->asSymbol().kind != SymbolKind::Package)
                if (auto* par = up->VpiParent())
                    its->Instance((UHDM::instance*)par);
            // An imported param's typespec is INSTANCED at its package — but
            // NOT a plain UNTYPED (implicit) integral import, whose int_typespec
            // stays Instance-less in both views (Surelog; fail_detect_width).
            bool implicitImport9 =
                !typedParam && ps->getDeclaredType() &&
                ps->getDeclaredType()->getTypeSyntax() &&
                ps->getDeclaredType()->getTypeSyntax()->kind ==
                    syntax::SyntaxKind::ImplicitType;
            // ...and the package it reaches is the ELABORATED (top) one:
            // typespec::Compare recurses vpiInstance, so a DEF-view instance
            // drags the unelaborated package (symbolic typespec bounds) into
            // every module comparison that follows this typespec
            // (LogicArrayParam/IntegerConcat TopMod r=-32). Same rule as the
            // def-view materialized-import site (~4834).
            if (!implicitImport9 && ps->getParentScope() &&
                ps->getParentScope()->asSymbol().kind == SymbolKind::Package) {
                const void* home9 = &ps->getParentScope()->asSymbol();
                if (auto tit = pkgTopMap.find(home9); tit != pkgTopMap.end())
                    its->Instance((UHDM::instance*)tit->second);
                else if (auto pit = pkgDefMap.find(home9);
                         pit != pkgDefMap.end()) {
                    its->Instance((UHDM::instance*)pit->second);
                    pkgImportTsTopFixups.emplace_back(its, home9);
                }
            }
        }
        syntaxRefPrefix = savedPfx2;
        // Surelog's ELAB param_assign RHS constant refers to the MODULE DEF's
        // parameter typespec OBJECT -- literally the same object the def-view
        // parameter binds -- not to a per-instance clone (measured over the
        // whole golden cache: 538k shared vs 50k distinct). Sharing is
        // invisible to uhdm-cmp in the folded model, which is why the clone
        // survived this long, but under -elabuhdm it is load-bearing: the
        // param_assign is the ONLY edge by which ElaboratorListener reaches a
        // def-view typespec from inside an instance, so sharing is what binds
        // the ref_objs in that typespec's ranges to THIS instance's parameters
        // (leaveRef_obj -> bindAny), and UhdmAdjuster::leaveOperation then
        // folds them. Unshared, the def range stays unbound and unfolded:
        // PartSelect4 `bit [N*4-1:0]` keeps N*4 where Surelog has 32, and
        // UnsizedParam's `my_type_t` keeps an unbound X-1.
        // Read the object the DEF-view parameter actually BINDS, never the
        // defMap.paramTs entry: paramTs can hold a clone the def view then
        // discarded in favour of a shared package typespec, and pointing an
        // elab ref at that discarded clone resurrects a whole orphan subtree
        // into the dump (ParameterInitializedInTopOf5LevelHierarchy TargetCfg).
        const DefinitionSymbol* defSym9 = nullptr;
        if (auto* psc9 = ps->getParentScope();
            psc9 && psc9->asSymbol().kind == SymbolKind::InstanceBody)
            defSym9 = &psc9->asSymbol()
                           .as<InstanceBodySymbol>()
                           .getDefinition();
        auto defParamTs = [&]() -> UHDM::typespec* {
            if (!defSym9)
                return nullptr;
            auto dit9 = defMap.find(defSym9);
            if (dit9 == defMap.end() || !dit9->second.mod ||
                dit9->second.mod->UhdmType() != UHDM::uhdmmodule_inst)
                return nullptr;
            auto* dm9 = (UHDM::module_inst*)dit9->second.mod;
            if (!dm9->Parameters())
                return nullptr;
            // A uniquified instance body owns its OWN ParameterSymbols, so the
            // def object is found by name, not by symbol pointer.
            for (auto* dp9 : *dm9->Parameters())
                if (dp9->UhdmType() == UHDM::uhdmparameter &&
                    dp9->VpiName() == ps->name)
                    if (auto* rt9 = ((UHDM::parameter*)dp9)->Typespec())
                        return rt9->Actual_typespec();
            return nullptr;
        };
        // defParamTs() is only consulted for the def object's NAME below; the
        // IDENTITY is resolved in drainShareDefParamTs, because the def
        // parameter's own typespec is still re-bound by later deferred passes.
        // Park the share rather than binding it here.
        auto shareDefParamTs = [&](UHDM::ref_typespec* rt9) {
            if (defSym9)
                pendingShareDefParamTs.push_back(
                    {rt9, defSym9, std::string(ps->name)});
        };
        // A cont-assign whose LHS is an IMPLICIT (never declared) net does NOT
        // drive Surelog's read rewrite. Measured on a four-way ablation of the
        // UnsizedParam body (Surelog -elabuhdm, `parameter my_type_t Y = '1`
        // in a twice-instantiated submodule, /tmp/r10ab):
        //   assign a = int'(Y);  `a` undeclared        -> SHARED def ts
        //   assign a = int'(Y);  `a` = output int port -> fresh bare ts
        //   assign a = int'(Y);  `a` = logic [31:0]    -> fresh bare ts
        //   no cont-assign at all                      -> SHARED def ts
        // Only the LHS declaration changes across the pair, so the implicit
        // net -- not the port list, not the cast -- is the distinguisher.
        auto caReadThroughRealLhs = [&]() {
            const Scope* body9 = nullptr;
            for (auto* sc9 = ps->getParentScope(); sc9;
                 sc9 = sc9->asSymbol().getParentScope())
                if (sc9->asSymbol().kind == SymbolKind::InstanceBody) {
                    body9 = sc9;
                    break;
                }
            if (!body9)
                return true;
            for (auto& mb9 : body9->members()) {
                if (mb9.kind != SymbolKind::ContinuousAssign)
                    continue;
                auto& asn9 = mb9.as<ContinuousAssignSymbol>().getAssignment();
                if (asn9.kind != ExpressionKind::Assignment)
                    continue;
                auto& ae9 = asn9.as<AssignmentExpression>();
                auto& lhs9 = stripImplicitConv(ae9.left());
                if (lhs9.kind == ExpressionKind::NamedValue) {
                    auto& lsym9 = lhs9.as<NamedValueExpression>().symbol;
                    if (lsym9.kind == SymbolKind::Net &&
                        lsym9.as<NetSymbol>().isImplicit)
                        continue; // implicit LHS: no rewrite
                }
                bool reads9 = false;
                ae9.right().visit(makeVisitor(
                    [&](auto& v9, const NamedValueExpression& nv9) {
                        if (nv9.symbol.name == ps->name)
                            reads9 = true;
                        v9.visitDefault(nv9);
                    }));
                if (reads9)
                    return true;
            }
            return false;
        };
        if (rhsRt && !opClone) {
            // The ELAB UINT-recomputed fold ('1 -> all-ones) of a VECTOR
            // param binds a fresh LOC-LESS bare clone (unparented bounds,
            // no clone parent); BIN-valued folds keep the located ts.
            auto* rc0 = rhsRt->VpiParent();
            bool uintFold = rc0 && rc0->UhdmType() == UHDM::uhdmconstant &&
                            ((UHDM::constant*)rc0)->VpiValue().rfind("UINT:", 0) == 0;
            // A DEGENERATE unbased fill's BIN constant only takes the LOC-LESS
            // bare ts when it was actually SHARED into a reading cont-assign
            // (its parent got re-stamped to that CA). An unshared '0 (used only
            // in an override expr) keeps its LOCATED param ts.
            bool unbasedSharedActive =
                unbasedSharedPaConst.count(ps) && rc0 &&
                rc0->VpiParent() &&
                rc0->VpiParent()->UhdmType() == UHDM::uhdmcont_assign;
            // A RANGED UNTYPED param folded from a REAL literal binds a
            // fresh LOC-LESS bare logic_typespec (realexpr p1).
            bool realFold9 = rc0 && rc0->UhdmType() == UHDM::uhdmconstant &&
                             ((UHDM::constant*)rc0)
                                     ->VpiValue()
                                     .rfind("REAL:", 0) == 0;
            // srlgReadFoldsTs: a BASED (HEX/OCT/BIN) fold takes the bare vec
            // ts too — but ONLY when the param is actually READ. Surelog
            // rewrites the value typespec inside getObject/setRange
            // (CompileHelper.cpp:5417), so a vector param nobody reads keeps
            // its located declaration ts in the elab view as well. Measured
            // on a 6-param ablation (based/unbased/decimal x read/unread):
            // the READ, not the value encoding, is the distinguisher.
            // Package params never go through this path (probe: both pkg
            // views keep the located ts).
            bool readFold9 = rc0 && rc0->UhdmType() == UHDM::uhdmconstant &&
                             ps->getParentScope() &&
                             ps->getParentScope()->asSymbol().kind !=
                                 SymbolKind::Package &&
                             (paramNameIsRead(*ps) || paramCaFoldRead(*ps));
            if (signedBinFoldParams.count(ps) && rc0 &&
                rc0->UhdmType() == UHDM::uhdmconstant) {
                auto* sb9 = s.MakeInt_typespec();
                if (ps->getType().isSigned())
                    sb9->VpiSigned(true);
                rhsRt->Actual_typespec(sb9);
            }
            else if (realFold9 && !typedParam &&
                     ps->getType().getCanonicalType().isIntegral()) {
                auto* lts9 = s.MakeLogic_typespec();
                // Surelog's bare logic_typespec carries a LOC-LESS range
                // mirroring the param's packed [7:0] — loc-less bounds that
                // print only their UINT value (no size/decompile/parent).
                auto& ct9 = ps->getType().getCanonicalType();
                if (ct9.isPackedArray()) {
                    auto fr9 = ct9.getFixedRange();
                    auto* rg9 = s.MakeRange();
                    rg9->VpiParent(lts9);
                    auto mkB9 = [&](int64_t v) -> UHDM::expr* {
                        auto* c = s.MakeConstant();
                        c->VpiValue("UINT:" + std::to_string(v));
                        return c;
                    };
                    rg9->Left_expr(mkB9(fr9.left));
                    rg9->Right_expr(mkB9(fr9.right));
                    auto* rv9 = s.MakeRangeVec();
                    rv9->push_back(rg9);
                    lts9->Ranges(rv9);
                }
                rhsRt->Actual_typespec(lts9);
            }
            // An UNTYPED RANGED param (`parameter [2:1] a`) takes the same
            // rewrite — the setRange gate is the VALUE's range, not the
            // declaration form — but only through the READ, never through the
            // bare uintFold/unbased shapes (HighLow).
            //
            // ...and the READ is the ONLY trigger: `uintFold` (the '1 ->
            // all-ones recompute) was an over-approximation measured on read
            // params. Ablation (probe r9hilo p4, one `sub` instance, each
            // param declared once and read by at most one cont-assign):
            //   parameter bit   [4:0] B1 = '1     unread -> bit_typespec  LOC
            //   parameter bit   [4:0] B2 = '1     read   -> logic_typespec BARE
            //   parameter logic [4:0] L1 = '1     unread -> logic_typespec LOC
            //   parameter logic [4:0] L2 = '1     read   -> logic_typespec BARE
            //   parameter bit   [4:0] B3 = 5'd7   unread -> bit_typespec  LOC
            //   parameter bit   [4:0] B4 = 5'd7   read   -> logic_typespec BARE
            //   parameter       [4:0] R1 = '1     unread -> int_typespec  LOC
            //   parameter       [4:0] R2 = '1     read   -> logic_typespec BARE
            // An OVERRIDDEN param keeps its located ts even when read (probe
            // p5, the same eight declarations with #(.B1(5'd9), ...)), which
            // is what the isOverriddenParam guard already says.
            // ...and a param typed by a NAMED vector typedef whose only reads
            // go through implicit-net cont-assigns is never rewritten at all:
            // it keeps the SHARED def object (UnsizedParam Y). See
            // caReadThroughRealLhs for the ablation that isolates this.
            else if ((unbasedSharedActive || readFold9) &&
                (typedParam || (readFold9 && isRangedUntypedParam(*ps))) &&
                !isOverriddenParam(*ps) &&
                [&] {
                    auto* d9 = defParamTs();
                    return !d9 || d9->VpiName().empty() ||
                           caReadThroughRealLhs();
                }() &&
                ps->getType().getCanonicalType().isPackedArray()) {
                // A DEGENERATE unbased fill ('0/'x/'z, BIN) binds the SAME
                // loc-less bare vec ts as the '1 (UINT) recompute (Surelog).
                if (auto* bare = makeBareVecParamTs(*ps, /*parentBounds=*/false))
                    rhsRt->Actual_typespec(bare);
            }
            // An IMPORTED vector-typedef param's elab OPERATION Rhs ts ref
            // binds its OWN clone pair (module-prefix scoped), not the param's
            // (Surelog).
            else if ([&] {
                         if (!rc0 || rc0->UhdmType() != UHDM::uhdmoperation)
                             return false;
                         auto d0 = ps->getDeclaredType();
                         if (!d0 ||
                             d0->getType().kind != SymbolKind::TypeAlias)
                             return false;
                         auto& ct9 = ps->getType().getCanonicalType();
                         if (ct9.kind != SymbolKind::PackedArrayType ||
                             !ct9.isIntegral())
                             return false;
                         auto hs9 = d0->getType()
                                        .as<TypeAliasType>()
                                        .getParentScope();
                         return hs9 && hs9->asSymbol().kind ==
                                           SymbolKind::Package &&
                                ps->getParentScope() == hs9;
                     }()) {
                std::string full9(prt->VpiFullName());
                auto dot9 = full9.rfind('.');
                syntaxRefPrefix =
                    dot9 == std::string::npos ? full9 : full9.substr(0, dot9);
                auto* opTs9 = makeParamTs(*ps, typedParam);
                syntaxRefPrefix = savedPfx2;
                rhsRt->Actual_typespec(opTs9);
                opTs9->VpiParent(rhsRt);
            }
            // A TYPEDEF'd vector param INITIALIZED BY a module-local PARAM
            // REF (localparam int8_t int8 = int4): the elab fold's constant
            // binds a FRESH bare int_typespec (signed per the param type),
            // not the param's own typedef clone (typedef_param).
            else if ([&] {
                         if (!typedParam || !rc0 ||
                             rc0->UhdmType() != UHDM::uhdmconstant)
                             return false;
                         auto d0 = ps->getDeclaredType();
                         if (!d0 ||
                             d0->getType().kind != SymbolKind::TypeAlias)
                             return false;
                         if (!ps->getType().getCanonicalType().isPackedArray())
                             return false;
                         auto init9 = ps->getInitializer();
                         if (!init9)
                             return false;
                         auto& si9 = stripImplicitConv(*init9);
                         if (si9.kind != ExpressionKind::NamedValue)
                             return false;
                         auto& sym9 = si9.as<NamedValueExpression>().symbol;
                         return sym9.kind == SymbolKind::Parameter &&
                                sym9.getParentScope() &&
                                sym9.getParentScope()->asSymbol().kind !=
                                    SymbolKind::Package;
                     }()) {
                auto* bi9 = s.MakeInt_typespec();
                if (ps->getType().getCanonicalType().isSigned())
                    bi9->VpiSigned(true);
                rhsRt->Actual_typespec(bi9);
            }
            // Default: SHARE the module def's parameter typespec object (see
            // the defParamTs note above). `its` is bound as the fallback the
            // final drain keeps if the def view has no matching object.
            else {
                rhsRt->Actual_typespec(its);
                shareDefParamTs(rhsRt);
            }
        }
        prt->Actual_typespec(its);
        elabParamOwnTs[ps] = its;
        // Bind (and drop) any op ts refs parked by an elab pattern SUBSTITUTION
        // of THIS parameter. Dropping matters: a second instance of the same
        // module parks its own refs and must not be handed this instance's
        // clone.
        if (!pendingSubstOpTs.empty()) {
            std::vector<std::pair<const ParameterSymbol*, UHDM::ref_typespec*>>
                keep9;
            for (auto& [sp9, rt9] : pendingSubstOpTs) {
                if (sp9 == ps)
                    rt9->Actual_typespec(its);
                else
                    keep9.push_back({sp9, rt9});
            }
            pendingSubstOpTs.swap(keep9);
        }
        if (!sharedPkgTs)
            its->VpiParent(prt);
        // Record this ELAB struct/union param clone so a bare-package-typedef
        // aggregate param's DEF view can SHARE it (shareDefAggParamTs), rather
        // than mint its own def-scoped clone (Surelog: one clone per param).
        if (its->UhdmType() == UHDM::uhdmstruct_typespec ||
            its->UhdmType() == UHDM::uhdmunion_typespec)
            if (auto* ob9 = paramOwnerBody(*ps))
                elabAggParamClone[{&ob9->getDefinition(),
                                   std::string(ps->name)}] = its;
        // Unbased-unsized override pa constant ts (see unbasedOvTsRef).
        if (auto uit = unbasedOvTsRef.find(ps); uit != unbasedOvTsRef.end()) {
            uit->second->Actual_typespec(its);
            unbasedOvTsRef.erase(uit);
        }
        if (auto cit = unbasedOvCloneTsRef.find(ps);
            cit != unbasedOvCloneTsRef.end()) {
            for (auto* ubRt : cit->second) {
                std::string savedPfx3 = syntaxRefPrefix;
                syntaxRefPrefix = std::string(ubRt->VpiFullName());
                auto* ubTs = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
                syntaxRefPrefix = savedPfx3;
                ubRt->Actual_typespec(ubTs);
                ubTs->VpiParent(ubRt);
            }
            unbasedOvCloneTsRef.erase(cit);
        }
        // No-default override fold-constant ts refs take the same SHARED def
        // object as an ordinary Rhs constant (defParamTs above): a no-default
        // param is exactly the overridden case, and PartSelect4's
        // `bit [N*4-1:0] DReqDepth` reaches its def typespec only here.
        if (auto nit = noDefOvTsRef.find(ps); nit != noDefOvTsRef.end()) {
            for (auto* r0 : nit->second) {
                r0->Actual_typespec(its);
                shareDefParamTs(r0);
            }
            noDefOvTsRef.erase(nit);
        }
        // A param used as a cast width hangs a vpiExpr ref on its def-view
        // ts; the elab ts SHARES that ref_obj.
        if (its->UhdmType() == UHDM::uhdmint_typespec) {
            if (auto psc = ps->getParentScope();
                psc && psc->asSymbol().kind == SymbolKind::InstanceBody) {
                auto dit = defMap.find(
                    &psc->asSymbol().as<InstanceBodySymbol>().getDefinition());
                if (dit != defMap.end())
                    if (auto pit = dit->second.paramTs.find(ps);
                        pit != dit->second.paramTs.end() &&
                        pit->second->UhdmType() == UHDM::uhdmint_typespec)
                        if (auto* ce =
                                ((UHDM::int_typespec*)pit->second)->Cast_to_expr())
                            ((UHDM::int_typespec*)its)->Cast_to_expr(ce);
            }
        }
        (void)up;
    }
}

// Point every parked elab param_assign Rhs ts ref at the module DEF
// parameter's FINAL typespec object -- Surelog's elab override constants refer
// to the def object rather than to a per-instance clone, which is what lets
// UHDM's ElaboratorListener reach a def-view typespec from inside an instance
// and bind (then fold) the parameter refs in its ranges. Runs last because the
// def parameter's own typespec is still re-bound by several deferred passes;
// a ref parked here keeps the elab clone it already has whenever the def view
// ends up with no object, or with one of a different kind (a shape change
// means the elab value was retyped and owns its typespec).
void UhdmExporter::drainShareDefParamTs() {
    for (auto& e : pendingShareDefParamTs) {
        auto dit = defMap.find(e.def);
        if (dit == defMap.end() || !dit->second.mod ||
            dit->second.mod->UhdmType() != UHDM::uhdmmodule_inst)
            continue;
        auto* dm = (UHDM::module_inst*)dit->second.mod;
        if (!dm->Parameters())
            continue;
        for (auto* dp : *dm->Parameters()) {
            if (dp->UhdmType() != UHDM::uhdmparameter || dp->VpiName() != e.name)
                continue;
            auto* drt = ((UHDM::parameter*)dp)->Typespec();
            UHDM::typespec* dts = drt ? drt->Actual_typespec() : nullptr;
            auto* cur = e.rt->Actual_typespec();
            if (dts && cur && dts != cur && dts->UhdmType() == cur->UhdmType())
                e.rt->Actual_typespec(dts);
            break;
        }
    }
    pendingShareDefParamTs.clear();
}

// Deferred DEF-view aggregate-typedef param ts: bind the SHARED named typedef
// typespec now that emitTypedefs has populated typedefTs. The shared object
// keeps its own parent/instance. Falls back to a fresh makeParamTs when the
// typedef wasn't materialized (mirrors the non-deferred path).
void UhdmExporter::drainDefParamTs() {
    for (auto& pd : pendingDefParamTs) {
        UHDM::typespec* its = nullptr;
        bool sharedTs = false;
        bool bareAggPkgTd = false;
        if (auto d0 = pd.ps->getDeclaredType()) {
            auto& dt0 = d0->getType();
            // A VECTOR typedef (typedef logic[X-1:0] my_type_t) is CLONED with a
            // Typedef_alias in both views (like struct/union/enum params take the
            // share shortcut) — fall through to makeParamTs for the clone.
            bool vectorAlias =
                dt0.kind == SymbolKind::TypeAlias &&
                dt0.getCanonicalType().kind == SymbolKind::PackedArrayType &&
                dt0.getCanonicalType().isIntegral() &&
                // An ALIAS-OF-ALIAS (typedef int8_t char_t) SHARES the
                // typedef ts instead — Surelog builds no usable param clone
                // for it (typedef_param ch).
                dt0.as<TypeAliasType>().targetType.getType().kind !=
                    SymbolKind::TypeAlias;
            // An aggregate param typed by a PACKAGE typedef named BARE (a
            // wildcard-imported target_cfg_t / flash_req_t) gets a FRESH clone
            // in the DEF view too — exactly the qualification rule the ELAB
            // view applies (patchParamTypespecs). Only a QUALIFIED pkg::T use
            // shares the package's typespec object.
            if (!pd.inPackage && dt0.kind == SymbolKind::TypeAlias) {
                auto ck0 = dt0.getCanonicalType().kind;
                if (ck0 == SymbolKind::PackedStructType ||
                    ck0 == SymbolKind::PackedUnionType ||
                    ck0 == SymbolKind::UnpackedStructType) {
                    bool qualified0 = false;
                    if (auto* tsyn0 = d0->getTypeSyntax();
                        tsyn0 && tsyn0->kind == syntax::SyntaxKind::NamedType)
                        qualified0 =
                            tsyn0->as<syntax::NamedTypeSyntax>().name->kind ==
                            syntax::SyntaxKind::ScopedName;
                    if (!qualified0)
                        if (auto* sc0 =
                                dt0.as<TypeAliasType>().getParentScope();
                            sc0 && sc0->asSymbol().kind == SymbolKind::Package)
                            bareAggPkgTd = true;
                }
            }
            // A TOP-view package param shares its OWN view's typedef object
            // (the module-scoped clone with folded member bounds), not the
            // def-view one — Surelog's top package param_assign Lhs typespec
            // is the top typedef (TypedefStructParamWithRangeInSubmodule).
            bool topPkgView = pd.inPackage && pd.m &&
                              pd.m->UhdmType() == UHDM::uhdmpackage &&
                              ((UHDM::package*)pd.m)->VpiTop();
            if (topPkgView && !vectorAlias)
                if (auto tit0 = pkgTopTypedefTs.find((const void*)&dt0);
                    tit0 != pkgTopTypedefTs.end()) {
                    its = tit0->second;
                    sharedTs = true;
                }
            if (!its)
                if (auto tit = typedefTs.find(&dt0);
                    tit != typedefTs.end() && !vectorAlias && !bareAggPkgTd) {
                    its = tit->second;
                    sharedTs = true;
                }
        }
        if (!its) {
            std::string savedPfx2 = syntaxRefPrefix;
            const Scope* savedCS = currentScope;
            syntaxRefPrefix = pd.refFullName;
            defViewParamTs = true;
            if (!currentScope)
                currentScope = pd.ps->getParentScope();
            // A DEF-view aggregate CLONE is shaped like the elab one: member
            // leaf typespecs parent at their ref_typespec, and folded
            // package-param member bounds carry Surelog's size/typespec meta.
            auto pck0 = pd.ps->getType().getCanonicalType().kind;
            bool aggClone0 = pck0 == SymbolKind::PackedStructType ||
                             pck0 == SymbolKind::PackedUnionType ||
                             pck0 == SymbolKind::UnpackedStructType;
            if (aggClone0)
                structCloneMemberRefParent = true;
            its = makeParamTs(*pd.ps, pd.typedParam);
            structCloneMemberRefParent = false;
            if (aggClone0)
                attachFoldedBoundMeta(its, (UHDM::instance*)its->Instance());
            defViewParamTs = false;
            currentScope = savedCS;
            syntaxRefPrefix = savedPfx2;
        }
        if (pd.inPackage && !sharedTs && pd.typedParam)
            its->Instance((UHDM::instance*)pd.m);
        if (pd.di)
            pd.di->paramTs[pd.member] = its;
        if (pd.rhsRt)
            pd.rhsRt->Actual_typespec(its);
        pd.prt->Actual_typespec(its);
        if (!sharedTs && pd.typedParam)
            its->VpiParent(pd.up);
        // A bare-package-typedef aggregate param defers to SHARE its ELAB
        // clone: Surelog emits ONE struct/union clone per param (parented at
        // the elab ref, pkg-instanced) that BOTH the def and elab views use.
        // The fresh def clone minted above is a fallback for an uninstantiated
        // def; shareDefAggParamTs re-points these refs once the elab clone
        // exists (5-level-hierarchy / parameter-passed-down families).
        if (bareAggPkgTd)
            if (auto* ob = paramOwnerBody(*pd.ps))
                pendingDefAggShare.push_back({pd.prt, pd.rhsRt, pd.di,
                                              pd.member, &ob->getDefinition(),
                                              std::string(pd.ps->name)});
    }
    pendingDefParamTs.clear();
}

// Re-point deferred def-view bare-package-typedef aggregate param refs at the
// single ELAB clone Surelog shares across both views. Leaves the fresh def
// clone (now unreferenced) out of the dump; keeps it only when the def was
// never elaborated (no matching elab clone).
void UhdmExporter::shareDefAggParamTs() {
    for (auto& e : pendingDefAggShare) {
        auto it = elabAggParamClone.find({e.def, e.name});
        if (it == elabAggParamClone.end())
            continue;
        auto* elab = it->second;
        if (e.prt)
            e.prt->Actual_typespec(elab);
        if (e.rhsRt)
            e.rhsRt->Actual_typespec(elab);
        if (e.di && e.member)
            e.di->paramTs[e.member] = elab;
    }
    pendingDefAggShare.clear();
}

// A fold whose init chain (through param refs) lands on an ENUM VALUE takes
// the enum literal's source HEX form (8'hCC / HEX:CC / constType 5) — Surelog.
// Returns true when the recode applied.
bool UhdmExporter::enumOriginHexRecode(UHDM::constant* c,
                                       const Expression* init) {
    if (!init)
        return false;
    const Expression* ce = &stripImplicitConv(*init);
    const Expression* evInit = nullptr;
    for (int g = 0; ce && g < 8; g++) {
        if (ce->kind != ExpressionKind::NamedValue)
            break;
        auto& sym2 = ce->as<NamedValueExpression>().symbol;
        if (sym2.kind == SymbolKind::EnumValue) {
            evInit = sym2.as<EnumValueSymbol>().getInitializer();
            break;
        }
        if (sym2.kind != SymbolKind::Parameter)
            break;
        auto* ini2 = sym2.as<ParameterSymbol>().getInitializer();
        ce = ini2 ? &stripImplicitConv(*ini2) : nullptr;
    }
    if (!evInit)
        return false;
    std::string lit = rawText(stripImplicitConv(*evInit).sourceRange);
    while (!lit.empty() && (unsigned char)lit.back() <= ' ')
        lit.pop_back();
    while (!lit.empty() && (unsigned char)lit.front() <= ' ')
        lit.erase(lit.begin());
    auto hp = lit.find("'h");
    if (hp == std::string::npos)
        hp = lit.find("'H");
    if (hp == std::string::npos)
        return false;
    std::string digits = lit.substr(hp + 2);
    for (auto& ch : digits)
        ch = (char)toupper((unsigned char)ch);
    c->VpiValue("HEX:" + digits);
    c->VpiConstType(vpiHexConst);
    c->VpiDecompile(lit);
    return true;
}

// A pkg-param fold whose init chain (through param REFERENCES, across package
// boundaries) lands on a BASED integer literal takes that literal's SOURCE
// encoding, exactly as the enum-value chain above takes the enum literal's.
// Surelog reduces `parameter bit [N-1:0] X = other_pkg::X;` by substituting
// the referenced parameter's own compiled constant, which still carries the
// base it was written in (20'b0110... -> BIN:0110... / vpiBinaryConst /
// decompile "20'b0110..."), never a re-decimalised UINT (LogicArrayParam).
// A DIRECT literal init is already handled by the emitter's own literal paths,
// so at least one reference hop is required here.
bool UhdmExporter::paramOriginBaseRecode(UHDM::constant* c,
                                         const Expression* init) {
    if (!init)
        return false;
    const Expression* ce = &stripImplicitConv(*init);
    const Expression* lit0 = nullptr;
    for (int g = 0; ce && g < 8; g++) {
        if (ce->kind != ExpressionKind::NamedValue)
            break;
        auto& sym2 = ce->as<NamedValueExpression>().symbol;
        if (sym2.kind != SymbolKind::Parameter)
            break;
        auto* ini2 = sym2.as<ParameterSymbol>().getInitializer();
        if (!ini2)
            break;
        ce = &stripImplicitConv(*ini2);
        if (ce->kind == ExpressionKind::IntegerLiteral) {
            lit0 = ce;
            break;
        }
    }
    if (!lit0)
        return false;
    std::string lit = stripSep(std::string(rawText(lit0->sourceRange)));
    auto tick = lit.find('\'');
    if (tick == std::string::npos)
        return false;
    size_t bp = tick + 1;
    if (bp < lit.size() && (lit[bp] == 's' || lit[bp] == 'S'))
        bp++;
    if (bp >= lit.size())
        return false;
    std::string digits = lit.substr(bp + 1);
    if (digits.empty())
        return false;
    switch ((char)tolower((unsigned char)lit[bp])) {
        case 'b':
            c->VpiValue("BIN:" + digits);
            c->VpiConstType(vpiBinaryConst);
            break;
        case 'h':
            for (auto& ch : digits)
                ch = (char)toupper((unsigned char)ch);
            c->VpiValue("HEX:" + digits);
            c->VpiConstType(vpiHexConst);
            break;
        case 'o':
            c->VpiValue("OCT:" + digits);
            c->VpiConstType(vpiOctConst);
            break;
        case 'd':
            c->VpiValue("DEC:" + digits);
            c->VpiConstType(vpiDecConst);
            break;
        default:
            return false;
    }
    c->VpiDecompile(lit);
    return true;
}

void UhdmExporter::analyzeParamEnc(const Scope& body) {
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Parameter)
            continue;
        auto& ps = member.as<ParameterSymbol>();
        if (auto init = ps.getInitializer()) {
            if (init->kind != ExpressionKind::IntegerLiteral && isIntEncoded(*init))
                paramIntEnc[&member] = true;
            // A subtract init (localparam W = X-1) is signed arithmetic, so a
            // bare reference to W as a range bound folds to a signed INT
            // constant — mirroring the direct-subtract-bound rule.
            else if (auto& si = stripImplicitConv(*init);
                     si.kind == ExpressionKind::BinaryOp &&
                     si.as<BinaryExpression>().op == BinaryOperator::Subtract)
                paramIntEnc[&member] = true;
        }
    }
}

// After the def/top member cross-wire swap, each swapped-in FOLDED member
// packed_array_typespec bound that came from a package-param identifier
// ([K:0]) gets Surelog's metadata: vpiSize:32 + a vpiTypespec ref to a
// FRESH int_typespec (the source param's type, instance-less). The ref
// fullname copies the member's typespec fullname (rewritten to work@<mod>
// form later, in the module typedef-listing pass).
void UhdmExporter::attachFoldedBoundMeta(UHDM::typespec* container,
                                         UHDM::instance* pkgInst) {
    UHDM::VectorOftypespec_member* mems = nullptr;
    if (container->UhdmType() == UHDM::uhdmstruct_typespec)
        mems = ((UHDM::struct_typespec*)container)->Members();
    else if (container->UhdmType() == UHDM::uhdmunion_typespec)
        mems = ((UHDM::union_typespec*)container)->Members();
    if (!mems)
        return;
    for (auto* tmM : *mems) {
        if (!tmM->Typespec())
            continue;
        auto* mAct = tmM->Typespec()->Actual_typespec();
        if (!mAct || mAct->UhdmType() != UHDM::uhdmpacked_array_typespec)
            continue;
        auto* pats = (UHDM::packed_array_typespec*)mAct;
        if (!pats->Ranges())
            continue;
        std::string memFN(tmM->Typespec()->VpiFullName());
        for (auto* rg : *pats->Ranges())
            for (UHDM::expr* be : {rg->Left_expr(), rg->Right_expr()}) {
                if (!be || be->UhdmType() != UHDM::uhdmconstant)
                    continue;
                auto* c = (UHDM::constant*)be;
                auto fit = foldedMemberBoundParam.find(c);
                if (fit == foldedMemberBoundParam.end())
                    continue;
                const Symbol* psym = fit->second;
                c->VpiSize(32);
                auto* its2 = s.MakeInt_typespec();
                if (psym->kind == SymbolKind::Parameter) {
                    auto& psp = psym->as<ParameterSymbol>();
                    bool implicitSrc = false;
                    if (auto dt0 = psp.getDeclaredType())
                        if (auto* ts0 = dt0->getTypeSyntax())
                            implicitSrc =
                                ts0->kind == syntax::SyntaxKind::ImplicitType;
                    // An UNTYPED source param leaves this synthesized ts
                    // UNSIGNED (Surelog), even though its value type is int.
                    if (!implicitSrc && psp.getType().getCanonicalType().isSigned())
                        its2->VpiSigned(true);
                    if (auto dt = psp.getDeclaredType())
                        if (auto* tsyn = dt->getTypeSyntax()) {
                            // An UNTYPED source param (parameter K = 8)
                            // spans its whole DECLARATION, like every
                            // other untyped param int_typespec (Surelog).
                            if (tsyn->kind == syntax::SyntaxKind::ImplicitType) {
                                for (auto q = psp.getSyntax(); q; q = q->parent)
                                    if (q->kind ==
                                        syntax::SyntaxKind::ParameterDeclaration) {
                                        setLoc(its2, q->sourceRange());
                                        break;
                                    }
                            }
                            else
                                setLoc(its2, tsyn->sourceRange());
                        }
                    // vpiInstance follows the source param's TYPING: a TYPED
                    // one (parameter int K) carries the package; an UNTYPED
                    // one stays instance-less — the same typed/untyped split
                    // the param's own int_typespec follows (Surelog).
                    if (!implicitSrc)
                        its2->Instance(pkgInst);
                }
                auto* rt2 = s.MakeRef_typespec();
                rt2->VpiParent(c);
                rt2->VpiFullName(memFN);
                rt2->Actual_typespec(its2);
                its2->VpiParent(rt2);
                c->Typespec(rt2);
            }
    }
}

const Symbol* UhdmExporter::importShadowOf(const Symbol& ta) {
    if (ta.kind != SymbolKind::TypeAlias)
        return nullptr;
    auto* sc = ta.getParentScope();
    if (!sc || sc->asSymbol().kind != SymbolKind::Package)
        return nullptr;
    for (auto& mem : sc->asSymbol().as<PackageSymbol>().members()) {
        if (mem.kind != SymbolKind::WildcardImport)
            continue;
        auto* sp = mem.as<WildcardImportSymbol>().getPackage();
        if (!sp)
            continue;
        for (auto& pm : sp->members())
            if (pm.kind == SymbolKind::TypeAlias && pm.name == ta.name)
                return &pm;
    }
    return nullptr;
}

UHDM::package* UhdmExporter::emitPackage(const PackageSymbol& pkg, bool topView) {
    std::string prefix = std::string(pkg.name) + "::";
    auto* up = s.MakePackage();
    if (!topView)
        pkgDefMap[&pkg] = up;
    else
        pkgTopMap[&pkg] = up;
    up->VpiName(pkg.name);
    up->VpiFullName(prefix);
    up->VpiDefName(pkg.name);
    up->VpiParent(d);
    up->VpiFile(fullFilePath(pkg.location));
    if (topView)
        up->VpiTop(true);
    if (auto syn = pkg.getSyntax()) {
        setLoc(up, syn->sourceRange());
        // endpackage : name -> vpiEndLabel.
        if (syntax::ModuleDeclarationSyntax::isKind(syn->kind))
            if (auto* bn = syn->as<syntax::ModuleDeclarationSyntax>().blockName)
                up->VpiEndLabel(bn->name.valueText());
    }
    NetMap none;
    auto savedPkgViewVars0 = pkgViewVarObjs9;
    auto* savedCurPkg0 = curPkgEmitSym;
    bool savedPkgTopView0 = pkgEmitTopView;
    curPkgEmitSym = &pkg;
    pkgEmitTopView = topView;
    // Package-scope cast typespecs (size-literal integer_typespecs) carry
    // vpiInstance = the package (Surelog); expose it during param emission.
    auto* savedPkgInst0 = pkgScopeInst;
    pkgScopeInst = (UHDM::instance*)up;
    // Package params take part in the INT-encoding chain exactly as module
    // ones do: kmac_pkg's BufferCycles is a `/` fold (INT), so the
    // RegIntfWidth * BufferCycles that READS it reduces to INT too. Without
    // this the package side of the chain silently reverted to UINT.
    analyzeParamEnc(pkg);
    // Rebuilt per view: a paren-param size cast reuses THIS view's parameter
    // typespec object (see pkgScopeParamTs).
    auto savedPkgParamTs0 = pkgScopeParamTs;
    pkgScopeParamTs.clear();
    emitParameters(pkg, up, prefix, none, topView, nullptr, true);
    pkgScopeParamTs = savedPkgParamTs0;
    pkgScopeInst = savedPkgInst0;
    // Package typedefs: struct/enum/vector typespecs named pkg::T, parented and
    // instanced at the package, populating typedefTs so package-typedef'd
    // signals/params resolve.
    auto* tds = s.MakeTypespecVec();
    pkgTopEmit = topView; // enum-const decompile is view-dependent (buildEnumTs)
    inPkgTypedefEmit = true;
    // Package typedefs are CREATED in source order (so intra-package
    // references resolve via typedefTs) but LISTED name-sorted (Surelog).
    std::vector<const Symbol*> pkgAliases;
    for (auto& member : pkg.members())
        if (member.kind == SymbolKind::TypeAlias)
            pkgAliases.push_back(&member);
    // Typedefs that are the TARGET of a same-package ALIAS-of-typedef
    // (typedef imm_i_t imm_l_t; typedef op32_op62_et opc_t;). Surelog
    // materialises their ELABORATED listing object while re-elaborating the
    // alias — i.e. still in def-package context — so that object keeps the
    // DEF vpiInstance (jeras_union imm_i_t/op32_op62_et; the aliases
    // themselves are single def objects to begin with).
    std::set<const Symbol*> aliasTargetTd9;
    for (auto& m9 : pkg.members())
        if (m9.kind == SymbolKind::TypeAlias) {
            auto& tt9 = m9.as<TypeAliasType>().targetType.getType();
            if (tt9.kind == SymbolKind::TypeAlias &&
                tt9.getParentScope() == (const Scope*)&pkg)
                aliasTargetTd9.insert((const Symbol*)&tt9.as<TypeAliasType>());
        }
    std::vector<std::pair<std::string, UHDM::typespec*>> pkgTdByName;
    // Class-handle typedefs of the ELABORATED view: (name, its class_typespec,
    // the GENERIC CLASS SYMBOL they share).  Resolved into base + aliased
    // clones after the loop, once every name is known.  The key is the slang
    // symbol, not the UHDM class_defn, because the package's class_defns do
    // not exist yet while this loop runs (emitPackageClasses is called after
    // it, so every Class_defn here is still a pendingClassTsLink).
    std::vector<std::tuple<std::string, UHDM::class_typespec*, const void*>>
        pkgClassTd9;
    // A package IMPORTING another package lists the imported ENUM typedefs
    // as ONE shared clone per typedef (created on first sight; module import
    // listings share it) plus an import_typespec per import item (after the
    // sorted typedefs).
    std::vector<UHDM::typespec*> importTss;
    if (true) {
        for (auto& mem : pkg.members()) {
            std::string_view pn;
            if (mem.kind == SymbolKind::WildcardImport)
                pn = mem.as<WildcardImportSymbol>().packageName;
            else if (mem.kind == SymbolKind::ExplicitImport)
                pn = mem.as<ExplicitImportSymbol>().packageName;
            else
                continue;
            if (auto* spkg = comp.getPackage(pn)) {
                for (auto& pm : spkg->members()) {
                    if (pm.kind != SymbolKind::TypeAlias)
                        continue;
                    auto& ta2 = pm.as<TypeAliasType>();
                    auto& ct2 = ta2.getCanonicalType();
                    if (ct2.kind != SymbolKind::EnumType &&
                        ct2.kind != SymbolKind::PackedStructType &&
                        ct2.kind != SymbolKind::UnpackedStructType)
                        continue;
                    // ONE clone per imported typedef, shared by every module
                    // import listing (direct and transitive) — created here
                    // (the home pkg emitted earlier in source order).
                    UHDM::enum_typespec* cl2 = nullptr;
                    if (auto cit2 = pkgImportCloneTs.find(&pm);
                        cit2 != pkgImportCloneTs.end())
                        cl2 = (UHDM::enum_typespec*)cit2->second;
                    else {
                        const syntax::SyntaxNode* dSyn2 = ta2.getSyntax();
                        const syntax::SyntaxNode* tSyn2 = nullptr;
                        if (dSyn2 && dSyn2->kind ==
                                         syntax::SyntaxKind::TypedefDeclaration)
                            tSyn2 = dSyn2->as<syntax::TypedefDeclarationSyntax>()
                                        .type;
                        std::string nm2 =
                            std::string(pn) + "::" + std::string(ta2.name);
                        if (ct2.kind == SymbolKind::PackedStructType ||
                            ct2.kind == SymbolKind::UnpackedStructType) {
                            bool pkc2 =
                                ct2.kind == SymbolKind::PackedStructType;
                            auto* scl =
                                pkc2 ? buildStructTs(ct2.as<PackedStructType>(),
                                                     true, nm2, "::")
                                     : buildStructTs(
                                           ct2.as<UnpackedStructType>(), false,
                                           nm2, "::");
                            scl->VpiName(nm2);
                            if (tSyn2)
                                setLoc(scl, tSyn2->sourceRange());
                            scl->Instance((UHDM::instance*)up);
                            // The clone's MEMBER typespecs stay instanced at
                            // the struct's HOME package (Surelog) — only the
                            // clone itself moves to the importing package.
                            if (auto hip3 = pkgDefMap.find(&spkg->asSymbol());
                                hip3 != pkgDefMap.end()) {
                                std::function<void(UHDM::typespec*)> stampHome =
                                    [&](UHDM::typespec* t3) {
                                        if (!t3 ||
                                            t3->UhdmType() !=
                                                UHDM::uhdmstruct_typespec)
                                            return;
                                        auto* ms3 =
                                            ((UHDM::struct_typespec*)t3)
                                                ->Members();
                                        if (!ms3)
                                            return;
                                        for (auto* tm3 : *ms3) {
                                            if (!tm3->Typespec())
                                                continue;
                                            auto* at3 =
                                                tm3->Typespec()
                                                    ->Actual_typespec();
                                            if (!at3)
                                                continue;
                                            // FRESH (unnamed) scalar member
                                            // typespecs take the HOME pkg
                                            // instance too (rp32 isa_base_t
                                            // clone `bit E` members).
                                            if (at3->Instance() ||
                                                at3->VpiName().empty())
                                                at3->Instance(hip3->second);
                                            stampHome(at3);
                                        }
                                    };
                                stampHome(scl);
                            }
                            // ...but a member typed by ANOTHER already-cloned
                            // typedef of the same home package binds that
                            // typedef's CLONE, not the home object (rp32
                            // riscv_priv_pkg csr_adr_t.perm -> the isa_i-
                            // instanced csr_perm_t clone). Source order
                            // guarantees the member's clone exists already.
                            if (auto* ms4 = scl->Members())
                                for (auto* tm4 : *ms4) {
                                    if (!tm4->Typespec())
                                        continue;
                                    auto* at4 =
                                        tm4->Typespec()->Actual_typespec();
                                    if (!at4 || at4->VpiName().empty())
                                        continue;
                                    for (auto& [aSym4, cl4] :
                                         pkgImportCloneTs) {
                                        auto hIt4 = typedefTs.find(aSym4);
                                        if (hIt4 != typedefTs.end() &&
                                            hIt4->second == at4 &&
                                            cl4 != at4) {
                                            tm4->Typespec()->Actual_typespec(
                                                cl4);
                                            break;
                                        }
                                    }
                                }
                            pkgImportCloneTs[&pm] = scl;
                            if (!topView)
                                defPassOwnedTs.insert(scl);
                            pkgTdByName.emplace_back(std::string(ta2.name),
                                                     (UHDM::typespec*)scl);
                            continue;
                        }
                        importCloneEmit = true;
                        auto* ecl = buildEnumTs(ct2.as<EnumType>(), tSyn2, nm2);
                        importCloneEmit = false;
                        ecl->VpiName(nm2);
                        if (dSyn2)
                            setLoc(ecl, dSyn2->sourceRange());
                        ecl->Instance((UHDM::instance*)up);
                        if (ecl->Base_typespec() &&
                            ecl->Base_typespec()->Actual_typespec())
                            if (auto hip2 = pkgDefMap.find(&spkg->asSymbol());
                                hip2 != pkgDefMap.end())
                                ecl->Base_typespec()
                                    ->Actual_typespec()
                                    ->Instance(hip2->second);
                        pkgImportCloneTs[&pm] = ecl;
                        if (!topView)
                            defPassOwnedTs.insert(ecl);
                        cl2 = ecl;
                    }
                    pkgTdByName.emplace_back(std::string(ta2.name),
                                             (UHDM::typespec*)cl2);
                }
                // The typedefs the enum/struct rule above skips — vector,
                // scalar and class aliases — list too, and TRANSITIVELY: a
                // package that wildcard-imports a package which itself
                // wildcard-imports a third one lists the third's typedefs,
                // named after their OWN home package (PackageOrder: A imports
                // D imports B, and A lists `B::C`).  One clone per typedef is
                // shared by every importer and its vpiParent/vpiInstance
                // follow the LAST package to list it (Surelog's last-writer
                // stamp) — the module-side listing in emitImportArtifacts
                // already ran this rule for all kinds; only the PACKAGE side
                // was enum/struct-only.
                std::vector<const Symbol*> otherTds;
                std::set<const Symbol*> seenPkgs8;
                std::function<void(const PackageSymbol&)> collectOther =
                    [&](const PackageSymbol& p8) {
                        if (!seenPkgs8.insert(&p8).second)
                            return;
                        for (auto& pm8 : p8.members()) {
                            if (pm8.kind == SymbolKind::TypeAlias) {
                                auto& ct8 =
                                    pm8.as<TypeAliasType>().getCanonicalType();
                                if (ct8.kind == SymbolKind::EnumType ||
                                    ct8.kind == SymbolKind::PackedStructType ||
                                    ct8.kind == SymbolKind::UnpackedStructType)
                                    continue;
                                // An EXPLICIT import lists only the named
                                // symbol (the wildcard form lists them all).
                                if (mem.kind == SymbolKind::ExplicitImport &&
                                    mem.as<ExplicitImportSymbol>()
                                            .importedSymbol() != &pm8)
                                    continue;
                                // A local typedef shadowed by a wildcard
                                // import never lists.
                                if (!importShadowOf(pm8))
                                    otherTds.push_back(&pm8);
                            }
                            else if (pm8.kind == SymbolKind::WildcardImport) {
                                if (auto* np8 = pm8.as<WildcardImportSymbol>()
                                                    .getPackage())
                                    collectOther(*np8);
                            }
                        }
                    };
                collectOther(*spkg);
                for (auto* tdSym : otherTds) {
                    auto& ta8 = tdSym->as<TypeAliasType>();
                    auto* home8 = tdSym->getParentScope();
                    if (!home8)
                        continue;
                    UHDM::typespec* cl8 = nullptr;
                    if (auto cit8 = pkgImportCloneTs.find(tdSym);
                        cit8 != pkgImportCloneTs.end())
                        cl8 = cit8->second;
                    else {
                        const syntax::SyntaxNode* dSyn8 = ta8.getSyntax();
                        const syntax::SyntaxNode* tSyn8 = nullptr;
                        if (dSyn8 &&
                            dSyn8->kind ==
                                syntax::SyntaxKind::TypedefDeclaration)
                            tSyn8 = dSyn8->as<syntax::TypedefDeclarationSyntax>()
                                        .type;
                        bypassTypedefShare = true;
                        cl8 = makeTypespec(ta8, tSyn8);
                        bypassTypedefShare = false;
                        if (!cl8)
                            continue;
                        cl8->VpiName(std::string(home8->asSymbol().name) +
                                     "::" + std::string(ta8.name));
                        if (tSyn8)
                            setLoc(cl8, tSyn8->sourceRange());
                        pkgImportCloneTs[tdSym] = cl8;
                        if (!topView)
                            defPassOwnedTs.insert(cl8);
                    }
                    // The last-writer stamp is a DEF-pass effect only: the
                    // elaborated pass re-lists the very same object and leaves
                    // its owner alone, so a shared clone keeps the DEF package
                    // of the last importer (PackageOrder's `B::C` is owned by
                    // def-A even though top-A lists it afterwards).
                    if (!topView || !cl8->Instance()) {
                        cl8->VpiParent(up);
                        cl8->Instance((UHDM::instance*)up);
                    }
                    pkgTdByName.emplace_back(std::string(ta8.name), cl8);
                }
            }
            auto* its2 = s.MakeImport_typespec();
            its2->VpiName(std::string(pn));
            its2->Instance((UHDM::instance*)up);
            if (auto msyn = mem.getSyntax())
                setLoc(its2, msyn->sourceRange());
            // Hidden item constant: "*" (loc-less) or the imported name (at
            // its token). Dump-invisible but uhdm-cmp checked.
            {
                std::string itemName = "*";
                auto* c = s.MakeConstant();
                if (mem.kind == SymbolKind::ExplicitImport) {
                    itemName =
                        std::string(mem.as<ExplicitImportSymbol>().importName);
                    setLoc(c, SourceRange(mem.location,
                                          mem.location + itemName.size()));
                }
                c->VpiDecompile(itemName);
                c->VpiSize((int32_t)itemName.size() * 8);
                c->VpiValue("STRING:" + itemName);
                c->VpiConstType(8); // Surelog's string-const encoding here
                its2->Item(c);
            }
            importTss.push_back(its2);
            // An EXPLICITLY imported SUBROUTINE (import pkg::f) re-emits in
            // this package's scope (prefix-renamed) sharing the HOME
            // function's Return var; calls keep binding the home object.
            if (mem.kind == SymbolKind::ExplicitImport)
                if (auto* is9 = mem.as<ExplicitImportSymbol>().importedSymbol();
                    is9 && is9->kind == SymbolKind::Subroutine &&
                    comp.getPackage(pn)) {
                    UHDM::task_func* homeTf = nullptr;
                    SubInfo homeSi;
                    bool hadHome = false;
                    if (auto sit9 = subMap.find(is9); sit9 != subMap.end()) {
                        homeSi = sit9->second;
                        homeTf = homeSi.tf;
                        hadHome = true;
                    }
                    // The clone's typespecs keep vpiInstance = the HOME
                    // package (where the function is defined), not this
                    // importing package.
                    UHDM::instance* homeInst = nullptr;
                    if (homeTf && homeTf->Instance())
                        homeInst = (UHDM::instance*)homeTf->Instance();
                    else if (auto hip9 =
                                 pkgDefMap.find(&comp.getPackage(pn)->asSymbol());
                             hip9 != pkgDefMap.end())
                        homeInst = (UHDM::instance*)hip9->second;
                    importCopyTsInst = homeInst;
                    std::vector<UHDM::typespec*> copyTss;
                    importCopyTsCollect = &copyTss;
                    emitTaskFuncs(*comp.getPackage(pn), up, prefix, nullptr,
                                  /*sharedScope=*/false, is9);
                    importCopyTsCollect = nullptr;
                    importCopyTsInst = nullptr;
                    // The clone's own typespecs keep vpiInstance = the
                    // ELABORATED (top) home package, resolved after both
                    // package views are built.
                    for (auto* cts : copyTss)
                        importCopyTsFixups.emplace_back(cts, std::string(pn));
                    if (homeTf && up->Task_funcs() &&
                        !up->Task_funcs()->empty()) {
                        auto* cp9 = up->Task_funcs()->back();
                        if (cp9->UhdmType() == UHDM::uhdmfunction &&
                            homeTf->UhdmType() == UHDM::uhdmfunction) {
                            ((UHDM::function*)cp9)
                                ->Return(((UHDM::function*)homeTf)->Return());
                            // A P::f() call through this importing package binds
                            // the ELABORATED clone (top view).
                            if (topView)
                                importCopyFunc[{&pkg, is9}] =
                                    (UHDM::function*)cp9;
                        }
                    }
                    if (hadHome)
                        subMap[is9] = homeSi; // calls bind the home object
                }
        }
    }
    // `typedef pkg1::type_t type_alias;` — the base struct typespec this
    // alias re-names, if it is already built (a NAMED struct_typespec).
    // Null for anything else, so the caller falls through to the normal
    // fresh-struct branch.
    auto structAliasBase = [&](const TypeAliasType& al) -> UHDM::typespec* {
        auto& tgt = al.targetType.getType();
        if (tgt.kind != SymbolKind::TypeAlias)
            return nullptr;
        auto bit = typedefTs.find(&tgt);
        if (bit == typedefTs.end())
            return nullptr;
        auto* base = bit->second;
        if (!base || base->UhdmType() != UHDM::uhdmstruct_typespec ||
            base->VpiName().empty())
            return nullptr;
        return base;
    };
    for (auto* memberP : pkgAliases) {
        auto& member = *memberP;
        auto& ta = member.as<TypeAliasType>();
        // A LOCAL typedef name-shadowed by a WILDCARD-imported typedef never
        // materializes (Surelog's import overwrites the symbol-table entry):
        // no listing entry in either view, and every use binds the IMPORTED
        // typespec (rp32 riscv_isa_i_pkg csr_adr_t -> riscv_priv_pkg's).
        if (auto* sh0 = importShadowOf(member)) {
            if (!topView) {
                if (auto hIt0 = typedefTs.find(sh0); hIt0 != typedefTs.end())
                    typedefTs[&ta] = hIt0->second;
            }
            else if (auto hIt1 = pkgTopTypedefTs.find(
                         (const void*)&sh0->as<TypeAliasType>());
                     hIt1 != pkgTopTypedefTs.end())
                pkgTopTypedefTs[&ta] = hIt1->second;
            else if (auto hIt2 = typedefTs.find(sh0); hIt2 != typedefTs.end())
                pkgTopTypedefTs[&ta] = hIt2->second;
            continue;
        }
        // A package consumed by ANOTHER package SHARES its typedef objects
        // into the top view (Surelog builds no fresh elab clones there);
        // last-writer registry: when an importing package built a CLONE,
        // the top listing points at the CLONE, else at the def object —
        // rp32 riscv_isa_pkg / riscv_priv_pkg.
        if (topView && pkgImportedByPkg.count(&pkg)) {
            UHDM::typespec* share0 = nullptr;
            if (auto cIt0 = pkgImportCloneTs.find(&member);
                cIt0 != pkgImportCloneTs.end())
                share0 = cIt0->second;
            else if (auto dIt0 = typedefTs.find(&ta); dIt0 != typedefTs.end())
                share0 = dIt0->second;
            if (share0) {
                pkgTopTypedefTs[&ta] = share0;
                pkgTdByName.emplace_back(std::string(ta.name), share0);
                continue;
            }
        }
        auto& ct = ta.targetType.getType().getCanonicalType();
        const syntax::SyntaxNode* typeSyn = nullptr;
        if (auto syn = ta.getSyntax())
            if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
                typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
        UHDM::typespec* ts = nullptr;
        // A packed-array-of-AGGREGATE typedef (typedef a[1:0] b, a = struct):
        // a packed_array_typespec with a Typedef_alias (bare clone), the [1:0]
        // Range (UINT bounds), and an Elem ref -> the SHARED element typedef
        // ts — all refs doubled-scoped pkg::pkg::b (Surelog).
        bool aggArray = false;
        if (ct.kind == SymbolKind::PackedArrayType) {
            const Type* el0 = &ct;
            while (el0->getCanonicalType().kind == SymbolKind::PackedArrayType)
                el0 = &el0->getCanonicalType().as<PackedArrayType>().elementType;
            auto& elc = el0->getCanonicalType();
            aggArray = elc.isStruct() || elc.isUnion();
        }
        if (aggArray) {
            // Listed in the TOP package view only (Surelog).
            if (!topView)
                continue;
            auto& pat = ct.as<PackedArrayType>();
            std::string dblName = prefix + prefix + std::string(ta.name);
            auto* outer = s.MakePacked_array_typespec();
            outer->VpiParent(up);
            if (typeSyn)
                setLoc(outer, typeSyn->sourceRange());
            auto* cl = s.MakePacked_array_typespec();
            // The alias-actual clone is LOCATED at the typedef type span,
            // pkg-Instanced, and carries the dim range with token-anchored
            // bounds (Surelog).
            if (typeSyn) {
                setLoc(cl, typeSyn->sourceRange());
                cl->Instance((UHDM::instance*)up);
                std::vector<DimSpan> clSp9;
                {
                    auto full9 = typeSyn->sourceRange();
                    clSp9 = scanDimSpans(std::string(rawText(full9)),
                                         full9.start());
                }
                auto* clr9 = s.MakeRange();
                clr9->VpiParent(cl);
                const DimSpan* cds9 = clSp9.empty() ? nullptr : &clSp9[0];
                if (cds9)
                    setLoc(clr9, cds9->range);
                auto mkB9c = [&](int64_t v9,
                                 const SourceRange* lc9) -> UHDM::expr* {
                    auto* c9 = s.MakeConstant();
                    std::string d9 = std::to_string(v9);
                    c9->VpiDecompile(d9);
                    c9->VpiSize(64);
                    c9->VpiValue("UINT:" + d9);
                    c9->VpiConstType(vpiUIntConst);
                    c9->VpiParent(clr9);
                    if (lc9)
                        setLoc(c9, *lc9);
                    return c9;
                };
                clr9->Left_expr(
                    mkB9c(pat.range.left, cds9 ? &cds9->left : nullptr));
                clr9->Right_expr(
                    mkB9c(pat.range.right, cds9 ? &cds9->right : nullptr));
                auto* clrv9 = s.MakeRangeVec();
                clrv9->push_back(clr9);
                cl->Ranges(clrv9);
            }
            auto* art = s.MakeRef_typespec();
            art->VpiFullName(dblName);
            art->VpiParent(outer);
            art->Actual_typespec(cl);
            outer->Typedef_alias(art);
            auto* rvec = s.MakeRangeVec();
            auto* r = s.MakeRange();
            r->VpiParent(outer);
            auto mkB2 = [&](int64_t v) -> UHDM::expr* {
                auto* c = s.MakeConstant();
                std::string d = std::to_string(v);
                c->VpiDecompile(d);
                c->VpiSize(64);
                c->VpiValue("UINT:" + d);
                c->VpiConstType(vpiUIntConst);
                c->VpiParent(r);
                return c;
            };
            r->Left_expr(mkB2(pat.range.left));
            r->Right_expr(mkB2(pat.range.right));
            rvec->push_back(r);
            outer->Ranges(rvec);
            // Element ref -> the shared element typedef ts (by alias Type, or
            // canonical match).
            const Type* elAl = &pat.elementType;
            UHDM::typespec* ets2 = nullptr;
            if (auto tit = typedefTs.find(elAl); tit != typedefTs.end())
                ets2 = tit->second;
            else
                for (auto& [sym0, tsp0] : typedefTs)
                    if (sym0->kind == SymbolKind::TypeAlias &&
                        &((const Type*)sym0)->getCanonicalType() ==
                            &elAl->getCanonicalType()) {
                        ets2 = tsp0;
                        break;
                    }
            if (ets2) {
                // The alias-actual TWIN also carries a NAMELESS Elem ref to
                // the same shared element ts (Surelog).
                auto* certn = s.MakeRef_typespec();
                certn->VpiParent(cl);
                certn->Actual_typespec(ets2);
                cl->Elem_typespec(certn);
                auto* ert = s.MakeRef_typespec();
                ert->VpiFullName(dblName);
                ert->VpiParent(outer);
                ert->Actual_typespec(ets2);
                outer->Elem_typespec(ert);
            }
            ts = outer;
        }
        else if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType &&
                 (ct.as<FixedSizeUnpackedArrayType>()
                          .elementType.getCanonicalType()
                          .isStruct() ||
                  ct.as<FixedSizeUnpackedArrayType>()
                          .elementType.getCanonicalType()
                          .isUnion())) {
            // typedef of an UNPACKED array of a struct/union typedef
            // (typedef a b[1:0]): a NAMED array_typespec (pkg::b, pkg-parented
            // and -Instanced, listed in the TOP package view only). Its Elem
            // ref (doubled name pkg::pkg::b) binds a fresh NAMED struct clone
            // of the element typedef (pkg::a) with a Typedef_alias -> the
            // shared element ts — mirrors the module emitTypedefs arm.
            if (!topView)
                continue;
            auto& fua = ct.as<FixedSizeUnpackedArrayType>();
            auto* ats = s.MakeArray_typespec();
            ats->VpiParent(up);
            ats->Instance((UHDM::instance*)up);
            SourceLocation aS = ta.location, aE = ta.location;
            if (typeSyn)
                aS = typeSyn->sourceRange().start();
            const syntax::VariableDimensionSyntax* dimSyn = nullptr;
            if (auto dsyn = ta.getSyntax();
                dsyn && dsyn->kind == syntax::SyntaxKind::TypedefDeclaration) {
                auto& td = dsyn->as<syntax::TypedefDeclarationSyntax>();
                if (!td.dimensions.empty()) {
                    dimSyn = td.dimensions[0];
                    aE = td.dimensions[td.dimensions.size() - 1]
                             ->sourceRange()
                             .end();
                }
            }
            setLoc(ats, SourceRange(aS, aE));
            auto* rv = s.MakeRangeVec();
            auto* r = s.MakeRange();
            r->VpiParent(ats);
            const syntax::ExpressionSyntax* lSyn = nullptr;
            const syntax::ExpressionSyntax* rSyn = nullptr;
            const syntax::ExpressionSyntax* szSyn = nullptr;
            if (dimSyn && dimSyn->specifier &&
                dimSyn->specifier->kind ==
                    syntax::SyntaxKind::RangeDimensionSpecifier) {
                auto& sel = *dimSyn->specifier
                                 ->as<syntax::RangeDimensionSpecifierSyntax>()
                                 .selector;
                if (auto* rss = sel.as_if<syntax::RangeSelectSyntax>()) {
                    lSyn = rss->left;
                    rSyn = rss->right;
                }
                else if (auto* bss = sel.as_if<syntax::BitSelectSyntax>())
                    szSyn = bss->expr;
            }
            auto mkB = [&](int64_t v,
                           const syntax::SyntaxNode* bs) -> UHDM::expr* {
                auto* c = s.MakeConstant();
                std::string digits = std::to_string(v);
                c->VpiDecompile(digits);
                c->VpiSize(64);
                c->VpiValue("UINT:" + digits);
                c->VpiConstType(vpiUIntConst);
                c->VpiParent(r);
                if (bs)
                    setLoc(c, bs->sourceRange());
                return c;
            };
            if (szSyn) {
                setLoc(r, szSyn->sourceRange());
                r->Left_expr(mkB(0, nullptr));
                auto* op = s.MakeOperation();
                op->VpiOpType(vpiSubOp);
                op->VpiParent(r);
                setLoc(op, szSyn->sourceRange());
                auto* ops = s.MakeAnyVec();
                auto* nC = mkB(fua.range.width(), szSyn);
                nC->VpiParent(op);
                ops->push_back(nC);
                auto* one = s.MakeConstant();
                one->VpiSize(64);
                one->VpiValue("INT:1");
                one->VpiConstType(vpiIntConst);
                one->VpiParent(op);
                ops->push_back(one);
                op->Operands(ops);
                r->Right_expr(op);
            }
            else {
                if (dimSyn)
                    setLoc(r, dimSyn->sourceRange());
                r->Left_expr(mkB(fua.range.left, lSyn));
                r->Right_expr(mkB(fua.range.right, rSyn));
            }
            rv->push_back(r);
            ats->Ranges(rv);
            const Type* el0 = &fua.elementType;
            UHDM::typespec* ets0 = nullptr;
            if (auto ei = typedefTs.find(el0); ei != typedefTs.end())
                ets0 = ei->second;
            else
                for (auto& [sym0, tsp0] : typedefTs)
                    if (sym0->kind == SymbolKind::TypeAlias &&
                        &((const Type*)sym0)->getCanonicalType() ==
                            &el0->getCanonicalType()) {
                        ets0 = tsp0;
                        break;
                    }
            if (ets0) {
                UHDM::typespec* tgt0 = ets0;
                if (el0->kind == SymbolKind::TypeAlias &&
                    ets0->UhdmType() == UHDM::uhdmstruct_typespec) {
                    auto& ela = el0->as<TypeAliasType>();
                    auto& elc = el0->getCanonicalType();
                    std::string clName = prefix + std::string(ela.name);
                    UHDM::struct_typespec* cl0 =
                        elc.kind == SymbolKind::PackedStructType
                            ? buildStructTs(elc.as<PackedStructType>(), true,
                                            clName)
                            : buildStructTs(elc.as<UnpackedStructType>(), false,
                                            clName);
                    cl0->VpiName(clName);
                    cl0->VpiLineNo(ets0->VpiLineNo());
                    cl0->VpiColumnNo(ets0->VpiColumnNo());
                    cl0->VpiEndLineNo(ets0->VpiEndLineNo());
                    cl0->VpiEndColumnNo(ets0->VpiEndColumnNo());
                    cl0->Instance((UHDM::instance*)up);
                    if (auto* mems = cl0->Members())
                        for (auto* tm : *mems)
                            if (tm->Typespec() &&
                                tm->Typespec()->Actual_typespec())
                                tm->Typespec()->Actual_typespec()->Instance(
                                    (UHDM::instance*)up);
                    auto* art0 = s.MakeRef_typespec();
                    art0->VpiFullName(clName);
                    art0->VpiParent(cl0);
                    art0->Actual_typespec(ets0);
                    cl0->Typedef_alias(art0);
                    tgt0 = cl0;
                }
                auto* ert = s.MakeRef_typespec();
                ert->VpiFullName(prefix + prefix + std::string(ta.name));
                ert->VpiParent(ats);
                ert->Actual_typespec(tgt0);
                ats->Elem_typespec(ert);
            }
            ts = ats;
        }
        else if ((ct.kind == SymbolKind::PackedArrayType ||
                  ct.kind == SymbolKind::ScalarType) &&
                 ta.targetType.getType().kind == SymbolKind::TypeAlias) {
            // A packed ALIAS-of-typedef (typedef imm_i_t imm_l_t): ONE shared
            // object cloned from the TARGET's declaration form — target type
            // span, signed, range FOLDED to constants — carrying a
            // Typedef_alias ref (module-scoped fullname) to a bare-named clone
            // of the target's ts. It is OMITTED from both pkg listings; module
            // listings and all member uses share it (jeras_union imm_l_t).
            if (topView) {
                // The TOP listing DOES carry the shared alias object (the def
                // listing omitted it) — jeras_union imm_l_t.
                if (auto tit9 = typedefTs.find(&ta); tit9 != typedefTs.end()) {
                    pkgTopTypedefTs[&ta] = tit9->second;
                    pkgTdByName.emplace_back(std::string(ta.name),
                                             tit9->second);
                }
                continue;
            }
            auto& tgt9 = ta.targetType.getType().as<TypeAliasType>();
            const syntax::SyntaxNode* tgtTypeSyn9 = nullptr;
            if (auto asyn9 = tgt9.getSyntax();
                asyn9 && asyn9->kind == syntax::SyntaxKind::TypedefDeclaration)
                tgtTypeSyn9 = asyn9->as<syntax::TypedefDeclarationSyntax>().type;
            // Left bound folds INT when written as a binary op (12-1), UINT
            // for a literal — decided from the TARGET's dim syntax.
            bool leftBin9 = false;
            if (tgtTypeSyn9 &&
                syntax::IntegerTypeSyntax::isKind(tgtTypeSyn9->kind)) {
                auto& dims9 =
                    tgtTypeSyn9->as<syntax::IntegerTypeSyntax>().dimensions;
                if (!dims9.empty() && (*dims9.begin())->specifier &&
                    (*dims9.begin())->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& sel9 = (*dims9.begin())
                                     ->specifier
                                     ->as<syntax::RangeDimensionSpecifierSyntax>();
                    if (sel9.selector->kind ==
                        syntax::SyntaxKind::SimpleRangeSelect)
                        leftBin9 =
                            sel9.selector->as<syntax::RangeSelectSyntax>()
                                .left->kind !=
                            syntax::SyntaxKind::IntegerLiteralExpression;
                }
            }
            auto foldBounds9 = [&](UHDM::typespec* t9) {
                if (!t9 || t9->UhdmType() != UHDM::uhdmlogic_typespec)
                    return;
                auto* rs9 = ((UHDM::logic_typespec*)t9)->Ranges();
                if (!rs9 || rs9->empty())
                    return;
                auto cr9 = ct.kind == SymbolKind::PackedArrayType
                               ? ct.as<PackedArrayType>().range
                               : ConstantRange{0, 0};
                auto mkC9 = [&](int32_t v9, bool int9,
                                UHDM::expr* old9) -> UHDM::expr* {
                    auto* c9 = s.MakeConstant();
                    std::string d9 = std::to_string(v9);
                    c9->VpiDecompile(d9);
                    c9->VpiSize(64);
                    c9->VpiValue((int9 ? "INT:" : "UINT:") + d9);
                    c9->VpiConstType(int9 ? vpiIntConst : vpiUIntConst);
                    c9->VpiParent((*rs9)[0]);
                    if (old9) {
                        // Anchor at the OLD bound's leading span (the left
                        // operand of a folded N-1 op).
                        UHDM::expr* anchor9 = old9;
                        if (old9->UhdmType() == UHDM::uhdmoperation) {
                            auto* ops9 = ((UHDM::operation*)old9)->Operands();
                            if (ops9 && !ops9->empty())
                                anchor9 = (UHDM::expr*)(*ops9)[0];
                        }
                        c9->VpiLineNo(anchor9->VpiLineNo());
                        c9->VpiColumnNo(anchor9->VpiColumnNo());
                        c9->VpiEndLineNo(anchor9->VpiEndLineNo());
                        c9->VpiEndColumnNo(anchor9->VpiEndColumnNo());
                    }
                    return c9;
                };
                auto* r9 = (*rs9)[0];
                bool leftOp9 = leftBin9 ||
                               (r9->Left_expr() &&
                                r9->Left_expr()->UhdmType() ==
                                    UHDM::uhdmoperation);
                r9->Left_expr(mkC9(cr9.left, leftOp9, r9->Left_expr()));
                r9->Right_expr(mkC9(cr9.right, false, r9->Right_expr()));
            };
            bypassTypedefShare = true;
            auto* lts9 = makeTypespec(ta, tgtTypeSyn9 ? tgtTypeSyn9 : typeSyn);
            bypassTypedefShare = false;
            foldBounds9(lts9);
            if (tgtTypeSyn9)
                setLoc(lts9, tgtTypeSyn9->sourceRange());
            lts9->VpiName(prefix + std::string(ta.name));
            lts9->Instance((UHDM::instance*)up);
            // Typedef_alias -> a bare-named clone of the target's form, which
            // itself carries a Typedef_alias ref (bare fullname) to the
            // TARGET's shared listing object, instanced at the package.
            bypassTypedefShare = true;
            auto* bare9 = makeTypespec(ta, tgtTypeSyn9 ? tgtTypeSyn9 : typeSyn);
            bypassTypedefShare = false;
            foldBounds9(bare9);
            if (tgtTypeSyn9)
                setLoc(bare9, tgtTypeSyn9->sourceRange());
            bare9->VpiName(tgt9.name);
            bare9->Instance((UHDM::instance*)up);
            if (bare9->UhdmType() == UHDM::uhdmlogic_typespec) {
                // ...whose Actual is the TARGET's TOP/module LISTING object
                // (folded pkg-named twin, module-parented last-writer) —
                // Surelog binds the alias chain into the elab family, not a
                // fresh symbolic clone (jeras_union imm_l_t -> imm_i_t).
                // The top listing does not exist yet; defer the binding.
                auto* tart9 = s.MakeRef_typespec();
                tart9->VpiFullName(std::string(tgt9.name));
                tart9->VpiParent(bare9);
                pendingAliasChainTgt.emplace_back(tart9,
                                                  (const Symbol*)&tgt9);
                ((UHDM::logic_typespec*)bare9)->Typedef_alias(tart9);
            }
            auto* art9 = s.MakeRef_typespec();
            art9->VpiFullName(std::string(d->VpiName()) + "." + prefix +
                              std::string(ta.name));
            art9->VpiParent(lts9);
            art9->Actual_typespec(bare9);
            lts9->Typedef_alias(art9);
            typedefTs[&ta] = lts9;
            typedefClone[&ta] = nullptr;
            continue; // no def-listing entry
        }
        else if (ct.kind == SymbolKind::PackedArrayType || ct.kind == SymbolKind::ScalarType) {
            // A param-bounded range (logic [X-1:0]) stays UNFOLDED in the DEF
            // view with a pkg::pkg::T::-scoped ref (tfContext + :: separator);
            // the elaborated view folds it.
            bypassTypedefShare = true;
            bool savedTf = tfContext;
            std::string savedPfx = syntaxRefPrefix, savedSep = syntaxRefSep;
            if (!topView) {
                tfContext = true;
                syntaxRefPrefix = prefix + prefix + std::string(ta.name);
                syntaxRefSep = "::";
            }
            auto* lts = makeTypespec(ta, typeSyn);
            tfContext = savedTf;
            syntaxRefPrefix = savedPfx;
            syntaxRefSep = savedSep;
            bypassTypedefShare = false;
            lts->VpiParent(up);
            // Def-view unfolded bound refs to package params bind vpiActual
            // to the param's def-view init constant.
            if (!topView && lts->UhdmType() == UHDM::uhdmlogic_typespec) {
                std::function<void(UHDM::any*)> bindRefs = [&](UHDM::any* e) {
                    if (!e)
                        return;
                    if (e->UhdmType() == UHDM::uhdmref_obj) {
                        auto* r = (UHDM::ref_obj*)e;
                        if (!r->Actual_group())
                            if (auto* sym = pkg.find(r->VpiName()))
                                if (auto pit = pkgParamConst.find(sym);
                                    pit != pkgParamConst.end())
                                    r->Actual_group(pit->second);
                    }
                    else if (e->UhdmType() == UHDM::uhdmoperation) {
                        if (auto* ops = ((UHDM::operation*)e)->Operands())
                            for (auto* op : *ops)
                                bindRefs(op);
                    }
                };
                if (auto* rs = ((UHDM::logic_typespec*)lts)->Ranges())
                    for (auto* r : *rs) {
                        bindRefs(r->Left_expr());
                        bindRefs(r->Right_expr());
                    }
            }
            typedefClone[&ta] = nullptr;
            ts = lts;
        }
        else if ((ct.kind == SymbolKind::PackedStructType ||
                  ct.kind == SymbolKind::UnpackedStructType) &&
                 ta.targetType.getType().kind == SymbolKind::TypeAlias &&
                 structAliasBase(ta) != nullptr) {
            // A struct-typedef ALIAS (typedef pkg1::type_t type_alias):
            // Surelog mints ONE shared CLONE of the base struct typespec —
            // the BASE's span, this package's name/parent/Instance, a
            // Typedef_alias ref (pkg::pkg::alias) back to the base object,
            // and doubled-prefix member refs. It is OMITTED from the package
            // DEF listing and appears only in the elaborated one, exactly
            // like the packed alias-of-typedef case above.
            if (topView) {
                if (auto tit = typedefTs.find(&ta); tit != typedefTs.end()) {
                    pkgTopTypedefTs[&ta] = tit->second;
                    pkgTdByName.emplace_back(std::string(ta.name), tit->second);
                }
                continue;
            }
            auto* base = structAliasBase(ta);
            bool pkStr0 = ct.kind == SymbolKind::PackedStructType;
            const Scope& scope0 =
                pkStr0 ? (const Scope&)ct.as<PackedStructType>()
                       : (const Scope&)ct.as<UnpackedStructType>();
            std::string aliasName = prefix + std::string(ta.name);
            std::string dbl = prefix + aliasName;
            bool savedRP = structCloneMemberRefParent;
            structCloneMemberRefParent = true;
            auto* cl = buildStructTs(scope0, pkStr0, dbl, "::");
            structCloneMemberRefParent = savedRP;
            cl->VpiName(aliasName);
            cl->VpiFile(base->VpiFile());
            cl->VpiLineNo(base->VpiLineNo());
            cl->VpiColumnNo(base->VpiColumnNo());
            cl->VpiEndLineNo(base->VpiEndLineNo());
            cl->VpiEndColumnNo(base->VpiEndColumnNo());
            cl->VpiParent(up);
            cl->Instance((UHDM::instance*)up);
            // The clone's fresh member typespecs stay instanced at the BASE's
            // home package — only the clone itself belongs to this package.
            // The walk is RECURSIVE: a NESTED anonymous struct member carries
            // its own leaf typespecs, and a leaf left without vpiInstance is a
            // hard cmp blocker (instance::Compare recurses Instance(), so a
            // null on our side reports failLhs=<the home package>, failRhs=
            // null — StructTypedef's `struct packed { struct packed { logic q;
            // } en; ... }` re-exported through a second package).
            {
                std::function<void(UHDM::typespec*)> stampClone =
                    [&](UHDM::typespec* t0) {
                        const UHDM::VectorOftypespec_member* mems0 = nullptr;
                        if (t0->UhdmType() == UHDM::uhdmstruct_typespec)
                            mems0 = ((UHDM::struct_typespec*)t0)->Members();
                        else if (t0->UhdmType() == UHDM::uhdmunion_typespec)
                            mems0 = ((UHDM::union_typespec*)t0)->Members();
                        if (!mems0)
                            return;
                        for (auto* tm : *mems0) {
                            if (!tm->Typespec())
                                continue;
                            auto* mts = tm->Typespec()->Actual_typespec();
                            if (!mts || !mts->VpiName().empty())
                                continue;
                            mts->Instance(base->Instance());
                            stampClone(mts);
                        }
                    };
                stampClone(cl);
            }
            auto* art = s.MakeRef_typespec();
            art->VpiFullName(dbl);
            art->VpiParent(cl);
            art->Actual_typespec(base);
            cl->Typedef_alias(art);
            typedefTs[&ta] = cl;
            continue;
        }
        else if (ct.kind == SymbolKind::PackedStructType ||
                 ct.kind == SymbolKind::UnpackedStructType) {
            // Package struct member refs use pkg::pkg::T::m (doubled prefix);
            // each field typespec carries vpiInstance = package.
            // DEF-view member bounds stay UNFOLDED (member-scoped refs bound
            // to the params' def init constants); the elab view folds them.
            // A NESTED-struct-containing typedef's TOP view instead scopes
            // members pkg::T.m (single prefix, dot) and stays UNPARENTED.
            bool pkStr = ct.kind == SymbolKind::PackedStructType;
            const Scope& structScope =
                pkStr ? (const Scope&)ct.as<PackedStructType>()
                      : (const Scope&)ct.as<UnpackedStructType>();
            bool nestedStruct = false;
            for (auto& fm : structScope.membersOfType<FieldSymbol>())
                if (auto mk = fm.getType().getCanonicalType().kind;
                    mk == SymbolKind::PackedStructType ||
                    mk == SymbolKind::UnpackedStructType)
                    nestedStruct = true;
            bool topNested = topView && nestedStruct &&
                             wildcardImportedPkgs.count(&pkg);
            // A pkg struct consumed ONLY inside other package typedefs
            // (never by a module signal, directly or via packed array)
            // SHARES its def-view object into the elab pkg view instead of
            // materializing a top copy (nested_struct base_struct_t).
            if (topView && pkgDefStructTs.count(&ta)) {
                bool modUse9 = false;
                std::function<void(const InstanceBodySymbol&)> scan9 =
                    [&](const InstanceBodySymbol& b9) {
                        for (auto& mb9 : b9.members()) {
                            const DeclaredType* dt9 = nullptr;
                            if (mb9.kind == SymbolKind::Net ||
                                mb9.kind == SymbolKind::Variable ||
                                mb9.kind == SymbolKind::Port ||
                                mb9.kind == SymbolKind::Parameter)
                                dt9 = mb9.getDeclaredType();
                            if (dt9) {
                                const Type* t9 =
                                    &dt9->getType().getCanonicalType();
                                while (t9->getCanonicalType().kind ==
                                           SymbolKind::PackedArrayType ||
                                       t9->getCanonicalType().kind ==
                                           SymbolKind::
                                               FixedSizeUnpackedArrayType) {
                                    auto& c9 = t9->getCanonicalType();
                                    t9 = c9.kind == SymbolKind::PackedArrayType
                                             ? &c9.as<PackedArrayType>()
                                                    .elementType
                                             : &c9.as<
                                                     FixedSizeUnpackedArrayType>()
                                                    .elementType;
                                }
                                if (&t9->getCanonicalType() ==
                                    &ct.getCanonicalType())
                                    modUse9 = true;
                            }
                            if (mb9.kind == SymbolKind::Instance)
                                scan9(mb9.as<InstanceSymbol>().body);
                        }
                    };
                for (auto* ti9 : comp.getRoot().topInstances)
                    scan9(ti9->body);
                // Share only when the struct is nested inside ANOTHER
                // package's struct typedef (cross-pkg consumption).
                bool crossPkgNest9 = false;
                for (auto* opkg9 : comp.getPackages()) {
                    if (opkg9 == &pkg)
                        continue;
                    for (auto& om9 : opkg9->members())
                        if (om9.kind == SymbolKind::TypeAlias) {
                            auto& oct9 = om9.as<TypeAliasType>()
                                             .targetType.getType()
                                             .getCanonicalType();
                            if (oct9.isStruct())
                                for (auto& of9 : oct9.as<Scope>().members())
                                    if (of9.kind == SymbolKind::Field &&
                                        &of9.as<FieldSymbol>()
                                                .getType()
                                                .getCanonicalType() ==
                                            &ct.getCanonicalType())
                                        crossPkgNest9 = true;
                        }
                }
                if (!crossPkgNest9)
                    modUse9 = true;
                if (!modUse9) {
                    auto* shared9 = pkgDefStructTs[&ta];
                    pkgTopTypedefTs[&ta] = shared9;
                    pkgTdByName.emplace_back(std::string(ta.name), shared9);
                    continue;
                }
            }
            std::string alias = topNested
                                    ? prefix + std::string(ta.name)
                                    : prefix + prefix + std::string(ta.name);
            bool savedTf = tfContext;
            if (topView)
                tfContext = true;
            inPkgTopStructBuild = topView;
            auto* sts = buildStructTs(structScope, pkStr, alias,
                                      topNested ? "." : "::");
            inPkgTopStructBuild = false;
            tfContext = savedTf;
            if (!topNested)
                sts->VpiParent(up);
            if (sts->Members())
                for (auto* tm : *sts->Members())
                    if (tm->Typespec() && tm->Typespec()->Actual_typespec()) {
                        auto* mts = tm->Typespec()->Actual_typespec();
                        // A member whose actual is ANOTHER package's shared
                        // STRUCT typedef re-points at the import clone (never
                        // mutate the home object's Instance).
                        if (mts->UhdmType() == UHDM::uhdmstruct_typespec &&
                            mts->Instance() &&
                            mts->Instance() != (UHDM::instance*)up &&
                            mts->Instance()->UhdmType() == UHDM::uhdmpackage) {
                            const Symbol* homeSym9 = nullptr;
                            for (auto& [sym9, tsp9] : typedefTs)
                                if (tsp9 == mts) {
                                    homeSym9 = sym9;
                                    break;
                                }
                            if (homeSym9)
                                if (auto cit9 = pkgImportCloneTs.find(homeSym9);
                                    cit9 != pkgImportCloneTs.end()) {
                                    tm->Typespec()->Actual_typespec(
                                        cit9->second);
                                    mts = cit9->second;
                                }
                        }
                        // A member whose actual is ANOTHER package's shared
                        // enum typedef gets a FRESH per-use clone (Instance ->
                        // THIS package) — never mutate the shared object
                        // (Surelog keeps home Instance on the home copy).
                        if (mts->UhdmType() == UHDM::uhdmenum_typespec &&
                            mts->Instance() &&
                            mts->Instance() != (UHDM::instance*)up &&
                            mts->Instance()->UhdmType() == UHDM::uhdmpackage &&
                            // An ENUM-ALIAS ts (typedef op32_op62_et opc_t)
                            // stays the ONE shared object across views —
                            // never per-use cloned (jeras_union ctl_t.opc).
                            !((UHDM::enum_typespec*)mts)->Typedef_alias()) {
                            const EnumType* et9 = nullptr;
                            for (auto& [sym9, tsp9] : typedefTs)
                                if (tsp9 == mts &&
                                    sym9->kind == SymbolKind::TypeAlias) {
                                    auto& c9 = sym9->as<TypeAliasType>()
                                                   .getCanonicalType();
                                    if (c9.kind == SymbolKind::EnumType)
                                        et9 = &c9.as<EnumType>();
                                    break;
                                }
                            if (et9) {
                                auto* cl9 = buildEnumTs(
                                    *et9, nullptr,
                                    std::string(mts->VpiName()));
                                cl9->VpiName(mts->VpiName());
                                cl9->VpiLineNo(mts->VpiLineNo());
                                cl9->VpiColumnNo(mts->VpiColumnNo());
                                cl9->VpiEndLineNo(mts->VpiEndLineNo());
                                cl9->VpiEndColumnNo(mts->VpiEndColumnNo());
                                tm->Typespec()->Actual_typespec(cl9);
                                mts = cl9;
                            }
                        }
                        // Surelog leaves a member actual the DEF pass already
                        // instanced at THIS package on that def-view instance
                        // — one shared object across both views (rp32
                        // op32_op62_et/opc_t and the imported enum clones are
                        // #DEF in every listing). The condition is OWNERSHIP,
                        // not the current Instance() value: guarding on the
                        // value alone measured net-worse (170 -> 322) because
                        // members the TOP pass builds fresh DO need the elab
                        // instance. defOwnedTs unifies the two independently
                        // implemented creation-pass markers.
                        // An UNPACKED-array member (`logic [31:0] pair [2]`) is
                        // a WRAPPER array_typespec around the type Surelog
                        // actually compiled in the package scope: the ELEMENT
                        // typespec carries vpiInstance and the wrapper stays
                        // bare.  Only a wrapper whose element is FRESH
                        // (unnamed) redirects — one pointing at a shared
                        // typedef keeps the historic behaviour.
                        // (HierPathUnpacked keymgr_pkg::foo_t.pair.)
                        UHDM::typespec* instOwn = mts;
                        if (mts->UhdmType() == UHDM::uhdmarray_typespec)
                            if (auto* er0 =
                                    ((UHDM::array_typespec*)mts)->Elem_typespec())
                                if (auto* ea0 = er0->Actual_typespec();
                                    ea0 && ea0->VpiName().empty())
                                    instOwn = ea0;
                        if (topView && defOwnedTs(mts))
                            ; // shared def-owned object: keep def instance
                        else {
                            instOwn->Instance((UHDM::instance*)up);
                            if (!topView) {
                                defPassOwnedTs.insert(mts);
                                pkgDefMemberActual.insert(mts);
                            }
                        }
                        if (topView && mts->UhdmType() == UHDM::uhdmlogic_typespec) {
                            std::function<void(UHDM::any*)> bindRefs2 =
                                [&](UHDM::any* e) {
                                    if (!e)
                                        return;
                                    if (e->UhdmType() == UHDM::uhdmref_obj) {
                                        auto* r = (UHDM::ref_obj*)e;
                                        if (!r->Actual_group())
                                            if (auto* sym = pkg.find(r->VpiName()))
                                                if (auto pit = pkgParamConst.find(sym);
                                                    pit != pkgParamConst.end())
                                                    r->Actual_group(pit->second);
                                    }
                                    else if (e->UhdmType() == UHDM::uhdmoperation) {
                                        if (auto* ops =
                                                ((UHDM::operation*)e)->Operands())
                                            for (auto* op : *ops)
                                                bindRefs2(op);
                                    }
                                };
                            if (auto* rs = ((UHDM::logic_typespec*)mts)->Ranges())
                                for (auto* r : *rs) {
                                    bindRefs2(r->Left_expr());
                                    bindRefs2(r->Right_expr());
                                }
                        }
                    }
            if (typeSyn)
                setLoc(sts, typeSyn->sourceRange());
            // A FRESH (unnamed) scalar member typespec of a package struct
            // listing carries the package vpiInstance (Surelog; rp32
            // isa_base_t `bit E` members) — named shared typedefs keep
            // their own.
            if (sts->Members())
                for (auto* tmS : *sts->Members())
                    if (tmS->Typespec() && tmS->Typespec()->Actual_typespec()) {
                        auto* atS = tmS->Typespec()->Actual_typespec();
                        // ...but an UNPACKED-array wrapper stays bare: its
                        // ELEMENT is the typespec Surelog compiled in the
                        // package scope and already carries the Instance (see
                        // the member loop above).
                        bool wrapS = false;
                        if (atS->UhdmType() == UHDM::uhdmarray_typespec)
                            if (auto* erS = ((UHDM::array_typespec*)atS)
                                                ->Elem_typespec())
                                if (auto* eaS = erS->Actual_typespec();
                                    eaS && eaS->VpiName().empty())
                                    wrapS = true;
                        if (!wrapS && !atS->Instance() && atS->VpiName().empty())
                            atS->Instance((UHDM::instance*)up);
                    }
            // NESTED inner-struct member clones carry the pkg Instance on
            // their leaf member typespecs in BOTH views (nested_struct): the
            // def-view object is what the TOP struct ends up owning after the
            // member cross-wire below, and a leaf left without vpiInstance
            // breaks any Compare that reaches the top struct (NSAP).
            if (sts->Members())
                for (auto* tmN : *sts->Members())
                    if (tmN->Typespec() && tmN->Typespec()->Actual_typespec() &&
                        tmN->Typespec()->Actual_typespec()->UhdmType() ==
                            UHDM::uhdmstruct_typespec) {
                        auto* ists =
                            (UHDM::struct_typespec*)tmN->Typespec()
                                ->Actual_typespec();
                        if (ists->Members())
                            for (auto* itm : *ists->Members())
                                if (itm->Typespec() &&
                                    itm->Typespec()->Actual_typespec() &&
                                    !itm->Typespec()
                                         ->Actual_typespec()
                                         ->Instance())
                                    itm->Typespec()
                                        ->Actual_typespec()
                                        ->Instance((UHDM::instance*)up);
                    }
            // The TOP view's span stretches to the first module-signal USE
            // declarator (patched once defs exist); the def view keeps the
            // typedef span.
            if (topView)
                pendingPkgTsStretch.push_back(
                    {(UHDM::typespec*)sts, (const Type*)&ta});
            // Surelog CROSS-WIRES the two views' member typespecs: the
            // first-created (folded) member ts belongs to the TOP struct, the
            // second-created (unfolded) one to the DEF struct — while each
            // view's struct container keeps its own creation slot. Swap the
            // member actuals (and their parents/instances) after the top
            // build.
            if (!topView)
                pkgDefStructTs[&ta] = sts;
            else if (auto dit0 = pkgDefStructTs.find(&ta);
                     dit0 != pkgDefStructTs.end() && dit0->second->Members() &&
                     sts->Members() &&
                     dit0->second->Members()->size() == sts->Members()->size()) {
                auto* dsts = dit0->second;
                auto* dup2 = (UHDM::instance*)dsts->Instance();
                for (size_t mi = 0; mi < sts->Members()->size(); mi++) {
                    auto* dm = (*dsts->Members())[mi];
                    auto* tmM = (*sts->Members())[mi];
                    if (!dm->Typespec() || !tmM->Typespec())
                        continue;
                    auto* da = dm->Typespec()->Actual_typespec();
                    auto* taA = tmM->Typespec()->Actual_typespec();
                    if (!da || !taA || da->UhdmType() != taA->UhdmType())
                        continue;
                    // A NESTED struct/union member is NOT cross-wired: each
                    // view already built its own-view inner typedef (def ->
                    // symbolic def object, top -> folded elab object), so a
                    // swap would give each container the wrong-view inner
                    // aggregate (rsp_gen_minimal tl_d2h_t.d_user). Only the
                    // scalar (folded-vs-unfolded) leaves swap.
                    // An ENUM member is not cross-wired either: each view's
                    // struct references its OWN view's enum object (Surelog
                    // per-view identities; jeras_union ctl_alu_t.fn3 /
                    // ctl_t.ill).
                    if (da->UhdmType() == UHDM::uhdmstruct_typespec ||
                        da->UhdmType() == UHDM::uhdmunion_typespec ||
                        da->UhdmType() == UHDM::uhdmenum_typespec)
                        continue;
                    // A NAMED vector-typedef member clone is not cross-wired
                    // either: each view built its own (def -> symbolic,
                    // aliasing the def listing; top -> folded, aliasing the
                    // elab listing). Only the ANONYMOUS scalar leaves swap
                    // (rp32 dec_t.fn3 vs rsp_gen_minimal tl_d2h_t.d_size;
                    // jeras_union ctl_alu_t.imm needed the un-gated form —
                    // the earlier `topNested &&` guard let the def struct
                    // take the folded top clone).
                    if (!da->VpiName().empty() || !taA->VpiName().empty())
                        continue;
                    dm->Typespec()->Actual_typespec(taA);
                    tmM->Typespec()->Actual_typespec(da);
                    if (!taA->VpiName().length())
                        taA->VpiParent(dm);
                    if (!da->VpiName().length())
                        da->VpiParent(tmM);
                    // An ENUM member's BASE typespec travels with it: the
                    // view a swapped enum lands in owns its base too, so the
                    // base takes the same instance (rp32 op32_op62_et's
                    // unnamed logic base under every op32_*_t listing).
                    auto stampTs = [&](UHDM::typespec* t5,
                                       UHDM::instance* i5) {
                        if (!t5 || !i5)
                            return;
                        t5->Instance(i5);
                        if (t5->UhdmType() == UHDM::uhdmenum_typespec)
                            if (auto* br5 =
                                    ((UHDM::enum_typespec*)t5)->Base_typespec())
                                if (auto* ba5 = br5->Actual_typespec())
                                    ba5->Instance(i5);
                    };
                    if (dup2)
                        stampTs(taA, dup2);
                    // A NAMED member actual the DEF pass owns is Surelog's ONE
                    // shared object: the swap re-points the containers, but the
                    // object keeps its def-view instance (creation-pass marker
                    // — a value-based guard cannot tell it from a fresh
                    // top-built member).
                    if (!(defOwnedTs(da) && !da->VpiName().empty()))
                        stampTs(da, (UHDM::instance*)up);
                }
                attachFoldedBoundMeta(sts, (UHDM::instance*)up);
            }
            // The single-prefix TOP clone's per-member vector clones alias the
            // ELABORATED (folded) typedef object, not the def-listing one
            // (rp32 dec_t.fn3.fn3_t -> the module-scoped [2:0] fn3_t).
            if (topView && topNested && sts->Members())
                for (auto* tmA : *sts->Members()) {
                    if (!tmA->Typespec())
                        continue;
                    auto* mtsA = tmA->Typespec()->Actual_typespec();
                    if (!mtsA || mtsA->UhdmType() != UHDM::uhdmlogic_typespec)
                        continue;
                    auto* alA = ((UHDM::logic_typespec*)mtsA)->Typedef_alias();
                    if (!alA || !alA->Actual_typespec())
                        continue;
                    for (auto& [symA, tspA] : typedefTs)
                        if (tspA == alA->Actual_typespec()) {
                            if (auto tA = pkgTopTypedefTs.find((const void*)symA);
                                tA != pkgTopTypedefTs.end() && tA->second)
                                alA->Actual_typespec(tA->second);
                            break;
                        }
                }
            ts = sts;
        }
        else if (ct.kind == SymbolKind::EnumType &&
                 ta.targetType.getType().kind == SymbolKind::TypeAlias) {
            // A pkg ENUM-typedef ALIAS (typedef lc_tx_e lc_tx_t): CREATED in
            // the DEF pass (arena: before the top-pkg clones) but LISTED only
            // in the TOP view. The clone is built from the TARGET's enum
            // syntax (own consts + fresh base at the target's base span) with
            // a Typedef_alias ref (doubled pkg scoping) to the target's
            // shared TOP ts (bound later, in the top pass). Its span runs
            // from the TARGET typedef's start to the first USE declarator's
            // end.
            if (!topView) {
                auto& tgt = ta.targetType.getType().as<TypeAliasType>();
                const syntax::SyntaxNode* tgtSyn = nullptr;
                SourceLocation tgtStart = tgt.location;
                SourceRange tgtDecl;
                if (auto asyn = tgt.getSyntax();
                    asyn && asyn->kind == syntax::SyntaxKind::TypedefDeclaration) {
                    tgtSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
                    tgtStart = asyn->sourceRange().start();
                    tgtDecl = asyn->sourceRange();
                }
                // A module VARIABLE of the alias type extends the span to its
                // declarator end, DOUBLES the ref scoping and parents at the
                // package; port-only uses keep the TARGET's decl span, single
                // scoping and no parent.
                SourceLocation useEnd = SourceLocation::NoLocation;
                bool arrayAliasUse0 = false;
                for (auto inst : comp.getRoot().topInstances) {
                    for (auto& mb : inst->body.members()) {
                        if (mb.kind != SymbolKind::Variable)
                            continue;
                        auto dt0 = mb.getDeclaredType();
                        if (!dt0)
                            continue;
                        // Direct alias type OR a PACKED ARRAY of it
                        // (VarPassedTo2Submodules lc_tx_t [0:0] var). An
                        // ARRAY use doubles/parents but does NOT stretch
                        // the span (useEnd stays unset).
                        bool aliasDirect0 = &dt0->getType() == (const Type*)&ta;
                        bool aliasUse0 = aliasDirect0;
                        if (!aliasUse0)
                            for (const Type* t0 = &dt0->getType();;) {
                                if (t0 == (const Type*)&ta) {
                                    aliasUse0 = true;
                                    break;
                                }
                                auto& c0 = t0->getCanonicalType();
                                if (c0.kind != SymbolKind::PackedArrayType)
                                    break;
                                t0 = &c0.as<PackedArrayType>().elementType;
                            }
                        if (!aliasUse0)
                            continue;
                        if (!aliasDirect0) {
                            arrayAliasUse0 = true;
                            break;
                        }
                        // PORT-backed variables (output pkg::b o) don't count.
                        bool portBacked = false;
                        for (auto pb : inst->body.getPortList())
                            if (pb->kind == SymbolKind::Port &&
                                pb->as<PortSymbol>().internalSymbol == &mb)
                                portBacked = true;
                        if (portBacked)
                            continue;
                        if (auto dsyn0 = mb.getSyntax())
                            useEnd = dsyn0->sourceRange().end();
                        break;
                    }
                    if (useEnd != SourceLocation::NoLocation)
                        break;
                }
                bool varUse =
                    useEnd != SourceLocation::NoLocation || arrayAliasUse0;
                std::string refName = varUse
                                          ? prefix + prefix + std::string(ta.name)
                                          : prefix + std::string(ta.name);
                pkgListingEnumBuild = true;
                auto* ets = buildEnumTs(ct.as<EnumType>(), tgtSyn, refName);
                pkgListingEnumBuild = false;
                if (varUse)
                    ets->VpiParent(up);
                if (ets->Base_typespec() && ets->Base_typespec()->Actual_typespec()) {
                    auto* bts = ets->Base_typespec()->Actual_typespec();
                    bts->Instance((UHDM::instance*)up);
                    bts->VpiParent(ets->Base_typespec());
                }
                auto* art = s.MakeRef_typespec();
                art->VpiFullName(refName);
                art->VpiParent(ets);
                ets->Typedef_alias(art);
                if (varUse && useEnd != SourceLocation::NoLocation)
                    setLoc(ets, SourceRange(tgtStart, useEnd));
                else if (tgtDecl.start() != SourceLocation::NoLocation)
                    setLoc(ets, tgtDecl);
                else if (auto syn = ta.getSyntax())
                    setLoc(ets, syn->sourceRange());
                ets->VpiName(prefix + std::string(ta.name));
                ets->Instance((UHDM::instance*)up);
                // Module signals of the alias type (BOTH views) bind this
                // clone; the def LISTING omits it.
                typedefTs[&ta] = ets;
                continue;
            }
            // TOP pass: bind the alias target (now emitted) and list.
            auto tit0 = typedefTs.find(&ta);
            if (tit0 == typedefTs.end())
                continue;
            auto* ets = (UHDM::enum_typespec*)tit0->second;
            if (ets->Typedef_alias())
                if (auto tgtIt = pkgTopTypedefTs.find(&ta.targetType.getType());
                    tgtIt != pkgTopTypedefTs.end())
                    ets->Typedef_alias()->Actual_typespec(tgtIt->second);
            pkgTopTypedefTs[&ta] = ets;
            pkgTdByName.emplace_back(std::string(ta.name), ets);
            continue;
        }
        else if (ct.kind == SymbolKind::EnumType) {
            // The base ref fullname doubles the package scope
            // (pkg::pkg::name — Surelog scopes the already-prefixed typedef
            // name by the package again).
            pkgListingEnumBuild = true;
            auto* ets = buildEnumTs(ct.as<EnumType>(), typeSyn,
                                    prefix + prefix + std::string(ta.name));
            pkgListingEnumBuild = false;
            ets->VpiParent(up);
            if (auto syn = ta.getSyntax())
                setLoc(ets, syn->sourceRange());
            // The base typespec is package-instanced too.
            if (ets->Base_typespec() && ets->Base_typespec()->Actual_typespec())
                ets->Base_typespec()->Actual_typespec()->Instance((UHDM::instance*)up);
            // The TOP clone's span stretches to the first module-signal USE
            // declarator (a `pkg::e arr [N]` unpacked-array element extends the
            // endln to the array_var decl end — Surelog). The def view keeps
            // the typedef span.
            if (topView)
                pendingPkgTsStretch.push_back(
                    {(UHDM::typespec*)ets, (const Type*)&ta});
            ts = ets;
        }
        else if (ct.kind == SymbolKind::PackedUnionType ||
                 ct.kind == SymbolKind::UnpackedUnionType) {
            // Package UNION typedef -> union_typespec, members doubled-scoped
            // p::p::T::m ("::"), parented at the package (sibling of the
            // PackedStructType branch).
            std::string alias = prefix + prefix + std::string(ta.name);
            bool pk = ct.kind == SymbolKind::PackedUnionType;
            // Member bounds ([K:0]) stay SYMBOLIC in the top view (mirror the
            // PackedStructType branch's tfContext handling).
            bool savedTfU = tfContext;
            if (topView)
                tfContext = true;
            inPkgTopStructBuild = topView;
            auto* uts = pk
                            ? buildUnionTs(ct.as<PackedUnionType>(), true, alias,
                                           "::")
                            : buildUnionTs(ct.as<UnpackedUnionType>(), false,
                                           alias, "::");
            inPkgTopStructBuild = false;
            tfContext = savedTfU;
            uts->VpiParent(up);
            if (uts->Members())
                for (auto* tm : *uts->Members())
                    if (tm->Typespec() && tm->Typespec()->Actual_typespec()) {
                        auto* muA = tm->Typespec()->Actual_typespec();
                        if (topView && defOwnedTs(muA))
                            ; // shared with the def view — keeps its instance
                        else {
                            muA->Instance((UHDM::instance*)up);
                            if (!topView) {
                                defPassOwnedTs.insert(muA);
                                pkgDefMemberActual.insert(muA);
                            }
                        }
                    }
            // Mirror the struct arm: Surelog CROSS-WIRES the two views' member
            // typespecs. The DEF pass folds member bounds ([K:0] -> constant);
            // the TOP pass (tfContext) keeps them SYMBOLIC (ref_obj). Surelog
            // wires the symbolic (top-built) member ts into the DEF union and
            // the folded (def-built) one into the TOP union. Swap after top.
            if (!topView)
                pkgDefUnionTs[&ta] = uts;
            else if (auto duit = pkgDefUnionTs.find(&ta);
                     duit != pkgDefUnionTs.end() && duit->second->Members() &&
                     uts->Members() &&
                     duit->second->Members()->size() == uts->Members()->size()) {
                auto* duts = duit->second;
                auto* dup2 = (UHDM::instance*)duts->Instance();
                for (size_t mi = 0; mi < uts->Members()->size(); mi++) {
                    auto* dm = (*duts->Members())[mi];
                    auto* tmM = (*uts->Members())[mi];
                    if (!dm->Typespec() || !tmM->Typespec())
                        continue;
                    auto* da = dm->Typespec()->Actual_typespec();
                    auto* taA = tmM->Typespec()->Actual_typespec();
                    if (!da || !taA || da->UhdmType() != taA->UhdmType())
                        continue;
                    // A NESTED struct/union member is NOT cross-wired: each
                    // view already built its own-view inner typedef (def ->
                    // symbolic def object, top -> folded elab object), so a
                    // swap would give each container the wrong-view inner
                    // aggregate (rsp_gen_minimal tl_d2h_t.d_user). Only the
                    // scalar (folded-vs-unfolded) leaves swap.
                    if (da->UhdmType() == UHDM::uhdmstruct_typespec ||
                        da->UhdmType() == UHDM::uhdmunion_typespec)
                        continue;
                    dm->Typespec()->Actual_typespec(taA);
                    tmM->Typespec()->Actual_typespec(da);
                    if (!taA->VpiName().length())
                        taA->VpiParent(dm);
                    if (!da->VpiName().length())
                        da->VpiParent(tmM);
                    // An ENUM member's BASE typespec travels with it: the
                    // view a swapped enum lands in owns its base too, so the
                    // base takes the same instance (rp32 op32_op62_et's
                    // unnamed logic base under every op32_*_t listing).
                    auto stampTs = [&](UHDM::typespec* t5,
                                       UHDM::instance* i5) {
                        if (!t5 || !i5)
                            return;
                        t5->Instance(i5);
                        if (t5->UhdmType() == UHDM::uhdmenum_typespec)
                            if (auto* br5 =
                                    ((UHDM::enum_typespec*)t5)->Base_typespec())
                                if (auto* ba5 = br5->Actual_typespec())
                                    ba5->Instance(i5);
                    };
                    if (dup2)
                        stampTs(taA, dup2);
                    // A NAMED member actual the DEF pass owns is Surelog's ONE
                    // shared object: the swap re-points the containers, but the
                    // object keeps its def-view instance (creation-pass marker
                    // — a value-based guard cannot tell it from a fresh
                    // top-built member).
                    if (!(defOwnedTs(da) && !da->VpiName().empty()))
                        stampTs(da, (UHDM::instance*)up);
                }
                attachFoldedBoundMeta(uts, (UHDM::instance*)up);
            }
            if (typeSyn)
                setLoc(uts, typeSyn->sourceRange());
            ts = uts;
        }
        else if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType && topView) {
            // typedef a b[1:0] (TOP view only): an array_typespec spanning
            // target-type .. dims, Range at the dim tokens, Elem ref
            // (doubled pkg::pkg::b) -> the element typedef's ts (Surelog).
            auto& ua = ct.as<FixedSizeUnpackedArrayType>();
            auto* ats = s.MakeArray_typespec();
            SourceLocation aS = ta.location, aE = ta.location;
            if (typeSyn)
                aS = typeSyn->sourceRange().start();
            const syntax::SyntaxNode* dimSyn = nullptr;
            if (auto dsyn = ta.getSyntax();
                dsyn && dsyn->kind == syntax::SyntaxKind::TypedefDeclaration) {
                auto& td = dsyn->as<syntax::TypedefDeclarationSyntax>();
                if (!td.dimensions.empty()) {
                    dimSyn = td.dimensions[0];
                    aE = td.dimensions[td.dimensions.size() - 1]
                             ->sourceRange()
                             .end();
                }
            }
            setLoc(ats, SourceRange(aS, aE));
            auto* r = s.MakeRange();
            r->VpiParent(ats);
            const syntax::ExpressionSyntax* lSyn = nullptr;
            const syntax::ExpressionSyntax* rSyn = nullptr;
            if (dimSyn) {
                setLoc(r, dimSyn->sourceRange());
                auto& vd = dimSyn->as<syntax::VariableDimensionSyntax>();
                if (vd.specifier &&
                    vd.specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& sel = *vd.specifier
                                     ->as<syntax::RangeDimensionSpecifierSyntax>()
                                     .selector;
                    if (auto* rss = sel.as_if<syntax::RangeSelectSyntax>()) {
                        lSyn = rss->left;
                        rSyn = rss->right;
                    }
                }
            }
            auto mkAB = [&](int64_t v,
                            const syntax::ExpressionSyntax* bs) -> UHDM::expr* {
                auto* c = s.MakeConstant();
                std::string digits = std::to_string(v);
                c->VpiDecompile(digits);
                c->VpiSize(64);
                c->VpiValue("UINT:" + digits);
                c->VpiConstType(vpiUIntConst);
                c->VpiParent(r);
                if (bs)
                    setLoc(c, bs->sourceRange());
                return c;
            };
            r->Left_expr(mkAB(ua.range.left, lSyn));
            r->Right_expr(mkAB(ua.range.right, rSyn));
            auto* rvec = s.MakeRangeVec();
            rvec->push_back(r);
            ats->Ranges(rvec);
            // Elem ref -> the element typedef's ts in THIS view.
            UHDM::typespec* elemTs2 = nullptr;
            const Type* et = &ua.elementType;
            const Symbol* etSym =
                et->kind == SymbolKind::TypeAlias
                    ? (const Symbol*)&et->as<TypeAliasType>()
                    : nullptr;
            if (topView) {
                if (auto eit = pkgTopTypedefTs.find(etSym);
                    etSym && eit != pkgTopTypedefTs.end())
                    elemTs2 = eit->second;
            }
            else if (auto eit = typedefTs.find(etSym);
                     etSym && eit != typedefTs.end())
                elemTs2 = eit->second;
            if (!elemTs2 && !topView)
                for (auto& [sym2, tsp2] : typedefTs)
                    if (sym2->kind == SymbolKind::TypeAlias &&
                        &sym2->as<TypeAliasType>().getCanonicalType() ==
                            &et->getCanonicalType()) {
                        elemTs2 = tsp2;
                        break;
                    }
            if (elemTs2) {
                auto* ert = s.MakeRef_typespec();
                ert->VpiParent(ats);
                ert->VpiFullName(prefix + prefix + std::string(ta.name));
                ert->Actual_typespec(elemTs2);
                ats->Elem_typespec(ert);
            }
            ts = ats;
        }
        // A KEYWORD-INTEGER typedef (`typedef int UVM_FILE;`,
        // `typedef int uvm_action;`) is listed like every other package
        // typedef: one bare typespec of the keyword's own kind, named
        // pkg::T, spanning the TYPE tokens (`int` alone, not the declarator)
        // and Instanced at the package.  It was the one scalar spelling with
        // no arm at all — `int`/`integer`/`byte`/... canonicalise to
        // PredefinedIntegerType, which neither the ScalarType nor the
        // PackedArrayType arm above accepts, so the typedef emitted NOTHING
        // (BuildUVMPkg: golden 48 package Typespecs, ours 46).
        else if (ct.kind == SymbolKind::PredefinedIntegerType) {
            bool savedBTS7 = bypassTypedefShare;
            bypassTypedefShare = true;
            auto* its7 = makeTypespec(ta, typeSyn);
            bypassTypedefShare = savedBTS7;
            if (its7) {
                its7->VpiParent(up);
                typedefClone[&ta] = nullptr;
                ts = its7;
            }
        }
        // A CLASS-HANDLE typedef (`typedef uvm_callbacks#(A,B) uvm_reg_cb;`,
        // `typedef uvm_tlm_generic_payload uvm_tlm_gp;`, and the ASSOCIATIVE
        // spelling `typedef uvm_port_component_base uvm_port_list[string];`,
        // whose dim Surelog drops here) is listed in the ELABORATED package
        // view ONLY — the def view has none of them (BuildUVMPkg: def 48/48,
        // top 89 vs our 50).  Its vpiClassDefn is the GENERIC class_defn, not
        // the specialization, so every `uvm_callbacks#(...)` typedef points
        // at the same object; the specialization arguments are NOT carried
        // (vpiParameters empty).  Surelog mints ONE object per generic class
        // and CLONES it for the rest: the first typedef in the (name-sorted)
        // listing is the base, and every later one repeats the base's span
        // and adds a vpiTypedefAlias ref -> the base.
        else if (topView) {
            const Type* leaf9 = &arrayElemLeaf(ta.targetType.getType())
                                     .getCanonicalType();
            if (ct.kind != SymbolKind::FixedSizeUnpackedArrayType &&
                leaf9->kind == SymbolKind::ClassType) {
                auto* cts9 = s.MakeClass_typespec();
                cts9->VpiParent(up);
                auto* gc9 = leaf9->as<ClassType>().genericClass;
                const void* key9 = gc9 ? (const void*)gc9 : (const void*)leaf9;
                UHDM::class_defn* gcd9 = nullptr;
                if (gc9) {
                    if (auto git9 = genericDefnMap.find(gc9);
                        git9 != genericDefnMap.end())
                        gcd9 = git9->second;
                }
                if (!gcd9)
                    gcd9 = classDefnFor(*leaf9);
                if (gcd9)
                    cts9->Class_defn(gcd9);
                else
                    pendingClassTsLink.push_back({cts9, leaf9});
                // The span is the class NAME token alone — a `#(...)`
                // specialization suffix is outside it.
                if (typeSyn) {
                    auto tr9 = typeSyn->sourceRange();
                    setLoc(cts9, SourceRange(tr9.start(),
                                             tr9.start() + leaf9->name.size()));
                }
                pkgClassTd9.push_back({std::string(ta.name), cts9, key9});
                ts = cts9;
            }
        }
        if (!ts)
            continue;
        ts->VpiName(prefix + std::string(ta.name));
        {
            UHDM::instance* tsInst9 = (UHDM::instance*)up;
            if (topView && aliasTargetTd9.count((const Symbol*)&ta))
                if (auto dpi9 = pkgDefMap.find(&pkg); dpi9 != pkgDefMap.end()) {
                    tsInst9 = (UHDM::instance*)dpi9->second;
                    pkgDefInstPinned.insert(ts);
                }
            ts->Instance(tsInst9);
            // An enum's base typespec rides the same pin (its owner's whole
            // elaborated object was minted in def-package context).
            if (tsInst9 != (UHDM::instance*)up &&
                ts->UhdmType() == UHDM::uhdmenum_typespec)
                if (auto* bt9 = ((UHDM::enum_typespec*)ts)->Base_typespec())
                    if (auto* ba9 = bt9->Actual_typespec()) {
                        ba9->Instance(tsInst9);
                        pkgDefInstPinned.insert(ba9);
                    }
        }
        // A member typed by ANOTHER package's struct typedef keeps that
        // package's vpiInstance on the member's OWN sub-typespecs (Surelog);
        // only this typedef's own objects move to the importing package.
        if (ts->UhdmType() == UHDM::uhdmstruct_typespec) {
            std::function<void(UHDM::typespec*, UHDM::instance*)> stampSub =
                [&](UHDM::typespec* t4, UHDM::instance* inst4) {
                    if (!t4 || t4->UhdmType() != UHDM::uhdmstruct_typespec)
                        return;
                    auto* ms4 = ((UHDM::struct_typespec*)t4)->Members();
                    if (!ms4)
                        return;
                    for (auto* tm4 : *ms4) {
                        if (!tm4->Typespec())
                            continue;
                        auto* at4 = tm4->Typespec()->Actual_typespec();
                        if (!at4)
                            continue;
                        if (at4->Instance())
                            at4->Instance(inst4);
                        stampSub(at4, inst4);
                    }
                };
            if (ct.kind == SymbolKind::PackedStructType) {
                auto& pst4 = ct.as<PackedStructType>();
                auto* ms5 = ((UHDM::struct_typespec*)ts)->Members();
                for (auto& fld4 : pst4.membersOfType<FieldSymbol>()) {
                    auto dt4 = fld4.getDeclaredType();
                    if (!dt4 || dt4->getType().kind != SymbolKind::TypeAlias)
                        continue;
                    const Scope* hs4 = dt4->getType()
                                           .as<TypeAliasType>()
                                           .getParentScope();
                    if (!hs4 || hs4->asSymbol().kind != SymbolKind::Package ||
                        &hs4->asSymbol() == &pkg.asSymbol())
                        continue;
                    auto hip4 = pkgDefMap.find(&hs4->asSymbol());
                    if (hip4 == pkgDefMap.end() || !ms5)
                        continue;
                    for (auto* tm5 : *ms5)
                        if (tm5->VpiName() == fld4.name && tm5->Typespec())
                            stampSub(tm5->Typespec()->Actual_typespec(),
                                     (UHDM::instance*)hip4->second);
                }
            }
        }
        if (!topView)
            typedefTs[&ta] = ts;
        else
            pkgTopTypedefTs[&ta] = ts;
        UHDM::typespec* listTs = ts;
        // A pkg imported by ANOTHER pkg lists its DEF enum object in the
        // TOP view too (the top object appears only via module listings).
        if (topView && ct.kind == SymbolKind::EnumType &&
            pkgImportedByPkg.count(&pkg))
            if (auto dIt = typedefTs.find(&ta); dIt != typedefTs.end())
                listTs = dIt->second;
        pkgTdByName.emplace_back(std::string(ta.name), listTs);
    }
    // One class_typespec per GENERIC class is the base (the name-first of the
    // typedefs that share it); the rest are clones of it — same span, plus a
    // vpiTypedefAlias ref (doubled pkg::pkg:: fullname, like every other
    // self-alias this emitter builds) back to the base.
    {
        std::map<const void*, size_t> base9;
        for (size_t i = 0; i < pkgClassTd9.size(); i++) {
            auto* cd9 = std::get<2>(pkgClassTd9[i]);
            if (!cd9)
                continue;
            auto it9 = base9.find(cd9);
            if (it9 == base9.end() ||
                std::get<0>(pkgClassTd9[i]) <
                    std::get<0>(pkgClassTd9[it9->second]))
                base9[cd9] = i;
        }
        for (size_t i = 0; i < pkgClassTd9.size(); i++) {
            auto* cd9 = std::get<2>(pkgClassTd9[i]);
            if (!cd9)
                continue;
            size_t b9 = base9[cd9];
            if (b9 == i)
                continue;
            auto* bts9 = std::get<1>(pkgClassTd9[b9]);
            auto* cts9 = std::get<1>(pkgClassTd9[i]);
            cts9->VpiLineNo(bts9->VpiLineNo());
            cts9->VpiColumnNo(bts9->VpiColumnNo());
            cts9->VpiEndLineNo(bts9->VpiEndLineNo());
            cts9->VpiEndColumnNo(bts9->VpiEndColumnNo());
            cts9->VpiFile(bts9->VpiFile());
            auto* art9 = s.MakeRef_typespec();
            art9->VpiParent(cts9);
            art9->VpiFullName(prefix + prefix + std::get<0>(pkgClassTd9[i]));
            art9->Actual_typespec(bts9);
            cts9->Typedef_alias(art9);
        }
    }
    // The Typespecs LIST is name-sorted (creation stayed source-ordered).
    std::stable_sort(pkgTdByName.begin(), pkgTdByName.end(),
                     [](auto& a, auto& b) { return a.first < b.first; });
    for (auto& [nm0, ts0] : pkgTdByName)
        tds->push_back(ts0);
    // UhdmWriter::writeImportedSymbols appends an import_typespec only when no
    // typespec of that name is in the vector yet ("Prevents multiple
    // definition") — and for a PACKAGE it runs AFTER writeDataTypes, so the
    // typedefs above are in scope of the check. First import item of a package
    // wins; every later item of the same package is dropped.
    for (auto* it9 : importTss) {
        bool dup9 = false;
        for (auto* t9 : *tds)
            if (t9->VpiName() == it9->VpiName()) {
                dup9 = true;
                break;
            }
        if (!dup9)
            tds->push_back(it9);
    }
    if (!tds->empty())
        up->Typespecs(tds);
    // PACKAGE-SCOPE DATA DECLARATIONS split two ways in Surelog (r9bpapb,
    // measured on a purpose-built golden covering every builtin data type):
    //
    //   * a declaration written with a USER TYPEDEF that resolves to a packed
    //     vector or a packed struct (`word v;`, `st sv;`) is a NET —
    //     logic_net in vpiNet, with vpiNetType = vpiNet(36) stamped in the
    //     ELABORATED view only (the def view leaves it unset; PackageNet).
    //   * EVERYTHING ELSE is a VARIABLE in vpiVariables, byte-identical in
    //     both views: every keyword type (logic/reg/bit/byte/int/integer/
    //     shortint/longint/time/real/string/chandle), an ENUM typedef
    //     (enum_var — a typedef, but NOT a net), and class handles
    //     (class_var). vpiVisibility=1 always; vpiAutomatic=1 for every kind
    //     EXCEPT enum_var and class_var; vpiConstantVariable=1 for a `const`
    //     declaration; the initializer rides as vpiExpr; the object spans the
    //     whole DECLARATOR (name through initializer), while its typespec
    //     spans the type syntax.
    //
    // So the discriminator is the WRITTEN type, not integrality: `logic ls;`
    // and `int iv;` are package variables even though both are integral.
    // UNPACKED-array declarations are an array_var carrying a vpiReg child
    // and folded ranges — not modelled yet, still dropped.
    {
        auto* pnets = s.MakeNetVec();
        auto* pvars = s.MakeVariablesVec();
        // The out-of-body CONSTRUCTOR body locals Surelog duplicates into
        // this listing (collectOobCtorLocals).  They are NOT package
        // members, so they carry no place in the members() walk: flush each
        // one as soon as the walk passes its source location, which is what
        // puts the whole listing back in source order (golden's Variables
        // vector is strictly ascending by declaration position).
        std::vector<const Symbol*> hoist9;
        collectOobCtorLocals(pkg, hoist9);
        size_t hIdx9 = 0;
        auto flushHoist9 = [&](SourceLocation upto, bool all) {
            while (hIdx9 < hoist9.size() &&
                   (all || hoist9[hIdx9]->location < upto)) {
                size_t before9 = pvars->size();
                emitPackageVar(*hoist9[hIdx9++], up, prefix, pvars);
                // A hoisted SUBROUTINE local keeps its AUTOMATIC lifetime
                // even in kinds that carry none at package scope: golden's
                // hoisted class_vars (clp/top/cs/bld/common/rh) are all
                // vpiAutomatic:1 while the package's own class_vars
                // (build_ph, uvm_cmdline_proc) are not.
                for (size_t i9 = before9; i9 < pvars->size(); i9++)
                    (*pvars)[i9]->VpiAutomatic(true);
            }
        };
        for (auto& mem : pkg.members()) {
            if (mem.kind != SymbolKind::Variable)
                continue;
            auto& vs = mem.as<VariableSymbol>();
            const DeclaredType* dt = vs.getDeclaredType();
            if (!dt)
                continue;
            flushHoist9(vs.location, false);
            auto& ct = dt->getType().getCanonicalType();
            // Anonymous packed struct/union spellings are NETS like their
            // typedef'd forms (Surelog-measured, r9bpapb probe2) — the
            // written-type discriminator must not push them to the var arm.
            bool anonPacked =
                dt->getType().kind == SymbolKind::PackedStructType ||
                dt->getType().kind == SymbolKind::PackedUnionType;
            if (!anonPacked &&
                (!ct.isIntegral() || ct.isEnum() ||
                 dt->getType().kind != SymbolKind::TypeAlias)) {
                emitPackageVar(vs, up, prefix, pvars);
                continue;
            }
            auto* n = s.MakeLogic_net();
            n->VpiName(vs.name);
            n->VpiFullName(prefix + std::string(vs.name));
            n->VpiParent(up);
            setLoc(n, nameSpan(vs.location, vs.name));
            // vpiNet (36), not vpiWire: a package data declaration is not a
            // wire, and Surelog stamps the generic net kind — and only in the
            // ELABORATED view.
            if (topView)
                n->VpiNetType(vpiNet);
            // The net's typespec ref is named after the NET (my_package1::v)
            // and resolves to this view's shared package typedef object.
            UHDM::typespec* nts = nullptr;
            if (dt->getType().kind == SymbolKind::TypeAlias) {
                auto& ta0 = dt->getType().as<TypeAliasType>();
                if (topView) {
                    if (auto ti = pkgTopTypedefTs.find(&ta0);
                        ti != pkgTopTypedefTs.end())
                        nts = ti->second;
                }
                if (!nts)
                    if (auto ti = typedefTs.find((const Symbol*)&ta0);
                        ti != typedefTs.end())
                        nts = ti->second;
            }
            if (nts) {
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(prefix + std::string(vs.name));
                rt->VpiParent(n);
                // The net does NOT bind the package's listed typedef object:
                // Surelog gives every net use its own SELF-ALIAS clone (a
                // fresh logic_typespec of the same name whose Typedef_alias
                // points back at the listed one) — the same shape
                // portVectorTypedefClone builds for ports. uhdm-dump does not
                // print vpiTypedefAlias in this nesting, so the difference is
                // visible only through Compare.
                UHDM::typespec* bind = nts;
                if (nts->UhdmType() == UHDM::uhdmlogic_typespec) {
                    auto& ta1 = dt->getType().as<TypeAliasType>();
                    const syntax::SyntaxNode* tSyn1 = nullptr;
                    if (auto asyn1 = ta1.getSyntax())
                        if (asyn1->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tSyn1 =
                                asyn1->as<syntax::TypedefDeclarationSyntax>().type;
                    bool savedBTS1 = bypassTypedefShare;
                    bypassTypedefShare = true;
                    auto* cl1 = makeTypespec(ta1, tSyn1);
                    bypassTypedefShare = savedBTS1;
                    if (cl1 && cl1->UhdmType() == UHDM::uhdmlogic_typespec) {
                        cl1->VpiName(nts->VpiName());
                        auto* art1 = s.MakeRef_typespec();
                        art1->VpiFullName(std::string(nts->VpiName()));
                        art1->VpiParent(cl1);
                        art1->Actual_typespec(nts);
                        ((UHDM::logic_typespec*)cl1)->Typedef_alias(art1);
                        if (nts->Instance())
                            cl1->Instance(nts->Instance());
                        bind = cl1;
                    }
                }
                rt->Actual_typespec(bind);
                n->Typespec(rt);
            }
            pnets->push_back(n);
            pkgViewVarObjs9[&vs] = n;
            pkgVarObjsAll9[&vs] = n;
        }
        flushHoist9(SourceLocation(), true);
        if (!pnets->empty())
            up->Nets(pnets);
        if (!pvars->empty())
            up->Variables(pvars);
        // Refs from this package's own subroutines and class methods bind
        // these objects (svunit_pkg::svunit_version read by
        // svunit_testrunner::report); see pkgViewVarObjs9.
        for (auto* pv9 : *pvars)
            for (auto& mem9 : pkg.members())
                if (mem9.kind == SymbolKind::Variable &&
                    mem9.name == pv9->VpiName()) {
                    pkgViewVarObjs9[&mem9] = pv9;
                    pkgVarObjsAll9[&mem9] = pv9;
                }
    }
    // A package STRUCT typedef named as a package SUBROUTINE ARGUMENT's type
    // has its shared typespec RE-LOCATED to that argument's type reference —
    // Surelog's last-writer stamp. A RETURN type does NOT relocate
    // (rsp_gen_minimal: tl_d2h_t moves to the arg, tl_d2h_rsp_intg_t stays).
    for (auto& mem9 : pkg.members()) {
        if (mem9.kind != SymbolKind::Subroutine)
            continue;
        for (auto* arg9 : mem9.as<SubroutineSymbol>().getArguments()) {
            auto dt9 = arg9->getDeclaredType();
            if (!dt9 || dt9->getType().kind != SymbolKind::TypeAlias ||
                !(dt9->getType().getCanonicalType().isStruct() ||
                  dt9->getType().getCanonicalType().isPackedUnion()))
                continue;
            UHDM::typespec* sh9 = nullptr;
            // An IMPORTED typedef relocates this package's own CLONE, never
            // the home package's def object (rp32 riscv_isa_pkg isa_t keeps
            // its 148:9 declaration span; the riscv_isa_i_pkg clone takes the
            // enc32 formal's span).
            if (auto ic9 = pkgImportCloneTs.find(&dt9->getType());
                ic9 != pkgImportCloneTs.end())
                sh9 = ic9->second;
            // ...and a typedef named through an explicit `other_pkg::T`
            // QUALIFICATION relocates nothing at all: the object belongs to
            // its declaring package and Surelog leaves it at the typedef span
            // (PackFunc's `input b::foo_bar_t a` in package aa). Only a
            // typedef this package DECLARES is a last-writer target.
            else if (const Scope* hs9 = dt9->getType().getParentScope();
                     hs9 && hs9->asSymbol().kind == SymbolKind::Package &&
                     &hs9->asSymbol() != (const Symbol*)&pkg)
                continue;
            else if (topView) {
                if (auto i9 = pkgTopTypedefTs.find((const void*)&dt9->getType());
                    i9 != pkgTopTypedefTs.end())
                    sh9 = i9->second;
            }
            else if (auto i8 = typedefTs.find(&dt9->getType());
                     i8 != typedefTs.end())
                sh9 = i8->second;
            if (!sh9 || (sh9->UhdmType() != UHDM::uhdmstruct_typespec &&
                         sh9->UhdmType() != UHDM::uhdmunion_typespec))
                continue;
            if (auto tsy9 = dt9->getTypeSyntax())
                setLoc(sh9, tsy9->sourceRange());
        }
    }
    // A struct/union-typed package parameter references the SHARED package
    // typedef object (Surelog), not the fresh clone built during emitParameters
    // (which ran before this typedef loop, so nested-struct members had no
    // registered inner typedef and fell back to logic_typespec). Re-point each
    // such param's typespec actual to the now-materialized typedef.
    if (up->Parameters())
        for (auto& member : pkg.members()) {
            if (member.kind != SymbolKind::Parameter)
                continue;
            auto& ps2 = member.as<ParameterSymbol>();
            auto d0 = ps2.getDeclaredType();
            if (!d0 || d0->getType().kind != SymbolKind::TypeAlias)
                continue;
            auto ck2 = d0->getType().getCanonicalType().kind;
            if (ck2 != SymbolKind::PackedStructType &&
                ck2 != SymbolKind::UnpackedStructType &&
                ck2 != SymbolKind::PackedUnionType &&
                ck2 != SymbolKind::UnpackedUnionType)
                continue;
            auto& taSym2 = d0->getType().as<TypeAliasType>();
            UHDM::typespec* shared = nullptr;
            if (topView) {
                if (auto tit = pkgTopTypedefTs.find(&taSym2);
                    tit != pkgTopTypedefTs.end())
                    shared = tit->second;
            }
            else if (auto tit = typedefTs.find(&d0->getType());
                     tit != typedefTs.end())
                shared = tit->second;
            if (!shared)
                continue;
            for (auto* pv0 : *up->Parameters()) {
                if (pv0->UhdmType() != UHDM::uhdmparameter)
                    continue;
                auto* pv = (UHDM::parameter*)pv0;
                if (pv->VpiName() == ps2.name && pv->Typespec() &&
                    pv->Typespec()->Actual_typespec() &&
                    pv->Typespec()->Actual_typespec()->UhdmType() ==
                        shared->UhdmType())
                    pv->Typespec()->Actual_typespec(shared);
            }
        }
    // An UNPACKED-ARRAY-of-struct/union/enum package parameter's array_typespec
    // element also references the SHARED typedef; re-point its Elem actual
    // (built as a logic_typespec before the typedef loop ran).
    if (up->Parameters())
        for (auto& member : pkg.members()) {
            if (member.kind != SymbolKind::Parameter)
                continue;
            auto& ps2 = member.as<ParameterSymbol>();
            const Type* leaf = &ps2.getType().getCanonicalType();
            if (leaf->kind != SymbolKind::FixedSizeUnpackedArrayType)
                continue;
            while (leaf->getCanonicalType().kind ==
                   SymbolKind::FixedSizeUnpackedArrayType)
                leaf = &leaf->getCanonicalType()
                            .as<FixedSizeUnpackedArrayType>()
                            .elementType;
            if (leaf->kind != SymbolKind::TypeAlias)
                continue;
            UHDM::typespec* shared = nullptr;
            if (topView) {
                if (auto tit = pkgTopTypedefTs.find(&leaf->as<TypeAliasType>());
                    tit != pkgTopTypedefTs.end())
                    shared = tit->second;
            }
            else if (auto tit = typedefTs.find(leaf);
                     tit != typedefTs.end())
                shared = tit->second;
            if (!shared || (shared->UhdmType() != UHDM::uhdmstruct_typespec &&
                            shared->UhdmType() != UHDM::uhdmunion_typespec &&
                            shared->UhdmType() != UHDM::uhdmenum_typespec))
                continue;
            for (auto* pv0 : *up->Parameters()) {
                if (pv0->UhdmType() != UHDM::uhdmparameter)
                    continue;
                auto* pv = (UHDM::parameter*)pv0;
                if (pv->VpiName() != ps2.name || !pv->Typespec())
                    continue;
                auto* ats0 = pv->Typespec()->Actual_typespec();
                if (ats0 && ats0->UhdmType() == UHDM::uhdmarray_typespec)
                    if (auto* er = ((UHDM::array_typespec*)ats0)->Elem_typespec();
                        er && er->Actual_typespec() &&
                        er->Actual_typespec()->UhdmType() !=
                            UHDM::uhdmstruct_typespec)
                        er->Actual_typespec(shared);
            }
        }
    inPkgTypedefEmit = false;
    pkgTopEmit = topView;
    emitTaskFuncs(pkg, up, prefix, nullptr, /*sharedScope=*/false);
    pkgTopEmit = false;
    // Package classes ride the ELABORATED package view only
    // (§emitPackageClasses), emitted while the package context vars are
    // still in force, then the outer context is restored.
    if (topView) {
        emitPackageClasses(pkg, up, prefix);
        // ...and the DEF view gains one clone per out-of-body class-method
        // definition. It runs here, not in the def pass, because the clones
        // are built from the class_defns emitPackageClasses just created.
        emitPackageClassMethodClones(pkg, prefix);
    }
    curPkgEmitSym = savedCurPkg0;
    pkgEmitTopView = savedPkgTopView0;
    pkgViewVarObjs9 = savedPkgViewVars0;
    return up;
}

// See the header: the un-elaborated package's Task_funcs listing for
// `extern`-declared class methods. Two passes over the package's classes in
// DECLARATION order — non-constructors first, constructors second — because
// Surelog binds constructors after every other method, at both the class and
// the package level.
void UhdmExporter::emitPackageClassMethodClones(const PackageSymbol& pkg,
                                                const std::string& prefix) {
    auto dit = pkgDefMap.find(&pkg);
    if (dit == pkgDefMap.end() || !dit->second)
        return;
    std::vector<const ClassType*> pcls;
    for (auto& mem : pkg.members()) {
        if (mem.kind == SymbolKind::ClassType)
            pcls.push_back(&mem.as<ClassType>());
        else if (mem.kind == SymbolKind::GenericClassDef) {
            if (auto* dsp = mem.as<GenericClassDefSymbol>().getDefaultSpecialization(pkg);
                dsp && dsp->kind == SymbolKind::ClassType)
                pcls.push_back(&dsp->as<ClassType>());
        }
    }
    if (pcls.empty())
        return;
    pkgClassTfClone = dit->second;
    auto* savedCd0 = currentClassDefn;
    for (int pass = 0; pass < 2; pass++) {
        pkgClassTfCloneCtors = pass == 1;
        for (auto* c : pcls) {
            auto cit = classDefnMap.find(c);
            if (cit == classDefnMap.end())
                continue;
            currentClassDefn = cit->second;
            emitTaskFuncs(*c, cit->second,
                          prefix + std::string(c->name) + "::", nullptr,
                          /*sharedScope=*/false);
        }
    }
    currentClassDefn = savedCd0;
    // Surelog's package Task_funcs listing is not "free functions, then the
    // clones class by class" — it is ONE pass in DECLARATION-SOURCE order
    // over everything that is not a constructor (a free function sits
    // between two class methods whenever the source puts it there:
    // BuildUVMPkg's `uvm_hdl_concat2string` @61044 lands between
    // uvm_sequence_library::do_print @57012 and uvm_reg_backdoor::* @63227),
    // followed by one pass in the same order over the constructors.  The
    // two-pass emission above is kept — creation order is load-bearing for
    // binding — and only the LISTING is re-ordered, here, once both passes
    // have contributed.  Anything without a recorded key (never expected)
    // suppresses the sort rather than sorting against a fabricated one.
    if (auto* tfv = dit->second->Task_funcs()) {
        bool haveAll = true;
        for (auto* t : *tfv)
            if (!pkgTfOrder9.count(t)) {
                haveAll = false;
                break;
            }
        if (haveAll)
            std::stable_sort(tfv->begin(), tfv->end(),
                             [&](const UHDM::BaseClass* a,
                                 const UHDM::BaseClass* b) {
                                 auto& ka = pkgTfOrder9[a];
                                 auto& kb = pkgTfOrder9[b];
                                 if (ka.first != kb.first)
                                     return ka.first < kb.first;
                                 return ka.second < kb.second;
                             });
    }
    pkgClassTfClone = nullptr;
    pkgClassTfCloneCtors = false;
}

// One package-scope VARIABLE declaration (the non-net half of the split
// documented at the call site). Shapes measured against Surelog on a
// purpose-built golden: `string s = "hello"`, `const string cs`, `real r`,
// `cls_a h`, `int iv`, `logic ls`, `logic [3:0] lv`, `bit bt`, `byte by`,
// `integer ig`, `shortint si`, `longint li`, `time tm`, `ename ev`, `reg rg`.
void UhdmExporter::emitPackageVar(const Symbol& vs, UHDM::instance* up,
                                  const std::string& prefix,
                                  UHDM::VectorOfvariables* out,
                                  bool stampTsInstance) {
    const DeclaredType* dt = vs.getDeclaredType();
    if (!dt)
        return;
    auto& ct = dt->getType().getCanonicalType();
    // Unpacked aggregates (array_var + vpiReg child + folded ranges) are not
    // modelled here yet — dropping is the honest arm, mis-shaping them is
    // not.  DYNAMIC containers are (emitPkgArrayVar).
    switch (ct.kind) {
        case SymbolKind::DynamicArrayType:
        case SymbolKind::AssociativeArrayType:
        case SymbolKind::QueueType:
            // ...in the PACKAGE's own listing only; the copy an importing
            // MODULE materialises is unmeasured, so it keeps dropping.
            if (stampTsInstance)
                emitPkgArrayVar(vs, up, prefix, out);
            return;
        case SymbolKind::FixedSizeUnpackedArrayType:
        case SymbolKind::UnpackedStructType:
        case SymbolKind::UnpackedUnionType:
            return;
        default:
            break;
    }
    // Anonymous packed struct/union spellings are NETS at package scope
    // (Surelog-measured, probe2); the caller's net branch handles them. This
    // guard only defends future callers — mis-shaping as logic_var via the
    // reg fallback below would be worse than dropping.
    if (dt->getType().kind == SymbolKind::PackedStructType ||
        dt->getType().kind == SymbolKind::PackedUnionType)
        return;
    auto* v = makeVar(vs, /*portBacked=*/false);
    // A `reg` declaration is excluded from makeVar's logic_var arm because a
    // MODULE `reg` stays a net; a PACKAGE one is a logic_var like every other
    // keyword-typed package declaration.
    if (!v && ct.isIntegral() && ct.isFourState() &&
        ct.kind != SymbolKind::PredefinedIntegerType) {
        auto* lv = s.MakeLogic_var();
        lv->VpiVisibility(1);
        v = lv;
    }
    if (!v)
        return;
    std::string full = prefix + std::string(vs.name);
    v->VpiName(vs.name);
    v->VpiFullName(full);
    v->VpiParent(up);
    // The object spans the whole DECLARATOR — name token through initializer
    // — not just the name.
    if (auto* dsyn = vs.getSyntax();
        dsyn && dsyn->kind == syntax::SyntaxKind::Declarator)
        setLoc(v, dsyn->sourceRange());
    else
        setLoc(v, nameSpan(vs.location, vs.name));
    // vpiAutomatic rides every kind but enum_var and class_var (Surelog).
    if (v->UhdmType() != UHDM::uhdmenum_var &&
        v->UhdmType() != UHDM::uhdmclass_var)
        v->VpiAutomatic(true);
    if (vs.kind == SymbolKind::Variable &&
        vs.as<VariableSymbol>().flags.has(VariableFlags::Const))
        v->VpiConstantVariable(true);
    if (auto* ts = makeTypespec(vs)) {
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(full);
        rt->VpiParent(v);
        rt->Actual_typespec(ts);
        v->Typespec(rt);
        // A package-scope declaration's typespec is resolved in the package's
        // own scope, so it carries vpiInstance = the package — the same stamp
        // emitTaskFuncs already puts on a package subroutine's typespecs.
        // typespec::Compare recurses Instance(), so a missing one is a cmp
        // difference (ApbSlave `const string svunit_version` / the
        // `svunit_testcase current_tc` class handle).
        if (stampTsInstance && !ts->Instance())
            ts->Instance(up);
    }
    if (auto* init = dt->getInitializer()) {
        NetMap none9;
        if (auto* e = emitExpr(stripImplicitConv(*init), v, full, none9)) {
            // An INTEGRAL package variable's initializer constant is sized at
            // the VARIABLE's declared width, not the literal's own — measured
            // across int/byte/integer/shortint/bit and 4-state vectors, for
            // bare decimals and sized based literals alike (`int a = 3` -> 32,
            // `logic [3:0] e = 3` -> 4). Based literals keep their own
            // decompile/base; only the size follows the declaration.
            if (ct.isIntegral() && ct.getBitWidth()) {
                int32_t w9 = (int32_t)ct.getBitWidth();
                if (e->UhdmType() == UHDM::uhdmconstant) {
                    ((UHDM::constant*)e)->VpiSize(w9);
                    e->VpiParent(v);
                }
                // A negated literal (`int j = -4`) keeps the unary operation;
                // the width lands on its operand.
                else if (e->UhdmType() == UHDM::uhdmoperation)
                    if (auto* ops9 = ((UHDM::operation*)e)->Operands();
                        ops9 && ops9->size() == 1 &&
                        (*ops9)[0]->UhdmType() == UHDM::uhdmconstant)
                        ((UHDM::constant*)(*ops9)[0])->VpiSize(w9);
            }
            v->Expr((UHDM::expr*)e);
        }
    }
    out->push_back(v);
}

// A PACKAGE-scope dynamic container.  Measured on BuildUVMPkg's two, which
// are the whole shape:
//
//   uvm_object_wrapper uvm_deferred_init[$];          -> vpiArrayType 4
//   uvm_seed_map uvm_random_seed_table_lookup [string];  -> vpiArrayType 3
//
// Both are an array_var spanning the NAME ALONE (not the declarator, unlike
// a scalar package variable), vpiSize 1 / vpiRandType 1 / vpiVisibility 1,
// whose typespec ref resolves to an EMPTY array_typespec — no name, no
// span, no vpiInstance, no ranges and no element ref.  That is the point of
// difference from makeQueueDynArrayVar, which builds the SUBROUTINE-local
// shape (an [0:$] / [0:"unsized"] range and a shared element ref); Surelog's
// package data-declaration path and its statement path do not agree, so this
// must not be folded into that helper.  The element type rides ONLY on the
// single vpiReg child, a variable of the element's own kind with an EMPTY
// vpiName and the ARRAY's fullname.  An ASSOCIATIVE array adds the index
// type as the array_typespec's Index_typespec, spanning the index-type
// token inside the brackets.
bool UhdmExporter::emitPkgArrayVar(const Symbol& vs, UHDM::instance* up,
                                   const std::string& prefix,
                                   UHDM::VectorOfvariables* out) {
    auto* dt = vs.getDeclaredType();
    if (!dt)
        return false;
    auto& ct = dt->getType().getCanonicalType();
    const Type* elem = nullptr;
    const Type* idx = nullptr;
    int aType = 0;
    switch (ct.kind) {
        case SymbolKind::QueueType:
            elem = &ct.as<QueueType>().elementType;
            aType = vpiQueueArray;
            break;
        case SymbolKind::DynamicArrayType:
            elem = &ct.as<DynamicArrayType>().elementType;
            aType = vpiDynamicArray;
            break;
        case SymbolKind::AssociativeArrayType:
            elem = &ct.as<AssociativeArrayType>().elementType;
            idx = ct.as<AssociativeArrayType>().indexType;
            aType = vpiAssocArray;
            break;
        default:
            return false;
    }
    std::string full = prefix + std::string(vs.name);
    auto* av = s.MakeArray_var();
    av->VpiName(vs.name);
    av->VpiFullName(full);
    av->VpiParent(up);
    av->VpiSize(1);
    av->VpiArrayType(aType);
    av->VpiVisibility(1);
    // vpiNotRand on both — Surelog stamps the default rand type on every
    // package array_var while the scalar package variables carry none, and
    // uhdm-cmp DOES compare vpiRandType (vpiRand=2 first-failed here).
    av->VpiRandType(vpiNotRand);
    // ...and vpiAutomatic only on the ASSOCIATIVE one (measured: the queue
    // has none).  Neither field is compared by uhdm-cmp; both are recorded
    // for byte identity.
    if (aType == vpiAssocArray)
        av->VpiAutomatic(true);
    setLoc(av, nameSpan(vs.location, vs.name));
    auto* ats = s.MakeArray_typespec();
    auto* art = s.MakeRef_typespec();
    art->VpiFullName(full);
    art->VpiParent(av);
    art->Actual_typespec(ats);
    av->Typespec(art);
    // makeTypespec looks through the array dims, so it yields the ELEMENT's
    // typespec (a class_typespec for both of BuildUVMPkg's), spanning the
    // written type tokens and resolved in the package's scope.
    UHDM::typespec* elemTs = makeTypespec(vs);
    if (elemTs && !elemTs->Instance())
        elemTs->Instance(up);
    auto* reg = makeReturnVar(s, *elem);
    if (reg) {
        reg->VpiParent(av);
        reg->VpiFullName(full);
        setLoc(reg, nameSpan(vs.location, vs.name));
        if (elemTs) {
            auto* rrt = s.MakeRef_typespec();
            rrt->VpiFullName(full);
            rrt->VpiParent(reg);
            rrt->Actual_typespec(elemTs);
            reg->Typespec(rrt);
        }
        auto* rv = s.MakeVariablesVec();
        rv->push_back(reg);
        av->Variables(rv);
    }
    if (idx) {
        // The index typespec spans the token INSIDE the brackets
        // (`[string]` -> `string`); take it off the declarator's last
        // dimension rather than re-deriving it from the type.
        UHDM::typespec* its = nullptr;
        {
            auto& ick = idx->getCanonicalType();
            if (ick.kind == SymbolKind::StringType)
                its = s.MakeString_typespec();
            else if (ick.kind == SymbolKind::PredefinedIntegerType)
                its = predefIntTypespec(ick, vs);
            else if (ick.isIntegral())
                its = s.MakeLogic_typespec();
        }
        if (its) {
            const syntax::VariableDimensionSyntax* adim = nullptr;
            if (auto dsyn = vs.getSyntax();
                dsyn && dsyn->kind == syntax::SyntaxKind::Declarator)
                for (auto d : dsyn->as<syntax::DeclaratorSyntax>().dimensions)
                    adim = d;
            if (adim) {
                auto dr = adim->sourceRange();
                setLoc(its, SourceRange(dr.start() + 1, dr.end() - 1));
            }
            its->Instance(up);
            auto* irt = s.MakeRef_typespec();
            irt->VpiParent(ats);
            irt->Actual_typespec(its);
            ats->Index_typespec(irt);
        }
    }
    out->push_back(av);
    return true;
}

// Surelog compiles an OUT-OF-BODY CONSTRUCTOR in its home PACKAGE's scope
// and leaves the body's own locals behind in the package's variable listing
// as well as inside the function — one DUPLICATE object per local, named
// pkg::<local> (BuildUVMPkg: uvm_phase::new clp/val, uvm_root::new rh,
// uvm_component::new error_str/top/cs plus bld/common from a nested
// `begin`).  The distinguisher is the CONSTRUCTOR: a non-`new` out-of-body
// body hoists nothing (uvm_phase::execute_phase's four locals are absent
// from the package listing).  Locals of every nesting depth are collected,
// in source order; the caller interleaves them with the package's own
// declarations by location.
void UhdmExporter::collectOobCtorLocals(const PackageSymbol& pkg,
                                        std::vector<const Symbol*>& out) {
    std::function<void(const Scope&)> walk = [&](const Scope& sc) {
        for (auto& m : sc.members()) {
            if (m.kind == SymbolKind::Variable) {
                // slang materialises an implicit `this` handle in every class
                // method scope; it is not a written local and Surelog has no
                // object for it.
                if (m.as<VariableSymbol>().flags.has(
                        VariableFlags::CompilerGenerated))
                    continue;
                out.push_back(&m);
            }
            else if (m.kind == SymbolKind::StatementBlock)
                walk(m.as<StatementBlockSymbol>());
        }
    };
    auto scanClass = [&](const ClassType& c) {
        std::vector<const Symbol*> memberList;
        for (auto& m : c.members())
            memberList.push_back(&m);
        for (auto& m : c.members()) {
            if (m.kind != SymbolKind::MethodPrototype)
                continue;
            auto& mp = m.as<MethodPrototypeSymbol>();
            if (mp.flags.has(MethodFlags::Pure) || mp.name != "new")
                continue;
            auto* impl = mp.getSubroutine();
            if (!impl || !impl->getSyntax())
                continue;
            // Out-of-body == the subroutine members() never yields (the same
            // membership test emitTaskFuncs uses).
            if (std::find(memberList.begin(), memberList.end(),
                          (const Symbol*)impl) != memberList.end())
                continue;
            impl->getBody();
            walk(*impl);
        }
    };
    for (auto& mem : pkg.members()) {
        if (mem.kind == SymbolKind::ClassType)
            scanClass(mem.as<ClassType>());
        else if (mem.kind == SymbolKind::GenericClassDef) {
            if (auto* dsp =
                    mem.as<GenericClassDefSymbol>().getDefaultSpecialization(pkg);
                dsp && dsp->kind == SymbolKind::ClassType)
                scanClass(dsp->as<ClassType>());
        }
    }
    std::stable_sort(out.begin(), out.end(),
                     [](const Symbol* a, const Symbol* b) {
                         return a->location < b->location;
                     });
}

// After ALL def-view packages exist: insert the home def objects into the
// importing packages' Typespecs slots, stamp Instance = the importing pkg,
// and expose them for module import listings.

} // namespace slang_uhdm
