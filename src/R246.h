// r11u246 (pass 246, the expression/parameter ground,
// tools/probe/r11u246repro/README.md): every law reads its own
// R11U246_<LAW>_OFF switch; R11U246_OFF drops all of them,
// restoring the base's bytes.
// R11U246_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.246`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u246On(const char* sw) {
    if (getenv("R11U246_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u246 (the adversarial verification): each fix reads its own
// R11V246_<FIX>_OFF; R11V246_OFF drops every fix (the law's bytes).
inline bool r11v246On(const char* sw) {
    if (getenv("R11V246_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr246(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U246_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".246";
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
