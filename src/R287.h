// r11u287 (pass 287, the module/type ground,
// tools/probe/r11u287repro/README.md): every law reads its own
// R11U287_<LAW>_OFF switch; R11U287_OFF drops all of them,
// restoring the base's bytes.
//   R11U287_IFARRINTTS_OFF   § ifArrPortSizeIntTsUnlocated287 (ModuleEmit.cpp)
//   R11U287_DEFGENSELNAME_OFF § defGenSelRefChainName287 (UhdmExporter.cpp)
//   R11U287_PVRECVBODYTS_OFF  § pvRecvBodyParamTs287          (ModuleEmit.cpp)
//   R11U287_PVFLATTS_OFF      § pvPatFlattenTsUnparented287  (ModuleEmit.cpp)
//   R11U287_GENCASHARE_OFF    § genCaStructParamSharesPaOperand287 (ModuleEmit.cpp)
//   R11U287_EVALKEEP_OFF      § evalFuncUnreducedOperandKeepsCall287 (ModuleEmit.cpp)
//   R11U287_LOOPONCE_OFF      § evalFuncLoopBodyRunsOnce287 (ModuleEmit.cpp, inside the law above)
// v11u287 (the adversarial verification) reads r11v287On (R11V287_OFF drops
// its refinements; R11U287_OFF still drops everything):
//   R11V287_EVALOPSCOPE_OFF   § evalFuncKeepOwnParamAddCmp287v (ModuleEmit.cpp, inside
//                             § evalFuncUnreducedOperandKeepsCall287's M / P read)
// R11U287_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.287`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>

namespace slang_uhdm {
// § pvRecvBodyParamTs287: (the constant's ref_typespec, the receiver's
// ParameterSymbol), bound design-final to that parameter's elaborated typespec.
inline std::vector<std::pair<void*, const void*>>& pvRecvTs287() {
    static std::vector<std::pair<void*, const void*>> v;
    return v;
}
// § pvPatFlattenTsUnparented287: the port-view pattern operations'
// ref_typespecs, unparented and unnamed design-final.
inline std::vector<const void*>& pvFlatTs287() {
    static std::vector<const void*> v;
    return v;
}
} // namespace slang_uhdm
