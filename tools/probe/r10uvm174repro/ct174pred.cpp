// r10uvm174 — THE MOVER PREDICTOR.  MEASUREMENT ONLY.  Reads a PRISTINE
// database and names every cell the law is about to move, BEFORE the patched
// sweep runs.  LHS is ALWAYS golden; this tool reads OUR side only, so a
// prediction can be made for the 956 + 1358 databases that have no golden of
// their own.
//
// A CANDIDATE is a `constant` that
//   (1) lives in a listing of `design->AllPackages` (the DEF listing),
//   (2) is reached WITHOUT crossing a `class_defn` — i.e. it sits in the
//       package's own Task_funcs, not in a class body,
//   (3) whose innermost enclosing `function`/`task` has a `::` in its VpiName
//       (Surelog's/our spelling for an out-of-body class-method DEFINITION
//       that this listing carries), and
//   (4) wears the fingerprint of OUR `$bits` fold: `vpiSize` 64,
//       `vpiConstType` 9 (`vpiUIntConst`), a `UINT:` value, and a source span
//       at least 8 columns wide — `$bits(x)` is eight characters, while a
//       written unsized decimal spans its own digits.
//
// It is an UPPER BOUND: a wide-spanned unsized decimal in such a body would be
// counted and not move.  It is never a LOWER bound violation — every cell the
// gate flips is a constant the emitter minted at a `$bits` call site inside
// exactly this window.
//
// build: g++ -O2 -std=c++17 ct174pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct174pred
// usage: ct174pred <db.uhdm> [--rows]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct174pred <db.uhdm> [--rows]\n"); return 2; }
    bool rows = argc > 2 && std::string(argv[2]) == "--rows";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { printf("NO_DESIGN\n"); return 3; }
    std::map<const BaseClass*, std::string> defPkg;
    if (auto* v = d->AllPackages())
        for (auto* o : *v) defPkg[o] = std::string(o->VpiName());

    // THE WINDOW COUNT — the SOUND upper bound at database level.  A cell can
    // only move inside an out-of-body class-method clone of a DEF package
    // listing; this counts those clones directly, without looking at any
    // constant, so a database with WINDOWS=0 provably cannot move.  (The
    // CANDIDATES count below is tighter but can MISS a cell whose folded
    // constant hangs off an unparented carrier — BuildUVMPkg's twelve
    // `+: $bits(byte)` part-select widths do, so the two numbers bracket the
    // truth from opposite sides and both are reported.)
    size_t windows = 0;
    if (auto* v = d->AllPackages())
        for (auto* p : *v)
            if (auto* tfs = p->Task_funcs())
                for (auto* t : *tfs)
                    if (std::string(t->VpiName()).find("::") != std::string::npos)
                        ++windows;

    std::vector<std::string> hits;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmconstant) continue;
        const constant* c = (const constant*)o;
        if (c->VpiSize() != 64 || c->VpiConstType() != vpiUIntConst) continue;
        const std::string val(c->VpiValue());
        if (val.rfind("UINT:", 0) != 0) continue;
        unsigned l0 = o->VpiLineNo(), l1 = o->VpiEndLineNo();
        unsigned c0 = (unsigned)o->VpiColumnNo(), c1 = (unsigned)o->VpiEndColumnNo();
        if (l1 == l0 && (c1 < c0 + 8)) continue;
        // walk up
        std::string sub, pkg;
        bool crossedClass = false;
        int g = 0;
        for (const BaseClass* p = o->VpiParent(); p && g < 128; p = p->VpiParent(), ++g) {
            auto it = defPkg.find(p);
            if (it != defPkg.end()) { pkg = it->second; break; }
            if (p->UhdmType() == uhdmclass_defn) { crossedClass = true; break; }
            if (sub.empty() &&
                (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask))
                sub = std::string(p->VpiName());
        }
        if (pkg.empty() || crossedClass) continue;
        if (sub.find("::") == std::string::npos) continue;
        char b[900];
        snprintf(b, sizeof b, "  PKGDEF:%s %s @%u:%u-%u:%u %s", pkg.c_str(),
                 sub.c_str(), l0, c0, l1, c1, val.c_str());
        hits.push_back(b);
    }
    std::sort(hits.begin(), hits.end());
    printf("CANDIDATES %zu WINDOWS %zu\n", hits.size(), windows);
    if (rows)
        for (auto& h : hits) printf("%s\n", h.c_str());
    return 0;
}
