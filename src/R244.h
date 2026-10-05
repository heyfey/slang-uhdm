// r11u244 (pass 244, the expression/parameter ground,
// tools/probe/r11u244repro/README.md): every law reads its own
// R11U244_<LAW>_OFF switch; R11U244_OFF drops all of them,
// restoring the base's bytes.
// R11U244_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.244`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u244On(const char* sw) {
    if (getenv("R11U244_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u244 (the adversarial verification of r11u244,
// tools/probe/v11u244repro/README.md): each refinement reads its own
// R11V244_<FIX>_OFF switch; R11V244_OFF drops all of them (the
// implementer's bytes); R11U244_OFF still drops every law with them.
inline bool r11v244On(const char* sw) {
    if (getenv("R11U244_OFF") != nullptr || getenv("R11V244_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr244(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U244_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".244";
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
