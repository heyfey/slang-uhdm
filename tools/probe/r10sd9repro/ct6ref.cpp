// r10sd6 — THE INITIALISER-REF READER.
//
// The vector census (ct6pkgv) proved the two `uvm_pkg` Variables vectors are
// the SAME SIZE and agree entry for entry on kind/name/span/expr-kind, in both
// views.  So the head is NOT a missing sibling and NOT a vector-order defect;
// the failing slot has to be a SINGULAR field, and the only singular field in
// this neighbourhood that can hold a `class_var` is a reference's `vpiActual`.
//
// This tool walks a named package's Variables, descends each entry's `vpiExpr`
// and prints EVERY `ref_obj` / `ref_var` it finds with the object its
// `Actual_group` points at (kind, name, and whether that object is one of the
// package's own listed variables).  Two files are then diffed directly.
//
// GUARDS:
//   * `ref_obj` and `ref_var` are UNRELATED C++ hierarchies (ref_var is
//     `final : public variables`, ref_obj is `: public simple_expr`).  The
//     pass-47 type-punning defect is the record of what a C-style cast between
//     them does, so each is reached through `any_cast` to its OWN static type.
//   * a package that matches nothing prints NO-SUCH-PACKAGE and returns 4.
//   * an entry whose expr is present but reaches NO reference at all is
//     printed as `noref`, so "nothing printed" can never be read as "no
//     bindings" — absence of output is reported, not inferred.
//
// build: g++ -O2 -std=c++17 ct6ref.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct6ref
// usage: ct6ref <db.uhdm> <pkgname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string desc(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static int nref = 0;
static void walkExpr(const char* view, const char* owner, const any* e,
                     const std::set<const BaseClass*>& own, int depth) {
    if (!e || depth > 12) return;
    if (auto* ro = any_cast<ref_obj*>((any*)e)) {
        const any* a = ro->Actual_group();
        printf("%s %-28s ref_obj  name=%-34s actual=%s%s\n", view, owner,
               std::string(ro->VpiName()).c_str(), desc(a).c_str(),
               (a && own.count(a)) ? "  [OWN-PKG-VAR]" : "");
        nref++;
        return;
    }
    if (auto* rv = any_cast<ref_var*>((any*)e)) {
        const any* a = rv->Actual_group();
        printf("%s %-28s ref_var  name=%-34s actual=%s%s\n", view, owner,
               std::string(rv->VpiName()).c_str(), desc(a).c_str(),
               (a && own.count(a)) ? "  [OWN-PKG-VAR]" : "");
        nref++;
        return;
    }
    if (e->UhdmType() == uhdmoperation) {
        if (auto* ops = ((operation*)e)->Operands())
            for (auto* o : *ops) walkExpr(view, owner, o, own, depth + 1);
        return;
    }
    if (auto* tc = any_cast<tf_call*>((any*)e)) {
        if (auto* args = tc->Tf_call_args())
            for (auto* a : *args) walkExpr(view, owner, a, own, depth + 1);
        return;
    }
}

int32_t main(int32_t argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct6ref <db.uhdm> <pkgname>\n");
        return 2;
    }
    const std::string want(argv[2]);
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { printf("RESTORE-FAIL %s\n", argv[1]); return 3; }
    design* d = (design*)((const uhdm_handle*)restored[0])->object;
    int found = 0;
    auto walk = [&](VectorOfpackage* v, const char* view) {
        if (!v) return;
        for (auto* p : *v) {
            if (!p || std::string(p->VpiName()) != want) continue;
            found++;
            std::set<const BaseClass*> own;
            if (p->Variables())
                for (auto* x : *p->Variables()) if (x) own.insert(x);
            if (!p->Variables()) continue;
            for (auto* x : *p->Variables()) {
                if (!x) continue;
                if (!x->Expr()) continue;
                int before = nref;
                walkExpr(view, std::string(x->VpiName()).c_str(), x->Expr(), own, 0);
                if (nref == before)
                    printf("%s %-28s noref    expr=%s\n", view,
                           std::string(x->VpiName()).c_str(),
                           desc(x->Expr()).c_str());
            }
        }
    };
    walk(d->AllPackages(), "ALL");
    walk(d->TopPackages(), "TOP");
    if (!found) { printf("NO-SUCH-PACKAGE %s\n", want.c_str()); return 4; }
    printf("-- views=%d refs=%d\n", found, nref);
    return 0;
}
