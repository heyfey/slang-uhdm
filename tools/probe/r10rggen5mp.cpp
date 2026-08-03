// r10rggen5mp: census of PORT-VIEW interface_inst shape, one row per elab
// interface_inst: fullname, #modports, how many carry a vpiInterface back-ref,
// #parameters, #param_assigns, and whether the owning instance sits inside a
// gen_scope.  Run on golden and on ours and diff the rows.
//   r10rggen5mp <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <functional>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::function<void(const module_inst*, bool)> doMod;
    std::function<void(const gen_scope_array*, bool)> doGsa;
    auto row = [&](const interface_inst* ii, bool inGen) {
        size_t nmp = ii->Modports() ? ii->Modports()->size() : 0;
        size_t nback = 0;
        if (ii->Modports())
            for (auto* m : *ii->Modports())
                if (m->Interface_inst()) nback++;
        std::cout << ii->VpiFullName() << " mp=" << nmp << " back=" << nback
                  << " par=" << (ii->Parameters() ? ii->Parameters()->size() : 0)
                  << " pa="
                  << (ii->Param_assigns() ? ii->Param_assigns()->size() : 0)
                  << " gen=" << (inGen ? 1 : 0) << "\n";
    };
    auto doScope = [&](const gen_scope* g) {
        if (g->Interfaces())
            for (auto* ii : *g->Interfaces()) row(ii, true);
        if (g->Modules())
            for (auto* m : *g->Modules()) doMod(m, true);
        if (g->Gen_scope_arrays())
            for (auto* a : *g->Gen_scope_arrays()) doGsa(a, true);
    };
    doGsa = [&](const gen_scope_array* a, bool) {
        if (a->Gen_scopes())
            for (auto* g : *a->Gen_scopes()) doScope(g);
    };
    doMod = [&](const module_inst* m, bool inGen) {
        if (m->Interfaces())
            for (auto* ii : *m->Interfaces()) row(ii, inGen);
        if (m->Modules())
            for (auto* c : *m->Modules()) doMod(c, inGen);
        if (m->Gen_scope_arrays())
            for (auto* a : *m->Gen_scope_arrays()) doGsa(a, inGen);
    };
    if (d->TopModules())
        for (auto* m : *d->TopModules()) doMod(m, false);
    return 0;
}
