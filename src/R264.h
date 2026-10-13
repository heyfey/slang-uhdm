// r11u264 (pass 264, the expression/parameter ground,
// tools/probe/r11u264repro/README.md): every law reads its own
// R11U264_<LAW>_OFF switch; R11U264_OFF drops all of them,
// restoring the base's bytes.
// R11U264_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.264`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u264 (the adversarial verification, tools/probe/v11u264repro/README.md):
// each refinement reads its own R11V264_<FIX>_OFF switch; R11V264_OFF drops
// all of them, giving the law's bytes; R11U264_OFF still gives pristine.
}  // namespace slang_uhdm
