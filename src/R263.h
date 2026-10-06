// r11u263 (pass 263, the module/type ground,
// tools/probe/r11u263repro/README.md): every law reads its own
// R11U263_<LAW>_OFF switch; R11U263_OFF drops all of them,
// restoring the base's bytes.
// R11U263_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.263`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u263On(const char* sw) {
    if (getenv("R11U263_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr263(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U263_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".263";
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

// v11u263 (adversarial verification of r11u263,
// tools/probe/v11u263repro/README.md): every refinement reads its own
// R11V263_<FIX>_OFF switch; R11V263_OFF drops all of them (the law's bytes);
// R11U263_OFF still restores the base's bytes.
namespace slang_uhdm {
inline bool r11v263On(const char* sw) {
    if (getenv("R11V263_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
}  // namespace slang_uhdm
