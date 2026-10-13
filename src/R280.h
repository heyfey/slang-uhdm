// r11u280 (pass 280, the expression/parameter ground,
// tools/probe/r11u280repro/README.md): every law reads its own
// R11U280_<LAW>_OFF switch; R11U280_OFF drops all of them,
// restoring the base's bytes.
// R11U280_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.280`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm

// § hpMemVarSelNamesFinal280: ExprEmit's design-final drain, called at the
// end of ParamEmit's drainShareDefParamTs.
namespace slang_uhdm {
void hpMemVarSelNamesDrain280();
}  // namespace slang_uhdm
