//------------------------------------------------------------------------------
//! @file ParamEmit.cpp
//! @brief Parameters, param_assigns, deferred param typespecs, packages
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

namespace slang_uhdm {

void UhdmExporter::emitParameters(const Scope& body, UHDM::scope* m, const std::string& prefix,
                                  NetMap& netMap, bool topView, DefInfo* di, bool inPackage) {
    auto* params = s.MakeAnyVec();
    auto* passigns = s.MakeParam_assignVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Parameter)
            continue;
        auto& ps = member.as<ParameterSymbol>();
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
        bool wantTs = false;
        if (isLocal) {
            up->VpiLocalParam(true);
        }
        else {
            auto& cv = ps.getValue();
            if (cv.isInteger() && !cv.integer().hasUnknown()) {
                auto& iv = cv.integer();
                bool neg = iv.isSigned() && iv.isNegative();
                std::string digits = iv.toString(LiteralBase::Decimal, false);
                up->VpiValue((neg ? "INT:" : "UINT:") + digits);
            }
            wantTs = ps.getType().getCanonicalType().isIntegral();
        }
        if (auto declared0 = ps.getDeclaredType()) {
            if (auto tsyn0 = declared0->getTypeSyntax()) {
                if (tsyn0->kind != syntax::SyntaxKind::ImplicitType &&
                    ps.getType().getCanonicalType().isSigned())
                    up->VpiSigned(true);
            }
        }
        bool typedParam = false;
        if (auto declared = ps.getDeclaredType()) {
            if (auto tsyn = declared->getTypeSyntax())
                typedParam = tsyn->kind != syntax::SyntaxKind::ImplicitType;
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

        UHDM::ref_typespec* rhsRt = nullptr;
        auto* pa = s.MakeParam_assign();
        pa->VpiParent(m);
        if (auto syn = ps.getSyntax())
            setLoc(pa, syn->sourceRange());
        pa->Lhs(up);
        if (auto init0 = ps.getInitializer()) {
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
                else if ((rhs = tryFoldConst(*init))) {
                    ((UHDM::constant*)rhs)->VpiParent(pa);
                    ((UHDM::constant*)rhs)->VpiSize(64);
                    setLoc((UHDM::constant*)rhs, init->sourceRange);
                }
            }
            if (!rhs) {
                forceConstParent = true;
                rhs = emitExpr(*init, pa, prefix, netMap);
                forceConstParent = false;
            }
            if (rhs) {
                pa->Rhs(rhs);
                if (inPackage && !topView && rhs->UhdmType() == UHDM::uhdmconstant)
                    pkgParamConst[&member] = (UHDM::constant*)rhs;
                // Literal inits of typed params carry the param typespec
                // (patched late together with the param ref).
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

UHDM::typespec* UhdmExporter::makeParamTs(const ParameterSymbol& ps, bool typedParam) {
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
    auto* its = s.MakeInt_typespec();
    // Untyped parameters carry no signedness flag.
    if (typedParam)
        its->VpiSigned(ps.getType().getCanonicalType().isSigned());
    setLoc(its, tr);
    return its;
}

void UhdmExporter::patchParamTypespecs() {
    for (auto& [ps, up, prt, rhsRt, typedParam] : pendingParamTs) {
        auto* its = makeParamTs(*ps, typedParam);
        if (rhsRt)
            rhsRt->Actual_typespec(its);
        prt->Actual_typespec(its);
        its->VpiParent(prt);
        (void)up;
        (void)typedParam;
    }
    pendingParamTs.clear();
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
    return up;
}

} // namespace slang_uhdm
