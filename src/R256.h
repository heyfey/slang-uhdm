// r11u256 (pass 256, the expression/parameter ground,
// tools/probe/r11u256repro/README.md): every law reads its own
// R11U256_<LAW>_OFF switch; R11U256_OFF drops all of them,
// restoring the base's bytes.
// R11U256_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.256`, its first line `OUT <-o path>`, then `<law> <detail>`.
// The verifier's refinement (tools/probe/v11u256repro/README.md) reads its own
// R11V256_<FIX>_OFF switch; R11V256_OFF drops it, restoring the law's bytes.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u256On(const char* sw) {
    if (getenv("R11U256_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v256On(const char* sw) {
    if (getenv("R11V256_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr256(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U256_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".256";
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
