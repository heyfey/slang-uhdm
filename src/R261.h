// r11u261 (pass 261, the module/type ground,
// tools/probe/r11u261repro/README.md): every law reads its own
// R11U261_<LAW>_OFF switch; R11U261_OFF drops all of them,
// restoring the base's bytes.
// R11U261_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.261`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u261On(const char* sw) {
    if (getenv("R11U261_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u261 (the adversarial verification of r11u261,
// tools/probe/v11u261repro/README.md): each refinement reads its own
// R11V261_<FIX>_OFF switch; R11V261_OFF drops all of them (the law's bytes),
// and R11U261_OFF still drops the whole pass (pristine bytes).
inline bool r11v261On(const char* sw) {
    if (getenv("R11V261_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr261(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U261_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".261";
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
