// r11u245 (pass 245, the module/type ground,
// tools/probe/r11u245repro/README.md): every law reads its own
// R11U245_<LAW>_OFF switch; R11U245_OFF drops all of them,
// restoring the base's bytes.
// R11U245_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.245`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u245 (adversarial verification of r11u245,
// tools/probe/v11u245repro/README.md): each refinement reads its own
// R11V245_<FIX>_OFF switch; R11V245_OFF drops all of them (R11U245_OFF and
// R11U245_UNITLAWS_OFF drop them too: they live inside § unitTdLawS245).
}  // namespace slang_uhdm
