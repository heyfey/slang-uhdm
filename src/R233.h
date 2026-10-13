// r11u233 (the second adversarial verification of passes 227 and 228,
// tools/probe/r11u233verify/README.md): every refinement reads its own
// R11V233_<LAW>_OFF switch; R11V233_OFF drops all of them (the verified base's
// bytes).  R11V233_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.233`, its first line `OUT <-o path>`, then `<law> <detail>`.
// The trace allocates only when R11V233_TRACE is set.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
