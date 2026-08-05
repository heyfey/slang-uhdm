// r10earl13p — WHO LINKS TO THIS PACKAGE, in EITHER module vector.
// r10earl11p only walks AllModules; the § pkgTypespecInstanceIsTop heads also
// appear in TopModules (vq.sv's witness head is one), and the two vectors hold
// DIFFERENT objects, so the def-listing answer does not transfer.  Same
// callstack print, plus a `--first` mode that stops at the first hit whose
// package top-flag differs from the wanted one.
// Build: see tools/probe/r10earl_repro/README.
// Usage: r10earl13p <a.uhdm> <all|top> <ModuleDefName> <PackageName> [wantTop]
#include <uhdm/UhdmListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;
static int wantTop = -1;

class Finder : public UhdmListener {
public:
    int hits = 0;
    int shown = 0;
    void enterPackage(const package* const o) override {
        if (std::string(o->VpiName()) != want)
            return;
        hits++;
        if (wantTop >= 0 && (int)o->VpiTop() != wantTop)
            return;
        if (shown++ > 6)
            return;
        std::cout << "  HIT package '" << o->VpiName() << "' uid=" << o->UhdmId()
                  << " top=" << (int)o->VpiTop() << "\n";
        int d = 0;
        for (auto it = getCallstack().rbegin(); it != getCallstack().rend(); ++it) {
            const any* a = *it;
            std::cout << "     ^ " << UhdmName(a->UhdmType()) << " '" << a->VpiName()
                      << "' " << a->VpiLineNo() << ":" << a->VpiColumnNo()
                      << " uid=" << a->UhdmId() << "\n";
            if (++d > 12)
                break;
        }
    }
};

int main(int argc, char** argv) {
    if (argc < 5)
        return 1;
    std::string vec = argv[2];
    std::string mod = argv[3];
    want = argv[4];
    if (argc > 5)
        wantTop = atoi(argv[5]);
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty())
        return 2;
    auto* d = (const design*)((uhdm_handle*)h[0])->object;
    const VectorOfmodule_inst* v =
        vec == "top" ? d->TopModules() : d->AllModules();
    if (!v)
        return 3;
    for (auto* m : *v) {
        std::string dn(m->VpiDefName()), nm(m->VpiName());
        if (dn != mod && nm != mod)
            continue;
        std::cout << "== " << mod << " uid=" << m->UhdmId()
                  << " top=" << (int)m->VpiTop() << "\n";
        Finder f;
        f.getVisited().insert(d);
        f.listenAny(m);
        std::cout << "   hits=" << f.hits << "\n";
    }
    return 0;
}
