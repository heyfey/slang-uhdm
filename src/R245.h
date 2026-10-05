// r11u245 (pass 245, the module/type ground,
// tools/probe/r11u245repro/README.md): every law reads its own
// R11U245_<LAW>_OFF switch; R11U245_OFF drops all of them,
// restoring the base's bytes.
// R11U245_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.245`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u245On(const char* sw) {
    if (getenv("R11U245_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u245 (adversarial verification of r11u245,
// tools/probe/v11u245repro/README.md): each refinement reads its own
// R11V245_<FIX>_OFF switch; R11V245_OFF drops all of them (R11U245_OFF and
// R11U245_UNITLAWS_OFF drop them too: they live inside § unitTdLawS245).
inline bool r11v245On(const char* sw) {
    if (getenv("R11V245_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr245(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U245_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".245";
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
