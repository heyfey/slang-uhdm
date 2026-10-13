// r11u232 (pass 232, the expression/parameter ground,
// tools/probe/r11u232repro/README.md): every law reads its own
// R11U232_<LAW>_OFF switch; R11U232_OFF drops all of them,
// restoring the base's bytes.
// R11U232_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.232`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u232 (the adversarial verification, tools/probe/v11u232repro/README.md):
// each refinement reads its own R11V232_<NAME>_OFF switch; R11V232_OFF drops
// all of them (R11U232_OFF drops them too, with the laws they refine).
} // namespace slang_uhdm
