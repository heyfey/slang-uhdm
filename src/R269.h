// r11u269 (pass 269, the module/type ground,
// tools/probe/r11u269repro/README.md): every law reads its own
// R11U269_<LAW>_OFF switch; R11U269_OFF drops all of them,
// restoring the base's bytes.
// R11U269_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.269`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
// § retTopRangeOwnPkg269: the elaborated package object whose subroutine's
// per-reference return-name local ModuleEmit drainFuncRet is compiling (null
// everywhere else); TypeEmit's package-parameter range binding reads it.
inline const void* retTopPkg269 = nullptr;
inline bool r11u269On(const char* sw) {
    if (getenv("R11U269_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u269 (the adversarial verification of r11u269,
// tools/probe/v11u269repro/README.md): every refinement reads its own
// R11V269_<FIX>_OFF switch; R11V269_OFF drops all of them (the law's bytes),
// R11U269_OFF still drops the laws and the refinements together (pristine).
inline bool r11v269On(const char* sw) {
    if (getenv("R11U269_OFF") != nullptr || getenv("R11V269_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr269(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U269_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".269";
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

