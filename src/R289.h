// r11u289 (pass 289, the module/type ground,
// tools/probe/r11u289repro/README.md): every law reads its own
// R11U289_<LAW>_OFF switch; R11U289_OFF drops all of them,
// restoring the base's bytes.
//   R11U289_MODCASHARE_OFF    § caStructParamModSharesPaOperand289 (ModuleEmit.cpp)
//   R11U289_MODCACLONE_OFF    § caStructParamModClonesPaOperand289 (ModuleEmit.cpp)
//   R11U289_GENCATYPED_OFF    § genCaStructParamTypedLhsShares289 (ModuleEmit.cpp)
//   R11U289_IFCASHARE_OFF     § caStructParamIfaceSharesPaOperand289 (ModuleEmit.cpp)
//   R11U289_IFCLONEREUSE_OFF  § caStructParamIfaceCloneReused289 (ModuleEmit.cpp)
//   R11U289_IFCLONEFIRST_OFF  § caStructParamIfaceCloneReused289 (ModuleEmit.cpp, the first cell)
//   R11U289_IFSELSHARE_OFF    § caIfaceSelLhsTakesSharedRhs289 (ModuleEmit.cpp)
//   R11V289_DLYREF_OFF        § caDelayNameRefKeepsOperand289v (ModuleEmit.cpp; the verifier v11u289; R11V289_OFF drops both refinements)
//   R11V289_SELBOUNDS_OFF     § ifSelShareConstBounds289v (ModuleEmit.cpp; the verifier v11u289)
// R11U289_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.289`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>

namespace slang_uhdm {
inline bool r11u289On(const char* sw) {
    if (getenv("R11U289_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v289On(const char* sw) {
    if (getenv("R11U289_OFF") != nullptr || getenv("R11V289_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr289(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U289_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".289";
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
