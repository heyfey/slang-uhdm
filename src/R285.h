// r11u285 (pass 285, the module/type ground,
// tools/probe/r11u285repro/README.md): every law reads its own
// R11U285_<LAW>_OFF switch; R11U285_OFF drops all of them,
// restoring the base's bytes.
//   R11U285_CLSIMPTDSHARE_OFF § clsImpCopyTdBindsContainerListing285 (ModuleEmit.cpp)
//   R11U285_IMPHPNAME_OFF     § impCopyInitHierPathMemberName285   (ModuleEmit.cpp)
//   R11U285_CLONEMEMBNAME_OFF § cloneOwnAggMemberChainName285   (UhdmExporter.cpp)
//   R11U285_CLONEMEMBTYPE_OFF § cloneMembTdOwnCopy285           (UhdmExporter.cpp)
// R11U285_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.285`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u285On(const char* sw) {
    if (getenv("R11U285_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v285On(const char* sw) {
    if (getenv("R11U285_OFF") != nullptr || getenv("R11V285_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr285(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U285_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".285";
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
