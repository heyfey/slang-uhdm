// Side-by-side listing of a module's Param_assigns / Parameters vectors in
// both the DEF (AllModules) and TOP (TopModules) views: LOCAL/PARAM kind,
// name, span, arena address and the rhs kind+span. A `param_assign` element
// mismatch that cmptool reports as "constant@a vs constant@b" is almost
// always an ORDER or COUNT difference, which only the full vectors show; the
// addresses separate a SHARED def object from a fresh top-view twin, and the
// two vectors' orders differ independently (Surelog name-sorts materialized
// imported params in Parameters but not in Param_assigns).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void dumpMod(const module_inst* m, const char* tag) {
    std::cout << tag << " " << m->VpiName() << " (def=" << m->VpiDefName()
              << ")\n";
    if (auto* ps = m->Param_assigns()) {
        std::cout << "  Param_assigns " << ps->size() << "\n";
        for (auto* pa : *ps) {
            std::string nm;
            bool lp = false;
            if (auto* l = pa->Lhs()) {
                nm = l->VpiName();
                if (l->UhdmType() == uhdmparameter)
                    lp = ((const parameter*)l)->VpiLocalParam();
            }
            std::cout << "    " << (lp ? "LOCAL " : "PARAM ") << nm << " @"
                      << pa->VpiLineNo() << ":" << pa->VpiColumnNo()
                      << " pa=" << (const void*)pa
                      << " lhs=" << (const void*)pa->Lhs() << " rhs=";
            if (auto* r = pa->Rhs())
                std::cout << UhdmName(r->UhdmType()) << "@" << r->VpiLineNo()
                          << ":" << r->VpiColumnNo();
            std::cout << "\n";
        }
    }
    if (auto* pp = m->Parameters()) {
        std::cout << "  Parameters " << pp->size() << "\n";
        for (auto* p : *pp)
            std::cout << "    " << UhdmName(p->UhdmType()) << " " << p->VpiName()
                      << " @" << p->VpiLineNo() << ":" << p->VpiColumnNo()
                      << "\n";
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: w4parms <uhdm> [mod-name]\n"; return 2; }
    std::string want = argc > 2 ? argv[2] : "";
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (auto* v = d->AllModules())
        for (auto* m : *v)
            if (want.empty() || std::string(m->VpiDefName()).find(want) !=
                                    std::string::npos)
                dumpMod(m, "DEF");
    if (auto* v = d->TopModules())
        for (auto* m : *v)
            if (want.empty() || std::string(m->VpiDefName()).find(want) !=
                                    std::string::npos)
                dumpMod(m, "TOP");
    return 0;
}
