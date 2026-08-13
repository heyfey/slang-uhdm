// r10sd4 — WHO POINTS AT THE FAILING RHS OBJECT?  Every relation, both sides.
//
// The head's `m_failedRhs` is a specific pointer: OUR `uhdmtopPackages` copy of
// `uvm_pkg`.  Two `SafeCompare` arms can put it there (BaseClass.h:186-224):
//
//   SINGULAR  -> m_failedRhs = the CHILD      => some object's singular slot
//                                                HOLDS that package and golden's
//                                                twin slot is null.
//   VECTOR    -> m_failedRhs = the CONTAINER  => that package IS the object
//                                                being compared, and one of its
//                                                own vectors is NULL in golden
//                                                and non-empty in ours.
//
// sd2 read the print as SINGULAR and named `vpiInstance` as the only relation
// that can hold a package.  `ct4mut2` NULLED every one of OUR 6818
// `Instance()`-holders of that exact pointer, one at a time, and NOT ONE of them
// removed the failure — so the singular-`vpiInstance` reading is REFUTED by
// mutation, not by argument.  This tool asks the question without assuming the
// relation: it sweeps all 154 VPI relations over every object in BOTH databases
// and reports every singular slot and every vector that references the failing
// package, grouped by owner class and relation name.
//
// build: g++ -O2 -std=c++17 ct4ref.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4ref
// usage: ct4ref <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

struct Rel { int id; const char* name; };
static const Rel kRels[] = {
#include "ct2rels.inc"
};
static const int kNRels = sizeof(kRels) / sizeof(kRels[0]);

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo()) + "-" +
         std::to_string(p->VpiEndLineNo()) + ":" +
         std::to_string(p->VpiEndColumnNo());
    return s;
}

static void sweep(const char* tag, Serializer& s, const BaseClass* target,
                  int maxex) {
    std::map<std::string, int> sing, vec;
    std::map<std::string, std::vector<std::string>> ex;
    for (const auto& [p, i] : s.AllObjects()) {
        if (!p || p == target) continue;
        vpiHandle ah = NewVpiHandle(p);
        for (int k = 0; k < kNRels; k++) {
            if (vpiHandle x = vpi_handle(kRels[k].id, ah)) {
                if ((const BaseClass*)((uhdm_handle*)x)->object == target) {
                    std::string key = std::string(UhdmName(p->UhdmType())) + " ." +
                                      kRels[k].name;
                    sing[key]++;
                    if ((int)ex[key].size() < maxex) ex[key].push_back(ident(p));
                }
            }
            if (vpiHandle it = vpi_iterate(kRels[k].id, ah)) {
                while (vpiHandle e = vpi_scan(it)) {
                    if ((const BaseClass*)((uhdm_handle*)e)->object == target) {
                        std::string key = std::string(UhdmName(p->UhdmType())) +
                                          " ." + kRels[k].name + "[]";
                        vec[key]++;
                        if ((int)ex[key].size() < maxex) ex[key].push_back(ident(p));
                    }
                }
            }
        }
    }
    std::cout << "\n=== " << tag << "  referrers of " << ident(target) << "\n";
    std::cout << "  -- SINGULAR slots --\n";
    for (auto& [k, n] : sing) {
        printf("  %-46s %6d\n", k.c_str(), n);
        for (auto& e : ex[k]) std::cout << "        e.g. " << e << "\n";
    }
    if (sing.empty()) std::cout << "  (none)\n";
    std::cout << "  -- VECTOR memberships --\n";
    for (auto& [k, n] : vec) {
        printf("  %-46s %6d\n", k.c_str(), n);
        for (auto& e : ex[k]) std::cout << "        e.g. " << e << "\n";
    }
    if (vec.empty()) std::cout << "  (none)\n";
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct4ref <golden> <ours>\n"; return 2; }
    int maxex = argc > 3 ? atoi(argv[3]) : 3;
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* DA = (design*)((uhdm_handle*)ha[0])->object;
    auto* DB = (design*)((uhdm_handle*)hb[0])->object;
    CompareContext c;
    int r = DA->Compare(DB, &c);
    printf("BASELINE r=%d lhs=%s rhs=%s visited=%zu\n", r,
           ident(c.m_failedLhs).c_str(), ident(c.m_failedRhs).c_str(),
           c.m_visited.size());
    if (!c.m_failedRhs) return 1;
    const BaseClass* T = c.m_failedRhs;
    sweep("OURS", sb, T, maxex);

    // and the golden twin of that package, both views, for contrast
    if (DA->TopPackages())
        for (auto* p : *DA->TopPackages())
            if (p->VpiName() == T->VpiName())
                sweep("GOLDEN (TOP view twin)", sa, p, maxex);
    if (DA->AllPackages())
        for (auto* p : *DA->AllPackages())
            if (p->VpiName() == T->VpiName())
                sweep("GOLDEN (ALL view twin)", sa, p, maxex);
    return 0;
}
