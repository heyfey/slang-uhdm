// r11u291 (pass 291, the module/type ground,
// tools/probe/r11u291repro/README.md): every law reads its own
// R11U291_<LAW>_OFF switch; R11U291_OFF drops all of them,
// restoring the base's bytes.
//   R11U291_TPUSEOBJ_OFF      § tpUseSigBindsTpObj291 (TypeEmit.cpp)
//   R11U291_ANONMEMBNAME_OFF  § anonAggMemberChainName291 (UhdmExporter.cpp)
//   R11U291_CLSSPECDECL_OFF   § clsSpecDeclNameSpan291 (TypeEmit.cpp)
// R11U291_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.291`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>

namespace slang_uhdm {
inline bool r11u291On(const char* sw) {
    if (getenv("R11U291_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u291 (the adversarial verification of r11u291,
// tools/probe/v11u291repro/README.md): the verifier's refinements of
// § tpUseSigBindsTpObj291, each behind R11V291_<X>_OFF; R11V291_OFF drops all
// of them (the law's bytes), R11U291_OFF still drops the law with them.
//   R11V291_GENSHADOW_OFF  § tpUseGenShadowAbstains291v
//   R11V291_BODYTD_OFF     § tpUseBodyTdTargetAbstains291v
//   R11V291_CLASSTP_OFF    § tpUseClassTargetAbstains291v
inline bool r11v291On(const char* sw) {
    if (getenv("R11V291_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr291(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U291_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".291";
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
