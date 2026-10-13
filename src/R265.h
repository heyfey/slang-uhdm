// r11u265 (pass 265, the module/type ground,
// tools/probe/r11u265repro/README.md): every law reads its own
// R11U265_<LAW>_OFF switch; R11U265_OFF drops all of them,
// restoring the base's bytes.
// R11U265_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.265`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm

