//------------------------------------------------------------------------------
//! @file ParamEmit.cpp
//! @brief Parameters, param_assigns, deferred param typespecs, packages
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

namespace slang_uhdm {

static bool containsUserCall(const Expression& e) {
    bool found = false;
    e.visit(makeVisitor([&](auto& v, const CallExpression& c) {
        if (!c.isSystemCall())
            found = true;
        v.visitDefault(c);
    }));
    return found;
}

void UhdmExporter::emitParameters(const Scope& body, UHDM::scope* m, const std::string& prefix,
                                  NetMap& netMap, bool topView, DefInfo* di, bool inPackage,
                                  bool topShareTs, bool funcScope) {
    auto* params = s.MakeAnyVec();
    auto* passigns = s.MakeParam_assignVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Parameter)
            continue;
        auto& ps = member.as<ParameterSymbol>();
        // Instance overrides: the bound initializer's syntax is the
        // override expression at the instantiation, not the declaration
        // default. Both views keep DEFAULT-derived values; the instance
        // param_assign carries the folded override.
        const syntax::ExpressionSyntax* defaultSyn = paramDefaultSyn(ps);
        const Expression* boundInit = ps.getInitializer();
        bool overridden = isOverriddenParam(ps);
        // A required (override-only) param has NO declaration default; Surelog
        // leaves it valueless/typespec-less in the def view.
        bool hasDefault = defaultSyn != nullptr;
        // The default, bound in this scope (used for values in both views).
        const Expression* defaultInit = hasDefault ? boundInit : nullptr;
        if (overridden) {
            ASTContext actx(body, LookupLocation::max);
            defaultInit = &Expression::bind(*defaultSyn, actx);
            if (defaultInit->bad())
                defaultInit = nullptr;
        }
        auto* up = s.MakeParameter();
        up->VpiName(ps.name);
        up->VpiFullName(joinPath(prefix, ps.name));
        up->VpiParent(m);
        setLoc(up, SourceRange(ps.location, ps.location + ps.name.size()));

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
        bool wantTs = false;
        if (isLocal)
            up->VpiLocalParam(true);
        // Function-scope, explicitly-TYPED, and ranged (localparam [7:0] X)
        // localparams are valued and typed like module non-local params.
        // All parameters — including plain local untyped ones (localparam
        // IDLE = 2'b00) — carry a value/typespec (Surelog); the inner
        // literalInit/wantTs gates decide the exact encoding.
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
                    std::string digits = raw.substr(tick + 1);
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
            if (!unbasedInit && literalInit && cv.isInteger() &&
                !cv.integer().hasUnknown()) {
                auto& iv = cv.integer();
                bool neg = iv.isSigned() && iv.isNegative();
                std::string digits = iv.toString(LiteralBase::Decimal, false);
                std::string value = (neg ? "INT:" : "UINT:") + digits;
                // Based-literal initializers keep their base encoding.
                if (auto init0 = defaultInit) {
                    auto& lit = stripImplicitConv(*init0);
                    if (lit.kind == ExpressionKind::IntegerLiteral) {
                        std::string raw = rawText(lit.sourceRange);
                        auto tick = raw.find('\'');
                        if (tick != std::string::npos) {
                            size_t basePos = tick + 1;
                            if (basePos < raw.size() &&
                                (raw[basePos] == 's' || raw[basePos] == 'S'))
                                basePos++;
                            char base = basePos < raw.size() ? (char)tolower(raw[basePos])
                                                             : 'd';
                            std::string litDigits = raw.substr(basePos + 1);
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
            // Untyped params carry a typespec only for LITERAL initializers;
            // computed values ($clog2(W), 2**S) get none. Typed and ranged
            // params always do.
            auto& ctw = ps.getType().getCanonicalType();
            // Typed/ranged params always carry a typespec (its range/type is
            // independent of the value); only an untyped literal is gated on a
            // known value.
            wantTs = (ctw.isIntegral() || ctw.isFloating() ||
                      (ctw.isString() && typedParam)) &&
                     (typedParam || isRangedUntypedParam(ps) ||
                      (literalInit && !unknownDefault));
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
                    ps.getType().getCanonicalType().isSigned() && hasKeyword)
                    up->VpiSigned(true);
            }
        }
        UHDM::ref_typespec* prt = nullptr;
        if (wantTs) {
            // The actual typespec object is created late (after the instance
            // ports) to match Surelog's arena order; the ref is patched then.
            prt = s.MakeRef_typespec();
            prt->VpiFullName(joinPath(prefix, ps.name));
            prt->VpiParent(up);
            up->Typespec(prt);
        }
        params->push_back(up);
        if (funcScope)
            netMap[&member] = up;

        UHDM::ref_typespec* rhsRt = nullptr;
        auto* pa = s.MakeParam_assign();
        pa->VpiParent(m);
        if (auto syn = ps.getSyntax())
            setLoc(pa, syn->sourceRange());
        pa->Lhs(up);
        // Function-scope params parent at their param_assign.
        if (funcScope)
            up->VpiParent(pa);
        if (topView && (overridden || (!hasDefault && boundInit)))
            pa->VpiOverriden(true);
        // Instance view of an override: folded constant, base-encoded and
        // override-site-anchored for literal overrides; expression overrides
        // anchor at the DEFAULT initializer.
        if (topView && overridden) {
            auto& cvo = ps.getValue();
            if (cvo.isInteger()) {
                auto& iv = cvo.integer();
                std::string digits = iv.toString(LiteralBase::Decimal, false);
                auto* c = s.MakeConstant();
                c->VpiDecompile(digits);
                // A GENERATE-containing child is uniquified by Surelog's
                // elaboration: its overrides encode UINT at the value width
                // even for untyped params.
                bool genChild = false;
                for (auto& mb0 : body.members())
                    if (mb0.kind == SymbolKind::GenerateBlock ||
                        mb0.kind == SymbolKind::GenerateBlockArray) {
                        genChild = true;
                        break;
                    }
                // Typed params fold UINT at the type width; untyped INT at
                // size -1.
                if (typedParam || genChild) {
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiSize((int32_t)iv.getBitWidth());
                }
                else {
                    c->VpiValue("INT:" + digits);
                    c->VpiConstType(vpiIntConst);
                    c->VpiSize(-1);
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
                    rt->VpiFullName(tsPrefix);
                    rt->VpiParent(c);
                    c->Typespec(rt);
                    rhsRt = rt;
                }
                pa->Rhs(c);
                passigns->push_back(pa);
                if (prt) {
                    if (!inPackage) {
                        pendingParamTs.push_back({&ps, up, prt, rhsRt, typedParam});
                    }
                    else {
                        auto* its = makeParamTs(ps, typedParam);
                        its->Instance((UHDM::instance*)m);
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
        if (!hasDefault && topView && boundInit)
            noDefOvPa[&member].push_back(pa);
        if (auto init0 = (overridden      ? defaultInit
                          : (!hasDefault) ? nullptr
                                          : ps.getInitializer())) {
            const Expression* init = init0;
            while (init->kind == ExpressionKind::Conversion &&
                   init->as<ConversionExpression>().isImplicit())
                init = &init->as<ConversionExpression>().operand();
            UHDM::any* rhs = nullptr;
            if (topView) {
                if (init->kind == ExpressionKind::IntegerLiteral) {
                    forceConstParent = true;
                    rhs = emitExpr(*init, pa, prefix, netMap);
                    forceConstParent = false;
                    if (rhs)
                        ((UHDM::constant*)rhs)->VpiSize((int32_t)ps.getType().getBitWidth());
                }
                // A TYPED string param never folds (the elab Rhs re-emits the
                // string constant, decompiled without quotes). Pkg CONCAT
                // inits keep the operation in both views.
                else if (!ps.getType().getCanonicalType().isString() &&
                         !(inPackage && stripImplicitConv(*init).kind ==
                                            ExpressionKind::Concatenation) &&
                         !containsUserCall(*init) &&
                         (rhs = tryFoldConst(
                              *init, (typedParam && init != init0) ? init0
                                                                   : nullptr))) {
                    ((UHDM::constant*)rhs)->VpiParent(pa);
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
                    ((UHDM::constant*)rhs)
                        ->VpiSize(typedParam ? (int32_t)ps.getType().getBitWidth()
                                  : sizeCastVal ? (int32_t)scv.type->getBitWidth()
                                                : 64);
                    setLoc((UHDM::constant*)rhs, init->sourceRange);
                    // A SUBTRACT init (W - 19) folds signed (INT).
                    if (scv.kind == ExpressionKind::BinaryOp &&
                        scv.as<BinaryExpression>().op == BinaryOperator::Subtract) {
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
                        if (bit.isUnknown()) {
                            std::string d = bit.value == logic_t::X_VALUE ? "X" : "Z";
                            c->VpiValue("BIN:" + d);
                            c->VpiConstType(vpiBinaryConst);
                            c->VpiDecompile(std::to_string(w) + "'b" + d);
                        }
                        else if (bit.value == 0) {
                            c->VpiValue("BIN:0");
                            c->VpiConstType(vpiBinaryConst);
                            c->VpiDecompile(std::to_string(w) + "'b0");
                        }
                        else {
                            slang::SVInt ones((slang::bitwidth_t)w, 0, false);
                            ones = ~ones;
                            std::string digits = ones.toString(LiteralBase::Decimal, false);
                            c->VpiValue("UINT:" + digits);
                            c->VpiConstType(vpiUIntConst);
                            c->VpiDecompile(digits);
                        }
                    }
                    // Typed-param (non-pattern) folds carry a ts ref to the param.
                    if (typedParam && wantTs && !isPattern) {
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
                forceConstParent = true;
                inParamInit = true;
                paramInitDef = !topView;
                paramInitPkg = inPackage;
                rhs = emitExpr(*init, pa, prefix, netMap);
                paramInitPkg = false;
                paramInitDef = false;
                inParamInit = false;
                forceConstParent = false;
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
                    if (anyUnknown) {
                        auto* rt = s.MakeRef_typespec();
                        std::string tsPrefix = prefix;
                        if (tsPrefix.size() >= 2 &&
                            tsPrefix.compare(tsPrefix.size() - 2, 2, "::") == 0)
                            tsPrefix.resize(tsPrefix.size() - 2);
                        rt->VpiFullName(tsPrefix);
                        rt->VpiParent(opr);
                        opr->Typespec(rt);
                        rhsRt = rt;
                    }
                }
            }
            if (rhs) {
                pa->Rhs(rhs);
                if (inPackage && !topView && rhs->UhdmType() == UHDM::uhdmconstant)
                    pkgParamConst[&member] = (UHDM::constant*)rhs;
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
                if (wantTs && rhs->UhdmType() == UHDM::uhdmconstant &&
                    (init->kind == ExpressionKind::IntegerLiteral ||
                     init->kind == ExpressionKind::UnbasedUnsizedIntegerLiteral ||
                     (typedParam && init->kind == ExpressionKind::StringLiteral))) {
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
        passigns->push_back(pa);
        if (prt) {
            if (topView && !inPackage) {
                pendingParamTs.push_back({&ps, up, prt, rhsRt, typedParam});
            }
            else {
                auto* its = makeParamTs(ps, typedParam);
                if (inPackage)
                    its->Instance((UHDM::instance*)m);
                if (di)
                    di->paramTs[&member] = its;
                if (rhsRt)
                    rhsRt->Actual_typespec(its);
                prt->Actual_typespec(its);
                bool signedImplicit = false;
                if (auto d0 = ps.getDeclaredType())
                    if (auto t0 = d0->getTypeSyntax())
                        if (t0->kind == syntax::SyntaxKind::ImplicitType)
                            signedImplicit =
                                t0->as<syntax::ImplicitTypeSyntax>().signing.valid() &&
                                t0->as<syntax::ImplicitTypeSyntax>().dimensions.empty();
                if (typedParam || isRangedUntypedParam(ps) || signedImplicit)
                    its->VpiParent(up);
            }
        }
    }
    if (!params->empty())
        m->Parameters(params);
    if (!passigns->empty())
        m->Param_assigns(passigns);
}

bool UhdmExporter::isRangedUntypedParam(const ParameterSymbol& ps) {
    if (auto declared = ps.getDeclaredType())
        if (auto tsyn = declared->getTypeSyntax())
            if (tsyn->kind == syntax::SyntaxKind::ImplicitType)
                return !tsyn->as<syntax::ImplicitTypeSyntax>().dimensions.empty() &&
                       ps.getType().getCanonicalType().isPackedArray();
    return false;
}

UHDM::typespec* UhdmExporter::makeParamTs(const ParameterSymbol& ps, bool typedParam,
                                          bool parentBounds) {
    SourceRange tr(ps.location, ps.location + ps.name.size());
    if (typedParam) {
        if (auto declared = ps.getDeclaredType())
            if (auto tsyn = declared->getTypeSyntax())
                tr = tsyn->sourceRange();
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
    // A real (real/shortreal) param is a real_typespec.
    if (typedParam && !its && ps.getType().getCanonicalType().isFloating())
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
        }
    }
    // An untyped param initialized with a string literal (parameter X = "FOO")
    // is a bare (unlocated) string_typespec, not an int_typespec.
    bool stringParam = false;
    if (!its && !typedParam) {
        if (auto init = ps.getInitializer();
            init && stripImplicitConv(*init).kind == ExpressionKind::StringLiteral) {
            its = s.MakeString_typespec();
            stringParam = true;
        }
    }
    UHDM::int_typespec* intTs = nullptr;
    if (!its) {
        intTs = s.MakeInt_typespec();
        // Untyped parameters carry no signedness flag.
        if (typedParam)
            intTs->VpiSigned(sgn);
        its = intTs;
    }
    if (!stringParam)
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
                        auto mkB = [&](int64_t v, const syntax::ExpressionSyntax* es) {
                            auto* c = s.MakeConstant();
                            c->VpiDecompile(std::to_string(v));
                            c->VpiSize(64);
                            c->VpiValue("UINT:" + std::to_string(v));
                            c->VpiConstType(vpiUIntConst);
                            c->VpiParent(r);
                            if (es)
                                setLoc(c, es->sourceRange());
                            return c;
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
                rawText(lit.sourceRange).find('\'') != std::string::npos) {
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

void UhdmExporter::patchParamTypespecs(size_t lo, size_t hi) {
    for (size_t i = lo; i < hi && i < pendingParamTs.size(); i++) {
        auto& [ps, up, prt, rhsRt, typedParam] = pendingParamTs[i];
        auto* its = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
        if (rhsRt) {
            // The ELAB UINT-recomputed fold ('1 -> all-ones) of a VECTOR
            // param binds a fresh LOC-LESS bare clone (unparented bounds,
            // no clone parent); BIN-valued folds keep the located ts.
            auto* rc0 = rhsRt->VpiParent();
            bool uintFold = rc0 && rc0->UhdmType() == UHDM::uhdmconstant &&
                            ((UHDM::constant*)rc0)->VpiValue().rfind("UINT:", 0) == 0;
            if (uintFold && typedParam && !isOverriddenParam(*ps) &&
                ps->getType().getCanonicalType().isPackedArray()) {
                if (auto* bare = makeBareVecParamTs(*ps, /*parentBounds=*/false))
                    rhsRt->Actual_typespec(bare);
            }
            else
                rhsRt->Actual_typespec(its);
        }
        prt->Actual_typespec(its);
        its->VpiParent(prt);
        // No-default override fold-constant ts refs share this elab ts.
        if (auto nit = noDefOvTsRef.find(ps); nit != noDefOvTsRef.end()) {
            for (auto* r0 : nit->second)
                r0->Actual_typespec(its);
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

void UhdmExporter::analyzeParamEnc(const InstanceBodySymbol& body) {
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Parameter)
            continue;
        auto& ps = member.as<ParameterSymbol>();
        if (auto init = ps.getInitializer()) {
            if (init->kind != ExpressionKind::IntegerLiteral && isIntEncoded(*init))
                paramIntEnc[&member] = true;
        }
    }
}

UHDM::package* UhdmExporter::emitPackage(const PackageSymbol& pkg, bool topView) {
    std::string prefix = std::string(pkg.name) + "::";
    auto* up = s.MakePackage();
    if (!topView)
        pkgDefMap[&pkg] = up;
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
    emitParameters(pkg, up, prefix, none, topView, nullptr, true);
    // Package typedefs: struct/enum/vector typespecs named pkg::T, parented and
    // instanced at the package, populating typedefTs so package-typedef'd
    // signals/params resolve.
    auto* tds = s.MakeTypespecVec();
    pkgTopEmit = topView; // enum-const decompile is view-dependent (buildEnumTs)
    for (auto& member : pkg.members()) {
        if (member.kind != SymbolKind::TypeAlias)
            continue;
        auto& ta = member.as<TypeAliasType>();
        auto& ct = ta.targetType.getType().getCanonicalType();
        const syntax::SyntaxNode* typeSyn = nullptr;
        if (auto syn = ta.getSyntax())
            if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
                typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
        UHDM::typespec* ts = nullptr;
        if (ct.kind == SymbolKind::PackedArrayType || ct.kind == SymbolKind::ScalarType) {
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
        else if (ct.kind == SymbolKind::PackedStructType) {
            // Package struct member refs use pkg::pkg::T::m (doubled prefix);
            // each field typespec carries vpiInstance = package.
            // DEF-view member bounds stay UNFOLDED (member-scoped refs bound
            // to the params' def init constants); the elab view folds them.
            std::string alias = prefix + prefix + std::string(ta.name);
            bool savedTf = tfContext;
            if (topView)
                tfContext = true;
            auto* sts = buildStructTs(ct.as<PackedStructType>(), true, alias, "::");
            tfContext = savedTf;
            sts->VpiParent(up);
            if (sts->Members())
                for (auto* tm : *sts->Members())
                    if (tm->Typespec() && tm->Typespec()->Actual_typespec()) {
                        auto* mts = tm->Typespec()->Actual_typespec();
                        mts->Instance((UHDM::instance*)up);
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
                    dm->Typespec()->Actual_typespec(taA);
                    tmM->Typespec()->Actual_typespec(da);
                    if (!taA->VpiName().length())
                        taA->VpiParent(dm);
                    if (!da->VpiName().length())
                        da->VpiParent(tmM);
                    if (dup2)
                        taA->Instance(dup2);
                    da->Instance((UHDM::instance*)up);
                }
            }
            ts = sts;
        }
        else if (ct.kind == SymbolKind::EnumType) {
            // The base ref fullname doubles the package scope
            // (pkg::pkg::name — Surelog scopes the already-prefixed typedef
            // name by the package again).
            auto* ets = buildEnumTs(ct.as<EnumType>(), typeSyn,
                                    prefix + prefix + std::string(ta.name));
            ets->VpiParent(up);
            if (auto syn = ta.getSyntax())
                setLoc(ets, syn->sourceRange());
            // The base typespec is package-instanced too.
            if (ets->Base_typespec() && ets->Base_typespec()->Actual_typespec())
                ets->Base_typespec()->Actual_typespec()->Instance((UHDM::instance*)up);
            ts = ets;
        }
        if (!ts)
            continue;
        ts->VpiName(prefix + std::string(ta.name));
        ts->Instance((UHDM::instance*)up);
        if (!topView)
            typedefTs[&ta] = ts;
        else
            pkgTopTypedefTs[&ta] = ts;
        tds->push_back(ts);
    }
    if (!tds->empty())
        up->Typespecs(tds);
    pkgTopEmit = topView;
    emitTaskFuncs(pkg, up, prefix, nullptr, /*sharedScope=*/false);
    pkgTopEmit = false;
    return up;
}

} // namespace slang_uhdm
