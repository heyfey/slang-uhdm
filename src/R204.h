// r11u204 (the second adversarial verification of passes 196 and 198,
// tools/probe/r11u204verify/README.md): every refinement reads its own
// R11V204_<LAW>_OFF switch; R11V204_OFF drops all of them (the verified base's
// bytes).  R11V204_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.204`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
