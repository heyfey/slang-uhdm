// r10uvm203 — ct203cen.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the
// sole judge; this tool only reports.  LHS is ALWAYS golden (Surelog), RHS is
// ALWAYS ours.
//
// THE CENSUS FACE OF § oobCtorLocalsRideTheImport203: every instance scope's
// NET listing and VARIABLE listing, keyed by the scope's DEFNAME + the VIEW,
// and by the entry's NAME + its occurrence index under that name (never by
// slot, which is blind below itself when the two sides differ in size --
// RESUME §9).  The payload is what the generated `Compare` reads for these
// kinds: the UHDM kind, VpiNetType, and the typespec's kind + name.
//
// Two extra cell kinds make the ARITY itself comparable rather than implied:
//   ARITY  <defname> <view> NETS|VARS  ->  the vector's size
//   NAMEMULT <defname> <view> NETS|VARS <name>  ->  that name's multiplicity
//
// build: g++ -O2 -std=c++17 ct203cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct203cen
// usage: ct203cen <db.uhdm>          (one TAB-separated cell per line: KEY \t PAYLOAD)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string tsFace(const ref_typespec* rt) {
    if (!rt) return "-";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "ref-noactual";
    return std::string(UhdmName(a->UhdmType())) + ":" + std::string(a->VpiName());
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct203cen <db.uhdm>\n"); return 2; }
    Serializer s;
    std::vector<vpiHandle> designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) { fprintf(stderr, "FATAL: no design in %s\n", argv[1]); return 3; }

    auto emitScope = [&](const char* view, const instance* inst) {
        std::string dn(inst->VpiDefName());
        // NETS
        {
            const std::vector<net*>* v = inst->Nets();
            printf("ARITY\t%s\t%s\tNETS\t\t\t%zu\n", dn.c_str(), view, v ? v->size() : 0);
            std::map<std::string, int> seen;
            std::map<std::string, int> mult;
            if (v)
                for (const net* n : *v) {
                    std::string nm(n->VpiName());
                    int occ = seen[nm]++;
                    mult[nm]++;
                    printf("NET\t%s\t%s\t%s\t%d\t\t%s|nt=%d|ts=%s\n", dn.c_str(), view,
                           nm.c_str(), occ,
                           std::string(UhdmName(n->UhdmType())).c_str(),
                           (int)n->VpiNetType(), tsFace(n->Typespec()).c_str());
                }
            for (auto& kv : mult)
                printf("NAMEMULT\t%s\t%s\tNETS\t%s\t\t%d\n", dn.c_str(), view,
                       kv.first.c_str(), kv.second);
        }
        // VARIABLES
        {
            const std::vector<variables*>* v = inst->Variables();
            printf("ARITY\t%s\t%s\tVARS\t\t\t%zu\n", dn.c_str(), view, v ? v->size() : 0);
            std::map<std::string, int> seen;
            std::map<std::string, int> mult;
            if (v)
                for (const variables* x : *v) {
                    std::string nm(x->VpiName());
                    int occ = seen[nm]++;
                    mult[nm]++;
                    printf("VAR\t%s\t%s\t%s\t%d\t\t%s|ts=%s\n", dn.c_str(), view,
                           nm.c_str(), occ,
                           std::string(UhdmName(x->UhdmType())).c_str(),
                           tsFace(x->Typespec()).c_str());
                }
            for (auto& kv : mult)
                printf("NAMEMULT\t%s\t%s\tVARS\t%s\t\t%d\n", dn.c_str(), view,
                       kv.first.c_str(), kv.second);
        }
    };

    for (vpiHandle dh : designs) {
        const design* d = (const design*)((const uhdm_handle*)dh)->object;
        if (d->AllModules())
            for (const module_inst* m : *d->AllModules()) emitScope("def", m);
        if (d->TopModules())
            for (const module_inst* m : *d->TopModules()) emitScope("elab", m);
        if (d->AllInterfaces())
            for (const interface_inst* m : *d->AllInterfaces()) emitScope("defif", m);
        if (d->AllPrograms())
            for (const program* m : *d->AllPrograms()) emitScope("defpg", m);
        if (d->AllPackages())
            for (const package* p : *d->AllPackages()) emitScope("defpkg", p);
        if (d->TopPackages())
            for (const package* p : *d->TopPackages()) emitScope("elabpkg", p);
    }
    return 0;
}
