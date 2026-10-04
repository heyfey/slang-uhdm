// r11u236 (pass 236, the expression/parameter ground,
// tools/probe/r11u236repro/README.md): every law reads its own
// R11U236_<LAW>_OFF switch; R11U236_OFF drops all of them,
// restoring the base's bytes.
// R11U236_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.236`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <map>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u236On(const char* sw) {
    if (getenv("R11U236_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u236 (the adversarial verification, tools/probe/v11u236repro/README.md):
// each refinement reads its own R11V236_<X>_OFF; R11V236_OFF (or R11U236_OFF)
// drops all of them.
inline bool r11v236On(const char* sw) {
    if (getenv("R11U236_OFF") != nullptr || getenv("R11V236_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr236(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U236_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".236";
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
// § pkgDefPatSubstShared236 (ExprEmit pkgPatSubstValue arm, ParamEmit
// emitParameters): set while the declaring package's definition listing
// (AllPackages, not topView, not an import) emits a parameter's initializer;
// the map holds the one copy per substituted source object.
inline bool& pkgDefPatShare236() {
    static bool on = false;
    return on;
}
// § pkgDefPatHomeOnly236v (v11u236): the declaring package's scope (slang
// Scope*) while pkgDefPatShare236() is set; a read shares only when every
// parameter it names is declared in this scope.
inline const void*& pkgDefPatShareScope236() {
    static const void* sc = nullptr;
    return sc;
}
inline std::map<const void*, void*>& pkgDefPatShareMemo236() {
    static std::map<const void*, void*> m;
    return m;
}
} // namespace slang_uhdm
