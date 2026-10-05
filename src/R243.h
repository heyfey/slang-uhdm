// r11u243 (pass 243, the module/type ground,
// tools/probe/r11u243repro/README.md): every law reads its own
// R11U243_<LAW>_OFF switch; R11U243_OFF drops all of them,
// restoring the base's bytes.
// v11u243 (tools/probe/v11u243repro/README.md) adds two refinements, each
// behind its own R11V243_<FIX>_OFF switch (R11V243_OFF drops both):
// § thisNetHomeListedOnly243v (R11V243_THISHOME_OFF, TypeEmit) and
// § unitImpPaRhsActualFinal243v (R11V243_UNITRHSACT_OFF, UhdmExporter).
// R11U243_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.243`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u243On(const char* sw) {
    if (getenv("R11U243_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr243(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U243_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".243";
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
