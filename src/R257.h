// r11u257 (pass 257, the module/type ground,
// tools/probe/r11u257repro/README.md): every law reads its own
// R11U257_<LAW>_OFF switch; R11U257_OFF drops all of them,
// restoring the base's bytes.
// R11U257_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.257`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u257 (the adversarial verifier of r11u257,
// tools/probe/v11u257repro/README.md): every refinement reads its own
// R11V257_<FIX>_OFF switch; R11V257_OFF drops them all (the law's bytes),
// R11U257_OFF drops the law and its refinements (the base's bytes).
}  // namespace slang_uhdm
