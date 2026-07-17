//------------------------------------------------------------------------------
//! @file UhdmExporter.cpp
//! @brief Exporter core: design assembly, locations, raw text
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include "EmitHelpers.h"

namespace slang_uhdm {

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

    // All definitions used anywhere in the design, name-sorted like Surelog's
    // module map.
    std::map<std::string, const InstanceSymbol*> defs;
    for (auto inst : root.topInstances) {
        auto name = std::string(inst->getDefinition().name);
        if (defs.emplace(name, inst).second)
            collectDefs(inst->body, defs);
    }

    // User packages (skip built-ins).
    std::vector<const PackageSymbol*> pkgs;
    for (auto pkg : comp.getPackages()) {
        if (pkg->name != "std" && pkg->name != "$unit")
            pkgs.push_back(pkg);
    }
    if (!pkgs.empty()) {
        auto* allP = s.MakePackageVec();
        for (auto pkg : pkgs)
            allP->push_back(emitPackage(*pkg, false));
        d->AllPackages(allP);
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

    // Surelog compiles every module's parameters at module-compile time, so
    // all def-view parameter typespecs precede any elaboration typespecs.
    for (auto& [name, inst] : defs) {
        DefInfo& info = defMap[&inst->getDefinition()];
        emitParameters(inst->body, info.mod, "work@" + name, info.nets, /*topView=*/false,
                       &info, false);
    }

    for (auto inst : root.topInstances) {
        std::string prefix = "work@" + std::string(inst->getDefinition().name);
        topMods->push_back(emitInstance(*inst, prefix, nullptr, nullptr, nullptr, /*isTop=*/true));
    }
    // Write phase: every top's ports + deferred typespecs, after all tops'
    // netlist elaboration (Surelog arena order).
    for (auto& tp : topPendings)
        emitTopPorts(tp);
    topPendings.clear();
    pendingParamTs.clear();
    pendingNetTs.clear();
    d->TopModules(topMods);

    if (!pkgs.empty()) {
        auto* topP = s.MakePackageVec();
        for (auto pkg : pkgs)
            topP->push_back(emitPackage(*pkg, true));
        d->TopPackages(topP);
    }

    s.MakeUhdmHandle(UHDM::uhdmdesign, d);
    return d;
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
