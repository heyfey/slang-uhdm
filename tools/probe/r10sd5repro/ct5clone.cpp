// r10sd5 — DOES `clone_tree` PRODUCE GOLDEN'S SHAPE?  Read it, do not assume.
//
// `ct5deep` read golden's answer: the class-listing copy of an imported package
// variable is a DISTINCT object down to the actual typespec and the init expr,
// and its typespec's own children are SHARED (`class_typespec L3.Class_defn
// SAME 117`).  Two implementations could deliver that, and they differ by
// orders of magnitude in database size:
//
//   (a) a hand-written per-kind shallow copy  — correct by construction, but it
//       must enumerate every `variables` subtype that can reach the site;
//   (b) `UHDM::clone_tree` with a plain `CloneContext` — one line, IF it stops
//       where golden stops.  If it recurses into `Class_defn` it duplicates a
//       whole class per imported class_var and the fix is a catastrophe.
//
// `UhdmExporter.h:490` already records that DeepClone "recurses forever through
// the self-referential Typedef_alias", so the pessimistic reading is the prior.
// This probe MEASURES it on the real objects: it restores OUR SeqDriver database,
// clones each variable a class listing shares with a package, and reports, per
// level, whether the clone is a new object and whether its typespec's children
// are SHARED with the original (golden's answer) or DUPLICATED (a blow-up).
//
// GUARD: a run that clones ZERO variables is a hard error.
//
// build: g++ -O2 -std=c++17 ct5clone.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct5clone
// usage: ct5clone <ours.uhdm>
#include <uhdm/ElaboratorListener.h>
#include <uhdm/clone_tree.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <set>
#include <string>

using namespace UHDM;

static std::map<std::string, long> tally;

int32_t main(int32_t argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct5clone <ours.uhdm>\n");
        return 2;
    }
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        fprintf(stderr, "FATAL: could not restore %s\n", argv[1]);
        return 3;
    }
    design* d = (design*)((const uhdm_handle*)restored[0])->object;

    // The objects the PACKAGE listings own — the shared-push population.
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

    size_t before = s.AllObjects().size();
    long cloned = 0;
    std::set<const class_defn*> seen;
    std::set<const variables*> doneVar;
    auto doClass = [&](const class_defn* c) {
        if (!c || !c->Variables()) return;
        for (auto* x : *c->Variables()) {
            if (!x || !pkgOwn.count(x)) continue;  // only the SHARED entries
            if (!doneVar.insert(x).second) continue;
            std::string k(UhdmName(x->UhdmType()));
            ElaboratorContext ctx(&s, false, /*muteErrors=*/true);
            auto* cl = (variables*)clone_tree(x, &ctx);
            if (!cl) {
                tally[k + " CLONE-FAILED"]++;
                continue;
            }
            cloned++;
            tally[k + " L0.var " + (cl == x ? "SAME" : "NEW")]++;
            const ref_typespec* r0 = x->Typespec();
            const ref_typespec* r1 = cl->Typespec();
            if (r0 || r1)
                tally[k + " L1.ref_typespec " +
                      (!r0 || !r1 ? "one-null" : (r0 == r1 ? "SHARED" : "NEW"))]++;
            const expr* e0 = x->Expr();
            const expr* e1 = cl->Expr();
            if (e0 || e1)
                tally[k + " L1.expr " +
                      (!e0 || !e1 ? "one-null" : (e0 == e1 ? "SHARED" : "NEW"))]++;
            const typespec* a0 = r0 ? r0->Actual_typespec() : nullptr;
            const typespec* a1 = r1 ? r1->Actual_typespec() : nullptr;
            if (a0 || a1)
                tally[k + " L2.actual " +
                      (!a0 || !a1 ? "one-null" : (a0 == a1 ? "SHARED" : "NEW"))]++;
            if (a0 && a1) {
                tally[k + " L2.actual.inst " +
                      std::string(a1->Instance() ? "INST" : "null")]++;
                if (auto* p0 = any_cast<const class_typespec*>(a0)) {
                    auto* p1 = any_cast<const class_typespec*>(a1);
                    if (p1 && (p0->Class_defn() || p1->Class_defn()))
                        tally[k + " L3.Class_defn " +
                              (p0->Class_defn() == p1->Class_defn() ? "SHARED"
                                                                    : "DUPLICATED")]++;
                }
            }
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

    size_t after = s.AllObjects().size();
    printf("\n[C] clone_tree on %ld distinct shared imported variables\n", cloned);
    printf("    serializer objects %zu -> %zu  (+%zu, %.1f per clone)\n", before, after,
           after - before, cloned ? double(after - before) / double(cloned) : 0.0);
    for (auto& [k, v] : tally) printf("    %-44s %ld\n", k.c_str(), v);
    if (cloned == 0) {
        printf("REFUSING TO REPORT: zero clones -- an empty population agrees with anything\n");
        return 5;
    }
    return 0;
}
