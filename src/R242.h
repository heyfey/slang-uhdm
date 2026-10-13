// r11u242 (pass 242, the expression/parameter ground,
// tools/probe/r11u242repro/README.md): every law reads its own
// R11U242_<LAW>_OFF switch; R11U242_OFF drops all of them,
// restoring the base's bytes.
// R11U242_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.242`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
