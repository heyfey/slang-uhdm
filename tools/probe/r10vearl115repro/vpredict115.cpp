// r10vearl115 -- THE VERIFIER'S OWN MOVER PREDICTION, from PRISTINE databases.
// MEASUREMENT ONLY.
//
// Deliberately a SUPERSET of r10earl115's `predict115`: it applies NO fence at
// all, only the reachability the consumer walk has (TOP modules, gen scopes,
// a vpiAssignmentPatternOp Rhs, a `hier_path` operand with a BOUND element
// after index 0).  Every cell the patch can possibly clear is in here, so a
// byte mover outside this row set is a mover the law does not explain.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <functional>
#include <string>
using namespace UHDM;
static const any* actOf(const BaseClass* e) {
    if (!e) return nullptr;
    switch (e->UhdmType()) {
        case uhdmref_obj: return ((const ref_obj*)e)->Actual_group();
        case uhdmref_var: return ((const ref_var*)e)->Actual_group();
        case uhdmbit_select: return ((const bit_select*)e)->Actual_group();
        case uhdmvar_select: return ((const var_select*)e)->Actual_group();
        default: return nullptr;
    }
}
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: vpredict115 <ours.uhdm> <tag>\n"); return 2; }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { printf("VPRC 3 %s\n", argv[2]); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;
    long cells = 0, paths = 0;
    std::function<void(const any*, bool)> walk = [&](const any* sc, bool inGen) {
        if (!sc) return;
        const VectorOfcont_assign* cas = nullptr;
        const VectorOfgen_scope_array* gsas = nullptr;
        const VectorOfmodule_inst* mods = nullptr;
        const VectorOfinterface_inst* ifs = nullptr;
        bool isGen = false;
        if (auto* mi = any_cast<const module_inst*>(sc)) {
            cas = mi->Cont_assigns(); gsas = mi->Gen_scope_arrays();
            mods = mi->Modules(); ifs = mi->Interfaces();
        } else if (auto* ii = any_cast<const interface_inst*>(sc)) {
            cas = ii->Cont_assigns(); gsas = ii->Gen_scope_arrays();
            ifs = ii->Interfaces();
        } else if (auto* gs = any_cast<const gen_scope*>(sc)) {
            cas = gs->Cont_assigns(); gsas = gs->Gen_scope_arrays();
            mods = gs->Modules(); ifs = gs->Interfaces(); isGen = true;
        } else if (auto* ga = any_cast<const gen_scope_array*>(sc)) {
            if (ga->Gen_scopes())
                for (auto* g : *ga->Gen_scopes()) walk(g, inGen);
            return;
        }
        if (isGen && cas)
            for (auto* ca : *cas) {
                auto* r = ca->Rhs();
                if (!r || r->UhdmType() != uhdmoperation) continue;
                auto* op = (const operation*)r;
                if (op->VpiOpType() != vpiAssignmentPatternOp || !op->Operands()) continue;
                for (auto* o : *op->Operands()) {
                    if (!o || o->UhdmType() != uhdmhier_path) continue;
                    auto* es = ((const hier_path*)o)->Path_elems();
                    if (!es) continue;
                    bool any_bound = false;
                    for (size_t i = 1; i < es->size(); i++)
                        if (actOf((*es)[i])) { cells++; any_bound = true; }
                    if (any_bound) paths++;
                }
            }
        if (gsas) for (auto* g : *gsas) walk(g, inGen);
        if (mods) for (auto* m : *mods) walk(m, inGen);
        if (ifs) for (auto* i2 : *ifs) walk(i2, inGen);
    };
    if (d->TopModules())
        for (auto* t : *d->TopModules()) walk(t, false);
    printf("VPREDICT\t%s\tbound_nonfirst_cells=%ld\tpaths=%ld\n", argv[2], cells, paths);
    printf("VPRC 0 %s\n", argv[2]);
    return 0;
}
