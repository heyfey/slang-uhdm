// r11u283 (pass 283, the module/type ground,
// tools/probe/r11u283repro/README.md): every law reads its own
// R11U283_<LAW>_OFF switch; R11U283_OFF drops all of them,
// restoring the base's bytes.
//   R11U283_PROGLAST_OFF     § progDefKeepsLastInstProcs283       (ModuleEmit.cpp)
//   R11U283_PROGGENDUP_OFF   § progGenDupFirstSpan283             (ModuleEmit.cpp)
//   R11U283_DEFGENCOMMA_OFF  § defGenCaCommaListSpan283           (ModuleEmit.cpp)
//   R11U283_IFPROCFIRST_OFF  § ifaceInstFirstProcsShared283       (ModuleEmit.cpp)
//   R11U283_IFVIEWNOPROC_OFF § ifacePortViewNoProcs283            (ModuleEmit.cpp)
//   R11U283_BINDDISP_OFF     § bindChildDisplayScopedNames283     (ModuleEmit.cpp)
//   R11U283_SCOPEDRET_OFF    § scopedClassRetQualSpan283          (TaskFuncEmit.cpp)
// The verifier's refinement (v11u283, tools/probe/v11u283repro/README.md) reads
// r11v283On: R11V283_OFF gives the law's bytes, R11U283_OFF still pristine's.
//   R11V283_SRCORDER_OFF     § progLastInstSrcOrder283v           (ModuleEmit.cpp)
// R11U283_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.283`, its first line `OUT <-o path>`, then `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u283On(const char* sw) {
    if (getenv("R11U283_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline bool r11v283On(const char* sw) {
    if (getenv("R11U283_OFF") != nullptr || getenv("R11V283_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr283(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U283_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".283";
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
