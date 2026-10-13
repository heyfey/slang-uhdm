// r11u274 (pass 274, the expression/parameter ground,
// tools/probe/r11u274repro/README.md): every law reads its own
// R11U274_<LAW>_OFF switch; R11U274_OFF drops all of them,
// restoring the base's bytes.
// R11U274_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.274`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u274 (the adversarial verification of pass 274,
// tools/probe/v11u274repro/README.md): each refinement reads its own
// R11V274_<NAME>_OFF switch; R11V274_OFF drops the refinements (the
// implementer's law bytes), R11U274_OFF still drops everything.
}  // namespace slang_uhdm
