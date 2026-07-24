//------------------------------------------------------------------------------
//! @file ModuleEmit.cpp
//! @brief Module definitions, instances, ports, continuous assigns
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include <algorithm>
#include <functional>

#include "EmitHelpers.h"

#include "slang/ast/EvalContext.h"

namespace slang_uhdm {

static bool subWritesNonLocal(const SubroutineSymbol& sub);

// Surelog stores an interface's modports in a name-keyed std::map, so it
// emits them SORTED ALPHABETICALLY BY NAME (not in source-declaration order).
// Collect the body's modports in that same order.
static std::vector<const ModportSymbol*>
sortedModports(const InstanceBodySymbol& body) {
    std::vector<const ModportSymbol*> mps;
    for (auto& member : body.members())
        if (member.kind == SymbolKind::Modport)
            mps.push_back(&member.as<ModportSymbol>());
    std::stable_sort(mps.begin(), mps.end(),
                     [](const ModportSymbol* a, const ModportSymbol* b) {
                         return a->name < b->name;
                     });
    return mps;
}

// True when a declared type is a PACKAGE-scoped typedef'd struct.
// True when the declaration EXPLICITLY package-qualifies the type
// (p::req_t x). A wildcard-imported bare name (import p::*; req_t x)
// returns false — Surelog keys interface net-type quirks on the WRITTEN form.
static bool isExplicitPkgQualified(const Symbol& sym) {
    auto* dt = sym.getDeclaredType();
    if (!dt)
        return false;
    auto* tsyn = dt->getTypeSyntax();
    if (!tsyn || tsyn->kind != syntax::SyntaxKind::NamedType)
        return false;
    return tsyn->as<syntax::NamedTypeSyntax>().name->kind ==
           syntax::SyntaxKind::ScopedName;
}

static bool isPkgStructType(const Symbol& sym) {
    auto* dt = sym.getDeclaredType();
    if (!dt)
        return false;
    // Descend packed-array dims to the leaf (a packed array of a package
    // struct is still a package-struct net).
    const Type* leaf = &dt->getType().getCanonicalType();
    while (leaf->getCanonicalType().kind == SymbolKind::PackedArrayType)
        leaf = &leaf->getCanonicalType().as<PackedArrayType>().elementType;
    if (!leaf->getCanonicalType().isStruct())
        return false;
    // The named alias (possibly reached through the array dims).
    const Type* t = &dt->getType();
    while (t->getCanonicalType().kind == SymbolKind::PackedArrayType) {
        if (t->kind == SymbolKind::TypeAlias)
            break;
        t = &t->getCanonicalType().as<PackedArrayType>().elementType;
    }
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
        if (f.kind == SymbolKind::Field) {
            auto& fct = f.as<FieldSymbol>().getType().getCanonicalType();
            if (fct.isStruct())
                return true;
            // A packed-ARRAY-of-struct member also makes the net non-flat.
            if (fct.kind == SymbolKind::PackedArrayType) {
                const Type* el = &fct;
                while (el->getCanonicalType().kind == SymbolKind::PackedArrayType)
                    el = &el->getCanonicalType().as<PackedArrayType>().elementType;
                if (el->getCanonicalType().isStruct())
                    return true;
            }
        }
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
        // The module span starts at the `module` keyword (attribute
        // instances excluded); module-level (* *) specs attach as
        // vpiAttributes (Surelog).
        auto mr0 = syntax->sourceRange();
        if (syntax->kind == syntax::SyntaxKind::ModuleDeclaration) {
            auto& md0 = syntax->as<syntax::ModuleDeclarationSyntax>();
            mr0 = SourceRange(md0.header->moduleKeyword.location(), mr0.end());
            if (auto* bn = md0.blockName)
                m->VpiEndLabel(bn->name.valueText());
            if (!md0.attributes.empty()) {
                auto* mav = s.MakeAttributeVec();
                for (auto* asp0 : md0.attributes)
                    for (auto* aspec : asp0->specs) {
                        auto* ua0 = s.MakeAttribute();
                        ua0->VpiName(aspec->name.valueText());
                        ua0->VpiParent(m);
                        setLoc(ua0, aspec->sourceRange());
                        mav->push_back(ua0);
                    }
                if (!mav->empty())
                    m->Attributes(mav);
            }
        }
        setLoc(m, mr0);
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
    // Local nets typed by a typedef passed as a `type` parameter argument to a
    // child instance omit their def-view typespec (Surelog).
    std::set<const Type*> typeParamArgTypes;
    collectTypeParamArgTypes(body, typeParamArgTypes);
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
        // An implicit net slang minted from a PATTERN MEMBER-KEY inside a
        // port-connection value is dropped entirely (Surelog).
        if (it.sym->kind == SymbolKind::Net &&
            it.sym->as<NetSymbol>().isImplicit &&
            implicitNetFromPatternKey(it.sym, body))
            continue;
        // A net typed by an ALIAS-OF-ALIAS typedef omits its net type
        // (Surelog); other nets print it.
        bool aliasOfAlias0 = false;
        if (auto dt0 = it.sym->getDeclaredType())
            if (dt0->getType().kind == SymbolKind::TypeAlias) {
                auto& tt0 =
                    dt0->getType().as<TypeAliasType>().targetType.getType();
                aliasOfAlias0 =
                    tt0.kind == SymbolKind::PackedArrayType &&
                    tt0.as<PackedArrayType>().elementType.kind ==
                        SymbolKind::TypeAlias;
            }
        // A PACKED-ARRAY typedef signal (pkg::b c) carries NO net type even
        // when its element leaf is a pkg struct (Surelog).
        bool aliasPackedArr0 = false;
        if (auto dt0 = it.sym->getDeclaredType())
            if (dt0->getType().kind == SymbolKind::TypeAlias)
                aliasPackedArr0 = dt0->getType()
                                      .as<TypeAliasType>()
                                      .targetType.getType()
                                      .kind == SymbolKind::PackedArrayType;
        if (int32_t nt = aliasOfAlias0 ? 0 : netTypeFor(*it.sym, true))
            n->VpiNetType(nt);
        // A PACKAGE-typedef struct net (port, or a flat-member local) is a
        // wire; nested-struct-member locals stay untyped, and a struct with
        // an ATOM member (integer r;) carries no net type.
        else if (!aliasPackedArr0 && isPkgStructType(*it.sym) &&
                 isExplicitPkgQualified(*it.sym) &&
                 !([&] {
                     auto d9 = it.sym->getDeclaredType();
                     if (!d9)
                         return false;
                     auto& c9 = d9->getType().getCanonicalType();
                     if (!c9.isStruct())
                         return false;
                     for (auto& f9 : c9.as<Scope>().members())
                         if (f9.kind == SymbolKind::Field) {
                             auto& fc9 = f9.as<FieldSymbol>()
                                             .getType()
                                             .getCanonicalType();
                             if (fc9.kind ==
                                     SymbolKind::PredefinedIntegerType ||
                                 fc9.kind == SymbolKind::EnumType ||
                                 !fc9.isFourState())
                                 return true;
                         }
                     return false;
                 }()) &&
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
        // A net whose UNPACKED-leaf type is a MODULE-PREFIXED struct typedef
        // (member-only use: neither nested nor whole-assigned) carries NO
        // def-view typespec — unless it has an initializer or feeds a child
        // instance port connection. Packed-array-of-struct nets keep theirs.
        bool prefixedStructNet = false;
        if (auto dtn = it.sym->getDeclaredType();
            dtn && !dtn->getInitializer()) {
            const Type* lf = &dtn->getType().getCanonicalType();
            while (lf->getCanonicalType().kind ==
                   SymbolKind::FixedSizeUnpackedArrayType)
                lf = &lf->getCanonicalType()
                          .as<FixedSizeUnpackedArrayType>()
                          .elementType;
            prefixedStructNet =
                lf->getCanonicalType().kind == SymbolKind::PackedStructType &&
                modulePrefixedStructs.count(&lf->getCanonicalType());

            if (prefixedStructNet) {
                // The ts drop is keyed on the module HEADER style: it
                // happens only in NON-ANSI-header modules.
                bool nonAnsi = false;
                if (auto* dsyn = body.getDefinition().getSyntax()) {
                    if (dsyn->kind ==
                        slang::syntax::SyntaxKind::ModuleDeclaration) {
                        auto& mds =
                            dsyn->as<slang::syntax::ModuleDeclarationSyntax>();
                        nonAnsi = mds.header->ports &&
                                  mds.header->ports->kind ==
                                      slang::syntax::SyntaxKind::NonAnsiPortList;
                    }
                }
                if (!nonAnsi)
                    prefixedStructNet = false;
            }
        }
        // A local net typed by a typedef used as a child instance's `type`
        // parameter argument stays a bare logic_net in the def view.
        bool typeParamArgNet =
            it.sym->getDeclaredType() &&
            typeParamArgTypes.count(&it.sym->getDeclaredType()->getType());
        if (!it.port && !implicitNet && !classHandle && !prefixedStructNet &&
            !typeParamArgNet) {
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
                if (auto sit = sharedAttrObjs.find((const void*)asyn);
                    asyn && sit != sharedAttrObjs.end()) {
                    sit->second->VpiParent(n); // last-writer
                    av->push_back(sit->second);
                    stored.push_back(sit->second);
                    continue;
                }
                auto* ua = s.MakeAttribute();
                if (asyn)
                    sharedAttrObjs[(const void*)asyn] = ua;
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
        info.nets[portBase] = n;
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
            // A PASSTHROUGH conn (the iface lives in an OUTER module) gets
            // no connection-site net here.
            if (conn.first->getParentScope() != (const Scope*)&body)
                continue;
            const PortConnection* pc = nullptr;
            for (auto cc : child.getPortConnections())
                if (&cc->port == pb) {
                    pc = cc;
                    break;
                }
            // Only a BARE whole-interface connection gets a connection-site
            // net; modport-qualified (.mon(s.mon)) don't, and a POSITIONAL
            // conn whose actual name EQUALS the formal's name is deduped
            // (m0(bus, ...) with formal `bus`) — Surelog.
            if (!pc || !connectionExpr(*pc) ||
                rawText(connectionExpr(*pc)->sourceRange).find('.') != std::string::npos)
                continue;
            {
                bool mixed9 = false;
                for (auto cc9 : child.getPortConnections())
                    if (cc9->port.kind != SymbolKind::InterfacePort)
                        mixed9 = true;
                if (hasOrderedConns(child) && mixed9 &&
                    conn.first->name == pb->name)
                    continue;
            }
            // An interface instance connected to MULTIPLE children gets a
            // SINGLE connection-site net, anchored at the FIRST connection
            // site (source order) — Surelog. Skip later duplicates.
            if (ifaceConnNet.count(conn.first))
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
    emitGates(body, m, prefix, info.nets, /*topView=*/false);

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
    emitDefGenStmts(body, m, prefix);

    (void)netTsAtEntry;
    (void)topDef;

    return m;
}

// An INSTANCE ARRAY (myif arr[N]) is a module_array (vpiModuleArray) — the
// def module_typespec as element type, the array range, broadcast port
// connections (HighConn ref_obj -> the parent net), and the per-index
// interface instances. Surelog emits it in BOTH the def and elab views.
UHDM::module_array* UhdmExporter::emitModuleArray(const InstanceArraySymbol& arr,
                                                  UHDM::module_inst* m,
                                                  const std::string& prefix,
                                                  NetMap& nets,
                                                  bool withInstances) {
    const InstanceSymbol* rep = nullptr;
    for (auto* e : arr.elements)
        if (e && e->kind == SymbolKind::Instance) {
            rep = &e->as<InstanceSymbol>();
            break;
        }
    if (!rep || !useInterfacePath(*rep))
        return nullptr;
    auto& adef = rep->getDefinition();
    auto* ma = s.MakeModule_array();
    ma->VpiName(arr.name);
    ma->VpiFullName("work@" + std::string(adef.name));
    ma->VpiParent(m);
    setLoc(ma, SourceRange(arr.location, arr.location + arr.name.size()));
    // Range bounds keep their SOURCE op-form (arr[2-1:0] -> LeftRange = op 2-1)
    // via emitSyntaxExpr; fall back to the folded constant if no syntax.
    const syntax::ExpressionSyntax* leftSyn = nullptr;
    const syntax::ExpressionSyntax* rightSyn = nullptr;
    const syntax::ExpressionSyntax* sizeSyn9 = nullptr;
    const syntax::SyntaxNode* dimSyn9 = nullptr;
    const syntax::SyntaxNode* instTypeSyn9 = nullptr;
    if (auto* asyn = arr.getSyntax();
        asyn && asyn->kind == syntax::SyntaxKind::HierarchicalInstance) {
        for (auto p9 = asyn->parent; p9; p9 = p9->parent)
            if (p9->kind == syntax::SyntaxKind::HierarchyInstantiation) {
                instTypeSyn9 = p9;
                break;
            }
        if (auto* decl = asyn->as<syntax::HierarchicalInstanceSyntax>().decl;
            decl && !decl->dimensions.empty()) {
            auto* dim = *decl->dimensions.begin();
            dimSyn9 = dim;
            if (dim->specifier &&
                dim->specifier->kind ==
                    syntax::SyntaxKind::RangeDimensionSpecifier) {
                auto& spec =
                    dim->specifier->as<syntax::RangeDimensionSpecifierSyntax>();
                if (spec.selector->kind == syntax::SyntaxKind::SimpleRangeSelect) {
                    auto& sel = spec.selector->as<syntax::RangeSelectSyntax>();
                    leftSyn = sel.left;
                    rightSyn = sel.right;
                }
                else if (spec.selector->kind ==
                         syntax::SyntaxKind::BitSelect)
                    sizeSyn9 =
                        spec.selector->as<syntax::BitSelectSyntax>().expr;
            }
        }
    }
    auto* rng = s.MakeRange();
    rng->VpiParent(ma);
    // A SIZE-form dim (m[2]) ranges [0 : 2-1]: loc at the size token,
    // loc-less 0 left, op N-1 right (Surelog).
    if (sizeSyn9) {
        setLoc(rng, sizeSyn9->sourceRange());
        auto* lc9 = s.MakeConstant();
        lc9->VpiDecompile("0");
        lc9->VpiSize(64);
        lc9->VpiValue("UINT:0");
        lc9->VpiConstType(vpiUIntConst);
        lc9->VpiParent(rng);
        rng->Left_expr(lc9);
        auto* op9 = s.MakeOperation();
        op9->VpiParent(rng);
        op9->VpiOpType(11);
        setLoc(op9, sizeSyn9->sourceRange());
        auto* ops9 = s.MakeAnyVec();
        auto* sc9 = s.MakeConstant();
        sc9->VpiDecompile(
            std::to_string(arr.range.width()));
        sc9->VpiSize(64);
        sc9->VpiValue("UINT:" + std::to_string(arr.range.width()));
        sc9->VpiConstType(vpiUIntConst);
        sc9->VpiParent(op9);
        setLoc(sc9, sizeSyn9->sourceRange());
        ops9->push_back(sc9);
        auto* one9 = s.MakeConstant();
        one9->VpiSize(64);
        one9->VpiValue("INT:1");
        one9->VpiConstType(vpiIntConst);
        ops9->push_back(one9);
        op9->Operands(ops9);
        rng->Right_expr(op9);
        auto* rvec9 = s.MakeRangeVec();
        rvec9->push_back(rng);
        ma->Ranges(rvec9);
    }
    else {
    auto mkBound = [&](const syntax::ExpressionSyntax* bs, int32_t v) -> UHDM::expr* {
        if (bs) {
            std::string sp = syntaxRefPrefix;
            syntaxRefPrefix = prefix;
            auto* e = emitSyntaxExpr(*bs, rng);
            syntaxRefPrefix = sp;
            if (e)
                return (UHDM::expr*)e;
        }
        auto* c = s.MakeConstant();
        c->VpiDecompile(std::to_string(v));
        c->VpiSize(64);
        c->VpiValue("UINT:" + std::to_string(v));
        c->VpiConstType(vpiUIntConst);
        c->VpiParent(rng);
        return c;
    };
    // The explicit-range dim locates the range at the [..] tokens.
    if (dimSyn9)
        setLoc(rng, dimSyn9->sourceRange());
    rng->Left_expr(mkBound(leftSyn, arr.range.left));
    rng->Right_expr(mkBound(rightSyn, arr.range.right));
    auto* rvec = s.MakeRangeVec();
    rvec->push_back(rng);
    ma->Ranges(rvec);
    }
    auto* mts = s.MakeModule_typespec();
    mts->VpiName(adef.name);
    // Located at the instantiation's TYPE token (Surelog).
    if (instTypeSyn9)
        setLoc(mts,
               instTypeSyn9->as<syntax::HierarchyInstantiationSyntax>()
                   .type.range());
    auto* ert = s.MakeRef_typespec();
    ert->VpiFullName(prefix + "." + std::string(arr.name));
    ert->VpiParent(ma);
    ert->Actual_typespec(mts);
    ma->Elem_typespec(ert);
    auto* mports = s.MakePortVec();
    for (auto conn : rep->getPortConnections()) {
        auto* ax = connectionExpr(*conn);
        if (!ax || ax->kind != ExpressionKind::NamedValue)
            continue;
        auto& nv = ax->as<NamedValueExpression>();
        auto* p = s.MakePort();
        p->VpiName(conn->port.name);
        p->VpiParent(ma);
        if (auto npc = findConnSyntax(*rep, conn->port.name))
            setLoc(p, npc->sourceRange());
        auto* r = s.MakeRef_obj();
        r->VpiName(nv.symbol.name);
        r->VpiFullName(prefix + "." + std::string(arr.name) + "." +
                       std::string(conn->port.name) + "." +
                       std::string(nv.symbol.name));
        r->VpiParent(p);
        setLoc(r, ax->sourceRange);
        if (auto nit = nets.find(&nv.symbol); nit != nets.end())
            r->Actual_group(nit->second);
        p->High_conn(r);
        mports->push_back(p);
    }
    if (!mports->empty())
        ma->Ports(mports);
    if (withInstances) {
        int32_t lo = std::min(arr.range.left, arr.range.right);
        auto* insts = s.MakeInstanceVec();
        std::set<const Symbol*> arrRefs;
        for (size_t i = 0; i < arr.elements.size(); i++) {
            auto* e = arr.elements[i];
            if (!e || e->kind != SymbolKind::Instance)
                continue;
            std::string ipath = prefix + "." + std::string(arr.name) + "[" +
                                std::to_string(lo + (int32_t)i) + "]";
            insts->push_back(emitInterfaceInstance(e->as<InstanceSymbol>(),
                                                   ipath, m, &nets, &arrRefs));
        }
        if (!insts->empty())
            ma->Instances(insts);
    }
    return ma;
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
    // are folded (recompiled), unlike local-net typespecs. EXCEPT for a
    // NON-TOP (child-instantiated) def: its overridable-module-param dim
    // bounds stay symbolic (defPortDim) — the def ts is not shared with the
    // elab child port ts. A TOP def's ports get the write-phase swap instead,
    // so leave them folded here (that folded object becomes the elab port).
    bool isTopDef = false;
    for (auto ti : comp.getRoot().topInstances)
        if (&ti->getDefinition() == &def) {
            isTopDef = true;
            break;
        }
    defPortDim = !isTopDef;
    emitPorts(body, m, prefix, info.nets, /*topView=*/false, &defTs);
    defPortDim = false;

    // Child instance references (def view uses ref_module stubs; bound
    // instances are skipped in the def view).
    auto* refmods = s.MakeRef_moduleVec();
    UHDM::VectorOfmodule_array* moduleArrays = nullptr;
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::InstanceArray) {
            if (auto* ma = emitModuleArray(member.as<InstanceArraySymbol>(), m,
                                           prefix, info.nets, false)) {
                if (!moduleArrays)
                    moduleArrays = s.MakeModule_arrayVec();
                moduleArrays->push_back(ma);
            }
            continue;
        }
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
        // A MODULE child with an OPERATION among its positional conns
        // (uut(clk, a && b, ...)) emits NO def ref_module at all
        // (interfaces keep theirs — Surelog).
        if (hasOrderedConns(child) &&
            ifaceDefMap.find(&child.getDefinition()) == ifaceDefMap.end()) {
            bool hasOpConn = false;
            bool hasIfaceConn = false;
            for (auto conn : child.getPortConnections()) {
                if (conn->port.kind == SymbolKind::InterfacePort) {
                    // Only a SAME-NAME positional iface conn MIXED with
                    // regular conns (m0(bus, din) with formal `bus`) omits
                    // the ref_module; iface-only conn lists keep it (Surelog).
                    bool mixed9 = false;
                    for (auto cc9 : child.getPortConnections())
                        if (cc9->port.kind != SymbolKind::InterfacePort)
                            mixed9 = true;
                    auto ic9 = conn->port.as<InterfacePortSymbol>()
                                   .getConnection();
                    if (mixed9 && ic9.first &&
                        ic9.first->name == conn->port.name)
                        hasIfaceConn = true;
                    continue;
                }
                auto* ex0 = connectionExpr(*conn);
                if (!ex0)
                    continue;
                auto k0 = stripImplicitConv(*ex0).kind;
                if (k0 == ExpressionKind::BinaryOp ||
                    k0 == ExpressionKind::UnaryOp ||
                    k0 == ExpressionKind::ConditionalOp) {
                    hasOpConn = true;
                    break;
                }
            }
            // A positional IFACE conn also omits the ref_module (Surelog).
            if (hasOpConn || hasIfaceConn)
                continue;
            // A NON-ANSI (1995-style port list) PARENT also omits its
            // positional child ref_modules (wandwor — Surelog).
            bool nonAnsiParent = false;
            if (auto psyn9 = body.getSyntax();
                psyn9 && psyn9->kind == syntax::SyntaxKind::ModuleDeclaration) {
                auto& mh9 = *psyn9->as<syntax::ModuleDeclarationSyntax>().header;
                if (mh9.ports &&
                    mh9.ports->kind == syntax::SyntaxKind::NonAnsiPortList)
                    nonAnsiParent = true;
            }
            if (nonAnsiParent)
                continue;
            // A child whose #(...) override TEXTS differ while the folded
            // VALUES coincide (demo_003 #(1.0)/#(1)) omits the ref_module
            // (Surelog's pre-elab textual uniquification conflicts with the
            // value merge); value-distinct multis keep theirs
            // (param_no_default).
            if (textMultiParamDefs.count(&child.getDefinition()) &&
                !multiParamDefs.count(&child.getDefinition()))
                continue;
        }
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
            // An UNCONNECTED port (dut d();) emits no ref_module port.
            if (!connectionExpr(*conn) && !findConnSyntax(child, conn->port.name))
                continue;
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
            // A `.name` SHORTHAND named conn — and a port left to its
            // declared DEFAULT — carry NO HighConn (Surelog).
            {
                auto* npcS = findConnSyntax(child, conn->port.name);
                if (npcS && !npcS->openParen) {
                    rports->push_back(p);
                    continue;
                }
                if (!npcS && !ordered && connectionExpr(*conn)) {
                    // Default-value port (no conn written): NO ref_module
                    // port at all.
                    if (auto isynS = child.getSyntax()) {
                        auto irS = isynS->sourceRange();
                        auto esS = connectionExpr(*conn)->sourceRange.start();
                        if (esS != SourceLocation::NoLocation &&
                            (esS < irS.start() || esS > irS.end()))
                            continue;
                    }
                }
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
                    // An interface-ARRAY element connection (.b(arr[0])) is a
                    // bit_select on the module_array, named by the array and
                    // scoped by the child instance (work@dut.p0.arr) — Surelog.
                    if (conn->port.kind == SymbolKind::InterfacePort &&
                        h->UhdmType() == UHDM::uhdmref_obj) {
                        std::string rn(((UHDM::ref_obj*)h)->VpiName());
                        if (auto lb = rn.find('[');
                            lb != std::string::npos && !rn.empty() &&
                            rn.back() == ']') {
                            std::string base = rn.substr(0, lb);
                            std::string idxS =
                                rn.substr(lb + 1, rn.size() - lb - 2);
                            auto* bs = s.MakeBit_select();
                            bs->VpiName(base);
                            bs->VpiFullName(prefix + "." + std::string(child.name) +
                                            "." + base);
                            bs->VpiParent(p);
                            setLoc(bs, expr->sourceRange);
                            auto* ic = s.MakeConstant();
                            ic->VpiValue("UINT:" + idxS);
                            ic->VpiDecompile(idxS);
                            ic->VpiSize(64);
                            ic->VpiConstType(vpiUIntConst);
                            ic->VpiParent(bs);
                            setLoc(ic, expr->sourceRange);
                            bs->VpiIndex(ic);
                            h = bs;
                        }
                    }
                    if (conn->port.kind == SymbolKind::InterfacePort &&
                        h->UhdmType() == UHDM::uhdmref_obj) {
                        if (auto cc =
                                conn->port.as<InterfacePortSymbol>().getConnection().first;
                            cc && cc->kind == SymbolKind::Instance) {
                            auto* r = (UHDM::ref_obj*)h;
                            r->VpiFullName(prefix + "." + std::string(child.name) + "." +
                                           std::string(conn->port.name) + "." +
                                           std::string(r->VpiName()));
                            // A PASSTHROUGH conn binds this module's own
                            // iface-port net, not the outer instance's.
                            const Symbol* site =
                                body.find(std::string(r->VpiName()));
                            if (site && site->kind == SymbolKind::InterfacePort) {
                                if (auto nit2 = info.nets.find(site);
                                    nit2 != info.nets.end())
                                    r->Actual_group(nit2->second);
                            }
                            else if (auto nit = ifaceConnNet.find(cc);
                                     nit != ifaceConnNet.end())
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
    if (moduleArrays && !moduleArrays->empty())
        m->Module_arrays(moduleArrays);

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
        // Collect imported typedef symbols: explicit imports name one; a
        // WILDCARD import lists every package typedef (name-sorted, matching
        // the package's own list order).
        std::vector<std::pair<const Symbol*, const Symbol*>> importedTds;
        for (auto& mem : body.members()) {
            if (mem.kind == SymbolKind::ExplicitImport) {
                auto* imported = mem.as<ExplicitImportSymbol>().importedSymbol();
                if (imported && imported->kind == SymbolKind::TypeAlias)
                    importedTds.emplace_back(&mem, imported);
            }
            else if (mem.kind == SymbolKind::WildcardImport) {
                auto* pkg = comp.getPackage(
                    mem.as<WildcardImportSymbol>().packageName);
                if (!pkg)
                    continue;
                std::vector<const Symbol*> tas;
                // TRANSITIVE typedefs too: a package the imported package
                // itself wildcard-imports contributes its typedefs to the
                // module list (Surelog).
                std::set<const Symbol*> seenPkgs;
                std::function<void(const PackageSymbol&)> collectTas =
                    [&](const PackageSymbol& p9) {
                        if (!seenPkgs.insert(&p9).second)
                            return;
                        for (auto& pm : p9.members()) {
                            if (pm.kind == SymbolKind::TypeAlias)
                                tas.push_back(&pm);
                            else if (pm.kind == SymbolKind::WildcardImport)
                                if (auto* np = pm.as<WildcardImportSymbol>()
                                                   .getPackage())
                                    collectTas(*np);
                        }
                    };
                collectTas(*pkg);
                std::stable_sort(tas.begin(), tas.end(),
                                 [](const Symbol* a, const Symbol* b) {
                                     return a->name < b->name;
                                 });
                for (auto* ta : tas)
                    importedTds.emplace_back(&mem, ta);
            }
        }
        for (auto& [memP, imported] : importedTds) {
            auto& mem = *memP;
            // A typedef whose home pkg is imported by ANOTHER pkg: all module
            // listings share that ONE clone (Surelog).
            UHDM::typespec* tsSel = nullptr;
            if (auto cit = pkgImportCloneTs.find(imported);
                cit != pkgImportCloneTs.end())
                tsSel = cit->second;
            else if (auto tit = pkgTopTypedefTs.find(imported);
                     tit != pkgTopTypedefTs.end())
                tsSel = tit->second;
            if (!tsSel)
                continue;
            // A HEADER import (module top import pkg::T; (...)) lists the
            // typespec but keeps its package parent; body imports re-parent.
            bool headerImport = false;
            for (auto q = mem.getSyntax(); q; q = q->parent)
                if (q->kind == syntax::SyntaxKind::ModuleHeader) {
                    headerImport = true;
                    break;
                }
            auto* ts = tsSel;
            // A WILDCARD-imported FLAT typedef re-parents to the module and
            // re-scopes member/base refs to work@<mod>.<pkg>::<name>[.m]
            // (interface-style, last-writer). NESTED-struct-containing
            // typedefs keep their package parent and scoping.
            // Only SAME-package nesting keeps the pkg scoping; a member
            // struct typedef'd in ANOTHER package (cross-pkg nesting) still
            // re-scopes to the module (nested_struct).
            bool nestedContainer = false;
            if (imported->kind == SymbolKind::TypeAlias) {
                auto& ict = imported->as<TypeAliasType>().getCanonicalType();
                auto impPkg9 = imported->getParentScope();
                if (ict.kind == SymbolKind::PackedStructType)
                    for (auto& fm :
                         ict.as<PackedStructType>().membersOfType<FieldSymbol>())
                        if (fm.getType().getCanonicalType().kind ==
                            SymbolKind::PackedStructType) {
                            auto& ft9 = fm.getType();
                            const Scope* fPkg9 = nullptr;
                            if (ft9.kind == SymbolKind::TypeAlias)
                                fPkg9 = ft9.as<TypeAliasType>().getParentScope();
                            if (!fPkg9 || fPkg9 == impPkg9)
                                nestedContainer = true;
                        }
            }
            bool wildcard = mem.kind == SymbolKind::WildcardImport;
            // The header-import share-without-touch rule is EXPLICIT-only;
            // wildcard header imports re-scope like body imports (Surelog).
            if ((!headerImport || wildcard) && !nestedContainer) {
                ts->VpiParent(m);
                if (wildcard) {
                    // Scope by the typedef's HOME package (== the imported
                    // one for direct imports; differs for transitives).
                    std::string pn(mem.as<WildcardImportSymbol>().packageName);
                    std::string homePn = pn;
                    const Symbol* homePkg = nullptr;
                    for (auto sc9 = imported->getParentScope(); sc9;
                         sc9 = sc9->asSymbol().getParentScope())
                        if (sc9->asSymbol().kind == SymbolKind::Package) {
                            homePkg = &sc9->asSymbol();
                            homePn = std::string(homePkg->name);
                            break;
                        }
                    // A TRANSITIVE typedef lists a FRESH CLONE (module-
                    // parented, Instance -> the DIRECT import package, base
                    // ref module-scoped) — never mutate the shared home-pkg
                    // object.
                    if (homePn != pn &&
                        ts->UhdmType() == UHDM::uhdmenum_typespec &&
                        imported->kind == SymbolKind::TypeAlias) {
                        auto clKey = std::make_pair(
                            imported, std::string(m->VpiDefName()));
                        auto& taE = imported->as<TypeAliasType>();
                        auto& ectE = taE.getCanonicalType();
                        if (auto pcit9 = pkgImportCloneTs.find(imported);
                            pcit9 != pkgImportCloneTs.end())
                            ts = pcit9->second;
                        else if (auto cit9 = transitiveTdClone.find(clKey);
                            cit9 != transitiveTdClone.end()) {
                            ts = cit9->second;
                            // The def pass ran before packages existed —
                            // fill the Instance on the later (elab) hit.
                            if (!ts->Instance())
                                if (auto* dp = comp.getPackage(pn))
                                    if (auto pit9 = pkgDefMap.find(dp);
                                        pit9 != pkgDefMap.end())
                                        ts->Instance(pit9->second);
                        }
                        else if (ectE.kind == SymbolKind::EnumType) {
                            std::string scopedE =
                                std::string(m->VpiDefName()) + "." + homePn +
                                "::" + std::string(imported->name);
                            const syntax::SyntaxNode* eSyn9 = nullptr;
                            if (auto dS9 = taE.getSyntax();
                                dS9 && dS9->kind ==
                                           syntax::SyntaxKind::TypedefDeclaration)
                                eSyn9 = dS9->as<syntax::TypedefDeclarationSyntax>()
                                            .type;
                            auto* cl9 = buildEnumTs(ectE.as<EnumType>(),
                                                    eSyn9, scopedE);
                            // The base actual is HOME-package-instanced,
                            // like the home listing (Surelog).
                            if (cl9->Base_typespec() &&
                                cl9->Base_typespec()->Actual_typespec() &&
                                homePkg)
                                if (auto hip9 = pkgDefMap.find(homePkg);
                                    hip9 != pkgDefMap.end())
                                    cl9->Base_typespec()
                                        ->Actual_typespec()
                                        ->Instance(hip9->second);
                            cl9->VpiName(homePn + "::" +
                                         std::string(imported->name));
                            cl9->VpiParent(m);
                            if (auto tsyn9 = taE.getSyntax())
                                setLoc(cl9, tsyn9->sourceRange());
                            if (auto* dp = comp.getPackage(pn))
                                if (auto pit9 = pkgDefMap.find(dp);
                                    pit9 != pkgDefMap.end())
                                    cl9->Instance(pit9->second);
                            transitiveTdClone[clKey] = cl9;
                            ts = cl9;
                        }
                    }
                    std::string scopedName =
                        std::string(m->VpiDefName()) + "." + homePn + "::" +
                        std::string(imported->name);
                    if (ts->UhdmType() == UHDM::uhdmenum_typespec) {
                        auto* ets = (UHDM::enum_typespec*)ts;
                        if (ets->Base_typespec())
                            ets->Base_typespec()->VpiFullName(scopedName);
                    }
                    if (ts->UhdmType() == UHDM::uhdmstruct_typespec) {
                        auto* sts = (UHDM::struct_typespec*)ts;
                        if (sts->Members())
                            for (auto* tm : *sts->Members())
                                if (tm->Typespec())
                                    tm->Typespec()->VpiFullName(
                                        scopedName + "." +
                                        std::string(tm->VpiName()));
                    }
                }
            }
            if (!tds) {
                tds = s.MakeTypespecVec();
                m->Typespecs(tds);
            }
            if (std::find(tds->begin(), tds->end(), (UHDM::typespec*)ts) == tds->end())
                tds->push_back(ts);
        }
        // The module's Typespecs list interleaves its own and imported
        // typedefs by BASE name (the portion after the last ::) — full-name
        // sorting misplaces transitive imports (pad_type_e before
        // pinmux_pkg::target_cfg_t — Surelog).
        if (tds)
            std::stable_sort(tds->begin(), tds->end(),
                             [](const UHDM::typespec* a, const UHDM::typespec* b) {
                                 auto base = [](std::string_view n) {
                                     auto p9 = n.rfind("::");
                                     return p9 == std::string_view::npos
                                                ? n
                                                : n.substr(p9 + 2);
                                 };
                                 return base(a->VpiName()) < base(b->VpiName());
                             });
    }
    for (auto& mem : body.members()) {
        std::string pkgName;
        if (mem.kind == SymbolKind::WildcardImport)
            pkgName = std::string(mem.as<WildcardImportSymbol>().packageName);
        else if (mem.kind == SymbolKind::ExplicitImport)
            pkgName = std::string(mem.as<ExplicitImportSymbol>().packageName);
        else
            continue;
        // An EXPLICIT import whose package is ALSO wildcard-imported in this
        // body carries no import_typespec of its own — the wildcard import's
        // import_typespec already covers the package (Surelog de-dups). An
        // explicit import of a package with no wildcard keeps its own.
        if (mem.kind == SymbolKind::ExplicitImport) {
            bool pkgWildcarded = false;
            for (auto& w : body.members())
                if (w.kind == SymbolKind::WildcardImport &&
                    w.as<WildcardImportSymbol>().packageName == pkgName) {
                    pkgWildcarded = true;
                    break;
                }
            if (pkgWildcarded)
                continue;
        }
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
        for (auto& [tf, rg9] : it->second)
            if (std::find(v->begin(), v->end(), tf) == v->end())
                v->push_back(tf);
    }
    // A module that WILDCARD-imports a package materializes ALL that
    // package's subroutines into its Task_funcs (the shared def object),
    // whether or not any is called here — Surelog lists them in both the
    // def and elab views. (Explicit imports name specific symbols; the
    // call-site path above already covers those that are functions.)
    if (m->UhdmType() == UHDM::uhdmmodule_inst) {
        for (auto& mem : body.members()) {
            if (mem.kind != SymbolKind::WildcardImport)
                continue;
            auto* pkg = comp.getPackage(
                mem.as<WildcardImportSymbol>().packageName);
            if (!pkg)
                continue;
            for (auto& pm : pkg->members()) {
                if (pm.kind != SymbolKind::Subroutine)
                    continue;
                auto sit = subMap.find(&pm);
                if (sit == subMap.end() || !sit->second.tf)
                    continue;
                auto* v = m->Task_funcs();
                if (!v) {
                    v = s.MakeTask_funcVec();
                    m->Task_funcs(v);
                }
                if (std::find(v->begin(), v->end(), sit->second.tf) == v->end())
                    v->push_back(sit->second.tf);
            }
        }
    }
}

// Surelog's vpiDirection for a modport interface port (X_if.mp Y): vpiInput
// iff the connection explicitly names the modport (.Y(x.mp), a dotted actual)
// AND the modport declares >=1 OUTPUT member. Otherwise vpiInout — a plain
// interface connection (.Y(x)), an input-only modport, or a bare interface
// port. Decoded across 16 iface tests (conn/field_assign/cfg_mem = input;
// out/modport/member_port/member_read_assign/... = inout).
int32_t UhdmExporter::interfacePortDirection(const InterfacePortSymbol& ip) {
    if (ip.modport.empty())
        return vpiInout;
    auto ce = ip.getConnectionAndExpr();
    const ModportSymbol* mp = ce.first.second;
    if (!mp)
        return vpiInout;
    bool hasOut = false;
    for (auto& mm : mp->members())
        if (mm.kind == SymbolKind::ModportPort &&
            mm.as<ModportPortSymbol>().direction == ArgumentDirection::Out) {
            hasOut = true;
            break;
        }
    if (!hasOut) {
        // Input-only modport: vpiInput only when the module never touches a
        // modport MEMBER through the port (param-only access like
        // s.CFG.BUS.DAT); any member access keeps inout
        // (member_port/member_read_assign/struct_field_bitselect).
        bool memberRef = false;
        if (auto ps9 = ip.getParentScope()) {
            if (auto msyn9 = ps9->asSymbol().getSyntax()) {
                std::string body9 = rawText(msyn9->sourceRange());
                for (auto& mm : mp->members()) {
                    if (mm.kind != SymbolKind::ModportPort)
                        continue;
                    std::string pat9 =
                        std::string(ip.name) + "." + std::string(mm.name);
                    if (body9.find(pat9) != std::string::npos) {
                        memberRef = true;
                        break;
                    }
                }
            }
        }
        if (memberRef)
            return vpiInout;
    }
    const Expression* ex = ce.second;
    bool qualified =
        ex && rawText(ex->sourceRange).find('.') != std::string::npos;
    return qualified ? vpiInput : vpiInout;
}

// An implicit net stays in the elab view only when it feeds a child
// instance port connection; one referenced only from gen scopes is dropped
// (its module-level cont_assign shares the def object bare).
// True when an IMPLICIT net's declaration point sits inside a port-conn
// assignment-pattern value (slang mints one for a member-key identifier).
bool UhdmExporter::implicitNetFromPatternKey(const Symbol* sym,
                                             const InstanceBodySymbol& body) {
    for (auto& mb : body.members()) {
        if (mb.kind != SymbolKind::Instance)
            continue;
        for (auto pc : mb.as<InstanceSymbol>().getPortConnections()) {
            auto* pe = pc->getExpression();
            if (!pe)
                continue;
            const Expression* e = pe;
            if (e->kind == ExpressionKind::Assignment)
                e = &e->as<AssignmentExpression>().left();
            auto k = stripImplicitConv(*e).kind;
            if (k != ExpressionKind::SimpleAssignmentPattern &&
                k != ExpressionKind::StructuredAssignmentPattern &&
                k != ExpressionKind::ReplicatedAssignmentPattern)
                continue;
            auto sr = e->sourceRange;
            if (sym->location >= sr.start() && sym->location < sr.end())
                return true;
        }
    }
    return false;
}

bool UhdmExporter::implicitNetKeptInElab(const Symbol* sym,
                                         const InstanceBodySymbol& body) {
    for (auto& mb : body.members()) {
        if (mb.kind != SymbolKind::Instance)
            continue;
        for (auto pc : mb.as<InstanceSymbol>().getPortConnections()) {
            if (auto* pe = pc->getExpression()) {
                const Expression* e = pe;
                if (e->kind == ExpressionKind::Assignment)
                    e = &e->as<AssignmentExpression>().left();
                // An assignment-pattern conn value can't drive a net; a
                // MEMBER-KEY identifier slang minted as an implicit net
                // inside it must not keep the net alive (Surelog drops it).
                auto pk9 = stripImplicitConv(*e).kind;
                if (pk9 == ExpressionKind::SimpleAssignmentPattern ||
                    pk9 == ExpressionKind::StructuredAssignmentPattern ||
                    pk9 == ExpressionKind::ReplicatedAssignmentPattern)
                    continue;
                std::set<const Symbol*> syms;
                collectLhsSyms(*e, syms);
                const Expression* bot = &stripImplicitConv(*e);
                if (bot->kind == ExpressionKind::NamedValue)
                    syms.insert(&bot->as<NamedValueExpression>().symbol);
                if (syms.count(sym))
                    return true;
            }
        }
    }
    return false;
}

const std::vector<UHDM::attribute*>* UhdmExporter::findAttrs(const Symbol* sym) {
    if (auto it = attrMap.find(sym); it != attrMap.end())
        return &it->second;
    for (auto& kv : attrMap)
        if (kv.first->location == sym->location && kv.first->name == sym->name)
            return &kv.second;
    return nullptr;
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
    // Gen-scope children scope their conn names at the GEN SCOPE.
    if (genvarConnFold && !genConnPrefix.empty())
        parentPrefix = genConnPrefix;

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
    auto* arrayNets = s.MakeArray_netVec();
    for (auto& it : collectNetOrder(body)) {
        std::string name(it.sym->name);
        std::string fullName = prefix + "." + name;
        // Implicit nets carry no typespec (and print a bare wire net type).
        bool implicitNet = it.sym->kind == SymbolKind::Net &&
                           it.sym->as<NetSymbol>().isImplicit;

        // Implicit nets not feeding a child instance conn are dropped from
        // the elab view (their cont_assigns share the def object bare).
        if (implicitNet && !implicitNetKeptInElab(it.sym, body))
            continue;
        // A real/shortreal var carries no typespec ref; its init is a vpiExpr.
        bool realVar = it.sym->getDeclaredType() &&
                       it.sym->getDeclaredType()->getType().isFloating();
        // Vector-typedef signals bind a fresh plain NAMED clone (built at
        // net-emission time, no alias link).
        // A signal typed by an alias-of-packed-array-of-alias FILE typedef
        // elaborates as a logic_var bound to the shared DESIGN ts (Surelog).
        // A signal declared straight from an UNPACKED-ARRAY typedef
        // (foobar_t fb): bare array_var referencing the SHARED named
        // array_typespec (Surelog).
        if (!implicitNet && !realVar) {
            if (auto dtu9 = it.sym->getDeclaredType()) {
                auto& tu9 = dtu9->getType();
                if (tu9.kind == SymbolKind::TypeAlias) {
                    if (auto ti9 = typedefTs.find(&tu9);
                        ti9 != typedefTs.end() &&
                        ti9->second->UhdmType() == UHDM::uhdmarray_typespec) {
                        auto* av9 = s.MakeArray_var();
                        av9->VpiName(name);
                        av9->VpiFullName(fullName);
                        av9->VpiParent(m);
                        setLoc(av9, nameSpan(it.sym->location, it.sym->name));
                        av9->VpiVisibility(1);
                        auto* rt9 = s.MakeRef_typespec();
                        rt9->VpiFullName(fullName);
                        rt9->VpiParent(av9);
                        rt9->Actual_typespec(ti9->second);
                        av9->Typespec(rt9);
                        topNets[it.sym] = av9;
                        sigOrder.emplace_back(it.sym, av9);
                        vars->push_back(av9);
                        continue;
                    }
                }
            }
        }
        if (!implicitNet && !realVar) {
            if (auto dtv2 = it.sym->getDeclaredType()) {
                auto& tv2 = dtv2->getType();
                if (tv2.kind == SymbolKind::TypeAlias &&
                    typedefTs.count(&tv2)) {
                    auto& tt2 = tv2.as<TypeAliasType>().targetType.getType();
                    if (tt2.kind == SymbolKind::PackedArrayType &&
                        tt2.as<PackedArrayType>().elementType.kind ==
                            SymbolKind::TypeAlias) {
                        // Enum-array typedefs (packed_array_typespec) get a
                        // BARE packed_array_var; vector aliases a logic_var.
                        UHDM::variables* v2 =
                            typedefTs[&tv2]->UhdmType() ==
                                    UHDM::uhdmpacked_array_typespec
                                ? (UHDM::variables*)s.MakePacked_array_var()
                                : (UHDM::variables*)s.MakeLogic_var();
                        v2->VpiName(name);
                        v2->VpiFullName(fullName);
                        v2->VpiParent(m);
                        setLoc(v2, nameSpan(it.sym->location, it.sym->name));
                        v2->VpiVisibility(1);
                        auto* rt2 = s.MakeRef_typespec();
                        rt2->VpiFullName(fullName);
                        rt2->VpiParent(v2);
                        rt2->Actual_typespec(typedefTs[&tv2]);
                        v2->Typespec(rt2);
                        topNets[it.sym] = v2;
                        sigOrder.emplace_back(it.sym, v2);
                        vars->push_back(v2);
                        continue;
                    }
                }
            }
        }
        UHDM::typespec* ts = nullptr;
        if (auto dtv = it.sym->getDeclaredType(); dtv && !implicitNet) {
            auto& tv = dtv->getType();
            // An IMPORTED-unqualified pkg-typedef signal (import pkg::T;
            // output T o) binds the SHARED pkg typespec, not a clone (the
            // elab PORT gets the clone instead — emitTopPorts).
            bool importedUnqual = false;
            if (tv.kind == SymbolKind::TypeAlias)
                if (auto sc0 = tv.as<TypeAliasType>().getParentScope();
                    sc0 && sc0->asSymbol().kind == SymbolKind::Package)
                    if (auto tsyn0 = dtv->getTypeSyntax();
                        tsyn0 && tsyn0->kind == syntax::SyntaxKind::NamedType &&
                        tsyn0->as<syntax::NamedTypeSyntax>().name->kind ==
                            syntax::SyntaxKind::IdentifierName)
                        importedUnqual = true;
            // A FILE-level vector-typedef signal also clones (named, at the
            // typedef target span, with a Typedef_alias ref to the shared
            // design ts — Surelog).
            bool fileLevelVec = false;
            if (tv.kind == SymbolKind::TypeAlias &&
                !typedefClone.count(&tv))
                if (auto sc1 = tv.as<TypeAliasType>().getParentScope();
                    sc1 &&
                    sc1->asSymbol().kind == SymbolKind::CompilationUnit)
                    if (auto tit1 = typedefTs.find(&tv);
                        tit1 != typedefTs.end() &&
                        tit1->second->UhdmType() == UHDM::uhdmlogic_typespec &&
                        tv.as<TypeAliasType>().targetType.getType().kind !=
                            SymbolKind::TypeAlias)
                        fileLevelVec = true;
            // A file-level vector-typedef PORT net binds the SHARED base ts:
            // Surelog gives the per-use clone to the PORT's vpiTypedef (see
            // portVectorTypedefClone), and leaves the port's NET pointing at
            // the bare design typedef. Non-port file-level nets still clone.
            if (!importedUnqual && fileLevelVec && it.port) {
                if (auto tit = typedefTs.find(&tv); tit != typedefTs.end())
                    ts = tit->second;
            }
            else if (!importedUnqual && (typedefClone.count(&tv) || fileLevelVec)) {
                const syntax::SyntaxNode* targetSyn = nullptr;
                if (auto asyn = tv.as<TypeAliasType>().getSyntax()) {
                    if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                        targetSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
                }
                bypassTypedefShare = true;
                // Non-port clone signals fold computed bounds BARE; a PORT'S
                // clone keeps the anchored fold (TypedefInModulePort).
                bareCloneComputedBounds = it.port == nullptr;
                ts = makeTypespec(*it.sym, targetSyn);
                bareCloneComputedBounds = false;
                bypassTypedefShare = false;
                ts->VpiName(tv.name);
                // Package-typedef clones keep the package instance link
                // (module-local clones carry none); file-level clones keep
                // the DESIGN instance link.
                if (auto tit0 = typedefTs.find(&tv);
                    tit0 != typedefTs.end() && tit0->second->Instance() &&
                    (tit0->second->Instance()->UhdmType() ==
                         UHDM::uhdmpackage ||
                     fileLevelVec))
                    ts->Instance(tit0->second->Instance());
                if (fileLevelVec &&
                    ts->UhdmType() == UHDM::uhdmlogic_typespec) {
                    auto* art9 = s.MakeRef_typespec();
                    art9->VpiFullName(tv.name);
                    art9->VpiParent(ts);
                    art9->Actual_typespec(typedefTs[&tv]);
                    ((UHDM::logic_typespec*)ts)->Typedef_alias(art9);
                }
                // MODULE-LOCAL vector-typedef NET clones in the elab view
                // carry a Typedef_alias ref to the shared module ts and the
                // module Instance (Surelog, net_types). Var-backed signals
                // keep the bare-clone form.
                else if (it.sym->kind == SymbolKind::Net &&
                         ts->UhdmType() == UHDM::uhdmlogic_typespec &&
                         !((UHDM::logic_typespec*)ts)->Typedef_alias()) {
                    if (auto tit9 = typedefTs.find(&tv);
                        tit9 != typedefTs.end()) {
                        if (auto sc9 = tv.as<TypeAliasType>().getParentScope();
                            sc9 && sc9->asSymbol().kind !=
                                       SymbolKind::Package) {
                            auto* art9 = s.MakeRef_typespec();
                            art9->VpiFullName(tv.name);
                            art9->VpiParent(ts);
                            art9->Actual_typespec(tit9->second);
                            ((UHDM::logic_typespec*)ts)->Typedef_alias(art9);
                            ts->Instance(tit9->second->Instance());
                        }
                    }
                }
            }
        }
        // An ANONYMOUS packed-struct signal (no typedef, no initializer)
        // gets a per-instance elab CLONE: instance-scoped member refs, span
        // over the `struct` keyword only, parented at the struct_net.
        bool anonStructClone = false;
        if (!ts && !implicitNet && !realVar) {
            if (auto dtv = it.sym->getDeclaredType();
                dtv && !dtv->getInitializer() &&
                dtv->getType().kind == SymbolKind::PackedStructType) {
                auto* sts = buildStructTs(
                    dtv->getType().as<PackedStructType>(), true, fullName);
                if (auto tsyn = dtv->getTypeSyntax())
                    if (auto* su =
                            tsyn->as_if<syntax::StructUnionTypeSyntax>())
                        setLoc(sts, su->keyword.range());
                ts = sts;
                anonStructClone = true;
            }
        }
        // A signal typed by a DIRECT packed array of a FILE-level vector
        // alias (reg8_t [0:3] in): the elab ts ref binds a NAMED clone of
        // the ELEMENT alias (Typedef_alias -> the shared design ts).
        if (!ts && !implicitNet && !realVar) {
            if (auto dtv3 = it.sym->getDeclaredType()) {
                auto& tv3 = dtv3->getType();
                if (tv3.kind == SymbolKind::PackedArrayType &&
                    tv3.as<PackedArrayType>().elementType.kind ==
                        SymbolKind::TypeAlias) {
                    auto& el3 = tv3.as<PackedArrayType>().elementType;
                    auto& ta3 = el3.as<TypeAliasType>();
                    auto tit3 = typedefTs.find(&el3);
                    bool fileLevel3 = false;
                    if (auto sc3 = ta3.getParentScope())
                        fileLevel3 = sc3->asSymbol().kind ==
                                     SymbolKind::CompilationUnit;
                    if (fileLevel3 && tit3 != typedefTs.end() &&
                        tit3->second->UhdmType() ==
                            UHDM::uhdmlogic_typespec) {
                        const syntax::SyntaxNode* tgtSyn3 = nullptr;
                        if (auto asyn3 = ta3.getSyntax())
                            if (asyn3->kind ==
                                syntax::SyntaxKind::TypedefDeclaration)
                                tgtSyn3 =
                                    asyn3->as<
                                             syntax::
                                                 TypedefDeclarationSyntax>()
                                        .type;
                        bypassTypedefShare = true;
                        auto* cl3 = makeTypespec(ta3, tgtSyn3);
                        bypassTypedefShare = false;
                        cl3->VpiName(ta3.name);
                        if (tgtSyn3)
                            setLoc(cl3, tgtSyn3->sourceRange());
                        auto* ar3 = s.MakeRef_typespec();
                        ar3->VpiFullName(ta3.name);
                        ar3->VpiParent(cl3);
                        ar3->Actual_typespec(tit3->second);
                        ((UHDM::logic_typespec*)cl3)->Typedef_alias(ar3);
                        ts = cl3;
                    }
                }
            }
        }
        // A `parameter type T`-typed port variable SHARES the type param's
        // resolved elab typespec object (Surelog).
        if (!ts && !implicitNet && !realVar) {
            if (auto* tpsym = portTypeParam(*it.sym))
                if (auto tit = typeParamElabTs.find(tpsym);
                    tit != typeParamElabTs.end())
                    ts = tit->second;
        }
        if (!ts && !implicitNet && !realVar) {
            boundOwnerFullName = fullName;
            ts = sharedTypespec(*it.sym, netTs);
            boundOwnerFullName.clear();
        }
        // Unpacked array of a NET-type leaf (reg memory): the instance view
        // is an array_net (vpiNet = logic_net), not an array_var.
        if (!implicitNet && !realVar &&
            unpackedArrayLeafIsNet(*it.sym, it.port != nullptr)) {
            if (auto* an = emitArrayNet(*it.sym, name, fullName, m, ts)) {
                // Share the def-view attribute objects onto both the array_net
                // and its element logic_net (Surelog attaches to both).
                if (auto* attrs = findAttrs(it.sym)) {
                    auto* av1 = s.MakeAttributeVec();
                    for (auto* ua : *attrs)
                        av1->push_back(ua);
                    an->Attributes(av1);
                    if (an->Nets() && !an->Nets()->empty()) {
                        auto* av2 = s.MakeAttributeVec();
                        for (auto* ua : *attrs)
                            av2->push_back(ua);
                        (*an->Nets())[0]->Attributes(av2);
                    }
                }
                topNets[it.sym] = an;
                sigOrder.emplace_back(it.sym, an);
                arrayNets->push_back(an);
                continue;
            }
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
        // (ranges + struct_var element), not a flat logic_var. A PORT stays a
        // net (packed_array_net, doubled element fullname).
        if (!implicitNet && !realVar) {
            if (it.port) {
                if (auto* pan = emitPackedStructArrayNet(*it.sym, name, fullName, m)) {
                    topNets[it.sym] = pan;
                    sigOrder.emplace_back(it.sym, pan);
                    nets->push_back(pan);
                    continue;
                }
            }
            else if (auto* pav = emitPackedStructArrayVar(*it.sym, name, fullName, m)) {
                topNets[it.sym] = pav;
                sigOrder.emplace_back(it.sym, pav);
                vars->push_back(pav);
                continue;
            }
            else if (auto* vav =
                         emitVectorTypedefArrayVar(*it.sym, name, fullName, m)) {
                topNets[it.sym] = vav;
                sigOrder.emplace_back(it.sym, vav);
                vars->push_back(vav);
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
                        // Like port-init calls, var-init call args carry no
                        // formal-ts ref (Surelog omits it in this view).
                        bool savePic = portInitCtx;
                        portInitCtx = true;
                        if (auto* e = emitExpr(ic, v, fullName, topNets))
                            v->Expr((UHDM::expr*)e);
                        portInitCtx = savePic;
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
                    // A PACKED-array assignment-pattern init ('{'{...},...}
                    // on logic[1:0][2:0][3:0]) keeps the FULL nested op75
                    // tree with the as-written leaf constants (Surelog).
                    else if (ic.kind == ExpressionKind::SimpleAssignmentPattern &&
                             dt->getType().getCanonicalType().isPackedArray()) {
                        if (auto* e = emitExpr(ic, v, fullName, topNets))
                            v->Expr((UHDM::expr*)e);
                    }
                    else if (ic.kind == ExpressionKind::UnaryOp &&
                             ic.as<UnaryExpression>().op == UnaryOperator::Minus &&
                             stripImplicitConv(ic.as<UnaryExpression>().operand())
                                     .kind == ExpressionKind::IntegerLiteral) {
                        // A NEGATED-literal init (int4_t x = -1): the minus
                        // operation is the var Expr; its constant operand is
                        // UNPARENTED and sized at the var width.
                        auto* nop = s.MakeOperation();
                        nop->VpiOpType(mapUnaryOp(UnaryOperator::Minus));
                        nop->VpiParent(v);
                        setLoc(nop, ic.sourceRange);
                        auto& lit0 =
                            stripImplicitConv(ic.as<UnaryExpression>().operand());
                        auto liv = lit0.as<IntegerLiteral>().getValue();
                        auto* c0 = s.MakeConstant();
                        std::string dg0 = liv.toString(LiteralBase::Decimal, false);
                        c0->VpiDecompile(dg0);
                        c0->VpiSize((int32_t)dt->getType().getBitWidth());
                        c0->VpiValue("UINT:" + dg0);
                        c0->VpiConstType(vpiUIntConst);
                        setLoc(c0, lit0.sourceRange);
                        auto* nops = s.MakeAnyVec();
                        nops->push_back(c0);
                        nop->Operands(nops);
                        v->Expr(nop);
                    }
                    else if (ic.kind == ExpressionKind::NamedValue && !enumRef &&
                             ic.as<NamedValueExpression>().symbol.kind ==
                                 SymbolKind::Parameter) {
                        // A PARAM-ref init (logic [127:0] b = y_int) FOLDS to
                        // the param's value (sized at the var width) with a ts
                        // ref to the param's typespec (scoped at the var).
                        auto& psym =
                            ic.as<NamedValueExpression>().symbol.as<ParameterSymbol>();
                        auto& pcv = psym.getValue();
                        if (pcv.isInteger() && !pcv.integer().hasUnknown()) {
                            auto piv = pcv.integer();
                            bool neg = piv.isSigned() && piv.isNegative();
                            // A CONST-FUNCTION-CALL-initialized param folds
                            // INT (signed return) with NO ts ref (Surelog).
                            bool callSigned = false;
                            if (auto* pini = psym.getInitializer()) {
                                bool hasCall = false;
                                pini->visit(makeVisitor(
                                    [&](auto& v9, const CallExpression& cc9) {
                                        if (!cc9.isSystemCall())
                                            hasCall = true;
                                        v9.visitDefault(cc9);
                                    }));
                                callSigned = hasCall && piv.isSigned();
                            }
                            // toString(Decimal, false) already includes the
                            // sign for a negative signed value.
                            std::string digits = piv.toString(LiteralBase::Decimal, false);
                            auto* c = s.MakeConstant();
                            c->VpiParent(v);
                            c->VpiSize((int32_t)dt->getType().getBitWidth());
                            c->VpiDecompile(digits);
                            c->VpiValue((neg || callSigned ? "INT:" : "UINT:") +
                                        digits);
                            c->VpiConstType(neg || callSigned ? vpiIntConst
                                                              : vpiUIntConst);
                            setLoc(c, ic.sourceRange);
                            bool tP = false;
                            if (auto d2 = psym.getDeclaredType())
                                if (auto t2 = d2->getTypeSyntax())
                                    tP = t2->kind != syntax::SyntaxKind::ImplicitType;
                            if (!callSigned)
                                if (auto* its = makeParamTs(psym, tP)) {
                                    auto* rt = s.MakeRef_typespec();
                                    rt->VpiFullName(fullName);
                                    rt->VpiParent(c);
                                    rt->Actual_typespec(its);
                                    c->Typespec(rt);
                                }
                            v->Expr((UHDM::expr*)c);
                        }
                    }
                    else if (ic.kind == ExpressionKind::NamedValue && !enumRef) {
                        // A VAR-ref init (int8_t y = int4): a ref_obj scoped
                        // through the initialized var (work@top.y.int4) whose
                        // actual is the referenced var object.
                        auto& rsym = ic.as<NamedValueExpression>().symbol;
                        auto* r0 = s.MakeRef_obj();
                        r0->VpiName(rsym.name);
                        r0->VpiFullName(fullName + "." + std::string(rsym.name));
                        r0->VpiParent(v);
                        setLoc(r0, ic.sourceRange);
                        if (auto tit0 = topNets.find(&rsym); tit0 != topNets.end())
                            r0->Actual_group(tit0->second);
                        v->Expr((UHDM::expr*)r0);
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
                            // A pkg-scoped enum-const init on an enum_var
                            // parents at the var.
                            if (enumRef && e->UhdmType() == UHDM::uhdmconstant &&
                                !e->VpiParent())
                                e->VpiParent(v);
                            v->Expr((UHDM::expr*)e);
                        }
                        forceConstParent = forceSaved;
                    }
                }
                // A port-backed var whose PORT carries an initializer (and the
                // var itself none) holds the FOLDED substituted value as
                // vpiExpr.
                if (!dt->getInitializer() && it.port && it.port->getInitializer()) {
                    auto* pinit = it.port->getInitializer();
                    ASTContext pctx(comp.getRoot(), LookupLocation::max);
                    ConstantValue pcv = pctx.tryEval(*pinit);
                    if (pcv && pcv.isInteger() && !pcv.integer().hasUnknown()) {
                        auto piv = pcv.integer();
                        // A CALL-folded init encodes signed (INT); a literal
                        // stays UINT.
                        bool isCall =
                            stripImplicitConv(*pinit).kind == ExpressionKind::Call;
                        std::string digits = piv.toString(LiteralBase::Decimal, false);
                        auto* rc = s.MakeConstant();
                        rc->VpiParent(v);
                        rc->VpiSize((int32_t)dt->getType().getBitWidth());
                        rc->VpiDecompile(digits);
                        rc->VpiValue((isCall ? "INT:" : "UINT:") + digits);
                        rc->VpiConstType(isCall ? vpiIntConst : vpiUIntConst);
                        setLoc(rc, pinit->sourceRange);
                        v->Expr((UHDM::expr*)rc);
                    }
                }
            }
            if (auto* attrs = findAttrs(it.sym)) {
                auto* av = s.MakeAttributeVec();
                for (auto* ua : *attrs)
                    av->push_back(ua);
                v->Attributes(av);
            }
            // Vars creation-parent their (non-typedef) typespec like nets;
            // a shared decl-group ts ends at the group's last var.
            if (ts && ts->UhdmType() != UHDM::uhdmenum_typespec &&
                ts->UhdmType() != UHDM::uhdmstruct_typespec && ts->VpiName().empty())
                ts->VpiParent(v);
            // Initialized plain-typed vars span declarator..init; a var of a
            // pkg typedef-ALIAS type (lc_ctrl_pkg::lc_tx_t x = ...) does too.
            bool aliasOfAlias = false;
            if (it.sym->getDeclaredType() &&
                it.sym->getDeclaredType()->getType().kind == SymbolKind::TypeAlias) {
                auto& at0 = it.sym->getDeclaredType()->getType().as<TypeAliasType>();
                if (at0.targetType.getType().kind == SymbolKind::TypeAlias)
                    if (auto sc0 = at0.getParentScope();
                        sc0 && sc0->asSymbol().kind == SymbolKind::Package)
                        aliasOfAlias = true;
            }
            if (auto dtl = it.sym->getDeclaredType();
                dtl && dtl->getInitializer() &&
                (realVar || aliasOfAlias || (ts && ts->VpiName().empty()))) {
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
            // Packed-struct signals — and anonymous packed/unpacked union
            // signals — become struct_nets in the instance view.
            bool isStruct = false;
            if (auto dt = it.sym->getDeclaredType())
                isStruct = dt->getType().getCanonicalType().kind ==
                               SymbolKind::PackedStructType ||
                           dt->getType().kind == SymbolKind::PackedUnionType ||
                           dt->getType().kind == SymbolKind::UnpackedUnionType;
            // A packed-struct signal WITH an initializer is a struct_VAR
            // (the init becomes its vpiExpr, operands unparented), spanning
            // the declarator name.
            // A pkg-typedef struct with a packed-ARRAY-of-struct member
            // elaborates as a struct_var (ts ref -> the shared pkg TOP ts);
            // direct-struct containers stay untyped logic_nets.
            bool arrOfStructMember = false;
            if (auto dtA = it.sym->getDeclaredType()) {
                auto& ctA = dtA->getType().getCanonicalType();
                if (ctA.isStruct())
                    for (auto& fA : ctA.as<Scope>().members())
                        if (fA.kind == SymbolKind::Field) {
                            auto& fct = fA.as<FieldSymbol>()
                                            .getType()
                                            .getCanonicalType();
                            if (fct.kind == SymbolKind::PackedArrayType) {
                                const Type* el = &fct;
                                while (el->getCanonicalType().kind ==
                                       SymbolKind::PackedArrayType)
                                    el = &el->getCanonicalType()
                                              .as<PackedArrayType>()
                                              .elementType;
                                if (el->getCanonicalType().isStruct())
                                    arrOfStructMember = true;
                            }
                        }
            }
            if (isStruct && arrOfStructMember && isPkgStructType(*it.sym) &&
                !it.sym->getDeclaredType()->getInitializer()) {
                auto* sv = s.MakeStruct_var();
                sv->VpiName(name);
                sv->VpiFullName(fullName);
                sv->VpiParent(m);
                setLoc(sv, nameSpan(it.sym->location, it.sym->name));
                sv->VpiVisibility(1);
                if (rt) {
                    rt->VpiParent(sv);
                    sv->Typespec(rt);
                }
                topNets[it.sym] = sv;
                sigOrder.emplace_back(it.sym, sv);
                vars->push_back(sv);
                continue;
            }
            // A packed-struct signal initialized by an ASSIGNMENT PATTERN
            // ('{...}) is a struct_NET whose init becomes a net-decl cont_assign
            // (Surelog) — a bare-expression init (concat, literal) stays a
            // struct_VAR carrying the init as its vpiExpr.
            bool patternInit = false;
            if (auto* ini = it.sym->getDeclaredType()->getInitializer()) {
                auto k = stripImplicitConv(*ini).kind;
                patternInit = k == ExpressionKind::SimpleAssignmentPattern ||
                              k == ExpressionKind::StructuredAssignmentPattern ||
                              k == ExpressionKind::ReplicatedAssignmentPattern;
            }
            if (isStruct && it.sym->getDeclaredType()->getInitializer() &&
                !patternInit) {
                auto* sv = s.MakeStruct_var();
                sv->VpiName(name);
                sv->VpiFullName(fullName);
                sv->VpiParent(m);
                setLoc(sv, nameSpan(it.sym->location, it.sym->name));
                sv->VpiVisibility(1);
                if (rt) {
                    rt->VpiParent(sv);
                    sv->Typespec(rt);
                }
                bool savedS = suppressConstParent, savedF = forceConstParent;
                suppressConstParent = true;
                forceConstParent = false;
                if (auto* e = emitExpr(*it.sym->getDeclaredType()->getInitializer(),
                                       sv, fullName, topNets)) {
                    sv->Expr((UHDM::expr*)e);
                    e->VpiParent(sv);
                }
                suppressConstParent = savedS;
                forceConstParent = savedF;
                topNets[it.sym] = sv;
                sigOrder.emplace_back(it.sym, sv);
                vars->push_back(sv);
                continue;
            }
            UHDM::net* n = isStruct ? (UHDM::net*)s.MakeStruct_net()
                                    : (UHDM::net*)s.MakeLogic_net();
            n->VpiName(name);
            n->VpiFullName(fullName);
            n->VpiParent(m);
            if (it.port && !it.bodyDecl)
                setLocNamed(n, *it.port);
            else if (patternInit && isStruct)
                // A pattern-init struct_net spans the NAME only (the init lives
                // in its net-decl cont_assign, not the net decl).
                setLoc(n, nameSpan(it.sym->location, it.sym->name));
            else
                setLoc(n, regNetSpan(*it.sym));
            if (!isStruct) {
                if (int32_t nt = netTypeFor(*it.sym))
                    ((UHDM::logic_net*)n)->VpiNetType(nt);
                // An explicit PREDEFINED-INTEGER net decl (wire integer x)
                // prints NO vpiSigned in the module listing (Surelog).
                bool intBody9 =
                    it.sym->kind == SymbolKind::Net &&
                    hasExplicitNetKeyword(*it.sym) &&
                    it.sym->getDeclaredType() &&
                    it.sym->getDeclaredType()
                            ->getType()
                            .getCanonicalType()
                            .kind == SymbolKind::PredefinedIntegerType;
                if (!intBody9 && it.sym->getDeclaredType() &&
                    it.sym->getDeclaredType()->getType().isSigned())
                    n->VpiSigned(true);
            }
            else if (it.port && n->UhdmType() == UHDM::uhdmlogic_net &&
                     isPkgStructType(*it.sym) &&
                     isExplicitPkgQualified(*it.sym))
                ((UHDM::logic_net*)n)->VpiNetType(vpiWire);
            // A pkg-typedef struct net (non-port, flat members) is a WIRE
            // struct_net; nested-struct members stay untyped.
            else if (isStruct && isPkgStructType(*it.sym) &&
                     isExplicitPkgQualified(*it.sym) &&
                     !hasStructFieldMember(*it.sym))
                ((UHDM::struct_net*)n)->VpiNetType(vpiWire);
            if (rt) {
                rt->VpiParent(n);
                n->Typespec(rt);
            }
            // The instance-view net shares the def-view attribute objects.
            if (auto* attrs = findAttrs(it.sym)) {
                auto* av = s.MakeAttributeVec();
                for (auto* ua : *attrs)
                    av->push_back(ua);
                n->Attributes(av);
            }
            // Surelog parents the net typespec at creation; a shared
            // declaration-group typespec ends at the group's last net.
            // Typedef typespecs keep their own parent.
            if (ts && (anonStructClone ||
                       (ts->UhdmType() != UHDM::uhdmenum_typespec &&
                        ts->UhdmType() != UHDM::uhdmstruct_typespec)))
                ts->VpiParent(n);
            // An INPUT struct port driven by a LITERAL constant at its
            // instantiation is a struct_VAR (vpiVariables, Visibility) in
            // the elab view (MUSI); signal-fed struct ports stay nets
            // (simple_struct/DotRange distinguisher).
            bool litConnVar9 = false;
            if (isStruct && it.port && !it.bodyDecl) {
                for (auto pc9 : inst.getPortConnections()) {
                    if (&pc9->port != (const Symbol*)it.port)
                        continue;
                    if (auto* pe9 = pc9->getExpression()) {
                        const Expression* ce9 = pe9;
                        if (ce9->kind == ExpressionKind::Assignment)
                            ce9 = &ce9->as<AssignmentExpression>().right();
                        if (stripImplicitConv(*ce9).kind ==
                            ExpressionKind::IntegerLiteral)
                            litConnVar9 = true;
                    }
                    break;
                }
            }
            if (litConnVar9) {
                auto* sv9 = s.MakeStruct_var();
                sv9->VpiName(name);
                sv9->VpiFullName(fullName);
                sv9->VpiParent(m);
                sv9->VpiLineNo(n->VpiLineNo());
                sv9->VpiColumnNo(n->VpiColumnNo());
                sv9->VpiEndLineNo(n->VpiEndLineNo());
                sv9->VpiEndColumnNo(n->VpiEndColumnNo());
                sv9->VpiVisibility(1);
                if (auto* rt9 = n->Typespec()) {
                    rt9->VpiParent(sv9);
                    sv9->Typespec(rt9);
                }
                topNets[it.sym] = sv9;
                sigOrder.emplace_back(it.sym, sv9);
                vars->push_back(sv9);
                continue;
            }
            topNets[it.sym] = n;
            sigOrder.emplace_back(it.sym, n);
            nets->push_back(n);
        }
    }
    if (!nets->empty())
        m->Nets(nets);
    if (!vars->empty())
        m->Variables(vars);
    if (!arrayNets->empty())
        ((UHDM::instance*)m)->Array_nets(arrayNets);

    // Children are elaborated before the instance's own ports (typespec
    // creation order follows Surelog).
    if (isTop) {
        currentTopPrefix = prefix;
        currentTopNets = &topNets;
    }
    // Interface PORTS and their instance-scoped views are emitted BEFORE
    // the children (their typespecs/views precede child objects in
    // Surelog's arena); regular ports keep the children-first order.
    std::map<const Symbol*, UHDM::port*> ifacePortObjs;
    auto* portIfaces = s.MakeInterface_instVec();
    if (!isTop) {
        std::vector<UHDM::port*> ifPortList;
        for (auto portBase : body.getPortList()) {
            if (portBase->kind != SymbolKind::InterfacePort)
                continue;
            {
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
                p->VpiDirection(interfacePortDirection(ip));
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
                    // An interface-ARRAY element connection (.b(arr[0])): a
                    // bit_select named by the array, scoped by this producer
                    // instance (work@dut.p0.arr), index = the element constant.
                    std::string::size_type albr;
                    if ((albr = connRaw.find('[')) != std::string::npos &&
                        !connRaw.empty() && connRaw.back() == ']') {
                        std::string base = connRaw.substr(0, albr);
                        std::string idxS =
                            connRaw.substr(albr + 1, connRaw.size() - albr - 2);
                        auto* bs = s.MakeBit_select();
                        bs->VpiName(base);
                        bs->VpiFullName(prefix + "." + base);
                        bs->VpiParent(p);
                        if (iconn && connectionExpr(*iconn))
                            setLoc(bs, connectionExpr(*iconn)->sourceRange);
                        auto* ic = s.MakeConstant();
                        ic->VpiValue("UINT:" + idxS);
                        ic->VpiDecompile(idxS);
                        ic->VpiSize(64);
                        ic->VpiConstType(vpiUIntConst);
                        ic->VpiParent(bs);
                        if (iconn && connectionExpr(*iconn))
                            setLoc(ic, connectionExpr(*iconn)->sourceRange);
                        bs->VpiIndex(ic);
                        p->High_conn(bs);
                    }
                    else if (auto iit = ifaceInstMap.find(conn.first);
                        iit != ifaceInstMap.end()) {
                        auto* hc = s.MakeRef_obj();
                        hc->VpiName(conn.first->name);
                        hc->VpiFullName(parentPrefix + "." +
                                        std::string(conn.first->name));
                        hc->VpiParent(p);
                        // Points at the col-0 tail duplicate of the interface
                        // (weak ref → weaklyReferenced tail), falling back to
                        // the home view when no dup exists. A PASSTHROUGH
                        // (the conn names the ENCLOSING module's own iface
                        // PORT) binds that module's port view instead.
                        const Symbol* connSite = nullptr;
                        if (iconn && connectionExpr(*iconn))
                            if (auto ps9 = inst.getParentScope())
                                connSite = ps9->find(
                                    rawText(connectionExpr(*iconn)->sourceRange));
                        auto pvIt = connSite && connSite->kind == SymbolKind::InterfacePort
                                        ? ifacePortViewMap.find(connSite)
                                        : ifacePortViewMap.end();
                        auto dit = ifaceTailDup.find(conn.first);
                        hc->Actual_group(pvIt != ifacePortViewMap.end() ? pvIt->second
                                         : dit != ifaceTailDup.end()   ? dit->second
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
                ifacePortObjs[portBase] = p;
                ifPortList.push_back(p);
            }
        }
        for (auto portBase : body.getPortList()) {
            if (portBase->kind != SymbolKind::InterfacePort)
                continue;
            auto& ip = portBase->as<InterfacePortSymbol>();
            auto conn = ip.getConnection();
            if (conn.first && conn.first->kind == SymbolKind::Instance) {
                auto* ii = emitInterfaceInstance(
                    conn.first->as<InstanceSymbol>(),
                    prefix + "." + std::string(portBase->name), m, &topNets, &instRefs,
                    /*portView=*/&inst, /*connModport=*/std::string(ip.modport));
                // A port view is named by the PORT, not the connected instance.
                ii->VpiName(std::string(portBase->name));
                portIfaces->push_back(ii);
                ifacePortViewMap[portBase] = ii;
                // A plain (no-modport) interface port lists the view TWICE
                // under vpiInterface and re-points the LowConn ref at it,
                // dropping the ref's port parent (Surelog quirks).
                if (ip.modport.empty()) {
                    portIfaces->push_back(ii);
                    for (auto* pp : ifPortList)
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
                    for (auto* pp : ifPortList)
                        if (pp->VpiName() == ip.name && pp->Low_conn() &&
                            pp->Low_conn()->UhdmType() == UHDM::uhdmref_obj)
                            for (auto* umod : *ii->Modports())
                                if (umod->VpiName() == ip.modport)
                                    ((UHDM::ref_obj*)pp->Low_conn())
                                        ->Actual_group(umod);
            }
        }
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
            bool fromBind = false, bindInGen = false;
            const syntax::BindDirectiveSyntax* bindSyn = nullptr;
            for (auto p2 = child.getSyntax(); p2; p2 = p2->parent) {
                if (p2->kind == syntax::SyntaxKind::BindDirective) {
                    fromBind = true;
                    bindSyn = &p2->as<syntax::BindDirectiveSyntax>();
                }
                else if (fromBind &&
                         (p2->kind == syntax::SyntaxKind::GenerateBlock ||
                          p2->kind == syntax::SyntaxKind::GenerateRegion ||
                          p2->kind == syntax::SyntaxKind::IfGenerate ||
                          p2->kind == syntax::SyntaxKind::LoopGenerate)) {
                    bindInGen = true;
                    break;
                }
            }
            // A bind directive INSIDE A GENERATE SCOPE never materializes
            // (Surelog drops it; the bound def's port phase still runs in
            // the write phase).
            if (fromBind && bindInGen) {
                droppedBindDefs.insert(&child.getDefinition());
                continue;
            }
            // An INSTANCE-PATH-target bind (bind top.foo_i / $root.top.foo_i)
            // materializes in the DEF view only — Surelog's ELAB omits the
            // bound child. Module-NAME targets (bind foo ...) keep it. The
            // bound def's port phase still runs in the write phase.
            if (fromBind && bindSyn &&
                bindSyn->target->kind != syntax::SyntaxKind::IdentifierName) {
                droppedBindDefs.insert(&child.getDefinition());
                continue;
            }
            if (fromBind && !currentTopPrefix.empty())
                bindDisplayPath = currentTopPrefix + "." + std::string(child.name);
            children->push_back(emitInstance(child, prefix + "." + std::string(child.name), m,
                                             &topNets, &instRefs, /*isTop=*/false));
            bindDisplayPath.clear();
        }
        else if (member.kind == SymbolKind::InstanceArray) {
            auto& arr = member.as<InstanceArraySymbol>();
            // The module_array object lives in the DEF view ONLY (emitModuleDef);
            // the ELAB view carries just the per-index interface_inst elements
            // under vpiInterface (Surelog — the elab dut has no vpiModuleArray).
            int32_t alo = std::min(arr.range.left, arr.range.right);
            for (size_t i = 0; i < arr.elements.size(); i++) {
                auto* e = arr.elements[i];
                if (!e || e->kind != SymbolKind::Instance ||
                    !useInterfacePath(e->as<InstanceSymbol>()))
                    continue;
                std::string iname = std::string(arr.name) + "[" +
                                    std::to_string(alo + (int32_t)i) + "]";
                std::string ipath = prefix + "." + iname;
                auto* ii = emitInterfaceInstance(e->as<InstanceSymbol>(), ipath,
                                                 m, &topNets, &instRefs);
                ii->VpiName(iname);
                ifaceChildren->push_back(ii);
            }
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
            // Elab InterfacePort: emitted in the pre-children pass above.
            if (portBase->kind == SymbolKind::InterfacePort) {
                if (auto it9 = ifacePortObjs.find(portBase);
                    it9 != ifacePortObjs.end())
                    ports->push_back(it9->second);
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
                const Expression* connE9 = connectionExpr(*conn);
                // A DEFAULT-value connection (port left unconnected, falling
                // back to its declared default) carries NO HighConn
                // (Surelog) — its expr lives at the CHILD's port decl,
                // outside the instantiation syntax.
                if (connE9) {
                    if (auto isyn9 = inst.getSyntax()) {
                        auto ir9 = isyn9->sourceRange();
                        auto es9 = connE9->sourceRange.start();
                        if (es9 != SourceLocation::NoLocation &&
                            (es9 < ir9.start() || es9 > ir9.end())) {
                            // Default-value conn: a folded 64-bit UINT
                            // constant HighConn (unparented — Surelog).
                            ASTContext dctx9(comp.getRoot(),
                                             LookupLocation::max);
                            ConstantValue dcv9 = dctx9.tryEval(*connE9);
                            if (dcv9 && dcv9.isInteger() &&
                                !dcv9.integer().hasUnknown()) {
                                auto* cH9 = s.MakeConstant();
                                std::string dg9 = dcv9.integer().toString(
                                    LiteralBase::Decimal, false);
                                cH9->VpiDecompile(dg9);
                                cH9->VpiSize(64);
                                cH9->VpiValue("UINT:" + dg9);
                                cH9->VpiConstType(vpiUIntConst);
                                setLoc(cH9, stripImplicitConv(*connE9)
                                                .sourceRange);
                                p->High_conn(cH9);
                            }
                            connE9 = nullptr;
                        }
                    }
                }
                if (auto expr = connE9) {
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
                    // An UNPACKED-ARRAY pattern conn with a SINGLE element
                    // flattens to the ELEMENT pattern, carrying a nameless
                    // ts ref to the shared element typedef ts (Surelog).
                    if (!h) {
                        auto& hcA = stripImplicitConv(*expr);
                        if (hcA.kind ==
                                ExpressionKind::SimpleAssignmentPattern &&
                            hcA.type &&
                            hcA.type->getCanonicalType().kind ==
                                SymbolKind::FixedSizeUnpackedArrayType) {
                            auto els9 =
                                hcA.as<SimpleAssignmentPatternExpression>()
                                    .elements();
                            if (els9.size() == 1) {
                                auto& in9 = stripImplicitConv(*els9[0]);
                                if (in9.kind == ExpressionKind::
                                                    StructuredAssignmentPattern ||
                                    in9.kind ==
                                        ExpressionKind::SimpleAssignmentPattern) {
                                    bool savedRe9 = reemitting;
                                    reemitting = true;
                                    h = emitExpr(in9, p, hcPrefix,
                                                 *parentNets);
                                    reemitting = savedRe9;
                                    if (h && h->UhdmType() ==
                                                 UHDM::uhdmoperation) {
                                        auto& etA =
                                            hcA.type->getCanonicalType()
                                                .as<FixedSizeUnpackedArrayType>()
                                                .elementType;
                                        UHDM::typespec* etsA = nullptr;
                                        if (auto tiA = typedefTs.find(&etA);
                                            tiA != typedefTs.end())
                                            etsA = tiA->second;
                                        else if (auto tiB =
                                                     pkgTopTypedefTs.find(&etA);
                                                 tiB != pkgTopTypedefTs.end())
                                            etsA = tiB->second;
                                        if (etsA) {
                                            // PARENTLESS ref -> prints
                                            // nameless (fullname is
                                            // synthesized from parents).
                                            auto* rtA = s.MakeRef_typespec();
                                            rtA->Actual_typespec(etsA);
                                            ((UHDM::operation*)h)->Typespec(
                                                rtA);
                                        }
                                    }
                                }
                            }
                        }
                    }
                    // A named UNPACKED-ARRAY-of-packed-struct PARAM connection
                    // (.port(HwDataAttr)) folds, in Surelog's elab, to the SAME
                    // op75 the param's elab RHS uses: a conn-scoped array_typespec
                    // ts ref (prefix.inst.port) over the folded pattern operands.
                    if (!h) {
                        auto& ce9 = stripImplicitConv(*expr);
                        if (ce9.kind == ExpressionKind::NamedValue) {
                            auto& csym9 = ce9.as<NamedValueExpression>().symbol;
                            if (csym9.kind == SymbolKind::Parameter &&
                                csym9.as<ParameterSymbol>()
                                        .getType()
                                        .getCanonicalType()
                                        .kind ==
                                    SymbolKind::FixedSizeUnpackedArrayType) {
                                auto& pp9 = csym9.as<ParameterSymbol>();
                                UHDM::typespec* arrTs9 = nullptr;
                                if (auto pit9 = pkgParamObj.find(&csym9);
                                    pit9 != pkgParamObj.end() &&
                                    pit9->second->Typespec())
                                    arrTs9 = pit9->second->Typespec()
                                                 ->Actual_typespec();
                                if (arrTs9 && pp9.getInitializer()) {
                                    std::string cfn9 =
                                        prefix + "." + std::string(inst.name) +
                                        "." + std::string(ps.name);
                                    if (auto* fop9 =
                                            foldUnpackedStructArrayPattern(
                                                *pp9.getInitializer(),
                                                pp9.getType(), arrTs9, cfn9, p,
                                                hcPrefix, *parentNets))
                                        h = fop9;
                                }
                            }
                        }
                    }
                    if (!h)
                        h = emitExpr(*expr, p, hcPrefix, *parentNets);
                    // Child bit_select HighConns double through the CHILD
                    // INSTANCE name (gen scopes via genConnPrefix; regular
                    // children via the parent prefix) — Surelog.
                    if (h && h->UhdmType() == UHDM::uhdmbit_select) {
                        auto* bsx = (UHDM::bit_select*)h;
                        const std::string& dblPfx =
                            (genvarConnFold && !genConnPrefix.empty())
                                ? genConnPrefix
                                : hcPrefix;
                        bsx->VpiFullName(dblPfx + "." +
                                         std::string(inst.name) + "." +
                                         std::string(bsx->VpiName()));
                    }
                    // A CALL HighConn's arg refs scope through the child
                    // instance + formal and stay UNBOUND (Surelog). The
                    // called imported function lists on the ENCLOSING module;
                    // gen-scope conns also materialize an implicit wire.
                    if (h && h->UhdmType() == UHDM::uhdmfunc_call) {
                        auto* fc9h = (UHDM::func_call*)h;
                        if (auto* fn9 = fc9h->Function(); fn9 && parentM) {
                            pendingConnTfList.push_back(
                                {parentM, (UHDM::task_func*)fn9});
                            // The conn-call registration keyed the CHILD's
                            // body — the child does NOT list it (Surelog).
                            for (auto& [k9, v9] : importedTfCalls)
                                v9.erase(std::remove_if(
                                             v9.begin(), v9.end(),
                                             [&](auto& pr9) {
                                                 return pr9.first ==
                                                        (UHDM::task_func*)fn9;
                                             }),
                                         v9.end());
                        }
                        if (genvarConnFold)
                            pendingGenCallNets.push_back(
                                {std::string(fc9h->VpiName()),
                                 stripImplicitConv(*expr).sourceRange});
                        const std::string& dblPfx =
                            (genvarConnFold && !genConnPrefix.empty())
                                ? genConnPrefix
                                : hcPrefix;
                        std::string argPfx = dblPfx + "." +
                                             std::string(inst.name) + "." +
                                             std::string(ps.name) + ".";
                        if (auto* args9 =
                                ((UHDM::func_call*)h)->Tf_call_args())
                            for (auto* a9 : *args9) {
                                if (a9->UhdmType() != UHDM::uhdmref_obj)
                                    continue;
                                auto* r9 = (UHDM::ref_obj*)a9;
                                r9->VpiFullName(argPfx +
                                                std::string(r9->VpiName()));
                                r9->Actual_group(nullptr);
                                if (auto* rt9 = r9->Typespec())
                                    rt9->VpiFullName(
                                        argPfx + std::string(r9->VpiName()));
                            }
                    }
                    // A CONCAT HighConn's direct ref operands scope through
                    // the child instance + formal too (Surelog).
                    if (h && h->UhdmType() == UHDM::uhdmoperation &&
                        ((UHDM::operation*)h)->VpiOpType() == vpiConcatOp) {
                        const std::string& dblPfx =
                            (genvarConnFold && !genConnPrefix.empty())
                                ? genConnPrefix
                                : hcPrefix;
                        std::string opPfx = dblPfx + "." +
                                            std::string(inst.name) + "." +
                                            std::string(ps.name) + ".";
                        if (auto* ops9 = ((UHDM::operation*)h)->Operands())
                            for (auto* o9 : *ops9)
                                if (o9->UhdmType() == UHDM::uhdmref_obj) {
                                    auto* r9 = (UHDM::ref_obj*)o9;
                                    r9->VpiFullName(
                                        opPfx + std::string(r9->VpiName()));
                                }
                    }
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

            UHDM::typespec* pts = nullptr;
            // A `parameter type T`-typed port's vpiTypedef shares the ONE
            // def-view type-param DEFAULT typespec object (Surelog).
            if (auto* tpp = portTypeParam(*internal)) {
                auto tit = typeParamDefaultTs.find(
                    {(const void*)&inst.getDefinition(), std::string(tpp->name)});
                if (tit != typeParamDefaultTs.end())
                    pts = tit->second;
            }
            if (!pts)
                pts = makeTypespec(*internal, nullptr, &ps);
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(prefix + "." + std::string(ps.name));
            rt->VpiParent(p);
            rt->Actual_typespec(pts);
            p->Typespec(rt);
            ports->push_back(p);
        }
        if (!ports->empty())
            m->Ports(ports);
        // Interfaces: declared iface children first, then the port views
        // (built in the pre-children pass).
        auto* allIf = s.MakeInterface_instVec();
        if (ifaceChildren)
            for (auto* ic : *ifaceChildren)
                allIf->push_back(ic);
        for (auto* pv : *portIfaces)
            allIf->push_back(pv);
        if (!allIf->empty())
            m->Interfaces(allIf);
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

    emitGates(body, m, prefix, topNets, /*topView=*/true);

    // Generate scopes exist only in the instance view.
    emitGenScopes(body, m, prefix, topNets);
    // Imported pkg functions called from GEN-SCOPE conns register during
    // emitGenScopes — drain them into the module list late (the def-phase
    // drain has already run).
    if (auto itf9 = importedTfCalls.find((const Scope*)&body);
        itf9 != importedTfCalls.end() && !itf9->second.empty()) {
        auto* v9 = m->Task_funcs();
        if (!v9) {
            v9 = s.MakeTask_funcVec();
            m->Task_funcs(v9);
        }
        for (auto& [tf9, rg9] : itf9->second)
            if (std::find(v9->begin(), v9->end(), tf9) == v9->end())
                v9->push_back(tf9);
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
        {
            auto* procs = s.MakeProcess_stmtVec();
        // An OUTPUT port INITIALIZER synthesizes a loc-less initial
        // assigning the folded value: bare Lhs ref, Rhs = a use-site clone
        // of the param's elab constant (Surelog).
        for (auto portBase : body.getPortList()) {
            if (portBase->kind != SymbolKind::Port)
                continue;
            auto& ps9 = portBase->as<PortSymbol>();
            if (ps9.direction != ArgumentDirection::Out)
                continue;
            const Expression* init9 = ps9.getInitializer();
            if (!init9 && ps9.internalSymbol)
                if (auto* dts9 = ps9.internalSymbol->getDeclaredType())
                    init9 = dts9->getInitializer();
            if (!init9)
                continue;
            auto& ic9 = stripImplicitConv(*init9);
            // A LITERAL init (output reg a_old = 0) synthesizes the same
            // loc-less initial with a bare 64-bit fold (Surelog) — but NOT
            // for predefined-integer outputs (integer w = 16), whose init
            // rides on the var's vpiExpr instead.
            if (ic9.kind == ExpressionKind::IntegerLiteral &&
                !(ps9.internalSymbol && ps9.internalSymbol->getDeclaredType() &&
                  ps9.internalSymbol->getDeclaredType()
                          ->getType()
                          .getCanonicalType()
                          .kind == SymbolKind::PredefinedIntegerType)) {
                auto* iniL = s.MakeInitial();
                auto* asL = s.MakeAssignment();
                asL->VpiParent(iniL);
                setLoc(asL, nameSpan(ps9.location, ps9.name));
                auto* lrL = s.MakeRef_obj();
                lrL->VpiName(ps9.name);
                lrL->VpiParent(asL);
                setLoc(lrL, nameSpan(ps9.location, ps9.name));
                asL->Lhs(lrL);
                auto ivL = ic9.as<IntegerLiteral>().getValue();
                auto* rcL = s.MakeConstant();
                std::string dgL = ivL.toString(LiteralBase::Decimal, false);
                rcL->VpiDecompile(dgL);
                rcL->VpiSize(64);
                rcL->VpiValue("UINT:" + dgL);
                rcL->VpiConstType(vpiUIntConst);
                setLoc(rcL, ic9.sourceRange);
                asL->Rhs(rcL);
                iniL->Stmt(asL);
                procs->push_back(iniL);
                continue;
            }
            if (ic9.kind != ExpressionKind::NamedValue)
                continue;
            auto& is9 = ic9.as<NamedValueExpression>().symbol;
            UHDM::constant* econ9 = nullptr;
            if (m->Param_assigns())
                for (auto* pa9 : *m->Param_assigns()) {
                    auto* lp9 = (UHDM::parameter*)pa9->Lhs();
                    if (lp9 && lp9->VpiName() == is9.name && pa9->Rhs() &&
                        ((UHDM::any*)pa9->Rhs())->UhdmType() ==
                            UHDM::uhdmconstant)
                        econ9 = (UHDM::constant*)pa9->Rhs();
                }
            if (!econ9)
                continue;
            auto* ini9 = s.MakeInitial();
            auto* as9 = s.MakeAssignment();
            as9->VpiParent(ini9);
            setLoc(as9, nameSpan(ps9.location, ps9.name));
            auto* lr9 = s.MakeRef_obj();
            lr9->VpiName(ps9.name);
            lr9->VpiFullName(std::string(ps9.name));
            lr9->VpiParent(as9);
            setLoc(lr9, nameSpan(ps9.location, ps9.name));
            as9->Lhs(lr9);
            auto* rc9 = s.MakeConstant();
            rc9->VpiDecompile(econ9->VpiDecompile());
            rc9->VpiSize(econ9->VpiSize());
            rc9->VpiValue(std::string(econ9->VpiValue()));
            rc9->VpiConstType(econ9->VpiConstType());
            rc9->VpiParent((UHDM::any*)econ9->VpiParent());
            (void)0;
            setLoc(rc9, ic9.sourceRange);
            auto* rt9 = s.MakeRef_typespec();
            rt9->VpiFullName(prefix);
            rt9->VpiParent(rc9);
            UHDM::typespec* pt9 = nullptr;
            {
                auto& pct9 = is9.as<ParameterSymbol>()
                                 .getType()
                                 .getCanonicalType();
                if (pct9.kind == SymbolKind::PredefinedIntegerType &&
                    pct9.as<PredefinedIntegerType>().integerKind ==
                        PredefinedIntegerType::Integer) {
                    auto* it9x = s.MakeInteger_typespec();
                    it9x->VpiSigned(true);
                    pt9 = it9x;
                }
                else {
                    auto* it9x = s.MakeInt_typespec();
                    it9x->VpiSigned(true);
                    pt9 = it9x;
                }
                if (auto dt9 = is9.as<ParameterSymbol>().getDeclaredType())
                    if (auto tsn9 = dt9->getTypeSyntax())
                        setLoc(pt9, tsn9->sourceRange());
            }
            rt9->Actual_typespec(pt9);
            pt9->VpiParent(rt9);
            rc9->Typespec(rt9);
            as9->Rhs(rc9);
            ini9->Stmt(as9);
            procs->push_back(ini9);
        }
            if (it != defMap.end())
                for (auto* p : it->second.processes)
                    procs->push_back(p);
            if (!procs->empty())
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
        // Imported functions called from THIS module's conns (queued during
        // gen-scope/child emission; the shared-def assignment above must not
        // wipe them).
        if (!pendingConnTfList.empty()) {
            for (auto& [pm9, tf9] : pendingConnTfList) {
                if (pm9 != m)
                    continue;
                auto app9 = [&](UHDM::module_inst* mm9) {
                    auto* tv9 = mm9->Task_funcs();
                    if (!tv9) {
                        tv9 = s.MakeTask_funcVec();
                        mm9->Task_funcs(tv9);
                    }
                    if (std::find(tv9->begin(), tv9->end(), tf9) ==
                        tv9->end())
                        tv9->push_back(tf9);
                };
                app9(m);
                // The DEF view lists it too (Surelog).
                if (it != defMap.end() && it->second.mod &&
                    it->second.mod != m)
                    app9(it->second.mod);
            }
            pendingConnTfList.erase(
                std::remove_if(pendingConnTfList.begin(),
                               pendingConnTfList.end(),
                               [&](auto& pr9) { return pr9.first == m; }),
                pendingConnTfList.end());
        }
        if (isTop && it != defMap.end() && !it->second.typedefs.empty()) {
            auto* tds = s.MakeTypespecVec();
            for (auto* td : it->second.typedefs)
                tds->push_back(td);
            // Name-sorted like the def listing (Surelog's name-keyed registry).
            std::stable_sort(tds->begin(), tds->end(),
                             [](const UHDM::typespec* a, const UHDM::typespec* b) {
                                 return a->VpiName() < b->VpiName();
                             });
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
    std::function<UHDM::gen_scope_array*(const GenerateBlockSymbol&,
                                         const std::string&, const std::string&,
                                         UHDM::BaseClass*)>
        emitBlock = [&](const GenerateBlockSymbol& blk, const std::string& name,
                        const std::string& parentFull,
                        UHDM::BaseClass* parentObj) -> UHDM::gen_scope_array* {
        std::string fullName = parentFull + "." + name;
        auto* gsa = s.MakeGen_scope_array();
        gsa->VpiName(name);
        gsa->VpiFullName(fullName);
        gsa->VpiParent(parentObj);
        auto* gs = s.MakeGen_scope();
        gs->VpiFullName(fullName);
        gs->VpiParent(gsa);
        if (auto syn = blk.getSyntax()) {
            setLoc(gsa, syn->sourceRange());
            setLoc(gs, syn->sourceRange());
            // A CASE-generate taken BEGIN..END block spans its first member
            // CONSTRUCT (the always/assign inside the clause), not the
            // begin..end clause; a bare-statement item keeps the item span
            // (Surelog).
            bool underCase9 = syn->kind == syntax::SyntaxKind::GenerateBlock;
            if (underCase9) {
                underCase9 = false;
                for (auto q = syn->parent; q; q = q->parent)
                    if (q->kind == syntax::SyntaxKind::CaseGenerate) {
                        underCase9 = true;
                        break;
                    }
                // A taken ELSE-IF branch block (its IfGenerate hangs off an
                // ElseClause) also spans its first member (Surelog re-pass).
                if (!underCase9 && syn->parent &&
                    syn->parent->kind == syntax::SyntaxKind::IfGenerate &&
                    syn->parent->parent &&
                    syn->parent->parent->kind ==
                        syntax::SyntaxKind::ElseClause)
                    underCase9 = true;
            }
            if (underCase9)
                for (auto& gm9 : blk.members()) {
                    if (gm9.kind == SymbolKind::Genvar ||
                        gm9.kind == SymbolKind::Parameter ||
                        gm9.kind == SymbolKind::TransparentMember)
                        continue;
                    if (auto* ms9 = gm9.getSyntax()) {
                        // Span the whole top-level ITEM inside the block
                        // (wire DECLARATION incl. keyword/semicolon, not just
                        // the declarator).
                        while (ms9->parent && ms9->parent != syn)
                            ms9 = ms9->parent;
                        setLoc(gsa, ms9->sourceRange());
                        setLoc(gs, ms9->sourceRange());
                        break;
                    }
                }
        }
        auto* gv = s.MakeGen_scopeVec();
        gv->push_back(gs);
        gsa->Gen_scopes(gv);

        // Genvar localparam: line of the generate loop, column 0, no end.
        auto* params = s.MakeAnyVec();
        auto* genPas = s.MakeParam_assignVec();
        // Block-localparam fold constants, SHARED into gen CA RHS folds.
        std::map<const Symbol*, UHDM::constant*> genLpConst;
        // REAL localparams list before the genvar localparam (Surelog order).
        for (int lpPass = 0; lpPass < 2; lpPass++)
        for (auto& gm : blk.members()) {
            if (gm.kind != SymbolKind::Parameter)
                continue;
            {
                bool isReal = false;
                for (auto q = gm.getSyntax(); q; q = q->parent)
                    if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                        isReal = true;
                        break;
                    }
                if ((lpPass == 0) != isReal)
                    continue;
            }
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
            // A REAL block localparam (written `localparam ... = ...`) keeps
            // its name span, source-base value encoding, and typed ts; the
            // GENVAR localparam keeps the loop-line/col-0 deferred-int form.
            bool realLp = false;
            for (auto q = ps.getSyntax(); q; q = q->parent)
                if (q->kind == syntax::SyntaxKind::ParameterDeclaration) {
                    realLp = true;
                    break;
                }
            if (realLp) {
                setLoc(up, nameSpan(ps.location, ps.name));
                // A signed gen-scope localparam carries vpiSigned ONLY when it
                // is EXPLICITLY typed (localparam int Offset); an UNTYPED one
                // (localparam PREV = i-1) whose value is merely inferred-signed
                // omits it (Surelog) — mirror the def-view gate (ParamEmit:280).
                bool explicitType = false;
                if (auto dt0 = ps.getDeclaredType())
                    if (auto tsyn0 = dt0->getTypeSyntax())
                        explicitType =
                            tsyn0->kind != syntax::SyntaxKind::ImplicitType;
                if (explicitType && ps.getType().getCanonicalType().isSigned())
                    up->VpiSigned(true);
                if (auto init = ps.getInitializer()) {
                    auto& lit = stripImplicitConv(*init);
                    std::string raw = rawText(lit.sourceRange);
                    auto tick = raw.find('\'');
                    if (lit.kind == ExpressionKind::IntegerLiteral &&
                        tick != std::string::npos) {
                        size_t bp = tick + 1;
                        if (bp < raw.size() && (raw[bp] == 's' || raw[bp] == 'S'))
                            bp++;
                        char bch = bp < raw.size() ? (char)tolower(raw[bp]) : 'd';
                        std::string dg =
                            bp + 1 <= raw.size() ? raw.substr(bp + 1) : "";
                        dg.erase(std::remove(dg.begin(), dg.end(), '_'), dg.end());
                        if (bch == 'h')
                            up->VpiValue("HEX:" + dg);
                        else if (bch == 'b')
                            up->VpiValue("BIN:" + dg);
                        else if (bch == 'o')
                            up->VpiValue("OCT:" + dg);
                    }
                }
                bool typedLp = false;
                if (auto d0 = ps.getDeclaredType())
                    if (auto t0 = d0->getTypeSyntax())
                        typedLp = t0->kind != syntax::SyntaxKind::ImplicitType;
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(fullName + "." + std::string(ps.name));
                rt->VpiParent(up);
                up->Typespec(rt);
                params->push_back(up);
                // The gen-scope param_assign: Rhs is a source-encoded constant
                // (init span, gen-scope-scoped ts ref) SHARED into the gen CA
                // fold (its parent becomes the sharing cont_assign).
                if (auto init = ps.getInitializer()) {
                    auto& lit = stripImplicitConv(*init);
                    if (lit.kind == ExpressionKind::IntegerLiteral) {
                        auto* pa2 = s.MakeParam_assign();
                        pa2->VpiParent(gs);
                        if (auto dsyn = ps.getSyntax();
                            dsyn && dsyn->kind == syntax::SyntaxKind::Declarator)
                            setLoc(pa2, dsyn->sourceRange());
                        auto* c2 = s.MakeConstant();
                        std::string raw2 = rawText(lit.sourceRange);
                        c2->VpiDecompile(raw2);
                        c2->VpiSize((int32_t)ps.getType().getBitWidth());
                        std::string_view v2 = up->VpiValue();
                        c2->VpiValue(std::string(v2));
                        c2->VpiConstType(v2.rfind("HEX:", 0) == 0   ? vpiHexConst
                                         : v2.rfind("BIN:", 0) == 0 ? vpiBinaryConst
                                         : v2.rfind("OCT:", 0) == 0 ? vpiOctConst
                                                                    : vpiUIntConst);
                        setLoc(c2, lit.sourceRange);
                        auto* crt = s.MakeRef_typespec();
                        crt->VpiFullName(fullName);
                        crt->VpiParent(c2);
                        // Actuals (bare clone + typed ts) fill in the write
                        // phase (Surelog arena order).
                        pendingGenLpTs.push_back({rt, crt, &ps, typedLp});
                        rt = nullptr; // consumed
                        c2->Typespec(crt);
                        pa2->Rhs(c2);
                        pa2->Lhs(up);
                        genPas->push_back(pa2);
                        genLpConst[&gm] = c2;
                        genLpFoldByPath[fullName + "." +
                                        std::string(ps.name)] = {pa2, c2, &ps};
                    }
                    else if (cv.isInteger() && !cv.integer().hasUnknown()) {
                        // NON-literal init (localparam PREV = i-1): param_assign
                        // with the FOLDED signed constant at the init span.
                        auto* pa2 = s.MakeParam_assign();
                        pa2->VpiParent(gs);
                        if (auto dsyn = ps.getSyntax();
                            dsyn && dsyn->kind == syntax::SyntaxKind::Declarator)
                            setLoc(pa2, dsyn->sourceRange());
                        auto* c2 = s.MakeConstant();
                        int64_t sv = cv.integer().as<int64_t>().value_or(0);
                        std::string sd = std::to_string(sv);
                        c2->VpiDecompile(sd);
                        c2->VpiSize((int32_t)ps.getType().getBitWidth());
                        // Folds encode INT when ANY sibling instance of this
                        // gen-array localparam is negative (gen_test4 PREV =
                        // i-1: foo[0] is -1 so ALL fold INT); otherwise UINT
                        // (LPINFL/gvl2 keep UINT on signed types).
                        bool negSib9 = sv < 0;
                        if (!negSib9) {
                            if (auto bp9 = blk.getParentScope();
                                bp9 && bp9->asSymbol().kind ==
                                           SymbolKind::GenerateBlockArray) {
                                for (auto& sb9 :
                                     bp9->asSymbol()
                                         .as<GenerateBlockArraySymbol>()
                                         .entries) {
                                    for (auto& sm9 : sb9->members())
                                        if (sm9.kind ==
                                                SymbolKind::Parameter &&
                                            sm9.name == ps.name) {
                                            auto& sv9 =
                                                sm9.as<ParameterSymbol>()
                                                    .getValue();
                                            if (sv9.isInteger() &&
                                                sv9.integer()
                                                        .as<int64_t>()
                                                        .value_or(0) < 0)
                                                negSib9 = true;
                                        }
                                    if (negSib9)
                                        break;
                                }
                            }
                        }
                        if (negSib9) {
                            c2->VpiValue("INT:" + sd);
                            c2->VpiConstType(vpiIntConst);
                        }
                        else {
                            c2->VpiValue("UINT:" + sd);
                            c2->VpiConstType(vpiUIntConst);
                        }
                        // The computed fold's constant parents at its
                        // param_assign when the fold is INT-signed
                        // (gen_test4); UINT folds keep the sharing-claimed
                        // parent (LPINFL).
                        if (negSib9)
                            c2->VpiParent(pa2);
                        setLoc(c2, lit.sourceRange);
                        auto* crt = s.MakeRef_typespec();
                        crt->VpiFullName(fullName);
                        crt->VpiParent(c2);
                        // A localparam whose init is a direct element-select of
                        // a top array param (int O = RhoOffset[1]) adopts THAT
                        // elab pattern operand: Surelog gives the operand
                        // constant a ts ref to this localparam's int typespec.
                        UHDM::ref_typespec* operandRt = nullptr;
                        if (typedLp) {
                            if (auto* ie = ps.getInitializer()) {
                                auto& se0 = stripImplicitConv(*ie);
                                if (se0.kind == ExpressionKind::ElementSelect) {
                                    auto& es0 =
                                        se0.as<ElementSelectExpression>();
                                    auto& bv = stripImplicitConv(es0.value());
                                    if (bv.kind == ExpressionKind::NamedValue &&
                                        bv.as<NamedValueExpression>()
                                                .symbol.kind ==
                                            SymbolKind::Parameter) {
                                        auto& rp =
                                            bv.as<NamedValueExpression>()
                                                .symbol.as<ParameterSymbol>();
                                        auto oit = elabArrayPatternOp.find(&rp);
                                        auto& rpt =
                                            rp.getType().getCanonicalType();
                                        ASTContext ec0(comp.getRoot(),
                                                       LookupLocation::max);
                                        ConstantValue iv =
                                            ec0.tryEval(es0.selector());
                                        if (oit != elabArrayPatternOp.end() &&
                                            iv && iv.isInteger() &&
                                            rpt.kind ==
                                                SymbolKind::
                                                    FixedSizeUnpackedArrayType) {
                                            auto* op0 = oit->second;
                                            int64_t ix =
                                                iv.integer()
                                                    .as<int64_t>()
                                                    .value_or(-1);
                                            auto rng =
                                                rpt.as<
                                                       FixedSizeUnpackedArrayType>()
                                                    .range;
                                            int32_t lo = std::min(rng.left,
                                                                  rng.right);
                                            int64_t pos = ix - lo;
                                            // Only the plain (source-ordered)
                                            // pattern maps index->position 1:1.
                                            if (op0->VpiReordered() != 1 &&
                                                op0->Operands() && ix >= 0 &&
                                                pos >= 0 &&
                                                pos < (int64_t)op0->Operands()
                                                          ->size()) {
                                                auto* opnd =
                                                    (*op0->Operands())[pos];
                                                if (opnd->UhdmType() ==
                                                        UHDM::uhdmconstant &&
                                                    !((UHDM::constant*)opnd)
                                                         ->Typespec()) {
                                                    operandRt =
                                                        s.MakeRef_typespec();
                                                    operandRt->VpiParent(opnd);
                                                    ((UHDM::constant*)opnd)
                                                        ->Typespec(operandRt);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        pendingGenLpTs.push_back(
                            {rt, crt, &ps, typedLp, operandRt});
                        rt = nullptr;
                        c2->Typespec(crt);
                        pa2->Rhs(c2);
                        pa2->Lhs(up);
                        genPas->push_back(pa2);
                        genLpConst[&gm] = c2;
                        genLpFoldByPath[fullName + "." +
                                        std::string(ps.name)] = {pa2, c2, &ps};
                    }
                }
                if (rt)
                    pendingGenLpTs.push_back({rt, nullptr, &ps, typedLp});
                continue;
            }
            if (auto syn = blk.getSyntax()) {
                // Locate the genvar at the LOOP line (Surelog), not the block
                // body line — a no-begin `for(i..) <stmt>` block is the stmt.
                const syntax::SyntaxNode* loopSyn = syn;
                for (auto q = syn; q; q = q->parent)
                    if (q->kind == syntax::SyntaxKind::LoopGenerate) {
                        loopSyn = q;
                        break;
                    }
                up->VpiLineNo(sm->getLineNumber(loopSyn->sourceRange().start()));
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
        if (!genPas->empty())
            gs->Param_assigns(genPas);

        // Local nets declared inside the block (wire tmp; ...).
        auto* gnets = s.MakeNetVec();
        std::vector<UHDM::cont_assign*> ndaCas;
        // A REG local (scalar or ranged) DRIVEN inside the block — by a
        // cont_assign OR a process — elaborates as a logic_net (NetType 48)
        // instead of a logic_var (Surelog). Undriven regs stay vars.
        std::set<const Symbol*> blkWrites;
        {
            for (auto& cm : blk.members()) {
                if (cm.kind == SymbolKind::ContinuousAssign) {
                    auto& asn = cm.as<ContinuousAssignSymbol>().getAssignment();
                    if (asn.kind == ExpressionKind::Assignment) {
                        auto& lc = stripImplicitConv(
                            asn.as<AssignmentExpression>().left());
                        if (lc.kind == ExpressionKind::NamedValue)
                            blkWrites.insert(
                                &lc.as<NamedValueExpression>().symbol);
                    }
                }
                else if (cm.kind == SymbolKind::ProceduralBlock) {
                    cm.as<ProceduralBlockSymbol>().getBody().visit(makeVisitor(
                        [&](auto&, const AssignmentExpression& ae9) {
                            auto& lw = stripImplicitConv(ae9.left());
                            if (lw.kind == ExpressionKind::NamedValue)
                                blkWrites.insert(
                                    &lw.as<NamedValueExpression>().symbol);
                        }));
                }
            }
        }
        auto caDrivenVar = [&](const Symbol& gm) {
            if (gm.kind != SymbolKind::Variable)
                return false;
            auto& vk = gm.as<VariableSymbol>().getType().getCanonicalType();
            bool okKind =
                vk.kind == SymbolKind::ScalarType ||
                (vk.kind == SymbolKind::PackedArrayType &&
                 vk.as<PackedArrayType>()
                         .elementType.getCanonicalType()
                         .kind == SymbolKind::ScalarType);
            if (!okKind || !blkWrites.count(&gm))
                return false;
            // Only REG-keyword decls net-ify; `logic` locals stay vars.
            if (auto dt0 = gm.getDeclaredType())
                if (auto tsn0 = dt0->getTypeSyntax())
                    return tsn0->kind == syntax::SyntaxKind::RegType;
            return false;
        };
        auto* genArrayNets = s.MakeArray_netVec();
        for (auto& gm : blk.members()) {
            bool caVar = gm.kind == SymbolKind::Variable && caDrivenVar(gm);
            bool structVar = gm.kind == SymbolKind::Variable &&
                             gm.getDeclaredType() &&
                             gm.getDeclaredType()
                                 ->getType()
                                 .getCanonicalType()
                                 .isStruct();
            if (gm.kind != SymbolKind::Net && !caVar && !structVar)
                continue;
            // A STRUCT-typed gen-block local signal (pkt_t r) nets as a
            // struct_net sharing the struct typespec — Surelog.
            if (structVar && !caVar) {
                std::string sfull = fullName + "." + std::string(gm.name);
                UHDM::typespec* sts = nullptr;
                if (auto tt = pkgTopTypedefTs.find(&gm.getDeclaredType()->getType());
                    tt != pkgTopTypedefTs.end())
                    sts = tt->second;
                if (!sts)
                    if (auto tt2 = typedefTs.find(&gm.getDeclaredType()->getType());
                        tt2 != typedefTs.end())
                        sts = tt2->second;
                if (!sts)
                    sts = makeTypespec(gm);
                auto* sn = s.MakeStruct_net();
                sn->VpiName(gm.name);
                sn->VpiFullName(sfull);
                sn->VpiParent(gs);
                setLoc(sn, nameSpan(gm.location, gm.name));
                auto* srt = s.MakeRef_typespec();
                srt->VpiFullName(sfull);
                srt->VpiParent(sn);
                srt->Actual_typespec(sts);
                sn->Typespec(srt);
                genScopeNets[&gm] = sn;
                netMap[&gm] = sn;
                gnets->push_back(sn);
                continue;
            }
            // Unpacked-array nets (wire z [7]) elaborate as array_nets.
            if (gm.kind == SymbolKind::Net && gm.getDeclaredType() &&
                gm.getDeclaredType()->getType().getCanonicalType().kind ==
                    SymbolKind::FixedSizeUnpackedArrayType) {
                std::string nfull2 = fullName + "." + std::string(gm.name);
                UHDM::typespec* ets3 =
                    makeTypespec(gm, gm.getDeclaredType()->getTypeSyntax());
                if (auto* an3 = emitArrayNet(gm, std::string(gm.name), nfull2,
                                             gs, ets3)) {
                    netMap[&gm] = an3;
                    genArrayNets->push_back(an3);
                }
                continue;
            }
            std::string nfull = fullName + "." + std::string(gm.name);
            auto* n = s.MakeLogic_net();
            n->VpiName(gm.name);
            n->VpiFullName(nfull);
            n->VpiParent(gs);
            setLoc(n, nameSpan(gm.location, gm.name));
            if (caVar) {
                n->VpiNetType(48);
                netMap[&gm] = n;
            }
            int32_t nt = caVar ? 0 : netTypeFor(gm);
            if (nt)
                n->VpiNetType(nt);
            auto* dt = gm.getDeclaredType();
            bool hasInit = dt && dt->getInitializer();
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(nfull);
            rt->VpiParent(n);
            // Bind bounds in the gen-scope context ONLY when a dim
            // references a sibling GEN-SCOPE localparam (so [w:0] folds at
            // the param's int width) — module-param bounds keep the plain
            // 64-bit fold path (enabling the bind for them regresses).
            auto savedCS9 = currentScope;
            {
                bool genLpDim9 = false;
                if (auto dt9 = gm.getDeclaredType())
                    if (auto tsn9 = dt9->getTypeSyntax()) {
                        std::string raw9(rawText(tsn9->sourceRange()));
                        for (auto psc9 = gm.getParentScope();
                             psc9 && !genLpDim9 &&
                             psc9->asSymbol().kind != SymbolKind::InstanceBody;
                             psc9 = psc9->asSymbol().getParentScope())
                            for (auto& sib9 : psc9->members())
                                if (sib9.kind == SymbolKind::Parameter &&
                                    !sib9.as<ParameterSymbol>()
                                         .isFromGenvar() &&
                                    !sib9.name.empty() &&
                                    raw9.find(sib9.name) !=
                                        std::string::npos) {
                                    genLpDim9 = true;
                                    break;
                                }
                    }
                if (genLpDim9)
                    currentScope = gm.getParentScope();
            }
            auto* ats = makeTypespec(gm);
            currentScope = savedCS9;
            // A net-decl-assign net's list typespec loses its net parent (the
            // fresh Lhs net carries the parented one); a plain net keeps it.
            if (!hasInit)
                ats->VpiParent(n);
            rt->Actual_typespec(ats);
            n->Typespec(rt);
            genScopeNets[&gm] = n;
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
                // LOOP-gen scopes share the SCOPE NET bare as the Lhs for
                // SCALAR nets; ranged nets (and if/named scopes) mint a
                // fresh Lhs net (Surelog).
                bool loopScope9 = false;
                for (auto q = blk.getSyntax(); q; q = q->parent)
                    if (q->kind == syntax::SyntaxKind::LoopGenerate) {
                        loopScope9 = true;
                        break;
                    }
                if (loopScope9 && dt->getType().getCanonicalType().kind !=
                                      SymbolKind::ScalarType)
                    loopScope9 = false;
                if (loopScope9) {
                    ca->Lhs((UHDM::expr*)(UHDM::any*)n);
                }
                else {
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
                }
                ndaCas.push_back(ca);
            }
        }
        if (!gnets->empty())
            gs->Nets(gnets);
        if (!genArrayNets->empty())
            gs->Array_nets(genArrayNets);

        // Local INTEGER variables declared inside the block (integer x, y;):
        // integer_var under Variables (signed, visible), ref -> an
        // integer_typespec at the type-keyword span (mirrors the def-view
        // decl-assignment Lhs form).
        auto* gvars = s.MakeVariablesVec();
        for (auto& gm : blk.members()) {
            if (gm.kind != SymbolKind::Variable)
                continue;
            if (caDrivenVar(gm))
                continue; // emitted as a logic_net above
            auto& vct = gm.as<VariableSymbol>().getType().getCanonicalType();
            // Unpacked-array locals: the standard elab array_var (folded
            // ranges, bare array_typespec ref), parented at the gen_scope.
            if (vct.kind == SymbolKind::FixedSizeUnpackedArrayType) {
                std::string vfull2 = fullName + "." + std::string(gm.name);
                UHDM::typespec* ets2 = nullptr;
                if (auto* dt3 = gm.getDeclaredType())
                    ets2 = makeTypespec(gm, dt3->getTypeSyntax());
                if (ets2)
                    if (auto* av2 = emitArrayVar(gm, std::string(gm.name),
                                                 vfull2, gs, ets2)) {
                        netMap[&gm] = av2;
                        gvars->push_back(av2);
                    }
                continue;
            }
            bool isInt2 = vct.kind == SymbolKind::PredefinedIntegerType &&
                          vct.as<PredefinedIntegerType>().integerKind ==
                              PredefinedIntegerType::Integer;
            bool isScalar2 = vct.kind == SymbolKind::ScalarType;
            // Ranged logic locals (logic [63:W] x) emit a logic_var whose
            // ts carries the folded ranges.
            bool isRanged2 =
                vct.kind == SymbolKind::PackedArrayType &&
                vct.as<PackedArrayType>()
                        .elementType.getCanonicalType()
                        .kind == SymbolKind::ScalarType;
            if (!isInt2 && !isScalar2 && !isRanged2)
                continue;
            std::string vfull = fullName + "." + std::string(gm.name);
            UHDM::variables* iv;
            if (isInt2) {
                auto* v0 = s.MakeInteger_var();
                v0->VpiSigned(true);
                iv = v0;
            }
            else {
                iv = s.MakeLogic_var();
            }
            iv->VpiName(gm.name);
            iv->VpiFullName(vfull);
            iv->VpiParent(gs);
            iv->VpiVisibility(1);
            // INITIALIZED gen locals span decl..init in the ELAB view and
            // carry the init constant as vpiExpr (32-bit, parent = the var).
            if (gm.getDeclaredType() && gm.getDeclaredType()->getInitializer() &&
                gm.getSyntax()) {
                setLoc(iv, gm.getSyntax()->sourceRange());
                auto* in0 = gm.getDeclaredType()->getInitializer();
                ASTContext ic0(comp.getRoot(), LookupLocation::max);
                if (auto cv0 = ic0.tryEval(*in0);
                    cv0 && cv0.isInteger() && !cv0.integer().hasUnknown()) {
                    auto* c0 = s.MakeConstant();
                    std::string d0 = cv0.integer().toString(
                        LiteralBase::Decimal, false);
                    c0->VpiDecompile(d0);
                    c0->VpiSize(32);
                    c0->VpiValue("UINT:" + d0);
                    c0->VpiConstType(vpiUIntConst);
                    c0->VpiParent(iv);
                    setLoc(c0, stripImplicitConv(*in0).sourceRange);
                    iv->Expr(c0);
                }
            }
            else
                setLoc(iv, nameSpan(gm.location, gm.name));
            UHDM::typespec* ivt;
            if (isInt2) {
                auto* t0 = s.MakeInteger_typespec();
                t0->VpiSigned(true);
                ivt = t0;
            }
            else if (isRanged2) {
                ivt = makeTypespec(gm, gm.getDeclaredType()
                                           ? gm.getDeclaredType()
                                                 ->getTypeSyntax()
                                           : nullptr);
            }
            else {
                ivt = s.MakeLogic_typespec();
            }
            if (auto* dt2 = gm.getDeclaredType())
                if (auto* tsn2 = dt2->getTypeSyntax())
                    setLoc(ivt, tsn2->sourceRange());
            auto* ivr = s.MakeRef_typespec();
            ivr->VpiFullName(vfull);
            ivr->VpiParent(iv);
            ivr->Actual_typespec(ivt);
            iv->Typespec(ivr);
            netMap[&gm] = iv;
            gvars->push_back(iv);
        }
        if (!gvars->empty())
            gs->Variables(gvars);

        // Module instances declared inside the block: full elab children
        // under vpiModule, re-parented at the gen_scope (Surelog). The
        // enclosing module supplies the conn prefix (HighConns bind to the
        // MODULE's nets, not the gen path).
        auto* gmods = s.MakeModule_instVec();
        for (auto& gm : blk.members()) {
            if (gm.kind != SymbolKind::Instance)
                continue;
            auto& ci = gm.as<InstanceSymbol>();
            if (useInterfacePath(ci))
                continue;
            genvarConnFold = true;
            genConnPrefix = fullName;
            auto* mi = emitInstance(ci, fullName + "." + std::string(ci.name),
                                    (UHDM::module_inst*)m, &netMap, nullptr,
                                    /*isTop=*/false);
            genConnPrefix.clear();
            genvarConnFold = false;
            // A gen-scope child carries ONLY the gen_scope parent — Surelog
            // omits the vpiInstance/vpiModuleInst back-refs it gives normal
            // (module-parented) children.
            mi->VpiParent(gs);
            mi->Instance(nullptr);
            mi->Module_inst(nullptr);
            gmods->push_back(mi);
        }
        if (!gmods->empty())
            gs->Modules(gmods);
        // Implicit wires from gen-conn CALLS (queued during the child conn
        // emission above).
        if (!pendingGenCallNets.empty()) {
            auto* nv9 = gs->Nets();
            if (!nv9) {
                nv9 = s.MakeNetVec();
                gs->Nets(nv9);
            }
            for (auto& [nm9, rg9] : pendingGenCallNets) {
                auto* ln9 = s.MakeLogic_net();
                ln9->VpiName(nm9);
                ln9->VpiFullName(fullName + "." + nm9);
                ln9->VpiParent(gs);
                ln9->VpiNetType(1);
                setLoc(ln9, SourceRange(rg9.start(), rg9.start() + nm9.size()));
                nv9->push_back(ln9);
            }
            pendingGenCallNets.clear();
        }

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
            // A comma-list continuous assign gives EVERY cont_assign the whole
            // list's span (Surelog quirk), like the module-level emitter.
            SourceRange caLoc = assign.sourceRange;
            if (auto* asyn = casym.getSyntax())
                for (auto p = asyn->parent; p; p = p->parent)
                    if (p->kind == syntax::SyntaxKind::ContinuousAssign) {
                        auto& cas = p->as<syntax::ContinuousAssignSyntax>();
                        if (cas.assignments.size() > 1)
                            caLoc = cas.assignments.sourceRange();
                        break;
                    }
            setLoc(ca, caLoc);
            {
                auto& lc0 = stripImplicitConv(ae.left());
                if (lc0.kind == ExpressionKind::NamedValue)
                    genLhsSyms.insert(&lc0.as<NamedValueExpression>().symbol);
            }
            bool forceSaved = forceConstParent;
            if (isLiteralExpr(ae.right()))
                forceConstParent = true;
            UHDM::any* rhs = nullptr;
            // A gen CA reading a BLOCK localparam SHARES the param_assign's
            // fold constant (its parent becomes this cont_assign).
            if (auto& rcp0 = stripImplicitConv(ae.right());
                rcp0.kind == ExpressionKind::NamedValue) {
                auto& rsym0 = rcp0.as<NamedValueExpression>().symbol;
                if (auto lit0 = genLpConst.find(&rsym0);
                    lit0 != genLpConst.end()) {
                    lit0->second->VpiParent(ca);
                    rhs = lit0->second;
                }
                // The GENVAR ref folds to its iteration value: a LOC-LESS
                // 64-bit UINT constant parented at the ca (Surelog). Real
                // block localparams (written `localparam`) are excluded.
                else if (rsym0.kind == SymbolKind::Parameter &&
                         rsym0.getParentScope() == &blk &&
                         ![&] {
                             for (auto q = rsym0.getSyntax(); q; q = q->parent)
                                 if (q->kind ==
                                     syntax::SyntaxKind::ParameterDeclaration)
                                     return true;
                             return false;
                         }()) {
                    auto& gv = rsym0.as<ParameterSymbol>().getValue();
                    if (gv.isInteger() && !gv.integer().hasUnknown()) {
                        auto* c = s.MakeConstant();
                        std::string dg =
                            gv.integer().toString(LiteralBase::Decimal, false);
                        c->VpiDecompile(dg);
                        c->VpiSize(64);
                        c->VpiValue("UINT:" + dg);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(ca);
                        rhs = c;
                    }
                }
            }
            // A gen-scope RHS that is a plain ref to a module PARAM with a
            // shared part-select fold constant (FullDepth) re-folds FRESH at
            // the ref location, copying the value + the param's typespec.
            if (auto& rcp = stripImplicitConv(ae.right());
                !rhs && rcp.kind == ExpressionKind::NamedValue) {
                auto fit = moduleParamFoldConst.find(
                    &rcp.as<NamedValueExpression>().symbol);
                if (fit != moduleParamFoldConst.end()) {
                    auto* src = fit->second;
                    auto* c = s.MakeConstant();
                    c->VpiValue(std::string(src->VpiValue()));
                    c->VpiSize(src->VpiSize());
                    c->VpiConstType(src->VpiConstType());
                    c->VpiDecompile(std::string(src->VpiDecompile()));
                    c->VpiParent(ca);
                    setLoc(c, rcp.sourceRange);
                    // A FRESH bit/logic_typespec whose range refs are scoped
                    // to THIS gen scope (work@<gen>.<bound>), built from the
                    // param's own type syntax.
                    auto& fsym = rcp.as<NamedValueExpression>().symbol;
                    if (fsym.getDeclaredType()) {
                        std::string savedPfx = syntaxRefPrefix,
                                    savedSep = syntaxRefSep;
                        bool savedTf = tfContext;
                        syntaxRefPrefix = fullName;
                        syntaxRefSep = ".";
                        tfContext = true;
                        auto* fts = makeTypespec(fsym);
                        tfContext = savedTf;
                        syntaxRefPrefix = savedPfx;
                        syntaxRefSep = savedSep;
                        auto* rt = s.MakeRef_typespec();
                        rt->VpiFullName(fullName);
                        rt->VpiParent(c);
                        rt->Actual_typespec(fts);
                        if (fts)
                            fts->VpiParent(rt);
                        c->Typespec(rt);
                    }
                    rhs = c;
                }
            }
            // Constant gen-scope calls fold to the source literal, sized at
            // the LHS width.
            if (!rhs)
            if (auto cfr2 = constCallFold(stripImplicitConv(ae.right()));
                cfr2.lit && !cfr2.param) {
                forceConstParent = true;
                rhs = emitExpr(*cfr2.lit, ca, fullName, netMap);
                forceConstParent = false;
                if (rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                    rawText(cfr2.lit->sourceRange).find('\'') == std::string::npos)
                    ((UHDM::constant*)rhs)->VpiSize((int32_t)ae.left().type->getBitWidth());
            }
            // A gen-scope call RHS (possibly cast-wrapped: int'(f())) that
            // evaluates folds to a LOC-LESS constant sized at the LHS width.
            if (!rhs) {
                const Expression* callE = &stripImplicitConv(ae.right());
                if (callE->kind == ExpressionKind::Conversion)
                    callE = &stripImplicitConv(
                        callE->as<ConversionExpression>().operand());
                if (callE->kind == ExpressionKind::Call &&
                    !callE->as<CallExpression>().isSystemCall()) {
                    auto subp3 = std::get_if<const SubroutineSymbol*>(
                        &callE->as<CallExpression>().subroutine);
                    ASTContext gctx(comp.getRoot(), LookupLocation::max);
                    ConstantValue gcv = gctx.tryEval(ae.right());
                    if (!gcv) {
                        // Functions DECLARED in generate blocks fail strict
                        // constant-function rules; script-mode eval relaxes.
                        EvalContext ectx2(gctx, EvalFlags::IsScript);
                        gcv = ae.right().eval(ectx2);
                    }
                    if (gcv && gcv.isInteger() && !gcv.integer().hasUnknown() &&
                        (!subp3 || !subWritesNonLocal(**subp3))) {
                        auto giv = gcv.integer();
                        giv.setSigned(false);
                        auto* c = s.MakeConstant();
                        std::string digits =
                            giv.toString(LiteralBase::Decimal, false);
                        c->VpiDecompile(digits);
                        c->VpiSize((int32_t)ae.left().type->getBitWidth());
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        rhs = c;
                    }
                }
            }
            if (!rhs) {
                // A gen-scope CA RHS selecting an element of an UNPACKED-ARRAY
                // param (RhoOffset[1]) folds to the constant value (Surelog
                // elab), mirroring the module-level unpackedParamSel path.
                auto& usel = stripImplicitConv(ae.right());
                const Expression* uselBase = &usel;
                while (uselBase->kind == ExpressionKind::ElementSelect)
                    uselBase = &stripImplicitConv(
                        uselBase->as<ElementSelectExpression>().value());
                if (usel.kind == ExpressionKind::ElementSelect &&
                    uselBase->kind == ExpressionKind::NamedValue &&
                    uselBase->as<NamedValueExpression>().symbol.kind ==
                        SymbolKind::Parameter &&
                    uselBase->as<NamedValueExpression>()
                            .symbol.getType()
                            .getCanonicalType()
                            .kind == SymbolKind::FixedSizeUnpackedArrayType)
                    if (auto* fc = tryFoldConst(ae.right()))
                        rhs = fc;
            }
            if (!rhs) {
                // A gen CA RHS mixing params with NEVER-WRITTEN const-init
                // module vars folds fully to a LOC-LESS BIN constant at the
                // LHS width (Surelog re-elab). tryEval can't see through the
                // var, so substitute manually.
                bool cvOk9 = true, sawVar9 = false;
                ae.right().visit(makeVisitor(
                    [&](auto& v9, const NamedValueExpression& nv9) {
                        if (nv9.symbol.kind == SymbolKind::Parameter) {
                        }
                        else if (nv9.symbol.kind == SymbolKind::Variable) {
                            auto dt9 = nv9.symbol.getDeclaredType();
                            const Expression* ini9 =
                                dt9 ? dt9->getInitializer() : nullptr;
                            bool written9 = false;
                            for (auto& mm9 : body.members()) {
                                if (mm9.kind != SymbolKind::ProceduralBlock)
                                    continue;
                                mm9.as<ProceduralBlockSymbol>()
                                    .getBody()
                                    .visit(makeVisitor(
                                        [&](auto& vv9,
                                            const AssignmentExpression& ax9) {
                                            auto& lc9 = stripImplicitConv(
                                                ax9.left());
                                            if (lc9.kind ==
                                                    ExpressionKind::
                                                        NamedValue &&
                                                &lc9.as<NamedValueExpression>()
                                                         .symbol ==
                                                    &nv9.symbol)
                                                written9 = true;
                                            vv9.visitDefault(ax9);
                                        }));
                            }
                            if (ini9 && !written9)
                                sawVar9 = true;
                            else
                                cvOk9 = false;
                        }
                        else
                            cvOk9 = false;
                        v9.visitDefault(nv9);
                    }));
                if (cvOk9 && sawVar9) {
                    std::function<std::optional<int64_t>(const Expression&)>
                        ev9 = [&](const Expression& e9)
                        -> std::optional<int64_t> {
                        auto& se9 = stripImplicitConv(e9);
                        switch (se9.kind) {
                            case ExpressionKind::IntegerLiteral: {
                                ASTContext c9(comp.getRoot(),
                                              LookupLocation::max);
                                auto v9c = c9.tryEval(se9);
                                if (v9c && v9c.isInteger())
                                    return v9c.integer()
                                        .as<int64_t>()
                                        .value_or(0);
                                return std::nullopt;
                            }
                            case ExpressionKind::NamedValue: {
                                auto& sy9 =
                                    se9.as<NamedValueExpression>().symbol;
                                if (sy9.kind == SymbolKind::Parameter) {
                                    auto& pv9 = sy9.as<ParameterSymbol>()
                                                    .getValue();
                                    if (pv9.isInteger())
                                        return pv9.integer()
                                            .as<int64_t>()
                                            .value_or(0);
                                    return std::nullopt;
                                }
                                if (sy9.kind == SymbolKind::Variable)
                                    if (auto dt9b = sy9.getDeclaredType())
                                        if (auto* i9b =
                                                dt9b->getInitializer())
                                            return ev9(*i9b);
                                return std::nullopt;
                            }
                            case ExpressionKind::BinaryOp: {
                                auto& b9 = se9.as<BinaryExpression>();
                                auto l9 = ev9(b9.left()),
                                     r9v = ev9(b9.right());
                                if (!l9 || !r9v)
                                    return std::nullopt;
                                switch (b9.op) {
                                    case BinaryOperator::Add:
                                        return *l9 + *r9v;
                                    case BinaryOperator::Subtract:
                                        return *l9 - *r9v;
                                    case BinaryOperator::Multiply:
                                        return *l9 * *r9v;
                                    case BinaryOperator::Divide:
                                        if (!*r9v)
                                            return std::nullopt;
                                        return *l9 / *r9v;
                                    case BinaryOperator::Equality:
                                        return *l9 == *r9v ? 1 : 0;
                                    case BinaryOperator::Inequality:
                                        return *l9 != *r9v ? 1 : 0;
                                    default:
                                        return std::nullopt;
                                }
                            }
                            default:
                                return std::nullopt;
                        }
                    };
                    if (auto vres9 = ev9(ae.right())) {
                        int32_t w9 =
                            (int32_t)ae.left().type->getBitWidth();
                        auto* c9 = s.MakeConstant();
                        std::string bits9;
                        for (int32_t i9 = w9 - 1; i9 >= 0; i9--)
                            bits9 += ((*vres9 >> i9) & 1) ? '1' : '0';
                        c9->VpiDecompile(
                            std::to_string(*vres9));
                        c9->VpiSize(w9);
                        c9->VpiValue("BIN:" + bits9);
                        c9->VpiConstType(vpiBinaryConst);
                        rhs = c9;
                    }
                }
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
                // Child-instance OR NESTED gen-scope CA RHS refs to outer
                // signals stay unbound (parentFull has a '.' once nested).
                bool childGen = prefix.find('.') != std::string::npos ||
                                parentFull.find('.') != std::string::npos;
                // A gen-scope cont_assign RHS with NO parameter reference
                // leaves its WHOLE net refs unbound (Surelog); bit_selects
                // still bind. A param-referencing RHS keeps binding/folding.
                // Suppress (unbind whole net refs) UNLESS the RHS references a
                // BINDABLE symbol: an OUTER (module) param, or a signal DRIVEN
                // in this gen-scope (in genLhsSyms). A gen-block genvar and a
                // read-only outer net (sel) do not count.
                bool hasBindableRef = false;
                ae.right().visit(makeVisitor(
                    [&](auto& v, const NamedValueExpression& nvp) {
                        if (nvp.symbol.kind == SymbolKind::Parameter) {
                            for (auto sc0 = nvp.symbol.getParentScope(); sc0;
                                 sc0 = sc0->asSymbol().getParentScope()) {
                                auto sk = sc0->asSymbol().kind;
                                if (sk == SymbolKind::GenerateBlock ||
                                    sk == SymbolKind::GenerateBlockArray)
                                    break;
                                if (sk == SymbolKind::InstanceBody) {
                                    hasBindableRef = true;
                                    break;
                                }
                            }
                        }
                        else if (genLhsSyms.count(&nvp.symbol) ||
                                 blkWrites.count(&nvp.symbol))
                            hasBindableRef = true;
                        v.visitDefault(nvp);
                    }));
                bool suppress = streamRhs || childGen || !hasBindableRef;
                // INTERFACE gen scopes bind their CA refs to gen-local VARS
                // (Surelog) — net-mapped targets stay under the module rules.
                // (The childGen prefix-dot test always trips for an iface
                // HOME view — work@top.intf — so it doesn't apply here.)
                if (m->UhdmType() == UHDM::uhdminterface_inst && !streamRhs) {
                    bool allVarRefs = true;
                    stripImplicitConv(ae.right())
                        .visit(makeVisitor([&](auto& v,
                                               const NamedValueExpression&
                                                   nvp9) {
                            auto mit9 = netMap.find(&nvp9.symbol);
                            switch (mit9 != netMap.end()
                                        ? mit9->second->UhdmType()
                                        : UHDM::uhdmlogic_net) {
                                case UHDM::uhdmlogic_net:
                                case UHDM::uhdmstruct_net:
                                case UHDM::uhdmarray_net:
                                case UHDM::uhdmenum_net:
                                case UHDM::uhdmpacked_array_net:
                                    allVarRefs = false;
                                    break;
                                default:
                                    break;
                            }
                            v.visitDefault(nvp9);
                        }));
                    if (allVarRefs)
                        suppress = false;
                }
                if (suppress)
                    suppressRefActual = true;
                bool blkInLoop3 = false;
                for (auto q = blk.getSyntax(); q; q = q->parent)
                    if (q->kind == syntax::SyntaxKind::LoopGenerate) {
                        blkInLoop3 = true;
                        break;
                    }
                genCaLhsParamFold = !blkInLoop3;
                rhs = emitExpr(ae.right(), ca, fullName, netMap);
                genCaLhsParamFold = false;
                if (suppress)
                    suppressRefActual = false;
            }
            if (rhs)
                ca->Rhs((UHDM::expr*)rhs);
            // A BARE-decimal literal Rhs sizes at the LHS type width when
            // the LHS is a 2-state typed var (assign out = 42 -> 32) —
            // Surelog.
            if (rhs && rhs->UhdmType() == UHDM::uhdmconstant) {
                auto& rl9 = stripImplicitConv(ae.right());
                auto& ll9 = stripImplicitConv(ae.left());
                if (rl9.kind == ExpressionKind::IntegerLiteral &&
                    rawText(rl9.sourceRange).find('\'') == std::string::npos &&
                    ll9.type &&
                    (!ll9.type->getCanonicalType().isFourState() ||
                     // A 4-state LHS also sizes the fold when the gen scope
                     // belongs to a CHILD instance (nested elaboration) —
                     // Surelog. Top-module gen scopes keep 64.
                     prefix.find('.') != std::string::npos) &&
                    ll9.type->getCanonicalType().isIntegral())
                    ((UHDM::constant*)rhs)->VpiSize(
                        (int32_t)ll9.type->getBitWidth());
            }
            // A gen-scope $bits/$signed-style sys call RHS carries a result
            // typespec ref (gen-scope fullname, LHS net's actual) — Surelog.
            if (rhs && rhs->UhdmType() == UHDM::uhdmsys_func_call) {
                auto& rcs = stripImplicitConv(ae.right());
                if (rcs.kind == ExpressionKind::Call &&
                    rcs.as<CallExpression>().isSystemCall()) {
                    auto nm3 = rcs.as<CallExpression>().getSubroutineName();
                    if (nm3 == "bits" || nm3 == "$bits" || nm3 == "signed" ||
                        nm3 == "$signed" || nm3 == "unsigned" ||
                        nm3 == "$unsigned" || nm3 == "clog2" ||
                        nm3 == "$clog2") {
                        auto& le3 = stripImplicitConv(ae.left());
                        UHDM::typespec* act3 = nullptr;
                        if (le3.kind == ExpressionKind::NamedValue) {
                            auto nit3 = netMap.find(
                                &le3.as<NamedValueExpression>().symbol);
                            if (nit3 != netMap.end() &&
                                nit3->second->UhdmType() ==
                                    UHDM::uhdmlogic_net) {
                                auto* srcTs =
                                    ((UHDM::logic_net*)nit3->second)
                                        ->Typespec();
                                if (srcTs)
                                    act3 = srcTs->Actual_typespec();
                            }
                        }
                        if (act3) {
                            auto* rt3 = s.MakeRef_typespec();
                            rt3->VpiFullName(fullName);
                            rt3->VpiParent(rhs);
                            rt3->Actual_typespec(act3);
                            ((UHDM::expr*)rhs)->Typespec(rt3);
                        }
                    }
                }
            }
            forceConstParent = forceSaved;
            inLhs = true;
            // A FOR-loop gen-scope CA whose LHS is a whole-ref to an outer
            // VARIABLE (output int o) leaves its actual UNBOUND — Surelog (else
            // ours mints a fresh int_var actual). A NET LHS (output logic o)
            // still binds, as do single-instance (if/named) gen-scopes and
            // bit/part-selects.
            bool lhsSuppress = false;
            if (auto& lcl = stripImplicitConv(ae.left());
                lcl.kind == ExpressionKind::NamedValue &&
                lcl.as<NamedValueExpression>().symbol.kind ==
                    SymbolKind::Variable &&
                lcl.type && !lcl.type->getCanonicalType().isFourState()) {
                for (auto q = blk.getSyntax(); q; q = q->parent)
                    if (q->kind == syntax::SyntaxKind::LoopGenerate) {
                        lhsSuppress = true;
                        break;
                    }
            }
            // A NESTED gen scope (parent scope is itself a generate block)
            // leaves a MODULE-level whole-ref LHS unbound; refs to GEN-scope
            // nets still bind (Surelog).
            if (!lhsSuppress &&
                stripImplicitConv(ae.left()).kind ==
                    ExpressionKind::NamedValue) {
                auto& lsym0 =
                    stripImplicitConv(ae.left()).as<NamedValueExpression>().symbol;
                bool symModuleLevel = false;
                if (auto sps0 = lsym0.getParentScope())
                    symModuleLevel =
                        sps0->asSymbol().kind == SymbolKind::InstanceBody;
                if (auto ps0 = blk.getParentScope(); ps0) {
                    auto pk0 = ps0->asSymbol().kind;
                    // If-gen nested blocks leave module-level refs AND
                    // variable refs unbound; loop-gen blocks (parent is the
                    // GenerateBlockArray) leave only refs to module-level
                    // VARIABLES (emitted as *_var — port-backed logic vars
                    // become nets and still bind) unbound — Surelog.
                    bool mapsToVar0 = false;
                    if (lsym0.kind == SymbolKind::Variable)
                        if (auto mit0 = netMap.find(&lsym0);
                            mit0 != netMap.end())
                            switch (mit0->second->UhdmType()) {
                                case UHDM::uhdmlogic_net:
                                case UHDM::uhdmarray_net:
                                case UHDM::uhdmstruct_net:
                                case UHDM::uhdmenum_net:
                                case UHDM::uhdmpacked_array_net:
                                case UHDM::uhdmnet_bit:
                                    break;
                                default:
                                    mapsToVar0 = true;
                            }
                    if ((pk0 == SymbolKind::GenerateBlock &&
                         (symModuleLevel ||
                          lsym0.kind == SymbolKind::Variable)) ||
                        (pk0 == SymbolKind::GenerateBlockArray && mapsToVar0))
                        lhsSuppress = true;
                }
            }
            if (lhsSuppress)
                suppressRefActual = true;
            bool blkInLoop2 = false;
            for (auto q = blk.getSyntax(); q; q = q->parent)
                if (q->kind == syntax::SyntaxKind::LoopGenerate) {
                    blkInLoop2 = true;
                    break;
                }
            genCaLhsParamFold = !blkInLoop2;
            genCaLhsReelab =
                !blkInLoop2 && isLiteralExpr(stripImplicitConv(ae.right()));
            if (auto* l = emitExpr(ae.left(), ca, fullName, netMap)) {
                // Nested-scope CA LHS refs to a PARENT gen scope's nets bind
                // through the dedicated gen-net map.
                if (!lhsSuppress && l->UhdmType() == UHDM::uhdmref_obj &&
                    !((UHDM::ref_obj*)l)->Actual_group()) {
                    auto& lc9 = stripImplicitConv(ae.left());
                    if (lc9.kind == ExpressionKind::NamedValue) {
                        auto& ls9 = lc9.as<NamedValueExpression>().symbol;
                        // Only refs to a PARENT scope's nets bind; refs to
                        // this block's own nets stay unbound (Surelog).
                        bool parentNet9 = false;
                        if (auto sp9 = ls9.getParentScope())
                            parentNet9 = &sp9->asSymbol() != (const Symbol*)&blk;
                        auto git9 = genScopeNets.find(&ls9);
                        if (parentNet9 && git9 != genScopeNets.end())
                            ((UHDM::ref_obj*)l)->Actual_group(git9->second);
                        else if (git9 != genScopeNets.end()) {
                            // Own-scope net: SL resolves the NAME against
                            // the MODULE scope (binds the module net of the
                            // same name when one exists).
                            for (auto& [ms9, mo9] : netMap)
                                if (ms9->name == ls9.name &&
                                    ms9->getParentScope() &&
                                    ms9->getParentScope()->asSymbol().kind ==
                                        SymbolKind::InstanceBody) {
                                    ((UHDM::ref_obj*)l)->Actual_group(mo9);
                                    break;
                                }
                        }
                    }
                }
                ca->Lhs((UHDM::expr*)l);
            }
            genCaLhsReelab = false;
            genCaLhsParamFold = false;
            if (lhsSuppress)
                suppressRefActual = false;
            inLhs = false;
            cas->push_back(ca);
        }
        if (!cas->empty())
            gs->Cont_assigns(cas);

        auto* procs = s.MakeProcess_stmtVec();
        suppressRefActual = true;
        inGenScopeProc = true;
        currentGenBlkScope = &blk;
        genScopeProcInLoop = false;
        for (auto q = blk.getSyntax(); q; q = q->parent)
            if (q->kind == syntax::SyntaxKind::LoopGenerate) {
                genScopeProcInLoop = true;
                break;
            }
        // INTERFACE gen scopes bind their for-generate locals (Surelog);
        // module for-generate locals stay unbound.
        if (genScopeProcInLoop && m->UhdmType() == UHDM::uhdminterface_inst)
            genScopeProcInLoop = false;
        for (auto& gm : blk.members()) {
            if (gm.kind == SymbolKind::ProceduralBlock) {
                if (auto* p = emitProcess(gm.as<ProceduralBlockSymbol>(), m, fullName, netMap)) {
                    p->VpiParent(gs);
                    procs->push_back(p);
                }
            }
        }
        inGenScopeProc = false;
        currentGenBlkScope = nullptr;
        suppressRefActual = false;
        if (!procs->empty())
            gs->Process(procs);

        // NESTED generates (for/if inside this block): their gen_scope_arrays
        // attach to THIS gen_scope (not the module).
        auto* nestedGsas = s.MakeGen_scope_arrayVec();
        for (auto& gm : blk.members()) {
            if (gm.kind == SymbolKind::GenerateBlockArray) {
                auto& arr2 = gm.as<GenerateBlockArraySymbol>();
                for (auto entry2 : arr2.entries) {
                    if (entry2->isUninstantiated)
                        continue;
                    std::string idx2;
                    if (entry2->arrayIndex)
                        idx2 = entry2->arrayIndex->toString(LiteralBase::Decimal, false);
                    std::string nm2 =
                        std::string(arr2.getExternalName()) + "[" + idx2 + "]";
                    if (auto* ng = emitBlock(*entry2, nm2, fullName, gs))
                        nestedGsas->push_back(ng);
                }
            }
            else if (gm.kind == SymbolKind::GenerateBlock) {
                auto& blk2 = gm.as<GenerateBlockSymbol>();
                if (!blk2.isUninstantiated)
                    if (auto* ng = emitBlock(
                            blk2, std::string(blk2.getExternalName()), fullName, gs))
                        nestedGsas->push_back(ng);
            }
        }
        if (!nestedGsas->empty())
            gs->Gen_scope_arrays(nestedGsas);

        return gsa;
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
                if (auto* g = emitBlock(*entry, name, prefix, m))
                    gsas->push_back(g);
            }
        }
        else if (member.kind == SymbolKind::GenerateBlock) {
            auto& blk = member.as<GenerateBlockSymbol>();
            if (!blk.isUninstantiated) {
                std::string gname(blk.getExternalName());
                // Surelog identifies an UNNAMED gen block containing nested
                // generate constructs by its FIRST nested construct: named
                // genblk<idx+1> and spanning that construct.
                const syntax::SyntaxNode* spanOv = nullptr;
                if (gname.rfind("genblk", 0) == 0) {
                    for (auto& nm2 : blk.members()) {
                        if (nm2.kind != SymbolKind::GenerateBlock &&
                            nm2.kind != SymbolKind::GenerateBlockArray)
                            continue;
                        for (auto q = nm2.getSyntax(); q; q = q->parent)
                            if (q->kind == syntax::SyntaxKind::IfGenerate ||
                                q->kind == syntax::SyntaxKind::LoopGenerate ||
                                q->kind == syntax::SyntaxKind::CaseGenerate) {
                                spanOv = q;
                                break;
                            }
                        break;
                    }
                    if (spanOv && gname.rfind("genblk", 0) == 0)
                        gname = "genblk" +
                                std::to_string(atoi(gname.c_str() + 6) + 1);
                }
                // A taken BARE-STATEMENT else-if branch (unnamed genblkN whose
                // syntax is a plain statement under IfGenerate < ElseClause)
                // is WRAPPED: outer genblkN spans the taken IfGenerate's whole
                // remaining chain, and the content lives in a NESTED
                // genblkN.genblk1 at the statement span (Surelog re-pass).
                const syntax::SyntaxNode* elseIfChain9 = nullptr;
                if (gname.rfind("genblk", 0) == 0 && !spanOv) {
                    if (auto bs9 = blk.getSyntax();
                        bs9 && bs9->kind != syntax::SyntaxKind::GenerateBlock &&
                        bs9->parent &&
                        bs9->parent->kind == syntax::SyntaxKind::IfGenerate &&
                        bs9->parent->parent &&
                        bs9->parent->parent->kind ==
                            syntax::SyntaxKind::ElseClause)
                        elseIfChain9 = bs9->parent;
                }
                if (elseIfChain9) {
                    std::string outerFull = prefix + "." + gname;
                    auto* ogsa = s.MakeGen_scope_array();
                    ogsa->VpiName(gname);
                    ogsa->VpiFullName(outerFull);
                    ogsa->VpiParent(m);
                    setLoc(ogsa, elseIfChain9->sourceRange());
                    auto* ogs = s.MakeGen_scope();
                    ogs->VpiFullName(outerFull);
                    ogs->VpiParent(ogsa);
                    setLoc(ogs, elseIfChain9->sourceRange());
                    auto* ogv = s.MakeGen_scopeVec();
                    ogv->push_back(ogs);
                    ogsa->Gen_scopes(ogv);
                    if (auto* ig = emitBlock(blk, "genblk1", outerFull, ogs)) {
                        // The re-pass nested CA leaves its LHS ref UNBOUND
                        // (Surelog).
                        if (ig->Gen_scopes())
                            for (auto* igs9 : *ig->Gen_scopes())
                                if (auto* cas9 = igs9->Cont_assigns())
                                    for (auto* ca9 : *cas9)
                                        if (auto* lhs9 = ca9->Lhs();
                                            lhs9 && lhs9->UhdmType() ==
                                                        UHDM::uhdmref_obj)
                                            ((UHDM::ref_obj*)lhs9)
                                                ->Actual_group(nullptr);
                        auto* igv = s.MakeGen_scope_arrayVec();
                        igv->push_back(ig);
                        ogs->Gen_scope_arrays(igv);
                    }
                    gsas->push_back(ogsa);
                }
                else if (auto* g = emitBlock(blk, gname, prefix, m)) {
                    if (spanOv) {
                        setLoc(g, spanOv->sourceRange());
                        if (g->Gen_scopes() && !g->Gen_scopes()->empty())
                            setLoc((*g->Gen_scopes())[0],
                                   spanOv->sourceRange());
                    }
                    gsas->push_back(g);
                }
            }
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
    std::span<syntax::VariableDimensionSyntax* const> dims0;
    if (auto* its0 = tsyn0->as_if<syntax::IntegerTypeSyntax>())
        dims0 = its0->dimensions;
    else if (auto* imt0 = tsyn0->as_if<syntax::ImplicitTypeSyntax>())
        dims0 = imt0->dimensions;
    else
        return false;
    bool found = false;
    for (auto* dim : dims0) {
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
            // SINGLE-VIEW top module (def == top): the def net ref REUSES
            // the elab view's per-net alias-clone — one clone per net,
            // shared across views (Surelog, net_types).
            if (pn.di && pn.di->mod) {
                for (auto& tp9 : topPendings) {
                    if (tp9.m->VpiDefName() != pn.di->mod->VpiDefName())
                        continue;
                    UHDM::any* ln9 = nullptr;
                    if (auto nit9 = tp9.nets.find(pn.sym);
                        nit9 != tp9.nets.end())
                        ln9 = nit9->second;
                    else
                        for (auto& [ns9, no9] : tp9.nets)
                            if (ns9->name == pn.sym->name &&
                                ns9->location == pn.sym->location) {
                                ln9 = no9;
                                break;
                            }
                    if (ln9 && ln9->UhdmType() == UHDM::uhdmlogic_net)
                        if (auto* rt9 = ((UHDM::logic_net*)ln9)->Typespec())
                            if (auto* act9 = rt9->Actual_typespec()) {
                                pn.rt->Actual_typespec(act9);
                                return;
                            }
                }
            }
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
    // A PACKAGE packed-array typedef signal (pkg::b c) shares the NAMED
    // shared pkg typespec directly (Surelog).
    if (!ts) {
        if (auto dt3 = pn.sym->getDeclaredType()) {
            auto& t3 = dt3->getType();
            if (t3.kind == SymbolKind::TypeAlias) {
                if (auto ps3 = t3.as<TypeAliasType>().getParentScope();
                    ps3 && ps3->asSymbol().kind == SymbolKind::Package) {
                    if (auto i4 = pkgTopTypedefTs.find(&t3);
                        i4 != pkgTopTypedefTs.end() &&
                        i4->second->UhdmType() ==
                            UHDM::uhdmpacked_array_typespec)
                        ts = i4->second;
                    else if (auto i5 = typedefTs.find(&t3);
                             i5 != typedefTs.end() &&
                             i5->second->UhdmType() ==
                                 UHDM::uhdmpacked_array_typespec)
                        ts = i5->second;
                    if (ts) {
                        pn.rt->Actual_typespec(ts);
                        return;
                    }
                }
            }
        }
    }
    // An INITIALIZED pkg-struct signal (p::S m = '{...}) gets a FRESH
    // pkg-scoped clone (doubled p::p::S member refs, parent+Instance = the
    // package) spanning typedef-start .. the signal's INIT end (Surelog).
    if (!ts) {
        auto dt4 = pn.sym->getDeclaredType();
        if (dt4 && dt4->getInitializer()) {
            auto& t4 = dt4->getType();
            if (t4.kind == SymbolKind::TypeAlias &&
                t4.getCanonicalType().isStruct()) {
                auto sc4 = t4.as<TypeAliasType>().getParentScope();
                if (sc4 && sc4->asSymbol().kind == SymbolKind::Package) {
                    std::string pn4(sc4->asSymbol().name);
                    std::string alias4 =
                        pn4 + "::" + pn4 + "::" + std::string(t4.name);
                    auto& ct4 = t4.getCanonicalType();
                    bool savedTf4 = tfContext;
                    tfContext = true;
                    UHDM::struct_typespec* cl4 =
                        ct4.kind == SymbolKind::PackedStructType
                            ? buildStructTs(ct4.as<PackedStructType>(), true,
                                            alias4, "::")
                            : buildStructTs(ct4.as<UnpackedStructType>(),
                                            false, alias4, "::");
                    tfContext = savedTf4;
                    cl4->VpiName(pn4 + "::" + std::string(t4.name));
                    if (auto pit4 = pkgDefMap.find(&sc4->asSymbol());
                        pit4 != pkgDefMap.end()) {
                        cl4->VpiParent(pit4->second);
                        cl4->Instance(pit4->second);
                    }
                    SourceLocation st4;
                    bool haveStart4 = false;
                    if (auto as4 = t4.as<TypeAliasType>().getSyntax())
                        if (as4->kind ==
                            syntax::SyntaxKind::TypedefDeclaration) {
                            st4 = as4->as<syntax::TypedefDeclarationSyntax>()
                                      .type->sourceRange()
                                      .start();
                            haveStart4 = true;
                        }
                    auto en4 = dt4->getInitializer()->sourceRange.end();
                    if (haveStart4)
                        setLoc(cl4, SourceRange(st4, en4));
                    pn.rt->Actual_typespec(cl4);
                    return;
                }
            }
        }
    }
    // A def-view bound referencing an OVERRIDDEN param stays UNFOLDED
    // (name-only refs) — the folded value is override-dependent.
    if (!ts) {
        bool savedTf0 = tfContext;
        if (rangeRefsOverriddenParam(*pn.sym))
            tfContext = true;
        // A packed array over a VECTOR TYPEDEF (logic4 [1:0] v) needs the
        // anonymous-logic-ts branch of makeTypespec (Elem ref -> typedef, array
        // dim as range); that branch is tfContext-gated, but the write-phase
        // drain runs with tfContext forced on. The dims here are literal, so
        // clear it for this net.
        bool vectorTypedefArray = false;
        const TypeAliasType* vtaElem = nullptr;
        UHDM::typespec* vtaBase = nullptr;
        if (auto* dtv = pn.sym->getDeclaredType();
            dtv && dtv->getType().kind == SymbolKind::PackedArrayType) {
            auto& etv = dtv->getType().as<PackedArrayType>().elementType;
            if (etv.kind == SymbolKind::TypeAlias) {
                if (auto titv = typedefTs.find(&etv);
                    titv != typedefTs.end() &&
                    titv->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                    vectorTypedefArray = true;
                    vtaElem = &etv.as<TypeAliasType>();
                    vtaBase = titv->second;
                }
            }
        }
        if (vectorTypedefArray)
            tfContext = false;
        ts = makeTypespec(*pn.sym);
        tfContext = savedTf0;
        // The anonymous logic ts's Elem ref binds the BARE shared typedef;
        // Surelog instead points it at a fresh NAMED alias-clone (name, ranges,
        // Typedef_alias -> the shared base, Instance = module) created per use.
        if (vectorTypedefArray && vtaElem && vtaBase &&
            ts->UhdmType() == UHDM::uhdmlogic_typespec) {
            if (auto* et = ((UHDM::logic_typespec*)ts)->Elem_typespec()) {
                const syntax::SyntaxNode* tgtSyn = nullptr;
                if (auto asyn = vtaElem->getSyntax())
                    if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                        tgtSyn =
                            asyn->as<syntax::TypedefDeclarationSyntax>().type;
                bypassTypedefShare = true;
                auto* cl = makeTypespec(*vtaElem, tgtSyn);
                bypassTypedefShare = false;
                cl->VpiName(vtaElem->name);
                auto* art = s.MakeRef_typespec();
                art->VpiFullName(std::string(vtaElem->name));
                art->VpiParent(cl);
                art->Actual_typespec(vtaBase);
                ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
                cl->Instance(vtaBase->Instance());
                et->Actual_typespec(cl);
            }
        }
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
    for (auto it9 = pendingIfacePortTs.rbegin(); it9 != pendingIfacePortTs.rend();
         ++it9)
        it9->first->Actual_typespec(makeIfacePortTs(*it9->second));
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

        // A top-module port with an INITIALIZER carries a FOLDED-value
        // HighConn (64-bit; a call-fold encodes signed INT, a literal UINT).
        if (auto* pinit = ps.getInitializer()) {
            ASTContext hctx(comp.getRoot(), LookupLocation::max);
            ConstantValue hcv = hctx.tryEval(*pinit);
            if (hcv && hcv.isInteger() && !hcv.integer().hasUnknown()) {
                bool isCall =
                    stripImplicitConv(*pinit).kind == ExpressionKind::Call;
                std::string digits =
                    hcv.integer().toString(LiteralBase::Decimal, false);
                auto* rc = s.MakeConstant();
                rc->VpiSize(64);
                rc->VpiDecompile(digits);
                rc->VpiValue((isCall ? "INT:" : "UINT:") + digits);
                rc->VpiConstType(isCall ? vpiIntConst : vpiUIntConst);
                setLoc(rc, pinit->sourceRange);
                p->High_conn((UHDM::expr*)rc);
            }
        }

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
        // An UNPACKED-array port's DEF-side re-bound typespec is an
        // array_typespec wrapping the fresh element ts (vpiArrayType + one
        // range per unpacked dim, spanning type..last-dim), created here in
        // the write phase (arena tail); the TOP port keeps the def's original
        // bare element ts via the swap below.
        UHDM::typespec* defPts = pts;
        if (internal && internal->getDeclaredType() &&
            internal->getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType) {
            auto* ats = s.MakeArray_typespec();
            ats->VpiParent(p);
            ats->VpiArrayType(1);
            SourceLocation aStart = internal->location, aEnd = internal->location;
            if (auto tsn = internal->getDeclaredType()->getTypeSyntax())
                aStart = tsn->sourceRange().start();
            if (auto dsyn = internal->getSyntax();
                dsyn && dsyn->kind == syntax::SyntaxKind::Declarator)
                for (auto dim : dsyn->as<syntax::DeclaratorSyntax>().dimensions) {
                    aEnd = dim->sourceRange().end();
                    // A SIZE dim ([4]) ends BEFORE its bracket; a ranged dim
                    // ([15:0]) includes it (Surelog quirk).
                    if (dim->specifier &&
                        dim->specifier->kind ==
                            syntax::SyntaxKind::RangeDimensionSpecifier &&
                        dim->specifier->as<syntax::RangeDimensionSpecifierSyntax>()
                            .selector->kind == syntax::SyntaxKind::BitSelect)
                        aEnd = aEnd - 1;
                }
            setLoc(ats, SourceRange(aStart, aEnd));
            if (auto* ranges = buildUnpackedRanges(
                    *internal, ats, tp.prefix + "." + std::string(ps.name)))
                ats->Ranges(ranges);
            auto* ert = s.MakeRef_typespec();
            ert->VpiParent(ats);
            ert->VpiFullName(tp.prefix + "." + std::string(ps.name));
            ert->Actual_typespec(pts);
            ats->Elem_typespec(ert);
            defPts = ats;
        }
        // An IMPORTED-unqualified pkg-typedef port's TOP typespec is a fresh
        // NAMED clone (unqualified name, Typedef_alias ref to the shared pkg
        // ts, anchored range bounds); def port and net keep the shared ts.
        UHDM::typespec* topActual = defActual ? defActual : pts;
        if (internal && internal->getDeclaredType()) {
            auto& pt0 = internal->getDeclaredType()->getType();
            if (pt0.kind == SymbolKind::TypeAlias) {
                auto sc0 = pt0.as<TypeAliasType>().getParentScope();
                auto tsyn0 = internal->getDeclaredType()->getTypeSyntax();
                if (sc0 && sc0->asSymbol().kind == SymbolKind::Package && tsyn0 &&
                    tsyn0->kind == syntax::SyntaxKind::NamedType &&
                    tsyn0->as<syntax::NamedTypeSyntax>().name->kind ==
                        syntax::SyntaxKind::IdentifierName) {
                    if (auto tit0 = typedefTs.find(&pt0);
                        tit0 != typedefTs.end() &&
                        tit0->second->UhdmType() == UHDM::uhdmlogic_typespec) {
                        const syntax::SyntaxNode* targetSyn = nullptr;
                        if (auto asyn = pt0.as<TypeAliasType>().getSyntax())
                            if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
                                targetSyn =
                                    asyn->as<syntax::TypedefDeclarationSyntax>().type;
                        bypassTypedefShare = true;
                        auto* cl = makeTypespec(*internal, targetSyn);
                        bypassTypedefShare = false;
                        cl->VpiName(pt0.name);
                        auto* art = s.MakeRef_typespec();
                        art->VpiFullName(std::string(pt0.name));
                        art->VpiParent(cl);
                        art->Actual_typespec(tit0->second);
                        ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
                        if (tit0->second->Instance())
                            cl->Instance(tit0->second->Instance());
                        topActual = cl;
                        // The DEF-view port clones too — a QUALIFIED-named
                        // sibling (typedef-aliased to the shared pkg ts,
                        // instanced at the package). It does NOT share the pkg
                        // ts like a plain qualified-port would (Surelog).
                        bypassTypedefShare = true;
                        auto* dcl = makeTypespec(*internal, targetSyn);
                        bypassTypedefShare = false;
                        dcl->VpiName(std::string(tit0->second->VpiName()));
                        auto* dart = s.MakeRef_typespec();
                        dart->VpiFullName(std::string(tit0->second->VpiName()));
                        dart->VpiParent(dcl);
                        dart->Actual_typespec(tit0->second);
                        ((UHDM::logic_typespec*)dcl)->Typedef_alias(dart);
                        if (tit0->second->Instance())
                            dcl->Instance(tit0->second->Instance());
                        defPts = dcl;
                    }
                }
            }
        }
        // A `parameter type T`-typed port's vpiTypedef (top AND def views)
        // shares the ONE def-view type-param DEFAULT typespec object (Surelog).
        if (internal) {
            if (auto* tpp = portTypeParam(*internal)) {
                auto tit = typeParamDefaultTs.find(
                    {(const void*)&tp.inst->getDefinition(), std::string(tpp->name)});
                if (tit != typeParamDefaultTs.end()) {
                    topActual = tit->second;
                    defPts = tit->second;
                }
            }
        }
        // A vector-typedef-typed port's vpiTypedef is a self-alias clone in
        // BOTH views, but Surelog makes them DISTINCT: the DEF-view clone is
        // bare (no Instance), the ELAB (top) clone carries the design/module
        // Instance. The def view (emitPorts) already built the bare clone —
        // keep it for defPts and mint a fresh instanced sibling for topActual.
        // Skipped when the pkg / type-param branches above assigned clones.
        if (internal && defPts == pts && defActual &&
            defActual->UhdmType() == UHDM::uhdmlogic_typespec &&
            ((UHDM::logic_typespec*)defActual)->Typedef_alias()) {
            defPts = defActual;
            if (auto* tcl = portVectorTypedefClone(*internal, /*withInstance=*/true))
                topActual = tcl;
            else
                topActual = defActual;
        }
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(tp.prefix + "." + std::string(ps.name));
        rt->VpiParent(p);
        rt->Actual_typespec(topActual);
        if (defRt)
            defRt->Actual_typespec(defPts);
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
                auto ik = ct.as<PredefinedIntegerType>().integerKind;
                if (ik == PredefinedIntegerType::Byte) {
                    auto* bts2 = s.MakeByte_typespec();
                    bts2->VpiSigned(ct.isSigned());
                    tts = bts2;
                }
                else {
                    auto* its2 = s.MakeInt_typespec();
                    its2->VpiSigned(ct.isSigned());
                    tts = its2;
                }
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
        // MULTIPARAM def: an UNTYPED defaulted param fold carries an
        // int_typespec spanning the whole param declaration (Surelog
        // resolves the implicit int type) — checked BEFORE the bare-vec
        // branch, which would otherwise claim the implicit logic[31:0].
        bool implicitMP = false;
        if (auto d9 = pc.ps->getDeclaredType()) {
            auto t9 = d9->getTypeSyntax();
            if (!t9 || t9->kind == syntax::SyntaxKind::ImplicitType) {
                auto sc9 = pc.ps->getParentScope();
                implicitMP = sc9 && sc9->asSymbol().kind ==
                                        SymbolKind::InstanceBody;
            }
        }
        if (implicitMP) {
            auto* it9 = s.MakeInt_typespec();
            for (auto p9 = pc.ps->getSyntax(); p9; p9 = p9->parent)
                if (p9->kind == syntax::SyntaxKind::ParameterDeclaration) {
                    setLoc(it9, p9->sourceRange());
                    break;
                }
            it9->VpiParent(pc.rt);
            pc.rt->Actual_typespec(it9);
            continue;
        }
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

    // Net-decl-assign Lhs typespecs (last in the arena). A NAMED shared
    // typedef ts keeps its own parent (the package); only fresh anonymous
    // typespecs parent at the ref.
    for (auto& [rt, sym] : pendingNetDeclTs) {
        auto* fts = makeTypespec(*sym);
        if (fts->VpiName().empty())
            fts->VpiParent(rt);
        rt->Actual_typespec(fts);
    }
    pendingNetDeclTs.clear();
    // Array-of-struct net-decl-assign Lhs: the ELEMENT struct typespec (the
    // shared typedef object), not the array net's own array/logic typespec.
    for (auto& [rt, ety] : pendingNetDeclElemTs) {
        UHDM::typespec* ets = nullptr;
        if (auto tit = typedefTs.find(ety); tit != typedefTs.end())
            ets = tit->second;
        if (ets)
            rt->Actual_typespec(ets);
    }
    pendingNetDeclElemTs.clear();
    // Gen-block REAL-localparam typespecs: the CA constant's LOC-LESS bare
    // clone, then the typed param ts (Surelog: after the top-port ts, before
    // the genvar int ts).
    for (auto& gl : pendingGenLpTs) {
        if (gl.crt && gl.typedLp)
            if (auto* bare = makeBareVecParamTs(*gl.ps, false))
                gl.crt->Actual_typespec(bare);
        // A FRESH elab ts, parented at the elab ref (Surelog). An UNTYPED
        // gen localparam resolves to an int_typespec spanning the FULL
        // parameter declaration (3rd sighting of the untyped->int rule).
        UHDM::typespec* its = nullptr;
        if (!gl.typedLp) {
            auto* it9 = s.MakeInt_typespec();
            for (auto q9 = gl.ps->getSyntax(); q9; q9 = q9->parent)
                if (q9->kind == syntax::SyntaxKind::ParameterDeclaration) {
                    setLoc(it9, q9->sourceRange());
                    break;
                }
            its = it9;
        }
        else
            its = makeParamTs(*gl.ps, gl.typedLp);
        if (its) {
            gl.rt->Actual_typespec(its);
            its->VpiParent(gl.rt);
            if (gl.crt && !gl.crt->Actual_typespec())
                gl.crt->Actual_typespec(its);
            // The adopted elab pattern operand shares this localparam's int
            // typespec (Surelog: the operand IS the localparam value).
            if (gl.operandRt && !gl.operandRt->Actual_typespec())
                gl.operandRt->Actual_typespec(its);
            if (gl.hierIdxRt && !gl.hierIdxRt->Actual_typespec())
                gl.hierIdxRt->Actual_typespec(its);
        }
    }
    pendingGenLpTs.clear();
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

// A port typed by a vector typedef needs its vpiTypedef to be a fresh
// self-alias clone (Typedef_alias -> shared base) rather than the bare shared
// base — Surelog gives each such USE (net or port) its own clone. Mirrors the
// net's fileLevelVec / module-local clone logic (emitInstance ~1690-1770).
UHDM::logic_typespec* UhdmExporter::portVectorTypedefClone(const Symbol& internal,
                                                           bool withInstance) {
    auto dtv = internal.getDeclaredType();
    if (!dtv)
        return nullptr;
    auto& tv = dtv->getType();
    if (tv.kind != SymbolKind::TypeAlias)
        return nullptr;
    auto& ta = tv.as<TypeAliasType>();
    auto* parentScope = ta.getParentScope();
    if (!parentScope)
        return nullptr;
    auto parentKind = parentScope->asSymbol().kind;
    // Package-typedef ports (qualified `pkg::T` OR imported-unqualified) bind
    // the SHARED pkg base ts here; the emitTopPorts pkg branch builds the elab
    // clone for the imported-unqualified case. Never clone them in this helper.
    if (parentKind == SymbolKind::Package)
        return nullptr;
    // Applies to file-level (compilation unit) vector typedefs and module-local
    // vector typedefs the def registered as clone sources (typedefClone). Both
    // resolve to a bare logic_typespec base.
    bool fileLevelVec = false;
    if (!typedefClone.count(&tv) && parentKind == SymbolKind::CompilationUnit) {
        if (auto tit1 = typedefTs.find(&tv);
            tit1 != typedefTs.end() &&
            tit1->second->UhdmType() == UHDM::uhdmlogic_typespec &&
            ta.targetType.getType().kind != SymbolKind::TypeAlias)
            fileLevelVec = true;
    }
    if (!(typedefClone.count(&tv) || fileLevelVec))
        return nullptr;
    auto tit0 = typedefTs.find(&tv);
    if (tit0 == typedefTs.end() ||
        tit0->second->UhdmType() != UHDM::uhdmlogic_typespec)
        return nullptr;
    const syntax::SyntaxNode* targetSyn = nullptr;
    if (auto asyn = ta.getSyntax())
        if (asyn->kind == syntax::SyntaxKind::TypedefDeclaration)
            targetSyn = asyn->as<syntax::TypedefDeclarationSyntax>().type;
    bypassTypedefShare = true;
    auto* cl = makeTypespec(internal, targetSyn);
    bypassTypedefShare = false;
    if (!cl || cl->UhdmType() != UHDM::uhdmlogic_typespec)
        return nullptr;
    cl->VpiName(tv.name);
    auto* art = s.MakeRef_typespec();
    art->VpiFullName(std::string(tv.name));
    art->VpiParent(cl);
    art->Actual_typespec(tit0->second);
    ((UHDM::logic_typespec*)cl)->Typedef_alias(art);
    // The elab (top) port clone carries the shared base's Instance link; the
    // def-view port clone omits it (Surelog: top-port clones instanced, def-
    // port clones bare).
    if (withInstance && tit0->second->Instance())
        cl->Instance(tit0->second->Instance());
    return (UHDM::logic_typespec*)cl;
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
            p->VpiDirection(interfacePortDirection(ip));
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

        // A port with an INITIALIZER (output integer w = bar(4)) carries a
        // vpiHighConn = the init expression (a call stays a call; a literal
        // folds to a constant).
        if (auto* init0 = ps.getInitializer()) {
            bool sip = inParamInit, spc = portInitCtx;
            // A port-init call anchors at the callee name and its args carry
            // no formal-ts refs; a literal HighConn stays UNPARENTED.
            inParamInit = true;
            portInitCtx = true;
            if (auto* h = emitExpr(*init0, p, prefix, netMap)) {
                // A plain-ref default doubles its fullname through the
                // PORT name (work@cnt.cnt.initval — Surelog).
                if (h->UhdmType() == UHDM::uhdmref_obj)
                    ((UHDM::ref_obj*)h)
                        ->VpiFullName(prefix + "." + std::string(ps.name) +
                                      "." +
                                      std::string(
                                          ((UHDM::ref_obj*)h)->VpiName()));
                p->High_conn((UHDM::expr*)h);
            }
            inParamInit = sip;
            portInitCtx = spc;
        }

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
                UHDM::typespec* ts = nullptr;
                // A `parameter type T`-typed port's vpiTypedef shares the ONE
                // def-view type-param DEFAULT typespec object (Surelog).
                if (auto* tp = portTypeParam(*internal)) {
                    auto tit = typeParamDefaultTs.find(
                        {(const void*)&body.getDefinition(), std::string(tp->name)});
                    if (tit != typeParamDefaultTs.end())
                        ts = tit->second;
                }
                // A vector-typedef-typed port's vpiTypedef gets its OWN
                // self-alias clone (Typedef_alias -> shared base), like the
                // net's typespec, instead of the bare shared base (Surelog).
                if (!ts)
                    ts = portVectorTypedefClone(*internal);
                if (!ts)
                    ts = sharedTs ? sharedTypespec(*internal, *sharedTs, &ps)
                                  : makeTypespec(*internal, nullptr, &ps);
                // A DEF-view UNPACKED-array port of a 2-STATE (bit) element
                // wraps its element ts in an array_typespec (vpiArrayType,
                // one range per unpacked dim, spanning type..last-dim) —
                // Surelog. 4-state elements keep the bare element ts.
                bool twoStateArr9 = false;
                if (internal->getDeclaredType() &&
                    internal->getDeclaredType()
                            ->getType()
                            .getCanonicalType()
                            .kind == SymbolKind::FixedSizeUnpackedArrayType) {
                    const Type* lf9 = &internal->getDeclaredType()
                                           ->getType()
                                           .getCanonicalType();
                    while (lf9->getCanonicalType().kind ==
                           SymbolKind::FixedSizeUnpackedArrayType)
                        lf9 = &lf9->getCanonicalType()
                                   .as<FixedSizeUnpackedArrayType>()
                                   .elementType;
                    auto& lc9 = lf9->getCanonicalType();
                    // BIT-kind leaves (scalar/vector) and packed-STRUCT
                    // leaves wrap; predefined int/byte and plain logic
                    // vectors keep the bare element ts (Surelog).
                    twoStateArr9 = ((lc9.kind == SymbolKind::ScalarType ||
                                     lc9.kind == SymbolKind::PackedArrayType) &&
                                    lc9.isIntegral() && !lc9.isFourState()) ||
                                   lc9.kind == SymbolKind::PackedStructType;
                }
                if (!topView && m->UhdmType() == UHDM::uhdmmodule_inst &&
                    twoStateArr9) {
                    auto* ats = s.MakeArray_typespec();
                    ats->VpiParent(p);
                    ats->VpiArrayType(1);
                    SourceLocation aStart = internal->location,
                                   aEnd = internal->location;
                    if (auto tsn = internal->getDeclaredType()->getTypeSyntax())
                        aStart = tsn->sourceRange().start();
                    if (auto dsyn = internal->getSyntax();
                        dsyn && dsyn->kind == syntax::SyntaxKind::Declarator)
                        for (auto dim :
                             dsyn->as<syntax::DeclaratorSyntax>().dimensions) {
                            aEnd = dim->sourceRange().end();
                            if (dim->specifier &&
                                dim->specifier->kind ==
                                    syntax::SyntaxKind::
                                        RangeDimensionSpecifier &&
                                dim->specifier
                                        ->as<syntax::
                                                 RangeDimensionSpecifierSyntax>()
                                        .selector->kind ==
                                    syntax::SyntaxKind::BitSelect)
                                aEnd = aEnd - 1;
                        }
                    setLoc(ats, SourceRange(aStart, aEnd));
                    if (auto* ranges = buildUnpackedRanges(
                            *internal, ats,
                            prefix + "." + std::string(ps.name)))
                        ats->Ranges(ranges);
                    auto* ert = s.MakeRef_typespec();
                    ert->VpiParent(ats);
                    ert->VpiFullName(prefix + "." + std::string(ps.name));
                    ert->Actual_typespec(ts);
                    ats->Elem_typespec(ert);
                    ts = ats;
                }
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

// Gate primitives (and/or/nand/nor/xor/xnor/buf/not): a gate object per
// instance under vpiPrimitive — DefName work@<prim>, PrimType from the vpi
// enum, and a prim_term per connection (output first, TermIndex from 1; buf/
// not have the INPUT last instead). Term exprs are ref_objs scoped through
// the GATE instance (prefix.<gate>.<actual>), actual -> the module net.
void UhdmExporter::emitGates(const InstanceBodySymbol& body, UHDM::module_inst* m,
                             const std::string& prefix, NetMap& netMap,
                             bool topView) {
    UHDM::VectorOfprimitive* prims = nullptr;
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::PrimitiveInstance)
            continue;
        auto& pi = member.as<PrimitiveInstanceSymbol>();
        std::string pname(pi.primitiveType.name);
        static const std::map<std::string, int32_t> primMap = {
            {"and", vpiAndPrim},   {"nand", vpiNandPrim}, {"nor", vpiNorPrim},
            {"or", vpiOrPrim},     {"xor", vpiXorPrim},   {"xnor", vpiXnorPrim},
            {"buf", vpiBufPrim},   {"not", vpiNotPrim}};
        auto pmIt = primMap.find(pname);
        if (pmIt == primMap.end()) {
            noteUnsupported("gate primitive: " + pname);
            continue;
        }
        auto* g = s.MakeGate();
        g->VpiParent(m);
        g->VpiDefName("work@" + pname);
        g->VpiName(member.name);
        std::string gfull = prefix + "." + std::string(member.name);
        g->VpiFullName(gfull);
        g->VpiPrimType(pmIt->second);
        if (auto syn = pi.getSyntax())
            setLoc(g, syn->sourceRange());
        auto* terms = s.MakePrim_termVec();
        auto conns = pi.getPortConnections();
        // DEF view: Surelog marks ONLY term 0 as the output — even for a
        // multi-output buf/not. ELAB view: TRUE directions (buf/not: all but
        // the last are outputs).
        bool outLast = topView && (pname == "buf" || pname == "not");
        int32_t idx = 0;
        for (auto* ce : conns) {
            if (!ce) {
                idx++;
                continue;
            }
            auto* t = s.MakePrim_term();
            t->VpiParent(g);
            setLoc(t, ce->sourceRange);
            bool isOut = outLast ? (idx + 1 < (int32_t)conns.size()) : idx == 0;
            t->VpiDirection(isOut ? vpiOutput : vpiInput);
            if (idx > 0)
                t->VpiTermIndex(idx);
            // An OUTPUT terminal binds as an implicit assignment (o = <gate>);
            // the term expr is its LHS.
            const Expression* te = &stripImplicitConv(*ce);
            if (te->kind == ExpressionKind::Assignment)
                te = &stripImplicitConv(te->as<AssignmentExpression>().left());
            auto& se = *te;
            if (se.kind == ExpressionKind::NamedValue) {
                auto& nv = se.as<NamedValueExpression>();
                auto* r = s.MakeRef_obj();
                r->VpiParent(g);
                r->VpiName(nv.symbol.name);
                r->VpiFullName(gfull + "." + std::string(nv.symbol.name));
                setLoc(r, ce->sourceRange);
                if (auto nit = netMap.find(&nv.symbol); nit != netMap.end())
                    r->Actual_group(nit->second);
                t->Expr(r);
            }
            else if (auto* e = emitExpr(*ce, t, prefix, netMap)) {
                t->Expr((UHDM::expr*)e);
            }
            terms->push_back(t);
            idx++;
        }
        g->Prim_terms(terms);
        if (!prims)
            prims = s.MakePrimitiveVec();
        prims->push_back(g);
    }
    if (prims && !prims->empty())
        m->Primitives(prims);
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
        // Packed-struct signals with an assignment-pattern init are emitted as
        // struct_nets (see emitInstance) and likewise take a net-decl assign.
        // An unpacked array-of-struct with an assignment-pattern init
        // (tl_h2d_t a[1:0] = '{...}) is an array_net that likewise takes a
        // net-decl assign (fresh struct_net Lhs of the ELEMENT type).
        bool arrOfStruct = false;
        const Type* arrElemTy = nullptr; // non-canonical element (the alias)
        if (it.sym->kind == SymbolKind::Variable &&
            nit->second->UhdmType() == UHDM::uhdmarray_net) {
            const Type* el = &dt->getType();
            while (el->getCanonicalType().kind ==
                   SymbolKind::FixedSizeUnpackedArrayType)
                el = &el->getCanonicalType()
                          .as<FixedSizeUnpackedArrayType>()
                          .elementType;
            arrOfStruct = el->getCanonicalType().isStruct();
            arrElemTy = el;
        }
        if (it.sym->kind != SymbolKind::Net &&
            !(it.sym->kind == SymbolKind::Variable &&
              nit->second->UhdmType() == UHDM::uhdmlogic_net &&
              dt->getType().isIntegral()) &&
            !(it.sym->kind == SymbolKind::Variable &&
              nit->second->UhdmType() == UHDM::uhdmstruct_net) &&
            !arrOfStruct)
            continue;
        auto* ca = s.MakeCont_assign();
        ca->VpiParent(m);
        ca->VpiNetDeclAssign(true);
        setLoc(ca, nameSpan(it.sym->location, it.sym->name));
        bool fcp = forceConstParent;
        forceConstParent = true;
        UHDM::any* rhs = nullptr;
        // A PACKED-struct assignment-pattern net-decl RHS folds to an op75
        // wrapping the packed constant value (Surelog), not a tagged-pattern
        // tree — the struct is integral, so the whole pattern is one constant.
        if (nit->second->UhdmType() == UHDM::uhdmstruct_net) {
            auto& pat = stripImplicitConv(*dt->getInitializer());
            if (pat.kind == ExpressionKind::SimpleAssignmentPattern ||
                pat.kind == ExpressionKind::StructuredAssignmentPattern ||
                pat.kind == ExpressionKind::ReplicatedAssignmentPattern) {
                if (auto* fc = tryFoldConst(*dt->getInitializer())) {
                    auto* op = s.MakeOperation();
                    op->VpiOpType(vpiAssignmentPatternOp);
                    op->VpiParent(ca);
                    setLoc(op, pat.sourceRange);
                    fc->VpiParent(op);
                    auto* ov = s.MakeAnyVec();
                    ov->push_back(fc);
                    op->Operands(ov);
                    rhs = op;
                }
            }
        }
        if (!rhs)
            rhs = emitExpr(*dt->getInitializer(), ca, prefix, netMap);
        if (rhs) {
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
            bool isStructNet =
                nit->second->UhdmType() == UHDM::uhdmstruct_net || arrOfStruct;
            UHDM::net* lnet = isStructNet ? (UHDM::net*)s.MakeStruct_net()
                                          : (UHDM::net*)s.MakeLogic_net();
            lnet->VpiName(it.sym->name);
            lnet->VpiFullName(prefix + "." + std::string(it.sym->name));
            lnet->VpiParent(ca);
            if (isStructNet)
                // A struct_net re-elaborated LHS spans the NAME only.
                setLoc(lnet, nameSpan(it.sym->location, it.sym->name));
            else {
                ((UHDM::logic_net*)lnet)->VpiNetType(mnet->VpiNetType());
                if (mnet->VpiSigned())
                    lnet->VpiSigned(true);
                setLoc(lnet, regNetSpan(*it.sym));
            }
            if ((mnet->Typespec() && mnet->Typespec()->Actual_typespec()) ||
                arrOfStruct) {
                auto* rt = s.MakeRef_typespec();
                rt->VpiFullName(prefix + "." + std::string(it.sym->name));
                rt->VpiParent(lnet);
                lnet->Typespec(rt);
                if (arrOfStruct && arrElemTy)
                    pendingNetDeclElemTs.push_back({rt, arrElemTy});
                else
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
        // An implicit-net LHS cont_assign shares the DEF-view object into
        // the elab list bare (the net itself is dropped there — Surelog).
        if (topView) {
            auto& lc0 = stripImplicitConv(ae.left());
            if (lc0.kind == ExpressionKind::NamedValue &&
                lc0.as<NamedValueExpression>().symbol.kind == SymbolKind::Net &&
                lc0.as<NamedValueExpression>().symbol.as<NetSymbol>().isImplicit &&
                !implicitNetKeptInElab(&lc0.as<NamedValueExpression>().symbol,
                                       body)) {
                if (defInfo && myIdx < defInfo->contAssigns.size())
                    cas->push_back(defInfo->contAssigns[myIdx]);
                continue;
            }
        }
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
        // An element-select on an UNPACKED-ARRAY param (LP[0], P[i][j]): the
        // elab view re-emits it FOLDED to the element constant (Surelog), so it
        // must NOT share the def-view var_select/bit_select.
        bool unpackedParamSel = false;
        {
            auto& rc = stripImplicitConv(ae.right());
            const Expression* selBase = &rc;
            while (selBase->kind == ExpressionKind::ElementSelect)
                selBase =
                    &stripImplicitConv(selBase->as<ElementSelectExpression>().value());
            if (rc.kind == ExpressionKind::ElementSelect &&
                selBase->kind == ExpressionKind::NamedValue) {
                auto& bsym = selBase->as<NamedValueExpression>().symbol;
                if (bsym.kind == SymbolKind::Parameter) {
                    if (bsym.getType().getCanonicalType().kind ==
                        SymbolKind::FixedSizeUnpackedArrayType)
                        unpackedParamSel = true;
                    if (auto sc0 = bsym.getParentScope();
                        sc0 && sc0->asSymbol().kind == SymbolKind::Package)
                        pkgParamSel = &bsym.as<ParameterSymbol>();
                }
            }
        }
        // A CHILD-instance PART-SELECT-of-parameter RHS folds fresh in the
        // elab view (loc-less BIN) — it must not share the def CA.
        bool paramPartSelRhs = false;
        if (prefix.find('.') != std::string::npos) {
            auto& rc0p = stripImplicitConv(ae.right());
            if (rc0p.kind == ExpressionKind::RangeSelect) {
                auto& b0p = stripImplicitConv(
                    rc0p.as<RangeSelectExpression>().value());
                if (b0p.kind == ExpressionKind::NamedValue &&
                    b0p.as<NamedValueExpression>().symbol.kind ==
                        SymbolKind::Parameter)
                    paramPartSelRhs = true;
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
                    // A typedef-return call WITHOUT args never folds
                    // (TypedefedFunctionReturn); with args it still folds
                    // (TypedefedRangedFunctionArgument).
                    typedefRet =
                        (*subp0)->getReturnType().kind == SymbolKind::TypeAlias &&
                        rc.as<CallExpression>().arguments().empty();
        }
        // Signed-scalar-formal calls never straight-line-reduce (the body
        // conversion changes the value).
        bool sgnFormal9 = false;
        {
            auto& rc9e = stripImplicitConv(ae.right());
            if (rc9e.kind == ExpressionKind::Call &&
                !rc9e.as<CallExpression>().isSystemCall())
                if (auto sp9e = std::get_if<const SubroutineSymbol*>(
                        &rc9e.as<CallExpression>().subroutine))
                    for (auto a9e : (*sp9e)->getArguments())
                        if (a9e->getType().isSigned() &&
                            a9e->getType().getCanonicalType().kind ==
                                SymbolKind::ScalarType) {
                            sgnFormal9 = true;
                            break;
                        }
        }
        CallFold cfr = (topView && !typedefRet && !sgnFormal9)
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
                if (cv && cv.isInteger() && !cv.integer().hasUnknown()) {
                    // An IMPURE function (writes a symbol outside itself)
                    // is not folded: the def cont_assign is shared into the
                    // elab view instead.
                    auto subp2 =
                        std::get_if<const SubroutineSymbol*>(
                            &rc.as<CallExpression>().subroutine);
                    if (!subp2 || !subWritesNonLocal(**subp2))
                        callFold = std::move(cv);
                }
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
        // A member access on a STRUCT-typed param (assign o = P.a) folds in
        // the ELAB view to the member's pattern-setter constant (fresh CA,
        // def CA not shared).
        const Expression* structParamSetter = nullptr;
        if (topView) {
            auto& rc = stripImplicitConv(ae.right());
            if (rc.kind == ExpressionKind::MemberAccess) {
                auto& ma = rc.as<MemberAccessExpression>();
                auto& base = stripImplicitConv(ma.value());
                if (base.kind == ExpressionKind::NamedValue &&
                    base.as<NamedValueExpression>().symbol.kind ==
                        SymbolKind::Parameter) {
                    auto& psym = base.as<NamedValueExpression>()
                                     .symbol.as<ParameterSymbol>();
                    if (psym.getType().getCanonicalType().kind ==
                        SymbolKind::PackedStructType) {
                        if (auto pinit = psym.getInitializer()) {
                            auto& ic = stripImplicitConv(*pinit);
                            if (ic.kind ==
                                ExpressionKind::StructuredAssignmentPattern) {
                                auto& ap =
                                    ic.as<StructuredAssignmentPatternExpression>();
                                for (auto& ms : ap.memberSetters)
                                    if (ms.member == &ma.member) {
                                        structParamSetter = ms.expr;
                                        break;
                                    }
                                if (!structParamSetter)
                                    structParamSetter = ap.defaultSetter;
                            }
                        }
                    }
                }
            }
        }
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
                    // A whole STRUCT/UNION-typed param ref stays a shared ref
                    // in the elab CA (Surelog keeps the ref_obj, no fold).
                    auto ck9 = ps.getType().getCanonicalType().kind;
                    if (auto dt = ps.getDeclaredType();
                        dt && ck9 != SymbolKind::PackedStructType &&
                        ck9 != SymbolKind::PackedUnionType)
                        if (auto tsyn = dt->getTypeSyntax())
                            if (tsyn->kind != syntax::SyntaxKind::ImplicitType &&
                                ((ps.getValue().isInteger() &&
                                  !ps.getValue().integer().hasUnknown()) ||
                                 (ps.getType().getCanonicalType().isString() &&
                                  moduleStringParamConst.count(&sym))))
                                typedParamRhs = &sym;
                    // An UNTYPED param with a default, non-overridden, inside a
                    // uniquified MULTIPARAM def folds like a typed one (its
                    // clone yields the int typespec) — Surelog re-compiles the
                    // concrete value.
                    if (!typedParamRhs && ck9 != SymbolKind::PackedStructType &&
                        ck9 != SymbolKind::PackedUnionType &&
                        paramDefaultSyn(ps) &&
                        // CONST-FUNCTION-initialized params keep the def CA
                        // share (no fresh elab fold) — Surelog.
                        !([&] {
                            if (!ps.getInitializer())
                                return false;
                            bool call9 = false;
                            ps.getInitializer()->visit(makeVisitor(
                                [&](auto& v9, const CallExpression& cc9) {
                                    if (!cc9.isSystemCall())
                                        call9 = true;
                                    v9.visitDefault(cc9);
                                }));
                            return call9;
                        }()) &&
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
                if (bsym && bsym->kind == SymbolKind::InterfacePort) {
                    ifaceDotFresh = true;
                    // A PASSTHROUGH-connected port (the conn names the
                    // instantiating module's own iface PORT) keeps the
                    // SHARED def cont_assign.
                    if (auto pi9 = body.parentInstance)
                        for (auto pc9 : pi9->getPortConnections())
                            if (&pc9->port == bsym)
                                if (auto ce9 = connectionExpr(*pc9))
                                    if (auto ps9 = pi9->getParentScope())
                                        if (auto* cs9 = ps9->find(
                                                rawText(ce9->sourceRange));
                                            cs9 && cs9->kind ==
                                                       SymbolKind::InterfacePort)
                                            ifaceDotFresh = false;
                }
            }
        }
        // A select-LHS over an UNPACKED-array base (intermediate[3] = ...,
        // intermediate[depth2Index(1)] = ...) re-emits a FRESH elab
        // cont_assign whose Rhs shares the def constant; vector-base selects
        // stay shared.
        bool callIdxLhs = false;
        if (auto& l1 = stripImplicitConv(ae.left());
            l1.kind == ExpressionKind::ElementSelect) {
            auto& b1 = stripImplicitConv(l1.as<ElementSelectExpression>().value());
            if (b1.kind == ExpressionKind::NamedValue &&
                b1.as<NamedValueExpression>()
                        .symbol.getType()
                        .getCanonicalType()
                        .kind == SymbolKind::FixedSizeUnpackedArrayType)
                callIdxLhs = true;
        }
        if (shareWithDef && defInfo && myIdx < defInfo->contAssigns.size() &&
            ((!plainLhs && !dottedLhs && !ifaceDotFresh && !callIdxLhs &&
              !callFold) ||
             (plainLhs &&
              !containsOperation(ae.right()) && !literalRhs && !enumRhs && !cfr &&
              !callFold && !ovParamRhs && !typedParamRhs && !constVarRhs &&
              !pkgParamSel && !unpackedParamSel && !noDefOvRhs &&
              !paramPartSelRhs && !structParamSetter))) {
            cas->push_back(defInfo->contAssigns[myIdx]);
            continue;
        }
        // A CONCAT-LHS const-call CA keeps the DEF form (func_call Rhs,
        // already merged from the def pass) and adds a fresh elab CA with
        // the folded constant (Surelog) — no extra share push.
        auto* ca = s.MakeCont_assign();
        ca->VpiParent(m);
        // A comma-list continuous assign (assign a=0, b=1;) gives EVERY
        // cont_assign the whole list's span (Surelog quirk), not each
        // sub-assign's.
        SourceRange caLoc = assign.sourceRange;
        if (auto* asyn = casym.getSyntax())
            for (auto p = asyn->parent; p; p = p->parent)
                if (p->kind == syntax::SyntaxKind::ContinuousAssign) {
                    auto& cas = p->as<syntax::ContinuousAssignSyntax>();
                    if (cas.assignments.size() > 1)
                        caLoc = cas.assignments.sourceRange();
                    break;
                }
        setLoc(ca, caLoc);
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
        // An UNQUALIFIED imported enum const keeps its ref (only pkg::VALUE
        // folds) — Surelog.
        if (pkgEnumRhs &&
            rawText(stripImplicitConv(ae.right()).sourceRange).find("::") ==
                std::string::npos) {
            pkgEnumRhs = false;
            enumRhs = nullptr;
        }
        // An enum-ALIAS-typed LHS (output pkg::b o; assign o = pkg::x): the
        // TOP view folds FRESH (decimal decompile, parented at the ca, sized
        // to the LHS enum width, at the RHS span) instead of sharing the pkg
        // fold constant.
        bool aliasEnumLhs = false;
        if (topView && pkgEnumRhs) {
            auto& l2 = stripImplicitConv(ae.left());
            if (l2.kind == ExpressionKind::NamedValue) {
                auto& lt2 = l2.as<NamedValueExpression>().symbol.getType();
                if (lt2.kind == SymbolKind::TypeAlias &&
                    lt2.as<TypeAliasType>().targetType.getType().kind ==
                        SymbolKind::TypeAlias) {
                    pkgEnumRhs = false;
                    aliasEnumLhs = true;
                }
            }
        }
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
                if (aliasEnumLhs) {
                    c->VpiSize((int32_t)ae.left().type->getBitWidth());
                    setLoc(c, stripImplicitConv(ae.right()).sourceRange);
                }
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
                // The fold is TRUNCATED to the assignment target width when the
                // LHS net is narrower than the param (Surelog); a wider/equal
                // LHS keeps the param's own width.
                int32_t ovW = (int32_t)iv.getBitWidth();
                if (ae.left().type &&
                    (int32_t)ae.left().type->getBitWidth() < ovW)
                    ovW = (int32_t)ae.left().type->getBitWidth();
                c->VpiSize(ovW);
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
        // A STRING typed-param ref (o = X) SHARES the param's elab fold
        // constant (Surelog expression cache), re-parenting it at THIS
        // cont-assign (the param_assign's Rhs then back-references it).
        if (!rhs && topView && typedParamRhs &&
            typedParamRhs->as<ParameterSymbol>().getType().getCanonicalType().isString()) {
            if (auto sit = moduleStringParamConst.find(typedParamRhs);
                sit != moduleStringParamConst.end()) {
                rhs = sit->second;
                ((UHDM::constant*)rhs)->VpiParent(ca);
            }
        }
        // A typed PART-SELECT param ref (o = FullDepth) shares the param's
        // BIN fold constant the same way.
        if (!rhs && topView) {
            const Symbol* pref = nullptr;
            if (auto& rcp = stripImplicitConv(ae.right());
                rcp.kind == ExpressionKind::NamedValue &&
                rcp.as<NamedValueExpression>().symbol.kind == SymbolKind::Parameter)
                pref = &rcp.as<NamedValueExpression>().symbol;
            if (pref) {
                if (auto fit = moduleParamFoldConst.find(pref);
                    fit != moduleParamFoldConst.end()) {
                    rhs = fit->second;
                    ((UHDM::constant*)rhs)->VpiParent(ca);
                }
            }
        }
        // A CHILD-instance CA whose RHS is a PART-SELECT of a parameter
        // folds to a LOC-LESS BIN constant at the select width (bit-string
        // decompile) — Surelog.
        if (!rhs && topView && prefix.find('.') != std::string::npos) {
            auto& rps9 = stripImplicitConv(ae.right());
            if (rps9.kind == ExpressionKind::RangeSelect) {
                auto& base9 = stripImplicitConv(
                    rps9.as<RangeSelectExpression>().value());
                if (base9.kind == ExpressionKind::NamedValue &&
                    base9.as<NamedValueExpression>().symbol.kind ==
                        SymbolKind::Parameter) {
                    ASTContext ctx9(comp.getRoot(), LookupLocation::max);
                    if (auto cv9 = ctx9.tryEval(rps9);
                        cv9 && cv9.isInteger() &&
                        !cv9.integer().hasUnknown()) {
                        auto iv9 = cv9.integer();
                        int32_t w9 = (int32_t)iv9.getBitWidth();
                        std::string bits9;
                        for (int32_t i9 = w9 - 1; i9 >= 0; i9--)
                            bits9 +=
                                iv9[i9] == slang::logic_t(1) ? '1' : '0';
                        auto* c9 = s.MakeConstant();
                        c9->VpiDecompile(bits9);
                        c9->VpiSize(w9);
                        c9->VpiValue("BIN:" + bits9);
                        c9->VpiConstType(vpiBinaryConst);
                        c9->VpiParent(ca);
                        rhs = c9;
                    }
                }
            }
        }
        // Typed non-overridden param ref: folded default constant + a ref to
        // the param's typespec (cloned at the end of the write phase). Located
        // at the param's default-value expression.
        if (!rhs && topView && typedParamRhs &&
            typedParamRhs->as<ParameterSymbol>().getValue().isInteger()) {
            auto& ps2 = typedParamRhs->as<ParameterSymbol>();
            slang::SVInt iv = ps2.getValue().integer();
            // Truncated (value AND size) to a narrower assignment target
            // width (Surelog).
            int32_t tpW = (int32_t)iv.getBitWidth();
            if (ae.left().type && (int32_t)ae.left().type->getBitWidth() < tpW) {
                tpW = (int32_t)ae.left().type->getBitWidth();
                iv = iv.resize((slang::bitwidth_t)tpW);
                // The truncated bits encode UNSIGNED (Surelog).
                iv.setSigned(false);
            }
            bool neg = iv.isSigned() && iv.isNegative();
            std::string digits = iv.toString(LiteralBase::Decimal, false);
            auto* c = s.MakeConstant();
            c->VpiDecompile(digits);
            c->VpiValue((neg ? "INT:" : "UINT:") + digits);
            c->VpiConstType(neg ? vpiIntConst : vpiUIntConst);
            c->VpiSize(tpW);
            c->VpiParent(ca);
            // A LOCAL param folds at its default-value expression; an IMPORTED
            // param (package-scoped, materialized here) folds at the REFERENCE
            // site instead — the copy is resolved at the use, not the source
            // declaration (Surelog).
            bool impRef = ps2.getParentScope() &&
                          ps2.getParentScope()->asSymbol().kind ==
                              SymbolKind::Package;
            if (impRef)
                setLoc(c, stripImplicitConv(ae.right()).sourceRange);
            else if (auto* dsy = paramDefaultSyn(ps2))
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
            // A no-default TYPED param overridden by a plain (un-based) integer
            // literal folds to a UINT constant carrying the param's own
            // typespec (Surelog) — the untyped case keeps no typespec below.
            else if (ovc.kind == ExpressionKind::IntegerLiteral &&
                     ps2.getValue().isInteger() &&
                     !ps2.getValue().integer().hasUnknown()) {
                bool typed2 = false;
                if (auto dt2 = ps2.getDeclaredType())
                    if (auto tsyn2 = dt2->getTypeSyntax())
                        typed2 =
                            tsyn2->kind != syntax::SyntaxKind::ImplicitType;
                if (typed2) {
                    auto& iv = ps2.getValue().integer();
                    std::string digits = iv.toString(LiteralBase::Decimal, false);
                    auto* c = s.MakeConstant();
                    c->VpiDecompile(digits);
                    c->VpiValue("UINT:" + digits);
                    c->VpiConstType(vpiUIntConst);
                    int32_t nW = (int32_t)iv.getBitWidth();
                    if (ae.left().type &&
                        (int32_t)ae.left().type->getBitWidth() < nW)
                        nW = (int32_t)ae.left().type->getBitWidth();
                    c->VpiSize(nW);
                    c->VpiParent(ca);
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiFullName(prefix);
                    rt->VpiParent(c);
                    c->Typespec(rt);
                    pendingParamCloneTs.push_back({rt, &ps2});
                    rhs = c;
                }
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
        // A call whose FORMAL is SIGNED never straight-line-reduces (the
        // body conversion changes the value); it falls to the eval fold
        // with Surelog's shape: UINT at size 32, arg-span loc, formal-ts.
        const SubroutineSymbol* sgnSub9 = nullptr;
        {
            auto& rc9c = stripImplicitConv(ae.right());
            if (rc9c.kind == ExpressionKind::Call &&
                !rc9c.as<CallExpression>().isSystemCall())
                if (auto sp9 = std::get_if<const SubroutineSymbol*>(
                        &rc9c.as<CallExpression>().subroutine))
                    for (auto a9 : (*sp9)->getArguments())
                        if (a9->getType().isSigned() &&
                            a9->getType().getCanonicalType().kind ==
                                SymbolKind::ScalarType) {
                            sgnSub9 = *sp9;
                            break;
                        }
        }
        if (!rhs && topView && sgnSub9 && !callFold) {
            ASTContext gctx9(comp.getRoot(), LookupLocation::max);
            ConstantValue gcv9 = gctx9.tryEval(ae.right());
            if (gcv9 && gcv9.isInteger() && !gcv9.integer().hasUnknown())
                callFold = std::move(gcv9);
        }
        if (!rhs && topView && callFold && sgnSub9) {
            auto& iv9 = callFold->integer();
            auto uiv9 = iv9;
            uiv9.setSigned(false);
            std::string dg9 = uiv9.toString(LiteralBase::Decimal, false);
            auto* c9 = s.MakeConstant();
            c9->VpiDecompile(dg9);
            c9->VpiSize(32);
            c9->VpiValue("UINT:" + dg9);
            c9->VpiConstType(vpiUIntConst);
            c9->VpiParent(ca);
            auto& rc9d = stripImplicitConv(ae.right());
            if (!rc9d.as<CallExpression>().arguments().empty())
                setLoc(c9, rc9d.as<CallExpression>()
                               .arguments()[0]
                               ->sourceRange);
            if (auto smit9 = subMap.find(sgnSub9);
                smit9 != subMap.end() && !smit9->second.argTs.empty() &&
                smit9->second.argTs[0].first) {
                auto* rt9c = s.MakeRef_typespec();
                rt9c->VpiFullName(prefix);
                rt9c->VpiParent(c9);
                rt9c->Actual_typespec(smit9->second.argTs[0].first);
                c9->Typespec(rt9c);
            }
            rhs = c9;
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
            // A CONCAT-LHS call fold encodes BINARY at the full width, no
            // decompile (Surelog).
            else if (stripImplicitConv(ae.left()).kind ==
                     ExpressionKind::Concatenation) {
                int32_t w = (int32_t)iv.getBitWidth();
                std::string bits;
                for (int32_t i = w - 1; i >= 0; i--)
                    bits += (iv[i] == slang::logic_t(1)) ? '1' : '0';
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
            // A folded call that returns a[K] of a pattern-initialized local
            // (get_a1 -> a[1] of '{0,1}) locates at the SOURCE element token.
            if (rcCall.kind == ExpressionKind::Call) {
                if (auto sp0 = std::get_if<const SubroutineSymbol*>(
                        &rcCall.as<CallExpression>().subroutine)) {
                    const Statement* body = &(*sp0)->getBody();
                    const Expression* retExpr = nullptr;
                    std::function<void(const Statement&)> findRet =
                        [&](const Statement& st) {
                            if (retExpr)
                                return;
                            if (st.kind == StatementKind::Return) {
                                retExpr = st.as<ReturnStatement>().expr;
                                return;
                            }
                            if (st.kind == StatementKind::List)
                                for (auto s2 : st.as<StatementList>().list)
                                    findRet(*s2);
                            else if (st.kind == StatementKind::Block)
                                findRet(st.as<BlockStatement>().body);
                        };
                    if (body)
                        findRet(*body);
                    auto& re0 = retExpr ? stripImplicitConv(*retExpr) : rcCall;
                    if (re0.kind == ExpressionKind::ElementSelect) {
                        auto& es0 = re0.as<ElementSelectExpression>();
                        ASTContext ictx(comp.getRoot(), LookupLocation::max);
                        auto icv = ictx.tryEval(es0.selector());
                        auto& base0 = stripImplicitConv(es0.value());
                        if (icv && icv.isInteger() &&
                            base0.kind == ExpressionKind::NamedValue) {
                            auto* bsym = &base0.as<NamedValueExpression>().symbol;
                            if (auto bdt = bsym->getDeclaredType())
                                if (auto binit = bdt->getInitializer()) {
                                    auto& bp = stripImplicitConv(*binit);
                                    int idx = (int)icv.integer().as<int64_t>().value_or(0);
                                    if (bp.kind == ExpressionKind::SimpleAssignmentPattern) {
                                        auto els =
                                            bp.as<SimpleAssignmentPatternExpression>()
                                                .elements();
                                        if (idx >= 0 && idx < (int)els.size())
                                            setLoc(c, els[idx]->sourceRange);
                                    }
                                }
                        }
                    }
                }
            }
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
        // Unary-PLUS over a param ref keeps the operation (no fold);
        // unary-MINUS / binary-SUBTRACT over params fold to a loc-less
        // signed INT at the UNCONVERTED value, sized to the LHS width.
        bool skipGeneralFold = false;
        if (!rhs && topView) {
            auto& rn = stripImplicitConv(ae.right());
            bool unaryPlusParam =
                rn.kind == ExpressionKind::UnaryOp &&
                rn.as<UnaryExpression>().op == UnaryOperator::Plus &&
                stripImplicitConv(rn.as<UnaryExpression>().operand()).kind ==
                    ExpressionKind::NamedValue;
            if (unaryPlusParam)
                skipGeneralFold = true;
            bool minusParam =
                (rn.kind == ExpressionKind::UnaryOp &&
                 rn.as<UnaryExpression>().op == UnaryOperator::Minus &&
                 stripImplicitConv(rn.as<UnaryExpression>().operand()).kind ==
                     ExpressionKind::NamedValue) ||
                (rn.kind == ExpressionKind::BinaryOp &&
                 rn.as<BinaryExpression>().op == BinaryOperator::Subtract &&
                 (stripImplicitConv(rn.as<BinaryExpression>().left()).kind ==
                      ExpressionKind::NamedValue ||
                  stripImplicitConv(rn.as<BinaryExpression>().right()).kind ==
                      ExpressionKind::NamedValue));
            if (minusParam) {
                ASTContext nctx(comp.getRoot(), LookupLocation::max);
                ConstantValue ncv = nctx.tryEval(rn);
                int32_t w = (int32_t)ae.left().type->getBitWidth();
                if (ncv && ncv.isInteger() && !ncv.integer().hasUnknown() &&
                    w > 0) {
                    auto niv = ncv.integer();
                    niv.setSigned(true);
                    auto* c = s.MakeConstant();
                    c->VpiSize(w);
                    std::string digits = niv.toString(LiteralBase::Decimal, false);
                    c->VpiDecompile(digits);
                    c->VpiValue("INT:" + digits);
                    c->VpiConstType(vpiIntConst);
                    rhs = c;
                }
            }
        }
        // Whole struct/union-param refs never general-fold (SL keeps the ref).
        bool structWholeParamRef = false;
        {
            auto& rc9 = stripImplicitConv(ae.right());
            if (rc9.kind == ExpressionKind::NamedValue &&
                rc9.as<NamedValueExpression>().symbol.kind == SymbolKind::Parameter) {
                auto ck9 = rc9.as<NamedValueExpression>()
                               .symbol.getType()
                               .getCanonicalType()
                               .kind;
                structWholeParamRef = ck9 == SymbolKind::PackedStructType ||
                                      ck9 == SymbolKind::PackedUnionType;
            }
        }
        if (!rhs && !bitsRhs && !skipGeneralFold && !structParamSetter &&
            !structWholeParamRef) {
            // Unbased-unsized RHS never general-folds here: '1 folded above,
            // '0 shares the def constant, 'x/'z have unknowns. Replicated
            // patterns re-emit as operations. A CONCATENATION that references a
            // PARAMETER also stays an operation (its param operands keep their
            // ref_obj) — Surelog reduces a literal-only concat to a packed
            // constant but leaves a param concat ({a,b,c} of params) unfolded.
            bool paramConcat = false;
            if (stripImplicitConv(ae.right()).kind ==
                ExpressionKind::Concatenation)
                stripImplicitConv(ae.right())
                    .visit(makeVisitor([&](auto& v, const NamedValueExpression& nv) {
                        if (nv.symbol.kind == SymbolKind::Parameter)
                            paramConcat = true;
                        v.visitDefault(nv);
                    }));
            rhs = (topView && !paramConcat &&
                   stripImplicitConv(ae.right()).kind !=
                       ExpressionKind::UnbasedUnsizedIntegerLiteral &&
                   stripImplicitConv(ae.right()).kind !=
                       ExpressionKind::ReplicatedAssignmentPattern)
                      ? tryFoldConst(ae.right())
                      : nullptr;
        }
        // A NESTED cast RHS, or a cast whose operand is a PARAMETER ref
        // (int'(X)), that evals fully folds loc-less: UINT by magnitude at
        // the result width (signed wraps encode 4294967295-style). Casts of
        // literals / calls keep the operation.
        if (!rhs && topView) {
            auto& rc0 = stripImplicitConv(ae.right());
            auto& rcOp = rc0.kind == ExpressionKind::Conversion
                             ? stripImplicitConv(rc0.as<ConversionExpression>().operand())
                             : rc0;
            bool nestedCast =
                rc0.kind == ExpressionKind::Conversion &&
                !rc0.as<ConversionExpression>().isImplicit() &&
                rcOp.kind == ExpressionKind::Conversion &&
                !rcOp.as<ConversionExpression>().isImplicit();
            bool paramCast = rc0.kind == ExpressionKind::Conversion &&
                             !rc0.as<ConversionExpression>().isImplicit() &&
                             rcOp.kind == ExpressionKind::NamedValue &&
                             rcOp.as<NamedValueExpression>().symbol.kind ==
                                 SymbolKind::Parameter;
            // Only a param whose init references NO unknown-valued param
            // folds (C = A/B with A,B = 'x coerces to 0 in int context but
            // stays an operation; X = '1 folds).
            if (paramCast) {
                auto& psym =
                    rcOp.as<NamedValueExpression>().symbol.as<ParameterSymbol>();
                bool tainted = false;
                if (auto* pinit = psym.getInitializer())
                    pinit->visit(makeVisitor([&](auto& v, const NamedValueExpression& nvv) {
                        if (nvv.symbol.kind == SymbolKind::Parameter) {
                            auto& pv2 = nvv.symbol.as<ParameterSymbol>().getValue();
                            if (!pv2.isInteger() || pv2.integer().hasUnknown())
                                tainted = true;
                        }
                        v.visitDefault(nvv);
                    }));
                if (tainted)
                    paramCast = false;
                // A PKG-TYPEDEF'd vector param cast (int'(P), P typed by an
                // imported pkg typedef) keeps the cast op; module-local
                // typedefs still fold (Surelog).
                if (auto d1 = psym.getDeclaredType();
                    paramCast && d1 &&
                    d1->getType().kind == SymbolKind::TypeAlias &&
                    d1->getType().getParentScope() &&
                    d1->getType()
                            .getParentScope()
                            ->asSymbol()
                            .kind == SymbolKind::Package &&
                    ((psym.getType().getCanonicalType().kind ==
                          SymbolKind::PackedArrayType &&
                      psym.getType().getCanonicalType().isIntegral()) ||
                     psym.getType().getCanonicalType().kind ==
                         SymbolKind::PackedStructType))
                    paramCast = false;
            }
            if ((nestedCast || paramCast) && rc0.syntax &&
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
            // A SIGNED based literal NARROWER than the LHS does not share:
            // the elab view folds the sign-EXTENDED BIN at the net width
            // (bit-string decompile, bare int ts ref) — Surelog.
            bool signExt9 = false;
            if ((raw.find("'s") != std::string::npos ||
                 raw.find("'S") != std::string::npos) &&
                ae.left().type) {
                auto& lit9 = stripImplicitConv(ae.right());
                int32_t lw9 = (int32_t)ae.left().type->getBitWidth();
                if (lit9.type &&
                    (int32_t)lit9.type->getBitWidth() < lw9) {
                    ASTContext ctx9(comp.getRoot(), LookupLocation::max);
                    if (auto cv9 = ctx9.tryEval(ae.right());
                        cv9 && cv9.isInteger()) {
                        auto iv9 = cv9.integer();
                        std::string bits9;
                        for (int32_t i9 = lw9 - 1; i9 >= 0; i9--)
                            bits9 += iv9[i9] == slang::logic_t(1) ? '1' : '0';
                        auto* c9 = s.MakeConstant();
                        c9->VpiDecompile(bits9);
                        c9->VpiSize(lw9);
                        c9->VpiValue("BIN:" + bits9);
                        c9->VpiConstType(vpiBinaryConst);
                        c9->VpiParent(ca);
                        setLoc(c9, lit9.sourceRange);
                        auto* rt9 = s.MakeRef_typespec();
                        rt9->VpiFullName(prefix);
                        rt9->VpiParent(c9);
                        auto* its9x = s.MakeInt_typespec();
                        its9x->VpiParent(rt9);
                        rt9->Actual_typespec(its9x);
                        c9->Typespec(rt9);
                        rhs = c9;
                        signExt9 = true;
                    }
                }
            }
            if (!signExt9 && raw.find('\'') != std::string::npos)
                rhs = (UHDM::any*)defInfo->contAssigns[myIdx]->Rhs();
        }
        // Dotted-LHS re-emits share the def Rhs object wholesale.
        if (!rhs && topView && (dottedLhs || callIdxLhs) && shareWithDef && defInfo &&
            myIdx < defInfo->contAssigns.size())
            rhs = (UHDM::any*)defInfo->contAssigns[myIdx]->Rhs();
        // Struct-param member access folds to the member's setter constant
        // (source encoding + setter loc, parented at the ca).
        if (!rhs && topView && structParamSetter) {
            bool fsp = forceConstParent;
            forceConstParent = true;
            rhs = emitExpr(*structParamSetter, ca, prefix, netMap);
            forceConstParent = fsp;
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
            // DEF-view NESTED assignment-pattern RHS ('{'{0,1},..}): leaf
            // constants stay UNPARENTED (only the nested pattern operations
            // self-parent); the elab re-emit parents them normally. Flat and
            // replicated patterns keep their existing parenting/sizing.
            bool suppSaved = suppressConstParent;
            if (!topView) {
                auto& prc = stripImplicitConv(ae.right());
                if (prc.kind == ExpressionKind::SimpleAssignmentPattern)
                    for (auto* el :
                         prc.as<SimpleAssignmentPatternExpression>().elements())
                        if (stripImplicitConv(*el).kind ==
                            ExpressionKind::SimpleAssignmentPattern)
                            suppressConstParent = true;
            }
            paramInitDef = !topView;
            contAssignView = topView ? 2 : 1;
            // When the ENTIRE RHS is a signed based literal, record the LHS
            // target signedness (no implicit conversion is inserted for a
            // same-width signedness change) so the literal's int_typespec drops
            // vpiSigned for an unsigned target (Surelog).
            int savedICT7 = implicitConvTargetSigned;
            if (stripImplicitConv(ae.right()).kind ==
                    ExpressionKind::IntegerLiteral &&
                ae.left().type)
                implicitConvTargetSigned = ae.left().type->isSigned() ? 1 : 0;
            rhs = emitExpr(ae.right(), ca, prefix, rhsMap);
            implicitConvTargetSigned = savedICT7;
            contAssignView = 0;
            paramInitDef = false;
            // Flat pattern on an UNPACKED-array LHS: based-literal leaves are
            // SIZELESS in both views; the DEF view also leaves them UNPARENTED
            // (the elab re-emit parents them at the fresh op) — Surelog.
            if (rhs && rhs->UhdmType() == UHDM::uhdmoperation &&
                stripImplicitConv(ae.right()).kind ==
                    ExpressionKind::SimpleAssignmentPattern &&
                ae.left().type &&
                ae.left().type->getCanonicalType().kind ==
                    SymbolKind::FixedSizeUnpackedArrayType) {
                if (auto* ops9 = ((UHDM::operation*)rhs)->Operands())
                    for (auto* o9 : *ops9)
                        if (o9->UhdmType() == UHDM::uhdmconstant) {
                            if (!topView)
                                o9->VpiParent(nullptr);
                            auto ct9 = ((UHDM::constant*)o9)->VpiConstType();
                            if (ct9 == vpiBinaryConst || ct9 == vpiHexConst ||
                                ct9 == vpiOctConst)
                                ((UHDM::expr*)o9)->VpiSize(0);
                        }
            }
            suppressConstParent = suppSaved;
            forceConstParent = forceSaved;
            refCollector = nullptr;
            reemitting = false;
            // Re-emitted BARE literals and $bits folds size at the LHS
            // type width; a bare literal WIDER than the LHS also truncates
            // its value (out = 74 on a 1-bit net -> UINT:0).
            if (topView && rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                (bitsRhs ||
                 (literalRhs &&
                  rawText(stripImplicitConv(ae.right()).sourceRange).find('\'') ==
                      std::string::npos))) {
                int32_t w = (int32_t)ae.left().type->getBitWidth();
                auto* rc = (UHDM::constant*)rhs;
                rc->VpiSize(w);
                if (literalRhs && !bitsRhs &&
                    stripImplicitConv(ae.right()).kind ==
                        ExpressionKind::IntegerLiteral) {
                    auto lv =
                        stripImplicitConv(ae.right()).as<IntegerLiteral>().getValue();
                    if (!lv.hasUnknown() && w > 0 &&
                        (int32_t)lv.getActiveBits() > w) {
                        auto tv = lv.trunc((slang::bitwidth_t)w);
                        tv.setSigned(false);
                        std::string digits = tv.toString(LiteralBase::Decimal, false);
                        rc->VpiDecompile(digits);
                        rc->VpiValue("UINT:" + digits);
                    }
                }
            }
            // A def-view '0 RHS (alone among unbased-unsized) on a WHOLE-NET
            // LHS sizes at the LHS width; the elab view then shares this
            // constant. Select/dotted LHS keeps -1.
            if (!topView && rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                stripImplicitConv(ae.left()).kind == ExpressionKind::NamedValue &&
                stripImplicitConv(ae.right()).kind ==
                    ExpressionKind::UnbasedUnsizedIntegerLiteral &&
                rawText(stripImplicitConv(ae.right()).sourceRange) == "'0")
                ((UHDM::constant*)rhs)->VpiSize((int32_t)ae.left().type->getBitWidth());
            // An unsized BASED literal ('h42) keeps -1 on a dotted/select
            // LHS; only a whole-net LHS gets the bare-CA size-0 form.
            if (rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
                ((UHDM::constant*)rhs)->VpiSize() == 0 &&
                stripImplicitConv(ae.left()).kind != ExpressionKind::NamedValue &&
                stripImplicitConv(ae.right()).kind ==
                    ExpressionKind::IntegerLiteral) {
                auto rtx = rawText(stripImplicitConv(ae.right()).sourceRange);
                if (!rtx.empty() && rtx[0] == '\'')
                    ((UHDM::constant*)rhs)->VpiSize(-1);
            }
        }
        // A bare folded RHS constant (e.g. an untyped param ref -> value) that
        // no dedicated path parented takes the cont_assign as its parent —
        // only inside a uniquified MULTIPARAM def (Surelog leaves the
        // single-parameterization fold unparented).
        if (topView && rhs && rhs->UhdmType() == UHDM::uhdmconstant &&
            !rhs->VpiParent() && isMultiParamDef(body) &&
            stripImplicitConv(ae.right()).kind == ExpressionKind::NamedValue)
            rhs->VpiParent(ca);
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
            // A NESTED pattern ('{'{..},..}) leaves no orphan.
            bool nestedPat = false;
            if (rc.kind == ExpressionKind::SimpleAssignmentPattern)
                for (auto* el : rc.as<SimpleAssignmentPatternExpression>().elements())
                    if (stripImplicitConv(*el).kind ==
                        ExpressionKind::SimpleAssignmentPattern)
                        nestedPat = true;
            if (!nestedPat &&
                (rc.kind == ExpressionKind::SimpleAssignmentPattern ||
                 rc.kind == ExpressionKind::StructuredAssignmentPattern)) {
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
        elabContAssignLhs = topView;
        elabLhsReelab = topView && (literalRhs || bitsRhs ||
                                    containsOperation(ae.right()));
        // Literal-RHS re-emits bind BOTH sides to def-view objects.
        NetMap& lhsMap = (topView && shareWithDef &&
                          (literalRhs || bitsRhs || cfr || callFold || ovParamRhs ||
                           typedParamRhs || constVarRhs || noDefOvRhs || enumRhs) &&
                          defInfo)
                             ? defInfo->nets
                             : netMap;
        if (auto* l = emitExpr(ae.left(), ca, prefix, lhsMap))
            ca->Lhs((UHDM::expr*)l);
        elabContAssignLhs = false;
        elabLhsReelab = false;
        inLhs = false;
        cas->push_back(ca);
        if (defInfo)
            defInfo->contAssigns.push_back(ca);
    }
    // An INPUT port DEFAULT (input [3:0] delta = 10) synthesizes an elab
    // net-decl-assign cont_assign: fresh Lhs net (own ts) + the folded
    // default constant (Surelog).
    if (topView) {
        for (auto portBase : body.getPortList()) {
            if (portBase->kind != SymbolKind::Port)
                continue;
            auto& psD = portBase->as<PortSymbol>();
            if (psD.direction != ArgumentDirection::In)
                continue;
            const Expression* initD = psD.getInitializer();
            if (!initD && psD.internalSymbol)
                if (auto* dtsD = psD.internalSymbol->getDeclaredType())
                    initD = dtsD->getInitializer();
            if (!initD)
                continue;
            ASTContext dctx(comp.getRoot(), LookupLocation::max);
            ConstantValue dcv = dctx.tryEval(*initD);
            if (!dcv || !dcv.isInteger() || dcv.integer().hasUnknown())
                continue;
            auto* caD = s.MakeCont_assign();
            caD->VpiParent(m);
            caD->VpiNetDeclAssign(true);
            setLoc(caD, nameSpan(psD.location, psD.name));
            auto* cD = s.MakeConstant();
            std::string dg =
                dcv.integer().toString(LiteralBase::Decimal, false);
            cD->VpiDecompile(dg);
            cD->VpiSize((int32_t)psD.getType().getBitWidth());
            cD->VpiValue("UINT:" + dg);
            cD->VpiConstType(vpiUIntConst);
            cD->VpiParent(caD);
            setLoc(cD, stripImplicitConv(*initD).sourceRange);
            caD->Rhs(cD);
            auto* lnD = s.MakeLogic_net();
            lnD->VpiName(psD.name);
            lnD->VpiFullName(prefix + "." + std::string(psD.name));
            lnD->VpiParent(caD);
            setLoc(lnD, nameSpan(psD.location, psD.name));
            auto* rtD = s.MakeRef_typespec();
            rtD->VpiFullName(prefix + "." + std::string(psD.name));
            rtD->VpiParent(lnD);
            auto* ltD = s.MakeLogic_typespec();
            SourceRange ltSpanD{};
            bool haveSpanD = false;
            if (psD.internalSymbol)
                if (auto* dtsD2 = psD.internalSymbol->getDeclaredType())
                    if (auto tsnD = dtsD2->getTypeSyntax()) {
                        auto trD = tsnD->sourceRange();
                        std::string rwD = rawText(trD);
                        auto eD = trD.end();
                        while (!rwD.empty() &&
                               (rwD.back() == ' ' || rwD.back() == '\t')) {
                            rwD.pop_back();
                            eD = eD - 1;
                        }
                        ltSpanD = SourceRange(trD.start(), eD);
                        haveSpanD = true;
                        setLoc(ltD, ltSpanD);
                    }
            // The default-CA lhs ts carries the FOLDED [hi:lo] range and
            // stays UNPARENTED (Surelog).
            {
                auto& ptD = psD.getType().getCanonicalType();
                if (ptD.isIntegral() && ptD.getBitWidth() > 1 && haveSpanD) {
                    auto* rD = s.MakeRange();
                    rD->VpiParent(ltD);
                    setLoc(rD, ltSpanD);
                    auto rngD = ptD.getFixedRange();
                    auto mkCD = [&](int32_t v, int off) {
                        auto* c2 = s.MakeConstant();
                        std::string d2 = std::to_string(v);
                        c2->VpiDecompile(d2);
                        c2->VpiSize(64);
                        c2->VpiValue("UINT:" + d2);
                        c2->VpiConstType(vpiUIntConst);
                        c2->VpiParent(rD);
                        setLoc(c2, SourceRange(ltSpanD.start() + off,
                                               ltSpanD.start() + off + 1));
                        return c2;
                    };
                    rD->Left_expr(mkCD(rngD.left, 1));
                    rD->Right_expr(mkCD(rngD.right, 3));
                    auto* rvD = s.MakeRangeVec();
                    rvD->push_back(rD);
                    ltD->Ranges(rvD);
                }
            }
            rtD->Actual_typespec(ltD);
            lnD->Typespec(rtD);
            caD->Lhs(lnD);
            cas->push_back(caD);
        }
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
        // $UNIT functions with TYPEDEF'd returns get no return-var artifact
        // (body refs stay unbound; the Return uses the Typedef_alias clone).
        if (sub.getReturnType().kind == SymbolKind::TypeAlias) {
            if (auto ps0 = sub.getParentScope();
                ps0 && ps0->asSymbol().kind == SymbolKind::CompilationUnit)
                continue;
        }
        for (auto* r : pf.refs) {
            // The local's fullname mirrors the binding ref's scope (named
            // blocks included).
            std::string localFull(r->VpiFullName());
            if (localFull.empty())
                localFull = pf.fullName + "." + std::string(sub.name);
            auto* lv = makeReturnVar(s, sub.getReturnType(),
                                     [&] {
                                         auto* rs0 = returnTypeSyntax(sub);
                                         return rs0 && rs0->kind ==
                                             slang::syntax::SyntaxKind::ImplicitType;
                                     }());
            lv->VpiName(sub.name);
            lv->VpiFullName(localFull);
            lv->VpiParent(r);
            auto* rt = s.MakeRef_typespec();
            rt->VpiFullName(localFull);
            rt->VpiParent(lv);
            // A PKG-typedef return binds the SHARED pkg ts unmutated (its
            // package parent kept); other returns clone as before.
            UHDM::typespec* ts = nullptr;
            bool sharedPkg = false;
            if (sub.getReturnType().kind == SymbolKind::TypeAlias) {
                auto& rta = sub.getReturnType();
                if (auto sc0 =
                        rta.as<TypeAliasType>().getParentScope();
                    sc0 &&
                    (sc0->asSymbol().kind == SymbolKind::Package ||
                     sc0->asSymbol().kind == SymbolKind::CompilationUnit))
                    if (auto tit0 = typedefTs.find(&rta);
                        tit0 != typedefTs.end()) {
                        ts = tit0->second;
                        sharedPkg = true;
                    }
            }
            if (!ts) {
                tfContext = true;
                syntaxRefPrefix = localFull;
                ts = makeTypespec(*sub.returnValVar, returnTypeSyntax(sub));
                syntaxRefPrefix.clear();
                tfContext = false;
                ts->VpiParent(rt);
                if (pf.inst)
                    ts->Instance(pf.inst);
            }
            rt->Actual_typespec(ts);
            lv->Typespec(rt);
            // The ret var spans the RETURN TYPE syntax (trailing ws
            // trimmed).
            if (auto* rtsyn = returnTypeSyntax(sub)) {
                auto rr9 = rtsyn->sourceRange();
                std::string rw9 = rawText(rr9);
                auto re9 = rr9.end();
                while (!rw9.empty() &&
                       (rw9.back() == ' ' || rw9.back() == '\t')) {
                    rw9.pop_back();
                    re9 = re9 - 1;
                }
                setLoc(lv, SourceRange(rr9.start(), re9));
            }
            else {
                lv->VpiLineNo(ts->VpiLineNo());
                lv->VpiColumnNo(ts->VpiColumnNo());
                lv->VpiEndLineNo(ts->VpiEndLineNo());
                lv->VpiEndColumnNo(ts->VpiEndColumnNo());
            }
            (void)sharedPkg;
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
// True when the subroutine's immediate body writes a symbol OUTSIDE itself
// (out6[exp] = ... in a function): such calls never fold — the def
// cont_assign is shared into the elab view instead.
static bool subWritesNonLocal(const SubroutineSymbol& sub) {
    bool impure = false;
    sub.getBody().visit(makeVisitor([&](auto& vis, const AssignmentExpression& ax) {
        std::set<const Symbol*> ls;
        collectLhsSyms(ax.left(), ls);
        for (auto* s2 : ls) {
            bool inSub = false;
            for (auto sc = s2->getParentScope(); sc;
                 sc = sc->asSymbol().getParentScope())
                if (&sc->asSymbol() == (const Symbol*)&sub) {
                    inSub = true;
                    break;
                }
            if (!inSub)
                impure = true;
        }
        vis.visitDefault(ax);
    }));
    return impure;
}

UhdmExporter::CallFold UhdmExporter::constCallFold(const Expression& expr) {
    CallFold none;
    if (expr.kind != ExpressionKind::Call || expr.as<CallExpression>().isSystemCall())
        return none;
    auto& call = expr.as<CallExpression>();
    auto subp = std::get_if<const SubroutineSymbol*>(&call.subroutine);
    if (!subp)
        return none;
    if (subWritesNonLocal(**subp))
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

void UhdmExporter::emitNamedClockingBlocks(const InstanceBodySymbol& body,
                                           UHDM::instance* m,
                                           const std::string& prefix,
                                           NetMap& nm, bool defView) {
    UHDM::VectorOfclocking_block* vec = nullptr;
    // ELAB pass: resolve def-view event refs against this instance's nets.
    if (!defView)
        for (auto& [r9, sym9] : pendingCbRefs)
            if (auto nit9 = nm.find(sym9); nit9 != nm.end())
                r9->Actual_group(nit9->second);
    for (auto& member : body.members()) {
        if (member.kind != SymbolKind::ClockingBlock)
            continue;
        auto& cbs = member.as<ClockingBlockSymbol>();
        auto csyn = cbs.getSyntax();
        if (!csyn || csyn->kind != syntax::SyntaxKind::ClockingDeclaration)
            continue;
        auto& cdecl = csyn->as<syntax::ClockingDeclarationSyntax>();
        if (cdecl.globalOrDefault.valueText() == "default")
            continue; // handled by emitDefaultClocking
        std::string cbName(cbs.name);
        std::string cbFull = prefix + "." + cbName;
        auto* cb = s.MakeClocking_block();
        cb->VpiName(cbName);
        cb->VpiFullName(cbFull);
        cb->VpiParent(m);
        setLoc(cb, csyn->sourceRange());
        auto* ec = s.MakeEvent_control();
        ec->VpiParent(cb);
        setLoc(ec, SourceRange(cdecl.at.range().start(),
                               cdecl.event->sourceRange().end()));
        // Event refs emit UNBOUND in BOTH views; only the DEF ref binds
        // (to the ELAB var, via pendingCbRefs) — Surelog.
        NetMap emptyNm9;
        if (auto* cond = emitEventExpr(cbs.getEvent(), ec, cbFull, emptyNm9)) {
            ec->VpiCondition(cond);
            if (defView) {
                // Def-view event refs bind the ELAB var (patched late).
                std::function<void(UHDM::any*)> collect = [&](UHDM::any* e) {
                    if (!e)
                        return;
                    if (e->UhdmType() == UHDM::uhdmref_obj) {
                        auto* r0 = (UHDM::ref_obj*)e;
                        if (!r0->Actual_group())
                            if (auto* sym0 =
                                    body.find(std::string(r0->VpiName())))
                                pendingCbRefs.emplace_back(r0, sym0);
                    }
                    else if (e->UhdmType() == UHDM::uhdmoperation) {
                        if (auto* ops = ((UHDM::operation*)e)->Operands())
                            for (auto* o : *ops)
                                collect(o);
                    }
                };
                collect(cond);
            }
        }
        cb->Clocking_event(ec);
        auto* ios = s.MakeClocking_io_declVec();
        for (auto& cm : cbs.members()) {
            if (cm.kind != SymbolKind::ClockVar)
                continue;
            auto& cv = cm.as<ClockVarSymbol>();
            auto* io = s.MakeClocking_io_decl();
            io->VpiName(cv.name);
            io->VpiParent(cb);
            setLoc(io, nameSpan(cv.location, cv.name));
            int32_t dir = cv.direction == ArgumentDirection::In    ? vpiInput
                          : cv.direction == ArgumentDirection::Out ? vpiOutput
                          : cv.direction == ArgumentDirection::InOut ? vpiInout
                                                                     : 0;
            if (dir)
                io->VpiDirection(dir);
            ios->push_back(io);
        }
        if (!ios->empty())
            cb->Clocking_io_decls(ios);
        if (!vec)
            vec = s.MakeClocking_blockVec();
        vec->push_back(cb);
    }
    if (vec) {
        if (m->UhdmType() == UHDM::uhdminterface_inst)
            ((UHDM::interface_inst*)m)->Clocking_blocks(vec);
        else if (m->UhdmType() == UHDM::uhdmmodule_inst)
            ((UHDM::module_inst*)m)->Clocking_blocks(vec);
    }
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
            // Surelog binds |=> TIGHTER than until: lhs |=> c until d comes
            // out as until(implies(lhs, c), d), the hoisted until op left
            // UNPARENTED (sva_range).
            if ((bae.op == BinaryAssertionOperator::NonOverlappedImplication ||
                 bae.op == BinaryAssertionOperator::OverlappedImplication) &&
                bae.right.kind == AssertionExprKind::Binary &&
                (bae.right.as<BinaryAssertionExpr>().op ==
                     BinaryAssertionOperator::Until ||
                 bae.right.as<BinaryAssertionExpr>().op ==
                     BinaryAssertionOperator::SUntil)) {
                auto& rb = bae.right.as<BinaryAssertionExpr>();
                auto* uop = s.MakeOperation();
                uop->VpiOpType(mapAssertBinOp(rb.op));
                if (ae.syntax)
                    setLocCompact(uop, ae.syntax->sourceRange());
                auto* iop = s.MakeOperation();
                iop->VpiOpType(mapAssertBinOp(bae.op));
                iop->VpiParent(uop);
                if (bae.left.syntax && rb.left.syntax)
                    setLoc(iop,
                           SourceRange(bae.left.syntax->sourceRange().start(),
                                       rb.left.syntax->sourceRange().end()));
                auto* iops = s.MakeAnyVec();
                if (auto* l =
                        emitAssertionExpr(bae.left, iop, prefix, netMap))
                    iops->push_back(l);
                if (auto* r = emitAssertionExpr(rb.left, iop, prefix, netMap)) {
                    // Hoist-context whole-refs are BARE-named (sva_range).
                    if (r->UhdmType() == UHDM::uhdmref_obj)
                        ((UHDM::ref_obj*)r)->VpiFullName("");
                    iops->push_back(r);
                }
                iop->Operands(iops);
                auto* uops = s.MakeAnyVec();
                uops->push_back(iop);
                if (auto* r2 =
                        emitAssertionExpr(rb.right, uop, prefix, netMap)) {
                    if (r2->UhdmType() == UHDM::uhdmref_obj)
                        ((UHDM::ref_obj*)r2)->VpiFullName("");
                    uops->push_back(r2);
                }
                uop->Operands(uops);
                return uop;
            }
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
            // An UNBOUNDED range delay (a ##[*] b) is opType 60 with NO
            // delay constant and BARE-named operand refs; a LEADING delay
            // (|=> ##5 d, single element) is the unary form (53) spanning
            // from the delay constant (sva_range).
            bool unboundedDelay9 = false;
            for (auto& el : sc.elements)
                if (!el.delay.max)
                    unboundedDelay9 = true;
            bool leadingDelay9 = sc.elements.size() == 1 &&
                                 sc.elements[0].delay.min != 0;
            op->VpiOpType(unboundedDelay9 ? 60
                          : leadingDelay9 ? vpiUnaryCycleDelayOp
                                          : vpiCycleDelayOp);
            op->VpiParent(parent);
            // Span the elements themselves (Surelog strips enclosing parens).
            if (!sc.elements.empty() && sc.elements.front().sequence->syntax &&
                sc.elements.back().sequence->syntax) {
                auto st9 =
                    sc.elements.front().sequence->syntax->sourceRange().start();
                if (leadingDelay9 &&
                    sc.elements[0].delayRange.start() !=
                        SourceLocation::NoLocation)
                    st9 = sc.elements[0].delayRange.start() - 2;
                setLoc(op, SourceRange(
                              st9,
                              sc.elements.back().sequence->syntax->sourceRange().end()));
            }
            else if (ae.syntax)
                setLoc(op, ae.syntax->sourceRange());
            auto* operands = s.MakeAnyVec();
            bool first = true;
            for (auto& el : sc.elements) {
                if ((!first || el.delay.min != 0) && el.delay.max) {
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
                if (auto* e = emitAssertionExpr(*el.sequence, op, prefix, netMap)) {
                    // Bare-named refs inside the unbounded-range op.
                    if (unboundedDelay9 &&
                        e->UhdmType() == UHDM::uhdmref_obj)
                        ((UHDM::ref_obj*)e)->VpiFullName("");
                    operands->push_back(e);
                }
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
    if (auto syn = body.getSyntax()) {
        setLoc(iface, syn->sourceRange());
        // endinterface: <label>
        if (syn->kind == syntax::SyntaxKind::InterfaceDeclaration)
            if (auto* bn = syn->as<syntax::ModuleDeclarationSyntax>().blockName)
                iface->VpiEndLabel(bn->name.valueText());
    }

    emitParameters(body, iface, prefix, info.nets, /*topView=*/false, &info, false);

    // Interface-scope typedefs (typedef struct {...} req_t; INSIDE the
    // interface) list under the interface_inst's Typespecs, exactly like
    // module typedefs (member refs scope prefix.<td>.<member>).
    emitTypedefs(body, iface, prefix, info);

    auto* nets = s.MakeNetVec();
    UHDM::VectorOfarray_net* ifaceArrayNets9 = nullptr;
    // An unpacked-array-of-STRUCT signal: its base/inner nets carry the shared
    // struct ELEMENT typespec (the array dim lives on the array_net), just like
    // a plain struct net — Surelog. Returns nullptr for non-struct elements.
    auto structElemTs = [&](const Symbol& sym) -> UHDM::typespec* {
        auto dtp = sym.getDeclaredType();
        if (!dtp)
            return nullptr;
        const Type* canon = &dtp->getType().getCanonicalType();
        const Type* named = nullptr;
        while (canon->kind == SymbolKind::FixedSizeUnpackedArrayType) {
            named = &canon->as<FixedSizeUnpackedArrayType>().elementType;
            canon = &named->getCanonicalType();
        }
        if (!named || !canon->isStruct())
            return nullptr;
        if (auto i2 = typedefTs.find(named); i2 != typedefTs.end())
            return i2->second;
        if (auto i3 = pkgTopTypedefTs.find(named); i3 != pkgTopTypedefTs.end())
            return i3->second;
        return nullptr;
    };
    for (auto& it : collectNetOrder(body)) {
        std::string name(it.sym->name);
        auto* n = s.MakeLogic_net();
        n->VpiName(name);
        n->VpiFullName(prefix + "." + name);
        n->VpiParent(iface);
        setLoc(n, nameSpan(it.sym->location, it.sym->name));
        if (int32_t nt = netTypeFor(*it.sym))
            n->VpiNetType(nt);
        // An EXPLICITLY package-qualified struct interface VARIABLE
        // (p::req_t req) nets as a wire; an imported bare name (import p::*;
        // req_t req) or local typedef stays UNTYPED (Surelog keys on the
        // written form).
        else if (it.sym->kind == SymbolKind::Variable &&
                 isPkgStructType(*it.sym) && isExplicitPkgQualified(*it.sym) &&
                 !hasStructFieldMember(*it.sym))
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
            // Array-of-struct: the base net shares the struct element typespec
            // directly (no logic_typespec fold).
            if (auto* sts = structElemTs(*it.sym))
                rt->Actual_typespec(sts);
            else
                pendingNetTs.push_back({it.sym, rt, &info});
        }
        // Record the def net so def-view port LowConns can bind to it.
        info.nets[it.sym] = n;
        nets->push_back(n);
        // An UNPACKED-array iface signal ALSO lists an array_net (size 1,
        // dim range, LOC-LESS doubled inner net) — Surelog.
        if (it.sym->getDeclaredType() &&
            it.sym->getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType) {
            auto* an9 = s.MakeArray_net();
            an9->VpiName(name);
            an9->VpiFullName(prefix + "." + name);
            an9->VpiParent(iface);
            setLoc(an9, nameSpan(it.sym->location, it.sym->name));
            an9->VpiSize(1);
            // Def-view array_net keeps PARAM-based dim bounds symbolic
            // (ref_obj <arraynet>.<param>), so pass the array_net fullname.
            if (auto* rngs9 = buildUnpackedRanges(*it.sym, an9, prefix + "." + name))
                an9->Ranges(rngs9);
            auto* in9 = s.MakeLogic_net();
            in9->VpiName(name);
            in9->VpiFullName(prefix + "." + name + "." + name);
            in9->VpiParent(an9);
            auto* irt9 = s.MakeRef_typespec();
            irt9->VpiFullName(prefix + "." + name + "." + name);
            irt9->VpiParent(in9);
            in9->Typespec(irt9);
            // Struct-element array: inner net shares the struct element ts and
            // carries NO vpiNetType (Surelog); scalar-element arrays keep the
            // logic-net form (netType 36, deferred logic typespec).
            if (auto* sts = structElemTs(*it.sym))
                irt9->Actual_typespec(sts);
            else {
                in9->VpiNetType(36);
                pendingNetTs.push_back({it.sym, irt9, &info});
            }
            auto* inv9 = s.MakeNetVec();
            inv9->push_back(in9);
            an9->Nets(inv9);
            if (!ifaceArrayNets9)
                ifaceArrayNets9 = s.MakeArray_netVec();
            ifaceArrayNets9->push_back(an9);
        }
    }
    if (!nets->empty())
        iface->Nets(nets);
    if (ifaceArrayNets9)
        iface->Array_nets(ifaceArrayNets9);

    // Def-view cont-assigns and ports (LowConn only) reuse the shared helpers.
    // Processes are emitted once in the ELAB view and shared here (Surelog
    // folds a single process object into both interface_inst views).
    emitContAssigns(body, iface, prefix, info.nets, /*topView=*/false, &info, false, nullptr,
                    nullptr);

    // Modports: name + one io_decl (direction + name) per modport port.
    auto* mports = s.MakeModportVec();
    for (auto* mpPtr : sortedModports(body)) {
        auto& mp = *mpPtr;
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
    emitNamedClockingBlocks(body, iface, prefix, info.nets, /*defView=*/true);
    // Def-view generate placeholders (gen_for/gen_if/gen_case + unelaborated
    // begin bodies) — same emission the module def path uses.
    emitDefGenStmts(body, iface, prefix);
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
    // VARIABLE symbols only — NET-kind symbols (header-port-backing clk/rst
    // wires) are not listed as dup Variables (Surelog); they reach the dup via
    // the modport io_decl exprs instead.
    auto* vars = s.MakeVariablesVec();
    for (auto& it : collectNetOrder(body))
        if (auto nit = sharedNets.find(it.sym); nit != sharedNets.end()) {
            if (it.sym->kind == SymbolKind::Net)
                continue;
            // NET-CLASS home objects (struct_net members) are not dup
            // Variables either — they reach the dup via modport io exprs.
            switch (nit->second->UhdmType()) {
                case UHDM::uhdmstruct_net:
                case UHDM::uhdmlogic_net:
                case UHDM::uhdmarray_net:
                case UHDM::uhdmenum_net:
                case UHDM::uhdmpacked_array_net:
                    continue;
                default:
                    break;
            }
            vars->push_back((UHDM::variables*)nit->second);
        }
    if (!vars->empty())
        dup->Variables(vars);
    // The dup lists the iface's HEADER PORTS as BARE ports (name + decl
    // name span only) — Surelog.
    {
        auto* dports = s.MakePortVec();
        for (auto portBase : body.getPortList()) {
            if (portBase->kind != SymbolKind::Port)
                continue;
            auto& ps9 = portBase->as<PortSymbol>();
            auto* dp9 = s.MakePort();
            dp9->VpiName(ps9.name);
            dp9->VpiParent(dup);
            setLocNamed(dp9, ps9);
            dports->push_back(dp9);
        }
        if (!dports->empty())
            dup->Ports(dports);
    }

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
    for (auto* mpPtr : sortedModports(body)) {
        auto& mp = *mpPtr;
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
                                                          const InstanceSymbol* portView,
                                                          const std::string& connModport) {
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
    // EVERY port view carries NO param_assigns (Surelog quirk) — EXCEPT a
    // parameterized (multi-distinct-value) interface def, whose port-view keeps
    // the override param_assign.
    bool multiParamIface = isMultiParamDef(body);
    if (portView && !multiParamIface)
        iface->Param_assigns(nullptr);
    // A PLAIN (non-modport) PORT VIEW additionally lists each parameter TWICE
    // at its DEFAULT value. A MODPORT-qualified port view (myif.man b) keeps a
    // single param.
    if (portView && connModport.empty() && iface->Parameters()) {
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
    // overrides); the HOME view keeps the instance values. EXCEPTION: a
    // MULTI-parameterized interface def is uniquified per parameterization, so
    // its port-view folds at the CONNECTED instance's own values (inst.body).
    if (portView && !multiParamIface) {
        auto dit0 = ifaceDefaultInst.find(&def);
        if (dit0 == ifaceDefaultInst.end())
            dit0 = ifaceDefaultInst
                       .emplace(&def, &InstanceSymbol::createDefault(comp, def))
                       .first;
        ifaceDefaultScope = &dit0->second->body;
    }
    // Pre-create each port's typespec BEFORE the variable typespecs so their
    // arena ids precede the elab var typespecs — matching Surelog's
    // [port-ts, var-ts] weak-tail order. Reused by the port loop below.
    std::map<const Symbol*, UHDM::typespec*> portTsPre;
    for (auto portBase : body.getPortList()) {
        if (portBase->kind != SymbolKind::Port)
            continue;
        auto& ps0 = portBase->as<PortSymbol>();
        if (ps0.internalSymbol)
            portTsPre[portBase] = makeTypespec(*ps0.internalSymbol, nullptr, &ps0);
    }
    auto* vars = s.MakeVariablesVec();
    auto* elabNets = s.MakeNetVec();
    UHDM::VectorOfarray_net* elabArrayNets = nullptr;
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
            // Only an EXPLICITLY package-qualified struct interface signal
            // nets as a wire; imported/local typedefs stay untyped (Surelog).
            if (isPkgStructType(*it.sym) && isExplicitPkgQualified(*it.sym) &&
                !hasStructFieldMember(*it.sym))
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
        // An unpacked-array-of-STRUCT interface signal: elaborated array_net
        // (vpiSize = element count) with a FOLDED [lo:hi] range and a single
        // inner struct_net sharing the struct element typespec — Surelog. The
        // scalar-element case falls through to makeVar/logic_net below.
        if (it.sym->kind == SymbolKind::Variable &&
            it.sym->getDeclaredType() &&
            it.sym->getDeclaredType()->getType().getCanonicalType().kind ==
                SymbolKind::FixedSizeUnpackedArrayType) {
            const Type* canon =
                &it.sym->getDeclaredType()->getType().getCanonicalType();
            const Type* elemNamed = nullptr;
            int32_t total = 1;
            while (canon->kind == SymbolKind::FixedSizeUnpackedArrayType) {
                auto& ua0 = canon->as<FixedSizeUnpackedArrayType>();
                total *= (int32_t)ua0.range.width();
                elemNamed = &ua0.elementType;
                canon = &elemNamed->getCanonicalType();
            }
            if (!portView && elemNamed && canon->isStruct()) {
                UHDM::typespec* sts = nullptr;
                if (auto tt = pkgTopTypedefTs.find(elemNamed);
                    tt != pkgTopTypedefTs.end())
                    sts = tt->second;
                if (!sts)
                    if (auto tt2 = typedefTs.find(elemNamed);
                        tt2 != typedefTs.end())
                        sts = tt2->second;
                auto* an = s.MakeArray_net();
                an->VpiName(name);
                an->VpiFullName(fullName);
                an->VpiParent(iface);
                setLoc(an, nameSpan(it.sym->location, it.sym->name));
                an->VpiSize(total);
                if (auto* rngs = buildUnpackedRanges(*it.sym, an))
                    an->Ranges(rngs);
                auto* inr = s.MakeStruct_net();
                inr->VpiName(name);
                inr->VpiFullName(fullName + "." + name);
                inr->VpiParent(an);
                // Inner struct_net spans the declarator name through the dim.
                if (auto* dsyn0 = it.sym->getSyntax();
                    dsyn0 && dsyn0->kind == syntax::SyntaxKind::Declarator)
                    setLoc(inr, dsyn0->sourceRange());
                else
                    setLoc(inr, nameSpan(it.sym->location, it.sym->name));
                auto* irt = s.MakeRef_typespec();
                irt->VpiFullName(fullName + "." + name);
                irt->VpiParent(inr);
                if (sts)
                    irt->Actual_typespec(sts);
                inr->Typespec(irt);
                auto* inv = s.MakeNetVec();
                inv->push_back(inr);
                an->Nets(inv);
                if (!elabArrayNets)
                    elabArrayNets = s.MakeArray_netVec();
                elabArrayNets->push_back(an);
                netMap[it.sym] = an;
                continue;
            }
            // Scalar-element unpacked-array iface signal (logic d [0:1]): BOTH
            // the elab HOME view and reference-style PORT views list an
            // array_var (ranges + inner logic_var reg carrying the element
            // typespec) under vpiVariables — Surelog. (Struct-element port
            // views fall through to makeVar.)
            if (!(elemNamed && canon->isStruct())) {
                auto* elemTs = makeTypespec(*it.sym);
                if (auto* av =
                        emitArrayVar(*it.sym, name, fullName, iface, elemTs)) {
                    netMap[it.sym] = av;
                    vars->push_back(av);
                    continue;
                }
            }
        }
        auto* v = makeVar(*it.sym, /*portBacked=*/false);
        if (!v) {
            // A LOGIC/wire interface net (input logic clk/rst) that makeVar
            // does not model becomes a logic_net under the interface instance
            // (HOME view) — Surelog. (makeVar already handles var-typed
            // interface signals: input int x -> int_var.)
            if (it.sym->kind == SymbolKind::Net && !portView) {
                // A 2-STATE (bit) iface header port is a bit_var (Surelog).
                if (it.sym->getDeclaredType() &&
                    it.sym->getDeclaredType()->getType().isIntegral() &&
                    !it.sym->getDeclaredType()
                         ->getType()
                         .getCanonicalType()
                         .isFourState()) {
                    auto* bv = s.MakeBit_var();
                    bv->VpiName(name);
                    bv->VpiFullName(fullName);
                    bv->VpiParent(iface);
                    setLoc(bv, nameSpan(it.sym->location, it.sym->name));
                    bv->VpiVisibility(1);
                    auto* brt = s.MakeRef_typespec();
                    brt->VpiFullName(fullName);
                    brt->VpiParent(bv);
                    auto* bts9 = makeTypespec(*it.sym);
                    brt->Actual_typespec(bts9);
                    if (bts9 && bts9->VpiName().empty())
                        bts9->VpiParent(bv);
                    bv->Typespec(brt);
                    netMap[it.sym] = bv;
                    vars->push_back(bv);
                    continue;
                }
                auto* ln = s.MakeLogic_net();
                ln->VpiName(name);
                ln->VpiFullName(fullName);
                ln->VpiParent(iface);
                setLoc(ln, nameSpan(it.sym->location, it.sym->name));
                if (int32_t nt = netTypeFor(*it.sym))
                    ln->VpiNetType(nt);
                if (it.sym->getDeclaredType() &&
                    it.sym->getDeclaredType()->getType().isSigned())
                    ln->VpiSigned(true);
                if (auto* ts = makeTypespec(*it.sym)) {
                    auto* rt = s.MakeRef_typespec();
                    rt->VpiFullName(fullName);
                    rt->VpiParent(ln);
                    rt->Actual_typespec(ts);
                    if (ts->VpiName().empty())
                        ts->VpiParent(ln);
                    ln->Typespec(rt);
                }
                netMap[it.sym] = ln;
                elabNets->push_back(ln);
            }
            continue;
        }
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
    if (elabArrayNets)
        iface->Array_nets(elabArrayNets);

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

    // Fresh logic_nets created for interface-HEADER-port modport members
    // (clk/rst), keyed by member name so the header-port LowConn below can
    // share the same object as vpiActual (Surelog reuses one net).
    std::map<std::string, UHDM::logic_net*> ifacePortMemberNet;
    // Elab-view modports (fresh objects parented to this interface_inst). Each
    // modport's Interface_inst self-references this view. A reference-style port
    // view additionally carries a vpiExpr on each io_decl (pointing at this
    // view's variable); the declaration-style home view does not.
    {
        auto* mports = s.MakeModportVec();
        for (auto* mpPtr : sortedModports(body)) {
            auto& mp = *mpPtr;
            // A MODPORT-qualified port view (myif.man b) carries ONLY the
            // connected modport, not every modport the interface declares.
            if (!connModport.empty() && mp.name != connModport)
                continue;
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
                    // Iface HEADER-PORT-backed members always take the
                    // doubled fresh-net form (never the home net) — Surelog.
                    bool portBacked9 = false;
                    for (auto pb9 : body.getPortList())
                        if (pb9->kind == SymbolKind::Port &&
                            pb9->as<PortSymbol>().internalSymbol ==
                                mpp.internalSymbol) {
                            portBacked9 = true;
                            break;
                        }
                    if (auto nit = netMap.find(mpp.internalSymbol);
                        !portBacked9 && nit != netMap.end())
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
                        // Wire type only for EXPLICITLY package-qualified
                        // struct types (p::req_t); imported bare names and
                        // interface-local typedefs stay untyped (Surelog —
                        // same distinguisher as the module struct-net gates).
                        if (isPkgStructType(msym) &&
                            isExplicitPkgQualified(msym))
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
                    else if (mpp.internalSymbol) {
                        // An interface-PORT modport member (clk/rst declared in
                        // the iface header, not a local signal — so absent from
                        // netMap): a fresh scalar logic_net whose fullname is
                        // doubled through the modport and member
                        // (prefix.<modport>.<member>.<member> — the same
                        // Surelog quirk as the struct-member case above).
                        auto& msym = *mpp.internalSymbol;
                        std::string mname(msym.name);
                        std::string dfull = prefix + "." + std::string(mp.name) +
                                            "." + mname + "." + mname;
                        auto* ln = s.MakeLogic_net();
                        ln->VpiName(mname);
                        ln->VpiFullName(dfull);
                        ln->VpiParent(io);
                        ln->VpiNetType(vpiNet); // 36 — SL's quirk for these
                        setLoc(ln, nameSpan(msym.location, msym.name));
                        if (auto* mts = makeTypespec(msym)) {
                            auto* mrt = s.MakeRef_typespec();
                            mrt->VpiFullName(dfull);
                            mrt->VpiParent(ln);
                            mrt->Actual_typespec(mts);
                            ln->Typespec(mrt);
                        }
                        io->Expr(ln);
                        ifacePortMemberNet[mname] = ln;
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
    if (!portView)
        emitNamedClockingBlocks(body, iface, prefix, netMap,
                                /*defView=*/false);

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
            std::function<void(UHDM::any*)> rebind = [&](UHDM::any* e) {
                if (!e)
                    return;
                if (e->UhdmType() == UHDM::uhdmref_obj) {
                    auto* ro = (UHDM::ref_obj*)e;
                    if (auto* act = ro->Actual_group()) {
                        auto f = netToVar.find(act);
                        if (f != netToVar.end())
                            ro->Actual_group(f->second);
                    }
                } else if (e->UhdmType() == UHDM::uhdmoperation) {
                    // The RHS operation's operands are ref_objs into the same
                    // def nets; recurse so they rebind to the elab vars too
                    // (Surelog's folded def cont-assign binds every operand to
                    // the primary instance's per-instance logic_var).
                    auto* op = (UHDM::operation*)e;
                    if (op->Operands())
                        for (auto* opd : *op->Operands())
                            rebind(opd);
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
    // Only the HOME (declaration) view carries them; a reference-style port
    // view (work@dut.c.bus) lists no cont_assigns (Surelog).
    if (auto iit2 = ifaceDefMap.find(&def);
        !portView && iit2 != ifaceDefMap.end() && iit2->second->Cont_assigns()) {
        auto* elabCas = s.MakeCont_assignVec();
        for (auto* defCa : *iit2->second->Cont_assigns()) {
            // Surelog folds ONE cont_assign object (parented at the DEF
            // interface_inst, operands rebound to the PRIMARY instance's elab
            // vars) and shares it into every elab interface_inst view. Only a
            // pkg-enum-const RHS ref genuinely differs per view (it folds to a
            // LOC-LESS constant), needing a fresh object; everything else
            // references the def object directly.
            bool needsFold = false;
            if (auto* rhs0 = defCa->Rhs();
                rhs0 && rhs0->UhdmType() == UHDM::uhdmref_obj) {
                auto* ract0 = ((UHDM::ref_obj*)rhs0)->Actual_group();
                if (ract0 && ract0->UhdmType() == UHDM::uhdmenum_const)
                    needsFold = true;
            }
            // A plain CONSTANT RHS (assign x = 10) keeps the fresh per-view
            // re-emit with an elab-prefixed Lhs ref (Surelog re-lists it).
            else if (defCa->Rhs() &&
                     defCa->Rhs()->UhdmType() == UHDM::uhdmconstant)
                needsFold = true;
            if (!needsFold) {
                elabCas->push_back(defCa);
                continue;
            }
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
    // The folded process is parented at the DEF interface_inst and its block
    // names use the DEF prefix (work@<iface>), though ref actuals still resolve
    // to this elab instance's vars (via netMap). Surelog folds one process
    // object into both interface_inst views.
    auto iitP = ifaceDefMap.find(&def);
    UHDM::interface_inst* procParent =
        iitP != ifaceDefMap.end() ? iitP->second : iface;
    std::string procPrefix =
        iitP != ifaceDefMap.end() ? "work@" + std::string(def.name) : prefix;
    auto* procs = s.MakeProcess_stmtVec();
    for (auto& member : body.members()) {
        if (member.kind == SymbolKind::ProceduralBlock)
            if (auto* p = emitProcess(member.as<ProceduralBlockSymbol>(), procParent,
                                      procPrefix, netMap))
                procs->push_back(p);
    }
    if (!procs->empty()) {
        instSetProcess(iface, procs);
        if (iitP != ifaceDefMap.end())
            instSetProcess(iitP->second, procs);
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
        // PORT-VIEW LowConn refs anchor at the iface PORT DECL; the home
        // view anchors at the connection site (Surelog).
        if (portView)
            setLocNamed(lc, ps);
        else if (auto npc = findConnSyntax(inst, ps.name))
            setLoc(lc, SourceRange(npc->name.location(),
                                   npc->name.location() + ps.name.size()));
        else if (hasOrderedConns(inst) && conn && connectionExpr(*conn))
            setLoc(lc, connectionExpr(*conn)->sourceRange);
        else
            setLocNamed(lc, ps);
        if (auto it2 = netMap.find(internal); it2 != netMap.end())
            lc->Actual_group(it2->second);
        else if (auto it3 = ifacePortMemberNet.find(std::string(ps.name));
                 it3 != ifacePortMemberNet.end())
            lc->Actual_group(it3->second); // share the io_decl's logic_net
        p->Low_conn(lc);
        // A PORT VIEW's header ports carry only LowConn + typedef; the actual
        // connection HighConn belongs to the HOME view only (Surelog).
        if (conn && parentNets && !portView) {
            if (auto expr = connectionExpr(*conn)) {
                refCollector = parentRefs;
                forceConstParent = true;
                if (auto* h = emitExpr(*expr, p, parentPrefix, *parentNets))
                    p->High_conn(h);
                forceConstParent = false;
                refCollector = nullptr;
            }
        }
        auto ptp = portTsPre.find(portBase);
        auto* pts = ptp != portTsPre.end() ? ptp->second
                                           : makeTypespec(*internal, nullptr, &ps);
        auto* prt = s.MakeRef_typespec();
        prt->VpiFullName(prefix + "." + std::string(ps.name));
        prt->VpiParent(p);
        prt->Actual_typespec(pts);
        p->Typespec(prt);
        ports->push_back(p);
    }
    if (!ports->empty())
        iface->Ports(ports);
    // Elaborated generate scopes (gen_scope_array) — only the declaration-style
    // HOME view carries them; a reference-style port view does not.
    if (!portView)
        emitGenScopes(body, iface, prefix, netMap);
    return iface;
}

void UhdmExporter::emitDefGenStmts(const InstanceBodySymbol& body, UHDM::instance* m,
                                   const std::string& prefix) {
        auto* regions = s.MakeGen_stmtVec();
        std::set<const syntax::SyntaxNode*> doneIfs;
        std::set<const syntax::SyntaxNode*> doneCases;
        // A generate branch body: named begin for labeled blocks, anonymous
        // begin (module fullname) otherwise; cont_assigns from syntax.
        std::function<UHDM::any*(const syntax::SyntaxNode&, UHDM::BaseClass*,
                                 const Scope*, const std::string&, bool)>
            emitBranch;
        emitBranch = [&](const syntax::SyntaxNode& memSyn,
                         UHDM::BaseClass* parent, const Scope* astBlock,
                         const std::string& basePrefix,
                         bool noFull) -> UHDM::any* {
            UHDM::scope* b = nullptr;
            std::string branchPrefix = basePrefix;
            std::vector<const syntax::SyntaxNode*> items;
            if (memSyn.kind == syntax::SyntaxKind::GenerateBlock) {
                auto& gb = memSyn.as<syntax::GenerateBlockSyntax>();
                std::string label;
                if (gb.beginName)
                    label = std::string(gb.beginName->name.valueText());
                if (!label.empty()) {
                    auto* nb = s.MakeNamed_begin();
                    nb->VpiName(label);
                    branchPrefix = basePrefix + "." + label;
                    nb->VpiFullName(branchPrefix);
                    b = nb;
                }
                else {
                    auto* ub = s.MakeBegin();
                    // A case-item begin carries NO fullname (Surelog).
                    if (!noFull)
                        ub->VpiFullName(basePrefix);
                    b = ub;
                }
                for (auto mem2 : gb.members)
                    items.push_back(mem2);
            }
            else {
                auto* ub = s.MakeBegin();
                if (!noFull)
                    ub->VpiFullName(basePrefix);
                b = ub;
                items.push_back(&memSyn);
            }
            b->VpiParent(parent);
            auto* stmts = s.MakeAnyVec();
            // Gen-block localparams (def view): a param_assign stmt whose
            // parameter carries the typed ts (via the AST symbol) and whose
            // Rhs keeps the source literal encoding, unparented (Surelog).
            std::map<std::string, UHDM::parameter*> branchParams;
            for (auto* item : items) {
                if (item->kind != syntax::SyntaxKind::ParameterDeclarationStatement ||
                    !astBlock)
                    continue;
                auto& pds = item->as<syntax::ParameterDeclarationStatementSyntax>();
                if (pds.parameter->kind != syntax::SyntaxKind::ParameterDeclaration)
                    continue;
                auto& pd = pds.parameter->as<syntax::ParameterDeclarationSyntax>();
                bool isLocal2 = pd.keyword.valueText() == "localparam";
                bool typedP2 = pd.type->kind != syntax::SyntaxKind::ImplicitType;
                for (auto* dcl : pd.declarators) {
                    std::string pname(dcl->name.valueText());
                    const ParameterSymbol* psym = nullptr;
                    for (auto& mb : astBlock->members())
                        if (mb.kind == SymbolKind::Parameter && mb.name == pname)
                            psym = &mb.as<ParameterSymbol>();
                    if (!psym)
                        continue;
                    auto* pa2 = s.MakeParam_assign();
                    pa2->VpiParent(b);
                    setLoc(pa2, dcl->sourceRange());
                    auto* up2 = s.MakeParameter();
                    up2->VpiName(pname);
                    up2->VpiFullName(branchPrefix + "." + pname);
                    up2->VpiParent(pa2);
                    setLoc(up2, dcl->sourceRange());
                    if (isLocal2)
                        up2->VpiLocalParam(true);
                    // An UNTYPED gen localparam whose init references the
                    // loop GENVAR carries NO def-view typespec (its type is
                    // iteration-dependent) — Surelog.
                    bool genvarInit2 = false;
                    if (!typedP2 && dcl->initializer) {
                        std::string gvn2;
                        for (auto q2 = item->parent; q2; q2 = q2->parent)
                            if (q2->kind == syntax::SyntaxKind::LoopGenerate) {
                                auto& lg2 =
                                    q2->as<syntax::LoopGenerateSyntax>();
                                gvn2 = lg2.identifier.valueText();
                                break;
                            }
                        if (!gvn2.empty()) {
                            std::string raw2(
                                rawText(dcl->initializer->expr->sourceRange()));
                            for (size_t p2 = raw2.find(gvn2);
                                 p2 != std::string::npos;
                                 p2 = raw2.find(gvn2, p2 + 1)) {
                                bool lb2 = p2 == 0 ||
                                           (!isalnum((unsigned char)
                                                         raw2[p2 - 1]) &&
                                            raw2[p2 - 1] != '_');
                                size_t e2 = p2 + gvn2.size();
                                bool rb2 = e2 >= raw2.size() ||
                                           (!isalnum((unsigned char)
                                                         raw2[e2]) &&
                                            raw2[e2] != '_');
                                if (lb2 && rb2) {
                                    genvarInit2 = true;
                                    break;
                                }
                            }
                        }
                    }
                    // UNTYPED gen localparams resolve to an int_typespec at
                    // the FULL declaration span in the ELAB share (Surelog);
                    // typed ones keep their makeParamTs form.
                    UHDM::typespec* its2 = nullptr;
                    if (!typedP2) {
                        auto* it2g = s.MakeInt_typespec();
                        setLoc(it2g, pds.parameter->sourceRange());
                        its2 = it2g;
                    }
                    else
                        its2 = makeParamTs(*psym, typedP2);
                    if (its2) {
                        defGenLpTs[psym] = its2; // shared into the elab ref
                        if (!genvarInit2) {
                            auto* prt2 = s.MakeRef_typespec();
                            prt2->VpiFullName(branchPrefix + "." + pname);
                            prt2->VpiParent(up2);
                            prt2->Actual_typespec(its2);
                            up2->Typespec(prt2);
                        }
                    }
                    pa2->Lhs(up2);
                    if (dcl->initializer) {
                        syntaxRefPrefix = branchPrefix;
                        if (auto* rc2 =
                                emitSyntaxExpr(*dcl->initializer->expr, pa2)) {
                            ((UHDM::expr*)rc2)->VpiParent(nullptr);
                            pa2->Rhs((UHDM::expr*)rc2);
                        }
                        syntaxRefPrefix.clear();
                    }
                    branchParams[pname] = up2;
                    stmts->push_back(pa2);
                }
            }
            // Gen-block INTEGER variable decls (integer x, y;): Surelog
            // stmt-ifies each declarator as a Rhs-less blocking assignment
            // (opType 82) whose Lhs is the integer_var (typespec ref -> an
            // integer_typespec at the type-keyword span).
            for (auto* item : items) {
                if (item->kind != syntax::SyntaxKind::DataDeclaration ||
                    !astBlock)
                    continue;
                auto& dd = item->as<syntax::DataDeclarationSyntax>();
                for (auto* dcl : dd.declarators) {
                    std::string vname(dcl->name.valueText());
                    const VariableSymbol* vsym = nullptr;
                    for (auto& mb : astBlock->members())
                        if (mb.kind == SymbolKind::Variable && mb.name == vname)
                            vsym = &mb.as<VariableSymbol>();
                    if (!vsym)
                        continue;
                    auto& vct = vsym->getType().getCanonicalType();
                    bool isInt =
                        vct.kind == SymbolKind::PredefinedIntegerType &&
                        vct.as<PredefinedIntegerType>().integerKind ==
                            PredefinedIntegerType::Integer;
                    bool isScalar = vct.kind == SymbolKind::ScalarType;
                    // Ranged logic (logic [63:W] x) also stmt-ifies; the ts
                    // keeps its ranges symbolic (emitSyntaxExpr, branch scope).
                    bool isRangedLogic =
                        vct.kind == SymbolKind::PackedArrayType &&
                        vct.as<PackedArrayType>()
                                .elementType.getCanonicalType()
                                .kind == SymbolKind::ScalarType;
                    // Unpacked-ARRAY decls (logic [..] mem [0:N-1]) stmt-ify
                    // as a Rhs-less assignment whose Lhs is a bare array_var
                    // (ts -> array_typespec with SYMBOLIC dim bounds; inner
                    // reg logic_var carries the element logic_typespec).
                    if (vct.kind == SymbolKind::FixedSizeUnpackedArrayType) {
                        auto* as3 = s.MakeAssignment();
                        as3->VpiParent(b);
                        as3->VpiOpType(82);
                        as3->VpiBlocking(true);
                        setLoc(as3, dcl->sourceRange());
                        auto* av3 = s.MakeArray_var();
                        av3->VpiName(vname);
                        av3->VpiFullName(branchPrefix + "." + vname);
                        av3->VpiParent(as3);
                        setLoc(av3, nameSpan(dcl->name.location(), vname));
                        av3->VpiArrayType(1);
                        auto* ats3 = s.MakeArray_typespec();
                        setLoc(ats3, dcl->sourceRange());
                        auto* arv3 = s.MakeRangeVec();
                        for (auto* dim : dcl->dimensions) {
                            if (!dim->specifier ||
                                dim->specifier->kind !=
                                    syntax::SyntaxKind::RangeDimensionSpecifier)
                                continue;
                            auto& sel3 =
                                dim->specifier
                                    ->as<syntax::RangeDimensionSpecifierSyntax>()
                                    .selector;
                            if (sel3->kind !=
                                syntax::SyntaxKind::SimpleRangeSelect)
                                continue;
                            auto& rs4 = sel3->as<syntax::RangeSelectSyntax>();
                            auto* r4 = s.MakeRange();
                            r4->VpiParent(ats3);
                            setLoc(r4, dim->sourceRange());
                            // Bounds refs stay BARE (name only — Surelog).
                            if (auto* le = emitSyntaxExpr(*rs4.left, r4))
                                r4->Left_expr((UHDM::expr*)le);
                            if (auto* re = emitSyntaxExpr(*rs4.right, r4))
                                r4->Right_expr((UHDM::expr*)re);
                            arv3->push_back(r4);
                        }
                        if (!arv3->empty())
                            ats3->Ranges(arv3);
                        auto* rta3 = s.MakeRef_typespec();
                        rta3->VpiFullName(branchPrefix + "." + vname);
                        rta3->VpiParent(av3);
                        rta3->Actual_typespec(ats3);
                        av3->Typespec(rta3);
                        auto* lv3 = s.MakeLogic_var();
                        lv3->VpiFullName(branchPrefix + "." + vname);
                        lv3->VpiParent(av3);
                        setLoc(lv3, nameSpan(dcl->name.location(), vname));
                        auto* lts3 = s.MakeLogic_typespec();
                        setLoc(lts3, dd.type->sourceRange());
                        if (dd.type->kind == syntax::SyntaxKind::LogicType) {
                            auto& its4 = dd.type->as<syntax::IntegerTypeSyntax>();
                            auto* prv3 = s.MakeRangeVec();
                            for (auto* dim : its4.dimensions) {
                                if (!dim->specifier ||
                                    dim->specifier->kind !=
                                        syntax::SyntaxKind::
                                            RangeDimensionSpecifier)
                                    continue;
                                auto& sel4 =
                                    dim->specifier
                                        ->as<syntax::
                                                 RangeDimensionSpecifierSyntax>()
                                        .selector;
                                if (sel4->kind !=
                                    syntax::SyntaxKind::SimpleRangeSelect)
                                    continue;
                                auto& rs5 = sel4->as<syntax::RangeSelectSyntax>();
                                auto* r5 = s.MakeRange();
                                r5->VpiParent(lts3);
                                setLoc(r5, dim->sourceRange());
                                if (auto* le = emitSyntaxExpr(*rs5.left, r5))
                                    r5->Left_expr((UHDM::expr*)le);
                                if (auto* re = emitSyntaxExpr(*rs5.right, r5))
                                    r5->Right_expr((UHDM::expr*)re);
                                prv3->push_back(r5);
                            }
                            if (!prv3->empty())
                                lts3->Ranges(prv3);
                        }
                        // The array_typespec links the shared element ts via
                        // an unnamed Elem ref (Surelog).
                        auto* ert3 = s.MakeRef_typespec();
                        ert3->VpiParent(ats3);
                        ert3->Actual_typespec(lts3);
                        ats3->Elem_typespec(ert3);
                        auto* rtl3 = s.MakeRef_typespec();
                        rtl3->VpiFullName(branchPrefix + "." + vname);
                        rtl3->VpiParent(lv3);
                        rtl3->Actual_typespec(lts3);
                        lv3->Typespec(rtl3);
                        auto* regs3 = s.MakeVariablesVec();
                        regs3->push_back(lv3);
                        av3->Variables(regs3);
                        as3->Lhs(av3);
                        stmts->push_back(as3);
                        continue;
                    }
                    if (!isInt && !isScalar && !isRangedLogic)
                        continue;
                    auto* as2 = s.MakeAssignment();
                    as2->VpiParent(b);
                    as2->VpiOpType(82);
                    as2->VpiBlocking(true);
                    // An INITIALIZED decl (integer a = 1) spans decl..init
                    // and carries the init constant as Rhs (Surelog);
                    // bare decls keep the name-only span, no Rhs.
                    if (dcl->initializer) {
                        setLoc(as2, dcl->sourceRange());
                        if (auto* rI2 =
                                emitSyntaxExpr(*dcl->initializer->expr, as2))
                            as2->Rhs((UHDM::expr*)rI2);
                    }
                    else
                        setLoc(as2, nameSpan(dcl->name.location(), vname));
                    UHDM::variables* iv;
                    UHDM::typespec* it2;
                    if (isInt) {
                        auto* v0 = s.MakeInteger_var();
                        v0->VpiSigned(true);
                        auto* t0 = s.MakeInteger_typespec();
                        t0->VpiSigned(true);
                        iv = v0;
                        it2 = t0;
                    }
                    else {
                        iv = s.MakeLogic_var();
                        auto* lt2 = s.MakeLogic_typespec();
                        // Symbolic range bounds ([63:CounterWidth]) from the
                        // dim syntax, refs scoped at the branch.
                        if (isRangedLogic &&
                            (dd.type->kind == syntax::SyntaxKind::LogicType ||
                             dd.type->kind == syntax::SyntaxKind::RegType)) {
                            auto& its3 = dd.type->as<syntax::IntegerTypeSyntax>();
                            auto* rvec3 = s.MakeRangeVec();
                            for (auto* dim : its3.dimensions) {
                                if (!dim->specifier ||
                                    dim->specifier->kind !=
                                        syntax::SyntaxKind::
                                            RangeDimensionSpecifier)
                                    continue;
                                auto& sel =
                                    dim->specifier
                                        ->as<syntax::
                                                 RangeDimensionSpecifierSyntax>()
                                        .selector;
                                if (sel->kind !=
                                    syntax::SyntaxKind::SimpleRangeSelect)
                                    continue;
                                auto& rs3 =
                                    sel->as<syntax::RangeSelectSyntax>();
                                auto* r3 = s.MakeRange();
                                r3->VpiParent(lt2);
                                setLoc(r3, dim->sourceRange());
                                if (auto* le =
                                        emitSyntaxExpr(*rs3.left, r3))
                                    r3->Left_expr((UHDM::expr*)le);
                                if (auto* re =
                                        emitSyntaxExpr(*rs3.right, r3))
                                    r3->Right_expr((UHDM::expr*)re);
                                rvec3->push_back(r3);
                            }
                            if (!rvec3->empty())
                                lt2->Ranges(rvec3);
                        }
                        it2 = lt2;
                    }
                    iv->VpiName(vname);
                    iv->VpiFullName(branchPrefix + "." + vname);
                    iv->VpiParent(as2);
                    setLoc(iv, nameSpan(dcl->name.location(), vname));
                    setLoc(it2, dd.type->sourceRange());
                    auto* rt2 = s.MakeRef_typespec();
                    rt2->VpiFullName(branchPrefix + "." + vname);
                    rt2->VpiParent(iv);
                    rt2->Actual_typespec(it2);
                    iv->Typespec(rt2);
                    as2->Lhs(iv);
                    stmts->push_back(as2);
                }
            }
            // Gen-block module instances (def view): a ref_module stmt named by
            // the instance, DefName work@<def>, with a port per NAMED conn —
            // HighConn ref_obj scoped branchPrefix.<inst>.<formal>.<actual>
            // (Surelog's doubled form). No LowConn/direction/actual link.
            for (auto* item : items) {
                if (item->kind != syntax::SyntaxKind::HierarchyInstantiation)
                    continue;
                auto& hi = item->as<syntax::HierarchyInstantiationSyntax>();
                std::string defn(hi.type.valueText());
                for (auto* hinst : hi.instances) {
                    if (!hinst->decl)
                        continue;
                    std::string iname(hinst->decl->name.valueText());
                    auto* rm = s.MakeRef_module();
                    rm->VpiParent(b);
                    rm->VpiName(iname);
                    rm->VpiDefName("work@" + defn);
                    setLoc(rm, nameSpan(hinst->decl->name.location(), iname));
                    auto* rports = s.MakePortVec();
                    for (auto* conn : hinst->connections) {
                        if (conn->kind != syntax::SyntaxKind::NamedPortConnection)
                            continue;
                        auto& npc = conn->as<syntax::NamedPortConnectionSyntax>();
                        if (!npc.expr)
                            continue;
                        std::string formal(npc.name.valueText());
                        std::string act = rawText(npc.expr->sourceRange());
                        auto* p = s.MakePort();
                        p->VpiParent(rm);
                        p->VpiName(formal);
                        setLoc(p, conn->sourceRange());
                        // Parse ALL [..] groups of the actual.
                        std::vector<std::pair<size_t, std::string>> idxGroups;
                        {
                            size_t p0 = act.find('[');
                            while (p0 != std::string::npos) {
                                auto p1 = act.find(']', p0);
                                if (p1 == std::string::npos)
                                    break;
                                idxGroups.emplace_back(
                                    p0 + 1, act.substr(p0 + 1, p1 - p0 - 1));
                                p0 = act.find('[', p1);
                            }
                        }
                        auto lb2 = act.find('[');
                        if (idxGroups.size() >= 2 && !act.empty() &&
                            act.back() == ']') {
                            // MULTIDIM select (data_i[0][j]): a var_select
                            // named by the base, fullname DOUBLED through the
                            // formal (prefix.<inst>.<formal>.<base>), loc at
                            // the whole select; indices are constants (digits)
                            // or refs scoped vsFull.<idx>.
                            std::string base2 = act.substr(0, lb2);
                            std::string vsFull = branchPrefix + "." + iname +
                                                 "." + formal + "." + base2;
                            auto* vs = s.MakeVar_select();
                            vs->VpiParent(p);
                            vs->VpiName(base2);
                            vs->VpiFullName(vsFull);
                            setLoc(vs, npc.expr->sourceRange());
                            auto* ixv = s.MakeExprVec();
                            for (auto& [off9, tx9] : idxGroups) {
                                auto ixStart =
                                    npc.expr->sourceRange().start() + off9;
                                if (!tx9.empty() &&
                                    tx9.find_first_not_of("0123456789") ==
                                        std::string::npos) {
                                    auto* c9 = s.MakeConstant();
                                    c9->VpiDecompile(tx9);
                                    c9->VpiSize(64);
                                    c9->VpiValue("UINT:" + tx9);
                                    c9->VpiConstType(vpiUIntConst);
                                    c9->VpiParent(vs);
                                    setLoc(c9,
                                           SourceRange(ixStart,
                                                       ixStart + tx9.size()));
                                    ixv->push_back(c9);
                                }
                                else {
                                    auto* r9 = s.MakeRef_obj();
                                    r9->VpiName(tx9);
                                    r9->VpiFullName(vsFull + "." + tx9);
                                    r9->VpiParent(vs);
                                    setLoc(r9,
                                           SourceRange(ixStart,
                                                       ixStart + tx9.size()));
                                    ixv->push_back(r9);
                                }
                            }
                            vs->Exprs(ixv);
                            p->High_conn(vs);
                        }
                        else if (lb2 != std::string::npos && !act.empty() &&
                            act.back() == ']') {
                            // A SELECT actual (sig[i]): bit_select named by
                            // the BASE, fullname prefix.<inst>.<base> (no
                            // formal doubling), loc at the INDEX; index is a
                            // genvar ref (or a constant for digits).
                            std::string base2 = act.substr(0, lb2);
                            std::string idxT =
                                act.substr(lb2 + 1, act.size() - lb2 - 2);
                            auto idxStart =
                                npc.expr->sourceRange().start() + (lb2 + 1);
                            auto* bs = s.MakeBit_select();
                            bs->VpiParent(p);
                            bs->VpiName(base2);
                            bs->VpiFullName(branchPrefix + "." + iname + "." +
                                            base2);
                            setLoc(bs, SourceRange(idxStart,
                                                   idxStart + idxT.size()));
                            if (!idxT.empty() &&
                                idxT.find_first_not_of("0123456789") ==
                                    std::string::npos) {
                                auto* ic2 = s.MakeConstant();
                                ic2->VpiDecompile(idxT);
                                ic2->VpiSize(64);
                                ic2->VpiValue("UINT:" + idxT);
                                ic2->VpiConstType(vpiUIntConst);
                                ic2->VpiParent(bs);
                                setLoc(ic2, SourceRange(idxStart,
                                                        idxStart + idxT.size()));
                                bs->VpiIndex(ic2);
                            }
                            else {
                                auto* ir = s.MakeRef_obj();
                                ir->VpiName(idxT);
                                ir->VpiFullName(branchPrefix + "." + iname +
                                                "." + idxT);
                                ir->VpiParent(bs);
                                setLoc(ir, SourceRange(idxStart,
                                                       idxStart + idxT.size()));
                                bs->VpiIndex(ir);
                            }
                            p->High_conn(bs);
                        }
                        else if ([&] {
                                     const syntax::SyntaxNode* e9 = npc.expr;
                                     if (e9->kind == syntax::SyntaxKind::
                                                         SimplePropertyExpr)
                                         e9 = e9->as<syntax::
                                                         SimplePropertyExprSyntax>()
                                                  .expr;
                                     if (e9->kind == syntax::SyntaxKind::
                                                         SimpleSequenceExpr)
                                         e9 = e9->as<syntax::
                                                         SimpleSequenceExprSyntax>()
                                                  .expr;
                                     return e9->kind ==
                                                syntax::SyntaxKind::
                                                    InvocationExpression &&
                                            e9->as<syntax::
                                                       InvocationExpressionSyntax>()
                                                    .left->kind ==
                                                syntax::SyntaxKind::
                                                    IdentifierName;
                                 }()) {
                            // A CALL actual (f(sig)): func_call named by the
                            // function, args as formal-scoped refs (Surelog).
                            const syntax::SyntaxNode* ie9 = npc.expr;
                            if (ie9->kind ==
                                syntax::SyntaxKind::SimplePropertyExpr)
                                ie9 = ie9->as<syntax::SimplePropertyExprSyntax>()
                                          .expr;
                            if (ie9->kind ==
                                syntax::SyntaxKind::SimpleSequenceExpr)
                                ie9 = ie9->as<syntax::SimpleSequenceExprSyntax>()
                                          .expr;
                            auto& inv9 =
                                ie9->as<syntax::InvocationExpressionSyntax>();
                            auto* fc9 = s.MakeFunc_call();
                            fc9->VpiName(inv9.left
                                             ->as<syntax::IdentifierNameSyntax>()
                                             .identifier.valueText());
                            fc9->VpiParent(p);
                            setLoc(fc9, npc.expr->sourceRange());
                            if (inv9.arguments &&
                                !inv9.arguments->parameters.empty()) {
                                auto* args9 = s.MakeAnyVec();
                                for (auto a9 : inv9.arguments->parameters) {
                                    std::string ar9(
                                        rawText(a9->sourceRange()));
                                    auto* r9 = s.MakeRef_obj();
                                    r9->VpiName(ar9);
                                    r9->VpiFullName(branchPrefix + "." + iname +
                                                    "." + formal + "." + ar9);
                                    r9->VpiParent(fc9);
                                    setLoc(r9, a9->sourceRange());
                                    args9->push_back(r9);
                                }
                                fc9->Tf_call_args(args9);
                            }
                            p->High_conn(fc9);
                        }
                        else {
                            auto* r = s.MakeRef_obj();
                            r->VpiParent(p);
                            r->VpiName(act);
                            r->VpiFullName(branchPrefix + "." + iname + "." +
                                           formal + "." + act);
                            setLoc(r, npc.expr->sourceRange());
                            p->High_conn(r);
                        }
                        rports->push_back(p);
                    }
                    if (!rports->empty())
                        rm->Ports(rports);
                    stmts->push_back(rm);
                }
            }
            for (auto* item : items) {
                if (item->kind != syntax::SyntaxKind::ContinuousAssign)
                    continue;
                auto& cas2 = item->as<syntax::ContinuousAssignSyntax>();
                for (auto asyn : cas2.assignments) {
                    auto* ca = s.MakeCont_assign();
                    ca->VpiParent(b);
                    setLoc(ca, asyn->sourceRange());
                    syntaxRefPrefix = branchPrefix;
                    // Refs naming a branch localparam bind that parameter.
                    std::function<void(UHDM::any*)> bindP = [&](UHDM::any* e) {
                        if (!e)
                            return;
                        if (e->UhdmType() == UHDM::uhdmref_obj) {
                            auto* r0 = (UHDM::ref_obj*)e;
                            if (auto bp = branchParams.find(std::string(r0->VpiName()));
                                bp != branchParams.end() && !r0->Actual_group())
                                r0->Actual_group(bp->second);
                        }
                        else if (e->UhdmType() == UHDM::uhdmoperation) {
                            if (auto* ops = ((UHDM::operation*)e)->Operands())
                                for (auto* o : *ops)
                                    bindP(o);
                        }
                    };
                    (void)bindP; // SL leaves def-view gen CA refs unbound
                    if (asyn->kind == syntax::SyntaxKind::AssignmentExpression) {
                        auto& be = asyn->as<syntax::BinaryExpressionSyntax>();
                        // A def gen-CA bit_select spans its INDEX only.
                        auto selSpan = [&](UHDM::any* e,
                                           const syntax::ExpressionSyntax& sy) {
                            if (!e || e->UhdmType() != UHDM::uhdmbit_select)
                                return;
                            if (sy.kind == syntax::SyntaxKind::
                                               ElementSelectExpression) {
                                auto& es2 = sy.as<
                                    syntax::ElementSelectExpressionSyntax>();
                                if (es2.select && es2.select->selector)
                                    setLoc((UHDM::expr*)e,
                                           es2.select->selector->sourceRange());
                            }
                            else if (sy.kind ==
                                     syntax::SyntaxKind::IdentifierSelectName) {
                                auto& isn2 =
                                    sy.as<syntax::IdentifierSelectNameSyntax>();
                                if (!isn2.selectors.empty() &&
                                    isn2.selectors[0]->selector)
                                    setLoc((UHDM::expr*)e,
                                           isn2.selectors[0]
                                               ->selector->sourceRange());
                            }
                        };
                        if (auto* l = emitSyntaxExpr(*be.left, ca)) {
                            // LHS selects keep the whole span (Surelog).
                            if (be.left->kind ==
                                syntax::SyntaxKind::ElementSelectExpression)
                                selSpan(l, *be.left);
                            ca->Lhs((UHDM::expr*)l);
                        }
                        selBaseScopeIdx = true;
                        auto* r = emitSyntaxExpr(*be.right, ca);
                        selBaseScopeIdx = false;
                        if (r) {
                            selSpan(r, *be.right);
                            ca->Rhs((UHDM::expr*)r);
                        }
                    }
                    syntaxRefPrefix.clear();
                    stmts->push_back(ca);
                }
            }
            // NESTED if-generates recurse: a gen_if (keyword span) whose
            // stmt is the nested branch begin, fullnames chaining through
            // this branch's prefix.
            for (auto* item : items) {
                if (item->kind != syntax::SyntaxKind::IfGenerate)
                    continue;
                auto& nIf = item->as<syntax::IfGenerateSyntax>();
                doneIfs.insert(&nIf); // consumed here, not at top level
                UHDM::gen_if_else* ngie = nullptr;
                UHDM::gen_if* ngi = nullptr;
                UHDM::gen_stmt* ng0;
                if (nIf.elseClause) {
                    ngie = s.MakeGen_if_else();
                    // NESTED (else-if chain) gen_if_else carries the whole
                    // construct span, unlike the loc-less top-level one.
                    setLoc(ngie, nIf.sourceRange());
                    ng0 = ngie;
                }
                else {
                    ngi = s.MakeGen_if();
                    setLoc(ngi, nIf.keyword.range());
                    ng0 = ngi;
                }
                ng0->VpiParent(b);
                syntaxRefPrefix = branchPrefix;
                if (auto* c = emitSyntaxExpr(*nIf.condition, ng0)) {
                    if (ngie)
                        ngie->VpiCondition((UHDM::expr*)c);
                    else
                        ngi->VpiCondition((UHDM::expr*)c);
                }
                syntaxRefPrefix.clear();
                auto findNested = [&](const syntax::SyntaxNode* bs)
                    -> const Scope* {
                    if (!astBlock)
                        return nullptr;
                    for (auto& m2 : astBlock->members())
                        if (m2.kind == SymbolKind::GenerateBlock &&
                            m2.getSyntax() == bs)
                            return &m2.as<Scope>();
                    return nullptr;
                };
                if (auto* t = emitBranch(
                        *nIf.block, ng0,
                        findNested((const syntax::SyntaxNode*)nIf.block),
                        branchPrefix, false)) {
                    if (ngie)
                        ngie->VpiStmt((UHDM::any*)t);
                    else
                        ngi->VpiStmt(t);
                }
                if (nIf.elseClause && ngie) {
                    if (auto* e = emitBranch(
                            *nIf.elseClause->clause, ngie,
                            findNested((const syntax::SyntaxNode*)nIf
                                           .elseClause->clause),
                            branchPrefix, false))
                        ngie->VpiElseStmt((UHDM::any*)e);
                }
                stmts->push_back(ng0);
            }
            // Def-view gen-block PROCESSES: each always/initial re-emits
            // under the branch begin with branch-prefix-scoped UNBOUND refs.
            if (astBlock) {
                for (auto* item : items) {
                    if (item->kind != syntax::SyntaxKind::AlwaysBlock &&
                        item->kind != syntax::SyntaxKind::AlwaysCombBlock &&
                        item->kind != syntax::SyntaxKind::AlwaysFFBlock &&
                        item->kind != syntax::SyntaxKind::AlwaysLatchBlock &&
                        item->kind != syntax::SyntaxKind::InitialBlock)
                        continue;
                    const ProceduralBlockSymbol* pbs = nullptr;
                    for (auto& mb : astBlock->members())
                        if (mb.kind == SymbolKind::ProceduralBlock &&
                            mb.getSyntax() == item)
                            pbs = &mb.as<ProceduralBlockSymbol>();
                    if (!pbs)
                        continue;
                    NetMap unbound;
                    suppressRefActual = true;
                    defGenProcessEmit = true;
                    auto* p = emitProcess(
                        *pbs, m, branchPrefix.empty() ? prefix : branchPrefix,
                        unbound);
                    defGenProcessEmit = false;
                    suppressRefActual = false;
                    if (p) {
                        p->VpiParent(b);
                        stmts->push_back(p);
                    }
                }
            }
            // The def-view stmt list follows SOURCE order (decls, CAs and
            // processes interleave as written).
            std::stable_sort(stmts->begin(), stmts->end(),
                             [](const UHDM::any* a1, const UHDM::any* a2) {
                                 auto* e1 = (const UHDM::expr*)a1;
                                 auto* e2 = (const UHDM::expr*)a2;
                                 if (e1->VpiLineNo() != e2->VpiLineNo())
                                     return e1->VpiLineNo() < e2->VpiLineNo();
                                 return e1->VpiColumnNo() < e2->VpiColumnNo();
                             });
            if (b->UhdmType() == UHDM::uhdmnamed_begin)
                ((UHDM::named_begin*)b)->Stmts(stmts);
            else
                ((UHDM::begin*)b)->Stmts(stmts);
            return b;
        };
        // Surelog wraps a whole explicit `generate...endgenerate` region in ONE
        // gen_region placeholder; dedup the fallback by GenerateRegion syntax.
        std::set<const syntax::SyntaxNode*> doneFallbackRegions;
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
                    // Enum-VALUE refs in the condition bind their enum_const
                    // (Surelog).
                    std::function<void(UHDM::any*)> bindEC =
                        [&](UHDM::any* e) {
                            if (!e)
                                return;
                            if (e->UhdmType() == UHDM::uhdmref_obj) {
                                auto* r0 = (UHDM::ref_obj*)e;
                                if (r0->Actual_group())
                                    return;
                                for (auto& [sym0, tsp0] : typedefTs) {
                                    if (tsp0->UhdmType() !=
                                        UHDM::uhdmenum_typespec)
                                        continue;
                                    auto* ets0 = (UHDM::enum_typespec*)tsp0;
                                    if (ets0->Enum_consts())
                                        for (auto* ec0 : *ets0->Enum_consts())
                                            if (ec0->VpiName() ==
                                                r0->VpiName()) {
                                                r0->Actual_group(ec0);
                                                return;
                                            }
                                }
                            }
                            else if (e->UhdmType() == UHDM::uhdmoperation) {
                                if (auto* ops =
                                        ((UHDM::operation*)e)->Operands())
                                    for (auto* o : *ops)
                                        bindEC(o);
                            }
                        };
                    bindEC(c);
                    if (gie)
                        gie->VpiCondition((UHDM::expr*)c);
                    else
                        gi->VpiCondition((UHDM::expr*)c);
                }
                syntaxRefPrefix.clear();
                // The AST scope for EACH branch: the GenerateBlock member
                // whose syntax is that branch (the dedup means we emit both
                // branches from the FIRST member's visit, so search all).
                auto findBranchScope =
                    [&](const syntax::SyntaxNode* bs) -> const Scope* {
                    for (auto& m2 : body.members())
                        if (m2.kind == SymbolKind::GenerateBlock &&
                            m2.getSyntax() == bs)
                            return &m2.as<Scope>();
                    return nullptr;
                };
                const Scope* tbScope =
                    findBranchScope((const syntax::SyntaxNode*)ifSyn->block);
                if (auto* t = emitBranch(*ifSyn->block, g0, tbScope, prefix, false)) {
                    if (gie)
                        gie->VpiStmt(t);
                    else
                        gi->VpiStmt(t);
                }
                if (ifSyn->elseClause) {
                    const Scope* ebScope = findBranchScope(
                        (const syntax::SyntaxNode*)ifSyn->elseClause->clause);
                    if (auto* e = emitBranch(*ifSyn->elseClause->clause, gie,
                                             ebScope, prefix, false))
                        gie->VpiElseStmt((UHDM::any*)e);
                }
                // Inside an EXPLICIT generate...endgenerate region the if
                // wraps gen_region -> UNNAMED begin (module fullname) -> the
                // gen_if (Surelog drops nothing else).
                bool inRegion = false;
                for (auto q = (const syntax::SyntaxNode*)ifSyn; q;
                     q = q->parent)
                    if (q->kind == syntax::SyntaxKind::GenerateRegion) {
                        inRegion = true;
                        break;
                    }
                // Only region-wrapped gen_if_else carries a location (the
                // whole if..else span); bare ones stay loc-less.
                if (inRegion && gie)
                    setLoc(gie, ifSyn->sourceRange());
                if (inRegion) {
                    auto* gr0 = s.MakeGen_region();
                    gr0->VpiParent(m);
                    auto* wb = s.MakeBegin();
                    wb->VpiFullName(prefix);
                    wb->VpiParent(gr0);
                    auto* ws = s.MakeAnyVec();
                    g0->VpiParent(wb);
                    ws->push_back(g0);
                    wb->Stmts(ws);
                    gr0->VpiStmt(wb);
                    regions->push_back(gr0);
                }
                else
                    regions->push_back(g0);
                continue;
            }
            // CASE-generates (def view): Surelog emits the WHOLE gen_case tree
            // SYMBOLICALLY — the condition ref plus ALL case_items (taken AND
            // untaken), each item's begin re-emitting its processes/assigns
            // from syntax. Wrapped in a gen_region -> begin (module fullname),
            // matching the explicit `generate...endgenerate` region shape.
            const syntax::CaseGenerateSyntax* caseSyn = nullptr;
            if (member.kind == SymbolKind::GenerateBlock)
                for (auto q = member.getSyntax(); q; q = q->parent)
                    if (q->kind == syntax::SyntaxKind::CaseGenerate) {
                        caseSyn = &q->as<syntax::CaseGenerateSyntax>();
                        break;
                    }
            if (caseSyn) {
                if (!doneCases.insert(caseSyn).second)
                    continue;
                auto* gr = s.MakeGen_region();
                gr->VpiParent(m);
                auto* ob = s.MakeBegin();
                ob->VpiFullName(prefix);
                ob->VpiParent(gr);
                auto* gc = s.MakeGen_case();
                gc->VpiParent(ob);
                setLoc(gc, SourceRange(caseSyn->keyword.range().start(),
                                       caseSyn->endCase.range().end()));
                syntaxRefPrefix = prefix;
                if (auto* c = emitSyntaxExpr(*caseSyn->condition, gc))
                    gc->VpiCondition((UHDM::expr*)c);
                syntaxRefPrefix.clear();
                // The AST GenerateBlock scope for a given case-item clause (its
                // ProceduralBlock members exist even for UNINSTANTIATED items).
                auto findItemScope =
                    [&](const syntax::SyntaxNode* bs) -> const Scope* {
                    for (auto& m2 : body.members())
                        if (m2.kind == SymbolKind::GenerateBlock &&
                            m2.getSyntax() == bs)
                            return &m2.as<Scope>();
                    return nullptr;
                };
                auto* citems = s.MakeCase_itemVec();
                for (auto* ci : caseSyn->items) {
                    auto* item = s.MakeCase_item();
                    // Surelog leaves the case_item's parent UNSET; that stops
                    // ComputeFullName so the item's begin (and its always) get
                    // NO computed fullname (bare, symbolic def-view shape).
                    const syntax::SyntaxNode* clause = nullptr;
                    if (ci->kind == syntax::SyntaxKind::StandardCaseItem) {
                        auto& sci = ci->as<syntax::StandardCaseItemSyntax>();
                        clause = sci.clause;
                        auto* exprs = s.MakeAnyVec();
                        syntaxRefPrefix = prefix;
                        for (auto* le : sci.expressions) {
                            if (auto* e = emitSyntaxExpr(*le, item))
                                exprs->push_back(e);
                        }
                        syntaxRefPrefix.clear();
                        if (!exprs->empty())
                            item->VpiExprs(exprs);
                    }
                    else if (ci->kind == syntax::SyntaxKind::DefaultCaseItem) {
                        clause = ci->as<syntax::DefaultCaseItemSyntax>().clause;
                    }
                    if (clause) {
                        const Scope* isc = findItemScope(clause);
                        if (auto* bb = emitBranch(*clause, item, isc, prefix,
                                                  /*noFull=*/true))
                            item->Stmt(bb);
                    }
                    citems->push_back(item);
                }
                if (!citems->empty())
                    gc->Case_items(citems);
                auto* obs = s.MakeAnyVec();
                obs->push_back(gc);
                ob->Stmts(obs);
                gr->VpiStmt(ob);
                regions->push_back(gr);
                continue;
            }
            // FOR-generates: a LOC-LESS gen_for with the genvar init
            // assignment (int_var + 64-bit UINT), the condition (refs bound to
            // the int_var), the incr op, and the block body (Surelog def view).
            const syntax::LoopGenerateSyntax* loopSyn = nullptr;
            if (member.kind == SymbolKind::GenerateBlockArray)
                for (auto q = member.getSyntax(); q; q = q->parent)
                    if (q->kind == syntax::SyntaxKind::LoopGenerate) {
                        loopSyn = &q->as<syntax::LoopGenerateSyntax>();
                        break;
                    }
            // Only an INLINE-genvar loop (for (genvar c = ...)) becomes a
            // gen_for; a separate `genvar i;` + loop keeps the gen_region
            // placeholder (Surelog).
            if (loopSyn && !loopSyn->genvar)
                loopSyn = nullptr;
            if (loopSyn) {
                auto* gf = s.MakeGen_for();
                gf->VpiParent(m);
                std::string gname(loopSyn->identifier.valueText());
                std::string gfull = prefix + "." + gname;
                // Init: assignment spanning genvar..init, Lhs a SIGNED int_var
                // with an int_typespec at the name token, Rhs the init value.
                auto* asn = s.MakeAssignment();
                asn->VpiParent(gf);
                SourceLocation initStart = loopSyn->genvar
                                               ? loopSyn->genvar.range().start()
                                               : loopSyn->identifier.range().start();
                setLoc(asn, SourceRange(initStart,
                                        loopSyn->initialExpr->sourceRange().end()));
                auto* iv = s.MakeInt_var();
                iv->VpiName(gname);
                iv->VpiFullName(gfull);
                iv->VpiParent(asn);
                setLoc(iv, loopSyn->identifier.range());
                iv->VpiSigned(true);
                auto* ivrt = s.MakeRef_typespec();
                ivrt->VpiFullName(gfull);
                ivrt->VpiParent(iv);
                auto* ivts = s.MakeInt_typespec();
                setLoc(ivts, loopSyn->identifier.range());
                ivrt->Actual_typespec(ivts);
                iv->Typespec(ivrt);
                syntaxRefPrefix = prefix;
                if (auto* rc = emitSyntaxExpr(*loopSyn->initialExpr, asn)) {
                    ((UHDM::expr*)rc)->VpiParent(nullptr); // SL: unparented
                    asn->Rhs((UHDM::expr*)rc);
                }
                asn->Lhs((UHDM::expr*)iv);
                // Surelog: the init goes in the PLURAL vector, the incr in the
                // SINGULAR field (dump-identical either way; Compare differs).
                {
                    auto* iniv = s.MakeAnyVec();
                    iniv->push_back(asn);
                    gf->VpiForInitStmts(iniv);
                }
                // Condition: refs to the genvar bind the int_var.
                std::function<void(UHDM::any*)> bindGenvar = [&](UHDM::any* e) {
                    if (!e)
                        return;
                    if (e->UhdmType() == UHDM::uhdmref_obj) {
                        auto* r = (UHDM::ref_obj*)e;
                        if (r->VpiName() == gname) {
                            r->VpiFullName(gfull);
                            r->Actual_group(iv);
                        }
                    }
                    else if (e->UhdmType() == UHDM::uhdmoperation) {
                        if (auto* ops = ((UHDM::operation*)e)->Operands())
                            for (auto* o : *ops)
                                bindGenvar(o);
                    }
                };
                if (auto* c = emitSyntaxExpr(*loopSyn->stopExpr, gf)) {
                    bindGenvar(c);
                    gf->VpiCondition((UHDM::expr*)c);
                }
                syntaxRefPrefix.clear();
                // Incr (c++): op 62 at the operator span, LOC-LESS ref operand
                // parented at the gen_for (Surelog quirk).
                {
                    auto* op = s.MakeOperation();
                    op->VpiOpType(62);
                    op->VpiParent(gf);
                    // Anchored at the OPERAND token (Surelog quirk).
                    auto ir = loopSyn->iterationExpr->sourceRange();
                    setLoc(op, SourceRange(ir.start(), ir.start() + gname.size()));
                    auto* r = s.MakeRef_obj();
                    r->VpiName(gname);
                    r->VpiFullName(gfull);
                    r->VpiParent(gf);
                    r->Actual_group(iv);
                    auto* ops = s.MakeAnyVec();
                    ops->push_back(r);
                    op->Operands(ops);
                    gf->VpiForIncStmt(op);
                }
                // An INTERFACE def-view for-generate carries only an EMPTY
                // anonymous begin placeholder (fullname = interface); the
                // elaborated body lives solely in the ELAB gen_scope_array
                // (Surelog quirk — modules instead fill the def begin).
                if (m->UhdmType() == UHDM::uhdminterface_inst) {
                    auto* bb = s.MakeBegin();
                    bb->VpiFullName(prefix);
                    bb->VpiParent(gf);
                    gf->VpiStmt(bb);
                    regions->push_back(gf);
                    continue;
                }
                {
                    const Scope* astBlock = nullptr;
                    auto& arr2 = member.as<GenerateBlockArraySymbol>();
                    for (auto entry2 : arr2.entries)
                        if (entry2 && !entry2->isUninstantiated) {
                            astBlock = entry2;
                            break;
                        }
                    if (auto* b = emitBranch(*loopSyn->block, gf, astBlock, prefix, false))
                        gf->VpiStmt(b);
                }
                regions->push_back(gf);
                continue;
            }
            // An UNCONDITIONAL named generate block (generate begin : A ... end
            // — not if/for) becomes a gen_region wrapping a named_begin that
            // carries the label and the block contents (Surelog), not the empty
            // placeholder begin below.
            if (member.kind == SymbolKind::GenerateBlock) {
                if (auto* gsyn = member.getSyntax();
                    gsyn && gsyn->kind == syntax::SyntaxKind::GenerateBlock &&
                    gsyn->as<syntax::GenerateBlockSyntax>().beginName) {
                    auto* gr = s.MakeGen_region();
                    gr->VpiParent(m);
                    if (auto* b = emitBranch(*gsyn, gr, &member.as<Scope>(), prefix, false))
                        gr->VpiStmt(b);
                    regions->push_back(gr);
                    continue;
                }
            }
            // Fallback placeholder: only ONCE per explicit generate region.
            const syntax::SyntaxNode* genRegion = nullptr;
            for (auto q = member.getSyntax(); q; q = q->parent)
                if (q->kind == syntax::SyntaxKind::GenerateRegion) {
                    genRegion = q;
                    break;
                }
            if (genRegion && !doneFallbackRegions.insert(genRegion).second)
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
            instSetGenStmts(m, regions);
}

} // namespace slang_uhdm
