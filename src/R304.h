// r11u304 (pass 304, the expression/parameter ground,
// tools/probe/r11u304repro/README.md): every law reads its own
// R11U304_<LAW>_OFF switch; R11U304_OFF drops all of them,
// restoring the base's bytes.  The laws:
//   § tfBodyTypedefIsItem304           R11U304_TDITEM_OFF (StmtEmit, the
//                                      subroutine body's wrapper begin anchor)
//   § tfBodyTypedefForcesBegin304      R11U304_TDBEGIN_OFF (StmtEmit,
//                                      emitStmt's entry: the wrapper begin of a
//                                      one-statement body written with a typedef)
//   § uninstIfaceForeachParamOwnTs304  R11U304_UIPARAMTS_OFF (StmtEmit, the
//                                      foreach array reference's typespec)
//   § genCaCastTdAliasScopedName304    R11U304_CASTALIAS_OFF (ExprEmit, the
//                                      module-scope cast clone's Typedef_alias)
//   § hpOpIdxNestedSelByPath304        R11U304_NESTSEL_OFF (ExprEmit,
//                                      emitMixedHierPath's tail)
// R11U304_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.304`, its first line `OUT <-o path>`, then
// `<law> <detail>` (a tag ending in _ABSTAIN moves nothing).
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u304On(const char* sw) {
    if (getenv("R11U304_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u304 (the adversarial verification, tools/probe/v11u304repro/README.md):
// the refinements read R11V304_<X>_OFF, R11V304_OFF dropping all of them
// (giving the law binary's bytes); R11U304_OFF still drops everything.
//   § hpOpIdxTernTrueKeepsIdxLoc304v   R11V304_TERNTRUE_OFF (ExprEmit,
//                                      hpOpIdxNestedSelByPath304's walk)
//   § castAliasSignCastRhsNoClone304v  R11V304_SIGNCAST_OFF (ExprEmit,
//                                      genCaCastTdAliasScopedName304's gate)
inline bool r11v304On(const char* sw) {
    if (getenv("R11V304_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr304(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U304_TRACE");
        if (!d || !*d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".304";
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
