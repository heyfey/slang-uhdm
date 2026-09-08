// r10uvm206 — ct206pred2.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the
// sole judge; this tool only reports.
//
// THE PREDICTOR FOR THE SECOND EDIT (the INDEX half of § 203's
// `stampTsInstance`).  That edit can only move a database that holds an
// `array_var` whose parent is a `module_inst` and whose `array_typespec` has an
// `Index_typespec` carrying a NON-NULL `vpiInstance` — the only shape the line
// writes.  Prints the owning module and the array name, so the prediction is
// BY NAME and not by count.
//
// build: g++ -O2 -std=c++17 ct206pred2.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct206pred2
// usage: ct206pred2 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct206pred2 <db.uhdm>\n"); return 2; }
    Serializer s;
    auto designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) { printf("NODESIGN\n"); return 0; }
    std::vector<std::string> hits;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmarray_var) continue;
        const array_var* av = (const array_var*)o;
        const BaseClass* p = (const BaseClass*)av->VpiParent();
        if (!p || p->UhdmType() != uhdmmodule_inst) continue;
        const ref_typespec* rt = av->Typespec();
        if (!rt || !rt->Actual_typespec()) continue;
        const typespec* at = rt->Actual_typespec();
        if (at->UhdmType() != uhdmarray_typespec) continue;
        const ref_typespec* irt = ((const array_typespec*)at)->Index_typespec();
        if (!irt || !irt->Actual_typespec()) continue;
        if (!irt->Actual_typespec()->Instance()) continue;
        hits.push_back(std::string(p->VpiName()) + "." + std::string(av->VpiName()) +
                       ":" + std::string(UhdmName(irt->Actual_typespec()->UhdmType())));
    }
    if (hits.empty()) { printf("CLEAN\n"); return 0; }
    printf("MAYBE n=%zu", hits.size());
    for (size_t i = 0; i < hits.size() && i < 40; i++) printf(" %s", hits[i].c_str());
    printf("\n");
    return 0;
}
