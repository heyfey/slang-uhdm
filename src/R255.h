// r11u255 (pass 255, the module/type ground,
// tools/probe/r11u255repro/README.md): every law reads its own
// R11U255_<LAW>_OFF switch; R11U255_OFF drops all of them,
// restoring the base's bytes.
// R11U255_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.255`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <unordered_set>
#include <utility>
#include <vector>

namespace slang_uhdm {
inline bool r11u255On(const char* sw) {
    if (getenv("R11U255_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr255(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U255_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".255";
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
// § fwWinnerListedObject255's record: every object § bareTdNameFirstWriterWins98
// handed out (fwWinnerTs98) with the winning TypeAliasType symbol, in emission
// order; drained design-final in UhdmExporter.
inline std::vector<std::pair<void*, const void*>>& r255Fw98() {
    static std::vector<std::pair<void*, const void*>> v;
    return v;
}
}  // namespace slang_uhdm
