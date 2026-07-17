//------------------------------------------------------------------------------
//! @file ModuleEmit.cpp
//! @brief Module definitions, instances, ports, continuous assigns
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

namespace slang_uhdm {

UHDM::module_inst* UhdmExporter::emitModuleDef(const InstanceSymbol& inst, bool topDef) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    size_t netTsAtEntry = pendingNetTs.size();
    std::string prefix = "work@" + std::string(def.name);

    DefInfo& info = defMap[&def];
    currentScope = &body;
    auto* m = info.mod;
    m->VpiDefName(prefix);
    m->VpiFullName(prefix);
    m->VpiParent(d);
    m->VpiFile(fullFilePath(def.location));
    if (auto syntax = body.getSyntax())
        setLoc(m, syntax->sourceRange());

    // (Def-view parameters were emitted in the exportDesign pre-pass.)

    // Typedefs first: their base typespecs precede everything else in the
    // def's arena region.
    emitTypedefs(body, m, prefix, info);

    // Nets in Surelog's collection order: explicit declarations by source
    // location, then port-declaration-only nets in port-list order.
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port)
            noteUnsupported("port kind: " + std::string(toString(portBase->kind)));
    }
    auto* nets = s.MakeNetVec();
    TsCache& defTs = info.defTs;
    (void)defTs;
    for (auto& it : collectNetOrder(body)) {
        std::string name(it.sym->name);
        auto* n = s.MakeLogic_net();
        n->VpiName(name);
        n->VpiFullName(prefix + "." + name);
        n->VpiParent(m);
        // Port nets without a body re-declaration anchor at the port-list
        // name; anything with a real declaration anchors there.
        if (it.port && !it.bodyDecl)
            setLocNamed(n, *it.port);
        else
            setLoc(n, nameSpan(it.sym->location, it.sym->name));
        if (int32_t nt = netTypeFor(*it.sym))
            n->VpiNetType(nt);
        if (!it.port) {
            // Local nets carry a typespec whose actual is created only in
            // the write phase (Surelog arena order); the ref is patched then.
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(prefix + "." + name);
            rt->VpiParent(n);
            n->Typespec(rt);
            pendingNetTs.push_back({it.sym, rt, &info});
        }
        if (auto attrs = comp.getAttributes(*it.sym); !attrs.empty()) {
            // Surelog keeps only the last attribute spec; the object is
            // shared with the instance view.
            auto* av = s.MakeAttributeVec();
            auto* ua = s.MakeAttribute();
            ua->VpiName(attrs.back()->name);
            if (auto asyn = attrs.back()->getSyntax())
                setLoc(ua, asyn->sourceRange());
            ua->VpiParent(n);
            av->push_back(ua);
            n->Attributes(av);
            attrMap[it.sym] = ua;
        }
        info.nets[it.sym] = n;
        nets->push_back(n);
    }
    if (!nets->empty())
        m->Nets(nets);

    // Tasks/functions are module items; their typespecs (return, io_decls)
    // precede cont_assign and port typespecs.
    emitTaskFuncs(body, m, prefix, info);

    // Def-view cont_assigns come before ports (their typespecs precede the
    // port typespecs in Surelog's arena).
    emitContAssigns(body, m, prefix, info.nets, /*topView=*/false, &info, false, nullptr,
                    nullptr);

    // Processes are compiled as module items, so any typespecs they create
    // (for-loop vars, cast typespecs) also precede the port typespecs.
    auto* procs = s.MakeProcess_stmtVec();
    refCollector = &info.processRefs;
    inProcessEmit = true;
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::ProceduralBlock) {
            auto* p = emitProcess(member.as<ProceduralBlockSymbol>(), m, prefix, info.nets);
            if (p) {
                procs->push_back(p);
                info.processes.push_back(p);
            }
        }
    }
    inProcessEmit = false;
    refCollector = nullptr;
    if (!procs->empty())
        m->Process(procs);

    // Def view keeps only a gen_region placeholder per generate construct
    // (an unlocated begin naming the module scope).
    {
        auto* regions = s.MakeGen_stmtVec();
        for (auto& member : body.members()) {
            if (member.kind != SymbolKind::GenerateBlockArray &&
                member.kind != SymbolKind::GenerateBlock)
                continue;
            auto* gr = s.MakeGen_region();
            gr->VpiParent(m);
            auto* b = s.MakeBegin();
            b->VpiFullName(prefix);
            b->VpiParent(gr);
            gr->VpiStmt(b);
            regions->push_back(gr);
        }
        if (!regions->empty())
            m->Gen_stmts(regions);
    }

    // Def-view ports share one typespec object per declaration (Surelog's
    // TypespecCache behavior), with no parent set; their param-dim bounds
    // are folded (recompiled), unlike local-net typespecs.
    emitPorts(body, m, prefix, info.nets, /*topView=*/false, &defTs);

    // Child instance references (def view uses ref_module stubs; bound
    // instances are skipped in the def view).
    auto* refmods = s.MakeRef_moduleVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Instance)
            continue;
        auto& child = member.as<InstanceSymbol>();
        bool fromBind = false;
        for (auto p2 = child.getSyntax(); p2; p2 = p2->parent) {
            if (p2->kind == syntax::SyntaxKind::BindDirective) {
                fromBind = true;
                break;
            }
        }
        if (fromBind)
            continue;
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

    (void)netTsAtEntry;
    (void)topDef;

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
    size_t childNetTsLo = pendingNetTs.size();
    // Surelog materializes a definition the first time the instance tree
    // reaches it; typespec creation order depends on this.
    if (!defMap[&def].filled) {
        defMap[&def].filled = true;
        emitModuleDef(inst, isTop);
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
    std::string bindPath = bindDisplayPath;
    bindDisplayPath.clear();
    if (!isTop && !bindPath.empty()) {
        m->VpiName(inst.name);
        m->VpiFullName(bindPath);
        m->VpiParent(parentM);
        m->Instance(parentM);
        m->Module_inst(parentM);
        m->VpiDefFile(fullFilePath(def.location));
        m->VpiDefLineNo((int32_t)sm->getLineNumber(def.location));
        if (auto syn = inst.getSyntax()) {
            const syntax::SyntaxNode* stmtSyn = syn;
            while (stmtSyn->parent &&
                   stmtSyn->kind != syntax::SyntaxKind::HierarchyInstantiation) {
                stmtSyn = stmtSyn->parent;
            }
            setLoc(m, stmtSyn->sourceRange());
        }
    }
    else if (!isTop) {
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
                       pit != defMap.end() ? &pit->second : nullptr, false,
                       /*topShareTs=*/isTop);
    }
    std::vector<std::pair<const Symbol*, UHDM::any*>> sigOrder;
    auto* nets = s.MakeNetVec();
    auto* vars = s.MakeVariablesVec();
    for (auto& it : collectNetOrder(body)) {
        std::string name(it.sym->name);
        std::string fullName = prefix + "." + name;
        // Vector-typedef signals bind a fresh plain NAMED clone (built at
        // net-emission time, no alias link).
        UHDM::typespec* ts = nullptr;
        if (auto dtv = it.sym->getDeclaredType()) {
            auto& tv = dtv->getType();
            if (typedefClone.count(&tv)) {
                const syntax::SyntaxNode* targetSyn = nullptr;
                if (auto asyn = tv.as<TypeAliasType>().getSyntax()) {
                    if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                        targetSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
                }
                bypassTypedefShare = true;
                ts = makeTypespec(*it.sym, targetSyn);
                bypassTypedefShare = false;
                ts->VpiName(tv.name);
            }
        }
        if (!ts)
            ts = sharedTypespec(*it.sym, netTs);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(fullName);
        rt->Actual_typespec(ts);
        if (auto* v = makeVar(*it.sym, /*portBacked=*/it.port != nullptr)) {
            v->VpiName(name);
            v->VpiFullName(fullName);
            v->VpiParent(m);
            if (it.port && !it.bodyDecl)
                setLocNamed(v, *it.port);
            else
                setLoc(v, nameSpan(it.sym->location, it.sym->name));
            rt->VpiParent(v);
            v->Typespec(rt);
            if (ts->UhdmType() == UHDM::uhdmenum_typespec &&
                ((UHDM::enum_typespec*)ts)->VpiName().empty()) {
                ts->VpiParent(v);
                if (((UHDM::enum_typespec*)ts)->Base_typespec())
                    ((UHDM::enum_typespec*)ts)->Base_typespec()->VpiFullName(fullName);
            }
            // Var initializers appear as vpiExpr on the top var (enum-const
            // refs or literal constants, parented at the var).
            if (auto dt = it.sym->getDeclaredType()) {
                if (auto init = dt->getInitializer()) {
                    auto& ic = stripImplicitConv(*init);
                    bool enumRef = ic.kind == ExpressionKind::NamedValue &&
                                   ic.as<NamedValueExpression>().symbol.kind ==
                                       SymbolKind::EnumValue;
                    if (enumRef || isLiteralExpr(ic)) {
                        bool forceSaved = forceConstParent;
                        if (!enumRef)
                            forceConstParent = true;
                        if (auto* e = emitExpr(ic, v, fullName, topNets)) {
                            // Bare-decimal inits size at the var type width.
                            if (e->UhdmType() == UHDM::uhdmconstant &&
                                rawText(ic.sourceRange).find('\'') == std::string::npos)
                                ((UHDM::constant*)e)->VpiSize(
                                    (int32_t)dt->getType().getBitWidth());
                            v->Expr((UHDM::expr*)e);
                        }
                        forceConstParent = forceSaved;
                    }
                }
            }
            if (auto ait = attrMap.find(it.sym); ait != attrMap.end()) {
                auto* av = s.MakeAttributeVec();
                av->push_back(ait->second);
                v->Attributes(av);
            }
            // Vars creation-parent their (non-typedef) typespec like nets;
            // a shared decl-group ts ends at the group's last var.
            if (ts->UhdmType() != UHDM::uhdmenum_typespec &&
                ts->UhdmType() != UHDM::uhdmstruct_typespec && ts->VpiName().empty())
                ts->VpiParent(v);
            // Initialized plain-typed vars span declarator..init.
            if (auto dtl = it.sym->getDeclaredType();
                dtl && dtl->getInitializer() && ts->VpiName().empty()) {
                if (auto dsyn = it.sym->getSyntax()) {
                    auto dr = dsyn->sourceRange();
                    if (dr.start() != SourceLocation::NoLocation)
                        setLoc(v, dr);
                }
            }
            topNets[it.sym] = v;
            sigOrder.emplace_back(it.sym, v);
            vars->push_back(v);
        }
        else {
            // Packed-struct signals become struct_nets in the instance view.
            bool isStruct = false;
            if (auto dt = it.sym->getDeclaredType())
                isStruct = dt->getType().getCanonicalType().kind ==
                           SymbolKind::PackedStructType;
            UHDM::net* n = isStruct ? (UHDM::net*)s.MakeStruct_net()
                                    : (UHDM::net*)s.MakeLogic_net();
            n->VpiName(name);
            n->VpiFullName(fullName);
            n->VpiParent(m);
            if (it.port && !it.bodyDecl)
                setLocNamed(n, *it.port);
            else
                setLoc(n, nameSpan(it.sym->location, it.sym->name));
            if (!isStruct) {
                if (int32_t nt = netTypeFor(*it.sym))
                    ((UHDM::logic_net*)n)->VpiNetType(nt);
                if (it.sym->getDeclaredType() &&
                    it.sym->getDeclaredType()->getType().isSigned())
                    n->VpiSigned(true);
            }
            rt->VpiParent(n);
            n->Typespec(rt);
            // Surelog parents the net typespec at creation; a shared
            // declaration-group typespec ends at the group's last net.
            // Typedef typespecs keep their own parent.
            if (ts->UhdmType() != UHDM::uhdmenum_typespec &&
                ts->UhdmType() != UHDM::uhdmstruct_typespec)
                ts->VpiParent(n);
            topNets[it.sym] = n;
            sigOrder.emplace_back(it.sym, n);
            nets->push_back(n);
        }
    }
    if (!nets->empty())
        m->Nets(nets);
    if (!vars->empty())
        m->Variables(vars);

    // Children are elaborated before the instance's own ports (typespec
    // creation order follows Surelog).
    if (isTop) {
        currentTopPrefix = prefix;
        currentTopNets = &topNets;
    }
    auto* children = s.MakeModule_instVec();
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::Instance) {
            auto& child = member.as<InstanceSymbol>();
            // Bound instances path directly under the top module.
            bool fromBind = false;
            for (auto p2 = child.getSyntax(); p2; p2 = p2->parent) {
                if (p2->kind == syntax::SyntaxKind::BindDirective) {
                    fromBind = true;
                    break;
                }
            }
            if (fromBind && !currentTopPrefix.empty())
                bindDisplayPath = currentTopPrefix + "." + std::string(child.name);
            children->push_back(emitInstance(child, prefix + "." + std::string(child.name), m,
                                             &topNets, &instRefs, /*isTop=*/false));
            bindDisplayPath.clear();
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
            // Bound instances: display-scoped low conns bound to DEF nets;
            // high conns resolve in the bind-directive (top) scope.
            lc->VpiFullName((bindPath.empty() ? prefix : bindPath) + "." +
                            std::string(ps.name));
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
                    // Bound instances: TOP-scoped high-conn names, parent
                    // binding.
                    const std::string& hcPrefix =
                        (!bindPath.empty() && !currentTopPrefix.empty()) ? currentTopPrefix
                                                                         : parentPrefix;
                    if (auto* h = emitExpr(*expr, p, hcPrefix, *parentNets))
                        p->High_conn(h);
                    refCollector = nullptr;
                }
            }

            auto* pts = makeTypespec(*internal, nullptr, &ps);
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
        // Bound instances' content binds DEF nets.
        NetMap* caNets = &topNets;
        if (!bindPath.empty() && it != defMap.end())
            caNets = &it->second.nets;
        emitContAssigns(body, m, prefix, *caNets, /*topView=*/true,
                        it != defMap.end() ? &it->second : nullptr, /*shareWithDef=*/true,
                        &instRefs, &caLhsSyms);
    }

    // Generate scopes exist only in the instance view.
    emitGenScopes(body, m, prefix, topNets);

    // Deferred typespecs drain in the second (port) pass over top instances.

    // Nets got their typespec parent at creation; a cont_assign LHS
    // elaboration re-points it at a temporary that Save() collects, so those
    // typespecs end up unparented.
    for (auto sym : caLhsSyms) {
        auto it = topNets.find(sym);
        if (it == topNets.end())
            continue;
        auto* ex = (UHDM::expr*)it->second;
        if (ex->Typespec() && ex->Typespec()->Actual_typespec()) {
            auto* a = ex->Typespec()->Actual_typespec();
            if (a->UhdmType() != UHDM::uhdmenum_typespec &&
                a->UhdmType() != UHDM::uhdmstruct_typespec)
                a->VpiParent(nullptr);
        }
    }

    // ALL instances share the definition's process objects (the def is the
    // single compiled copy); task/function and typedef objects too.
    if (true) {
        auto it = defMap.find(&def);
        if (it != defMap.end() && !it->second.processes.empty()) {
            auto* procs = s.MakeProcess_stmtVec();
            for (auto* p : it->second.processes)
                procs->push_back(p);
            m->Process(procs);
        }
        if (isTop && it != defMap.end() && !it->second.taskFuncs.empty()) {
            auto* tfs = s.MakeTask_funcVec();
            for (auto* tf : it->second.taskFuncs)
                tfs->push_back(tf);
            m->Task_funcs(tfs);
        }
        if (isTop && it != defMap.end() && !it->second.typedefs.empty()) {
            auto* tds = s.MakeTypespecVec();
            for (auto* td : it->second.typedefs)
                tds->push_back(td);
            m->Typespecs(tds);
        }
    }
    else {
        // Bound instances' re-emitted content binds DEF nets.
        NetMap* contentNets = &topNets;
        if (!bindPath.empty()) {
            auto dit = defMap.find(&def);
            if (dit != defMap.end())
                contentNets = &dit->second.nets;
        }
        auto* procs = s.MakeProcess_stmtVec();
        for (auto& member : body.members()) {
            if (member.kind == SymbolKind::ProceduralBlock) {
                if (auto* p =
                        emitProcess(member.as<ProceduralBlockSymbol>(), m, prefix, *contentNets))
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
    (void)childNetTsLo;

    return m;
}

// Generate blocks: one gen_scope_array + gen_scope per unrolled iteration
// (instance view only). The genvar becomes an unlocated localparam.
void UhdmExporter::emitGenScopes(const InstanceBodySymbol& body, UHDM::module_inst* m,
                                 const std::string& prefix, NetMap& netMap) {
    auto* gsas = s.MakeGen_scope_arrayVec();
    auto emitBlock = [&](const GenerateBlockSymbol& blk, const std::string& name) {
        std::string fullName = prefix + "." + name;
        auto* gsa = s.MakeGen_scope_array();
        gsa->VpiName(name);
        gsa->VpiFullName(fullName);
        gsa->VpiParent(m);
        auto* gs = s.MakeGen_scope();
        gs->VpiFullName(fullName);
        gs->VpiParent(gsa);
        if (auto syn = blk.getSyntax()) {
            setLoc(gsa, syn->sourceRange());
            setLoc(gs, syn->sourceRange());
        }
        auto* gv = s.MakeGen_scopeVec();
        gv->push_back(gs);
        gsa->Gen_scopes(gv);

        // Genvar localparam: line of the generate loop, column 0, no end.
        auto* params = s.MakeAnyVec();
        for (auto& gm : blk.members()) {
            if (gm.kind != SymbolKind::Parameter)
                continue;
            auto& ps = gm.as<ParameterSymbol>();
            auto* up = s.MakeParameter();
            up->VpiName(ps.name);
            up->VpiFullName(fullName + "." + std::string(ps.name));
            up->VpiParent(gs);
            up->VpiLocalParam(true);
            auto& cv = ps.getValue();
            if (cv.isInteger() && !cv.integer().hasUnknown()) {
                bool neg = cv.integer().isSigned() && cv.integer().isNegative();
                std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
                up->VpiValue((neg ? "INT:" : "UINT:") + digits);
            }
            if (auto syn = blk.getSyntax()) {
                up->VpiLineNo(sm->getLineNumber(syn->sourceRange().start()));
                up->VpiColumnNo(0);
            }
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(fullName + "." + std::string(ps.name));
            rt->VpiParent(up);
            // Actual int_typespec created at the end of the write phase.
            pendingIoTs.push_back({rt, rt});
            up->Typespec(rt);
            params->push_back(up);
        }
        if (!params->empty())
            gs->Parameters(params);

        // Contents: cont_assigns and processes with gen-scoped prefixes.
        auto* cas = s.MakeCont_assignVec();
        for (auto& gm : blk.members()) {
            if (gm.kind != SymbolKind::ContinuousAssign)
                continue;
            auto& casym = gm.as<ContinuousAssignSymbol>();
            auto& assign = casym.getAssignment();
            if (assign.kind != ExpressionKind::Assignment)
                continue;
            auto& ae = assign.as<AssignmentExpression>();
            auto* ca = s.MakeCont_assign();
            ca->VpiParent(gs);
            setLoc(ca, assign.sourceRange);
            bool forceSaved = forceConstParent;
            if (isLiteralExpr(ae.right()))
                forceConstParent = true;
            if (auto* rhs = emitExpr(ae.right(), ca, fullName, netMap))
                ca->Rhs((UHDM::expr*)rhs);
            forceConstParent = forceSaved;
            inLhs = true;
            if (auto* l = emitExpr(ae.left(), ca, fullName, netMap))
                ca->Lhs((UHDM::expr*)l);
            inLhs = false;
            cas->push_back(ca);
        }
        if (!cas->empty())
            gs->Cont_assigns(cas);

        auto* procs = s.MakeProcess_stmtVec();
        for (auto& gm : blk.members()) {
            if (gm.kind == SymbolKind::ProceduralBlock) {
                if (auto* p = emitProcess(gm.as<ProceduralBlockSymbol>(), m, fullName, netMap)) {
                    p->VpiParent(gs);
                    procs->push_back(p);
                }
            }
        }
        if (!procs->empty())
            gs->Process(procs);

        gsas->push_back(gsa);
    };
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::GenerateBlockArray) {
            auto& arr = member.as<GenerateBlockArraySymbol>();
            for (auto entry : arr.entries) {
                if (entry->isUninstantiated)
                    continue;
                std::string idx;
                if (entry->arrayIndex)
                    idx = entry->arrayIndex->toString(LiteralBase::Decimal, false);
                std::string name = std::string(arr.getExternalName()) + "[" + idx + "]";
                emitBlock(*entry, name);
            }
        }
        else if (member.kind == SymbolKind::GenerateBlock) {
            auto& blk = member.as<GenerateBlockSymbol>();
            if (!blk.isUninstantiated)
                emitBlock(blk, std::string(blk.getExternalName()));
        }
    }
    if (!gsas->empty())
        m->Gen_scope_arrays(gsas);
}


// Builds a def-local net's typespec (fresh per net; vector typedefs get a
// NAMED clone with Instance + TypedefAlias; anonymous enums fresh
// unparented; initialized decls extend through the init).
void UhdmExporter::materializeDefNetTs(PendingNetTs& pn) {
    UHDM::typespec* ts = nullptr;
    if (auto dt2 = pn.sym->getDeclaredType()) {
        auto& t2 = dt2->getType();
        if (typedefClone.count(&t2)) {
            auto& ta2 = t2.as<TypeAliasType>();
            const syntax::SyntaxNode* targetSyn = nullptr;
            if (auto asyn = ta2.getSyntax()) {
                if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                    targetSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
            }
            bypassTypedefShare = true;
            ts = makeTypespec(*pn.sym, targetSyn);
            bypassTypedefShare = false;
            ts->VpiName(t2.name);
            auto tit = typedefTs.find(&t2);
            if (tit != typedefTs.end()) {
                auto* mainTs = tit->second;
                ts->Instance(mainTs->Instance());
                auto* art = s.MakeRef_typespec();
                art->VpiFullName(t2.name);
                art->VpiParent(ts);
                art->Actual_typespec(mainTs);
                ((UHDM::logic_typespec*)ts)->Typedef_alias(art);
            }
        }
    }
    if (!ts)
        ts = makeTypespec(*pn.sym);
    // Initialized decls extend the def-view typespec through the init.
    if (auto dtl = pn.sym->getDeclaredType();
        dtl && dtl->getInitializer() && ts->VpiName().empty()) {
        if (auto dsyn = pn.sym->getSyntax()) {
            auto dr = dsyn->sourceRange();
            if (dr.start() != SourceLocation::NoLocation) {
                ts->VpiEndLineNo(sm->getLineNumber(dr.end()));
                ts->VpiEndColumnNo(sm->getColumnNumber(dr.end()));
            }
        }
    }
    pn.rt->Actual_typespec(ts);
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

        // The write phase recompiles the port typespec with UNFOLDED range
        // bounds and swaps attachments with the DEF port: the def port's ref
        // gets the fresh unfolded object, while the top port inherits the
        // folded object the def port was created with.
        UHDM::typespec* defActual = nullptr;
        UHDM::ref_typespec* defRt = nullptr;
        {
            auto dit = defMap.find(&tp.inst->getDefinition());
            if (dit != defMap.end() && dit->second.mod && dit->second.mod->Ports()) {
                for (auto dp : *dit->second.mod->Ports()) {
                    if (dp->VpiName() == ps.name && dp->Typespec()) {
                        defRt = dp->Typespec();
                        defActual = defRt->Actual_typespec();
                        break;
                    }
                }
            }
        }
        tfContext = true;
        auto* pts = makeTypespec(*internal, nullptr, &ps);
        tfContext = false;
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(tp.prefix + "." + std::string(ps.name));
        rt->VpiParent(p);
        rt->Actual_typespec(defActual ? defActual : pts);
        if (defRt)
            defRt->Actual_typespec(pts);
        p->Typespec(rt);
        ports->push_back(p);
    }
    if (!ports->empty())
        tp.m->Ports(ports);

    // Write-phase drains: def-view local-net typespecs (unfolded
    // module-compile ranges), then function return locals, then instance
    // param typespecs, then bare io-decl typespecs.
    tfContext = true;
    // Def-local typespecs drain in name-sorted def order (the writer walks
    // allModules sorted), stable within a def.
    std::stable_sort(pendingNetTs.begin() + tp.netTsLo, pendingNetTs.begin() + tp.netTsHi,
                     [](const PendingNetTs& a, const PendingNetTs& b) {
                         return a.di->mod->VpiDefName() < b.di->mod->VpiDefName();
                     });
    {
        auto* ownDi = &defMap[&tp.inst->getDefinition()];
        for (auto& pn : pendingNetTs) {
            if (pn.di == ownDi && !pn.rt->Actual_typespec())
                materializeDefNetTs(pn);
        }
    }
    tfContext = false;

    // Function return-value locals: one var + typespec pair per body ref
    // (Surelog creates them at each bind in the write phase).
    for (auto& pf : pendingFuncRet) {
        auto& sub = *pf.sub;
        if (pf.refs.empty() || !sub.returnValVar || sub.getReturnType().isVoid())
            continue;
        std::string localFull = pf.fullName + "." + std::string(sub.name);
        for (auto* r : pf.refs) {
            auto* lv = makeReturnVar(s, sub.getReturnType());
            lv->VpiName(sub.name);
            lv->VpiFullName(localFull);
            lv->VpiParent(r);
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(localFull);
            rt->VpiParent(lv);
            tfContext = true;
            syntaxRefPrefix = localFull;
            auto* ts = makeTypespec(*sub.returnValVar, returnTypeSyntax(sub));
            syntaxRefPrefix.clear();
            tfContext = false;
            ts->VpiParent(rt);
            rt->Actual_typespec(ts);
            lv->Typespec(rt);
            lv->VpiLineNo(ts->VpiLineNo());
            lv->VpiColumnNo(ts->VpiColumnNo());
            lv->VpiEndLineNo(ts->VpiEndLineNo());
            lv->VpiEndColumnNo(ts->VpiEndColumnNo());
            r->Actual_group(lv);
        }
    }
    pendingFuncRet.clear();

    patchParamTypespecs(tp.paramLo, tp.paramHi);

    {
        std::map<const void*, UHDM::typespec*> bareCache;
        for (auto& [rt, key] : pendingIoTs) {
            // Key == the ref itself marks a genvar param (int, never shared).
            if (key == rt) {
                rt->Actual_typespec(s.MakeInt_typespec());
                continue;
            }
            auto& slot = bareCache[key];
            if (!slot)
                slot = s.MakeLogic_typespec();
            rt->Actual_typespec(slot);
        }
        pendingIoTs.clear();
    }

    // Deferred re-emitted cast typespecs (very end of the write phase).
    for (auto& pc : pendingCastTs) {
        auto* its = s.MakeInteger_typespec();
        its->VpiLineNo(pc.line);
        its->VpiColumnNo(pc.col);
        its->VpiEndLineNo(pc.endLine);
        its->VpiEndColumnNo(pc.endCol);
        if (pc.sizeExpr) {
            NetMap none;
            bool savedCS = inCastSize;
            inCastSize = true;
            if (auto* e = emitExpr(*pc.sizeExpr, its, pc.prefix, none))
                its->Expr((UHDM::expr*)e);
            inCastSize = savedCS;
        }
        else {
            its->VpiValue(pc.value);
        }
        its->VpiParent(pc.rt);
        pc.rt->Actual_typespec(its);
    }
    pendingCastTs.clear();

    // Orphan pattern first-compiles (share the def operands).
    for (auto& po : pendingPatternOrphans) {
        auto* op = s.MakeOperation();
        op->VpiOpType(vpiAssignmentPatternOp);
        op->VpiParent(po.defCa);
        op->VpiLineNo(po.line);
        op->VpiColumnNo(po.col);
        op->VpiEndLineNo(po.endLine);
        op->VpiEndColumnNo(po.endCol);
        if (po.ts) {
            auto* rt = s.MakeRef_typespec();
            rt->Actual_typespec(po.ts);
            op->Typespec(rt);
        }
        if (po.defOp->Operands()) {
            auto* ops = s.MakeAnyVec();
            for (auto* o : *po.defOp->Operands()) {
                // Structured patterns unwrap to the tagged values.
                UHDM::any* val = o;
                if (o->UhdmType() == UHDM::uhdmtagged_pattern) {
                    if (auto* pat = ((UHDM::tagged_pattern*)o)->Pattern())
                        val = (UHDM::any*)pat;
                }
                ops->push_back(val);
                // The recompile re-parents the shared def operands at the
                // orphan (this is also what pulls it into the dump).
                val->VpiParent(op);
            }
            op->Operands(ops);
        }
    }
    pendingPatternOrphans.clear();
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
        // Def view: work@mod.<n>.<n> (port-scoped) with a name; ports whose
        // net is re-declared in the body use work@mod.<n> and no name.
        bool merged = internal && hasBodyDecl(*internal);
        if (topView || merged) {
            if (topView)
                lc->VpiName(ps.name);
            lc->VpiFullName(prefix + "." + std::string(ps.name));
        }
        else {
            lc->VpiName(ps.name);
            lc->VpiFullName(prefix + "." + std::string(ps.name) + "." + std::string(ps.name));
        }
        lc->VpiParent(p);
        setLocNamed(lc, ps);
        if (auto it = netMap.find(internal); it != netMap.end())
            lc->Actual_group(it->second);
        p->Low_conn(lc);

        UHDM::typespec* ts = sharedTs ? sharedTypespec(*internal, *sharedTs, &ps)
                                      : makeTypespec(*internal, nullptr, &ps);
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
        // Only whole-net LHS assigns get netlist-elaborated (and so lose
        // their net-typespec parent); select-LHS assigns don't.
        if (lhsSyms) {
            auto& lhsCore = stripImplicitConv(ae.left());
            if (lhsCore.kind == ExpressionKind::NamedValue)
                lhsSyms->insert(&lhsCore.as<NamedValueExpression>().symbol);
        }
        bool literalRhs = isLiteralExpr(ae.right());
        // Evaluable $bits RHS behaves like a literal in the def view
        // (parented fold).
        bool bitsRhs = false;
        {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::Call && rc.as<CallExpression>().isSystemCall()) {
                auto sn = rc.as<CallExpression>().getSubroutineName();
                if (sn == "bits" || sn == "$bits")
                    bitsRhs = true;
            }
        }
        // RHS refs to enum constants also get re-emitted (folded to the
        // constant's value, loc-less).
        const Symbol* enumRhs = nullptr;
        {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::NamedValue &&
                rc.as<NamedValueExpression>().symbol.kind == SymbolKind::EnumValue)
                enumRhs = &rc.as<NamedValueExpression>().symbol;
        }
        // Top modules share the def's cont_assign object unless netlist
        // elaboration re-compiles it: that happens only for whole-net LHS
        // (RHS resized against the net width) when the RHS contains
        // operations or is a literal. Select-LHS assigns always stay shared.
        bool plainLhs = stripImplicitConv(ae.left()).kind == ExpressionKind::NamedValue;
        if (shareWithDef && defInfo && myIdx < defInfo->contAssigns.size() &&
            (!plainLhs || (!containsOperation(ae.right()) && !literalRhs && !enumRhs))) {
            cas->push_back(defInfo->contAssigns[myIdx]);
            continue;
        }
        auto* ca = s.MakeCont_assign();
        ca->VpiParent(m);
        setLoc(ca, assign.sourceRange);
        UHDM::any* rhs = nullptr;
        if (topView && enumRhs) {
            if (auto eit = enumConstMap.find(enumRhs); eit != enumConstMap.end()) {
                auto* src = (UHDM::enum_const*)eit->second;
                auto* c = s.MakeConstant();
                c->VpiParent(ca);
                c->VpiDecompile(src->VpiDecompile());
                c->VpiSize(src->VpiSize());
                std::string_view v = src->VpiValue();
                c->VpiValue(std::string(v));
                if (v.rfind("BIN:", 0) == 0)
                    c->VpiConstType(vpiBinaryConst);
                else if (v.rfind("HEX:", 0) == 0)
                    c->VpiConstType(vpiHexConst);
                else if (v.rfind("OCT:", 0) == 0)
                    c->VpiConstType(vpiOctConst);
                else if (v.rfind("DEC:", 0) == 0)
                    c->VpiConstType(vpiDecConst);
                else
                    c->VpiConstType(vpiUIntConst);
                rhs = c;
            }
        }
        // Unbased-unsized literal RHS folds to a LOCATED, parented constant
        // at the type width.
        if (!rhs && topView) {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                ASTContext ctx(comp.getRoot(), LookupLocation::max);
                ConstantValue cv = ctx.tryEval(ae.right());
                if (cv && cv.isInteger() && !cv.integer().hasUnknown()) {
                    auto* c = s.MakeConstant();
                    std::string digits = cv.integer().toString(LiteralBase::Decimal, false);
                    c->VpiDecompile(digits);
                    c->VpiSize((int32_t)ae.right().type->getBitWidth());
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    c->VpiParent(ca);
                    setLoc(c, rc.sourceRange);
                    rhs = c;
                }
            }
        }
        if (!rhs && !bitsRhs)
            rhs = topView ? tryFoldConst(ae.right()) : nullptr;
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
            if (literalRhs || bitsRhs)
                forceConstParent = true;
            rhs = emitExpr(ae.right(), ca, prefix, rhsMap);
            forceConstParent = forceSaved;
            refCollector = nullptr;
            reemitting = false;
            // Re-emitted BARE literals and $bits folds size at the LHS
            // type width.
            if (topView && rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                (bitsRhs ||
                 (literalRhs &&
                  rawText(stripImplicitConv(ae.right()).sourceRange).find('\'') ==
                      std::string::npos)))
                ((UHDM::constant*)rhs)->VpiSize((int32_t)ae.left().type->getBitWidth());
        }
        if (rhs)
            ca->Rhs((UHDM::expr*)rhs);
        // Re-emitted pattern RHS leaves an orphan first-compile op behind
        // (materialized at the very end of the write phase).
        if (topView && defInfo && myIdx < defInfo->contAssigns.size()) {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::SimpleAssignmentPattern ||
                rc.kind == ExpressionKind::StructuredAssignmentPattern) {
                auto* defCa = defInfo->contAssigns[myIdx];
                if (defCa->Rhs() && defCa->Rhs()->UhdmType() == UHDM::uhdmoperation) {
                    UHDM::typespec* pts = nullptr;
                    if (auto it2 = typedefTs.find(rc.type); it2 != typedefTs.end())
                        pts = it2->second;
                    auto sr = rc.sourceRange;
                    pendingPatternOrphans.push_back(
                        {defCa, (UHDM::operation*)defCa->Rhs(),
                         sm->getLineNumber(sr.start()), sm->getColumnNumber(sr.start()),
                         sm->getLineNumber(sr.end()), sm->getColumnNumber(sr.end()), pts});
                }
            }
        }
        inLhs = true;
        // Literal-RHS re-emits bind BOTH sides to def-view objects.
        NetMap& lhsMap = (topView && shareWithDef && (literalRhs || bitsRhs) && defInfo)
                             ? defInfo->nets
                             : netMap;
        if (auto* l = emitExpr(ae.left(), ca, prefix, lhsMap))
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
