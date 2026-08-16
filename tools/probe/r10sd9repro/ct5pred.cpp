// r10sd5 — THE CENSUS-PREDICT, artifact-based.
//
// The standing rule is that the mover prediction is made BEFORE the sweeps and
// from the ARTIFACT, not from source text.  sd4's F1 is the reason: a source
// scan reported `BuildUVMPkg` on the strength of a `.sl` pointer file that holds
// no SystemVerilog at all.  This tool never looks at source.  It restores each
// database the PRISTINE sweep already produced and counts the ONE thing the fix
// changes:
//
//   the number of entries in a class_defn's `Variables` listing that are
//   POINTER-IDENTICAL to a variable a package lists — i.e. the shared push.
//
// A design with a nonzero count is predicted to move; a design with zero cannot
// move, because the patched code path is reached only where that count is
// nonzero.  It also reports the count of those whose actual typespec carries a
// `vpiInstance`, which is the cmp-VISIBLE part; the rest move bytes only.
//
// GUARD: a database that fails to restore is printed as RESTORE-FAIL and COUNTED.
// A predictor that silently skips its inputs predicts nothing.
//
// build: g++ -O2 -std=c++17 ct5pred.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct5pred
// usage: ct5pred <db.uhdm> [<db.uhdm> ...]        (one line per database)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

int32_t main(int32_t argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct5pred <db.uhdm> [...]\n");
        return 2;
    }
    long files = 0, fails = 0, hits = 0;
    for (int32_t i = 1; i < argc; i++) {
        files++;
        Serializer s;
        const std::vector<vpiHandle> restored = s.Restore(std::string(argv[i]));
        if (restored.empty()) {
            printf("RESTORE-FAIL %s\n", argv[i]);
            fails++;
            continue;
        }
        design* d = (design*)((const uhdm_handle*)restored[0])->object;
        std::set<const BaseClass*> pkgOwn;
        auto walk = [&](VectorOfpackage* v) {
            if (!v) return;
            for (auto* p : *v) {
                if (!p || !p->Variables()) continue;
                for (auto* x : *p->Variables())
                    if (x) pkgOwn.insert(x);
            }
        };
        walk(d->AllPackages());
        walk(d->TopPackages());
        long shared = 0, sharedInst = 0, entries = 0;
        std::set<const class_defn*> seen;
        auto doClass = [&](const class_defn* c) {
            if (!c || !c->Variables()) return;
            for (auto* x : *c->Variables()) {
                if (!x) continue;
                entries++;
                if (!pkgOwn.count(x)) continue;
                shared++;
                if (auto* rt = x->Typespec())
                    if (auto* at = rt->Actual_typespec())
                        if (at->Instance()) sharedInst++;
            }
        };
        auto pkgClasses = [&](VectorOfpackage* v) {
            if (!v) return;
            for (auto* p : *v) {
                if (!p || !p->Class_defns()) continue;
                for (auto* c : *p->Class_defns())
                    if (seen.insert(c).second) doClass(c);
            }
        };
        pkgClasses(d->AllPackages());
        pkgClasses(d->TopPackages());
        if (d->AllClasses())
            for (auto* c : *d->AllClasses())
                if (seen.insert(c).second) doClass(c);
        if (shared) hits++;
        printf("%s shared=%ld sharedInst=%ld entries=%ld classes=%zu\n", argv[i], shared,
               sharedInst, entries, seen.size());
    }
    fprintf(stderr, "-- databases=%ld RESTORE-FAIL=%ld PREDICTED-MOVERS=%ld\n", files, fails,
            hits);
    return 0;
}
