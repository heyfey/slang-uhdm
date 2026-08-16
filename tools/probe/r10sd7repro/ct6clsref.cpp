// r10sd6 — THE POPULATION CENSUS for the class-listing copy's INITIALISER
// REFERENCE.
//
// ct6pkgv refuted the brief's hypothesis (the two `uvm_pkg` Variables vectors
// are the same size and agree entry for entry), and ct6path found the real
// slot: the copy that `§ importedClassVarIsOwnCopyNoInstance5` pushes into an
// importing CLASS keeps its initialiser reference pointing at the PACKAGE's
// variable, and keeps the PACKAGE's spelling of that reference's fullname,
// where golden re-names it to the copy's own owner chain and leaves it UNBOUND.
//
// One cell is not a law.  This tool prints the WHOLE population on either side
// so the rule can be read off every instance instead of one:
//
//   for every class_defn reachable from the design, for every entry in its
//   `Variables` listing, for every ref_obj / ref_var anywhere in that entry's
//   `vpiExpr` subtree:  class / var / ref-name / ref-fullname / actual.
//
// GUARDS:
//   * `ref_obj` and `ref_var` are UNRELATED hierarchies — each is reached
//     through `any_cast` to its own static type (the pass-47 type-punning
//     defect is the record of what a C-style cast between them does);
//   * classes are collected from AllClasses/TopPackages/AllPackages AND
//     recursively through `Derived_classes`, because SeqDriver's adpcm classes
//     hang off uvm_pkg's inheritance tree, not off any listing (ct6path shows
//     the path `package / vpiClassDefn / vpiDerivedClasses / ...`);
//   * every class is visited ONCE (pointer set), so a diamond cannot inflate
//     the census;
//   * an EMPTY population is a hard error (exit 5): the whole point of this
//     tool is that "no rows" must never read as "the two sides agree".
//
// build: g++ -O2 -std=c++17 ct6clsref.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct6clsref
// usage: ct6clsref <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string desc(const BaseClass* o) {
    if (!o) return "<null>";
    // VpiFullName lives on `variables`/`instance`/..., not on BaseClass, so it
    // is reached through the one group that has it and falls back to VpiName.
    std::string n(o->VpiName());
    if (auto* v = any_cast<const variables*>(o))
        if (!v->VpiFullName().empty()) n = v->VpiFullName();
    return std::string(UhdmName(o->UhdmType())) + "(" + n + ")";
}

static long rows = 0, refs = 0;

static void walkExpr(const std::string& cls, const std::string& var,
                     const any* e, int depth) {
    if (!e || depth > 12) return;
    if (auto* ro = any_cast<ref_obj*>((any*)e)) {
        printf("REF  %-46s %-26s ref_obj name=%-28s full=%-64s actual=%s\n",
               cls.c_str(), var.c_str(), std::string(ro->VpiName()).c_str(),
               std::string(ro->VpiFullName()).c_str(),
               desc(ro->Actual_group()).c_str());
        refs++;
        return;
    }
    if (auto* rv = any_cast<ref_var*>((any*)e)) {
        printf("REF  %-46s %-26s ref_var name=%-28s full=%-64s actual=%s\n",
               cls.c_str(), var.c_str(), std::string(rv->VpiName()).c_str(),
               std::string(rv->VpiFullName()).c_str(),
               desc(rv->Actual_group()).c_str());
        refs++;
        return;
    }
    if (e->UhdmType() == uhdmoperation) {
        if (auto* ops = ((operation*)e)->Operands())
            for (auto* o : *ops) walkExpr(cls, var, o, depth + 1);
        return;
    }
    if (auto* tc = any_cast<tf_call*>((any*)e)) {
        if (auto* args = tc->Tf_call_args())
            for (auto* a : *args) walkExpr(cls, var, a, depth + 1);
        return;
    }
}

static std::set<const class_defn*> seen;

static void doClass(const class_defn* cd) {
    if (!cd || !seen.insert(cd).second) return;
    if (cd->Variables())
        for (auto* v : *cd->Variables()) {
            if (!v) continue;
            rows++;
            if (!v->Expr()) continue;
            walkExpr(std::string(cd->VpiFullName()), std::string(v->VpiName()),
                     v->Expr(), 0);
        }
    if (cd->Deriveds())
        for (auto* d : *cd->Deriveds()) doClass(d);
}

int32_t main(int32_t argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct6clsref <db.uhdm>\n");
        return 2;
    }
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { printf("RESTORE-FAIL %s\n", argv[1]); return 3; }
    design* d = (design*)((const uhdm_handle*)restored[0])->object;
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) doClass(c);
    auto pkgs = [&](VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v)
            if (p && p->Class_defns())
                for (auto* c : *p->Class_defns()) doClass(c);
    };
    pkgs(d->AllPackages());
    pkgs(d->TopPackages());
    printf("-- classes=%zu listing-entries=%ld refs-in-initialisers=%ld\n",
           seen.size(), rows, refs);
    if (rows == 0) {
        printf("REFUSING TO REPORT: EMPTY POPULATION\n");
        return 5;
    }
    return 0;
}
