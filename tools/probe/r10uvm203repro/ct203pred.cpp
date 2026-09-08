// r10uvm203 — ct203pred.cpp — THE PREDICTOR.  MEASUREMENT ONLY.
//
// Answers, from ONE database and nothing else, "does § oobCtorLocalsRideTheImport203
// reach this design?"  Run over the PRISTINE sweep it names the byte movers
// BEFORE the patched binary exists, which is the gate's own requirement.
//
// Three predicates, one per way the law can move a byte:
//
//  P1 PARTIAL-MATERIALIZATION — a module's def-view net listing carries SOME of
//     a package's `Variables()` names and MISSES at least one.  That is exactly
//     the shape a members()-only hoist produces: the package listing's hoisted
//     out-of-body constructor locals and its dynamic containers are absent while
//     its own scalar declarations are present.
//
//  P2 SHADOWED-IMPLICIT — a module lists a NETTYPE-1, TYPESPEC-LESS net (the
//     implicit-wire mint) under a name the SAME module already lists another net
//     for.  The law makes the mint a last resort, so such a pair disappears.
//
//  P3 UNNAMED-MATERIALIZED-CLASS-TS — a def-view net whose name is a package
//     `Variables()` name and whose class_typespec has NO VpiName.  Those gain
//     the class name at the module copy.
//
// Prints one line per firing predicate plus a FIRES=<n> summary, so a driver can
// grep the databases that move.
//
// build: g++ -O2 -std=c++17 ct203pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct203pred
// usage: ct203pred <db.uhdm> [<tag>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct203pred <db.uhdm> [tag]\n"); return 2; }
    std::string tag = argc > 2 ? argv[2] : argv[1];
    Serializer s;
    std::vector<vpiHandle> designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) { printf("PRED %s NODB FIRES=0\n", tag.c_str()); return 0; }
    int fires = 0;
    for (vpiHandle dh : designs) {
        const design* d = (const design*)((const uhdm_handle*)dh)->object;
        // package name -> its Variables() listing names (a SET; the listing may
        // repeat a name and the predicate only asks about presence).
        std::vector<std::pair<std::string, std::set<std::string>>> pkgs;
        std::set<std::string> anyPkgVar;
        if (d->AllPackages())
            for (const package* p : *d->AllPackages()) {
                std::set<std::string> ns;
                if (p->Variables())
                    for (const variables* v : *p->Variables()) {
                        ns.insert(std::string(v->VpiName()));
                        anyPkgVar.insert(std::string(v->VpiName()));
                    }
                if (!ns.empty()) pkgs.push_back({std::string(p->VpiName()), ns});
            }
        if (!d->AllModules()) continue;
        for (const module_inst* m : *d->AllModules()) {
            std::map<std::string, int> nm;
            std::vector<const net*> nets;
            if (m->Nets())
                for (const net* n : *m->Nets()) {
                    nm[std::string(n->VpiName())]++;
                    nets.push_back(n);
                }
            if (nm.empty()) continue;
            std::string dn(m->VpiDefName());
            for (auto& pk : pkgs) {
                int have = 0, miss = 0;
                std::string missName;
                for (auto& n : pk.second) {
                    if (nm.count(n)) have++;
                    else { miss++; if (missName.empty()) missName = n; }
                }
                if (have > 0 && miss > 0) {
                    printf("PRED %s P1 mod=%s pkg=%s have=%d miss=%d first=%s\n",
                           tag.c_str(), dn.c_str(), pk.first.c_str(), have, miss,
                           missName.c_str());
                    fires++;
                }
            }
            for (const net* n : nets) {
                std::string nn(n->VpiName());
                if (n->VpiNetType() == 1 && !n->Typespec() && nm[nn] > 1) {
                    printf("PRED %s P2 mod=%s name=%s mult=%d\n", tag.c_str(),
                           dn.c_str(), nn.c_str(), nm[nn]);
                    fires++;
                }
                if (anyPkgVar.count(nn))
                    if (const ref_typespec* rt = n->Typespec())
                        if (const typespec* a = rt->Actual_typespec())
                            if (a->UhdmType() == uhdmclass_typespec &&
                                a->VpiName().empty()) {
                                printf("PRED %s P3 mod=%s name=%s\n", tag.c_str(),
                                       dn.c_str(), nn.c_str());
                                fires++;
                            }
            }
        }
    }
    printf("PRED %s FIRES=%d\n", tag.c_str(), fires);
    return 0;
}
