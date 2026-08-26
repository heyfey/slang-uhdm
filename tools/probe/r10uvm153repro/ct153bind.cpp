// r10uvm153 — THE BINDING CENSUS.  MEASUREMENT ONLY; the official uhdm-cmp is
// the judge.  LHS IS ALWAYS GOLDEN (Surelog); RHS IS ALWAYS OURS.
//
// For every `ref_obj` in either database it prints one row keyed by
//     kind | name | line:col-endline:endcol
// (a MULTISET key — several objects share it: the DEF view and the ELAB view,
// and a wildcard-import clone; the two sides' groups are compared as SORTED
// MULTISETS of the binding target, never as a last-writer dict) and classifies
// the binding `vpiActual`:
//     SAME        the two multisets agree
//     GOLD-BOUND  golden binds where we are bare        (a MISSING binding)
//     OURS-BOUND  we bind where golden is bare          (an AWAY binding)
//     DIFF        both bind, different targets
//     ONLY-GOLD / ONLY-OURS   the key exists on one side only
// The binding target is spelled by KIND+NAME+SPAN, never by id (ids differ).
//
// build: g++ -O2 -std=c++17 ct153bind.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct153bind
// usage: ct153bind <golden.uhdm> <ours.uhdm> [--all] [--kind=ref_obj]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string tgt(const BaseClass* o) {
    if (!o) return "<bare>";
    char b[900];
    // The target's OWNER KIND rides in the spelling: it is what separates this
    // pass's family (a target listed on a PACKAGE) from the io_decl and
    // block-local families that share the GOLD-BOUND column.
    const BaseClass* p = o->VpiParent();
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u^%s",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(),
             p ? std::string(UhdmName(p->UhdmType())).c_str() : "none");
    return b;
}
static std::string key(const BaseClass* o) {
    char b[900];
    snprintf(b, sizeof b, "%s|%s|%u:%u-%u:%u",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static void collect(Serializer& s, std::map<std::string, std::vector<std::string>>& m,
                    const char* kindFilter) {
    for (const auto& [obj, i] : s.AllObjects()) {
        if (!obj) continue;
        const std::string k(UhdmName(obj->UhdmType()));
        if (kindFilter && k != kindFilter) continue;
        auto [single, vt, vec] = obj->GetByVpiType(700 /*vpiActual*/);
        m[key(obj)].push_back(tgt(single));
    }
    for (auto& [k, v] : m) std::sort(v.begin(), v.end());
}
static std::string join(const std::vector<std::string>& v) {
    std::string r;
    for (size_t i = 0; i < v.size(); i++) { if (i) r += " , "; r += v[i]; }
    return r;
}
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct153bind golden ours [--all] [--kind=K]\n"); return 2; }
    bool all = false;
    const char* kind = "ref_obj";
    for (int a = 3; a < argc; a++) {
        if (!strcmp(argv[a], "--all")) all = true;
        else if (!strncmp(argv[a], "--kind=", 7)) kind = argv[a] + 7;
    }
    Serializer sg, so;
    auto hg = sg.Restore(std::string(argv[1]));
    auto ho = so.Restore(std::string(argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "restore failed\n"); return 3; }
    std::map<std::string, std::vector<std::string>> G, O;
    collect(sg, G, kind);
    collect(so, O, kind);
    long same = 0, goldBound = 0, oursBound = 0, diff = 0, onlyG = 0, onlyO = 0;
    for (auto& [k, gv] : G) {
        auto it = O.find(k);
        if (it == O.end()) { onlyG++; if (all) printf("ONLY-GOLD  %s  -> %s\n", k.c_str(), join(gv).c_str()); continue; }
        const auto& ov = it->second;
        if (gv == ov) { same++; continue; }
        bool gAllBare = true, oAllBare = true;
        for (auto& x : gv) if (x != "<bare>") gAllBare = false;
        for (auto& x : ov) if (x != "<bare>") oAllBare = false;
        if (oAllBare && !gAllBare) { goldBound++; printf("GOLD-BOUND %s  G=[%s]  O=[%s]\n", k.c_str(), join(gv).c_str(), join(ov).c_str()); }
        else if (gAllBare && !oAllBare) { oursBound++; printf("OURS-BOUND %s  G=[%s]  O=[%s]\n", k.c_str(), join(gv).c_str(), join(ov).c_str()); }
        else { diff++; if (all) printf("DIFF       %s  G=[%s]  O=[%s]\n", k.c_str(), join(gv).c_str(), join(ov).c_str()); }
    }
    for (auto& [k, ov] : O) if (!G.count(k)) { onlyO++; if (all) printf("ONLY-OURS  %s  -> %s\n", k.c_str(), join(ov).c_str()); }
    printf("-- kind=%s SAME=%ld GOLD-BOUND=%ld OURS-BOUND=%ld DIFF=%ld ONLY-GOLD=%ld ONLY-OURS=%ld\n",
           kind, same, goldBound, oursBound, diff, onlyG, onlyO);
    return 0;
}
