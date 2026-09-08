// r10uvm208 — THE A-PRIORI MOVER PREDICTOR.  Reads ONE database (a PRISTINE
// one) and prints how many cells § cloneSharedArrayElemSplitMint208 can move in
// it, from the database ALONE — no emitter state, no patched run.
//
// This is r10uvm205repro/ct205pred.cpp with the SCORE INVERTED.  § 205 moved
// the clone-EXCLUSIVE refs (owner mask 1) and refused the SHARED ones (mask 3);
// § 208 is exactly the refused set.  So the column that matters here is
// `shared` = wide − strict, and beside it `splits` = how many CLONE
// DECLARATIONS get a fresh chain (their own ref must be clone-exclusive, which
// is the split's own guard).  `strict` is printed unchanged so that a reader
// can check § 205's population is ALREADY MOVED in the database being scanned
// (it reads 0 on a post-§205 pristine database, which is the calibration).
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
//
// It re-implements the law's own walk:
//   * every declaration (`variables` / `io_decl`) whose innermost enclosing
//     object, climbing `VpiParent`, is a subroutine (a `class_defn`, package,
//     module or design on the way REFUSES it, exactly as § 16 does);
//   * a function's RETURN variable counts as a NON-clone owner (§ 16's
//     measured exception);
//   * the typespec chain below it, descending `array_typespec` /
//     `packed_array_typespec` `Elem_typespec` and `Index_typespec` links;
//   * a ref BELOW an array link carries an OWNER MASK — clone / not-clone —
//     and only a CLONE-EXCLUSIVE ref may move.
//
// `pkgImportCloneTfs16` is emitter state that no database records, so CLONE is
// decided by the database's own evidence: the declaration's outermost package
// ancestor is NOT the package that qualifies the bound typespec's alias target
// (`uvm_pkg::uvm_reg_addr_t` reached from a declaration listed under
// `adpcm_pkg` is a wildcard-import clone body's, by construction — the home
// body's copies are listed under `uvm_pkg` itself).
//
// strict = the cells the law moves.  wide = the same population WITHOUT the
// exclusivity guard, i.e. the upper bound the movers must stay inside.
//
// build: g++ -O2 -std=c++17 ct208pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct208pred
// usage: ct208pred <db.uhdm> <row label>
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
    if (argc < 3) { fprintf(stderr, "usage: ct205pred <db> <row>\n"); return 2; }
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
    // pass 1 — the owner mask over every ref below an array link, and (§ 208)
    // the owner mask on each DECLARATION'S OWN ref, which is what decides
    // whether the split may re-point it.
    std::map<const ref_typespec*, int> owner;
    std::map<const ref_typespec*, int> outer;
    std::function<void(const ref_typespec*, int, int, bool)> walk =
        [&](const ref_typespec* rt, int bit, int budget, bool below) {
            if (!rt || budget <= 0) return;
            if (below) owner[rt] |= bit;
            const typespec* at = rt->Actual_typespec();
            if (!at) return;
            if (at->UhdmType() == uhdmarray_typespec) {
                auto* a = (const array_typespec*)at;
                walk(a->Elem_typespec(), bit, budget - 1, true);
                walk(a->Index_typespec(), bit, budget - 1, true);
            } else if (at->UhdmType() == uhdmpacked_array_typespec) {
                auto* a = (const packed_array_typespec*)at;
                walk(a->Elem_typespec(), bit, budget - 1, true);
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
        // the CLONE test, from the database alone: the declaration's listing
        // package is not the package that qualifies the typedef it binds.
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
                }
            };
        probe(rt, 8);
        if (clone && tf->UhdmType() == uhdmfunction &&
            (const BaseClass*)((const function*)tf)->Return() == o)
            clone = false;
        walk(rt, clone ? 1 : 2, 8, false);
        outer[rt] |= clone ? 1 : 2;
    }
    long strict = 0, wide = 0, shared = 0;
    std::set<std::string> names, snames;
    for (auto& [rt, m] : owner) {
        const typespec* at = rt->Actual_typespec();
        if (!at || !scalarTdKind(at->UhdmType())) continue;
        const ref_typespec* al = at->Typedef_alias();
        const typespec* tg = al ? al->Actual_typespec() : nullptr;
        if (!tg) continue;
        std::string an(tg->VpiName());
        if (an.find("::") == std::string::npos) continue;   // already bare
        if (std::string(at->VpiName()).find("::") != std::string::npos)
            continue;                                       // not LAW S's shape
        if (m & 1) {
            ++wide;
            if (m == 1) { ++strict; names.insert(an); }
            else { ++shared; snames.insert(an); }
        }
    }
    // § 208's own population: the CLONE declarations whose own ref is
    // clone-exclusive and whose chain reaches one of the shared refs above.
    std::function<bool(const typespec*, int)> needs;
    auto linkNeeds = [&](const ref_typespec* r, int budget) -> bool {
        if (!r) return false;
        auto it = owner.find(r);
        if (it != owner.end() && it->second == 3) {
            const typespec* at = r->Actual_typespec();
            if (at && scalarTdKind(at->UhdmType())) {
                const ref_typespec* al = at->Typedef_alias();
                const typespec* tg = al ? al->Actual_typespec() : nullptr;
                if (tg && std::string(tg->VpiName()).find("::") !=
                              std::string::npos &&
                    std::string(at->VpiName()).find("::") == std::string::npos)
                    return true;
            }
        }
        return needs(r->Actual_typespec(), budget - 1);
    };
    needs = [&](const typespec* at, int budget) -> bool {
        if (!at || budget <= 0) return false;
        if (at->UhdmType() == uhdmarray_typespec) {
            auto* a = (const array_typespec*)at;
            return linkNeeds(a->Elem_typespec(), budget) ||
                   linkNeeds(a->Index_typespec(), budget);
        }
        if (at->UhdmType() == uhdmpacked_array_typespec)
            return linkNeeds(((const packed_array_typespec*)at)->Elem_typespec(),
                             budget);
        return false;
    };
    long splits = 0;
    for (auto& [rt, m] : outer)
        if (m == 1 && needs(rt->Actual_typespec(), 8)) ++splits;
    std::string nm, sn;
    for (auto& n : names) nm += (nm.empty() ? "" : ",") + n;
    for (auto& n : snames) sn += (sn.empty() ? "" : ",") + n;
    printf("PREDCELLS %s shared=%ld splits=%ld strict=%ld wide=%ld "
           "typedefs=[%s] shared-typedefs=[%s]\n", row, shared, splits, strict,
           wide, nm.c_str(), sn.c_str());
    return 0;
}
