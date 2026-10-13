// r11u279 (pass 279, the module/type ground,
// tools/probe/r11u279repro/README.md): every law reads its own
// R11U279_<LAW>_OFF switch; R11U279_OFF drops all of them,
// restoring the base's bytes.
//   R11U279_SPCAVAL_OFF      § structParamCaReadsPaValue279        (ModuleEmit.cpp)
//   R11U279_TOPPKGTDELEM_OFF § topPkgMemberTdOfNamedElemShares279  (TypeEmit.cpp)
//   R11U279_CLSTDPATH_OFF    § clsTdMemberContainerPath279         (UhdmExporter.cpp)
//   R11U279_CLSTDQUAL_OFF    § clsTdScopedTargetQualSpan279        (UhdmExporter.cpp)
//   R11U279_EXTQUALSPAN_OFF  § extendsScopedBaseNameSpan279        (UhdmExporter.cpp)
//   R11U279_INLSTRUCTKW_OFF  § inlineStructPortVarKwSpan279        (TypeEmit.cpp)
// R11U279_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.279`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
