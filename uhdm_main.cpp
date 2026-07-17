//------------------------------------------------------------------------------
//! @file uhdm_main.cpp
//! @brief slang-uhdm: export a SystemVerilog design as a UHDM database
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#include "UhdmExporter.h"

#include <cstdio>
#include <uhdm/uhdm.h>

#include "slang/ast/Compilation.h"
#include "slang/driver/Driver.h"
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
    auto compilation = driver.createCompilation();
    driver.reportCompilation(*compilation, /* quiet */ true);
    ok &= driver.reportDiagnostics(/* quiet */ true);
    if (!ok)
        return 3;

    UHDM::Serializer serializer;
    slang_uhdm::UhdmExporter exporter(*compilation, serializer);
    exporter.exportDesign();
    serializer.Save(outputFile.value_or("slang.uhdm"));

    if (!exporter.unsupported().empty()) {
        fprintf(stderr, "slang-uhdm: unsupported constructs encountered:\n");
        for (auto& u : exporter.unsupported())
            fprintf(stderr, "  %s\n", u.c_str());
        return 4;
    }
    return 0;
}
