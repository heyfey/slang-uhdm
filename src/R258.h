// r11u258 (pass 258, the expression/parameter ground,
// tools/probe/r11u258repro/README.md): every law reads its own
// R11U258_<LAW>_OFF switch; R11U258_OFF drops all of them,
// restoring the base's bytes.
// R11U258_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.258`, its first line `OUT <-o path>`, then `<law> <detail>`.
// The verifier's refinement (tools/probe/v11u258repro/README.md, the
// adversarial verification of r11u258) reads its own R11V258_<FIX>_OFF switch;
// R11V258_OFF drops it, restoring the law's bytes, and R11U258_OFF drops it
// too, restoring pristine's.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <map>
#include <utility>
#include <vector>

namespace UHDM {
class foreach_stmt;
class ref_typespec;
class ref_var;
class typespec;
}  // namespace UHDM

namespace slang_uhdm {
inline bool r11u258On(const char* sw) {
    if (getenv("R11U258_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v258On(const char* sw) {
    if (getenv("R11U258_OFF") != nullptr || getenv("R11V258_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr258(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U258_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".258";
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
// § cloneLoopVarAssocIdxTs258: the clone's shared loop-variable object of a
// foreach over an associative array whose index is not a class, string or int
// gets the index typespec only after UhdmExporter's clone-body member binder
// (§ pkgCloneMember10) has run, at the head of ParamEmit
// drainUnsizedBasedRhs106, and is parented there at its home foreach_stmt:
// golden's DeepClone resolved the body's `range.min` while the shared object
// was still unresolved, so the member reference stays unbound.
struct AssocIdx258 {
    UHDM::ref_typespec* rt = nullptr;
    UHDM::typespec* ts = nullptr;
    UHDM::ref_var* sh = nullptr;
    std::string key;
};
inline std::vector<AssocIdx258>& deferredAssocIdxTs258() {
    static std::vector<AssocIdx258> v;
    return v;
}
// The HOME foreach_stmt of every non-copy foreach, by the foreach keyword's
// location: [0] the definition-view listing's, [1] the elaborated body's.
inline std::map<std::string, std::pair<UHDM::foreach_stmt*, UHDM::foreach_stmt*>>& homeForeach258() {
    static std::map<std::string, std::pair<UHDM::foreach_stmt*, UHDM::foreach_stmt*>> m;
    return m;
}
}  // namespace slang_uhdm
