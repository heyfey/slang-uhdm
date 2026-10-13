// r11u243 (pass 243, the module/type ground,
// tools/probe/r11u243repro/README.md): every law reads its own
// R11U243_<LAW>_OFF switch; R11U243_OFF drops all of them,
// restoring the base's bytes.
// v11u243 (tools/probe/v11u243repro/README.md) adds two refinements, each
// behind its own R11V243_<FIX>_OFF switch (R11V243_OFF drops both):
// § thisNetHomeListedOnly243v (R11V243_THISHOME_OFF, TypeEmit) and
// § unitImpPaRhsActualFinal243v (R11V243_UNITRHSACT_OFF, UhdmExporter).
// R11U243_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.243`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
