// r11u276 (pass 276, the expression/parameter ground,
// tools/probe/r11u276repro/README.md): every law reads its own
// R11U276_<LAW>_OFF switch; R11U276_OFF drops all of them,
// restoring the base's bytes.
// R11U276_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.276`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u276On(const char* sw) {
    if (getenv("R11U276_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u276 (the adversarial verification of r11u276, tools/probe/v11u276repro/README.md):
// each refinement reads its own R11V276_<FIX>_OFF switch; R11V276_OFF drops all of them
// (giving the r11u276 law's bytes), and R11U276_OFF still drops the laws together with
// their refinements (pristine's bytes).
inline bool r11v276On(const char* sw) {
    if (getenv("R11U276_OFF") != nullptr || getenv("R11V276_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr276(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U276_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".276";
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
