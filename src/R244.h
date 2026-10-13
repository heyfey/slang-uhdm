// r11u244 (pass 244, the expression/parameter ground,
// tools/probe/r11u244repro/README.md): every law reads its own
// R11U244_<LAW>_OFF switch; R11U244_OFF drops all of them,
// restoring the base's bytes.
// R11U244_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.244`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u244 (the adversarial verification of r11u244,
// tools/probe/v11u244repro/README.md): each refinement reads its own
// R11V244_<FIX>_OFF switch; R11V244_OFF drops all of them (the
// implementer's bytes); R11U244_OFF still drops every law with them.
}  // namespace slang_uhdm
