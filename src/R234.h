// r11u234 (the decode of map 15's thirteen nine-row UVM clusters,
// tools/probe/r11u234dec/README.md): every law reads its own
// R11U234_<LAW>_OFF switch; R11U234_OFF drops all of them (the base's bytes).
// R11U234_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.234`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
