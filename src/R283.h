// r11u283 (pass 283, the module/type ground,
// tools/probe/r11u283repro/README.md): every law reads its own
// R11U283_<LAW>_OFF switch; R11U283_OFF drops all of them,
// restoring the base's bytes.
//   R11U283_PROGLAST_OFF     § progDefKeepsLastInstProcs283       (ModuleEmit.cpp)
//   R11U283_PROGGENDUP_OFF   § progGenDupFirstSpan283             (ModuleEmit.cpp)
//   R11U283_DEFGENCOMMA_OFF  § defGenCaCommaListSpan283           (ModuleEmit.cpp)
//   R11U283_IFPROCFIRST_OFF  § ifaceInstFirstProcsShared283       (ModuleEmit.cpp)
//   R11U283_IFVIEWNOPROC_OFF § ifacePortViewNoProcs283            (ModuleEmit.cpp)
//   R11U283_BINDDISP_OFF     § bindChildDisplayScopedNames283     (ModuleEmit.cpp)
//   R11U283_SCOPEDRET_OFF    § scopedClassRetQualSpan283          (TaskFuncEmit.cpp)
// The verifier's refinement (v11u283, tools/probe/v11u283repro/README.md) reads
// r11v283On: R11V283_OFF gives the law's bytes, R11U283_OFF still pristine's.
//   R11V283_SRCORDER_OFF     § progLastInstSrcOrder283v           (ModuleEmit.cpp)
// R11U283_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.283`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
