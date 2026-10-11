// r11u286 (pass 286, the expression/parameter ground,
// tools/probe/r11u286repro/README.md): every law reads its own
// R11U286_<LAW>_OFF switch; R11U286_OFF drops all of them,
// restoring the base's bytes.
// R11U286_TRACE=<dir> names every firing and abstention: one file per
// process, `<dir>/<pid>.286`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>
#include <string_view>
#include <vector>
#include <set>
#include <map>
#include <utility>
#include <uhdm/uhdm.h>

namespace slang_uhdm {
inline bool r11u286On(const char* sw) {
    if (getenv("R11U286_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// The verifier's refinements (v11u286): R11V286_<X>_OFF each; R11U286_OFF
// drops them with the laws.
inline bool r11v286On(const char* sw) {
    if (getenv("R11U286_OFF") != nullptr || getenv("R11V286_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
inline void tr286(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U286_TRACE");
        if (!d || !*d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".286";
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
// § elabCastKeyBindsDefNet286: the definition listing's minted cast-pattern
// key wires, by (definition name, key name).
inline std::map<std::pair<std::string, std::string>, UHDM::logic_net*>& castKeyDefNets286() {
    static std::map<std::pair<std::string, std::string>, UHDM::logic_net*> m;
    return m;
}
// The wires an elaborated instance minted under the definition's name, not
// yet adopted by the definition listing.
inline std::set<UHDM::logic_net*>& castKeyAdopt286() {
    static std::set<UHDM::logic_net*> v;
    return v;
}
}  // namespace slang_uhdm
