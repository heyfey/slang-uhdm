// r11u275 (pass 275, the module/type ground,
// tools/probe/r11u275repro/README.md): every law reads its own
// R11U275_<LAW>_OFF switch; R11U275_OFF drops all of them,
// restoring the base's bytes.
// R11U275_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.275`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u275On(const char* sw) {
    if (getenv("R11U275_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u275 (the adversarial verification of r11u275,
// tools/probe/v11u275repro/README.md): each refinement reads its own
// R11V275_<FIX>_OFF switch; R11V275_OFF drops all of them, giving the
// law's bytes (R11U275_OFF still gives the base's).
inline bool r11v275On(const char* sw) {
    if (getenv("R11U275_OFF") != nullptr || getenv("R11V275_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr275(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U275_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".275";
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
// § defNetTpPatKeepsActual275v (UhdmExporter.cpp): after the ElaboratorListener.
void defNetTpPatKeepActual275v();
}  // namespace slang_uhdm
