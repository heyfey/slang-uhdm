// r11u251 (pass 251, the module/type ground,
// tools/probe/r11u251repro/README.md): every law reads its own
// R11U251_<LAW>_OFF switch; R11U251_OFF drops all of them,
// restoring the base's bytes.
// R11U251_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.251`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <unordered_set>

namespace slang_uhdm {
inline bool r11u251On(const char* sw) {
    if (getenv("R11U251_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr251(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U251_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".251";
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
// § regTdArrElabIsNet251 — the elaborated array_vars ModuleEmit placed among
// the nets (the design-final $unit typedef pass leaves their typespec
// unfolded: the net branch reads the typedef's own typespec).
extern std::unordered_set<const void*> g251RegNetVars;
}  // namespace slang_uhdm
