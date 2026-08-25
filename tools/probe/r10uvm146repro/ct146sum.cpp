// r10uvm146 — design-level parameter/param_assign LISTING SUMMARY for one DB.
// MEASUREMENT ONLY.  usage: ct146sum <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    Serializer s;
    const std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) { printf("RESTORE-FAIL\n"); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;
    size_t np = d->Parameters() ? d->Parameters()->size() : 0;
    size_t na = d->Param_assigns() ? d->Param_assigns()->size() : 0;
    size_t imp = 0;
    if (d->Parameters())
        for (auto* p : *d->Parameters())
            if (p->UhdmType() == uhdmparameter &&
                !((const parameter*)p)->VpiImported().empty()) imp++;
    printf("PARAM=%zu PASSIGN=%zu IMPORTED=%zu\n", np, na, imp);
    return 0;
}
