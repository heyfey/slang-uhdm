// r11u303 (pass 303, the module/type ground,
// tools/probe/r11u303repro/README.md): every law reads its own
// R11U303_<LAW>_OFF switch; R11U303_OFF drops all of them,
// restoring the base's bytes.
//   R11U303_SELBASETRIM_OFF     § genConnSelBaseNameTrim303 (ModuleEmit.cpp)
//   R11U303_BOUNDSYSCLONE_OFF   § bodyTdBoundSysCallClone303 (TypeEmit.cpp)
//   R11U303_SYSARGNAME_OFF      § sysCallArgRefScopedName303 (TypeEmit.cpp)
//   R11U303_MODARRSELNAME_OFF   § modArrBoundSelUnstored303 (ModuleEmit.cpp)
//   R11U303_MODARRIPSSPAN_OFF   § modArrBoundIpsWholeSpan303 (ModuleEmit.cpp)
//   R11U303_GENCAENUMSPAN_OFF   § genCaEnumQualWholeSpan303 (TypeEmit.cpp)
//   R11U303_GENNDASEL_OFF       § genNdaSelRhsSharesNet303 (ModuleEmit.cpp)
//   R11U303_GENNDAOP_OFF        § genNdaOpRhsFreshNet303 (ModuleEmit.cpp)
//   R11U303_CLSPARAMTD_OFF      § classParamNamedTypeTs303 (UhdmExporter.cpp)
//   R11U303_IFTERNFILL_OFF      § ifCaTernFillArmKept303 (ModuleEmit.cpp)
// The verifier's refinements (v11u303, tools/probe/v11u303repro/README.md) read
// R11V303_<X>_OFF; R11V303_OFF drops all of them and gives the law's bytes:
//   R11V303_ENUMSELQUAL_OFF     § genCaEnumSelBoundLhsQual303v (TypeEmit.cpp)
//   R11V303_NDASELCONST_OFF     § genNdaSelConstReduces303v (ModuleEmit.cpp)
//   R11V303_IFFILLIDX_OFF       § ifFillBitSelConstIdx303v (ModuleEmit.cpp)
// R11U303_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.303`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u303On(const char* sw) {
    if (getenv("R11U303_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v303On(const char* sw) {
    if (!r11u303On("R11U303_OFF") || getenv("R11V303_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr303(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U303_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".303";
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
