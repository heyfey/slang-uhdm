// v149 VERIFIER's OWN a-priori mover predictor.  MEASUREMENT ONLY.
// Scans one golden database for GOLDEN's queue-member signature: a
// typespec_member whose Actual_typespec is a NAMELESS array_typespec with
// EXACTLY ONE range one of whose bounds is a vpiUnboundedConst.
// usage: ctv149pred <db.uhdm>   -> prints one line per hit, "N hits"
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static bool unb(const any* e) {
    return e && e->UhdmType() == uhdmconstant &&
           ((const constant*)e)->VpiConstType() == vpiUnboundedConst;
}
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    Serializer s;
    const std::vector<vpiHandle> r = s.Restore(std::string(argv[1]));
    if (r.empty()) { printf("0 hits (no restore)\n"); return 1; }
    int n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmtypespec_member) continue;
        const typespec_member* tm = (const typespec_member*)o;
        if (!tm->Typespec()) continue;
        const typespec* a = tm->Typespec()->Actual_typespec();
        if (!a || a->UhdmType() != uhdmarray_typespec) continue;
        const array_typespec* at = (const array_typespec*)a;
        if (!at->VpiName().empty()) continue;
        if (!at->Ranges() || at->Ranges()->size() != 1) continue;
        const range* rg = (*at->Ranges())[0];
        if (!unb(rg->Left_expr()) && !unb(rg->Right_expr())) continue;
        printf("HIT %s %s:%d:%d\n", std::string(tm->VpiName()).c_str(),
               std::string(tm->VpiFile()).c_str(), (int)tm->VpiLineNo(),
               (int)tm->VpiColumnNo());
        n++;
    }
    printf("%d hits\n", n);
    return 0;
}
