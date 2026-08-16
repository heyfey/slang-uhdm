// r10sd6 — THE CENSUS-PREDICT, artifact-based, run BEFORE the delivered sweeps.
//
// The standing rule is that the mover prediction is made from the ARTIFACT, not
// from source text (sd4's F1: a source scan "found" a design whose `.sl` pointer
// file holds no SystemVerilog at all).  This tool never looks at source.  It
// restores each database the PRISTINE sweep already produced and counts EXACTLY
// what the patch rewrites:
//
//   a reference (`ref_obj`/`ref_var`) anywhere in the `vpiExpr` subtree of an
//   entry in some `class_defn`'s `Variables` listing, whose `vpiFullName` is NOT
//   already `<entry fullname>::<ref name>`, OR whose `vpiActual` is NOT null.
//
// Those are precisely the writes `importCopyRefs6` performs that CHANGE
// something; a database with zero of them cannot move, because every write the
// patch makes there is a no-op.  It is deliberately the EFFECT-side predicate
// and not "is this an import copy": after pass 5 a copy is an ordinary own
// object and nothing in the artifact labels it as copied, so an
// import-copy-shaped predicate would have to be guessed.  This one is
// checkable against the observed movers, which is the point.
//
// GUARDS:
//   * a database that fails to restore prints RESTORE-FAIL and is COUNTED — a
//     predictor that silently skips its inputs predicts nothing;
//   * classes are reached through AllClasses, both package listings AND
//     `Derived_classes` recursion, each class visited once;
//   * the per-file line is printed for EVERY file, hits or not, so the zero
//     rows are visible rather than inferred.
//
// build: g++ -O2 -std=c++17 ct6pred.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct6pred
// usage: ct6pred <db.uhdm> [<db.uhdm> ...]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static long gRename = 0, gUnbind = 0;

static void walkExpr(const std::string& owner, const any* e, int depth) {
    if (!e || depth > 12) return;
    if (auto* ro = any_cast<ref_obj*>((any*)e)) {
        const std::string want = owner + "::" + std::string(ro->VpiName());
        if (!ro->VpiName().empty() && std::string(ro->VpiFullName()) != want)
            gRename++;
        if (ro->Actual_group() != nullptr) gUnbind++;
        return;
    }
    if (auto* rv = any_cast<ref_var*>((any*)e)) {
        const std::string want = owner + "::" + std::string(rv->VpiName());
        if (!rv->VpiName().empty() && std::string(rv->VpiFullName()) != want)
            gRename++;
        if (rv->Actual_group() != nullptr) gUnbind++;
        return;
    }
    if (e->UhdmType() == uhdmoperation) {
        if (auto* ops = ((operation*)e)->Operands())
            for (auto* o : *ops) walkExpr(owner, o, depth + 1);
        return;
    }
    if (auto* tc = any_cast<tf_call*>((any*)e)) {
        if (auto* args = tc->Tf_call_args())
            for (auto* a : *args) walkExpr(owner, a, depth + 1);
    }
}

int32_t main(int32_t argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct6pred <db.uhdm> [...]\n");
        return 2;
    }
    long files = 0, fails = 0, movers = 0;
    for (int32_t i = 1; i < argc; i++) {
        files++;
        Serializer s;
        const std::vector<vpiHandle> restored = s.Restore(std::string(argv[i]));
        if (restored.empty()) { printf("RESTORE-FAIL %s\n", argv[i]); fails++; continue; }
        design* d = (design*)((const uhdm_handle*)restored[0])->object;
        gRename = gUnbind = 0;
        long entries = 0;
        std::set<const class_defn*> seen;
        std::vector<const class_defn*> stack;
        auto push = [&](const class_defn* c) { if (c) stack.push_back(c); };
        if (d->AllClasses()) for (auto* c : *d->AllClasses()) push(c);
        auto pkgs = [&](VectorOfpackage* v) {
            if (!v) return;
            for (auto* p : *v)
                if (p && p->Class_defns())
                    for (auto* c : *p->Class_defns()) push(c);
        };
        pkgs(d->AllPackages());
        pkgs(d->TopPackages());
        while (!stack.empty()) {
            const class_defn* cd = stack.back();
            stack.pop_back();
            if (!seen.insert(cd).second) continue;
            if (cd->Variables())
                for (auto* v : *cd->Variables()) {
                    if (!v) continue;
                    entries++;
                    if (v->Expr())
                        walkExpr(std::string(v->VpiFullName()), v->Expr(), 0);
                }
            if (cd->Deriveds())
                for (auto* dd : *cd->Deriveds()) push(dd);
        }
        const long hits = gRename + gUnbind;
        if (hits) movers++;
        printf("%-52s rename=%-5ld unbind=%-4ld entries=%-6ld classes=%zu%s\n",
               argv[i], gRename, gUnbind, entries, seen.size(),
               hits ? "   PREDICT-MOVER" : "");
    }
    printf("-- files=%ld restore-fail=%ld PREDICTED MOVERS=%ld\n", files, fails,
           movers);
    return 0;
}
