// r11u276 (pass 276, the expression/parameter ground,
// tools/probe/r11u276repro/README.md): every law reads its own
// R11U276_<LAW>_OFF switch; R11U276_OFF drops all of them,
// restoring the base's bytes.
// R11U276_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.276`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u276 (the adversarial verification of r11u276, tools/probe/v11u276repro/README.md):
// each refinement reads its own R11V276_<FIX>_OFF switch; R11V276_OFF drops all of them
// (giving the r11u276 law's bytes), and R11U276_OFF still drops the laws together with
// their refinements (pristine's bytes).
}  // namespace slang_uhdm
