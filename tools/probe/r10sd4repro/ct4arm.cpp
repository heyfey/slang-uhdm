// r10sd4 — WHICH ARM, and WHICH PACKAGE PAIR?
//
// `SafeCompare` has TWO arms that print `LHS: <null>` and set ONLY
// `m_failedRhs` (BaseClass.h:186-224):
//
//   SINGULAR  SafeCompare(lhs, rhs)                  -> m_failedRhs = rhs
//             ... the failing CHILD is a package.
//   VECTOR    SafeCompare(lhs_obj, lhs_vec,          -> m_failedRhs = rhs_obj
//                         rhs_obj, rhs_vec)             ... the failing
//             CONTAINER is a package, and the divergence is
//             `golden's vector == nullptr && ours' vector is non-empty`.
//
// BOTH print a `package` as the RHS.  sd2 read the print as the singular arm;
// this tool decides it by MEASUREMENT, by comparing the package objects pairwise
// with a fresh context and reading which vector diverges.
//
// The reason this matters: Surelog emits every package TWICE, as two distinct
// objects — the DEF view in `uhdmallPackages` (`vpiTop=0`, `Class_defns` NULL)
// and the ELABORATED view in `uhdmtopPackages` (`vpiTop=1`, `Class_defns=323`)
// — sd2 §3.  So a `vpiInstance` that names the WRONG VIEW makes `package::
// Compare` compare a def view against an elab view, and the first vector that is
// NULL in one view and populated in the other IS the head.  That is invisible to
// a census that compares AllPackages[i] with AllPackages[i] and TopPackages[i]
// with TopPackages[i] — which is what sd2's `ct2pkgv` did, correctly, and why it
// reported the vectors IDENTICAL while the head persisted.
//
// build: g++ -O2 -std=c++17 ct4arm.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4arm
// usage: ct4arm <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

using namespace UHDM;

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

// every vector `package::Compare` walks, in declaration order, NULL kept
// distinct from EMPTY (-1 vs 0) — that distinction IS the arm.
// scope::Compare, generated/src/scope.cpp:335-351, then instance::Compare,
// generated/src/instance.cpp:332-339 — IN THAT ORDER, which is the order the
// head is decided in.
#define VECS(P, F)                                                            \
    F(Property_decls) F(Sequence_decls) F(Concurrent_assertions)              \
    F(Named_events) F(Named_event_arrays) F(Variables)                        \
    F(Virtual_interface_vars) F(Logic_vars) F(Array_vars) F(Array_var_mems)   \
    F(Parameters) F(Param_assigns) F(Scopes) F(Typespecs) F(Instance_items)   \
    F(Let_decls) F(Attributes)                                                \
    F(Programs) F(Program_arrays) F(Class_defns) F(Task_funcs) F(Nets)        \
    F(Array_nets) F(Spec_params) F(Assertions)

template <typename V>
static long vsz(const V* v) { return v ? (long)v->size() : -1; }

static void dumpPkg(const char* tag, const package* p) {
    if (!p) { printf("%-28s <null>\n", tag); return; }
    printf("%-28s %s vpiTop=%d\n", tag, ident(p).c_str(), (int)p->VpiTop());
}

static void cmpPkgPair(const char* tag, const package* g, const package* o) {
    printf("\n=== %s\n", tag);
    dumpPkg("  golden", g);
    dumpPkg("  ours  ", o);
    if (!g || !o) return;
    CompareContext c;
    int r = g->Compare(o, &c);
    printf("  Compare r=%d lhs=%s rhs=%s\n", r, ident(c.m_failedLhs).c_str(),
           ident(c.m_failedRhs).c_str());
    printf("  %-22s %8s %8s   (-1 == NULL vector, 0 == empty vector)\n", "vector",
           "GOLDEN", "OURS");
#define ROW(N)                                                                \
    if (vsz(g->N()) != vsz(o->N()))                                           \
        printf("  %-22s %8ld %8ld   <== DIVERGES\n", #N, vsz(g->N()),         \
               vsz(o->N()));                                                  \
    else                                                                      \
        printf("  %-22s %8ld %8ld\n", #N, vsz(g->N()), vsz(o->N()));
    VECS(x, ROW)
#undef ROW
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct4arm <golden> <ours>\n"; return 2; }
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* DA = (design*)((uhdm_handle*)ha[0])->object;
    auto* DB = (design*)((uhdm_handle*)hb[0])->object;

    CompareContext c0;
    int r0 = DA->Compare(DB, &c0);
    printf("BASELINE r=%d lhs=%s rhs=%s  visited=%zu\n", r0,
           ident(c0.m_failedLhs).c_str(), ident(c0.m_failedRhs).c_str(),
           c0.m_visited.size());

    const package *gAll = nullptr, *gTop = nullptr, *oAll = nullptr,
                  *oTop = nullptr;
    auto pick = [](design* d, bool top, const char* nm) -> const package* {
        auto* v = top ? d->TopPackages() : d->AllPackages();
        if (!v) return nullptr;
        for (auto* p : *v)
            if (p->VpiName() == nm) return p;
        return nullptr;
    };
    gAll = pick(DA, false, "uvm_pkg");
    gTop = pick(DA, true, "uvm_pkg");
    oAll = pick(DB, false, "uvm_pkg");
    oTop = pick(DB, true, "uvm_pkg");
    printf("\nfailedRhs == ours AllPackages uvm_pkg : %d\n",
           (const BaseClass*)oAll == c0.m_failedRhs);
    printf("failedRhs == ours TopPackages uvm_pkg : %d\n",
           (const BaseClass*)oTop == c0.m_failedRhs);

    // The four pairings.  If the head is the VECTOR arm on a VIEW MISMATCH, the
    // CROSS pairing (golden DEF view vs ours ELAB view) reproduces it and the
    // two LIKE pairings do not.
    cmpPkgPair("LIKE  golden ALL  vs ours ALL", gAll, oAll);
    cmpPkgPair("LIKE  golden TOP  vs ours TOP", gTop, oTop);
    cmpPkgPair("CROSS golden ALL  vs ours TOP", gAll, oTop);
    cmpPkgPair("CROSS golden TOP  vs ours ALL", gTop, oAll);
    return 0;
}
