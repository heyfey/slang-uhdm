//------------------------------------------------------------------------------
//! @file uhdm_main.cpp
//! @brief slang-uhdm: export a SystemVerilog design as a UHDM database
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "BuiltinSv.h"
#include "UhdmExporter.h"

#include <cstdio>
#include <filesystem>
#include <uhdm/ElaboratorListener.h>
#include <uhdm/UhdmAdjuster.h>
#include <uhdm/uhdm.h>

#include "slang/ast/Compilation.h"
#include "slang/driver/Driver.h"
#include "slang/syntax/SyntaxTree.h"
#include "slang/util/VersionInfo.h"

using namespace slang;
using namespace slang::driver;

int main(int argc, char** argv) {
    Driver driver;
    driver.addStandardArgs();

    std::optional<bool> showHelp;
    std::optional<bool> showVersion;
    std::optional<std::string> outputFile;
    driver.cmdLine.add("-h,--help", showHelp, "Display available options");
    driver.cmdLine.add("--version", showVersion, "Display version information and exit");
    driver.cmdLine.add("-o,--output", outputFile, "Output UHDM database file", "<file>");

    std::optional<bool> elabUhdm;
    driver.cmdLine.add("--elabuhdm", elabUhdm,
                       "Forces UHDM/VPI full elaboration; default is the folded model");

    std::optional<bool> builtins;
    driver.cmdLine.add("--builtins", builtins,
                       "Adds the SystemVerilog builtin package and builtin.sv classes, "
                       "mirroring Surelog run WITHOUT -nobuiltin");

    if (!driver.parseCommandLine(argc, argv))
        return 1;

    if (showHelp == true) {
        printf("%s\n",
               driver.cmdLine.getHelpText("slang-uhdm: SystemVerilog to UHDM exporter").c_str());
        return 0;
    }

    if (showVersion == true) {
        printf("slang-uhdm using slang version %s\n", VersionInfo::getVersionString().c_str());
        return 0;
    }

    if (!driver.processOptions())
        return 2;

    bool ok = driver.parseAllSources();

    // Surelog (unless given -nobuiltin) parses an embedded builtin.sv as a fake
    // file in the CURRENT WORKING DIRECTORY; the UHDM class spans reference that
    // path. Feed slang the same text under the same reported path so the parser
    // yields identical line:column information.
    std::string builtinPath;
    if (builtins == true) {
        builtinPath = (std::filesystem::current_path() / "builtin.sv").string();
        auto buffer = driver.sourceManager.assignText(builtinPath, slang_uhdm::kBuiltinSvText);
        auto tree = syntax::SyntaxTree::fromBuffer(buffer, driver.sourceManager,
                                                   driver.createParseOptionBag());
        driver.syntaxTrees.push_back(tree);
    }

    auto compilation = driver.createCompilation();
    driver.reportCompilation(*compilation, /* quiet */ true);
    ok &= driver.reportDiagnostics(/* quiet */ true);
    if (!ok)
        return 3;

    UHDM::Serializer serializer;
    // Kept off so stale compile artifacts (e.g. abandoned pattern
    // first-compiles) survive into the database, as they do in the reference
    // shape. Surelog's own default is GC ON (CommandLineParser m_gc(true)), but
    // GC makes no measurable difference to its output and no corpus test passes
    // -gc/-nogc, so this is a difference in reason rather than in result.
    serializer.SetGCEnabled(false);
    slang_uhdm::UhdmExporter exporter(*compilation, serializer);
    if (builtins == true)
        exporter.enableBuiltins(builtinPath);
    UHDM::design* design = exporter.exportDesign();

    if (elabUhdm == true) {
        // Mirrors Surelog UhdmWriter.cpp: UHDM elaborates its own model, then
        // UhdmAdjuster rewrites the elaborated tree. uniquifyTypespec(false) is
        // Surelog's non-default choice (the listener defaults it to true).
        std::vector<vpiHandle> designs{
            reinterpret_cast<vpiHandle>(new uhdm_handle(UHDM::uhdmdesign, design))};

        UHDM::ElaboratorContext elaboratorContext(&serializer, false, false);
        elaboratorContext.m_elaborator.uniquifyTypespec(false);
        elaboratorContext.m_elaborator.listenDesigns(designs);

        UHDM::UhdmAdjuster adjuster(&serializer, design);
        adjuster.listenDesigns(designs);
    }

    serializer.Save(outputFile.value_or("slang.uhdm"));

    if (!exporter.unsupported().empty()) {
        fprintf(stderr, "slang-uhdm: unsupported constructs encountered:\n");
        for (auto& u : exporter.unsupported())
            fprintf(stderr, "  %s\n", u.c_str());
        return 4;
    }
    return 0;
}
