// r11u268 (pass 268, the expression/parameter ground,
// tools/probe/r11u268repro/README.md): every law reads its own
// R11U268_<LAW>_OFF switch; R11U268_OFF drops all of them,
// restoring the base's bytes.
// R11U268_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.268`, its first line `OUT <-o path>`, then `<law> <detail>`
// (an abstention reads `<law> abstain <detail>`).
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <set>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u268 (the adversarial verification of r11u268): every fix reads its
// own R11V268_<FIX>_OFF switch; R11V268_OFF drops the fixes (the law's
// bytes); R11U268_OFF still drops the laws and the fixes together.
// the trace is on: callers build their detail strings only then (no heap
// traffic while the design is emitted when it is off)
}  // namespace slang_uhdm
