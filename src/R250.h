// r11u250 (pass 250, the expression/parameter ground,
// tools/probe/r11u250repro/README.md): every law reads its own
// R11U250_<LAW>_OFF switch; R11U250_OFF drops all of them,
// restoring the base's bytes.
// R11U250_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.250`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u250On(const char* sw) {
    if (getenv("R11U250_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u250 (adversarial verification of r11u250): every fix reads its own
// R11V250_<FIX>_OFF switch; R11V250_OFF drops all of them (R11U250_OFF still
// restores the base's bytes: each fix lives inside a law's branch).
inline bool r11v250On(const char* sw) {
    if (getenv("R11V250_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr250(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U250_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".250";
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
