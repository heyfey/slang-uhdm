// r11u259 (pass 259, the module/type ground,
// tools/probe/r11u259repro/README.md): every law reads its own
// R11U259_<LAW>_OFF switch; R11U259_OFF drops all of them,
// restoring the base's bytes.
// R11U259_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.259`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
