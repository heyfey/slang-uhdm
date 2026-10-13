// r11u240 (pass 240, the expression/parameter ground,
// tools/probe/r11u240repro/README.md): every law reads its own
// R11U240_<LAW>_OFF switch; R11U240_OFF drops all of them,
// restoring the base's bytes.
// R11U240_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.240`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
