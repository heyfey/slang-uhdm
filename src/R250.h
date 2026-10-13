// r11u250 (pass 250, the expression/parameter ground,
// tools/probe/r11u250repro/README.md): every law reads its own
// R11U250_<LAW>_OFF switch; R11U250_OFF drops all of them,
// restoring the base's bytes.
// R11U250_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.250`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u250 (adversarial verification of r11u250): every fix reads its own
// R11V250_<FIX>_OFF switch; R11V250_OFF drops all of them (R11U250_OFF still
// restores the base's bytes: each fix lives inside a law's branch).
}  // namespace slang_uhdm
