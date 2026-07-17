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

    // Non-logic types get their own typespec classes.
    if (declared) {
        auto& ct = declared->getType().getCanonicalType();
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
    if (declared && declared->getType().isSigned())
        ts->VpiSigned(true);
    setLoc(ts, range);

    // Packed dimensions: one uhdm range per dimension, bounds as evaluated
    // UINT constants (64-bit) that keep their source text as decompile.
    // Dims live on IntegerTypeSyntax ("logic [7:0]") or ImplicitTypeSyntax
    // ("input [7:0] a" / "wire [7:0] w").
    if (declared && declared->getType().isPackedArray()) {
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
                        // at the bound expression's first token.
                        auto* c = s.MakeConstant();
                        c->VpiParent(r);
                        c->VpiSize(64);
                        c->VpiConstType(vpiIntConst);
                        std::string digits = std::to_string(value);
                        c->VpiValue("INT:" + digits);
                        c->VpiDecompile(digits);
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
            noteUnsupported("packed array without integer type syntax");
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
    if (!portBacked && !regDecl && internal.kind == SymbolKind::Variable &&
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

} // namespace slang_uhdm
