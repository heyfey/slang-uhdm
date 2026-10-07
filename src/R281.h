// r11u281 (pass 281, the module/type ground,
// tools/probe/r11u281repro/README.md): every law reads its own
// R11U281_<LAW>_OFF switch; R11U281_OFF drops all of them,
// restoring the base's bytes.
//   R11U281_TPPATNEST_OFF    § defNetTpPatNestedSig281             (UhdmExporter.cpp)
//   R11U281_TPREBINDSPAN_OFF § tpRebindSpanDiffers281              (UhdmExporter.cpp)
//   R11U281_TPPORTSPAN_OFF   § tpElabPortRebindSpanDiffers281      (UhdmExporter.cpp)
//   R11U281_IFTPSHARE_OFF    § ifaceInstTypeParamSharesDef281      (UhdmExporter.cpp)
//   R11U281_IFTPUSE_OFF      § ifaceTpUseBindsDefDefault281        (UhdmExporter.cpp)
// R11U281_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.281`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u281On(const char* sw) {
    if (getenv("R11U281_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u281 (adversarial verification of r11u281, tools/probe/v11u281repro/README.md):
// R11V281_OFF drops every refinement (the law's bytes); each reads its own switch.
//   R11V281_PATNAMED_OFF  § tpPatNestNamedChain281v  (UhdmExporter.cpp)
//   R11V281_MULTIDECL_OFF § ifTpUseMultiDeclShared281v (UhdmExporter.cpp)
inline bool r11v281On(const char* sw) {
    if (getenv("R11U281_OFF") != nullptr || getenv("R11V281_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr281(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U281_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".281";
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
