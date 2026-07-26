//------------------------------------------------------------------------------
//! @file UhdmExporter.cpp
//! @brief Exporter core: design assembly, locations, raw text
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"
#include "slang/syntax/SyntaxTree.h"

namespace slang_uhdm {

UhdmExporter::UhdmExporter(Compilation& compilation, UHDM::Serializer& serializer) :
    comp(compilation), s(serializer), sm(compilation.getSourceManager()) {
}

void UhdmExporter::noteUnsupported(const std::string& what) {
    unsupportedKinds.insert(what);
}

bool UhdmExporter::isBuiltinUnit(const Scope& unit) {
    if (!builtins)
        return false;
    for (auto& mem : unit.members())
        return fullFilePath(mem.location) == builtinFilePath;
    return false;
}

// Surelog's Builtin::addBuiltinTypes() synthesizes a package named `builtin`
// holding five empty class_defns; UhdmWriter then inserts it at the FRONT of
// both package lists (the elaborated copy carries vpiTop + the class_defns,
// the un-elaborated one just the names). Nothing has a source position.
void UhdmExporter::emitBuiltinPackage(UHDM::VectorOfpackage*& allP,
                                      UHDM::VectorOfpackage*& topP) {
    static constexpr std::string_view kClasses[] = {"any_sverilog_class", "array",
                                                    "queue", "string", "system"};
    // TopPackages copy first (Surelog builds the elaborated views first).
    auto* pTop = s.MakePackage();
    pTop->VpiName("builtin");
    pTop->VpiFullName("builtin::");
    pTop->VpiDefName("builtin");
    pTop->VpiParent(d);
    pTop->VpiTop(true);
    auto* cds = s.MakeClass_defnVec();
    for (auto cn : kClasses) {
        auto* cd = s.MakeClass_defn();
        cd->VpiName(cn);
        cd->VpiFullName("builtin::" + std::string(cn));
        cd->VpiParent(pTop);
        cds->push_back(cd);
    }
    pTop->Class_defns(cds);
    auto* pAll = s.MakePackage();
    pAll->VpiName("builtin");
    pAll->VpiFullName("builtin::");
    pAll->VpiDefName("builtin");
    pAll->VpiParent(d);
    if (!allP)
        allP = s.MakePackageVec();
    if (!topP)
        topP = s.MakePackageVec();
    allP->insert(allP->begin(), pAll);
    topP->insert(topP->begin(), pTop);
}

// True when one of the body's own parameters is declared with a type alias
// that is ALSO declared in that body (parameter alert_tx_t P = ...).
static bool paramTypedByLocalTypedef(const Scope& body) {
    for (auto& mem : body.members()) {
        if (mem.kind != SymbolKind::Parameter)
            continue;
        auto dt = mem.as<ParameterSymbol>().getDeclaredType();
        if (!dt)
            continue;
        auto& ty = dt->getType();
        if (ty.kind != SymbolKind::TypeAlias)
            continue;
        if (ty.as<TypeAliasType>().getParentScope() == &body)
            return true;
    }
    return false;
}

void UhdmExporter::setLoc(UHDM::BaseClass* obj, SourceRange range) {
    if (range.start() == SourceLocation::NoLocation)
        return;
    // Macro-expanded tokens: SINGLE-LINE bodies lay out VIRTUALLY at the
    // INVOCATION site (usage line, usage col + body offset); later lines of
    // multi-line bodies keep their macro-DEFINITION-site span (Surelog).
    auto lineColOf = [&](SourceLocation lc, uint32_t& L, uint32_t& C) {
        uint32_t vl, vc;
        // Single-line macro bodies lay out at the invocation site; add the
        // intra-body argument-substitution shift Surelog applies.
        if (sm->isMacroLoc(lc) && macroInvLineCol(lc, vl, vc)) {
            L = vl;
            C = (uint32_t)((int32_t)vc + macroArgShift(lc));
            return;
        }
        // Multi-line macro bodies keep their definition line; the column is the
        // definition column shifted right past earlier argument substitutions.
        if (sm->isMacroLoc(lc)) {
            SourceLocation d = sm->getFullyOriginalLoc(lc);
            L = (uint32_t)sm->getLineNumber(d);
            C = (uint32_t)((int32_t)sm->getColumnNumber(d) + macroArgShift(lc));
            return;
        }
        fileLineCol(lc, L, C);
    };
    uint32_t l = 0, c = 0;
    lineColOf(range.start(), l, c);
    obj->VpiLineNo(l);
    obj->VpiColumnNo(c);
    if (range.end() != SourceLocation::NoLocation) {
        lineColOf(range.end(), l, c);
        obj->VpiEndLineNo(l);
        obj->VpiEndColumnNo(c);
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
    setLoc(obj, nameSpan(loc, symbol.name));
}

SourceRange UhdmExporter::regNetSpan(const Symbol& sym) {
    // A reg variable emitted as a net, with an initializer, anchors over the
    // whole declarator ("b = 0") rather than just the name token.
    if (sym.kind == SymbolKind::Variable && sym.getDeclaredType() &&
        sym.getDeclaredType()->getInitializer()) {
        if (auto dsyn = sym.getSyntax()) {
            auto dr = dsyn->sourceRange();
            if (dr.start() != SourceLocation::NoLocation)
                return dr;
        }
    }
    return nameSpan(sym.location, sym.name);
}

SourceRange UhdmExporter::nameSpan(SourceLocation loc, std::string_view name) {
    // Escaped identifiers ("\foo* ") get Surelog's quirky name+6 width.
    if (rawText(SourceRange(loc, loc + 1)) == "\\")
        return SourceRange(loc, loc + name.size() + 6);
    return SourceRange(loc, loc + name.size());
}

SourceRange UhdmExporter::trimTypeSigning(const slang::syntax::SyntaxNode* tsyn,
                                          SourceRange r) {
    if (!tsyn || r.start() == SourceLocation::NoLocation)
        return r;
    // Only the integer ATOM types (signed by default) drop the keyword; a
    // logic/reg/bit vector keeps `signed` in its typespec span.
    switch (tsyn->kind) {
        case slang::syntax::SyntaxKind::ByteType:
        case slang::syntax::SyntaxKind::ShortIntType:
        case slang::syntax::SyntaxKind::IntType:
        case slang::syntax::SyntaxKind::LongIntType:
        case slang::syntax::SyntaxKind::IntegerType:
            break;
        default:
            return r;
    }
    auto* ity = tsyn->as_if<slang::syntax::IntegerTypeSyntax>();
    if (!ity || !ity->signing ||
        ity->signing.kind != slang::parsing::TokenKind::SignedKeyword)
        return r;
    auto ke = ity->keyword.range().end();
    if (ke == SourceLocation::NoLocation || !(ke < r.end()))
        return r;
    return SourceRange(r.start(), ke);
}

std::string UhdmExporter::fullFilePath(SourceLocation loc) {
    if (loc == SourceLocation::NoLocation)
        return "";
    // Macro-expansion buffers have no path; report the definition file.
    if (sm->isMacroLoc(loc))
        loc = sm->getFullyOriginalLoc(loc);
    return sm->getFullPath(loc.buffer()).string();
}

// A class definition (file-level or module-local): properties as ::-scoped
// automatic vars (typespecs deferred to the write phase), methods via
// emitTaskFuncs in class scope. File-level classes display their work@ name;
// module-local ones keep the bare name with a work@mod::name fullname.
UHDM::class_defn* UhdmExporter::emitClassDefn(const ClassType& cls,
                                              const std::string& dispName,
                                              const std::string& fullName,
                                              UHDM::BaseClass* parent) {
    auto* cd = s.MakeClass_defn();
    cd->VpiName(dispName);
    if (fullName != dispName)
        cd->VpiFullName(fullName);
    cd->VpiParent(parent);
    cd->VpiFile(fullFilePath(cls.location));
    if (auto syn = cls.getSyntax())
        setLoc(cd, syn->sourceRange());
    auto* vars = s.MakeVariablesVec();
    for (auto& pm : cls.members()) {
        if (pm.kind != SymbolKind::ClassProperty)
            continue;
        auto& cp = pm.as<ClassPropertySymbol>();
        auto& ct = cp.getType().getCanonicalType();
        if (!ct.isIntegral())
            continue;
        // A predefined integer field (int/byte/...) is the matching typed
        // var (int_var + vpiSigned), not a bare bit_var; anonymous bit/logic
        // vectors keep bit/logic_var.
        UHDM::variables* v = nullptr;
        if (ct.kind == SymbolKind::PredefinedIntegerType)
            v = makeVar(cp, /*portBacked=*/false);
        if (!v)
            v = ct.isFourState() ? (UHDM::variables*)s.MakeLogic_var()
                                 : (UHDM::variables*)s.MakeBit_var();
        v->VpiName(cp.name);
        v->VpiFullName(fullName + "::" + std::string(cp.name));
        v->VpiParent(cd);
        setLoc(v, nameSpan(cp.location, cp.name));
        v->VpiAutomatic(true);
        v->VpiVisibility(1);
        auto* rt = s.MakeRef_typespec();
        rt->VpiFullName(fullName + "::" + std::string(cp.name));
        rt->VpiParent(v);
        // The property ts is created in the write phase (arena order): the
        // ref is patched then.
        pendingClassPropTs.push_back({rt, &cp, v});
        v->Typespec(rt);
        vars->push_back(v);
    }
    if (!vars->empty())
        cd->Variables(vars);
    classDefnMap[&cls] = cd;
    if (builtins)
        emitClassTypedefs(cls, cd);
    currentClassDefn = cd;
    emitTaskFuncs(cls, cd, fullName + "::", nullptr, false);
    currentClassDefn = nullptr;
    return cd;
}

// Class-scope typedefs (class_defn vpiTypedef). Only the builtin
// `process::state` enum exercises this today, so it stays behind --builtins.
void UhdmExporter::emitClassTypedefs(const ClassType& cls, UHDM::class_defn* cd) {
    auto* tds = s.MakeTypespecVec();
    for (auto& member : cls.members()) {
        if (member.kind != SymbolKind::TypeAlias)
            continue;
        auto& ta = member.as<TypeAliasType>();
        auto& ct = ta.targetType.getType().getCanonicalType();
        if (ct.kind != SymbolKind::EnumType)
            continue;
        const syntax::SyntaxNode* typeSyn = nullptr;
        if (auto syn = ta.getSyntax())
            if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
                typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
        auto* ets = buildEnumTs(ct.as<EnumType>(), typeSyn, std::string(ta.name));
        ets->VpiName(ta.name);
        ets->VpiParent(cd);
        if (auto syn = ta.getSyntax())
            setLoc(ets, syn->sourceRange());
        // Registering it lets a method's return type share this object.
        typedefTs[&ta] = ets;
        tds->push_back(ets);
    }
    if (!tds->empty())
        cd->Typespecs(tds);
}

// Builds a canonical string of an instance's parameterization (value +
// type-parameter tuple) so distinct overrides can be counted per definition.
static std::string paramTuple(const InstanceSymbol& inst) {
    std::string key;
    for (auto& mem : inst.body.members()) {
        if (mem.kind == SymbolKind::Parameter) {
            auto& ps = mem.as<ParameterSymbol>();
            key += ps.name;
            key += '=';
            auto& v = ps.getValue();
            key += v.bad() ? std::string("?") : v.toString();
            key += ';';
        }
        else if (mem.kind == SymbolKind::TypeParameter) {
            auto& tp = mem.as<TypeParameterSymbol>();
            key += tp.name;
            key += '#';
            key += tp.targetType.getType().toString();
            key += ';';
        }
    }
    return key;
}

void UhdmExporter::computeParamMultiplicity() {
    std::map<const DefinitionSymbol*, std::set<std::string>> perDef;
    // TEXTUAL override multiplicity: distinct #(...) raw texts across
    // instances (Surelog uniquifies pre-elab, so #(1.0) vs #(1) differ even
    // when the folded values coincide — realexpr).
    std::map<const DefinitionSymbol*, std::set<std::string>> perDefText;
    std::function<void(const Symbol&)> visit = [&](const Symbol& member) {
        if (member.kind == SymbolKind::Instance) {
            auto& child = member.as<InstanceSymbol>();
            perDef[&child.getDefinition()].insert(paramTuple(child));
            defInstTotal[&child.getDefinition()]++;
            defAllInstCount[&child.getDefinition()]++;
            {
                std::string ptxt9;
                for (auto p9 = child.getSyntax(); p9; p9 = p9->parent)
                    if (p9->kind ==
                        syntax::SyntaxKind::HierarchyInstantiation) {
                        if (auto* pva9 =
                                p9->as<syntax::HierarchyInstantiationSyntax>()
                                    .parameters)
                            ptxt9 = std::string(
                                rawText(pva9->sourceRange()));
                        break;
                    }
                if (!ptxt9.empty())
                    overriddenTextDefs.insert(&child.getDefinition());
                perDefText[&child.getDefinition()].insert(ptxt9);
            }
            for (auto& gm : child.body.members())
                visit(gm);
        }
        else if (member.kind == SymbolKind::InstanceArray) {
            for (auto* e : member.as<InstanceArraySymbol>().elements)
                visit(*e);
        }
        else if (member.kind == SymbolKind::GenerateBlock) {
            if (!member.as<GenerateBlockSymbol>().isUninstantiated)
                for (auto& gm : member.as<Scope>().members())
                    visit(gm);
        }
        else if (member.kind == SymbolKind::GenerateBlockArray) {
            for (auto& gb : member.as<GenerateBlockArraySymbol>().entries)
                for (auto& gm : gb->members())
                    visit(gm);
        }
    };
    for (auto inst : comp.getRoot().topInstances) {
        defAllInstCount[&inst->getDefinition()]++;
        for (auto& m : inst->body.members())
            visit(m);
    }
    for (auto& [def, tuples] : perDef)
        if (tuples.size() > 1)
            multiParamDefs.insert(def);
    for (auto& [def, texts] : perDefText)
        if (texts.size() > 1)
            textMultiParamDefs.insert(def);
}

bool UhdmExporter::isMultiParamDef(const Scope& body) const {
    auto& sym = body.asSymbol();
    if (sym.kind != SymbolKind::InstanceBody)
        return false;
    return multiParamDefs.count(&sym.as<InstanceBodySymbol>().getDefinition()) > 0;
}

bool UhdmExporter::srcOrderLess(SourceLocation a, SourceLocation b) const {
    if (bufRank.empty()) {
        size_t seq = 0;
        for (auto unit : comp.getCompilationUnits())
            for (auto& mem : unit->members())
                if (mem.location)
                    bufRank.emplace(mem.location.buffer(), seq++);
    }
    auto rank = [&](SourceLocation l) -> size_t {
        auto it = bufRank.find(l.buffer());
        // Unranked buffers (no top-level member) keep bufferID order after
        // every ranked one.
        return it != bufRank.end() ? it->second
                                   : (size_t)l.buffer().getId() + (1u << 20);
    };
    size_t ra = rank(a), rb = rank(b);
    if (ra != rb)
        return ra < rb;
    if (a.buffer() != b.buffer())
        return a.buffer() < b.buffer();
    return a.offset() < b.offset();
}

UHDM::design* UhdmExporter::exportDesign() {
    auto& root = comp.getRoot();
    computeParamMultiplicity();

    d = s.MakeDesign();
    // `include occurrences -> design-level include_file_info entries
    // (Surelog): located at the FILENAME TOKEN in the including file, with
    // vpiIncludedFile = the included file's full path (mriscv_bind_sva
    // jg_bind_wrapper.sv `include "rv32_opcodes.v").
    {
        auto* infos = s.MakeInclude_file_infoVec();
        for (auto buf : sm->getAllBuffers()) {
            auto incFrom = sm->getIncludedFrom(buf);
            if (!incFrom)
                continue;
            auto* ifi = s.MakeInclude_file_info();
            ifi->VpiIncludedFile(sm->getFullPath(buf).string());
            ifi->VpiParent(d);
            // incFrom points into the include directive; anchor at the quoted
            // filename token (scan the source text from the directive).
            auto text = sm->getSourceText(incFrom.buffer());
            size_t off = incFrom.offset();
            SourceRange r(incFrom, incFrom);
            if (off < text.size()) {
                auto q0 = text.find_first_of("\"<", off);
                if (q0 != std::string_view::npos) {
                    char close = text[q0] == '<' ? '>' : '"';
                    auto q1 = text.find(close, q0 + 1);
                    if (q1 != std::string_view::npos)
                        r = SourceRange(
                            SourceLocation(incFrom.buffer(), q0),
                            SourceLocation(incFrom.buffer(), q1 + 1));
                }
            }
            // The entry's own file is the INCLUDING file (the directive site).
            ifi->VpiFile(fullFilePath(incFrom));
            setLoc(ifi, r);
            infos->push_back(ifi);
        }
        if (!infos->empty())
            d->Include_file_infos(infos);
    }
    // Multi-top designs: Surelog names the design after (and lists tops in)
    // SOURCE order; slang's topInstances may differ.
    std::vector<const InstanceSymbol*> orderedTops(root.topInstances.begin(),
                                                   root.topInstances.end());
    // Driver-added SYNTHETIC tops (bind carriers) are not design tops: pull
    // them out; they are re-added below as uninstantiated def views only.
    std::vector<const InstanceSymbol*> synthTops;
    if (!syntheticTops.empty()) {
        auto mid = std::stable_partition(
            orderedTops.begin(), orderedTops.end(),
            [this](const InstanceSymbol* t) {
                return syntheticTops.count(
                           std::string(t->getDefinition().name)) == 0;
            });
        synthTops.assign(mid, orderedTops.end());
        orderedTops.erase(mid, orderedTops.end());
    }
    std::stable_sort(orderedTops.begin(), orderedTops.end(),
                     [this](const InstanceSymbol* a, const InstanceSymbol* b) {
                         return srcOrderLess(a->getDefinition().location,
                                             b->getDefinition().location);
                     });
    if (!orderedTops.empty())
        d->VpiName("work@" + std::string(orderedTops[0]->getDefinition().name));
    else
        d->VpiName("unnamed"); // no top module: Surelog's unnamed design

    // All definitions used anywhere in the design, name-sorted like Surelog's
    // module map.
    std::map<std::string, const InstanceSymbol*> defs;
    for (auto inst : orderedTops) {
        auto name = std::string(inst->getDefinition().name);
        if (defs.emplace(name, inst).second)
            collectDefs(inst->body, defs);
    }
    // Parsed-but-unreferenced module definitions (an explicit --top prunes
    // them from the root) still get def views — Surelog compiles every parsed
    // module (load_and_derive testflags: ref_mod under -top dut). Only
    // safely-instantiable ones: modules with all params defaulted and no
    // interface ports.
    std::set<const DefinitionSymbol*> unrefDefs;
    for (auto* udefSym : comp.getUnreferencedDefinitions()) {
        auto& udef = *udefSym;
        if (udef.definitionKind != DefinitionKind::Module)
            continue;
        if (defs.count(std::string(udef.name)))
            continue;
        // Library-unit (-y/-v) modules compile on demand only — an unused
        // one gets NO def view (Surelog).
        if (!udef.sourceLibrary.isDefault ||
            (udef.syntaxTree && udef.syntaxTree->isLibraryUnit))
            continue;
        bool allDefaulted = true;
        for (auto& up : udef.parameters)
            if (!up.hasDefault()) {
                allDefaulted = false;
                break;
            }
        if (!allDefaulted)
            continue;
        auto& uinst = InstanceSymbol::createDefault(comp, udef);
        bool ifacePorted = false;
        for (auto pb : uinst.body.getPortList())
            if (pb->kind == SymbolKind::InterfacePort) {
                ifacePorted = true;
                break;
            }
        if (ifacePorted)
            continue;
        if (defs.emplace(std::string(udef.name), &uinst).second) {
            unrefDefs.insert(&udef);
            collectDefs(uinst.body, defs);
        }
    }
    // Synthetic (bind-carrier) tops: def views only, filled like an
    // unreferenced def in the write phase; never emitted as tops.
    for (auto* st : synthTops)
        if (defs.emplace(std::string(st->getDefinition().name), st).second) {
            unrefDefs.insert(&st->getDefinition());
            collectDefs(st->body, defs);
        }
    // Bound-child display paths (see bindDefDisplay).
    for (auto* ti : orderedTops)
        for (auto& member : ti->body.members()) {
            if (member.kind != SymbolKind::Instance)
                continue;
            auto& child = member.as<InstanceSymbol>();
            bool fromBind9 = false;
            for (auto p2 = child.getSyntax(); p2; p2 = p2->parent)
                if (p2->kind == syntax::SyntaxKind::BindDirective) {
                    fromBind9 = true;
                    break;
                }
            if (fromBind9)
                bindDefDisplay.emplace(
                    &child.getDefinition(),
                    "work@" + std::string(ti->getDefinition().name) + "." +
                        std::string(child.name));
        }
    // A design with NO top (recursive_map: every module is instantiated,
    // recursively) still carries every module definition in allModules —
    // Surelog compiles defs regardless of elaboration. Build uninstantiated
    // def views; their child instantiations become UninstantiatedDefSymbols
    // (ref_module stubs), so recursion cannot loop.
    if (orderedTops.empty()) {
        for (auto sym : comp.getDefinitions()) {
            if (sym->kind != SymbolKind::Definition)
                continue;
            auto& defSym = sym->as<DefinitionSymbol>();
            if (defSym.definitionKind != DefinitionKind::Module)
                continue;
            auto& inv = InstanceSymbol::createInvalid(comp, defSym);
            defs.emplace(std::string(defSym.name), &inv);
        }
    }
    // Surelog also lists UN-INSTANTIATED interface definitions in
    // AllInterfaces (iface_method_call intf2) — emit them from a default
    // parameterization. Modules stay instance-driven.
    for (auto defSym : comp.getDefinitions()) {
        if (defSym->kind != SymbolKind::Definition)
            continue;
        auto& d9 = defSym->as<DefinitionSymbol>();
        if (d9.definitionKind != DefinitionKind::Interface)
            continue;
        if (defs.count(std::string(d9.name)))
            continue;
        auto& di9 = InstanceSymbol::createDefault(comp, d9);
        defs.emplace(std::string(d9.name), &di9);
    }

    // User packages (skip built-ins).
    std::vector<const PackageSymbol*> pkgs;
    for (auto pkg : comp.getPackages()) {
        if (pkg->name != "std" && pkg->name != "$unit")
            pkgs.push_back(pkg);
    }
    // Surelog keeps source (compile) order; slang name-sorts.
    std::stable_sort(pkgs.begin(), pkgs.end(), [this](auto* a, auto* b) {
        return srcOrderLess(a->location, b->location);
    });
    // Which packages are wildcard-imported by a module body (their
    // nested-container struct typedefs take a special TOP form).
    for (auto& [name, inst] : defs)
        for (auto& mem : inst->body.members())
            if (mem.kind == SymbolKind::WildcardImport)
                if (auto* p0 = comp.getPackage(
                        mem.as<WildcardImportSymbol>().packageName))
                    wildcardImportedPkgs.insert(p0);
    for (auto pkg : pkgs)
        for (auto& mem : pkg->members()) {
            std::string_view pn9;
            if (mem.kind == SymbolKind::WildcardImport)
                pn9 = mem.as<WildcardImportSymbol>().packageName;
            else if (mem.kind == SymbolKind::ExplicitImport)
                pn9 = mem.as<ExplicitImportSymbol>().packageName;
            else
                continue;
            if (auto* tp9 = comp.getPackage(pn9))
                pkgImportedByPkg.insert(tp9);
        }
    if (!pkgs.empty()) {
        auto* allP = s.MakePackageVec();
        for (auto pkg : pkgs)
            allP->push_back(emitPackage(*pkg, false));
        d->AllPackages(allP);
        // Surelog builds both package views before any module.
        auto* topP = s.MakePackageVec();
        for (auto pkg : pkgs)
            topP->push_back(emitPackage(*pkg, true));
        d->TopPackages(topP);
        // Import-clone typespecs point vpiInstance at the ELABORATED (top)
        // home package, which only exists now that the top views are built.
        for (auto& [cts, pn] : importCopyTsFixups)
            for (auto* tp : *topP)
                if (tp->VpiName() == pn) {
                    cts->Instance(tp);
                    break;
                }
        // Cross-package def-init param refs re-point at the ELAB home-package
        // parameter (Surelog's def-view init ref reaches the folded elab param).
        for (auto& [ref, homeSym, pname] : pkgCrossRefTopFixups) {
            auto tit = pkgTopMap.find(homeSym);
            if (tit != pkgTopMap.end() && tit->second->Parameters())
                for (auto* pp : *tit->second->Parameters())
                    if (pp->VpiName() == pname) {
                        ref->Actual_group(pp);
                        break;
                    }
        }
        pkgCrossRefTopFixups.clear();
        // Materialized-import param typespecs created in the DEF package pass
        // reach the ELABORATED home package too (same rule as the import
        // clones above) — BitSelectOfParameterPassedToSubmodule.
        for (auto& [ts9, home9] : pkgImportTsTopFixups)
            if (auto tit9 = pkgTopMap.find(home9); tit9 != pkgTopMap.end())
                ts9->Instance(tit9->second);
        pkgImportTsTopFixups.clear();
        // Intra-package USES inside a pkg consumed by ANOTHER package bind
        // the importer's ELAB clone (Surelog registry, last-writer): repoint
        // def-listing struct/union member actuals from the HOME typedef
        // object to its import clone once the clones exist (rp32
        // csr_adr_t.perm -> csr_perm_t clone, isa_t.spec -> isa_spec_t
        // clone). Clone-less typedefs keep the home binding.
        for (auto pkg : pkgs) {
            if (!pkgImportedByPkg.count(pkg))
                continue;
            auto dIt = pkgDefMap.find((const void*)pkg);
            if (dIt == pkgDefMap.end() || !dIt->second->Typespecs())
                continue;
            for (auto* ts0 : *dIt->second->Typespecs()) {
                UHDM::VectorOftypespec_member* ms0 = nullptr;
                if (ts0->UhdmType() == UHDM::uhdmstruct_typespec)
                    ms0 = ((UHDM::struct_typespec*)ts0)->Members();
                else if (ts0->UhdmType() == UHDM::uhdmunion_typespec)
                    ms0 = ((UHDM::union_typespec*)ts0)->Members();
                if (!ms0)
                    continue;
                for (auto* tm0 : *ms0) {
                    if (!tm0->Typespec())
                        continue;
                    auto* act0 = tm0->Typespec()->Actual_typespec();
                    if (!act0)
                        continue;
                    for (auto& [aSym0, cl0] : pkgImportCloneTs) {
                        auto hIt0 = typedefTs.find(aSym0);
                        if (hIt0 != typedefTs.end() && hIt0->second == act0 &&
                            cl0 != act0) {
                            tm0->Typespec()->Actual_typespec(cl0);
                            break;
                        }
                    }
                }
            }
        }
    }
    // --builtins: the synthesized `builtin` package heads both lists.
    if (builtins) {
        auto* allP = d->AllPackages();
        auto* topP = d->TopPackages();
        emitBuiltinPackage(allP, topP);
        d->AllPackages(allP);
        d->TopPackages(topP);
    }

    // File-level ($unit) parameters -> DESIGN-level Parameters/Param_assigns
    // (name-only, typespecs materialized at the very end).
    {
        auto* uparams = s.MakeAnyVec();
        auto* upassigns = s.MakeParam_assignVec();
        for (auto unit : comp.getCompilationUnits()) {
            for (auto& mem : unit->members()) {
                if (mem.kind != SymbolKind::Parameter)
                    continue;
                auto& ps = mem.as<ParameterSymbol>();
                auto* up = s.MakeParameter();
                up->VpiName(ps.name);
                up->VpiParent(d);
                setLoc(up, SourceRange(ps.location, ps.location + ps.name.size()));
                auto& cv = ps.getValue();
                if (cv.isInteger() && !cv.integer().hasUnknown()) {
                    auto& iv = cv.integer();
                    bool neg = iv.isSigned() && iv.isNegative();
                    std::string digits = iv.toString(LiteralBase::Decimal, false);
                    up->VpiValue((neg ? "INT:" : "UINT:") + digits);
                }
                if (ps.getType().getCanonicalType().isSigned())
                    up->VpiSigned(true);
                auto* prt = s.MakeRef_typespec();
                prt->VpiFullName(ps.name);
                prt->VpiParent(up);
                up->Typespec(prt);
                auto* pa = s.MakeParam_assign();
                pa->VpiParent(d);
                if (auto syn = ps.getSyntax())
                    setLoc(pa, syn->sourceRange());
                pa->Lhs(up);
                UHDM::ref_typespec* rhsRt = nullptr;
                if (auto* init = ps.getInitializer()) {
                    auto& ic = stripImplicitConv(*init);
                    if (ic.kind == ExpressionKind::IntegerLiteral &&
                        cv.isInteger() && !cv.integer().hasUnknown()) {
                        auto* c = s.MakeConstant();
                        std::string digits =
                            cv.integer().toString(LiteralBase::Decimal, false);
                        c->VpiDecompile(digits);
                        c->VpiSize((int32_t)ps.getType().getBitWidth());
                        c->VpiValue("UINT:" + digits);
                        c->VpiConstType(vpiUIntConst);
                        c->VpiParent(pa);
                        setLoc(c, ic.sourceRange);
                        rhsRt = s.MakeRef_typespec();
                        rhsRt->VpiParent(c);
                        c->Typespec(rhsRt);
                        pa->Rhs(c);
                    }
                }
                unitParamMap[&mem] = up;
                pendingUnitParamTs.push_back({up, prt, rhsRt, &ps});
                uparams->push_back(up);
                upassigns->push_back(pa);
            }
        }
        if (!uparams->empty()) {
            d->Parameters(uparams);
            d->Param_assigns(upassigns);
        }
    }


    // True when some module signal (net/port/variable) has the given struct
    // type (so its file-level typedef is elaborated with a design parent).
    auto structUsedByModuleSignal = [&](const Type& structType) -> bool {
        const Type* target = &structType.getCanonicalType();
        // A $unit function returning the struct elaborates first (before any
        // module) and leaves its typedef unparented.
        for (auto unit : comp.getCompilationUnits())
            for (auto& member : unit->members())
                if (member.kind == SymbolKind::Subroutine &&
                    &member.as<SubroutineSymbol>().getReturnType().getCanonicalType() == target)
                    return false;
        bool directUse = false;
        for (auto& [name, inst] : defs) {
            for (auto& member : inst->body.members()) {
                const DeclaredType* dt = nullptr;
                if (member.kind == SymbolKind::Net || member.kind == SymbolKind::Variable ||
                    member.kind == SymbolKind::Port ||
                    member.kind == SymbolKind::Parameter)
                    dt = member.getDeclaredType();
                if (!dt)
                    continue;
                auto& mct = dt->getType().getCanonicalType();
                if (&mct == target)
                    directUse = true;
                // A signal whose type is a PACKED ARRAY of the struct reaches
                // it through the packed_array_typespec's Elem_typespec, which
                // still counts as a module-signal use.
                else if (mct.isPackedArray()) {
                    const Type* el = &mct;
                    while (el->getCanonicalType().kind == SymbolKind::PackedArrayType)
                        el = &el->getCanonicalType().as<PackedArrayType>().elementType;
                    if (&el->getCanonicalType() == target)
                        directUse = true;
                }
            }
        }
        return directUse;
    };

    // Surelog's UhdmWriter::writeCont_assign ends by CLEARING the vpiParent of
    // the typespec it resolved for the assign's LHS (UhdmWriter.cpp:2295) —
    // so a file-level struct typedef that types ANY continuous-assign target
    // signal ends up unparented at the design, whatever the typedef pass set
    // (DotMultirange status_t, gen_struct_access td2). Only a WHOLE-signal
    // LHS resolves the signal's typespec; member/index selects do not.
    auto structTypesContAssignLhs = [&](const Type& structType) -> bool {
        const Type* target = &structType.getCanonicalType();
        bool found = false;
        std::function<void(const Scope&)> scan = [&](const Scope& sc) {
            for (auto& mem : sc.members()) {
                if (found)
                    return;
                if (mem.kind == SymbolKind::ContinuousAssign) {
                    auto& asn =
                        mem.as<ContinuousAssignSymbol>().getAssignment();
                    if (asn.kind != ExpressionKind::Assignment)
                        continue;
                    auto& lc = stripImplicitConv(
                        asn.as<AssignmentExpression>().left());
                    if (lc.kind != ExpressionKind::NamedValue)
                        continue;
                    if (auto dt2 =
                            lc.as<NamedValueExpression>().symbol.getDeclaredType();
                        dt2 && &dt2->getType().getCanonicalType() == target)
                        found = true;
                }
                else if (mem.kind == SymbolKind::GenerateBlock)
                    scan(mem.as<GenerateBlockSymbol>());
                else if (mem.kind == SymbolKind::GenerateBlockArray)
                    for (auto* ge : mem.as<GenerateBlockArraySymbol>().entries)
                        scan(*ge);
            }
        };
        for (auto& [name, inst] : defs)
            scan(inst->body);
        return found;
    };

    // File-level (compilation-unit) typedefs: the typespec OBJECTS are built
    // in SOURCE order (so their member typespecs land in source order in the
    // arena), but the design Typespecs LIST is name-sorted like Surelog's.
    {
        std::vector<const Symbol*> srcAliases;
        for (auto unit : comp.getCompilationUnits())
            for (auto& member : unit->members())
                if (member.kind == SymbolKind::TypeAlias)
                    srcAliases.push_back(&member);
        std::stable_sort(srcAliases.begin(), srcAliases.end(),
                         [this](auto* a, auto* b) {
                             return srcOrderLess(a->location, b->location);
                         });
        std::map<std::string, UHDM::typespec*> byName;
        {
            for (auto* memberPtr : srcAliases) {
                auto& member = *memberPtr;
                auto& ta = member.as<TypeAliasType>();
                auto& ct = ta.targetType.getType().getCanonicalType();
                const syntax::SyntaxNode* typeSyn = nullptr;
                if (auto syn = ta.getSyntax()) {
                    if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
                        typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
                }
                UHDM::typespec* ts = nullptr;
                if (ct.kind == SymbolKind::EnumType) {
                    ts = buildEnumTs(ct.as<EnumType>(), typeSyn, std::string(ta.name));
                    ts->VpiParent(d);
                    if (auto syn = ta.getSyntax())
                        setLoc(ts, syn->sourceRange());
                }
                else if (ct.kind == SymbolKind::PackedStructType) {
                    ts = buildStructTs(ct.as<PackedStructType>(), true,
                                       std::string(ta.name));
                    // A file-level packed struct used by a MODULE signal
                    // (net/port/var) parents at the design; one used only in
                    // function returns etc. stays unparented. One used by a
                    // $UNIT function FORMAL parents at the design and anchors
                    // at that first formal's type token.
                    const syntax::SyntaxNode* formalSyn = nullptr;
                    for (auto unit2 : comp.getCompilationUnits()) {
                        for (auto& m2 : unit2->members()) {
                            if (m2.kind != SymbolKind::Subroutine)
                                continue;
                            for (auto arg2 :
                                 m2.as<SubroutineSymbol>().getArguments()) {
                                if (&arg2->getType().getCanonicalType() != &ct)
                                    continue;
                                if (auto dt2 = arg2->getDeclaredType())
                                    if (auto tsy2 = dt2->getTypeSyntax())
                                        formalSyn = tsy2;
                                break;
                            }
                            if (formalSyn)
                                break;
                        }
                        if (formalSyn)
                            break;
                    }
                    if (structUsedByModuleSignal(ct) &&
                        !structTypesContAssignLhs(ct))
                        ts->VpiParent(d);
                    else if (formalSyn)
                        ts->VpiParent(d);
                    if (formalSyn && !structUsedByModuleSignal(ct))
                        setLoc(ts, formalSyn->sourceRange());
                    else if (typeSyn)
                        setLoc(ts, typeSyn->sourceRange());
                }
                else if (ct.kind == SymbolKind::UnpackedStructType) {
                    ts = buildStructTs(ct.as<UnpackedStructType>(), false,
                                       std::string(ta.name));
                    ts->VpiParent(d);
                    if (typeSyn)
                        setLoc(ts, typeSyn->sourceRange());
                }
                else if (ct.kind == SymbolKind::PackedUnionType) {
                    ts = buildUnionTs(ct.as<PackedUnionType>(), true,
                                      std::string(ta.name));
                    if (structUsedByModuleSignal(ct))
                        ts->VpiParent(d);
                    if (typeSyn)
                        setLoc(ts, typeSyn->sourceRange());
                }
                else if (ct.kind == SymbolKind::PackedArrayType ||
                         ct.kind == SymbolKind::ScalarType) {
                    // Vector/scalar typedef: a NAMED logic_typespec with its
                    // ranges at the target type syntax (like module-scope
                    // vector typedefs).
                    bypassTypedefShare = true;
                    bool savedTf = tfContext;
                    tfContext = true;
                    typedefTsContext = true;
                    ts = makeTypespec(ta, typeSyn);
                    typedefTsContext = false;
                    tfContext = savedTf;
                    bypassTypedefShare = false;
                    ts->VpiParent(d);
                    if (typeSyn)
                        setLoc(ts, typeSyn->sourceRange());
                    // A typedef aliasing a NAMED vector typedef with ADDED
                    // packed dims (typedef reg8_t [0:3] t2): Surelog's
                    // multi-clone graph — the design ts spans the first USE,
                    // Elem-refs an unnamed clone chain over the target span,
                    // and SHARES a packed_array ts's range.
                    auto& tgtT = ta.targetType.getType();
                    if (ct.kind == SymbolKind::PackedArrayType && typeSyn &&
                        tgtT.kind == SymbolKind::PackedArrayType &&
                        tgtT.as<PackedArrayType>().elementType.kind ==
                            SymbolKind::TypeAlias &&
                        typedefTs.count(
                            &tgtT.as<PackedArrayType>().elementType)) {
                        auto& elT = tgtT.as<PackedArrayType>().elementType;
                        auto* baseTs = typedefTs[&elT];
                        // Dedicated ELEM clones (named reg8_t, ranges) — one
                        // per array-clone level. Surelog mints a FRESH element
                        // clone for BOTH the outer clone (clA.elem) and the
                        // inner alias clone (clB.elem), and gives the outer
                        // one a Typedef_alias to a BARE sibling clone (R1),
                        // while the inner one aliases the shared design ts.
                        auto& eta = elT.as<TypeAliasType>();
                        const syntax::SyntaxNode* etSyn = nullptr;
                        if (auto easyn = eta.getSyntax())
                            if (easyn->kind ==
                                syntax::SyntaxKind::TypedefDeclaration)
                                etSyn = easyn
                                            ->as<syntax::
                                                     TypedefDeclarationSyntax>()
                                            .type;
                        // Mint a fresh named element clone; if aliasTgt is set,
                        // give it a Typedef_alias ref to it (parented at the
                        // clone). Returns null on a non-logic result.
                        auto mintElem =
                            [&](UHDM::typespec* aliasTgt) -> UHDM::typespec* {
                            bypassTypedefShare = true;
                            auto* c = makeTypespec(eta, etSyn);
                            bypassTypedefShare = false;
                            if (!c)
                                return nullptr;
                            c->VpiName(eta.name);
                            if (etSyn)
                                setLoc(c, etSyn->sourceRange());
                            if (aliasTgt &&
                                c->UhdmType() == UHDM::uhdmlogic_typespec) {
                                auto* ar = s.MakeRef_typespec();
                                ar->VpiFullName(eta.name);
                                ar->VpiParent(c);
                                ar->Actual_typespec(aliasTgt);
                                ((UHDM::logic_typespec*)c)->Typedef_alias(ar);
                            }
                            return c;
                        };
                        auto tspan = typeSyn->sourceRange();
                        std::string raw = rawText(tspan);
                        auto lb = raw.find('[');
                        auto cl = raw.find(':');
                        auto rb = raw.find(']');
                        auto mkDimRange =
                            [&](UHDM::BaseClass* pts) -> UHDM::range* {
                            if (lb == std::string::npos ||
                                cl == std::string::npos ||
                                rb == std::string::npos)
                                return nullptr;
                            auto* r = s.MakeRange();
                            r->VpiParent(pts);
                            setLoc(r, SourceRange(tspan.start() + lb,
                                                  tspan.start() + rb + 1));
                            auto mkC = [&](size_t from, size_t to) {
                                std::string dg = raw.substr(from, to - from);
                                while (!dg.empty() && dg.front() == ' ') {
                                    dg.erase(dg.begin());
                                    from++;
                                }
                                while (!dg.empty() && dg.back() == ' ') {
                                    dg.pop_back();
                                    to--;
                                }
                                auto* c = s.MakeConstant();
                                c->VpiDecompile(dg);
                                c->VpiSize(64);
                                c->VpiValue("UINT:" + dg);
                                c->VpiConstType(vpiUIntConst);
                                c->VpiParent(r);
                                setLoc(c, SourceRange(tspan.start() + from,
                                                      tspan.start() + to));
                                return c;
                            };
                            r->Left_expr(mkC(lb + 1, cl));
                            r->Right_expr(mkC(cl + 1, rb));
                            return r;
                        };
                        auto* pat2 = s.MakePacked_array_typespec();
                        setLoc(pat2, tspan);
                        auto* shr = mkDimRange(pat2);
                        if (shr) {
                            auto* v0 = s.MakeRangeVec();
                            v0->push_back(shr);
                            pat2->Ranges(v0);
                        }
                        auto* clA = s.MakeLogic_typespec();
                        setLoc(clA, tspan);
                        auto* clB = s.MakeLogic_typespec();
                        setLoc(clB, tspan);
                        // Mint the three reg8_t element clones in Surelog's
                        // creation order: elemCl_B (clB.elem, alias -> shared
                        // base), then elemCl (clA.elem), then its BARE alias
                        // sibling R1.
                        UHDM::typespec* elemClB = mintElem(baseTs);
                        UHDM::typespec* elemCl = mintElem(nullptr);
                        if (elemCl &&
                            elemCl->UhdmType() == UHDM::uhdmlogic_typespec) {
                            auto* r1 = mintElem(nullptr);
                            auto* eal = s.MakeRef_typespec();
                            eal->VpiFullName(eta.name);
                            eal->VpiParent(elemCl);
                            eal->Actual_typespec(r1 ? r1 : baseTs);
                            if (r1)
                                r1->VpiParent(eal);
                            ((UHDM::logic_typespec*)elemCl)->Typedef_alias(eal);
                        }
                        auto* tar = s.MakeRef_typespec();
                        tar->VpiParent(clA);
                        tar->Actual_typespec(clB);
                        clA->Typedef_alias(tar);
                        auto* ear = s.MakeRef_typespec();
                        ear->VpiParent(clA);
                        ear->Actual_typespec(elemCl ? elemCl : baseTs);
                        if (elemCl)
                            elemCl->VpiParent(ear);
                        clA->Elem_typespec(ear);
                        if (auto* rA = mkDimRange(clA)) {
                            auto* vA = s.MakeRangeVec();
                            vA->push_back(rA);
                            clA->Ranges(vA);
                        }
                        auto* ebr = s.MakeRef_typespec();
                        ebr->VpiParent(clB);
                        ebr->Actual_typespec(elemClB ? elemClB : baseTs);
                        clB->Elem_typespec(ebr);
                        if (auto* rB = mkDimRange(clB)) {
                            auto* vB = s.MakeRangeVec();
                            vB->push_back(rB);
                            clB->Ranges(vB);
                        }
                        auto* der = s.MakeRef_typespec();
                        der->VpiFullName(ta.name);
                        der->VpiParent(ts);
                        der->Actual_typespec(clA);
                        ((UHDM::logic_typespec*)ts)->Elem_typespec(der);
                        if (shr) {
                            auto* vT = s.MakeRangeVec();
                            vT->push_back(shr); // SHARED — parent stays pat2
                            ((UHDM::logic_typespec*)ts)->Ranges(vT);
                        }
                        // Span the design ts at the FIRST module-signal USE.
                        bool spanned = false;
                        for (auto& [nm2, inst2] : defs) {
                            for (auto& member : inst2->body.members()) {
                                const DeclaredType* dtu = nullptr;
                                if (member.kind == SymbolKind::Net ||
                                    member.kind == SymbolKind::Variable ||
                                    member.kind == SymbolKind::Port)
                                    dtu = member.getDeclaredType();
                                if (!dtu || &dtu->getType() != (const Type*)&ta)
                                    continue;
                                if (auto tsy = dtu->getTypeSyntax()) {
                                    setLoc(ts, tsy->sourceRange());
                                    spanned = true;
                                }
                                break;
                            }
                            if (spanned)
                                break;
                        }
                    }
                }
                else {
                    noteUnsupported("typedef target: " + std::string(toString(ct.kind)));
                    continue;
                }
                ts->VpiName(ta.name);
                ts->Instance((UHDM::instance*)(UHDM::BaseClass*)d);
                // MULTI-TOP designs parent $unit typedefs at the DESIGN
                // (arrays03); single-top ones leave them for net re-parenting
                // (DotMultirange).
                if (comp.getRoot().topInstances.size() > 1)
                    ts->VpiParent((UHDM::BaseClass*)d);
                typedefTs[&ta] = ts;
                byName[std::string(ta.name)] = ts;
            }
        }
        if (!byName.empty()) {
            auto* tds = s.MakeTypespecVec();
            for (auto& [nm, ts] : byName)
                tds->push_back(ts);
            d->Typespecs(tds);
        }
    }

    // $unit (compilation-unit) functions live on the design object.
    for (auto unit : comp.getCompilationUnits())
        emitTaskFuncs(*unit, d, "", nullptr);

    auto* allMods = s.MakeModule_instVec();
    auto* topMods = s.MakeModule_instVec();

    // Pre-create the definition shells so ref_modules can point at them
    // regardless of emission order. Interface defs get interface_inst shells
    // in AllInterfaces; everything else module_inst shells in AllModules.
    auto* allIfaces = s.MakeInterface_instVec();
    for (auto& [name, inst] : defs) {
        if (useInterfacePath(*inst)) {
            auto* iface = s.MakeInterface_inst();
            ifaceDefMap[&inst->getDefinition()] = iface;
            allIfaces->push_back(iface);
        }
        else {
            defMap[&inst->getDefinition()].mod = s.MakeModule_inst();
            allMods->push_back(defMap[&inst->getDefinition()].mod);
        }
    }
    d->AllModules(allMods);
    if (!allIfaces->empty())
        d->AllInterfaces(allIfaces);


    // Surelog compiles every module's parameters at module-compile time, so
    // all def-view parameter typespecs precede any elaboration typespecs.
    for (auto& [name, inst] : defs) {
        if (useInterfacePath(*inst))
            continue; // simple-interface params handled in emitInterfaceDef
        DefInfo& info = defMap[&inst->getDefinition()];
        // A param TYPED BY one of the module's own typedefs forces that
        // typedef's compile first (Surelog compiles the typedef declaration
        // before the parameter that names it), so the typedef's member
        // typespecs precede the param initializer's own objects.
        if (!info.typedefsDone && paramTypedByLocalTypedef(inst->body)) {
            info.typedefsDone = true;
            const Scope* savedCS = currentScope;
            currentScope = &inst->body;
            emitTypedefs(inst->body, info.mod, "work@" + name, info);
            currentScope = savedCS;
        }
        emitParameters(inst->body, info.mod, "work@" + name, info.nets, /*topView=*/false,
                       &info, false);
    }
    // Every def's CONTENT (typedefs, nets, task_funcs, cont_assigns,
    // processes, generate placeholders) compiles before any instance; only
    // the port/net-ts phase is encounter-ordered.
    for (auto& [name, inst] : defs) {
        if (useInterfacePath(*inst))
            emitInterfaceDef(*inst);
        else
            emitModuleDef(*inst, false);
    }
    // Deferred def-view aggregate-typedef param ts (typedefTs is now full).
    drainDefParamTs();
    // Pkg struct typedef ts spans stretch to the first module-signal USE
    // declarator (Surelog).
    for (auto& [tsP, aliasT] : pendingPkgTsStretch) {
        // LAST use wins (Surelog last-writer semantics).
        for (auto& [nm9, inst9] : defs) {
            for (auto& member : inst9->body.members()) {
                const DeclaredType* dt9 = nullptr;
                if (member.kind == SymbolKind::Net ||
                    member.kind == SymbolKind::Variable ||
                    member.kind == SymbolKind::Port)
                    dt9 = member.getDeclaredType();
                if (!dt9)
                    continue;
                const Type* t9 = &dt9->getType();
                while (t9->getCanonicalType().kind ==
                       SymbolKind::FixedSizeUnpackedArrayType)
                    t9 = &t9->getCanonicalType()
                              .as<FixedSizeUnpackedArrayType>()
                              .elementType;
                if ((const Type*)t9 != aliasT)
                    continue;
                if (auto dsyn9 = member.getSyntax()) {
                    // Only declarators extending past the name (an
                    // initializer or unpacked dims) stretch the span.
                    if (dsyn9->kind == syntax::SyntaxKind::Declarator) {
                        auto& dd9 = dsyn9->as<syntax::DeclaratorSyntax>();
                        if (!dd9.initializer && dd9.dimensions.empty())
                            continue;
                        // A STRUCT typedef only relocates for an unpacked-dim
                        // declarator or an assignment-PATTERN init; a bare
                        // literal fill (hw_key_req_t k = '1) leaves the shared
                        // typespec at its typedef span (PartSelectInFor).
                        // Enum/alias typedefs stretch on any init
                        // (typedef_package).
                        if (tsP->UhdmType() == UHDM::uhdmstruct_typespec &&
                            dd9.dimensions.empty() && dd9.initializer &&
                            dd9.initializer->expr->kind !=
                                syntax::SyntaxKind::AssignmentPatternExpression)
                            continue;
                    }
                    // ANSI PORT uses don't stretch (Surelog).
                    {
                        bool ansiPort9 = false;
                        for (auto q9 = dsyn9; q9; q9 = q9->parent)
                            if (q9->kind ==
                                syntax::SyntaxKind::ImplicitAnsiPort) {
                                ansiPort9 = true;
                                break;
                            }
                        if (ansiPort9)
                            continue;
                    }
                    auto e9 = dsyn9->sourceRange().end();
                    if (e9 != SourceLocation::NoLocation) {
                        tsP->VpiEndLineNo((uint32_t)sm->getLineNumber(e9));
                        tsP->VpiEndColumnNo(
                            (uint32_t)sm->getColumnNumber(e9));
                    }
                }
            }
        }
    }
    pendingPkgTsStretch.clear();

    // File-level class definitions -> design->AllClasses: properties as
    // ::-scoped automatic vars, methods via emitTaskFuncs (class scope).
    {
        auto* classes = s.MakeClass_defnVec();
        struct ClassEnt {
            const ClassType* cls;
            bool builtinFile;
        };
        std::vector<ClassEnt> ents;
        for (auto unit : comp.getCompilationUnits()) {
            bool bi = isBuiltinUnit(*unit);
            for (auto& mem : unit->members())
                if (mem.kind == SymbolKind::ClassType)
                    ents.push_back({&mem.as<ClassType>(), bi});
        }
        // Surelog compiles builtin.sv before the user sources, so its
        // class_defn objects lead the arena; the design's class LIST is then
        // ordered by SHORT class name (Surelog's multimap<name, ClassDefn*>).
        std::map<const ClassType*, UHDM::class_defn*> made;
        auto emitOne = [&](const ClassType* c) {
            std::string cname = "work@" + std::string(c->name);
            made[c] = emitClassDefn(*c, cname, cname, d);
        };
        for (auto& e : ents)
            if (e.builtinFile)
                emitOne(e.cls);
        for (auto& e : ents)
            if (!e.builtinFile)
                emitOne(e.cls);
        std::stable_sort(ents.begin(), ents.end(),
                         [](const ClassEnt& a, const ClassEnt& b) {
                             return a.cls->name < b.cls->name;
                         });
        for (auto& e : ents)
            classes->push_back(made[e.cls]);
        if (!classes->empty())
            d->AllClasses(classes);
    }


    for (auto inst : orderedTops) {
        std::string prefix = "work@" + std::string(inst->getDefinition().name);
        topMods->push_back(emitInstance(*inst, prefix, nullptr, nullptr, nullptr, /*isTop=*/true));
    }
    // Bind pkg alias-of-vector-typedef chains to the TARGET's top/module
    // listing object now that the top walk built it (jeras_union imm_l_t);
    // fall back to the def listing when the package never top-emitted.
    for (auto& [rt9, tgtSym9] : pendingAliasChainTgt) {
        UHDM::typespec* t9 = nullptr;
        if (auto it9 = pkgTopTypedefTs.find((const void*)tgtSym9);
            it9 != pkgTopTypedefTs.end())
            t9 = it9->second;
        else if (auto it8 = typedefTs.find(tgtSym9); it8 != typedefTs.end())
            t9 = it8->second;
        if (t9)
            rt9->Actual_typespec(t9);
    }
    pendingAliasChainTgt.clear();
    // Class property typespecs materialize post-elab (write phase).
    for (auto& pc : pendingClassPropTs) {
        auto* ts = makeTypespec(*pc.sym);
        pc.rt->Actual_typespec(ts);
        if (ts)
            ts->VpiParent(pc.var);
    }
    pendingClassPropTs.clear();
    // Write phase: walk defs NAME-SORTED; top defs write their ports +
    // deferred typespecs, other defs materialize their local-net typespecs
    // (Surelog write-phase arena order).
    for (auto& [name, inst] : defs) {
        // Simple interfaces have no top ports but do materialize their def-view
        // net typespecs (below), so they are NOT skipped here.
        auto* di = &defMap[&inst->getDefinition()];
        // A def never reached by the instance walk (its only "instance" was
        // a DROPPED bind under an implicit top, an unreferenced definition
        // under an explicit --top, or the design has NO top at all —
        // recursive_map) fills its port phase here.
        if (!di->filled && (droppedBindDefs.count(&inst->getDefinition()) ||
                            unrefDefs.count(&inst->getDefinition()) ||
                            orderedTops.empty())) {
            di->filled = true;
            emitModuleDefPorts(*inst);
        }
        // The def's LAST elaborated instance deferred its port typespecs to
        // this slot (ports precede nets, as in the top-def phase).
        drainElabPortTs(&inst->getDefinition());
        bool isTopDef = false;
        for (auto& tp : topPendings) {
            if (&tp.inst->getDefinition() == &inst->getDefinition()) {
                isTopDef = true;
                emitTopPorts(tp);
            }
        }
        if (!isTopDef) {
            // A (non-top) interface def unfolds its param-dependent net ranges
            // (W-1 -> operation); its def typespec is not shared with an elab
            // one, so this is safe.
            bool savedTf = tfContext;
            if (useInterfacePath(*inst))
                tfContext = true;
            for (auto& pn : pendingNetTs) {
                if (pn.di == di && !pn.rt->Actual_typespec())
                    materializeDefNetTs(pn);
            }
            tfContext = savedTf;
        }
    }
    // Re-point deferred def-view bare-package-typedef aggregate param refs at
    // the ELAB clone Surelog shares between both views (all elab param clones
    // now exist — they are minted in the emitTopPorts write phase above).
    shareDefAggParamTs();
    // A deferred instance whose def never appeared in the walk still needs its
    // typespec (safety net; normally everything drained above).
    for (auto& pe : pendingElabPortTs)
        if (!pe.rt->Actual_typespec())
            drainElabPortTs(pe.def);
    pendingElabPortTs.clear();
    topPendings.clear();
    pendingParamTs.clear();
    pendingNetTs.clear();
    for (auto& [dst, src] : netTsAlias)
        if (dst && src && !dst->Actual_typespec())
            dst->Actual_typespec(src->Actual_typespec());
    netTsAlias.clear();

    // Bind enum-value refs whose enum_const was only materialized in the
    // deferred typespec pass (anonymous enums).
    for (auto& [ref, sym] : pendingEnumRefs)
        if (auto eit = enumConstMap.find(sym); eit != enumConstMap.end())
            ref->Actual_group(eit->second);
    pendingEnumRefs.clear();

    // $signed/$unsigned result typespecs: share the LHS port's actual typespec
    // (no tail duplicate); fall back to a fresh one for non-port LHSs.
    for (auto& p : pendingSysFuncTs) {
        UHDM::typespec* act = nullptr;
        if (p.mod && p.mod->Ports())
            for (auto* pt : *p.mod->Ports())
                if (pt->VpiName() == p.sym->name && pt->Typespec())
                    act = pt->Typespec()->Actual_typespec();
        // Non-port LHS: share the def NET's typespec.
        if (!act && p.mod && p.mod->Nets())
            for (auto* nt : *p.mod->Nets())
                if (nt->VpiName() == p.sym->name && nt->Typespec())
                    act = nt->Typespec()->Actual_typespec();
        p.rt->Actual_typespec(act ? act : makeTypespec(*p.sym));
    }
    pendingSysFuncTs.clear();

    // $unit param typespecs are the very last arena objects.
    for (auto& pu : pendingUnitParamTs) {
        auto* its = makeParamTs(*pu.ps, /*typedParam=*/true);
        pu.prt->Actual_typespec(its);
        if (pu.rhsRt)
            pu.rhsRt->Actual_typespec(its);
        its->VpiParent(pu.up);
    }
    pendingUnitParamTs.clear();

    d->TopModules(topMods);

    s.MakeUhdmHandle(UHDM::uhdmdesign, d);
    // $bits(SIGNAL) typespec-bound arg refs bind their DEF nets (deferred:
    // the def param pre-pass ran before the nets existed).
    for (auto& [r0, sym0] : pendingBitsBoundRefs) {
        for (auto sc0 = sym0->getParentScope(); sc0;
             sc0 = sc0->asSymbol().getParentScope()) {
            if (sc0->asSymbol().kind != SymbolKind::InstanceBody)
                continue;
            auto dit0 =
                defMap.find(&sc0->asSymbol().as<InstanceBodySymbol>().getDefinition());
            if (dit0 != defMap.end()) {
                if (auto nit0 = dit0->second.nets.find(sym0);
                    nit0 != dit0->second.nets.end())
                    r0->Actual_group(nit0->second);
                else {
                    // Elaborated-instance param typespecs re-emit the $bits arg
                    // ref against the instance's own net symbol, but the def
                    // NetMap is keyed by the def-view body's symbols — bind by
                    // name to the DEF net (Surelog reuses work@<def>.<sig>).
                    for (auto& [ks, vn] : dit0->second.nets)
                        if (ks->name == sym0->name) {
                            r0->Actual_group(vn);
                            break;
                        }
                }
            }
            break;
        }
    }
    pendingBitsBoundRefs.clear();
    // Part-select fold constants' own logic_typespecs (bare-bound range),
    // materialized last (weak tail).
    for (auto& p : pendingPartSelFoldTs) {
        auto* lts = s.MakeLogic_typespec();
        auto* rg = s.MakeRange();
        rg->VpiParent(lts);
        auto mkb = [&](int64_t val) {
            auto* bc = s.MakeConstant();
            bc->VpiValue("UINT:" + std::to_string(val));
            return bc;
        };
        rg->Left_expr(mkb(p.left));
        rg->Right_expr(mkb(p.right));
        auto* rgv = s.MakeRangeVec();
        rgv->push_back(rg);
        lts->Ranges(rgv);
        p.rt->Actual_typespec(lts);
    }
    pendingPartSelFoldTs.clear();
    return d;
}

// Surelog reports source positions in the FULLY MACRO-EXPANDED text: every
// macro call is replaced in place by its expanded body, recursively (nested
// calls expanded, formals replaced by the actual argument text). This builder
// measures every expansion once so both layers can be reproduced:
//   * lineShifts   - a FILE position past a top-level macro call on its line
//                    moves right by (expandedLen - callLen).
//   * macroRepls   - a position INSIDE a macro body moves right by the deltas
//                    of the replacements (argument substitutions AND nested
//                    macro calls) that precede it on that body line.
// slang models each expansion as its own buffer whose getExpansionRange()
// names the text it replaces, so the buffers form the expansion tree directly.
void UhdmExporter::buildMacroExpansions() {
    macroExpBuilt = true;

    // Pasted-argument text per MacroArg buffer: slang gives EVERY token of a
    // macro argument its own buffer, so record both the token extent and the
    // whitespace that preceded it (the gap the next token pastes over).
    std::map<uint32_t, uint32_t> argLen, argLead;
    std::function<void(const slang::syntax::SyntaxNode&)> walk =
        [&](const slang::syntax::SyntaxNode& node) {
            for (size_t i = 0, n = node.getChildCount(); i < n; i++) {
                if (auto* child = node.childNode(i)) {
                    walk(*child);
                    continue;
                }
                auto tok = node.childToken(i);
                if (!tok)
                    continue;
                auto loc = tok.location();
                if (loc == SourceLocation::NoLocation || !sm->isMacroArgLoc(loc))
                    continue;
                uint32_t end = (uint32_t)(loc.offset() + tok.rawText().size());
                auto it = argLen.find(loc.buffer().getId());
                if (it == argLen.end() || end > it->second)
                    argLen[loc.buffer().getId()] = end;
                if (it == argLen.end()) {
                    size_t tl = 0;
                    for (auto& tv : tok.trivia())
                        tl += tv.getRawText().size();
                    argLead[loc.buffer().getId()] = (uint32_t)tl;
                }
            }
        };
    for (auto& tree : comp.getSyntaxTrees())
        walk(tree->root());

    // Every expansion buffer: what it replaces, and its unexpanded length.
    struct BufInfo {
        slang::SourceRange usage;
        int32_t rawLen = 0;
        bool multiLine = false;
    };
    std::map<uint32_t, BufInfo> info;
    std::vector<uint32_t> order;
    for (auto buf : sm->getAllBuffers()) {
        SourceLocation b0(buf, 0);
        if (!sm->isMacroLoc(b0))
            continue;
        BufInfo bi;
        bi.usage = sm->getExpansionRange(b0);
        if (bi.usage.start() == SourceLocation::NoLocation ||
            bi.usage.end() == SourceLocation::NoLocation ||
            bi.usage.start().buffer() != bi.usage.end().buffer())
            continue;
        if (sm->isMacroArgLoc(b0)) {
            // An argument buffer with no surviving token is an intermediate
            // hop (an actual that is itself a formal); it carries no text.
            auto it = argLen.find(buf.getId());
            if (it == argLen.end())
                continue;
            bi.rawLen = (int32_t)it->second;
        }
        else {
            SourceLocation bodyStart = sm->getFullyOriginalLoc(b0);
            if (bodyStart == SourceLocation::NoLocation ||
                sm->isMacroLoc(bodyStart))
                continue;
            auto text = sm->getSourceText(bodyStart.buffer());
            size_t p = bodyStart.offset();
            if (p >= text.size())
                continue;
            size_t e = p;
            while (e < text.size() && text[e] != '\n')
                e++;
            // Multi-line bodies (line-continuation backslash) keep definition
            // spans; no single-line length applies.
            size_t e2 = e;
            while (e2 > p && (text[e2 - 1] == ' ' || text[e2 - 1] == '\t' ||
                              text[e2 - 1] == '\r'))
                e2--;
            bi.multiLine = (e2 > p && text[e2 - 1] == '\\');
            bi.rawLen = (int32_t)(e2 - p);
        }
        info[buf.getId()] = bi;
        order.push_back(buf.getId());
    }

    // Attach each nested expansion to the body buffer it sits in.
    for (auto id : order) {
        auto& bi = info[id];
        auto us = bi.usage.start();
        if (!sm->isMacroLoc(us))
            continue;
        SourceLocation d = sm->getFullyOriginalLoc(us);
        uint32_t dl = (d == SourceLocation::NoLocation || sm->isMacroLoc(d))
                          ? 0
                          : (uint32_t)sm->getLineNumber(d);
        macroRepls[us.buffer().getId()].push_back(
            {(uint32_t)us.offset(), (uint32_t)bi.usage.end().offset(), 0, dl,
             {id}});
    }
    // Merge the parts that replace the SAME text (the tokens of one multi-token
    // argument) and keep only the outermost replacements: a formal that lives
    // inside a nested macro call is already covered by that call's expansion.
    for (auto& [k, v] : macroRepls) {
        std::sort(v.begin(), v.end(),
                  [](const MacroRepl& a, const MacroRepl& b) {
                      if (a.start != b.start)
                          return a.start < b.start;
                      if (a.end != b.end)
                          return a.end > b.end;
                      return a.parts.front() < b.parts.front();
                  });
        std::vector<MacroRepl> keep;
        uint32_t covered = 0;
        for (auto& r : v) {
            if (!keep.empty() && r.start == keep.back().start &&
                r.end == keep.back().end) {
                keep.back().parts.push_back(r.parts.front());
                continue;
            }
            if (!keep.empty() && r.start < covered)
                continue;
            keep.push_back(r);
            covered = r.end;
        }
        v.swap(keep);
    }

    // Expanded length of a buffer's text, recursively.
    std::map<uint32_t, int32_t> expLenMemo;
    std::function<int32_t(uint32_t)> expLen = [&](uint32_t id) -> int32_t {
        auto m = expLenMemo.find(id);
        if (m != expLenMemo.end())
            return m->second;
        auto bi = info.find(id);
        if (bi == info.end())
            return 0;
        expLenMemo[id] = bi->second.rawLen; // cycle guard
        int32_t len = bi->second.rawLen;
        auto ri = macroRepls.find(id);
        if (ri != macroRepls.end()) {
            for (auto& r : ri->second) {
                int32_t sum = 0;
                bool ok = true;
                for (size_t pi = 0; pi < r.parts.size(); pi++) {
                    auto ci = info.find(r.parts[pi]);
                    if (ci == info.end() || ci->second.multiLine) {
                        ok = false;
                        break;
                    }
                    // The gap before each continuation token is pasted too.
                    if (pi) {
                        auto li = argLead.find(r.parts[pi]);
                        if (li != argLead.end())
                            sum += (int32_t)li->second;
                    }
                    sum += expLen(r.parts[pi]);
                }
                if (!ok)
                    continue;
                r.delta = sum - (int32_t)(r.end - r.start);
                len += r.delta;
            }
        }
        expLenMemo[id] = len;
        return len;
    };

    // Resolve every replacement's delta (a multi-line body contributes no
    // line shift of its own, but its arguments still shift its body columns).
    for (auto id : order)
        expLen(id);

    // Where each continuation part lands inside its replacement.
    for (auto& [k, v] : macroRepls) {
        for (auto& r : v) {
            uint32_t off = 0;
            for (size_t pi = 0; pi < r.parts.size(); pi++) {
                if (pi) {
                    auto li = argLead.find(r.parts[pi]);
                    off += (li == argLead.end() ? 0 : li->second);
                    macroPartOffset[r.parts[pi]] = off;
                }
                auto ei = expLenMemo.find(r.parts[pi]);
                off += (ei == expLenMemo.end() ? 0 : (uint32_t)ei->second);
            }
        }
    }

    // Top-level calls (the ones whose replaced text is in a real file) drive
    // the per-line column shifts.
    for (auto id : order) {
        auto& bi = info[id];
        if (bi.multiLine)
            continue;
        auto us = bi.usage.start();
        if (sm->isMacroLoc(us))
            continue;
        int32_t delta =
            expLen(id) - (int32_t)(bi.usage.end().offset() - us.offset());
        if (delta == 0)
            continue;
        auto key = std::make_pair(us.buffer().getId(),
                                  (uint32_t)sm->getLineNumber(us));
        lineShifts[key].push_back({(uint32_t)sm->getColumnNumber(us), delta});
    }
    for (auto& [k, v] : lineShifts)
        std::sort(v.begin(), v.end());
}

// Column delta a macro-expanded token acquires from the replacements that
// precede it within its macro body line. Body tokens anchor at their own body
// offset; argument tokens anchor at the formal parameter they replaced (so the
// substitution itself is excluded, but earlier ones on the line still count).
int32_t UhdmExporter::macroArgShift(SourceLocation loc) {
    if (loc == SourceLocation::NoLocation || !sm->isMacroLoc(loc))
        return 0;
    if (!macroExpBuilt)
        buildMacroExpansions();
    SourceLocation bodyLoc = loc;
    if (sm->isMacroArgLoc(loc)) {
        bodyLoc = sm->getExpansionRange(loc).start();
        if (bodyLoc == SourceLocation::NoLocation || !sm->isMacroLoc(bodyLoc))
            return 0;
    }
    SourceLocation fdef = sm->getFullyOriginalLoc(bodyLoc);
    if (fdef == SourceLocation::NoLocation || sm->isMacroLoc(fdef))
        return 0;
    uint32_t defLine = (uint32_t)sm->getLineNumber(fdef);
    auto it = macroRepls.find(bodyLoc.buffer().getId());
    if (it == macroRepls.end())
        return 0;
    int32_t shift = 0;
    for (auto& r : it->second)
        if (r.end <= bodyLoc.offset() && r.defLine == defLine)
            shift += r.delta;
    return shift;
}

// Whitespace runs that TRAIL a based number literal on `line` (Surelog's
// lexer folds each into a single column). Memoized per (buffer, line).
const std::vector<std::pair<uint32_t, int32_t>>& UhdmExporter::numLitWsShift(
    SourceLocation lc, uint32_t line, uint32_t col) {
    auto key = std::make_pair(lc.buffer().getId(), line);
    auto [it, fresh] = numLitWsShifts.try_emplace(key);
    if (!fresh)
        return it->second;
    auto text = sm->getSourceText(lc.buffer());
    if (col == 0 || lc.offset() + 1 < col)
        return it->second;
    size_t ls = lc.offset() - (size_t)(col - 1);
    size_t le = text.find('\n', ls);
    if (ls >= text.size())
        return it->second;
    std::string_view ln =
        text.substr(ls, (le == std::string_view::npos ? text.size() : le) - ls);
    // A based literal's VALUE characters (the base letter is one of them).
    auto isVal = [](char ch) {
        return (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f') ||
               (ch >= 'A' && ch <= 'F') || ch == 'x' || ch == 'X' ||
               ch == 'z' || ch == 'Z' || ch == '?' || ch == '_';
    };
    for (size_t p = 0; p < ln.size();) {
        if (ln[p] != ' ') {
            p++;
            continue;
        }
        size_t q = p;
        while (q < ln.size() && ln[q] == ' ')
            q++;
        size_t runLen = q - p;
        if (runLen >= 2 && p > 0) {
            size_t j = p;
            while (j > 0 && isVal(ln[j - 1]))
                j--;
            // ...'<value>  or  ...'s<value>
            bool based = j < p && j > 0 &&
                         (ln[j - 1] == '\'' ||
                          ((ln[j - 1] == 's' || ln[j - 1] == 'S') && j > 1 &&
                           ln[j - 2] == '\''));
            // A PLAIN DECIMAL literal's trailing run collapses too
            // ("[12  -1:0]" pp-prints as "[12 -1:0]"; jeras_union imm_*) —
            // but ONLY in files Surelog actively preprocesses (any `
            // directive present); directive-free files pass through the pp
            // verbatim (fsm's "#1  IDLE" keeps its spacing).
            bool plain = false;
            if (!based && j < p &&
                text.find('`') != std::string_view::npos) {
                bool digitsOnly = ln[j] >= '0' && ln[j] <= '9';
                for (size_t k = j; digitsOnly && k < p; k++)
                    if (!((ln[k] >= '0' && ln[k] <= '9') || ln[k] == '_'))
                        digitsOnly = false;
                char pc = j > 0 ? ln[j - 1] : ' ';
                plain = digitsOnly &&
                        !((pc >= 'a' && pc <= 'z') || (pc >= 'A' && pc <= 'Z') ||
                          (pc >= '0' && pc <= '9') || pc == '_' || pc == '$' ||
                          pc == '\'' || pc == '.');
            }
            if (based || plain)
                it->second.push_back({(uint32_t)q, -(int32_t)(runLen - 1)});
        }
        p = q;
    }
    return it->second;
}

// A FILE position's Surelog-layout line/col (col shifted right past any
// single-line macro expansions earlier on the line, and LEFT past any
// whitespace run folded into a preceding based number literal).
void UhdmExporter::fileLineCol(SourceLocation lc, uint32_t& line,
                               uint32_t& col) {
    line = (uint32_t)sm->getLineNumber(lc);
    col = (uint32_t)sm->getColumnNumber(lc);
    if (!macroExpBuilt)
        buildMacroExpansions();
    uint32_t c0 = col;
    for (auto& [ucol, d] : numLitWsShift(lc, line, c0))
        if (ucol < c0)
            col = (uint32_t)((int32_t)col + d);
    auto it = lineShifts.find(std::make_pair(lc.buffer().getId(), line));
    if (it == lineShifts.end())
        return;
    for (auto& [ucol, d] : it->second)
        if (ucol < c0)
            col = (uint32_t)((int32_t)col + d);
}

// For a token from a SINGLE-LINE macro body: the Surelog-style virtual
// position (invocation line, invocation col + offset within the body).
// Returns false for multi-line-body tokens (they keep definition spans).
bool UhdmExporter::macroInvLineCol(SourceLocation loc, uint32_t& line,
                                   uint32_t& col) {
    if (!sm->isMacroLoc(loc))
        return false;
    SourceLocation orig = sm->getFullyOriginalLoc(loc);
    SourceLocation bodyStart =
        sm->getFullyOriginalLoc(SourceLocation(loc.buffer(), 0));
    if (orig.buffer() != bodyStart.buffer() ||
        orig.offset() < bodyStart.offset())
        return false;
    auto text = sm->getSourceText(orig.buffer());
    for (size_t i = bodyStart.offset(); i < orig.offset() && i < text.size();
         i++)
        if (text[i] == '\n')
            return false;
    SourceLocation u = sm->getExpansionRange(loc).start();
    uint32_t ul, uc;
    if (sm->isMacroLoc(u)) {
        if (!macroInvLineCol(u, ul, uc)) {
            u = sm->getFullyOriginalLoc(u);
            fileLineCol(u, ul, uc);
        }
        else if (!sm->isMacroArgLoc(loc)) {
            // A nested call sits at its own shifted position inside the parent
            // body. (For an argument paste the caller's macroArgShift already
            // supplies that shift, anchored at the formal it replaced.)
            uc = (uint32_t)((int32_t)uc + macroArgShift(u));
        }
    }
    else if (u == SourceLocation::NoLocation) {
        return false;
    }
    else {
        fileLineCol(u, ul, uc);
    }
    line = ul;
    col = uc + (uint32_t)loc.offset();
    // A continuation token of a multi-token argument starts where the earlier
    // parts of that argument end, not at the substitution point.
    if (!macroExpBuilt)
        buildMacroExpansions();
    if (auto pi = macroPartOffset.find(loc.buffer().getId());
        pi != macroPartOffset.end())
        col += pi->second;
    return true;
}

std::string UhdmExporter::rawText(SourceRange range) {
    if (range.start() == SourceLocation::NoLocation || range.end() == SourceLocation::NoLocation)
        return "";
    // Macro-expansion buffers have no stored text; read the definition site.
    if (sm->isMacroLoc(range.start()) && sm->isMacroLoc(range.end()))
        range = sm->getFullyOriginalRange(range);
    auto text = sm->getSourceText(range.start().buffer());
    size_t start = range.start().offset();
    size_t end = range.end().offset();
    if (end > text.size() || start > end)
        return "";
    return std::string(text.substr(start, end - start));
}

SourceRange UhdmExporter::ifaceElemIndexRange(SourceRange range) {
    std::string t = rawText(range);
    auto lb = t.find('[');
    if (lb == std::string::npos || t.empty() || t.back() != ']')
        return range;
    size_t b = lb + 1, e = t.size() - 1;
    while (b < e && isspace((unsigned char)t[b]))
        ++b;
    while (e > b && isspace((unsigned char)t[e - 1]))
        --e;
    if (b >= e)
        return range;
    return SourceRange(range.start() + b, range.start() + e);
}

} // namespace slang_uhdm
