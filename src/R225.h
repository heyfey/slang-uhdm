// r11u225 (pass 225, the module/type ground: tools/probe/r11u225repro/README.md):
// every law reads its own R11U225_<LAW>_OFF switch; R11U225_OFF drops all of
// them (the base's bytes).  R11U225_TRACE=<dir> names every firing: one file
// per process, `<dir>/<pid>.225`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u225Law(const char* sw) {
    if (getenv("R11U225_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr225(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U225_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".225";
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
#include <utility>
#include <vector>
namespace slang_uhdm {
// § initHierFillKept225 — the declared signals whose packed range carries a
// substituted struct-member path (§ initHierAtRefToken225's site records them,
// ModuleEmit's unbased-fill fold reads them): (declaring scope, name).  Empty
// (no heap block) until the substitution fires, so a design it never reaches
// allocates nothing here (§ formalRegNoHeap223v's lesson: an allocation during
// emission moves later objects' addresses, and § refFullNameThroughNamedExpr175
// registers names in address order).
inline std::vector<std::pair<const void*, std::string>>& initHierOwners225() {
    static std::vector<std::pair<const void*, std::string>> v;
    return v;
}
inline bool initHierOwner225(const void* sc, std::string_view n) {
    for (auto& e : initHierOwners225())
        if (e.first == sc && e.second == n)
            return true;
    return false;
}
} // namespace slang_uhdm
namespace slang_uhdm {
// § fillSymbolicRootOnly225v (v11u225, the adversarial verification of r11u225):
// the refinements' switches.  R11V225_OFF drops every one of them.
inline bool r11v225Law(const char* sw) {
    if (getenv("R11V225_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
} // namespace slang_uhdm
