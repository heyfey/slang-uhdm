// r11u263 (pass 263, the module/type ground,
// tools/probe/r11u263repro/README.md): every law reads its own
// R11U263_<LAW>_OFF switch; R11U263_OFF drops all of them,
// restoring the base's bytes.
// R11U263_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.263`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm

// v11u263 (adversarial verification of r11u263,
// tools/probe/v11u263repro/README.md): every refinement reads its own
// R11V263_<FIX>_OFF switch; R11V263_OFF drops all of them (the law's bytes);
// R11U263_OFF still restores the base's bytes.
namespace slang_uhdm {
}  // namespace slang_uhdm
