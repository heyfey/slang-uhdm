// r11u253 (pass 253, the module/type ground,
// tools/probe/r11u253repro/README.md): every law reads its own
// R11U253_<LAW>_OFF switch; R11U253_OFF drops all of them,
// restoring the base's bytes.
// R11U253_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.253`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <unordered_set>

namespace slang_uhdm {
inline bool r11u253On(const char* sw) {
    if (getenv("R11U253_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr253(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U253_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".253";
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
