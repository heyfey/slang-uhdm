// r10rgg4pts: def-view parameter TYPESPEC census — one row per (module def,
// parameter): the typespec's type, NAME and span.  Ranks the "int_typespec
// named after the parameter at the param-name location vs unnamed at the type
// keyword" class by showing which parameters take which form in the golden.
//   r10rgg4pts <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string tsOf(const any* p) {
    const ref_typespec* rt = nullptr;
    if (p->UhdmType() == uhdmparameter) rt = ((const parameter*)p)->Typespec();
    if (!rt) return "<no-ref>";
    const typespec* t = rt->Actual_typespec();
    if (!t) return "<no-act>";
    return std::string(UhdmName(t->UhdmType())) + "(" + std::string(t->VpiName()) +
           ")@" + std::to_string(t->VpiLineNo()) + ":" +
           std::to_string(t->VpiColumnNo()) + "-" +
           std::to_string(t->VpiEndLineNo()) + ":" +
           std::to_string(t->VpiEndColumnNo());
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::vector<std::string> rows;
    auto doMod = [&](const module_inst* m) {
        if (!m->Parameters()) return;
        for (auto* p : *m->Parameters())
            rows.push_back(std::string(m->VpiDefName()) + " | " +
                           std::string(p->VpiName()) + " | " +
                           std::string(UhdmName(p->UhdmType())) + " | " +
                           tsOf(p));
    };
    if (auto* A = d->AllModules())
        for (auto* m : *A) doMod(m);
    std::sort(rows.begin(), rows.end());
    rows.erase(std::unique(rows.begin(), rows.end()), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
