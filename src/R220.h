// r11u220 (pass 220, the expression/parameter ground,
// tools/probe/r11u220repro/README.md): every law reads its own
// R11U220_<LAW>_OFF switch; R11U220_OFF drops all of them and the landed
// r11u218 laws (src/R218.h), restoring the base's bytes.
// R11U220_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.220`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u220On(const char* sw) {
    if (getenv("R11U220_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr220(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U220_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".220";
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
