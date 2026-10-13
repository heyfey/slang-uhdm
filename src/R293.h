// r11u293 (pass 293, the module/type ground,
// tools/probe/r11u293repro/README.md): every law reads its own
// R11U293_<LAW>_OFF switch; R11U293_OFF drops all of them,
// restoring the base's bytes.
//   R11U293_CLONERETSEL_OFF   § cloneRetNameSelRefBindsHomeReturn293 (ModuleEmit.cpp)
//   R11U293_CLSARRDIMEND_OFF  § defNetClassArrTsDimEnd293 (ModuleEmit.cpp)
//   R11U293_HOISTELEMSPAN_OFF § pkgHoistArrNetElemDimSpan293 (ModuleEmit.cpp)
//   R11U293_IFFIRSTREF_OFF    § ifaceFirstSignalBindsRefs293 (ModuleEmit.cpp)
//   R11U293_IFLOWFIRST_OFF    § ifaceLowConnFirstSignal293 (ModuleEmit.cpp)
//   R11U293_PVNDAPARENT_OFF   § portViewNdaNetCellParent293 (ModuleEmit.cpp)
// v11u293 (adversarial verification of r11u293, tools/probe/v11u293repro):
// the verifier's refinement reads r11v293On: R11V293_OFF drops it (the law's
// bytes), R11U293_OFF still drops everything (pristine's bytes).
//   R11V293_PVTSUNSTORED_OFF  § pvNdaTsNameUnstored293v (ModuleEmit.cpp)
// R11U293_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.293`, its first line `OUT <-o path>`, then `<law> <detail>`.
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
