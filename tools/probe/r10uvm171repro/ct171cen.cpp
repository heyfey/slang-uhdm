// r10uvm171 — SELECT/PREFIX ACTUAL-BINDING CENSUS.  MEASUREMENT ONLY; the
// official ~/git-repos/UHDM/build/bin/uhdm-cmp is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The r10uvm171 head is `string_var(uvm_pkg::uvm_instance_scope)` with
// `RHS: <null>` — BaseClass.h's SINGULAR SafeCompare naming a VALUE.  The
// owner-finder (ct171own.cpp) named the failing edges: `vpiActual` (700) of a
// `bit_select` and of the leading `ref_obj` of a method-call `hier_path`, in
// the ELABORATED view, where golden binds the enclosing function's RETURN
// variable and we bind nothing.
//
// This census keys every reference-bearing object by
//   kind | parent-kind | grandparent-kind | actual-kind(or NULL) | line:col
// and multiset-joins golden against ours.  The DEF/ELAB view is deliberately
// NOT in the key (the two producers label the clone's home differently — see
// RESUME §9 "keep the DEF/ELAB view out of the key"); the two views are
// instead separated by their COUNT per span, which is what the join reports.
//
// build: g++ -O2 -std=c++17 ct171cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct171cen
// usage: ct171cen <golden.uhdm> <ours.uhdm> [--rows]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kn(const BaseClass* o) {
    // UhdmName returns a string_view that is NOT guaranteed NUL-terminated —
    // printing its .data() with %s prints the whole table.  Copy it.
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static const any* actualOf(const BaseClass* o) {
    // bit_select / part_select / var_select / indexed_part_select are all IS-A
    // ref_obj in UHDM, so ONE accessor covers the whole select family.
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
// The population this pass measures: the SELECT family (all IS-A ref_obj) and
// the leading `ref_obj` of a method-call `hier_path`.  A plain `ref_obj` under
// an ordinary expression is EXCLUDED — it binds on both sides already, and
// carrying it would drown the join in unrelated naming residues.
static bool isRefish(const BaseClass* o) {
    const UHDM_OBJECT_TYPE t = o->UhdmType();
    if (t == uhdmbit_select || t == uhdmpart_select || t == uhdmvar_select ||
        t == uhdmindexed_part_select)
        return true;
    if (t == uhdmref_obj && o->VpiParent() &&
        o->VpiParent()->UhdmType() == uhdmhier_path)
        return true;
    return false;
}
// The nearest enclosing subroutine, and whether the reference names ITS return
// variable (the name equals the subroutine's name).
static const BaseClass* encFn(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct171cen <golden> <ours> [--rows]\n"); return 2; }
    const bool rows = (argc > 3 && !strcmp(argv[3], "--rows"));
    // --agg drops line:col from the key and prints EVERY key (agreeing ones
    // too): the shape tally that decodes Surelog's rule, as opposed to the
    // span-keyed join that names the movers.
    const bool agg = (argc > 3 && !strcmp(argv[3], "--agg"));
    std::map<std::string, int> cg, co;
    for (int side = 0; side < 2; ++side) {
        Serializer s;
        if (s.Restore(std::string(argv[1 + side])).empty()) {
            printf("RESTORE_FAIL %s\n", side ? "ours" : "golden");
            return 3;
        }
        std::map<std::string, int>& C = side ? co : cg;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || !isRefish(o)) continue;
            const any* a = actualOf(o);
            const BaseClass* p = o->VpiParent();
            const BaseClass* g = p ? p->VpiParent() : nullptr;
            const BaseClass* fn = encFn(o);
            const bool isRet =
                fn && std::string(fn->VpiName()) == std::string(o->VpiName());
            char b[700];
            if (agg)
                snprintf(b, sizeof b, "%-22s par=%-18s gp=%-18s ret=%d act=%s",
                         kn(o).c_str(), kn(p).c_str(), kn(g).c_str(), isRet ? 1 : 0,
                         a ? kn(a).c_str() : "NULL");
            else
                snprintf(b, sizeof b, "%-22s par=%-18s gp=%-18s ret=%d act=%-18s %u:%u",
                         kn(o).c_str(), kn(p).c_str(), kn(g).c_str(), isRet ? 1 : 0,
                         a ? kn(a).c_str() : "NULL",
                         o->VpiLineNo(), (unsigned)o->VpiColumnNo());
            C[b]++;
        }
    }
    long onlyG = 0, onlyO = 0, both = 0;
    std::map<std::string, int> all;
    for (auto& kv : cg) all[kv.first] += 0;
    for (auto& kv : co) all[kv.first] += 0;
    for (auto& kv : all) {
        int a = cg.count(kv.first) ? cg[kv.first] : 0;
        int b = co.count(kv.first) ? co[kv.first] : 0;
        if (a == b && !agg) { both += a; continue; }
        if (a == b) { both += a; printf("  g=%-5d o=%-5d  %s\n", a, b, kv.first.c_str()); continue; }
        if (a > b) onlyG += a - b;
        if (b > a) onlyO += b - a;
        if (rows || agg) printf("  g=%-5d o=%-5d  %s\n", a, b, kv.first.c_str());
    }
    printf("CENSUS agree=%ld golden-only=%ld ours-only=%ld keys=%zu\n", both, onlyG,
           onlyO, all.size());
    return 0;
}
