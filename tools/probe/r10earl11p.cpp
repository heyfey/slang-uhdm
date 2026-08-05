// r10earl11p — WHO LINKS TO THIS PACKAGE?  § pkgTypespecInstanceIsTop heads
// read "package X {top=1} vs {top=0}" with the design as the whole parent
// chain, so no dump and no census can say which object inside the module
// listing reached the package copy.  This walks ONE named AllModules entry with
// UhdmListener (which follows every UHDM link) and prints, for each visit of a
// package with the wanted name, the CALLSTACK that got there.
// Usage: r10earl11p <a.uhdm> <ModuleDefName> <PackageName>
#include <uhdm/UhdmListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;

class Finder : public UhdmListener {
public:
    int hits = 0;
    void enterPackage(const package* const o) override {
        if (std::string(o->VpiName()) != want)
            return;
        hits++;
        std::cout << "  HIT package '" << o->VpiName() << "' uid=" << o->UhdmId()
                  << " top=" << (int)o->VpiTop() << "\n";
        int d = 0;
        for (auto it = getCallstack().rbegin(); it != getCallstack().rend(); ++it) {
            const any* a = *it;
            std::cout << "     ^ " << UhdmName(a->UhdmType()) << " '" << a->VpiName()
                      << "' " << a->VpiLineNo() << ":" << a->VpiColumnNo()
                      << " uid=" << a->UhdmId() << "\n";
            if (++d > 14)
                break;
        }
    }
};

int main(int argc, char** argv) {
    if (argc < 4)
        return 1;
    std::string mod = argv[2];
    want = argv[3];
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty())
        return 2;
    auto* d = (const design*)((uhdm_handle*)h[0])->object;
    if (!d->AllModules())
        return 3;
    for (auto* m : *d->AllModules()) {
        if (std::string(m->VpiDefName()) != mod)
            continue;
        std::cout << "== " << mod << " uid=" << m->UhdmId() << " top=" << (int)m->VpiTop()
                  << "\n";
        Finder f;
        // Block the walk from climbing VpiParent into the design (which would
        // reach every package trivially and mark them visited first).
        f.getVisited().insert(d);
        f.listenAny(m);
        std::cout << "   hits=" << f.hits << "\n";
    }
    return 0;
}
