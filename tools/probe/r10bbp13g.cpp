// r10bbp13g: does the TOP (elaborated) module listing SHARE its Ports /
// Cont_assigns objects with the DEF listing, or hold its own copies?  Prints
// the UhdmIds side by side for AllModules[0] and TopModules[0] so a golden-vs-
// ours comparison answers "is the elab body a fresh copy" before any fold rule
// is theorised.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp13g.cpp -o /tmp/r10bbp13gq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp13gq <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    const module_inst* a = (*d->AllModules())[0];
    const module_inst* b = (*d->TopModules())[0];
    std::cout << "AllMod id" << a->UhdmId() << "  TopMod id" << b->UhdmId()
              << "\n";
    auto rep = [&](const char* tag, auto* va, auto* vb) {
        size_t na = va ? va->size() : 0, nb = vb ? vb->size() : 0;
        std::cout << tag << " n=" << na << "/" << nb << "  ";
        size_t n = na < nb ? na : nb, same = 0;
        for (size_t i = 0; i < n; i++)
            if ((*va)[i] == (const BaseClass*)(*vb)[i]) same++;
        std::cout << "shared=" << same << "\n";
        for (size_t i = 0; i < n && i < 5; i++)
            std::cout << "   [" << i << "] def id" << (*va)[i]->UhdmId()
                      << " top id" << (*vb)[i]->UhdmId() << "\n";
    };
    rep("Ports", a->Ports(), b->Ports());
    rep("Cont_assigns", a->Cont_assigns(), b->Cont_assigns());
    rep("Nets", a->Nets(), b->Nets());
    rep("Process", a->Process(), b->Process());
    return 0;
}
