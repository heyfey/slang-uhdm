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
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u298On(const char* sw) {
    if (getenv("R11U298_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v298On(const char* sw) {
    if (getenv("R11V298_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr298(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U298_TRACE");
        if (!d || !*d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".298";
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
