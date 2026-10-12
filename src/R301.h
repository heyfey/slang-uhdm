// r11u301 (pass 301, the module/type ground,
// tools/probe/r11u301repro/README.md): every law reads its own
// R11U301_<LAW>_OFF switch; R11U301_OFF drops all of them,
// restoring the base's bytes.
//   R11U301_CAINSIDE_OFF        § caInsideRhsClonesCell301 (ModuleEmit.cpp)
//   R11U301_SELPARAMREUSE_OFF   § caSelLhsParamReuseAnyEnc301 (ModuleEmit.cpp)
//   R11U301_CONSTVARINIT_OFF    § caConstVarFoldNeedsReducibleInit301 (ModuleEmit.cpp)
//   R11U301_TERNREAL_OFF        § caTernRealArmKept301 (ModuleEmit.cpp)
//   R11U301_TERNTPQUERY_OFF     § caTernTypeParamQueryNoFold301 (ModuleEmit.cpp)
//   R11U301_TERNPARAMARM_OFF    § caTernParamArmReusesPaConst301 (ModuleEmit.cpp)
//   R11U301_SETCASTW_OFF        § caStructSetterCastMemberWidthNoFold301 (ModuleEmit.cpp)
//   R11U301_DLYLITFRESH_OFF     § caDlyParamLitRhsFresh301 (ModuleEmit.cpp)
//   R11U301_IFDLYCONST_OFF      § ifCaConstDelayPerCell301 (ModuleEmit.cpp)
//   R11U301_FILLAGGELAB_OFF     § caFillPackedAggElabSharesDef301 (ModuleEmit.cpp)
//   R11U301_PUREPROTO_OFF       § unitTdPureProtoFormalWriter301 (UhdmExporter.cpp)
//   R11U301_PUREAGG_OFF         § pureProtoInlineAggSpans301 (TaskFuncEmit.cpp)
// v11u301 (the adversarial verification of r11u301,
// tools/probe/v11u301repro/README.md): each refinement reads its own
// R11V301_<X>_OFF switch; R11V301_OFF drops all of them (the law's bytes),
// and R11U301_OFF still drops every law and refinement (pristine's bytes).
//   R11V301_CALLTOP_OFF         § constVarNestedCallFolds301v (ModuleEmit.cpp)
//   R11V301_CASTWQUAL_OFF       § setCastWidthParenQualFolds301v (ModuleEmit.cpp)
//   R11V301_XZLEAD_OFF          § ternParamArmLeadXzOnly301v (ModuleEmit.cpp)
// R11U301_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.301`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <utility>
#include <vector>

namespace slang_uhdm {
inline bool r11u301On(const char* sw) {
    if (getenv("R11U301_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v301On(const char* sw) {
    if (getenv("R11V301_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr301(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U301_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".301";
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
