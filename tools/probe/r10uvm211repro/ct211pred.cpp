// r10uvm211 — THE A-PRIORI MOVER PREDICTOR.  Reads ONE database (a PRISTINE
// one) and prints how many cells § cloneSharedArrayStructSplitMint211 can move
// in it, from the database ALONE — no emitter state, no patched run.
//
// This is r10uvm208repro/ct208pred.cpp's method aimed one link over: § 208
// split the array chain whose ELEMENT was a package SCALAR typedef; § 211
// splits the array chain whose ELEMENT is a package STRUCT typedef with a
// repairable member.  § 207 re-points a struct-binding ref whose owner mask is
// 1 and REFUSES mask 3, so the population here is exactly § 207's refused set.
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
//     `packed_array_typespec` `Elem_typespec` and `Index_typespec` links, and
//     the STRUCT the element ref binds;
//   * every ref carries an OWNER MASK — clone / not-clone — and the split
//     needs the DECLARATION'S OWN ref exclusive (mask 1) and the ELEMENT ref
//     SHARED (mask 3), which is the mask § 207 refused.
//
// `pkgImportCloneTfs16` is emitter state that no database records, so CLONE is
// decided by the database's own evidence, exactly as § 208's predictor did:
// the declaration's outermost package ancestor is NOT the package that
// qualifies the bound member's alias target (`uvm_pkg::uvm_reg_addr_t` reached
// from a declaration listed under `svaunit_pkg` is a wildcard-import clone
// body's, by construction — the home body's copies are listed under `uvm_pkg`
// itself).
//
// splits = the DECLARATIONS that get a fresh array chain.  cells = the member
// cells those splits repair.  shared = the element refs § 207 refused, the
// upper bound the movers must stay inside.
//
// build: g++ -O2 -std=c++17 ct211pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct211pred
// usage: ct211pred <db.uhdm> <row label> [--list]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <functional>
#include <map>
#include <set>
#include <string>

using namespace UHDM;

static bool scalarTdKind(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmlogic_typespec:
        case uhdmbit_typespec:
        case uhdmint_typespec:
        case uhdminteger_typespec:
        case uhdmbyte_typespec:
        case uhdmshort_int_typespec:
        case uhdmlong_int_typespec:
            return true;
        default:
            return false;
    }
}
static std::string nameOf(const BaseClass* o) {
    return o ? std::string(o->VpiName()) : std::string("-");
}
// § 16's own fence, as a climb: the innermost enclosing subroutine of a
// DECLARATION, refusing a class PROPERTY.
static const task_func* declTf(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        const auto k = p->UhdmType();
        if (k == uhdmfunction || k == uhdmtask) return (const task_func*)p;
        if (k == uhdmclass_defn || k == uhdmpackage || k == uhdmmodule_inst ||
            k == uhdmdesign)
            return nullptr;
    }
    return nullptr;
}
static std::string outerPkg(const BaseClass* o) {
    const BaseClass* pkg = nullptr;
    for (const BaseClass* p = o; p; p = p->VpiParent())
        if (p->UhdmType() == uhdmpackage) pkg = p;
    return pkg ? std::string(pkg->VpiName()) : std::string("-");
}
// a member cell in the § 180 repair shape: BARE own name, QUALIFIED alias
// target.  The qualifier is returned so the CLONE test can compare it with the
// declaration's own outermost package.
static bool repairShape(const typespec* mt, std::string& qual) {
    if (!mt || !scalarTdKind(mt->UhdmType())) return false;
    auto* al = mt->Typedef_alias();
    auto* tg = al ? al->Actual_typespec() : nullptr;
    if (!tg) return false;
    std::string tn(tg->VpiName()), mn(mt->VpiName());
    auto p = tn.find("::");
    if (p == std::string::npos || mn.find("::") != std::string::npos)
        return false;
    qual = tn.substr(0, p);
    return true;
}
static bool repairableStruct(const struct_typespec* st, std::string& qual,
                             int budget) {
    if (!st || budget <= 0 || !st->Members()) return false;
    for (auto* m : *st->Members()) {
        auto* mr = m->Typespec();
        auto* mt = mr ? mr->Actual_typespec() : nullptr;
        if (!mt) continue;
        if (repairShape(mt, qual)) return true;
        if (mt->UhdmType() == uhdmstruct_typespec &&
            repairableStruct((const struct_typespec*)mt, qual, budget - 1))
            return true;
    }
    return false;
}
static int repairableCells(const struct_typespec* st, int budget) {
    if (!st || budget <= 0 || !st->Members()) return 0;
    int n = 0;
    std::string q;
    for (auto* m : *st->Members()) {
        auto* mr = m->Typespec();
        auto* mt = mr ? mr->Actual_typespec() : nullptr;
        if (!mt) continue;
        if (repairShape(mt, q)) ++n;
        else if (mt->UhdmType() == uhdmstruct_typespec)
            n += repairableCells((const struct_typespec*)mt, budget - 1);
    }
    return n;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct211pred <db.uhdm> <row label> [--list]\n");
        return 2;
    }
    bool list = (argc > 3 && !strcmp(argv[3], "--list"));
    FILE* f = fopen(argv[1], "rb");
    if (!f) { printf("PREDCELLS %s OPENFAIL\n", argv[2]); return 3; }
    fclose(f);
    Serializer S;
    S.Restore(std::string(argv[1]));

    // Pass 1 — the owner mask over every ref in every declaration chain, and
    // the struct each ref binds.
    std::map<const ref_typespec*, int> own;
    std::map<const ref_typespec*, const struct_typespec*> sref;
    std::map<const ref_typespec*, const BaseClass*> declOf;
    std::set<const ref_typespec*> ownRef;
    std::function<void(const ref_typespec*, int, int)> walk =
        [&](const ref_typespec* rt, int bit, int budget) {
            if (!rt || budget <= 0) return;
            own[rt] |= bit;
            auto* at = rt->Actual_typespec();
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
                std::string q;
                if (repairableStruct(st, q, 6)) sref[rt] = st;
            }
        };
    std::map<const BaseClass*, const ref_typespec*> rootOf;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const ref_typespec* rt = nullptr;
        if (auto* v = any_cast<const variables*>(o)) rt = v->Typespec();
        else if (auto* io = any_cast<const io_decl*>(o)) rt = io->Typespec();
        if (!rt) continue;
        const task_func* tf = declTf(o);
        if (!tf) continue;
        // CLONE, from the database's own evidence: a declaration whose
        // outermost package ancestor is not the package that qualifies the
        // repair-shape member reached below it.
        bool clone = false;
        {
            std::string q;
            const typespec* at = rt->Actual_typespec();
            const typespec* cur = at;
            for (int g = 0; cur && g < 8; ++g) {
                if (cur->UhdmType() == uhdmarray_typespec) {
                    auto* rr = ((const array_typespec*)cur)->Elem_typespec();
                    cur = rr ? rr->Actual_typespec() : nullptr;
                } else if (cur->UhdmType() == uhdmpacked_array_typespec) {
                    auto* rr =
                        ((const packed_array_typespec*)cur)->Elem_typespec();
                    cur = rr ? rr->Actual_typespec() : nullptr;
                } else break;
            }
            if (cur && cur->UhdmType() == uhdmstruct_typespec)
                repairableStruct((const struct_typespec*)cur, q, 6);
            else if (cur)
                repairShape(cur, q);
            if (!q.empty() && q != outerPkg(o)) clone = true;
        }
        if (clone && tf->UhdmType() == uhdmfunction &&
            (const BaseClass*)((const function*)tf)->Return() == o)
            clone = false;
        ownRef.insert(rt);
        if (clone) { declOf[rt] = o; rootOf[o] = rt; }
        walk(rt, clone ? 1 : 2, 8);
    }
    // Pass 2 — the split set: a clone declaration whose OWN ref is exclusive
    // and whose chain holds an element ref § 207 refused (mask 3) that binds a
    // repairable struct.
    long shared = 0, splits = 0, cells = 0;
    for (auto& [rt, st] : sref)
        if (own[rt] == 3) ++shared;
    std::set<std::string> names;
    std::function<int(const typespec*, int)> below = [&](const typespec* at,
                                                         int budget) -> int {
        if (!at || budget <= 0) return 0;
        auto link = [&](const ref_typespec* rr) -> int {
            if (!rr) return 0;
            auto it = sref.find(rr);
            if (it != sref.end() && own[rr] == 3)
                return repairableCells(it->second, 6);
            return below(rr->Actual_typespec(), budget - 1);
        };
        if (at->UhdmType() == uhdmarray_typespec) {
            auto* a = (const array_typespec*)at;
            return link(a->Elem_typespec()) + link(a->Index_typespec());
        }
        if (at->UhdmType() == uhdmpacked_array_typespec)
            return link(((const packed_array_typespec*)at)->Elem_typespec());
        return 0;
    };
    for (auto& [o, rt] : rootOf) {
        if (own[rt] != 1) continue;
        int c = below(rt->Actual_typespec(), 8);
        if (c <= 0) continue;
        ++splits;
        cells += c;
        char b[512];
        const task_func* tf = declTf(o);
        snprintf(b, sizeof b, "%s|%s|%s@%u:%u", outerPkg(o).c_str(),
                 nameOf(tf).c_str(), nameOf(o).c_str(), o->VpiLineNo(),
                 (unsigned)o->VpiColumnNo());
        names.insert(b);
    }
    printf("PREDCELLS %s shared=%ld splits=%ld cells=%ld\n", argv[2], shared,
           splits, cells);
    if (list)
        for (auto& n : names) printf("PREDSPLIT %s %s\n", argv[2], n.c_str());
    return 0;
}
