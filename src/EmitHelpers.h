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

// Surelog's struct net-vs-var rule, verbatim (NetlistElaboration.cpp, the
// `ttmp == uhdmstruct_typespec` arm of elab_signal_): a struct-typed signal is
// a NET only while EVERY member's typespec is a logic_typespec or another
// struct_typespec. One enum / packed-array / bit / int / real member and the
// whole signal becomes a struct_VAR. Members carrying no actual typespec are
// skipped, exactly as Surelog's `if (const typespec* mtps = ...)` skips them.
//
// The rule reads the EMITTED typespec rather than the slang type so the two
// stay consistent by construction: whatever we decided to spell as a
// packed_array_typespec is what Surelog's writer would have seen.
//
// It governs the UNPACKED-ARRAY leaf too: the same `isNet` flag decides
// array_net vs array_var (unpackedArrayLeafIsNet).
inline bool structTsIsNetLike(const UHDM::typespec* ts) {
    if (!ts || ts->UhdmType() != UHDM::uhdmstruct_typespec)
        return true;
    auto* sts = (const UHDM::struct_typespec*)ts;
    if (!sts->Members())
        return true;
    for (auto* mem : *sts->Members()) {
        auto* mrt = mem->Typespec();
        if (!mrt)
            continue;
        auto* mts = mrt->Actual_typespec();
        if (!mts)
            continue;
        auto k = mts->UhdmType();
        if (k != UHDM::uhdmlogic_typespec && k != UHDM::uhdmstruct_typespec)
            return false;
    }
    return true;
}

// Surelog re-lexes based literals compactly ("8'd 3" -> "8'd3"); spans that
// contain them shrink by the whitespace between the base char and the digits.
inline size_t basedLiteralSpaceCount(std::string_view text) {
    size_t n = 0;
    for (size_t i = 0; i + 1 < text.size(); i++) {
        if (text[i] != '\'')
            continue;
        size_t j = i + 1;
        if (j < text.size() && (text[j] == 's' || text[j] == 'S'))
            j++;
        if (j >= text.size())
            break;
        char b = (char)tolower(text[j]);
        if (b != 'd' && b != 'h' && b != 'b' && b != 'o')
            continue;
        for (j++; j < text.size() && (text[j] == ' ' || text[j] == '\t'); j++)
            n++;
    }
    return n;
}

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

// True when an ANSI port spells the `var` keyword explicitly
// ("input var logic i1"). Surelog elaborates such a port as a VARIABLE even
// though the def view keeps the generic logic_net (StandardNetVar).
inline bool ansiVarKeywordPort(const Symbol& internal) {
    for (auto p = internal.getSyntax(); p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::ImplicitAnsiPort) {
            auto& ap = p->as<syntax::ImplicitAnsiPortSyntax>();
            if (ap.header->kind == syntax::SyntaxKind::VariablePortHeader)
                return ap.header->as<syntax::VariablePortHeaderSyntax>()
                    .varKeyword.valid();
            return false;
        }
        if (p->kind == syntax::SyntaxKind::ModuleDeclaration)
            break;
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
                return nullptr;
            }
            // A CONTINUATION declarator (output wire [3:0] a, b, c: slang
            // gives b/c a bare VariablePortHeader with no direction) of a NET
            // port inherits the nearest PRECEDING port's explicit net header.
            if (internal.kind == SymbolKind::Net &&
                ap.header->kind == syntax::SyntaxKind::VariablePortHeader &&
                !ap.header->as<syntax::VariablePortHeaderSyntax>()
                     .direction.valid() &&
                p->parent) {
                const syntax::SyntaxNode* list = p->parent;
                const syntax::NetPortHeaderSyntax* found = nullptr;
                for (size_t ci = 0; ci < list->getChildCount(); ci++) {
                    const syntax::SyntaxNode* cn = list->childNode(ci);
                    if (!cn)
                        continue;
                    if (cn == p)
                        return found;
                    if (cn->kind == syntax::SyntaxKind::ImplicitAnsiPort) {
                        auto& ap2 = cn->as<syntax::ImplicitAnsiPortSyntax>();
                        if (ap2.header->kind == syntax::SyntaxKind::NetPortHeader) {
                            auto& nh2 =
                                ap2.header->as<syntax::NetPortHeaderSyntax>();
                            found = nh2.netType.valid() ? &nh2 : nullptr;
                        }
                        else if (ap2.header->kind ==
                                     syntax::SyntaxKind::VariablePortHeader &&
                                 !ap2.header
                                      ->as<syntax::VariablePortHeaderSyntax>()
                                      .direction.valid()) {
                            // Another continuation: chain unchanged.
                        }
                        else {
                            found = nullptr;
                        }
                    }
                }
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
// A signal whose declared type is written as a bare identifier that resolves
// to a `parameter type T` — Surelog models these ports specially (def-view net
// with no net type + type-param default typespec; elab-view logic_var).
inline const TypeParameterSymbol* portTypeParam(const Symbol& internal) {
    auto* dt = internal.getDeclaredType();
    if (!dt)
        return nullptr;
    auto* tsyn = dt->getTypeSyntax();
    if (!tsyn || tsyn->kind != syntax::SyntaxKind::NamedType)
        return nullptr;
    auto& nt = tsyn->as<syntax::NamedTypeSyntax>();
    if (nt.name->kind != syntax::SyntaxKind::IdentifierName)
        return nullptr;
    auto name = nt.name->as<syntax::IdentifierNameSyntax>().identifier.valueText();
    auto* scope = internal.getParentScope();
    if (!scope)
        return nullptr;
    auto* sym = scope->find(std::string(name));
    if (sym && sym->kind == SymbolKind::TypeParameter)
        return &sym->as<TypeParameterSymbol>();
    return nullptr;
}

// A declaration whose type is named through an explicit `other_pkg::T`
// qualification: the shared typespec belongs to THAT package and every
// vpiInstance / span stamp made while emitting the USING package must leave it
// alone (Surelog creates the object once, in its declaring package —
// PackFunc). `home` is the package currently being emitted; null outside one.
inline bool foreignPkgTypedef(const Symbol& declSym, const Symbol* home) {
    auto* dt = declSym.getDeclaredType();
    if (!home || !dt || dt->getType().kind != SymbolKind::TypeAlias)
        return false;
    auto* sc = dt->getType().getParentScope();
    return sc && sc->asSymbol().kind == SymbolKind::Package &&
           &sc->asSymbol() != home;
}

// The set of local types passed as `type` parameter arguments to child
// instances of `body` — a module-local net of such a type omits its def-view
// typespec (Surelog leaves it a bare logic_net; the elab view re-types it).
inline void collectTypeParamArgTypes(const InstanceBodySymbol& body,
                                     std::set<const Type*>& out) {
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Instance)
            continue;
        for (auto& cm : member.as<InstanceSymbol>().body.members()) {
            if (cm.kind != SymbolKind::TypeParameter)
                continue;
            auto& tp = cm.as<TypeParameterSymbol>();
            if (!tp.isOverridden())
                continue;
            out.insert(&tp.targetType.getType());
        }
    }
}

inline int32_t netTypeFor(const Symbol& internal, bool defView = false) {
    // A `parameter type T`-typed port carries no net type (Surelog).
    if (portTypeParam(internal))
        return 0;
    if (internal.kind == SymbolKind::Net) {
        // Implicitly-declared nets (created by an undeclared name in an assign
        // or port connection) print as a bare wire.
        if (internal.as<NetSymbol>().isImplicit)
            return vpiWire;
        // DEF view only (net_types; the ELAB/top view keeps real kinds):
        // a PREDEFINED-INTEGER net (wire integer x) prints NO net type; a
        // net declared via a MODULE-LOCAL vector typedef prints 36
        // regardless of wire/wand/wor.
        if (auto* dt0 = internal.getDeclaredType(); dt0 && defView) {
            if (dt0->getType().getCanonicalType().kind ==
                SymbolKind::PredefinedIntegerType)
                return 0;
            if (dt0->getType().kind == SymbolKind::TypeAlias) {
                auto& ta1 = dt0->getType().as<TypeAliasType>();
                auto ck1 = ta1.targetType.getType().getCanonicalType().kind;
                if (auto ps1 = ta1.getParentScope();
                    ps1 &&
                    ps1->asSymbol().kind != SymbolKind::Package &&
                    (ck1 == SymbolKind::PackedArrayType ||
                     ck1 == SymbolKind::ScalarType))
                    return 36;
            }
        }
        // A PREDEFINED-INTEGER ANSI net-port (input wire integer x) prints
        // NO net type in every view; a BODY declaration keeps its kind in
        // the elab view (Surelog).
        if (auto* dt0 = internal.getDeclaredType())
            if (dt0->getType().getCanonicalType().kind ==
                    SymbolKind::PredefinedIntegerType &&
                ansiNetHeader(internal) != nullptr)
                return 0;
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
                // A packed array whose LEAF is a struct (filter_ctl_t [1:0])
                // carries no net type.
                const Type* leaf0 = &ct;
                while (leaf0->getCanonicalType().kind == SymbolKind::PackedArrayType)
                    leaf0 = &leaf0->getCanonicalType()
                                 .as<PackedArrayType>()
                                 .elementType;
                if (leaf0->getCanonicalType().isStruct())
                    return 0;
                if ((ct.kind == SymbolKind::PackedArrayType ||
                     ct.kind == SymbolKind::ScalarType) &&
                    ct.isFourState()) {
                    // SCOPED pkg-typedef references (pkg::T x, pkg::T [1:0] x)
                    // print none; an IMPORTED unqualified name (import
                    // pkg::T; output T o) behaves like a local typedef and
                    // keeps vpiNet. Descend packed dims to the leaf alias.
                    const Type* la = &t;
                    while (la->kind == SymbolKind::PackedArrayType)
                        la = &la->as<PackedArrayType>().elementType;
                    if (la->kind == SymbolKind::TypeAlias &&
                        tsyn->as<syntax::NamedTypeSyntax>().name->kind !=
                            syntax::SyntaxKind::IdentifierName)
                        if (auto sc = la->as<TypeAliasType>().getParentScope();
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
    // An INSTANCE ARRAY (myif arr[N], producer p[N]) is an InstanceArraySymbol
    // whose elements are the per-index InstanceSymbols (or nested arrays) — its
    // definition must be collected too, else the interface/module def is
    // dropped from AllInterfaces/AllModules entirely.
    std::function<void(const Symbol&)> visit = [&](const Symbol& member) {
        if (member.kind == SymbolKind::Instance) {
            auto& child = member.as<InstanceSymbol>();
            auto name = std::string(child.getDefinition().name);
            if (defs.emplace(name, &child).second)
                collectDefs(child.body, defs);
        }
        else if (member.kind == SymbolKind::InstanceArray) {
            for (auto* e : member.as<InstanceArraySymbol>().elements)
                visit(*e);
        }
        // Instances INSIDE generate blocks (begin:foo mod_a a(...); end) —
        // their defs must reach AllModules too. Non-taken branches don't.
        else if (member.kind == SymbolKind::GenerateBlock) {
            if (!member.as<GenerateBlockSymbol>().isUninstantiated)
                for (auto& gm : member.as<Scope>().members())
                    visit(gm);
        }
        else if (member.kind == SymbolKind::GenerateBlockArray) {
            for (auto& gm : member.as<Scope>().members())
                visit(gm);
        }
    };
    for (auto& member : body.members())
        visit(member);
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
// True for a parameter-port-list entry written WITHOUT the `parameter` /
// `localparam` keyword — the grammar's `data_type list_of_param_assignments`
// form (`module m #( int unsigned XLEN = 32 )`), an IMPLICIT parameter. slang
// leaves ParameterDeclarationSyntax::keyword invalid for it, so the test is
// exact. Surelog re-creates these AFTER the body params in the elaborated
// instance (see the rank comment in emitParameters).
inline bool isImplicitPortParam(const ParameterSymbol& ps) {
    if (!ps.isPortParam())
        return false;
    auto* n = ps.getSyntax();
    // Declarator -> SeparatedSyntaxList -> ParameterDeclaration.
    for (int i = 0; n && i < 4; i++, n = n->parent) {
        if (n->kind != syntax::SyntaxKind::ParameterDeclaration)
            continue;
        return !n->as<syntax::ParameterDeclarationSyntax>().keyword;
    }
    return false;
}
inline bool isOverriddenParam(const Symbol& sym) {
    if (sym.kind != SymbolKind::Parameter)
        return false;
    auto& ps = sym.as<ParameterSymbol>();
    auto* defaultSyn = paramDefaultSyn(ps);
    auto* bi = ps.getInitializer();
    if (!bi || !defaultSyn)
        return false;
    auto dr = defaultSyn->sourceRange();
    // The bound initializer's source span: its syntax node if present (a
    // PARENTHESIZED default binds to the inner expr, so the node differs from
    // the default's paren node), else the folded expression's range.
    SourceRange br = bi->syntax ? bi->syntax->sourceRange() : bi->sourceRange;
    if (br.start() == SourceLocation::NoLocation ||
        dr.start() == SourceLocation::NoLocation)
        return bi->syntax && bi->syntax != defaultSyn;
    // A default (even parenthesized) has its tokens WITHIN the declaration
    // default's range; a real override binds syntax from the instantiation,
    // OUTSIDE that range.
    if (br.start() >= dr.start() && br.end() <= dr.end())
        return false;
    return true;
}

// True when a LOCALPARAM's initializer is a COMPUTED (non-literal) expression:
// e.g. `localparam W = $clog2(DATA_WIDTH)`. Surelog keeps a def-view packed
// range that references such a localparam UNFOLDED (op(ref W - 1)), just like
// it does for overridden params, because the folded bound is not a plain
// source literal. Restricted to LOCALPARAMs: an overridable module parameter
// with a computed default (`parameter W = $clog2(N)`) still FOLDS in Surelog's
// range (for_loop_nonconst_bound, multiple_blocking) — only the immutable
// localparam form is kept symbolic. Literal-init (`localparam W = 32`) folds.
inline bool paramInitIsComputed(const Symbol& sym) {
    if (sym.kind != SymbolKind::Parameter)
        return false;
    auto& ps = sym.as<ParameterSymbol>();
    if (!ps.isLocalParam())
        return false;
    const Expression* bi = ps.getInitializer();
    if (!bi)
        return false;
    // Unwrap implicit/explicit conversions (int cast around $clog2, etc.).
    const Expression* e = bi;
    while (e->kind == ExpressionKind::Conversion)
        e = &e->as<ConversionExpression>().operand();
    switch (e->kind) {
        case ExpressionKind::IntegerLiteral:
        case ExpressionKind::UnbasedUnsizedIntegerLiteral:
        case ExpressionKind::RealLiteral:
            return false;
        default:
            return true;
    }
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

// A `net_lvalue` in the 1800 grammar: a (possibly hierarchical, possibly
// selected) identifier, or a concatenation of those.  Nothing else --
// literals, operations, calls and replications are all excluded.
inline bool isNetLvalueSyntax(const syntax::ExpressionSyntax& e) {
    switch (e.kind) {
        case syntax::SyntaxKind::IdentifierName:
        case syntax::SyntaxKind::IdentifierSelectName:
        case syntax::SyntaxKind::ScopedName:
        case syntax::SyntaxKind::MemberAccessExpression:
        case syntax::SyntaxKind::ElementSelectExpression:
        case syntax::SyntaxKind::ConcatenationExpression:
            return true;
        default:
            return false;
    }
}

// Surelog's parser resolves `foo f(a, b);` as a **udp_instantiation**, not a
// module_instantiation: with an ordered connection list of two or more
// terminals whose first parses as a `net_lvalue` (the UDP output), the
// udp_instantiation alternative matches and ANTLR takes it -- whether or not
// a UDP named `foo` exists.  CompileModule then routes the item to
// compileUdpInstantiation, which builds NO `ref_module`, so the definition
// view of the parent carries no child reference at all.  Measured on a
// ten-shape probe: `i(x,y)`, `i(x,y,z)`, `i(x, y&z)` and `i({x,y}, z)` are
// UDPs; `.a(x)` named lists, a non-net_lvalue FIRST terminal (`i(x&y, z)`,
// `i(1'b0, z)`), an empty terminal (`i(x, , z)`) and single-terminal lists
// all stay module_instantiations and keep their ref_module.
//
// A `#(...)` override does NOT by itself break the shape: `delay2 ::= # (
// mintypmax_expression [, mintypmax_expression] )` swallows an ORDERED list
// of one or two values, so `sub #(1) i(x,y)`, `sub #(1,2) i(x,y)` and
// `Example #("FOO") e2(a,b,c,d)` are all UDPs.  Three or more values, or any
// NAMED override, exceed delay2 and leave a module_instantiation (measured).
inline bool udpShapedInstantiation(const InstanceSymbol& inst) {
    auto syn = inst.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::HierarchicalInstance)
        return false;
    auto& hi = syn->as<syntax::HierarchicalInstanceSyntax>();
    if (hi.connections.size() < 2)
        return false;
    const syntax::ExpressionSyntax* firstExpr = nullptr;
    for (auto conn : hi.connections) {
        if (conn->kind != syntax::SyntaxKind::OrderedPortConnection)
            return false;
        // A port connection's expression is wrapped in the property/sequence
        // shells the assertion grammar shares with it.
        const syntax::PropertyExprSyntax* pe =
            conn->as<syntax::OrderedPortConnectionSyntax>().expr;
        if (!pe || pe->kind != syntax::SyntaxKind::SimplePropertyExpr)
            return false;
        const syntax::SequenceExprSyntax* se =
            pe->as<syntax::SimplePropertyExprSyntax>().expr;
        if (!se || se->kind != syntax::SyntaxKind::SimpleSequenceExpr)
            return false;
        const syntax::ExpressionSyntax* e =
            se->as<syntax::SimpleSequenceExprSyntax>().expr;
        // An empty terminal (`i(x, , z)`) is not a UDP instance.
        if (!e || e->getFirstToken().isMissing())
            return false;
        if (!firstExpr)
            firstExpr = e;
    }
    // A `#(...)` override survives only while it still reads as delay2.
    for (auto p = syn->parent; p; p = p->parent) {
        if (p->kind == syntax::SyntaxKind::HierarchyInstantiation) {
            auto* pva = p->as<syntax::HierarchyInstantiationSyntax>().parameters;
            if (pva) {
                if (pva->parameters.size() > 2)
                    return false;
                for (auto pa : pva->parameters)
                    if (pa->kind != syntax::SyntaxKind::OrderedParamAssignment)
                        return false;
            }
            break;
        }
        if (p->kind == syntax::SyntaxKind::ModuleDeclaration)
            break;
    }
    return firstExpr && isNetLvalueSyntax(*firstExpr);
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
            // Built-in METHOD calls (a.getc(i): no leading $) are shared,
            // as are the transparent casts and sampled-value functions.
            if (n.empty() || n[0] != '$')
                return false;
            return n != "$signed" && n != "$unsigned" && n != "$fell" &&
                   n != "$rose" && n != "$stable" && n != "$past";
        }
        case ExpressionKind::SimpleAssignmentPattern:
        case ExpressionKind::StructuredAssignmentPattern:
        case ExpressionKind::ReplicatedAssignmentPattern:
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

// A non-ANSI header port written `.X1(internal)`: the port names itself and
// the expression names what it connects to. Surelog keeps the two apart — the
// PORT mints a net of its own name at the port-name location, while the
// expression's symbol keeps the net (and gains the port) of its declaration.
// A plain `(a)` header port shares one identity and is NOT explicit.
inline bool isExplicitNonAnsiPort(const PortSymbol& ps) {
    auto syn = ps.getSyntax();
    return !ps.isAnsiPort && !ps.isNullPort && syn && syn->parent &&
           syn->parent->kind == syntax::SyntaxKind::ExplicitNonAnsiPort;
}

// The distinct symbols named by a body's EXPLICIT ports, in port order.
inline std::vector<const Symbol*> explicitPortInternals(
    const InstanceBodySymbol& body) {
    std::vector<const Symbol*> out;
    for (auto pb : body.getPortList()) {
        if (pb->kind != SymbolKind::Port)
            continue;
        auto& ps = pb->as<PortSymbol>();
        if (!ps.internalSymbol || !isExplicitNonAnsiPort(ps))
            continue;
        if (std::find(out.begin(), out.end(), ps.internalSymbol) == out.end())
            out.push_back(ps.internalSymbol);
    }
    return out;
}

// ...of those, the ones no header port is already named after: each is a port
// declaration in its own right, so it earns its own port object.
inline std::vector<const Symbol*> explicitPortOwnPorts(
    const InstanceBodySymbol& body) {
    std::vector<const Symbol*> out;
    for (auto* isym : explicitPortInternals(body)) {
        bool named = false;
        for (auto pb : body.getPortList())
            if (pb->name == isym->name)
                named = true;
        if (!named)
            out.push_back(isym);
    }
    return out;
}

// The direction of the port declaration an explicit port's symbol came from,
// read off the header ports that name it.
inline int32_t explicitPortDirection(const InstanceBodySymbol& body,
                                     const Symbol& isym) {
    for (auto pb : body.getPortList()) {
        if (pb->kind != SymbolKind::Port)
            continue;
        auto& ps = pb->as<PortSymbol>();
        if (ps.internalSymbol != &isym)
            continue;
        switch (ps.direction) {
            case ArgumentDirection::In:
                return vpiInput;
            case ArgumentDirection::Out:
                return vpiOutput;
            default:
                return vpiInout;
        }
    }
    return vpiInout;
}

struct NetOrderItem {
    const Symbol* sym;
    const PortSymbol* port;
    bool bodyDecl;
    // The net an EXPLICIT non-ANSI port mints under its OWN name; `sym` is
    // the expression's symbol (the lowConn actual), NOT this net's identity.
    bool portExprNet = false;
};

// An interface handled by the interface_inst path: variables/nets/parameters/
// ports/cont-assigns/processes are supported; child instances, generate, and
// modports still fall through to the (incomplete) module_inst path.
inline bool isSimpleInterfaceBody(const InstanceBodySymbol& body) {
    for (auto& m : body.members()) {
        switch (m.kind) {
            // Child instances (interface/module instantiated INSIDE the
            // interface) still fall through to the module_inst path. Generate
            // blocks are now handled by the interface path (def-view gen_stmts +
            // elab gen_scope_arrays).
            case SymbolKind::Instance:
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
// The module_inst view of an instance object, or null when it is a program /
// interface_inst (relations that exist only on module_inst).
inline UHDM::module_inst* asModuleInst(UHDM::instance* m) {
    return (m && m->UhdmType() == UHDM::uhdmmodule_inst) ? (UHDM::module_inst*)m
                                                         : nullptr;
}

inline void instSetContAssigns(UHDM::instance* m, UHDM::VectorOfcont_assign* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Cont_assigns(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Cont_assigns(v);
    else
        ((UHDM::module_inst*)m)->Cont_assigns(v);
}
inline void instSetProcess(UHDM::instance* m, UHDM::VectorOfprocess_stmt* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Process(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Process(v);
    else
        ((UHDM::module_inst*)m)->Process(v);
}
inline void instSetPorts(UHDM::instance* m, UHDM::VectorOfport* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Ports(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Ports(v);
    else
        ((UHDM::module_inst*)m)->Ports(v);
}
inline UHDM::VectorOfport* instGetPorts(const UHDM::instance* m) {
    if (!m)
        return nullptr;
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        return ((const UHDM::interface_inst*)m)->Ports();
    if (m->UhdmType() == UHDM::uhdmprogram)
        return ((const UHDM::program*)m)->Ports();
    if (m->UhdmType() == UHDM::uhdmmodule_inst)
        return ((const UHDM::module_inst*)m)->Ports();
    return nullptr;
}
inline void instSetGenScopeArrays(UHDM::instance* m, UHDM::VectorOfgen_scope_array* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Gen_scope_arrays(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Gen_scope_arrays(v);
    else
        ((UHDM::module_inst*)m)->Gen_scope_arrays(v);
}
inline void instSetInterfaces(UHDM::instance* m, UHDM::VectorOfinterface_inst* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Interfaces(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Interfaces(v);
    else
        ((UHDM::module_inst*)m)->Interfaces(v);
}
inline UHDM::VectorOfinterface_array* instGetInterfaceArrays(const UHDM::instance* m) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        return ((const UHDM::interface_inst*)m)->Interface_arrays();
    if (m->UhdmType() == UHDM::uhdmprogram)
        return ((const UHDM::program*)m)->Interface_arrays();
    return ((const UHDM::module_inst*)m)->Interface_arrays();
}
inline void instSetInterfaceArrays(UHDM::instance* m, UHDM::VectorOfinterface_array* v) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Interface_arrays(v);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->Interface_arrays(v);
    else
        ((UHDM::module_inst*)m)->Interface_arrays(v);
}
inline void instSetEndLabel(UHDM::instance* m, std::string_view lbl) {
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->VpiEndLabel(lbl);
    else if (m->UhdmType() == UHDM::uhdmprogram)
        ((UHDM::program*)m)->VpiEndLabel(lbl);
    else
        ((UHDM::module_inst*)m)->VpiEndLabel(lbl);
}
inline void instSetGenStmts(UHDM::instance* m, UHDM::VectorOfgen_stmt* v) {
    // UHDM's `program` carries no gen_stmts relation, so a program def drops
    // its generate placeholders (no corpus case yet).
    if (m->UhdmType() == UHDM::uhdminterface_inst)
        ((UHDM::interface_inst*)m)->Gen_stmts(v);
    else if (auto* mm = asModuleInst(m))
        mm->Gen_stmts(v);
}

// A `program` block is written into design->AllPrograms / instance->Programs,
// never AllModules. Surelog's program writer is a separate path from its
// module writer, and the two differ in the def view (see emitModuleDef).
inline bool isProgramDef(const InstanceSymbol& inst) {
    return inst.getDefinition().definitionKind == DefinitionKind::Program;
}
// The GENERIC interface port form (`module m (interface intf);`) — the port
// names no interface type. Surelog never recognises it as an interface port:
// it compiles an ordinary net-backed port whose typespec is an
// unsupported_typespec named after the PORT. Ports that do name a type
// (`ConnectTB.tb intf`, `sim_sram_if ss_if`) take the interface path.
inline bool isGenericIfacePort(const InterfacePortSymbol& ip) {
    for (auto sy = ip.getSyntax(); sy; sy = sy->parent) {
        const syntax::InterfacePortHeaderSyntax* iph = nullptr;
        if (sy->kind == syntax::SyntaxKind::InterfacePortHeader)
            iph = &sy->as<syntax::InterfacePortHeaderSyntax>();
        else if (sy->kind == syntax::SyntaxKind::ImplicitAnsiPort) {
            const syntax::PortHeaderSyntax* h =
                sy->as<syntax::ImplicitAnsiPortSyntax>().header;
            if (h && h->kind == syntax::SyntaxKind::InterfacePortHeader)
                iph = &h->as<syntax::InterfacePortHeaderSyntax>();
        }
        if (iph)
            return !iph->modport &&
                   iph->nameOrKeyword.kind == parsing::TokenKind::InterfaceKeyword;
        if (sy->kind == syntax::SyntaxKind::ImplicitAnsiPort)
            break;
    }
    return false;
}

inline const Expression& stripImplicitConv(const Expression& e);

// The def-view source span of an implicit net that slang minted at the FIRST
// terminal of an UNNAMED gate. Surelog's def-view gate compile never lands
// that terminal (see emitGates), so the net is not born there — it appears at
// the first terminal Surelog does compile. Only such nets get an entry; every
// other net keeps its own declaration span.
inline std::map<const Symbol*, SourceRange> defImplicitNetLocs(
    const InstanceBodySymbol& body) {
    auto primOf = [](const Symbol& mb) -> const PrimitiveInstanceSymbol* {
        if (mb.kind == SymbolKind::PrimitiveInstance)
            return &mb.as<PrimitiveInstanceSymbol>();
        if (mb.kind == SymbolKind::InstanceArray) {
            auto& arr = mb.as<InstanceArraySymbol>();
            if (!arr.elements.empty() && arr.elements[0] &&
                arr.elements[0]->kind == SymbolKind::PrimitiveInstance)
                return &arr.elements[0]->as<PrimitiveInstanceSymbol>();
        }
        return nullptr;
    };
    auto termSym = [](const Expression* ce) -> const Symbol* {
        if (!ce)
            return nullptr;
        const Expression* te = &stripImplicitConv(*ce);
        if (te->kind == ExpressionKind::Assignment)
            te = &stripImplicitConv(te->as<AssignmentExpression>().left());
        if (te->kind != ExpressionKind::NamedValue)
            return nullptr;
        auto& sym = te->as<NamedValueExpression>().symbol;
        if (sym.kind != SymbolKind::Net || !sym.as<NetSymbol>().isImplicit)
            return nullptr;
        return &sym;
    };
    // Nets born on a terminal the def view drops.
    std::set<const Symbol*> orphaned;
    for (auto& mb : body.members()) {
        auto* pi = primOf(mb);
        if (!pi || !mb.name.empty())
            continue;
        auto conns = pi->getPortConnections();
        if (conns.empty())
            continue;
        if (auto* sym = termSym(conns[0]);
            sym && sym->location == conns[0]->sourceRange.start())
            orphaned.insert(sym);
    }
    std::map<const Symbol*, SourceRange> locs;
    if (orphaned.empty())
        return locs;
    for (auto& mb : body.members()) {
        auto* pi = primOf(mb);
        if (!pi)
            continue;
        auto conns = pi->getPortConnections();
        for (size_t ci = mb.name.empty() ? 1u : 0u; ci < conns.size(); ci++) {
            auto* sym = termSym(conns[ci]);
            if (sym && orphaned.count(sym) && !locs.count(sym))
                locs[sym] = conns[ci]->sourceRange;
        }
    }
    return locs;
}

inline std::vector<NetOrderItem> collectNetOrder(const InstanceBodySymbol& body) {
    std::vector<NetOrderItem> sorted, implicitPorts, mintedNets;
    std::set<const Symbol*> portInternals;
    for (auto pb : body.getPortList()) {
        if (pb->kind != SymbolKind::Port)
            continue;
        auto& ps = pb->as<PortSymbol>();
        if (!ps.internalSymbol)
            continue;
        // An EXPLICIT port keeps its own net in the port group; the
        // expression's symbol falls through to the member loop and sorts by
        // its declaration, so BOTH nets exist (Surelog).
        if (isExplicitNonAnsiPort(ps)) {
            implicitPorts.push_back({ps.internalSymbol, &ps, false, true});
            continue;
        }
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
        // A connection-MINTED implicit net (no declaration anywhere) sorts
        // AFTER the non-ANSI port nets (mriscv top: clk/rstn before the
        // implicit .trap(trap) nets); declared nets stay before them.
        if (member.kind == SymbolKind::Net &&
            member.as<NetSymbol>().isImplicit)
            mintedNets.push_back({&member, nullptr, true});
        else
            sorted.push_back({&member, nullptr, true});
    }
    auto locLess = [](const NetOrderItem& a, const NetOrderItem& b) {
        return a.sym->location < b.sym->location;
    };
    std::stable_sort(sorted.begin(), sorted.end(), locLess);
    std::stable_sort(mintedNets.begin(), mintedNets.end(), locLess);
    sorted.insert(sorted.end(), implicitPorts.begin(), implicitPorts.end());
    sorted.insert(sorted.end(), mintedNets.begin(), mintedNets.end());
    return sorted;
}

// The declared return-type syntax of a function ("function [3:0] f;"), used
// to anchor the return variable's typespec.
inline const syntax::SyntaxNode* returnTypeSyntax(const SubroutineSymbol& sub) {
    auto syn = sub.getSyntax();
    if (syn && syn->kind == syntax::SyntaxKind::FunctionDeclaration)
        return sub.getSyntax()->as<syntax::FunctionDeclarationSyntax>().prototype->returnType;
    if (syn && syn->kind == syntax::SyntaxKind::DPIImport)
        return syn->as<syntax::DPIImportSyntax>().method->returnType;
    return nullptr;
}

// Return-value variables take the class of the function's return type.
inline UHDM::variables* makeReturnVar(UHDM::Serializer& s, const Type& retType,
                                      bool signedImplicitRet = false) {
    auto& ct = retType.getCanonicalType();
    // An UNPACKED-array return (typedef int T[N]; function T f) is a bare
    // array_var carrying only the ref to the array_typespec — Surelog
    // (ArrayExprFuncArg/DefaultPattern*).  Unlike a function-LOCAL unpacked
    // array it has no element reg and no vpiArrayType.
    if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType)
        return s.MakeArray_var();
    if (ct.kind == SymbolKind::PackedStructType ||
        ct.kind == SymbolKind::UnpackedStructType)
        return s.MakeStruct_var();
    // A union-typed return is a union_var (Surelog, rp32 enc32/dec32).
    if (ct.kind == SymbolKind::PackedUnionType ||
        ct.kind == SymbolKind::UnpackedUnionType)
        return s.MakeUnion_var();
    if (ct.kind == SymbolKind::EnumType)
        return s.MakeEnum_var();
    if (ct.kind == SymbolKind::StringType)
        return s.MakeString_var();
    // A chandle return/formal is a chandle_var (Surelog, DpiChandle).
    if (ct.kind == SymbolKind::CHandleType)
        return s.MakeChandle_var();
    // A class-handle return is a class_var (Surelog).
    if (ct.kind == SymbolKind::ClassType)
        return s.MakeClass_var();
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
        if (pit.integerKind == PredefinedIntegerType::ShortInt) {
            auto* v = s.MakeShort_int_var();
            v->VpiSigned(pit.isSigned);
            return v;
        }
        if (pit.integerKind == PredefinedIntegerType::LongInt) {
            auto* v = s.MakeLong_int_var();
            v->VpiSigned(pit.isSigned);
            return v;
        }
        if (pit.integerKind == PredefinedIntegerType::Byte) {
            auto* v = s.MakeByte_var();
            v->VpiSigned(pit.isSigned);
            return v;
        }
    }
    if (ct.kind == SymbolKind::FloatingType) {
        if (ct.as<FloatingType>().floatKind == FloatingType::ShortReal)
            return s.MakeShort_real_var();
        return s.MakeReal_var();
    }
    // A packed array whose ELEMENT is a NAMED TYPEDEF (word[1:0]) is a
    // packed_array_var; plain vectors (logic [1:0]) stay logic_vars.
    if (ct.kind == SymbolKind::PackedArrayType &&
        ct.as<PackedArrayType>().elementType.kind == SymbolKind::TypeAlias)
        return s.MakePacked_array_var();
    // A SIGNED implicit-base packed return (function signed [3:0] f) is an
    // int_var carrying vpiSigned (Surelog); other packed returns/vars stay
    // logic_vars (signedness rides on the typespec).
    if (signedImplicitRet && ct.kind == SymbolKind::PackedArrayType &&
        retType.isSigned()) {
        auto* v = s.MakeInt_var();
        v->VpiSigned(true);
        return v;
    }
    // A `bit`-based return (bit f, bit [1:0] f) is a bit_var; four-state
    // logic/reg returns stay logic_vars.
    {
        const Type* base9 = &ct;
        if (base9->kind == SymbolKind::PackedArrayType)
            base9 = &base9->as<PackedArrayType>()
                         .elementType.getCanonicalType();
        if (base9->kind == SymbolKind::ScalarType &&
            base9->as<ScalarType>().scalarKind == ScalarType::Bit) {
            // Signedness rides on the typespec only (Surelog leaves the
            // bit_var itself unsigned even for `function bit signed f`).
            return s.MakeBit_var();
        }
    }
    return s.MakeLogic_var();
}

// Packed dims written after a NAMED type (filter_ctl_t [1:0] a) live neither
// in the type syntax nor in getResolvedDimensions; scan the source between
// the type name and the declarator for bracket groups. Returns
// (range-span, left-bound-span, right-bound-span) per dim.
struct DimSpan {
    SourceRange range, left, right;
};
inline std::vector<DimSpan> scanDimSpans(const std::string& raw, SourceLocation base) {
    std::vector<DimSpan> out;
    for (size_t i = 0; i < raw.size(); i++) {
        if (raw[i] != '[')
            continue;
        auto close = raw.find(']', i);
        auto colon = raw.find(':', i);
        if (close == std::string::npos || colon == std::string::npos || colon > close)
            continue;
        auto trim = [&](size_t a, size_t b) {
            while (a < b && isspace((unsigned char)raw[a]))
                a++;
            while (b > a && isspace((unsigned char)raw[b - 1]))
                b--;
            return SourceRange(base + a, base + b);
        };
        out.push_back({SourceRange(base + i, base + close + 1), trim(i + 1, colon),
                       trim(colon + 1, close)});
        i = close;
    }
    return out;
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
