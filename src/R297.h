// r11u297 (pass 297, the module/type ground,
// tools/probe/r11u297repro/README.md): every law reads its own
// R11U297_<LAW>_OFF switch; R11U297_OFF drops all of them,
// restoring the base's bytes.
//   R11U297_VARINITTSEND_OFF  § varDeclInitMovesSharedTsEnd297 (ModuleEmit.cpp)
//   R11U297_VARINITSPAN_OFF   § varDeclInitElabSpan297 (ModuleEmit.cpp)
//   R11U297_NESTNOSHELL_OFF   § nestedDefPortsNeedShell297 (ModuleEmit.cpp)
// v11u297 (the adversarial verification of r11u297,
// tools/probe/v11u297repro/README.md): each refinement reads its own
// R11V297_<X>_OFF switch; R11V297_OFF drops all of them (the law's bytes),
// and R11U297_OFF still drops every law and refinement (pristine's bytes).
//   (none yet)
// R11U297_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.297`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>

namespace slang_uhdm {
inline bool r11u297On(const char* sw) {
    if (getenv("R11U297_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v297On(const char* sw) {
    if (getenv("R11V297_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr297(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U297_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".297";
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
