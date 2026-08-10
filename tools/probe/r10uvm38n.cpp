// r10uvm38n — the TOP MODULE's Nets() / Variables() listings in order, for
// both views.  § thisImplicitNet38 mints a net into a module listing and
// uhdm-cmp compares those vectors ELEMENT-WISE, so the insertion POSITION is
// the part of the law a binding census cannot see.
//   r10uvm38n <file.uhdm>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void dumpMod(const module_inst* m, const char* tag) {
    std::cout << tag << " module '" << m->VpiName() << "' def='"
              << m->VpiDefName() << "'\n";
    if (m->Nets()) {
        std::cout << "  Nets(" << m->Nets()->size() << "):";
        for (auto* n : *m->Nets())
            std::cout << " " << UhdmName(n->UhdmType()) << ":" << n->VpiName();
        std::cout << "\n";
    }
    if (m->Variables()) {
        std::cout << "  Vars(" << m->Variables()->size() << "):";
        for (auto* v : *m->Variables())
            std::cout << " " << UhdmName(v->UhdmType()) << ":" << v->VpiName();
        std::cout << "\n";
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    if (d->TopModules())
        for (auto* m : *d->TopModules()) dumpMod(m, "TOP");
    if (d->AllModules())
        for (auto* m : *d->AllModules()) dumpMod(m, "DEF");
    return 0;
}
