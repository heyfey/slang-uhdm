// r10sd2 — WHICH VIEW does `vpiInstance` name?  A span-keyed, MULTISET census.
//
// Surelog emits each package TWICE — once into `design.uhdmallPackages` (the
// "def" view: `vpiTop=0`, `Class_defns` NULL) and once into
// `design.uhdmtopPackages` (the elaborated view: `vpiTop=1`, `Class_defns=323`
// for uvm_pkg) — and every object under a package is likewise duplicated, once
// per view.  `vpiInstance` therefore has THREE possible states, not two: NULL,
// the ALL-view package, or the TOP-view package.  A census that only asks
// "null or not" (ct2inst.cpp) cannot see a view swap, and a census that keeps
// one value per key (same) cannot see a population imbalance among duplicates.
//
// This tool keys every object carrying a singular `Instance()` by
// (uhdmType, VpiName, line:col-endline:endcol) — VpiFile is excluded because our
// emission leaves it empty — and reports, per key, the MULTISET of Instance
// states on each side.  Keys where our multiset holds a package the golden
// multiset does not are exactly the candidates for the `LHS:<null>` head.
//
// build: g++ -O2 -std=c++17 ct2view.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2view
// usage: ct2view <golden.uhdm> <ours.uhdm> [maxexamples]
#include <uhdm/uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

using namespace UHDM;

static int g_maxex = 12;

static std::string span(const BaseClass* p) {
    std::ostringstream k;
    k << UhdmName(p->UhdmType()) << "|" << p->VpiName() << "|" << p->VpiLineNo()
      << ":" << p->VpiColumnNo() << "-" << p->VpiEndLineNo() << ":"
      << p->VpiEndColumnNo();
    return k.str();
}

struct Side {
    std::map<std::string, std::map<std::string, int>> byKey;  // key -> state -> n
};

static void collect(const char* path, Side& s) {
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(path));
    if (h.empty()) { std::cerr << "RESTORE_FAIL " << path << "\n"; exit(3); }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::map<const BaseClass*, std::string> pkgState;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages())
            pkgState[p] = "ALL:" + std::string(p->VpiName());
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            pkgState[p] = "TOP:" + std::string(p->VpiName());
    for (const auto& [p, id] : ser.AllObjects()) {
        if (!p) continue;
        const typespec* t = any_cast<const typespec*>(p);
        const variables* v = any_cast<const variables*>(p);
        const task_func* f = any_cast<const task_func*>(p);
        const ports* q = any_cast<const ports*>(p);
        const clocking_block* cb = any_cast<const clocking_block*>(p);
        const instance* in = any_cast<const instance*>(p);
        if (!(t || v || f || q || cb || in)) continue;
        const instance* val = t    ? t->Instance()
                              : v  ? v->Instance()
                              : f  ? f->Instance()
                              : q  ? q->Instance()
                              : cb ? cb->Instance()
                                   : in->Instance();
        std::string st = "<null>";
        if (val) {
            auto it = pkgState.find((const BaseClass*)val);
            st = it != pkgState.end()
                     ? it->second
                     : ("OTHER:" + std::string(UhdmName(val->UhdmType())) + "(" +
                        std::string(val->VpiName()) + ")");
        }
        s.byKey[span(p)][st]++;
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct2view <golden.uhdm> <ours.uhdm> [maxex]\n";
        return 2;
    }
    if (argc > 3) g_maxex = atoi(argv[3]);
    Side G, O;
    collect(argv[1], G);
    collect(argv[2], O);
    std::cout << "keys: golden=" << G.byKey.size() << " ours=" << O.byKey.size()
              << "\n";
    // Whole-database state totals first: the population picture.
    std::map<std::string, int> gt, ot;
    for (auto& [k, m] : G.byKey)
        for (auto& [st, n] : m) gt[st] += n;
    for (auto& [k, m] : O.byKey)
        for (auto& [st, n] : m) ot[st] += n;
    std::cout << "\nvpiInstance state totals (whole database)\n";
    printf("%-34s %9s %9s %9s\n", "state", "GOLDEN", "OURS", "DELTA");
    std::vector<std::string> sts;
    for (auto& [k, v] : gt) sts.push_back(k);
    for (auto& [k, v] : ot)
        if (!gt.count(k)) sts.push_back(k);
    std::sort(sts.begin(), sts.end());
    for (const auto& st : sts)
        printf("%-34s %9d %9d %+9d\n", st.c_str(), gt[st], ot[st],
               ot[st] - gt[st]);

    // Per-key: our multiset holds a package state golden's does not.
    int nkeys = 0, shown = 0;
    std::map<std::string, int> byOwner;
    std::cout << "\nkeys where OURS names a package state GOLDEN never does "
                 "for that key:\n";
    for (const auto& [k, om] : O.byKey) {
        auto git = G.byKey.find(k);
        if (git == G.byKey.end()) continue;
        for (const auto& [st, n] : om) {
            if (st == "<null>") continue;
            int gn = git->second.count(st) ? git->second.at(st) : 0;
            if (gn > 0) continue;
            nkeys++;
            byOwner[k.substr(0, k.find('|'))]++;
            if (shown++ < g_maxex) {
                std::cout << "  " << k << "\n      golden:";
                for (const auto& [a, b] : git->second)
                    std::cout << " " << a << "=" << b;
                std::cout << "\n      ours  :";
                for (const auto& [a, b] : om) std::cout << " " << a << "=" << b;
                std::cout << "\n";
            }
        }
    }
    std::cout << "TOTAL such (key,state) pairs: " << nkeys << "\n  by owner:";
    for (const auto& [k, v] : byOwner) std::cout << " " << k << "=" << v;
    std::cout << "\n";
    return 0;
}
