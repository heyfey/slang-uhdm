// r11u264 (pass 264, the expression/parameter ground,
// tools/probe/r11u264repro/README.md): every law reads its own
// R11U264_<LAW>_OFF switch; R11U264_OFF drops all of them,
// restoring the base's bytes.
// R11U264_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.264`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u264On(const char* sw) {
    if (getenv("R11U264_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u264 (the adversarial verification, tools/probe/v11u264repro/README.md):
// each refinement reads its own R11V264_<FIX>_OFF switch; R11V264_OFF drops
// all of them, giving the law's bytes; R11U264_OFF still gives pristine.
inline bool r11v264On(const char* sw) {
    if (getenv("R11U264_OFF") != nullptr || getenv("R11V264_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr264(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U264_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".264";
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
