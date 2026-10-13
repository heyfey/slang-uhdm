// r11u295 (pass 295, the module/type ground,
// tools/probe/r11u295repro/README.md): every law reads its own
// R11U295_<LAW>_OFF switch; R11U295_OFF drops all of them,
// restoring the base's bytes.
//   R11U295_ESCNAMESPAN_OFF   § escNameSpanSites295 (ModuleEmit.cpp, UhdmExporter.cpp)
//   R11U295_RAWEND_OFF        § rawEndLineModel295 (ModuleEmit.cpp)
//   R11U295_NESTARRNAME_OFF   § nestedModArrayScopedName295 (ModuleEmit.cpp)
//   R11U295_DYNMEMSPAN_OFF    § dynAssocMemberSpanToDim295 (TypeEmit.cpp)
// v11u295 (the adversarial verification of r11u295,
// tools/probe/v11u295repro/README.md): each refinement reads its own
// R11V295_<X>_OFF switch; R11V295_OFF drops all of them (the law's bytes),
// and R11U295_OFF still drops every law and refinement (pristine's bytes).
//   R11V295_NESTSHADOW_OFF    § nestArrShadowTopKeepsBare295v (ModuleEmit.cpp)
// R11U295_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.295`, its first line `OUT <-o path>`, then `<law> <detail>`.
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
