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

std::string UhdmExporter::rootFilePath(SourceLocation loc) {
    if (loc == SourceLocation::NoLocation)
        return "";
    if (sm->isMacroLoc(loc))
        loc = sm->getFullyOriginalLoc(loc);
    auto buf = loc.buffer();
    for (int guard = 0; guard < 64; guard++) {
        auto up = sm->getIncludedFrom(buf);
        if (up == SourceLocation::NoLocation || !up.buffer().valid())
            break;
        buf = up.buffer();
    }
    return sm->getFullPath(buf).string();
}

std::vector<std::pair<const Symbol*, const Symbol*>>
UhdmExporter::fileScopeImportTypedefs(SourceLocation modLoc) {
    std::vector<std::pair<const Symbol*, const Symbol*>> out;
    std::string modFile = rootFilePath(modLoc);
    if (modFile.empty())
        return out;
    for (auto unit : comp.getCompilationUnits()) {
        for (auto& mem : unit->members()) {
            if (mem.kind != SymbolKind::WildcardImport &&
                mem.kind != SymbolKind::ExplicitImport)
                continue;
            if (rootFilePath(mem.location) != modFile)
                continue;
            if (mem.kind == SymbolKind::ExplicitImport) {
                auto* imported = mem.as<ExplicitImportSymbol>().importedSymbol();
                if (imported && imported->kind == SymbolKind::TypeAlias)
                    out.emplace_back(&mem, imported);
                continue;
            }
            auto* pkg = comp.getPackage(
                mem.as<WildcardImportSymbol>().packageName);
            if (!pkg)
                continue;
            std::vector<const Symbol*> tas;
            for (auto& pm : pkg->members())
                if (pm.kind == SymbolKind::TypeAlias)
                    tas.push_back(&pm);
            std::stable_sort(tas.begin(), tas.end(),
                             [](const Symbol* a, const Symbol* b) {
                                 return a->name < b->name;
                             });
            for (auto* ta : tas)
                out.emplace_back(&mem, ta);
        }
    }
    return out;
}

bool UhdmExporter::verilogLexMode(SourceLocation loc) {
    if (loc == SourceLocation::NoLocation)
        return false;
    if (sm->isMacroLoc(loc))
        loc = sm->getFullyOriginalLoc(loc);
    // The lexer mode is set once per COMMAND-LINE file, so an `included
    // header inherits its includer's mode: walk to the root of the chain.
    auto buf = loc.buffer();
    for (int guard = 0; guard < 64; guard++) {
        auto up = sm->getIncludedFrom(buf);
        if (up == SourceLocation::NoLocation || !up.buffer().valid())
            break;
        buf = up.buffer();
    }
    return sm->getFullPath(buf).extension().string() != ".sv";
}

// ---------------------------------------------------------------------------
// Include file info
// ---------------------------------------------------------------------------
// Surelog hangs one include_file_info off the design for every ACTIVE
// `include directive it preprocessed -- the Context::INCLUDE + Action::PUSH
// records of each command-line file's root PreprocessFile, walked in
// preprocessing pre-order (CompileDesign.cpp "Compile Include file info" +
// UhdmWriter.cpp `d->Include_file_infos`).  Per record:
//
//   VpiFile         the ROOT source file of the include chain (the records all
//                   live on the root PreprocessFile, so a nested include still
//                   reports the command-line file)
//   VpiIncludedFile the resolved path of the included file
//   line/col        the filename token's span, EXCEPT that the line is
//                   Surelog's FLATTENED preprocessor-output line: the
//                   directive lines of the enclosing chain accumulate, and
//                   every earlier include in the same file shifts the line by
//                   the number of lines that include spliced in.
//
// slang gives us the same events from `SyntaxTree::getIncludeDirectives()`:
// recorded per directive, in pre-order, skipped inside a false `ifdef branch
// (parseBranchDirective consumes raw tokens), and with a FRESH buffer id per
// inclusion so the include tree is recoverable through the includer buffer.
// One asymmetry: when slang's header-guard detection suppresses a re-inclusion
// it records the directive with NO buffer.  Surelog still re-reads the file and
// records the event (its guarded body just appends nothing), so we keep those,
// resolving their path from the earlier inclusion that did open the file.
void UhdmExporter::emitIncludeFileInfos() {
    struct Ev {
        slang::BufferID inBuf;   // buffer holding the directive
        slang::BufferID incBuf;  // buffer of the included file, if opened
        uint32_t line = 0, col = 0, endLine = 0, endCol = 0;
        std::string path;    // resolved path of the included file
        uint32_t flat = 0;   // output lines this inclusion splices in
        int32_t parent = -1; // enclosing inclusion, -1 at a root file
    };
    std::vector<Ev> evs;
    std::map<uint32_t, size_t> evOfIncluded; // included buffer id -> event
    std::map<std::string, std::string> resolved; // as written -> full path
    for (auto tree : comp.getSyntaxTrees()) {
        for (auto& im : tree->getIncludeDirectives()) {
            if (!im.syntax)
                continue;
            auto r = im.syntax->fileName.range();
            if (r.start() == SourceLocation::NoLocation)
                continue;
            Ev e;
            e.inBuf = sm->getFullyExpandedLoc(r.start()).buffer();
            if (im.buffer.id) {
                e.incBuf = im.buffer.id;
                e.path = sm->getFullPath(im.buffer.id).string();
                resolved.emplace(std::string(im.path), e.path);
            }
            else {
                // Guard-suppressed (or unopenable) include: no buffer of its
                // own, so reuse the path this spelling resolved to before.
                auto it = resolved.find(std::string(im.path));
                if (it == resolved.end())
                    continue;
                e.path = it->second;
            }
            fileLineCol(r.start(), e.line, e.col);
            if (r.end() != SourceLocation::NoLocation)
                fileLineCol(r.end(), e.endLine, e.endCol);
            else {
                e.endLine = e.line;
                e.endCol = e.col;
            }
            if (e.incBuf)
                evOfIncluded.emplace(e.incBuf.getId(), evs.size());
            evs.push_back(std::move(e));
        }
    }
    if (evs.empty())
        return;
    // The enclosing inclusion is the event that opened the buffer this
    // directive sits in; pre-order guarantees it comes first, which also keeps
    // the parent walk below finite.
    for (size_t i = 0; i < evs.size(); i++) {
        auto it = evOfIncluded.find(evs[i].inBuf.getId());
        if (it != evOfIncluded.end() && it->second < i)
            evs[i].parent = (int32_t)it->second;
    }
    // How many output lines each inclusion splices into its includer: the
    // included file's own line count plus whatever ITS includes splice in.  An
    // inclusion slang suppressed (header guard already satisfied) splices
    // nothing -- Surelog re-reads the file but its guarded body appends
    // nothing.  Children always follow their parent in pre-order, so one
    // reverse pass accumulates.
    for (size_t i = evs.size(); i-- > 0;) {
        auto& e = evs[i];
        if (e.incBuf) {
            auto text = sm->getSourceText(e.incBuf);
            e.flat += (uint32_t)std::count(text.begin(), text.end(), '\n');
        }
        if (e.parent >= 0)
            evs[(size_t)e.parent].flat += e.flat;
    }
    // Line within the includer's own output = raw line plus the splices of the
    // earlier includes in that same buffer; the chain then adds each ancestor's
    // own such line minus one (the directive line the content replaces).
    std::map<uint32_t, uint32_t> shift; // includer buffer id -> lines spliced so far
    std::vector<uint32_t> rel(evs.size(), 0);
    for (size_t i = 0; i < evs.size(); i++) {
        auto& e = evs[i];
        rel[i] = e.line + shift[e.inBuf.getId()];
        shift[e.inBuf.getId()] += e.flat;
    }
    auto* infos = s.MakeInclude_file_infoVec();
    for (size_t i = 0; i < evs.size(); i++) {
        auto& e = evs[i];
        uint32_t line = rel[i];
        auto* rootBuf = &e.inBuf;
        for (int32_t p = e.parent; p >= 0; p = evs[(size_t)p].parent) {
            line += rel[(size_t)p] - 1;
            rootBuf = &evs[(size_t)p].inBuf;
        }
        auto* ifi = s.MakeInclude_file_info();
        ifi->VpiParent(d);
        ifi->VpiFile(sm->getFullPath(*rootBuf).string());
        ifi->VpiIncludedFile(e.path);
        ifi->VpiLineNo(line);
        ifi->VpiColumnNo(e.col);
        ifi->VpiEndLineNo(e.endLine > e.line ? line + (e.endLine - e.line) : line);
        ifi->VpiEndColumnNo(e.endCol);
        infos->push_back(ifi);
    }
    d->Include_file_infos(infos);
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
    if (auto syn = cls.getSyntax()) {
        // Surelog anchors a class_defn at the `class` KEYWORD (its
        // sl_collect(modId, paCLASS) start node), so a `virtual class` starts
        // past the `virtual`.
        auto r = syn->sourceRange();
        if (auto* cds = syn->as_if<syntax::ClassDeclarationSyntax>())
            if (cds->classKeyword.range().start() != SourceLocation::NoLocation)
                r = SourceRange(cds->classKeyword.range().start(), r.end());
        setLoc(cd, r);
    }
    auto* vars = s.MakeVariablesVec();
    for (auto& pm : cls.members()) {
        if (pm.kind != SymbolKind::ClassProperty)
            continue;
        auto& cp = pm.as<ClassPropertySymbol>();
        auto& ct = cp.getType().getCanonicalType();
        std::string pfn = fullName + "::" + std::string(cp.name);
        // `rand`/`randc` qualifier -> vpiIsRandomized + vpiRandType
        // (vpiNotRand 1 / vpiRand 2 / vpiRandC 3); an unqualified property
        // keeps whatever the shape below sets (SimpleConstraint).
        int32_t randTy = cp.randMode == RandMode::Rand    ? 2
                         : cp.randMode == RandMode::RandC ? 3
                                                          : 0;
        // A DYNAMIC-array / QUEUE / ASSOC property is an array_var carrying a
        // bare array_typespec, with the ELEMENT variable under vpiReg.
        if (ct.kind == SymbolKind::DynamicArrayType ||
            ct.kind == SymbolKind::QueueType ||
            ct.kind == SymbolKind::AssociativeArrayType) {
            const Type* et = nullptr;
            int32_t akind = 2;
            if (ct.kind == SymbolKind::DynamicArrayType)
                et = &ct.as<DynamicArrayType>().elementType;
            else if (ct.kind == SymbolKind::QueueType) {
                et = &ct.as<QueueType>().elementType;
                akind = 4;
            }
            else {
                et = &ct.as<AssociativeArrayType>().elementType;
                akind = 3;
            }
            auto* reg = classElemVar(*et);
            if (!reg) {
                noteUnsupported("class array property element");
                continue;
            }
            auto* av = s.MakeArray_var();
            av->VpiName(cp.name);
            av->VpiFullName(pfn);
            av->VpiParent(cd);
            setLoc(av, nameSpan(cp.location, cp.name));
            av->VpiSize(1);
            av->VpiAutomatic(true);
            if (randTy) {
                av->VpiIsRandomized(true);
                av->VpiRandType(randTy);
            }
            else
                av->VpiRandType(1);
            av->VpiVisibility(1);
            av->VpiArrayType(akind);
            auto* ats = s.MakeArray_typespec();
            auto* art = s.MakeRef_typespec();
            art->VpiParent(av);
            art->Actual_typespec(ats);
            av->Typespec(art);
            reg->VpiParent(av);
            reg->VpiFullName(pfn);
            setLoc(reg, nameSpan(cp.location, cp.name));
            // An ELEMENT type with no shared alias (a bare `bit [7:0]`) still
            // gets its own typespec, minted in the write phase like any other
            // property's (SimpleConstraint `rand bit [7:0] payload []`: the
            // vpiReg bit_var's ref_typespec -> a ranged bit_typespec).
            if (auto* rrt = reg->Typespec();
                rrt && !((UHDM::ref_typespec*)rrt)->Actual_typespec())
                pendingClassPropTs.push_back(
                    {(UHDM::ref_typespec*)rrt, &cp, reg});
            auto* rvars = s.MakeVariablesVec();
            rvars->push_back(reg);
            av->Variables(rvars);
            vars->push_back(av);
            continue;
        }
        // A predefined integer field (int/byte/...) is the matching typed
        // var (int_var + vpiSigned), not a bare bit_var; anonymous bit/logic
        // vectors keep bit/logic_var.
        UHDM::variables* v = nullptr;
        // An ENUM-typed property is an enum_var, not the bit/logic_var its
        // integral base would give (SimpleConstraint `rand pkt_type ptype`);
        // the array-element path (classElemVar) already had this rule.
        if (ct.kind == SymbolKind::EnumType)
            v = s.MakeEnum_var();
        else if (ct.isIntegral()) {
            if (ct.kind == SymbolKind::PredefinedIntegerType)
                v = makeVar(cp, /*portBacked=*/false);
            if (!v)
                v = ct.isFourState() ? (UHDM::variables*)s.MakeLogic_var()
                                     : (UHDM::variables*)s.MakeBit_var();
        }
        else
            v = makeVar(cp, /*portBacked=*/false);
        if (!v) {
            noteUnsupported("class property type: " +
                            std::string(toString(ct.kind)));
            continue;
        }
        v->VpiName(cp.name);
        v->VpiFullName(fullName + "::" + std::string(cp.name));
        v->VpiParent(cd);
        setLoc(v, nameSpan(cp.location, cp.name));
        v->VpiAutomatic(true);
        if (randTy) {
            v->VpiIsRandomized(true);
            v->VpiRandType(randTy);
        }
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
    if (cls.genericClass)
        genericDefnMap.emplace(cls.genericClass, cd);
    // `virtual class` / `pure virtual class`.
    if (cls.isAbstract)
        cd->VpiVirtual(true);
    // Parameters BEFORE typedefs: Surelog compiles the class header first, so
    // a formal's typespec is the older object (arena order — VirtualClass's
    // type_parameter logic_typespec precedes the typedefs' own objects).
    emitClassParameters(cls, cd, fullName);
    emitClassTypedefs(cls, cd);
    currentClassDefn = cd;
    emitTaskFuncs(cls, cd, fullName + "::", nullptr, false);
    currentClassDefn = nullptr;
    // NESTED classes are their own class_defns parented at the enclosing one
    // and listed in its vpiInternalScope (Surelog's
    // CompileClass::compile_class_declaration_ pushes them onto Scopes()).
    // They are NOT re-listed in the owning package/module class list.
    {
        auto* scopes = s.MakeScopeVec();
        for (auto& nm : cls.members()) {
            const ClassType* nested = nullptr;
            if (nm.kind == SymbolKind::ClassType)
                nested = &nm.as<ClassType>();
            else if (nm.kind == SymbolKind::GenericClassDef) {
                if (auto* dsp = nm.as<GenericClassDefSymbol>().getDefaultSpecialization(cls);
                    dsp && dsp->kind == SymbolKind::ClassType)
                    nested = &dsp->as<ClassType>();
            }
            if (!nested)
                continue;
            scopes->push_back(emitClassDefn(*nested, std::string(nm.name),
                                            fullName + "::" + std::string(nm.name), cd));
        }
        if (!scopes->empty())
            cd->Scopes(scopes);
    }
    // `extends` needs every class_defn in the design to exist first.
    if (cls.getBaseClass())
        pendingExtends.push_back({cd, &cls});
    return cd;
}

UHDM::typespec* UhdmExporter::sharedAliasTs(const Type& t) {
    if (t.kind != SymbolKind::TypeAlias)
        return nullptr;
    if (auto it = pkgTopTypedefTs.find((const void*)&t); it != pkgTopTypedefTs.end())
        return it->second;
    if (auto it2 = typedefTs.find(&t); it2 != typedefTs.end())
        return it2->second;
    return nullptr;
}

UHDM::variables* UhdmExporter::classElemVar(const Type& elemType) {
    auto& ec = elemType.getCanonicalType();
    UHDM::variables* v = nullptr;
    UHDM::typespec* ts = nullptr;
    if (ec.kind == SymbolKind::ClassType) {
        v = s.MakeClass_var();
        auto* cts = s.MakeClass_typespec();
        cts->VpiName(ec.name);
        pendingClassTsLink.push_back({cts, &ec});
        ts = cts;
    }
    else if (ec.isStruct()) {
        v = s.MakeStruct_var();
        ts = sharedAliasTs(elemType);
    }
    else if (ec.isUnpackedUnion() || ec.isPackedUnion()) {
        v = s.MakeUnion_var();
        ts = sharedAliasTs(elemType);
    }
    else if (ec.kind == SymbolKind::EnumType) {
        v = s.MakeEnum_var();
        ts = sharedAliasTs(elemType);
    }
    else if (ec.kind == SymbolKind::StringType)
        v = s.MakeString_var();
    else if (ec.kind == SymbolKind::PredefinedIntegerType ||
             ec.kind == SymbolKind::ScalarType || ec.kind == SymbolKind::PackedArrayType)
        v = ec.isFourState() ? (UHDM::variables*)s.MakeLogic_var()
                             : (UHDM::variables*)s.MakeBit_var();
    if (!v)
        return nullptr;
    auto* rt = s.MakeRef_typespec();
    rt->VpiParent(v);
    if (ts)
        rt->Actual_typespec(ts);
    v->Typespec(rt);
    return v;
}

// Class-scope parameters. Surelog compiles them with Reduce::No, so only a
// LITERAL initializer becomes a value: such a parameter carries the folded
// value plus a synthesized int_typespec spanning its whole DECLARATION, shared
// by every declarator of that declaration and by their RHS constants. A
// parameter whose RHS is an expression (5 * p1) keeps neither. The param_assign
// RHS is built from SYNTAX (unfolded), matching Surelog's un-reduced model.
void UhdmExporter::emitClassParameters(const ClassType& cls, UHDM::class_defn* cd,
                                       const std::string& fullName) {
    auto* params = s.MakeAnyVec();
    auto* pas = s.MakeParam_assignVec();
    // The `parameter <...>` declaration node a declarator belongs to (its span
    // excludes the trailing `;`, which the class-property wrapper would add).
    auto declNodeOf = [](const Symbol& sym) -> const syntax::SyntaxNode* {
        for (auto p = sym.getSyntax(); p; p = p->parent)
            if (p->kind == syntax::SyntaxKind::ParameterDeclaration ||
                p->kind == syntax::SyntaxKind::TypeParameterDeclaration)
                return p;
        return nullptr;
    };
    for (auto& mem : cls.members()) {
        if (mem.kind == SymbolKind::TypeParameter) {
            auto& tps = mem.as<TypeParameterSymbol>();
            auto* tp = s.MakeType_parameter();
            tp->VpiName(tps.name);
            tp->VpiFullName(fullName + "::" + std::string(tps.name));
            tp->VpiParent(cd);
            setLoc(tp, nameSpan(tps.location, tps.name));
            auto* rt = s.MakeRef_typespec();
            rt->VpiParent(tp);
            auto& dt = tps.targetType.getType();
            auto* dsyn = tps.targetType.getTypeSyntax();
            UHDM::typespec* its = nullptr;
            if (auto& dct = dt.getCanonicalType(); dct.kind == SymbolKind::ClassType) {
                auto* cts = s.MakeClass_typespec();
                cts->VpiName(dsyn ? std::string(rawText(dsyn->sourceRange()))
                                  : std::string(dct.name));
                cts->VpiParent(tp);
                if (dsyn)
                    setLoc(cts, dsyn->sourceRange());
                pendingClassTsLink.push_back({cts, &dct});
                its = cts;
            }
            else {
                its = makeTypespec(mem, dsyn);
                if (its)
                    its->VpiParent(tp);
            }
            rt->Actual_typespec(its);
            tp->Typespec(rt);
            params->push_back(tp);
            continue;
        }
        if (mem.kind != SymbolKind::Parameter)
            continue;
        auto& ps = mem.as<ParameterSymbol>();
        auto* pv = s.MakeParameter();
        pv->VpiName(ps.name);
        pv->VpiFullName(fullName + "::" + std::string(ps.name));
        pv->VpiParent(cd);
        setLoc(pv, nameSpan(ps.location, ps.name));
        // Class parameters are localparams by LRM, but Surelog reports
        // vpiLocalParam off the WRITTEN keyword (paLocal_parameter_declaration).
        if (auto* dn0 = declNodeOf(ps))
            if (auto* pd0 = dn0->as_if<syntax::ParameterDeclarationBaseSyntax>();
                pd0 && pd0->keyword.kind == parsing::TokenKind::LocalParamKeyword)
                pv->VpiLocalParam(true);
        params->push_back(pv);
        // RHS from syntax (Surelog does not reduce class parameters).
        const syntax::ExpressionSyntax* rhsSyn = nullptr;
        if (auto dsyn = ps.getSyntax())
            if (auto* dcl = dsyn->as_if<syntax::DeclaratorSyntax>();
                dcl && dcl->initializer)
                rhsSyn = dcl->initializer->expr;
        if (!rhsSyn)
            continue;
        auto* pa = s.MakeParam_assign();
        pa->VpiParent(cd);
        setLoc(pa, SourceRange(ps.location, rhsSyn->sourceRange().end()));
        auto* rhs = emitSyntaxExpr(*rhsSyn, pa);
        if (!rhs) {
            pas->push_back(pa);
            pa->Lhs(pv);
            continue;
        }
        pa->Rhs((UHDM::expr*)rhs);
        pa->Lhs(pv);
        pas->push_back(pa);
        // A literal RHS folds: the parameter takes its value, and both the
        // parameter and the constant share the declaration's int_typespec.
        if (rhs->UhdmType() != UHDM::uhdmconstant)
            continue;
        auto* rc = (UHDM::constant*)rhs;
        pv->VpiValue(rc->VpiValue());
        // ONE int_typespec per DECLARATOR (three declarators on one
        // `parameter` line give three objects), spanning the whole declaration
        // and shared with that declarator's own fold constant. A SIZED literal
        // RHS also gives it the literal's packed range.
        auto* dn = declNodeOf(ps);
        UHDM::typespec* dts = nullptr;
        {
            auto* its = s.MakeInt_typespec();
            if (dn)
                setLoc(its, dn->sourceRange());
            if (rhsSyn->kind == syntax::SyntaxKind::IntegerVectorExpression) {
                std::string raw0(rawText(rhsSyn->sourceRange()));
                auto tick0 = raw0.find('\'');
                int32_t sz0 = tick0 != std::string::npos && tick0 > 0
                                  ? atoi(raw0.substr(0, tick0).c_str())
                                  : 0;
                if (sz0 > 0) {
                    auto mk0 = [&](int64_t v) {
                        auto* c0 = s.MakeConstant();
                        c0->VpiValue("INT:" + std::to_string(v));
                        return c0;
                    };
                    auto* rg0 = s.MakeRange();
                    rg0->VpiParent(its);
                    rg0->Left_expr(mk0(sz0 - 1));
                    rg0->Right_expr(mk0(0));
                    auto* rgv0 = s.MakeRangeVec();
                    rgv0->push_back(rg0);
                    its->Ranges(rgv0);
                }
            }
            dts = its;
        }
        auto* prt = s.MakeRef_typespec();
        prt->VpiParent(pv);
        prt->Actual_typespec(dts);
        pv->Typespec(prt);
        auto* crt = s.MakeRef_typespec();
        crt->VpiParent(rc);
        crt->Actual_typespec(dts);
        rc->Typespec(crt);
    }
    if (!params->empty())
        cd->Parameters(params);
    if (!pas->empty())
        cd->Param_assigns(pas);
}

// PACKAGE-scope class definitions: emitted onto the ELABORATED package view
// only, name-sorted (Surelog's multimap<name, ClassDefinition*>).
void UhdmExporter::emitPackageClasses(const PackageSymbol& pkg, UHDM::package* up,
                                      const std::string& prefix) {
    std::vector<std::pair<std::string, const ClassType*>> pcls;
    for (auto& mem : pkg.members()) {
        if (mem.kind == SymbolKind::ClassType)
            pcls.emplace_back(std::string(mem.name), &mem.as<ClassType>());
        else if (mem.kind == SymbolKind::GenericClassDef) {
            if (auto* dsp = mem.as<GenericClassDefSymbol>().getDefaultSpecialization(pkg);
                dsp && dsp->kind == SymbolKind::ClassType)
                pcls.emplace_back(std::string(mem.name), &dsp->as<ClassType>());
        }
    }
    if (pcls.empty())
        return;
    std::stable_sort(pcls.begin(), pcls.end(),
                     [](auto& a, auto& b) { return a.first < b.first; });
    auto* cds = s.MakeClass_defnVec();
    for (auto& [nm, c] : pcls)
        cds->push_back(emitClassDefn(*c, nm, prefix + nm, up));
    up->Class_defns(cds);
}

// The deferred `extends` pass. Surelog binds base classes by walking the
// design-wide name-sorted class map (TestbenchElaboration::bindBaseClasses_),
// so vpiDerivedClasses lists derived classes in NAME order. Two shapes:
//   extends <class>      -> extends parented at the derived class_defn, the
//                           class_typespec named/located at the written base
//                           name, and the base gains a vpiDerivedClasses entry.
//   extends <typeparam>  -> extends has NO vpiParent, the class_typespec is
//                           loc-less and named after the parameter, its
//                           vpiClassDefn copied from the type_parameter's own
//                           class_typespec, and the base gains NO derived entry.
void UhdmExporter::drainPendingExtends() {
    for (auto& [cts, ty] : pendingClassTsLink) {
        if (cts->Class_defn())
            continue;
        if (auto* cd9 = classDefnFor(*ty))
            cts->Class_defn(cd9);
    }
    pendingClassTsLink.clear();
    for (auto& pp : pendingClassTsPa) {
        if (pp.pa->Lhs())
            continue;
        if (auto* cd9 = classDefnFor(*pp.cls); cd9 && cd9->Parameters())
            for (auto* p9 : *cd9->Parameters())
                if (p9->VpiName() == pp.paramName) {
                    pp.pa->Lhs(p9);
                    break;
                }
    }
    pendingClassTsPa.clear();
    auto pend = pendingExtends;
    pendingExtends.clear();
    std::stable_sort(pend.begin(), pend.end(), [](const PendingExtends& a,
                                                  const PendingExtends& b) {
        return a.cls->name < b.cls->name;
    });
    for (auto& pe : pend) {
        auto* base = pe.cls->getBaseClass();
        if (!base)
            continue;
        // The base name AS WRITTEN (Surelog names the class_typespec after the
        // extends-clause token, not after the resolved class).
        std::string written;
        const syntax::SyntaxNode* nameSyn = nullptr;
        SourceRange nameRange;
        if (auto syn = pe.cls->getSyntax();
            syn && syn->kind == syntax::SyntaxKind::ClassDeclaration)
            if (auto* ec = syn->as<syntax::ClassDeclarationSyntax>().extendsClause) {
                nameSyn = ec->baseName;
                // A PARAMETERIZED base (`extends resource_db#(T)`) names and
                // spans only the class IDENTIFIER — Surelog drops the
                // parameter assignment from both (ClassParamAsParam).
                if (auto* cn = nameSyn->as_if<syntax::ClassNameSyntax>()) {
                    written = std::string(cn->identifier.valueText());
                    nameRange = cn->identifier.range();
                }
                else {
                    written = std::string(rawText(nameSyn->sourceRange()));
                    nameRange = nameSyn->sourceRange();
                }
            }
        // `extends IF` where IF is one of this class's own type parameters.
        const Symbol* tpSym = nullptr;
        if (!written.empty())
            for (auto& mem : pe.cls->members())
                if (mem.kind == SymbolKind::TypeParameter && mem.name == written) {
                    tpSym = &mem;
                    break;
                }
        auto* ext = s.MakeExtends();
        auto* rt = s.MakeRef_typespec();
        auto* cts = s.MakeClass_typespec();
        rt->VpiParent(ext);
        rt->Actual_typespec(cts);
        ext->Class_typespec(rt);
        cts->VpiName(written.empty() ? std::string(base->name) : written);
        auto& bct = base->getCanonicalType();
        if (auto bit = classDefnMap.find(&bct); bit != classDefnMap.end())
            cts->Class_defn(bit->second);
        if (nameSyn)
            setLoc(ext, nameRange);
        if (!tpSym) {
            // The class-bound branch: the extends is parented, the typespec
            // located, and the base collects the derived class.
            ext->VpiParent(pe.cd);
            if (nameSyn)
                setLoc(cts, nameRange);
            if (auto* baseCd = (UHDM::class_defn*)cts->Class_defn()) {
                auto* der = baseCd->Deriveds();
                if (!der) {
                    baseCd->Deriveds(s.MakeClass_defnVec());
                    der = baseCd->Deriveds();
                }
                der->push_back(pe.cd);
            }
            // A base class named through the enclosing package's WILDCARD
            // import also lists that typedef's shared import clone in the
            // DERIVING class's own Typespecs — the package import-listing
            // rule applied to the scope that actually resolved the name
            // (ClassExtends: `class c2 extends c3` inside p2 lists p1::c3).
            if (!written.empty())
                if (auto* sc9 = pe.cls->getParentScope();
                    sc9 && sc9->asSymbol().kind == SymbolKind::Package)
                    for (auto& im9 : sc9->members()) {
                        if (im9.kind != SymbolKind::WildcardImport)
                            continue;
                        auto* ip9 = im9.as<WildcardImportSymbol>().getPackage();
                        if (!ip9)
                            continue;
                        for (auto& tm9 : ip9->members()) {
                            if (tm9.kind != SymbolKind::TypeAlias ||
                                tm9.name != written)
                                continue;
                            auto ic9 = pkgImportCloneTs.find(&tm9);
                            if (ic9 == pkgImportCloneTs.end())
                                continue;
                            auto* tv9 = pe.cd->Typespecs();
                            if (!tv9) {
                                pe.cd->Typespecs(s.MakeTypespecVec());
                                tv9 = pe.cd->Typespecs();
                            }
                            if (std::find(tv9->begin(), tv9->end(),
                                          ic9->second) == tv9->end())
                                tv9->push_back(ic9->second);
                        }
                    }
        }
        pe.cd->Extends(ext);
    }
}

// A specialization's class_defn: Surelog compiles a parameterized class ONCE
// (from its default specialization), so every slang specialization symbol of
// the same generic maps onto that one object.
UHDM::class_defn* UhdmExporter::classDefnFor(const Type& ct) {
    if (auto it = classDefnMap.find(&ct); it != classDefnMap.end())
        return it->second;
    if (ct.kind == SymbolKind::ClassType)
        if (auto* gc = ct.as<ClassType>().genericClass)
            if (auto git = genericDefnMap.find(gc); git != genericDefnMap.end())
                return git->second;
    return nullptr;
}

// The specialization carried by a class_typespec (see the header note).
void UhdmExporter::emitClassTsParams(UHDM::class_typespec* cts, const ClassType& cls,
                                     const std::string& prefix) {
    auto* params = s.MakeAnyVec();
    auto* pas = s.MakeParam_assignVec();
    for (auto& mem : cls.members()) {
        // Value parameters of a specialization have no observed Surelog form
        // here yet; only `type` formals are reproduced.
        if (mem.kind != SymbolKind::TypeParameter)
            continue;
        auto& tps = mem.as<TypeParameterSymbol>();
        std::string fn = prefix + "." + std::string(tps.name);
        auto* tp = s.MakeType_parameter();
        tp->VpiName(tps.name);
        tp->VpiFullName(fn);
        tp->VpiParent(cts);
        setLoc(tp, nameSpan(tps.location, tps.name));
        auto* rt = s.MakeRef_typespec();
        rt->VpiParent(tp);
        rt->VpiFullName(fn);
        auto& dct = tps.targetType.getType().getCanonicalType();
        auto* dsyn = tps.targetType.getTypeSyntax();
        UHDM::typespec* its = nullptr;
        if (dct.kind == SymbolKind::ClassType) {
            auto* nts = s.MakeClass_typespec();
            nts->VpiName(dct.name);
            nts->VpiParent(tp);
            if (auto* bcd = classDefnFor(dct))
                nts->Class_defn(bcd);
            else
                pendingClassTsLink.push_back({nts, &dct});
            if (dsyn)
                setLoc(nts, dsyn->sourceRange());
            emitClassTsParams(nts, dct.as<ClassType>(),
                              fn + "." + std::string(dct.name));
            its = nts;
        }
        else {
            its = makeTypespec(mem, dsyn);
            if (its)
                its->VpiParent(tp);
        }
        rt->Actual_typespec(its);
        tp->Typespec(rt);
        params->push_back(tp);
        auto* pa = s.MakeParam_assign();
        pa->VpiParent(cts);
        setLoc(pa, nameSpan(tps.location, tps.name));
        pa->Rhs(tp);
        pas->push_back(pa);
        // Lhs is the class_defn's own formal of the same name.
        bool bound = false;
        if (auto* bcd = classDefnFor(cls); bcd && bcd->Parameters())
            for (auto* p9 : *bcd->Parameters())
                if (p9->VpiName() == tps.name) {
                    pa->Lhs(p9);
                    bound = true;
                    break;
                }
        if (!bound)
            pendingClassTsPa.push_back({pa, &cls, std::string(tps.name)});
    }
    if (params->empty())
        return;
    cts->Parameters(params);
    cts->Param_assigns(pas);
}

// Class-scope typedefs (class_defn vpiTypedef), NAME-ordered: Surelog writes
// the class's DataTypeMap, a std::map keyed by the typedef name, and gives a
// class_defn's typespecs no vpiInstance (UhdmWriter::writeDataTypes).
//
// Two alias shapes are reproduced:
//   * ENUM aliases — the builtin `process::state` shape, behind --builtins.
//   * CLASS-handle aliases (`typedef resource #(T) rsrc_t;`) — a class_typespec
//     NAMED AFTER THE ALIAS but pointing at the TARGET class's class_defn, and
//     located at the target's own name text. The property declared with the
//     alias (`rsrc_t rsrc;`) shares this very object rather than minting a
//     fresh class_typespec named after the class (ClassParamAsParam,
//     ClassTypeParam) — makeTypespec's typedefTs lookup does that for free.
//
//   * ORDINARY data types (`typedef logic [SIZE-1:0] t_vector;`, an unpacked
//     array, a struct) — built exactly like a module's own typedefs, EXCEPT
//     that every dimension bound stays UNFOLDED. A class_defn is emitted once
//     per generic (classDefnFor), so the formals of the specialization slang
//     hands us (SIZE=1) must not leak in: golden holds `operation(SIZE-1)`
//     over a bare ref_obj SIZE. The refs' fullnames chain off the CLASS with
//     `::` (work@C::t_vector::SIZE), the separator Surelog uses inside a class.
//     No vpiInstance on any of them (writeDataTypes skips it for class_defn).
void UhdmExporter::emitClassTypedefs(const ClassType& cls, UHDM::class_defn* cd) {
    buildClassTypedefTs(cls, std::string(cd->VpiName()));
    std::vector<std::pair<std::string, UHDM::typespec*>> ents;
    for (auto& member : cls.members()) {
        if (member.kind != SymbolKind::TypeAlias)
            continue;
        auto& ta = member.as<TypeAliasType>();
        auto itT = typedefTs.find((const Symbol*)&ta);
        if (itT == typedefTs.end())
            continue;
        itT->second->VpiParent(cd);
        ents.emplace_back(std::string(ta.name), itT->second);
    }
    if (ents.empty())
        return;
    std::stable_sort(ents.begin(), ents.end(),
                     [](const auto& a, const auto& b) { return a.first < b.first; });
    auto* tds = s.MakeTypespecVec();
    for (auto& e : ents)
        tds->push_back(e.second);
    cd->Typespecs(tds);
}

// The typespec half of emitClassTypedefs, split out so a reference from a
// class that sorts EARLIER by name can force it (see makeTypespec). Builds
// and REGISTERS each nested typedef's typespec once; the owning class's own
// emitClassTypedefs then reuses the objects, parents them and lists them.
void UhdmExporter::buildClassTypedefTs(const ClassType& cls,
                                       const std::string& clsName) {
    if (!buildingClassTypedefs.insert(&cls).second)
        return;
    struct BctGuard {
        std::set<const void*>& set;
        const void* key;
        ~BctGuard() { set.erase(key); }
    } bctGuard{buildingClassTypedefs, (const void*)&cls};
    for (auto& member : cls.members()) {
        if (member.kind != SymbolKind::TypeAlias)
            continue;
        auto& ta = member.as<TypeAliasType>();
        if (typedefTs.count((const Symbol*)&ta))
            continue;
        auto& ct = ta.targetType.getType().getCanonicalType();
        const syntax::SyntaxNode* typeSyn = nullptr;
        if (auto syn = ta.getSyntax())
            if (syn->kind == syntax::SyntaxKind::TypedefDeclaration)
                typeSyn = syn->as<syntax::TypedefDeclarationSyntax>().type;
        UHDM::typespec* ts = nullptr;
        if (ct.kind == SymbolKind::EnumType && builtins) {
            auto* ets = buildEnumTs(ct.as<EnumType>(), typeSyn, std::string(ta.name));
            if (auto syn = ta.getSyntax())
                setLoc(ets, syn->sourceRange());
            ts = ets;
        }
        else if (ct.kind == SymbolKind::ClassType) {
            auto* cts = s.MakeClass_typespec();
            if (auto* bcd = classDefnFor(ct))
                cts->Class_defn(bcd);
            else
                pendingClassTsLink.push_back({cts, &ct});
            // The span is the target class NAME as written — a parameterized
            // target (`resource #(T)`) contributes only its identifier, the
            // same rule drainPendingExtends applies to an extends clause.
            if (typeSyn) {
                auto r = typeSyn->sourceRange();
                if (auto* nt = typeSyn->as_if<syntax::NamedTypeSyntax>())
                    if (auto* cn = nt->name->as_if<syntax::ClassNameSyntax>())
                        r = cn->identifier.range();
                setLoc(cts, r);
            }
            ts = cts;
        }
        else if (ct.kind == SymbolKind::UnpackedStructType ||
                 ct.kind == SymbolKind::PackedStructType ||
                 ct.kind == SymbolKind::FixedSizeUnpackedArrayType ||
                 ct.kind == SymbolKind::PackedArrayType ||
                 ct.kind == SymbolKind::ScalarType) {
            const std::string aliasFull = clsName + "::" + std::string(ta.name);
            bool savedTf = tfContext, savedTd = typedefTsContext;
            bool savedBy = bypassTypedefShare, savedUf = unfoldedTypedefDims;
            std::string savedPfx = syntaxRefPrefix, savedSep = syntaxRefSep;
            tfContext = true;
            typedefTsContext = true;
            bypassTypedefShare = true;
            unfoldedTypedefDims = true;
            syntaxRefPrefix = aliasFull;
            syntaxRefSep = "::";
            if (ct.kind == SymbolKind::FixedSizeUnpackedArrayType) {
                ts = buildUnpackedArrayTypedefTs(ta, aliasFull);
            }
            else if (ct.kind == SymbolKind::UnpackedStructType ||
                     ct.kind == SymbolKind::PackedStructType) {
                auto* sts =
                    ct.kind == SymbolKind::PackedStructType
                        ? buildStructTs(ct.as<PackedStructType>(), true,
                                        aliasFull, "::")
                        : buildStructTs(ct.as<UnpackedStructType>(), false,
                                        aliasFull, "::");
                if (typeSyn)
                    setLoc(sts, typeSyn->sourceRange());
                ts = sts;
            }
            else {
                ts = makeTypespec(ta, typeSyn);
            }
            syntaxRefSep = savedSep;
            syntaxRefPrefix = savedPfx;
            unfoldedTypedefDims = savedUf;
            bypassTypedefShare = savedBy;
            typedefTsContext = savedTd;
            tfContext = savedTf;
        }
        if (!ts)
            continue;
        ts->VpiName(ta.name);
        // Registering it lets a method's return type / a property share it.
        typedefTs[&ta] = ts;
    }
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
        // Rank buffers by SYNTAX order, not semantic-unit membership: modules
        // are definitions, not compilation-unit members, so a module-only file
        // never appears in unit->members() and would fall to the BufferID
        // fallback — and BufferIDs follow parallel-load completion order,
        // which flips run to run (mriscv_bind_sva design name work@Wrapper vs
        // work@mriscvcore_top_s2qed). Syntax-tree member order is the parsed
        // command-line order and covers every declaration kind.
        size_t seq = 0;
        for (auto& tree : comp.getSyntaxTrees()) {
            if (!tree)
                continue;
            auto& rootNode = tree->root();
            if (rootNode.kind == syntax::SyntaxKind::CompilationUnit) {
                for (auto mem :
                     rootNode.as<syntax::CompilationUnitSyntax>().members) {
                    auto loc = mem->sourceRange().start();
                    if (loc != SourceLocation::NoLocation)
                        bufRank.emplace(loc.buffer(), seq++);
                }
            }
            else {
                auto loc = rootNode.sourceRange().start();
                if (loc != SourceLocation::NoLocation)
                    bufRank.emplace(loc.buffer(), seq++);
            }
        }
        // Semantic units still rank anything syntax missed (e.g. buffers
        // whose only content expanded from directives).
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

    // Surelog applies a -P override under `instance->getParent() == nullptr`,
    // i.e. only to the DEFINITIONS of top-level instances -- and it mutates the
    // definition's own Parameter object, so both the def view and every
    // instance view of that definition see the effect.
    if (!cliParams.empty())
        for (auto* t : root.topInstances)
            cliTopDefs.insert(&t->getDefinition());

    d = s.MakeDesign();
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
    // A file-scope `program` is NOT a design top for Surelog. Measured on a
    // purpose-built golden pair (bare `program p1;` vs `program p1;` +
    // `module m1;`): in BOTH the program appears only in design->AllPrograms
    // as a DEF view (VpiName empty, VpiDefName work@p1) and never in
    // AllModules/TopModules; with no module top besides it the design is
    // `unnamed` with AllModules/TopModules NULL, and with a module top the
    // design is named after the MODULE. slang, by contrast, elaborates an
    // uninstantiated program as a root top instance. So pull program tops out
    // of orderedTops (they still get their AllPrograms def view below) —
    // instantiated programs (OneNetInterf/OneNetModPort/OneNetRange) are not
    // root tops in slang either, so they are untouched by this rule.
    std::vector<const InstanceSymbol*> progTops;
    {
        auto mid = std::stable_partition(
            orderedTops.begin(), orderedTops.end(),
            [](const InstanceSymbol* t) { return !isProgramDef(*t); });
        progTops.assign(mid, orderedTops.end());
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
    // NOTE (design-root family, TopParam): a module whose parameter has NO
    // default (`module top #(parameter param);`) is a design top for Surelog
    // (design `work@top`, TopModules = [top], the child getting an overriding
    // param_assign whose Rhs ref_obj resolves to top's own unset parameter),
    // but slang refuses it both automatically and under an explicit --top
    // ("'top' is not a valid top-level module"), so orderedTops comes back
    // empty and the design falls to `unnamed` with a null TopModules. Not
    // reachable without a slang change; the AllModules def views already match.

    // Surelog attaches the include records before any model content.
    emitIncludeFileInfos();

    // All definitions used anywhere in the design, name-sorted like Surelog's
    // module map.
    std::map<std::string, const InstanceSymbol*> defs;
    std::set<std::string> uninstGenDefNames;
    for (auto inst : orderedTops) {
        auto name = std::string(inst->getDefinition().name);
        if (defs.emplace(name, inst).second)
            collectDefs(inst->body, defs, &uninstGenDefNames);
    }
    // Parsed-but-unreferenced module definitions (an explicit --top prunes
    // them from the root) still get def views — Surelog compiles every parsed
    // module (load_and_derive testflags: ref_mod under -top dut). Only
    // safely-instantiable ones: modules with all params defaulted and no
    // interface ports.
    std::set<const DefinitionSymbol*> unrefDefs;
    auto addDefOnlyModule = [&](const DefinitionSymbol& udef, bool requireNoPorts = false) {
        if (udef.definitionKind != DefinitionKind::Module)
            return;
        if (defs.count(std::string(udef.name)))
            return;
        // Library-unit (-y/-v) modules compile on demand only — an unused
        // one gets NO def view (Surelog).
        if (!udef.sourceLibrary.isDefault ||
            (udef.syntaxTree && udef.syntaxTree->isLibraryUnit))
            return;
        bool allDefaulted = true;
        for (auto& up : udef.parameters)
            if (!up.hasDefault()) {
                allDefaulted = false;
                break;
            }
        if (!allDefaulted)
            return;
        auto& uinst = InstanceSymbol::createDefault(comp, udef);
        // A def harvested from a NON-TAKEN generate branch is admitted only
        // when it is PORTLESS. slang's createDefault instance has no
        // connection syntax, and resolving the port connections of such an
        // instance crashes inside slang for the Earlgrey_0_1 shapes; a
        // portless def (HierPathEval's `module GOOD();`) never reaches that
        // path. Widen only with a corpus test that proves the shape is safe.
        if (requireNoPorts && !uinst.body.getPortList().empty())
            return;
        bool ifacePorted = false;
        for (auto pb : uinst.body.getPortList())
            if (pb->kind == SymbolKind::InterfacePort) {
                ifacePorted = true;
                break;
            }
        if (ifacePorted)
            return;
        if (defs.emplace(std::string(udef.name), &uinst).second) {
            unrefDefs.insert(&udef);
            collectDefs(uinst.body, defs, &uninstGenDefNames);
        }
    };
    for (auto* udefSym : comp.getUnreferencedDefinitions())
        addDefOnlyModule(*udefSym);
    // Modules instantiated ONLY inside a non-taken generate branch: slang never
    // reports them as unreferenced, but Surelog still compiled them, so they
    // carry the same def-view-only entry in AllModules. A def added here can
    // itself hide further non-taken branches, so run to a fixpoint over a
    // snapshot (collectDefs keeps appending to uninstGenDefs).
    //
    // NOTE (design-root family): this closes the design ROOT of HierPathEval
    // and UnsignedParam, both of which then diverge on CONSTANT EVALUATION,
    // not on containers:
    //   * HierPathEval — `.PadType(TargetCfg.dio_pad_type)` where TargetCfg is
    //     a 2-bit packed struct {logic a; pad_type_e dio_pad_type} = 'b10.
    //     slang folds the member select to 0 (first member is the MSB, per
    //     LRM); Surelog folds it to 1. Matching golden means reproducing
    //     Surelog's LSB-first member offset for this fold — do not do it
    //     globally, it would break every converged packed-struct fold.
    //   * UnsignedParam — `localparam signed [63:0] n` gives golden an
    //     int_typespec with vpiSigned:1 that we do not set (a real, separate
    //     gap), and beyond it `n4 == 10376293541461622783` is TRUE for Surelog
    //     (64-bit unsigned) and FALSE for slang (the unsized decimal needs 65
    //     bits as a SIGNED value), so the `GOOD good();` generate branch is
    //     taken in golden's topModules and not in ours. Not reachable without
    //     a slang change.
    std::set<std::string> genDefsDone;
    for (bool changed = true; changed;) {
        changed = false;
        std::vector<std::string> pending(uninstGenDefNames.begin(),
                                         uninstGenDefNames.end());
        for (auto& gname : pending) {
            if (!genDefsDone.insert(gname).second)
                continue;
            changed = true;
            for (auto* sym : comp.getDefinitions())
                if (sym->kind == SymbolKind::Definition && sym->name == gname) {
                    addDefOnlyModule(sym->as<DefinitionSymbol>(),
                                     /*requireNoPorts=*/true);
                    break;
                }
        }
    }
    // Uninstantiated file-scope `program`s: def views only (AllPrograms),
    // filled like an unreferenced def in the write phase; never design tops.
    for (auto* pt : progTops)
        if (defs.emplace(std::string(pt->getDefinition().name), pt).second) {
            unrefDefs.insert(&pt->getDefinition());
            uninstProgDefs.insert(&pt->getDefinition());
            collectDefs(pt->body, defs, &uninstGenDefNames);
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
        // A call BETWEEN package functions (prim_util_pkg::vbits calling
        // prim_util_pkg::_clog2) binds the callee in the ELABORATED (top)
        // package view in BOTH copies — Surelog resolves package calls after
        // it has built the top views, so the def copy's own function object is
        // never the callee. Module-level calls already bind the top view (they
        // are emitted after this point), so the sweep only reaches calls made
        // inside a package. EvalFunc.
        for (auto& pr : s.AllObjects()) {
            if (!pr.first ||
                pr.first->UhdmType() != UHDM::uhdmfunc_call)
                continue;
            auto* fc = (UHDM::func_call*)pr.first;
            auto* callee = fc->Function();
            if (!callee)
                continue;
            const UHDM::instance* home = callee->Instance();
            if (!home)
                continue;
            size_t pi = allP->size();
            for (size_t i = 0; i < allP->size(); i++)
                if ((*allP)[i] == home)
                    pi = i;
            if (pi == allP->size())
                continue;
            auto* tf = (*topP)[pi]->Task_funcs();
            if (!tf)
                continue;
            for (auto* t : *tf)
                if (t->UhdmType() == UHDM::uhdmfunction &&
                    t->VpiName() == callee->VpiName()) {
                    fc->Function((UHDM::function*)t);
                    break;
                }
        }
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
        // A package subroutine that names ANOTHER package's typedef binds the
        // ELABORATED listing object in both views (Surelog) — the def pass
        // could only reach the def object, so re-point now (PackFunc).
        for (auto& [rt9, aliasT9] : pkgForeignTsTopFixups)
            if (auto t9 = pkgTopTypedefTs.find((const void*)aliasT9);
                t9 != pkgTopTypedefTs.end() && t9->second)
                rt9->Actual_typespec(t9->second);
        pkgForeignTsTopFixups.clear();
        // A DEF-view package TYPEDEF listing whose symbolic member bound names
        // ANOTHER package's parameter ([top_pkg::TL_SZW-1:0] inside
        // tlul_pkg::tl_h2d_t) binds the ELABORATED (folded) home parameter —
        // the same rule pkgCrossRefTopFixups applies to def-view cross-package
        // param INITS, here for type ranges. Done structurally because the
        // bound ref is minted by several range-builder arms; the def→top param
        // swap is keyed on the def param object, so only refs that actually
        // reached a FOREIGN package's def listing move (Surelog,
        // PackStructVar). A SAME-package bound is untouched: its def param is
        // not in the foreign map.
        {
            // def parameter object -> (owning def package, elab twin)
            std::map<const UHDM::any*, std::pair<UHDM::package*, UHDM::any*>>
                defParamTwin;
            for (auto* dp0 : *allP) {
                UHDM::package* tp0 = nullptr;
                for (auto* t0 : *topP)
                    if (t0->VpiName() == dp0->VpiName()) {
                        tp0 = t0;
                        break;
                    }
                if (!tp0 || !dp0->Parameters() || !tp0->Parameters())
                    continue;
                for (auto* p0 : *dp0->Parameters())
                    for (auto* p1 : *tp0->Parameters())
                        if (p0->VpiName() == p1->VpiName()) {
                            defParamTwin[p0] = {dp0, p1};
                            break;
                        }
            }
            std::function<void(UHDM::any*, UHDM::package*)> fixExpr =
                [&](UHDM::any* e, UHDM::package* home) {
                    if (!e)
                        return;
                    if (e->UhdmType() == UHDM::uhdmref_obj) {
                        auto* r0 = (UHDM::ref_obj*)e;
                        if (auto* act = r0->Actual_group())
                            if (auto it0 = defParamTwin.find(act);
                                it0 != defParamTwin.end() &&
                                it0->second.first != home)
                                r0->Actual_group(it0->second.second);
                        return;
                    }
                    if (e->UhdmType() == UHDM::uhdmoperation)
                        if (auto* ops = ((UHDM::operation*)e)->Operands())
                            for (auto* o0 : *ops)
                                fixExpr(o0, home);
                };
            auto fixRanges = [&](UHDM::VectorOfrange* rs, UHDM::package* home) {
                if (!rs)
                    return;
                for (auto* r0 : *rs) {
                    fixExpr((UHDM::any*)r0->Left_expr(), home);
                    fixExpr((UHDM::any*)r0->Right_expr(), home);
                }
            };
            std::function<void(UHDM::typespec*, UHDM::package*, int)> fixTs =
                [&](UHDM::typespec* t0, UHDM::package* home, int depth) {
                    if (!t0 || depth > 8)
                        return;
                    switch (t0->UhdmType()) {
                        case UHDM::uhdmlogic_typespec:
                            fixRanges(((UHDM::logic_typespec*)t0)->Ranges(),
                                      home);
                            break;
                        case UHDM::uhdmbit_typespec:
                            fixRanges(((UHDM::bit_typespec*)t0)->Ranges(), home);
                            break;
                        case UHDM::uhdmpacked_array_typespec: {
                            auto* pt0 = (UHDM::packed_array_typespec*)t0;
                            fixRanges(pt0->Ranges(), home);
                            if (pt0->Elem_typespec())
                                fixTs(pt0->Elem_typespec()->Actual_typespec(),
                                      home, depth + 1);
                            break;
                        }
                        case UHDM::uhdmarray_typespec: {
                            auto* at0 = (UHDM::array_typespec*)t0;
                            fixRanges(at0->Ranges(), home);
                            if (at0->Elem_typespec())
                                fixTs(at0->Elem_typespec()->Actual_typespec(),
                                      home, depth + 1);
                            break;
                        }
                        case UHDM::uhdmstruct_typespec:
                            if (auto* ms =
                                    ((UHDM::struct_typespec*)t0)->Members())
                                for (auto* m0 : *ms)
                                    if (m0->Typespec())
                                        fixTs(m0->Typespec()->Actual_typespec(),
                                              home, depth + 1);
                            break;
                        case UHDM::uhdmunion_typespec:
                            if (auto* ms =
                                    ((UHDM::union_typespec*)t0)->Members())
                                for (auto* m0 : *ms)
                                    if (m0->Typespec())
                                        fixTs(m0->Typespec()->Actual_typespec(),
                                              home, depth + 1);
                            break;
                        default:
                            break;
                    }
                };
            for (auto* dp0 : *allP)
                if (dp0->Typespecs())
                    for (auto* t0 : *dp0->Typespecs())
                        fixTs(t0, dp0, 0);
        }
        // NOTE: a pkg consumed by ANOTHER package keeps its DEF listing bound
        // to its OWN typedef objects (rp32 riscv_priv_pkg csr_adr_t.perm ->
        // the home csr_perm_t, riscv_isa_pkg isa_t.spec -> the home
        // isa_spec_t). The importer's clone carries the clone bindings, wired
        // where the clone is built (emitPackage). An earlier revision
        // repointed the DEF listing here instead, which exchanged the two
        // views' member actuals.
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
                // `typedef uvm_config_db#(uvm_object, string) alias;` — the
                // same rule as a class-SCOPE class alias: one class_typespec
                // named after the ALIAS, carrying the specialization, which
                // every declaration of the alias then shares (ClassTypeParam).
                else if (ct.kind == SymbolKind::ClassType) {
                    auto* cts = s.MakeClass_typespec();
                    if (auto* bcd = classDefnFor(ct))
                        cts->Class_defn(bcd);
                    else
                        pendingClassTsLink.push_back({cts, &ct});
                    emitClassTsParams(cts, ct.as<ClassType>(), std::string(ta.name));
                    cts->VpiParent(d);
                    if (typeSyn) {
                        auto r = typeSyn->sourceRange();
                        if (auto* nt = typeSyn->as_if<syntax::NamedTypeSyntax>())
                            if (auto* cn = nt->name->as_if<syntax::ClassNameSyntax>())
                                r = SourceRange(cn->identifier.range().start(), r.end());
                        setLoc(cts, r);
                    }
                    ts = cts;
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
        // A user-defined NETTYPE (`nettype real my_real with my_function2`) is
        // a design-level typespec too: Surelog emits the resolved DATA type
        // under the nettype's name, with vpiInstance = the design and
        // vpiFunction = the resolution function. The function object only
        // exists after the $unit task_func pass below, so the binding is
        // deferred (FileResolutionFunction).
        std::vector<std::pair<UHDM::typespec*, std::string>> nettypeResolvers;
        for (auto unit : comp.getCompilationUnits())
            for (auto& member : unit->members()) {
                if (member.kind != SymbolKind::NetType)
                    continue;
                auto& nt = member.as<NetType>();
                if (nt.isBuiltIn())
                    continue;
                const syntax::SyntaxNode* dtSyn = nullptr;
                if (auto syn = nt.getSyntax())
                    if (syn->kind == syntax::SyntaxKind::NetTypeDeclaration)
                        dtSyn = syn->as<syntax::NetTypeDeclarationSyntax>().type;
                auto* ts = makeTypespec(nt, dtSyn);
                if (!ts)
                    continue;
                ts->VpiName(nt.name);
                ts->VpiParent(d);
                ts->Instance((UHDM::instance*)(UHDM::BaseClass*)d);
                if (dtSyn)
                    setLoc(ts, dtSyn->sourceRange());
                byName[std::string(nt.name)] = ts;
                if (auto* rf = nt.getResolutionFunction())
                    nettypeResolvers.push_back({ts, std::string(rf->name)});
            }
        // A FILE-SCOPE `import pkg::*` puts the package's typedefs into that
        // FileContent's DataTypeMap (CompileHelper::importPackage), and the
        // design's Typespecs are the union of every FileContent's map
        // (UhdmWriter, "Non-Elaborated Model") -- so the SHARED package
        // typespec is listed at the design too, under its unqualified name.
        for (auto unit : comp.getCompilationUnits())
            for (auto& mem : unit->members()) {
                const Symbol* only = nullptr;
                const PackageSymbol* ipkg = nullptr;
                if (mem.kind == SymbolKind::WildcardImport)
                    ipkg = comp.getPackage(
                        mem.as<WildcardImportSymbol>().packageName);
                else if (mem.kind == SymbolKind::ExplicitImport) {
                    only = mem.as<ExplicitImportSymbol>().importedSymbol();
                    if (!only || only->kind != SymbolKind::TypeAlias)
                        continue;
                    ipkg = comp.getPackage(
                        mem.as<ExplicitImportSymbol>().packageName);
                }
                if (!ipkg)
                    continue;
                for (auto& pm : ipkg->members()) {
                    if (pm.kind != SymbolKind::TypeAlias)
                        continue;
                    if (only && &pm != only)
                        continue;
                    auto tit = pkgTopTypedefTs.find((const void*)&pm);
                    if (tit == pkgTopTypedefTs.end() || !tit->second)
                        continue;
                    byName.emplace(std::string(pm.name), tit->second);
                }
            }
        if (!byName.empty()) {
            auto* tds = s.MakeTypespecVec();
            for (auto& [nm, ts] : byName)
                tds->push_back(ts);
            d->Typespecs(tds);
        }

        // $unit (compilation-unit) functions live on the design object.
        for (auto unit : comp.getCompilationUnits())
            emitTaskFuncs(*unit, d, "", nullptr);

        for (auto& [ts, fname] : nettypeResolvers) {
            if (ts->UhdmType() != UHDM::uhdmreal_typespec || !d->Task_funcs())
                continue;
            for (auto* tf : *d->Task_funcs())
                if (tf->UhdmType() == UHDM::uhdmfunction && tf->VpiName() == fname) {
                    ((UHDM::real_typespec*)ts)->Resolution_func((UHDM::function*)tf);
                    break;
                }
        }
    }

    auto* allMods = s.MakeModule_instVec();
    auto* topMods = s.MakeModule_instVec();

    // Pre-create the definition shells so ref_modules can point at them
    // regardless of emission order. Interface defs get interface_inst shells
    // in AllInterfaces, `program` defs get program shells in AllPrograms, and
    // everything else module_inst shells in AllModules.
    auto* allIfaces = s.MakeInterface_instVec();
    auto* allProgs = s.MakeProgramVec();
    for (auto& [name, inst] : defs) {
        if (useInterfacePath(*inst)) {
            auto* iface = s.MakeInterface_inst();
            ifaceDefMap[&inst->getDefinition()] = iface;
            allIfaces->push_back(iface);
        }
        // EVERY `program` def gets the program shell — a file-scope program is
        // never a design top (see the progTops partition in exportDesign), so
        // there is no module_inst fallback left.
        else if (isProgramDef(*inst)) {
            auto* prog = s.MakeProgram();
            defMap[&inst->getDefinition()].mod = prog;
            allProgs->push_back(prog);
        }
        else {
            defMap[&inst->getDefinition()].mod = s.MakeModule_inst();
            allMods->push_back((UHDM::module_inst*)defMap[&inst->getDefinition()].mod);
        }
    }
    // A design with no module definition at all (a lone `program` file, an
    // interface-only file) leaves AllModules NULL in golden, not an empty
    // vector — Surelog's writer only creates the vector when it has a member.
    if (!allMods->empty())
        d->AllModules(allMods);
    if (!allIfaces->empty())
        d->AllInterfaces(allIfaces);
    if (!allProgs->empty())
        d->AllPrograms(allProgs);
    // `primitive ... endprimitive` -> design->AllUdps, name-sorted like
    // Surelog's module map (a UDP is a ModuleDefinition there, routed to
    // AllUdps instead of AllModules by its declaration type).
    emitUdpDefns();

    // Surelog compiles every module's parameters at module-compile time, so
    // all def-view parameter typespecs precede any elaboration typespecs.
    for (auto& [name, inst] : defs) {
        if (useInterfacePath(*inst))
            continue; // simple-interface params handled in emitInterfaceDef
        // -bb_mod/-bb_inst: Surelog returns from CompileModule BEFORE any
        // collectModuleObjects_ pass, so a blackboxed definition never gets
        // parameters either -- the AllModules entry is a bare shell.
        if (blackboxedDef("work@" + name))
            continue;
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
        // A blackboxed def emits its HEADER only (the emitModuleDef /
        // emitInterfaceDef early return); mark the port phase done so neither
        // the instance walk nor the write-phase fallback fills it in later.
        if (blackboxedDef("work@" + name))
            defMap[&inst->getDefinition()].filled = true;
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
            for (auto& mem : unit->members()) {
                if (mem.kind == SymbolKind::ClassType)
                    ents.push_back({&mem.as<ClassType>(), bi});
                // A PARAMETERIZED class declaration (`class resource #(type
                // T=int)`) is a GenericClassDefSymbol in slang, not a
                // ClassType, so it never reached AllClasses. Surelog compiles
                // it once, from its DEFAULT specialization, exactly like the
                // nested-class path above (ClassParamAsParam, ClassTypeParam,
                // VirtualClass).
                // ClassParamAsParam and ClassTypeParam are CMP_EQUAL as of the
                // design-root-class block: this list, plus class-SCOPE class
                // aliases (emitClassTypedefs), the specialization carried on a
                // class_typespec (emitClassTsParams), a $unit class alias as a
                // design typedef, and the `= new` var vpiExpr.
                // VirtualClass still diverges, on THREE independent rules:
                //   (a) class-scope aliases of ordinary data types
                //       (t_vector/t_array/t_struct) must be listed with their
                //       SIZE-dependent ranges kept UNFOLDED (golden holds
                //       operation(SIZE-1); the default specialization folds
                //       SIZE=1 to [0:0]), which emitClassTypedefs skips;
                //   (b) a class-SCOPED type reference (`C#(t_t0,3)::t_vector`)
                //       is an unsupported_typespec named `C::t_vector` in
                //       golden — Surelog does not resolve it;
                //   (c) the vars it types are bare logic_vars with NO typespec
                //       in the top view, and def-view logic_nets pointing at
                //       the unsupported_typespec.
                else if (mem.kind == SymbolKind::GenericClassDef) {
                    auto& gc = mem.as<GenericClassDefSymbol>();
                    if (auto* dsp = gc.getDefaultSpecialization(*unit);
                        dsp && dsp->kind == SymbolKind::ClassType)
                        ents.push_back({&dsp->as<ClassType>(), bi});
                }
            }
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
        // isTop always yields a module_inst (see emitInstance): design->
        // TopModules has no program variant.
        topMods->push_back((UHDM::module_inst*)emitInstance(*inst, prefix, nullptr, nullptr,
                                                            nullptr, /*isTop=*/true));
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

    // A foreach_stmt's iterated-array ref binds the array's OWN array_typespec.
    // Surelog resolves the name against the module in declaration-object order,
    // so an instance-view array_var's typespec wins over the port's — and only
    // an array whose leaf is a NET (no array_var) falls back to the port's.
    // Both are minted after the statement, hence the deferred bind.
    for (auto& pf : pendingForeachArrayTs) {
        if (pf.rt->Actual_typespec())
            continue;
        UHDM::typespec* act = nullptr;
        if (auto ait = arrayVarArrayTs.find(pf.sym); ait != arrayVarArrayTs.end())
            act = ait->second;
        if (!act && pf.mod && instGetPorts(pf.mod))
            for (auto* pt : *instGetPorts(pf.mod))
                if (pt->VpiName() == pf.sym->name && pt->Typespec() &&
                    pt->Typespec()->Actual_typespec() &&
                    pt->Typespec()->Actual_typespec()->UhdmType() ==
                        UHDM::uhdmarray_typespec)
                    act = pt->Typespec()->Actual_typespec();
        pf.rt->Actual_typespec(act ? act : s.MakeArray_typespec());
    }
    pendingForeachArrayTs.clear();

    // $signed/$unsigned result typespecs: share the LHS port's actual typespec
    // (no tail duplicate); fall back to a fresh one for non-port LHSs.
    for (auto& p : pendingSysFuncTs) {
        UHDM::typespec* act = nullptr;
        if (p.mod && instGetPorts(p.mod))
            for (auto* pt : *instGetPorts(p.mod))
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

    // Package-function return-value locals are normally drained from
    // emitTopPorts; a design with NO module never reaches that call and the
    // `f = ...` body refs would stay unbound (PackFunc is packages only).
    // Already-processed entries carry no refs, so this is a no-op otherwise.
    drainFuncRet(/*pkgOnly=*/true);

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
    // --disable-feature=parametersubstitution: a substituted ref_obj borrows
    // the hopped parameter's typespec, which the deferred param-typespec pass
    // may only have filled in after the ref was built.
    for (auto& [dst, src] : noSubstRefTs)
        if (!dst->Actual_typespec() && src->Actual_typespec())
            dst->Actual_typespec(src->Actual_typespec());
    noSubstRefTs.clear();
    // Base-class wiring last: every class_defn (package, module-local,
    // file-level, nested) now exists, so a base in any scope resolves.
    drainPendingExtends();
    // EvalFunc member-assignment leftovers: stamp AFTER every typespec is
    // materialized (the struct ts a parameter points at is filled by the
    // deferred drain above) and only on the ELABORATED views.
    stampEvalFuncLeftovers(d);
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

// ---------------------------------------------------------------- UDP defns
//
// Surelog compiles a `primitive ... endprimitive` into a ModuleDefinition
// whose declaration type is paUdp_declaration; UhdmWriter routes those to
// design->AllUdps instead of AllModules (CompileModule::collectUdpObjects_
// builds the udp_defn itself).  The compare surface is narrow: udp_defn
// compares DefName/VpiSize/VpiProtected/VpiPrimType/Attributes/Io_decls/
// Table_entrys/Initial; table_entry compares only VpiSize (its "? 1 : 1"
// string is NOT compared); io_decl compares Direction/Name/Expr; attribute
// compares only VpiName.  `initial::Compare` does not even recurse into its
// statement — the body is emitted for dump fidelity only.
//
// Shapes taken from the Udp golden:
//   * udp_defn VpiDefName is the QUALIFIED name ("work@udp_body"), spanning
//     the `primitive` keyword through `endprimitive` (NOT the leading
//     attribute group, which slang folds into the declaration's range).
//   * one io_decl per HEADER port, in header order, anchored at the header
//     name token, with vpiExpr = a logic_net anchored at the body
//     declaration (`output a;` / `input b,c;` — both input nets carry the
//     whole declaration's span and share its attribute objects).
//   * VpiSize on a table_entry is the number of INPUT fields, where a
//     parenthesised edge `(01)` counts as one and every other character
//     counts as one (so it always equals ports-1).
void UhdmExporter::emitUdpDefns() {
    std::vector<const PrimitiveSymbol*> prims;
    // getDefinitions() is already name-sorted, matching Surelog's module map.
    for (auto* sym : comp.getDefinitions()) {
        if (sym->kind != SymbolKind::Primitive)
            continue;
        auto& ps = sym->as<PrimitiveSymbol>();
        // Built-in gate types live in slang's gateMap, never in the definition
        // map, so only source-declared UDPs reach here; the guard documents
        // the invariant (Surelog skips definitions with no file contents).
        if (ps.primitiveKind != PrimitiveSymbol::UserDefined || !ps.getSyntax())
            continue;
        prims.push_back(&ps);
    }
    if (prims.empty())
        return;
    auto* udps = s.MakeUdp_defnVec();
    for (auto* ps : prims)
        udps->push_back(buildUdpDefn(*ps));
    d->AllUdps(udps);
}

UHDM::udp_defn* UhdmExporter::buildUdpDefn(const PrimitiveSymbol& prim) {
    auto* defn = s.MakeUdp_defn();
    udpDefnMap[&prim] = defn;
    std::string qname = "work@" + std::string(prim.name);
    defn->VpiParent(d);
    defn->VpiDefName(qname);

    const syntax::UdpDeclarationSyntax* us = nullptr;
    if (auto* syn = prim.getSyntax();
        syn && syn->kind == syntax::SyntaxKind::UdpDeclaration)
        us = &syn->as<syntax::UdpDeclarationSyntax>();
    if (us)
        setLoc(defn, SourceRange(us->primitive.location(),
                                 us->endprimitive.range().end()));

    // Attribute objects are shared between the declaration group's members
    // (Surelog compiles the group once and hands the same vector out), so a
    // net-level `(* clk = "foo" *) input clk, d;` gives clk and d the same
    // attribute object — exactly as the golden prints it.
    auto buildAttrs = [&](std::span<const AttributeSymbol* const> attrs,
                          UHDM::BaseClass* parent) -> UHDM::VectorOfattribute* {
        if (attrs.empty())
            return nullptr;
        auto* av = s.MakeAttributeVec();
        for (auto* a : attrs) {
            auto* asyn = a->getSyntax();
            UHDM::attribute* ua = nullptr;
            if (auto sit = sharedAttrObjs.find((const void*)asyn);
                asyn && sit != sharedAttrObjs.end()) {
                ua = sit->second;
            }
            else {
                ua = s.MakeAttribute();
                if (asyn) {
                    sharedAttrObjs[(const void*)asyn] = ua;
                    setLoc(ua, asyn->sourceRange());
                }
                ua->VpiName(a->name);
                // Only a direct STRING clause is spelled out; the value is not
                // part of attribute::Compare, so anything else is left unset.
                if (asyn && asyn->kind == syntax::SyntaxKind::AttributeSpec)
                    if (auto* vc = asyn->as<syntax::AttributeSpecSyntax>().value;
                        vc && vc->expr->kind ==
                                  syntax::SyntaxKind::StringLiteralExpression) {
                        std::string raw = rawText(vc->expr->sourceRange());
                        if (raw.size() >= 2 && raw.front() == '"' &&
                            raw.back() == '"')
                            raw = raw.substr(1, raw.size() - 2);
                        ua->VpiValue("STRING:" + raw);
                    }
            }
            ua->VpiParent(parent); // last writer, like Surelog's shared vectors
            av->push_back(ua);
        }
        return av;
    };

    if (auto* av = buildAttrs(comp.getAttributes(prim), defn))
        defn->Attributes(av);

    // Header port-name spans (non-ANSI): slang moves PrimitivePortSymbol
    // ::location onto the BODY declaration, so the header token has to come
    // from the syntax.
    std::map<std::string_view, SourceRange> hdrLoc;
    if (us && us->portList->kind == syntax::SyntaxKind::NonAnsiUdpPortList)
        for (auto* p : us->portList->as<syntax::NonAnsiUdpPortListSyntax>().ports)
            hdrLoc.emplace(p->identifier.valueText(), p->identifier.range());

    if (!prim.ports.empty()) {
        auto* ios = s.MakeIo_declVec();
        for (auto* port : prim.ports) {
            auto* io = s.MakeIo_decl();
            io->VpiParent(defn);
            io->VpiName(port->name);
            io->VpiDirection(port->direction == PrimitivePortDirection::In
                                 ? vpiInput
                                 : vpiOutput);
            if (auto hit = hdrLoc.find(port->name); hit != hdrLoc.end())
                setLoc(io, hit->second);
            else
                setLocNamed(io, *port);
            auto* net = s.MakeLogic_net();
            net->VpiParent(defn);
            net->VpiName(port->name);
            net->VpiFullName(qname + "." + std::string(port->name));
            // The net is born at the BODY declaration; an input name syntax
            // is one entry of `input b,c;`, so walk up to the declaration.
            if (auto* psyn = port->getSyntax()) {
                const syntax::SyntaxNode* dsyn = psyn;
                for (auto* p = psyn; p; p = p->parent)
                    if (p->kind == syntax::SyntaxKind::UdpInputPortDecl ||
                        p->kind == syntax::SyntaxKind::UdpOutputPortDecl) {
                        dsyn = p;
                        break;
                    }
                setLoc(net, dsyn->sourceRange());
            }
            if (auto* av = buildAttrs(comp.getAttributes(*port), net))
                net->Attributes(av);
            io->Expr(net);
            ios->push_back(io);
        }
        defn->Io_decls(ios);
    }

    if (!prim.table.empty()) {
        auto* tes = s.MakeTable_entryVec();
        // Row spans come from the syntax; slang drops a row it diagnosed, so
        // only a 1:1 count lets the two lists be zipped.
        const syntax::UdpEntrySyntax* const* esyn = nullptr;
        if (us && us->body->entries.size() == prim.table.size())
            esyn = us->body->entries.begin();
        size_t ri = 0;
        for (auto& row : prim.table) {
            auto* te = s.MakeTable_entry();
            te->VpiParent(defn);
            int32_t nfields = 0;
            std::string val = "STRING:";
            for (size_t i = 0; i < row.inputs.size(); i++) {
                if (row.inputs[i] == '(') {
                    // `(01)` — Surelog writes the two edge chars unseparated.
                    for (i++; i < row.inputs.size() && row.inputs[i] != ')'; i++)
                        val += row.inputs[i];
                    val += ' ';
                }
                else {
                    val += row.inputs[i];
                    val += ' ';
                }
                nfields++;
            }
            val += ": ";
            if (row.state) {
                val += row.state;
                val += " : ";
            }
            // A sequential row's output keeps a trailing space; a `-` (no
            // change) and every combinational output do not.
            if (row.state && row.output != '-') {
                val += row.output;
                val += ' ';
            }
            else
                val += row.output;
            te->VpiValue(val);
            te->VpiSize(nfields);
            if (esyn && !esyn[ri]->inputs.empty())
                setLoc(te, esyn[ri]->inputs.sourceRange());
            tes->push_back(te);
            ri++;
        }
        defn->Table_entrys(tes);
    }

    // `initial q = 0;` inside the primitive. Only the object's existence is
    // compared, but the body is written out the way Surelog writes it.
    if (prim.initVal && us && us->body->initialStmt) {
        auto& is = *us->body->initialStmt;
        auto* init = s.MakeInitial();
        init->VpiParent(defn);
        setLoc(init, is.sourceRange());
        auto* asg = s.MakeAssignment();
        asg->VpiParent(init);
        setLoc(asg, is.sourceRange());
        init->Stmt(asg);
        auto* ref = s.MakeRef_obj();
        ref->VpiParent(asg);
        ref->VpiName(is.name.valueText());
        ref->VpiFullName(qname + "." + std::string(is.name.valueText()));
        setLoc(ref, is.name.range());
        asg->Lhs(ref);
        auto* c = s.MakeConstant();
        c->VpiParent(asg);
        std::string dec = rawText(is.value->sourceRange());
        c->VpiValue("UINT:" + dec);
        c->VpiDecompile(dec);
        c->VpiSize(64);
        c->VpiConstType(vpiUIntConst);
        setLoc(c, is.value->sourceRange());
        asg->Rhs(c);
        defn->Initial(init);
    }
    return defn;
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
