// r11u239 (pass 239, the module/type ground,
// tools/probe/r11u239repro/README.md): every law reads its own
// R11U239_<LAW>_OFF switch; R11U239_OFF drops all of them (the base's bytes).
// R11U239_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.239`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u239 (the adversarial verification of r11u239,
// tools/probe/v11u239repro/README.md): every refinement reads its own
// R11V239_<LAW>_OFF switch; R11V239_OFF drops all of them (r11u239's bytes).
// R11U239_OFF drops these refinements too (the base's bytes on every case).
// Firings are logged through tr239 (R11U239_TRACE).
} // namespace slang_uhdm
