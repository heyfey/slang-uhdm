// r11u277 (pass 277, the module/type ground,
// tools/probe/r11u277repro/README.md): every law reads its own
// R11U277_<LAW>_OFF switch; R11U277_OFF drops all of them,
// restoring the base's bytes.
// R11U277_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.277`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
