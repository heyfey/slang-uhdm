// r11u267 (pass 267, the module/type ground,
// tools/probe/r11u267repro/README.md): every law reads its own
// R11U267_<LAW>_OFF switch; R11U267_OFF drops all of them,
// restoring the base's bytes.
// R11U267_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.267`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u267On(const char* sw) {
    if (getenv("R11U267_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u267 (adversarial verification of r11u267,
// tools/probe/v11u267repro/README.md): the verifier's refinements read their own
// R11V267_<FIX>_OFF switch; R11V267_OFF drops all of them (the law's bytes),
// and R11U267_OFF still restores the base's bytes.
inline bool r11v267On(const char* sw) {
    if (getenv("R11V267_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr267(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U267_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".267";
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

