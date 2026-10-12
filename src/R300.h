// r11u300 (pass 300, the expression/parameter ground,
// tools/probe/r11u300repro/README.md): every law reads its own
// R11U300_<LAW>_OFF switch; R11U300_OFF drops all of them,
// restoring the base's bytes.  The laws:
//   § pkgRetCallFoldSharesCalleeRet300 R11U300_RETSHARE_OFF (ExprEmit's
//                                      user-call branch; the registry of
//                                      each listing's return expression is
//                                      written in StmtEmit)
// R11U300_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.300`, its first line `OUT <-o path>`, then
// `<law> <detail>` (a tag ending in _ABSTAIN moves nothing).
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <map>
#include <utility>

#include <uhdm/uhdm_types.h>
#include <uhdm/BaseClass.h>

namespace slang_uhdm {
inline bool r11u300On(const char* sw) {
    if (getenv("R11U300_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u300 (adversarial verification of r11u300): the verifier's refinement
//   § retShareActualFoldAbstain300v R11V300_ACTFOLD_OFF (ExprEmit, inside the
//                                      law's site); R11V300_OFF drops it and
//                                      gives the law's bytes, R11U300_OFF still
//                                      gives pristine's.  Its firing traces as
//                                      `ACTFOLD300V <caller>-><callee> <why>`.
inline bool r11v300On(const char* sw) {
    if (getenv("R11V300_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr300(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U300_TRACE");
        if (!d || !*d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".300";
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
// § pkgRetCallFoldSharesCalleeRet300's registry: the expression object a
// direct `return` of a package function was emitted with in an ELABORATED
// (TopPackages) listing, keyed by (the listing's package object, the
// subroutine's home symbol); and, for the home package's own listing, by the
// symbol alone (a package-qualified call into another package reads that one).
inline std::map<std::pair<const void*, const void*>, UHDM::any*>& retCondReg300() {
    static std::map<std::pair<const void*, const void*>, UHDM::any*> m;
    return m;
}
inline std::map<const void*, UHDM::any*>& retCondHome300() {
    static std::map<const void*, UHDM::any*> m;
    return m;
}
}  // namespace slang_uhdm
