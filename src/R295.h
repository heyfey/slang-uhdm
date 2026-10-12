// r11u295 (pass 295, the module/type ground,
// tools/probe/r11u295repro/README.md): every law reads its own
// R11U295_<LAW>_OFF switch; R11U295_OFF drops all of them,
// restoring the base's bytes.
//   R11U295_ESCNAMESPAN_OFF   § escNameSpanSites295 (ModuleEmit.cpp, UhdmExporter.cpp)
//   R11U295_RAWEND_OFF        § rawEndLineModel295 (ModuleEmit.cpp)
//   R11U295_NESTARRNAME_OFF   § nestedModArrayScopedName295 (ModuleEmit.cpp)
//   R11U295_DYNMEMSPAN_OFF    § dynAssocMemberSpanToDim295 (TypeEmit.cpp)
// v11u295 (the adversarial verification of r11u295,
// tools/probe/v11u295repro/README.md): each refinement reads its own
// R11V295_<X>_OFF switch; R11V295_OFF drops all of them (the law's bytes),
// and R11U295_OFF still drops every law and refinement (pristine's bytes).
//   R11V295_NESTSHADOW_OFF    § nestArrShadowTopKeepsBare295v (ModuleEmit.cpp)
// R11U295_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.295`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>

namespace slang_uhdm {
inline bool r11u295On(const char* sw) {
    if (getenv("R11U295_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v295On(const char* sw) {
    if (getenv("R11V295_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr295(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U295_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".295";
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
