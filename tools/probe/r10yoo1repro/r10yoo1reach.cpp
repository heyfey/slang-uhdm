// r10yoo1reach -- REACH SCANNER.  Given ONE database (a golden), print every
// param_assign whose Rhs constant's typespec is a SPANLESS logic_typespec, and
// every one whose typespec is a RANGED int_typespec, with the owner and view.
//
// WHY IT SCANS GOLDENS AND NOT SOURCES.  The population this law touches is
// "untyped parameter, based-literal initialiser, more than one declarator in
// the statement".  Grepping Verilog for that is guesswork -- continuations,
// macros and comments all lie.  Golden's own answer does not: a SPANLESS
// logic_typespec on a param_assign Rhs IS the law firing.  So the reach is
// counted from the golden cache, over the whole corpus, and the number is
// measured rather than estimated.
//
// Prints one line per hit; the caller aggregates.  Exit 0 even with no hits --
// "no hits" is a real answer and must not look like a crash.
//
// Build:
//   g++ -std=c++20 -O0 r10yoo1reach.cpp -o /tmp/r10yoo1reach \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static const char* TAG = "";

static bool spanless(const BaseClass* o) {
    return o && o->VpiLineNo() == 0 && o->VpiColumnNo() == 0;
}

static void scanPAs(const VectorOfparam_assign* pas, const std::string& owner,
                    const char* view) {
    if (!pas) return;
    for (auto* pa : *pas) {
        auto* r = pa->Rhs();
        if (!r || r->UhdmType() != uhdmconstant) continue;
        auto* c = (const constant*)r;
        if (!c->Typespec()) continue;
        auto* ts = c->Typespec()->Actual_typespec();
        if (!ts) continue;
        std::string lhs = "?";
        if (auto* l = pa->Lhs()) lhs = std::string(l->VpiName());
        if (ts->UhdmType() == uhdmlogic_typespec && spanless(ts)) {
            auto* rv = ((const logic_typespec*)ts)->Ranges();
            printf("HIT-SPANLESS-LOGIC %s %s %s %s nranges=%d\n", TAG, view,
                   owner.c_str(), lhs.c_str(), rv ? (int)rv->size() : 0);
        }
        else if (ts->UhdmType() == uhdmint_typespec &&
                 ((const int_typespec*)ts)->Ranges()) {
            printf("RANGED-INT %s %s %s %s\n", TAG, view, owner.c_str(),
                   lhs.c_str());
        }
    }
}

static void walkModule(const module_inst* m, const char* view) {
    scanPAs(m->Param_assigns(), std::string(m->VpiFullName()), view);
    if (m->Modules())
        for (auto* s : *m->Modules()) walkModule(s, view);
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10yoo1reach <db.uhdm> [tag]\n"; return 2; }
    TAG = argc > 2 ? argv[2] : "-";
    Serializer ser;
    std::vector<vpiHandle> hs;
    try {
        hs = ser.Restore(std::filesystem::path(argv[1]));
    } catch (...) {
        printf("LOADFAIL %s\n", TAG);
        return 0;
    }
    if (hs.empty()) { printf("LOADFAIL %s\n", TAG); return 0; }
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    if (d->AllModules()) for (auto* m : *d->AllModules()) walkModule(m, "DEF");
    if (d->TopModules()) for (auto* m : *d->TopModules()) walkModule(m, "TOP");
    if (d->AllPackages())
        for (auto* p : *d->AllPackages())
            scanPAs(p->Param_assigns(), "pkg:" + std::string(p->VpiName()),
                    "DEFPKG");
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            scanPAs(p->Param_assigns(), "pkg:" + std::string(p->VpiName()),
                    "TOPPKG");
    printf("DONE %s\n", TAG);
    return 0;
}
