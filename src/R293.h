// r11u293 (pass 293, the module/type ground,
// tools/probe/r11u293repro/README.md): every law reads its own
// R11U293_<LAW>_OFF switch; R11U293_OFF drops all of them,
// restoring the base's bytes.
//   R11U293_CLONERETSEL_OFF   § cloneRetNameSelRefBindsHomeReturn293 (ModuleEmit.cpp)
//   R11U293_CLSARRDIMEND_OFF  § defNetClassArrTsDimEnd293 (ModuleEmit.cpp)
//   R11U293_HOISTELEMSPAN_OFF § pkgHoistArrNetElemDimSpan293 (ModuleEmit.cpp)
//   R11U293_IFFIRSTREF_OFF    § ifaceFirstSignalBindsRefs293 (ModuleEmit.cpp)
//   R11U293_IFLOWFIRST_OFF    § ifaceLowConnFirstSignal293 (ModuleEmit.cpp)
//   R11U293_PVNDAPARENT_OFF   § portViewNdaNetCellParent293 (ModuleEmit.cpp)
// v11u293 (adversarial verification of r11u293, tools/probe/v11u293repro):
// the verifier's refinement reads r11v293On: R11V293_OFF drops it (the law's
// bytes), R11U293_OFF still drops everything (pristine's bytes).
//   R11V293_PVTSUNSTORED_OFF  § pvNdaTsNameUnstored293v (ModuleEmit.cpp)
// R11U293_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.293`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>

namespace slang_uhdm {
inline bool r11u293On(const char* sw) {
    if (getenv("R11U293_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v293On(const char* sw) {
    if (getenv("R11U293_OFF") != nullptr || getenv("R11V293_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr293(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U293_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".293";
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
} // namespace slang_uhdm
