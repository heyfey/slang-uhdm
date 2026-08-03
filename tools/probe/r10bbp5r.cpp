// r10bbp5r: per-view PACKED-ARRAY param dim census — for every parameter
// whose typespec is a packed_array_typespec, print the kind of each range
// bound (constant = folded, operation = unfolded) per listing, with the
// DEF/TOP discriminator on the listing package.  Decides which listings fold
// a symbolic packed dim (`bp_proc_param_s [max_cfgs-1:0] all_cfgs_gp`).
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp5r.cpp -o /tmp/r10bbp5rq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

template <typename V>
static void doInst(const std::string& tag, V* v) {
    if (!v) return;
    for (auto* p : *v) {
        std::string vw(p->VpiName());
        if (p->UhdmType() == uhdmpackage)
            vw += ((const package*)p)->VpiTop() ? "[TOP]" : "[DEF]";
        if (!p->Parameters()) continue;
        for (auto* pa : *p->Parameters()) {
            if (pa->UhdmType() != uhdmparameter) continue;
            auto* rt = ((const parameter*)pa)->Typespec();
            if (!rt || !rt->Actual_typespec()) continue;
            auto* a = rt->Actual_typespec();
            if (a->UhdmType() != uhdmpacked_array_typespec) continue;
            auto* rs = ((const packed_array_typespec*)a)->Ranges();
            std::cout << tag << "/" << vw << " " << pa->VpiName() << " dims=";
            if (!rs) { std::cout << "-\n"; continue; }
            for (auto* r : *rs)
                std::cout << "["
                          << (r->Left_expr() ? UhdmName(r->Left_expr()->UhdmType())
                                             : "-")
                          << ":"
                          << (r->Right_expr()
                                  ? UhdmName(r->Right_expr()->UhdmType())
                                  : "-")
                          << "]";
            std::cout << "\n";
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    doInst("ALLPKG", d->AllPackages());
    doInst("TOPPKG", d->TopPackages());
    doInst("ALLMOD", d->AllModules());
    doInst("TOPMOD", d->TopModules());
    return 0;
}
