// r11u269 (pass 269, the module/type ground,
// tools/probe/r11u269repro/README.md): every law reads its own
// R11U269_<LAW>_OFF switch; R11U269_OFF drops all of them,
// restoring the base's bytes.
// R11U269_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.269`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// § retTopRangeOwnPkg269: the elaborated package object whose subroutine's
// per-reference return-name local ModuleEmit drainFuncRet is compiling (null
// everywhere else); TypeEmit's package-parameter range binding reads it.
inline const void* retTopPkg269 = nullptr;
// v11u269 (the adversarial verification of r11u269,
// tools/probe/v11u269repro/README.md): every refinement reads its own
// R11V269_<FIX>_OFF switch; R11V269_OFF drops all of them (the law's bytes),
// R11U269_OFF still drops the laws and the refinements together (pristine).
}  // namespace slang_uhdm

