//------------------------------------------------------------------------------
//! @file UhdmExporter.cpp
//! @brief Exports a slang Compilation to a UHDM database (Surelog-compatible)
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include <uhdm/uhdm.h>

#include "slang/ast/ASTVisitor.h"
#include "slang/ast/Compilation.h"
#include "slang/ast/TimingControl.h"
#include "slang/ast/expressions/AssignmentExpressions.h"
#include "slang/ast/expressions/ConversionExpression.h"
#include "slang/ast/expressions/LiteralExpressions.h"
#include "slang/ast/expressions/MiscExpressions.h"
#include "slang/ast/expressions/OperatorExpressions.h"
#include "slang/ast/expressions/SelectExpressions.h"
#include "slang/ast/statements/ConditionalStatements.h"
#include "slang/ast/statements/MiscStatements.h"
#include "slang/ast/symbols/CompilationUnitSymbols.h"
#include "slang/ast/symbols/InstanceSymbols.h"
#include "slang/ast/symbols/MemberSymbols.h"
#include "slang/ast/symbols/PortSymbols.h"
#include "slang/ast/symbols/VariableSymbols.h"
#include "slang/ast/types/AllTypes.h"
#include "slang/ast/types/Type.h"
#include "slang/syntax/AllSyntax.h"
#include "slang/text/SourceManager.h"

using namespace slang;
using namespace slang::ast;

namespace slang_uhdm {

static constexpr int kVpiAssignmentOp = 82; // sv_vpi_user.h vpiAssignmentOp

// Surelog derives vpiNetType from the declared type keyword: explicit
// `logic` -> vpiNet, `reg` -> vpiReg, implicit -> unset; explicit net
// keywords map to their vpi net types.
static int32_t netTypeFor(const Symbol& internal) {
    if (internal.kind == SymbolKind::Net) {
        // Explicit net declarations ("wire w;") carry the net kind; implicit
        // port-backed nets do not print a net type.
        auto& nt = internal.as<NetSymbol>().netType;
        bool explicitDecl = false;
        for (auto p = internal.getSyntax(); p; p = p->parent) {
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
        }
    }
    return 0;
}

static int32_t mapUnaryOp(UnaryOperator op) {
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

static int32_t mapBinaryOp(BinaryOperator op) {
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

UhdmExporter::UhdmExporter(Compilation& compilation, UHDM::Serializer& serializer) :
    comp(compilation), s(serializer), sm(compilation.getSourceManager()) {
}

void UhdmExporter::noteUnsupported(const std::string& what) {
    unsupportedKinds.insert(what);
}

void UhdmExporter::setLoc(UHDM::BaseClass* obj, SourceRange range) {
    if (range.start() == SourceLocation::NoLocation)
        return;
    obj->VpiLineNo(sm->getLineNumber(range.start()));
    obj->VpiColumnNo(sm->getColumnNumber(range.start()));
    if (range.end() != SourceLocation::NoLocation) {
        obj->VpiEndLineNo(sm->getLineNumber(range.end()));
        obj->VpiEndColumnNo(sm->getColumnNumber(range.end()));
    }
}

void UhdmExporter::setLocNamed(UHDM::BaseClass* obj, const Symbol& symbol) {
    auto loc = symbol.location;
    // Surelog anchors ports and port-backed nets at the port-list name, not
    // the declaration.
    if (symbol.kind == SymbolKind::Port)
        loc = symbol.as<PortSymbol>().externalLoc;
    if (loc == SourceLocation::NoLocation)
        return;
    setLoc(obj, SourceRange(loc, loc + symbol.name.size()));
}

std::string UhdmExporter::fullFilePath(SourceLocation loc) {
    if (loc == SourceLocation::NoLocation)
        return "";
    return sm->getFullPath(loc.buffer()).string();
}

// Collects one representative instance per definition, recursively.
static void collectDefs(const InstanceBodySymbol& body,
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

UHDM::design* UhdmExporter::exportDesign() {
    auto& root = comp.getRoot();

    d = s.MakeDesign();
    if (!root.topInstances.empty())
        d->VpiName("work@" + std::string(root.topInstances[0]->getDefinition().name));

    // All definitions used anywhere in the design, name-sorted like Surelog's
    // module map.
    std::map<std::string, const InstanceSymbol*> defs;
    for (auto inst : root.topInstances) {
        auto name = std::string(inst->getDefinition().name);
        if (defs.emplace(name, inst).second)
            collectDefs(inst->body, defs);
    }

    auto* allMods = s.MakeModule_instVec();
    auto* topMods = s.MakeModule_instVec();

    // Pre-create the definition shells so ref_modules can point at them
    // regardless of emission order.
    for (auto& [name, inst] : defs) {
        defMap[&inst->getDefinition()].mod = s.MakeModule_inst();
        allMods->push_back(defMap[&inst->getDefinition()].mod);
    }
    d->AllModules(allMods);

    for (auto inst : root.topInstances) {
        std::string prefix = "work@" + std::string(inst->getDefinition().name);
        topMods->push_back(emitInstance(*inst, prefix, nullptr, nullptr, /*isTop=*/true));
    }
    d->TopModules(topMods);

    s.MakeUhdmHandle(UHDM::uhdmdesign, d);
    return d;
}

// Finds the named port connection syntax for a formal port name, so locations
// can anchor at the ".a(o)" text like Surelog.
static const syntax::NamedPortConnectionSyntax* findConnSyntax(const InstanceSymbol& inst,
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

// Port connection expressions for output ports come wrapped in an assignment;
// the connected expression is its left side.
static const Expression* connectionExpr(const PortConnection& conn) {
    auto expr = conn.getExpression();
    if (expr && expr->kind == ExpressionKind::Assignment)
        expr = &expr->as<AssignmentExpression>().left();
    return expr;
}

UHDM::module_inst* UhdmExporter::emitModuleDef(const InstanceSymbol& inst) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    std::string prefix = "work@" + std::string(def.name);

    DefInfo& info = defMap[&def];
    auto* m = info.mod;
    m->VpiDefName(prefix);
    m->VpiFullName(prefix);
    m->VpiParent(d);
    m->VpiFile(fullFilePath(def.location));
    if (auto syntax = body.getSyntax())
        setLoc(m, syntax->sourceRange());

    // Nets (in port order for port-connected signals, like Surelog).
    auto* nets = s.MakeNetVec();
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port) {
            noteUnsupported("port kind: " + std::string(toString(portBase->kind)));
            continue;
        }
        auto& ps = portBase->as<PortSymbol>();
        auto* internal = ps.internalSymbol;
        if (!internal)
            continue;

        auto* n = s.MakeLogic_net();
        n->VpiName(ps.name);
        n->VpiFullName(prefix + "." + std::string(ps.name));
        n->VpiParent(m);
        setLocNamed(n, ps); // Surelog uses the port-list location for the net
        if (int32_t nt = netTypeFor(*internal))
            n->VpiNetType(nt);
        info.nets[internal] = n;
        nets->push_back(n);
    }
    // Local (non-port) declarations stay logic_nets in the def view, but
    // carry a typespec and explicit net type.
    TsCache defTs;
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Net && member.kind != SymbolKind::Variable)
            continue;
        if (info.nets.count(&member))
            continue;
        auto* n = s.MakeLogic_net();
        n->VpiName(member.name);
        n->VpiFullName(prefix + "." + std::string(member.name));
        n->VpiParent(m);
        setLocNamed(n, member);
        if (int32_t nt = netTypeFor(member))
            n->VpiNetType(nt);
        auto* ts = sharedTypespec(member, defTs);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(prefix + "." + std::string(member.name));
        rt->VpiParent(n);
        rt->Actual_typespec(ts);
        n->Typespec(rt);
        info.nets[&member] = n;
        nets->push_back(n);
    }
    if (!nets->empty())
        m->Nets(nets);

    // Def-view ports share one typespec object per declaration (Surelog's
    // TypespecCache behavior), with no parent set.
    emitPorts(body, m, prefix, info.nets, /*topView=*/false, &defTs);

    // Child instance references (def view uses ref_module stubs).
    auto* refmods = s.MakeRef_moduleVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Instance)
            continue;
        auto& child = member.as<InstanceSymbol>();
        auto* rm = s.MakeRef_module();
        rm->VpiName(child.name);
        rm->VpiDefName("work@" + std::string(child.getDefinition().name));
        rm->VpiParent(m);
        setLoc(rm, SourceRange(child.location, child.location + child.name.size()));
        if (auto it = defMap.find(&child.getDefinition()); it != defMap.end())
            rm->Actual_group(it->second.mod);

        auto* rports = s.MakePortVec();
        for (auto conn : child.getPortConnections()) {
            auto* p = s.MakePort();
            p->VpiName(conn->port.name);
            p->VpiParent(rm);
            if (auto npc = findConnSyntax(child, conn->port.name))
                setLoc(p, npc->sourceRange());
            if (auto expr = connectionExpr(*conn)) {
                if (expr->kind == ExpressionKind::NamedValue) {
                    auto& nv = expr->as<NamedValueExpression>();
                    auto* r = s.MakeRef_obj();
                    r->VpiName(nv.symbol.name);
                    r->VpiFullName(prefix + "." + std::string(child.name) + "." +
                                   std::string(conn->port.name) + "." +
                                   std::string(nv.symbol.name));
                    r->VpiParent(p);
                    setLoc(r, expr->sourceRange);
                    if (auto nit = info.nets.find(&nv.symbol); nit != info.nets.end())
                        r->Actual_group(nit->second);
                    p->High_conn(r);
                }
                else if (auto* h = emitExpr(*expr, p, prefix, info.nets)) {
                    p->High_conn(h);
                }
            }
            rports->push_back(p);
        }
        if (!rports->empty())
            rm->Ports(rports);
        refmods->push_back(rm);
    }
    if (!refmods->empty())
        m->Ref_modules(refmods);

    emitContAssigns(body, m, prefix, info.nets, /*topView=*/false, &info, false);

    // Processes
    auto* procs = s.MakeProcess_stmtVec();
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::ProceduralBlock) {
            auto* p = emitProcess(member.as<ProceduralBlockSymbol>(), m, prefix, info.nets);
            if (p) {
                procs->push_back(p);
                info.processes.push_back(p);
            }
        }
    }
    if (!procs->empty())
        m->Process(procs);

    return m;
}

UHDM::module_inst* UhdmExporter::emitInstance(const InstanceSymbol& inst, const std::string& path,
                                              UHDM::module_inst* parentM, NetMap* parentNets,
                                              bool isTop) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    // Surelog materializes a definition the first time the instance tree
    // reaches it; typespec creation order depends on this.
    if (!defMap[&def].filled) {
        defMap[&def].filled = true;
        emitModuleDef(inst);
    }
    std::string prefix = path;
    std::string defPrefix = "work@" + std::string(def.name);
    std::string parentPrefix;
    if (parentM && parentM->VpiFullName().length())
        parentPrefix = std::string(parentM->VpiFullName());

    auto* m = s.MakeModule_inst();
    m->VpiDefName(defPrefix);
    m->VpiFullName(prefix);
    m->VpiFile(fullFilePath(def.location));
    if (isTop) {
        m->VpiName(prefix);
        m->VpiParent(d);
        m->VpiTop(true);
        m->VpiTopModule(true);
        if (auto syntax = body.getSyntax())
            setLoc(m, syntax->sourceRange());
    }
    else {
        m->VpiName(inst.name);
        m->VpiParent(parentM);
        m->Instance(parentM);
        m->Module_inst(parentM);
        m->VpiDefFile(fullFilePath(def.location));
        m->VpiDefLineNo((int32_t)sm->getLineNumber(def.location));
        // The child instance spans the whole instantiation statement.
        if (auto syn = inst.getSyntax()) {
            const syntax::SyntaxNode* stmtSyn = syn;
            while (stmtSyn->parent &&
                   stmtSyn->kind != syntax::SyntaxKind::HierarchyInstantiation) {
                stmtSyn = stmtSyn->parent;
            }
            setLoc(m, stmtSyn->sourceRange());
        }
    }

    // Top view gets its own net objects, each carrying a typespec. The
    // typespec object is shared per declaration (Surelog's TypespecCache),
    // and its parent is overwritten by each net using it, so it ends up
    // pointing at the last net of the declaration.
    NetMap topNets;
    TsCache netTs;
    auto* nets = s.MakeNetVec();
    auto* vars = s.MakeVariablesVec();
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port)
            continue;
        auto& ps = portBase->as<PortSymbol>();
        auto* internal = ps.internalSymbol;
        if (!internal)
            continue;

        std::string fullName = prefix + "." + std::string(ps.name);
        auto* ts = sharedTypespec(*internal, netTs);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(fullName);
        rt->Actual_typespec(ts);

        if (auto* v = makeVar(*internal, /*portBacked=*/true)) {
            v->VpiName(ps.name);
            v->VpiFullName(fullName);
            v->VpiParent(m);
            setLocNamed(v, ps);
            rt->VpiParent(v);
            v->Typespec(rt);
            topNets[internal] = v;
            vars->push_back(v);
        }
        else {
            auto* n = s.MakeLogic_net();
            n->VpiName(ps.name);
            n->VpiFullName(fullName);
            n->VpiParent(m);
            setLocNamed(n, ps);
            if (int32_t nt = netTypeFor(*internal))
                n->VpiNetType(nt);
            ts->VpiParent(n);
            rt->VpiParent(n);
            n->Typespec(rt);
            topNets[internal] = n;
            nets->push_back(n);
        }
    }
    // Local (non-port) declarations: logic/reg variables become logic_vars,
    // explicit nets stay logic_nets.
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Net && member.kind != SymbolKind::Variable)
            continue;
        if (topNets.count(&member))
            continue;
        std::string fullName = prefix + "." + std::string(member.name);
        auto* ts = sharedTypespec(member, netTs);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(fullName);
        rt->Actual_typespec(ts);
        if (auto* v = makeVar(member, /*portBacked=*/false)) {
            v->VpiName(member.name);
            v->VpiFullName(fullName);
            v->VpiParent(m);
            setLocNamed(v, member);
            rt->VpiParent(v);
            v->Typespec(rt);
            topNets[&member] = v;
            vars->push_back(v);
        }
        else {
            auto* n = s.MakeLogic_net();
            n->VpiName(member.name);
            n->VpiFullName(fullName);
            n->VpiParent(m);
            setLocNamed(n, member);
            if (int32_t nt = netTypeFor(member))
                n->VpiNetType(nt);
            ts->VpiParent(n);
            rt->VpiParent(n);
            n->Typespec(rt);
            topNets[&member] = n;
            nets->push_back(n);
        }
    }
    if (!nets->empty())
        m->Nets(nets);
    if (!vars->empty())
        m->Variables(vars);

    // Children are elaborated before the instance's own ports (typespec
    // creation order follows Surelog).
    auto* children = s.MakeModule_instVec();
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::Instance) {
            auto& child = member.as<InstanceSymbol>();
            children->push_back(emitInstance(child, prefix + "." + std::string(child.name), m,
                                             &topNets, /*isTop=*/false));
        }
    }
    if (!children->empty())
        m->Modules(children);

    // Instance-view ports each get a fresh typespec object (no sharing).
    auto* ports = s.MakePortVec();
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port)
            continue;
        auto& ps = portBase->as<PortSymbol>();
        auto* internal = ps.internalSymbol;
        if (!internal)
            continue;

        auto* p = s.MakePort();
        p->VpiName(ps.name);
        p->VpiParent(m);
        setLocNamed(p, ps);
        switch (ps.direction) {
            case ArgumentDirection::In:
                p->VpiDirection(vpiInput);
                break;
            case ArgumentDirection::Out:
                p->VpiDirection(vpiOutput);
                break;
            case ArgumentDirection::InOut:
                p->VpiDirection(vpiInout);
                break;
            default:
                noteUnsupported("port direction");
                break;
        }

        const PortConnection* conn = nullptr;
        if (!isTop) {
            for (auto c : inst.getPortConnections()) {
                if (&c->port == portBase) {
                    conn = c;
                    break;
                }
            }
        }

        auto* lc = s.MakeRef_obj();
        lc->VpiName(ps.name);
        lc->VpiFullName(prefix + "." + std::string(ps.name));
        lc->VpiParent(p);
        if (!isTop) {
            // Child low conns anchor at the formal name in the connection.
            if (auto npc = findConnSyntax(inst, ps.name))
                setLoc(lc, SourceRange(npc->name.location(),
                                       npc->name.location() + ps.name.size()));
            else
                setLocNamed(lc, ps);
        }
        else {
            setLocNamed(lc, ps);
        }
        if (auto it = topNets.find(internal); it != topNets.end())
            lc->Actual_group(it->second);
        p->Low_conn(lc);

        if (conn && parentNets) {
            if (auto expr = connectionExpr(*conn)) {
                if (auto* h = emitExpr(*expr, p, parentPrefix, *parentNets)) {
                    p->High_conn(h);
                    // Surelog rebinds the connected signal's typespec when it
                    // feeds a child port connection: the typespec is
                    // reparented to the signal and tagged with the enclosing
                    // instance.
                    if (expr->kind == ExpressionKind::NamedValue) {
                        auto it = parentNets->find(&expr->as<NamedValueExpression>().symbol);
                        if (it != parentNets->end()) {
                            auto* ex = (UHDM::expr*)it->second;
                            if (ex->Typespec() && ex->Typespec()->Actual_typespec())
                                ex->Typespec()->Actual_typespec()->VpiParent(ex);
                        }
                    }
                }
            }
        }

        auto* pts = makeTypespec(*internal);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(prefix + "." + std::string(ps.name));
        rt->VpiParent(p);
        rt->Actual_typespec(pts);
        p->Typespec(rt);
        ports->push_back(p);
    }
    if (!ports->empty())
        m->Ports(ports);

    {
        auto it = defMap.find(&def);
        emitContAssigns(body, m, prefix, topNets, /*topView=*/true,
                        it != defMap.end() ? &it->second : nullptr, isTop);
    }

    // Top modules share the definition's process objects (their hierarchical
    // prefix is identical); child instances get their own copies with the
    // instance path baked into names.
    if (isTop) {
        auto it = defMap.find(&def);
        if (it != defMap.end() && !it->second.processes.empty()) {
            auto* procs = s.MakeProcess_stmtVec();
            for (auto* p : it->second.processes)
                procs->push_back(p);
            m->Process(procs);
        }
    }
    else {
        auto* procs = s.MakeProcess_stmtVec();
        for (auto& member : body.members()) {
            if (member.kind == SymbolKind::ProceduralBlock) {
                if (auto* p = emitProcess(member.as<ProceduralBlockSymbol>(), m, prefix, topNets))
                    procs->push_back(p);
            }
        }
        if (!procs->empty())
            m->Process(procs);
    }

    return m;
}

void UhdmExporter::emitPorts(const InstanceBodySymbol& body, UHDM::module_inst* m,
                             const std::string& prefix,
                             NetMap& netMap, bool topView,
                             TsCache* sharedTs) {
    auto* ports = s.MakePortVec();
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port)
            continue;
        auto& ps = portBase->as<PortSymbol>();
        auto* internal = ps.internalSymbol;
        if (!internal)
            continue;

        auto* p = s.MakePort();
        p->VpiName(ps.name);
        p->VpiParent(m);
        setLocNamed(p, ps);
        switch (ps.direction) {
            case ArgumentDirection::In:
                p->VpiDirection(vpiInput);
                break;
            case ArgumentDirection::Out:
                p->VpiDirection(vpiOutput);
                break;
            case ArgumentDirection::InOut:
                p->VpiDirection(vpiInout);
                break;
            default:
                noteUnsupported("port direction");
                break;
        }

        auto* lc = s.MakeRef_obj();
        lc->VpiName(ps.name);
        // Def view: work@mod.<n>.<n> (port-scoped); top view: work@mod.<n>.
        if (topView)
            lc->VpiFullName(prefix + "." + std::string(ps.name));
        else
            lc->VpiFullName(prefix + "." + std::string(ps.name) + "." + std::string(ps.name));
        lc->VpiParent(p);
        setLocNamed(lc, ps);
        if (auto it = netMap.find(internal); it != netMap.end())
            lc->Actual_group(it->second);
        p->Low_conn(lc);

        UHDM::typespec* ts = sharedTs ? sharedTypespec(*internal, *sharedTs)
                                            : makeTypespec(*internal);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(prefix + "." + std::string(ps.name));
        rt->VpiParent(p);
        rt->Actual_typespec(ts);
        p->Typespec(rt);

        ports->push_back(p);
    }
    if (!ports->empty())
        m->Ports(ports);
}

// The location Surelog gives a typespec: the declared type's syntax range for
// explicit types, or a zero-width range at the declaration's *first*
// declarator for implicit types (shared across all declarators).
static SourceLocation firstDeclaratorLoc(const Symbol& sym) {
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
    }
    return sym.location;
}

UHDM::typespec* UhdmExporter::makeTypespec(const Symbol& declSymbol) {
    auto declared = declSymbol.getDeclaredType();
    SourceLocation implicitLoc = firstDeclaratorLoc(declSymbol);
    SourceRange range(implicitLoc, implicitLoc);
    bool explicitType = false;
    if (declared) {
        if (auto tsyn = declared->getTypeSyntax()) {
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
    // ("wire w;" -> the wire token).
    if (!explicitType && declSymbol.kind == SymbolKind::Net) {
        for (auto p = declSymbol.getSyntax(); p; p = p->parent) {
            if (p->kind == syntax::SyntaxKind::NetDeclaration) {
                range = p->as<syntax::NetDeclarationSyntax>().netType.range();
                break;
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
    setLoc(ts, range);

    // Packed dimensions: one uhdm range per dimension, bounds as evaluated
    // UINT constants (64-bit) that keep their source text as decompile.
    if (declared && declared->getType().isPackedArray()) {
        auto tsyn = declared->getTypeSyntax();
        if (tsyn && syntax::IntegerTypeSyntax::isKind(tsyn->kind)) {
            auto& its = tsyn->as<syntax::IntegerTypeSyntax>();
            std::vector<ConstantRange> dims;
            const Type* t = &declared->getType().getCanonicalType();
            while (t->isPackedArray()) {
                auto& pat = t->as<PackedArrayType>();
                dims.push_back(pat.range);
                t = &pat.elementType.getCanonicalType();
            }
            if (dims.size() == its.dimensions.size()) {
                auto* ranges = s.MakeRangeVec();
                for (size_t i = 0; i < dims.size(); i++) {
                    auto* dimSyn = its.dimensions[i];
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
                    r->Left_expr(makeBoundConst(lsyn, dims[i].left, r));
                    r->Right_expr(makeBoundConst(rsyn, dims[i].right, r));
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
    // Non-port variables of 4-state integral type become logic_vars in the
    // elaborated view.
    if (!portBacked && internal.kind == SymbolKind::Variable &&
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

UHDM::any* UhdmExporter::tryFoldConst(const Expression& expr) {
    // Surelog's netlist elaboration re-compiles top-view cont_assign
    // expressions with constant reduction. Fold only genuine expressions,
    // not plain literals.
    if (expr.kind == ExpressionKind::IntegerLiteral)
        return nullptr;
    ASTContext ctx(comp.getRoot(), LookupLocation::max);
    ConstantValue cv = ctx.tryEval(expr);
    if (!cv || !cv.isInteger())
        return nullptr;
    auto& iv = cv.integer();
    if (iv.hasUnknown() || (iv.isSigned() && iv.isNegative()))
        return nullptr;
    std::string digits = iv.toString(LiteralBase::Decimal, /*includeBase*/ false);
    auto* c = s.MakeConstant();
    c->VpiDecompile(digits);
    c->VpiSize((int32_t)expr.type->getBitWidth());
    c->VpiValue("UINT:" + digits);
    c->VpiConstType(vpiUIntConst);
    return c;
}

void UhdmExporter::emitContAssigns(const InstanceBodySymbol& body, UHDM::module_inst* m,
                                   const std::string& prefix, NetMap& netMap, bool topView,
                                   DefInfo* defInfo, bool shareWithDef) {
    auto* cas = s.MakeCont_assignVec();
    size_t idx = 0;
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::ContinuousAssign)
            continue;
        auto& casym = member.as<ContinuousAssignSymbol>();
        auto& assign = casym.getAssignment();
        size_t myIdx = idx++;
        if (assign.kind != ExpressionKind::Assignment) {
            noteUnsupported("continuous assign form");
            continue;
        }
        auto& ae = assign.as<AssignmentExpression>();
        // Top modules share the def's cont_assign object unless constant
        // folding changes the RHS.
        if (shareWithDef && defInfo && myIdx < defInfo->contAssigns.size() &&
            !tryFoldConst(ae.right())) {
            cas->push_back(defInfo->contAssigns[myIdx]);
            continue;
        }
        auto* ca = s.MakeCont_assign();
        ca->VpiParent(m);
        setLoc(ca, assign.sourceRange);
        UHDM::any* rhs = topView ? tryFoldConst(ae.right()) : nullptr;
        if (!rhs)
            rhs = emitExpr(ae.right(), ca, prefix, netMap);
        if (rhs)
            ca->Rhs((UHDM::expr*)rhs);
        if (auto* l = emitExpr(ae.left(), ca, prefix, netMap))
            ca->Lhs((UHDM::expr*)l);
        cas->push_back(ca);
        if (defInfo)
            defInfo->contAssigns.push_back(ca);
    }
    if (!cas->empty())
        m->Cont_assigns(cas);
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

UHDM::typespec* UhdmExporter::sharedTypespec(const Symbol& declSymbol, TsCache& cache) {
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
    auto* ts = makeTypespec(declSymbol);
    cache[key] = ts;
    return ts;
}

UHDM::process_stmt* UhdmExporter::emitProcess(const ProceduralBlockSymbol& block,
                                              UHDM::module_inst* m, const std::string& prefix,
                                              NetMap& netMap) {
    UHDM::process_stmt* proc = nullptr;
    switch (block.procedureKind) {
        case ProceduralBlockKind::Always: {
            auto* a = s.MakeAlways();
            a->VpiAlwaysType(vpiAlways);
            proc = a;
            break;
        }
        case ProceduralBlockKind::AlwaysComb: {
            auto* a = s.MakeAlways();
            a->VpiAlwaysType(vpiAlwaysComb);
            proc = a;
            break;
        }
        case ProceduralBlockKind::AlwaysFF: {
            auto* a = s.MakeAlways();
            a->VpiAlwaysType(vpiAlwaysFF);
            proc = a;
            break;
        }
        case ProceduralBlockKind::Initial:
            proc = s.MakeInitial();
            break;
        default:
            noteUnsupported("procedure kind: " + std::string(toString(block.procedureKind)));
            return nullptr;
    }

    proc->VpiParent(m);
    if (auto syntax = block.getSyntax())
        setLoc(proc, syntax->sourceRange());

    if (auto* body = emitStmt(block.getBody(), proc, prefix, netMap))
        proc->Stmt(body);
    return proc;
}

UHDM::any* UhdmExporter::emitEventExpr(const TimingControl& tc, UHDM::BaseClass* parent,
                                       const std::string& prefix,
                                       NetMap& netMap) {
    switch (tc.kind) {
        case TimingControlKind::SignalEvent: {
            auto& sec = tc.as<SignalEventControl>();
            if (sec.iffCondition) {
                noteUnsupported("iff event condition");
                return nullptr;
            }
            int32_t opType = 0;
            switch (sec.edge) {
                case EdgeKind::PosEdge:
                    opType = vpiPosedgeOp;
                    break;
                case EdgeKind::NegEdge:
                    opType = vpiNegedgeOp;
                    break;
                case EdgeKind::None:
                    return emitExpr(sec.expr, parent, prefix, netMap);
                default:
                    noteUnsupported("edge kind");
                    return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opType);
            op->VpiParent(parent);
            setLoc(op, tc.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* e = emitExpr(sec.expr, op, prefix, netMap))
                operands->push_back(e);
            op->Operands(operands);
            return op;
        }
        case TimingControlKind::EventList: {
            auto& el = tc.as<EventListControl>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiEventOrOp);
            op->VpiParent(parent);
            // slang's event list range includes the parens; Surelog spans the
            // events only.
            if (!el.events.empty()) {
                setLoc(op, SourceRange(el.events.front()->sourceRange.start(),
                                       el.events.back()->sourceRange.end()));
            }
            auto* operands = s.MakeAnyVec();
            for (auto ev : el.events) {
                if (auto* e = emitEventExpr(*ev, op, prefix, netMap))
                    operands->push_back(e);
            }
            op->Operands(operands);
            return op;
        }
        default:
            noteUnsupported("timing control: " + std::string(toString(tc.kind)));
            return nullptr;
    }
}

UHDM::any* UhdmExporter::emitStmt(const Statement& stmt, UHDM::BaseClass* parent,
                                  const std::string& prefix,
                                  NetMap& netMap) {
    switch (stmt.kind) {
        case StatementKind::Timed: {
            auto& timed = stmt.as<TimedStatement>();
            auto& timing = timed.timing;
            switch (timing.kind) {
                case TimingControlKind::ImplicitEvent:
                case TimingControlKind::SignalEvent:
                case TimingControlKind::EventList: {
                    auto* ec = s.MakeEvent_control();
                    ec->VpiParent(parent);
                    // The event_control covers the whole "@(...)" region: from
                    // the statement start through the closing paren (implicit
                    // event syntax already includes it).
                    if (timing.kind == TimingControlKind::ImplicitEvent) {
                        setLoc(ec, timing.sourceRange);
                    }
                    else {
                        // Event list ranges include the closing paren; a bare
                        // signal event does not.
                        auto end = timing.sourceRange.end();
                        if (timing.kind == TimingControlKind::SignalEvent)
                            end = end + 1;
                        setLoc(ec, SourceRange(stmt.sourceRange.start(), end));
                        if (auto* cond = emitEventExpr(timing, ec, prefix, netMap))
                            ec->VpiCondition(cond);
                    }
                    if (auto* inner = emitStmt(timed.stmt, ec, prefix, netMap))
                        ec->Stmt(inner);
                    return ec;
                }
                default:
                    noteUnsupported("timing control: " + std::string(toString(timing.kind)));
                    return nullptr;
            }
        }
        case StatementKind::ExpressionStatement: {
            auto& es = stmt.as<ExpressionStatement>();
            return emitExpr(es.expr, parent, prefix, netMap);
        }
        case StatementKind::Block: {
            auto& bs = stmt.as<BlockStatement>();
            if (bs.blockKind != StatementBlockKind::Sequential) {
                noteUnsupported("parallel block");
                return nullptr;
            }
            if (bs.blockSymbol && !bs.blockSymbol->name.empty()) {
                noteUnsupported("named block");
                return nullptr;
            }
            auto* b = s.MakeBegin();
            b->VpiParent(parent);
            b->VpiFullName(prefix);
            // stmt.sourceRange covers only the body; the syntax node covers
            // the full begin..end region that Surelog reports.
            if (stmt.syntax)
                setLoc(b, stmt.syntax->sourceRange());
            else
                setLoc(b, stmt.sourceRange);
            auto* stmts = s.MakeAnyVec();
            auto& body = bs.body;
            if (body.kind == StatementKind::List) {
                for (auto st : body.as<StatementList>().list) {
                    if (auto* u = emitStmt(*st, b, prefix, netMap))
                        stmts->push_back(u);
                }
            }
            else if (auto* u = emitStmt(body, b, prefix, netMap)) {
                stmts->push_back(u);
            }
            b->Stmts(stmts);
            return b;
        }
        case StatementKind::Conditional: {
            auto& cs = stmt.as<ConditionalStatement>();
            if (cs.conditions.size() != 1 || cs.conditions[0].pattern) {
                noteUnsupported("complex if condition");
                return nullptr;
            }
            // Surelog parents the condition expression at the if's enclosing
            // scope, not the if statement itself.
            if (cs.ifFalse) {
                auto* ie = s.MakeIf_else();
                ie->VpiParent(parent);
                setLoc(ie, stmt.sourceRange);
                if (auto* c = emitExpr(*cs.conditions[0].expr, parent, prefix, netMap))
                    ie->VpiCondition((UHDM::expr*)c);
                if (auto* t = emitStmt(cs.ifTrue, ie, prefix, netMap))
                    ie->VpiStmt(t);
                if (auto* f = emitStmt(*cs.ifFalse, ie, prefix, netMap))
                    ie->VpiElseStmt(f);
                return ie;
            }
            auto* is = s.MakeIf_stmt();
            is->VpiParent(parent);
            setLoc(is, stmt.sourceRange);
            if (auto* c = emitExpr(*cs.conditions[0].expr, parent, prefix, netMap))
                is->VpiCondition((UHDM::expr*)c);
            if (auto* t = emitStmt(cs.ifTrue, is, prefix, netMap))
                is->VpiStmt(t);
            return is;
        }
        default:
            noteUnsupported("statement kind: " + std::string(toString(stmt.kind)));
            return nullptr;
    }
}

UHDM::any* UhdmExporter::emitExpr(const Expression& expr, UHDM::BaseClass* parent,
                                  const std::string& prefix,
                                  NetMap& netMap) {
    switch (expr.kind) {
        case ExpressionKind::Assignment: {
            auto& ae = expr.as<AssignmentExpression>();
            auto* asn = s.MakeAssignment();
            asn->VpiOpType(kVpiAssignmentOp);
            asn->VpiBlocking(!ae.isNonBlocking());
            asn->VpiParent(parent);
            setLoc(asn, expr.sourceRange);
            if (auto* lhs = emitExpr(ae.left(), asn, prefix, netMap))
                asn->Lhs((UHDM::expr*)lhs);
            if (auto* rhs = emitExpr(ae.right(), asn, prefix, netMap))
                asn->Rhs(rhs);
            return asn;
        }
        case ExpressionKind::ConditionalOp: {
            auto& cond = expr.as<ConditionalExpression>();
            if (cond.conditions.size() != 1 || cond.conditions[0].pattern) {
                noteUnsupported("complex conditional");
                return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiConditionOp);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* c = emitExpr(*cond.conditions[0].expr, op, prefix, netMap))
                operands->push_back(c);
            if (auto* t = emitExpr(cond.left(), op, prefix, netMap))
                operands->push_back(t);
            if (auto* f = emitExpr(cond.right(), op, prefix, netMap))
                operands->push_back(f);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::NamedValue: {
            auto& nv = expr.as<NamedValueExpression>();
            auto* ref = s.MakeRef_obj();
            ref->VpiName(nv.symbol.name);
            ref->VpiFullName(prefix + "." + std::string(nv.symbol.name));
            ref->VpiParent(parent);
            setLoc(ref, expr.sourceRange);
            if (auto it = netMap.find(&nv.symbol); it != netMap.end())
                ref->Actual_group(it->second);
            return ref;
        }
        case ExpressionKind::UnaryOp: {
            auto& ue = expr.as<UnaryExpression>();
            int32_t opType = mapUnaryOp(ue.op);
            if (!opType) {
                noteUnsupported("unary op: " + std::string(toString(ue.op)));
                return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opType);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* e = emitExpr(ue.operand(), op, prefix, netMap))
                operands->push_back(e);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::BinaryOp: {
            auto& be = expr.as<BinaryExpression>();
            int32_t opType = mapBinaryOp(be.op);
            if (!opType) {
                noteUnsupported("binary op: " + std::string(toString(be.op)));
                return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opType);
            op->VpiParent(parent);
            setLoc(op, expr.sourceRange);
            auto* operands = s.MakeAnyVec();
            if (auto* l = emitExpr(be.left(), op, prefix, netMap))
                operands->push_back(l);
            if (auto* r = emitExpr(be.right(), op, prefix, netMap))
                operands->push_back(r);
            op->Operands(operands);
            return op;
        }
        case ExpressionKind::IntegerLiteral: {
            auto& il = expr.as<IntegerLiteral>();
            auto* c = s.MakeConstant();
            std::string raw = rawText(expr.sourceRange);
            c->VpiDecompile(raw);
            c->VpiSize((int32_t)expr.type->getBitWidth());
            setLoc(c, expr.sourceRange);
            // Surelog parents constants only as operation operands and
            // bit_select indices (not assignment sides or select ranges).
            if (parent && (parent->UhdmType() == UHDM::uhdmoperation ||
                           parent->UhdmType() == UHDM::uhdmbit_select))
                c->VpiParent(parent);

            auto tick = raw.find('\'');
            if (tick == std::string::npos) {
                // Bare decimal literals: Surelog encodes as 64-bit UINT.
                c->VpiSize(64);
                c->VpiValue("UINT:" + raw);
                c->VpiConstType(vpiUIntConst);
            }
            else {
                size_t basePos = tick + 1;
                if (basePos < raw.size() && (raw[basePos] == 's' || raw[basePos] == 'S'))
                    basePos++;
                char base = basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
                std::string digits = raw.substr(basePos + 1);
                switch (base) {
                    case 'b':
                        c->VpiValue("BIN:" + digits);
                        c->VpiConstType(vpiBinaryConst);
                        break;
                    case 'h':
                        c->VpiValue("HEX:" + digits);
                        c->VpiConstType(vpiHexConst);
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
            }
            (void)il;
            return c;
        }
        case ExpressionKind::Conversion: {
            auto& conv = expr.as<ConversionExpression>();
            if (conv.isImplicit())
                return emitExpr(conv.operand(), parent, prefix, netMap);
            noteUnsupported("explicit conversion");
            return nullptr;
        }
        case ExpressionKind::UnbasedUnsizedIntegerLiteral: {
            auto& ul = expr.as<UnbasedUnsizedIntegerLiteral>();
            auto* c = s.MakeConstant();
            std::string raw = rawText(expr.sourceRange);
            c->VpiDecompile(raw);
            c->VpiSize(-1);
            logic_t bit = ul.getLiteralValue();
            std::string digit = bit.isUnknown() ? (bit.value == logic_t::X_VALUE ? "x" : "z")
                                                : (bit.value ? "1" : "0");
            c->VpiValue("BIN:" + digit);
            c->VpiConstType(vpiBinaryConst);
            setLoc(c, expr.sourceRange);
            if (parent && (parent->UhdmType() == UHDM::uhdmoperation ||
                           parent->UhdmType() == UHDM::uhdmbit_select))
                c->VpiParent(parent);
            return c;
        }
        case ExpressionKind::ElementSelect: {
            auto& es = expr.as<ElementSelectExpression>();
            if (es.value().kind != ExpressionKind::NamedValue) {
                noteUnsupported("element select base");
                return nullptr;
            }
            auto& nv = es.value().as<NamedValueExpression>();
            auto* bs = s.MakeBit_select();
            bs->VpiName(nv.symbol.name);
            bs->VpiFullName(prefix + "." + std::string(nv.symbol.name));
            bs->VpiParent(parent);
            // Surelog anchors bit_selects at the index expression.
            setLoc(bs, es.selector().sourceRange);
            if (auto* ix = emitExpr(es.selector(), bs, prefix, netMap))
                bs->VpiIndex((UHDM::expr*)ix);
            return bs;
        }
        case ExpressionKind::RangeSelect: {
            auto& rs = expr.as<RangeSelectExpression>();
            if (rs.value().kind != ExpressionKind::NamedValue ||
                rs.getSelectionKind() != RangeSelectionKind::Simple) {
                noteUnsupported("range select form");
                return nullptr;
            }
            auto& nv = rs.value().as<NamedValueExpression>();
            auto* psel = s.MakePart_select();
            psel->VpiName(nv.symbol.name);
            psel->VpiDefName(nv.symbol.name);
            psel->VpiFullName(prefix + "." + std::string(nv.symbol.name));
            psel->VpiParent(parent);
            setLoc(psel, expr.sourceRange);
            bool constSel = rs.left().kind == ExpressionKind::IntegerLiteral &&
                            rs.right().kind == ExpressionKind::IntegerLiteral;
            if (constSel)
                psel->VpiConstantSelect(true);
            if (auto* l = emitExpr(rs.left(), psel, prefix, netMap))
                psel->Left_range((UHDM::expr*)l);
            if (auto* r = emitExpr(rs.right(), psel, prefix, netMap))
                psel->Right_range((UHDM::expr*)r);
            return psel;
        }
        default:
            noteUnsupported("expression kind: " + std::string(toString(expr.kind)));
            return nullptr;
    }
}

std::string UhdmExporter::rawText(SourceRange range) {
    if (range.start() == SourceLocation::NoLocation || range.end() == SourceLocation::NoLocation)
        return "";
    auto text = sm->getSourceText(range.start().buffer());
    size_t start = range.start().offset();
    size_t end = range.end().offset();
    if (end > text.size() || start > end)
        return "";
    return std::string(text.substr(start, end - start));
}

} // namespace slang_uhdm
