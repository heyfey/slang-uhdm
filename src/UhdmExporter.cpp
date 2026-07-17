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
#include "slang/ast/expressions/LiteralExpressions.h"
#include "slang/ast/expressions/MiscExpressions.h"
#include "slang/ast/expressions/OperatorExpressions.h"
#include "slang/ast/statements/MiscStatements.h"
#include "slang/ast/symbols/CompilationUnitSymbols.h"
#include "slang/ast/symbols/InstanceSymbols.h"
#include "slang/ast/symbols/MemberSymbols.h"
#include "slang/ast/symbols/PortSymbols.h"
#include "slang/ast/symbols/VariableSymbols.h"
#include "slang/ast/types/Type.h"
#include "slang/syntax/AllSyntax.h"
#include "slang/text/SourceManager.h"

using namespace slang;
using namespace slang::ast;

namespace slang_uhdm {

static constexpr int kVpiAssignmentOp = 82; // sv_vpi_user.h vpiAssignmentOp

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

UHDM::design* UhdmExporter::exportDesign() {
    auto& root = comp.getRoot();

    d = s.MakeDesign();
    if (!root.topInstances.empty())
        d->VpiName("work@" + std::string(root.topInstances[0]->getDefinition().name));

    auto* allMods = s.MakeModule_instVec();
    auto* topMods = s.MakeModule_instVec();

    for (auto inst : root.topInstances) {
        auto* def = emitModuleDef(*inst);
        allMods->push_back(def);
    }
    d->AllModules(allMods);

    for (auto inst : root.topInstances) {
        auto it = defMap.find(&inst->getDefinition());
        auto* top = emitTopModule(*inst, it->second);
        topMods->push_back(top);
    }
    d->TopModules(topMods);

    s.MakeUhdmHandle(UHDM::uhdmdesign, d);
    return d;
}

UHDM::module_inst* UhdmExporter::emitModuleDef(const InstanceSymbol& inst) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    std::string prefix = "work@" + std::string(def.name);

    auto* m = s.MakeModule_inst();
    m->VpiDefName(prefix);
    m->VpiFullName(prefix);
    m->VpiParent(d);
    m->VpiFile(fullFilePath(def.location));
    if (auto syntax = body.getSyntax())
        setLoc(m, syntax->sourceRange());

    DefInfo& info = defMap[&def];
    info.mod = m;

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
        if (internal->kind == SymbolKind::Variable)
            n->VpiNetType(vpiReg);
        info.nets[internal] = n;
        nets->push_back(n);
    }
    if (!nets->empty())
        m->Nets(nets);

    // Def-view ports share one typespec object per declaration (Surelog's
    // TypespecCache behavior), with no parent set.
    TsCache defTs;
    emitPorts(body, m, prefix, info.nets, /*topView=*/false, &defTs);

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

UHDM::module_inst* UhdmExporter::emitTopModule(const InstanceSymbol& inst, DefInfo& def) {
    auto& body = inst.body;
    std::string prefix = "work@" + std::string(inst.getDefinition().name);

    auto* m = s.MakeModule_inst();
    m->VpiName(prefix);
    m->VpiDefName(prefix);
    m->VpiFullName(prefix);
    m->VpiParent(d);
    m->VpiTop(true);
    m->VpiTopModule(true);
    m->VpiFile(fullFilePath(inst.getDefinition().location));
    if (auto syntax = body.getSyntax())
        setLoc(m, syntax->sourceRange());

    // Top view gets its own net objects, each carrying a typespec. The
    // typespec object is shared per declaration (Surelog's TypespecCache),
    // and its parent is overwritten by each net using it, so it ends up
    // pointing at the last net of the declaration.
    std::map<const Symbol*, UHDM::logic_net*> topNets;
    TsCache netTs;
    auto* nets = s.MakeNetVec();
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port)
            continue;
        auto& ps = portBase->as<PortSymbol>();
        auto* internal = ps.internalSymbol;
        if (!internal)
            continue;

        auto* n = s.MakeLogic_net();
        n->VpiName(ps.name);
        n->VpiFullName(prefix + "." + std::string(ps.name));
        n->VpiParent(m);
        setLocNamed(n, ps);
        if (internal->kind == SymbolKind::Variable)
            n->VpiNetType(vpiReg);

        auto* ts = sharedTypespec(*internal, netTs);
        ts->VpiParent(n);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(prefix + "." + std::string(ps.name));
        rt->VpiParent(n);
        rt->Actual_typespec(ts);
        n->Typespec(rt);

        topNets[internal] = n;
        nets->push_back(n);
    }
    if (!nets->empty())
        m->Nets(nets);

    // Top-view ports each get a fresh typespec object (no sharing).
    emitPorts(body, m, prefix, topNets, /*topView=*/true, nullptr);

    // Processes are shared with the definition (folded model).
    if (!def.processes.empty()) {
        auto* procs = s.MakeProcess_stmtVec();
        for (auto* p : def.processes)
            procs->push_back(p);
        m->Process(procs);
    }

    return m;
}

void UhdmExporter::emitPorts(const InstanceBodySymbol& body, UHDM::module_inst* m,
                             const std::string& prefix,
                             std::map<const Symbol*, UHDM::logic_net*>& netMap, bool topView,
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

        UHDM::logic_typespec* ts = sharedTs ? sharedTypespec(*internal, *sharedTs)
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

UHDM::logic_typespec* UhdmExporter::makeTypespec(const Symbol& declSymbol) {
    auto* ts = s.MakeLogic_typespec();

    SourceLocation implicitLoc = firstDeclaratorLoc(declSymbol);
    SourceRange range(implicitLoc, implicitLoc);
    if (auto declared = declSymbol.getDeclaredType()) {
        if (auto tsyn = declared->getTypeSyntax()) {
            if (tsyn->kind != syntax::SyntaxKind::ImplicitType) {
                auto sr = tsyn->sourceRange();
                if (sr.start() != SourceLocation::NoLocation)
                    range = sr;
            }
        }
    }
    setLoc(ts, range);
    return ts;
}

UHDM::logic_typespec* UhdmExporter::sharedTypespec(const Symbol& declSymbol, TsCache& cache) {
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
                                              std::map<const Symbol*, UHDM::logic_net*>& netMap) {
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

UHDM::any* UhdmExporter::emitStmt(const Statement& stmt, UHDM::BaseClass* parent,
                                  const std::string& prefix,
                                  std::map<const Symbol*, UHDM::logic_net*>& netMap) {
    switch (stmt.kind) {
        case StatementKind::Timed: {
            auto& timed = stmt.as<TimedStatement>();
            auto& timing = timed.timing;
            if (timing.kind == TimingControlKind::ImplicitEvent) {
                auto* ec = s.MakeEvent_control();
                ec->VpiParent(parent);
                setLoc(ec, timing.sourceRange);
                if (auto* inner = emitStmt(timed.stmt, ec, prefix, netMap))
                    ec->Stmt(inner);
                return ec;
            }
            noteUnsupported("timing control: " + std::string(toString(timing.kind)));
            return nullptr;
        }
        case StatementKind::ExpressionStatement: {
            auto& es = stmt.as<ExpressionStatement>();
            return emitExpr(es.expr, parent, prefix, netMap);
        }
        default:
            noteUnsupported("statement kind: " + std::string(toString(stmt.kind)));
            return nullptr;
    }
}

UHDM::any* UhdmExporter::emitExpr(const Expression& expr, UHDM::BaseClass* parent,
                                  const std::string& prefix,
                                  std::map<const Symbol*, UHDM::logic_net*>& netMap) {
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
        default:
            noteUnsupported("expression kind: " + std::string(toString(expr.kind)));
            return nullptr;
    }
}

} // namespace slang_uhdm
