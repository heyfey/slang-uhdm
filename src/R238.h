// r11u238 (pass 238, the expression/parameter ground,
// tools/probe/r11u238repro/README.md): every law reads its own
// R11U238_<LAW>_OFF switch; R11U238_OFF drops all of them,
// restoring the base's bytes.
// R11U238_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.238`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <map>
#include <string>
#include <vector>
#include <unistd.h>

namespace UHDM {
class ref_obj;
class ref_typespec;
class variables;
}  // namespace UHDM
namespace slang::ast {
class Symbol;
}  // namespace slang::ast

namespace slang_uhdm {
inline bool r11u238On(const char* sw) {
    if (getenv("R11U238_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u238 (the adversarial verification, tools/probe/v11u238repro/README.md):
// each refinement reads its own R11V238_<NAME>_OFF; R11V238_OFF drops all of
// them, and R11U238_OFF drops them with the laws they refine.
inline bool r11u238vOn(const char* sw) {
    if (getenv("R11U238_OFF") != nullptr || getenv("R11V238_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr238(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U238_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".238";
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
// § cloneForIncBindsHomeVar238 (StmtEmit ForLoop arm, drained in ParamEmit
// drainPaNameCopySrc38): a for-header loop variable -> the HOME listing's
// emitted object (the last and the first emission outside any import clone),
// and the import clones' loop-variable references waiting for it.
inline std::map<const slang::ast::Symbol*, UHDM::variables*>& homeForVar238() {
    static std::map<const slang::ast::Symbol*, UHDM::variables*> m;
    return m;
}
inline std::map<const slang::ast::Symbol*, UHDM::variables*>&
homeForVarFirst238() {
    static std::map<const slang::ast::Symbol*, UHDM::variables*> m;
    return m;
}
struct CloneForIncRef238 {
    UHDM::ref_obj* ref;
    const slang::ast::Symbol* sym;
    bool classClone;  // an out-of-body class method's clone: the FIRST home
                      // emission (the class listing), else the LAST
};
inline std::vector<CloneForIncRef238>& cloneForIncRefs238() {
    static std::vector<CloneForIncRef238> v;
    return v;
}
// § foreachClassPropStringTsShared238: loop-variable ref_typespecs left to
// pendingLoopVarTs9's mirror; ParamEmit drainShareDefParamTs gives any the
// mirror missed the old fresh string_typespec.
inline std::vector<UHDM::ref_typespec*>& deferredStrTs238() {
    static std::vector<UHDM::ref_typespec*> v;
    return v;
}
}  // namespace slang_uhdm
