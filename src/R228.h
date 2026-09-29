// r11u228 (pass 228, the module/type ground: tools/probe/r11u228repro/README.md):
// every law reads its own R11U228_<LAW>_OFF switch; R11U228_OFF drops all of
// them (the base's bytes).  R11U228_TRACE=<dir> names every firing: one file
// per process, `<dir>/<pid>.228`, its first line `OUT <-o path>`, then
// `<law> <detail>`.  The trace allocates only when R11U228_TRACE is set.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u228Law(const char* sw) {
    if (getenv("R11U228_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr228(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U228_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".228";
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

// v11u228 (the adversarial verification of r11u228,
// tools/probe/v11u228repro/README.md): the refinements read their own
// R11V228_<LAW>_OFF switches; R11V228_OFF drops them all (r11u228's bytes).
// Their firings trace to the same R11U228_TRACE file, law names ending `228v`.
namespace slang_uhdm {
inline bool r11v228Law(const char* sw) {
    if (getenv("R11V228_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void trv228(const char* law, const std::string& detail = std::string()) {
    tr228(law, detail);
}
} // namespace slang_uhdm
