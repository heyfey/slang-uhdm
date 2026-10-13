// r11u208 (the second adversarial verification of passes 201 and 202,
// tools/probe/r11u208verify/README.md): every refinement reads its own
// R11V208_<LAW>_OFF switch; R11V208_OFF drops all of them (the verified base's
// bytes).  R11V208_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.208`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
