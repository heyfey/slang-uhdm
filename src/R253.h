// r11u253 (pass 253, the module/type ground,
// tools/probe/r11u253repro/README.md): every law reads its own
// R11U253_<LAW>_OFF switch; R11U253_OFF drops all of them,
// restoring the base's bytes.
// R11U253_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.253`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <unordered_set>

namespace slang_uhdm {
}  // namespace slang_uhdm
