//------------------------------------------------------------------------------
//! @file TypeEmit.cpp
//! @brief Typespecs, bound constants, variable object creation
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

namespace slang_uhdm {

// True when a signal's declared-type packed dimensions reference a PARAMETER
// (its width can be overridden per instance) — such widths keep $bits(sig)
// unfolded; a fixed width (int, logic [7:0]) folds.
static bool typeWidthUsesParam(const Symbol& sym) {
    auto dt = sym.getDeclaredType();
    if (!dt)
        return false;
    auto tsyn = dt->getTypeSyntax();
    if (!tsyn)
        return false;
    bool found = false;
    std::function<void(const syntax::SyntaxNode&)> scan =
        [&](const syntax::SyntaxNode& sn) {
            if (found)
                return;
            if (sn.kind == syntax::SyntaxKind::IdentifierName)
                found = true;
            for (size_t i = 0; i < sn.getChildCount(); i++)
                if (auto* cn = sn.childNode(i))
                    scan(*cn);
        };
    if (syntax::IntegerTypeSyntax::isKind(tsyn->kind))
        for (auto d : tsyn->as<syntax::IntegerTypeSyntax>().dimensions)
            scan(*d);
    return found;
}



UHDM::typespec* UhdmExporter::makeTypespec(const Symbol& declSymbol,
                                           const syntax::SyntaxNode* typeSynOverride,
                                           const PortSymbol* portCtx) {
    // A local var of a function inside an elaborated GEN block: fold its
    // param-ref type bounds (concrete instance). declSymbol's parent chain
    // reaches the function+gen-block even in the deferred typespec drain.
    const Scope* savedGbf = genBlockFnScope;
    {
        bool inFn = false, inGen = false;
        const Scope* fnScope = nullptr;
        for (auto sc = declSymbol.getParentScope(); sc;
             sc = sc->asSymbol().getParentScope()) {
            auto k = sc->asSymbol().kind;
            if (k == SymbolKind::Subroutine) {
                inFn = true;
                fnScope = sc;
            }
            if (k == SymbolKind::GenerateBlock ||
                k == SymbolKind::GenerateBlockArray)
                inGen = true;
            if (k == SymbolKind::InstanceBody)
                break;
        }
        // The function RETURN type keeps its param-ref bounds as refs (like a
        // normal function type); only genuine LOCAL VARS fold. So exclude the
        // subroutine's return-value var.
        if (inFn && inGen && fnScope) {
            auto& fnSym = fnScope->asSymbol();
            const Symbol* retVar =
                fnSym.kind == SymbolKind::Subroutine
                    ? fnSym.as<SubroutineSymbol>().returnValVar
                    : nullptr;
            if (&declSymbol != retVar)
                genBlockFnScope = fnScope;
        }
    }
    struct GbfGuard {
        const Scope*& slot;
        const Scope* prev;
        ~GbfGuard() { slot = prev; }
    } gbfGuard{genBlockFnScope, savedGbf};
    auto declared = declSymbol.getDeclaredType();
    // Typedef'd declarations share the typedef's typespec object; anonymous
    // enums build an unnamed, unlocated enum_typespec per declaration.
    if (declared) {
        if (auto it = typedefTs.find(&declared->getType());
            it != typedefTs.end() && !bypassTypedefShare)
            return it->second;
        // Class handles: a fresh class_typespec per declaration, named by the
        // class and linked to its class_defn.
        if (auto& ct0 = declared->getType().getCanonicalType();
            ct0.kind == SymbolKind::ClassType) {
            auto* cts = s.MakeClass_typespec();
            cts->VpiName(ct0.name);
            if (auto cit = classDefnMap.find(&ct0); cit != classDefnMap.end())
                cts->Class_defn(cit->second);
            if (auto tsyn0 = declared->getTypeSyntax())
                setLoc(cts, tsyn0->sourceRange());
            return cts;
        }
        if (!typeSynOverride) {
            auto& ct0 = declared->getType().getCanonicalType();
            if (ct0.kind == SymbolKind::EnumType)
                return buildEnumTs(ct0.as<EnumType>(), declared->getTypeSyntax(), "",
                                   /*implicitBaseRef=*/true);
        }
    }
    // Ports whose net is re-declared in the body ("input clock; wire clock;")
    // build their port typespec from the PORT declaration (its dims/type),
    // not the body re-declaration.
    bool mergedPort = portCtx && hasBodyDecl(declSymbol);
    const syntax::SyntaxNode* portDeclTypeSyn = nullptr;
    if (mergedPort) {
        auto scope0 = declSymbol.getParentScope();
        const syntax::SyntaxNode* msyn0 =
            scope0 ? scope0->asSymbol().getSyntax() : nullptr;
        if (msyn0 && msyn0->kind == syntax::SyntaxKind::ModuleDeclaration) {
            for (auto member : msyn0->as<syntax::ModuleDeclarationSyntax>().members) {
                if (member->kind != syntax::SyntaxKind::PortDeclaration)
                    continue;
                auto& pd = member->as<syntax::PortDeclarationSyntax>();
                bool found = false;
                for (auto dcl : pd.declarators) {
                    if (dcl->name.valueText() == portCtx->name)
                        found = true;
                }
                if (found) {
                    if (pd.header->kind == syntax::SyntaxKind::VariablePortHeader)
                        portDeclTypeSyn =
                            pd.header->as<syntax::VariablePortHeaderSyntax>().dataType;
                    else if (pd.header->kind == syntax::SyntaxKind::NetPortHeader)
                        portDeclTypeSyn =
                            pd.header->as<syntax::NetPortHeaderSyntax>().dataType;
                    break;
                }
            }
        }
        if (portDeclTypeSyn)
            typeSynOverride = portDeclTypeSyn;
    }
    auto typeSynFor = [&]() -> const syntax::SyntaxNode* {
        if (typeSynOverride)
            return typeSynOverride;
        return declared ? declared->getTypeSyntax() : nullptr;
    };
    // Merged ports anchor at the first declarator of the port declaration
    // group ("input clock,reset,..." -> clock); reach it through the port's
    // own declared-type syntax.
    SourceLocation implicitLoc;
    if (mergedPort) {
        implicitLoc = portCtx->location;
        auto scope = declSymbol.getParentScope();
        const syntax::SyntaxNode* msyn =
            scope ? scope->asSymbol().getSyntax() : nullptr;
        if (msyn && msyn->kind == syntax::SyntaxKind::ModuleDeclaration) {
            for (auto member : msyn->as<syntax::ModuleDeclarationSyntax>().members) {
                if (member->kind != syntax::SyntaxKind::PortDeclaration)
                    continue;
                auto& pd = member->as<syntax::PortDeclarationSyntax>();
                bool found = false;
                for (auto dcl : pd.declarators) {
                    if (dcl->name.valueText() == portCtx->name)
                        found = true;
                }
                if (found && !pd.declarators.empty()) {
                    implicitLoc = pd.declarators[0]->name.location();
                    break;
                }
            }
        }
    }
    else {
        implicitLoc = firstDeclaratorLoc(declSymbol);
    }
    SourceRange range(implicitLoc, implicitLoc);
    bool explicitType = false;
    if (declared && !(mergedPort && !portDeclTypeSyn)) {
        if (auto tsyn = typeSynFor()) {
            if (tsyn->kind != syntax::SyntaxKind::ImplicitType) {
                auto sr = tsyn->sourceRange();
                if (sr.start() != SourceLocation::NoLocation) {
                    range = sr;
                    explicitType = true;
                }
            }
        }
    }
    // Implicit-typed explicit net declarations anchor at the net keyword
    // ("wire w;" / "input wire x" -> the wire token).
    bool netKeywordAnchor = false;
    if (!explicitType && !mergedPort && declSymbol.kind == SymbolKind::Net) {
        if (auto nh = ansiNetHeader(declSymbol)) {
            range = nh->netType.range();
            netKeywordAnchor = true;
        }
        else {
            for (auto p = declSymbol.getSyntax(); p; p = p->parent) {
                if (p->kind == syntax::SyntaxKind::NetDeclaration) {
                    range = p->as<syntax::NetDeclarationSyntax>().netType.range();
                    netKeywordAnchor = true;
                    break;
                }
            }
        }
    }
    // Implicit types with a signing keyword ("input signed [3:0] x") anchor
    // at the signing token alone.
    bool implicitSigning = false;
    if (!explicitType && !netKeywordAnchor && declared) {
        if (auto tsyn = typeSynFor()) {
            if (tsyn->kind == syntax::SyntaxKind::ImplicitType) {
                auto& its = tsyn->as<syntax::ImplicitTypeSyntax>();
                if (its.signing.valid()) {
                    range = its.signing.range();
                    implicitSigning = true;
                }
            }
        }
    }

    // Non-logic types get their own typespec classes. Unpacked arrays
    // resolve to their ELEMENT type (the dims become array_var ranges).
    if (declared) {
        const Type* et = &declared->getType().getCanonicalType();
        while (et->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
            et = &et->getCanonicalType().as<FixedSizeUnpackedArrayType>().elementType;
        auto& ct = et->getCanonicalType();
        if (ct.kind == SymbolKind::FloatingType) {
            UHDM::typespec* t = ct.as<FloatingType>().floatKind == FloatingType::ShortReal
                                    ? (UHDM::typespec*)s.MakeShort_real_typespec()
                                    : (UHDM::typespec*)s.MakeReal_typespec();
            setLoc(t, range);
            return t;
        }
        if (ct.kind == SymbolKind::StringType) {
            auto* t = s.MakeString_typespec();
            setLoc(t, range);
            return t;
        }
        // Packed array whose leaf element is a shared struct/enum typedef ->
        // packed_array_typespec { dims + Elem_typespec ref -> the typedef }.
        if (declared->getType().isPackedArray() && !bypassTypedefShare) {
        int arrDims = 0;
        const Type* leaf = &declared->getType().getCanonicalType();
        while (leaf->getCanonicalType().kind == SymbolKind::PackedArrayType) {
            arrDims++;
            leaf = &leaf->getCanonicalType().as<PackedArrayType>().elementType;
        }
        auto& lc = leaf->getCanonicalType();
        if (lc.kind == SymbolKind::PackedStructType || lc.kind == SymbolKind::EnumType) {
            UHDM::typespec* elemTs = nullptr;
            for (auto& [sym, tsp] : typedefTs)
                if (sym->kind == SymbolKind::TypeAlias &&
                    &sym->as<TypeAliasType>().getCanonicalType() == &lc) {
                    elemTs = tsp;
                    break;
                }
            if (elemTs) {
                auto* pat = s.MakePacked_array_typespec();
                // Semantic dims from the packed-type walk; source spans from
                // a bracket scan between type name and declarator (named
                // types carry the dims in neither syntax node).
                std::vector<ConstantRange> arrRanges;
                {
                    const Type* t2 = &declared->getType().getCanonicalType();
                    for (int i = 0; i < arrDims; i++) {
                        arrRanges.push_back(
                            t2->getCanonicalType().as<PackedArrayType>().range);
                        t2 = &t2->getCanonicalType().as<PackedArrayType>().elementType;
                    }
                }
                std::vector<DimSpan> spans;
                {
                    // Prefer the type-syntax..declarator span; fall back to
                    // the typespec range (struct members expose no
                    // getTypeSyntax()).
                    SourceLocation tStart = range.start();
                    SourceLocation tEnd = declSymbol.location;
                    if (auto tsn2 = declared->getTypeSyntax())
                        tStart = tsn2->sourceRange().start();
                    if (!(tStart < tEnd))
                        tEnd = range.end();
                    if (tStart < tEnd)
                        spans = scanDimSpans(
                            std::string(rawText(SourceRange(tStart, tEnd))), tStart);
                }
                SourceRange patLoc = range;
                // A multi-dim packed array typespec span truncates to the end
                // of the FIRST dimension (Surelog), like the def-net path — but
                // NOT for a struct/union member, which keeps its full span.
                if (arrDims >= 2 && !spans.empty() && !structMemberTsCtx)
                    patLoc = SourceRange(range.start(), spans[0].range.end());
                auto* rvec = s.MakeRangeVec();
                for (int i = 0; i < arrDims; i++) {
                    auto* r = s.MakeRange();
                    r->VpiParent(pat);
                    auto mkBound = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
                        // A packed-dim bound that is a bare ENUM-CONSTANT name
                        // (logic [s_e:n_e] arr, s_e an enum member) stays
                        // SYMBOLIC in the standalone typespec: Surelog emits a
                        // ref_obj -> the enum_const (the packed_array_VAR view
                        // still folds it to a constant). Resolve the source
                        // identifier in the declaration's own scope.
                        if (loc) {
                            std::string raw(rawText(*loc));
                            bool ident = !raw.empty() &&
                                         (isalpha((unsigned char)raw[0]) ||
                                          raw[0] == '_');
                            for (char ch : raw)
                                if (!(isalnum((unsigned char)ch) || ch == '_')) {
                                    ident = false;
                                    break;
                                }
                            if (ident) {
                                if (auto* psc = declSymbol.getParentScope())
                                    if (auto* bsym = psc->find(raw);
                                        bsym &&
                                        bsym->kind == SymbolKind::EnumValue)
                                        if (auto eit = enumConstMap.find(bsym);
                                            eit != enumConstMap.end() &&
                                            eit->second->UhdmType() ==
                                                UHDM::uhdmenum_const) {
                                            auto* ro = s.MakeRef_obj();
                                            ro->VpiName(raw);
                                            ro->VpiParent(r);
                                            setLoc(ro, *loc);
                                            ro->Actual_group(eit->second);
                                            return (UHDM::expr*)ro;
                                        }
                            }
                        }
                        // Typedef-member context: an IDENTIFIER bound
                        // ([MpRegions:0]) keeps a member-scoped ref_obj
                        // chained to the pkg param's def Rhs (Surelog).
                        if (loc && tfContext && structMemberTsCtx &&
                            !syntaxRefPrefix.empty()) {
                            std::string raw(rawText(*loc));
                            bool ident = !raw.empty() &&
                                         (isalpha((unsigned char)raw[0]) ||
                                          raw[0] == '_');
                            for (char ch : raw)
                                if (!(isalnum((unsigned char)ch) || ch == '_')) {
                                    ident = false;
                                    break;
                                }
                            if (ident) {
                                auto* ro = s.MakeRef_obj();
                                ro->VpiName(raw);
                                ro->VpiFullName(syntaxRefPrefix + syntaxRefSep +
                                                raw);
                                ro->VpiParent(r);
                                setLoc(ro, *loc);
                                for (auto& [ps9, rhs9] : pkgParamDefRhs)
                                    if (ps9->name == raw &&
                                        ps9->getParentScope() &&
                                        ps9->getParentScope()->asSymbol().kind ==
                                            SymbolKind::Package) {
                                        ro->Actual_group(rhs9);
                                        break;
                                    }
                                return (UHDM::expr*)ro;
                            }
                        }
                        // A literal-arithmetic bound (`1-1`, `66-1`) keeps
                        // its SUB op tree in the standalone typespec
                        // (MultirangesStartNotFromZero): op11 with UINT
                        // digit constants at their sub-spans.
                        if (loc) {
                            std::string raw9(rawText(*loc));
                            size_t dash9 = raw9.find('-');
                            bool litSub9 = dash9 != std::string::npos &&
                                           dash9 > 0 && dash9 + 1 < raw9.size();
                            if (litSub9)
                                for (size_t p9 = 0; p9 < raw9.size(); p9++)
                                    if (p9 != dash9 &&
                                        !isdigit((unsigned char)raw9[p9])) {
                                        litSub9 = false;
                                        break;
                                    }
                            if (litSub9) {
                                auto* op9 = s.MakeOperation();
                                op9->VpiOpType(vpiSubOp);
                                op9->VpiParent(r);
                                setLoc(op9, *loc);
                                auto* opnds9 = s.MakeAnyVec();
                                auto mkD9 = [&](const std::string& dg,
                                                int32_t colOff,
                                                int32_t len) -> UHDM::any* {
                                    auto* c9 = s.MakeConstant();
                                    c9->VpiDecompile(dg);
                                    c9->VpiSize(64);
                                    c9->VpiValue("UINT:" + dg);
                                    c9->VpiConstType(vpiUIntConst);
                                    c9->VpiParent(op9);
                                    setLoc(c9, *loc);
                                    c9->VpiColumnNo(op9->VpiColumnNo() +
                                                    colOff);
                                    c9->VpiEndColumnNo(op9->VpiColumnNo() +
                                                       colOff + len);
                                    return c9;
                                };
                                opnds9->push_back(mkD9(raw9.substr(0, dash9),
                                                       0, (int32_t)dash9));
                                opnds9->push_back(mkD9(
                                    raw9.substr(dash9 + 1), (int32_t)dash9 + 1,
                                    (int32_t)(raw9.size() - dash9 - 1)));
                                op9->Operands(opnds9);
                                return (UHDM::expr*)op9;
                            }
                        }
                        auto* c = s.MakeConstant();
                        std::string digits = std::to_string(v);
                        c->VpiDecompile(digits);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(r);
                        if (loc)
                            setLoc(c, *loc);
                        // A DEF-pass folded member bound derived from a package
                        // param IDENTIFIER ([K:0]) records that param — the
                        // post-swap TOP member pass gives it vpiSize:32 + a
                        // vpiTypespec (ref -> fresh int_typespec) like Surelog.
                        if (loc && structMemberTsCtx) {
                            std::string raw(rawText(*loc));
                            bool ident = !raw.empty() &&
                                         (isalpha((unsigned char)raw[0]) ||
                                          raw[0] == '_');
                            for (char ch : raw)
                                if (!(isalnum((unsigned char)ch) || ch == '_')) {
                                    ident = false;
                                    break;
                                }
                            if (ident)
                                for (auto& [ps9, rhs9] : pkgParamDefRhs)
                                    if (ps9->name == raw &&
                                        ps9->getParentScope() &&
                                        ps9->getParentScope()->asSymbol().kind ==
                                            SymbolKind::Package) {
                                        foldedMemberBoundParam[c] = ps9;
                                        break;
                                    }
                        }
                        return c;
                    };
                    const DimSpan* ds = i < (int)spans.size() ? &spans[i] : nullptr;
                    if (ds)
                        setLoc(r, ds->range);
                    r->Left_expr(mkBound(arrRanges[i].left, ds ? &ds->left : nullptr));
                    r->Right_expr(mkBound(arrRanges[i].right, ds ? &ds->right : nullptr));
                    rvec->push_back(r);
                }
                pat->Ranges(rvec);
                // A PACKAGE-struct leaf's packed_array_typespec is UNLOCATED
                // (its struct_typespec lives at the package); a module-local
                // one keeps the declaration span. A struct/union MEMBER (even
                // with a package leaf) spans its member type..dims (Surelog).
                bool pkgLeaf = false;
                for (auto sc0 = lc.getParentScope(); sc0;
                     sc0 = sc0->asSymbol().getParentScope())
                    if (sc0->asSymbol().kind == SymbolKind::Package) {
                        pkgLeaf = true;
                        break;
                    }
                if (!pkgLeaf || structMemberTsCtx)
                    setLoc(pat, patLoc);
                auto* ert = s.MakeRef_typespec();
                ert->VpiParent(pat);
                ert->Actual_typespec(elemTs);
                pat->Elem_typespec(ert);
                return pat;
            }
        }
        }
        // A packed array over a VECTOR TYPEDEF (logic4 [1:0] v) in module
        // context: an anonymous logic ts at the type span with an Elem ref
        // to the SHARED typedef ts and the ARRAY dim as its range (Surelog).
        if (!tfContext && declared->getType().kind == SymbolKind::PackedArrayType) {
            auto& et9 = declared->getType().as<PackedArrayType>().elementType;
            if (et9.kind == SymbolKind::TypeAlias) {
                if (auto tit9 = typedefTs.find(&et9);
                    tit9 != typedefTs.end() &&
                    tit9->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                    auto* lts = s.MakeLogic_typespec();
                    setLoc(lts, range);
                    auto* ert9 = s.MakeRef_typespec();
                    ert9->VpiParent(lts);
                    ert9->Actual_typespec(tit9->second);
                    lts->Elem_typespec(ert9);
                    auto pr9 =
                        declared->getType().as<PackedArrayType>().range;
                    std::vector<DimSpan> spans9;
                    {
                        SourceLocation tS9 = range.start();
                        if (auto tsy9 = declared->getTypeSyntax())
                            tS9 = tsy9->sourceRange().start();
                        if (tS9 < declSymbol.location)
                            spans9 = scanDimSpans(
                                std::string(rawText(
                                    SourceRange(tS9, declSymbol.location))),
                                tS9);
                    }
                    auto* rng9 = s.MakeRange();
                    rng9->VpiParent(lts);
                    const DimSpan* ds9 = spans9.empty() ? nullptr : &spans9[0];
                    if (ds9)
                        setLoc(rng9, ds9->range);
                    auto mk9 = [&](int64_t v,
                                   const SourceRange* loc) -> UHDM::expr* {
                        auto* c = s.MakeConstant();
                        std::string digits = std::to_string(v);
                        c->VpiDecompile(digits);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(rng9);
                        if (loc)
                            setLoc(c, *loc);
                        return c;
                    };
                    rng9->Left_expr(mk9(pr9.left, ds9 ? &ds9->left : nullptr));
                    rng9->Right_expr(
                        mk9(pr9.right, ds9 ? &ds9->right : nullptr));
                    auto* rvec9 = s.MakeRangeVec();
                    rvec9->push_back(rng9);
                    lts->Ranges(rvec9);
                    return lts;
                }
            }
        }
        if (ct.kind == SymbolKind::PredefinedIntegerType) {
            auto& pit = ct.as<PredefinedIntegerType>();
            UHDM::typespec* its = nullptr;
            switch (pit.integerKind) {
                case PredefinedIntegerType::Int: {
                    auto* t = s.MakeInt_typespec();
                    t->VpiSigned(pit.isSigned);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::Integer: {
                    auto* t = s.MakeInteger_typespec();
                    t->VpiSigned(pit.isSigned);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::ShortInt: {
                    auto* t = s.MakeShort_int_typespec();
                    t->VpiSigned(pit.isSigned);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::LongInt: {
                    auto* t = s.MakeLong_int_typespec();
                    t->VpiSigned(pit.isSigned);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::Byte: {
                    auto* t = s.MakeByte_typespec();
                    t->VpiSigned(pit.isSigned);
                    its = t;
                    break;
                }
                case PredefinedIntegerType::Time: {
                    its = s.MakeTime_typespec();
                    break;
                }
                default:
                    noteUnsupported("integer type kind");
                    break;
            }
            if (its) {
                setLoc(its, range);
                return its;
            }
        }
    }

    // An ANONYMOUS packed union (union packed {..} u;) builds an unnamed
    // union_typespec. A TYPEDEF'd union (kind == TypeAlias) is excluded — it
    // shares the named typedef ts (or is cloned by the typedef paths).
    if (declared && (declared->getType().kind == SymbolKind::PackedUnionType ||
                     declared->getType().kind == SymbolKind::UnpackedUnionType)) {
        bool pk = declared->getType().kind == SymbolKind::PackedUnionType;
        auto& ctU = declared->getType().getCanonicalType();
        auto* uts = pk ? buildUnionTs(ctU.as<PackedUnionType>(), true, "")
                       : buildUnionTs(ctU.as<UnpackedUnionType>(), false, "");
        if (auto tsyn = declared->getTypeSyntax()) {
            // A PACKED anonymous union ts spans only the `union packed` HEADER;
            // an UNPACKED one spans the whole syntax (Surelog).
            if (auto* su = tsyn->as_if<syntax::StructUnionTypeSyntax>(); su && pk) {
                SourceLocation e = su->keyword.range().end();
                if (su->packed && su->packed.range().end() > e)
                    e = su->packed.range().end();
                if (su->signing && su->signing.range().end() > e)
                    e = su->signing.range().end();
                setLoc(uts, SourceRange(su->keyword.range().start(), e));
            }
            else
                setLoc(uts, tsyn->sourceRange());
        }
        return uts;
    }
    // An ANONYMOUS packed struct (struct packed {..} s;) builds an unnamed
    // struct_typespec — directly, or as the ELEMENT of an unpacked array
    // (struct packed {..} a [4]; the array emission wraps this in an
    // array_typespec). Typedef'd structs share their named ts above.
    if (declared) {
        const Type* st = &declared->getType();
        bool arrayElem = false;
        while (st->kind == SymbolKind::FixedSizeUnpackedArrayType) {
            st = &st->as<FixedSizeUnpackedArrayType>().elementType;
            arrayElem = true;
        }
        if (st->kind == SymbolKind::PackedStructType) {
            auto* sts = buildStructTs(st->as<PackedStructType>(), true, "");
            const syntax::SyntaxNode* ssyn =
                arrayElem ? st->getSyntax() : declared->getTypeSyntax();
            if (ssyn) {
                if (auto* su = ssyn->as_if<syntax::StructUnionTypeSyntax>()) {
                    // Surelog locates an ANONYMOUS inline struct_typespec at
                    // the bare `struct`/`union` keyword token (an unpacked-array
                    // ELEMENT struct: `struct packed {..} a[4]` spans just
                    // `struct`, NOT `struct packed`). A directly-declared
                    // (non-array-element) anonymous struct keeps the extended
                    // keyword+packed+signing span.
                    if (arrayElem) {
                        setLoc(sts, su->keyword.range());
                    }
                    else {
                        SourceLocation e = su->keyword.range().end();
                        if (su->packed && su->packed.range().end() > e)
                            e = su->packed.range().end();
                        if (su->signing && su->signing.range().end() > e)
                            e = su->signing.range().end();
                        setLoc(sts, SourceRange(su->keyword.range().start(), e));
                    }
                }
                else
                    setLoc(sts, ssyn->sourceRange());
            }
            return sts;
        }
    }
    // 2-state (bit) vectors take a bit_typespec; 4-state stay logic.
    // An UNPACKED array's element ts keys on its packed LEAF (bit [0:0][0:0]
    // b [0:0] still gets a bit_typespec element).
    UHDM::typespec* ts0;
    const Type* fsLeaf0 = declared ? &declared->getType().getCanonicalType() : nullptr;
    while (fsLeaf0 && fsLeaf0->getCanonicalType().kind ==
                          SymbolKind::FixedSizeUnpackedArrayType)
        fsLeaf0 = &fsLeaf0->getCanonicalType()
                       .as<FixedSizeUnpackedArrayType>()
                       .elementType.getCanonicalType();
    if (fsLeaf0 && fsLeaf0->isIntegral() && !fsLeaf0->isFourState())
        ts0 = s.MakeBit_typespec();
    else
        ts0 = s.MakeLogic_typespec();
    auto* ts = (UHDM::logic_typespec*)ts0;
    // Net-keyword-anchored typespecs omit the signed flag.
    if (declared && declared->getType().isSigned() && !netKeywordAnchor)
        ts->VpiSigned(true);
    setLoc(ts, range);

    // Packed dimensions: one uhdm range per dimension, bounds as evaluated
    // UINT constants (64-bit) that keep their source text as decompile.
    // Dims live on IntegerTypeSyntax ("logic [7:0]") or ImplicitTypeSyntax
    // ("input [7:0] a" / "wire [7:0] w").
    // The packed element sits under any unpacked array dims (an unpacked-array
    // net still carries its packed element ranges on the element typespec).
    const Type* packedLeaf = declared ? &declared->getType().getCanonicalType() : nullptr;
    while (packedLeaf &&
           packedLeaf->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
        packedLeaf = &packedLeaf->getCanonicalType()
                          .as<FixedSizeUnpackedArrayType>()
                          .elementType.getCanonicalType();
    if (packedLeaf && packedLeaf->isPackedArray()) {
        auto tsyn = typeSynFor();
        const syntax::SyntaxList<syntax::VariableDimensionSyntax>* dimSyns = nullptr;
        if (tsyn && syntax::IntegerTypeSyntax::isKind(tsyn->kind)) {
            dimSyns = &tsyn->as<syntax::IntegerTypeSyntax>().dimensions;
        }
        else if (tsyn && tsyn->kind == syntax::SyntaxKind::ImplicitType) {
            auto& its = tsyn->as<syntax::ImplicitTypeSyntax>();
            if (!its.dimensions.empty()) {
                dimSyns = &its.dimensions;
                // Location: net declarations span the net keyword through the
                // dims; port declarations use the dims range alone. A signing
                // keyword anchor wins over the dims range.
                if (!implicitSigning) {
                    SourceRange dr(its.dimensions[0]->sourceRange().start(),
                                   its.dimensions[its.dimensions.size() - 1]
                                       ->sourceRange()
                                       .end());
                    if (mergedPort) {
                        // Port-decl dims: the dims range alone.
                    }
                    else if (auto nh = ansiNetHeader(declSymbol)) {
                        dr = SourceRange(nh->netType.range().start(), dr.end());
                    }
                    else {
                        for (auto p = declSymbol.getSyntax(); p; p = p->parent) {
                            if (p->kind == syntax::SyntaxKind::NetDeclaration) {
                                dr = SourceRange(
                                    p->as<syntax::NetDeclarationSyntax>().netType.range().start(),
                                    dr.end());
                                break;
                            }
                        }
                    }
                    setLoc(ts, dr);
                }
            }
        }
        if (dimSyns) {
            std::vector<ConstantRange> dims;
            const Type* t = &declared->getType().getCanonicalType();
            // A net/var element typespec covers only the PACKED dims; descend
            // past any unpacked array dims (e.g. logic [7:0] memory [0:15])
            // to reach the packed element before collecting its ranges.
            while (t->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
                t = &t->getCanonicalType()
                         .as<FixedSizeUnpackedArrayType>()
                         .elementType.getCanonicalType();
            while (t->isPackedArray()) {
                auto& pat = t->as<PackedArrayType>();
                dims.push_back(pat.range);
                t = &pat.elementType.getCanonicalType();
            }
            if (dims.size() == dimSyns->size()) {
                auto* ranges = s.MakeRangeVec();
                for (size_t i = 0; i < dims.size(); i++) {
                    auto* dimSyn = (*dimSyns)[i];
                    auto* r = s.MakeRange();
                    r->VpiParent(ts);
                    setLoc(r, dimSyn->sourceRange());
                    const syntax::ExpressionSyntax* lsyn = nullptr;
                    const syntax::ExpressionSyntax* rsyn = nullptr;
                    if (dimSyn->specifier &&
                        dimSyn->specifier->kind == syntax::SyntaxKind::RangeDimensionSpecifier) {
                        auto& spec = dimSyn->specifier->as<syntax::RangeDimensionSpecifierSyntax>();
                        if (spec.selector->kind == syntax::SyntaxKind::SimpleRangeSelect) {
                            auto& sel = spec.selector->as<syntax::RangeSelectSyntax>();
                            lsyn = sel.left;
                            rsyn = sel.right;
                        }
                    }
                    auto emitBound = [&](const syntax::ExpressionSyntax* bsyn,
                                         int64_t value) -> UHDM::expr* {
                        if (!bsyn || bsyn->kind == syntax::SyntaxKind::IntegerLiteralExpression)
                            return makeBoundConst(bsyn, value, r);
                        // A $bits(SIGNAL) bound stays UNFOLDED in module and
                        // param contexts alike ($bits(type) still folds): the
                        // sys call's arg ref scopes through the declaring
                        // symbol and binds the signal's net.
                        bool bitsOfSignal = false;
                        const Scope* declScope = declSymbol.getParentScope();
                        {
                            std::function<void(const syntax::SyntaxNode&)> scan =
                                [&](const syntax::SyntaxNode& sn) {
                                    if (bitsOfSignal)
                                        return;
                                    if (sn.kind ==
                                        syntax::SyntaxKind::InvocationExpression) {
                                        auto& inv2 =
                                            sn.as<syntax::InvocationExpressionSyntax>();
                                        if (inv2.left->kind ==
                                                syntax::SyntaxKind::SystemName &&
                                            inv2.arguments && declScope)
                                            for (auto a2 : inv2.arguments->parameters) {
                                                auto* sy2 = declScope->find(std::string(
                                                    rawText(a2->sourceRange())));
                                                if (sy2 &&
                                                    (sy2->kind == SymbolKind::Net ||
                                                     sy2->kind == SymbolKind::Variable))
                                                    bitsOfSignal = true;
                                            }
                                    }
                                    for (size_t ci = 0; ci < sn.getChildCount(); ci++)
                                        if (auto* cn = sn.childNode(ci))
                                            scan(*cn);
                                };
                            if (bsyn)
                                scan(*bsyn);
                        }
                        // A BARE param-ref bound in a PARAMETER's own typespec
                        // ([DepthW:0] on localparam FullDepth) stays a scoped
                        // ref_obj (a VAR/NET typespec folds it — issue326).
                        bool bareParamInParamTs = false;
                        if (declSymbol.kind == SymbolKind::Parameter && bsyn &&
                            bsyn->kind == syntax::SyntaxKind::IdentifierName &&
                            currentScope) {
                            ASTContext bctx(*currentScope, LookupLocation::max);
                            auto& be = Expression::bind(*bsyn, bctx);
                            if (!be.bad() &&
                                stripImplicitConv(be).kind ==
                                    ExpressionKind::NamedValue &&
                                stripImplicitConv(be)
                                        .as<NamedValueExpression>()
                                        .symbol.kind == SymbolKind::Parameter)
                                bareParamInParamTs = true;
                        }
                        // A NON-TOP def port dim bound referencing an
                        // OVERRIDABLE module parameter (X-1 on parameter int X)
                        // stays symbolic: unresolved in the child def view.
                        bool defModuleParamDim = false;
                        if (defPortDim && bsyn && currentScope) {
                            ASTContext bctx(*currentScope, LookupLocation::max);
                            auto& be = Expression::bind(*bsyn, bctx);
                            if (!be.bad())
                                be.visit(makeVisitor(
                                    [&](auto& v, const NamedValueExpression& nv) {
                                        if (nv.symbol.kind ==
                                                SymbolKind::Parameter &&
                                            !nv.symbol.as<ParameterSymbol>()
                                                 .isLocalParam())
                                            defModuleParamDim = true;
                                        v.visitDefault(nv);
                                    }));
                        }
                        // A MODULE signal/net packed range bound that reaches
                        // an INTERFACE member THROUGH a modport/interface port
                        // (sub.OFF, s.CFG.BUS.DAT) stays a SYMBOLIC operation
                        // tree in Surelog's elab view — the port hop is not
                        // folded (unlike a bound referencing only local params
                        // or the interface's own params directly, which fold).
                        // Detected from the module PORT LIST (scope-independent:
                        // the elab-view bind of a modport-hop bound can fail):
                        // an identifier in the bound that names an interface/
                        // modport PORT of the declaring module means the bound
                        // reaches an interface member through the port hop.
                        bool ifacePortBound = false;
                        if (bsyn && !tfContext && !bitsOfSignal &&
                            !bareParamInParamTs && !defModuleParamDim) {
                            const InstanceBodySymbol* ib = nullptr;
                            for (auto sc = declSymbol.getParentScope(); sc;
                                 sc = sc->asSymbol().getParentScope())
                                if (sc->asSymbol().kind == SymbolKind::InstanceBody) {
                                    ib = &sc->asSymbol().as<InstanceBodySymbol>();
                                    break;
                                }
                            if (ib) {
                                std::set<std::string> ifacePortNames;
                                for (auto pb : ib->getPortList())
                                    if (pb && pb->kind == SymbolKind::InterfacePort)
                                        ifacePortNames.insert(std::string(pb->name));
                                if (!ifacePortNames.empty()) {
                                    std::function<void(const syntax::SyntaxNode&)>
                                        scan = [&](const syntax::SyntaxNode& sn) {
                                            if (ifacePortBound)
                                                return;
                                            if (sn.kind ==
                                                syntax::SyntaxKind::IdentifierName) {
                                                auto txt = rawText(
                                                    sn.as<syntax::IdentifierNameSyntax>()
                                                        .identifier.range());
                                                if (ifacePortNames.count(
                                                        std::string(txt)))
                                                    ifacePortBound = true;
                                            }
                                            for (size_t ci = 0;
                                                 ci < sn.getChildCount(); ci++)
                                                if (auto* cn = sn.childNode(ci))
                                                    scan(*cn);
                                        };
                                    scan(*bsyn);
                                }
                            }
                        }
                        // ...but only in the DEF/generic view. An ELABORATED
                        // child-instance body folds the bound (Surelog).
                        // elabInstanceTs marks the elab-instance net/var
                        // typespec emission. The fold uses the interface's
                        // DEFAULT param value (the AllModules width), NOT the
                        // connected per-instance override. Re-evaluate the
                        // bound substituting each interface param reached
                        // through the port with its DEFAULT value: an external
                        // (through-port) parameter resolves to a default
                        // instance of its OWN interface definition (safe to
                        // instantiate — no port hop), while local params and
                        // literals fold normally.
                        if (ifacePortBound && elabInstanceTs) {
                            ifacePortBound = false;
                            const InstanceBodySymbol* ib2 = nullptr;
                            for (auto sc = declSymbol.getParentScope(); sc;
                                 sc = sc->asSymbol().getParentScope())
                                if (sc->asSymbol().kind ==
                                    SymbolKind::InstanceBody) {
                                    ib2 = &sc->asSymbol()
                                               .as<InstanceBodySymbol>();
                                    break;
                                }
                            if (ib2 && bsyn && currentScope) {
                                ASTContext bctx(*currentScope,
                                                LookupLocation::max);
                                auto& be = Expression::bind(*bsyn, bctx);
                                std::function<std::optional<ConstantValue>(
                                    const Expression&)>
                                    evalDef =
                                        [&](const Expression& e)
                                        -> std::optional<ConstantValue> {
                                    switch (e.kind) {
                                    case ExpressionKind::Conversion:
                                        return evalDef(
                                            e.as<ConversionExpression>()
                                                .operand());
                                    case ExpressionKind::UnaryOp: {
                                        auto& u = e.as<UnaryExpression>();
                                        auto ov = evalDef(u.operand());
                                        if (!ov)
                                            return std::nullopt;
                                        if (u.op == UnaryOperator::Minus)
                                            return ConstantValue(-ov->integer());
                                        if (u.op == UnaryOperator::Plus)
                                            return ov;
                                        return std::nullopt;
                                    }
                                    case ExpressionKind::BinaryOp: {
                                        auto& b = e.as<BinaryExpression>();
                                        auto l = evalDef(b.left());
                                        auto r = evalDef(b.right());
                                        if (!l || !r)
                                            return std::nullopt;
                                        auto cv = OpInfo::eval(b.op, *l, *r);
                                        if (cv.isInteger())
                                            return cv;
                                        return std::nullopt;
                                    }
                                    case ExpressionKind::NamedValue:
                                    case ExpressionKind::HierarchicalValue: {
                                        const Symbol& sym =
                                            e.kind == ExpressionKind::NamedValue
                                                ? e.as<NamedValueExpression>()
                                                      .symbol
                                                : e.as<HierarchicalValueExpression>()
                                                      .symbol;
                                        if (sym.kind == SymbolKind::Parameter) {
                                            const InstanceBodySymbol* pib =
                                                nullptr;
                                            for (auto sc = sym.getParentScope();
                                                 sc;
                                                 sc = sc->asSymbol()
                                                          .getParentScope())
                                                if (sc->asSymbol().kind ==
                                                    SymbolKind::InstanceBody) {
                                                    pib = &sc->asSymbol()
                                                               .as<InstanceBodySymbol>();
                                                    break;
                                                }
                                            // External (through-port) interface
                                            // param: substitute the interface
                                            // DEFAULT value.
                                            if (pib && pib != ib2 &&
                                                pib->getDefinition()
                                                        .definitionKind ==
                                                    DefinitionKind::Interface) {
                                                auto& pdef =
                                                    pib->getDefinition();
                                                auto dfIt =
                                                    moduleDefaultInst.find(
                                                        &pdef);
                                                if (dfIt ==
                                                    moduleDefaultInst.end())
                                                    dfIt =
                                                        moduleDefaultInst
                                                            .emplace(
                                                                &pdef,
                                                                &InstanceSymbol::
                                                                    createDefault(
                                                                        comp,
                                                                        pdef))
                                                            .first;
                                                if (auto* dsym =
                                                        dfIt->second->body.find(
                                                            std::string(
                                                                sym.name));
                                                    dsym &&
                                                    dsym->kind ==
                                                        SymbolKind::Parameter) {
                                                    auto dv =
                                                        dsym->as<ParameterSymbol>()
                                                            .getValue();
                                                    if (dv.isInteger())
                                                        return dv;
                                                }
                                            }
                                            auto pv =
                                                sym.as<ParameterSymbol>()
                                                    .getValue();
                                            if (pv.isInteger())
                                                return pv;
                                            return std::nullopt;
                                        }
                                        return std::nullopt;
                                    }
                                    default: {
                                        // Literals and param-free subtrees fold
                                        // via the normal instance context.
                                        ASTContext ec(*currentScope,
                                                      LookupLocation::max);
                                        if (auto cv = ec.tryEval(e);
                                            cv && cv.isInteger())
                                            return cv;
                                        return std::nullopt;
                                    }
                                    }
                                };
                                if (!be.bad())
                                    if (auto dcv = evalDef(be);
                                        dcv && dcv->isInteger() &&
                                        !dcv->integer().hasUnknown())
                                        value = *dcv->integer().as<int64_t>();
                            }
                        }
                        // A packed range bound referencing a LOCALPARAM whose
                        // init reads a MEMBER of a struct-typed parameter
                        // (localparam int N = Info.x) stays SYMBOLIC in Surelog:
                        // the localparam ref is SUBSTITUTED by a re-emission of
                        // its init hier_path (Info.x), kept unfolded. Applies in
                        // both def and elab module views (module signal dims).
                        // Follow a param's init chain: a param whose init reads
                        // a struct-param MEMBER (N = Info.x) IS the member-init
                        // param; a param whose init is a bare ref to another
                        // param (an OVERRIDE, Depth = N) recurses. Returns the
                        // member-init param whose init hier_path is re-emitted.
                        std::function<const ParameterSymbol*(
                            const ParameterSymbol*, int)>
                            resolveMemberInit =
                                [&](const ParameterSymbol* p,
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
                                return resolveMemberInit(
                                    &rs->as<ParameterSymbol>(), depth + 1);
                            return nullptr;
                        };
                        const ParameterSymbol* memberInitParam = nullptr;
                        if (bsyn && currentScope && !tfContext && !bitsOfSignal &&
                            !bareParamInParamTs && !defModuleParamDim &&
                            !ifacePortBound && !defPortDim) {
                            ASTContext bctx(*currentScope, LookupLocation::max);
                            auto& be = Expression::bind(*bsyn, bctx);
                            if (!be.bad())
                                be.visit(makeVisitor(
                                    [&](auto& v, const NamedValueExpression& nv) {
                                        if (memberInitParam)
                                            return;
                                        if (nv.symbol.kind ==
                                            SymbolKind::Parameter)
                                            memberInitParam = resolveMemberInit(
                                                &nv.symbol
                                                     .as<ParameterSymbol>(),
                                                0);
                                        v.visitDefault(nv);
                                    }));
                        }
                        if (memberInitParam) {
                            ASTContext bctx(*currentScope, LookupLocation::max);
                            auto& be = Expression::bind(*bsyn, bctx);
                            NetMap none;
                            std::string bpfx = boundOwnerFullName;
                            // Re-emit N's init (Info.x) as a hier_path, and
                            // attach a ref_typespec scoped under the declaring
                            // signal (work@top.data.Info.x) whose actual is N's
                            // own (int) typespec.
                            auto emitInitHier =
                                [&](UHDM::BaseClass* par) -> UHDM::expr* {
                                auto* init = memberInitParam->getInitializer();
                                auto* he = (UHDM::expr*)emitExpr(*init, par, bpfx,
                                                                 none);
                                if (he &&
                                    he->UhdmType() == UHDM::uhdmhier_path) {
                                    auto* hp = (UHDM::hier_path*)he;
                                    auto* rt = s.MakeRef_typespec();
                                    rt->VpiFullName(
                                        bpfx.empty()
                                            ? std::string(hp->VpiName())
                                            : bpfx + "." +
                                                  std::string(hp->VpiName()));
                                    rt->VpiParent(hp);
                                    auto* its = s.MakeInt_typespec();
                                    if (auto dt =
                                            memberInitParam->getDeclaredType())
                                        if (auto* tsyn = dt->getTypeSyntax())
                                            setLoc(its, tsyn->sourceRange());
                                    if (memberInitParam->getType().isSigned())
                                        its->VpiSigned(true);
                                    rt->Actual_typespec(its);
                                    hp->Typespec(rt);
                                }
                                return he;
                            };
                            if (!be.bad() &&
                                stripImplicitConv(be).kind ==
                                    ExpressionKind::BinaryOp) {
                                auto& bin =
                                    stripImplicitConv(be).as<BinaryExpression>();
                                auto* op = s.MakeOperation();
                                op->VpiOpType(mapBinaryOp(bin.op));
                                op->VpiParent(r);
                                setLoc(op, bsyn->sourceRange());
                                auto* operands = s.MakeAnyVec();
                                if (auto* l = emitInitHier(op))
                                    operands->push_back(l);
                                const syntax::ExpressionSyntax* rsub = nullptr;
                                if (syntax::BinaryExpressionSyntax::isKind(
                                        bsyn->kind))
                                    rsub =
                                        bsyn->as<syntax::BinaryExpressionSyntax>()
                                            .right;
                                int64_t rval = 1;
                                if (auto rcv = bctx.tryEval(bin.right());
                                    rcv && rcv.isInteger())
                                    rval = *rcv.integer().as<int64_t>();
                                if (rsub)
                                    operands->push_back(
                                        makeBoundConst(rsub, rval, op));
                                op->Operands(operands);
                                return op;
                            }
                            if (auto* he = emitInitHier(r))
                                return he;
                        }
                        if (tfContext || bitsOfSignal || bareParamInParamTs ||
                            defModuleParamDim || ifacePortBound ||
                            structMemberSymBound) {
                            // Function/typedef context: unfolded expression.
                            bool savedBCN = boundCallNameSpan;
                            boundCallNameSpan = true;
                            auto* e0bcn = emitSyntaxExpr(*bsyn, r);
                            boundCallNameSpan = savedBCN;
                            if (auto* e = e0bcn) {
                                // The sys-call arg refs bind their DEF
                                // nets — deferred until the nets exist.
                                if (bitsOfSignal) {
                                    std::function<void(UHDM::any*)> bindR =
                                        [&](UHDM::any* n0) {
                                            if (!n0)
                                                return;
                                            if (n0->UhdmType() == UHDM::uhdmref_obj) {
                                                auto* r2 = (UHDM::ref_obj*)n0;
                                                if (!r2->Actual_group() && declScope)
                                                    if (auto* sy3 = declScope->find(
                                                            std::string(r2->VpiName())))
                                                        pendingBitsBoundRefs.push_back(
                                                            {r2, sy3});
                                            }
                                            else if (n0->UhdmType() ==
                                                     UHDM::uhdmoperation) {
                                                if (auto* ops2 =
                                                        ((UHDM::operation*)n0)
                                                            ->Operands())
                                                    for (auto* o2 : *ops2)
                                                        bindR(o2);
                                            }
                                            else if (n0->UhdmType() ==
                                                     UHDM::uhdmsys_func_call) {
                                                if (auto* ar2 =
                                                        ((UHDM::sys_func_call*)n0)
                                                            ->Tf_call_args())
                                                    for (auto* o2 : *ar2)
                                                        bindR(o2);
                                            }
                                        };
                                    bindR(e);
                                }
                                return (UHDM::expr*)e;
                            }
                        }
                        // Elab IFACE views re-evaluate the bound at the
                        // DEFAULT param values (per-instance overrides are
                        // ignored — Surelog's AllModules width).
                        if (ifaceDefaultScope) {
                            ASTContext dctx(*ifaceDefaultScope, LookupLocation::max);
                            auto& dbe = Expression::bind(*bsyn, dctx);
                            if (!dbe.bad())
                                if (auto dcv = dctx.tryEval(dbe);
                                    dcv && dcv.isInteger() &&
                                    !dcv.integer().hasUnknown())
                                    value = *dcv.integer().as<int64_t>();
                        }
                        // Module context: a bare reference bound ([i:i]) folds
                        // to a UINT value-constant at its token; only an
                        // OPERATION bound (N-1) folds to an INT anchored at the
                        // operator's LEFT operand span.
                        auto* c = s.MakeConstant();
                        c->VpiParent(r);
                        c->VpiSize(64);
                        std::string digits = std::to_string(value);
                        c->VpiDecompile(digits);
                        if (syntax::BinaryExpressionSyntax::isKind(bsyn->kind)) {
                            // A subtract bound (N-1) reduces to a signed INT;
                            // other operators (N+1, N*2) reduce to UINT. Both
                            // anchor at the left-operand span — except in a
                            // typedef-signal CLONE, where the constant stays
                            // BARE (no loc, no parent).
                            if (bsyn->kind == syntax::SyntaxKind::SubtractExpression) {
                                c->VpiConstType(vpiIntConst);
                                c->VpiValue("INT:" + digits);
                            }
                            else {
                                c->VpiConstType(vpiUIntConst);
                                c->VpiValue("UINT:" + digits);
                            }
                            if (bareCloneComputedBounds)
                                c->VpiParent(nullptr);
                            else
                                setLoc(c, bsyn->as<syntax::BinaryExpressionSyntax>()
                                              .left->sourceRange());
                        }
                        else {
                            // A bound that references an int-encoded param
                            // (e.g. DINW = 2**SELW) folds to a signed INT
                            // const. A bare MODULE-param ref folds at the
                            // param's width with a ts ref (loc-less signed
                            // int clone, var-scoped fullname).
                            bool intEnc = false;
                            const ParameterSymbol* boundParam = nullptr;
                            // The MODULE (InstanceBody) param a bare bound
                            // resolves to, captured regardless of typed-ness for
                            // the elab-clone width fold below.
                            const ParameterSymbol* elabModPar = nullptr;
                            if (currentScope) {
                                ASTContext bctx(*currentScope, LookupLocation::max);
                                auto& be = Expression::bind(*bsyn, bctx);
                                if (!be.bad()) {
                                    intEnc = isIntEncoded(be);
                                    auto& bee = stripImplicitConv(be);
                                    if (bee.kind == ExpressionKind::NamedValue &&
                                        bee.as<NamedValueExpression>().symbol.kind ==
                                            SymbolKind::Parameter) {
                                        auto& bp = bee.as<NamedValueExpression>()
                                                       .symbol.as<ParameterSymbol>();
                                        // TYPED params only (untyped keep
                                        // the bare 64-bit fold).
                                        bool typedP = false;
                                        if (auto bd0 = bp.getDeclaredType())
                                            if (auto bt0 = bd0->getTypeSyntax())
                                                typedP =
                                                    bt0->kind !=
                                                    syntax::SyntaxKind::ImplicitType;
                                        if (auto bsc = bp.getParentScope();
                                            typedP && bsc &&
                                            bsc->asSymbol().kind ==
                                                SymbolKind::InstanceBody)
                                            boundParam = &bp;
                                        // A GEN-SCOPE localparam bound folds
                                        // BARE at 32 (untyped resolves to
                                        // int) — Surelog.
                                        else if (auto bsc2 =
                                                     bp.getParentScope();
                                                 bsc2 && !bp.isFromGenvar() &&
                                                 bsc2->asSymbol().kind ==
                                                     SymbolKind::GenerateBlock)
                                            c->VpiSize(32);
                                        if (auto bsc3 = bp.getParentScope();
                                            bsc3 &&
                                            bsc3->asSymbol().kind ==
                                                SymbolKind::InstanceBody)
                                            elabModPar = &bp;
                                    }
                                }
                            }
                            if (boundParam && !boundOwnerFullName.empty() &&
                                !intEnc) {
                                c->VpiSize(
                                    (int32_t)boundParam->getType().getBitWidth());
                                c->VpiConstType(vpiUIntConst);
                                c->VpiValue("UINT:" + digits);
                                auto* rt0 = s.MakeRef_typespec();
                                rt0->VpiFullName(boundOwnerFullName);
                                rt0->VpiParent(c);
                                auto* its0 = s.MakeInt_typespec();
                                if (boundParam->getType().isSigned())
                                    its0->VpiSigned(true);
                                rt0->Actual_typespec(its0);
                                c->Typespec(rt0);
                            }
                            // An ELAB var-dim bound folding a MODULE-param ref
                            // that did NOT take the typed+var-scoped ts-ref path
                            // above (an untyped int-valued param, or a typed one
                            // minted without a var-scoped owner as in a gen-child
                            // typespec clone) takes the param's own width
                            // (int-valued -> 32) but NO ts ref — Surelog.
                            // A TYPED param always carries its width; an
                            // UNTYPED param only takes its (narrow) width when
                            // its initializer is a plain integer LITERAL — one
                            // computed from a $clog2/func CALL keeps the bare
                            // 64-bit fold (Surelog).
                            else if (elabModPar && !intEnc &&
                                     (boundParam ||
                                      (elabModPar->getInitializer() &&
                                       stripImplicitConv(
                                           *elabModPar->getInitializer())
                                               .kind ==
                                           ExpressionKind::IntegerLiteral))) {
                                c->VpiSize(
                                    (int32_t)elabModPar->getType().getBitWidth());
                                c->VpiConstType(vpiUIntConst);
                                c->VpiValue("UINT:" + digits);
                            }
                            else {
                                c->VpiConstType(intEnc ? vpiIntConst : vpiUIntConst);
                                c->VpiValue((intEnc ? "INT:" : "UINT:") + digits);
                            }
                            setLoc(c, bsyn->getFirstToken().range());
                        }
                        return c;
                    };
                    r->Left_expr(emitBound(lsyn, dims[i].left));
                    r->Right_expr(emitBound(rsyn, dims[i].right));
                    ranges->push_back(r);
                }
                ts->Ranges(ranges);
            }
            else {
                noteUnsupported("packed dimension shape");
            }
        }
        else {
            // NamedType + extra packed dims (reg8_t [0:3] x): golden emits the
            // net with NO typespec; emit a dim-less logic ts (callers require
            // non-null) — close enough to unblock (dump shows the bare ts).
        }
    }
    return ts;
}

UHDM::variables* UhdmExporter::makeVar(const Symbol& internal, bool portBacked) {
    auto declared = internal.getDeclaredType();
    if (!declared)
        return nullptr;
    auto& ct = declared->getType().getCanonicalType();
    // Non-port `logic` variables become logic_vars in the elaborated view;
    // `reg` declarations stay logic_nets.
    bool regDecl = false;
    if (auto tsyn = declared->getTypeSyntax())
        regDecl = tsyn->kind == syntax::SyntaxKind::RegType;
    // A `parameter type T`-typed port elaborates as a variable of its resolved
    // type (Surelog), even though the def view keeps it a net.
    bool typeParamPort = portTypeParam(internal) != nullptr;
    // Enum variables — and PORTS typed by a PACKAGE enum typedef
    // (input custom::enum1 e), or by a `type` parameter resolving to an enum —
    // elaborate as enum_vars.
    bool pkgEnumAlias = false;
    if (ct.kind == SymbolKind::EnumType) {
        auto& t0 = declared->getType();
        if (t0.kind == SymbolKind::TypeAlias)
            if (auto sc0 = t0.as<TypeAliasType>().getParentScope();
                sc0 && sc0->asSymbol().kind == SymbolKind::Package)
                pkgEnumAlias = true;
    }
    if (ct.kind == SymbolKind::EnumType &&
        (internal.kind == SymbolKind::Variable || pkgEnumAlias || typeParamPort)) {
        auto* v = s.MakeEnum_var();
        v->VpiVisibility(1);
        return v;
    }
    // Class handles are class_vars in the elab view.
    if (ct.kind == SymbolKind::ClassType) {
        auto* v = s.MakeClass_var();
        v->VpiVisibility(1);
        return v;
    }
    // A TYPEDEF'd union variable elaborates as a union_var; an ANONYMOUS one
    // (declared type IS the union, not an alias) routes to the net path as a
    // struct_net (Surelog) — return null so the caller falls through.
    if (ct.kind == SymbolKind::PackedUnionType) {
        if (declared->getType().kind == SymbolKind::PackedUnionType)
            return nullptr;
        auto* v = s.MakeUnion_var();
        v->VpiVisibility(1);
        return v;
    }
    // A 2-STATE scalar (bit) signal can never be a net — bit_var, even for
    // ports (Surelog).
    if (ct.kind == SymbolKind::ScalarType && ct.isIntegral() &&
        !ct.isFourState()) {
        auto* v = s.MakeBit_var();
        v->VpiVisibility(1);
        return v;
    }
    // Real/shortreal signals are variables, never nets.
    if (ct.kind == SymbolKind::FloatingType) {
        auto* v = ct.as<FloatingType>().floatKind == FloatingType::ShortReal
                      ? (UHDM::variables*)s.MakeShort_real_var()
                      : (UHDM::variables*)s.MakeReal_var();
        v->VpiVisibility(1);
        return v;
    }
    // String signals are variables.
    if (ct.kind == SymbolKind::StringType) {
        auto* v = s.MakeString_var();
        v->VpiVisibility(1);
        return v;
    }
    // Packed structs become struct_nets (handled by the net branch) —
    // except 2-STATE structs (int members etc.), which cannot be nets and
    // elaborate as struct_vars.
    if (ct.kind == SymbolKind::PackedStructType) {
        if (!ct.isFourState()) {
            auto* v = s.MakeStruct_var();
            v->VpiVisibility(1);
            return v;
        }
        // A 4-state struct whose TOP-LEVEL fields include an ATOM
        // (byte/int/integer), an ENUM, or any 2-state member is a struct_var
        // too (net_types decode) — but only for plain non-port, no-init,
        // non-portBacked declarations.
        if (!portBacked && internal.kind == SymbolKind::Variable &&
            !internal.getDeclaredType()->getInitializer()) {
            bool atomField = false;
            for (auto& fm :
                 ct.as<PackedStructType>().membersOfType<FieldSymbol>()) {
                auto& fct = fm.getType().getCanonicalType();
                if (fct.kind == SymbolKind::PredefinedIntegerType ||
                    fct.kind == SymbolKind::EnumType ||
                    fct.kind == SymbolKind::PackedUnionType ||
                    !fct.isFourState()) {
                    atomField = true;
                    break;
                }
            }
            if (atomField) {
                auto* v = s.MakeStruct_var();
                v->VpiVisibility(1);
                return v;
            }
        }
        return nullptr;
    }
    // A packed array over a packed struct that reached here (its element is an
    // ANONYMOUS struct, so emitPackedStructArrayVar didn't fire) is a
    // struct_var carrying the shared packed_array_typespec.
    if (ct.kind == SymbolKind::PackedArrayType) {
        const Type* lf = &ct;
        while (lf->getCanonicalType().kind == SymbolKind::PackedArrayType)
            lf = &lf->getCanonicalType().as<PackedArrayType>().elementType;
        if (lf->getCanonicalType().kind == SymbolKind::PackedStructType) {
            auto* v = s.MakeStruct_var();
            v->VpiVisibility(1);
            return v;
        }
    }
    // A non-port logic variable, or a port with a separate `logic` body
    // redeclaration (input [3:0] a; logic [3:0] a;), is a logic_var; a plain
    // ANSI port stays a net. A port typed by a SCOPED package vector typedef
    // (output my_pkg::word o) is a logic_var too — but an IMPORTED
    // unqualified typedef port (import pkg::T; output T o) stays a net.
    bool pkgAliasPort = false;
    {
        auto& t = declared->getType();
        if (t.kind == SymbolKind::TypeAlias)
            if (auto sc = t.as<TypeAliasType>().getParentScope();
                sc && sc->asSymbol().kind == SymbolKind::Package) {
                pkgAliasPort = true;
                if (auto tsyn = declared->getTypeSyntax();
                    tsyn && tsyn->kind == syntax::SyntaxKind::NamedType &&
                    tsyn->as<syntax::NamedTypeSyntax>().name->kind ==
                        syntax::SyntaxKind::IdentifierName)
                    pkgAliasPort = false;
            }
    }
    if ((!portBacked || hasBodyDecl(internal) || pkgAliasPort || typeParamPort) &&
        !regDecl &&
        (internal.kind == SymbolKind::Variable || typeParamPort) &&
        ct.kind != SymbolKind::PredefinedIntegerType && ct.isIntegral() && ct.isFourState()) {
        auto* v = s.MakeLogic_var();
        v->VpiVisibility(1);
        // TYPEDEF'd vars carry signedness on the shared typespec only.
        if (ct.isSigned() && declared->getType().kind != SymbolKind::TypeAlias)
            v->VpiSigned(true);
        return v;
    }
    // A NET of a predefined-integer type (wire integer x) stays a NET in
    // the elab too (net_types decode: only Variables and ports become vars).
    if (ct.kind == SymbolKind::PredefinedIntegerType &&
        (internal.kind != SymbolKind::Net || portBacked ||
         !hasExplicitNetKeyword(internal))) {
        auto& pit = ct.as<PredefinedIntegerType>();
        switch (pit.integerKind) {
            case PredefinedIntegerType::Int: {
                auto* v = s.MakeInt_var();
                v->VpiSigned(pit.isSigned);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::Integer: {
                auto* v = s.MakeInteger_var();
                v->VpiSigned(pit.isSigned);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::ShortInt: {
                auto* v = s.MakeShort_int_var();
                v->VpiSigned(pit.isSigned);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::LongInt: {
                auto* v = s.MakeLong_int_var();
                v->VpiSigned(pit.isSigned);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::Byte: {
                auto* v = s.MakeByte_var();
                v->VpiSigned(pit.isSigned);
                v->VpiVisibility(1);
                return v;
            }
            case PredefinedIntegerType::Time: {
                // A `time` PORT stays a logic_net (time_typespec actual);
                // only non-port time variables become time_vars.
                if (portBacked)
                    return nullptr;
                auto* v = s.MakeTime_var();
                v->VpiVisibility(1);
                return v;
            }
            default:
                return nullptr;
        }
    }
    return nullptr;
}

UHDM::constant* UhdmExporter::makeBoundConst(const syntax::SyntaxNode* syn, int64_t value,
                                             UHDM::BaseClass* parent) {
    auto* c = s.MakeConstant();
    c->VpiParent(parent);
    c->VpiSize(64);
    c->VpiConstType(vpiUIntConst);
    c->VpiValue("UINT:" + std::to_string(value));
    if (syn) {
        setLoc(c, syn->sourceRange());
        // rawText returns "" for MACRO-expanded ranges (call-site offsets do
        // not map into the buffer) — fall back to the numeric value.
        std::string raw = rawText(syn->sourceRange());
        c->VpiDecompile(raw.empty() ? std::to_string(value) : raw);
    }
    return c;
}

UHDM::typespec* UhdmExporter::makeTypeParamDefaultTs(
    const syntax::DataTypeSyntax& defSyn, const Scope& body) {
    ASTContext actx(body, LookupLocation::max);
    const Type& dt = comp.getType(defSyn, actx);
    const Type& ct = dt.getCanonicalType();
    // A named typedef/enum default shares its already-emitted typespec.
    for (auto& [sym, tsp] : typedefTs)
        if (sym->kind == SymbolKind::TypeAlias &&
            &sym->as<TypeAliasType>().getCanonicalType() == &ct)
            return tsp;
    auto* ts = s.MakeLogic_typespec();
    setLoc(ts, defSyn.sourceRange());
    if (dt.isSigned())
        ts->VpiSigned(true);
    // Packed vector dims -> ranges (bounds as UINT constants, source spans from
    // the default type-syntax dimensions).
    const syntax::SyntaxList<syntax::VariableDimensionSyntax>* dimSyns = nullptr;
    if (syntax::IntegerTypeSyntax::isKind(defSyn.kind))
        dimSyns = &defSyn.as<syntax::IntegerTypeSyntax>().dimensions;
    if (dimSyns && ct.isPackedArray()) {
        std::vector<ConstantRange> dims;
        const Type* t = &ct;
        while (t->isPackedArray()) {
            dims.push_back(t->as<PackedArrayType>().range);
            t = &t->as<PackedArrayType>().elementType.getCanonicalType();
        }
        if (dims.size() == dimSyns->size()) {
            auto* ranges = s.MakeRangeVec();
            for (size_t i = 0; i < dims.size(); i++) {
                auto* dimSyn = (*dimSyns)[i];
                auto* r = s.MakeRange();
                r->VpiParent(ts);
                setLoc(r, dimSyn->sourceRange());
                const syntax::ExpressionSyntax* lsyn = nullptr;
                const syntax::ExpressionSyntax* rsyn = nullptr;
                if (dimSyn->specifier &&
                    dimSyn->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& spec = dimSyn->specifier
                                     ->as<syntax::RangeDimensionSpecifierSyntax>();
                    if (spec.selector->kind == syntax::SyntaxKind::SimpleRangeSelect) {
                        auto& sel = spec.selector->as<syntax::RangeSelectSyntax>();
                        lsyn = sel.left;
                        rsyn = sel.right;
                    }
                }
                r->Left_expr(makeBoundConst(lsyn, dims[i].left, r));
                r->Right_expr(makeBoundConst(rsyn, dims[i].right, r));
                ranges->push_back(r);
            }
            ts->Ranges(ranges);
        }
    }
    return ts;
}

UHDM::typespec* UhdmExporter::sharedTypespec(const Symbol& declSymbol, TsCache& cache,
                                             const PortSymbol* portCtx) {
    // Key on the shared type syntax node so all declarators of one
    // declaration ("input A, B;") reuse the same typespec object.
    const void* key = &declSymbol;
    if (auto declared = declSymbol.getDeclaredType()) {
        if (auto tsyn = declared->getTypeSyntax())
            key = tsyn;
    }
    auto it = cache.find(key);
    if (it != cache.end())
        return it->second;
    auto* ts = makeTypespec(declSymbol, nullptr, portCtx);
    cache[key] = ts;
    return ts;
}

// Shared enum_typespec builder: base typespec (when the syntax declares
// one) + enum constants with Surelog value encodings.
UHDM::enum_typespec* UhdmExporter::buildEnumTs(const EnumType& et,
                                               const syntax::SyntaxNode* enumSyn,
                                               const std::string& refFullName,
                                               bool implicitBaseRef) {
    auto* ets = s.MakeEnum_typespec();
    const syntax::SyntaxNode* baseSyn = nullptr;
    if (enumSyn && enumSyn->kind == syntax::SyntaxKind::EnumType)
        baseSyn = enumSyn->as<syntax::EnumTypeSyntax>().baseType;
    if (baseSyn) {
        // An integer base (enum int/integer/... {..}) uses the matching integer
        // typespec; a logic/bit vector base uses logic_typespec (with a range).
        UHDM::typespec* bts = nullptr;
        auto& bct = et.baseType.getCanonicalType();
        if (bct.kind == SymbolKind::PredefinedIntegerType) {
            bool sgn = et.baseType.isSigned();
            switch (bct.as<PredefinedIntegerType>().integerKind) {
                case PredefinedIntegerType::Int: {
                    auto* t = s.MakeInt_typespec();
                    if (sgn) t->VpiSigned(true);
                    bts = t;
                    break;
                }
                case PredefinedIntegerType::Integer: {
                    auto* t = s.MakeInteger_typespec();
                    if (sgn) t->VpiSigned(true);
                    bts = t;
                    break;
                }
                case PredefinedIntegerType::ShortInt: {
                    auto* t = s.MakeShort_int_typespec();
                    if (sgn) t->VpiSigned(true);
                    bts = t;
                    break;
                }
                case PredefinedIntegerType::LongInt: {
                    auto* t = s.MakeLong_int_typespec();
                    if (sgn) t->VpiSigned(true);
                    bts = t;
                    break;
                }
                case PredefinedIntegerType::Byte: {
                    auto* t = s.MakeByte_typespec();
                    if (sgn) t->VpiSigned(true);
                    bts = t;
                    break;
                }
                default:
                    break;
            }
            if (bts)
                setLoc(bts, baseSyn->sourceRange());
        }
        if (bts) {
            auto* brt = s.MakeRef_typespec();
            brt->VpiFullName(refFullName);
            brt->VpiParent(ets);
            brt->Actual_typespec(bts);
            ets->Base_typespec(brt);
        }
        else {
        // A `bit`-based enum keeps a bit_typespec base (Surelog); logic and
        // implicit vectors use logic_typespec.
        bool bitBase9 = baseSyn->kind == syntax::SyntaxKind::BitType;
        UHDM::typespec* bts =
            bitBase9 ? (UHDM::typespec*)s.MakeBit_typespec()
                     : (UHDM::typespec*)s.MakeLogic_typespec();
        if (et.baseType.isSigned()) {
            if (bitBase9)
                ((UHDM::bit_typespec*)bts)->VpiSigned(true);
            else
                ((UHDM::logic_typespec*)bts)->VpiSigned(true);
        }
        setLoc(bts, baseSyn->sourceRange());
        if (et.baseType.isPackedArray()) {
            auto range = et.baseType.getFixedRange();
            const syntax::ExpressionSyntax* lsyn = nullptr;
            const syntax::ExpressionSyntax* rsyn = nullptr;
            if (syntax::IntegerTypeSyntax::isKind(baseSyn->kind)) {
                auto& dims = baseSyn->as<syntax::IntegerTypeSyntax>().dimensions;
                if (dims.size() == 1 && (*dims.begin())->specifier &&
                    (*dims.begin())->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier) {
                    auto& spec = (*dims.begin())
                                     ->specifier
                                     ->as<syntax::RangeDimensionSpecifierSyntax>();
                    if (spec.selector->kind == syntax::SyntaxKind::SimpleRangeSelect) {
                        auto& sel = spec.selector->as<syntax::RangeSelectSyntax>();
                        lsyn = sel.left;
                        rsyn = sel.right;
                    }
                }
            }
            auto* r = s.MakeRange();
            r->VpiParent(bts);
            if (syntax::IntegerTypeSyntax::isKind(baseSyn->kind) &&
                !baseSyn->as<syntax::IntegerTypeSyntax>().dimensions.empty())
                setLoc(r, (*baseSyn->as<syntax::IntegerTypeSyntax>().dimensions.begin())
                              ->sourceRange());
            // Non-literal bounds (logic [W-1:0]) stay UNFOLDED in a
            // MODULE-local enum typedef's base; a PKG enum's base FOLDS to a
            // signed INT constant anchored at the bound's leading
            // identifier token (MUSI pkg::enum_t [Width-1:0] -> INT:3 at
            // the Width span). The fold applies in the ELABORATED (top)
            // package view and in module-context clones; the DEF-view PACKAGE
            // typedef LISTING keeps the bound SYMBOLIC (Surelog emits a
            // symbolic def base + a folded elab base). inPkgTypedefEmit
            // distinguishes the def-package listing from module context (both
            // have pkgTopEmit == false).
            bool pkgEnum9 =
                refFullName.find("::") != std::string::npos &&
                !(inPkgTypedefEmit && !pkgTopEmit);
            auto enumBound = [&](const syntax::ExpressionSyntax* bsyn,
                                 int64_t val) -> UHDM::expr* {
                if (bsyn && bsyn->kind != syntax::SyntaxKind::IntegerLiteralExpression) {
                    if (pkgEnum9) {
                        auto* c9 = s.MakeConstant();
                        std::string d9 = std::to_string(val);
                        c9->VpiDecompile(d9);
                        c9->VpiSize(64);
                        c9->VpiValue("INT:" + d9);
                        c9->VpiConstType(vpiIntConst);
                        c9->VpiParent(r);
                        const syntax::SyntaxNode* anchor9 = bsyn;
                        if (auto* be9 =
                                bsyn->as_if<syntax::BinaryExpressionSyntax>())
                            anchor9 = be9->left;
                        setLoc(c9, anchor9->sourceRange());
                        return c9;
                    }
                    // A DEF-view PACKAGE enum base bound (logic [Width-1:0])
                    // keeps its param ref linked to the referenced package
                    // param's def-init constant (Surelog value-ref chaining) —
                    // activate the tf-type-scope resolver over the enum's home
                    // package so the ref binds instead of dangling.
                    const slang::ast::Scope* savedTfScope9 = tfTypeScope;
                    bool setTf9 = false;
                    if (!tfTypeScope && inPkgTypedefEmit &&
                        refFullName.find("::") != std::string::npos)
                        if (auto* esc9 = et.getParentScope()) {
                            tfTypeScope = esc9;
                            setTf9 = true;
                        }
                    auto* e = emitSyntaxExpr(*bsyn, r);
                    if (setTf9)
                        tfTypeScope = savedTfScope9;
                    if (e)
                        return (UHDM::expr*)e;
                }
                return makeBoundConst(bsyn, val, r);
            };
            r->Left_expr(enumBound(lsyn, range.left));
            r->Right_expr(enumBound(rsyn, range.right));
            auto* rv = s.MakeRangeVec();
            rv->push_back(r);
            if (bitBase9)
                ((UHDM::bit_typespec*)bts)->Ranges(rv);
            else
                ((UHDM::logic_typespec*)bts)->Ranges(rv);
        }
        auto* brt = s.MakeRef_typespec();
        brt->VpiFullName(refFullName);
        brt->VpiParent(ets);
        brt->Actual_typespec(bts);
        ets->Base_typespec(brt);
        }
    }
    else if (implicitBaseRef) {
        // An inline anonymous enum (enum {..} v) carries a bare base
        // ref_typespec (fullname only, no actual); the caller patches its
        // fullname to the variable's. Typedef anon-base enums omit it.
        auto* brt = s.MakeRef_typespec();
        brt->VpiFullName(refFullName);
        brt->VpiParent(ets);
        ets->Base_typespec(brt);
    }
    auto* consts = s.MakeEnum_constVec();
    for (auto& ev : et.values()) {
        auto* ec = s.MakeEnum_const();
        ec->VpiName(ev.name);
        ec->VpiParent(ets);
        if (auto syn = ev.getSyntax())
            setLoc(ec, syn->sourceRange());
        auto& cv = ev.getValue();
        std::string value;
        if (auto init = ev.getInitializer()) {
            auto& lit = stripImplicitConv(*init);
            if (lit.kind == ExpressionKind::IntegerLiteral) {
                std::string raw = rawText(lit.sourceRange);
                auto tick = raw.find('\'');
                if (tick != std::string::npos) {
                    // Based literal: literal encoding at the literal size.
                    // Surelog strips whitespace between the base char and
                    // the digits (3'h 0 -> 3'h0), shrinking the end loc
                    // (rsp_gen_minimal).
                    {
                        size_t bp9 = tick + 1;
                        if (bp9 < raw.size() &&
                            (raw[bp9] == 's' || raw[bp9] == 'S'))
                            bp9++;
                        size_t ws9 = 0;
                        while (bp9 + 1 + ws9 < raw.size() &&
                               (raw[bp9 + 1 + ws9] == ' ' ||
                                raw[bp9 + 1 + ws9] == '\t'))
                            ws9++;
                        if (ws9) {
                            raw.erase(bp9 + 1, ws9);
                            if (ec->VpiEndColumnNo() >
                                (int32_t)ws9)
                                ec->VpiEndColumnNo(ec->VpiEndColumnNo() -
                                                   (int32_t)ws9);
                        }
                    }
                    ec->VpiDecompile(raw);
                    ec->VpiSize((int32_t)lit.type->getBitWidth());
                    size_t basePos = tick + 1;
                    if (basePos < raw.size() && (raw[basePos] == 's' || raw[basePos] == 'S'))
                        basePos++;
                    char base = basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
                    std::string digits = raw.substr(basePos + 1);
                    switch (base) {
                        case 'b':
                            value = "BIN:" + digits;
                            break;
                        case 'h':
                            value = "HEX:" + digits;
                            break;
                        case 'o':
                            value = "OCT:" + digits;
                            break;
                        default:
                            // Based-decimal enum inits (3'd0) encode INT
                            // (MultirangesStartNotFromZero), not DEC.
                            value = "INT:" + digits;
                            break;
                    }
                }
                else {
                    // Bare decimal: 64-bit UINT.
                    ec->VpiDecompile(raw);
                    ec->VpiSize(64);
                    value = "UINT:" + raw;
                }
            }
        }
        if (value.empty() && cv.isInteger() && !cv.integer().hasUnknown()) {
            // A non-literal initializer (enum X = pkg::PARAM) keeps the SOURCE
            // reference as the decompile and follows the base signedness;
            // implicit/computed values decompile to the folded digits.
            std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
            auto* evInit = ev.getInitializer();
            bool nonLitInit = evInit && stripImplicitConv(*evInit).kind !=
                                            ExpressionKind::IntegerLiteral;
            // A COMPUTED init (concat/operation, not a plain ref) encodes BIN
            // at the base width: def decompile = source text w/o spaces, top
            // view = <w>'b<bits>.
            bool refInit = evInit && stripImplicitConv(*evInit).kind ==
                                         ExpressionKind::NamedValue;
            if (nonLitInit && !refInit && baseSyn) {
                int w = (int)et.baseType.getBitWidth();
                auto& ivv = cv.integer();
                std::string bits((size_t)w, '0');
                for (int bi = 0; bi < w; bi++)
                    if (ivv[bi].value == 1)
                        bits[(size_t)(w - 1 - bi)] = '1';
                ec->VpiValue("BIN:" + bits);
                std::string raw = rawText(stripImplicitConv(*evInit).sourceRange);
                raw.erase(std::remove_if(raw.begin(), raw.end(),
                                         [](unsigned char ch) { return std::isspace(ch); }),
                          raw.end());
                // The TOP-view package const leaves the decompile UNSET.
                if (!pkgTopEmit)
                    ec->VpiDecompile(raw);
                ec->VpiSize(w);
                consts->push_back(ec);
                if (!enumConstMap.count(&ev))
                    enumConstMap[&ev] = ec;
                continue;
            }
            // Only an explicit UNSIGNED INTEGER base (enum int unsigned {..})
            // encodes UINT; implicit / logic-vector / signed bases use INT.
            bool unsignedIntBase =
                baseSyn &&
                et.baseType.getCanonicalType().kind == SymbolKind::PredefinedIntegerType &&
                !et.baseType.isSigned();
            value = (unsignedIntBase ? "UINT:" : "INT:") + digits;
            // Non-literal init keeps the SOURCE reference as the decompile in
            // the def view; the top/elab view folds to digits.
            if (nonLitInit && !pkgTopEmit)
                ec->VpiDecompile(rawText(stripImplicitConv(*evInit).sourceRange));
            else
                ec->VpiDecompile(digits);
            ec->VpiSize(baseSyn ? (int32_t)et.baseType.getBitWidth() : 64);
        }
        if (!value.empty())
            ec->VpiValue(value);
        consts->push_back(ec);
        if (!enumConstMap.count(&ev))
            enumConstMap[&ev] = ec;
    }
    ets->Enum_consts(consts);
    return ets;
}

// Packed struct typespec: typespec_members with member-type Ref locations
// and alias-scoped ref fullnames.
UHDM::struct_typespec* UhdmExporter::buildStructTs(const Scope& structScope, bool packed,
                                                   const std::string& aliasName,
                                                   const std::string& memberSep) {
    auto* sts = s.MakeStruct_typespec();
    if (packed)
        sts->VpiPacked(true);
    // A MODULE-scope NAMED struct typedef keeps its members' packed-dim
    // OPERATION bounds symbolic in the elab view (Surelog); anonymous structs
    // (declared inline on a variable) and PACKAGE typedefs fold them. Named =
    // the struct's syntax sits inside a TypedefDeclaration; scope = no Package
    // ancestor.
    bool savedSymBound = structMemberSymBound;
    {
        bool namedTypedef = false;
        for (auto sn = structScope.asSymbol().getSyntax(); sn; sn = sn->parent)
            if (sn->kind == syntax::SyntaxKind::TypedefDeclaration) {
                namedTypedef = true;
                break;
            }
        bool inPkg = false;
        for (auto sc = structScope.asSymbol().getParentScope(); sc;
             sc = sc->asSymbol().getParentScope())
            if (sc->asSymbol().kind == SymbolKind::Package) {
                inPkg = true;
                break;
            }
        structMemberSymBound = namedTypedef && !inPkg;
    }
    auto* members = s.MakeTypespec_memberVec();
    for (auto& fm : structScope.members()) {
        if (fm.kind != SymbolKind::Field)
            continue;
        auto* tm = s.MakeTypespec_member();
        tm->VpiName(fm.name);
        tm->VpiParent(sts);
        setLoc(tm, nameSpan(fm.location, fm.name));
        // An UNPACKED-array member (foo_t f [7]) spans name..last dim
        // (Surelog).
        if (fm.getDeclaredType() &&
            fm.getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType)
            if (auto dsm9 = fm.getSyntax();
                dsm9 && dsm9->kind == syntax::SyntaxKind::Declarator) {
                auto& ddm9 = dsm9->as<syntax::DeclaratorSyntax>();
                if (!ddm9.dimensions.empty()) {
                    auto de9 = ddm9.dimensions[ddm9.dimensions.size() - 1]
                                   ->sourceRange()
                                   .end();
                    tm->VpiEndLineNo(sm->getLineNumber(de9));
                    tm->VpiEndColumnNo(sm->getColumnNumber(de9));
                }
            }
        // The canonical struct's fields may lose their type-syntax link;
        // recover it from the member declaration syntax.
        const syntax::SyntaxNode* memberTypeSyn = nullptr;
        for (auto p2 = fm.getSyntax(); p2; p2 = p2->parent) {
            if (p2->kind == syntax::SyntaxKind::StructUnionMember) {
                memberTypeSyn = p2->as<syntax::StructUnionMemberSyntax>().type;
                break;
            }
        }
        UHDM::typespec* fts = nullptr;
        // Unpacked-array member ats parent policy (see branch below):
        // MAIN (module-scoped) trees leave the ats/range/elem-ref/1-const
        // PARENT-FREE; BARE clone trees parent the ats at the member's ref.
        bool ats9MainFree = false;
        bool ats9CloneRefParent = false;
        if (fm.getDeclaredType() &&
            fm.getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType) {
            // Unpacked-array member (foo_t f [7]): a LOC-LESS array_typespec.
            // With a TYPEDEF'd element it carries the dim range ([0 : N-1 op]
            // at the size token) and an Elem ref to the shared element ts;
            // otherwise it stays bare (Surelog).
            auto* ats9 = s.MakeArray_typespec();
            bool main9 = aliasName.find('.') != std::string::npos ||
                         aliasName.find(':') != std::string::npos;
            ats9MainFree = main9;
            ats9CloneRefParent = !main9;
            auto& ua9 = fm.getDeclaredType()
                            ->getType()
                            .getCanonicalType()
                            .as<FixedSizeUnpackedArrayType>();
            UHDM::typespec* ets9 = nullptr;
            if (auto ei9 = typedefTs.find(&ua9.elementType);
                ei9 != typedefTs.end())
                ets9 = ei9->second;
            if (ets9) {
                const syntax::VariableDimensionSyntax* dim9 = nullptr;
                if (auto ds9 = fm.getSyntax();
                    ds9 && ds9->kind == syntax::SyntaxKind::Declarator) {
                    auto& dd9 = ds9->as<syntax::DeclaratorSyntax>();
                    if (!dd9.dimensions.empty())
                        dim9 = dd9.dimensions[0];
                }
                const syntax::ExpressionSyntax* sz9 = nullptr;
                if (dim9 && dim9->specifier &&
                    dim9->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier)
                    if (auto* bs9 =
                            dim9->specifier
                                ->as<syntax::RangeDimensionSpecifierSyntax>()
                                .selector->as_if<syntax::BitSelectSyntax>())
                        sz9 = bs9->expr;
                auto* r9 = s.MakeRange();
                if (!main9)
                    r9->VpiParent(ats9);
                if (sz9)
                    setLoc(r9, sz9->sourceRange());
                auto mk9 = [&](int64_t v,
                               const syntax::SyntaxNode* bs) -> UHDM::expr* {
                    auto* c = s.MakeConstant();
                    std::string d = std::to_string(v);
                    c->VpiDecompile(d);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + d);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiParent(r9);
                    if (bs)
                        setLoc(c, bs->sourceRange());
                    return c;
                };
                r9->Left_expr(mk9(0, nullptr));
                if (sz9) {
                    auto* op9 = s.MakeOperation();
                    op9->VpiOpType(vpiSubOp);
                    op9->VpiParent(r9);
                    setLoc(op9, sz9->sourceRange());
                    auto* ops9v = s.MakeAnyVec();
                    auto* n9c = mk9(ua9.range.width(), sz9);
                    n9c->VpiParent(op9);
                    ops9v->push_back(n9c);
                    auto* one9 = s.MakeConstant();
                    one9->VpiSize(64);
                    one9->VpiValue("INT:1");
                    one9->VpiConstType(vpiIntConst);
                    if (!main9)
                        one9->VpiParent(op9);
                    ops9v->push_back(one9);
                    op9->Operands(ops9v);
                    r9->Right_expr(op9);
                }
                else
                    r9->Right_expr(mk9(ua9.range.right, nullptr));
                auto* rv9 = s.MakeRangeVec();
                rv9->push_back(r9);
                ats9->Ranges(rv9);
                // The elem points at a fresh NAMED alias clone
                // (Typedef_alias -> the shared element ts) — Surelog.
                UHDM::typespec* tgt9 = ets9;
                if (ua9.elementType.kind == SymbolKind::TypeAlias &&
                    (ets9->UhdmType() == UHDM::uhdmbit_typespec ||
                     ets9->UhdmType() == UHDM::uhdmlogic_typespec)) {
                    auto* al9 = &ua9.elementType.as<TypeAliasType>();
                    const syntax::SyntaxNode* tsn9 = nullptr;
                    if (auto as9 = al9->getSyntax())
                        if (as9->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tsn9 = as9->as<syntax::TypedefDeclarationSyntax>()
                                       .type;
                    bypassTypedefShare = true;
                    auto* cl9e = makeTypespec(*al9, tsn9);
                    bypassTypedefShare = false;
                    cl9e->VpiName(al9->name);
                    auto* art9e = s.MakeRef_typespec();
                    // Alias-clone ref scopes through the member AND the
                    // type name (work@top.bar_t.f.foo_t) — Surelog.
                    art9e->VpiFullName(aliasName + memberSep +
                                       std::string(fm.name) + memberSep +
                                       std::string(al9->name));
                    art9e->VpiParent(cl9e);
                    art9e->Actual_typespec(ets9);
                    if (cl9e->UhdmType() == UHDM::uhdmbit_typespec)
                        ((UHDM::bit_typespec*)cl9e)->Typedef_alias(art9e);
                    else if (cl9e->UhdmType() == UHDM::uhdmlogic_typespec)
                        ((UHDM::logic_typespec*)cl9e)->Typedef_alias(art9e);
                    if (main9)
                        cl9e->VpiParent(tm);
                    else {
                        // BARE clone tree: two-level chain — the alias ref
                        // points at a SECOND named clone with located
                        // ranges (Surelog); cloneA parents at the elem ref
                        // (set below, after ert9 exists).
                        bypassTypedefShare = true;
                        auto* cl9b = makeTypespec(*al9, tsn9);
                        bypassTypedefShare = false;
                        cl9b->VpiName(al9->name);
                        cl9b->VpiParent(art9e);
                        art9e->Actual_typespec(cl9b);
                    }
                    tgt9 = cl9e;
                }
                auto* ert9 = s.MakeRef_typespec();
                // The MODULE-scoped (main) member's elem ref is NAMELESS;
                // a BARE-scoped clone tree names it alias.member (Surelog).
                if (aliasName.find('.') == std::string::npos &&
                    aliasName.find(':') == std::string::npos)
                    ert9->VpiFullName(aliasName + memberSep +
                                      std::string(fm.name));
                if (!main9)
                    ert9->VpiParent(ats9);
                ert9->Actual_typespec(tgt9);
                ats9->Elem_typespec(ert9);
                if (!main9 && tgt9 != ets9)
                    tgt9->VpiParent(ert9);
            }
            fts = ats9;
        }
        else {
            // Typedef-context member bound refs scope through the member
            // (pkg::pkg::T::m::PARAM). A module named typedef keeps its member
            // bounds symbolic in the elab view too, with the same member-scoped
            // ref name — so scope refs there as well.
            std::string savedPfx = syntaxRefPrefix, savedSep = syntaxRefSep;
            if ((tfContext || structMemberSymBound) && !aliasName.empty()) {
                syntaxRefPrefix = aliasName + memberSep + std::string(fm.name);
                syntaxRefSep = memberSep;
            }
            structMemberTsCtx = true;
            // A packed array over a VECTOR TYPEDEF member (logic4 [2:0] m)
            // needs makeTypespec's anonymous-logic-ts branch (Elem ref ->
            // typedef, array dim as range), which is tfContext-gated. A def-view
            // struct/union typespec is built with tfContext forced on; the dims
            // are literal, so clear it for this member.
            bool savedTf = tfContext;
            const TypeAliasType* vtaMem = nullptr;
            UHDM::typespec* vtaMemBase = nullptr;
            const TypeAliasType* btaMem = nullptr;
            UHDM::typespec* btaMemBase = nullptr;
            if (fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind ==
                    SymbolKind::PackedArrayType) {
                auto& etm = fm.getDeclaredType()
                                ->getType()
                                .as<PackedArrayType>()
                                .elementType;
                if (etm.kind == SymbolKind::TypeAlias) {
                    if (auto titm = typedefTs.find(&etm);
                        titm != typedefTs.end() &&
                        titm->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                        tfContext = false;
                        vtaMem = &etm.as<TypeAliasType>();
                        vtaMemBase = titm->second;
                    }
                    else if (titm != typedefTs.end() &&
                             titm->second->UhdmType() ==
                                 UHDM::uhdmbit_typespec) {
                        btaMem = &etm.as<TypeAliasType>();
                        btaMemBase = titm->second;
                    }
                }
            }
            // A packed array over a BIT TYPEDEF member (bit8_t [3:0] a):
            // packed_array_typespec with the array dim + Elem ref to a fresh
            // NAMED bit clone (Typedef_alias -> shared base) — Surelog.
            if (btaMem && btaMemBase) {
                auto* pat9 = s.MakePacked_array_typespec();
                if (memberTypeSyn)
                    setLoc(pat9, memberTypeSyn->sourceRange());
                auto& par9 =
                    fm.getDeclaredType()->getType().as<PackedArrayType>();
                std::vector<DimSpan> spans9;
                if (memberTypeSyn) {
                    auto full9 = memberTypeSyn->sourceRange();
                    spans9 = scanDimSpans(std::string(rawText(full9)),
                                          full9.start());
                }
                auto* r9 = s.MakeRange();
                r9->VpiParent(pat9);
                const DimSpan* ds9 =
                    spans9.empty() ? nullptr : &spans9[0];
                if (ds9)
                    setLoc(r9, ds9->range);
                auto mkB9 = [&](int64_t v9,
                                const SourceRange* lc9) -> UHDM::expr* {
                    auto* c9 = s.MakeConstant();
                    std::string d9 = std::to_string(v9);
                    c9->VpiDecompile(d9);
                    c9->VpiSize(64);
                    c9->VpiValue("UINT:" + d9);
                    c9->VpiConstType(vpiUIntConst);
                    c9->VpiParent(r9);
                    if (lc9)
                        setLoc(c9, *lc9);
                    return c9;
                };
                r9->Left_expr(mkB9(par9.range.left, ds9 ? &ds9->left : nullptr));
                r9->Right_expr(
                    mkB9(par9.range.right, ds9 ? &ds9->right : nullptr));
                auto* rv9 = s.MakeRangeVec();
                rv9->push_back(r9);
                pat9->Ranges(rv9);
                const syntax::SyntaxNode* tgtSyn9 = nullptr;
                if (auto asyn9 = btaMem->getSyntax())
                    if (asyn9->kind ==
                        syntax::SyntaxKind::TypedefDeclaration)
                        tgtSyn9 =
                            asyn9->as<syntax::TypedefDeclarationSyntax>().type;
                bypassTypedefShare = true;
                auto* cl9 = makeTypespec(*btaMem, tgtSyn9);
                bypassTypedefShare = false;
                cl9->VpiName(btaMem->name);
                auto* art9 = s.MakeRef_typespec();
                art9->VpiFullName(std::string(btaMem->name));
                art9->VpiParent(cl9);
                art9->Actual_typespec(btaMemBase);
                if (cl9->UhdmType() == UHDM::uhdmbit_typespec)
                    ((UHDM::bit_typespec*)cl9)->Typedef_alias(art9);
                else if (cl9->UhdmType() == UHDM::uhdmlogic_typespec)
                    ((UHDM::logic_typespec*)cl9)->Typedef_alias(art9);
                if (savedTf)
                    cl9->Instance(btaMemBase->Instance());
                auto* ert9 = s.MakeRef_typespec();
                ert9->VpiFullName(aliasName + memberSep +
                                  std::string(fm.name));
                ert9->VpiParent(pat9);
                ert9->Actual_typespec(cl9);
                pat9->Elem_typespec(ert9);
                fts = pat9;
            }
            // A DIRECT vector-typedef member (reg_addr_t rs1;): Surelog gives
            // the member its own NAMED alias clone (parent = the member,
            // Typedef_alias -> the shared typedef ts, own range copy) instead
            // of pointing at the shared ts.
            if (!fts && fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind == SymbolKind::TypeAlias) {
                auto& amt = fm.getDeclaredType()->getType();
                if (auto tita = typedefTs.find(&amt);
                    tita != typedefTs.end() &&
                    tita->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                    auto* dta = &amt.as<TypeAliasType>();
                    const syntax::SyntaxNode* tgtSynD = nullptr;
                    if (auto asynD = dta->getSyntax())
                        if (asynD->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tgtSynD =
                                asynD->as<syntax::TypedefDeclarationSyntax>()
                                    .type;
                    bypassTypedefShare = true;
                    auto* clD = makeTypespec(*dta, tgtSynD);
                    bypassTypedefShare = false;
                    clD->VpiName(dta->name);
                    clD->VpiParent(tm);
                    auto* artD = s.MakeRef_typespec();
                    artD->VpiFullName(aliasName + memberSep +
                                      std::string(fm.name) + memberSep +
                                      std::string(dta->name));
                    artD->VpiParent(clD);
                    artD->Actual_typespec(tita->second);
                    if (clD->UhdmType() == UHDM::uhdmlogic_typespec)
                        ((UHDM::logic_typespec*)clD)->Typedef_alias(artD);
                    fts = clD;
                }
            }
            if (!fts)
                fts = makeTypespec(fm, memberTypeSyn);
            // A nested ANONYMOUS struct member's struct_typespec is located at
            // the `struct` keyword span (Surelog); makeTypespec leaves it
            // loc-less for the anonymous form.
            if (fts && fts->UhdmType() == UHDM::uhdmstruct_typespec &&
                fts->VpiLineNo() == 0 && memberTypeSyn)
                setLoc(fts, memberTypeSyn->getFirstToken().range());
            tfContext = savedTf;
            // Surelog points the member's Elem ref at a fresh NAMED alias-clone
            // (Typedef_alias -> shared base, Instance = module) rather than the
            // bare base the anonymous-ts branch bound.
            if (vtaMem && vtaMemBase &&
                fts->UhdmType() == UHDM::uhdmlogic_typespec) {
                if (auto* et = ((UHDM::logic_typespec*)fts)->Elem_typespec()) {
                    const syntax::SyntaxNode* tgtSyn = nullptr;
                    if (auto asyn = vtaMem->getSyntax())
                        if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tgtSyn = asyn->as<syntax::TypedefDeclarationSyntax>()
                                         .type;
                    bypassTypedefShare = true;
                    auto* cl = makeTypespec(*vtaMem, tgtSyn);
                    bypassTypedefShare = false;
                    cl->VpiName(vtaMem->name);
                    auto* art = s.MakeRef_typespec();
                    art->VpiFullName(std::string(vtaMem->name));
                    art->VpiParent(cl);
                    art->Actual_typespec(vtaMemBase);
                    ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
                    // Only the DEF-view clone (tfContext build) carries
                    // Instance; the elab-view clone leaves it null (Surelog).
                    if (savedTf)
                        cl->Instance(vtaMemBase->Instance());
                    et->Actual_typespec(cl);
                }
            }
            structMemberTsCtx = false;
            syntaxRefPrefix = savedPfx;
            syntaxRefSep = savedSep;
        }
        // Fresh member typespecs parent at the member; shared typedef
        // typespecs (named) keep their own parent. Elab param CLONES parent
        // them at the member's REF instead (Surelog clone form).
        if (fts->VpiName().empty() && !ats9MainFree)
            fts->VpiParent(tm);
        auto* rt = s.MakeRef_typespec();
        // ANONYMOUS structs (empty alias) name member refs bare, no
        // leading separator (struct_3d_packed_array).
        rt->VpiFullName(aliasName.empty()
                            ? std::string(fm.name)
                            : aliasName + memberSep + std::string(fm.name));
        rt->VpiParent(tm);
        rt->Actual_typespec(fts);
        tm->Typespec(rt);
        if ((structCloneMemberRefParent || ats9CloneRefParent) &&
            fts->VpiName().empty())
            fts->VpiParent(rt);
        // Ref* fields point at the member's type syntax.
        if (memberTypeSyn) {
            auto sr = memberTypeSyn->sourceRange();
            if (sr.start() != SourceLocation::NoLocation) {
                tm->VpiRefFile(fullFilePath(sr.start()));
                tm->VpiRefLineNo(sm->getLineNumber(sr.start()));
                tm->VpiRefColumnNo(sm->getColumnNumber(sr.start()));
                tm->VpiRefEndLineNo(sm->getLineNumber(sr.end()));
                tm->VpiRefEndColumnNo(sm->getColumnNumber(sr.end()));
            }
        }
        members->push_back(tm);
    }
    structMemberSymBound = savedSymBound;
    sts->Members(members);
    return sts;
}


UHDM::union_typespec* UhdmExporter::buildUnionTs(const Scope& unionScope, bool packed,
                                                 const std::string& aliasName,
                                                 const std::string& memberSep) {
    auto* uts = s.MakeUnion_typespec();
    if (packed)
        uts->VpiPacked(true);
    auto* members = s.MakeTypespec_memberVec();
    for (auto& fm : unionScope.members()) {
        if (fm.kind != SymbolKind::Field)
            continue;
        auto* tm = s.MakeTypespec_member();
        tm->VpiName(fm.name);
        tm->VpiParent(uts);
        setLoc(tm, nameSpan(fm.location, fm.name));
        // An UNPACKED-array member (foo_t f [7]) spans name..last dim
        // (Surelog).
        if (fm.getDeclaredType() &&
            fm.getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType)
            if (auto dsm9 = fm.getSyntax();
                dsm9 && dsm9->kind == syntax::SyntaxKind::Declarator) {
                auto& ddm9 = dsm9->as<syntax::DeclaratorSyntax>();
                if (!ddm9.dimensions.empty()) {
                    auto de9 = ddm9.dimensions[ddm9.dimensions.size() - 1]
                                   ->sourceRange()
                                   .end();
                    tm->VpiEndLineNo(sm->getLineNumber(de9));
                    tm->VpiEndColumnNo(sm->getColumnNumber(de9));
                }
            }
        const syntax::SyntaxNode* memberTypeSyn = nullptr;
        for (auto p2 = fm.getSyntax(); p2; p2 = p2->parent) {
            if (p2->kind == syntax::SyntaxKind::StructUnionMember) {
                memberTypeSyn = p2->as<syntax::StructUnionMemberSyntax>().type;
                break;
            }
        }
        UHDM::typespec* fts = nullptr;
        // Unpacked-array member ats parent policy (see branch below):
        // MAIN (module-scoped) trees leave the ats/range/elem-ref/1-const
        // PARENT-FREE; BARE clone trees parent the ats at the member's ref.
        bool ats9MainFree = false;
        bool ats9CloneRefParent = false;
        if (fm.getDeclaredType() &&
            fm.getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType) {
            // Unpacked-array member (foo_t f [7]): a LOC-LESS array_typespec.
            // With a TYPEDEF'd element it carries the dim range ([0 : N-1 op]
            // at the size token) and an Elem ref to the shared element ts;
            // otherwise it stays bare (Surelog).
            auto* ats9 = s.MakeArray_typespec();
            bool main9 = aliasName.find('.') != std::string::npos ||
                         aliasName.find(':') != std::string::npos;
            ats9MainFree = main9;
            ats9CloneRefParent = !main9;
            auto& ua9 = fm.getDeclaredType()
                            ->getType()
                            .getCanonicalType()
                            .as<FixedSizeUnpackedArrayType>();
            UHDM::typespec* ets9 = nullptr;
            if (auto ei9 = typedefTs.find(&ua9.elementType);
                ei9 != typedefTs.end())
                ets9 = ei9->second;
            if (ets9) {
                const syntax::VariableDimensionSyntax* dim9 = nullptr;
                if (auto ds9 = fm.getSyntax();
                    ds9 && ds9->kind == syntax::SyntaxKind::Declarator) {
                    auto& dd9 = ds9->as<syntax::DeclaratorSyntax>();
                    if (!dd9.dimensions.empty())
                        dim9 = dd9.dimensions[0];
                }
                const syntax::ExpressionSyntax* sz9 = nullptr;
                if (dim9 && dim9->specifier &&
                    dim9->specifier->kind ==
                        syntax::SyntaxKind::RangeDimensionSpecifier)
                    if (auto* bs9 =
                            dim9->specifier
                                ->as<syntax::RangeDimensionSpecifierSyntax>()
                                .selector->as_if<syntax::BitSelectSyntax>())
                        sz9 = bs9->expr;
                auto* r9 = s.MakeRange();
                if (!main9)
                    r9->VpiParent(ats9);
                if (sz9)
                    setLoc(r9, sz9->sourceRange());
                auto mk9 = [&](int64_t v,
                               const syntax::SyntaxNode* bs) -> UHDM::expr* {
                    auto* c = s.MakeConstant();
                    std::string d = std::to_string(v);
                    c->VpiDecompile(d);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + d);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiParent(r9);
                    if (bs)
                        setLoc(c, bs->sourceRange());
                    return c;
                };
                r9->Left_expr(mk9(0, nullptr));
                if (sz9) {
                    auto* op9 = s.MakeOperation();
                    op9->VpiOpType(vpiSubOp);
                    op9->VpiParent(r9);
                    setLoc(op9, sz9->sourceRange());
                    auto* ops9v = s.MakeAnyVec();
                    auto* n9c = mk9(ua9.range.width(), sz9);
                    n9c->VpiParent(op9);
                    ops9v->push_back(n9c);
                    auto* one9 = s.MakeConstant();
                    one9->VpiSize(64);
                    one9->VpiValue("INT:1");
                    one9->VpiConstType(vpiIntConst);
                    if (!main9)
                        one9->VpiParent(op9);
                    ops9v->push_back(one9);
                    op9->Operands(ops9v);
                    r9->Right_expr(op9);
                }
                else
                    r9->Right_expr(mk9(ua9.range.right, nullptr));
                auto* rv9 = s.MakeRangeVec();
                rv9->push_back(r9);
                ats9->Ranges(rv9);
                // The elem points at a fresh NAMED alias clone
                // (Typedef_alias -> the shared element ts) — Surelog.
                UHDM::typespec* tgt9 = ets9;
                if (ua9.elementType.kind == SymbolKind::TypeAlias &&
                    (ets9->UhdmType() == UHDM::uhdmbit_typespec ||
                     ets9->UhdmType() == UHDM::uhdmlogic_typespec)) {
                    auto* al9 = &ua9.elementType.as<TypeAliasType>();
                    const syntax::SyntaxNode* tsn9 = nullptr;
                    if (auto as9 = al9->getSyntax())
                        if (as9->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tsn9 = as9->as<syntax::TypedefDeclarationSyntax>()
                                       .type;
                    bypassTypedefShare = true;
                    auto* cl9e = makeTypespec(*al9, tsn9);
                    bypassTypedefShare = false;
                    cl9e->VpiName(al9->name);
                    auto* art9e = s.MakeRef_typespec();
                    // Alias-clone ref scopes through the member AND the
                    // type name (work@top.bar_t.f.foo_t) — Surelog.
                    art9e->VpiFullName(aliasName + memberSep +
                                       std::string(fm.name) + memberSep +
                                       std::string(al9->name));
                    art9e->VpiParent(cl9e);
                    art9e->Actual_typespec(ets9);
                    if (cl9e->UhdmType() == UHDM::uhdmbit_typespec)
                        ((UHDM::bit_typespec*)cl9e)->Typedef_alias(art9e);
                    else if (cl9e->UhdmType() == UHDM::uhdmlogic_typespec)
                        ((UHDM::logic_typespec*)cl9e)->Typedef_alias(art9e);
                    if (main9)
                        cl9e->VpiParent(tm);
                    else {
                        // BARE clone tree: two-level chain — the alias ref
                        // points at a SECOND named clone with located
                        // ranges (Surelog); cloneA parents at the elem ref
                        // (set below, after ert9 exists).
                        bypassTypedefShare = true;
                        auto* cl9b = makeTypespec(*al9, tsn9);
                        bypassTypedefShare = false;
                        cl9b->VpiName(al9->name);
                        cl9b->VpiParent(art9e);
                        art9e->Actual_typespec(cl9b);
                    }
                    tgt9 = cl9e;
                }
                auto* ert9 = s.MakeRef_typespec();
                // The MODULE-scoped (main) member's elem ref is NAMELESS;
                // a BARE-scoped clone tree names it alias.member (Surelog).
                if (aliasName.find('.') == std::string::npos &&
                    aliasName.find(':') == std::string::npos)
                    ert9->VpiFullName(aliasName + memberSep +
                                      std::string(fm.name));
                if (!main9)
                    ert9->VpiParent(ats9);
                ert9->Actual_typespec(tgt9);
                ats9->Elem_typespec(ert9);
                if (!main9 && tgt9 != ets9)
                    tgt9->VpiParent(ert9);
            }
            fts = ats9;
        }
        else {
            // Typedef-context member bound refs scope through the member
            // (pkg::pkg::T::m::PARAM). A module named typedef keeps its member
            // bounds symbolic in the elab view too, with the same member-scoped
            // ref name — so scope refs there as well.
            std::string savedPfx = syntaxRefPrefix, savedSep = syntaxRefSep;
            if ((tfContext || structMemberSymBound) && !aliasName.empty()) {
                syntaxRefPrefix = aliasName + memberSep + std::string(fm.name);
                syntaxRefSep = memberSep;
            }
            structMemberTsCtx = true;
            // A packed array over a VECTOR TYPEDEF member (logic4 [2:0] m)
            // needs makeTypespec's anonymous-logic-ts branch (Elem ref ->
            // typedef, array dim as range), which is tfContext-gated. A def-view
            // struct/union typespec is built with tfContext forced on; the dims
            // are literal, so clear it for this member.
            bool savedTf = tfContext;
            const TypeAliasType* vtaMem = nullptr;
            UHDM::typespec* vtaMemBase = nullptr;
            const TypeAliasType* btaMem = nullptr;
            UHDM::typespec* btaMemBase = nullptr;
            if (fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind ==
                    SymbolKind::PackedArrayType) {
                auto& etm = fm.getDeclaredType()
                                ->getType()
                                .as<PackedArrayType>()
                                .elementType;
                if (etm.kind == SymbolKind::TypeAlias) {
                    if (auto titm = typedefTs.find(&etm);
                        titm != typedefTs.end() &&
                        titm->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                        tfContext = false;
                        vtaMem = &etm.as<TypeAliasType>();
                        vtaMemBase = titm->second;
                    }
                    else if (titm != typedefTs.end() &&
                             titm->second->UhdmType() ==
                                 UHDM::uhdmbit_typespec) {
                        btaMem = &etm.as<TypeAliasType>();
                        btaMemBase = titm->second;
                    }
                }
            }
            // A packed array over a BIT TYPEDEF member (bit8_t [3:0] a):
            // packed_array_typespec with the array dim + Elem ref to a fresh
            // NAMED bit clone (Typedef_alias -> shared base) — Surelog.
            if (btaMem && btaMemBase) {
                auto* pat9 = s.MakePacked_array_typespec();
                if (memberTypeSyn)
                    setLoc(pat9, memberTypeSyn->sourceRange());
                auto& par9 =
                    fm.getDeclaredType()->getType().as<PackedArrayType>();
                std::vector<DimSpan> spans9;
                if (memberTypeSyn) {
                    auto full9 = memberTypeSyn->sourceRange();
                    spans9 = scanDimSpans(std::string(rawText(full9)),
                                          full9.start());
                }
                auto* r9 = s.MakeRange();
                r9->VpiParent(pat9);
                const DimSpan* ds9 =
                    spans9.empty() ? nullptr : &spans9[0];
                if (ds9)
                    setLoc(r9, ds9->range);
                auto mkB9 = [&](int64_t v9,
                                const SourceRange* lc9) -> UHDM::expr* {
                    auto* c9 = s.MakeConstant();
                    std::string d9 = std::to_string(v9);
                    c9->VpiDecompile(d9);
                    c9->VpiSize(64);
                    c9->VpiValue("UINT:" + d9);
                    c9->VpiConstType(vpiUIntConst);
                    c9->VpiParent(r9);
                    if (lc9)
                        setLoc(c9, *lc9);
                    return c9;
                };
                r9->Left_expr(mkB9(par9.range.left, ds9 ? &ds9->left : nullptr));
                r9->Right_expr(
                    mkB9(par9.range.right, ds9 ? &ds9->right : nullptr));
                auto* rv9 = s.MakeRangeVec();
                rv9->push_back(r9);
                pat9->Ranges(rv9);
                const syntax::SyntaxNode* tgtSyn9 = nullptr;
                if (auto asyn9 = btaMem->getSyntax())
                    if (asyn9->kind ==
                        syntax::SyntaxKind::TypedefDeclaration)
                        tgtSyn9 =
                            asyn9->as<syntax::TypedefDeclarationSyntax>().type;
                bypassTypedefShare = true;
                auto* cl9 = makeTypespec(*btaMem, tgtSyn9);
                bypassTypedefShare = false;
                cl9->VpiName(btaMem->name);
                auto* art9 = s.MakeRef_typespec();
                art9->VpiFullName(std::string(btaMem->name));
                art9->VpiParent(cl9);
                art9->Actual_typespec(btaMemBase);
                if (cl9->UhdmType() == UHDM::uhdmbit_typespec)
                    ((UHDM::bit_typespec*)cl9)->Typedef_alias(art9);
                else if (cl9->UhdmType() == UHDM::uhdmlogic_typespec)
                    ((UHDM::logic_typespec*)cl9)->Typedef_alias(art9);
                if (savedTf)
                    cl9->Instance(btaMemBase->Instance());
                auto* ert9 = s.MakeRef_typespec();
                ert9->VpiFullName(aliasName + memberSep +
                                  std::string(fm.name));
                ert9->VpiParent(pat9);
                ert9->Actual_typespec(cl9);
                pat9->Elem_typespec(ert9);
                fts = pat9;
            }
            // A DIRECT vector-typedef member (reg_addr_t rs1;): Surelog gives
            // the member its own NAMED alias clone (parent = the member,
            // Typedef_alias -> the shared typedef ts, own range copy) instead
            // of pointing at the shared ts.
            if (!fts && fm.getDeclaredType() &&
                fm.getDeclaredType()->getType().kind == SymbolKind::TypeAlias) {
                auto& amt = fm.getDeclaredType()->getType();
                if (auto tita = typedefTs.find(&amt);
                    tita != typedefTs.end() &&
                    tita->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                    auto* dta = &amt.as<TypeAliasType>();
                    const syntax::SyntaxNode* tgtSynD = nullptr;
                    if (auto asynD = dta->getSyntax())
                        if (asynD->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tgtSynD =
                                asynD->as<syntax::TypedefDeclarationSyntax>()
                                    .type;
                    bypassTypedefShare = true;
                    auto* clD = makeTypespec(*dta, tgtSynD);
                    bypassTypedefShare = false;
                    clD->VpiName(dta->name);
                    clD->VpiParent(tm);
                    auto* artD = s.MakeRef_typespec();
                    artD->VpiFullName(aliasName + memberSep +
                                      std::string(fm.name) + memberSep +
                                      std::string(dta->name));
                    artD->VpiParent(clD);
                    artD->Actual_typespec(tita->second);
                    if (clD->UhdmType() == UHDM::uhdmlogic_typespec)
                        ((UHDM::logic_typespec*)clD)->Typedef_alias(artD);
                    fts = clD;
                }
            }
            if (!fts)
                fts = makeTypespec(fm, memberTypeSyn);
            // A nested ANONYMOUS struct member's struct_typespec is located at
            // the `struct` keyword span (Surelog); makeTypespec leaves it
            // loc-less for the anonymous form.
            if (fts && fts->UhdmType() == UHDM::uhdmstruct_typespec &&
                fts->VpiLineNo() == 0 && memberTypeSyn)
                setLoc(fts, memberTypeSyn->getFirstToken().range());
            tfContext = savedTf;
            // Surelog points the member's Elem ref at a fresh NAMED alias-clone
            // (Typedef_alias -> shared base, Instance = module) rather than the
            // bare base the anonymous-ts branch bound.
            if (vtaMem && vtaMemBase &&
                fts->UhdmType() == UHDM::uhdmlogic_typespec) {
                if (auto* et = ((UHDM::logic_typespec*)fts)->Elem_typespec()) {
                    const syntax::SyntaxNode* tgtSyn = nullptr;
                    if (auto asyn = vtaMem->getSyntax())
                        if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                            tgtSyn = asyn->as<syntax::TypedefDeclarationSyntax>()
                                         .type;
                    bypassTypedefShare = true;
                    auto* cl = makeTypespec(*vtaMem, tgtSyn);
                    bypassTypedefShare = false;
                    cl->VpiName(vtaMem->name);
                    auto* art = s.MakeRef_typespec();
                    art->VpiFullName(std::string(vtaMem->name));
                    art->VpiParent(cl);
                    art->Actual_typespec(vtaMemBase);
                    ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
                    // Only the DEF-view clone (tfContext build) carries
                    // Instance; the elab-view clone leaves it null (Surelog).
                    if (savedTf)
                        cl->Instance(vtaMemBase->Instance());
                    et->Actual_typespec(cl);
                }
            }
            structMemberTsCtx = false;
            syntaxRefPrefix = savedPfx;
            syntaxRefSep = savedSep;
        }
        if (fts->VpiName().empty() && !ats9MainFree)
            fts->VpiParent(tm);
        auto* rt = s.MakeRef_typespec();
        // ANONYMOUS structs (empty alias) name member refs bare, no
        // leading separator (struct_3d_packed_array).
        rt->VpiFullName(aliasName.empty()
                            ? std::string(fm.name)
                            : aliasName + memberSep + std::string(fm.name));
        rt->VpiParent(tm);
        rt->Actual_typespec(fts);
        tm->Typespec(rt);
        if (ats9CloneRefParent && fts->VpiName().empty())
            fts->VpiParent(rt);
        if (memberTypeSyn) {
            auto sr = memberTypeSyn->sourceRange();
            if (sr.start() != SourceLocation::NoLocation) {
                tm->VpiRefFile(fullFilePath(sr.start()));
                tm->VpiRefLineNo(sm->getLineNumber(sr.start()));
                tm->VpiRefColumnNo(sm->getColumnNumber(sr.start()));
                tm->VpiRefEndLineNo(sm->getLineNumber(sr.end()));
                tm->VpiRefEndColumnNo(sm->getColumnNumber(sr.end()));
            }
        }
        members->push_back(tm);
    }
    uts->Members(members);
    return uts;
}

// Typedefs (enums, packed structs): module Typespecs entries compiled at
// module compile, shared by both views and by all declarations.
void UhdmExporter::emitTypedefs(const InstanceBodySymbol& body, UHDM::instance* m,
                                const std::string& prefix, DefInfo& info) {
    auto* tds = s.MakeTypespecVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::TypeAlias)
            continue;
        auto& ta = member.as<TypeAliasType>();
        auto& ct = ta.targetType.getType().getCanonicalType();
        const syntax::SyntaxNode* typeSyn = nullptr;
        if (auto syn = ta.getSyntax()) {
            if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
                typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
        }
        UHDM::typespec* ts = nullptr;
        if (ct.kind == SymbolKind::EnumType) {
            auto* ets = buildEnumTs(ct.as<EnumType>(), typeSyn,
                                    prefix + "." + std::string(ta.name));
            ets->VpiParent(m);
            if (auto syn = ta.getSyntax())
                setLoc(ets, syn->sourceRange());
            ts = ets;
        }
        else if (ct.kind == SymbolKind::PackedStructType) {
            // A struct whose variable is assigned WHOLE — cont-assigned
            // (assign c = ... / assign b = c) or declared with an initializer
            // (hw2reg_wrap_t w = {c, d}) — is netlist-recompiled: BARE member
            // refs, no module parent. Member-only or $bits-only uses keep the
            // module-prefixed refs + module parent (alert_rx_t / dmi_t /
            // EnumWidth's bar_t), regardless of nested typedef members.
            bool wholeAssigned = false;
            for (auto& mb2 : body.members()) {
                if (mb2.kind != SymbolKind::ContinuousAssign)
                    continue;
                auto& as2 = mb2.as<ContinuousAssignSymbol>().getAssignment();
                if (as2.kind != ExpressionKind::Assignment)
                    continue;
                auto& ae2 = as2.as<AssignmentExpression>();
                for (auto* side : {&ae2.left(), &ae2.right()}) {
                    auto& sc2 = stripImplicitConv(*side);
                    if (sc2.kind == ExpressionKind::NamedValue &&
                        &sc2.as<NamedValueExpression>()
                                .symbol.getType()
                                .getCanonicalType() == &ct)
                        wholeAssigned = true;
                }
            }
            bool bareRefs = wholeAssigned;
            // The def-net typespec drop applies only to structs with NO
            // nested UNION member (UnionInsideStruct's bar_t keeps its ts).
            bool hasUnionMember = false;
            for (auto& fm : ct.as<PackedStructType>().members()) {
                if (fm.kind != SymbolKind::Field)
                    continue;
                if (fm.as<FieldSymbol>().getType().getCanonicalType().kind ==
                    SymbolKind::PackedUnionType)
                    hasUnionMember = true;
            }
            if (!bareRefs && !hasUnionMember)
                modulePrefixedStructs.insert(&ct);
            std::string alias = bareRefs ? std::string(ta.name)
                                         : prefix + "." + std::string(ta.name);
            auto* sts = buildStructTs(ct.as<PackedStructType>(), true, alias);
            if (!bareRefs)
                sts->VpiParent(m);
            if (typeSyn)
                setLoc(sts, typeSyn->sourceRange());
            ts = sts;
        }
        else if (ct.kind == SymbolKind::UnpackedStructType) {
            // Unpacked structs: module parent + module-scoped member refs.
            auto* sts = buildStructTs(ct.as<UnpackedStructType>(), false,
                                      prefix + "." + std::string(ta.name));
            sts->VpiParent(m);
            if (typeSyn)
                setLoc(sts, typeSyn->sourceRange());
            ts = sts;
        }
        else if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType) {
            // typedef of an unpacked array (typedef bar_t foobar_t [2]):
            // a NAMED array_typespec spanning target-type..last-dim; a
            // SIZE-form dim ([2]) folds to [0 : N-1 op] at the size token,
            // a ranged dim keeps its bounds at their tokens (Surelog —
            // mirrors the pkg-typedef form).
            auto* ats = s.MakeArray_typespec();
            ats->VpiParent(m);
            auto& fua = ct.as<FixedSizeUnpackedArrayType>();
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
                // Size form: range at the size token, [0 : N-1 op] (the op
                // located at the size token; the 1 is a loc-less INT).
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
            // Elem ref -> the ELEMENT typedef's shared ts (typedef bar_t
            // foobar_t [2] points at bar_t's struct ts) — Surelog.
            {
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
                    // A STRUCT element points at a fresh NAMED clone with a
                    // BARE-scoped member tree and a Typedef_alias ref to the
                    // shared ts (Surelog); other elements share directly.
                    UHDM::typespec* tgt0 = ets0;
                    if (el0->kind == SymbolKind::TypeAlias &&
                        el0->getCanonicalType().isStruct() &&
                        ets0->UhdmType() == UHDM::uhdmstruct_typespec) {
                        auto& ela = el0->as<TypeAliasType>();
                        auto& elc = el0->getCanonicalType();
                        UHDM::struct_typespec* cl0 =
                            elc.kind == SymbolKind::PackedStructType
                                ? buildStructTs(elc.as<PackedStructType>(),
                                                true, std::string(ela.name))
                                : buildStructTs(elc.as<UnpackedStructType>(),
                                                false, std::string(ela.name));
                        cl0->VpiName(ela.name);
                        cl0->VpiLineNo(ets0->VpiLineNo());
                        cl0->VpiColumnNo(ets0->VpiColumnNo());
                        cl0->VpiEndLineNo(ets0->VpiEndLineNo());
                        cl0->VpiEndColumnNo(ets0->VpiEndColumnNo());
                        auto* art0 = s.MakeRef_typespec();
                        art0->VpiFullName(std::string(ela.name));
                        art0->VpiParent(cl0);
                        art0->Actual_typespec(ets0);
                        cl0->Typedef_alias(art0);
                        tgt0 = cl0;
                    }
                    auto* ert = s.MakeRef_typespec();
                    ert->VpiFullName(prefix + "." + std::string(ta.name));
                    ert->VpiParent(ats);
                    ert->Actual_typespec(tgt0);
                    ats->Elem_typespec(ert);
                }
            }
            ts = ats;
        }
        else if (ct.kind == SymbolKind::PackedUnionType) {
            // Packed unions mirror packed structs: WHOLE-assigned unions keep
            // BARE member refs; member-only uses take module-prefixed refs.
            bool uWhole = false;
            for (auto& mb2 : body.members()) {
                if (mb2.kind != SymbolKind::ContinuousAssign)
                    continue;
                auto& as2 = mb2.as<ContinuousAssignSymbol>().getAssignment();
                if (as2.kind != ExpressionKind::Assignment)
                    continue;
                auto& ae2 = as2.as<AssignmentExpression>();
                for (auto* side : {&ae2.left(), &ae2.right()}) {
                    auto& sc2 = stripImplicitConv(*side);
                    if (sc2.kind == ExpressionKind::NamedValue &&
                        &sc2.as<NamedValueExpression>()
                                .symbol.getType()
                                .getCanonicalType() == &ct)
                        uWhole = true;
                }
            }
            auto* uts = buildUnionTs(ct.as<PackedUnionType>(), true,
                                     uWhole ? std::string(ta.name)
                                            : prefix + "." + std::string(ta.name));
            uts->VpiParent(m);
            if (typeSyn)
                setLoc(uts, typeSyn->sourceRange());
            ts = uts;
        }
        else if (ct.kind == SymbolKind::PackedArrayType &&
                 [&] {
                     const Type* lf = &ct;
                     while (lf->getCanonicalType().kind == SymbolKind::PackedArrayType)
                         lf = &lf->getCanonicalType().as<PackedArrayType>().elementType;
                     return lf->getCanonicalType().kind == SymbolKind::PackedStructType ||
                            lf->getCanonicalType().kind == SymbolKind::EnumType;
                 }()) {
            // A packed array over a packed struct (struct packed {...} [31:0]
            // T) or an ENUM (typedef u[0:1] crash): a NAMED packed_array_typespec
            // whose Elem_typespec is a fresh struct_typespec / enum_typespec.
            std::string alias = prefix + "." + std::string(ta.name);
            const Type* leaf = &ct;
            int arrDims = 0;
            while (leaf->getCanonicalType().kind == SymbolKind::PackedArrayType) {
                arrDims++;
                leaf = &leaf->getCanonicalType().as<PackedArrayType>().elementType;
            }
            bool enumLeaf =
                leaf->getCanonicalType().kind == SymbolKind::EnumType;
            std::string ename =
                leaf->kind == SymbolKind::TypeAlias ? std::string(leaf->name) : "";
            const syntax::SyntaxNode* esyn = leaf->getCanonicalType().getSyntax();
            // An enum leaf that IS a named typedef in this scope SHARES the
            // typedef's enum object (elem ref fullname = the outer alias's
            // BARE name) — Surelog.
            UHDM::typespec* sts = nullptr;
            bool sharedEnumLeaf = false;
            if (leaf->kind == SymbolKind::TypeAlias)
                if (auto sIt = typedefTs.find(
                        (const Symbol*)&leaf->as<TypeAliasType>());
                    sIt != typedefTs.end()) {
                    // A STRUCT leaf that is a named typedef shares its
                    // struct object too (Surelog).
                    sts = sIt->second;
                    sharedEnumLeaf = true;
                }
            if (!sts)
                sts = enumLeaf
                          ? (UHDM::typespec*)buildEnumTs(
                                leaf->getCanonicalType().as<EnumType>(), esyn,
                                ename)
                          : (UHDM::typespec*)buildStructTs(
                                leaf->getCanonicalType().as<PackedStructType>(),
                                true, alias);
            if (enumLeaf && !sharedEnumLeaf) {
                sts->VpiName(ename);
                if (esyn)
                    setLoc(sts, esyn->sourceRange());
            }
            // struct_typespec loc = the `struct` keyword token.
            else if (!enumLeaf && typeSyn)
                setLoc(sts, typeSyn->getFirstToken().range());
            auto* pat = s.MakePacked_array_typespec();
            pat->VpiParent(m);
            if (enumLeaf)
                pat->VpiName(ta.name);
            if (typeSyn)
                setLoc(pat, typeSyn->sourceRange());
            // One range per packed dim (bounds 64-bit UINT; loc from the dim
            // brackets scanned between the struct body and the declarator).
            std::vector<ConstantRange> arrRanges;
            {
                const Type* t2 = &ct;
                for (int i = 0; i < arrDims; i++) {
                    arrRanges.push_back(t2->getCanonicalType().as<PackedArrayType>().range);
                    t2 = &t2->getCanonicalType().as<PackedArrayType>().elementType;
                }
            }
            std::vector<DimSpan> spans;
            if (typeSyn) {
                auto full = typeSyn->sourceRange();
                spans = scanDimSpans(std::string(rawText(full)), full.start());
            }
            auto* rvec = s.MakeRangeVec();
            for (int i = 0; i < arrDims; i++) {
                auto* r = s.MakeRange();
                r->VpiParent(pat);
                const DimSpan* ds = i < (int)spans.size() ? &spans[i] : nullptr;
                if (ds)
                    setLoc(r, ds->range);
                auto mkB = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
                    auto* c = s.MakeConstant();
                    std::string digits = std::to_string(v);
                    c->VpiDecompile(digits);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiParent(r);
                    if (loc)
                        setLoc(c, *loc);
                    return c;
                };
                r->Left_expr(mkB(arrRanges[i].left, ds ? &ds->left : nullptr));
                r->Right_expr(mkB(arrRanges[i].right, ds ? &ds->right : nullptr));
                rvec->push_back(r);
            }
            pat->Ranges(rvec);
            auto* ert = s.MakeRef_typespec();
            ert->VpiParent(pat);
            ert->VpiFullName(sharedEnumLeaf ? std::string(ta.name) : alias);
            ert->Actual_typespec(sts);
            pat->Elem_typespec(ert);
            // Surelog re-parents the struct's members to the ARRAY typespec.
            if (!enumLeaf && ((UHDM::struct_typespec*)sts)->Members())
                for (auto* tm : *((UHDM::struct_typespec*)sts)->Members())
                    tm->VpiParent(pat);
            ts = pat;
        }
        else if ((ct.kind == SymbolKind::PackedArrayType ||
                  ct.kind == SymbolKind::ScalarType) &&
                 ta.targetType.getType().kind == SymbolKind::TypeAlias &&
                 typedefTs.count(&ta.targetType.getType()) &&
                 typedefTs[&ta.targetType.getType()]->UhdmType() ==
                     UHDM::uhdmlogic_typespec) {
            // A typedef ALIAS of another vector typedef (typedef int8_t
            // char_t): a NAMED clone at the TARGET typedef's type span with
            // its ranges and a Typedef_alias ref to the target's shared ts.
            auto& tgt = ta.targetType.getType().as<TypeAliasType>();
            const syntax::SyntaxNode* tgtSyn = nullptr;
            if (auto asyn = tgt.getSyntax())
                if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                    tgtSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
            bypassTypedefShare = true;
            auto* cl = makeTypespec(tgt, tgtSyn);
            bypassTypedefShare = false;
            auto* art = s.MakeRef_typespec();
            art->VpiFullName(prefix + "." + std::string(ta.name));
            art->VpiParent(cl);
            art->Actual_typespec(typedefTs[&ta.targetType.getType()]);
            ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
            cl->VpiParent(m);
            ts = cl;
        }
        else if (ct.kind == SymbolKind::PackedArrayType ||
                 ct.kind == SymbolKind::ScalarType) {
            // Vector/scalar typedefs: a NAMED logic_typespec at the target
            // type syntax, module parent + Instance. Typedef ranges keep
            // param/$bits-dependent bounds UNFOLDED (typedef context).
            bypassTypedefShare = true;
            bool savedTf = tfContext;
            tfContext = true;
            typedefTsContext = true;
            auto* lts = makeTypespec(ta, typeSyn);
            typedefTsContext = false;
            tfContext = savedTf;
            bypassTypedefShare = false;
            // A module vector typedef used by a NET declaration (wire
            // typename x) carries only Instance, no VpiParent (net_types);
            // var/function-typed typedefs keep the module parent.
            bool netUse9 = false;
            for (auto& nm9 : body.members())
                if (nm9.kind == SymbolKind::Net)
                    if (auto* nd9 = nm9.getDeclaredType();
                        nd9 && &nd9->getType() == &ta) {
                        netUse9 = true;
                        break;
                    }
            if (!netUse9)
                lts->VpiParent(m);
            typedefClone[&ta] = nullptr;
            ts = lts;
        }
        else {
            noteUnsupported("typedef target: " + std::string(toString(ct.kind)));
            continue;
        }
        ts->VpiName(ta.name);
        ((UHDM::typespec*)ts)->Instance(m);
        typedefTs[&ta] = ts;
        info.typedefs.push_back(ts);
        tds->push_back(ts);
    }
    // A struct typedef referenced from another typedef's member gets
    // module parent and module-scoped member ref fullnames.
    for (auto* td : *tds) {
        if (td->UhdmType() != UHDM::uhdmstruct_typespec)
            continue;
        auto* sts = (UHDM::struct_typespec*)td;
        if (!sts->Members())
            continue;
        for (auto* tm : *sts->Members()) {
            if (!tm->Typespec() || !tm->Typespec()->Actual_typespec())
                continue;
            auto* target = tm->Typespec()->Actual_typespec();
            if (target->UhdmType() != UHDM::uhdmstruct_typespec || target->VpiParent())
                continue;
            auto* tsts = (UHDM::struct_typespec*)target;
            bool ours = false;
            for (auto* other : *tds)
                if (other == target)
                    ours = true;
            if (!ours)
                continue;
            tsts->VpiParent(m);
            if (tsts->Members()) {
                for (auto* mm : *tsts->Members()) {
                    if (mm->Typespec())
                        mm->Typespec()->VpiFullName(prefix + "." +
                                                    std::string(tsts->VpiName()) + "." +
                                                    std::string(mm->VpiName()));
                }
            }
        }
    }
    if (!tds->empty()) {
        // Surelog lists module typedefs NAME-SORTED (its typespec registry
        // is a name-keyed map), not in declaration order.
        std::stable_sort(tds->begin(), tds->end(),
                         [](const UHDM::typespec* a, const UHDM::typespec* b) {
                             return a->VpiName() < b->VpiName();
                         });
        m->Typespecs(tds);
    }
}

// Maps binary expression syntax kinds to vpi op codes (range-bound exprs).
static int32_t mapSyntaxUnaryOp(syntax::SyntaxKind k) {
    switch (k) {
        case syntax::SyntaxKind::UnaryLogicalNotExpression:
            return vpiNotOp;
        case syntax::SyntaxKind::UnaryBitwiseNotExpression:
            return vpiBitNegOp;
        case syntax::SyntaxKind::UnaryMinusExpression:
            return vpiMinusOp;
        case syntax::SyntaxKind::UnaryPlusExpression:
            return vpiPlusOp;
        default:
            return 0;
    }
}

static int32_t mapSyntaxBinOp(syntax::SyntaxKind k) {
    switch (k) {
        case syntax::SyntaxKind::AddExpression:
            return vpiAddOp;
        case syntax::SyntaxKind::SubtractExpression:
            return vpiSubOp;
        case syntax::SyntaxKind::MultiplyExpression:
            return vpiMultOp;
        case syntax::SyntaxKind::DivideExpression:
            return vpiDivOp;
        case syntax::SyntaxKind::ModExpression:
            return vpiModOp;
        case syntax::SyntaxKind::LogicalShiftLeftExpression:
            return vpiLShiftOp;
        case syntax::SyntaxKind::LogicalShiftRightExpression:
            return vpiRShiftOp;
        case syntax::SyntaxKind::PowerExpression:
            return vpiPowerOp;
        case syntax::SyntaxKind::GreaterThanExpression:
            return vpiGtOp;
        case syntax::SyntaxKind::GreaterThanEqualExpression:
            return vpiGeOp;
        case syntax::SyntaxKind::LessThanExpression:
            return vpiLtOp;
        case syntax::SyntaxKind::LessThanEqualExpression:
            return vpiLeOp;
        case syntax::SyntaxKind::EqualityExpression:
            return vpiEqOp;
        case syntax::SyntaxKind::InequalityExpression:
            return vpiNeqOp;
        case syntax::SyntaxKind::WildcardEqualityExpression:
            return 69; // vpiWildEqOp
        case syntax::SyntaxKind::WildcardInequalityExpression:
            return 70; // vpiWildNeqOp
        case syntax::SyntaxKind::LogicalAndExpression:
            return vpiLogAndOp;
        case syntax::SyntaxKind::LogicalOrExpression:
            return vpiLogOrOp;
        case syntax::SyntaxKind::BinaryAndExpression:
            return vpiBitAndOp;
        case syntax::SyntaxKind::BinaryOrExpression:
            return vpiBitOrOp;
        case syntax::SyntaxKind::BinaryXorExpression:
            return vpiBitXorOp;
        default:
            return 0;
    }
}

UHDM::any* UhdmExporter::emitSyntaxExpr(const syntax::SyntaxNode& syn, UHDM::BaseClass* parent) {
    switch (syn.kind) {
        case syntax::SyntaxKind::IdentifierName: {
            auto name = syn.as<syntax::IdentifierNameSyntax>().identifier.valueText();
            // A module param identifier inside an elaborated GEN-BLOCK
            // function's type bound folds to its value (matching the ExprEmit
            // fold) — the gen block is a concrete instance. genBlockFnScope is
            // set off declSymbol in makeTypespec, so this works in the deferred
            // typespec drain where currentSubSym is null.
            if (genBlockFnScope) {
                {
                    ASTContext bctx(*genBlockFnScope, LookupLocation::max);
                    auto& be = Expression::bind(syn.as<syntax::ExpressionSyntax>(),
                                                bctx);
                    if (!be.bad() && stripImplicitConv(be).kind ==
                                         ExpressionKind::NamedValue) {
                        auto& psy =
                            stripImplicitConv(be).as<NamedValueExpression>().symbol;
                        if (psy.kind == SymbolKind::Parameter) {
                            auto& cv = psy.as<ParameterSymbol>().getValue();
                            if (cv.isInteger() && !cv.integer().hasUnknown()) {
                                auto* c = s.MakeConstant();
                                std::string digits = cv.integer().toString(
                                    LiteralBase::Decimal, false);
                                c->VpiDecompile(digits);
                                c->VpiSize((int32_t)psy.as<ParameterSymbol>()
                                               .getType()
                                               .getBitWidth());
                                c->VpiValue("UINT:" + digits);
                                c->VpiConstType(vpiUIntConst);
                                c->VpiParent(parent);
                                setLoc(c, syn.sourceRange());
                                // SL carries the folded param's type as a
                                // ref_typespec (no fullname in type context).
                                auto* its = s.MakeInt_typespec();
                                if (auto dt = psy.getDeclaredType())
                                    if (auto tsy = dt->getTypeSyntax())
                                        setLoc(its, tsy->sourceRange());
                                auto* rt = s.MakeRef_typespec();
                                rt->VpiParent(c);
                                rt->Actual_typespec(its);
                                c->Typespec(rt);
                                return c;
                            }
                        }
                    }
                }
            }
            auto* ref = s.MakeRef_obj();
            ref->VpiName(name);
            if (!syntaxRefPrefix.empty())
                ref->VpiFullName(syntaxRefPrefix + syntaxRefSep + std::string(name));
            ref->VpiParent(parent);
            setLoc(ref, syn.sourceRange());
            // Inside a package function's return/arg TYPE range (logic
            // [PARAM-1:0]), a reference to a package parameter binds to that
            // param's def-init constant (Surelog value-ref chaining), not left
            // dangling.
            if (tfTypeScope && !ref->Actual_group()) {
                ASTContext tctx(*tfTypeScope, LookupLocation::max);
                auto& be = Expression::bind(syn.as<syntax::ExpressionSyntax>(),
                                            tctx);
                if (!be.bad() && stripImplicitConv(be).kind ==
                                     ExpressionKind::NamedValue) {
                    auto& psy =
                        stripImplicitConv(be).as<NamedValueExpression>().symbol;
                    if (psy.kind == SymbolKind::Parameter) {
                        if (auto pit = pkgParamConst.find(&psy);
                            pit != pkgParamConst.end())
                            ref->Actual_group(pit->second);
                        else if (auto pit2 = pkgParamDefRhs.find(&psy);
                                 pit2 != pkgParamDefRhs.end())
                            ref->Actual_group(pit2->second);
                    }
                }
            }
            return ref;
        }
        case syntax::SyntaxKind::IntegerLiteralExpression: {
            auto* c = s.MakeConstant();
            std::string raw = rawText(syn.sourceRange());
            // MACRO-expanded literals have call-site offsets rawText cannot
            // map — fall back to the token's numeric value.
            if (raw.empty())
                raw = syn.as<syntax::LiteralExpressionSyntax>()
                          .literal.intValue()
                          .toString(LiteralBase::Decimal, false);
            c->VpiDecompile(raw);
            c->VpiSize(64);
            c->VpiValue("UINT:" + raw);
            c->VpiConstType(vpiUIntConst);
            c->VpiParent(parent);
            setLoc(c, syn.sourceRange());
            return c;
        }
        case syntax::SyntaxKind::IntegerVectorExpression: {
            // Based literal (64'h123..): raw decompile, size from the prefix,
            // value in the written base.
            auto* c = s.MakeConstant();
            std::string raw = rawText(syn.sourceRange());
            c->VpiDecompile(raw);
            auto tick = raw.find('\'');
            int32_t sz = 0;
            if (tick != std::string::npos && tick > 0)
                sz = (int32_t)atoi(raw.substr(0, tick).c_str());
            size_t basePos = tick == std::string::npos ? 0 : tick + 1;
            if (basePos < raw.size() && (raw[basePos] == 's' || raw[basePos] == 'S'))
                basePos++;
            char base = basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
            std::string digits = basePos + 1 <= raw.size() ? raw.substr(basePos + 1) : "";
            digits.erase(std::remove(digits.begin(), digits.end(), '_'), digits.end());
            switch (base) {
                case 'h':
                    c->VpiValue("HEX:" + digits);
                    c->VpiConstType(vpiHexConst);
                    break;
                case 'b':
                    c->VpiValue("BIN:" + digits);
                    c->VpiConstType(vpiBinaryConst);
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
            c->VpiSize(sz ? sz : 64);
            c->VpiParent(parent);
            setLoc(c, syn.sourceRange());
            return c;
        }
        case syntax::SyntaxKind::ParenthesizedExpression:
            return emitSyntaxExpr(*syn.as<syntax::ParenthesizedExpressionSyntax>().expression,
                                  parent);
        case syntax::SyntaxKind::ElementSelectExpression:
        case syntax::SyntaxKind::IdentifierSelectName: {
            // t[0] -> bit_select (prefix-scoped fullname, parented index).
            std::string_view bname;
            const syntax::SelectorSyntax* sel = nullptr;
            // Multi-selector chain (x[i][e:w]) -> var_select with one
            // vpiIndex per selector; a range selector becomes a nested
            // part_select with base-doubled naming
            // (MultirangesStartNotFromZero gen CA).
            std::vector<const syntax::SelectorSyntax*> selChain;
            std::string_view chainBase;
            if (syn.kind == syntax::SyntaxKind::ElementSelectExpression) {
                const syntax::SyntaxNode* walk = &syn;
                while (walk->kind ==
                       syntax::SyntaxKind::ElementSelectExpression) {
                    auto& eseW = walk->as<syntax::ElementSelectExpressionSyntax>();
                    if (!eseW.select || !eseW.select->selector)
                        return nullptr;
                    selChain.insert(selChain.begin(), eseW.select->selector);
                    walk = eseW.left;
                }
                if (walk->kind != syntax::SyntaxKind::IdentifierName)
                    return nullptr;
                chainBase =
                    walk->as<syntax::IdentifierNameSyntax>().identifier.valueText();
            }
            else {
                auto& isnW = syn.as<syntax::IdentifierSelectNameSyntax>();
                chainBase = isnW.identifier.valueText();
                for (auto* s2 : isnW.selectors) {
                    if (!s2->selector)
                        return nullptr;
                    selChain.push_back(s2->selector);
                }
            }
            if (selChain.empty())
                return nullptr;
            if (selChain.size() > 1) {
                auto* vs = s.MakeVar_select();
                vs->VpiName(chainBase);
                std::string vsFull;
                if (!syntaxRefPrefix.empty()) {
                    vsFull = syntaxRefPrefix + syntaxRefSep +
                             std::string(chainBase);
                    vs->VpiFullName(vsFull);
                }
                vs->VpiParent(parent);
                setLoc(vs, syn.sourceRange());
                auto* ixs = s.MakeExprVec();
                std::string savedPfxV = syntaxRefPrefix;
                if (!vsFull.empty())
                    syntaxRefPrefix = vsFull;
                for (auto* s3 : selChain) {
                    if (s3->kind == syntax::SyntaxKind::BitSelect) {
                        if (auto* ix = emitSyntaxExpr(
                                *s3->as<syntax::BitSelectSyntax>().expr, vs))
                            ixs->push_back((UHDM::expr*)ix);
                    }
                    else if (s3->kind ==
                             syntax::SyntaxKind::SimpleRangeSelect) {
                        auto& rsV = s3->as<syntax::RangeSelectSyntax>();
                        auto* psV = s.MakePart_select();
                        psV->VpiName(chainBase);
                        if (!vsFull.empty())
                            psV->VpiFullName(vsFull + syntaxRefSep +
                                             std::string(chainBase));
                        psV->VpiDefName(chainBase);
                        psV->VpiConstantSelect(true);
                        psV->VpiParent(vs);
                        setLoc(psV, s3->sourceRange());
                        std::string savedPfxP = syntaxRefPrefix;
                        if (!vsFull.empty())
                            syntaxRefPrefix =
                                vsFull + syntaxRefSep + std::string(chainBase);
                        if (auto* le = emitSyntaxExpr(*rsV.left, psV))
                            psV->Left_range((UHDM::expr*)le);
                        if (auto* re = emitSyntaxExpr(*rsV.right, psV))
                            psV->Right_range((UHDM::expr*)re);
                        syntaxRefPrefix = savedPfxP;
                        ixs->push_back(psV);
                    }
                    else {
                        syntaxRefPrefix = savedPfxV;
                        return nullptr;
                    }
                }
                syntaxRefPrefix = savedPfxV;
                vs->Exprs(ixs);
                return vs;
            }
            if (syn.kind == syntax::SyntaxKind::ElementSelectExpression) {
                auto& ese = syn.as<syntax::ElementSelectExpressionSyntax>();
                if (ese.left->kind != syntax::SyntaxKind::IdentifierName)
                    return nullptr;
                bname = ese.left->as<syntax::IdentifierNameSyntax>()
                            .identifier.valueText();
                sel = ese.select->selector;
            }
            else {
                auto& isn = syn.as<syntax::IdentifierSelectNameSyntax>();
                bname = isn.identifier.valueText();
                if (isn.selectors.size() != 1)
                    return nullptr;
                sel = isn.selectors[0]->selector;
            }
            // A RANGE select (x[63:W]) is a part_select (DefName = base,
            // ConstantSelect, Left/Right from the written bounds) — not a
            // bit_select.
            if (sel && sel->kind == syntax::SyntaxKind::SimpleRangeSelect) {
                auto& rs = sel->as<syntax::RangeSelectSyntax>();
                auto* pssel = s.MakePart_select();
                pssel->VpiName(bname);
                if (!syntaxRefPrefix.empty())
                    pssel->VpiFullName(syntaxRefPrefix + syntaxRefSep +
                                       std::string(bname));
                pssel->VpiDefName(bname);
                pssel->VpiConstantSelect(true);
                pssel->VpiParent(parent);
                setLoc(pssel, syn.sourceRange());
                // Bound refs scope THROUGH the select base (prefix.base.P);
                // bound constants stay unparented (Surelog).
                std::string savedPfx2 = syntaxRefPrefix;
                if (!syntaxRefPrefix.empty())
                    syntaxRefPrefix += syntaxRefSep + std::string(bname);
                auto unparentConst = [](UHDM::any* e) {
                    if (e && e->UhdmType() == UHDM::uhdmconstant)
                        ((UHDM::expr*)e)->VpiParent(nullptr);
                };
                if (auto* le = emitSyntaxExpr(*rs.left, pssel)) {
                    unparentConst(le);
                    pssel->Left_range((UHDM::expr*)le);
                }
                if (auto* re = emitSyntaxExpr(*rs.right, pssel)) {
                    unparentConst(re);
                    pssel->Right_range((UHDM::expr*)re);
                }
                syntaxRefPrefix = savedPfx2;
                return pssel;
            }
            auto* bs = s.MakeBit_select();
            bs->VpiName(bname);
            if (!syntaxRefPrefix.empty())
                bs->VpiFullName(syntaxRefPrefix + syntaxRefSep + std::string(bname));
            bs->VpiParent(parent);
            setLoc(bs, syn.sourceRange());
            if (sel && sel->kind == syntax::SyntaxKind::BitSelect) {
                // Def gen-CA RHS: index subexpressions scope THROUGH the
                // select base (prefix.base.<name>) — Surelog.
                std::string savedPfx3 = syntaxRefPrefix;
                if (selBaseScopeIdx && !syntaxRefPrefix.empty())
                    syntaxRefPrefix += syntaxRefSep + std::string(bname);
                if (auto* ix = emitSyntaxExpr(
                        *sel->as<syntax::BitSelectSyntax>().expr, bs))
                    bs->VpiIndex((UHDM::expr*)ix);
                syntaxRefPrefix = savedPfx3;
            }
            return bs;
        }
        case syntax::SyntaxKind::UnbasedUnsizedLiteralExpression: {
            // '0/'1/'x/'z: BIN digit, size -1, raw decompile ('x -> 'X).
            auto* c = s.MakeConstant();
            std::string raw = rawText(syn.sourceRange());
            if (raw.empty())
                raw = std::string(syn.as<syntax::LiteralExpressionSyntax>()
                                      .literal.rawText());
            for (auto& ch : raw)
                if (ch == 'x' || ch == 'z')
                    ch = (char)toupper(ch);
            c->VpiDecompile(raw);
            c->VpiSize(-1);
            std::string digit = raw.size() > 1 ? raw.substr(1) : "0";
            c->VpiValue("BIN:" + digit);
            c->VpiConstType(vpiBinaryConst);
            c->VpiParent(parent);
            setLoc(c, syn.sourceRange());
            return c;
        }
        case syntax::SyntaxKind::StreamingConcatenationExpression: {
            // {<< [N] {a,b}}: stream op at the INNER braces span wrapping a
            // concat that takes the WHOLE streaming span (Surelog span swap);
            // an explicit slice size is a located first operand.
            auto& sce = syn.as<syntax::StreamingConcatenationExpressionSyntax>();
            auto* op = s.MakeOperation();
            op->VpiOpType(sce.operatorToken.valueText() == ">>" ? vpiStreamLROp
                                                                : vpiStreamRLOp);
            op->VpiParent(parent);
            setLoc(op, SourceRange(sce.innerOpenBrace.location(),
                                   sce.innerCloseBrace.location() + 1));
            auto* outer = s.MakeAnyVec();
            if (sce.sliceSize)
                if (auto* c = emitSyntaxExpr(*sce.sliceSize, op))
                    outer->push_back(c);
            auto* cc = s.MakeOperation();
            cc->VpiOpType(vpiConcatOp);
            cc->VpiParent(op);
            setLoc(cc, syn.sourceRange());
            auto* inner = s.MakeAnyVec();
            for (auto* se : sce.expressions)
                if (auto* e = emitSyntaxExpr(*se->expression, cc))
                    inner->push_back(e);
            cc->Operands(inner);
            outer->push_back(cc);
            op->Operands(outer);
            return op;
        }
        case syntax::SyntaxKind::InvocationExpression: {
            auto& inv = syn.as<syntax::InvocationExpressionSyntax>();
            // System call ($bits(dmi_t)): a sys_func_call with the argument
            // emitted as a ref_obj (type/name-token) argument.
            if (inv.left->kind == syntax::SyntaxKind::SystemName) {
                auto sysName = inv.left->as<syntax::SystemNameSyntax>()
                                   .systemIdentifier.valueText();
                // Type-query calls ($bits(type)/$size(...)) fold to a constant
                // when the argument resolves in the current scope. $bits of a
                // SIGNAL folds too UNLESS the signal's width is param-dependent
                // ($bits(int o) -> 32; $bits([X-1:0] o) stays a sys_func_call).
                bool foldQuery = typedefTsContext;
                // Outside a typedef ts, $bits folds ONLY for a FIXED-width
                // SIGNAL arg ($bits(int o) -> 32); a $bits(TYPE) or a
                // param-dependent signal stays a sys_func_call.
                if (!foldQuery && currentScope && inv.arguments &&
                    (sysName == "$bits" || sysName == "$size")) {
                    for (auto a2 : inv.arguments->parameters)
                        if (auto* sy2 = currentScope->find(
                                std::string(rawText(a2->sourceRange()))))
                            if ((sy2->kind == SymbolKind::Net ||
                                 sy2->kind == SymbolKind::Variable) &&
                                !typeWidthUsesParam(*sy2))
                                foldQuery = true;
                }
                if (foldQuery && currentScope &&
                    (sysName == "$bits" || sysName == "$size" || sysName == "$clog2")) {
                    ASTContext bctx(*currentScope, LookupLocation::max);
                    auto& bound = Expression::bind(syn.as<syntax::ExpressionSyntax>(), bctx);
                    if (auto cv = bctx.tryEval(bound); cv && cv.isInteger()) {
                        auto* c = s.MakeConstant();
                        std::string digits =
                            cv.integer().toString(LiteralBase::Decimal, false);
                        c->VpiDecompile(digits);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(parent);
                        setLoc(c, syn.sourceRange());
                        return c;
                    }
                }
                auto* sfc = s.MakeSys_func_call();
                sfc->VpiName(sysName);
                sfc->VpiParent(parent);
                setLoc(sfc, syn.sourceRange());
                if (inv.arguments) {
                    auto* args = s.MakeAnyVec();
                    for (auto arg : inv.arguments->parameters) {
                        // DOTTED args (blk1.w) re-emit as hier_paths (bare
                        // base, prefix-scoped leaf).
                        std::string argRaw = rawText(arg->sourceRange());
                        if (argRaw.find('.') != std::string::npos &&
                            arg->kind == syntax::SyntaxKind::OrderedArgument) {
                            const syntax::SyntaxNode* ae =
                                arg->as<syntax::OrderedArgumentSyntax>().expr;
                            if (ae->kind ==
                                syntax::SyntaxKind::SimplePropertyExpr)
                                ae = ae->as<syntax::SimplePropertyExprSyntax>()
                                         .expr;
                            if (ae->kind ==
                                syntax::SyntaxKind::SimpleSequenceExpr)
                                ae = ae->as<syntax::SimpleSequenceExprSyntax>()
                                         .expr;
                            if (auto* e2 = emitSyntaxExpr(*ae, sfc)) {
                                args->push_back(e2);
                                continue;
                            }
                        }
                        auto* r = s.MakeRef_obj();
                        r->VpiName(argRaw);
                        r->VpiParent(sfc);
                        setLoc(r, arg->sourceRange());
                        args->push_back(r);
                    }
                    if (!args->empty())
                        sfc->Tf_call_args(args);
                }
                return sfc;
            }
            // Module-compile calls: NAME-token span, linked to the module
            // function when one matches by name (Surelog).
            auto* fc = s.MakeFunc_call();
            if (inv.left->kind == syntax::SyntaxKind::IdentifierName)
                fc->VpiName(
                    inv.left->as<syntax::IdentifierNameSyntax>().identifier.valueText());
            fc->VpiParent(parent);
            // TYPE-BOUND contexts anchor at the callee NAME token; expression
            // contexts keep the full call span (Surelog).
            if (boundCallNameSpan)
                setLoc(fc, inv.left->sourceRange());
            else
                setLoc(fc, syn.sourceRange());
            // Only TYPEDEF/PORT-context bounds (tfContext) link the
            // function; gen-conn call args stay unbound (Surelog).
            if (tfContext)
                for (auto& [subK, subI] : subMap)
                    if (subI.tf && subI.tf->VpiName() == fc->VpiName() &&
                        subI.tf->UhdmType() == UHDM::uhdmfunction) {
                        fc->Function((UHDM::function*)subI.tf);
                        break;
                    }
            // Arguments emit from syntax too (prefix_or(i[OFF-1:0])).
            if (inv.arguments && !inv.arguments->parameters.empty()) {
                auto* args = s.MakeAnyVec();
                for (auto a2 : inv.arguments->parameters)
                    if (a2->kind == syntax::SyntaxKind::OrderedArgument) {
                        // Unwrap the property/sequence wrappers around a
                        // plain expression argument.
                        const syntax::SyntaxNode* ae =
                            a2->as<syntax::OrderedArgumentSyntax>().expr;
                        if (ae->kind == syntax::SyntaxKind::SimplePropertyExpr)
                            ae = ae->as<syntax::SimplePropertyExprSyntax>()
                                     .expr;
                        if (ae->kind == syntax::SyntaxKind::SimpleSequenceExpr)
                            ae = ae->as<syntax::SimpleSequenceExprSyntax>()
                                     .expr;
                        if (auto* e2 = emitSyntaxExpr(*ae, fc))
                            args->push_back(e2);
                    }
                if (!args->empty())
                    fc->Tf_call_args(args);
            }
            return fc;
        }
        case syntax::SyntaxKind::CastExpression: {
            // int'(expr) at module compile: operation 67 with a scoped ts ref
            // (int_typespec at the cast-target token) + the operand.
            auto& ce = syn.as<syntax::CastExpressionSyntax>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiCastOp);
            op->VpiParent(parent);
            setLoc(op, syn.sourceRange());
            UHDM::typespec* cts = nullptr;
            if (ce.left->kind == syntax::SyntaxKind::IntType) {
                auto* t = s.MakeInt_typespec();
                t->VpiSigned(true);
                cts = t;
            }
            else {
                cts = s.MakeLogic_typespec();
            }
            setLoc((UHDM::BaseClass*)cts, ce.left->sourceRange());
            auto* rt = s.MakeRef_typespec();
            if (!syntaxRefPrefix.empty())
                rt->VpiFullName(syntaxRefPrefix);
            rt->VpiParent(op);
            rt->Actual_typespec(cts);
            op->Typespec(rt);
            auto* operands = s.MakeAnyVec();
            const syntax::SyntaxNode* opnd = ce.right;
            if (opnd->kind == syntax::SyntaxKind::ParenthesizedExpression)
                opnd = opnd->as<syntax::ParenthesizedExpressionSyntax>().expression;
            if (auto* e = emitSyntaxExpr(*opnd, op))
                operands->push_back(e);
            op->Operands(operands);
            return op;
        }
        case syntax::SyntaxKind::AssignmentPatternExpression: {
            // Structured pattern ('{f1: expr, ...}) in a DEF gen CA:
            // operation 75 of tagged_patterns; each carries the member expr
            // (parented at the operation) and a string_typespec ref named by
            // the FIELD, scoped at the gen prefix (Surelog).
            auto& ape = syn.as<syntax::AssignmentPatternExpressionSyntax>();
            if (ape.pattern->kind !=
                syntax::SyntaxKind::StructuredAssignmentPattern)
                return nullptr;
            auto& spn =
                ape.pattern->as<syntax::StructuredAssignmentPatternSyntax>();
            auto* op9 = s.MakeOperation();
            op9->VpiOpType(75);
            op9->VpiParent(parent);
            setLoc(op9, ape.pattern->sourceRange());
            auto* ops9 = s.MakeAnyVec();
            for (auto* item9 : spn.items) {
                if (item9->kind != syntax::SyntaxKind::AssignmentPatternItem)
                    continue;
                auto& api9 = item9->as<syntax::AssignmentPatternItemSyntax>();
                auto* tp9 = s.MakeTagged_pattern();
                tp9->VpiParent(op9);
                setLoc(tp9, api9.expr->sourceRange());
                if (auto* pe9 = emitSyntaxExpr(*api9.expr, op9))
                    tp9->Pattern((UHDM::expr*)pe9);
                auto* rt9 = s.MakeRef_typespec();
                if (!syntaxRefPrefix.empty())
                    rt9->VpiFullName(syntaxRefPrefix);
                rt9->VpiParent(tp9);
                auto* st9 = s.MakeString_typespec();
                st9->VpiName(rawText(api9.key->sourceRange()));
                setLoc(st9, api9.key->sourceRange());
                rt9->Actual_typespec(st9);
                tp9->Typespec(rt9);
                ops9->push_back(tp9);
            }
            op9->Operands(ops9);
            return op9;
        }
        case syntax::SyntaxKind::ScopedName: {
            // A dotted HIERARCHICAL name (B.y, blk[0].sub.x) in a DEF-view
            // gen-block cont_assign: a hier_path built from the source text,
            // mirroring the ELAB HierarchicalValue handler (ExprEmit). A
            // package-scoped name (pkg::x) has no '.' -> <2 parts -> falls
            // through to null (unchanged). syntaxRefPrefix is the enclosing
            // gen-scope fullname (work@gen_test9.A); the leaf ref carries
            // prefix.<leaf> (Surelog flattens intermediate blocks: A.y not
            // A.B.y). Other (non-gen) callers have an empty/param prefix, so
            // the leaf simply gets no fullname.
            std::string raw = rawText(syn.sourceRange());
            // A SYMBOLIC base index (STAGE[i-1].C) re-lexes with spaces
            // around binary operators (Surelog) and needs the selector
            // SYNTAX for the bit_select index emission.
            const syntax::ExpressionSyntax* baseSelSyn = nullptr;
            {
                auto& scn0 = syn.as<syntax::ScopedNameSyntax>();
                if (scn0.left->kind ==
                    syntax::SyntaxKind::IdentifierSelectName) {
                    auto& isn0 =
                        scn0.left->as<syntax::IdentifierSelectNameSyntax>();
                    if (isn0.selectors.size() == 1 &&
                        isn0.selectors[0]->selector &&
                        isn0.selectors[0]->selector->kind ==
                            syntax::SyntaxKind::BitSelect)
                        baseSelSyn = isn0.selectors[0]
                                         ->selector
                                         ->as<syntax::BitSelectSyntax>()
                                         .expr;
                }
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
            std::string dispRaw = spaceOps(raw);
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
            // A PACKAGE-SCOPED reference (pkg::PARAM) in a symbolic TYPE range
            // keeps a ref_obj bound to the package parameter — Surelog leaves the
            // [pkg::WIDTH-1:0] bound UNFOLDED (fail_detect_width output port).
            if (parts.size() < 2 && raw.find("::") != std::string::npos) {
                auto* ref = s.MakeRef_obj();
                ref->VpiName(raw);
                ref->VpiFullName(raw);
                ref->VpiParent(parent);
                setLoc(ref, syn.sourceRange());
                const Scope& bscope =
                    currentScope ? *currentScope : (const Scope&)comp.getRoot();
                ASTContext bctx(bscope, LookupLocation::max);
                auto& be =
                    Expression::bind(syn.as<syntax::ExpressionSyntax>(), bctx);
                if (!be.bad() && stripImplicitConv(be).kind ==
                                     ExpressionKind::NamedValue) {
                    auto& psy =
                        stripImplicitConv(be).as<NamedValueExpression>().symbol;
                    if (auto poit = pkgParamObj.find(&psy);
                        poit != pkgParamObj.end())
                        ref->Actual_group(poit->second);
                }
                return ref;
            }
            if (parts.size() < 2)
                return nullptr;
            auto* hp = s.MakeHier_path();
            hp->VpiName(dispRaw);
            hp->VpiFullName(dispRaw);
            hp->VpiParent(parent);
            setLoc(hp, syn.sourceRange());
            auto* elems = s.MakeAnyVec();
            auto exprStart = syn.sourceRange().start();
            std::string dottedSoFar;
            bool genVarBaseEmitted = false;
            for (size_t i = 0; i < parts.size(); i++) {
                auto& [pname, off] = parts[i];
                dottedSoFar += (i == 0 ? pname : "." + pname);
                auto lb = pname.find('[');
                auto rb = pname.find(']');
                if (lb != std::string::npos && rb != std::string::npos &&
                    rb > lb + 1 &&
                    pname.find_first_not_of("0123456789", lb + 1) == rb) {
                    std::string base = pname.substr(0, lb);
                    std::string idx = pname.substr(lb + 1, rb - lb - 1);
                    auto* bs = s.MakeBit_select();
                    bs->VpiName(base);
                    bs->VpiParent(hp);
                    bs->VpiFullName(dottedSoFar);
                    setLoc(bs, SourceRange(exprStart + off,
                                           exprStart + off + base.size()));
                    auto* c = s.MakeConstant();
                    c->VpiDecompile(idx);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + idx);
                    c->VpiConstType(vpiUIntConst);
                    size_t digitOff = off + lb + 1;
                    setLoc(c, SourceRange(exprStart + digitOff,
                                          exprStart + digitOff + idx.size()));
                    bs->VpiIndex(c);
                    elems->push_back(bs);
                    continue;
                }
                // A [L:R] literal RANGE on an element (f1[63:0]):
                // part_select named by the member, fullname = the dotted
                // path incl. the select, ConstantSelect, UINT64 bounds.
                {
                    auto cl9 = pname.find(':');
                    if (lb != std::string::npos && rb != std::string::npos &&
                        cl9 != std::string::npos && cl9 > lb && cl9 < rb &&
                        pname.find_first_not_of("0123456789",
                                                lb + 1) == cl9 &&
                        pname.find_first_not_of("0123456789",
                                                cl9 + 1) == rb) {
                        std::string base9 = pname.substr(0, lb);
                        auto* ps9 = s.MakePart_select();
                        ps9->VpiName(base9);
                        ps9->VpiFullName(dottedSoFar);
                        ps9->VpiParent(hp);
                        ps9->VpiConstantSelect(true);
                        setLoc(ps9, SourceRange(exprStart + off,
                                                exprStart + off + rb));
                        auto mkB9 = [&](size_t from, size_t to) {
                            auto* c9 = s.MakeConstant();
                            std::string dg9 =
                                pname.substr(from, to - from);
                            c9->VpiDecompile(dg9);
                            c9->VpiSize(64);
                            c9->VpiValue("UINT:" + dg9);
                            c9->VpiConstType(vpiUIntConst);
                            setLoc(c9,
                                   SourceRange(exprStart + off + from,
                                               exprStart + off + to));
                            return c9;
                        };
                        ps9->Left_range(mkB9(lb + 1, cl9));
                        ps9->Right_range(mkB9(cl9 + 1, rb));
                        elems->push_back(ps9);
                        continue;
                    }
                }
                // SYMBOLIC index on the base (STAGE[i-1]): bit_select named
                // by the base, fullname with SPACED index, index from the
                // selector syntax.
                if (i == 0 && baseSelSyn && lb != std::string::npos &&
                    rb != std::string::npos && rb > lb + 1) {
                    std::string base = pname.substr(0, lb);
                    auto* bs = s.MakeBit_select();
                    bs->VpiName(base);
                    bs->VpiParent(hp);
                    bs->VpiFullName(spaceOps(pname));
                    setLoc(bs, SourceRange(exprStart + off,
                                           exprStart + off + base.size()));
                    if (auto* ix = emitSyntaxExpr(*baseSelSyn, bs))
                        bs->VpiIndex((UHDM::expr*)ix);
                    elems->push_back(bs);
                    continue;
                }
                // A GENVAR/variable-indexed BASE component (man[i].req.lck in a
                // genvar for): bit_select(base), raw component fullname, with a
                // ref_obj index child that PARENTS AT THE HIER_PATH and carries
                // the gen-scope-prefixed genvar fullname (Surelog). Distinct
                // from the constant-index and symbolic-doubled-index forms.
                if (i == 0 && lb != std::string::npos && rb != std::string::npos &&
                    rb > lb + 1) {
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
                        bs->VpiFullName(pname);
                        setLoc(bs, SourceRange(exprStart + off,
                                               exprStart + off + base.size()));
                        auto* ir = s.MakeRef_obj();
                        ir->VpiName(idx);
                        if (!syntaxRefPrefix.empty())
                            ir->VpiFullName(syntaxRefPrefix + "." + idx);
                        ir->VpiParent(hp);
                        size_t idOff = off + lb + 1;
                        setLoc(ir, SourceRange(exprStart + idOff,
                                               exprStart + idOff + idx.size()));
                        bs->VpiIndex(ir);
                        elems->push_back(bs);
                        genVarBaseEmitted = true;
                        continue;
                    }
                }
                auto* r = s.MakeRef_obj();
                r->VpiName(pname);
                if (genVarBaseEmitted && i + 1 == parts.size())
                    // A gen-scope modport-array member path gives the LEAF the
                    // RAW dotted fullname (Surelog).
                    r->VpiFullName(raw);
                else if (i + 1 == parts.size() && !syntaxRefPrefix.empty())
                    r->VpiFullName(syntaxRefPrefix + "." + pname);
                else
                    // Name-only cache blocks the dump-time lazy scoped
                    // fullname recompute (Surelog shows the bare name).
                    r->VpiFullName(pname);
                r->VpiParent(hp);
                setLoc(r, SourceRange(exprStart + off, exprStart + off + pname.size()));
                elems->push_back(r);
            }
            // A gen-scope modport-array member path anchors the hier_path at the
            // BASE-name token only (Surelog).
            if (genVarBaseEmitted && !elems->empty()) {
                auto* fe = (UHDM::expr*)elems->front();
                hp->VpiEndLineNo(fe->VpiEndLineNo());
                hp->VpiEndColumnNo(fe->VpiEndColumnNo());
            }
            hp->Path_elems(elems);
            return hp;
        }
        default: {
            // `x inside {a, b}` — op 95 with [x, a, b, ...] (Surelog).
            if (syn.kind == syntax::SyntaxKind::InsideExpression) {
                auto& ie = syn.as<syntax::InsideExpressionSyntax>();
                auto* op = s.MakeOperation();
                op->VpiOpType(95);
                op->VpiParent(parent);
                setLoc(op, syn.sourceRange());
                auto* operands = s.MakeAnyVec();
                if (auto* l = emitSyntaxExpr(*ie.expr, op))
                    operands->push_back(l);
                if (ie.ranges)
                    for (auto* vr : ie.ranges->valueRanges)
                        if (auto* e = emitSyntaxExpr(*vr, op))
                            operands->push_back(e);
                op->Operands(operands);
                return op;
            }
            // Ternary (?:) — vpiConditionOp with [cond, true, false].
            if (syn.kind == syntax::SyntaxKind::ConditionalExpression) {
                auto& ce = syn.as<syntax::ConditionalExpressionSyntax>();
                auto* op = s.MakeOperation();
                op->VpiOpType(32);
                op->VpiParent(parent);
                setLoc(op, syn.sourceRange());
                auto* operands = s.MakeAnyVec();
                if (!ce.predicate->conditions.empty())
                    if (auto* c0 = emitSyntaxExpr(
                            *ce.predicate->conditions[0]->expr, op))
                        operands->push_back(c0);
                if (auto* l = emitSyntaxExpr(*ce.left, op))
                    operands->push_back(l);
                if (auto* r = emitSyntaxExpr(*ce.right, op))
                    operands->push_back(r);
                op->Operands(operands);
                return op;
            }
            if (int32_t opType = mapSyntaxUnaryOp(syn.kind)) {
                auto& ue = syn.as<syntax::PrefixUnaryExpressionSyntax>();
                auto* op = s.MakeOperation();
                op->VpiOpType(opType);
                op->VpiParent(parent);
                setLoc(op, syn.sourceRange());
                auto* operands = s.MakeAnyVec();
                if (auto* e = emitSyntaxExpr(*ue.operand, op))
                    operands->push_back(e);
                op->Operands(operands);
                return op;
            }
            if (int32_t opType = mapSyntaxBinOp(syn.kind)) {
                auto& be = syn.as<syntax::BinaryExpressionSyntax>();
                auto* op = s.MakeOperation();
                op->VpiOpType(opType);
                op->VpiParent(parent);
                setLoc(op, syn.sourceRange());
                auto* operands = s.MakeAnyVec();
                if (auto* l = emitSyntaxExpr(*be.left, op))
                    operands->push_back(l);
                if (auto* r = emitSyntaxExpr(*be.right, op))
                    operands->push_back(r);
                op->Operands(operands);
                return op;
            }
            return nullptr;
        }
    }
}

UHDM::VectorOfrange* UhdmExporter::buildUnpackedRanges(
    const Symbol& sym, UHDM::BaseClass* parent,
    const std::string& defDimRefPrefix) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return nullptr;
    auto* ranges = s.MakeRangeVec();
    const syntax::SyntaxNode* dsyn = sym.getSyntax();
    const Type* dt = &declared->getType().getCanonicalType();
    if (dsyn && dsyn->kind == syntax::SyntaxKind::Declarator) {
        auto& dd = dsyn->as<syntax::DeclaratorSyntax>();
        for (auto dim : dd.dimensions) {
            if (dt->getCanonicalType().kind != SymbolKind::FixedSizeUnpackedArrayType)
                break;
            auto& ua = dt->getCanonicalType().as<FixedSizeUnpackedArrayType>();
            auto* r = s.MakeRange();
            r->VpiParent(parent);
            setLoc(r, dim->sourceRange());
            const syntax::ExpressionSyntax* leftSyn = nullptr;
            const syntax::ExpressionSyntax* rightSyn = nullptr;
            const syntax::ExpressionSyntax* sizeSyn = nullptr;
            if (dim->specifier &&
                dim->specifier->kind == syntax::SyntaxKind::RangeDimensionSpecifier) {
                auto& sel = *dim->specifier->as<syntax::RangeDimensionSpecifierSyntax>().selector;
                if (auto* rss = sel.as_if<syntax::RangeSelectSyntax>()) {
                    leftSyn = rss->left;
                    rightSyn = rss->right;
                }
                else if (auto* bss = sel.as_if<syntax::BitSelectSyntax>()) {
                    sizeSyn = bss->expr;
                }
            }
            // Size-style dim [N] (== [0:N-1]): the range spans the whole [N],
            // left bound is a bare 0, and the right bound is an UNFOLDED N-1
            // operation anchored at the size-expression span.
            if (sizeSyn) {
                setLoc(r, sizeSyn->sourceRange());
                auto* lc = s.MakeConstant();
                lc->VpiParent(r);
                lc->VpiDecompile("0");
                lc->VpiSize(64);
                lc->VpiValue("UINT:0");
                lc->VpiConstType(vpiUIntConst);
                r->Left_expr(lc);
                auto* op = s.MakeOperation();
                op->VpiParent(r);
                op->VpiOpType(11);
                setLoc(op, sizeSyn->sourceRange());
                auto* ops = s.MakeAnyVec();
                // DEF-view port array_typespec: a PARAM-sized dim ([N]) keeps
                // the size symbolic — a bare ref_obj <prefix>.N (no actual).
                if (!defDimRefPrefix.empty() &&
                    sizeSyn->kind == syntax::SyntaxKind::IdentifierName &&
                    parent->UhdmType() == UHDM::uhdmarray_typespec) {
                    auto* ro = s.MakeRef_obj();
                    std::string nm(sizeSyn->as<syntax::IdentifierNameSyntax>()
                                       .identifier.valueText());
                    ro->VpiName(nm);
                    ro->VpiFullName(defDimRefPrefix + "." + nm);
                    ro->VpiParent(op);
                    setLoc(ro, sizeSyn->sourceRange());
                    ops->push_back(ro);
                    auto* one = s.MakeConstant();
                    one->VpiSize(64);
                    one->VpiValue("INT:1");
                    one->VpiConstType(vpiIntConst);
                    ops->push_back(one);
                    op->Operands(ops);
                    r->Right_expr(op);
                    ranges->push_back(r);
                    dt = &ua.elementType;
                    continue;
                }
                auto* sc = s.MakeConstant();
                sc->VpiParent(op);
                // A PARAM-sized dim ([DEPTH]) folds to the value at the
                // param's width, with a ts ref (loc-less signed int clone,
                // fullname = the var); literal sizes keep the raw text at 64.
                if (sizeSyn->kind != syntax::SyntaxKind::IntegerLiteralExpression &&
                    currentScope &&
                    (parent->UhdmType() == UHDM::uhdmarray_var ||
                     parent->UhdmType() == UHDM::uhdmarray_net)) {
                    std::string digits = std::to_string(ua.range.width());
                    sc->VpiDecompile(digits);
                    ASTContext bctx0(*currentScope, LookupLocation::max);
                    auto& be0 = Expression::bind(
                        *const_cast<syntax::ExpressionSyntax*>(sizeSyn), bctx0);
                    int32_t w0 = 32;
                    bool sgn0 = true;
                    if (!be0.bad() && be0.type) {
                        w0 = (int32_t)be0.type->getBitWidth();
                        sgn0 = be0.type->isSigned();
                    }
                    sc->VpiSize(w0);
                    sc->VpiValue("UINT:" + digits);
                    auto* rt0 = s.MakeRef_typespec();
                    rt0->VpiFullName(std::string(
                        parent->UhdmType() == UHDM::uhdmarray_var
                            ? ((UHDM::array_var*)parent)->VpiFullName()
                            : ((UHDM::array_net*)parent)->VpiFullName()));
                    rt0->VpiParent(sc);
                    // A STRUCT-PARAM MEMBER dim (mem[pt.t]) anchors the fold
                    // at the param's DEFAULT literal (its raw decompile) and
                    // binds the SHARED struct typedef ts (Surelog).
                    UHDM::typespec* structTs0 = nullptr;
                    if (!be0.bad()) {
                        auto& ma0 = stripImplicitConv(be0);
                        if (ma0.kind == ExpressionKind::MemberAccess) {
                            auto& mb0 = stripImplicitConv(
                                ma0.as<MemberAccessExpression>().value());
                            if (mb0.kind == ExpressionKind::NamedValue &&
                                mb0.as<NamedValueExpression>().symbol.kind ==
                                    SymbolKind::Parameter) {
                                auto& psb0 = mb0.as<NamedValueExpression>()
                                                 .symbol.as<ParameterSymbol>();
                                auto d0b = psb0.getDeclaredType();
                                if (d0b &&
                                    d0b->getType().kind ==
                                        SymbolKind::TypeAlias) {
                                    auto& ta0b =
                                        d0b->getType().as<TypeAliasType>();
                                    auto& ctb0 = ta0b.getCanonicalType();
                                    if (auto tIt0 = typedefTs.find(
                                            (const Symbol*)&ta0b);
                                        tIt0 != typedefTs.end() &&
                                        ctb0.kind ==
                                            SymbolKind::PackedStructType) {
                                        // Surelog mints a PER-USE struct clone
                                        // at this folded bound (parent = the
                                        // constant's ref, member refs scoped at
                                        // the var, own logic ts at the member
                                        // ref) — NOT the shared $unit object.
                                        UHDM::typespec* sh0 = tIt0->second;
                                        std::string alias0 =
                                            std::string(rt0->VpiFullName()) +
                                            "." + std::string(ta0b.name);
                                        structCloneMemberRefParent = true;
                                        auto* scl0 = buildStructTs(
                                            ctb0.as<PackedStructType>(), true,
                                            alias0, ".");
                                        structCloneMemberRefParent = false;
                                        scl0->VpiName(ta0b.name);
                                        scl0->VpiParent(rt0);
                                        scl0->VpiFile(
                                            std::string(sh0->VpiFile()));
                                        scl0->VpiLineNo(sh0->VpiLineNo());
                                        scl0->VpiColumnNo(sh0->VpiColumnNo());
                                        scl0->VpiEndLineNo(sh0->VpiEndLineNo());
                                        scl0->VpiEndColumnNo(
                                            sh0->VpiEndColumnNo());
                                        structTs0 = scl0;
                                    }
                                }
                                if (auto* ini0 = psb0.getInitializer()) {
                                    auto& li0 = stripImplicitConv(*ini0);
                                    if (li0.kind ==
                                        ExpressionKind::IntegerLiteral) {
                                        setLoc(sc, li0.sourceRange);
                                        sc->VpiDecompile(
                                            rawText(li0.sourceRange));
                                    }
                                }
                            }
                        }
                    }
                    // Surelog attaches the folded dim constant's int_typespec
                    // ONLY when the sizing param is SIGNED (`int DEPTH` —
                    // issue326_packed_mem). An `int unsigned` sizing param
                    // (`int unsigned PMPNumChan` — hier_path) folds to a bare
                    // UINT constant with no typespec.
                    if (structTs0) {
                        rt0->Actual_typespec(structTs0);
                        sc->Typespec(rt0);
                    }
                    else if (sgn0) {
                        auto* its0 = s.MakeInt_typespec();
                        its0->VpiSigned(true);
                        rt0->Actual_typespec(its0);
                        sc->Typespec(rt0);
                    }
                    if (!be0.bad() &&
                        stripImplicitConv(be0).kind ==
                            ExpressionKind::MemberAccess &&
                        structTs0) {
                        // Skip the generic loc set below.
                        ops->push_back(sc);
                        auto* one0 = s.MakeConstant();
                        one0->VpiSize(64);
                        one0->VpiValue("INT:1");
                        one0->VpiConstType(vpiIntConst);
                        sc->VpiConstType(vpiUIntConst);
                        ops->push_back(one0);
                        op->Operands(ops);
                        r->Right_expr(op);
                        ranges->push_back(r);
                        dt = &ua.elementType;
                        continue;
                    }
                }
                else {
                    sc->VpiDecompile(rawText(sizeSyn->sourceRange()));
                    sc->VpiSize(64);
                    sc->VpiValue("UINT:" + std::to_string(ua.range.width()));
                }
                sc->VpiConstType(vpiUIntConst);
                setLoc(sc, sizeSyn->sourceRange());
                ops->push_back(sc);
                auto* one = s.MakeConstant();
                one->VpiSize(64);
                one->VpiValue("INT:1");
                one->VpiConstType(vpiIntConst);
                ops->push_back(one);
                op->Operands(ops);
                r->Right_expr(op);
                ranges->push_back(r);
                dt = &ua.elementType;
                continue;
            }
            auto mkBound = [&](int64_t val, const syntax::ExpressionSyntax* es) -> UHDM::expr* {
                // DEF-view unpacked PARAM dim ([IFN-1:0]) referencing an
                // OVERRIDDEN param: the bound stays a SYMBOLIC op11 with a
                // bare ref <param>.<bound> (param_array_wildcard).
                if (es && !defDimRefPrefix.empty() &&
                    parent->UhdmType() == UHDM::uhdmparameter) {
                    auto mkDimRef9 = [&](const syntax::ExpressionSyntax& is,
                                         UHDM::BaseClass* rp) {
                        auto* ro = s.MakeRef_obj();
                        std::string nm(is.as<syntax::IdentifierNameSyntax>()
                                           .identifier.valueText());
                        ro->VpiName(nm);
                        ro->VpiFullName(defDimRefPrefix + "." + nm);
                        ro->VpiParent(rp);
                        setLoc(ro, is.sourceRange());
                        return ro;
                    };
                    if (es->kind == syntax::SyntaxKind::IdentifierName)
                        return mkDimRef9(*es, r);
                    if (es->kind == syntax::SyntaxKind::SubtractExpression) {
                        auto& bs9 = es->as<syntax::BinaryExpressionSyntax>();
                        if (bs9.left->kind ==
                                syntax::SyntaxKind::IdentifierName &&
                            bs9.right->kind ==
                                syntax::SyntaxKind::IntegerLiteralExpression) {
                            auto* op9 = s.MakeOperation();
                            op9->VpiOpType(11);
                            op9->VpiParent(r);
                            setLoc(op9, es->sourceRange());
                            auto* ops9 = s.MakeAnyVec();
                            ops9->push_back(mkDimRef9(*bs9.left, op9));
                            auto* c9 = s.MakeConstant();
                            c9->VpiParent(op9);
                            c9->VpiDecompile(
                                rawText(bs9.right->sourceRange()));
                            c9->VpiSize(64);
                            c9->VpiValue(
                                "UINT:" +
                                std::string(
                                    rawText(bs9.right->sourceRange())));
                            c9->VpiConstType(vpiUIntConst);
                            setLoc(c9, bs9.right->sourceRange());
                            ops9->push_back(c9);
                            op9->Operands(ops9);
                            return (UHDM::expr*)op9;
                        }
                    }
                }
                // DEF-view array_net (interface/module def): a PARAM-based bound
                // ([0:DLY]) stays SYMBOLIC — a bare ref_obj <arraynet>.<param>
                // (no actual). The elab instance folds it to a constant.
                if (es && es->kind == syntax::SyntaxKind::IdentifierName &&
                    !defDimRefPrefix.empty() &&
                    parent->UhdmType() == UHDM::uhdmarray_net) {
                    auto* ro = s.MakeRef_obj();
                    std::string nm(es->as<syntax::IdentifierNameSyntax>()
                                       .identifier.valueText());
                    ro->VpiName(nm);
                    ro->VpiFullName(defDimRefPrefix + "." + nm);
                    ro->VpiParent(r);
                    setLoc(ro, es->sourceRange());
                    return ro;
                }
                // An ELAB array_net/array_var bound that is a bare PARAM
                // identifier ([0:DLY]) folds to a UINT constant (like a literal
                // bound), not the INT N-1 form — Surelog.
                bool arrParentIdBound =
                    es && es->kind == syntax::SyntaxKind::IdentifierName &&
                    (parent->UhdmType() == UHDM::uhdmarray_net ||
                     parent->UhdmType() == UHDM::uhdmarray_var) &&
                    // Only INTERFACE array bounds take the UINT form; module
                    // arrays keep the INT N-1 fold (blockrom).
                    parent->VpiParent() &&
                    parent->VpiParent()->UhdmType() ==
                        UHDM::uhdminterface_inst;
                // Literal / absent bounds: UINT at the token span. Non-literal
                // bounds (N-1) in module context fold to an INT constant
                // anchored at the top operator's LEFT operand span; in
                // function/typedef context they stay unfolded expressions.
                if (!arrParentIdBound && es &&
                    es->kind != syntax::SyntaxKind::IntegerLiteralExpression) {
                    if (tfContext) {
                        if (auto* e = emitSyntaxExpr(*es, r))
                            return (UHDM::expr*)e;
                    }
                    else {
                        auto* c = s.MakeConstant();
                        c->VpiParent(r);
                        c->VpiSize(64);
                        c->VpiConstType(vpiIntConst);
                        std::string digits = std::to_string(val);
                        c->VpiValue("INT:" + digits);
                        c->VpiDecompile(digits);
                        if (syntax::BinaryExpressionSyntax::isKind(es->kind))
                            setLoc(c, es->as<syntax::BinaryExpressionSyntax>().left->sourceRange());
                        else
                            setLoc(c, es->getFirstToken().range());
                        return c;
                    }
                }
                auto* c = s.MakeConstant();
                c->VpiParent(r);
                c->VpiDecompile(std::to_string(val));
                c->VpiSize(64);
                c->VpiValue("UINT:" + std::to_string(val));
                c->VpiConstType(vpiUIntConst);
                if (es)
                    setLoc(c, es->sourceRange());
                return c;
            };
            r->Left_expr(mkBound(ua.range.left, leftSyn));
            r->Right_expr(mkBound(ua.range.right, rightSyn));
            ranges->push_back(r);
            dt = &ua.elementType;
        }
    }
    if (ranges->empty())
        return nullptr;
    return ranges;
}

UHDM::array_var* UhdmExporter::emitArrayVar(const Symbol& sym, const std::string& name,
                                            const std::string& fullName, UHDM::BaseClass* m,
                                            UHDM::typespec* elemTs) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return nullptr;
    auto& ct = declared->getType().getCanonicalType();
    if (ct.kind != SymbolKind::FixedSizeUnpackedArrayType)
        return nullptr;

    // Leaf element type (for the inner reg's class and signedness).
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
        leaf = &leaf->getCanonicalType().as<FixedSizeUnpackedArrayType>().elementType;
    bool leafSigned = leaf->isSigned();

    auto* av = s.MakeArray_var();
    av->VpiName(name);
    av->VpiFullName(fullName);
    av->VpiParent(m);
    setLoc(av, nameSpan(sym.location, sym.name));
    if (leafSigned)
        av->VpiSigned(true);
    av->VpiRandType(1);
    av->VpiVisibility(1);
    av->VpiArrayType(1);

    // Total element count = product of the unpacked dimension widths —
    // PARAM-sized ([DEPTH]) dims contribute 1 (Surelog quirk).
    int32_t total = 1;
    {
        std::vector<const syntax::VariableDimensionSyntax*> dimSyns;
        if (auto dsyn0 = sym.getSyntax();
            dsyn0 && dsyn0->kind == syntax::SyntaxKind::Declarator)
            for (auto dim0 : dsyn0->as<syntax::DeclaratorSyntax>().dimensions)
                dimSyns.push_back(dim0);
        size_t di0 = 0;
        for (const Type* t = &declared->getType().getCanonicalType();
             t->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType;) {
            auto& ua = t->getCanonicalType().as<FixedSizeUnpackedArrayType>();
            bool paramSized = false;
            if (di0 < dimSyns.size() && dimSyns[di0]->specifier &&
                dimSyns[di0]->specifier->kind ==
                    syntax::SyntaxKind::RangeDimensionSpecifier) {
                auto& sel0 = *dimSyns[di0]
                                  ->specifier
                                  ->as<syntax::RangeDimensionSpecifierSyntax>()
                                  .selector;
                if (auto* bss0 = sel0.as_if<syntax::BitSelectSyntax>())
                    paramSized = bss0->expr->kind !=
                                 syntax::SyntaxKind::IntegerLiteralExpression;
            }
            if (!paramSized)
                total *= (int32_t)ua.range.width();
            t = &ua.elementType;
            di0++;
        }
    }
    av->VpiSize(total);

    // Ranges: one per unpacked dim.
    UHDM::VectorOfrange* avRanges = buildUnpackedRanges(sym, av);
    if (avRanges)
        av->Ranges(avRanges);

    // An ENUM- or packed-STRUCT-typedef unpacked-array element: the reg is an
    // enum_var / struct_var carrying the SHARED per-use enum_typespec /
    // struct_typespec clone (parented at the module, NOT the reg — Surelog).
    // Resolve the element alias's top/def clone.
    UHDM::typespec* aggElemTs = nullptr;
    bool enumElem = false, structElem = false;
    {
        auto lck = leaf->getCanonicalType().kind;
        if (lck == SymbolKind::EnumType || lck == SymbolKind::PackedStructType) {
            const Type* leafDecl = &declared->getType();
            while (leafDecl->getCanonicalType().kind ==
                   SymbolKind::FixedSizeUnpackedArrayType)
                leafDecl = &leafDecl->getCanonicalType()
                                .as<FixedSizeUnpackedArrayType>()
                                .elementType;
            if (leafDecl->kind == SymbolKind::TypeAlias) {
                auto& al = leafDecl->as<TypeAliasType>();
                auto want = lck == SymbolKind::EnumType
                                ? UHDM::uhdmenum_typespec
                                : UHDM::uhdmstruct_typespec;
                if (auto tit = pkgTopTypedefTs.find((const void*)&al);
                    tit != pkgTopTypedefTs.end() &&
                    tit->second->UhdmType() == want)
                    aggElemTs = tit->second;
                else if (auto tit2 = typedefTs.find(&al);
                         tit2 != typedefTs.end() &&
                         tit2->second->UhdmType() == want)
                    aggElemTs = tit2->second;
                if (aggElemTs) {
                    enumElem = lck == SymbolKind::EnumType;
                    structElem = !enumElem;
                }
            }
        }
    }

    // Inner reg: a var of the ELEMENT class (int/integer/logic) carrying the
    // element typespec (the shared net ts strips dims to the element span).
    UHDM::variables* reg;
    if (leaf->getCanonicalType().kind == SymbolKind::PredefinedIntegerType) {
        auto& pit = leaf->getCanonicalType().as<PredefinedIntegerType>();
        if (pit.integerKind == PredefinedIntegerType::Integer)
            reg = s.MakeInteger_var();
        else
            reg = s.MakeInt_var();
    }
    else if (enumElem) {
        reg = s.MakeEnum_var();
    }
    else if (structElem) {
        reg = s.MakeStruct_var();
    }
    else if (leaf->getCanonicalType().isIntegral() &&
             !leaf->getCanonicalType().isFourState()) {
        // 2-STATE (bit) element: bit_var SHARING the array's dim range
        // objects (Surelog).
        reg = s.MakeBit_var();
        if (avRanges)
            ((UHDM::bit_var*)reg)->Ranges(avRanges);
    }
    else {
        reg = s.MakeLogic_var();
    }
    reg->VpiParent(av);
    setLoc(reg, nameSpan(sym.location, sym.name));
    auto* regRt = s.MakeRef_typespec();
    regRt->VpiFullName(fullName);
    regRt->VpiParent(reg);
    if (aggElemTs) {
        // The shared aggregate clone keeps its module parent; only the ref
        // links to it.
        regRt->Actual_typespec(aggElemTs);
    }
    else {
        regRt->Actual_typespec(elemTs);
        elemTs->VpiParent(reg);
    }
    reg->Typespec(regRt);
    auto* rvars = s.MakeVariablesVec();
    rvars->push_back(reg);
    av->Variables(rvars);

    // Array-pattern initializer: emitted as vpiExpr parented at the inner
    // reg, referenced by BOTH the array_var and the reg.
    if (auto init = declared->getInitializer()) {
        auto& ic = stripImplicitConv(*init);
        if (ic.kind == ExpressionKind::SimpleAssignmentPattern ||
            ic.kind == ExpressionKind::ReplicatedAssignmentPattern ||
            ic.kind == ExpressionKind::StructuredAssignmentPattern) {
            NetMap none;
            // Array-pattern leaf constants stay unparented (only the nested
            // pattern operations self-parent).
            bool savedSCP = suppressConstParent;
            suppressConstParent = true;
            if (auto* e = emitExpr(ic, reg, fullName, none)) {
                av->Expr((UHDM::expr*)e);
                reg->Expr((UHDM::expr*)e);
            }
            suppressConstParent = savedSCP;
        }
    }

    // array_typespec (unlocated, no children) — created AFTER any pattern
    // init so its arena id follows the init's typespecs.
    auto* ats = s.MakeArray_typespec();
    auto* art = s.MakeRef_typespec();
    art->VpiFullName(fullName);
    art->VpiParent(av);
    art->Actual_typespec(ats);
    av->Typespec(art);
    return av;
}

// Root ValueSymbol of an lvalue expression (unwrapping selects / member
// access / conversions down to the base named/hierarchical reference).
static const Symbol* uaLvalueRoot(const Expression& e) {
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

// Whether `target` (or a select/member-access rooted at it) is the LHS of a
// CONTINUOUS assignment in `scope`, recursing into generate blocks. Surelog
// promotes a CONTINUOUSLY-driven unpacked-array-of-packed-struct signal to an
// array_var (hier_path's `csr_pmp_cfg_i` driven by `assign x[i].m = ...`); a
// signal driven only PROCEDURALLY (ucsbece154b's `dll_d`/`dll_q` written in
// always_comb) or undriven (OneStruct's dead `memArray[8]`) stays an
// array_net.
static bool uaScopeDrives(const Scope& scope, const Symbol& target) {
    for (auto& mem : scope.members()) {
        if (mem.kind == SymbolKind::ContinuousAssign) {
            auto& asn = mem.as<ContinuousAssignSymbol>().getAssignment();
            if (asn.kind == ExpressionKind::Assignment) {
                auto& ae = asn.as<AssignmentExpression>();
                if (uaLvalueRoot(ae.left()) == &target)
                    return true;
            }
        }
        else if (mem.kind == SymbolKind::GenerateBlock) {
            if (uaScopeDrives(mem.as<GenerateBlockSymbol>(), target))
                return true;
        }
        else if (mem.kind == SymbolKind::GenerateBlockArray) {
            for (auto& gb : mem.as<GenerateBlockArraySymbol>().entries)
                if (uaScopeDrives(*gb, target))
                    return true;
        }
    }
    return false;
}

bool UhdmExporter::unpackedArrayLeafIsNet(const Symbol& sym, bool portBacked) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return false;
    if (declared->getType().getCanonicalType().kind !=
        SymbolKind::FixedSizeUnpackedArrayType)
        return false;
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
        leaf = &leaf->getCanonicalType().as<FixedSizeUnpackedArrayType>().elementType;
    auto& lct = leaf->getCanonicalType();
    // Explicit variable-only leaves stay array_var.
    if (lct.kind == SymbolKind::EnumType || lct.kind == SymbolKind::FloatingType ||
        lct.kind == SymbolKind::StringType || lct.kind == SymbolKind::ClassType ||
        lct.kind == SymbolKind::PredefinedIntegerType ||
        lct.kind == SymbolKind::UnpackedStructType)
        return false;
    // A 4-state packed-struct unpacked array is a NET unless a continuous or
    // procedural assignment DRIVES it (a member/element select rooted at the
    // signal on some LHS), in which case Surelog promotes it to an array_var:
    //   - hier_path `csr_pmp_cfg_i[N]` driven by `assign x[i].m = ...` -> var
    //   - OneStruct dead `memArray[8]` (no driver) -> net
    // A declaration `= '{...}` initializer is a net-decl-assign, NOT a driver,
    // so `tl_h2d_t a[1:0] = '{...}` (IndexedPartSelectOfArrayElement) stays a
    // net.
    if (lct.kind == SymbolKind::PackedStructType) {
        if (!lct.isFourState())
            return false;
        if (auto* sc = sym.getParentScope())
            if (uaScopeDrives(*sc, sym))
                return false;
        return true;
    }
    // Any other 2-STATE integral leaf (bit scalars/vectors) can never be a
    // net — array_var (Surelog).
    if (lct.isIntegral() && !lct.isFourState())
        return false;
    // A 4-state logic/reg leaf mirrors makeVar's scalar carve-out: a non-port
    // `logic` VARIABLE is a var (array_var); a `reg`, or a plain ANSI port,
    // stays a net (array_net).
    if (lct.isIntegral() && lct.isFourState()) {
        bool regDecl = false;
        if (auto tsyn = declared->getTypeSyntax())
            regDecl = tsyn->kind == syntax::SyntaxKind::RegType;
        bool isVar = (!portBacked || hasBodyDecl(sym)) && !regDecl &&
                     sym.kind == SymbolKind::Variable;
        return !isVar;
    }
    return true;
}

// The NET form of an unpacked array whose leaf is a net-type (reg memory):
// array_net { vpiSize, vpiRange x N, vpiNet = logic_net(elemTs, netType) }.
// No array_typespec / rand / visibility (unlike array_var).
UHDM::array_net* UhdmExporter::emitArrayNet(const Symbol& sym, const std::string& name,
                                            const std::string& fullName, UHDM::BaseClass* m,
                                            UHDM::typespec* elemTs) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return nullptr;
    if (declared->getType().getCanonicalType().kind !=
        SymbolKind::FixedSizeUnpackedArrayType)
        return nullptr;

    auto* an = s.MakeArray_net();
    an->VpiName(name);
    an->VpiFullName(fullName);
    an->VpiParent(m);
    setLoc(an, nameSpan(sym.location, sym.name));

    // Total element count = product of unpacked dim widths (param-sized dims
    // contribute 1, matching array_var).
    int32_t total = 1;
    {
        std::vector<const syntax::VariableDimensionSyntax*> dimSyns;
        if (auto dsyn0 = sym.getSyntax();
            dsyn0 && dsyn0->kind == syntax::SyntaxKind::Declarator)
            for (auto dim0 : dsyn0->as<syntax::DeclaratorSyntax>().dimensions)
                dimSyns.push_back(dim0);
        size_t di0 = 0;
        for (const Type* t = &declared->getType().getCanonicalType();
             t->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType;) {
            auto& ua = t->getCanonicalType().as<FixedSizeUnpackedArrayType>();
            bool paramSized = false;
            if (di0 < dimSyns.size() && dimSyns[di0]->specifier &&
                dimSyns[di0]->specifier->kind ==
                    syntax::SyntaxKind::RangeDimensionSpecifier) {
                auto& sel0 = *dimSyns[di0]
                                  ->specifier
                                  ->as<syntax::RangeDimensionSpecifierSyntax>()
                                  .selector;
                if (auto* bss0 = sel0.as_if<syntax::BitSelectSyntax>())
                    paramSized = bss0->expr->kind !=
                                 syntax::SyntaxKind::IntegerLiteralExpression;
            }
            if (!paramSized)
                total *= (int32_t)ua.range.width();
            t = &ua.elementType;
            di0++;
        }
    }
    an->VpiSize(total);

    if (auto* ranges = buildUnpackedRanges(sym, an))
        an->Ranges(ranges);

    // A struct-element array (mem_s mem[8]) carries a struct_net element whose
    // fullname DOUBLES the signal name, referencing the shared struct_typespec.
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType)
        leaf = &leaf->getCanonicalType().as<FixedSizeUnpackedArrayType>().elementType;
    auto& lc = leaf->getCanonicalType();
    UHDM::typespec* structTs = nullptr;
    if (lc.kind == SymbolKind::PackedStructType) {
        for (auto& [s2, tsp] : typedefTs)
            if (s2->kind == SymbolKind::TypeAlias &&
                &s2->as<TypeAliasType>().getCanonicalType() == &lc) {
                structTs = tsp;
                break;
            }
        // ANONYMOUS packed-struct leaf (ucsbece154b `struct packed {...}
        // dll_d[4]`): there is no named typedef ts to share, but the element
        // typespec is itself a struct_typespec — use it directly so the
        // element is still a DOUBLED-name struct_net (not a flat logic_net).
        if (!structTs && elemTs &&
            elemTs->UhdmType() == UHDM::uhdmstruct_typespec)
            structTs = elemTs;
    }
    auto* nvec = s.MakeNetVec();
    if (structTs) {
        std::string dbl = fullName + "." + name;
        auto* sn = s.MakeStruct_net();
        sn->VpiParent(an);
        sn->VpiName(name);
        sn->VpiFullName(dbl);
        // The struct_net element spans the name through the FIRST unpacked
        // dim (Surelog quirk: multi-dim arrays still stop at dim 0's end).
        SourceLocation snEnd = sym.location + sym.name.size();
        if (auto dsyn = sym.getSyntax();
            dsyn && dsyn->kind == syntax::SyntaxKind::Declarator) {
            auto& dims = dsyn->as<syntax::DeclaratorSyntax>().dimensions;
            if (!dims.empty())
                snEnd = dims[0]->sourceRange().end();
        }
        setLoc(sn, SourceRange(sym.location, snEnd));
        auto* srt = s.MakeRef_typespec();
        srt->VpiParent(sn);
        srt->VpiFullName(dbl);
        srt->Actual_typespec(structTs);
        sn->Typespec(srt);
        nvec->push_back(sn);
    }
    else {
        auto* ln = s.MakeLogic_net();
        ln->VpiFullName(fullName);
        ln->VpiParent(an);
        setLoc(ln, nameSpan(sym.location, sym.name));
        if (leaf->isSigned())
            ln->VpiSigned(true);
        if (int32_t nt = netTypeFor(sym))
            ln->VpiNetType(nt);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(fullName);
        rt->VpiParent(ln);
        rt->Actual_typespec(elemTs);
        ln->Typespec(rt);
        elemTs->VpiParent(ln);
        nvec->push_back(ln);
    }
    an->Nets(nvec);
    return an;
}

UHDM::packed_array_var* UhdmExporter::emitVectorTypedefArrayVar(
    const Symbol& sym, const std::string& name, const std::string& fullName,
    UHDM::module_inst* m) {
    auto declared = sym.getDeclaredType();
    if (!declared)
        return nullptr;
    auto& dt = declared->getType();
    if (dt.kind != SymbolKind::PackedArrayType)
        return nullptr;
    // Collect the ARRAY dims down to the typedef-alias element.
    std::vector<ConstantRange> arrRanges;
    const Type* t2 = &dt;
    while (t2->kind == SymbolKind::PackedArrayType) {
        arrRanges.push_back(t2->as<PackedArrayType>().range);
        t2 = &t2->as<PackedArrayType>().elementType;
    }
    if (t2->kind != SymbolKind::TypeAlias)
        return nullptr;
    auto tit = typedefTs.find(t2);
    if (tit == typedefTs.end() ||
        tit->second->UhdmType() != UHDM::uhdmlogic_typespec)
        return nullptr;
    auto* pav = s.MakePacked_array_var();
    pav->VpiName(name);
    pav->VpiFullName(fullName);
    pav->VpiParent(m);
    setLoc(pav, nameSpan(sym.location, sym.name));
    pav->VpiVisibility(1);
    // The var ts binds a PLAIN named clone (name + ranges, NO alias, NO
    // Instance — Surelog's per-var bare clone), created here. The elab pass
    // ALSO creates an enriched anonymous array ts and a NAMED alias clone
    // (Typedef_alias -> shared, module-instanced).
    UHDM::typespec* plainCl = nullptr;
    {
        auto& elAl0 = t2->as<TypeAliasType>();
        const syntax::SyntaxNode* tgtSyn0 = nullptr;
        if (auto asyn0 = elAl0.getSyntax())
            if (asyn0->kind == syntax::SyntaxKind::TypedefDeclaration)
                tgtSyn0 = asyn0->as<syntax::TypedefDeclarationSyntax>().type;
        bypassTypedefShare = true;
        plainCl = makeTypespec(elAl0, tgtSyn0);
        bypassTypedefShare = false;
        plainCl->VpiName(elAl0.name);
    }
    (void)makeTypespec(sym);
    auto& elAl = t2->as<TypeAliasType>();
    const syntax::SyntaxNode* tgtSyn = nullptr;
    if (auto asyn = elAl.getSyntax())
        if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
            tgtSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
    bypassTypedefShare = true;
    auto* cl = makeTypespec(elAl, tgtSyn);
    bypassTypedefShare = false;
    cl->VpiName(elAl.name);
    auto* art = s.MakeRef_typespec();
    art->VpiFullName(std::string(elAl.name));
    art->VpiParent(cl);
    art->Actual_typespec(tit->second);
    ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
    cl->Instance((UHDM::instance*)m);
    auto* rt = s.MakeRef_typespec();
    rt->VpiFullName(fullName);
    rt->VpiParent(pav);
    rt->Actual_typespec(plainCl ? plainCl : tit->second);
    pav->Typespec(rt);
    // Dim spans scanned between the type-syntax start and the declarator.
    std::vector<DimSpan> spans;
    {
        SourceLocation tStart = sym.location;
        if (auto tsyn = declared->getTypeSyntax())
            tStart = tsyn->sourceRange().start();
        if (tStart < sym.location)
            spans = scanDimSpans(
                std::string(rawText(SourceRange(tStart, sym.location))), tStart);
    }
    auto* rvec = s.MakeRangeVec();
    for (size_t i = 0; i < arrRanges.size(); i++) {
        auto* r = s.MakeRange();
        r->VpiParent(pav);
        const DimSpan* ds = i < spans.size() ? &spans[i] : nullptr;
        if (ds)
            setLoc(r, ds->range);
        auto mkB = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
            auto* c = s.MakeConstant();
            std::string digits = std::to_string(v);
            c->VpiDecompile(digits);
            c->VpiSize(64);
            c->VpiValue("UINT:" + digits);
            c->VpiConstType(vpiUIntConst);
            c->VpiParent(r);
            if (loc)
                setLoc(c, *loc);
            return c;
        };
        r->Left_expr(mkB(arrRanges[i].left, ds ? &ds->left : nullptr));
        r->Right_expr(mkB(arrRanges[i].right, ds ? &ds->right : nullptr));
        rvec->push_back(r);
    }
    pav->Ranges(rvec);
    auto* ev = s.MakeLogic_var();
    ev->VpiParent(pav);
    ev->VpiFullName(fullName);
    auto* elems = s.MakeAnyVec();
    elems->push_back(ev);
    pav->Elements(elems);
    return pav;
}

UHDM::packed_array_var* UhdmExporter::emitPackedStructArrayVar(const Symbol& sym,
                                                               const std::string& name,
                                                               const std::string& fullName,
                                                               UHDM::module_inst* m) {
    auto declared = sym.getDeclaredType();
    if (!declared || !declared->getType().isPackedArray())
        return nullptr;
    // A signal declared straight from a PACKAGE packed-array typedef
    // (pkg::b c): bare packed_array_var referencing the SHARED named pkg
    // typespec — no inline ranges/elements (Surelog).
    if (declared->getType().kind == SymbolKind::TypeAlias) {
        auto& ta9 = declared->getType();
        if (auto ps9 = ta9.as<TypeAliasType>().getParentScope();
            ps9 && ps9->asSymbol().kind == SymbolKind::Package) {
            UHDM::typespec* sh9 = nullptr;
            if (auto i9 = pkgTopTypedefTs.find(&ta9);
                i9 != pkgTopTypedefTs.end() &&
                i9->second->UhdmType() == UHDM::uhdmpacked_array_typespec)
                sh9 = i9->second;
            else if (auto i8 = typedefTs.find(&ta9);
                     i8 != typedefTs.end() &&
                     i8->second->UhdmType() == UHDM::uhdmpacked_array_typespec)
                sh9 = i8->second;
            if (sh9) {
                auto* pav9 = s.MakePacked_array_var();
                pav9->VpiName(name);
                pav9->VpiFullName(fullName);
                pav9->VpiParent(m);
                setLoc(pav9, nameSpan(sym.location, sym.name));
                pav9->VpiVisibility(1);
                auto* rt9 = s.MakeRef_typespec();
                rt9->VpiFullName(fullName);
                rt9->VpiParent(pav9);
                rt9->Actual_typespec(sh9);
                pav9->Typespec(rt9);
                return pav9;
            }
        }
    }
    // Descend the packed dims to the leaf; it must be a shared struct or
    // enum typedef.
    int arrDims = 0;
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::PackedArrayType) {
        arrDims++;
        leaf = &leaf->getCanonicalType().as<PackedArrayType>().elementType;
    }
    auto& lc = leaf->getCanonicalType();
    if (lc.kind != SymbolKind::PackedStructType && lc.kind != SymbolKind::EnumType)
        return nullptr;
    UHDM::typespec* elemTs = nullptr;
    // Prefer the DECLARED alias (typedef lc_tx_e lc_tx_t used as elem type
    // resolves to lc_tx_t's clone, not the canonical enum's —
    // VarPassedTo2Submodules).
    {
        const Type* deE = &declared->getType();
        while (deE->kind != SymbolKind::TypeAlias &&
               deE->getCanonicalType().kind == SymbolKind::PackedArrayType)
            deE = &deE->getCanonicalType().as<PackedArrayType>().elementType;
        if (deE->kind == SymbolKind::TypeAlias &&
            &deE->getCanonicalType() != &lc) {
            auto& tgtE = deE->as<TypeAliasType>().targetType.getType();
            if (tgtE.getCanonicalType().kind == SymbolKind::PackedArrayType)
                deE = &tgtE.getCanonicalType()
                           .as<PackedArrayType>()
                           .elementType;
        }
        if (deE->kind == SymbolKind::TypeAlias &&
            &deE->getCanonicalType() == &lc)
            if (auto itE = typedefTs.find((const Symbol*)deE);
                itE != typedefTs.end())
                elemTs = itE->second;
    }
    if (!elemTs)
        for (auto& [s2, tsp] : typedefTs)
            if (s2->kind == SymbolKind::TypeAlias &&
                &s2->as<TypeAliasType>().getCanonicalType() == &lc) {
                elemTs = tsp;
                break;
            }
    if (!elemTs)
        return nullptr;

    // The packed ARRAY dims (outermost-first), collected from the type walk.
    std::vector<ConstantRange> arrRanges;
    {
        const Type* t2 = &declared->getType().getCanonicalType();
        for (int i = 0; i < arrDims; i++) {
            arrRanges.push_back(t2->getCanonicalType().as<PackedArrayType>().range);
            t2 = &t2->getCanonicalType().as<PackedArrayType>().elementType;
        }
    }

    auto* pav = s.MakePacked_array_var();
    pav->VpiName(name);
    pav->VpiFullName(fullName);
    pav->VpiParent(m);
    // Initialized vars span declarator..init; bare ones the name token.
    if (auto dsyn = sym.getSyntax(); dsyn && declared->getInitializer())
        setLoc(pav, dsyn->sourceRange());
    else
        setLoc(pav, nameSpan(sym.location, sym.name));
    pav->VpiVisibility(1);

    // One vpiRange per packed dim: UINT bounds located at the source dim
    // brackets (scanned between the type name and the declarator — named
    // types carry them in neither syntax node).
    std::vector<DimSpan> spans;
    if (auto tsn = declared->getTypeSyntax()) {
        auto tStart = tsn->sourceRange().start();
        if (tStart < sym.location)
            spans = scanDimSpans(std::string(rawText(SourceRange(tStart, sym.location))),
                                 tStart);
    }
    auto* rvec = s.MakeRangeVec();
    for (int i = 0; i < arrDims; i++) {
        auto* r = s.MakeRange();
        r->VpiParent(pav);
        auto mkBound = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
            auto* c = s.MakeConstant();
            std::string digits = std::to_string(v);
            c->VpiDecompile(digits);
            c->VpiSize(64);
            c->VpiValue("UINT:" + digits);
            c->VpiConstType(vpiUIntConst);
            // An ENUM-CONST bound folds SIGNED at the enum width in the
            // signal view (MultirangesStartNotFromZero [s_e:n_e]).
            if (loc) {
                std::string rawB(rawText(*loc));
                bool identB = !rawB.empty() &&
                              (isalpha((unsigned char)rawB[0]) ||
                               rawB[0] == '_');
                for (char chB : rawB)
                    if (!(isalnum((unsigned char)chB) || chB == '_')) {
                        identB = false;
                        break;
                    }
                if (identB)
                    if (auto* pscB = sym.getParentScope())
                        if (auto* bsB = pscB->find(rawB);
                            bsB && bsB->kind == SymbolKind::EnumValue) {
                            c->VpiValue("INT:" + digits);
                            c->VpiConstType(vpiIntConst);
                            c->VpiSize((int32_t)bsB->as<EnumValueSymbol>()
                                           .getType()
                                           .getBitWidth());
                        }
            }
            c->VpiParent(r);
            if (loc)
                setLoc(c, *loc);
            // A literal-arithmetic bound (1-1) folds with the FIRST digit
            // token's span only (Surelog).
            if (loc) {
                std::string rawB2(rawText(*loc));
                size_t d2 = rawB2.find('-');
                bool litSub2 = d2 != std::string::npos && d2 > 0;
                if (litSub2)
                    for (size_t p2 = 0; p2 < rawB2.size(); p2++)
                        if (p2 != d2 && !isdigit((unsigned char)rawB2[p2])) {
                            litSub2 = false;
                            break;
                        }
                if (litSub2) {
                    c->VpiEndColumnNo(c->VpiColumnNo() + (int32_t)d2);
                    // Arith folds encode INT (Surelog), size stays 64.
                    c->VpiValue("INT:" + std::string(c->VpiDecompile()));
                    c->VpiConstType(vpiIntConst);
                }
            }
            return c;
        };
        const DimSpan* ds = i < (int)spans.size() ? &spans[i] : nullptr;
        if (ds)
            setLoc(r, ds->range);
        r->Left_expr(mkBound(arrRanges[i].left, ds ? &ds->left : nullptr));
        r->Right_expr(mkBound(arrRanges[i].right, ds ? &ds->right : nullptr));
        rvec->push_back(r);
    }
    pav->Ranges(rvec);

    // vpiElement: a struct_var (or enum_var for enum leaves) referencing the
    // shared typedef typespec. When the element type is an ALIAS-OF-ALIAS
    // (typedef base_t; typedef base_t elem_t) Surelog emits a fresh element
    // CLONE whose fullname DOUBLES the signal name (work@m.sig.sig) and which
    // carries vpiName; a DIRECT enum/struct typedef keeps the single,
    // name-less element.
    bool aliasOfAlias = false;
    {
        const Type* de = &declared->getType();
        while (de->kind == SymbolKind::PackedArrayType)
            de = &de->as<PackedArrayType>().elementType;
        if (de->kind == SymbolKind::TypeAlias)
            aliasOfAlias = de->as<TypeAliasType>().targetType.getType().kind ==
                           SymbolKind::TypeAlias;
    }
    std::string elemFull = aliasOfAlias ? fullName + "." + name : fullName;
    UHDM::variables* sv = lc.kind == SymbolKind::EnumType
                              ? (UHDM::variables*)s.MakeEnum_var()
                              : (UHDM::variables*)s.MakeStruct_var();
    sv->VpiParent(pav);
    if (aliasOfAlias)
        sv->VpiName(name);
    sv->VpiFullName(elemFull);
    auto* srt = s.MakeRef_typespec();
    srt->VpiParent(sv);
    srt->VpiFullName(elemFull);
    srt->Actual_typespec(elemTs);
    sv->Typespec(srt);
    auto* elems = s.MakeAnyVec();
    elems->push_back(sv);
    pav->Elements(elems);

    // A pattern initializer becomes the var's vpiExpr: the operation is
    // parented at the ELEMENT struct_var (Surelog quirk), its literal
    // operands unparented.
    if (auto init = declared->getInitializer()) {
        bool savedS = suppressConstParent, savedF = forceConstParent;
        suppressConstParent = true;
        forceConstParent = false;
        NetMap noNets;
        if (auto* e = emitExpr(*init, sv, fullName, noNets)) {
            pav->Expr((UHDM::expr*)e);
            sv->Expr((UHDM::expr*)e);
            e->VpiParent(sv);
        }
        suppressConstParent = savedS;
        forceConstParent = savedF;
    }
    return pav;
}

// A packed array whose element is an enum (sp2v_e [1:0]) becomes a
// packed_array_var carrying one vpiRange per packed dim + a vpiElement
// enum_var. The typespec `ts` (already built by makeTypespec) supplies both
// the ranges (cloned with their source locs) and the shared enum_typespec.
UHDM::packed_array_var* UhdmExporter::makeEnumArrayVar(UHDM::typespec* ts,
                                                       const std::string& fullName,
                                                       UHDM::BaseClass* parent) {
    if (!ts || ts->UhdmType() != UHDM::uhdmpacked_array_typespec)
        return nullptr;
    auto* pat = (UHDM::packed_array_typespec*)ts;
    UHDM::typespec* elemTs = nullptr;
    if (auto* ert = pat->Elem_typespec())
        elemTs = ert->Actual_typespec();
    if (!elemTs || elemTs->UhdmType() != UHDM::uhdmenum_typespec)
        return nullptr;

    auto cloneLoc = [](UHDM::BaseClass* dst, const UHDM::BaseClass* src) {
        dst->VpiFile(src->VpiFile());
        dst->VpiLineNo(src->VpiLineNo());
        dst->VpiColumnNo(src->VpiColumnNo());
        dst->VpiEndLineNo(src->VpiEndLineNo());
        dst->VpiEndColumnNo(src->VpiEndColumnNo());
    };

    auto* pav = s.MakePacked_array_var();
    pav->VpiFullName(fullName);
    pav->VpiParent(parent);

    if (auto* prs = pat->Ranges()) {
        auto* rvec = s.MakeRangeVec();
        for (auto* pr : *prs) {
            auto* r = s.MakeRange();
            r->VpiParent(pav);
            cloneLoc(r, pr);
            auto cloneBound = [&](UHDM::expr* src) -> UHDM::expr* {
                auto* sc = (UHDM::constant*)src;
                auto* c = s.MakeConstant();
                c->VpiDecompile(sc->VpiDecompile());
                c->VpiSize(sc->VpiSize());
                c->VpiValue(sc->VpiValue());
                c->VpiConstType(sc->VpiConstType());
                c->VpiParent(r);
                cloneLoc(c, sc);
                return c;
            };
            if (pr->Left_expr())
                r->Left_expr(cloneBound(pr->Left_expr()));
            if (pr->Right_expr())
                r->Right_expr(cloneBound(pr->Right_expr()));
            rvec->push_back(r);
        }
        pav->Ranges(rvec);
    }

    auto* ev = s.MakeEnum_var();
    ev->VpiParent(pav);
    ev->VpiFullName(fullName);
    auto* ert = s.MakeRef_typespec();
    ert->VpiParent(ev);
    ert->VpiFullName(fullName);
    ert->Actual_typespec(elemTs);
    ev->Typespec(ert);
    auto* elems = s.MakeAnyVec();
    elems->push_back(ev);
    pav->Elements(elems);
    return pav;
}

// The NET form of a packed-array-of-struct (a child-instance PORT stays a
// net): packed_array_net (wire) + struct_net element whose fullname DOUBLES
// the signal name (work@m.d.sig.sig); the packed_array_typespec is shared
// unlocated.
UHDM::packed_array_net* UhdmExporter::emitPackedStructArrayNet(const Symbol& sym,
                                                               const std::string& name,
                                                               const std::string& fullName,
                                                               UHDM::module_inst* m) {
    auto declared = sym.getDeclaredType();
    if (!declared || !declared->getType().isPackedArray())
        return nullptr;
    int arrDims = 0;
    const Type* leaf = &declared->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::PackedArrayType) {
        arrDims++;
        leaf = &leaf->getCanonicalType().as<PackedArrayType>().elementType;
    }
    auto& lc = leaf->getCanonicalType();
    if (lc.kind != SymbolKind::PackedStructType)
        return nullptr;
    UHDM::typespec* elemTs = nullptr;
    for (auto& [s2, tsp] : typedefTs)
        if (s2->kind == SymbolKind::TypeAlias &&
            &s2->as<TypeAliasType>().getCanonicalType() == &lc) {
            elemTs = tsp;
            break;
        }
    if (!elemTs)
        return nullptr;

    std::vector<ConstantRange> arrRanges;
    {
        const Type* t2 = &declared->getType().getCanonicalType();
        for (int i = 0; i < arrDims; i++) {
            arrRanges.push_back(t2->getCanonicalType().as<PackedArrayType>().range);
            t2 = &t2->getCanonicalType().as<PackedArrayType>().elementType;
        }
    }

    auto* pan = s.MakePacked_array_net();
    pan->VpiName(name);
    pan->VpiFullName(fullName);
    pan->VpiParent(m);
    pan->VpiNetType(vpiWire);
    setLoc(pan, nameSpan(sym.location, sym.name));

    std::vector<DimSpan> spans;
    if (auto tsn = declared->getTypeSyntax()) {
        auto tStart = tsn->sourceRange().start();
        if (tStart < sym.location)
            spans = scanDimSpans(std::string(rawText(SourceRange(tStart, sym.location))),
                                 tStart);
    }
    auto* rvec = s.MakeRangeVec();
    for (int i = 0; i < arrDims; i++) {
        auto* r = s.MakeRange();
        r->VpiParent(pan);
        auto mkBound = [&](int64_t v, const SourceRange* loc) -> UHDM::expr* {
            auto* c = s.MakeConstant();
            std::string digits = std::to_string(v);
            c->VpiDecompile(digits);
            c->VpiSize(64);
            c->VpiValue("UINT:" + digits);
            c->VpiConstType(vpiUIntConst);
            // An ENUM-CONST bound folds SIGNED at the enum width in the
            // signal view (MultirangesStartNotFromZero [s_e:n_e]).
            if (loc) {
                std::string rawB(rawText(*loc));
                bool identB = !rawB.empty() &&
                              (isalpha((unsigned char)rawB[0]) ||
                               rawB[0] == '_');
                for (char chB : rawB)
                    if (!(isalnum((unsigned char)chB) || chB == '_')) {
                        identB = false;
                        break;
                    }
                if (identB)
                    if (auto* pscB = sym.getParentScope())
                        if (auto* bsB = pscB->find(rawB);
                            bsB && bsB->kind == SymbolKind::EnumValue) {
                            c->VpiValue("INT:" + digits);
                            c->VpiConstType(vpiIntConst);
                            c->VpiSize((int32_t)bsB->as<EnumValueSymbol>()
                                           .getType()
                                           .getBitWidth());
                        }
            }
            c->VpiParent(r);
            if (loc)
                setLoc(c, *loc);
            // A literal-arithmetic bound (1-1) folds with the FIRST digit
            // token's span only (Surelog).
            if (loc) {
                std::string rawB2(rawText(*loc));
                size_t d2 = rawB2.find('-');
                bool litSub2 = d2 != std::string::npos && d2 > 0;
                if (litSub2)
                    for (size_t p2 = 0; p2 < rawB2.size(); p2++)
                        if (p2 != d2 && !isdigit((unsigned char)rawB2[p2])) {
                            litSub2 = false;
                            break;
                        }
                if (litSub2) {
                    c->VpiEndColumnNo(c->VpiColumnNo() + (int32_t)d2);
                    // Arith folds encode INT (Surelog), size stays 64.
                    c->VpiValue("INT:" + std::string(c->VpiDecompile()));
                    c->VpiConstType(vpiIntConst);
                }
            }
            return c;
        };
        const DimSpan* ds = i < (int)spans.size() ? &spans[i] : nullptr;
        if (ds)
            setLoc(r, ds->range);
        r->Left_expr(mkBound(arrRanges[i].left, ds ? &ds->left : nullptr));
        r->Right_expr(mkBound(arrRanges[i].right, ds ? &ds->right : nullptr));
        rvec->push_back(r);
    }
    pan->Ranges(rvec);

    // vpiElement: a struct_net whose fullname DOUBLES the signal name.
    std::string dbl = fullName + "." + name;
    auto* sn = s.MakeStruct_net();
    sn->VpiParent(pan);
    sn->VpiName(name);
    sn->VpiFullName(dbl);
    auto* srt = s.MakeRef_typespec();
    srt->VpiParent(sn);
    srt->VpiFullName(dbl);
    srt->Actual_typespec(elemTs);
    sn->Typespec(srt);
    auto* elems = s.MakeAnyVec();
    elems->push_back(sn);
    pan->Elements(elems);
    return pan;
}

} // namespace slang_uhdm
