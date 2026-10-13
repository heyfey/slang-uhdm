// r11u275 (pass 275, the module/type ground,
// tools/probe/r11u275repro/README.md): every law reads its own
// R11U275_<LAW>_OFF switch; R11U275_OFF drops all of them,
// restoring the base's bytes.
// R11U275_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.275`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u275 (the adversarial verification of r11u275,
// tools/probe/v11u275repro/README.md): each refinement reads its own
// R11V275_<FIX>_OFF switch; R11V275_OFF drops all of them, giving the
// law's bytes (R11U275_OFF still gives the base's).
// § defNetTpPatKeepsActual275v (UhdmExporter.cpp): after the ElaboratorListener.
void defNetTpPatKeepActual275v();
}  // namespace slang_uhdm
