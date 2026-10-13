// r11u305 (pass 305, the module/type ground,
// tools/probe/r11u305repro/README.md): every law reads its own
// R11U305_<LAW>_OFF switch; R11U305_OFF drops all of them,
// restoring the base's bytes.
//   R11U305_UDPMPPATH_OFF       § udpPosModportPathAtSel305 (ModuleEmit.cpp)
//   R11U305_IFUNSIZED_OFF       § ifCaUnsizedRhsClonePerInst305 (ModuleEmit.cpp)
//   R11U305_IFSPLITFILL_OFF     § ifTernFillSplitPerInst305 (ModuleEmit.cpp)
//   R11U305_WIRESCOPEDEND_OFF   § wireScopedTdEndAtType305 (ModuleEmit.cpp)
//   R11U305_PVHDRPORTDECL_OFF   § pvHdrPortDeclNetFirst305 (ModuleEmit.cpp)
//   R11U305_PVBODYFIRSTNDA_OFF  § pvHdrBodyFirstNdaCell305 (ModuleEmit.cpp)
//   R11U305_PVPORTLOC_OFF       § pvHdrPortAtPortDecl305 (ModuleEmit.cpp)
//   R11U305_IFPLAINLHS_OFF      § ifCaPlainLhsNoVarBind305 (ModuleEmit.cpp)
//   R11U305_SCOPEDTDMEM_OFF     § scopedSimpleTdMemberBindsListing305 (TypeEmit.cpp)
// v11u305 (the adversarial verification, tools/probe/v11u305repro/README.md):
// four refinements, each droppable alone through R11V305_<X>_OFF;
// R11V305_OFF drops all four (giving the law's bytes), R11U305_OFF still
// gives pristine's.
//   R11V305_WIREPKG_OFF  § wireScopedTdPkgOnly305v (ModuleEmit.cpp)
//   R11V305_IFCALL_OFF   § ifUnsizedUserCallAbstains305v (ModuleEmit.cpp)
//   R11V305_TDCOPY_OFF   § scopedTdMemberCopyAbstains305v (TypeEmit.cpp)
//   R11V305_UDPBIND_OFF  § udpMpPathBindAbstains305v (ModuleEmit.cpp)
// R11U305_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.305`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
