// r11u226 (the second adversarial verification of passes 219, 220 and 223,
// tools/probe/r11u226verify/README.md): every refinement reads its own
// R11V226_<LAW>_OFF switch; R11V226_OFF drops all of them (the verified base's
// bytes).  A refinement of a landed law is also dropped by that law's landing
// switch (R11U223_OFF for § tfArgScalarTdExportOwnTd226v).
// R11V226_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.226`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11v226Law(const char* sw) {
    if (getenv("R11V226_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr226(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11V226_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".226";
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
