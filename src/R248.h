// r11u248 (pass 248, the expression/parameter ground,
// tools/probe/r11u248repro/README.md): every law reads its own
// R11U248_<LAW>_OFF switch; R11U248_OFF drops all of them,
// restoring the base's bytes.
// R11U248_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.248`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>
#include <uhdm/uhdm.h>

namespace slang_uhdm {
inline bool r11u248On(const char* sw) {
    if (getenv("R11U248_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u248 (adversarial verification of r11u248): every fix reads its own
// R11V248_<FIX>_OFF switch; R11V248_OFF drops all of them (R11U248_OFF still
// restores the base's bytes: each fix lives inside a law's branch).
inline bool r11v248On(const char* sw) {
    if (getenv("R11V248_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// § callArgCopyElabNearestOp248v: true while the exporter writes the
// --elabuhdm view (set by ParamEmit before drainCallArgCopyTs246).
inline bool& callArgCopyElabView248v() {
    static bool b = false;
    return b;
}
inline void tr248(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U248_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".248";
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
// § cloneLoopVarClassPropStringTs248: a shared clone loop variable whose
// property typespec is bound only by the class listing's drain (mirrored by
// pendingLoopVarTs9); ParamEmit drainShareDefParamTs gives any the mirror
// missed the base's unsupported placeholder, named and located as the
// shared object.
inline std::vector<std::pair<UHDM::ref_typespec*, UHDM::ref_var*>>& deferredCloneStrTs248() {
    static std::vector<std::pair<UHDM::ref_typespec*, UHDM::ref_var*>> v;
    return v;
}
}  // namespace slang_uhdm
