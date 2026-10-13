// r11u217 (the second adversarial verification of passes 209, 210 and 212,
// tools/probe/r11u217verify/README.md): every refinement reads its own
// R11V217_<LAW>_OFF switch; R11V217_OFF drops all of them (the verified base's
// bytes).  R11V217_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.217`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
