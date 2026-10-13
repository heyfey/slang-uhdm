// r11u241 (pass 241, the module/type ground,
// tools/probe/r11u241repro/README.md): every law reads its own
// R11U241_<LAW>_OFF switch; R11U241_OFF drops all of them (the base's bytes).
// R11U241_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.241`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
