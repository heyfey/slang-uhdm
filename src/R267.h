// r11u267 (pass 267, the module/type ground,
// tools/probe/r11u267repro/README.md): every law reads its own
// R11U267_<LAW>_OFF switch; R11U267_OFF drops all of them,
// restoring the base's bytes.
// R11U267_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.267`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u267 (adversarial verification of r11u267,
// tools/probe/v11u267repro/README.md): the verifier's refinements read their own
// R11V267_<FIX>_OFF switch; R11V267_OFF drops all of them (the law's bytes),
// and R11U267_OFF still restores the base's bytes.
}  // namespace slang_uhdm

