// r10uvm207 — THE A-PRIORI MOVER PREDICTOR.  Reads ONE database (a PRISTINE
// one) and prints how many refs § cloneStructMemberBareTdAlias207 can move in
// it, from the database ALONE — no emitter state, no patched run.
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
//
// It re-implements the law's own walk (r10uvm205's `ct205pred` form, one link
// deeper):
//   * every declaration (`variables` / `io_decl`) whose innermost enclosing
//     object, climbing `VpiParent`, is a subroutine (a `class_defn`, package,
//     module or design on the way REFUSES it, exactly as § 16 does);
//   * a function's RETURN variable counts as a NON-clone owner (§ 16's
//     measured exception);
//   * the typespec chain below it, descending `array_typespec` /
//     `packed_array_typespec` `Elem_typespec` / `Index_typespec` links AND a
//     `struct_typespec`'s `Members()`;
//   * EVERY ref in that chain carries an OWNER MASK — clone / not-clone — and
//     only a CLONE-EXCLUSIVE ref BINDING A STRUCT WITH A REPAIRABLE MEMBER may
//     move.
//
// `pkgImportCloneTfs16` is emitter state no database records, so CLONE is
// decided by the database's own evidence, exactly as `ct205pred` decides it:
// the declaration's outermost package ancestor is NOT the package that
// qualifies the typedef its chain binds.
//
// strict = the refs the law moves.  wide = the same population WITHOUT the
// exclusivity guard, i.e. the upper bound the movers must stay inside.
// cells   = the repairable MEMBER cells those refs carry, the number the
//           census must then show moving TO-GOLDEN.
//
// build: g++ -O2 -std=c++17 ct207pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct207pred
// usage: ct207pred <db.uhdm> <row label>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <functional>
#include <map>
#include <set>
#include <string>

using namespace UHDM;

static bool scalarTdKind(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmlogic_typespec: case uhdmbit_typespec: case uhdmint_typespec:
        case uhdminteger_typespec: case uhdmbyte_typespec:
        case uhdmshort_int_typespec: case uhdmlong_int_typespec: return true;
        default: return false;
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct207pred <db> <row>\n"); return 2; }
    const char* row = argv[2];
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        printf("RESTORE_FAIL %s\n", row);
        return 3;
    }
    auto declTf = [](const BaseClass* o) -> const task_func* {
        for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
            const auto k = p->UhdmType();
            if (k == uhdmfunction || k == uhdmtask) return (const task_func*)p;
            if (k == uhdmclass_defn || k == uhdmpackage ||
                k == uhdmmodule_inst || k == uhdmdesign)
                return nullptr;
        }
        return nullptr;
    };
    auto outerPkg = [](const BaseClass* o) -> std::string {
        const BaseClass* pkg = nullptr;
        for (const BaseClass* p = o; p; p = p->VpiParent())
            if (p->UhdmType() == uhdmpackage) pkg = p;
        return pkg ? std::string(pkg->VpiName()) : std::string();
    };
    // a member typespec that still stands for a package scalar-typedef listing
    // object: either LAW S's bare copy whose alias target is still qualified,
    // or the raw qualified listing object itself.
    auto repairableTs = [](const typespec* t) -> bool {
        if (!t || !scalarTdKind(t->UhdmType())) return false;
        const ref_typespec* al = t->Typedef_alias();
        const typespec* tg = al ? al->Actual_typespec() : nullptr;
        const std::string n(t->VpiName());
        if (tg) {
            const std::string an(tg->VpiName());
            return n.find("::") == std::string::npos &&
                   an.find("::") != std::string::npos;
        }
        return n.find("::") != std::string::npos;
    };
    std::function<int(const struct_typespec*, int)> repCount =
        [&](const struct_typespec* st, int budget) -> int {
        if (!st || budget <= 0 || !st->Members()) return 0;
        int n = 0;
        for (auto* m : *st->Members()) {
            const ref_typespec* mr = m->Typespec();
            const typespec* mt = mr ? mr->Actual_typespec() : nullptr;
            if (!mt) continue;
            if (repairableTs(mt)) ++n;
            else if (mt->UhdmType() == uhdmstruct_typespec)
                n += repCount((const struct_typespec*)mt, budget - 1);
        }
        return n;
    };

    std::map<const ref_typespec*, int> owner;
    std::map<const ref_typespec*, const struct_typespec*> sref;
    std::function<void(const ref_typespec*, int, int)> walk =
        [&](const ref_typespec* rt, int bit, int budget) {
            if (!rt || budget <= 0) return;
            owner[rt] |= bit;
            const typespec* at = rt->Actual_typespec();
            if (!at) return;
            if (at->UhdmType() == uhdmarray_typespec) {
                auto* a = (const array_typespec*)at;
                walk(a->Elem_typespec(), bit, budget - 1);
                walk(a->Index_typespec(), bit, budget - 1);
            } else if (at->UhdmType() == uhdmpacked_array_typespec) {
                auto* a = (const packed_array_typespec*)at;
                walk(a->Elem_typespec(), bit, budget - 1);
            } else if (at->UhdmType() == uhdmstruct_typespec) {
                auto* st = (const struct_typespec*)at;
                if (st->Members())
                    for (auto* m : *st->Members())
                        walk(m->Typespec(), bit, budget - 1);
                if (repCount(st, 6) > 0) sref[rt] = st;
            }
        };
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const ref_typespec* rt = nullptr;
        if (auto* v = any_cast<const variables*>(o)) rt = v->Typespec();
        else if (auto* io = any_cast<const io_decl*>(o)) rt = io->Typespec();
        if (!rt) continue;
        const task_func* tf = declTf(o);
        if (!tf) continue;
        // the CLONE test, from the database alone (ct205pred's, extended
        // through a struct member so a struct-typed declaration is testable).
        std::string pk = outerPkg(o);
        bool clone = false;
        std::function<void(const ref_typespec*, int)> probe =
            [&](const ref_typespec* r, int budget) {
                if (!r || budget <= 0 || clone) return;
                const typespec* at = r->Actual_typespec();
                if (!at) return;
                if (scalarTdKind(at->UhdmType())) {
                    const ref_typespec* al = at->Typedef_alias();
                    const typespec* tg = al ? al->Actual_typespec() : nullptr;
                    std::string n = tg ? std::string(tg->VpiName())
                                       : std::string(at->VpiName());
                    auto q = n.find("::");
                    if (q != std::string::npos && !pk.empty() &&
                        n.substr(0, q) != pk)
                        clone = true;
                    return;
                }
                if (at->UhdmType() == uhdmarray_typespec) {
                    auto* a = (const array_typespec*)at;
                    probe(a->Elem_typespec(), budget - 1);
                    probe(a->Index_typespec(), budget - 1);
                } else if (at->UhdmType() == uhdmpacked_array_typespec) {
                    probe(((const packed_array_typespec*)at)->Elem_typespec(),
                          budget - 1);
                } else if (at->UhdmType() == uhdmstruct_typespec) {
                    auto* st = (const struct_typespec*)at;
                    if (st->Members())
                        for (auto* m : *st->Members())
                            probe(m->Typespec(), budget - 1);
                }
            };
        probe(rt, 8);
        if (clone && tf->UhdmType() == uhdmfunction &&
            (const BaseClass*)((const function*)tf)->Return() == o)
            clone = false;
        walk(rt, clone ? 1 : 2, 8);
    }
    long strict = 0, wide = 0, cells = 0;
    std::set<std::string> names;
    for (auto& [rt, st] : sref) {
        auto it = owner.find(rt);
        const int m = it == owner.end() ? 0 : it->second;
        if (!(m & 1)) continue;
        ++wide;
        if (m == 1) {
            ++strict;
            cells += repCount(st, 6);
            names.insert(std::string(st->VpiName()));
        }
    }
    std::string nm;
    for (auto& n : names) nm += (nm.empty() ? "" : ",") + n;
    printf("PREDCELLS %s strict=%ld wide=%ld cells=%ld structs=[%s]\n", row,
           strict, wide, cells, nm.c_str());
    return 0;
}
