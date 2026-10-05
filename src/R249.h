// r11u249 (pass 249, the module/type ground,
// tools/probe/r11u249repro/README.md): every law reads its own
// R11U249_<LAW>_OFF switch; R11U249_OFF drops all of them,
// restoring the base's bytes.
// R11U249_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.249`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u249On(const char* sw) {
    if (getenv("R11U249_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr249(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U249_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".249";
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
// § unitDynArrTd249 / § modDynArrTd249 — set by a typedef writer around its
// buildUnpackedArrayTypedefTs call to ask the builder's dynamic-container
// branch for the kind-marker range (defined in TypeEmit.cpp).
extern bool g249DynRangeReq;
}  // namespace slang_uhdm
namespace slang::ast {
class TypeAliasType;
}
namespace slang_uhdm {
// The one-dimension dynamic / queue / associative typedef shapes the two
// writers list (TypeEmit.cpp).
bool unitDynTdShape249(const slang::ast::TypeAliasType& ta);
}  // namespace slang_uhdm
