// r10v182 — VERIFIER'S CORRECTED MOVER PREDICTOR (measurement only).
// r10uvm182's own ct182pred requires the candidate element's Actual_group to be
// NULL in the pristine database.  That is UNSOUND: § builtinArrayReadBinds-
// MintedFuncCall182 runs BEFORE `bind9`, so an element that pristine's `bind9`
// bound to a BODY LOCAL of the same name (arm C cell C3 — one of the pass's own
// headline cells) is a mover whose pristine bytes are NOT null.  ct182pred
// reports 0 candidates on that arm's own pristine database.
// This predictor drops the null requirement and instead excludes only the
// actual kinds § pkgCloneMember10 produces (typespec_member) and an already
// minted func_call.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <algorithm>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;
static bool arrayKind(const any* a) {
    if (!a) return false;
    auto t = a->UhdmType();
    return t == uhdmarray_var || t == uhdmpacked_array_var ||
           t == uhdmarray_net || t == uhdmpacked_array_net;
}
static bool builtinName(const std::string& n) {
    return n == "size" || n == "exists" || n == "find" || n == "max" || n == "min";
}
int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: v182pred <db.uhdm>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmhier_path) continue;
        const VectorOfany* v = ((const hier_path*)o)->Path_elems();
        if (!v) continue;
        for (size_t i = 1; i < v->size(); ++i) {
            const any* ce = v->at(i);
            if (!ce || ce->UhdmType() != uhdmref_obj) continue;
            const any* pe = v->at(i - 1);
            if (!pe || pe->UhdmType() != uhdmref_obj) continue;
            const ref_obj* cur = (const ref_obj*)ce;
            const ref_obj* prv = (const ref_obj*)pe;
            const std::string nm(cur->VpiName());
            if (!builtinName(nm)) continue;
            if (!arrayKind(prv->Actual_group())) continue;
            const any* ca = cur->Actual_group();
            if (ca && (ca->UhdmType() == uhdmtypespec_member ||
                       ca->UhdmType() == uhdmfunc_call)) continue;
            char b[900];
            snprintf(b, sizeof b, "  CAND %s %u:%u %s act=%s",
                     std::string(o->VpiName()).c_str(), cur->VpiLineNo(),
                     (unsigned)cur->VpiColumnNo(), nm.c_str(),
                     ca ? std::string(UhdmName(ca->UhdmType())).c_str() : "<null>");
            rows.push_back(b);
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("CANDIDATES %zu %s\n", rows.size(), argv[1]);
    return 0;
}
