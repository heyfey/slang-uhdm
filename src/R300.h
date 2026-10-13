// r11u300 (pass 300, the expression/parameter ground,
// tools/probe/r11u300repro/README.md): every law reads its own
// R11U300_<LAW>_OFF switch; R11U300_OFF drops all of them,
// restoring the base's bytes.  The laws:
//   § pkgRetCallFoldSharesCalleeRet300 R11U300_RETSHARE_OFF (ExprEmit's
//                                      user-call branch; the registry of
//                                      each listing's return expression is
//                                      written in StmtEmit)
// R11U300_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.300`, its first line `OUT <-o path>`, then
// `<law> <detail>` (a tag ending in _ABSTAIN moves nothing).
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <map>
#include <utility>

#include <uhdm/uhdm_types.h>
#include <uhdm/BaseClass.h>

namespace slang_uhdm {
// v11u300 (adversarial verification of r11u300): the verifier's refinement
//   § retShareActualFoldAbstain300v R11V300_ACTFOLD_OFF (ExprEmit, inside the
//                                      law's site); R11V300_OFF drops it and
//                                      gives the law's bytes, R11U300_OFF still
//                                      gives pristine's.  Its firing traces as
//                                      `ACTFOLD300V <caller>-><callee> <why>`.
// § pkgRetCallFoldSharesCalleeRet300's registry: the expression object a
// direct `return` of a package function was emitted with in an ELABORATED
// (TopPackages) listing, keyed by (the listing's package object, the
// subroutine's home symbol); and, for the home package's own listing, by the
// symbol alone (a package-qualified call into another package reads that one).
inline std::map<std::pair<const void*, const void*>, UHDM::any*>& retCondReg300() {
    static std::map<std::pair<const void*, const void*>, UHDM::any*> m;
    return m;
}
inline std::map<const void*, UHDM::any*>& retCondHome300() {
    static std::map<const void*, UHDM::any*> m;
    return m;
}
}  // namespace slang_uhdm
