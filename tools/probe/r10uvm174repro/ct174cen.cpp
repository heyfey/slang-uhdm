// r10uvm174 — THE SYSTEM-CALL FOLD CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden (Surelog); RHS is ALWAYS ours.
//
// One row per SYSTEM-CALL POSITION.  A position is (listing, home, name,
// line, start column) — the source site a `$bits` / `$size` / `$clog2` / …
// was written at.  At that site a producer either KEPT a `sys_func_call` or
// FOLDED it to a `constant`; the row records which, and the join over the two
// databases gives the four-way table the pass needs.
//
// The LISTING is read STRUCTURALLY, so both producers answer it the same way:
// walk the object's parent chain and stop at the first ancestor that is a
// member of `design->AllPackages` (PKGDEF), `design->TopPackages` (PKGELAB),
// `design->AllModules` (MODDEF), `design->TopModules` (MODELAB) or
// `design->AllClasses` (CLASSDEF).
//
// The HOME is the innermost enclosing `function`/`task` plus whether the walk
// to the listing crosses a `class_defn`, plus whether the subroutine's own
// VpiName carries a `::` (Surelog's spelling for an OUT-OF-BODY definition
// that `UhdmWriter::writePackage` left in the package's Task_funcs).
//
// build: g++ -O2 -std=c++17 ct174cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct174cen
// usage: ct174cen <db.uhdm> [--all]      (default: only type-query names)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

struct Listings {
    std::map<const BaseClass*, std::string> tag;
    void add(const std::vector<const BaseClass*>* v, const char* t) {
        if (!v) return;
        for (auto* o : *v) tag[o] = t;
    }
};

static bool isTypeQuery(const std::string& n) {
    static const std::set<std::string> k = {
        "$bits",   "$size",  "$clog2",   "$high",       "$low",
        "$left",   "$right", "$increment", "$dimensions",
        "$unpacked_dimensions", "$countones", "$typename", "$isunbounded"};
    return k.count(n) != 0;
}

struct Pos {
    std::string listing;      // PKGDEF:<name> / PKGELAB:<name> / MOD… / CLASSDEF…
    std::string home;         // sub kind + name (+ CLASSBODY / OOBNAME markers)
    std::string name;         // $bits …
    unsigned line = 0, col = 0;
    bool operator<(const Pos& o) const {
        return std::tie(listing, home, name, line, col) <
               std::tie(o.listing, o.home, o.name, o.line, o.col);
    }
};

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct174cen <db.uhdm> [--all]\n"); return 2; }
    bool all = argc > 2 && std::string(argv[2]) == "--all";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { printf("NO_DESIGN\n"); return 3; }
    Listings L;
    if (auto* v = d->AllPackages())
        for (auto* o : *v) L.tag[o] = "PKGDEF:" + std::string(o->VpiName());
    if (auto* v = d->TopPackages())
        for (auto* o : *v) L.tag[o] = "PKGELAB:" + std::string(o->VpiName());
    if (auto* v = d->AllModules())
        for (auto* o : *v) L.tag[o] = "MODDEF:" + std::string(o->VpiDefName());
    if (auto* v = d->TopModules())
        for (auto* o : *v) L.tag[o] = "MODELAB:" + std::string(o->VpiDefName());
    if (auto* v = d->AllClasses())
        for (auto* o : *v) L.tag[o] = "CLASSDEF:" + std::string(o->VpiName());

    // Position -> "KEEP" or "FOLD".  Both are collected in one walk; the join
    // is done by the python scorer over two of these listings.
    std::map<Pos, std::string> keep;   // sys_func_call sites, value = arg faces
    // constants indexed by (line,col) for the FOLD half
    std::map<std::string, std::vector<std::string>> constAt;

    auto describe = [&](const BaseClass* o, std::string& listing,
                        std::string& home) {
        listing = "-";
        home = "-";
        bool crossedClass = false;
        std::string sub;
        int g = 0;
        for (const BaseClass* p = o->VpiParent(); p && g < 128;
             p = p->VpiParent(), ++g) {
            auto it = L.tag.find(p);
            if (it != L.tag.end()) { listing = it->second; break; }
            if (p->UhdmType() == uhdmclass_defn) { crossedClass = true; continue; }
            if (sub.empty() && (p->UhdmType() == uhdmfunction ||
                                p->UhdmType() == uhdmtask)) {
                sub = std::string(UhdmName(p->UhdmType())) + ":" +
                      std::string(p->VpiName());
            }
        }
        if (sub.empty()) sub = "<none>";
        bool oobName = sub.find("::") != std::string::npos;
        home = sub + (crossedClass ? "|CLASSBODY" : "|PKGLIST") +
               (oobName ? "|OOBNAME" : "|BARENAME");
    };

    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmconstant) {
            char b[64];
            snprintf(b, sizeof b, "%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo());
            const constant* c = (const constant*)o;
            std::string listing, home;
            describe(o, listing, home);
            constAt[b].push_back(listing + " " + home + " " +
                                 std::string(c->VpiValue()));
            continue;
        }
        if (o->UhdmType() != uhdmsys_func_call) continue;
        const sys_func_call* sf = (const sys_func_call*)o;
        std::string nm(sf->VpiName());
        if (!all && !isTypeQuery(nm)) continue;
        Pos p;
        describe(o, p.listing, p.home);
        p.name = nm;
        p.line = o->VpiLineNo();
        p.col = (unsigned)o->VpiColumnNo();
        std::string args;
        if (auto* a = sf->Tf_call_args()) {
            for (auto* x : *a) {
                args += std::string(UhdmName(x->UhdmType()));
                args += "(";
                args += x->VpiName();
                args += ")";
                args += " ";
            }
        } else
            args = "<noargs>";
        keep[p] = args;
    }
    for (auto& [p, args] : keep)
        printf("KEEP\t%s\t%s\t%s\t%u\t%u\t%s\n", p.listing.c_str(),
               p.home.c_str(), p.name.c_str(), p.line, p.col, args.c_str());
    for (auto& [lc, v] : constAt)
        for (auto& r : v) printf("CONST\t%s\t%s\n", lc.c_str(), r.c_str());
    return 0;
}
