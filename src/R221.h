// r11u221 (the second adversarial verification of passes 216 and 215,
// tools/probe/r11u221verify/README.md): every refinement reads its own
// R11V221_<LAW>_OFF switch; R11V221_OFF drops all of them (the verified base's
// bytes).  R11V221_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.221`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
