// r11u231 (pass 231, the module/type ground: tools/probe/r11u231repro/README.md):
// every law reads its own R11U231_<LAW>_OFF switch; R11U231_OFF drops all of
// them (the base's bytes).  R11U231_TRACE=<dir> names every firing: one file
// per process, `<dir>/<pid>.231`, its first line `OUT <-o path>`, then
// `<law> <detail>`.  The trace allocates only when R11U231_TRACE is set.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {
inline bool r11u231Law(const char* sw) {
    if (getenv("R11U231_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr231(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U231_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".231";
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


// § cloneAliasTargetOwnCopy231's record: the typedef-alias refs
// § cloneAliasFormalOwnChain214 (TaskFuncEmit) gives an import clone's formal
// copy, filled at emission and read design-final (UhdmExporter).
#include <vector>
namespace slang_uhdm {
inline std::vector<void*>& r231CloneAliasRefs() {
    static std::vector<void*> v;
    return v;
}
} // namespace slang_uhdm

// § oobClassTdFirstClassKey231's record: (the out-of-body definition's formal
// ref_typespec, the bare type name written there),
// filled at emission (TaskFuncEmit), read design-final (UhdmExporter).
#include <string>
#include <utility>
namespace slang_uhdm {
inline std::vector<std::pair<void*, std::string>>& r231OobClassTdRefs() {
    static std::vector<std::pair<void*, std::string>> v;
    return v;
}
} // namespace slang_uhdm
