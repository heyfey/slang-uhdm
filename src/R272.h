// r11u272 (pass 272, the expression/parameter ground,
// tools/probe/r11u272repro/README.md): every law reads its own
// R11U272_<LAW>_OFF switch; R11U272_OFF drops all of them,
// restoring the base's bytes.
// R11U272_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.272`, its first line `OUT <-o path>`, then `<law> <detail>`
// (an abstention reads `<law> abstain <detail>`).
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <set>
#include <string>
#include <unistd.h>

namespace UHDM {
class ref_typespec;
class BaseClass;
}
namespace slang::ast {
class Symbol;
class Expression;
}

namespace slang_uhdm {
// the trace is on: callers build their detail strings only then (no heap
// traffic while the design is emitted when it is off)
}  // namespace slang_uhdm

namespace slang_uhdm {
// § leftoverTsCopyPerElabUse272 — the record: the elaborated param_assigns
// whose value is the parameter's default written as a bare or
// package-qualified parameter name (ParamEmit emitParameters).
void lotsValueCopyRec272(const UHDM::BaseClass* pa);
bool lotsValueCopy272(const UHDM::BaseClass* pa);
}  // namespace slang_uhdm
