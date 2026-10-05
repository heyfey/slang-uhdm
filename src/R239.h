// r11u239 (pass 239, the module/type ground,
// tools/probe/r11u239repro/README.md): every law reads its own
// R11U239_<LAW>_OFF switch; R11U239_OFF drops all of them (the base's bytes).
// R11U239_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.239`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u239Law(const char* sw) {
    if (getenv("R11U239_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr239(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U239_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".239";
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
// v11u239 (the adversarial verification of r11u239,
// tools/probe/v11u239repro/README.md): every refinement reads its own
// R11V239_<LAW>_OFF switch; R11V239_OFF drops all of them (r11u239's bytes).
// R11U239_OFF drops these refinements too (the base's bytes on every case).
// Firings are logged through tr239 (R11U239_TRACE).
inline bool r11v239Law(const char* sw) {
    if (getenv("R11V239_OFF") != nullptr || getenv("R11U239_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
} // namespace slang_uhdm
