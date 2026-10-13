// r11u236 (pass 236, the expression/parameter ground,
// tools/probe/r11u236repro/README.md): every law reads its own
// R11U236_<LAW>_OFF switch; R11U236_OFF drops all of them,
// restoring the base's bytes.
// R11U236_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.236`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <map>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// v11u236 (the adversarial verification, tools/probe/v11u236repro/README.md):
// each refinement reads its own R11V236_<X>_OFF; R11V236_OFF (or R11U236_OFF)
// drops all of them.
// § pkgDefPatSubstShared236 (ExprEmit pkgPatSubstValue arm, ParamEmit
// emitParameters): set while the declaring package's definition listing
// (AllPackages, not topView, not an import) emits a parameter's initializer;
// the map holds the one copy per substituted source object.
inline bool& pkgDefPatShare236() {
    static bool on = false;
    return on;
}
// § pkgDefPatHomeOnly236v (v11u236): the declaring package's scope (slang
// Scope*) while pkgDefPatShare236() is set; a read shares only when every
// parameter it names is declared in this scope.
inline const void*& pkgDefPatShareScope236() {
    static const void* sc = nullptr;
    return sc;
}
inline std::map<const void*, void*>& pkgDefPatShareMemo236() {
    static std::map<const void*, void*> m;
    return m;
}
} // namespace slang_uhdm
