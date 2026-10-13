// r11u298 (pass 298, the expression/parameter ground,
// tools/probe/r11u298repro/README.md): every law reads its own
// R11U298_<LAW>_OFF switch; R11U298_OFF drops all of them,
// restoring the base's bytes.  The laws (all in ExprEmit.cpp):
//   § nestedCastOuterTpPlaceholder298  R11U298_NESTCASTTP_OFF
//   § pkgQualBoundSpanTernary298       R11U298_QBTERN_OFF
//   § castClsTpOwnDefaultObj298        R11U298_CLSTPOBJ_OFF
//   § castClsTpOutOfBodyPlaceholder298 R11U298_CLSTPOOB_OFF (also under
//                                      R11U298_CLSTPOBJ_OFF)
// The verifier's refinement (v11u298, tools/probe/v11u298repro/README.md),
// read through r11v298On (R11V298_OFF drops it, giving the implementer's
// law bytes; R11U298_OFF still drops everything):
//   § nestedCastPlaceholderCaOnly298v  R11V298_CASITE_OFF
//   § castClsTpNestedClsPlaceholder298v R11V298_NESTCLS_OFF (also under
//                                      R11U298_CLSTPOBJ_OFF / _CLSTPOOB_OFF)
// R11U298_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.298`, its first line `OUT <-o path>`, then
// `<law> <detail>` (a tag ending in _ABSTAIN moves nothing).
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
