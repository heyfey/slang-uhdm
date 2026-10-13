// r11u260 (pass 260, the expression/parameter ground,
// tools/probe/r11u260repro/README.md): every law reads its own
// R11U260_<LAW>_OFF switch; R11U260_OFF drops all of them,
// restoring the base's bytes.
// R11U260_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.260`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
