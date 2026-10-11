// r11u282 (pass 282, the expression/parameter ground,
// tools/probe/r11u282repro/README.md): every law reads its own
// R11U282_<LAW>_OFF switch; R11U282_OFF drops all of them,
// restoring the base's bytes.
// R11U282_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.282`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u282On(const char* sw) {
    if (getenv("R11U282_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u282 (the adversarial verification of r11u282,
// tools/probe/v11u282repro/README.md): a refinement reads its own
// R11V282_<X>_OFF switch; R11V282_OFF drops every refinement (the law's
// bytes), R11U282_OFF still drops the law with it (pristine's bytes).
inline bool r11v282On(const char* sw) {
    if (getenv("R11U282_OFF") != nullptr || getenv("R11V282_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr282(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U282_TRACE");
        if (!d || !*d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".282";
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

// ExprEmit's design-final drain of the generate-scope fold names, called at
// the end of ParamEmit's drainShareDefParamTs (after pass 280's).
namespace UHDM { class Serializer; }
namespace slang_uhdm {
void foldTsNameFinalDrain282(UHDM::Serializer& s);
}  // namespace slang_uhdm
