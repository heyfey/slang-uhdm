// r10uvm170repro/pk170.cpp — the PACKAGE-COPY LISTING.  MEASUREMENT ONLY.
//
// A corpus database holds BOTH package views in ONE file: `design::AllPackages`
// (the DEF copy, which `design::Compare` walks FIRST) and `design::TopPackages`
// (the ELABORATED copy).  Both copies of a package carry the SAME VpiName, so
// only the UhdmId tells them apart — which is what `copies170.sh` joins against
// to say WHICH COPY of `uvm_pkg` agreed with golden at a cast site.
//
// build: g++ -O2 -std=c++17 pk170.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pk170
// usage: pk170 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("FAIL\n"); return 3; }
    const design* d = nullptr;
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign) d = (const design*)kv.first;
    if (!d) return 3;
    if (d->AllPackages()) for (auto* p : *d->AllPackages())
        printf("ALL  %s #%u ts=%zu\n", std::string(p->VpiName()).c_str(), p->UhdmId(),
               p->Typespecs() ? p->Typespecs()->size() : 0);
    if (d->TopPackages()) for (auto* p : *d->TopPackages())
        printf("TOP  %s #%u ts=%zu\n", std::string(p->VpiName()).c_str(), p->UhdmId(),
               p->Typespecs() ? p->Typespecs()->size() : 0);
    return 0;
}
