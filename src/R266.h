// r11u266 (pass 266, the expression/parameter ground,
// tools/probe/r11u266repro/README.md): every law reads its own
// R11U266_<LAW>_OFF switch; R11U266_OFF drops all of them,
// restoring the base's bytes.
// R11U266_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.266`, its first line `OUT <-o path>`, then `<law> <detail>`
// (an abstention reads `<law> abstain <detail>`).
#pragma once
#include <cstdio>
#include <cstdlib>
#include <set>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u266On(const char* sw) {
    if (getenv("R11U266_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// § sgnLitElabFreshIntTs266: the parameters the law marked (ParamEmit), read
// back at the generate-scope fold sites (ExprEmit).
inline std::set<const void*>& sgnLit266() {
    static std::set<const void*> s;
    return s;
}
inline void tr266(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U266_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".266";
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
