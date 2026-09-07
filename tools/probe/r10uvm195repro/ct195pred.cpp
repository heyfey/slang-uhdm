// r10uvm195 — THE A-PRIORI PREDICTOR, read off a PRISTINE database alone.
// MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
//
// The patched emitter rewrites exactly one thing: a slot of a `task_func`'s OWN
// `vpiVariables` listing that holds a `ref_var` with a non-null `vpiActual`.
// So a pristine database moves IFF it holds such a slot — and this tool counts
// them and NAMES them, before the patched sweep is read.
//
// It also reports, per cell, whether the same object is listed ELSEWHERE (the
// `GetByVpiType(vpiVariables)` membership count), which is the branch the
// emitter takes: `>1` mints an unbound twin for the subroutine's slot, `==1`
// unbinds the one object in place.
//
// build: g++ -O2 -std=c++17 ct195pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct195pred
// usage: ct195pred <db.uhdm> <rowlabel>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct195pred <db.uhdm> <rowlabel>\n"); return 2; }
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL %s\n", argv[2]); return 3; }
    const char* row = argv[2];
    std::map<const BaseClass*, int> nlist;
    for (auto& kv : S.AllObjects())
        if (auto* o = (const BaseClass*)kv.first)
            if (const auto* vv = std::get<2>(o->GetByVpiType(vpiVariables)))
                for (auto* e : *vv)
                    if (e) nlist[e]++;
    int cells = 0, twin = 0, inplace = 0;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        const VectorOfvariables* vars = nullptr;
        if (X->UhdmType() == uhdmtask) vars = ((const task*)X)->Variables();
        else if (X->UhdmType() == uhdmfunction) vars = ((const function*)X)->Variables();
        else continue;
        if (!vars) continue;
        for (size_t i = 0; i < vars->size(); ++i) {
            const variables* v = (*vars)[i];
            if (!v || v->UhdmType() != uhdmref_var) continue;
            if (!((const ref_var*)v)->Actual_group()) continue;
            ++cells;
            const int n = nlist.count(v) ? nlist[v] : 0;
            (n > 1 ? twin : inplace)++;
            printf("CELL %s | %s | %s@%u:%u | listed=%d\n", row,
                   std::string(X->VpiName()).c_str(),
                   std::string(((const ref_var*)v)->VpiFullName()).c_str(),
                   v->VpiLineNo(), (unsigned)v->VpiColumnNo(), n);
        }
    }
    printf("ROW %s cells=%d twin=%d inplace=%d\n", row, cells, twin, inplace);
    return 0;
}
