// r11u254 (pass 254, the expression/parameter ground,
// tools/probe/r11u254repro/README.md): every law reads its own
// R11U254_<LAW>_OFF switch; R11U254_OFF drops all of them,
// restoring the base's bytes.
// R11U254_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.254`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
