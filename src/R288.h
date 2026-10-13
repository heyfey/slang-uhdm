// r11u288 (pass 288, the expression/parameter ground,
// tools/probe/r11u288repro/README.md): every law reads its own
// R11U288_<LAW>_OFF switch; R11U288_OFF drops all of them,
// restoring the base's bytes.
// R11U288_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.288`, its first line `OUT <-o path>`, then
// `<law> <detail>` (a tag ending in _ABSTAIN moves nothing).
#pragma once
#include "LawSwitch.h"
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
}  // namespace slang_uhdm
// § randWithCallParentByConsumer288: every with-form scope randomize
// method_func_call § scopeRandomizeIsBareCall116 mints, with its constraint
// and the parent its emitExpr call was handed.
#include <vector>
#include <uhdm/uhdm.h>
namespace slang_uhdm {
struct RzRec288 {
    UHDM::method_func_call* mfc;
    UHDM::constraint* cons;
    UHDM::any* parent0;
};
inline std::vector<RzRec288>& rzWith288() {
    static std::vector<RzRec288> v;
    return v;
}
// The call's identifier-list arguments as Surelog's compileTfCallArguments
// leaves them under a parented call: no stored full name, so the name is the
// parent chain's (bareArgName116 stored the bare name on the parentless call).
inline void rzScopeArgs288(UHDM::method_func_call* m) {
    if (auto* args = m->Tf_call_args())
        for (auto* a : *args)
            if (a && a->UhdmType() == UHDM::uhdmref_obj) {
                auto* r = (UHDM::ref_obj*)a;
                if (r->VpiFullName() == r->VpiName())
                    r->VpiFullName("");
            }
}
inline bool rzIsRec288(const UHDM::any* o) {
    if (!o || o->UhdmType() != UHDM::uhdmmethod_func_call)
        return false;
    for (auto& r : rzWith288())
        if (r.mfc == o)
            return true;
    return false;
}
// design-final, from ParamEmit's drain list (ExprEmit holds the law).
void rzWithParentDrain288();
// v11u288 (the adversarial verification of r11u288): the verifier's
// refinements read R11V288_<X>_OFF, R11V288_OFF drops them all (giving the
// law's bytes) and R11U288_OFF still drops the whole pass.
// § rzMemberNoReparentDefView288v: whether this run writes the elaborated
// view (--elabuhdm), set by ParamEmit before rzWithParentDrain288 runs.
inline bool& rzElabView288v() {
    static bool v = false;
    return v;
}
}  // namespace slang_uhdm
