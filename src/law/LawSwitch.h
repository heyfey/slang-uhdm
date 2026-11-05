//------------------------------------------------------------------------------
//! @file LawSwitch.h
//! @brief The one switch reader and trace writer shared by every landed pass
//
// Every pass NNN (its section in LawState.h, tests/LAWS.md) guards each of its laws with an
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
// R11UNNN_TRACE=1 prints the lines to stderr instead. With the variable unset
// nothing is opened. Since 2026-11-04 every pass traces this way: the per-pass
// writers of passes 139 to 219 (stderr prefixes, suffixed files such as
// <pid>.200E) were folded into lawTrace, so a pass-200 trace is one file.
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

// The earliest passes (38, 48, 92) read the value: set, non-empty and not "0".
inline bool envTrue(const char* v) {
    const char* s = getenv(v);
    return s && *s && *s != '0';
}

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

// Two masters: a law landed by a later pass is dropped by either pass's master.
inline bool lawOn(int pass, int landedBy, const char* sw) {
    return lawOn(pass, sw) && lawOn(landedBy, sw);
}

// Pass 224 split one ground's half of passes 112, 175, 183 and 191 behind
// R11U224_SPLIT<pass>A_OFF (§ landingSwitchReach224).
inline bool splitAOff(int pass) {
    switch (pass) {
    case 112: return envSet("R11U224_SPLIT112A_OFF");
    case 175: return envSet("R11U224_SPLIT175A_OFF");
    case 183: return envSet("R11U224_SPLIT183A_OFF");
    case 191: return envSet("R11U224_SPLIT191A_OFF");
    default: return false;
    }
}

// A landing switch: the pass that landed another pass's laws can drop just
// those (pass 210 landed 201: R11U210_LANDING201_OFF; pass 219 landed 202,
// 212 and 216: R11U219_LANDING<n>_OFF; § landingSwitchReach210/219).
inline bool landingOff(int pass) {
    switch (pass) {
    case 201: return envSet("R11U210_LANDING201_OFF");
    case 202: return envSet("R11U219_LANDING202_OFF");
    case 212: return envSet("R11U219_LANDING212_OFF");
    case 216: return envSet("R11U219_LANDING216_OFF");
    default: return false;
    }
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
inline FILE* openFile(int pass, const std::string& suffix) {
    const char* d = traceDir(pass);
    if (!d)
        return nullptr;
    std::string fn = std::string(d) + "/" + std::to_string(getpid()) + "." + suffix;
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
}
inline FILE* open(int pass) {
    Slot& s = slot(pass);
    if (s.tried)
        return s.fp;
    s.tried = true;
    const char* d = traceDir(pass);
    s.fp = (d && std::string(d) == "1") ? stderr : openFile(pass, std::to_string(pass));
    return s.fp;
}
}  // namespace lawtrace_detail

// The early passes' trace files carry their own suffix (<pid>.200E for
// ExprEmit's pass 200 trace); the caller keeps the FILE* in its own static.
// stderrWhenOne: passes 214 and 219 print to stderr when the variable is "1".
inline FILE* lawTraceFile(int pass, const char* suffix, bool stderrWhenOne = false) {
    if (stderrWhenOne) {
        const char* d = lawtrace_detail::traceDir(pass);
        if (d && std::string(d) == "1")
            return stderr;
    }
    return lawtrace_detail::openFile(pass, suffix);
}

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
