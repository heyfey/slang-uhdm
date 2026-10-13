// r11u225 (pass 225, the module/type ground: tools/probe/r11u225repro/README.md):
// every law reads its own R11U225_<LAW>_OFF switch; R11U225_OFF drops all of
// them (the base's bytes).  R11U225_TRACE=<dir> names every firing: one file
// per process, `<dir>/<pid>.225`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
} // namespace slang_uhdm
#include <utility>
#include <vector>
namespace slang_uhdm {
// § initHierFillKept225 — the declared signals whose packed range carries a
// substituted struct-member path (§ initHierAtRefToken225's site records them,
// ModuleEmit's unbased-fill fold reads them): (declaring scope, name).  Empty
// (no heap block) until the substitution fires, so a design it never reaches
// allocates nothing here (§ formalRegNoHeap223v's lesson: an allocation during
// emission moves later objects' addresses, and § refFullNameThroughNamedExpr175
// registers names in address order).
inline std::vector<std::pair<const void*, std::string>>& initHierOwners225() {
    static std::vector<std::pair<const void*, std::string>> v;
    return v;
}
inline bool initHierOwner225(const void* sc, std::string_view n) {
    for (auto& e : initHierOwners225())
        if (e.first == sc && e.second == n)
            return true;
    return false;
}
} // namespace slang_uhdm
namespace slang_uhdm {
// § fillSymbolicRootOnly225v (v11u225, the adversarial verification of r11u225):
// the refinements' switches.  R11V225_OFF drops every one of them.
} // namespace slang_uhdm
