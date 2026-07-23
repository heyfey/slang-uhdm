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

// A module that IMPORTS (via wildcard or explicit import) and REFERENCES a
// package parameter materializes it as a module-local parameter (Surelog sets
// vpiImported = the package name). A QUALIFIED reference (pkg::P) with no
// import does NOT materialize it (ParameterColonReference, PkgParamAsFunctionArg).
static void collectImportedParams(const Scope& body,
                                  std::vector<const ParameterSymbol*>& out) {
    std::set<const Symbol*> wildcardPkgs; // packages wildcard-imported
    std::set<const Symbol*> explicitSyms; // explicitly imported symbols
    for (auto& m : body.members()) {
        if (m.kind == SymbolKind::WildcardImport) {
            if (auto* p = m.as<WildcardImportSymbol>().getPackage())
                wildcardPkgs.insert(p);
        }
        else if (m.kind == SymbolKind::ExplicitImport) {
            if (auto* imp = m.as<ExplicitImportSymbol>().importedSymbol())
                explicitSyms.insert(imp);
        }
    }
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
        }
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
    // Surelog orders materialized imported params by their DECLARATION order
    // in the package, not by reference-discovery order.
    std::stable_sort(found.begin(), found.end(),
                     [](const ParameterSymbol* a, const ParameterSymbol* b) {
                         return a->location < b->location;
                     });
    out.insert(out.end(), found.begin(), found.end());
}

void UhdmExporter::emitParameters(const Scope& body, UHDM::scope* m, const std::string& prefix,
                                  NetMap& netMap, bool topView, DefInfo* di, bool inPackage,
                                  bool topShareTs, bool funcScope) {
    auto* params = s.MakeAnyVec();
    auto* passigns = s.MakeParam_assignVec();
    std::vector<const ParameterSymbol*> paramSyms;
    for (auto& member0 : body.members())
        if (member0.kind == SymbolKind::Parameter)
            paramSyms.push_back(&member0.as<ParameterSymbol>());
    if (!inPackage && !funcScope) {
        collectImportedParams(body, paramSyms);
        // The module list is SOURCE-LOCATION ordered: materialized imported
        // params (pkg locs, usually earlier) list before declared ones.
        std::stable_sort(paramSyms.begin(), paramSyms.end(),
                         [](const ParameterSymbol* a,
                            const ParameterSymbol* b) {
                             return a->location < b->location;
                         });
    }
    for (auto* psPtr : paramSyms) {
        const Symbol& member = *psPtr;
        auto& ps = *psPtr;
        // Imported = the param belongs to ANOTHER scope (a package), not the
        // body being emitted (a package emitting its own params is NOT that).
        bool isImported = ps.getParentScope() != &body;
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
            // A bare assignment PATTERN ('{...}) cannot bind without a target
            // type — re-bind with the param's own type so pattern defaults
            // keep their Rhs (tagged-pattern op) instead of silently dropping.
            if (defaultInit->bad())
                defaultInit = &Expression::bindRValue(
                    ps.getType(), *defaultSyn, defaultSyn->sourceRange(), actx);
            if (defaultInit->bad())
                defaultInit = nullptr;
        }
        auto* up = s.MakeParameter();
        up->VpiName(ps.name);
        up->VpiFullName(joinPath(prefix, ps.name));
        up->VpiParent(m);
        setLoc(up, SourceRange(ps.location, ps.location + ps.name.size()));
        if (isImported)
            up->VpiImported(std::string(ps.getParentScope()->asSymbol().name));

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
        if (isImported && !typedParam) {
            auto& ct0 = ps.getType().getCanonicalType();
            typedParam = ct0.kind == SymbolKind::PredefinedIntegerType ||
                         ct0.kind == SymbolKind::ScalarType ||
                         (ct0.kind == SymbolKind::PackedArrayType && ct0.isIntegral());
        }
        bool wantTs = false;
        if (isLocal)
            up->VpiLocalParam(true);
        // Function-scope, explicitly-TYPED, and ranged (localparam [7:0] X)
        // localparams are valued and typed like module non-local params.
        // All parameters — including plain local untyped ones (localparam
        // IDLE = 2'b00) — carry a value/typespec (Surelog); the inner
        // literalInit/wantTs gates decide the exact encoding.
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
                                  return d9->kind == ExpressionKind::BinaryOp ||
                                         containsUserCall(*defaultInit);
                              }();
            if (!unbasedInit && (literalInit || pkgElabComputed) &&
                cv.isInteger() && !cv.integer().hasUnknown()) {
                auto& iv = cv.integer();
                bool neg = (iv.isSigned() && iv.isNegative()) ||
                           (pkgElabComputed && iv.isSigned() && defaultInit &&
                            containsUserCall(*defaultInit));
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
            bool realLit =
                defaultInit && stripImplicitConv(*defaultInit).kind ==
                                   ExpressionKind::RealLiteral;
            wantTs = (ctw.isIntegral() || ctw.isFloating() || ctw.isStruct() ||
                      (ctw.isString() && (typedParam || literalInit))) &&
                     (typedParam || isRangedUntypedParam(ps) || pkgElabComputed ||
                      ((literalInit || realLit) && !unknownDefault));
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
                    ps.getType().getCanonicalType().kind != SymbolKind::EnumType)
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
            auto* prng = buildUnpackedRanges(ps, up);
            if (prng)
                up->Ranges(prng);
            up->VpiSize(1);
            up->VpiSigned(leaf->isSigned());
            auto* ats = makeUnpackedArrayParamTs(ps, afull, up, prng);
            auto* art = s.MakeRef_typespec();
            art->VpiFullName(afull);
            art->VpiParent(up);
            art->Actual_typespec(ats);
            up->Typespec(art);
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
        if (topView && (overridden || (!hasDefault && boundInit)))
            pa->VpiOverriden(true);
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
        if (topView && (overridden || noDefExprOv || noDefLitMP)) {
            auto& cvo = ps.getValue();
            if (cvo.isInteger()) {
                auto& iv = cvo.integer();
                std::string digits = iv.toString(LiteralBase::Decimal, false);
                auto* c = s.MakeConstant();
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
                // A VECTOR-TYPEDEF param's literal override keeps its SOURCE
                // base form (384'b1 -> BIN:1, binary const) — Surelog.
                bool vecAliasOv8 = false;
                if (typedParam && boundInit && ps.getDeclaredType() &&
                    ps.getDeclaredType()->getType().kind ==
                        SymbolKind::TypeAlias &&
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
                        std::string dg8 = raw8.substr(bp8 + 1);
                        if (base8 == 'b' || base8 == 'h' || base8 == 'o') {
                            c->VpiValue((base8 == 'b'   ? "BIN:"
                                         : base8 == 'h' ? "HEX:"
                                                        : "OCT:") +
                                        dg8);
                            c->VpiConstType(base8 == 'b'   ? vpiBinaryConst
                                            : base8 == 'h' ? vpiHexConst
                                                           : vpiOctConst);
                            c->VpiSize((int32_t)iv.getBitWidth());
                            c->VpiDecompile(raw8);
                            vecAliasOv8 = true;
                        }
                    }
                }
                // Typed params fold UINT at the type width; untyped INT at
                // size -1.
                if (vecAliasOv8) {
                }
                else if (typedParam || genChild) {
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    // An untyped NO-DEFAULT param has no width source; Surelog's
                    // uniquified override folds it at the 64-bit default width.
                    c->VpiSize((noDefLitMP && !typedParam)
                                   ? 64
                                   : (int32_t)iv.getBitWidth());
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
                // A TYPED string param never folds (the elab Rhs re-emits the
                // string constant, decompiled without quotes). Pkg CONCAT
                // inits keep the operation in both views.
                else if (!ps.getType().getCanonicalType().isString() &&
                         !(inPackage && stripImplicitConv(*init).kind ==
                                            ExpressionKind::Concatenation) &&
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
                         (rhs = tryFoldConst(*init,
                                             typedParam ? init0 : nullptr))) {
                    bool partSelectFold = false;
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
                    }
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
                    // A typed-param PART-SELECT init (WidthRatio[5:0]) folds
                    // to BINARY at the type width (Surelog quirk) and is
                    // SHARED into a reading cont-assign (o = FullDepth).
                    if (sinit.kind == ExpressionKind::RangeSelect && typedParam &&
                        topView) {
                        auto* c = (UHDM::constant*)rhs;
                        int32_t w = (int32_t)ps.getType().getBitWidth();
                        std::string v(c->VpiValue());
                        std::string digits = v.find(':') != std::string::npos
                                                 ? v.substr(v.find(':') + 1)
                                                 : v;
                        slang::SVInt sv2 =
                            slang::SVInt::fromString(std::string_view(digits));
                        slang::SVInt wv(
                            (slang::bitwidth_t)(w > 0 ? w : 1), 0, false);
                        wv = sv2.resize((slang::bitwidth_t)(w > 0 ? w : 1));
                        std::string bits;
                        for (int32_t bi = w - 1; bi >= 0; bi--)
                            bits += (wv[bi] == slang::logic_t(1)) ? '1' : '0';
                        c->VpiValue("BIN:" + bits);
                        c->VpiConstType(vpiBinaryConst);
                        c->VpiDecompile(std::to_string(w) + "'b" + bits);
                        moduleParamFoldConst[&member] = c;
                        // Its own FRESH unlocated logic_typespec (range =
                        // the param's fixed range, BARE UINT bounds) — NOT
                        // the param's bit_typespec — created in the write-
                        // phase tail (deferred).
                        auto* rt = s.MakeRef_typespec();
                        rt->VpiFullName(prefix);
                        rt->VpiParent(c);
                        c->Typespec(rt);
                        auto fr = ps.getType().getCanonicalType().getFixedRange();
                        pendingPartSelFoldTs.push_back({rt, fr.left, fr.right});
                        partSelectFold = true;
                    }
                    // Typed-param (non-pattern) folds carry a ts ref to the param.
                    if (typedParam && wantTs && !isPattern && !partSelectFold) {
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
                {
                    auto& pctS = ps.getType().getCanonicalType();
                    auto k0 = stripImplicitConv(*init).kind;
                    structPat = pctS.kind == SymbolKind::PackedStructType &&
                                (k0 == ExpressionKind::StructuredAssignmentPattern ||
                                 k0 == ExpressionKind::SimpleAssignmentPattern);
                }
                // The DEF view of an INTERFACE struct param uses the same
                // folded op75 shape, its ts ref bound to the SHARED pkg ts.
                bool ifaceStructDef =
                    structPat && !topView &&
                    m->UhdmType() == UHDM::uhdminterface_inst &&
                    ps.getType().kind == SymbolKind::TypeAlias &&
                    typedefTs.count(&ps.getType());
                // NESTED struct params keep the tagged form (no fold).
                if (ifaceStructDef)
                    for (auto& fm9 : ps.getType()
                                         .getCanonicalType()
                                         .as<PackedStructType>()
                                         .membersOfType<FieldSymbol>())
                        if (fm9.getType().getCanonicalType().kind ==
                            SymbolKind::PackedStructType)
                            ifaceStructDef = false;
                if (structPat && (topView || ifaceStructDef)) {
                    auto& pctS = ps.getType().getCanonicalType();
                    auto& sinitK = stripImplicitConv(*init);
                    auto* op2 = s.MakeOperation();
                    op2->VpiOpType(75);
                    op2->VpiParent(pa);
                    setLoc(op2, init->sourceRange);
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiParent(op2);
                    op2->Typespec(rt);
                    if (ifaceStructDef)
                        rt->Actual_typespec(typedefTs[&ps.getType()]);
                    else
                        rhsRt = rt; // -> elab param clone (patchParamTypespecs)
                    auto* opnds = s.MakeAnyVec();
                    ASTContext ectx(comp.getRoot(), LookupLocation::max);
                    for (auto& fld :
                         pctS.as<PackedStructType>().membersOfType<FieldSymbol>()) {
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
                        // A LITERAL setter keeps its source encoding (1'b1 ->
                        // BIN, parented at the op via emitExpr); non-literal
                        // setters fold to UINT at the member width. Iface
                        // DEF params fold literals too.
                        if (!ifaceStructDef &&
                            stripImplicitConv(*se).kind ==
                                ExpressionKind::IntegerLiteral) {
                            if (auto* e2 = emitExpr(*se, op2, prefix, netMap)) {
                                ((UHDM::expr*)e2)->VpiParent(op2);
                                opnds->push_back(e2);
                            }
                            continue;
                        }
                        ConstantValue cvm = ectx.tryEval(*se);
                        if (cvm && cvm.isInteger() && !cvm.integer().hasUnknown()) {
                            auto* c2 = s.MakeConstant();
                            slang::SVInt uvm = cvm.integer();
                            uvm.setSigned(false);
                            // A CONCAT setter re-encodes BINARY at the member
                            // width with a BARE ts ref (Surelog).
                            if (stripImplicitConv(*se).kind ==
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
                forceConstParent = !nestedPat;
                inParamInit = true;
                paramInitDef = !topView;
                paramInitPkg = inPackage;
                bool savedSuppP = suppressConstParent;
                if (!topView && nestedPat)
                    suppressConstParent = true;
                if (!rhs)
                    rhs = emitExpr(*init, pa, prefix, netMap);
                suppressConstParent = savedSuppP;
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
                    bool unpackedArrayOp =
                        ps.getType().getCanonicalType().kind ==
                            SymbolKind::FixedSizeUnpackedArrayType &&
                        opr->VpiOpType() == vpiAssignmentPatternOp;
                    // A materialized IMPORTED vector-typedef param's elab
                    // CONCAT op also carries a ts ref (own clone pair).
                    bool importedConcatOp =
                        isImported && typedParam &&
                        ps.getType().getCanonicalType().isPackedArray() &&
                        opr->VpiOpType() == vpiConcatOp;
                    if ((anyUnknown || packedArrayOp || unpackedArrayOp ||
                         importedConcatOp) &&
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
                            rt->Actual_typespec(makeUnpackedArrayParamTs(
                                ps, joinPath(prefix, ps.name), rt, nullptr));
                        else
                            rhsRt = rt;
                    }
                }
            }
            if (rhs) {
                pa->Rhs(rhs);
                // An IMPORTED param's def-view copy is a materialized (already
                // resolved) param: its bare-decimal RHS folds to the type width
                // (int -> 32), exactly like the elab view — NOT the package
                // def's raw 64-bit bare decimal (Surelog sizes the copy, not
                // the source literal).
                if (isImported && !topView && typedParam &&
                    rhs->UhdmType() == UHDM::uhdmconstant)
                    ((UHDM::constant*)rhs)
                        ->VpiSize((int32_t)ps.getType().getBitWidth());
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
                if (topView && inPackage && typedParam &&
                    rhs->UhdmType() == UHDM::uhdmconstant)
                    enumOriginHexRecode((UHDM::constant*)rhs, init);
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
                if (auto& sik = stripImplicitConv(*init);
                    // An ELAB MATERIALIZED MULTIDIM-vector import's literal
                    // Rhs carries NO ts ref (Surelog); scalar/1-D imports
                    // keep it.
                    !(topView && isImported &&
                      ps.getType().getCanonicalType().kind ==
                          SymbolKind::PackedArrayType &&
                      ps.getType()
                              .getCanonicalType()
                              .as<PackedArrayType>()
                              .elementType.getCanonicalType()
                              .kind == SymbolKind::PackedArrayType) &&
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
                              .kind == SymbolKind::Package))) {
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
            }
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
                pendingParamTs.push_back({&ps, up, prt, rhsRt, typedParam});
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
                currentScope = savedCS;
                syntaxRefPrefix = savedPfx2;
                if (inPackage && typedParam)
                    its->Instance((UHDM::instance*)m);
                else if (!inPackage && isImported && ps.getParentScope()) {
                    // An imported param's typespec is INSTANCED at its package.
                    if (auto pit = pkgDefMap.find(&ps.getParentScope()->asSymbol());
                        pit != pkgDefMap.end())
                        its->Instance((UHDM::instance*)pit->second);
                    // Remember it so a def-view fold that READS this imported
                    // param can carry a ref_typespec to it.
                    importedParamDefTs[&ps] = its;
                }
                if (di)
                    di->paramTs[&member] = its;
                if (rhsRt)
                    rhsRt->Actual_typespec(its);
                prt->Actual_typespec(its);
                if (prtLhs9 && !prtLhs9->Actual_typespec()) {
                    // The Lhs clone gets its OWN fresh ts (pkg-Instanced,
                    // parented at the clone's ref) — Surelog.
                    std::string savedPfxL = syntaxRefPrefix;
                    syntaxRefPrefix = joinPath(prefix, ps.name);
                    auto* itsL = makeParamTs(ps, typedParam);
                    syntaxRefPrefix = savedPfxL;
                    if (!inPackage && isImported && ps.getParentScope())
                        if (auto pitL =
                                pkgDefMap.find(&ps.getParentScope()->asSymbol());
                            pitL != pkgDefMap.end())
                            itsL->Instance((UHDM::instance*)pitL->second);
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
                if (typedParam || isRangedUntypedParam(ps) || signedImplicit)
                    its->VpiParent(up);
            }
        }
    }
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
            if (ta9.getCanonicalType().kind == SymbolKind::EnumType)
                its = (UHDM::typespec*)buildEnumTs(
                    ta9.getCanonicalType().as<EnumType>(), tgt9,
                    std::string(ta9.name));
            else {
                bypassTypedefShare = true;
                its = makeTypespec(ta9, tgt9);
                bypassTypedefShare = false;
            }
            if (its) {
                its->VpiName(ta9.name);
                its->VpiParent(tp);
            }
            else
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
    if (!params->empty())
        m->Parameters(params);
    if (!passigns->empty())
        m->Param_assigns(passigns);
}

UHDM::array_typespec* UhdmExporter::makeUnpackedArrayParamTs(
    const ParameterSymbol& ps, const std::string& elemFull,
    UHDM::BaseClass* parent, UHDM::VectorOfrange* sharedRanges) {
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
    if (leaf->getCanonicalType().kind == SymbolKind::PredefinedIntegerType) {
        auto* its = s.MakeInt_typespec();
        its->VpiSigned(leaf->isSigned());
        setLoc(its, typeR);
        elemTs = its;
    }
    else {
        auto* lts = s.MakeLogic_typespec();
        setLoc(lts, typeR);
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
    UHDM::VectorOfrange* rsrc = sharedRanges ? sharedRanges : buildUnpackedRanges(ps, ats);
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
    return ats;
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
                    tr = tsyn->sourceRange();
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
                if (auto tit = typedefTs.find(&taSym);
                    tit != typedefTs.end() &&
                    tit->second->UhdmType() == UHDM::uhdmlogic_typespec) {
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
                        art->Actual_typespec(tit->second);
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
                            ecl->Instance(pit9->second);
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
            if (aliasPkg)
                if (auto pit = pkgDefMap.find(aliasPkg); pit != pkgDefMap.end()) {
                    its->Instance(pit->second);
                    // Fresh member-actual clones carry the package Instance
                    // too (shared package typespecs already have it).
                    if (auto* mems = ((UHDM::struct_typespec*)its)->Members())
                        for (auto* tm : *mems)
                            if (tm->Typespec() &&
                                tm->Typespec()->Actual_typespec() &&
                                !tm->Typespec()->Actual_typespec()->Instance())
                                tm->Typespec()->Actual_typespec()->Instance(
                                    pit->second);
                }
            if (auto* csyn = ct.getSyntax())
                tr = csyn->sourceRange();
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
    if (!stringParam && !sharedAggTs)
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
        if (aggParam && rhsRt && rhsRt->VpiParent() &&
            rhsRt->VpiParent()->UhdmType() == UHDM::uhdmoperation) {
            std::string full(prt->VpiFullName());
            auto dot = full.rfind('.');
            syntaxRefPrefix = dot == std::string::npos ? full : full.substr(0, dot);
            structCloneMemberRefParent = true;
            opClone = makeParamTs(*ps, typedParam, /*parentBounds=*/true);
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
                    if (auto sc = taSym.getParentScope();
                        qualified0 && sc &&
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
            if (its->UhdmType() == UHDM::uhdmstruct_typespec ||
                its->UhdmType() == UHDM::uhdmunion_typespec)
                if (auto* par = up->VpiParent())
                    its->Instance((UHDM::instance*)par);
            // An imported param's typespec is INSTANCED at its package.
            if (ps->getParentScope() &&
                ps->getParentScope()->asSymbol().kind == SymbolKind::Package)
                if (auto pit = pkgDefMap.find(&ps->getParentScope()->asSymbol());
                    pit != pkgDefMap.end())
                    its->Instance((UHDM::instance*)pit->second);
        }
        syntaxRefPrefix = savedPfx2;
        if (rhsRt && !opClone) {
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
            else
                rhsRt->Actual_typespec(its);
        }
        prt->Actual_typespec(its);
        if (!sharedPkgTs)
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

// Deferred DEF-view aggregate-typedef param ts: bind the SHARED named typedef
// typespec now that emitTypedefs has populated typedefTs. The shared object
// keeps its own parent/instance. Falls back to a fresh makeParamTs when the
// typedef wasn't materialized (mirrors the non-deferred path).
void UhdmExporter::drainDefParamTs() {
    for (auto& pd : pendingDefParamTs) {
        UHDM::typespec* its = nullptr;
        bool sharedTs = false;
        if (auto d0 = pd.ps->getDeclaredType()) {
            auto& dt0 = d0->getType();
            // A VECTOR typedef (typedef logic[X-1:0] my_type_t) is CLONED with a
            // Typedef_alias in both views (like struct/union/enum params take the
            // share shortcut) — fall through to makeParamTs for the clone.
            bool vectorAlias =
                dt0.kind == SymbolKind::TypeAlias &&
                dt0.getCanonicalType().kind == SymbolKind::PackedArrayType &&
                dt0.getCanonicalType().isIntegral();
            if (auto tit = typedefTs.find(&dt0);
                tit != typedefTs.end() && !vectorAlias) {
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
            its = makeParamTs(*pd.ps, pd.typedParam);
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
    }
    pendingDefParamTs.clear();
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

void UhdmExporter::analyzeParamEnc(const InstanceBodySymbol& body) {
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
    // Package typedefs are CREATED in source order (so intra-package
    // references resolve via typedefTs) but LISTED name-sorted (Surelog).
    std::vector<const Symbol*> pkgAliases;
    for (auto& member : pkg.members())
        if (member.kind == SymbolKind::TypeAlias)
            pkgAliases.push_back(&member);
    std::vector<std::pair<std::string, UHDM::typespec*>> pkgTdByName;
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
                        ct2.kind != SymbolKind::PackedStructType)
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
                        if (ct2.kind == SymbolKind::PackedStructType) {
                            auto* scl = buildStructTs(
                                ct2.as<PackedStructType>(), true, nm2, "::");
                            scl->VpiName(nm2);
                            if (tSyn2)
                                setLoc(scl, tSyn2->sourceRange());
                            scl->Instance((UHDM::instance*)up);
                            pkgImportCloneTs[&pm] = scl;
                            pkgTdByName.emplace_back(std::string(ta2.name),
                                                     (UHDM::typespec*)scl);
                            continue;
                        }
                        auto* ecl = buildEnumTs(ct2.as<EnumType>(), tSyn2, nm2);
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
                        cl2 = ecl;
                    }
                    pkgTdByName.emplace_back(std::string(ta2.name),
                                             (UHDM::typespec*)cl2);
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
    for (auto* memberP : pkgAliases) {
        auto& member = *memberP;
        auto& ta = member.as<TypeAliasType>();
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
        else if (ct.kind == SymbolKind::PackedStructType) {
            // Package struct member refs use pkg::pkg::T::m (doubled prefix);
            // each field typespec carries vpiInstance = package.
            // DEF-view member bounds stay UNFOLDED (member-scoped refs bound
            // to the params' def init constants); the elab view folds them.
            // A NESTED-struct-containing typedef's TOP view instead scopes
            // members pkg::T.m (single prefix, dot) and stays UNPARENTED.
            bool nestedStruct = false;
            for (auto& fm : ct.as<PackedStructType>().membersOfType<FieldSymbol>())
                if (fm.getType().getCanonicalType().kind ==
                    SymbolKind::PackedStructType)
                    nestedStruct = true;
            bool topNested = topView && nestedStruct &&
                             wildcardImportedPkgs.count(&pkg);
            std::string alias = topNested
                                    ? prefix + std::string(ta.name)
                                    : prefix + prefix + std::string(ta.name);
            bool savedTf = tfContext;
            if (topView)
                tfContext = true;
            auto* sts = buildStructTs(ct.as<PackedStructType>(), true, alias,
                                      topNested ? "." : "::");
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
                            mts->Instance()->UhdmType() == UHDM::uhdmpackage) {
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
                for (auto inst : comp.getRoot().topInstances) {
                    for (auto& mb : inst->body.members()) {
                        if (mb.kind != SymbolKind::Variable)
                            continue;
                        auto dt0 = mb.getDeclaredType();
                        if (!dt0 || &dt0->getType() != (const Type*)&ta)
                            continue;
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
                bool varUse = useEnd != SourceLocation::NoLocation;
                std::string refName = varUse
                                          ? prefix + prefix + std::string(ta.name)
                                          : prefix + std::string(ta.name);
                auto* ets = buildEnumTs(ct.as<EnumType>(), tgtSyn, refName);
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
                if (varUse)
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
            auto* uts = pk
                            ? buildUnionTs(ct.as<PackedUnionType>(), true, alias,
                                           "::")
                            : buildUnionTs(ct.as<UnpackedUnionType>(), false,
                                           alias, "::");
            tfContext = savedTfU;
            uts->VpiParent(up);
            if (uts->Members())
                for (auto* tm : *uts->Members())
                    if (tm->Typespec() && tm->Typespec()->Actual_typespec())
                        tm->Typespec()->Actual_typespec()->Instance(
                            (UHDM::instance*)up);
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
        if (!ts)
            continue;
        ts->VpiName(prefix + std::string(ta.name));
        ts->Instance((UHDM::instance*)up);
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
    // The Typespecs LIST is name-sorted (creation stayed source-ordered).
    std::stable_sort(pkgTdByName.begin(), pkgTdByName.end(),
                     [](auto& a, auto& b) { return a.first < b.first; });
    for (auto& [nm0, ts0] : pkgTdByName)
        tds->push_back(ts0);
    for (auto* it9 : importTss)
        tds->push_back(it9);
    if (!tds->empty())
        up->Typespecs(tds);
    pkgTopEmit = topView;
    emitTaskFuncs(pkg, up, prefix, nullptr, /*sharedScope=*/false);
    pkgTopEmit = false;
    return up;
}

// After ALL def-view packages exist: insert the home def objects into the
// importing packages' Typespecs slots, stamp Instance = the importing pkg,
// and expose them for module import listings.

} // namespace slang_uhdm
