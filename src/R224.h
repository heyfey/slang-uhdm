// r11u224 (pass 224, the expression/parameter ground,
// tools/probe/r11u224repro/README.md): every law reads its own
// R11U224_<LAW>_OFF switch; R11U224_OFF drops all of them,
// restoring the base's bytes.
// R11U224_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.224`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
