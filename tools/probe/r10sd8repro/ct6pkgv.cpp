// r10sd6 — THE VECTOR CENSUS that must run BEFORE anything else.
//
// The head is `LHS: <null>` / `RHS: class_var(uvm_pkg::uvm_default_table_printer)`.
// The standing MEASUREMENT LAW says a `<null>` on one side of a cmp head is
// very often a VECTOR ENTRY: SafeCompare walks two vectors in lockstep and, at
// the first index where one side runs out (or where the entries decompile
// differently), prints the pair — so a MISSING EARLIER SIBLING on the golden
// side shifts every later slot and the object it names is not the object that
// is wrong.
//
// This tool refuses to guess.  It prints, for a NAMED package, in EVERY view
// the design carries (AllPackages and TopPackages), the WHOLE `Variables`
// vector IN ORDER with, per entry: slot index, uhdm kind, VpiName, span,
// whether it carries a vpiExpr and what kind that expr is, vpiAutomatic and
// vpiVisibility.  Two files can then be joined BY NAME (not by slot), which is
// the only join that survives an insertion.
//
// GUARDS (each one an ops trap this campaign has already paid for):
//   * a package NAME that matches nothing in a file prints NO-SUCH-PACKAGE and
//     is COUNTED — an empty census must never read as agreement;
//   * BOTH views are printed separately and never merged: r10sd5 §4.2 is the
//     record of an instrument that silently picked one view's representative
//     and reported a false answer for it;
//   * a null `Variables()` vector prints `VARIABLES=<null>` explicitly, which
//     is a DIFFERENT fact from an empty vector, and the cmp head shape depends
//     on which one it is.
//
// build: g++ -O2 -std=c++17 ct6pkgv.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct6pkgv
// usage: ct6pkgv <db.uhdm> <pkgname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}

static void dumpVec(const char* view, const package* p) {
    auto* v = p->Variables();
    if (!v) {
        printf("%s VARIABLES=<null>\n", view);
        return;
    }
    printf("%s VARIABLES size=%u\n", view, (unsigned)v->size());
    for (size_t i = 0; i < v->size(); i++) {
        variables* x = (*v)[i];
        if (!x) {
            printf("%s [%3u] <NULL ENTRY>\n", view, (unsigned)i);
            continue;
        }
        const any* e = x->Expr();
        std::string ets = e ? kindOf(e) : std::string("-");
        std::string tsk = "-";
        if (auto* rt = x->Typespec()) {
            tsk = kindOf(rt);
            if (auto* at = rt->Actual_typespec())
                tsk = kindOf(at) + "(" + std::string(at->VpiName()) + ")";
        }
        printf("%s [%3u] %-16s %-40s @%u:%u-%u:%u expr=%-20s ts=%-34s auto=%d vis=%d\n",
               view, (unsigned)i, kindOf(x).c_str(),
               std::string(x->VpiName()).c_str(), (unsigned)x->VpiLineNo(),
               (unsigned)x->VpiColumnNo(), (unsigned)x->VpiEndLineNo(),
               (unsigned)x->VpiEndColumnNo(), ets.c_str(), tsk.c_str(),
               (int)x->VpiAutomatic(), (int)x->VpiVisibility());
    }
}

int32_t main(int32_t argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct6pkgv <db.uhdm> <pkgname>\n");
        return 2;
    }
    const std::string want(argv[2]);
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        printf("RESTORE-FAIL %s\n", argv[1]);
        return 3;
    }
    design* d = (design*)((const uhdm_handle*)restored[0])->object;
    int found = 0;
    auto walk = [&](VectorOfpackage* v, const char* view) {
        if (!v) {
            printf("%s <no package vector>\n", view);
            return;
        }
        for (auto* p : *v) {
            if (!p || std::string(p->VpiName()) != want) continue;
            found++;
            printf("== %s package %s @%u:%u\n", view, want.c_str(),
                   (unsigned)p->VpiLineNo(), (unsigned)p->VpiColumnNo());
            dumpVec(view, p);
        }
    };
    walk(d->AllPackages(), "ALL");
    walk(d->TopPackages(), "TOP");
    if (!found) {
        printf("NO-SUCH-PACKAGE %s in %s\n", want.c_str(), argv[1]);
        return 4;
    }
    printf("-- views matched: %d\n", found);
    return 0;
}
