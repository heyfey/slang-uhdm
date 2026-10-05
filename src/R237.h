// r11u237 (pass 237, the module/type ground,
// tools/probe/r11u237repro/README.md): every law reads its own
// R11U237_<LAW>_OFF switch; R11U237_OFF drops all of them (the base's bytes).
// R11U237_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.237`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u237Law(const char* sw) {
    if (getenv("R11U237_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr237(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U237_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".237";
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
// v11u237 (the adversarial verification of r11u237,
// tools/probe/v11u237repro/README.md): every refinement reads its own
// R11V237_<LAW>_OFF switch; R11V237_OFF drops all of them (r11u237's bytes).
// R11U237_OFF drops these refinements too (the base's bytes on every case,
// pass 235's enum-base laws included).  Firings are logged through tr237 (R11U237_TRACE).
inline bool r11v237Law(const char* sw) {
    if (getenv("R11V237_OFF") != nullptr || getenv("R11U237_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
} // namespace slang_uhdm
