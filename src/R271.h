// r11u271 (pass 271, the module/type ground,
// tools/probe/r11u271repro/README.md): every law reads its own
// R11U271_<LAW>_OFF switch; R11U271_OFF drops all of them,
// restoring the base's bytes.
// R11U271_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.271`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// The verifier's refinements (v11u271, tools/probe/v11u271repro/README.md):
// each reads its own R11V271_<FIX>_OFF; R11V271_OFF drops all of them
// (the law's bytes); R11U271_OFF drops them too (pristine's bytes).
}  // namespace slang_uhdm

