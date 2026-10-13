// r11u282 (pass 282, the expression/parameter ground,
// tools/probe/r11u282repro/README.md): every law reads its own
// R11U282_<LAW>_OFF switch; R11U282_OFF drops all of them,
// restoring the base's bytes.
// R11U282_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.282`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u282 (the adversarial verification of r11u282,
// tools/probe/v11u282repro/README.md): a refinement reads its own
// R11V282_<X>_OFF switch; R11V282_OFF drops every refinement (the law's
// bytes), R11U282_OFF still drops the law with it (pristine's bytes).
}  // namespace slang_uhdm

// ExprEmit's design-final drain of the generate-scope fold names, called at
// the end of ParamEmit's drainShareDefParamTs (after pass 280's).
namespace UHDM { class Serializer; }
namespace slang_uhdm {
void foldTsNameFinalDrain282(UHDM::Serializer& s);
}  // namespace slang_uhdm
