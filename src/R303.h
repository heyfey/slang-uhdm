// r11u303 (pass 303, the module/type ground,
// tools/probe/r11u303repro/README.md): every law reads its own
// R11U303_<LAW>_OFF switch; R11U303_OFF drops all of them,
// restoring the base's bytes.
//   R11U303_SELBASETRIM_OFF     § genConnSelBaseNameTrim303 (ModuleEmit.cpp)
//   R11U303_BOUNDSYSCLONE_OFF   § bodyTdBoundSysCallClone303 (TypeEmit.cpp)
//   R11U303_SYSARGNAME_OFF      § sysCallArgRefScopedName303 (TypeEmit.cpp)
//   R11U303_MODARRSELNAME_OFF   § modArrBoundSelUnstored303 (ModuleEmit.cpp)
//   R11U303_MODARRIPSSPAN_OFF   § modArrBoundIpsWholeSpan303 (ModuleEmit.cpp)
//   R11U303_GENCAENUMSPAN_OFF   § genCaEnumQualWholeSpan303 (TypeEmit.cpp)
//   R11U303_GENNDASEL_OFF       § genNdaSelRhsSharesNet303 (ModuleEmit.cpp)
//   R11U303_GENNDAOP_OFF        § genNdaOpRhsFreshNet303 (ModuleEmit.cpp)
//   R11U303_CLSPARAMTD_OFF      § classParamNamedTypeTs303 (UhdmExporter.cpp)
//   R11U303_IFTERNFILL_OFF      § ifCaTernFillArmKept303 (ModuleEmit.cpp)
// The verifier's refinements (v11u303, tools/probe/v11u303repro/README.md) read
// R11V303_<X>_OFF; R11V303_OFF drops all of them and gives the law's bytes:
//   R11V303_ENUMSELQUAL_OFF     § genCaEnumSelBoundLhsQual303v (TypeEmit.cpp)
//   R11V303_NDASELCONST_OFF     § genNdaSelConstReduces303v (ModuleEmit.cpp)
//   R11V303_IFFILLIDX_OFF       § ifFillBitSelConstIdx303v (ModuleEmit.cpp)
// R11U303_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.303`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
