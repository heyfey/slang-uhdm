//------------------------------------------------------------------------------
//! @file TypeEmit.cpp
//! @brief Typespecs, bound constants, variable object creation
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

namespace slang_uhdm {

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
                auto dimList = declared->getResolvedDimensions();
                // The typespec span reaches the last packed dim's closing "]".
                SourceRange patLoc = range;
                auto* rvec = s.MakeRangeVec();
                for (int i = 0; i < arrDims && i < (int)dimList.size(); i++) {
                    auto& d = dimList[i];
                    auto* r = s.MakeRange();
                    r->VpiParent(pat);
                    auto mkBound = [&](int64_t v, const Expression* be) -> UHDM::expr* {
                        auto* c = s.MakeConstant();
                        std::string digits = std::to_string(v);
                        c->VpiDecompile(digits);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(r);
                        if (be)
                            setLoc(c, be->sourceRange);
                        return c;
                    };
                    if (d.leftExpr && d.rightExpr) {
                        setLoc(r, SourceRange(d.leftExpr->sourceRange.start() - 1,
                                              d.rightExpr->sourceRange.end() + 1));
                        patLoc = SourceRange(range.start(), d.rightExpr->sourceRange.end() + 1);
                    }
                    r->Left_expr(mkBound(d.range.left, d.leftExpr));
                    r->Right_expr(mkBound(d.range.right, d.rightExpr));
                    rvec->push_back(r);
                }
                pat->Ranges(rvec);
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

    auto* ts = s.MakeLogic_typespec();
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
                        if (tfContext) {
                            // Function/typedef context: unfolded expression.
                            if (auto* e = emitSyntaxExpr(*bsyn, r))
                                return (UHDM::expr*)e;
                        }
                        // Module context: folded to an INT constant anchored
                        // at the top operator's LEFT operand span.
                        auto* c = s.MakeConstant();
                        c->VpiParent(r);
                        c->VpiSize(64);
                        c->VpiConstType(vpiIntConst);
                        std::string digits = std::to_string(value);
                        c->VpiValue("INT:" + digits);
                        c->VpiDecompile(digits);
                        if (syntax::BinaryExpressionSyntax::isKind(bsyn->kind))
                            setLoc(c, bsyn->as<syntax::BinaryExpressionSyntax>()
                                          .left->sourceRange());
                        else
                            setLoc(c, bsyn->getFirstToken().range());
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
            noteUnsupported("packed array without integer type syntax: " +
                            std::string(declSymbol.name));
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
    if (ct.kind == SymbolKind::EnumType && internal.kind == SymbolKind::Variable) {
        auto* v = s.MakeEnum_var();
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
    // Packed structs become struct_nets (handled by the net branch).
    if (ct.kind == SymbolKind::PackedStructType)
        return nullptr;
    // A non-port logic variable, or a port with a separate `logic` body
    // redeclaration (input [3:0] a; logic [3:0] a;), is a logic_var; a plain
    // ANSI port stays a net.
    if ((!portBacked || hasBodyDecl(internal)) && !regDecl &&
        internal.kind == SymbolKind::Variable &&
        ct.kind != SymbolKind::PredefinedIntegerType && ct.isIntegral() && ct.isFourState()) {
        auto* v = s.MakeLogic_var();
        v->VpiVisibility(1);
        if (ct.isSigned())
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
            // Implicit value: INT at the base width (64 for implicit bases).
            std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
            value = "INT:" + digits;
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
                                                   const std::string& aliasName) {
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
        auto* fts = makeTypespec(fm, memberTypeSyn);
        // Fresh member typespecs parent at the member; shared typedef
        // typespecs (named) keep their own parent.
        if (fts->VpiName().empty())
            fts->VpiParent(tm);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(aliasName + "." + std::string(fm.name));
        rt->VpiParent(tm);
        rt->Actual_typespec(fts);
        tm->Typespec(rt);
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
            auto* sts = buildStructTs(ct.as<PackedStructType>(), true, std::string(ta.name));
            // Packed struct typespecs stay unparented; loc = the type syntax.
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
        else if (ct.kind == SymbolKind::PackedArrayType ||
                 ct.kind == SymbolKind::ScalarType) {
            // Vector/scalar typedefs: a NAMED logic_typespec at the target
            // type syntax, module parent + Instance.
            bypassTypedefShare = true;
            auto* lts = makeTypespec(ta, typeSyn);
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
    if (!tds->empty())
        m->Typespecs(tds);
}

// Maps binary expression syntax kinds to vpi op codes (range-bound exprs).
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
                ref->VpiFullName(syntaxRefPrefix + "." + std::string(name));
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
        case syntax::SyntaxKind::ParenthesizedExpression:
            return emitSyntaxExpr(*syn.as<syntax::ParenthesizedExpressionSyntax>().expression,
                                  parent);
        case syntax::SyntaxKind::InvocationExpression: {
            // Module-compile calls: name-only, unlinked.
            auto& inv = syn.as<syntax::InvocationExpressionSyntax>();
            auto* fc = s.MakeFunc_call();
            if (inv.left->kind == syntax::SyntaxKind::IdentifierName)
                fc->VpiName(
                    inv.left->as<syntax::IdentifierNameSyntax>().identifier.valueText());
            fc->VpiParent(parent);
            setLoc(fc, syn.sourceRange());
            return fc;
        }
        default: {
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
                sc->VpiDecompile(rawText(sizeSyn->sourceRange()));
                sc->VpiSize(64);
                sc->VpiValue("UINT:" + std::to_string(ua.range.width()));
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
                                            const std::string& fullName, UHDM::module_inst* m,
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

    // Total element count = product of the unpacked dimension widths.
    int32_t total = 1;
    for (const Type* t = &declared->getType().getCanonicalType();
         t->getCanonicalType().kind == SymbolKind::FixedSizeUnpackedArrayType;) {
        auto& ua = t->getCanonicalType().as<FixedSizeUnpackedArrayType>();
        total *= (int32_t)ua.range.width();
        t = &ua.elementType;
    }
    av->VpiSize(total);

    // array_typespec (unlocated, no children).
    auto* ats = s.MakeArray_typespec();
    auto* art = s.MakeRef_typespec();
    art->VpiFullName(fullName);
    art->VpiParent(av);
    art->Actual_typespec(ats);
    av->Typespec(art);

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
            ic.kind == ExpressionKind::ReplicatedAssignmentPattern) {
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
    return av;
}

} // namespace slang_uhdm
