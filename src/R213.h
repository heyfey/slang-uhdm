// r11u213 (the second adversarial verification of passes 206 and 207,
// tools/probe/r11u213verify/README.md): every refinement reads its own
// R11V213_<LAW>_OFF switch; R11V213_OFF drops all of them (the verified base's
// bytes).  R11V213_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.213`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
