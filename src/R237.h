// r11u237 (pass 237, the module/type ground,
// tools/probe/r11u237repro/README.md): every law reads its own
// R11U237_<LAW>_OFF switch; R11U237_OFF drops all of them (the base's bytes).
// R11U237_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.237`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u237 (the adversarial verification of r11u237,
// tools/probe/v11u237repro/README.md): every refinement reads its own
// R11V237_<LAW>_OFF switch; R11V237_OFF drops all of them (r11u237's bytes).
// R11U237_OFF drops these refinements too (the base's bytes on every case,
// pass 235's enum-base laws included).  Firings are logged through tr237 (R11U237_TRACE).
} // namespace slang_uhdm
