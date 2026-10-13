// r11u247 (pass 247, the module/type ground,
// tools/probe/r11u247repro/README.md): every law reads its own
// R11U247_<LAW>_OFF switch; R11U247_OFF drops all of them,
// restoring the base's bytes.
// R11U247_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.247`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
