// r11u268 (pass 268, the expression/parameter ground,
// tools/probe/r11u268repro/README.md): every law reads its own
// R11U268_<LAW>_OFF switch; R11U268_OFF drops all of them,
// restoring the base's bytes.
// R11U268_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.268`, its first line `OUT <-o path>`, then `<law> <detail>`
// (an abstention reads `<law> abstain <detail>`).
#pragma once
#include <cstdio>
#include <cstdlib>
#include <set>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u268On(const char* sw) {
    if (getenv("R11U268_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u268 (the adversarial verification of r11u268): every fix reads its
// own R11V268_<FIX>_OFF switch; R11V268_OFF drops the fixes (the law's
// bytes); R11U268_OFF still drops the laws and the fixes together.
inline bool r11v268On(const char* sw) {
    if (getenv("R11U268_OFF") != nullptr || getenv("R11V268_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// the trace is on: callers build their detail strings only then (no heap
// traffic while the design is emitted when it is off)
inline bool tr268On() {
    static const bool on = getenv("R11U268_TRACE") != nullptr;
    return on;
}
inline void tr268(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U268_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".268";
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
