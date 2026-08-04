// r10earl4pa: every param_assign for a NAMED parameter, in every listing, on
// both sides.  tab2.py/pa3.py project a DUMP, which cannot tell two listings
// of the same package apart; this walks the design vectors directly and
// labels each row with the instance it was found in (name + vpiTop + uid).
// Usage: r10earl4pa <a.uhdm> <b.uhdm> <ParamName>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;

static void row(const std::string& where, const param_assign* pa) {
    const any* l = pa->Lhs();
    // want == "*" lists EVERY row of the listing, in vector order — the way to
    // see a positional SafeCompare pairing.
    if (want != "*" && (!l || std::string(l->VpiName()) != want)) return;
    if (want == "*")
        std::cout << "  [" << (l ? l->VpiName() : "<null lhs>") << "]";
    const any* r = pa->Rhs();
    std::cout << "  " << where << "  ";
    if (!r) { std::cout << "<null rhs>\n"; return; }
    std::cout << UhdmName(r->UhdmType());
    if (r->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)r;
        std::cout << " dec='" << c->VpiDecompile() << "' sz=" << c->VpiSize()
                  << " val='" << c->VpiValue() << "' ct=" << c->VpiConstType()
                  << " ts=" << (c->Typespec() ? "yes" : "no");
    }
    std::cout << "  @" << r->VpiLineNo() << ":" << r->VpiColumnNo() << "\n";
}

static void scanScope(const std::string& where, const scope* sc) {
    if (!sc) return;
    if (sc->Param_assigns())
        for (auto* pa : *sc->Param_assigns()) row(where, pa);
}

static void walkMod(const std::string& pfx, const module_inst* m) {
    std::string w = pfx + "/" + std::string(m->VpiDefName()) + "(" +
                    std::string(m->VpiName()) + ",top=" +
                    std::to_string((int)m->VpiTop()) + ",#" +
                    std::to_string(m->UhdmId()) + ")";
    scanScope(w, m);
    if (m->Modules())
        for (auto* c : *m->Modules()) walkMod(w, c);
}

static void one(const char* label, const char* path) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(path));
    if (h.empty()) return;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    std::cout << "==== " << label << "\n";
    if (d->AllPackages())
        for (auto* p : *d->AllPackages())
            scanScope("ALLPKG/" + std::string(p->VpiName()) + "#" +
                          std::to_string(p->UhdmId()),
                      p);
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            scanScope("TOPPKG/" + std::string(p->VpiName()) + "#" +
                          std::to_string(p->UhdmId()),
                      p);
    if (d->AllModules())
        for (auto* m : *d->AllModules()) walkMod("ALLMOD", m);
    if (d->TopModules())
        for (auto* m : *d->TopModules()) walkMod("TOPMOD", m);
}

int main(int argc, char** argv) {
    if (argc < 4) return 1;
    want = argv[3];
    one("A(golden)", argv[1]);
    one("B(ours)", argv[2]);
    return 0;
}
