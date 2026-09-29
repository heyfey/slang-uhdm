// r11u227 (pass 227, the expression/parameter ground,
// tools/probe/r11u227repro/README.md): every law reads its own
// R11U227_<LAW>_OFF switch; R11U227_OFF drops all of them,
// restoring the base's bytes.
// R11U227_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.227`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u227On(const char* sw) {
    if (getenv("R11U227_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// § landingSwitchReach227 — the ground-A half of a cross-ground whole-pass
// switch (R11U227_SPLIT<N>A_OFF); R11U227_OFF does NOT read it, the old
// whole-pass switches keep their meaning.
inline bool r11u227SplitAOff(const char* sw) { return getenv(sw) != nullptr; }
// v11u227 (the adversarial verification of pass 227,
// tools/probe/v11u227repro/README.md): every refinement reads its own
// R11V227_<LAW>_OFF switch; R11V227_OFF drops all of them (the pass's laws
// as delivered); R11U227_OFF drops the pass and with it every refinement.
inline bool r11v227On(const char* sw) {
    if (getenv("R11V227_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr227(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U227_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".227";
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
