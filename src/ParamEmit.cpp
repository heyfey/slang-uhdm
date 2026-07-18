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
        // The default, bound in this scope (used for values in both views).
        const Expression* defaultInit = boundInit;
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

        // Packages: follow the source keyword (slang marks package params
        // local per LRM; Surelog does not).
        bool isLocal = ps.isLocalParam();
        if (inPackage) {
            isLocal = false;
            for (auto q = ps.getSyntax(); q; q = q->parent) {
                if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                    isLocal = q->as<syntax::ParameterDeclarationSyntax>().keyword.valueText() ==
                              "localparam";
                    break;
                }
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
        // Function-scope and explicitly-TYPED localparams are valued and
        // typed like module non-local params.
        if (!isLocal || funcScope || typedParam) {
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
            if (literalInit && cv.isInteger() && !cv.integer().hasUnknown()) {
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
            wantTs = ps.getType().getCanonicalType().isIntegral() && !unknownDefault;
        }
        if (auto declared0 = ps.getDeclaredType()) {
            if (auto tsyn0 = declared0->getTypeSyntax()) {
                if (tsyn0->kind != syntax::SyntaxKind::ImplicitType &&
                    ps.getType().getCanonicalType().isSigned())
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
        if (topView && overridden)
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
                // Typed params fold UINT at the type width; untyped INT at
                // size -1.
                if (typedParam) {
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
                        if (typedParam)
                            its->VpiParent(up);
                    }
                }
                continue;
            }
        }
        if (auto init0 = (overridden ? defaultInit : ps.getInitializer())) {
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
                else if (!containsUserCall(*init) && (rhs = tryFoldConst(*init))) {
                    ((UHDM::constant*)rhs)->VpiParent(pa);
                    // Typed params fold at the type width; untyped at 64.
                    ((UHDM::constant*)rhs)
                        ->VpiSize(typedParam ? (int32_t)ps.getType().getBitWidth() : 64);
                    setLoc((UHDM::constant*)rhs, init->sourceRange);
                    // Typed-param folds carry a ts ref to the param typespec.
                    if (typedParam && wantTs) {
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
                rhs = emitExpr(*init, pa, prefix, netMap);
                inParamInit = false;
                forceConstParent = false;
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
                        if (!wantTs && !rc->Typespec()) {
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
                if (wantTs && rhs->UhdmType() == UHDM::uhdmconstant &&
                    init->kind == ExpressionKind::IntegerLiteral) {
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
                if (typedParam)
                    its->VpiParent(up);
            }
        }
    }
    if (!params->empty())
        m->Parameters(params);
    if (!passigns->empty())
        m->Param_assigns(passigns);
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
    UHDM::int_typespec* intTs = nullptr;
    if (!its) {
        intTs = s.MakeInt_typespec();
        // Untyped parameters carry no signedness flag.
        if (typedParam)
            intTs->VpiSigned(sgn);
        its = intTs;
    }
    setLoc(its, tr);
    // Untyped params with based-literal inits gain a bare [w-1:0] range
    // (loc-less, value-only INT constants).
    if (!typedParam) {
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

void UhdmExporter::patchParamTypespecs(size_t lo, size_t hi) {
    for (size_t i = lo; i < hi && i < pendingParamTs.size(); i++) {
        auto& [ps, up, prt, rhsRt, typedParam] = pendingParamTs[i];
        auto* its = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
        if (rhsRt)
            rhsRt->Actual_typespec(its);
        prt->Actual_typespec(its);
        its->VpiParent(prt);
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
    if (auto syn = pkg.getSyntax())
        setLoc(up, syn->sourceRange());
    NetMap none;
    emitParameters(pkg, up, prefix, none, topView, nullptr, true);
    pkgTopEmit = topView;
    emitTaskFuncs(pkg, up, prefix, nullptr, /*sharedScope=*/false);
    pkgTopEmit = false;
    return up;
}

} // namespace slang_uhdm
