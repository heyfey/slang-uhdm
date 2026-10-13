// r11u266 (pass 266, the expression/parameter ground,
// tools/probe/r11u266repro/README.md): every law reads its own
// R11U266_<LAW>_OFF switch; R11U266_OFF drops all of them,
// restoring the base's bytes.
// R11U266_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.266`, its first line `OUT <-o path>`, then `<law> <detail>`
// (an abstention reads `<law> abstain <detail>`).
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <set>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// § sgnLitElabFreshIntTs266: the parameters the law marked (ParamEmit), read
// back at the generate-scope fold sites (ExprEmit).
inline std::set<const void*>& sgnLit266() {
    static std::set<const void*> s;
    return s;
}
}  // namespace slang_uhdm
