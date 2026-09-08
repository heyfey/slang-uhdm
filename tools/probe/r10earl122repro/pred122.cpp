// r10earl122 — THE PREDICTION, made from the PRISTINE database ALONE.
//
// MEASUREMENT ONLY.  The official `uhdm-cmp` stays the sole acceptance judge.
//
// Prints the cells § genCaPatTagDeepBind122's descent can reach — the mover set
// BY NAME, before the patched database exists.  The condition is the patch's,
// term for term, EXCEPT the two terms a database cannot see; both can only make
// this an OVER-count, never an under-count, and both are named here:
//
//   patch term                                   | here
//   ---------------------------------------------|--------------------------
//   n20 is a `tagged_pattern` -> descend Pattern  | the path from the CA's Rhs
//                                                 | to the ref passes through
//                                                 | at least one tagged_pattern
//   walk runs only under `lhsGenLocal20`          | the CA's Lhs is a ref_obj
//     (d0: the Lhs names a Variable of THIS       | naming a `Variables` member
//      block; § 23: the Lhs is a select)          | of this gen_scope, or is a
//                                                 | select/hier_path object
//   `ca->Rhs()->UhdmType() == uhdmoperation`      | same
//   the ref's name is a Variable of THIS block    | the name is in this
//     and its netMap object is NOT a net kind     | gen_scope's `Variables()`
//   the ref is not already bound                  | same
//   § genCaAncestorNetShadowUnbinds98's walk up   | *** NOT VISIBLE ***: a
//     the elaborated hierarchy turns the walk OFF | shadowed Lhs is counted
//     when an ancestor MODULE body declares the   | here and does NOT move
//     Lhs name as a net/variable                  | (arm gf7)
//   the block's own member scan (a name also      | *** NOT VISIBLE ***: same
//     declared in the module body unbinds it)     | direction
//
// build: g++ -O2 -std=c++17 pred122.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred122
// usage: pred122 <ours.uhdm>          (prints one PRED row per predicted cell)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string spanOf(const BaseClass* o) {
    if (!o) return "-";
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}

// the UHDM kinds `deep20`'s leaf filter refuses (net-kind netMap objects)
static bool isNetKind(const BaseClass* o) {
    if (!o) return true;
    switch (o->UhdmType()) {
        case uhdmlogic_net:
        case uhdmarray_net:
        case uhdmstruct_net:
        case uhdmenum_net:
        case uhdmpacked_array_net:
        case uhdmnet_bit:
            return true;
        default:
            return false;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: pred122 <ours.uhdm>\n"); return 2; }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "FATAL: restore failed %s\n", argv[1]); return 3; }

    size_t sites = 0, cells = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        const gen_scope* gs = any_cast<const gen_scope*>((const any*)obj);
        if (!gs) continue;
        // the block's own non-net declarations, by name
        std::map<std::string, const BaseClass*> vars;
        if (auto* vv = gs->Variables())
            for (auto* v : *vv) vars[std::string(v->VpiName())] = v;
        if (!gs->Cont_assigns()) continue;
        for (auto* ca : *gs->Cont_assigns()) {
            const any* rhs = ca->Rhs();
            const any* lhs = ca->Lhs();
            if (!rhs || rhs->UhdmType() != uhdmoperation || !lhs) continue;
            bool lhsOk = false;
            if (lhs->UhdmType() == uhdmref_obj)
                lhsOk = vars.count(std::string(lhs->VpiName())) != 0;
            else if (lhs->UhdmType() == uhdmbit_select ||
                     lhs->UhdmType() == uhdmpart_select ||
                     lhs->UhdmType() == uhdmindexed_part_select ||
                     lhs->UhdmType() == uhdmhier_path)
                lhsOk = true;
            if (!lhsOk) continue;
            sites++;
            // walk the Rhs the way `deep20` does, remembering whether a
            // tagged_pattern was crossed (only those cells are NEW reach)
            std::vector<std::pair<const any*, bool>> st{{rhs, false}};
            while (!st.empty()) {
                auto [n, viaTag] = st.back();
                st.pop_back();
                if (!n) continue;
                if (n->UhdmType() == uhdmoperation) {
                    if (auto* ops = ((const operation*)n)->Operands())
                        for (auto* o : *ops) st.push_back({o, viaTag});
                    continue;
                }
                if (n->UhdmType() == uhdmtagged_pattern) {
                    st.push_back({((const tagged_pattern*)n)->Pattern(), true});
                    continue;
                }
                if (n->UhdmType() == uhdmsys_func_call) {
                    if (auto* as = ((const sys_func_call*)n)->Tf_call_args())
                        for (auto* a : *as) st.push_back({a, viaTag});
                    continue;
                }
                if (n->UhdmType() != uhdmref_obj) continue;
                if (!viaTag) continue;  // the pristine walk already reached it
                const ref_obj* r = (const ref_obj*)n;
                if (r->Actual_group()) continue;
                auto it = vars.find(std::string(r->VpiName()));
                if (it == vars.end() || isNetKind(it->second)) continue;
                printf("PRED\t%s|%s|%s\n", std::string(gs->VpiFullName()).c_str(),
                       std::string(r->VpiName()).c_str(), spanOf(r).c_str());
                cells++;
            }
        }
    }
    fprintf(stderr, "sites=%zu predicted-cells=%zu\n", sites, cells);
    return 0;
}
