// r11u223 (pass 223, the module/type ground: tools/probe/r11u223repro/README.md):
// every law reads its own R11U223_<LAW>_OFF switch; R11U223_OFF drops all of
// them (the base's bytes).  R11U223_TRACE=<dir> names every firing: one file
// per process, `<dir>/<pid>.223`, its first line `OUT <-o path>`, then
// `<law> <detail>`.
#pragma once
#include <cstdio>
#include <cstdlib>
#include <string>
#include <utility>
#include <vector>
#include <unistd.h>

#include "slang/text/SourceLocation.h"

namespace UHDM {
class ref_typespec;
}

namespace slang_uhdm {
inline bool r11u223Law(const char* sw) {
    if (getenv("R11U223_OFF") != nullptr)
        return false;
    return getenv(sw) == nullptr;
}
// v11u223 (the adversarial verification of r11u223,
// tools/probe/v11u223repro/README.md): every refinement reads its own
// R11V223_<NAME>_OFF switch; R11V223_OFF drops all of them, R11U223_OFF drops
// them with the laws they refine.
inline bool r11v223Law(const char* sw) {
    if (getenv("R11V223_OFF") != nullptr)
        return false;
    return r11u223Law(sw);
}
inline void tr223(const char* law, const std::string& detail = std::string()) {
    static FILE* tf = []() -> FILE* {
        const char* d = getenv("R11U223_TRACE");
        if (!d)
            return nullptr;
        std::string fn = std::string(d) + "/" + std::to_string(getpid()) + ".223";
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
// § tfArgScalarTdWriter223 — every subroutine formal whose data type is
// written as a bare type identifier, with that identifier's source range, in
// emission order (TaskFuncEmit records, the design-final pass in
// UhdmExporter::exportDesign reads; a vector, so the copies it mints follow
// emission order, never an address order).  The storage is reserved once (one
// mapping, never reallocated): a vector grown by push_back during emission
// frees and re-allocates heap blocks, which moved the heap addresses of later
// UHDM objects, and § refFullNameThroughNamedExpr175 (ExprEmit, the sister's
// ground) iterates Serializer::AllObjects() in ADDRESS order while registering
// fresh full-name strings, so the symbol table's tail order became a coin
// (BuildUVMPkg default: 4 of 16 concurrent draws on the unreserved draft, 0 of
// 16 reserved; 0 of 16 on the base binary; README section 9).
inline std::vector<std::pair<UHDM::ref_typespec*, slang::SourceRange>>& formalTdTokHeap223() {
    static std::vector<std::pair<UHDM::ref_typespec*, slang::SourceRange>> v = [] {
        std::vector<std::pair<UHDM::ref_typespec*, slang::SourceRange>> r;
        r.reserve(1u << 16);
        return r;
    }();
    return v;
}
// § formalRegNoHeap223v (v11u223, the adversarial verification of r11u223) —
// the reserved heap vector above did not keep MiniAmiq deterministic: its one
// 1.5 MB reservation, made at the first recorded formal DURING emission, still
// changed the heap state ahead of § refFullNameThroughNamedExpr175's
// address-order walk (ParamEmit drainPaNameCopySrc38, which runs before the
// design-final pass that reads this registry), and MiniAmiq default drew two
// hashes 8 : 8 in 16 concurrent draws on the law binary (identical uhdm-dump,
// 100 symbol-table tail strings of that family reordered) where the base
// binary and the law binary under R11U223_OFF drew one hash in 32 of 32 and 16
// of 16 (tools/probe/v11u223repro/README.md).  The registry now lives in
// static storage (no allocation at all during emission; entries beyond its
// capacity spill to the heap vector in the same order), so emission's heap
// traffic is the base's.  Switch R11V223_DETREG_OFF (the reserved heap
// vector of r11u223, R11V223_OFF with every v11u223 refinement).
struct FormalTdReg223 {
    using E = std::pair<UHDM::ref_typespec*, slang::SourceRange>;
    static constexpr size_t kCap = 1u << 16;
    E fixed[kCap];
    size_t n = 0;
    int heapMode = -1;
    void push_back(const E& e) {
        if (heapMode < 0)
            heapMode = r11v223Law("R11V223_DETREG_OFF") ? 0 : 1;
        if (heapMode == 1 || n >= kCap)
            formalTdTokHeap223().push_back(e);
        else
            fixed[n++] = e;
    }
    // Emission order: the static entries, then the spilled (or heap-mode) ones.
    template <typename F>
    void forEach(F&& f) {
        for (size_t i = 0; i < n; i++)
            f(fixed[i]);
        for (auto& e : formalTdTokHeap223())
            f(e);
    }
};
inline FormalTdReg223& formalTdTok223() {
    static FormalTdReg223 reg;
    return reg;
}
} // namespace slang_uhdm
