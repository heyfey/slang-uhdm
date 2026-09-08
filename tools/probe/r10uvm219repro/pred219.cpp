// r10uvm219 — pred219.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the
// sole judge; this tool only reports.
//
// THE A-PRIORI MOVER PREDICTOR, read off OUR OWN PRISTINE databases alone —
// no golden, no patched binary.  It is an UPPER BOUND by construction: a
// database this tool calls CLEAN cannot move under
// § hoistedThisRidesTheForwardedBlock219, because the law only ever changes
// the POSITION of the one `logic_net` named `this` that
// § thisImplicitNetBoth38 mints, and a database that holds no such net has
// nothing to move.
//
// For every `module_inst` in `AllModules` (the DEF-view shells — the only
// listing § 38 writes into) it prints:
//   THIS  <db> <defname> idx=<i> size=<n> after=<how many nets follow it>
//   afterNames=<the names that follow, comma separated, capped>
// and, when the module holds no such net,
//   CLEAN <db>
//
// build: g++ -O2 -std=c++17 pred219.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred219
// usage: pred219 <db.uhdm> [<db.uhdm> ...]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static int scanOne(const char* path) {
    Serializer s;
    std::vector<vpiHandle> designs;
    designs = s.Restore(std::string(path));
    if (designs.empty()) {
        printf("NODB %s\n", path);
        return 0;
    }
    const design* d = (const design*)((uhdm_handle*)designs[0])->object;
    bool any = false;
    if (d->AllModules())
        for (auto* m : *d->AllModules()) {
            if (!m || !m->Nets())
                continue;
            const auto& v = *m->Nets();
            for (size_t i = 0; i < v.size(); i++) {
                const net* nt = v[i];
                if (!nt || nt->UhdmType() != uhdmlogic_net) continue;
                if (nt->VpiName() != "this") continue;
                if (nt->VpiNetType() != 1) continue;
                if (nt->Typespec()) continue;
                any = true;
                std::string after;
                for (size_t j = i + 1; j < v.size() && after.size() < 400; j++) {
                    if (!after.empty()) after += ",";
                    after += std::string(v[j]->VpiName());
                }
                printf("THIS %s %s idx=%zu size=%zu after=%zu afterNames=%s\n",
                       path, std::string(m->VpiDefName()).c_str(), i, v.size(),
                       v.size() - i - 1, after.c_str());
            }
        }
    if (!any) printf("CLEAN %s\n", path);
    return 0;
}

int main(int argc, char** argv) {
    for (int i = 1; i < argc; i++) scanOne(argv[i]);
    fflush(stdout);
    return 0;
}
