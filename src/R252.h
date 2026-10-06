// r11u252 (pass 252, the expression/parameter ground,
// tools/probe/r11u252repro/README.md): every law reads its own
// R11U252_<LAW>_OFF switch; R11U252_OFF drops all of them,
// restoring the base's bytes.
// R11U252_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.252`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u252On(const char* sw) {
    if (getenv("R11U252_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u252 (the adversarial verification of r11u252,
// tools/probe/v11u252repro/README.md): each refinement reads its own
// R11V252_<FIX>_OFF switch; R11V252_OFF drops all of them (the law's bytes);
// R11U252_OFF still drops the laws and the refinements together.
inline bool r11v252On(const char* sw) {
    if (getenv("R11U252_OFF") != nullptr || getenv("R11V252_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr252(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U252_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".252";
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
