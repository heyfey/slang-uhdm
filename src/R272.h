// r11u272 (pass 272, the expression/parameter ground,
// tools/probe/r11u272repro/README.md): every law reads its own
// R11U272_<LAW>_OFF switch; R11U272_OFF drops all of them,
// restoring the base's bytes.
// R11U272_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.272`, its first line `OUT <-o path>`, then `<law> <detail>`
// (an abstention reads `<law> abstain <detail>`).
#pragma once
#include <cstdio>
#include <cstdlib>
#include <set>
#include <string>
#include <unistd.h>

namespace UHDM {
class ref_typespec;
class BaseClass;
}
namespace slang::ast {
class Symbol;
class Expression;
}

namespace slang_uhdm {
inline bool r11u272On(const char* sw) {
    if (getenv("R11U272_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// the trace is on: callers build their detail strings only then (no heap
// traffic while the design is emitted when it is off)
inline bool tr272On() {
    static const bool on = getenv("R11U272_TRACE") != nullptr;
    return on;
}
inline void tr272(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U272_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".272";
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

namespace slang_uhdm {
// § leftoverTsCopyPerElabUse272 — the record: the elaborated param_assigns
// whose value is the parameter's default written as a bare or
// package-qualified parameter name (ParamEmit emitParameters).
void lotsValueCopyRec272(const UHDM::BaseClass* pa);
bool lotsValueCopy272(const UHDM::BaseClass* pa);
}  // namespace slang_uhdm
