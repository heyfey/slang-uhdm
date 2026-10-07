// r11u278 (pass 278, the expression/parameter ground,
// tools/probe/r11u278repro/README.md): every law reads its own
// R11U278_<LAW>_OFF switch; R11U278_OFF drops all of them,
// restoring the base's bytes.
// R11U278_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.278`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u278On(const char* sw) {
    if (getenv("R11U278_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr278(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U278_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".278";
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

// v11u278 (adversarial verification of r11u278): the verifier's refinements
// read their own R11V278_<FIX>_OFF switch; R11V278_OFF drops all of them
// (giving the r11u278 law's bytes) and R11U278_OFF still drops everything.
namespace slang_uhdm {
inline bool r11v278On(const char* sw) {
    if (getenv("R11U278_OFF") != nullptr || getenv("R11V278_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
}  // namespace slang_uhdm
