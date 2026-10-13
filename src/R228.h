// r11u228 (pass 228, the module/type ground: tools/probe/r11u228repro/README.md):
// every law reads its own R11U228_<LAW>_OFF switch; R11U228_OFF drops all of
// them (the base's bytes).  R11U228_TRACE=<dir> names every firing: one file
// per process, `<dir>/<pid>.228`, its first line `OUT <-o path>`, then
// `<law> <detail>`.  The trace allocates only when R11U228_TRACE is set.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm

// v11u228 (the adversarial verification of r11u228,
// tools/probe/v11u228repro/README.md): the refinements read their own
// R11V228_<LAW>_OFF switches; R11V228_OFF drops them all (r11u228's bytes).
// Their firings trace to the same R11U228_TRACE file, law names ending `228v`.
namespace slang_uhdm {
inline void trv228(const char* law, const std::string& detail = std::string()) {
    lawTrace(228, law, detail);
}
} // namespace slang_uhdm
