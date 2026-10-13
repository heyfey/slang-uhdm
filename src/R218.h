// r11u218 (the ground-A decode of the r11u214 hand-offs and map 13,
// tools/probe/r11u218dec/README.md): every law reads its own
// R11U218_<LAW>_OFF switch; R11U218_OFF drops all of them (the base's bytes).
// Landed by pass r11u220 (tools/probe/r11u220repro/README.md): R11U220_OFF,
// the landing pass's switch for all of its laws, drops these too.
// R11U218_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.218`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
