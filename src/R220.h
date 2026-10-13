// r11u220 (pass 220, the expression/parameter ground,
// tools/probe/r11u220repro/README.md): every law reads its own
// R11U220_<LAW>_OFF switch; R11U220_OFF drops all of them and the landed
// r11u218 laws (src/R218.h), restoring the base's bytes.
// R11U220_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.220`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
