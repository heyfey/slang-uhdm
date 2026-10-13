// r11u262 (pass 262, the expression/parameter ground,
// tools/probe/r11u262repro/README.md): every law reads its own
// R11U262_<LAW>_OFF switch; R11U262_OFF drops all of them,
// restoring the base's bytes.
// R11U262_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.262`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
