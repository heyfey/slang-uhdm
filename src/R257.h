// r11u257 (pass 257, the module/type ground,
// tools/probe/r11u257repro/README.md): every law reads its own
// R11U257_<LAW>_OFF switch; R11U257_OFF drops all of them,
// restoring the base's bytes.
// R11U257_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.257`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u257On(const char* sw) {
    if (getenv("R11U257_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u257 (the adversarial verifier of r11u257,
// tools/probe/v11u257repro/README.md): every refinement reads its own
// R11V257_<FIX>_OFF switch; R11V257_OFF drops them all (the law's bytes),
// R11U257_OFF drops the law and its refinements (the base's bytes).
inline bool r11v257On(const char* sw) {
    if (getenv("R11U257_OFF") != nullptr || getenv("R11V257_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr257(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U257_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".257";
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
