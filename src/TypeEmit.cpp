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
                // one keeps the declaration span.
                bool pkgLeaf = false;
                for (auto sc0 = lc.getParentScope(); sc0;
                     sc0 = sc0->asSymbol().getParentScope())
                    if (sc0->asSymbol().kind == SymbolKind::Package) {
                        pkgLeaf = true;
                        break;
                    }
                if (!pkgLeaf)
                    setLoc(pat, patLoc);
                auto* ert = s.MakeRef_typespec();
                ert->VpiParent(pat);
                ert->Actual_typespec(elemTs);
                pat->Elem_typespec(ert);
                return pat;
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
                    SourceLocation e = su->keyword.range().end();
                    if (su->packed && su->packed.range().end() > e)
                        e = su->packed.range().end();
                    if (su->signing && su->signing.range().end() > e)
                        e = su->signing.range().end();
                    setLoc(sts, SourceRange(su->keyword.range().start(), e));
                }
                else
                    setLoc(sts, ssyn->sourceRange());
            }
            return sts;
        }
    }
    // 2-state (bit) vectors take a bit_typespec; 4-state stay logic.
    UHDM::typespec* ts0;
    if (declared && declared->getType().isIntegral() &&
        !declared->getType().getCanonicalType().isFourState())
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
                        if (tfContext || bitsOfSignal || bareParamInParamTs ||
                            defModuleParamDim) {
                            // Function/typedef context: unfolded expression.
                            if (auto* e = emitSyntaxExpr(*bsyn, r)) {
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
    // Enum variables — and PORTS typed by a PACKAGE enum typedef
    // (input custom::enum1 e) — elaborate as enum_vars.
    bool pkgEnumAlias = false;
    if (ct.kind == SymbolKind::EnumType) {
        auto& t0 = declared->getType();
        if (t0.kind == SymbolKind::TypeAlias)
            if (auto sc0 = t0.as<TypeAliasType>().getParentScope();
                sc0 && sc0->asSymbol().kind == SymbolKind::Package)
                pkgEnumAlias = true;
    }
    if (ct.kind == SymbolKind::EnumType &&
        (internal.kind == SymbolKind::Variable || pkgEnumAlias)) {
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
    if (ct.kind == SymbolKind::PackedUnionType &&
        internal.kind == SymbolKind::Variable) {
        if (declared->getType().kind == SymbolKind::PackedUnionType)
            return nullptr;
        auto* v = s.MakeUnion_var();
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
    if ((!portBacked || hasBodyDecl(internal) || pkgAliasPort) && !regDecl &&
        internal.kind == SymbolKind::Variable &&
        ct.kind != SymbolKind::PredefinedIntegerType && ct.isIntegral() && ct.isFourState()) {
        auto* v = s.MakeLogic_var();
        v->VpiVisibility(1);
        // TYPEDEF'd vars carry signedness on the shared typespec only.
        if (ct.isSigned() && declared->getType().kind != SymbolKind::TypeAlias)
            v->VpiSigned(true);
        return v;
    }
    if (ct.kind == SymbolKind::PredefinedIntegerType) {
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
        c->VpiDecompile(rawText(syn->sourceRange()));
    }
    return c;
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
        auto* bts = s.MakeLogic_typespec();
        if (et.baseType.isSigned())
            bts->VpiSigned(true);
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
            // Non-literal bounds (logic [W-1:0]) stay UNFOLDED in the enum
            // typedef's base typespec, like other typedef-context ranges.
            auto enumBound = [&](const syntax::ExpressionSyntax* bsyn,
                                 int64_t val) -> UHDM::expr* {
                if (bsyn && bsyn->kind != syntax::SyntaxKind::IntegerLiteralExpression)
                    if (auto* e = emitSyntaxExpr(*bsyn, r))
                        return (UHDM::expr*)e;
                return makeBoundConst(bsyn, val, r);
            };
            r->Left_expr(enumBound(lsyn, range.left));
            r->Right_expr(enumBound(rsyn, range.right));
            auto* rv = s.MakeRangeVec();
            rv->push_back(r);
            bts->Ranges(rv);
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
                            value = "DEC:" + digits;
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
    auto* members = s.MakeTypespec_memberVec();
    for (auto& fm : structScope.members()) {
        if (fm.kind != SymbolKind::Field)
            continue;
        auto* tm = s.MakeTypespec_member();
        tm->VpiName(fm.name);
        tm->VpiParent(sts);
        setLoc(tm, nameSpan(fm.location, fm.name));
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
        if (fm.getDeclaredType() &&
            fm.getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType)
            fts = s.MakeArray_typespec(); // bare (Surelog)
        else {
            // Typedef-context member bound refs scope through the member
            // (pkg::pkg::T::m::PARAM).
            std::string savedPfx = syntaxRefPrefix, savedSep = syntaxRefSep;
            if (tfContext && !aliasName.empty()) {
                syntaxRefPrefix = aliasName + memberSep + std::string(fm.name);
                syntaxRefSep = memberSep;
            }
            structMemberTsCtx = true;
            fts = makeTypespec(fm, memberTypeSyn);
            structMemberTsCtx = false;
            syntaxRefPrefix = savedPfx;
            syntaxRefSep = savedSep;
        }
        // Fresh member typespecs parent at the member; shared typedef
        // typespecs (named) keep their own parent. Elab param CLONES parent
        // them at the member's REF instead (Surelog clone form).
        if (fts->VpiName().empty())
            fts->VpiParent(tm);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(aliasName + memberSep + std::string(fm.name));
        rt->VpiParent(tm);
        rt->Actual_typespec(fts);
        tm->Typespec(rt);
        if (structCloneMemberRefParent && fts->VpiName().empty())
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
        const syntax::SyntaxNode* memberTypeSyn = nullptr;
        for (auto p2 = fm.getSyntax(); p2; p2 = p2->parent) {
            if (p2->kind == syntax::SyntaxKind::StructUnionMember) {
                memberTypeSyn = p2->as<syntax::StructUnionMemberSyntax>().type;
                break;
            }
        }
        UHDM::typespec* fts = nullptr;
        if (fm.getDeclaredType() &&
            fm.getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType)
            fts = s.MakeArray_typespec(); // bare (Surelog)
        else {
            // Typedef-context member bound refs scope through the member
            // (pkg::pkg::T::m::PARAM).
            std::string savedPfx = syntaxRefPrefix, savedSep = syntaxRefSep;
            if (tfContext && !aliasName.empty()) {
                syntaxRefPrefix = aliasName + memberSep + std::string(fm.name);
                syntaxRefSep = memberSep;
            }
            structMemberTsCtx = true;
            fts = makeTypespec(fm, memberTypeSyn);
            structMemberTsCtx = false;
            syntaxRefPrefix = savedPfx;
            syntaxRefSep = savedSep;
        }
        if (fts->VpiName().empty())
            fts->VpiParent(tm);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(aliasName + memberSep + std::string(fm.name));
        rt->VpiParent(tm);
        rt->Actual_typespec(fts);
        tm->Typespec(rt);
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
void UhdmExporter::emitTypedefs(const InstanceBodySymbol& body, UHDM::module_inst* m,
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
            // a NAMED array_typespec with the unpacked range(s).
            auto* ats = s.MakeArray_typespec();
            ats->VpiParent(m);
            if (auto syn = ta.getSyntax())
                setLoc(ats, syn->sourceRange());
            auto& fua = ct.as<FixedSizeUnpackedArrayType>();
            auto* rv = s.MakeRangeVec();
            auto* r = s.MakeRange();
            r->VpiParent(ats);
            auto mkB = [&](int64_t v) {
                auto* c = s.MakeConstant();
                std::string digits = std::to_string(v);
                c->VpiDecompile(digits);
                c->VpiSize(64);
                c->VpiValue("UINT:" + digits);
                c->VpiConstType(vpiUIntConst);
                c->VpiParent(r);
                return c;
            };
            r->Left_expr(mkB(fua.range.left));
            r->Right_expr(mkB(fua.range.right));
            // Range loc: the [N] dimension token from the declarator.
            if (auto dsyn = ta.getSyntax())
                setLoc(r, dsyn->sourceRange());
            rv->push_back(r);
            ats->Ranges(rv);
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
            UHDM::typespec* sts =
                enumLeaf
                    ? (UHDM::typespec*)buildEnumTs(leaf->getCanonicalType().as<EnumType>(),
                                                   esyn, ename)
                    : (UHDM::typespec*)buildStructTs(
                          leaf->getCanonicalType().as<PackedStructType>(), true, alias);
            if (enumLeaf) {
                sts->VpiName(ename);
                if (esyn)
                    setLoc(sts, esyn->sourceRange());
            }
            // struct_typespec loc = the `struct` keyword token.
            else if (typeSyn)
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
            ert->VpiFullName(alias);
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
            auto* ref = s.MakeRef_obj();
            auto name = syn.as<syntax::IdentifierNameSyntax>().identifier.valueText();
            ref->VpiName(name);
            if (!syntaxRefPrefix.empty())
                ref->VpiFullName(syntaxRefPrefix + syntaxRefSep + std::string(name));
            ref->VpiParent(parent);
            setLoc(ref, syn.sourceRange());
            return ref;
        }
        case syntax::SyntaxKind::IntegerLiteralExpression: {
            auto* c = s.MakeConstant();
            std::string raw = rawText(syn.sourceRange());
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
            auto* bs = s.MakeBit_select();
            bs->VpiName(bname);
            if (!syntaxRefPrefix.empty())
                bs->VpiFullName(syntaxRefPrefix + syntaxRefSep + std::string(bname));
            bs->VpiParent(parent);
            setLoc(bs, syn.sourceRange());
            if (sel && sel->kind == syntax::SyntaxKind::BitSelect)
                if (auto* ix = emitSyntaxExpr(
                        *sel->as<syntax::BitSelectSyntax>().expr, bs))
                    bs->VpiIndex((UHDM::expr*)ix);
            return bs;
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
                        auto* r = s.MakeRef_obj();
                        r->VpiName(rawText(arg->sourceRange()));
                        r->VpiParent(sfc);
                        setLoc(r, arg->sourceRange());
                        args->push_back(r);
                    }
                    if (!args->empty())
                        sfc->Tf_call_args(args);
                }
                return sfc;
            }
            // Module-compile calls: name-only, unlinked.
            auto* fc = s.MakeFunc_call();
            if (inv.left->kind == syntax::SyntaxKind::IdentifierName)
                fc->VpiName(
                    inv.left->as<syntax::IdentifierNameSyntax>().identifier.valueText());
            fc->VpiParent(parent);
            setLoc(fc, syn.sourceRange());
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
        default: {
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

UHDM::VectorOfrange* UhdmExporter::buildUnpackedRanges(const Symbol& sym,
                                                       UHDM::BaseClass* parent) {
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
                auto* sc = s.MakeConstant();
                sc->VpiParent(op);
                // A PARAM-sized dim ([DEPTH]) folds to the value at the
                // param's width, with a ts ref (loc-less signed int clone,
                // fullname = the var); literal sizes keep the raw text at 64.
                if (sizeSyn->kind != syntax::SyntaxKind::IntegerLiteralExpression &&
                    currentScope &&
                    parent->UhdmType() == UHDM::uhdmarray_var) {
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
                    rt0->VpiFullName(
                        std::string(((UHDM::array_var*)parent)->VpiFullName()));
                    rt0->VpiParent(sc);
                    auto* its0 = s.MakeInt_typespec();
                    if (sgn0)
                        its0->VpiSigned(true);
                    rt0->Actual_typespec(its0);
                    sc->Typespec(rt0);
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
                // Literal / absent bounds: UINT at the token span. Non-literal
                // bounds (N-1) in module context fold to an INT constant
                // anchored at the top operator's LEFT operand span; in
                // function/typedef context they stay unfolded expressions.
                if (es && es->kind != syntax::SyntaxKind::IntegerLiteralExpression) {
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
    if (auto* ranges = buildUnpackedRanges(sym, av))
        av->Ranges(ranges);

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
    else {
        reg = s.MakeLogic_var();
    }
    reg->VpiParent(av);
    setLoc(reg, nameSpan(sym.location, sym.name));
    auto* regRt = s.MakeRef_typespec();
    regRt->VpiFullName(fullName);
    regRt->VpiParent(reg);
    regRt->Actual_typespec(elemTs);
    reg->Typespec(regRt);
    elemTs->VpiParent(reg);
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
    // A 4-state packed struct is a net; a 2-state one is a var.
    if (lct.kind == SymbolKind::PackedStructType)
        return lct.isFourState();
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
    if (lc.kind == SymbolKind::PackedStructType)
        for (auto& [s2, tsp] : typedefTs)
            if (s2->kind == SymbolKind::TypeAlias &&
                &s2->as<TypeAliasType>().getCanonicalType() == &lc) {
                structTs = tsp;
                break;
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

UHDM::packed_array_var* UhdmExporter::emitPackedStructArrayVar(const Symbol& sym,
                                                               const std::string& name,
                                                               const std::string& fullName,
                                                               UHDM::module_inst* m) {
    auto declared = sym.getDeclaredType();
    if (!declared || !declared->getType().isPackedArray())
        return nullptr;
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
            c->VpiParent(r);
            if (loc)
                setLoc(c, *loc);
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
    // shared typedef typespec.
    UHDM::variables* sv = lc.kind == SymbolKind::EnumType
                              ? (UHDM::variables*)s.MakeEnum_var()
                              : (UHDM::variables*)s.MakeStruct_var();
    sv->VpiParent(pav);
    sv->VpiFullName(fullName);
    auto* srt = s.MakeRef_typespec();
    srt->VpiParent(sv);
    srt->VpiFullName(fullName);
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
            c->VpiParent(r);
            if (loc)
                setLoc(c, *loc);
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
