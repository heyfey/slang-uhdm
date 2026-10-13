// r11u227 (pass 227, the expression/parameter ground,
// tools/probe/r11u227repro/README.md): every law reads its own
// R11U227_<LAW>_OFF switch; R11U227_OFF drops all of them,
// restoring the base's bytes.
// R11U227_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.227`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u227 (the adversarial verification of pass 227,
// tools/probe/v11u227repro/README.md): every refinement reads its own
// R11V227_<LAW>_OFF switch (fixOn(227, ...)); R11V227_OFF drops all of them (the
// pass's laws as delivered); R11U227_OFF drops the pass and with it every
// refinement. The R11U227_SPLIT*A_OFF switches are read bare (envSet).
// § landingSwitchReach227 — the ground-A half of a cross-ground whole-pass
// switch (R11U227_SPLIT<N>A_OFF); R11U227_OFF does NOT read it, the old
// whole-pass switches keep their meaning.
} // namespace slang_uhdm
