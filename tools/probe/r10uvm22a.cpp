// r10uvm22a — LISTING-POPULATION census for the view-multiplicity question.
// For every package / module / design class, print the size of its Task_funcs,
// Class_defns, Typespecs and Variables listings, plus (for class_defns) the
// owning view.  Pass 21 left "golden lists every uvm_pkg body once per
// IMPORTING-PACKAGE CLASS (6 views x 150)" as the ranked #2 unknown; this is
// the census that measures it directly instead of inferring it from the
// foreach walk.
//   r10uvm22a <file.uhdm> [nameFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string g_filt;

template <typename V>
static size_t sz(const V* v) {
    return v ? v->size() : 0;
}

static void classRow(const std::string& view, const class_defn* c) {
    std::string nm(c->VpiName());
    if (!g_filt.empty() && nm.find(g_filt) == std::string::npos) return;
    std::cout << view << "::" << nm << "  tf=" << sz(c->Task_funcs())
              << " ts=" << sz(c->Typespecs()) << " vars=" << sz(c->Variables())
              << " params=" << sz(c->Parameters()) << "\n";
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    g_filt = argc > 2 ? argv[2] : "";
    auto pkgs = [&](const VectorOfpackage* v, const char* tag) {
        if (!v) return;
        for (auto* p : *v) {
            std::string view = std::string(tag) + "[" + std::string(p->VpiName()) + "]";
            std::cout << view << "  tf=" << sz(p->Task_funcs())
                      << " cds=" << sz(p->Class_defns())
                      << " ts=" << sz(p->Typespecs())
                      << " vars=" << sz(p->Variables()) << "\n";
            if (auto* cds = p->Class_defns())
                for (auto* c : *cds) classRow(view, c);
        }
    };
    pkgs(d->AllPackages(), "DEFPKG");
    pkgs(d->TopPackages(), "ELABPKG");
    auto mods = [&](const VectorOfmodule_inst* v, const char* tag) {
        if (!v) return;
        for (auto* m : *v) {
            std::string view = std::string(tag) + "[" + std::string(m->VpiName()) + "]";
            std::cout << view << "  tf=" << sz(m->Task_funcs())
                      << " cds=" << sz(m->Class_defns())
                      << " ts=" << sz(m->Typespecs())
                      << " vars=" << sz(m->Variables()) << "\n";
            if (auto* cds = m->Class_defns())
                for (auto* c : *cds) classRow(view, c);
        }
    };
    mods(d->AllModules(), "DEFMOD");
    mods(d->TopModules(), "ELABMOD");
    if (auto* cs = d->AllClasses())
        for (auto* c : *cs) classRow("DESIGNCLS", c);
    return 0;
}
