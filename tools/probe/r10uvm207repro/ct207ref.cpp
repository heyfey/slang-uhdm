// r10uvm207 — WHAT § `cloneStructMemberBareTdAlias207`'s PREDICATE ADMITS AND
// REFUSES, over one database, WITH THE OWNER MASK.
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  This tool reads OURS.
//
// r10uvm205's § `cloneArrayElemBareTdAlias205` walks every DECLARATION whose
// innermost enclosing object is a wildcard-import clone subroutine and descends
// `array_typespec` / `packed_array_typespec` `Elem_typespec` / `Index_typespec`
// links, re-pointing a ref BELOW an array link onto § 16's clone copy, with an
// OWNER-EXCLUSIVITY GUARD: a ref that any NON-clone declaration also reaches is
// refused, because one `ref_typespec` cannot carry two names.
//
// This pass's population sits one link further: below a `struct_typespec`'s
// `Members()`.  The member's own `ref_typespec` CANNOT be re-pointed — MEASURED
// on SeqDriver, every struct_typespec that carries a differing member cell is
// ALSO bound by home-package declarations whose member cells AGREE with golden
// (ct207cen --decide: 8 hot holders, 8 MIXED, 0 PURE).  The object that CAN
// move is the ref that BINDS THE STRUCT — the declaration's own `Typespec()`,
// or an array's `Elem_typespec` — re-pointed onto a CLONE COPY of the struct.
//
// So this probe computes, over the same declaration walk:
//
//   * `owner` — for every ref in every chain, bit 1 if a clone declaration
//     reaches it, bit 2 if any other declaration does (the return-variable
//     exception counts as a NON-clone owner, § 16's measured rule);
//   * for every ref that BINDS A STRUCT with at least one REPAIRABLE member
//     (a member whose typespec is a LAW-S listing object or bare copy whose
//     alias target is still the qualified listing object), the verdict:
//        MOVE      mask == 1, the law re-points it
//        REFUSE-SHARED  mask == 3, a non-clone declaration reaches it too
//        HOME      mask == 2, no clone reaches it at all
//   * and the same three-way tally for the MEMBER refs, to show why the member
//     ref itself is never the object that moves.
//
// build: g++ -O2 -std=c++17 ct207ref.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct207ref
// usage: ct207ref <db.uhdm> [--list] [--clones] [--name=SUB]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <functional>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static bool scalarTdKind(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmlogic_typespec: case uhdmbit_typespec: case uhdmint_typespec:
        case uhdminteger_typespec: case uhdmbyte_typespec:
        case uhdmshort_int_typespec: case uhdmlong_int_typespec: return true;
        default: return false;
    }
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static std::string nm(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("-");
}
static const char* shapeOf(std::string_view n) {
    if (n.empty()) return "NONAME";
    return n.find("::") == std::string_view::npos ? "BARE" : "QUAL";
}
// § 205's `declTf205`, verbatim: the innermost enclosing SUBROUTINE of a
// declaration, refusing a class PROPERTY (the climb stops at class_defn,
// package, module_inst or design).
static const task_func* declTf(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        const auto k = p->UhdmType();
        if (k == uhdmfunction || k == uhdmtask) return (const task_func*)p;
        if (k == uhdmclass_defn || k == uhdmpackage ||
            k == uhdmmodule_inst || k == uhdmdesign)
            return nullptr;
    }
    return nullptr;
}
static const BaseClass* pkgOf(const BaseClass* o) {
    const BaseClass* pkg = nullptr;
    for (const BaseClass* p = o; p; p = p->VpiParent())
        if (p->UhdmType() == uhdmpackage) pkg = p;
    return pkg;
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct207ref <db> [--list] [--clones] [--name=SUB]\n");
        return 2;
    }
    bool list = false, clones = false;
    const char* nameFilt = nullptr;
    for (int i = 2; i < argc; i++) {
        if (!strcmp(argv[i], "--list")) list = true;
        else if (!strcmp(argv[i], "--clones")) clones = true;
        else if (!strncmp(argv[i], "--name=", 7)) nameFilt = argv[i] + 7;
    }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { printf("NO_DESIGN\n"); return 3; }

    // WHICH SUBROUTINES ARE CLONE BODIES.  The emitter's own registry
    // (`pkgImportCloneTfs16`, populated by § 194 for WILDCARD imports only) is
    // not in the database, so this probe reconstructs the same set the only way
    // a reader can: a package subroutine listing whose declared HOME package —
    // the package that DECLARES the typedefs its chain binds — is a DIFFERENT
    // package from the one that lists it.  Reported, never used as a gate: the
    // production law reads the real registry.
    std::map<const task_func*, std::set<std::string>> tfPkg;
    // owner masks over every ref reached from a declaration chain
    std::map<const ref_typespec*, int> owner;
    // the refs that BIND A STRUCT carrying a repairable member
    std::map<const ref_typespec*, std::string> structRef;
    std::map<const ref_typespec*, std::string> memberRef;

    auto repairable = [](const typespec* t) -> bool {
        if (!t || !scalarTdKind(t->UhdmType())) return false;
        const ref_typespec* al = t->Typedef_alias();
        const typespec* tg = al ? al->Actual_typespec() : nullptr;
        // § 180's repair shape: our own name is already bare, the alias target
        // is still the package-qualified listing object.  A raw listing object
        // (QUAL name, no alias) counts too — nothing bared it at all.
        if (tg) return !strcmp(shapeOf(t->VpiName()), "BARE") &&
                       !strcmp(shapeOf(tg->VpiName()), "QUAL");
        return !strcmp(shapeOf(t->VpiName()), "QUAL");
    };

    std::function<void(const ref_typespec*, int, int)> walk =
        [&](const ref_typespec* rt, int bit, int budget) {
            if (!rt || budget <= 0) return;
            owner[(const ref_typespec*)rt] |= bit;
            const typespec* at = rt->Actual_typespec();
            if (!at) return;
            if (at->UhdmType() == uhdmarray_typespec) {
                auto* a = (const array_typespec*)at;
                walk(a->Elem_typespec(), bit, budget - 1);
                walk(a->Index_typespec(), bit, budget - 1);
                return;
            }
            if (at->UhdmType() == uhdmpacked_array_typespec) {
                auto* a = (const packed_array_typespec*)at;
                walk(a->Elem_typespec(), bit, budget - 1);
                return;
            }
            if (at->UhdmType() == uhdmstruct_typespec) {
                auto* st = (const struct_typespec*)at;
                int nrep = 0;
                if (auto* ms = st->Members())
                    for (auto* m : *ms) {
                        const ref_typespec* mr = m->Typespec();
                        if (!mr) continue;
                        walk(mr, bit, budget - 1);
                        const typespec* mt = mr->Actual_typespec();
                        if (repairable(mt)) {
                            ++nrep;
                            char b[400];
                            snprintf(b, sizeof b, "%s.%s", nm(st).c_str(),
                                     nm(m).c_str());
                            memberRef[mr] = b;
                        }
                    }
                if (nrep) {
                    char b[400];
                    snprintf(b, sizeof b, "%s (repairable members=%d)",
                             nm(st).c_str(), nrep);
                    structRef[rt] = b;
                }
                return;
            }
        };

    for (auto& kv : s.AllObjects()) {
        auto* o = (const BaseClass*)kv.first;
        if (!o) continue;
        const ref_typespec* rt = nullptr;
        if (auto* v = any_cast<const variables*>(o)) rt = v->Typespec();
        else if (auto* io = any_cast<const io_decl*>(o)) rt = io->Typespec();
        if (!rt) continue;
        const task_func* tf = declTf(o);
        if (!tf) continue;
        const BaseClass* pk = pkgOf(o);
        tfPkg[tf].insert(nm(pk));
        // A clone body is one listed under a package that is NOT the package
        // that declares the typedefs it binds.  Reconstructed here from the
        // vpiInstance of the chain's scalar typespecs.
        bool isClone = false;
        {
            const typespec* at = rt->Actual_typespec();
            const typespec* probe = at;
            for (int g = 0; probe && g < 6; ++g) {
                if (probe->UhdmType() == uhdmarray_typespec)
                    probe = ((const array_typespec*)probe)->Elem_typespec()
                                ? ((const array_typespec*)probe)
                                      ->Elem_typespec()
                                      ->Actual_typespec()
                                : nullptr;
                else if (probe->UhdmType() == uhdmpacked_array_typespec)
                    probe = ((const packed_array_typespec*)probe)->Elem_typespec()
                                ? ((const packed_array_typespec*)probe)
                                      ->Elem_typespec()
                                      ->Actual_typespec()
                                : nullptr;
                else break;
            }
            const any* in = probe ? ((typespec*)probe)->Instance() : nullptr;
            if (in && pk && nm(in) != nm(pk)) isClone = true;
        }
        // § 16's RETURN-VARIABLE EXCEPTION, verbatim: a clone function's return
        // variable counts as a NON-clone owner.
        if (isClone && tf->UhdmType() == uhdmfunction &&
            (const BaseClass*)((const function*)tf)->Return() == o)
            isClone = false;
        walk(rt, isClone ? 1 : 2, 8);
    }

    auto tally = [&](const char* what,
                     const std::map<const ref_typespec*, std::string>& m) {
        std::map<std::string, long> t;
        for (auto& [r, face] : m) {
            if (nameFilt && face.find(nameFilt) == std::string::npos) continue;
            int mask = owner.count(r) ? owner[r] : 0;
            const char* v = mask == 1 ? "MOVE"
                          : mask == 3 ? "REFUSE-SHARED"
                          : mask == 2 ? "HOME" : "UNREACHED";
            char b[520];
            snprintf(b, sizeof b, "%-14s %s", v, face.c_str());
            t[b]++;
            if (list) printf("%-8s %-14s %s\n", what, v, face.c_str());
        }
        printf("\n%s REFS BY VERDICT x FACE:\n", what);
        long move = 0, ref = 0, home = 0;
        for (auto& [k, v] : t) {
            printf("  %-92s %6ld\n", k.c_str(), v);
            if (!k.compare(0, 4, "MOVE")) move += v;
            else if (!k.compare(0, 13, "REFUSE-SHARED")) ref += v;
            else if (!k.compare(0, 4, "HOME")) home += v;
        }
        printf("  TOTAL %s: MOVE=%ld REFUSE-SHARED=%ld HOME=%ld\n", what, move,
               ref, home);
    };
    tally("STRUCT-BINDING", structRef);
    tally("MEMBER", memberRef);
    if (clones) {
        long multi = 0;
        for (auto& [tf, p] : tfPkg) if (p.size() > 1) ++multi;
        printf("\nsubroutines with declarations listed under >1 package: %ld / %zu\n",
               multi, tfPkg.size());
    }
    return 0;
}
