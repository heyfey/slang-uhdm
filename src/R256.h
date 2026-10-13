// r11u256 (pass 256, the expression/parameter ground,
// tools/probe/r11u256repro/README.md): every law reads its own
// R11U256_<LAW>_OFF switch; R11U256_OFF drops all of them,
// restoring the base's bytes.
// R11U256_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.256`, its first line `OUT <-o path>`, then `<law> <detail>`.
// The verifier's refinement (tools/probe/v11u256repro/README.md) reads its own
// R11V256_<FIX>_OFF switch; R11V256_OFF drops it, restoring the law's bytes.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
