// r11u307 (pass 307, the module/type ground,
// tools/probe/r11u307repro/README.md): every law reads its own
// R11U307_<LAW>_OFF switch; R11U307_OFF drops all of them,
// restoring the base's bytes.
//   R11U307_NESTREPDEF_OFF      § nestedDefSecondBodyReadsRep307 (ModuleEmit.cpp)
//   R11U307_DEEPSTUB_OFF        § nestedDeepInstStub307 (ModuleEmit.cpp)
//   R11U307_POSUDP_OFF          § nestedPosInstUdp307 (ModuleEmit.cpp)
//   R11U307_DEFGENUDP_OFF       § defGenUdpFormNoStmt307 (ModuleEmit.cpp)
//   R11U307_DEFGENORD_OFF       § defGenOrderedConnPorts307 (ModuleEmit.cpp)
//   R11U307_GENMODARR_OFF       § genScopeModArrayElems307 (ModuleEmit.cpp)
// v11u307 (the adversarial verification of r11u307,
// tools/probe/v11u307repro/README.md): three refinements inside the laws,
// each behind its own R11V307_<X>_OFF switch; R11V307_OFF drops all three,
// giving the law's bytes.
//   R11V307_SHADOW_OFF          § nestShadowFileScopeResolves307v (ModuleEmit.cpp)
//   R11V307_STUBOPND_OFF        § deepStubOperandLeafRule307v (ModuleEmit.cpp)
//   R11V307_STUBIFPORT_OFF      § deepStubIfacePortActual307v (ModuleEmit.cpp)
// R11U307_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.307`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
