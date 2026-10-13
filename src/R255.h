// r11u255 (pass 255, the module/type ground,
// tools/probe/r11u255repro/README.md): every law reads its own
// R11U255_<LAW>_OFF switch; R11U255_OFF drops all of them,
// restoring the base's bytes.
// R11U255_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.255`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <unordered_set>
#include <utility>
#include <vector>

namespace slang_uhdm {
// § fwWinnerListedObject255's record: every object § bareTdNameFirstWriterWins98
// handed out (fwWinnerTs98) with the winning TypeAliasType symbol, in emission
// order; drained design-final in UhdmExporter.
inline std::vector<std::pair<void*, const void*>>& r255Fw98() {
    static std::vector<std::pair<void*, const void*>> v;
    return v;
}
}  // namespace slang_uhdm
