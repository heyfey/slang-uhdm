// r11u288 (pass 288, the expression/parameter ground,
// tools/probe/r11u288repro/README.md): every law reads its own
// R11U288_<LAW>_OFF switch; R11U288_OFF drops all of them,
// restoring the base's bytes.
// R11U288_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.288`, its first line `OUT <-o path>`, then
// `<law> <detail>` (a tag ending in _ABSTAIN moves nothing).
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u288On(const char* sw) {
    if (getenv("R11U288_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr288(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U288_TRACE");
        if (!d || !*d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".288";
        FILE* fp = fopen(fn.c_str(), "a");
        if (!fp)
            return nullptr;
        std::string cl, prev, outp;
        if (FILE* c = fopen("/proc/self/cmdline", "r")) {
            int ch;
            while ((ch = fgetc(c)) != EOF) {
                if (ch == 0) {
                    if (prev == "-o")
                        outp = cl;
                    prev = cl;
                    cl.clear();
                }
                else
                    cl += (char)ch;
            }
            fclose(c);
        }
        fprintf(fp, "OUT %s\n", outp.c_str());
        return fp;
    }();
    if (tf) {
        fprintf(tf, "%s %s\n", law, detail.c_str());
        fflush(tf);
    }
}
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
inline bool r11v288On(const char* sw) {
    if (getenv("R11V288_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// § rzMemberNoReparentDefView288v: whether this run writes the elaborated
// view (--elabuhdm), set by ParamEmit before rzWithParentDrain288 runs.
inline bool& rzElabView288v() {
    static bool v = false;
    return v;
}
}  // namespace slang_uhdm
