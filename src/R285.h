// r11u285 (pass 285, the module/type ground,
// tools/probe/r11u285repro/README.md): every law reads its own
// R11U285_<LAW>_OFF switch; R11U285_OFF drops all of them,
// restoring the base's bytes.
//   R11U285_CLSIMPTDSHARE_OFF § clsImpCopyTdBindsContainerListing285 (ModuleEmit.cpp)
//   R11U285_IMPHPNAME_OFF     § impCopyInitHierPathMemberName285   (ModuleEmit.cpp)
//   R11U285_CLONEMEMBNAME_OFF § cloneOwnAggMemberChainName285   (UhdmExporter.cpp)
//   R11U285_CLONEMEMBTYPE_OFF § cloneMembTdOwnCopy285           (UhdmExporter.cpp)
// R11U285_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.285`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
