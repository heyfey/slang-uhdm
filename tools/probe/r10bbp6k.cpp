// r10bbp6k: package-view identity census — AllPackages / TopPackages with
// object ids and VpiTop, plus each package's typedef (Typespecs) listing
// entries by name/id.  Answers "does this design materialize a separate ELAB
// copy of package P, and which typespec objects does each view list?".
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp6k.cpp -o /tmp/r10bbp6kq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp6kq <db.uhdm> [name-substring-filter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;

static void dumpPkg(const std::string& tag, const package* p) {
    std::cout << tag << " package '" << p->VpiName() << "' #" << p->UhdmId()
              << " top=" << (p->VpiTop() ? 1 : 0) << "\n";
    if (!p->Typespecs()) return;
    for (auto* t : *p->Typespecs()) {
        std::string nm(t->VpiName());
        if (!want.empty() && nm.find(want) == std::string::npos) continue;
        std::cout << "    " << UhdmName(t->UhdmType()) << " '" << nm << "' #"
                  << t->UhdmId() << " @" << t->VpiLineNo() << "\n";
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    if (argc > 2) want = argv[2];
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) dumpPkg("ALLPKG", p);
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) dumpPkg("TOPPKG", p);
    return 0;
}
