// r11u278 (pass 278, the expression/parameter ground,
// tools/probe/r11u278repro/README.md): every law reads its own
// R11U278_<LAW>_OFF switch; R11U278_OFF drops all of them,
// restoring the base's bytes.
// R11U278_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.278`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm

// v11u278 (adversarial verification of r11u278): the verifier's refinements
// read their own R11V278_<FIX>_OFF switch; R11V278_OFF drops all of them
// (giving the r11u278 law's bytes) and R11U278_OFF still drops everything.
namespace slang_uhdm {
}  // namespace slang_uhdm
