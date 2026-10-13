// r11u226 (the second adversarial verification of passes 219, 220 and 223,
// tools/probe/r11u226verify/README.md): every refinement reads its own
// R11V226_<LAW>_OFF switch; R11V226_OFF drops all of them (the verified base's
// bytes).  A refinement of a landed law is also dropped by that law's landing
// switch (R11U223_OFF for § tfArgScalarTdExportOwnTd226v).
// R11V226_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.226`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
