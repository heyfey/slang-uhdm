// r11u246 (pass 246, the expression/parameter ground,
// tools/probe/r11u246repro/README.md): every law reads its own
// R11U246_<LAW>_OFF switch; R11U246_OFF drops all of them,
// restoring the base's bytes.
// R11U246_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.246`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u246 (the adversarial verification): each fix reads its own
// R11V246_<FIX>_OFF; R11V246_OFF drops every fix (the law's bytes).
}  // namespace slang_uhdm
