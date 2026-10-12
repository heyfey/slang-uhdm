// r11u299 (pass 299, the module/type ground,
// tools/probe/r11u299repro/README.md): every law reads its own
// R11U299_<LAW>_OFF switch; R11U299_OFF drops all of them,
// restoring the base's bytes.
//   R11U299_UNITCLSFORMAL_OFF  § unitTdClassFormalWriter299 (UhdmExporter.cpp)
//   R11U299_INLAGGFORMAL_OFF   § inlineAggFormalTypeSpan299 (TaskFuncEmit.cpp)
//   R11U299_INLAGGRET_OFF      § inlineAggReturnVarSpan299 (TaskFuncEmit.cpp)
//   R11U299_NATPVARHDR_OFF     § nonAnsiTpVarAtHeader299 (ModuleEmit.cpp)
//   R11U299_MODENUMCLONE_OFF   § modEnumTfArgCloneFollows299 (UhdmExporter.cpp)
// v11u299 (the adversarial verification of r11u299,
// tools/probe/v11u299repro/README.md): each refinement reads its own
// R11V299_<X>_OFF switch; R11V299_OFF drops all of them (the law's bytes),
// and R11U299_OFF still drops every law and refinement (pristine's bytes).
//   none: verified with no production fix (v11u299repro/README.md)
// R11U299_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.299`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>

namespace slang_uhdm {
inline bool r11u299On(const char* sw) {
    if (getenv("R11U299_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v299On(const char* sw) {
    if (getenv("R11V299_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr299(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U299_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".299";
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
