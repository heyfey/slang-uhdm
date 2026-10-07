// r11u270 (pass 270, the expression/parameter ground,
// tools/probe/r11u270repro/README.md): every law reads its own
// R11U270_<LAW>_OFF switch; R11U270_OFF drops all of them,
// restoring the base's bytes.
// R11U270_TRACE=<dir> names every firing: one file per process,
// `<dir>/<pid>.270`, its first line `OUT <-o path>`, then `<law> <detail>`
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
inline bool r11u270On(const char* sw) {
    if (getenv("R11U270_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// (r11u272: the r11v270On helper pre-written here for a verifier that wrote
// no fix was never called; removed, v11u270repro README's finding.)
// the trace is on: callers build their detail strings only then (no heap
// traffic while the design is emitted when it is off)
inline bool tr270On() {
    static const bool on = getenv("R11U270_TRACE") != nullptr;
    return on;
}
inline void tr270(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U270_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".270";
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
// § insideSetParamFoldKeepsPa270 — the design-final half (defined in
// ExprEmit.cpp, called from ParamEmit's drainPaNameCopySrc38).
void insideSetParamPaDrain270();
// § insideSetParamFoldKeepsPa270 — the case-inside item record (StmtEmit).
void insidePaRecordCase270(const slang::ast::Expression& member, UHDM::BaseClass* e,
                           const UHDM::BaseClass* op);
// § enumAliasCastBindsImportCopy270 — the casts ExprEmit recorded (read by
// ParamEmit's drainPaNameCopySrc38).
size_t enumAliasCastN270();
void enumAliasCastRec270(size_t i, UHDM::ref_typespec*& rt,
                         const slang::ast::Symbol*& sym);

}  // namespace slang_uhdm
