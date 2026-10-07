// r11u279 (pass 279, the module/type ground,
// tools/probe/r11u279repro/README.md): every law reads its own
// R11U279_<LAW>_OFF switch; R11U279_OFF drops all of them,
// restoring the base's bytes.
//   R11U279_SPCAVAL_OFF      § structParamCaReadsPaValue279        (ModuleEmit.cpp)
//   R11U279_TOPPKGTDELEM_OFF § topPkgMemberTdOfNamedElemShares279  (TypeEmit.cpp)
//   R11U279_CLSTDPATH_OFF    § clsTdMemberContainerPath279         (UhdmExporter.cpp)
//   R11U279_CLSTDQUAL_OFF    § clsTdScopedTargetQualSpan279        (UhdmExporter.cpp)
//   R11U279_EXTQUALSPAN_OFF  § extendsScopedBaseNameSpan279        (UhdmExporter.cpp)
//   R11U279_INLSTRUCTKW_OFF  § inlineStructPortVarKwSpan279        (TypeEmit.cpp)
// R11U279_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.279`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u279On(const char* sw) {
    if (getenv("R11U279_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr279(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U279_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".279";
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
