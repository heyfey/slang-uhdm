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
        // Implicit nets print no typespec.
        bool implicitNet = it.sym->kind == SymbolKind::Net &&
                           it.sym->as<NetSymbol>().isImplicit;
        if (!it.port && !implicitNet) {
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
                    else if (valExpr->kind == syntax::SyntaxKind::IntegerLiteralExpression &&
                             cv.isInteger()) {
                        auto& iv = cv.integer();
                        std::string digits = iv.toString(LiteralBase::Decimal, false);
                        bool neg = iv.isSigned() && iv.isNegative();
                        ua->VpiValue((neg ? "INT:" : "UINT:") + digits);
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
    if (!nets->empty())
        m->Nets(nets);

    // Tasks/functions are module items; their typespecs (return, io_decls)
    // precede cont_assign and port typespecs.
    emitTaskFuncs(body, m, prefix, &info);

    // Def-view cont_assigns come before ports (their typespecs precede the
    // port typespecs in Surelog's arena).
    emitContAssigns(body, m, prefix, info.nets, /*topView=*/false, &info, false, nullptr,
                    nullptr);

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
                auto* gie = s.MakeGen_if_else();
                gie->VpiParent(m);
                syntaxRefPrefix = prefix;
                if (auto* c = emitSyntaxExpr(*ifSyn->condition, gie))
                    gie->VpiCondition((UHDM::expr*)c);
                syntaxRefPrefix.clear();
                if (auto* t = emitBranch(*ifSyn->block, gie))
                    gie->VpiStmt(t);
                if (ifSyn->elseClause)
                    if (auto* e = emitBranch(*ifSyn->elseClause->clause, gie))
                        gie->VpiElseStmt((UHDM::any*)e);
                regions->push_back(gie);
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
        if (auto it = defMap.find(&child.getDefinition()); it != defMap.end())
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

    emitImportArtifacts(body, m);

    return m;
}

// Modules with package imports carry an import_typespec per import item and
// list import-called package functions (shared def objects) in Task_funcs.
void UhdmExporter::emitImportArtifacts(const InstanceBodySymbol& body, UHDM::module_inst* m) {
    auto* tds = m->Typespecs();
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
            }
        }
        if (!ts && !implicitNet && !realVar)
            ts = sharedTypespec(*it.sym, netTs);
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
                    // '1/'0/'x unbased-unsized inits fold to the var width.
                    if (ic.kind == ExpressionKind::UnbasedUnsizedIntegerLiteral) {
                        ASTContext ctx(comp.getRoot(), LookupLocation::max);
                        ConstantValue cv = ctx.tryEval(*init);
                        if (cv && cv.isInteger() && !cv.integer().hasUnknown()) {
                            auto* c = s.MakeConstant();
                            std::string digits =
                                cv.integer().toString(LiteralBase::Decimal, false);
                            c->VpiDecompile(digits);
                            c->VpiSize((int32_t)dt->getType().getBitWidth());
                            c->VpiValue("UINT:" + digits);
                            c->VpiConstType(vpiUIntConst);
                            c->VpiParent(v);
                            setLoc(c, ic.sourceRange);
                            v->Expr(c);
                        }
                    }
                    else if (ic.kind == ExpressionKind::RealLiteral) {
                        // The var's init constant is unparented in this view.
                        if (auto* c = emitExpr(ic, v, fullName, topNets))
                            v->Expr((UHDM::expr*)c);
                    }
                    else if (enumRef || isLiteralExpr(ic) || concatInit) {
                        bool forceSaved = forceConstParent;
                        // Concat ops self-parent; only bare literals need the
                        // force (which would leak into concat operands).
                        if (!enumRef && !concatInit)
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
void UhdmExporter::emitGenScopes(const InstanceBodySymbol& body, UHDM::module_inst* m,
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
            // Actual int_typespec created at the end of the write phase.
            pendingIoTs.push_back({rt, rt});
            up->Typespec(rt);
            params->push_back(up);
        }
        if (!params->empty())
            gs->Parameters(params);

        // Functions declared inside the block live on the gen_scope.
        {
            DefInfo genInfo;
            genInfo.nets = netMap;
            emitTaskFuncs(blk, gs, fullName, &genInfo);
        }

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
            if (!rhs)
                rhs = emitExpr(ae.right(), ca, fullName, netMap);
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
    for (auto& pc : pendingParamCloneTs) {
        auto* its = makeParamTs(*pc.ps, /*typedParam=*/true);
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
        // Argument-less user calls returning a literal fold in the top view
        // to that literal (its own loc and base shape).
        CallFold cfr = topView ? constCallFold(stripImplicitConv(ae.right())) : CallFold{};
        const Expression* constFnRet = (cfr && !cfr.param) ? cfr.lit : nullptr;
        // Calls with args still fold when evaluable: a LOC-LESS constant
        // shaped by the result type (signed int -> INT/vpiIntConst).
        std::optional<ConstantValue> callFold;
        if (topView && !cfr) {
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
        if (topView) {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::NamedValue) {
                auto& sym = rc.as<NamedValueExpression>().symbol;
                if (isOverriddenParam(sym))
                    ovParamRhs = &sym;
                else if (sym.kind == SymbolKind::Parameter) {
                    auto& ps = sym.as<ParameterSymbol>();
                    if (auto dt = ps.getDeclaredType())
                        if (auto tsyn = dt->getTypeSyntax())
                            if (tsyn->kind != syntax::SyntaxKind::ImplicitType &&
                                ps.getValue().isInteger() &&
                                !ps.getValue().integer().hasUnknown())
                                typedParamRhs = &sym;
                }
            }
        }
        // Top modules share the def's cont_assign object unless netlist
        // elaboration re-compiles it: that happens only for whole-net LHS
        // (RHS resized against the net width) when the RHS contains
        // operations or is a literal. Select-LHS assigns always stay shared.
        bool plainLhs = stripImplicitConv(ae.left()).kind == ExpressionKind::NamedValue;
        if (shareWithDef && defInfo && myIdx < defInfo->contAssigns.size() &&
            (!plainLhs ||
             (!containsOperation(ae.right()) && !literalRhs && !enumRhs && !cfr &&
              !callFold && !ovParamRhs && !typedParamRhs))) {
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
            c->VpiDecompile(digits);
            c->VpiSize((int32_t)iv.getBitWidth());
            c->VpiValue((sgn ? "INT:" : "UINT:") + digits);
            c->VpiConstType(sgn ? vpiIntConst : vpiUIntConst);
            c->VpiParent(ca);
            rhs = c;
        }
        if (!rhs && !bitsRhs)
            rhs = topView ? tryFoldConst(ae.right()) : nullptr;
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
                          (literalRhs || bitsRhs || cfr || callFold || ovParamRhs) &&
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
        m->Cont_assigns(cas);
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
    if (expr.kind != ExpressionKind::Call || expr.as<CallExpression>().isSystemCall() ||
        !expr.as<CallExpression>().arguments().empty())
        return none;
    auto& call = expr.as<CallExpression>();
    auto subp = std::get_if<const SubroutineSymbol*>(&call.subroutine);
    if (!subp)
        return none;
    std::map<const Symbol*, CallFold> env;
    auto resolve = [&](const Expression& e) -> CallFold {
        auto& l = stripImplicitConv(e);
        if (l.kind == ExpressionKind::NamedValue) {
            auto it = env.find(&l.as<NamedValueExpression>().symbol);
            if (it != env.end())
                return it->second;
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
    setLoc(as, inner->sourceRange);

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
    if (ca.propertySpec.syntax)
        setLoc(ps, ca.propertySpec.syntax->sourceRange());
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

UHDM::any* UhdmExporter::emitAssertionExpr(const AssertionExpr& ae, UHDM::BaseClass* parent,
                                           const std::string& prefix, NetMap& netMap) {
    switch (ae.kind) {
        case AssertionExprKind::Simple:
            return emitExpr(ae.as<SimpleAssertionExpr>().expr, parent, prefix, netMap);
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
                setLoc(op, ae.syntax->sourceRange());
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

} // namespace slang_uhdm
