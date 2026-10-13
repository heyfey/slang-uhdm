// r11u261 (pass 261, the module/type ground,
// tools/probe/r11u261repro/README.md): every law reads its own
// R11U261_<LAW>_OFF switch; R11U261_OFF drops all of them,
// restoring the base's bytes.
// R11U261_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.261`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u261 (the adversarial verification of r11u261,
// tools/probe/v11u261repro/README.md): each refinement reads its own
// R11V261_<FIX>_OFF switch; R11V261_OFF drops all of them (the law's bytes),
// and R11U261_OFF still drops the whole pass (pristine bytes).
}  // namespace slang_uhdm
