// r10uvm182 — THE MOVER PREDICTOR, from PRISTINE BYTES ONLY.
// MEASUREMENT ONLY; `uhdm-cmp` is the sole judge.
//
// § builtinArrayReadBindsMintedFuncCall182's byte signature in a PRISTINE
// database: a `hier_path` element at index i>0 that is
//   * a `ref_obj`,
//   * with a NULL `Actual_group`,
//   * named exactly `size` / `exists` / `find` / `max` / `min`,
//   * whose element i-1 is a `ref_obj` already BOUND to an `array_var` /
//     `packed_array_var` / `array_net` / `packed_array_net`.
//
// It is stated as an UPPER BOUND: bytes cannot show whether the owning
// subroutine is one of the emitter's wildcard-import CLONE bodies, which is the
// law's other gate, so a candidate outside one will not actually move.  A
// database with ZERO candidates provably cannot move.
//
// build: g++ -O2 -std=c++17 ct182pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct182pred
// usage: ct182pred <db.uhdm>       (prints one line per candidate, then a count)
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
    return n == "size" || n == "exists" || n == "find" || n == "max" ||
           n == "min";
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct182pred <db.uhdm>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmhier_path) continue;
        const VectorOfany* v = ((const hier_path*)o)->Path_elems();
        if (!v) continue;
        for (size_t i = 1; i < v->size(); ++i) {
            const ref_obj* cur = any_cast<const ref_obj*>(v->at(i));
            const ref_obj* prv = any_cast<const ref_obj*>(v->at(i - 1));
            if (!cur || !prv) continue;
            if (cur->Actual_group()) continue;
            const std::string nm(cur->VpiName());
            if (!builtinName(nm)) continue;
            if (!arrayKind(prv->Actual_group())) continue;
            char b[900];
            snprintf(b, sizeof b, "  CAND %s %u:%u %s",
                     std::string(o->VpiName()).c_str(), cur->VpiLineNo(),
                     (unsigned)cur->VpiColumnNo(), nm.c_str());
            rows.push_back(b);
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("CANDIDATES %zu %s\n", rows.size(), argv[1]);
    return 0;
}
