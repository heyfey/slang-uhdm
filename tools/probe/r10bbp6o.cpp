// r10bbp6o: ORDERED Parameters / Param_assigns listing per view (no sorting) —
// the RB residue is a MULTIPLICITY difference, so the fix has to reproduce
// golden's interleaving, not just its counts.  Prints "<view> P <idx> <name>
// imported=<vpiImported>" and the same for Param_assigns.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp6o.cpp -o /tmp/r10bbp6oq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp6oq <db.uhdm> [view-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;

template <typename V>
static void doInst(const std::string& tag, V* v) {
    if (!v) return;
    for (auto* p : *v) {
        std::string vw(p->VpiName());
        if (p->UhdmType() == uhdmpackage)
            vw += ((const package*)p)->VpiTop() ? "[TOP]" : "[DEF]";
        std::string full = tag + "/" + vw;
        if (!want.empty() && full.find(want) == std::string::npos) continue;
        if (p->Parameters()) {
            int i = 0;
            for (auto* pa : *p->Parameters())
                std::cout << full << " P " << i++ << " " << pa->VpiName()
                          << " imported="
                          << (pa->UhdmType() == uhdmparameter
                                  ? std::string(
                                        ((const parameter*)pa)->VpiImported())
                                  : std::string("-"))
                          << "\n";
        }
        if (p->Param_assigns()) {
            int i = 0;
            for (auto* pas : *p->Param_assigns())
                std::cout << full << " A " << i++ << " "
                          << (pas->Lhs() ? pas->Lhs()->VpiName() : "?")
                          << " rhs="
                          << (pas->Rhs() ? UhdmName(pas->Rhs()->UhdmType())
                                         : "NULL")
                          << "\n";
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    if (argc > 2) want = argv[2];
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
