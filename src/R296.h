// r11u296 (pass 296, the expression/parameter ground,
// tools/probe/r11u296repro/README.md): every law reads its own
// R11U296_<LAW>_OFF switch; R11U296_OFF drops all of them,
// restoring the base's bytes.
// R11U296_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.296`, its first line `OUT <-o path>`, then
// `<law> <detail>` (a tag ending in _ABSTAIN moves nothing).
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
