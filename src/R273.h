// r11u273 (pass 273, the module/type ground,
// tools/probe/r11u273repro/README.md): every law reads its own
// R11U273_<LAW>_OFF switch; R11U273_OFF drops all of them,
// restoring the base's bytes.
// R11U273_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.273`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u273 (adversarial verification of r11u273): every refinement reads its own
// R11V273_<FIX>_OFF switch; R11V273_OFF drops all of them, giving the
// implementer's law bytes (R11U273_OFF still gives the base's bytes).
}  // namespace slang_uhdm
