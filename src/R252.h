// r11u252 (pass 252, the expression/parameter ground,
// tools/probe/r11u252repro/README.md): every law reads its own
// R11U252_<LAW>_OFF switch; R11U252_OFF drops all of them,
// restoring the base's bytes.
// R11U252_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.252`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u252 (the adversarial verification of r11u252,
// tools/probe/v11u252repro/README.md): each refinement reads its own
// R11V252_<FIX>_OFF switch; R11V252_OFF drops all of them (the law's bytes);
// R11U252_OFF still drops the laws and the refinements together.
}  // namespace slang_uhdm
