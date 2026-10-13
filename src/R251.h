// r11u251 (pass 251, the module/type ground,
// tools/probe/r11u251repro/README.md): every law reads its own
// R11U251_<LAW>_OFF switch; R11U251_OFF drops all of them,
// restoring the base's bytes.
// R11U251_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.251`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <unordered_set>

namespace slang_uhdm {
// § regTdArrElabIsNet251 — the elaborated array_vars ModuleEmit placed among
// the nets (the design-final $unit typedef pass leaves their typespec
// unfolded: the net branch reads the typedef's own typespec).
extern std::unordered_set<const void*> g251RegNetVars;
}  // namespace slang_uhdm
