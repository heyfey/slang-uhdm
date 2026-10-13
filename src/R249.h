// r11u249 (pass 249, the module/type ground,
// tools/probe/r11u249repro/README.md): every law reads its own
// R11U249_<LAW>_OFF switch; R11U249_OFF drops all of them,
// restoring the base's bytes.
// R11U249_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.249`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// § unitDynArrTd249 / § modDynArrTd249 — set by a typedef writer around its
// buildUnpackedArrayTypedefTs call to ask the builder's dynamic-container
// branch for the kind-marker range (defined in TypeEmit.cpp).
extern bool g249DynRangeReq;
}  // namespace slang_uhdm
namespace slang::ast {
class TypeAliasType;
}
namespace slang_uhdm {
// The one-dimension dynamic / queue / associative typedef shapes the two
// writers list (TypeEmit.cpp).
bool unitDynTdShape249(const slang::ast::TypeAliasType& ta);
}  // namespace slang_uhdm
