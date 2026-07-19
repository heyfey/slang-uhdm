//------------------------------------------------------------------------------
//! @file EmitHelpers.h
//! @brief File-local helpers shared by the UhdmExporter translation units
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#pragma once

#include <uhdm/uhdm.h>

#include "slang/ast/ASTVisitor.h"
#include "slang/ast/Compilation.h"
#include "slang/ast/TimingControl.h"
#include "slang/ast/expressions/AssignmentExpressions.h"
#include "slang/ast/expressions/CallExpression.h"
#include "slang/ast/expressions/ConversionExpression.h"
#include "slang/ast/expressions/LiteralExpressions.h"
#include "slang/ast/expressions/MiscExpressions.h"
#include "slang/ast/expressions/OperatorExpressions.h"
#include "slang/ast/expressions/SelectExpressions.h"
#include "slang/ast/statements/ConditionalStatements.h"
#include "slang/ast/statements/LoopStatements.h"
#include "slang/ast/statements/MiscStatements.h"
#include "slang/ast/symbols/CompilationUnitSymbols.h"
#include "slang/ast/symbols/InstanceSymbols.h"
#include "slang/ast/symbols/MemberSymbols.h"
#include "slang/ast/symbols/ParameterSymbols.h"
#include "slang/ast/symbols/PortSymbols.h"
#include "slang/ast/symbols/SubroutineSymbols.h"
#include "slang/ast/symbols/VariableSymbols.h"
#include "slang/ast/types/AllTypes.h"
#include "slang/ast/types/Type.h"
#include "slang/syntax/AllSyntax.h"
#include "slang/text/SourceManager.h"

namespace slang_uhdm {

using namespace slang;
using namespace slang::ast;

inline constexpr int kVpiAssignmentOp = 82; // sv_vpi_user.h vpiAssignmentOp

// ANSI net-port headers ("input wire x") and non-ANSI net-port
// declarations ("input wire signed inp;") carry the net keyword token.
// True when a body net was declared with an explicit net-type keyword
// ("wire x", "tri y") rather than an implicit type ("logic z").
inline bool hasExplicitNetKeyword(const Symbol& sym) {
    if (sym.kind != SymbolKind::Net)
        return false;
    for (auto p = sym.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::NetDeclaration)
            return p->as<syntax::NetDeclarationSyntax>().netType.valid();
        if (p->kind == syntax::SyntaxKind::DataDeclaration)
            return false;
    }
    return false;
}

inline const syntax::NetPortHeaderSyntax* ansiNetHeader(const Symbol& internal) {
    for (auto p = internal.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::ImplicitAnsiPort) {
            auto& ap = p->as<syntax::ImplicitAnsiPortSyntax>();
            if (ap.header->kind == syntax::SyntaxKind::NetPortHeader) {
                auto& nh = ap.header->as<syntax::NetPortHeaderSyntax>();
                if (nh.netType.valid())
                    return &nh;
            }
            return nullptr;
        }
        if (p->kind == syntax::SyntaxKind::PortDeclaration) {
            auto& pd = p->as<syntax::PortDeclarationSyntax>();
            if (pd.header->kind == syntax::SyntaxKind::NetPortHeader) {
                auto& nh = pd.header->as<syntax::NetPortHeaderSyntax>();
                if (nh.netType.valid())
                    return &nh;
            }
            return nullptr;
        }
    }
    return nullptr;
}

// Surelog derives vpiNetType from the declared type keyword: explicit
// `logic` -> vpiNet, `reg` -> vpiReg, implicit -> unset; explicit net
// keywords map to their vpi net types.
inline int32_t netTypeFor(const Symbol& internal) {
    if (internal.kind == SymbolKind::Net) {
        // Implicitly-declared nets (created by an undeclared name in an assign
        // or port connection) print as a bare wire.
        if (internal.as<NetSymbol>().isImplicit)
            return vpiWire;
        // Explicit net declarations ("wire w;") and ANSI net-port headers
        // ("input wire x") carry the net kind; implicit port-backed nets do
        // not print a net type.
        auto& nt = internal.as<NetSymbol>().netType;
        bool explicitDecl = ansiNetHeader(internal) != nullptr;
        for (auto p = internal.getSyntax(); !explicitDecl && p; p = p->parent) {
            if (p->kind == syntax::SyntaxKind::NetDeclaration) {
                explicitDecl = true;
                break;
            }
        }
        if (explicitDecl) {
            switch (nt.netKind) {
                case NetType::Wire:
                    return vpiWire;
                case NetType::WAnd:
                    return vpiWand;
                case NetType::WOr:
                    return vpiWor;
                case NetType::Tri:
                    return vpiTri;
                default:
                    break;
            }
        }
    }
    if (auto declared = internal.getDeclaredType()) {
        if (auto tsyn = declared->getTypeSyntax()) {
            if (tsyn->kind == syntax::SyntaxKind::LogicType)
                return vpiNet;
            if (tsyn->kind == syntax::SyntaxKind::RegType)
                return vpiReg;
            // Typedefs of plain logic vectors keep the logic net type —
            // except PACKAGE typedefs, which print none (their ports become
            // logic_vars in the elab view).
            if (tsyn->kind == syntax::SyntaxKind::NamedType) {
                auto& t = declared->getType();
                auto& ct = t.getCanonicalType();
                if ((ct.kind == SymbolKind::PackedArrayType ||
                     ct.kind == SymbolKind::ScalarType) &&
                    ct.isFourState()) {
                    if (t.kind == SymbolKind::TypeAlias)
                        if (auto sc = t.as<TypeAliasType>().getParentScope();
                            sc && sc->asSymbol().kind == SymbolKind::Package)
                            return 0;
                    return vpiNet;
                }
            }
        }
    }
    return 0;
}

inline int32_t mapUnaryOp(UnaryOperator op) {
    switch (op) {
        case UnaryOperator::Plus:
            return vpiPlusOp;
        case UnaryOperator::Minus:
            return vpiMinusOp;
        case UnaryOperator::BitwiseNot:
            return vpiBitNegOp;
        case UnaryOperator::BitwiseAnd:
            return vpiUnaryAndOp;
        case UnaryOperator::BitwiseOr:
            return vpiUnaryOrOp;
        case UnaryOperator::BitwiseXor:
            return vpiUnaryXorOp;
        case UnaryOperator::BitwiseNand:
            return vpiUnaryNandOp;
        case UnaryOperator::BitwiseNor:
            return vpiUnaryNorOp;
        case UnaryOperator::BitwiseXnor:
            return vpiUnaryXNorOp;
        case UnaryOperator::LogicalNot:
            return vpiNotOp;
        case UnaryOperator::Preincrement:
            return vpiPreIncOp;
        case UnaryOperator::Postincrement:
            return vpiPostIncOp;
        case UnaryOperator::Predecrement:
            return vpiPreDecOp;
        case UnaryOperator::Postdecrement:
            return vpiPostDecOp;
        default:
            return 0;
    }
}

inline int32_t mapBinaryOp(BinaryOperator op) {
    switch (op) {
        case BinaryOperator::Add:
            return vpiAddOp;
        case BinaryOperator::Subtract:
            return vpiSubOp;
        case BinaryOperator::Multiply:
            return vpiMultOp;
        case BinaryOperator::Divide:
            return vpiDivOp;
        case BinaryOperator::Mod:
            return vpiModOp;
        case BinaryOperator::BinaryAnd:
            return vpiBitAndOp;
        case BinaryOperator::BinaryOr:
            return vpiBitOrOp;
        case BinaryOperator::BinaryXor:
            return vpiBitXorOp;
        case BinaryOperator::BinaryXnor:
            return vpiBitXNorOp;
        case BinaryOperator::Equality:
            return vpiEqOp;
        case BinaryOperator::Inequality:
            return vpiNeqOp;
        case BinaryOperator::CaseEquality:
            return vpiCaseEqOp;
        case BinaryOperator::CaseInequality:
            return vpiCaseNeqOp;
        case BinaryOperator::GreaterThanEqual:
            return vpiGeOp;
        case BinaryOperator::GreaterThan:
            return vpiGtOp;
        case BinaryOperator::LessThanEqual:
            return vpiLeOp;
        case BinaryOperator::LessThan:
            return vpiLtOp;
        case BinaryOperator::WildcardEquality:
            return vpiWildEqOp;
        case BinaryOperator::WildcardInequality:
            return vpiWildNeqOp;
        case BinaryOperator::LogicalAnd:
            return vpiLogAndOp;
        case BinaryOperator::LogicalOr:
            return vpiLogOrOp;
        case BinaryOperator::LogicalImplication:
            return vpiImplyOp;
        case BinaryOperator::LogicalShiftLeft:
            return vpiLShiftOp;
        case BinaryOperator::LogicalShiftRight:
            return vpiRShiftOp;
        case BinaryOperator::ArithmeticShiftLeft:
            return vpiArithLShiftOp;
        case BinaryOperator::ArithmeticShiftRight:
            return vpiArithRShiftOp;
        case BinaryOperator::Power:
            return vpiPowerOp;
        default:
            return 0;
    }
}

// Collects one representative instance per definition, recursively.
inline void collectDefs(const InstanceBodySymbol& body,
                        std::map<std::string, const InstanceSymbol*>& defs) {
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::Instance) {
            auto& child = member.as<InstanceSymbol>();
            auto name = std::string(child.getDefinition().name);
            if (defs.emplace(name, &child).second)
                collectDefs(child.body, defs);
        }
    }
}

// Finds the named port connection syntax for a formal port name, so locations
// can anchor at the ".a(o)" text like Surelog.
inline const syntax::NamedPortConnectionSyntax* findConnSyntax(const InstanceSymbol& inst,
                                                               std::string_view formal) {
    auto syn = inst.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::HierarchicalInstance)
        return nullptr;
    for (auto conn : syn->as<syntax::HierarchicalInstanceSyntax>().connections) {
        if (conn->kind == syntax::SyntaxKind::NamedPortConnection) {
            auto& npc = conn->as<syntax::NamedPortConnectionSyntax>();
            if (npc.name.valueText() == formal)
                return &npc;
        }
    }
    return nullptr;
}

// True when a parameter's bound initializer is an instance override (its
// syntax differs from the declaration-default initializer syntax).
inline const syntax::ExpressionSyntax* paramDefaultSyn(const ParameterSymbol& ps) {
    if (auto dsyn = ps.getSyntax()) {
        if (dsyn->kind == syntax::SyntaxKind::Declarator) {
            auto& dd = dsyn->as<syntax::DeclaratorSyntax>();
            if (dd.initializer)
                return dd.initializer->expr;
        }
    }
    return nullptr;
}
inline bool isOverriddenParam(const Symbol& sym) {
    if (sym.kind != SymbolKind::Parameter)
        return false;
    auto& ps = sym.as<ParameterSymbol>();
    auto* defaultSyn = paramDefaultSyn(ps);
    auto* bi = ps.getInitializer();
    if (!bi || !defaultSyn)
        return false;
    if (bi->syntax && bi->syntax != defaultSyn)
        return true;
    // Fallback: the bound init's tokens come from somewhere else entirely.
    auto br = bi->sourceRange;
    auto dr = defaultSyn->sourceRange();
    return br.start() != SourceLocation::NoLocation &&
           dr.start() != SourceLocation::NoLocation && br.start() != dr.start() &&
           br.end() != dr.end();
}

// Data-type syntax kinds that can appear as a cast target.
inline bool isTypeSyntaxKind(syntax::SyntaxKind k) {
    switch (k) {
        case syntax::SyntaxKind::LogicType:
        case syntax::SyntaxKind::BitType:
        case syntax::SyntaxKind::RegType:
        case syntax::SyntaxKind::ByteType:
        case syntax::SyntaxKind::ShortIntType:
        case syntax::SyntaxKind::IntType:
        case syntax::SyntaxKind::LongIntType:
        case syntax::SyntaxKind::IntegerType:
        case syntax::SyntaxKind::TimeType:
        case syntax::SyntaxKind::ShortRealType:
        case syntax::SyntaxKind::RealType:
        case syntax::SyntaxKind::RealTimeType:
        case syntax::SyntaxKind::StructType:
        case syntax::SyntaxKind::UnionType:
        case syntax::SyntaxKind::EnumType:
            return true;
        default:
            return false;
    }
}

// True when the instance's connection list is positional (ordered).
inline bool hasOrderedConns(const InstanceSymbol& inst) {
    auto syn = inst.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::HierarchicalInstance)
        return false;
    for (auto conn : syn->as<syntax::HierarchicalInstanceSyntax>().connections)
        if (conn->kind == syntax::SyntaxKind::OrderedPortConnection)
            return true;
    return false;
}

// True when the expression tree contains anything Surelog's netlist
// elaboration would re-compile as an operation (which forces a fresh
// cont_assign object in the instance view instead of sharing the def's).
inline bool containsOperation(const Expression& expr) {
    switch (expr.kind) {
        case ExpressionKind::UnaryOp:
        case ExpressionKind::BinaryOp:
        case ExpressionKind::ConditionalOp:
        case ExpressionKind::Concatenation:
        case ExpressionKind::Replication:
            return true;
        case ExpressionKind::Conversion: {
            auto& conv = expr.as<ConversionExpression>();
            if (!conv.isImplicit())
                return true;
            return containsOperation(conv.operand());
        }
        case ExpressionKind::Call: {
            // User function calls are reused as-is; sys calls inside
            // recompiled expressions force a fresh cont_assign - except the
            // transparent signedness casts $signed/$unsigned, which are shared.
            auto& call = expr.as<CallExpression>();
            if (!call.isSystemCall())
                return false;
            auto n = call.getSubroutineName();
            return n != "$signed" && n != "$unsigned";
        }
        case ExpressionKind::SimpleAssignmentPattern:
        case ExpressionKind::StructuredAssignmentPattern:
            return true;
        default:
            return false;
    }
}

// Port connection expressions for output ports come wrapped in an assignment;
// the connected expression is its left side.
inline const Expression* connectionExpr(const PortConnection& conn) {
    auto expr = conn.getExpression();
    if (expr && expr->kind == ExpressionKind::Assignment)
        expr = &expr->as<AssignmentExpression>().left();
    return expr;
}

// Refs inside package scopes keep :: separators all the way down.
inline std::string joinRef(const std::string& prefix, std::string_view name) {
    if (prefix.size() >= 2 && prefix.compare(prefix.size() - 2, 2, "::") == 0)
        return prefix + std::string(name);
    if (prefix.find("::") != std::string::npos)
        return prefix + "::" + std::string(name);
    return prefix + "." + std::string(name);
}

inline std::string joinPath(const std::string& prefix, std::string_view name) {
    if (prefix.size() >= 2 && prefix.compare(prefix.size() - 2, 2, "::") == 0)
        return prefix + std::string(name);
    return prefix + "." + std::string(name);
}

// The location Surelog gives a typespec: the declared type's syntax range for
// explicit types, or a zero-width range at the declaration's *first*
// declarator for implicit types (shared across all declarators).
inline SourceLocation firstDeclaratorLoc(const Symbol& sym) {
    for (auto p = sym.getSyntax(); p; p = p->parent) {
        const syntax::SeparatedSyntaxList<syntax::DeclaratorSyntax>* decls = nullptr;
        if (p->kind == syntax::SyntaxKind::PortDeclaration)
            decls = &p->as<syntax::PortDeclarationSyntax>().declarators;
        else if (p->kind == syntax::SyntaxKind::NetDeclaration)
            decls = &p->as<syntax::NetDeclarationSyntax>().declarators;
        else if (p->kind == syntax::SyntaxKind::DataDeclaration)
            decls = &p->as<syntax::DataDeclarationSyntax>().declarators;
        if (decls && !decls->empty())
            return (*decls)[0]->name.location();

        // ANSI header groups ("input clk, clr"): anchor at the first port of
        // the group (the one that carries the direction token).
        if (p->kind == syntax::SyntaxKind::ImplicitAnsiPort && p->parent) {
            auto& list = *p->parent;
            const syntax::ImplicitAnsiPortSyntax* groupStart = nullptr;
            for (size_t i = 0; i < list.getChildCount(); i++) {
                auto child = list.childNode(i);
                if (!child || child->kind != syntax::SyntaxKind::ImplicitAnsiPort)
                    continue;
                auto& ap = child->as<syntax::ImplicitAnsiPortSyntax>();
                bool hasHeaderTokens = false;
                if (ap.header->kind == syntax::SyntaxKind::VariablePortHeader) {
                    auto& vh = ap.header->as<syntax::VariablePortHeaderSyntax>();
                    hasHeaderTokens = vh.direction.valid() || vh.varKeyword.valid() ||
                                      vh.dataType->kind != syntax::SyntaxKind::ImplicitType;
                }
                else {
                    hasHeaderTokens = true;
                }
                if (hasHeaderTokens || !groupStart)
                    groupStart = &ap;
                if (child == p)
                    return groupStart->declarator->name.location();
            }
        }
    }
    return sym.location;
}

// Surelog's net collection order: nets from body net/data declarations and
// ANSI headers sort by declaration location; nets declared only through
// non-ANSI port declarations append afterwards in port-list order.
inline bool hasBodyDecl(const Symbol& sym) {
    for (auto p = sym.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::NetDeclaration ||
            p->kind == syntax::SyntaxKind::DataDeclaration)
            return true;
        if (p->kind == syntax::SyntaxKind::PortDeclaration ||
            p->kind == syntax::SyntaxKind::ImplicitAnsiPort)
            return false;
    }
    return false;
}

inline bool hasExplicitDeclLoc(const Symbol& sym) {
    for (auto p = sym.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::NetDeclaration ||
            p->kind == syntax::SyntaxKind::DataDeclaration ||
            p->kind == syntax::SyntaxKind::ImplicitAnsiPort)
            return true;
        if (p->kind == syntax::SyntaxKind::PortDeclaration)
            return false;
    }
    return false;
}

struct NetOrderItem {
    const Symbol* sym;
    const PortSymbol* port;
    bool bodyDecl;
};

// An interface handled by the interface_inst path: variables/nets/parameters/
// ports/cont-assigns/processes are supported; child instances, generate, and
// modports still fall through to the (incomplete) module_inst path.
inline bool isSimpleInterfaceBody(const InstanceBodySymbol& body) {
    for (auto& m : body.members()) {
        switch (m.kind) {
            case SymbolKind::Instance:
            case SymbolKind::GenerateBlock:
            case SymbolKind::GenerateBlockArray:
                return false;
            default:
                break;
        }
    }
    return true;
}

inline bool useInterfacePath(const InstanceSymbol& inst) {
    return inst.isInterface() && isSimpleInterfaceBody(inst.body);
}

// Cont_assigns/Process/Ports/Gen_scope_arrays are declared separately (same
// signature) on module_inst and interface_inst, not on the common `instance`
// base. These dispatch the setter on the runtime type so emission code can be
// written against instance*.
inline void instSetContAssigns(UHDM::instance* m, UHDM::VectorOfcont_assign* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Cont_assigns(v);
    else
        ((UHDM::module_inst*)m)->Cont_assigns(v);
}
inline void instSetProcess(UHDM::instance* m, UHDM::VectorOfprocess_stmt* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Process(v);
    else
        ((UHDM::module_inst*)m)->Process(v);
}
inline void instSetPorts(UHDM::instance* m, UHDM::VectorOfport* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Ports(v);
    else
        ((UHDM::module_inst*)m)->Ports(v);
}
inline void instSetGenScopeArrays(UHDM::instance* m, UHDM::VectorOfgen_scope_array* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Gen_scope_arrays(v);
    else
        ((UHDM::module_inst*)m)->Gen_scope_arrays(v);
}

inline std::vector<NetOrderItem> collectNetOrder(const InstanceBodySymbol& body) {
    std::vector<NetOrderItem> sorted, implicitPorts;
    std::set<const Symbol*> portInternals;
    for (auto pb : body.getPortList()) {
        if (pb->kind != SymbolKind::Port)
            continue;
        auto& ps = pb->as<PortSymbol>();
        if (!ps.internalSymbol)
            continue;
        portInternals.insert(ps.internalSymbol);
        NetOrderItem it{ps.internalSymbol, &ps, hasBodyDecl(*ps.internalSymbol)};
        if (it.bodyDecl || hasExplicitDeclLoc(*ps.internalSymbol))
            sorted.push_back(it);
        else
            implicitPorts.push_back(it);
    }
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Net && member.kind != SymbolKind::Variable)
            continue;
        if (portInternals.count(&member))
            continue;
        sorted.push_back({&member, nullptr, true});
    }
    std::stable_sort(sorted.begin(), sorted.end(), [](const NetOrderItem& a,
                                                      const NetOrderItem& b) {
        return a.sym->location < b.sym->location;
    });
    sorted.insert(sorted.end(), implicitPorts.begin(), implicitPorts.end());
    return sorted;
}

// The declared return-type syntax of a function ("function [3:0] f;"), used
// to anchor the return variable's typespec.
inline const syntax::SyntaxNode* returnTypeSyntax(const SubroutineSymbol& sub) {
    auto syn = sub.getSyntax();
    if (syn && syn->kind == syntax::SyntaxKind::FunctionDeclaration)
        return sub.getSyntax()->as<syntax::FunctionDeclarationSyntax>().prototype->returnType;
    return nullptr;
}

// Return-value variables take the class of the function's return type.
inline UHDM::variables* makeReturnVar(UHDM::Serializer& s, const Type& retType) {
    auto& ct = retType.getCanonicalType();
    if (ct.kind == SymbolKind::PackedStructType ||
        ct.kind == SymbolKind::UnpackedStructType)
        return s.MakeStruct_var();
    if (ct.kind == SymbolKind::EnumType)
        return s.MakeEnum_var();
    if (ct.kind == SymbolKind::StringType)
        return s.MakeString_var();
    if (ct.kind == SymbolKind::PredefinedIntegerType) {
        auto& pit = ct.as<PredefinedIntegerType>();
        if (pit.integerKind == PredefinedIntegerType::Int) {
            auto* v = s.MakeInt_var();
            v->VpiSigned(pit.isSigned);
            return v;
        }
        if (pit.integerKind == PredefinedIntegerType::Integer) {
            auto* v = s.MakeInteger_var();
            v->VpiSigned(pit.isSigned);
            return v;
        }
    }
    if (ct.kind == SymbolKind::FloatingType) {
        if (ct.as<FloatingType>().floatKind == FloatingType::ShortReal)
            return s.MakeShort_real_var();
        return s.MakeReal_var();
    }
    // Signedness rides on the typespec, not the logic_var.
    return s.MakeLogic_var();
}

// Strips slang's implicit conversion wrappers (Surelog has no equivalent).
inline const Expression& stripImplicitConv(const Expression& e) {
    const Expression* p = &e;
    while (p->kind == ExpressionKind::Conversion &&
           p->as<ConversionExpression>().isImplicit())
        p = &p->as<ConversionExpression>().operand();
    return *p;
}

inline bool isLiteralExpr(const Expression& e) {
    auto& c = stripImplicitConv(e);
    return c.kind == ExpressionKind::IntegerLiteral ||
           c.kind == ExpressionKind::StringLiteral ||
           c.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral;
}

// Collects the value symbols referenced on a cont_assign LHS (their top-view
// net typespecs lose the creation-time parent when Surelog re-elaborates the
// assignment).
inline void collectLhsSyms(const Expression& e, std::set<const Symbol*>& out) {
    switch (e.kind) {
        case ExpressionKind::NamedValue:
            out.insert(&e.as<NamedValueExpression>().symbol);
            break;
        case ExpressionKind::ElementSelect:
            collectLhsSyms(e.as<ElementSelectExpression>().value(), out);
            break;
        case ExpressionKind::RangeSelect:
            collectLhsSyms(e.as<RangeSelectExpression>().value(), out);
            break;
        case ExpressionKind::Concatenation:
            for (auto op : e.as<ConcatenationExpression>().operands())
                collectLhsSyms(*op, out);
            break;
        case ExpressionKind::Conversion:
            collectLhsSyms(e.as<ConversionExpression>().operand(), out);
            break;
        default:
            break;
    }
}

} // namespace slang_uhdm
