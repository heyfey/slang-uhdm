// r11u280 (pass 280, the expression/parameter ground,
// tools/probe/r11u280repro/README.md): every law reads its own
// R11U280_<LAW>_OFF switch; R11U280_OFF drops all of them,
// restoring the base's bytes.
// R11U280_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.280`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u280On(const char* sw) {
    if (getenv("R11U280_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr280(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U280_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".280";
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

// § hpMemVarSelNamesFinal280: ExprEmit's design-final drain, called at the
// end of ParamEmit's drainShareDefParamTs.
namespace slang_uhdm {
void hpMemVarSelNamesDrain280();
}  // namespace slang_uhdm
