// r11u218 (the ground-A decode of the r11u214 hand-offs and map 13,
// tools/probe/r11u218dec/README.md): every law reads its own
// R11U218_<LAW>_OFF switch; R11U218_OFF drops all of them (the base's bytes).
// Landed by pass r11u220 (tools/probe/r11u220repro/README.md): R11U220_OFF,
// the landing pass's switch for all of its laws, drops these too.
// R11U218_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.218`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u218On(const char* sw) {
    if (getenv("R11U218_OFF") != nullptr || getenv("R11U220_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr218(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U218_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".218";
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
