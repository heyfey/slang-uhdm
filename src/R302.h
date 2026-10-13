// r11u302 (pass 302, the expression/parameter ground,
// tools/probe/r11u302repro/README.md): every law reads its own
// R11U302_<LAW>_OFF switch; R11U302_OFF drops all of them,
// restoring the base's bytes.  The laws:
//   § modFnLitLeftoverAtLiteral302     R11U302_LITLOC_OFF (ParamEmit,
//                                      stampEvalFuncLeftovers' drain)
//   § pkgPatLeftoverSrcPkgListing302   R11U302_PATSRCPKG_OFF (ParamEmit, same
//                                      drain; record in emitParameters)
//   § modPatLeftoverCloneNoParent302   R11U302_PATMODNOPAR_OFF (ParamEmit,
//                                      same drain)
//   § elabImpSelFlatKeepsParent302     R11U302_IMPSELFLATPAR_OFF (ParamEmit,
//                                      § pkgPatReadTsNoParent131's elaborated
//                                      walk; record at § modDefImportPkgSelFlat60)
//   § castPatTagKeyLocThroughParens302 R11U302_CASTPATKEY_OFF (ExprEmit, the
//                                      structured-pattern tag keys)
//   § rootTdLeftoverStamp302           R11U302_ROOTTDSTAMP_OFF (ParamEmit,
//                                      stampEvalFuncLeftovers' stamp walk)
// The verifier's refinements (v11u302, tools/probe/v11u302repro/README.md),
// each behind its own R11V302_<X>_OFF switch; R11V302_OFF drops both and
// gives the law's bytes (R11U302_OFF still gives pristine's):
//   § modFnLitLeftoverValueGate302v    R11V302_LITVAL_OFF (ParamEmit, the
//                                      literal branch of § modFnLitLeftoverAtLiteral302)
//   § leftoverSlotSoleWriter302v       R11V302_SOLEWRITER_OFF (ParamEmit, the
//                                      literal branch and the pattern-parameter branch)
// R11U302_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.302`, its first line `OUT <-o path>`, then
// `<law> <detail>` (a tag ending in _ABSTAIN moves nothing).
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <map>
#include <set>
#include <vector>
#include <utility>

#include <slang/numeric/SVInt.h>
#include <uhdm/uhdm_types.h>
#include <uhdm/BaseClass.h>

namespace slang_uhdm {
// § pkgPatLeftoverSrcPkgListing302's record: a package parameter's elaborated
// Rhs object in the package's OWN (TopPackages) listing, keyed by its symbol.
inline std::map<const void*, UHDM::any*>& pkgOwnElabRhs302() {
    static std::map<const void*, UHDM::any*> m;
    return m;
}
// § elabImpSelFlatKeepsParent302's record: `pkg::NAME` of every package
// pattern parameter § modDefImportPkgSelFlat60 flattened in a DEF import copy.
inline std::set<std::string>& impSelFlat302() {
    static std::set<std::string> m;
    return m;
}
// § modFnLitLeftoverAtLiteral302's record: every emitted copy (emission
// order) of a literal assignment right side in a non-package subroutine,
// keyed by the slang right-side expression.
inline std::map<const void*, std::vector<UHDM::any*>>& modFnBodyLit302() {
    static std::map<const void*, std::vector<UHDM::any*>> m;
    return m;
}
// § modFnLitLeftoverValueGate302v's record: the folded member bits each
// minted leftover constant was cut from (makeMemLeftConst's slice), keyed by
// the minted constant.
inline std::map<const void*, slang::SVInt>& mintSlice302v() {
    static std::map<const void*, slang::SVInt> m;
    return m;
}
}  // namespace slang_uhdm
