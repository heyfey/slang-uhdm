//------------------------------------------------------------------------------
//! @file ModuleEmit.cpp
//! @brief Module definitions, instances, ports, continuous assigns
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

namespace slang_uhdm {

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

    // (Def-view parameters were emitted in the exportDesign pre-pass.)

    // Nets: ANSI modules list port-backed nets before locals; non-ANSI
    // modules list locals first (Surelog's collection order).
    bool ansiPorts = true;
    std::set<const Symbol*> portInternals;
    for (auto portBase : body.getPortList()) {
        if (portBase->kind == SymbolKind::Port) {
            auto& ps = portBase->as<PortSymbol>();
            if (!ps.isAnsiPort)
                ansiPorts = false;
            if (ps.internalSymbol)
                portInternals.insert(ps.internalSymbol);
        }
    }
    auto* nets = s.MakeNetVec();
    TsCache& defTs = info.defTs;
    auto emitDefPortNets = [&]() {
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
            setLocNamed(n, ps); // Surelog uses the port-list location
            if (int32_t nt = netTypeFor(*internal))
                n->VpiNetType(nt);
            info.nets[internal] = n;
            nets->push_back(n);
        }
    };
    if (ansiPorts)
        emitDefPortNets();
    // Local (non-port) declarations stay logic_nets in the def view, but
    // carry a typespec and explicit net type.
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Net && member.kind != SymbolKind::Variable)
            continue;
        if (portInternals.count(&member))
            continue;
        auto* n = s.MakeLogic_net();
        n->VpiName(member.name);
        n->VpiFullName(prefix + "." + std::string(member.name));
        n->VpiParent(m);
        setLocNamed(n, member);
        if (int32_t nt = netTypeFor(member))
            n->VpiNetType(nt);
        // The actual typespec object is created only after the top-level
        // instance's ports (Surelog arena order); the ref is patched then.
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(prefix + "." + std::string(member.name));
        rt->VpiParent(n);
        n->Typespec(rt);
        pendingNetTs.push_back({&member, rt, &info});
        info.nets[&member] = n;
        nets->push_back(n);
    }
    if (!ansiPorts)
        emitDefPortNets();
    if (!nets->empty())
        m->Nets(nets);

    // Def-view cont_assigns come before ports (their typespecs precede the
    // port typespecs in Surelog's arena).
    emitContAssigns(body, m, prefix, info.nets, /*topView=*/false, &info, false, nullptr,
                    nullptr);

    // Processes are compiled as module items, so any typespecs they create
    // (for-loop vars, cast typespecs) also precede the port typespecs.
    auto* procs = s.MakeProcess_stmtVec();
    refCollector = &info.processRefs;
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::ProceduralBlock) {
            auto* p = emitProcess(member.as<ProceduralBlockSymbol>(), m, prefix, info.nets);
            if (p) {
                procs->push_back(p);
                info.processes.push_back(p);
            }
        }
    }
    refCollector = nullptr;
    if (!procs->empty())
        m->Process(procs);

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

    return m;
}

UHDM::module_inst* UhdmExporter::emitInstance(const InstanceSymbol& inst, const std::string& path,
                                              UHDM::module_inst* parentM, NetMap* parentNets,
                                              std::set<const Symbol*>* parentRefs, bool isTop) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    // Pending-typespec ranges owned by this top's tree (recorded before the
    // def fill, which already queues def-local net typespecs).
    size_t paramLo = pendingParamTs.size();
    size_t netTsLo = pendingNetTs.size();
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
    std::set<const Symbol*> instRefs;
    analyzeParamEnc(body);
    {
        auto pit = defMap.find(&def);
        emitParameters(body, m, prefix, topNets, /*topView=*/true,
                       pit != defMap.end() ? &pit->second : nullptr, false);
    }
    std::vector<std::pair<const Symbol*, UHDM::any*>> sigOrder;
    bool ansiPorts = true;
    std::set<const Symbol*> portInternals;
    for (auto portBase : body.getPortList()) {
        if (portBase->kind == SymbolKind::Port) {
            auto& ps = portBase->as<PortSymbol>();
            if (!ps.isAnsiPort)
                ansiPorts = false;
            if (ps.internalSymbol)
                portInternals.insert(ps.internalSymbol);
        }
    }
    auto* nets = s.MakeNetVec();
    auto* vars = s.MakeVariablesVec();
    auto emitInstPortNets = [&]() {
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
            sigOrder.emplace_back(internal, v);
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
            if (internal->getDeclaredType() &&
                internal->getDeclaredType()->getType().isSigned())
                n->VpiSigned(true);
            rt->VpiParent(n);
            n->Typespec(rt);
            // Surelog parents the net typespec at creation; a shared
            // declaration-group typespec ends at the group's last net.
            ts->VpiParent(n);
            topNets[internal] = n;
            sigOrder.emplace_back(internal, n);
            nets->push_back(n);
        }
    }
    };
    if (ansiPorts)
        emitInstPortNets();
    // Local (non-port) declarations: logic/reg variables become logic_vars,
    // explicit nets stay logic_nets.
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Net && member.kind != SymbolKind::Variable)
            continue;
        if (portInternals.count(&member))
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
            sigOrder.emplace_back(&member, v);
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
            rt->VpiParent(n);
            n->Typespec(rt);
            ts->VpiParent(n);
            topNets[&member] = n;
            sigOrder.emplace_back(&member, n);
            nets->push_back(n);
        }
    }
    if (!ansiPorts)
        emitInstPortNets();
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
                                             &topNets, &instRefs, /*isTop=*/false));
        }
    }
    if (!children->empty())
        m->Modules(children);

    // Instance-view ports each get a fresh typespec object (no sharing).
    // Top-level instances' ports are emitted in a second pass over all tops
    // (Surelog write phase), after every top's netlist elaboration.
    if (!isTop) {
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
            for (auto c : inst.getPortConnections()) {
                if (&c->port == portBase) {
                    conn = c;
                    break;
                }
            }

            auto* lc = s.MakeRef_obj();
            lc->VpiName(ps.name);
            lc->VpiFullName(prefix + "." + std::string(ps.name));
            lc->VpiParent(p);
            // Child low conns anchor at the formal name in the connection.
            if (auto npc = findConnSyntax(inst, ps.name))
                setLoc(lc, SourceRange(npc->name.location(),
                                       npc->name.location() + ps.name.size()));
            else
                setLocNamed(lc, ps);
            if (auto it = topNets.find(internal); it != topNets.end())
                lc->Actual_group(it->second);
            p->Low_conn(lc);

            if (conn && parentNets) {
                if (auto expr = connectionExpr(*conn)) {
                    // Signals feeding child connections count as
                    // instance-view references (drives typespec reparenting
                    // in the parent).
                    refCollector = parentRefs;
                    if (auto* h = emitExpr(*expr, p, parentPrefix, *parentNets))
                        p->High_conn(h);
                    refCollector = nullptr;
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
    }

    std::set<const Symbol*> caLhsSyms;
    {
        auto it = defMap.find(&def);
        emitContAssigns(body, m, prefix, topNets, /*topView=*/true,
                        it != defMap.end() ? &it->second : nullptr, isTop, &instRefs,
                        &caLhsSyms);
    }

    // Deferred typespecs drain in the second (port) pass over top instances.

    // Nets got their typespec parent at creation; a cont_assign LHS
    // elaboration re-points it at a temporary that Save() collects, so those
    // typespecs end up unparented.
    for (auto sym : caLhsSyms) {
        auto it = topNets.find(sym);
        if (it == topNets.end())
            continue;
        auto* ex = (UHDM::expr*)it->second;
        if (ex->UhdmType() != UHDM::uhdmlogic_net)
            continue;
        if (ex->Typespec() && ex->Typespec()->Actual_typespec())
            ex->Typespec()->Actual_typespec()->VpiParent(nullptr);
    }

    // Variables (not nets) get their typespec parent only when referenced in
    // processes, re-emitted cont_assigns, or child connections (Surelog's
    // rebind behavior).
    {
        auto dit = defMap.find(&def);
        for (auto& [sym, obj] : sigOrder) {
            auto ut = ((UHDM::any*)obj)->UhdmType();
            if (ut == UHDM::uhdmlogic_net)
                continue;
            bool touched = instRefs.count(sym) ||
                           (dit != defMap.end() && dit->second.processRefs.count(sym));
            if (!touched)
                continue;
            auto* ex = (UHDM::expr*)obj;
            if (ex->Typespec() && ex->Typespec()->Actual_typespec())
                ex->Typespec()->Actual_typespec()->VpiParent(ex);
        }
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

    if (isTop) {
        topPendings.push_back({&inst, m, prefix, std::move(topNets), paramLo,
                               pendingParamTs.size(), netTsLo, pendingNetTs.size()});
    }

    return m;
}

// Second pass over a top instance: ports, then that top's deferred
// typespecs (Surelog write-phase arena order).
void UhdmExporter::emitTopPorts(TopPending& tp) {
    auto& body = tp.inst->body;
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
        p->VpiParent(tp.m);
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
        lc->VpiFullName(tp.prefix + "." + std::string(ps.name));
        lc->VpiParent(p);
        setLocNamed(lc, ps);
        if (auto it = tp.nets.find(internal); it != tp.nets.end())
            lc->Actual_group(it->second);
        p->Low_conn(lc);

        auto* pts = makeTypespec(*internal);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(tp.prefix + "." + std::string(ps.name));
        rt->VpiParent(p);
        rt->Actual_typespec(pts);
        p->Typespec(rt);
        ports->push_back(p);
    }
    if (!ports->empty())
        tp.m->Ports(ports);

    // Instance param typespecs first, then def-view local-net typespecs.
    patchParamTypespecs(tp.paramLo, tp.paramHi);
    for (size_t i = tp.netTsLo; i < tp.netTsHi; i++) {
        auto& pn = pendingNetTs[i];
        pn.rt->Actual_typespec(sharedTypespec(*pn.sym, pn.di->defTs));
    }
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

void UhdmExporter::emitContAssigns(const InstanceBodySymbol& body, UHDM::module_inst* m,
                                   const std::string& prefix, NetMap& netMap, bool topView,
                                   DefInfo* defInfo, bool shareWithDef,
                                   std::set<const Symbol*>* instRefs,
                                   std::set<const Symbol*>* lhsSyms) {
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
        if (lhsSyms)
            collectLhsSyms(ae.left(), *lhsSyms);
        bool literalRhs = isLiteralExpr(ae.right());
        // Top modules share the def's cont_assign object unless the RHS
        // contains operations or is a literal (netlist elaboration
        // re-compiles those, folded or not).
        if (shareWithDef && defInfo && myIdx < defInfo->contAssigns.size() &&
            !containsOperation(ae.right()) && !literalRhs) {
            cas->push_back(defInfo->contAssigns[myIdx]);
            continue;
        }
        auto* ca = s.MakeCont_assign();
        ca->VpiParent(m);
        setLoc(ca, assign.sourceRange);
        UHDM::any* rhs = topView ? tryFoldConst(ae.right()) : nullptr;
        // Sized/based literal RHS: the top-view cont_assign is fresh but its
        // Rhs reuses the def's constant (Surelog's expression cache); bare
        // decimals are re-emitted fresh.
        if (!rhs && topView && shareWithDef && literalRhs && defInfo &&
            myIdx < defInfo->contAssigns.size()) {
            auto raw = rawText(stripImplicitConv(ae.right()).sourceRange);
            if (raw.find('\'') != std::string::npos)
                rhs = (UHDM::any*)defInfo->contAssigns[myIdx]->Rhs();
        }
        if (!rhs) {
            if (topView) {
                refCollector = instRefs;
                reemitting = true;
            }
            // A literal RHS constant is parented at the cont_assign (both
            // views); re-emitted top-view RHS refs bind the def-view nets.
            NetMap& rhsMap = (topView && shareWithDef && defInfo) ? defInfo->nets : netMap;
            bool forceSaved = forceConstParent;
            if (literalRhs)
                forceConstParent = true;
            rhs = emitExpr(ae.right(), ca, prefix, rhsMap);
            forceConstParent = forceSaved;
            refCollector = nullptr;
            reemitting = false;
        }
        if (rhs)
            ca->Rhs((UHDM::expr*)rhs);
        inLhs = true;
        if (auto* l = emitExpr(ae.left(), ca, prefix, netMap))
            ca->Lhs((UHDM::expr*)l);
        inLhs = false;
        cas->push_back(ca);
        if (defInfo)
            defInfo->contAssigns.push_back(ca);
    }
    if (!cas->empty())
        m->Cont_assigns(cas);
}

} // namespace slang_uhdm
