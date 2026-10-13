// r11u229 (the second adversarial verification of passes 224, 225 and r11u226,
// tools/probe/r11u229verify/README.md): every refinement reads its own
// R11V229_<LAW>_OFF switch; R11V229_OFF drops all of them (the verified base's
// bytes).  R11V229_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.229`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
