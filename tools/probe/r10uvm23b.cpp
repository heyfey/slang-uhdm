// r10uvm23b — per-class LISTING DUMP for § classInheritsContainerImports.
// Prints, for every class_defn reachable from the design (package def/elab
// views, module def/elab views, design AllClasses), the ORDERED contents of
// its Task_funcs / Typespecs / Variables / Parameters / Param_assigns
// listings as "<vpiType-name> <VpiName>" — the fields uhdm-cmp actually
// reads — so golden and ours can be diffed line for line.
//   r10uvm23b <file.uhdm> [classNameFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string g_filt;

static std::string tn(const BaseClass* o) { return std::string(UhdmName(o->UhdmType())); }

template <typename V>
static void listing(const std::string& view, const char* tag, const V* v) {
    if (!v) return;
    size_t i = 0;
    for (auto* o : *v) {
        std::cout << view << " " << tag << "[" << i++ << "] " << std::flush;
        if (!o) { std::cout << "<null>\n"; continue; }
        std::cout << tn(o) << " '" << o->VpiName() << "'";
        if (o->UhdmType() == uhdmparam_assign) {
            auto* pa = (const param_assign*)o;
            std::cout << " lhs=" << (pa->Lhs() ? tn(pa->Lhs()) : "-") << " '"
                      << (pa->Lhs() ? pa->Lhs()->VpiName() : "") << "'";
        }
        std::cout << "\n";
    }
}

static void classRow(const std::string& view, const class_defn* c) {
    std::string nm(c->VpiName());
    if (!g_filt.empty() && nm.find(g_filt) == std::string::npos) return;
    std::string v = view + "::" + nm;
    listing(v, "tf", c->Task_funcs());
    listing(v, "ts", c->Typespecs());
    listing(v, "var", c->Variables());
    listing(v, "par", c->Parameters());
    listing(v, "pas", c->Param_assigns());
    for (auto* n : std::initializer_list<const class_defn*>{}) (void)n;
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
