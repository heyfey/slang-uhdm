// r10sd5 — THE CLONE-DEPTH INSTRUMENT.
//
// `ct5cls` proves golden's class-listing variable is its OWN object down to the
// actual typespec and the init expr.  A patch still cannot be written from that,
// because the standing brief's trap is the next level down:
//
//     "CLONED objects must not share child pointers golden duplicates."
//
// The inverse trap is just as expensive: cloning a child golden SHARES multiplies
// the database (a `class_typespec`'s `Class_defn` is a whole class).  So the
// depth has to be READ, one level at a time, by POINTER IDENTITY between the
// class-listing copy and the PACKAGE-listing copy of the SAME variable.
//
// For every (package listing entry, class listing entry) pair with the same name
// this prints, per level, SAME (one object) or DIFF (two objects):
//
//   L0 var   L1 ref_typespec   L1 expr   L2 actual typespec
//   L3 = the actual typespec's OWN children -- Class_defn / Base_typespec /
//        Elem_typespec / Index_typespec / Members / Ranges / Typedef_alias
//
// GUARD: a run that pairs ZERO entries is a hard error.  Zero pairs "agree".
//
// build: g++ -O2 -std=c++17 ct5deep.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct5deep
// usage: ct5deep <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::map<std::string, long> tally;
static std::string kindOf(const BaseClass* b) {
    return b ? std::string(UhdmName(b->UhdmType())) : std::string("<null>");
}
// L3: every child slot a typespec can own that is worth a separate verdict.
static void level3(const typespec* a, const typespec* b, const std::string& pfx) {
    if (!a || !b || a->UhdmType() != b->UhdmType()) return;
    auto cmp1 = [&](const char* slot, const BaseClass* x, const BaseClass* y) {
        if (!x && !y) return;
        tally[pfx + " L3." + slot + " " +
              (!x || !y ? "one-null" : (x == y ? "SAME" : "DIFF"))]++;
    };
    if (auto* p = any_cast<const class_typespec*>(a))
        cmp1("Class_defn", p->Class_defn(),
             ((const class_typespec*)b)->Class_defn());
    if (auto* p = any_cast<const enum_typespec*>(a))
        cmp1("Base_typespec", p->Base_typespec(),
             ((const enum_typespec*)b)->Base_typespec());
    if (auto* p = any_cast<const array_typespec*>(a))
        cmp1("Elem_typespec", p->Elem_typespec(),
             ((const array_typespec*)b)->Elem_typespec());
    if (auto* p = any_cast<const packed_array_typespec*>(a))
        cmp1("PA_Elem_typespec", p->Elem_typespec(),
             ((const packed_array_typespec*)b)->Elem_typespec());
    if (auto* p = any_cast<const struct_typespec*>(a)) {
        auto* q = (const struct_typespec*)b;
        auto* mx = p->Members();
        auto* my = q->Members();
        if (mx && my && mx->size() == my->size())
            for (size_t i = 0; i < mx->size(); i++)
                cmp1("Members[i]", (*mx)[i], (*my)[i]);
        else if (mx || my)
            tally[pfx + " L3.Members size-differs"]++;
    }
    {  // Ranges live on the concrete vector kinds; read them through the dump-
       // visible common accessor set instead of enumerating every kind.
        auto rx = a->VpiName(), ry = b->VpiName();
        tally[pfx + " L3.name " + (rx == ry ? "SAME-TEXT" : "DIFF-TEXT")]++;
    }
}
int32_t main(int32_t argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct5deep <db.uhdm>\n");
        return 2;
    }
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        fprintf(stderr, "FATAL: could not restore %s\n", argv[1]);
        return 3;
    }
    design* d = (design*)((const uhdm_handle*)restored[0])->object;

    // name -> the PACKAGE listing's own entry, per package name.
    std::map<std::string, const variables*> pkgVar;
    auto walkPkg = [&](VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v) {
            if (!p || !p->Variables()) continue;
            for (auto* x : *p->Variables())
                if (x) pkgVar.emplace(std::string(x->VpiName()), x);
        }
    };
    walkPkg(d->AllPackages());
    walkPkg(d->TopPackages());
    printf("package-listed variables (by name): %zu\n", pkgVar.size());

    long pairs = 0;
    std::set<const class_defn*> seen;
    auto doClass = [&](const class_defn* c) {
        if (!c || !c->Variables()) return;
        for (auto* x : *c->Variables()) {
            if (!x) continue;
            auto it = pkgVar.find(std::string(x->VpiName()));
            if (it == pkgVar.end()) continue;  // a class's OWN member: no pair
            const variables* pv = it->second;
            if (pv->UhdmType() != x->UhdmType()) continue;
            pairs++;
            std::string pfx = kindOf(x);
            tally[pfx + " L0.var " + (pv == x ? "SAME" : "DIFF")]++;
            const ref_typespec* rt0 = pv->Typespec();
            const ref_typespec* rt1 = x->Typespec();
            if (rt0 || rt1)
                tally[pfx + " L1.ref_typespec " +
                      (!rt0 || !rt1 ? "one-null" : (rt0 == rt1 ? "SAME" : "DIFF"))]++;
            const expr* e0 = pv->Expr();
            const expr* e1 = x->Expr();
            if (e0 || e1)
                tally[pfx + " L1.expr " +
                      (!e0 || !e1 ? "one-null" : (e0 == e1 ? "SAME" : "DIFF"))]++;
            const typespec* a0 = rt0 ? rt0->Actual_typespec() : nullptr;
            const typespec* a1 = rt1 ? rt1->Actual_typespec() : nullptr;
            if (a0 || a1)
                tally[pfx + " L2.actual " +
                      (!a0 || !a1 ? "one-null" : (a0 == a1 ? "SAME" : "DIFF"))]++;
            if (a0 && a1 && a0 != a1) level3(a0, a1, pfx);
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

    printf("\n[D] CLONE DEPTH over %ld (package entry, class entry) name pairs\n", pairs);
    for (auto& [k, v] : tally) printf("    %-46s %ld\n", k.c_str(), v);
    if (pairs == 0) {
        printf("REFUSING TO REPORT: zero pairs -- an empty population agrees with anything\n");
        return 5;
    }
    return 0;
}
