//------------------------------------------------------------------------------
//! @file LawSwitch.h
//! @brief The one switch reader and trace writer shared by every landed pass
//
// Every pass NNN (src/RNNN.h, tests/LAWS.md) guards each of its laws with an
// environment switch so a verifier can drop one law, one pass, or one pass's
// refinements and get the earlier bytes back:
//   lawOn(NNN, "R11UNNN_<LAW>_OFF")   false when R11UNNN_OFF or the switch is set
//   fixOn(NNN, "R11VNNN_<X>_OFF")     false when R11VNNN_OFF or the switch is set
//   lawFixOn(NNN, sw)                 false when R11UNNN_OFF, R11VNNN_OFF or sw is set
// With no variable set every law fires and the output is the same as if the
// switches did not exist.
//
// lawTrace(NNN, law, detail) appends one line per firing or abstention to
// <dir>/<pid>.NNN when R11UNNN_TRACE=<dir> (or, for the early passes 204 to
// 233, R11VNNN_TRACE) is set; the first line of the file is `OUT <-o path>`.
// With the variable unset no file is opened.
//
// SPDX-License-Identifier: MIT
//------------------------------------------------------------------------------
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <unistd.h>

namespace slang_uhdm {

inline bool envSet(const char* v) { return getenv(v) != nullptr; }

inline bool lawOn(int pass, const char* sw) {
    char m[32];
    snprintf(m, sizeof m, "R11U%d_OFF", pass);
    return !envSet(m) && !envSet(sw);
}

inline bool fixOn(int pass, const char* sw) {
    char m[32];
    snprintf(m, sizeof m, "R11V%d_OFF", pass);
    return !envSet(m) && !envSet(sw);
}

inline bool lawFixOn(int pass, const char* sw) {
    return lawOn(pass, sw) && fixOn(pass, sw);
}

namespace lawtrace_detail {
constexpr int kMaxPass = 1024;
struct Slot {
    bool tried = false;
    FILE* fp = nullptr;
};
inline Slot& slot(int pass) {
    static Slot slots[kMaxPass];
    return slots[pass < kMaxPass ? pass : 0];
}
inline const char* traceDir(int pass) {
    char v[32];
    snprintf(v, sizeof v, "R11U%d_TRACE", pass);
    const char* d = getenv(v);
    if (!d || !*d) {
        snprintf(v, sizeof v, "R11V%d_TRACE", pass);
        d = getenv(v);
    }
    return (d && *d) ? d : nullptr;
}
inline FILE* open(int pass) {
    Slot& s = slot(pass);
    if (s.tried)
        return s.fp;
    s.tried = true;
    const char* d = traceDir(pass);
    if (!d)
        return nullptr;
    std::string fn = std::string(d) + "/" + std::to_string(getpid()) + "." +
                     std::to_string(pass);
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
    s.fp = fp;
    return fp;
}
}  // namespace lawtrace_detail

inline bool lawTraceOn(int pass) {
    return lawtrace_detail::traceDir(pass) != nullptr;
}

inline void lawTrace(int pass, const char* law,
                     const std::string& detail = std::string()) {
    if (FILE* fp = lawtrace_detail::open(pass)) {
        fprintf(fp, "%s %s\n", law, detail.c_str());
        fflush(fp);
    }
}

}  // namespace slang_uhdm
