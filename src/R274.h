// r11u274 (pass 274, the expression/parameter ground,
// tools/probe/r11u274repro/README.md): every law reads its own
// R11U274_<LAW>_OFF switch; R11U274_OFF drops all of them,
// restoring the base's bytes.
// R11U274_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.274`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u274On(const char* sw) {
    if (getenv("R11U274_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u274 (the adversarial verification of pass 274,
// tools/probe/v11u274repro/README.md): each refinement reads its own
// R11V274_<NAME>_OFF switch; R11V274_OFF drops the refinements (the
// implementer's law bytes), R11U274_OFF still drops everything.
inline bool r11v274On(const char* sw) {
    if (getenv("R11U274_OFF") != nullptr || getenv("R11V274_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr274(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U274_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".274";
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
