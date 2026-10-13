// r11u297 (pass 297, the module/type ground,
// tools/probe/r11u297repro/README.md): every law reads its own
// R11U297_<LAW>_OFF switch; R11U297_OFF drops all of them,
// restoring the base's bytes.
//   R11U297_VARINITTSEND_OFF  § varDeclInitMovesSharedTsEnd297 (ModuleEmit.cpp)
//   R11U297_VARINITSPAN_OFF   § varDeclInitElabSpan297 (ModuleEmit.cpp)
//   R11U297_NESTNOSHELL_OFF   § nestedDefPortsNeedShell297 (ModuleEmit.cpp)
// v11u297 (the adversarial verification of r11u297,
// tools/probe/v11u297repro/README.md): each refinement reads its own
// R11V297_<X>_OFF switch; R11V297_OFF drops all of them (the law's bytes),
// and R11U297_OFF still drops every law and refinement (pristine's bytes).
//   (none yet)
// R11U297_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.297`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>

namespace slang_uhdm {
} // namespace slang_uhdm
