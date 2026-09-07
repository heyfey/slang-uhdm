// r10vearl114 IDENTITY + POPULATION PROBE -- MEASUREMENT ONLY.
// Two questions a verifier must not take on trust:
//  (1) IS THE TARGET SHARED OR MINTED?  For every hier_path that carries a
//      Typespec, is its ref_typespec the SAME OBJECT as the Root_value's
//      ref_typespec, and is its Actual_typespec the SAME OBJECT as the
//      Root_value's Actual_typespec?  Printed per cell, then tallied.
//  (2) THE TYPESPEC POPULATION: every typespec object by KIND and by SPAN,
//      with its referrer count -- so a "+N objects" delta can be shown to be
//      arena copies at an UNCHANGED coordinate rather than new types.
// build: g++ -O2 -std=c++17 vident114.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o vident114
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <set>
#include <string>
using namespace UHDM;
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "-";
}
static std::string spanOf(const BaseClass* o) {
    char b[96];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("VIDRC 1\n"); return 0; }
    long sameRt = 0, diffRt = 0, sameAct = 0, diffAct = 0, hung = 0, bare = 0, norv = 0;
    std::map<std::string, long> typePop;      // kind|span -> count
    std::map<const BaseClass*, long> refs;    // actual typespec -> referrer count
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmref_typespec) {
            auto* rt = (const ref_typespec*)o;
            if (rt->Actual_typespec()) refs[rt->Actual_typespec()]++;
            continue;
        }
        if (o->UhdmType() != uhdmhier_path) continue;
        auto* h = (const hier_path*)o;
        auto* prt = h->Typespec();
        if (!prt) { bare++; continue; }
        hung++;
        const any* rv = h->Root_value();
        const expr* rve = rv ? any_cast<const expr*>(rv) : nullptr;
        const ref_typespec* rrt = rve ? rve->Typespec() : nullptr;
        if (!rrt) { norv++; continue; }
        (prt == rrt ? sameRt : diffRt)++;
        (prt->Actual_typespec() == rrt->Actual_typespec() ? sameAct : diffAct)++;
    }
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        auto t = o->UhdmType();
        if (t == uhdmarray_typespec || t == uhdmstruct_typespec ||
            t == uhdmlogic_typespec || t == uhdmenum_typespec ||
            t == uhdmpacked_array_typespec)
            typePop[kindOf(o) + "|" + spanOf(o)]++;
    }
    printf("HIER_PATHS hung=%ld bare=%ld  (of the hung, root has no ref_typespec: %ld)\n",
           hung, bare, norv);
    printf("SAME ref_typespec OBJECT as the root's : yes=%ld no=%ld\n", sameRt, diffRt);
    printf("SAME Actual_typespec OBJECT as root's  : yes=%ld no=%ld\n", sameAct, diffAct);
    printf("TYPESPEC POPULATION (kind|span -> count, referrers)\n");
    for (auto& kv : typePop) printf("POP %s %ld\n", kv.first.c_str(), kv.second);
    long shared = 0, maxr = 0;
    for (auto& kv : refs) { if (kv.second > 1) shared++; if (kv.second > maxr) maxr = kv.second; }
    printf("REFERRERS: %zu distinct actual typespecs, %ld shared by >1 ref_typespec, max sharers=%ld\n",
           refs.size(), shared, maxr);
    printf("VIDRC 0\n");
    return 0;
}
