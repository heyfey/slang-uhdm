// r11u281 (pass 281, the module/type ground,
// tools/probe/r11u281repro/README.md): every law reads its own
// R11U281_<LAW>_OFF switch; R11U281_OFF drops all of them,
// restoring the base's bytes.
//   R11U281_TPPATNEST_OFF    § defNetTpPatNestedSig281             (UhdmExporter.cpp)
//   R11U281_TPREBINDSPAN_OFF § tpRebindSpanDiffers281              (UhdmExporter.cpp)
//   R11U281_TPPORTSPAN_OFF   § tpElabPortRebindSpanDiffers281      (UhdmExporter.cpp)
//   R11U281_IFTPSHARE_OFF    § ifaceInstTypeParamSharesDef281      (UhdmExporter.cpp)
//   R11U281_IFTPUSE_OFF      § ifaceTpUseBindsDefDefault281        (UhdmExporter.cpp)
// R11U281_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.281`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u281 (adversarial verification of r11u281, tools/probe/v11u281repro/README.md):
// R11V281_OFF drops every refinement (the law's bytes); each reads its own switch.
//   R11V281_PATNAMED_OFF  § tpPatNestNamedChain281v  (UhdmExporter.cpp)
//   R11V281_MULTIDECL_OFF § ifTpUseMultiDeclShared281v (UhdmExporter.cpp)
} // namespace slang_uhdm
