//------------------------------------------------------------------------------
//! @file ModuleEmit.cpp
//! @brief Module definitions, instances, ports, continuous assigns
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include <functional>

#include "EmitHelpers.h"

namespace slang_uhdm {

// True when a declared type is a PACKAGE-scoped typedef'd struct.
static bool isPkgStructType(const Symbol& sym) {
    auto* dt = sym.getDeclaredType();
    if (!dt || !dt->getType().getCanonicalType().isStruct())
        return false;
    const Type* t = &dt->getType();
    if (t->kind != SymbolKind::TypeAlias)
        return false;
    for (auto sc = t->getParentScope(); sc; sc = sc->asSymbol().getParentScope())
        if (sc->asSymbol().kind == SymbolKind::Package)
            return true;
    return false;
}

// A struct with a nested-struct field: Surelog leaves its net UNTYPED
// (no vpiNetType), unlike flat vector/scalar-member structs.
static bool hasStructFieldMember(const Symbol& sym) {
    auto* dt = sym.getDeclaredType();
    if (!dt)
        return false;
    auto& ct = dt->getType().getCanonicalType();
    if (!ct.isStruct())
        return false;
    for (auto& f : ct.as<Scope>().members())
        if (f.kind == SymbolKind::Field &&
            f.as<FieldSymbol>().getType().getCanonicalType().isStruct())
            return true;
    return false;
}

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
    if (auto syntax = body.getSyntax()) {
        setLoc(m, syntax->sourceRange());
        if (syntax->kind == syntax::SyntaxKind::ModuleDeclaration)
            if (auto* bn = syntax->as<syntax::ModuleDeclarationSyntax>().blockName)
                m->VpiEndLabel(bn->name.valueText());
    }

    // (Def-view parameters were emitted in the exportDesign pre-pass.)

    // Typedefs first: their base typespecs precede everything else in the
    // def's arena region.
    emitTypedefs(body, m, prefix, info);

    // Module-LOCAL class definitions attach under the def module's
    // vpiClassDefn (bare name, work@mod::name fullname).
    {
        auto* mclasses = s.MakeClass_defnVec();
        for (auto& mem : body.members()) {
            if (mem.kind != SymbolKind::ClassType)
                continue;
            auto& cls = mem.as<ClassType>();
            mclasses->push_back(emitClassDefn(cls, std::string(cls.name),
                                              prefix + "::" + std::string(cls.name),
                                              m));
        }
        if (!mclasses->empty())
            m->Class_defns(mclasses);
    }

    // Nets in Surelog's collection order: explicit declarations by source
    // location, then port-declaration-only nets in port-list order.
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port &&
            portBase->kind != SymbolKind::InterfacePort)
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
        // A PACKAGE-typedef struct net (port, or a flat-member local) is a
        // wire; nested-struct-member locals stay untyped.
        else if (isPkgStructType(*it.sym) &&
                 (it.port || !hasStructFieldMember(*it.sym)))
            n->VpiNetType(vpiWire);
        // Implicit nets print no typespec.
        bool implicitNet = it.sym->kind == SymbolKind::Net &&
                           it.sym->as<NetSymbol>().isImplicit;
        // A class-handle def net carries a typespec ONLY when the handle is
        // never procedurally assigned (bar = new() strips it — OneThis vs
        // OneClass).
        bool classHandle =
            it.sym->getDeclaredType() &&
            it.sym->getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::ClassType;
        if (classHandle) {
            bool written = false;
            for (auto& mb : body.members()) {
                if (mb.kind != SymbolKind::ProceduralBlock)
                    continue;
                mb.as<ProceduralBlockSymbol>().getBody().visit(
                    makeVisitor([&](auto& vis, const AssignmentExpression& ax) {
                        auto& lc = stripImplicitConv(ax.left());
                        if (lc.kind == ExpressionKind::NamedValue &&
                            &lc.as<NamedValueExpression>().symbol == it.sym)
                            written = true;
                        vis.visitDefault(ax);
                    }));
            }
            if (!written)
                classHandle = false;
        }
        if (!it.port && !implicitNet && !classHandle) {
            // Local nets carry a typespec whose actual is created only in
            // the write phase (Surelog arena order); the ref is patched then.
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(prefix + "." + name);
            rt->VpiParent(n);
            n->Typespec(rt);
            pendingNetTs.push_back({it.sym, rt, &info});
        }
        if (auto attrs = comp.getAttributes(*it.sym); !attrs.empty()) {
            // Surelog keeps only the LAST (* *) group; within that group every
            // attribute is emitted (with its value, for direct literals only).
            // The objects are shared with the instance view.
            const syntax::SyntaxNode* lastGroup = nullptr;
            for (auto* a : attrs)
                if (auto asyn = a->getSyntax())
                    lastGroup = asyn->parent;
            auto* av = s.MakeAttributeVec();
            std::vector<UHDM::attribute*> stored;
            for (auto* a : attrs) {
                auto asyn = a->getSyntax();
                if (asyn && asyn->parent != lastGroup)
                    continue;
                auto* ua = s.MakeAttribute();
                ua->VpiName(a->name);
                if (asyn)
                    setLoc(ua, asyn->sourceRange());
                ua->VpiParent(n);
                // Only a DIRECT literal value clause carries a value; a bare
                // (* attr *) or a computed value (-1, cast) emits none.
                const syntax::ExpressionSyntax* valExpr = nullptr;
                if (asyn && asyn->kind == syntax::SyntaxKind::AttributeSpec)
                    if (auto* vc = asyn->as<syntax::AttributeSpecSyntax>().value)
                        valExpr = vc->expr;
                if (valExpr) {
                    const ConstantValue& cv = a->getValue();
                    if (valExpr->kind == syntax::SyntaxKind::StringLiteralExpression) {
                        // slang packs the string into an SVInt; take the raw
                        // source text between the quotes.
                        std::string raw = rawText(valExpr->sourceRange());
                        if (raw.size() >= 2 && raw.front() == '"' && raw.back() == '"')
                            raw = raw.substr(1, raw.size() - 2);
                        ua->VpiValue("STRING:" + raw);
                    }
                    else if (valExpr->kind == syntax::SyntaxKind::RealLiteralExpression &&
                             cv.isReal()) {
                        char buf[64];
                        snprintf(buf, sizeof(buf), "%f", cv.real().v);
                        ua->VpiValue("REAL:" + std::string(buf));
                    }
                    else if (cv.isInteger()) {
                        std::string raw = rawText(valExpr->sourceRange());
                        auto tick = raw.find('\'');
                        if (tick != std::string::npos) {
                            // Based literal (1'b0, 8'hFF): encode by base.
                            size_t basePos = tick + 1;
                            if (basePos < raw.size() &&
                                (raw[basePos] == 's' || raw[basePos] == 'S'))
                                basePos++;
                            char base =
                                basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
                            std::string digits = raw.substr(basePos + 1);
                            const char* pfx = base == 'b'   ? "BIN:"
                                              : base == 'h' ? "HEX:"
                                              : base == 'o' ? "OCT:"
                                                            : "DEC:";
                            ua->VpiValue(pfx + digits);
                        }
                        else if (valExpr->kind ==
                                 syntax::SyntaxKind::IntegerLiteralExpression) {
                            // Bare decimal literal.
                            auto& iv = cv.integer();
                            std::string digits = iv.toString(LiteralBase::Decimal, false);
                            bool neg = iv.isSigned() && iv.isNegative();
                            ua->VpiValue((neg ? "INT:" : "UINT:") + digits);
                        }
                    }
                }
                av->push_back(ua);
                stored.push_back(ua);
            }
            n->Attributes(av);
            attrMap[it.sym] = stored;
        }
        info.nets[it.sym] = n;
        nets->push_back(n);
    }
    // Each interface port produces a bare logic_net (no typespec) at the port
    // name, so hierarchical references through it resolve.
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::InterfacePort)
            continue;
        auto& ip = portBase->as<InterfacePortSymbol>();
        auto* n = s.MakeLogic_net();
        n->VpiName(ip.name);
        n->VpiFullName(prefix + "." + std::string(ip.name));
        n->VpiParent(m);
        setLocNamed(n, ip);
        nets->push_back(n);
    }
    // Connection-site logic_net for each scalar interface passed to a child
    // module (bound by the child ref_module's interface port).
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Instance)
            continue;
        auto& child = member.as<InstanceSymbol>();
        for (auto pb : child.body.getPortList()) {
            if (pb->kind != SymbolKind::InterfacePort)
                continue;
            auto conn = pb->as<InterfacePortSymbol>().getConnection();
            if (!conn.first || conn.first->kind != SymbolKind::Instance)
                continue;
            const PortConnection* pc = nullptr;
            for (auto cc : child.getPortConnections())
                if (&cc->port == pb) {
                    pc = cc;
                    break;
                }
            // Only a BARE whole-interface connection (.bus(bus)) gets a
            // connection-site net; modport-qualified ones (.mon(s.mon)) don't.
            if (!pc || !connectionExpr(*pc) ||
                rawText(connectionExpr(*pc)->sourceRange).find('.') != std::string::npos)
                continue;
            auto* n = s.MakeLogic_net();
            n->VpiName(conn.first->name);
            n->VpiFullName(prefix + "." + std::string(conn.first->name));
            n->VpiParent(m);
            n->VpiNetType(vpiWire);
            setLoc(n, connectionExpr(*pc)->sourceRange);
            ifaceConnNet[conn.first] = n;
            info.nets[conn.first] = n;
            nets->push_back(n);
        }
    }
    if (!nets->empty())
        m->Nets(nets);

    // Tasks/functions are module items; their typespecs (return, io_decls)
    // precede cont_assign and port typespecs.
    emitTaskFuncs(body, m, prefix, &info);

    // Def-view cont_assigns come before ports (their typespecs precede the
    // port typespecs in Surelog's arena).
    emitContAssigns(body, m, prefix, info.nets, /*topView=*/false, &info, false, nullptr,
                    nullptr);

    // Named property declarations (property p(n); ... endproperty): a
    // property_decl with bare-ts formals and a formal-referenced body
    // (default instance); formal refs mint implicit module wires.
    {
        auto* pdecls = s.MakeProperty_declVec();
        for (auto& member : body.members()) {
            if (member.kind != SymbolKind::Property)
                continue;
            auto& prop = member.as<PropertySymbol>();
            auto* pd = s.MakeProperty_decl();
            pd->VpiName(prop.name);
            pd->VpiFullName(prefix + "." + std::string(prop.name));
            pd->VpiParent(m);
            setLoc(pd, SourceRange(prop.location, prop.location + prop.name.size()));
            auto* fdecls = s.MakeProp_formal_declVec();
            for (auto& fp : prop.membersOfType<AssertionPortSymbol>()) {
                auto* fd = s.MakeProp_formal_decl();
                fd->VpiName(fp.name);
                auto* frt = s.MakeRef_typespec();
                fd->Typespec(frt);
                fdecls->push_back(fd);
            }
            if (!fdecls->empty())
                pd->Prop_formal_decls(fdecls);
            auto& defInst = AssertionInstanceExpression::makeDefault(prop);
            if (defInst.kind == ExpressionKind::AssertionInstance) {
                auto& aie = defInst.as<AssertionInstanceExpression>();
                auto* psSpec = s.MakeProperty_spec();
                psSpec->VpiParent(pd);
                if (aie.body.syntax)
                    setLoc(psSpec, aie.body.syntax->sourceRange());
                auto* savedINM = implicitNetModule;
                auto savedINP = implicitNetPrefix;
                implicitNetModule = m;
                implicitNetPrefix = prefix;
                propDeclScope = &prop;
                if (auto* bodyE =
                        emitAssertionExpr(aie.body, psSpec,
                                          prefix + "." + std::string(prop.name),
                                          info.nets))
                    psSpec->VpiPropertyExpr(bodyE);
                propDeclScope = nullptr;
                implicitNetModule = savedINM;
                implicitNetPrefix = savedINP;
                pd->Property_spec(psSpec);
            }
            propertyDeclMap[&prop] = pd;
            pdecls->push_back(pd);
        }
        if (!pdecls->empty())
            m->Property_decls(pdecls);
    }

    // Processes are compiled as module items, so any typespecs they create
    // (for-loop vars, cast typespecs) also precede the port typespecs.
    auto* procs = s.MakeProcess_stmtVec();
    auto* asserts = s.MakeAnyVec();
    refCollector = &info.processRefs;
    inProcessEmit = true;
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::ProceduralBlock)
            continue;
        auto& pb = member.as<ProceduralBlockSymbol>();
        if (auto* as = emitAssertion(pb, m, prefix, info.nets)) {
            asserts->push_back(as);
            info.assertions.push_back(as);
            continue;
        }
        auto* p = emitProcess(pb, m, prefix, info.nets);
        if (p) {
            procs->push_back(p);
            info.processes.push_back(p);
        }
    }
    inProcessEmit = false;
    refCollector = nullptr;
    if (!procs->empty())
        m->Process(procs);
    if (!asserts->empty())
        m->Assertions(asserts);

    // Default clocking block (default clocking @(posedge clk); endclocking).
    if (auto* cb = emitDefaultClocking(body, m, prefix, info.nets))
        info.defaultClocking = cb;

    // Def view: for-generates keep a gen_region placeholder (unlocated begin
    // naming the module scope); if-generates become gen_if_else with BOTH
    // branches re-emitted from SYNTAX (unbound refs, name-only calls).
    {
        auto* regions = s.MakeGen_stmtVec();
        std::set<const syntax::SyntaxNode*> doneIfs;
        // A generate branch body: named begin for labeled blocks, anonymous
        // begin (module fullname) otherwise; cont_assigns from syntax.
        auto emitBranch = [&](const syntax::SyntaxNode& memSyn,
                              UHDM::BaseClass* parent) -> UHDM::any* {
            UHDM::scope* b = nullptr;
            std::string branchPrefix = prefix;
            std::vector<const syntax::SyntaxNode*> items;
            if (memSyn.kind == syntax::SyntaxKind::GenerateBlock) {
                auto& gb = memSyn.as<syntax::GenerateBlockSyntax>();
                std::string label;
                if (gb.beginName)
                    label = std::string(gb.beginName->name.valueText());
                if (!label.empty()) {
                    auto* nb = s.MakeNamed_begin();
                    nb->VpiName(label);
                    branchPrefix = prefix + "." + label;
                    nb->VpiFullName(branchPrefix);
                    b = nb;
                }
                else {
                    auto* ub = s.MakeBegin();
                    ub->VpiFullName(prefix);
                    b = ub;
                }
                for (auto mem2 : gb.members)
                    items.push_back(mem2);
            }
            else {
                auto* ub = s.MakeBegin();
                ub->VpiFullName(prefix);
                b = ub;
                items.push_back(&memSyn);
            }
            b->VpiParent(parent);
            auto* stmts = s.MakeAnyVec();
            for (auto* item : items) {
                if (item->kind != syntax::SyntaxKind::ContinuousAssign)
                    continue;
                auto& cas2 = item->as<syntax::ContinuousAssignSyntax>();
                for (auto asyn : cas2.assignments) {
                    auto* ca = s.MakeCont_assign();
                    ca->VpiParent(b);
                    setLoc(ca, asyn->sourceRange());
                    syntaxRefPrefix = branchPrefix;
                    if (asyn->kind == syntax::SyntaxKind::AssignmentExpression) {
                        auto& be = asyn->as<syntax::BinaryExpressionSyntax>();
                        if (auto* l = emitSyntaxExpr(*be.left, ca))
                            ca->Lhs((UHDM::expr*)l);
                        if (auto* r = emitSyntaxExpr(*be.right, ca))
                            ca->Rhs((UHDM::expr*)r);
                    }
                    syntaxRefPrefix.clear();
                    stmts->push_back(ca);
                }
            }
            if (b->UhdmType() == UHDM::uhdmnamed_begin)
                ((UHDM::named_begin*)b)->Stmts(stmts);
            else
                ((UHDM::begin*)b)->Stmts(stmts);
            return b;
        };
        for (auto& member : body.members()) {
            if (member.kind != SymbolKind::GenerateBlockArray &&
                member.kind != SymbolKind::GenerateBlock)
                continue;
            const syntax::IfGenerateSyntax* ifSyn = nullptr;
            if (member.kind == SymbolKind::GenerateBlock) {
                for (auto q = member.getSyntax(); q; q = q->parent) {
                    if (q->kind == syntax::SyntaxKind::IfGenerate) {
                        ifSyn = &q->as<syntax::IfGenerateSyntax>();
                        break;
                    }
                }
            }
            if (ifSyn) {
                if (!doneIfs.insert(ifSyn).second)
                    continue;
                // With an else clause: loc-less gen_if_else. Without: a
                // gen_if located at the `if` keyword.
                UHDM::gen_if_else* gie = nullptr;
                UHDM::gen_if* gi = nullptr;
                UHDM::gen_stmt* g0;
                if (ifSyn->elseClause) {
                    gie = s.MakeGen_if_else();
                    g0 = gie;
                }
                else {
                    gi = s.MakeGen_if();
                    setLoc(gi, ifSyn->keyword.range());
                    g0 = gi;
                }
                g0->VpiParent(m);
                syntaxRefPrefix = prefix;
                if (auto* c = emitSyntaxExpr(*ifSyn->condition, g0)) {
                    if (gie)
                        gie->VpiCondition((UHDM::expr*)c);
                    else
                        gi->VpiCondition((UHDM::expr*)c);
                }
                syntaxRefPrefix.clear();
                if (auto* t = emitBranch(*ifSyn->block, g0)) {
                    if (gie)
                        gie->VpiStmt(t);
                    else
                        gi->VpiStmt(t);
                }
                if (ifSyn->elseClause)
                    if (auto* e = emitBranch(*ifSyn->elseClause->clause, gie))
                        gie->VpiElseStmt((UHDM::any*)e);
                regions->push_back(g0);
                continue;
            }
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

    (void)netTsAtEntry;
    (void)topDef;

    return m;
}

// Encounter-phase def artifacts: ports, child stubs, imports. (Content is
// compiled for every def before any instance; see exportDesign.)
UHDM::module_inst* UhdmExporter::emitModuleDefPorts(const InstanceSymbol& inst) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    std::string prefix = "work@" + std::string(def.name);
    DefInfo& info = defMap[&def];
    currentScope = &body;
    auto* m = info.mod;
    TsCache& defTs = info.defTs;

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
        if (auto iit = ifaceDefMap.find(&child.getDefinition()); iit != ifaceDefMap.end())
            rm->Actual_group(iit->second);
        else if (auto it = defMap.find(&child.getDefinition()); it != defMap.end())
            rm->Actual_group(it->second.mod);

        auto* rports = s.MakePortVec();
        bool ordered = hasOrderedConns(child);
        for (auto conn : child.getPortConnections()) {
            auto* p = s.MakePort();
            // Positional connections: nameless port anchored at the actual.
            if (!ordered)
                p->VpiName(conn->port.name);
            p->VpiParent(rm);
            if (auto npc = findConnSyntax(child, conn->port.name))
                setLoc(p, npc->sourceRange());
            else if (ordered) {
                if (auto expr0 = connectionExpr(*conn))
                    setLoc(p, expr0->sourceRange);
            }
            if (auto expr = connectionExpr(*conn)) {
                if (expr->kind == ExpressionKind::NamedValue) {
                    auto& nv = expr->as<NamedValueExpression>();
                    auto* r = s.MakeRef_obj();
                    r->VpiName(nv.symbol.name);
                    r->VpiFullName(prefix + "." + std::string(child.name) +
                                   (ordered ? "" : "." + std::string(conn->port.name)) + "." +
                                   std::string(nv.symbol.name));
                    r->VpiParent(p);
                    setLoc(r, expr->sourceRange);
                    if (auto nit = info.nets.find(&nv.symbol); nit != info.nets.end())
                        r->Actual_group(nit->second);
                    p->High_conn(r);
                }
                else if (auto* h = emitExpr(*expr,  p,
                                            stripImplicitConv(*expr).kind ==
                                                        ExpressionKind::
                                                            StructuredAssignmentPattern ||
                                                    stripImplicitConv(*expr).kind ==
                                                        ExpressionKind::
                                                            SimpleAssignmentPattern
                                                ? prefix + "." + std::string(child.name) +
                                                      "." + std::string(conn->port.name)
                                                : prefix,
                                            info.nets)) {
                    if (conn->port.kind == SymbolKind::InterfacePort &&
                        h->UhdmType() == UHDM::uhdmref_obj) {
                        if (auto cc =
                                conn->port.as<InterfacePortSymbol>().getConnection().first;
                            cc && cc->kind == SymbolKind::Instance) {
                            auto* r = (UHDM::ref_obj*)h;
                            r->VpiFullName(prefix + "." + std::string(child.name) + "." +
                                           std::string(conn->port.name) + "." +
                                           std::string(r->VpiName()));
                            if (auto nit = ifaceConnNet.find(cc); nit != ifaceConnNet.end())
                                r->Actual_group(nit->second);
                        }
                    }
                    // A modport-qualified connection (s.mon) is a hier_path:
                    // non-last elements name-only; the LAST element scopes by
                    // the CHILD PORT path (work@m.u.mon.mon).
                    if (conn->port.kind == SymbolKind::InterfacePort &&
                        h->UhdmType() == UHDM::uhdmhier_path) {
                        auto* hp2 = (UHDM::hier_path*)h;
                        if (hp2->Path_elems() && !hp2->Path_elems()->empty()) {
                            for (auto* pe : *hp2->Path_elems())
                                if (pe->UhdmType() == UHDM::uhdmref_obj)
                                    ((UHDM::ref_obj*)pe)
                                        ->VpiFullName(std::string(pe->VpiName()));
                            auto* last = hp2->Path_elems()->back();
                            if (last->UhdmType() == UHDM::uhdmref_obj)
                                ((UHDM::ref_obj*)last)
                                    ->VpiFullName(prefix + "." + std::string(child.name) +
                                                  "." + std::string(conn->port.name) + "." +
                                                  std::string(last->VpiName()));
                        }
                    }
                    // A struct-member (dotted) conn on a REGULAR port scopes
                    // its LAST element through the child port path too
                    // (work@top.d.o.ping_p).
                    if (conn->port.kind == SymbolKind::Port &&
                        h->UhdmType() == UHDM::uhdmhier_path) {
                        auto* hp2 = (UHDM::hier_path*)h;
                        if (hp2->Path_elems() && !hp2->Path_elems()->empty()) {
                            auto* last = hp2->Path_elems()->back();
                            if (last->UhdmType() == UHDM::uhdmref_obj)
                                ((UHDM::ref_obj*)last)
                                    ->VpiFullName(prefix + "." + std::string(child.name) +
                                                  "." + std::string(conn->port.name) + "." +
                                                  std::string(last->VpiName()));
                        }
                    }
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

    emitImportArtifacts(body, m);

    return m;
}

// Modules with package imports carry an import_typespec per import item and
// list import-called package functions (shared def objects) in Task_funcs.
void UhdmExporter::emitImportArtifacts(const InstanceBodySymbol& body, UHDM::instance* m) {
    auto* tds = m->Typespecs();
    // An interface (def view) lists each imported package typedef in its own
    // Typespecs before the import_typespec, SHARING the top-view package
    // object: it re-parents it to the interface and re-scopes its base ref
    // fullname to work@<iface>.<pkg>::<name> (Surelog last-writer semantics).
    if (m->UhdmType() == UHDM::uhdminterface_inst) {
        for (auto& mem : body.members()) {
            if (mem.kind != SymbolKind::WildcardImport &&
                mem.kind != SymbolKind::ExplicitImport)
                continue;
            std::string_view pn = mem.kind == SymbolKind::WildcardImport
                                      ? mem.as<WildcardImportSymbol>().packageName
                                      : mem.as<ExplicitImportSymbol>().packageName;
            auto* pkg = comp.getPackage(pn);
            if (!pkg)
                continue;
            for (auto& pm : pkg->members()) {
                if (pm.kind != SymbolKind::TypeAlias)
                    continue;
                auto tit = pkgTopTypedefTs.find(&pm);
                if (tit == pkgTopTypedefTs.end())
                    continue;
                auto* ts = tit->second;
                ts->VpiParent(m);
                std::string scopedName = std::string(m->VpiDefName()) + "." +
                                         std::string(pn) + "::" +
                                         std::string(pm.as<TypeAliasType>().name);
                if (ts->UhdmType() == UHDM::uhdmenum_typespec) {
                    auto* ets = (UHDM::enum_typespec*)ts;
                    if (ets->Base_typespec())
                        ets->Base_typespec()->VpiFullName(scopedName);
                }
                // Struct typedefs: member typespec refs re-scope through the
                // interface too (work@<iface>.<pkg>::<ts>.<member>).
                if (ts->UhdmType() == UHDM::uhdmstruct_typespec) {
                    auto* sts = (UHDM::struct_typespec*)ts;
                    if (sts->Members())
                        for (auto* tm : *sts->Members())
                            if (tm->Typespec())
                                tm->Typespec()->VpiFullName(
                                    scopedName + "." + std::string(tm->VpiName()));
                }
                if (!tds) {
                    tds = s.MakeTypespecVec();
                    m->Typespecs(tds);
                }
                tds->push_back(ts);
            }
        }
    }
    // A module explicitly importing a package typedef (import pkg::T) lists
    // the SHARED top-view package typespec in its Typespecs (before the
    // import_typespec) and re-parents it to the module; fullnames keep their
    // pkg:: scoping (unlike the interface re-scope above).
    if (m->UhdmType() == UHDM::uhdmmodule_inst) {
        for (auto& mem : body.members()) {
            if (mem.kind != SymbolKind::ExplicitImport)
                continue;
            auto* imported = mem.as<ExplicitImportSymbol>().importedSymbol();
            if (!imported || imported->kind != SymbolKind::TypeAlias)
                continue;
            auto tit = pkgTopTypedefTs.find(imported);
            if (tit == pkgTopTypedefTs.end())
                continue;
            auto* ts = tit->second;
            ts->VpiParent(m);
            if (!tds) {
                tds = s.MakeTypespecVec();
                m->Typespecs(tds);
            }
            if (std::find(tds->begin(), tds->end(), (UHDM::typespec*)ts) == tds->end())
                tds->push_back(ts);
        }
    }
    for (auto& mem : body.members()) {
        std::string pkgName;
        if (mem.kind == SymbolKind::WildcardImport)
            pkgName = std::string(mem.as<WildcardImportSymbol>().packageName);
        else if (mem.kind == SymbolKind::ExplicitImport)
            pkgName = std::string(mem.as<ExplicitImportSymbol>().packageName);
        else
            continue;
        auto* its = s.MakeImport_typespec();
        its->VpiName(pkgName);
        its->VpiParent(m);
        if (auto syn = mem.getSyntax())
            setLoc(its, syn->sourceRange());
        // Hidden item constant: "*" (loc-less) or the imported name (at its
        // token). Dump-invisible but uhdm-cmp checked.
        {
            std::string itemName = "*";
            auto* c = s.MakeConstant();
            if (mem.kind == SymbolKind::ExplicitImport) {
                itemName = std::string(mem.as<ExplicitImportSymbol>().importName);
                setLoc(c, SourceRange(mem.location, mem.location + itemName.size()));
            }
            c->VpiDecompile(itemName);
            c->VpiSize((int32_t)itemName.size() * 8);
            c->VpiValue("STRING:" + itemName);
            c->VpiConstType(8); // Surelog's string-const encoding here
            its->Item(c);
        }
        if (!tds) {
            tds = s.MakeTypespecVec();
            m->Typespecs(tds);
        }
        tds->push_back(its);
    }
    if (auto it = importedTfCalls.find((const Scope*)&body);
        it != importedTfCalls.end() && !it->second.empty()) {
        auto* v = m->Task_funcs();
        if (!v) {
            v = s.MakeTask_funcVec();
            m->Task_funcs(v);
        }
        for (auto* tf : it->second)
            if (std::find(v->begin(), v->end(), tf) == v->end())
                v->push_back(tf);
    }
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
    // Def content is compiled for every def up front; the port/net phase
    // runs the first time the instance tree reaches the def.
    if (!defMap[&def].filled) {
        defMap[&def].filled = true;
        emitModuleDefPorts(inst);
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
        // Implicit nets carry no typespec (and print a bare wire net type).
        bool implicitNet = it.sym->kind == SymbolKind::Net &&
                           it.sym->as<NetSymbol>().isImplicit;
        // A real/shortreal var carries no typespec ref; its init is a vpiExpr.
        bool realVar = it.sym->getDeclaredType() &&
                       it.sym->getDeclaredType()->getType().isFloating();
        // Vector-typedef signals bind a fresh plain NAMED clone (built at
        // net-emission time, no alias link).
        UHDM::typespec* ts = nullptr;
        if (auto dtv = it.sym->getDeclaredType(); dtv && !implicitNet) {
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
                // Package-typedef clones keep the package instance link
                // (module-local clones carry none).
                if (auto tit0 = typedefTs.find(&tv);
                    tit0 != typedefTs.end() && tit0->second->Instance() &&
                    tit0->second->Instance()->UhdmType() == UHDM::uhdmpackage)
                    ts->Instance(tit0->second->Instance());
            }
        }
        if (!ts && !implicitNet && !realVar) {
            boundOwnerFullName = fullName;
            ts = sharedTypespec(*it.sym, netTs);
            boundOwnerFullName.clear();
        }
        // Unpacked-array signals: the instance view is an array_var (ranges
        // per unpacked dim, an inner reg carrying the element typespec, an
        // array_typespec). The def view keeps the plain net (see below).
        if (auto* av = (implicitNet || realVar)
                           ? nullptr
                           : emitArrayVar(*it.sym, name, fullName, m, ts)) {
            topNets[it.sym] = av;
            sigOrder.emplace_back(it.sym, av);
            vars->push_back(av);
            continue;
        }
        // Packed-array-of-struct: the elaborated view is a packed_array_var
        // (ranges + struct_var element), not a flat logic_var.
        if (!implicitNet && !realVar) {
            if (auto* pav = emitPackedStructArrayVar(*it.sym, name, fullName, m)) {
                topNets[it.sym] = pav;
                sigOrder.emplace_back(it.sym, pav);
                vars->push_back(pav);
                continue;
            }
        }
        UHDM::ref_typespec* rt = nullptr;
        if (!implicitNet && !realVar) {
            rt = s.MakeRef_typespec();
            rt->VpiFullName(fullName);
            rt->Actual_typespec(ts);
        }
        if (auto* v = makeVar(*it.sym, /*portBacked=*/it.port != nullptr)) {
            v->VpiName(name);
            v->VpiFullName(fullName);
            v->VpiParent(m);
            if (it.port && !it.bodyDecl)
                setLocNamed(v, *it.port);
            else
                setLoc(v, nameSpan(it.sym->location, it.sym->name));
            if (rt) {
                rt->VpiParent(v);
                v->Typespec(rt);
            }
            if (ts && ts->UhdmType() == UHDM::uhdmenum_typespec &&
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
                    bool concatInit = ic.kind == ExpressionKind::Concatenation;
                    // Unbased-unsized inits ('0/'1/'x/'z) each encode
                    // distinctly (Surelog quirk):
                    //   '0 -> BIN:0, sized to the var width, decompile '0
                    //   '1 -> UINT:<all-ones>, sized to width, decimal decompile
                    //   'x -> BIN:X, size -1, decompile 'X
                    //   'z -> BIN:Z, size -1, decompile 'Z
                    if (ic.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                        logic_t bit =
                            ic.as<UnbasedUnsizedIntegerLiteral>().getLiteralValue();
                        int32_t w = (int32_t)dt->getType().getBitWidth();
                        auto* c = s.MakeConstant();
                        if (bit.isUnknown()) {
                            std::string d =
                                bit.value == logic_t::X_VALUE ? "X" : "Z";
                            c->VpiDecompile("'" + d);
                            c->VpiSize(-1);
                            c->VpiValue("BIN:" + d);
                            c->VpiConstType(vpiBinaryConst);
                        }
                        else if (bit.value == 0) {
                            c->VpiDecompile("'0");
                            c->VpiSize(w);
                            c->VpiValue("BIN:0");
                            c->VpiConstType(vpiBinaryConst);
                        }
                        else {
                            slang::SVInt ones((slang::bitwidth_t)w, 0, false);
                            ones = ~ones; // all ones at width w, unsigned
                            std::string digits = ones.toString(LiteralBase::Decimal, false);
                            c->VpiDecompile(digits);
                            c->VpiSize(w);
                            c->VpiValue("UINT:" + digits);
                            c->VpiConstType(vpiUIntConst);
                        }
                        c->VpiParent(v);
                        setLoc(c, ic.sourceRange);
                        v->Expr(c);
                    }
                    else if (ic.kind == ExpressionKind::RealLiteral) {
                        // The var's init constant is unparented in this view.
                        if (auto* c = emitExpr(ic, v, fullName, topNets))
                            v->Expr((UHDM::expr*)c);
                    }
                    else if (ic.kind == ExpressionKind::Call &&
                             !ic.as<CallExpression>().isSystemCall()) {
                        // User-call inits keep the func_call as the var Expr.
                        if (auto* e = emitExpr(ic, v, fullName, topNets))
                            v->Expr((UHDM::expr*)e);
                    }
                    else if (ic.kind == ExpressionKind::StructuredAssignmentPattern &&
                             v->UhdmType() == UHDM::uhdmstruct_var) {
                        // Elab struct-var pattern init: op 75 with per-member
                        // FOLDED constants at the setter sites + a bare ts
                        // ref to the shared struct typespec.
                        auto& ap2 = ic.as<StructuredAssignmentPatternExpression>();
                        auto* op2 = s.MakeOperation();
                        op2->VpiOpType(vpiAssignmentPatternOp);
                        op2->VpiParent(v);
                        setLoc(op2, ic.sourceRange);
                        if (auto tt2 = typedefTs.find((const Symbol*)&dt->getType());
                            tt2 != typedefTs.end()) {
                            auto* rt3 = s.MakeRef_typespec();
                            rt3->Actual_typespec(tt2->second);
                            op2->Typespec(rt3);
                        }
                        auto* opnds = s.MakeAnyVec();
                        auto& sct = dt->getType()
                                        .getCanonicalType()
                                        .as<PackedStructType>();
                        ASTContext ectx(comp.getRoot(), LookupLocation::max);
                        for (auto& f : sct.membersOfType<FieldSymbol>()) {
                            const Expression* se = nullptr;
                            for (auto& ms2 : ap2.memberSetters)
                                if (ms2.member == &f) {
                                    se = ms2.expr;
                                    break;
                                }
                            if (!se)
                                se = ap2.defaultSetter;
                            if (!se)
                                continue;
                            ConstantValue cvm = ectx.tryEval(*se);
                            if (cvm && cvm.isInteger() &&
                                !cvm.integer().hasUnknown()) {
                                auto* c2 = s.MakeConstant();
                                slang::SVInt uvm = cvm.integer();
                                uvm.setSigned(false);
                                std::string digits2 =
                                    uvm.toString(LiteralBase::Decimal, false);
                                c2->VpiDecompile(digits2);
                                c2->VpiSize((int32_t)f.getType().getBitWidth());
                                c2->VpiValue("UINT:" + digits2);
                                c2->VpiConstType(vpiUIntConst);
                                c2->VpiParent(op2);
                                setLoc(c2, se->sourceRange);
                                opnds->push_back(c2);
                            }
                        }
                        op2->Operands(opnds);
                        v->Expr(op2);
                    }
                    else if (enumRef || isLiteralExpr(ic) || concatInit) {
                        bool forceSaved = forceConstParent;
                        // Concat ops self-parent; only bare literals need the
                        // force (which would leak into concat operands).
                        if (!enumRef && !concatInit)
                            forceConstParent = true;
                        if (auto* e = emitExpr(ic, v, fullName, topNets)) {
                            // Bare-decimal inits size at the var type width
                            // (string literals keep their 8*len size).
                            if (e->UhdmType() == UHDM::uhdmconstant &&
                                ic.kind != ExpressionKind::StringLiteral &&
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
                for (auto* ua : ait->second)
                    av->push_back(ua);
                v->Attributes(av);
            }
            // Vars creation-parent their (non-typedef) typespec like nets;
            // a shared decl-group ts ends at the group's last var.
            if (ts && ts->UhdmType() != UHDM::uhdmenum_typespec &&
                ts->UhdmType() != UHDM::uhdmstruct_typespec && ts->VpiName().empty())
                ts->VpiParent(v);
            // Initialized plain-typed vars span declarator..init.
            if (auto dtl = it.sym->getDeclaredType();
                dtl && dtl->getInitializer() && (realVar || (ts && ts->VpiName().empty()))) {
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
                setLoc(n, regNetSpan(*it.sym));
            if (!isStruct) {
                if (int32_t nt = netTypeFor(*it.sym))
                    ((UHDM::logic_net*)n)->VpiNetType(nt);
                if (it.sym->getDeclaredType() &&
                    it.sym->getDeclaredType()->getType().isSigned())
                    n->VpiSigned(true);
            }
            else if (it.port && n->UhdmType() == UHDM::uhdmlogic_net &&
                     isPkgStructType(*it.sym))
                ((UHDM::logic_net*)n)->VpiNetType(vpiWire);
            // A pkg-typedef struct net (non-port, flat members) is a WIRE
            // struct_net; nested-struct members stay untyped.
            else if (isStruct && isPkgStructType(*it.sym) &&
                     !hasStructFieldMember(*it.sym))
                ((UHDM::struct_net*)n)->VpiNetType(vpiWire);
            if (rt) {
                rt->VpiParent(n);
                n->Typespec(rt);
            }
            // The instance-view net shares the def-view attribute objects.
            if (auto ait = attrMap.find(it.sym); ait != attrMap.end()) {
                auto* av = s.MakeAttributeVec();
                for (auto* ua : ait->second)
                    av->push_back(ua);
                n->Attributes(av);
            }
            // Surelog parents the net typespec at creation; a shared
            // declaration-group typespec ends at the group's last net.
            // Typedef typespecs keep their own parent.
            if (ts && ts->UhdmType() != UHDM::uhdmenum_typespec &&
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
    auto* ifaceChildren = s.MakeInterface_instVec();
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::Instance) {
            auto& child = member.as<InstanceSymbol>();
            // Interface instances become interface_inst under vpiInterface.
            if (useInterfacePath(child)) {
                auto* ii = emitInterfaceInstance(
                    child, prefix + "." + std::string(child.name), m, &topNets, &instRefs);
                ifaceInstMap[&child] = ii;
                ifaceChildren->push_back(ii);
                continue;
            }
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
    if (!ifaceChildren->empty())
        m->Interfaces(ifaceChildren);

    // Instance-view ports each get a fresh typespec object (no sharing).
    // Top-level instances' ports are emitted in a second pass over all tops
    // (Surelog write phase), after every top's netlist elaboration.
    if (!isTop) {
        auto* ports = s.MakePortVec();
        for (auto portBase : body.getPortList()) {
            // Elab InterfacePort: LowConn ref_obj -> modport, HighConn ref_obj
            // -> the connected interface_inst.
            if (portBase->kind == SymbolKind::InterfacePort) {
                auto& ip = portBase->as<InterfacePortSymbol>();
                const PortConnection* iconn = nullptr;
                for (auto c : inst.getPortConnections())
                    if (&c->port == portBase) {
                        iconn = c;
                        break;
                    }
                auto* p = s.MakePort();
                p->VpiName(ip.name);
                p->VpiParent(m);
                setLocNamed(p, ip);
                p->VpiDirection(vpiInout);
                auto* lc = s.MakeRef_obj();
                lc->VpiFullName(prefix + "." + std::string(ip.name));
                lc->VpiParent(p);
                // A NAMED connection (.tcb(bi)) anchors the LowConn at the
                // FORMAL name; positional ones at the connection expression.
                if (auto npc = findConnSyntax(inst, ip.name))
                    setLoc(lc, SourceRange(npc->name.location(),
                                           npc->name.location() + ip.name.size()));
                else if (iconn && connectionExpr(*iconn))
                    setLoc(lc, connectionExpr(*iconn)->sourceRange);
                else
                    setLocNamed(lc, ip);
                if (ip.interfaceDef && !ip.modport.empty())
                    if (auto dit = modportsByDef.find(ip.interfaceDef);
                        dit != modportsByDef.end())
                        if (auto mit = dit->second.find(std::string(ip.modport));
                            mit != dit->second.end())
                            lc->Actual_group(mit->second);
                p->Low_conn(lc);
                auto conn = ip.getConnection();
                std::string connRaw =
                    iconn && connectionExpr(*iconn)
                        ? rawText(connectionExpr(*iconn)->sourceRange)
                        : std::string{};
                if (conn.first && connRaw.find('.') != std::string::npos) {
                    // Modport-qualified connection (s.mon): hier_path HighConn
                    // [s (name-only), mon (child-port-scoped fullname)].
                    auto* expr0 = connectionExpr(*iconn);
                    auto* hp = s.MakeHier_path();
                    hp->VpiName(connRaw);
                    hp->VpiFullName(connRaw);
                    hp->VpiParent(p);
                    setLoc(hp, expr0->sourceRange);
                    auto* elems2 = s.MakeAnyVec();
                    auto exprStart = expr0->sourceRange.start();
                    size_t start = 0, n2 = 0;
                    std::vector<std::pair<std::string, size_t>> comps;
                    while (start <= connRaw.size()) {
                        auto dot = connRaw.find('.', start);
                        if (dot == std::string::npos)
                            dot = connRaw.size();
                        comps.emplace_back(connRaw.substr(start, dot - start), start);
                        if (dot == connRaw.size())
                            break;
                        start = dot + 1;
                    }
                    for (auto& [cname, coff] : comps) {
                        auto* r2 = s.MakeRef_obj();
                        r2->VpiName(cname);
                        if (++n2 == comps.size())
                            r2->VpiFullName(prefix + "." + std::string(ip.name) + "." +
                                            cname);
                        else
                            r2->VpiFullName(cname); // name-only (dump omits)
                        r2->VpiParent(hp);
                        setLoc(r2, SourceRange(exprStart + coff,
                                               exprStart + coff + cname.size()));
                        elems2->push_back(r2);
                    }
                    hp->Path_elems(elems2);
                    p->High_conn(hp);
                }
                else if (conn.first) {
                    if (auto iit = ifaceInstMap.find(conn.first);
                        iit != ifaceInstMap.end()) {
                        auto* hc = s.MakeRef_obj();
                        hc->VpiName(conn.first->name);
                        hc->VpiFullName(parentPrefix + "." +
                                        std::string(conn.first->name));
                        hc->VpiParent(p);
                        // Points at the col-0 tail duplicate of the interface
                        // (weak ref → weaklyReferenced tail), falling back to
                        // the home view when no dup exists.
                        auto dit = ifaceTailDup.find(conn.first);
                        hc->Actual_group(dit != ifaceTailDup.end() ? dit->second
                                                                   : iit->second);
                        if (iconn && connectionExpr(*iconn))
                            setLoc(hc, connectionExpr(*iconn)->sourceRange);
                        p->High_conn(hc);
                    }
                }
                auto* its = makeIfacePortTs(ip);
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(prefix + "." + std::string(ip.name));
                rt->VpiParent(p);
                rt->Actual_typespec(its);
                p->Typespec(rt);
                ports->push_back(p);
                continue;
            }
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
            // Child low conns anchor at the formal name in the connection
            // (positional: at the actual expression).
            if (auto npc = findConnSyntax(inst, ps.name))
                setLoc(lc, SourceRange(npc->name.location(),
                                       npc->name.location() + ps.name.size()));
            else if (hasOrderedConns(inst) && conn && connectionExpr(*conn))
                setLoc(lc, connectionExpr(*conn)->sourceRange);
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
                    // An elab pattern HighConn folds to a based-decimal
                    // constant at the port width.
                    UHDM::any* h = nullptr;
                    {
                        auto& hc0 = stripImplicitConv(*expr);
                        if (hc0.kind == ExpressionKind::StructuredAssignmentPattern ||
                            hc0.kind == ExpressionKind::SimpleAssignmentPattern) {
                            ASTContext hctx(comp.getRoot(), LookupLocation::max);
                            ConstantValue hcv = hctx.tryEval(*expr);
                            if (hcv && hcv.isInteger() && !hcv.integer().hasUnknown()) {
                                auto& hiv = hcv.integer();
                                std::string digits =
                                    hiv.toString(LiteralBase::Decimal, false);
                                int32_t w = (int32_t)hiv.getBitWidth();
                                auto* c = s.MakeConstant();
                                c->VpiDecompile(std::to_string(w) + "'d" + digits);
                                c->VpiSize(w);
                                c->VpiValue("UINT:" + digits);
                                c->VpiConstType(0);
                                setLoc(c, hc0.sourceRange);
                                h = c;
                            }
                        }
                    }
                    if (!h)
                        h = emitExpr(*expr, p, hcPrefix, *parentNets);
                    if (h) {
                        // Elab-view literal HighConns parent at the port.
                        if (h->UhdmType() == UHDM::uhdmconstant)
                            h->VpiParent(p);
                        // Struct-member conns: last element scopes through the
                        // child port path; the hier_path carries the struct ts
                        // ref + the parent's elab base net as vpiExpr.
                        if (h->UhdmType() == UHDM::uhdmhier_path) {
                            auto* hp = (UHDM::hier_path*)h;
                            if (hp->Path_elems() && !hp->Path_elems()->empty()) {
                                auto* last = hp->Path_elems()->back();
                                if (last->UhdmType() == UHDM::uhdmref_obj)
                                    ((UHDM::ref_obj*)last)
                                        ->VpiFullName(prefix + "." +
                                                      std::string(ps.name) + "." +
                                                      std::string(last->VpiName()));
                            }
                            auto& ce = stripImplicitConv(*expr);
                            if (ce.kind == ExpressionKind::MemberAccess) {
                                auto& mbase = stripImplicitConv(
                                    ce.as<MemberAccessExpression>().value());
                                if (mbase.kind == ExpressionKind::NamedValue) {
                                    auto& bsym =
                                        mbase.as<NamedValueExpression>().symbol;
                                    if (auto tt = typedefTs.find(
                                            (const Symbol*)&bsym.getDeclaredType()
                                                ->getType());
                                        tt != typedefTs.end()) {
                                            auto* rt2 = s.MakeRef_typespec();
                                            rt2->VpiFullName(
                                                prefix + "." + std::string(ps.name) +
                                                "." + std::string(hp->VpiName()));
                                            rt2->VpiParent(hp);
                                            rt2->Actual_typespec(tt->second);
                                            hp->Typespec(rt2);
                                        }
                                    if (auto nit2 = parentNets->find(&bsym);
                                        nit2 != parentNets->end())
                                        hp->Root_value(nit2->second);
                                }
                            }
                        }
                        p->High_conn(h);
                    }
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
        // A module with interface ports exposes an instance-scoped
        // interface_inst view per port (work@top.m0.bus) under its vpiInterface.
        auto* portIfaces = s.MakeInterface_instVec();
        if (ifaceChildren)
            for (auto* ic : *ifaceChildren)
                portIfaces->push_back(ic);
        for (auto portBase : body.getPortList()) {
            if (portBase->kind != SymbolKind::InterfacePort)
                continue;
            auto& ip = portBase->as<InterfacePortSymbol>();
            auto conn = ip.getConnection();
            if (conn.first && conn.first->kind == SymbolKind::Instance) {
                auto* ii = emitInterfaceInstance(
                    conn.first->as<InstanceSymbol>(),
                    prefix + "." + std::string(portBase->name), m, &topNets, &instRefs,
                    /*portView=*/&inst);
                // A port view is named by the PORT, not the connected instance.
                ii->VpiName(std::string(portBase->name));
                portIfaces->push_back(ii);
                // A plain (no-modport) interface port lists the view TWICE
                // under vpiInterface and re-points the LowConn ref at it,
                // dropping the ref's port parent (Surelog quirks).
                if (ip.modport.empty()) {
                    portIfaces->push_back(ii);
                    for (auto* pp : *ports)
                        if (pp->VpiName() == ip.name && pp->Low_conn() &&
                            pp->Low_conn()->UhdmType() == UHDM::uhdmref_obj) {
                            auto* lr = (UHDM::ref_obj*)pp->Low_conn();
                            lr->Actual_group(ii);
                            lr->VpiParent(nullptr);
                        }
                }
                // Re-point the port's Low_conn ref_obj from the shared def
                // modport to this port view's own modport (which carries the
                // io_decl exprs + Interface_inst back-pointer Surelog expects).
                if (!ip.modport.empty() && ii->Modports())
                    for (auto* pp : *ports)
                        if (pp->VpiName() == ip.name && pp->Low_conn() &&
                            pp->Low_conn()->UhdmType() == UHDM::uhdmref_obj)
                            for (auto* umod : *ii->Modports())
                                if (umod->VpiName() == ip.modport)
                                    ((UHDM::ref_obj*)pp->Low_conn())
                                        ->Actual_group(umod);
            }
        }
        if (!portIfaces->empty())
            m->Interfaces(portIfaces);
    }

    std::set<const Symbol*> caLhsSyms;
    {
        auto it = defMap.find(&def);
        // Bound instances' content binds DEF nets.
        NetMap* caNets = &topNets;
        if (!bindPath.empty() && it != defMap.end())
            caNets = &it->second.nets;
        foldTypeCasts = !isTop;
        emitContAssigns(body, m, prefix, *caNets, /*topView=*/true,
                        it != defMap.end() ? &it->second : nullptr, /*shareWithDef=*/true,
                        &instRefs, &caLhsSyms);
        foldTypeCasts = false;
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
        if (it != defMap.end() && !it->second.assertions.empty()) {
            auto* av = s.MakeAnyVec();
            for (auto* a : it->second.assertions)
                av->push_back(a);
            m->Assertions(av);
        }
        // Elab views list the SHARED named-property declarations.
        {
            auto* pdecls = s.MakeProperty_declVec();
            for (auto& member : body.members())
                if (member.kind == SymbolKind::Property)
                    if (auto pit = propertyDeclMap.find(&member);
                        pit != propertyDeclMap.end())
                        pdecls->push_back(pit->second);
            if (!pdecls->empty())
                m->Property_decls(pdecls);
        }
        // Each view gets its own clocking_block object (not shared).
        if (it != defMap.end() && it->second.defaultClocking)
            emitDefaultClocking(body, m, prefix, topNets);
        if (it != defMap.end() && !it->second.taskFuncs.empty()) {
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

    emitImportArtifacts(body, m);

    if (isTop) {
        topPendings.push_back({&inst, m, prefix, std::move(topNets), paramLo,
                               pendingParamTs.size(), netTsLo, pendingNetTs.size()});
    }
    (void)childNetTsLo;

    return m;
}

// Generate blocks: one gen_scope_array + gen_scope per unrolled iteration
// (instance view only). The genvar becomes an unlocated localparam.
void UhdmExporter::emitGenScopes(const InstanceBodySymbol& body, UHDM::instance* m,
                                 const std::string& prefix, NetMap& netMap) {
    std::set<const Symbol*> genLhsSyms;
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
            // Actual int_typespec created LAST in the write phase (after any
            // gen-scope net-decl typespecs).
            pendingGenvarTs.push_back(rt);
            up->Typespec(rt);
            params->push_back(up);
        }
        if (!params->empty())
            gs->Parameters(params);

        // Local nets declared inside the block (wire tmp; ...).
        auto* gnets = s.MakeNetVec();
        std::vector<UHDM::cont_assign*> ndaCas;
        for (auto& gm : blk.members()) {
            if (gm.kind != SymbolKind::Net)
                continue;
            std::string nfull = fullName + "." + std::string(gm.name);
            auto* n = s.MakeLogic_net();
            n->VpiName(gm.name);
            n->VpiFullName(nfull);
            n->VpiParent(gs);
            setLoc(n, nameSpan(gm.location, gm.name));
            int32_t nt = netTypeFor(gm);
            if (nt)
                n->VpiNetType(nt);
            auto* dt = gm.getDeclaredType();
            bool hasInit = dt && dt->getInitializer();
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(nfull);
            rt->VpiParent(n);
            auto* ats = makeTypespec(gm);
            // A net-decl-assign net's list typespec loses its net parent (the
            // fresh Lhs net carries the parented one); a plain net keeps it.
            if (!hasInit)
                ats->VpiParent(n);
            rt->Actual_typespec(ats);
            n->Typespec(rt);
            gnets->push_back(n);
            // A net-declaration initializer (wire z = '1;) becomes a
            // net-decl-assign cont_assign with a FRESH Lhs net (own deferred
            // typespec), like the module-level net-decl-assign.
            if (hasInit) {
                auto* ca = s.MakeCont_assign();
                ca->VpiParent(gs);
                ca->VpiNetDeclAssign(true);
                setLoc(ca, nameSpan(gm.location, gm.name));
                bool fcp = forceConstParent;
                forceConstParent = true;
                if (auto* rhs = emitExpr(*dt->getInitializer(), ca, fullName, netMap)) {
                    if (rhs->UhdmType() == UHDM::uhdmconstant) {
                        auto* c = (UHDM::constant*)rhs;
                        int32_t w = (int32_t)dt->getType().getBitWidth();
                        if (c->VpiSize() == 64)
                            c->VpiSize(w);
                        else if (c->VpiSize() == -1) {
                            // Unbased-unsized ('1/'0) folds to the net width, UINT.
                            ASTContext actx(comp.getRoot(), LookupLocation::max);
                            auto cv = actx.tryEval(*dt->getInitializer());
                            if (cv.isInteger() && !cv.integer().hasUnknown()) {
                                std::string d = cv.integer().toString(LiteralBase::Decimal, false);
                                c->VpiValue("UINT:" + d);
                                c->VpiDecompile(d);
                                c->VpiSize(w);
                                c->VpiConstType(vpiUIntConst);
                            }
                        }
                    }
                    ca->Rhs((UHDM::expr*)rhs);
                }
                forceConstParent = fcp;
                auto* lnet = s.MakeLogic_net();
                lnet->VpiName(gm.name);
                lnet->VpiFullName(nfull);
                lnet->VpiParent(ca);
                if (nt)
                    lnet->VpiNetType(nt);
                setLoc(lnet, nameSpan(gm.location, gm.name));
                auto* lrt = s.MakeRef_typespec();
                lrt->VpiFullName(nfull);
                lrt->VpiParent(lnet);
                lnet->Typespec(lrt);
                pendingNetDeclTs.push_back({lrt, &gm});
                ca->Lhs(lnet);
                ndaCas.push_back(ca);
            }
        }
        if (!gnets->empty())
            gs->Nets(gnets);

        // Functions declared inside the block live on the gen_scope.
        {
            DefInfo genInfo;
            genInfo.nets = netMap;
            emitTaskFuncs(blk, gs, fullName, &genInfo);
        }

        // Contents: net-decl-assigns first, then explicit cont_assigns and
        // processes with gen-scoped prefixes.
        auto* cas = s.MakeCont_assignVec();
        for (auto* nca : ndaCas)
            cas->push_back(nca);
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
            {
                auto& lc0 = stripImplicitConv(ae.left());
                if (lc0.kind == ExpressionKind::NamedValue)
                    genLhsSyms.insert(&lc0.as<NamedValueExpression>().symbol);
            }
            bool forceSaved = forceConstParent;
            if (isLiteralExpr(ae.right()))
                forceConstParent = true;
            UHDM::any* rhs = nullptr;
            // Constant gen-scope calls fold to the source literal, sized at
            // the LHS width.
            if (auto cfr2 = constCallFold(stripImplicitConv(ae.right()));
                cfr2.lit && !cfr2.param) {
                forceConstParent = true;
                rhs = emitExpr(*cfr2.lit, ca, fullName, netMap);
                forceConstParent = false;
                if (rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                    rawText(cfr2.lit->sourceRange).find('\'') == std::string::npos)
                    ((UHDM::constant*)rhs)->VpiSize((int32_t)ae.left().type->getBitWidth());
            }
            if (!rhs) {
                // Gen-scope STREAMING operand refs stay unbound (Surelog).
                const Expression* rc0 = &stripImplicitConv(ae.right());
                if (rc0->kind == ExpressionKind::Conversion)
                    rc0 = &stripImplicitConv(
                        rc0->as<ConversionExpression>().operand());
                bool streamRhs = rc0->kind == ExpressionKind::Streaming;
                // CHILD-instance gen-scope CA RHS refs stay unbound too
                // (the LHS ref keeps its net actual).
                bool childGen = prefix.find('.') != std::string::npos;
                if (streamRhs || childGen)
                    suppressRefActual = true;
                rhs = emitExpr(ae.right(), ca, fullName, netMap);
                if (streamRhs || childGen)
                    suppressRefActual = false;
            }
            if (rhs)
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
        suppressRefActual = true;
        for (auto& gm : blk.members()) {
            if (gm.kind == SymbolKind::ProceduralBlock) {
                if (auto* p = emitProcess(gm.as<ProceduralBlockSymbol>(), m, fullName, netMap)) {
                    p->VpiParent(gs);
                    procs->push_back(p);
                }
            }
        }
        suppressRefActual = false;
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
        instSetGenScopeArrays(m, gsas);
    // Gen-scope CA LHS elaboration also strips the signal ts parent.
    for (auto sym : genLhsSyms) {
        auto it = netMap.find(sym);
        if (it == netMap.end())
            continue;
        auto* ex = (UHDM::expr*)it->second;
        if (ex->Typespec() && ex->Typespec()->Actual_typespec()) {
            auto* a = ex->Typespec()->Actual_typespec();
            if (a->UhdmType() != UHDM::uhdmenum_typespec &&
                a->UhdmType() != UHDM::uhdmstruct_typespec)
                a->VpiParent(nullptr);
        }
    }
}


// True when a packed-range bound of the symbol's declared type references a
// parameter that is OVERRIDDEN at some instantiation (its folded value is
// override-dependent, so the def view keeps the bound unfolded).
bool UhdmExporter::rangeRefsOverriddenParam(const Symbol& sym) {
    auto dt0 = sym.getDeclaredType();
    if (!dt0)
        return false;
    auto tsyn0 = dt0->getTypeSyntax();
    if (!tsyn0)
        return false;
    auto* its0 = tsyn0->as_if<syntax::IntegerTypeSyntax>();
    if (!its0)
        return false;
    bool found = false;
    for (auto* dim : its0->dimensions) {
        if (!dim->specifier ||
            dim->specifier->kind != syntax::SyntaxKind::RangeDimensionSpecifier)
            continue;
        auto& spec0 = dim->specifier->as<syntax::RangeDimensionSpecifierSyntax>();
        if (spec0.selector->kind != syntax::SyntaxKind::SimpleRangeSelect)
            continue;
        auto& sel0 = spec0.selector->as<syntax::RangeSelectSyntax>();
        for (const syntax::ExpressionSyntax* bs : {sel0.left.get(), sel0.right.get()}) {
            if (bs->kind == syntax::SyntaxKind::IntegerLiteralExpression)
                continue;
            if (auto psc0 = sym.getParentScope()) {
                ASTContext bctx0(*psc0, LookupLocation::max);
                auto& be0 = Expression::bind(*bs, bctx0);
                if (!be0.bad())
                    be0.visit(makeVisitor([&](auto& v0, const NamedValueExpression& nv0) {
                        if (nv0.symbol.kind == SymbolKind::Parameter &&
                            isOverriddenParam(nv0.symbol))
                            found = true;
                        v0.visitDefault(nv0);
                    }));
            }
        }
    }
    return found;
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
    // A def-view bound referencing an OVERRIDDEN param stays UNFOLDED
    // (name-only refs) — the folded value is override-dependent.
    if (!ts) {
        bool savedTf0 = tfContext;
        if (rangeRefsOverriddenParam(*pn.sym))
            tfContext = true;
        ts = makeTypespec(*pn.sym);
        tfContext = savedTf0;
    }
    // Unpacked-array def-view nets: the typespec span reaches the end of the
    // FIRST unpacked dimension (Surelog's element-span-plus-first-dim).
    if (auto dt3 = pn.sym->getDeclaredType()) {
        if (dt3->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType &&
            ts->VpiName().empty()) {
            if (auto dsyn = pn.sym->getSyntax();
                dsyn && dsyn->kind == syntax::SyntaxKind::Declarator) {
                auto& dd = dsyn->as<syntax::DeclaratorSyntax>();
                if (!dd.dimensions.empty()) {
                    auto de = dd.dimensions[0]->sourceRange().end();
                    ts->VpiEndLineNo(sm->getLineNumber(de));
                    ts->VpiEndColumnNo(sm->getColumnNumber(de));
                }
            }
        }
        // Multi-dim PACKED-array def nets also truncate to the first dim end
        // (top view keeps the whole-type span).
        else if (dt3->getType().isPackedArray() && ts->VpiName().empty()) {
            if (auto tsyn3 = dt3->getTypeSyntax();
                tsyn3 && syntax::IntegerTypeSyntax::isKind(tsyn3->kind)) {
                auto& dims3 = tsyn3->as<syntax::IntegerTypeSyntax>().dimensions;
                if (dims3.size() >= 2) {
                    auto de = dims3[0]->sourceRange().end();
                    ts->VpiEndLineNo(sm->getLineNumber(de));
                    ts->VpiEndColumnNo(sm->getColumnNumber(de));
                }
            }
            // Implicit-type nets (wire [3:0][7:0] t) likewise.
            else if (tsyn3 && tsyn3->kind == syntax::SyntaxKind::ImplicitType) {
                auto& dims3 = tsyn3->as<syntax::ImplicitTypeSyntax>().dimensions;
                if (dims3.size() >= 2) {
                    auto de = dims3[0]->sourceRange().end();
                    ts->VpiEndLineNo(sm->getLineNumber(de));
                    ts->VpiEndColumnNo(sm->getColumnNumber(de));
                }
            }
        }
    }
    // Initialized decls extend the def-view typespec through the init
    // (but unpacked arrays keep their first-dim span, handled above).
    bool isUnpacked = false;
    if (auto dt4 = pn.sym->getDeclaredType())
        isUnpacked = dt4->getType().getCanonicalType().kind ==
                     SymbolKind::FixedSizeUnpackedArrayType;
    if (auto dtl = pn.sym->getDeclaredType();
        dtl && dtl->getInitializer() && ts->VpiName().empty() && !isUnpacked &&
        !hasExplicitNetKeyword(*pn.sym)) {
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
    // Deferred DEF iface-port typespecs precede the top write-phase ts
    // (created after the whole netlist-elab pass; Surelog arena order).
    for (auto& [prt2, pip] : pendingIfacePortTs)
        prt2->Actual_typespec(makeIfacePortTs(*pip));
    pendingIfacePortTs.clear();
    // Package function return locals precede all module write-phase ts.
    drainFuncRet(/*pkgOnly=*/true);
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
    drainFuncRet();

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
        if (pc.castType) {
            auto& ct = pc.castType->getCanonicalType();
            UHDM::typespec* tts;
            if (ct.kind == SymbolKind::PredefinedIntegerType) {
                auto* its2 = s.MakeInt_typespec();
                its2->VpiSigned(ct.isSigned());
                tts = its2;
            }
            else {
                tts = s.MakeLogic_typespec();
            }
            tts->VpiLineNo(pc.line);
            tts->VpiColumnNo(pc.col);
            tts->VpiEndLineNo(pc.endLine);
            tts->VpiEndColumnNo(pc.endCol);
            tts->VpiParent(pc.rt);
            pc.rt->Actual_typespec(tts);
            continue;
        }
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

    // Param-clone typespecs for param-backed call folds (very end).
    // VECTOR params clone a LOC-LESS bare typespec instead (parented bounds,
    // clone parented at the ref).
    for (auto& pc : pendingParamCloneTs) {
        auto* rc0 = pc.rt->VpiParent();
        bool uintFold = rc0 && rc0->UhdmType() == UHDM::uhdmconstant &&
                        ((UHDM::constant*)rc0)->VpiValue().rfind("UINT:", 0) == 0;
        if (uintFold && !isOverriddenParam(*pc.ps) &&
            pc.ps->getType().getCanonicalType().isPackedArray()) {
            if (auto* bare = makeBareVecParamTs(*pc.ps, /*parentBounds=*/true)) {
                bare->VpiParent(pc.rt);
                pc.rt->Actual_typespec(bare);
                continue;
            }
        }
        bool tp2 = false;
        if (auto d0 = pc.ps->getDeclaredType())
            if (auto t0 = d0->getTypeSyntax())
                tp2 = t0->kind != syntax::SyntaxKind::ImplicitType;
        auto* its = makeParamTs(*pc.ps, tp2);
        if (auto sc = pc.ps->getParentScope()) {
            if (auto pit = pkgDefMap.find(&sc->asSymbol()); pit != pkgDefMap.end())
                its->Instance(pit->second);
        }
        its->VpiParent(pc.rt);
        pc.rt->Actual_typespec(its);
    }
    pendingParamCloneTs.clear();

    // Net-decl-assign Lhs typespecs (last in the arena).
    for (auto& [rt, sym] : pendingNetDeclTs) {
        auto* fts = makeTypespec(*sym);
        fts->VpiParent(rt);
        rt->Actual_typespec(fts);
    }
    pendingNetDeclTs.clear();
    // Gen-scope genvar int_typespecs are the very last arena objects.
    for (auto* rt : pendingGenvarTs)
        rt->Actual_typespec(s.MakeInt_typespec());
    pendingGenvarTs.clear();
    // Signed size-cast fold typespecs close out the tail.
    for (auto* rt : pendingSignedCastTs) {
        auto* lts = s.MakeLogic_typespec();
        lts->VpiSigned(true);
        rt->Actual_typespec(lts);
    }
    pendingSignedCastTs.clear();

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
                // The recompile re-parents SIMPLE-pattern operands at the
                // orphan (this is also what pulls it into the dump); tagged
                // (structured) pattern values stay unparented.
                if (val == o)
                    val->VpiParent(op);
            }
            op->Operands(ops);
        }
    }
    pendingPatternOrphans.clear();
}

void UhdmExporter::emitPorts(const InstanceBodySymbol& body, UHDM::instance* m,
                             const std::string& prefix,
                             NetMap& netMap, bool topView,
                             TsCache* sharedTs) {
    auto* ports = s.MakePortVec();
    for (auto portBase : body.getPortList()) {
        // A module port of interface type (myif.s sub): LowConn ref_obj ->
        // the modport object; vpiTypedef -> interface_typespec(modport).
        if (portBase->kind == SymbolKind::InterfacePort) {
            auto& ip = portBase->as<InterfacePortSymbol>();
            auto* p = s.MakePort();
            p->VpiName(ip.name);
            p->VpiParent(m);
            setLocNamed(p, ip);
            p->VpiDirection(vpiInout);
            auto* lc = s.MakeRef_obj();
            lc->VpiName(ip.name);
            lc->VpiFullName(prefix + "." + std::string(ip.name) + "." +
                            std::string(ip.name));
            lc->VpiParent(p);
            setLocNamed(lc, ip);
            if (ip.interfaceDef && !ip.modport.empty()) {
                if (auto dit = modportsByDef.find(ip.interfaceDef);
                    dit != modportsByDef.end()) {
                    if (auto mit = dit->second.find(std::string(ip.modport));
                        mit != dit->second.end())
                        lc->Actual_group(mit->second);
                }
            }
            // A plain (no-modport) interface port binds the DEF-view
            // interface instance as the LowConn actual.
            else if (ip.interfaceDef && !topView) {
                if (auto iit = ifaceDefMap.find(ip.interfaceDef);
                    iit != ifaceDefMap.end())
                    lc->Actual_group(iit->second);
            }
            p->Low_conn(lc);
            auto* rt = s.MakeRef_typespec();
            rt->VpiParent(p);
            // A plain (no-modport) DEF iface-port typespec is created LATE —
            // after the receiving child's port-view emission (arena order).
            if (ip.modport.empty() && !topView &&
                m->UhdmType() == UHDM::uhdmmodule_inst)
                pendingIfacePortTs.push_back({rt, &ip});
            else
                rt->Actual_typespec(makeIfacePortTs(ip));
            p->Typespec(rt);
            ports->push_back(p);
            continue;
        }
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

        // A def-view INTERFACE port carries no typespec (unlike a module port).
        if (!(m->UhdmType() == UHDM::uhdminterface_inst && !topView)) {
            // Override-gated port ranges: the def ts defers to the write
            // phase (arena tail) and unfolds there (materializeDefNetTs).
            if (!topView && m->UhdmType() == UHDM::uhdmmodule_inst &&
                rangeRefsOverriddenParam(*internal)) {
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(prefix + "." + std::string(ps.name));
                rt->VpiParent(p);
                p->Typespec(rt);
                pendingNetTs.push_back({internal, rt, &defMap[&body.getDefinition()]});
            }
            else {
                UHDM::typespec* ts = sharedTs ? sharedTypespec(*internal, *sharedTs, &ps)
                                              : makeTypespec(*internal, nullptr, &ps);
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(prefix + "." + std::string(ps.name));
                rt->VpiParent(p);
                rt->Actual_typespec(ts);
                p->Typespec(rt);
            }
        }

        ports->push_back(p);
    }
    if (!ports->empty())
        instSetPorts(m, ports);
}

void UhdmExporter::emitContAssigns(const InstanceBodySymbol& body, UHDM::instance* m,
                                   const std::string& prefix, NetMap& netMap, bool topView,
                                   DefInfo* defInfo, bool shareWithDef,
                                   std::set<const Symbol*>* instRefs,
                                   std::set<const Symbol*>* lhsSyms) {
    auto* cas = s.MakeCont_assignVec();
    // Net-declaration assignments (wire x = expr;) become cont_assigns with
    // vpiNetDeclAssign, before the explicit continuous assigns (top view only).
    for (auto& it : collectNetOrder(body)) {
        if (!topView)
            break;
        auto nit = netMap.find(it.sym);
        if (nit == netMap.end())
            continue;
        auto* dt = it.sym->getDeclaredType();
        if (!dt || !dt->getInitializer())
            continue;
        // Nets, and INTEGRAL reg variables emitted as logic_nets (reg b = 0),
        // get net-declaration assignments (real vars keep their own form).
        if (it.sym->kind != SymbolKind::Net &&
            !(it.sym->kind == SymbolKind::Variable &&
              nit->second->UhdmType() == UHDM::uhdmlogic_net &&
              dt->getType().isIntegral()))
            continue;
        auto* ca = s.MakeCont_assign();
        ca->VpiParent(m);
        ca->VpiNetDeclAssign(true);
        setLoc(ca, nameSpan(it.sym->location, it.sym->name));
        bool fcp = forceConstParent;
        forceConstParent = true;
        if (auto* rhs = emitExpr(*dt->getInitializer(), ca, prefix, netMap)) {
            // Surelog sizes a bare-decimal RHS (default 64) to the net width.
            if (rhs->UhdmType() == UHDM::uhdmconstant &&
                ((UHDM::expr*)rhs)->VpiSize() == 64)
                ((UHDM::expr*)rhs)->VpiSize((int32_t)dt->getType().getBitWidth());
            // Unbased-unsized inits: '0 keeps BIN:0 but sizes at the net
            // width; '1 UINT-folds at the width; 'x/'z stay unsized.
            if (rhs->UhdmType() == UHDM::uhdmconstant &&
                ((UHDM::expr*)rhs)->VpiSize() == -1) {
                auto& uic = stripImplicitConv(*dt->getInitializer());
                if (uic.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                    logic_t ub = uic.as<UnbasedUnsizedIntegerLiteral>().getLiteralValue();
                    auto* rc = (UHDM::constant*)rhs;
                    int32_t w = (int32_t)dt->getType().getBitWidth();
                    if (!ub.isUnknown()) {
                        rc->VpiSize(w);
                        if (ub.value) {
                            slang::SVInt ones((slang::bitwidth_t)w, 0, false);
                            ones = ~ones;
                            std::string digits = ones.toString(LiteralBase::Decimal, false);
                            rc->VpiValue("UINT:" + digits);
                            rc->VpiDecompile(digits);
                            rc->VpiConstType(vpiUIntConst);
                        }
                    }
                }
            }
            // A SIGNED based-literal RHS ('sb..) re-encodes as its signed
            // value (INT:<v>, decompile <v>, vpiIntConst).
            if (rhs->UhdmType() == UHDM::uhdmconstant) {
                auto& lic = stripImplicitConv(*dt->getInitializer());
                if (lic.kind == ExpressionKind::IntegerLiteral &&
                    rawText(lic.sourceRange).find("'s") != std::string::npos) {
                    auto ivl = lic.as<IntegerLiteral>().getValue();
                    if (!ivl.hasUnknown() && ivl.isSigned() && ivl.isNegative()) {
                        auto* rc = (UHDM::constant*)rhs;
                        std::string sd = ivl.toString(LiteralBase::Decimal, false);
                        rc->VpiDecompile(sd);
                        rc->VpiValue("INT:" + sd);
                        rc->VpiConstType(vpiIntConst);
                    }
                }
            }
            ca->Rhs((UHDM::expr*)rhs);
        }
        forceConstParent = fcp;
        // A LITERAL RHS is netlist-re-elaborated: the Lhs becomes a FRESH net
        // object (own typespec materialized last) and the module-list net
        // loses its typespec parent. A non-literal RHS reuses the module net
        // (a bare back-reference).
        auto* mnet = (UHDM::logic_net*)nit->second;
        auto& ncInit = *dt->getInitializer();
        // Literal or operation RHS -> netlist re-elaboration (fresh Lhs);
        // pure ref/select RHS -> shared module net (bare).
        if (isLiteralExpr(stripImplicitConv(ncInit)) || containsOperation(ncInit)) {
            auto* lnet = s.MakeLogic_net();
            lnet->VpiName(it.sym->name);
            lnet->VpiFullName(prefix + "." + std::string(it.sym->name));
            lnet->VpiParent(ca);
            lnet->VpiNetType(mnet->VpiNetType());
            if (mnet->VpiSigned())
                lnet->VpiSigned(true);
            setLoc(lnet, regNetSpan(*it.sym));
            if (mnet->Typespec() && mnet->Typespec()->Actual_typespec()) {
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(prefix + "." + std::string(it.sym->name));
                rt->VpiParent(lnet);
                lnet->Typespec(rt);
                pendingNetDeclTs.push_back({rt, it.sym});
            }
            ca->Lhs(lnet);
        }
        else {
            ca->Lhs((UHDM::expr*)mnet);
        }
        // The module-list net's typespec loses its parent (it is a
        // cont_assign LHS re-elaborated by the netlist pass).
        if (lhsSyms)
            lhsSyms->insert(it.sym);
        cas->push_back(ca);
    }
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
        // A select of a PACKAGE parameter (pkg::A[0]) folds in the elab view
        // to a BIN constant anchored at the param init's first char.
        const ParameterSymbol* pkgParamSel = nullptr;
        {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::ElementSelect) {
                auto& bser =
                    stripImplicitConv(rc.as<ElementSelectExpression>().value());
                if (bser.kind == ExpressionKind::NamedValue) {
                    auto& bsym = bser.as<NamedValueExpression>().symbol;
                    if (bsym.kind == SymbolKind::Parameter)
                        if (auto sc0 = bsym.getParentScope();
                            sc0 && sc0->asSymbol().kind == SymbolKind::Package)
                            pkgParamSel = &bsym.as<ParameterSymbol>();
                }
            }
        }
        // Argument-less user calls returning a literal fold in the top view
        // to that literal (its own loc and base shape). Calls returning a
        // TYPEDEF'd type never fold — the elab view shares the def CA.
        bool typedefRet = false;
        {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::Call &&
                !rc.as<CallExpression>().isSystemCall())
                if (auto subp0 = std::get_if<const SubroutineSymbol*>(
                        &rc.as<CallExpression>().subroutine))
                    typedefRet =
                        (*subp0)->getReturnType().kind == SymbolKind::TypeAlias;
        }
        CallFold cfr = (topView && !typedefRet)
                           ? constCallFold(stripImplicitConv(ae.right()))
                           : CallFold{};
        const Expression* constFnRet = (cfr && !cfr.param) ? cfr.lit : nullptr;
        // Calls with args still fold when evaluable: a LOC-LESS constant
        // shaped by the result type (signed int -> INT/vpiIntConst).
        std::optional<ConstantValue> callFold;
        if (topView && !cfr && !typedefRet) {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::Call && !rc.as<CallExpression>().isSystemCall()) {
                ASTContext ctx(comp.getRoot(), LookupLocation::max);
                ConstantValue cv = ctx.tryEval(ae.right());
                if (cv && cv.isInteger() && !cv.integer().hasUnknown())
                    callFold = std::move(cv);
            }
        }
        // Overridden-param RHS forces an instance-view re-emit: a folded
        // constant at the DEFAULT initializer's site, ts ref to the def
        // param typespec.
        const Symbol* ovParamRhs = nullptr;
        // A plain ref to a TYPED, non-overridden param folds (top view) to a
        // constant carrying a ref to the param's typespec, like an override.
        const Symbol* typedParamRhs = nullptr;
        // A plain ref to a constant-initialized, never-written module variable
        // folds (top view) to its init value.
        const Symbol* constVarRhs = nullptr;
        const Expression* constVarInit = nullptr;
        // A ref to a NO-DEFAULT overridden param folds to a raw-encoded
        // LOC-LESS constant shared into the param_assign Rhs.
        const Symbol* noDefOvRhs = nullptr;
        if (topView) {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::NamedValue) {
                auto& sym = rc.as<NamedValueExpression>().symbol;
                if (isOverriddenParam(sym))
                    ovParamRhs = &sym;
                else if (sym.kind == SymbolKind::Parameter &&
                         !paramDefaultSyn(sym.as<ParameterSymbol>()) &&
                         sym.as<ParameterSymbol>().getInitializer())
                    noDefOvRhs = &sym;
                else if (sym.kind == SymbolKind::Parameter) {
                    auto& ps = sym.as<ParameterSymbol>();
                    if (auto dt = ps.getDeclaredType())
                        if (auto tsyn = dt->getTypeSyntax())
                            if (tsyn->kind != syntax::SyntaxKind::ImplicitType &&
                                ps.getValue().isInteger() &&
                                !ps.getValue().integer().hasUnknown())
                                typedParamRhs = &sym;
                }
                else if (sym.kind == SymbolKind::Variable &&
                         sym.getDeclaredType() &&
                         sym.getDeclaredType()->getType().getCanonicalType().kind ==
                             SymbolKind::PredefinedIntegerType) {
                    auto dt = sym.getDeclaredType();
                    const Expression* init = dt ? dt->getInitializer() : nullptr;
                    if (init) {
                        ASTContext ctx(comp.getRoot(), LookupLocation::max);
                        ConstantValue cv = ctx.tryEval(*init);
                        if (cv && cv.isInteger() && !cv.integer().hasUnknown()) {
                            // Only fold if the var is never written procedurally.
                            bool written = false;
                            for (auto& mm : body.members()) {
                                if (mm.kind != SymbolKind::ProceduralBlock)
                                    continue;
                                mm.as<ProceduralBlockSymbol>().getBody().visit(makeVisitor(
                                    [&](auto& vis, const AssignmentExpression& ax) {
                                        auto& lc = stripImplicitConv(ax.left());
                                        if (lc.kind == ExpressionKind::NamedValue &&
                                            &lc.as<NamedValueExpression>().symbol == &sym)
                                            written = true;
                                        vis.visitDefault(ax);
                                    }));
                            }
                            if (!written) {
                                constVarRhs = &sym;
                                constVarInit = init;
                            }
                        }
                    }
                }
            }
        }
        // Top modules share the def's cont_assign object unless netlist
        // elaboration re-compiles it: that happens only for whole-net LHS
        // (RHS resized against the net width) when the RHS contains
        // operations or is a literal. Select-LHS assigns always stay shared.
        bool plainLhs = stripImplicitConv(ae.left()).kind == ExpressionKind::NamedValue;
        // A dotted (member-access) LHS re-emits a FRESH elab cont_assign
        // whose Rhs SHARES the def constant — but only when the elab base is
        // VAR-backed (net bases keep the shared def cont_assign).
        bool dottedLhs = stripImplicitConv(ae.left()).kind == ExpressionKind::MemberAccess;
        if (dottedLhs) {
            const Expression* baseE = &stripImplicitConv(ae.left());
            while (baseE->kind == ExpressionKind::MemberAccess)
                baseE = &stripImplicitConv(baseE->as<MemberAccessExpression>().value());
            if (baseE->kind == ExpressionKind::NamedValue) {
                auto nit0 = netMap.find(&baseE->as<NamedValueExpression>().symbol);
                if (nit0 != netMap.end()) {
                    auto ut0 = nit0->second->UhdmType();
                    if (ut0 == UHDM::uhdmlogic_net || ut0 == UHDM::uhdmstruct_net ||
                        ut0 == UHDM::uhdminteger_net || ut0 == UHDM::uhdmarray_net)
                        dottedLhs = false;
                }
            }
        }
        // An interface-port member LHS (ss_if.start_addr) in a CHILD elab
        // instance re-emits a FRESH cont_assign (hier_path Lhs, bare Rhs).
        bool ifaceDotFresh = false;
        {
            auto& l0 = stripImplicitConv(ae.left());
            std::string lraw = std::string(rawText(l0.sourceRange));
            auto ldot = lraw.find('.');
            if (topView && l0.kind == ExpressionKind::HierarchicalValue &&
                prefix.find('.') != std::string::npos && ldot != std::string::npos) {
                auto* bsym = body.find(lraw.substr(0, ldot));
                if (bsym && bsym->kind == SymbolKind::InterfacePort)
                    ifaceDotFresh = true;
            }
        }
        if (shareWithDef && defInfo && myIdx < defInfo->contAssigns.size() &&
            ((!plainLhs && !dottedLhs && !ifaceDotFresh) ||
             (plainLhs &&
              !containsOperation(ae.right()) && !literalRhs && !enumRhs && !cfr &&
              !callFold && !ovParamRhs && !typedParamRhs && !constVarRhs &&
              !pkgParamSel && !noDefOvRhs))) {
            cas->push_back(defInfo->contAssigns[myIdx]);
            continue;
        }
        auto* ca = s.MakeCont_assign();
        ca->VpiParent(m);
        setLoc(ca, assign.sourceRange);
        if (ifaceDotFresh) {
            // hier_path Lhs: name-only ref elements, ALL anchored at the
            // LAST member token; bare loc-only Rhs constant.
            auto& l0 = stripImplicitConv(ae.left());
            std::string raw = rawText(l0.sourceRange);
            auto* hp = s.MakeHier_path();
            hp->VpiName(raw);
            hp->VpiFullName(raw);
            hp->VpiParent(ca);
            setLoc(hp, l0.sourceRange);
            auto* elems = s.MakeAnyVec();
            size_t lastDot = raw.rfind('.');
            SourceRange lastSpan(l0.sourceRange.start() + (lastDot + 1),
                                 l0.sourceRange.start() + raw.size());
            size_t pos = 0;
            while (pos <= raw.size()) {
                auto dot = raw.find('.', pos);
                if (dot == std::string::npos)
                    dot = raw.size();
                auto* r = s.MakeRef_obj();
                r->VpiName(raw.substr(pos, dot - pos));
                // fullname==name (dump omits it); pre-set so no later pass
                // fills a scoped one in.
                r->VpiFullName(raw.substr(pos, dot - pos));
                r->VpiParent(hp);
                setLoc(r, lastSpan);
                elems->push_back(r);
                if (dot == raw.size())
                    break;
                pos = dot + 1;
            }
            hp->Path_elems(elems);
            ca->Lhs(hp);
            auto* bc = s.MakeConstant();
            setLoc(bc, stripImplicitConv(ae.right()).sourceRange);
            ca->Rhs(bc);
            cas->push_back(ca);
            continue;
        }
        UHDM::any* rhs = nullptr;
        // A PACKAGE-scoped enum const RHS folds to a LOCATED digits-constant in
        // BOTH views; a module-local one folds loc-less in the top view only.
        bool pkgEnumRhs = false;
        for (auto sc0 = enumRhs ? enumRhs->getParentScope() : nullptr; sc0;
             sc0 = sc0->asSymbol().getParentScope()) {
            if (sc0->asSymbol().kind == SymbolKind::Package) {
                pkgEnumRhs = true;
                break;
            }
            if (sc0->asSymbol().kind == SymbolKind::InstanceBody)
                break;
        }
        // Interface def views keep the enum-const ref (module views fold).
        if (m->UhdmType() != UHDM::uhdmmodule_inst)
            pkgEnumRhs = false;
        if (enumRhs && (topView || pkgEnumRhs)) {
            if (auto eit = enumConstMap.find(enumRhs); eit != enumConstMap.end()) {
                auto* src = (UHDM::enum_const*)eit->second;
                auto* c = s.MakeConstant();
                c->VpiParent(ca);
                c->VpiSize(src->VpiSize());
                std::string_view v = src->VpiValue();
                c->VpiValue(std::string(v));
                if (pkgEnumRhs) {
                    // BIN values decompile <w>'b<bits>; others the digits.
                    // Expression loc.
                    auto colon = v.find(':');
                    std::string digs(colon != std::string_view::npos
                                         ? v.substr(colon + 1)
                                         : v);
                    if (v.rfind("BIN:", 0) == 0)
                        c->VpiDecompile(std::to_string(src->VpiSize()) + "'b" + digs);
                    else
                        c->VpiDecompile(digs);
                    setLoc(c, stripImplicitConv(ae.right()).sourceRange);
                    // BOTH module views share ONE fold constant per enum const.
                    if (auto fit = pkgEnumFoldConst.find(enumRhs);
                        fit != pkgEnumFoldConst.end()) {
                        rhs = fit->second;
                        goto pkgFoldShared;
                    }
                    pkgEnumFoldConst[enumRhs] = c;
                }
                else
                    c->VpiDecompile(src->VpiDecompile());
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
            pkgFoldShared:;
            }
        }
        // Unbased-unsized literal RHS folds to a LOCATED, parented constant
        // at the type width.
        if (!rhs && topView) {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                ASTContext ctx(comp.getRoot(), LookupLocation::max);
                ConstantValue cv = ctx.tryEval(ae.right());
                // '0 does NOT fold fresh: the elab Rhs shares the def-view
                // constant (sized at the LHS width there). '1 folds to the
                // all-ones UINT.
                if (cv && cv.isInteger() && cv.integer() == 0)
                    cv = nullptr;
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
        if (!rhs && topView && ovParamRhs) {
            auto& ps2 = ovParamRhs->as<ParameterSymbol>();
            auto& cvo = ps2.getValue();
            if (cvo.isInteger() && !cvo.integer().hasUnknown()) {
                auto& iv = cvo.integer();
                std::string digits = iv.toString(LiteralBase::Decimal, false);
                auto* c = s.MakeConstant();
                c->VpiDecompile(digits);
                c->VpiValue("UINT:" + digits);
                c->VpiConstType(vpiUIntConst);
                c->VpiSize((int32_t)iv.getBitWidth());
                c->VpiParent(ca);
                if (auto* dsy = paramDefaultSyn(ps2))
                    setLoc(c, dsy->sourceRange());
                {
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiFullName(prefix);
                    rt->VpiParent(c);
                    c->Typespec(rt);
                    // Fresh param-ts clone at the very end of the write phase.
                    pendingParamCloneTs.push_back({rt, &ps2});
                }
                rhs = c;
            }
        }
        // Typed non-overridden param ref: folded default constant + a ref to
        // the param's typespec (cloned at the end of the write phase). Located
        // at the param's default-value expression.
        if (!rhs && topView && typedParamRhs) {
            auto& ps2 = typedParamRhs->as<ParameterSymbol>();
            auto& iv = ps2.getValue().integer();
            bool neg = iv.isSigned() && iv.isNegative();
            std::string digits = iv.toString(LiteralBase::Decimal, false);
            auto* c = s.MakeConstant();
            c->VpiDecompile(digits);
            c->VpiValue((neg ? "INT:" : "UINT:") + digits);
            c->VpiConstType(neg ? vpiIntConst : vpiUIntConst);
            c->VpiSize((int32_t)iv.getBitWidth());
            c->VpiParent(ca);
            if (auto* dsy = paramDefaultSyn(ps2))
                setLoc(c, dsy->sourceRange());
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(prefix);
            rt->VpiParent(c);
            c->Typespec(rt);
            pendingParamCloneTs.push_back({rt, &ps2});
            rhs = c;
        }
        // Constant-driven module var: fold to its init value (plain constant,
        // no typespec) at the initializer's site.
        if (!rhs && topView && constVarRhs) {
            ASTContext ctx(comp.getRoot(), LookupLocation::max);
            ConstantValue cvv = ctx.tryEval(*constVarInit);
            auto& iv = cvv.integer();
            bool neg = iv.isSigned() && iv.isNegative();
            std::string digits = iv.toString(LiteralBase::Decimal, false);
            auto* c = s.MakeConstant();
            c->VpiDecompile(digits);
            c->VpiValue((neg ? "INT:" : "UINT:") + digits);
            c->VpiConstType(neg ? vpiIntConst : vpiUIntConst);
            c->VpiSize((int32_t)iv.getBitWidth());
            c->VpiParent(ca);
            setLoc(c, stripImplicitConv(*constVarInit).sourceRange);
            rhs = c;
        }
        // Param-backed call folds: constant at the in-function ref site,
        // typed by the param, its ts cloned at the very end of the write
        // phase.
        if (!rhs && topView && cfr.param) {
            auto& ps2 = *cfr.param;
            auto& cv2 = ps2.getValue();
            if (cv2.isInteger() && !cv2.integer().hasUnknown()) {
                auto& iv2 = cv2.integer();
                bool neg2 = iv2.isSigned() && iv2.isNegative();
                std::string digits2 = iv2.toString(LiteralBase::Decimal, false);
                auto* c = s.MakeConstant();
                c->VpiDecompile(digits2);
                c->VpiSize((int32_t)ps2.getType().getBitWidth());
                c->VpiValue((neg2 ? "INT:" : "UINT:") + digits2);
                c->VpiConstType(neg2 ? vpiIntConst : vpiUIntConst);
                setLoc(c, cfr.site->sourceRange);
                c->VpiParent(ca);
                auto* rt2 = s.MakeRef_typespec();
                rt2->VpiFullName(prefix);
                rt2->VpiParent(c);
                c->Typespec(rt2);
                pendingParamCloneTs.push_back({rt2, &ps2});
                rhs = c;
            }
        }
        if (!rhs && topView && pkgParamSel) {
            ASTContext pctx(comp.getRoot(), LookupLocation::max);
            ConstantValue cv2 = pctx.tryEval(ae.right());
            if (cv2 && cv2.isInteger() && !cv2.integer().hasUnknown()) {
                auto& iv2 = cv2.integer();
                int32_t w2 = (int32_t)iv2.getBitWidth();
                std::string digits2 = iv2.toString(LiteralBase::Binary, false);
                auto* c = s.MakeConstant();
                c->VpiDecompile(std::to_string(w2) + "'b" + digits2);
                c->VpiSize(w2);
                c->VpiValue("BIN:" + digits2);
                c->VpiConstType(vpiBinaryConst);
                c->VpiParent(ca);
                if (auto* pinit = pkgParamSel->getInitializer()) {
                    auto st2 = pinit->sourceRange.start();
                    setLoc(c, SourceRange(st2, st2 + 1));
                }
                rhs = c;
            }
        }
        if (!rhs && topView && noDefOvRhs) {
            auto& ps2 = noDefOvRhs->as<ParameterSymbol>();
            auto& ovc = stripImplicitConv(*ps2.getInitializer());
            std::string raw = rawText(ovc.sourceRange);
            auto tick = raw.find('\'');
            if (ovc.kind == ExpressionKind::IntegerLiteral && tick != std::string::npos) {
                size_t basePos = tick + 1;
                if (basePos < raw.size() &&
                    (raw[basePos] == 's' || raw[basePos] == 'S'))
                    basePos++;
                char base = basePos < raw.size() ? (char)tolower(raw[basePos]) : 'd';
                std::string digits = raw.substr(basePos + 1);
                auto* c = s.MakeConstant();
                c->VpiDecompile(raw);
                c->VpiSize((int32_t)ps2.getType().getBitWidth());
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
                c->VpiParent(ca);
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(prefix);
                rt->VpiParent(c);
                c->Typespec(rt);
                // Shares the ELAB param typespec (bound in
                // patchParamTypespecs).
                noDefOvTsRef[noDefOvRhs].push_back(rt);
                // The instance param_assigns share this fold constant.
                if (auto npit = noDefOvPa.find(noDefOvRhs); npit != noDefOvPa.end()) {
                    for (auto* pa2 : npit->second)
                        pa2->Rhs(c);
                    noDefOvPa.erase(npit);
                }
                rhs = c;
            }
        }
        if (!rhs && topView && constFnRet) {
            forceConstParent = true;
            rhs = emitExpr(*constFnRet, ca, prefix, netMap);
            forceConstParent = false;
            // Bare-decimal folds size at the LHS type width.
            if (rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                rawText(constFnRet->sourceRange).find('\'') == std::string::npos)
                ((UHDM::constant*)rhs)->VpiSize((int32_t)ae.left().type->getBitWidth());
        }
        if (!rhs && topView && callFold) {
            auto& iv = callFold->integer();
            // A folded call WITH arguments keeps the signed (INT) encoding; an
            // argument-less fold is encoded by magnitude (UINT) unless negative.
            auto& rcCall = stripImplicitConv(ae.right());
            bool hasArgs = rcCall.kind == ExpressionKind::Call &&
                           !rcCall.as<CallExpression>().arguments().empty();
            bool sgn = hasArgs ? iv.isSigned() : (iv.isSigned() && iv.isNegative());
            std::string digits = iv.toString(LiteralBase::Decimal, false);
            auto* c = s.MakeConstant();
            // A SCALAR (1-bit logic) call result encodes as BINARY with a
            // based decompile (1'b1); wider results keep decimal.
            if (ae.right().type && ae.right().type->isFourState() &&
                ae.right().type->getBitWidth() == 1) {
                int32_t w = (int32_t)iv.getBitWidth();
                std::string bits;
                for (int32_t i = w - 1; i >= 0; i--)
                    bits += (iv[i] == slang::logic_t(1)) ? '1' : '0';
                c->VpiDecompile(std::to_string(w) + "'b" + bits);
                c->VpiSize(w);
                c->VpiValue("BIN:" + bits);
                c->VpiConstType(vpiBinaryConst);
            }
            else {
                c->VpiDecompile(digits);
                c->VpiSize((int32_t)iv.getBitWidth());
                c->VpiValue((sgn ? "INT:" : "UINT:") + digits);
                c->VpiConstType(sgn ? vpiIntConst : vpiUIntConst);
            }
            c->VpiParent(ca);
            rhs = c;
        }
        // A STRUCTURED assignment-pattern RHS re-emits EXPANDED in the elab
        // view: op75 with one per-field value constant (field width, UINT,
        // located at the source value token — the default's token repeats).
        if (!rhs && topView &&
            stripImplicitConv(ae.right()).kind ==
                ExpressionKind::StructuredAssignmentPattern &&
            stripImplicitConv(ae.right()).type &&
            stripImplicitConv(ae.right()).type->getCanonicalType().isStruct()) {
            auto& ap = stripImplicitConv(ae.right())
                           .as<StructuredAssignmentPatternExpression>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiAssignmentPatternOp);
            op->VpiParent(ca);
            setLoc(op, ap.sourceRange);
            auto* operands = s.MakeAnyVec();
            bool ok = true;
            for (auto el : ap.elements()) {
                ASTContext ectx(comp.getRoot(), LookupLocation::max);
                ConstantValue ecv = ectx.tryEval(*el);
                if (!ecv || !ecv.isInteger() || ecv.integer().hasUnknown()) {
                    ok = false;
                    break;
                }
                auto eiv = ecv.integer();
                eiv.setSigned(false);
                std::string digits = eiv.toString(LiteralBase::Decimal, false);
                auto* c = s.MakeConstant();
                c->VpiDecompile(digits);
                c->VpiSize((int32_t)el->type->getBitWidth());
                c->VpiValue("UINT:" + digits);
                c->VpiConstType(vpiUIntConst);
                c->VpiParent(op);
                setLoc(c, el->sourceRange);
                operands->push_back(c);
            }
            if (ok) {
                op->Operands(operands);
                rhs = op;
            }
        }
        // A STRING-typed RHS (concat {NAME,"efgh"}) folds to a single
        // loc-less STRING constant sized at 8 bits per character.
        if (!rhs && topView && ae.right().type && ae.right().type->isString() &&
            stripImplicitConv(ae.right()).kind == ExpressionKind::Concatenation) {
            ASTContext sctx(comp.getRoot(), LookupLocation::max);
            ConstantValue scv = sctx.tryEval(ae.right());
            if (scv && scv.isString()) {
                std::string sv = scv.str();
                auto* c = s.MakeConstant();
                c->VpiSize((int32_t)(sv.size() * 8));
                c->VpiValue("STRING:" + sv);
                c->VpiConstType(vpiStringConst);
                rhs = c;
            }
        }
        // A NEGATIVE literal RHS (-1) folds loc-less at the LHS type:
        // signed targets keep INT:<neg>, unsigned targets wrap to UINT.
        if (!rhs && topView) {
            auto& rn = stripImplicitConv(ae.right());
            if (rn.kind == ExpressionKind::UnaryOp &&
                rn.as<UnaryExpression>().op == UnaryOperator::Minus &&
                stripImplicitConv(rn.as<UnaryExpression>().operand()).kind ==
                    ExpressionKind::IntegerLiteral) {
                ASTContext nctx(comp.getRoot(), LookupLocation::max);
                ConstantValue ncv = nctx.tryEval(ae.right());
                int32_t w = (int32_t)ae.left().type->getBitWidth();
                if (ncv && ncv.isInteger() && !ncv.integer().hasUnknown() && w > 0 &&
                    w <= 64) {
                    auto niv = ncv.integer();
                    auto* c = s.MakeConstant();
                    c->VpiSize(w);
                    niv.setSigned(true);
                    std::string digits = niv.toString(LiteralBase::Decimal, false);
                    c->VpiDecompile(digits);
                    c->VpiValue("INT:" + digits);
                    c->VpiConstType(vpiIntConst);
                    rhs = c;
                }
            }
        }
        if (!rhs && !bitsRhs)
            // Unbased-unsized RHS never general-folds here: '1 folded above,
            // '0 shares the def constant, 'x/'z have unknowns. Replicated
            // patterns re-emit as operations.
            rhs = (topView &&
                   stripImplicitConv(ae.right()).kind !=
                       ExpressionKind::UnbasedUnsizedIntegerLiteral &&
                   stripImplicitConv(ae.right()).kind !=
                       ExpressionKind::ReplicatedAssignmentPattern)
                      ? tryFoldConst(ae.right())
                      : nullptr;
        // A NESTED cast RHS that evals fully (int'($clog2(X)'(X))) folds
        // loc-less: UINT by magnitude at the result width (signed wraps
        // encode 4294967295-style). Single casts keep the operation.
        if (!rhs && topView) {
            auto& rc0 = stripImplicitConv(ae.right());
            bool nestedCast =
                rc0.kind == ExpressionKind::Conversion &&
                !rc0.as<ConversionExpression>().isImplicit() &&
                stripImplicitConv(rc0.as<ConversionExpression>().operand()).kind ==
                    ExpressionKind::Conversion &&
                !stripImplicitConv(rc0.as<ConversionExpression>().operand())
                     .as<ConversionExpression>()
                     .isImplicit();
            if (nestedCast && rc0.syntax &&
                rc0.syntax->kind == syntax::SyntaxKind::CastExpression) {
                ASTContext cctx(comp.getRoot(), LookupLocation::max);
                if (ConstantValue ccv = cctx.tryEval(ae.right());
                    ccv && ccv.isInteger() && !ccv.integer().hasUnknown()) {
                    auto civ = ccv.integer();
                    int32_t w = (int32_t)civ.getBitWidth();
                    if (w > 0 && w <= 64) {
                        uint64_t uv = (uint64_t)civ.as<int64_t>().value_or(0);
                        if (w < 64)
                            uv &= (~0ULL >> (64 - w));
                        auto* c = s.MakeConstant();
                        std::string digits = std::to_string(uv);
                        c->VpiDecompile(digits);
                        c->VpiSize(w);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        rhs = c;
                    }
                }
            }
        }
        // A SIZE cast of a VARIABLE with a constant initializer folds
        // through the variable's INITIAL value (Surelog reduce quirk):
        // loc-less unparented constant at the cast width.
        if (!rhs && topView) {
            auto& rc0 = stripImplicitConv(ae.right());
            if (rc0.kind == ExpressionKind::Conversion &&
                !rc0.as<ConversionExpression>().isImplicit() && rc0.syntax &&
                rc0.syntax->kind == syntax::SyntaxKind::CastExpression &&
                rc0.syntax->as<syntax::CastExpressionSyntax>().left->kind ==
                    syntax::SyntaxKind::ScopedName) {
                auto& opnd = stripImplicitConv(rc0.as<ConversionExpression>().operand());
                if (opnd.kind == ExpressionKind::NamedValue &&
                    opnd.as<NamedValueExpression>().symbol.kind ==
                        SymbolKind::Variable) {
                    auto& vsym = opnd.as<NamedValueExpression>().symbol;
                    auto vdt = vsym.getDeclaredType();
                    int32_t w = (int32_t)ae.right().type->getBitWidth();
                    if (vdt && vdt->getInitializer() && w > 0 && w <= 64) {
                        ASTContext vctx(comp.getRoot(), LookupLocation::max);
                        ConstantValue vcv = vctx.tryEval(*vdt->getInitializer());
                        if (vcv && vcv.isInteger() && !vcv.integer().hasUnknown()) {
                            uint64_t uv = vcv.integer().as<uint64_t>().value_or(0);
                            if (w < 64)
                                uv &= (1ULL << w) - 1;
                            auto* c = s.MakeConstant();
                            std::string digits = std::to_string(uv);
                            c->VpiDecompile(digits);
                            c->VpiSize(w);
                            c->VpiValue("UINT:" + digits);
                            c->VpiConstType(vpiUIntConst);
                            rhs = c;
                        }
                    }
                }
            }
        }
        // Assignment-pattern RHS folds format the constant as based-decimal
        // ("8'd255"), at the LHS width, with no constType, located at the
        // pattern span.
        if (rhs && topView && rhs->UhdmType() == UHDM::uhdmconstant) {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::SimpleAssignmentPattern ||
                rc.kind == ExpressionKind::StructuredAssignmentPattern) {
                auto* c = (UHDM::constant*)rhs;
                int32_t w = (int32_t)ae.left().type->getBitWidth();
                std::string v(c->VpiValue());
                std::string digits =
                    v.find(':') != std::string::npos ? v.substr(v.find(':') + 1) : v;
                c->VpiDecompile(std::to_string(w) + "'d" + digits);
                c->VpiSize(w);
                c->VpiConstType(0);
                setLoc(c, rc.sourceRange);
            }
        }
        // Sized/based literal RHS: the top-view cont_assign is fresh but its
        // Rhs reuses the def's constant (Surelog's expression cache); bare
        // decimals are re-emitted fresh.
        if (!rhs && topView && shareWithDef && literalRhs && defInfo &&
            myIdx < defInfo->contAssigns.size()) {
            auto raw = rawText(stripImplicitConv(ae.right()).sourceRange);
            if (raw.find('\'') != std::string::npos)
                rhs = (UHDM::any*)defInfo->contAssigns[myIdx]->Rhs();
        }
        // Dotted-LHS re-emits share the def Rhs object wholesale.
        if (!rhs && topView && dottedLhs && shareWithDef && defInfo &&
            myIdx < defInfo->contAssigns.size())
            rhs = (UHDM::any*)defInfo->contAssigns[myIdx]->Rhs();
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
            paramInitDef = !topView;
            rhs = emitExpr(ae.right(), ca, prefix, rhsMap);
            paramInitDef = false;
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
            // A def-view '0 RHS (alone among unbased-unsized) on a WHOLE-NET
            // LHS sizes at the LHS width; the elab view then shares this
            // constant. Select/dotted LHS keeps -1.
            if (!topView && rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                stripImplicitConv(ae.left()).kind == ExpressionKind::NamedValue &&
                stripImplicitConv(ae.right()).kind ==
                    ExpressionKind::UnbasedUnsizedIntegerLiteral &&
                rawText(stripImplicitConv(ae.right()).sourceRange) == "'0")
                ((UHDM::constant*)rhs)->VpiSize((int32_t)ae.left().type->getBitWidth());
        }
        if (rhs)
            ca->Rhs((UHDM::expr*)rhs);
        // A $signed/$unsigned sys_func_call carries a result typespec (= the
        // LHS type) via a module-prefixed ref_typespec sharing the LHS port's
        // actual (bound in the deferred pass so no tail duplicate is minted).
        if (rhs && rhs->UhdmType() == UHDM::uhdmsys_func_call && defInfo) {
            auto& rcs = stripImplicitConv(ae.right());
            if (rcs.kind == ExpressionKind::Call && rcs.as<CallExpression>().isSystemCall()) {
                auto nm = rcs.as<CallExpression>().getSubroutineName();
                if (nm == "$signed" || nm == "$unsigned" || nm == "$bits" ||
                    nm == "$clog2" || nm == "$fell" || nm == "$rose" ||
                    nm == "$stable" || nm == "$past") {
                    auto& le = stripImplicitConv(ae.left());
                    if (le.kind == ExpressionKind::NamedValue) {
                        auto* rt = s.MakeRef_typespec();
                        rt->VpiFullName(prefix);
                        rt->VpiParent(rhs);
                        ((UHDM::expr*)rhs)->Typespec(rt);
                        pendingSysFuncTs.push_back(
                            {rt, defInfo->mod, &le.as<NamedValueExpression>().symbol});
                    }
                }
            }
        }
        // Re-emitted pattern RHS leaves an orphan first-compile op behind
        // (materialized at the very end of the write phase). A pattern that
        // FOLDS to a constant leaves no orphan.
        if (topView && defInfo && myIdx < defInfo->contAssigns.size() && rhs &&
            rhs->UhdmType() != UHDM::uhdmconstant) {
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
        NetMap& lhsMap = (topView && shareWithDef &&
                          (literalRhs || bitsRhs || cfr || callFold || ovParamRhs ||
                           typedParamRhs || constVarRhs || noDefOvRhs) &&
                          defInfo)
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
        instSetContAssigns(m, cas);
}


void UhdmExporter::drainFuncRet(bool pkgOnly) {
    for (auto& pf : pendingFuncRet) {
        auto& sub = *pf.sub;
        if (pkgOnly && !pf.inst)
            continue;
        if (pf.refs.empty() || !sub.returnValVar || sub.getReturnType().isVoid())
            continue;
        for (auto* r : pf.refs) {
            // The local's fullname mirrors the binding ref's scope (named
            // blocks included).
            std::string localFull(r->VpiFullName());
            if (localFull.empty())
                localFull = pf.fullName + "." + std::string(sub.name);
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
            if (pf.inst)
                ts->Instance(pf.inst);
            lv->Typespec(rt);
            lv->VpiLineNo(ts->VpiLineNo());
            lv->VpiColumnNo(ts->VpiColumnNo());
            lv->VpiEndLineNo(ts->VpiEndLineNo());
            lv->VpiEndColumnNo(ts->VpiEndColumnNo());
            r->Actual_group(lv);
        }
        pf.refs.clear(); // processed
    }
    if (!pkgOnly)
        pendingFuncRet.clear();
}


// Single-expression constant reduction: literal, package-param ref (value =
// the param's literal, loc anchor = the ref site), or a reducible call.
UhdmExporter::CallFold UhdmExporter::resolveConstExpr(const Expression& e) {
    CallFold r;
    auto& l = stripImplicitConv(e);
    if (l.kind == ExpressionKind::IntegerLiteral) {
        r.lit = &l;
        return r;
    }
    if (l.kind == ExpressionKind::NamedValue) {
        auto& sym = l.as<NamedValueExpression>().symbol;
        if (sym.kind == SymbolKind::Parameter) {
            auto sc = sym.getParentScope();
            if (sc && sc->asSymbol().kind == SymbolKind::Package) {
                auto& ps = sym.as<ParameterSymbol>();
                if (auto* init = ps.getInitializer()) {
                    auto& il = stripImplicitConv(*init);
                    if (il.kind == ExpressionKind::IntegerLiteral) {
                        r.lit = &il;
                        r.param = &ps;
                        r.site = &l;
                    }
                }
            }
        }
        return r;
    }
    if (l.kind == ExpressionKind::Call)
        return constCallFold(l);
    return r;
}

// What an argument-less user call reduces to via straight-line execution
// (nested calls followed, local-var literal values tracked).
UhdmExporter::CallFold UhdmExporter::constCallFold(const Expression& expr) {
    CallFold none;
    if (expr.kind != ExpressionKind::Call || expr.as<CallExpression>().isSystemCall())
        return none;
    auto& call = expr.as<CallExpression>();
    auto subp = std::get_if<const SubroutineSymbol*>(&call.subroutine);
    if (!subp)
        return none;
    std::map<const Symbol*, CallFold> env;
    // Formals bound to assignment patterns of literals (element-select
    // resolution follows the selected element back to its source literal).
    std::map<const Symbol*, const Expression*> patEnv;
    {
        auto formals = (*subp)->getArguments();
        auto args = call.arguments();
        if (!args.empty()) {
            if (args.size() != formals.size())
                return none;
            for (size_t i = 0; i < args.size(); i++) {
                auto& al = stripImplicitConv(*args[i]);
                if (al.kind == ExpressionKind::IntegerLiteral) {
                    CallFold f;
                    f.lit = &al;
                    env[formals[i]] = f;
                }
                else if (al.kind == ExpressionKind::SimpleAssignmentPattern) {
                    bool allLit = true;
                    for (auto* el :
                         al.as<SimpleAssignmentPatternExpression>().elements())
                        if (stripImplicitConv(*el).kind !=
                            ExpressionKind::IntegerLiteral)
                            allLit = false;
                    if (!allLit)
                        return none;
                    patEnv[formals[i]] = &al;
                }
                else
                    return none;
            }
        }
    }
    auto resolve = [&](const Expression& e) -> CallFold {
        auto& l = stripImplicitConv(e);
        if (l.kind == ExpressionKind::NamedValue) {
            auto it = env.find(&l.as<NamedValueExpression>().symbol);
            if (it != env.end())
                return it->second;
        }
        if (l.kind == ExpressionKind::ElementSelect) {
            auto& es = l.as<ElementSelectExpression>();
            auto& base = stripImplicitConv(es.value());
            auto& sel = stripImplicitConv(es.selector());
            if (base.kind == ExpressionKind::NamedValue &&
                sel.kind == ExpressionKind::IntegerLiteral) {
                auto pit = patEnv.find(&base.as<NamedValueExpression>().symbol);
                if (pit != patEnv.end()) {
                    auto elems =
                        pit->second->as<SimpleAssignmentPatternExpression>()
                            .elements();
                    auto idx = sel.as<IntegerLiteral>().getValue().as<uint64_t>();
                    if (idx && *idx < elems.size()) {
                        CallFold f;
                        f.lit = &stripImplicitConv(*elems[*idx]);
                        return f;
                    }
                }
            }
        }
        return resolveConstExpr(l);
    };
    std::function<CallFold(const Statement&)> findFold =
        [&](const Statement& st) -> CallFold {
        if (st.kind == StatementKind::Return) {
            if (auto* e = st.as<ReturnStatement>().expr) {
                CallFold v = resolve(*e);
                v.terminal = true; // an executed return stops the function
                return v;
            }
            return CallFold{};
        }
        if (st.kind == StatementKind::ExpressionStatement) {
            auto& e = st.as<ExpressionStatement>().expr;
            if (e.kind == ExpressionKind::Assignment) {
                auto& ae2 = e.as<AssignmentExpression>();
                auto& lc = stripImplicitConv(ae2.left());
                if (lc.kind == ExpressionKind::NamedValue) {
                    auto& sym = lc.as<NamedValueExpression>().symbol;
                    CallFold val = resolve(ae2.right());
                    if (&sym == (*subp)->returnValVar)
                        return val; // funcname= sets the value; not terminal
                    env[&sym] = val; // empty poisons
                    return CallFold{};
                }
            }
            return CallFold{};
        }
        if (st.kind == StatementKind::List) {
            // Straight-line: an executed return (terminal) wins immediately;
            // assignments to the return var accumulate.
            CallFold acc;
            for (auto* item : st.as<StatementList>().list) {
                if (item->kind == StatementKind::VariableDeclaration) {
                    auto& vs = item->as<VariableDeclStatement>().symbol;
                    if (auto* init = vs.getDeclaredType()->getInitializer())
                        env[&vs] = resolve(*init);
                    continue;
                }
                CallFold f = findFold(*item);
                if (f.terminal)
                    return f;
                if (f)
                    acc = f;
            }
            return acc;
        }
        if (st.kind == StatementKind::Block)
            return findFold(st.as<BlockStatement>().body);
        if (st.kind == StatementKind::ForLoop) {
            // A search loop that returns on its first iteration folds to that
            // return (straight-line, one iteration). Loops whose body has no
            // return can't be reduced this way.
            std::function<bool(const Statement&)> hasReturn =
                [&](const Statement& s2) -> bool {
                if (s2.kind == StatementKind::Return)
                    return true;
                if (s2.kind == StatementKind::List) {
                    for (auto* it2 : s2.as<StatementList>().list)
                        if (hasReturn(*it2))
                            return true;
                    return false;
                }
                if (s2.kind == StatementKind::Block)
                    return hasReturn(s2.as<BlockStatement>().body);
                if (s2.kind == StatementKind::ForLoop)
                    return hasReturn(s2.as<ForLoopStatement>().body);
                return false;
            };
            auto& fl = st.as<ForLoopStatement>();
            if (hasReturn(fl.body)) {
                CallFold f = findFold(fl.body);
                f.terminal = true; // the loop body executed a return
                return f;
            }
            return CallFold{};
        }
        return CallFold{};
    };
    CallFold r = findFold((*subp)->getBody());
    if (r)
        r.directSub = *subp;
    return r;
}

UHDM::concurrent_assertions* UhdmExporter::emitAssertion(const ProceduralBlockSymbol& pb,
                                                         UHDM::module_inst* m,
                                                         const std::string& prefix,
                                                         NetMap& netMap) {
    auto syn = pb.getSyntax();
    if (!syn || syn->kind != syntax::SyntaxKind::ConcurrentAssertionMember)
        return nullptr;
    auto& pbBody = pb.getBody();
    std::string label;
    const Statement* inner = &pbBody;
    if (pbBody.kind == StatementKind::Block) {
        if (auto* bs = pbBody.as<BlockStatement>().blockSymbol)
            label = std::string(bs->name);
        inner = &pbBody.as<BlockStatement>().body;
    }
    if (inner->kind == StatementKind::List && !inner->as<StatementList>().list.empty())
        inner = inner->as<StatementList>().list[0];
    if (inner->kind != StatementKind::ConcurrentAssertion)
        return nullptr;
    auto& ca = inner->as<ConcurrentAssertionStatement>();

    std::string aprefix = label.empty() ? prefix : prefix + "." + label;
    UHDM::concurrent_assertions* as = nullptr;
    switch (ca.assertionKind) {
        case AssertionKind::Assert:
            as = s.MakeAssert_stmt();
            break;
        case AssertionKind::Assume:
            as = s.MakeAssume();
            break;
        case AssertionKind::CoverProperty:
        case AssertionKind::CoverSequence:
            as = s.MakeCover();
            break;
        case AssertionKind::Restrict:
            as = s.MakeRestrict();
            break;
        default:
            noteUnsupported("assertion kind: " + std::string(toString(ca.assertionKind)));
            return nullptr;
    }
    if (!label.empty())
        as->VpiName(label);
    as->VpiFullName(aprefix);
    as->VpiParent(m);
    setLoc(as, SourceRange(inner->sourceRange.start(),
                           inner->sourceRange.end() -
                               basedLiteralSpaceCount(rawText(inner->sourceRange))));

    // Else action -> vpiStmt.
    if (ca.ifFalse)
        if (auto* st = emitStmt(*ca.ifFalse, as, aprefix, netMap))
            as->Stmt(st);

    // Property spec. An `assert` WITH an explicit clocking event keeps ONLY
    // the clocking op as VpiPropertyExpr (Surelog drops the body). Otherwise
    // (assume/cover, or no clocking) the clocking (if any) becomes
    // VpiClockingEvent and the body is emitted as VpiPropertyExpr.
    auto* ps = s.MakeProperty_spec();
    ps->VpiParent(as);
    // The property_spec span is the WHOLE property (incl. clocking).
    if (ca.propertySpec.syntax) {
        auto pr = ca.propertySpec.syntax->sourceRange();
        setLoc(ps, SourceRange(pr.start(),
                               pr.end() - basedLiteralSpaceCount(rawText(pr))));
    }
    const AssertionExpr* pe = &ca.propertySpec;
    const TimingControl* clocking = nullptr;
    if (pe->kind == AssertionExprKind::Clocking) {
        clocking = &pe->as<ClockingAssertionExpr>().clocking;
        pe = &pe->as<ClockingAssertionExpr>().expr;
    }
    bool isAssert = ca.assertionKind == AssertionKind::Assert;
    if (isAssert && clocking) {
        if (auto* clk = emitEventExpr(*clocking, ps, aprefix, netMap))
            ps->VpiPropertyExpr(clk);
    }
    else {
        if (clocking)
            if (auto* clk = emitEventExpr(*clocking, ps, aprefix, netMap))
                ps->VpiClockingEvent((UHDM::expr*)clk);
        if (auto* body = emitAssertionExpr(*pe, ps, aprefix, netMap))
            ps->VpiPropertyExpr(body);
    }
    as->VpiProperty(ps);
    return as;
}

static int32_t mapAssertBinOp(slang::ast::BinaryAssertionOperator op) {
    using O = slang::ast::BinaryAssertionOperator;
    switch (op) {
        case O::OverlappedImplication: return vpiOverlapImplyOp;
        case O::NonOverlappedImplication: return vpiNonOverlapImplyOp;
        case O::Implies: return vpiImpliesOp;
        case O::Until: return vpiUntilOp;
        case O::SUntil: return vpiUntilOp;
        case O::UntilWith: return vpiUntilWithOp;
        case O::SUntilWith: return vpiUntilWithOp;
        case O::Intersect: return vpiIntersectOp;
        case O::Throughout: return vpiThroughoutOp;
        case O::Within: return vpiWithinOp;
        case O::Iff: return vpiIffOp;
        case O::OverlappedFollowedBy: return vpiOverlapFollowedByOp;
        case O::NonOverlappedFollowedBy: return vpiNonOverlapFollowedByOp;
        case O::And: return vpiCompAndOp;
        case O::Or: return vpiCompOrOp;
        default: return 0;
    }
}

static int32_t mapAssertUnaryOp(slang::ast::UnaryAssertionOperator op) {
    using O = slang::ast::UnaryAssertionOperator;
    switch (op) {
        // Surelog encodes property `not` as opType 15 (matches its output).
        case O::Not: return 15;
        case O::NextTime: return vpiNexttimeOp;
        case O::SNextTime: return vpiNexttimeOp;
        case O::Always: return vpiAlwaysOp;
        case O::SAlways: return vpiAlwaysOp;
        case O::Eventually: return vpiEventuallyOp;
        case O::SEventually: return vpiEventuallyOp;
        default: return 0;
    }
}

UHDM::clocking_block* UhdmExporter::emitDefaultClocking(const InstanceBodySymbol& body,
                                                        UHDM::module_inst* m,
                                                        const std::string& prefix,
                                                        NetMap& netMap) {
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::ClockingBlock)
            continue;
        auto& cbs = member.as<ClockingBlockSymbol>();
        auto csyn = cbs.getSyntax();
        if (!csyn || csyn->kind != syntax::SyntaxKind::ClockingDeclaration)
            continue;
        auto& cdecl = csyn->as<syntax::ClockingDeclarationSyntax>();
        if (cdecl.globalOrDefault.valueText() != "default")
            continue;
        std::string cbName = cbs.name.empty() ? "unnamed_clocking_block"
                                              : std::string(cbs.name);
        std::string cbFull = prefix + "." + cbName;
        auto* cb = s.MakeClocking_block();
        cb->VpiName(cbName);
        cb->VpiFullName(cbFull);
        cb->VpiParent(m);
        setLoc(cb, csyn->sourceRange());
        auto* ec = s.MakeEvent_control();
        ec->VpiParent(cb);
        setLoc(ec, SourceRange(cdecl.at.range().start(), cdecl.event->sourceRange().end()));
        if (auto* cond = emitEventExpr(cbs.getEvent(), ec, cbFull, netMap))
            ec->VpiCondition(cond);
        cb->Clocking_event(ec);
        m->Default_clocking(cb);
        return cb;
    }
    return nullptr;
}

void UhdmExporter::setLocCompact(UHDM::BaseClass* obj, SourceRange range) {
    setLoc(obj, SourceRange(range.start(),
                            range.end() - basedLiteralSpaceCount(rawText(range))));
}

UHDM::any* UhdmExporter::emitAssertionExpr(const AssertionExpr& ae, UHDM::BaseClass* parent,
                                           const std::string& prefix, NetMap& netMap) {
    switch (ae.kind) {
        case AssertionExprKind::Simple: {
            auto& sae = ae.as<SimpleAssertionExpr>();
            // A repeated sequence's operand keeps the PROPERTY_SPEC as its
            // parent (Surelog builds it in the spec context before wrapping).
            UHDM::BaseClass* innerParent = parent;
            if (sae.repetition)
                for (UHDM::BaseClass* w = parent; w;
                     w = (UHDM::BaseClass*)w->VpiParent())
                    if (w->UhdmType() == UHDM::uhdmproperty_spec) {
                        innerParent = w;
                        break;
                    }
            UHDM::any* inner = emitExpr(sae.expr, innerParent, prefix, netMap);
            if (!sae.repetition || !inner)
                return inner;
            // seq [*N] -> repeat operation [seq, count]; the seq operand keeps
            // the OUTER parent (Surelog builds it before wrapping).
            auto* op = s.MakeOperation();
            op->VpiOpType(sae.repetition->kind == SequenceRepetition::Consecutive
                              ? vpiConsecutiveRepeatOp
                          : sae.repetition->kind == SequenceRepetition::GoTo
                              ? vpiGotoRepeatOp
                              : vpiRepeatOp);
            op->VpiParent(parent);
            if (ae.syntax)
                setLoc(op, ae.syntax->sourceRange());
            auto* operands = s.MakeAnyVec();
            operands->push_back(inner);
            const syntax::ExpressionSyntax* cntSyn = nullptr;
            if (ae.syntax && ae.syntax->kind == syntax::SyntaxKind::SimpleSequenceExpr) {
                auto* rep = ae.syntax->as<syntax::SimpleSequenceExprSyntax>().repetition;
                if (rep && rep->selector &&
                    rep->selector->kind == syntax::SyntaxKind::BitSelect)
                    cntSyn = rep->selector->as<syntax::BitSelectSyntax>().expr;
            }
            if (cntSyn) {
                UHDM::any* cnt = nullptr;
                if (propDeclScope && cntSyn->kind == syntax::SyntaxKind::IdentifierName)
                    cnt = emitPropFormalRef(
                        cntSyn->as<syntax::IdentifierNameSyntax>().identifier.valueText(),
                        cntSyn->sourceRange(), op, prefix);
                if (!cnt)
                    cnt = emitSyntaxExpr(*cntSyn, op);
                if (cnt) {
                    // Literal repeat counts stay unparented.
                    if (cnt->UhdmType() == UHDM::uhdmconstant)
                        cnt->VpiParent(nullptr);
                    operands->push_back(cnt);
                }
            }
            op->Operands(operands);
            return op;
        }
        case AssertionExprKind::Clocking:
            return emitAssertionExpr(ae.as<ClockingAssertionExpr>().expr, parent, prefix,
                                     netMap);
        case AssertionExprKind::Binary: {
            auto& bae = ae.as<BinaryAssertionExpr>();
            int32_t opt = mapAssertBinOp(bae.op);
            if (!opt) {
                noteUnsupported("assertion binary op");
                return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opt);
            op->VpiParent(parent);
            if (ae.syntax)
                setLocCompact(op, ae.syntax->sourceRange());
            auto* operands = s.MakeAnyVec();
            // Surelog builds `throughout`'s left operand in the enclosing
            // context, so it keeps the grandparent as its vpiParent.
            UHDM::BaseClass* leftParent =
                (bae.op == BinaryAssertionOperator::Throughout) ? parent : op;
            if (auto* l = emitAssertionExpr(bae.left, leftParent, prefix, netMap))
                operands->push_back(l);
            if (auto* r = emitAssertionExpr(bae.right, op, prefix, netMap))
                operands->push_back(r);
            op->Operands(operands);
            return op;
        }
        case AssertionExprKind::Unary: {
            auto& uae = ae.as<UnaryAssertionExpr>();
            int32_t opt = mapAssertUnaryOp(uae.op);
            if (!opt) {
                noteUnsupported("assertion unary op");
                return nullptr;
            }
            auto* op = s.MakeOperation();
            op->VpiOpType(opt);
            op->VpiParent(parent);
            if (ae.syntax)
                setLoc(op, ae.syntax->sourceRange());
            auto* operands = s.MakeAnyVec();
            if (auto* e = emitAssertionExpr(uae.expr, op, prefix, netMap))
                operands->push_back(e);
            op->Operands(operands);
            return op;
        }
        case AssertionExprKind::SequenceConcat: {
            // a ##N b ##M c -> operation(##) with operands
            // [a, N, b, M, c] (delay constants between elements).
            auto& sc = ae.as<SequenceConcatExpr>();
            auto* op = s.MakeOperation();
            op->VpiOpType(vpiCycleDelayOp);
            op->VpiParent(parent);
            // Span the elements themselves (Surelog strips enclosing parens).
            if (!sc.elements.empty() && sc.elements.front().sequence->syntax &&
                sc.elements.back().sequence->syntax)
                setLoc(op, SourceRange(
                              sc.elements.front().sequence->syntax->sourceRange().start(),
                              sc.elements.back().sequence->syntax->sourceRange().end()));
            else if (ae.syntax)
                setLoc(op, ae.syntax->sourceRange());
            auto* operands = s.MakeAnyVec();
            bool first = true;
            for (auto& el : sc.elements) {
                if (!first || el.delay.min != 0) {
                    auto* c = s.MakeConstant();
                    std::string d = std::to_string(el.delay.min);
                    c->VpiDecompile(d);
                    c->VpiSize(64);
                    c->VpiValue("UINT:" + d);
                    c->VpiConstType(vpiUIntConst);
                    // The delay constant spans the "##N" token, not just N.
                    if (el.delayRange.start() != SourceLocation::NoLocation)
                        setLoc(c, SourceRange(el.delayRange.start() - 2, el.delayRange.end()));
                    operands->push_back(c);
                }
                if (auto* e = emitAssertionExpr(*el.sequence, op, prefix, netMap))
                    operands->push_back(e);
                first = false;
            }
            op->Operands(operands);
            return op;
        }
        default:
            noteUnsupported("assertion expr kind: " + std::string(toString(ae.kind)));
            return nullptr;
    }
}

// --- Interfaces -------------------------------------------------------------
// Interfaces are emitted as interface_inst (design->AllInterfaces). Their
// content mirrors a module: the DEF view emits declared signals as logic_nets;
// the ELAB view emits them as variables with initializers. A parent module
// references the def via a ref_module (Actual->interface_inst) and the elab
// instance via Interfaces() (vpiInterface).

UHDM::interface_typespec* UhdmExporter::makeIfacePortTs(const InterfacePortSymbol& ip) {
    auto* its = s.MakeInterface_typespec();
    its->VpiName(ip.modport.empty() ? ip.name : ip.modport);
    const syntax::InterfacePortHeaderSyntax* iph = nullptr;
    const syntax::DataTypeSyntax* vdt = nullptr;
    for (auto sy = ip.getSyntax(); sy; sy = sy->parent) {
        if (sy->kind == syntax::SyntaxKind::InterfacePortHeader) {
            iph = &sy->as<syntax::InterfacePortHeaderSyntax>();
            break;
        }
        if (sy->kind == syntax::SyntaxKind::ImplicitAnsiPort) {
            const syntax::PortHeaderSyntax* h =
                sy->as<syntax::ImplicitAnsiPortSyntax>().header;
            if (h && h->kind == syntax::SyntaxKind::InterfacePortHeader)
                iph = &h->as<syntax::InterfacePortHeaderSyntax>();
            // A plain interface-typed port (sim_sram_if ss_if) parses as a
            // VariablePortHeader (the parser can't see the interface).
            else if (h && h->kind == syntax::SyntaxKind::VariablePortHeader)
                vdt = h->as<syntax::VariablePortHeaderSyntax>().dataType;
            break;
        }
    }
    if (iph && iph->modport) {
        its->VpiIsModPort(true);
        setLoc(its, iph->modport->member.range());
        auto* baseTs = s.MakeInterface_typespec();
        baseTs->VpiName(iph->nameOrKeyword.valueText());
        setLoc(baseTs, iph->nameOrKeyword.range());
        its->VpiParent(baseTs);
    }
    else if (iph) {
        // A plain interface port (sim_sram_if ss_if): the typespec is NAMED
        // by the interface TYPE, located at its keyword token.
        its->VpiName(iph->nameOrKeyword.valueText());
        setLoc(its, iph->nameOrKeyword.range());
    }
    else if (vdt && ip.interfaceDef) {
        its->VpiName(ip.interfaceDef->name);
        setLoc(its, vdt->sourceRange());
    }
    return its;
}

UHDM::interface_inst* UhdmExporter::emitInterfaceDef(const InstanceSymbol& inst) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    std::string prefix = "work@" + std::string(def.name);
    auto* iface = ifaceDefMap[&def];
    DefInfo& info = defMap[&def];
    currentScope = &body;
    iface->VpiDefName(prefix);
    iface->VpiFullName(prefix);
    iface->VpiParent(d);
    iface->VpiFile(fullFilePath(def.location));
    if (auto syn = body.getSyntax())
        setLoc(iface, syn->sourceRange());

    emitParameters(body, iface, prefix, info.nets, /*topView=*/false, &info, false);

    auto* nets = s.MakeNetVec();
    for (auto& it : collectNetOrder(body)) {
        std::string name(it.sym->name);
        auto* n = s.MakeLogic_net();
        n->VpiName(name);
        n->VpiFullName(prefix + "." + name);
        n->VpiParent(iface);
        setLoc(n, nameSpan(it.sym->location, it.sym->name));
        if (int32_t nt = netTypeFor(*it.sym))
            n->VpiNetType(nt);
        // A struct-typed interface VARIABLE (p::req_t req) nets as a wire.
        else if (it.sym->kind == SymbolKind::Variable && it.sym->getDeclaredType() &&
                 it.sym->getDeclaredType()->getType().getCanonicalType().isStruct())
            n->VpiNetType(vpiWire);
        bool implicitNet = it.sym->kind == SymbolKind::Net &&
                           it.sym->as<NetSymbol>().isImplicit;
        if (!it.port && !implicitNet) {
            // Deferred to the write phase (Surelog arena order), which also
            // extends the span through an initializer.
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(prefix + "." + name);
            rt->VpiParent(n);
            n->Typespec(rt);
            pendingNetTs.push_back({it.sym, rt, &info});
        }
        // Record the def net so def-view port LowConns can bind to it.
        info.nets[it.sym] = n;
        nets->push_back(n);
    }
    if (!nets->empty())
        iface->Nets(nets);

    // Def-view cont-assigns and ports (LowConn only) reuse the shared helpers.
    // Processes are emitted once in the ELAB view and shared here (Surelog
    // folds a single process object into both interface_inst views).
    emitContAssigns(body, iface, prefix, info.nets, /*topView=*/false, &info, false, nullptr,
                    nullptr);

    // Modports: name + one io_decl (direction + name) per modport port.
    auto* mports = s.MakeModportVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Modport)
            continue;
        auto& mp = member.as<ModportSymbol>();
        auto* umod = s.MakeModport();
        umod->VpiName(mp.name);
        umod->VpiParent(iface);
        setLocNamed(umod, mp);
        auto* iodecls = s.MakeIo_declVec();
        for (auto& pm : mp.members()) {
            if (pm.kind != SymbolKind::ModportPort)
                continue;
            auto& mpp = pm.as<ModportPortSymbol>();
            auto* io = s.MakeIo_decl();
            io->VpiName(mpp.name);
            io->VpiParent(umod);
            setLocNamed(io, mpp);
            int32_t dir = mpp.direction == ArgumentDirection::In    ? vpiInput
                          : mpp.direction == ArgumentDirection::Out ? vpiOutput
                          : mpp.direction == ArgumentDirection::InOut ? vpiInout
                                                                      : 0;
            if (dir)
                io->VpiDirection(dir);
            iodecls->push_back(io);
        }
        if (!iodecls->empty())
            umod->Io_decls(iodecls);
        modportsByDef[&def][std::string(mp.name)] = umod;
        mports->push_back(umod);
    }
    if (!mports->empty())
        iface->Modports(mports);

    emitPorts(body, iface, prefix, info.nets, /*topView=*/false, &info.defTs);
    emitImportArtifacts(body, iface);
    return iface;
}

// Surelog emits, for each interface instance, a reference-style COPY of the
// interface_inst placed at column 0 of the instance line. It shares the home
// view's variable objects and its own modport self-references it. It is only
// ever weakly referenced (from a receiving module port's HighConn ref_obj), so
// the dumper lists it in its weaklyReferenced tail. This object is SEMANTICALLY
// REDUNDANT (a dump artifact) — kept only to be byte/reference identical with
// Surelog's folded UHDM. A future `--no-surelog-tail-dups` switch (default off)
// can skip makeIfaceRefDup + the HighConn redirect entirely.
UHDM::interface_inst* UhdmExporter::makeIfaceRefDup(const InstanceSymbol& inst,
                                                    const std::string& path,
                                                    UHDM::module_inst* parentM,
                                                    NetMap& sharedNets,
                                                    UHDM::interface_inst* dup0,
                                                    UHDM::interface_inst* home) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    auto* dup = dup0 ? dup0 : s.MakeInterface_inst();
    dup->VpiDefName("work@" + std::string(def.name));
    dup->VpiName(inst.name);
    dup->VpiFullName(path);
    dup->VpiParent(parentM);
    // Column 0 of the instance statement line; reference-style (no endln,
    // no Instance/DefFile/DefLineNo).
    if (auto syn = inst.getSyntax()) {
        const syntax::SyntaxNode* stmtSyn = syn;
        while (stmtSyn->parent &&
               stmtSyn->kind != syntax::SyntaxKind::HierarchyInstantiation)
            stmtSyn = stmtSyn->parent;
        auto sr = stmtSyn->sourceRange();
        dup->VpiFile(fullFilePath(sr.start()));
        dup->VpiLineNo((int32_t)sm->getLineNumber(sr.start()));
        dup->VpiColumnNo(0);
    }

    // Shares the home view's variable objects (shown shallow in the tail dump).
    auto* vars = s.MakeVariablesVec();
    for (auto& it : collectNetOrder(body))
        if (auto nit = sharedNets.find(it.sym); nit != sharedNets.end())
            vars->push_back((UHDM::variables*)nit->second);
    if (!vars->empty())
        dup->Variables(vars);

    // The dup carries its OWN default-valued parameter objects (fresh ts
    // refs, drained with the others) and SHARES the home view's
    // param_assign objects.
    if (home && home->Parameters()) {
        auto* dparams = s.MakeAnyVec();
        for (auto* hp0 : *home->Parameters()) {
            auto* hp = (UHDM::parameter*)hp0;
            const ParameterSymbol* psym = nullptr;
            for (auto& mb2 : inst.body.members())
                if (mb2.kind == SymbolKind::Parameter && mb2.name == hp->VpiName())
                    psym = &mb2.as<ParameterSymbol>();
            auto* p2 = s.MakeParameter();
            p2->VpiName(hp->VpiName());
            p2->VpiFullName(hp->VpiFullName());
            p2->VpiParent(dup);
            p2->VpiValue(std::string(hp->VpiValue()));
            p2->VpiLineNo(hp->VpiLineNo());
            p2->VpiColumnNo(hp->VpiColumnNo());
            p2->VpiEndLineNo(hp->VpiEndLineNo());
            p2->VpiEndColumnNo(hp->VpiEndColumnNo());
            if (hp->VpiLocalParam())
                p2->VpiLocalParam(true);
            if (psym && hp->Typespec()) {
                auto* prt2 = s.MakeRef_typespec();
                prt2->VpiFullName(std::string(hp->Typespec()->VpiFullName()));
                prt2->VpiParent(p2);
                p2->Typespec(prt2);
                bool typedP = false;
                if (auto d0 = psym->getDeclaredType())
                    if (auto t0 = d0->getTypeSyntax())
                        typedP = t0->kind != syntax::SyntaxKind::ImplicitType;
                pendingParamTs.push_back({psym, p2, prt2, nullptr, typedP});
            }
            dparams->push_back(p2);
        }
        if (!dparams->empty())
            dup->Parameters(dparams);
        if (home->Param_assigns()) {
            auto* dpas = s.MakeParam_assignVec();
            for (auto* pa0 : *home->Param_assigns())
                dpas->push_back(pa0);
            dup->Param_assigns(dpas);
        }
    }

    auto* mports = s.MakeModportVec();
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::Modport)
            continue;
        auto& mp = member.as<ModportSymbol>();
        auto* dm = s.MakeModport();
        dm->VpiName(mp.name);
        dm->VpiParent(dup);
        setLocNamed(dm, mp);
        auto* iodecls = s.MakeIo_declVec();
        for (auto& pm : mp.members()) {
            if (pm.kind != SymbolKind::ModportPort)
                continue;
            auto& mpp = pm.as<ModportPortSymbol>();
            auto* io = s.MakeIo_decl();
            io->VpiName(mpp.name);
            io->VpiParent(dm);
            setLocNamed(io, mpp);
            int32_t dir = mpp.direction == ArgumentDirection::In    ? vpiInput
                          : mpp.direction == ArgumentDirection::Out ? vpiOutput
                          : mpp.direction == ArgumentDirection::InOut ? vpiInout
                                                                      : 0;
            if (dir)
                io->VpiDirection(dir);
            if (auto nit = sharedNets.find(mpp.internalSymbol);
                nit != sharedNets.end())
                io->Expr((UHDM::expr*)nit->second);
            iodecls->push_back(io);
        }
        if (!iodecls->empty())
            dm->Io_decls(iodecls);
        dm->Interface_inst(dup);  // self-reference
        mports->push_back(dm);
    }
    if (!mports->empty())
        dup->Modports(mports);
    return dup;
}

UHDM::interface_inst* UhdmExporter::emitInterfaceInstance(const InstanceSymbol& inst,
                                                          const std::string& path,
                                                          UHDM::module_inst* parentM,
                                                          NetMap* parentNets,
                                                          std::set<const Symbol*>* parentRefs,
                                                          const InstanceSymbol* portView) {
    auto& body = inst.body;
    auto& def = inst.getDefinition();
    std::string prefix = path;
    std::string defPrefix = "work@" + std::string(def.name);
    currentScope = &body;
    auto* iface = s.MakeInterface_inst();
    iface->VpiDefName(defPrefix);
    iface->VpiName(inst.name);
    iface->VpiFullName(prefix);
    iface->VpiParent(parentM);
    iface->VpiFile(fullFilePath(def.location));
    // Declaration-style (home) views carry Instance/DefFile/DefLineNo; a
    // reference-style port view (work@top.m0.bus, col 0) omits them.
    if (!portView) {
        iface->Instance(parentM);
        iface->VpiDefFile(fullFilePath(def.location));
        iface->VpiDefLineNo((int32_t)sm->getLineNumber(def.location));
        if (auto syn = inst.getSyntax()) {
            const syntax::SyntaxNode* stmtSyn = syn;
            while (stmtSyn->parent &&
                   stmtSyn->kind != syntax::SyntaxKind::HierarchyInstantiation)
                stmtSyn = stmtSyn->parent;
            setLoc(iface, stmtSyn->sourceRange());
        }
    }
    else {
        // Located at the receiving instance's instantiation line, column 0.
        if (auto syn = portView->getSyntax()) {
            const syntax::SyntaxNode* stmtSyn = syn;
            while (stmtSyn->parent &&
                   stmtSyn->kind != syntax::SyntaxKind::HierarchyInstantiation)
                stmtSyn = stmtSyn->parent;
            auto sr = stmtSyn->sourceRange();
            iface->VpiFile(fullFilePath(sr.start()));
            iface->VpiLineNo((int32_t)sm->getLineNumber(sr.start()));
            iface->VpiColumnNo(0);
        }
    }

    NetMap netMap;
    {
        auto pit = defMap.find(&def);
        emitParameters(body, iface, prefix, netMap, /*topView=*/true,
                       pit != defMap.end() ? &pit->second : nullptr, false);
    }
    // A PORT VIEW lists each parameter TWICE at its DEFAULT value and
    // carries NO param_assigns (Surelog quirk).
    if (portView && iface->Parameters()) {
        iface->Param_assigns(nullptr);
        auto* plist = iface->Parameters();
        size_t n0 = plist->size();
        for (size_t i = 0; i < n0; i++) {
            auto* p0 = (UHDM::parameter*)(*plist)[i];
            const ParameterSymbol* psym = nullptr;
            for (auto& mb2 : body.members())
                if (mb2.kind == SymbolKind::Parameter && mb2.name == p0->VpiName())
                    psym = &mb2.as<ParameterSymbol>();
            auto* p2 = s.MakeParameter();
            p2->VpiName(p0->VpiName());
            p2->VpiFullName(p0->VpiFullName());
            p2->VpiParent(iface);
            p2->VpiValue(std::string(p0->VpiValue()));
            p2->VpiLineNo(p0->VpiLineNo());
            p2->VpiColumnNo(p0->VpiColumnNo());
            p2->VpiEndLineNo(p0->VpiEndLineNo());
            p2->VpiEndColumnNo(p0->VpiEndColumnNo());
            if (p0->VpiLocalParam())
                p2->VpiLocalParam(true);
            if (psym && p0->Typespec()) {
                auto* prt2 = s.MakeRef_typespec();
                prt2->VpiFullName(std::string(p0->Typespec()->VpiFullName()));
                prt2->VpiParent(p2);
                p2->Typespec(prt2);
                bool typedP = false;
                if (auto d0 = psym->getDeclaredType())
                    if (auto t0 = d0->getTypeSyntax())
                        typedP = t0->kind != syntax::SyntaxKind::ImplicitType;
                pendingParamTs.push_back({psym, p2, prt2, nullptr, typedP});
            }
            plist->push_back(p2);
        }
    }
    // The col-0 tail duplicate's arena slot precedes the variables'
    // typespecs (Surelog creation order); its content fills in at the end.
    bool wantTailDup = false;
    if (!portView) {
        if (auto* psc = inst.getParentScope()) {
            for (auto& sib : psc->members()) {
                if (sib.kind != SymbolKind::Instance)
                    continue;
                auto& sibInst = sib.as<InstanceSymbol>();
                for (auto pb : sibInst.body.getPortList()) {
                    if (pb->kind != SymbolKind::InterfacePort)
                        continue;
                    if (pb->as<InterfacePortSymbol>().getConnection().first !=
                        (const Symbol*)&inst)
                        continue;
                    for (auto cc : sibInst.getPortConnections())
                        if (&cc->port == pb && connectionExpr(*cc) &&
                            rawText(connectionExpr(*cc)->sourceRange).find('.') ==
                                std::string::npos)
                            wantTailDup = true;
                }
            }
        }
    }
    UHDM::interface_inst* tailDupShell = wantTailDup ? s.MakeInterface_inst() : nullptr;
    // PORT-VIEW iface var bounds fold at the DEFAULT param values (Surelog
    // reads widths from the AllModules form, ignoring per-instance
    // overrides); the HOME view keeps the instance values.
    if (portView) {
        auto dit0 = ifaceDefaultInst.find(&def);
        if (dit0 == ifaceDefaultInst.end())
            dit0 = ifaceDefaultInst
                       .emplace(&def, &InstanceSymbol::createDefault(comp, def))
                       .first;
        ifaceDefaultScope = &dit0->second->body;
    }
    auto* vars = s.MakeVariablesVec();
    auto* elabNets = s.MakeNetVec();
    for (auto& it : collectNetOrder(body)) {
        std::string name(it.sym->name);
        std::string fullName = prefix + "." + name;
        // A struct-typed interface member is a struct_net (Nets, wire) in the
        // elab HOME view, its typespec ref sharing the typedef's
        // struct_typespec. PORT views carry it on the modport io_decl instead.
        if (it.sym->kind == SymbolKind::Variable && it.sym->getDeclaredType() &&
            it.sym->getDeclaredType()->getType().getCanonicalType().isStruct()) {
            if (portView)
                continue;
            auto* sn = s.MakeStruct_net();
            sn->VpiName(name);
            sn->VpiFullName(fullName);
            sn->VpiParent(iface);
            sn->VpiNetType(vpiWire);
            setLoc(sn, nameSpan(it.sym->location, it.sym->name));
            // The elab view shares the TOP-view package typedef typespec.
            UHDM::typespec* ts = nullptr;
            if (auto tt = pkgTopTypedefTs.find(&it.sym->getDeclaredType()->getType());
                tt != pkgTopTypedefTs.end())
                ts = tt->second;
            if (!ts)
                ts = makeTypespec(*it.sym);
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(fullName);
            rt->VpiParent(sn);
            rt->Actual_typespec(ts);
            sn->Typespec(rt);
            netMap[it.sym] = sn;
            elabNets->push_back(sn);
            continue;
        }
        auto* v = makeVar(*it.sym, /*portBacked=*/false);
        if (!v)
            continue;
        v->VpiName(name);
        v->VpiFullName(fullName);
        v->VpiParent(iface);
        setLoc(v, nameSpan(it.sym->location, it.sym->name));
        // Initialized vars span declarator..init.
        if (auto dt0 = it.sym->getDeclaredType(); dt0 && dt0->getInitializer())
            if (auto dsyn = it.sym->getSyntax()) {
                auto dr = dsyn->sourceRange();
                if (dr.start() != SourceLocation::NoLocation)
                    setLoc(v, dr);
            }
        auto* ts = makeTypespec(*it.sym);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(fullName);
        rt->VpiParent(v);
        rt->Actual_typespec(ts);
        v->Typespec(rt);
        if (ts->VpiName().empty())
            ts->VpiParent(v);
        if (auto dt = it.sym->getDeclaredType()) {
            if (auto init = dt->getInitializer()) {
                auto& ic = stripImplicitConv(*init);
                if (ic.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                    // '0/'1/'x/'z fold to the var width (Surelog quirk).
                    logic_t bit =
                        ic.as<UnbasedUnsizedIntegerLiteral>().getLiteralValue();
                    int32_t w = (int32_t)dt->getType().getBitWidth();
                    auto* c = s.MakeConstant();
                    if (bit.isUnknown()) {
                        std::string dd = bit.value == logic_t::X_VALUE ? "X" : "Z";
                        c->VpiDecompile("'" + dd);
                        c->VpiSize(-1);
                        c->VpiValue("BIN:" + dd);
                        c->VpiConstType(vpiBinaryConst);
                    }
                    else if (bit.value == 0) {
                        c->VpiDecompile("'0");
                        c->VpiSize(w);
                        c->VpiValue("BIN:0");
                        c->VpiConstType(vpiBinaryConst);
                    }
                    else {
                        slang::SVInt ones((slang::bitwidth_t)w, 0, false);
                        ones = ~ones;
                        std::string digits = ones.toString(LiteralBase::Decimal, false);
                        c->VpiDecompile(digits);
                        c->VpiSize(w);
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                    }
                    c->VpiParent(v);
                    setLoc(c, ic.sourceRange);
                    v->Expr(c);
                }
                else {
                    forceConstParent = true;
                    if (auto* e = emitExpr(*init, v, fullName, netMap))
                        v->Expr((UHDM::expr*)e);
                    forceConstParent = false;
                }
            }
        }
        netMap[it.sym] = v;
        vars->push_back(v);
    }
    ifaceDefaultScope = nullptr;
    if (!vars->empty())
        iface->Variables(vars);
    if (!elabNets->empty())
        iface->Nets(elabNets);

    // The elab HOME view lists the def view's typedef/import typespecs (SHARED
    // objects; the def view was emitted first). Port views don't.
    if (auto dIt = ifaceDefMap.find(&def);
        !portView && dIt != ifaceDefMap.end() && dIt->second->Typespecs()) {
        auto* tds2 = s.MakeTypespecVec();
        for (auto* t : *dIt->second->Typespecs())
            tds2->push_back(t);
        if (!tds2->empty())
            iface->Typespecs(tds2);
    }

    // Elab-view modports (fresh objects parented to this interface_inst). Each
    // modport's Interface_inst self-references this view. A reference-style port
    // view additionally carries a vpiExpr on each io_decl (pointing at this
    // view's variable); the declaration-style home view does not.
    {
        auto* mports = s.MakeModportVec();
        for (auto& member : body.members()) {
            if (member.kind != SymbolKind::Modport)
                continue;
            auto& mp = member.as<ModportSymbol>();
            auto* umod = s.MakeModport();
            umod->VpiName(mp.name);
            umod->VpiParent(iface);
            setLocNamed(umod, mp);
            auto* iodecls = s.MakeIo_declVec();
            for (auto& pm : mp.members()) {
                if (pm.kind != SymbolKind::ModportPort)
                    continue;
                auto& mpp = pm.as<ModportPortSymbol>();
                auto* io = s.MakeIo_decl();
                io->VpiName(mpp.name);
                io->VpiParent(umod);
                setLocNamed(io, mpp);
                int32_t dir = mpp.direction == ArgumentDirection::In    ? vpiInput
                              : mpp.direction == ArgumentDirection::Out ? vpiOutput
                              : mpp.direction == ArgumentDirection::InOut ? vpiInout
                                                                         : 0;
                if (dir)
                    io->VpiDirection(dir);
                if (portView) {
                    if (auto nit = netMap.find(mpp.internalSymbol);
                        nit != netMap.end())
                        io->Expr((UHDM::expr*)nit->second);
                    // Struct member: fresh struct_net parented at the io_decl,
                    // fullname doubled through the modport and the member
                    // (prefix.<modport>.<member>.<member> — Surelog quirk).
                    else if (mpp.internalSymbol &&
                             mpp.internalSymbol->getDeclaredType() &&
                             mpp.internalSymbol->getDeclaredType()
                                 ->getType()
                                 .getCanonicalType()
                                 .isStruct()) {
                        auto& msym = *mpp.internalSymbol;
                        std::string mname(msym.name);
                        std::string dfull = prefix + "." + std::string(mp.name) +
                                            "." + mname + "." + mname;
                        auto* sn2 = s.MakeStruct_net();
                        sn2->VpiName(mname);
                        sn2->VpiFullName(dfull);
                        sn2->VpiParent(io);
                        sn2->VpiNetType(vpiWire);
                        setLoc(sn2, nameSpan(msym.location, msym.name));
                        UHDM::typespec* mts = nullptr;
                        if (auto tt2 = pkgTopTypedefTs.find(
                                &msym.getDeclaredType()->getType());
                            tt2 != pkgTopTypedefTs.end())
                            mts = tt2->second;
                        if (!mts)
                            mts = makeTypespec(msym);
                        auto* mrt = s.MakeRef_typespec();
                        mrt->VpiFullName(dfull);
                        mrt->VpiParent(sn2);
                        mrt->Actual_typespec(mts);
                        sn2->Typespec(mrt);
                        io->Expr(sn2);
                    }
                }
                iodecls->push_back(io);
            }
            if (!iodecls->empty())
                umod->Io_decls(iodecls);
            umod->Interface_inst(iface);
            mports->push_back(umod);
        }
        if (!mports->empty())
            iface->Modports(mports);
    }

    // Home view: fill the col-0 tail duplicate (shares this view's vars) so a
    // receiving module port's HighConn ref_obj can weakly reference it — only
    // when some sibling child receives the WHOLE interface via a BARE
    // connection (.bus(bus)); modport-qualified connections (.mon(s.mon))
    // create neither the dup nor the weak ref.
    if (tailDupShell)
        ifaceTailDup[&inst] =
            makeIfaceRefDup(inst, prefix, parentM, netMap, tailDupShell, iface);

    // A single-instance interface's DEF cont-assign references resolve to THIS
    // instance's elab vars (Surelog quirk), not the def nets. Re-point them.
    if (auto dit = defMap.find(&def); dit != defMap.end()) {
        auto iit = ifaceDefMap.find(&def);
        if (iit != ifaceDefMap.end() && iit->second->Cont_assigns()) {
            std::map<const UHDM::any*, UHDM::any*> netToVar;
            for (auto& [sym, var] : netMap) {
                auto nit = dit->second.nets.find(sym);
                if (nit != dit->second.nets.end())
                    netToVar[nit->second] = var;
            }
            auto rebind = [&](UHDM::expr* e) {
                if (e && e->UhdmType() == UHDM::uhdmref_obj) {
                    auto* ro = (UHDM::ref_obj*)e;
                    if (auto* act = ro->Actual_group()) {
                        auto f = netToVar.find(act);
                        if (f != netToVar.end())
                            ro->Actual_group(f->second);
                    }
                }
            };
            for (auto* ca : *iit->second->Cont_assigns()) {
                rebind(ca->Lhs());
                rebind(ca->Rhs());
            }
        }
    }

    // Elab-view cont-assigns: the folded model shares the def cont-assign's
    // RHS object, pairing it with a fresh elab-prefixed, unbound LHS ref_obj.
    if (auto iit2 = ifaceDefMap.find(&def);
        iit2 != ifaceDefMap.end() && iit2->second->Cont_assigns()) {
        auto* elabCas = s.MakeCont_assignVec();
        for (auto* defCa : *iit2->second->Cont_assigns()) {
            auto* ca = s.MakeCont_assign();
            ca->VpiParent(iface);
            ca->VpiLineNo(defCa->VpiLineNo());
            ca->VpiColumnNo(defCa->VpiColumnNo());
            ca->VpiEndLineNo(defCa->VpiEndLineNo());
            ca->VpiEndColumnNo(defCa->VpiEndColumnNo());
            // A pkg-enum-const RHS ref folds to a LOC-LESS digits constant in
            // the elab view (the def keeps the ref).
            UHDM::expr* rhsShare = (UHDM::expr*)defCa->Rhs();
            if (rhsShare && rhsShare->UhdmType() == UHDM::uhdmref_obj) {
                auto* ract = ((UHDM::ref_obj*)rhsShare)->Actual_group();
                if (ract && ract->UhdmType() == UHDM::uhdmenum_const) {
                    auto* src = (UHDM::enum_const*)ract;
                    auto* c = s.MakeConstant();
                    c->VpiParent(ca);
                    c->VpiDecompile(src->VpiDecompile());
                    c->VpiSize(src->VpiSize());
                    std::string_view v = src->VpiValue();
                    c->VpiValue(std::string(v));
                    c->VpiConstType(v.rfind("BIN:", 0) == 0   ? vpiBinaryConst
                                    : v.rfind("HEX:", 0) == 0 ? vpiHexConst
                                    : v.rfind("OCT:", 0) == 0 ? vpiOctConst
                                    : v.rfind("DEC:", 0) == 0 ? vpiDecConst
                                                              : vpiUIntConst);
                    rhsShare = c;
                }
            }
            ca->Rhs(rhsShare);
            if (auto* dlhs = defCa->Lhs();
                dlhs && dlhs->UhdmType() == UHDM::uhdmref_obj) {
                auto* dro = (UHDM::ref_obj*)dlhs;
                auto* ro = s.MakeRef_obj();
                ro->VpiName(dro->VpiName());
                ro->VpiFullName(prefix + "." + std::string(dro->VpiName()));
                ro->VpiParent(ca);
                ro->VpiLineNo(dro->VpiLineNo());
                ro->VpiColumnNo(dro->VpiColumnNo());
                ro->VpiEndLineNo(dro->VpiEndLineNo());
                ro->VpiEndColumnNo(dro->VpiEndColumnNo());
                ca->Lhs(ro);
            }
            elabCas->push_back(ca);
        }
        if (!elabCas->empty())
            iface->Cont_assigns(elabCas);
    }
    auto* procs = s.MakeProcess_stmtVec();
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::ProceduralBlock)
            if (auto* p = emitProcess(member.as<ProceduralBlockSymbol>(), iface, prefix, netMap))
                procs->push_back(p);
    }
    if (!procs->empty()) {
        instSetProcess(iface, procs);
        // Surelog folds one process object into both interface_inst views.
        if (auto iit3 = ifaceDefMap.find(&def); iit3 != ifaceDefMap.end())
            instSetProcess(iit3->second, procs);
    }

    // Elab-view ports carry both LowConn (own var) and HighConn (parent
    // signal), mirroring a module instance's port loop.
    std::string parentPrefix = parentM && parentM->VpiFullName().length()
                                   ? std::string(parentM->VpiFullName())
                                   : std::string();
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
        p->VpiParent(iface);
        setLocNamed(p, ps);
        switch (ps.direction) {
            case ArgumentDirection::In: p->VpiDirection(vpiInput); break;
            case ArgumentDirection::Out: p->VpiDirection(vpiOutput); break;
            case ArgumentDirection::InOut: p->VpiDirection(vpiInout); break;
            default: noteUnsupported("port direction"); break;
        }
        const PortConnection* conn = nullptr;
        for (auto c : inst.getPortConnections())
            if (&c->port == portBase) { conn = c; break; }
        auto* lc = s.MakeRef_obj();
        lc->VpiName(ps.name);
        lc->VpiFullName(prefix + "." + std::string(ps.name));
        lc->VpiParent(p);
        if (auto npc = findConnSyntax(inst, ps.name))
            setLoc(lc, SourceRange(npc->name.location(),
                                   npc->name.location() + ps.name.size()));
        else if (hasOrderedConns(inst) && conn && connectionExpr(*conn))
            setLoc(lc, connectionExpr(*conn)->sourceRange);
        else
            setLocNamed(lc, ps);
        if (auto it2 = netMap.find(internal); it2 != netMap.end())
            lc->Actual_group(it2->second);
        p->Low_conn(lc);
        if (conn && parentNets) {
            if (auto expr = connectionExpr(*conn)) {
                refCollector = parentRefs;
                forceConstParent = true;
                if (auto* h = emitExpr(*expr, p, parentPrefix, *parentNets))
                    p->High_conn(h);
                forceConstParent = false;
                refCollector = nullptr;
            }
        }
        auto* pts = makeTypespec(*internal, nullptr, &ps);
        auto* prt = s.MakeRef_typespec();
        prt->VpiFullName(prefix + "." + std::string(ps.name));
        prt->VpiParent(p);
        prt->Actual_typespec(pts);
        p->Typespec(prt);
        ports->push_back(p);
    }
    if (!ports->empty())
        iface->Ports(ports);
    return iface;
}

} // namespace slang_uhdm
