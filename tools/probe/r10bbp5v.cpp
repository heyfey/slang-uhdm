// r10bbp5v: which package LISTING is VpiTop — AllPackages or TopPackages.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp5v.cpp -o /tmp/r10bbp5vq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages())
            std::cout << "ALLPKG " << p->VpiName() << " top=" << p->VpiTop()
                      << " #" << p->UhdmId()
                      << " nparam="
                      << (p->Parameters() ? p->Parameters()->size() : 0)
                      << "\n";
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            std::cout << "TOPPKG " << p->VpiName() << " top=" << p->VpiTop()
                      << " #" << p->UhdmId()
                      << " nparam="
                      << (p->Parameters() ? p->Parameters()->size() : 0)
                      << "\n";
    return 0;
}
