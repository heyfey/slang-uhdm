// r10uvm26v — the vpiAutomatic / lifetime census, PACKAGE views (r10uvm25v)
// PLUS the module views, because § packageVarAutomaticIsDataDeclaration26 is a
// PARSE-rule law (net_declaration vs data_declaration) whose module arm decides
// whether the import-hoist clones may share it.
//   r10uvm26v <file.uhdm> [nameFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string tn(const BaseClass* o) { return std::string(UhdmName(o->UhdmType())); }

template <typename V>
static void dump(const V* v, const char* tag, const std::string& filt) {
    if (!v) return;
    for (auto* p : *v) {
        std::string nm(p->VpiName());
        if (!filt.empty() && nm.find(filt) == std::string::npos) continue;
        if (!p->Variables()) continue;
        size_t i = 0;
        for (auto* var : *p->Variables()) {
            std::cout << tag << "[" << nm << "] var[" << i++ << "] " << tn(var)
                      << " '" << var->VpiName() << "'"
                      << " auto=" << (int)var->VpiAutomatic()
                      << " const=" << (int)var->VpiConstantVariable()
                      << " vis=" << var->VpiVisibility()
                      << " expr=" << (var->Expr() ? tn(var->Expr()) : "-")
                      << "\n";
        }
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    std::string filt = argc > 2 ? argv[2] : "";
    dump(d->AllPackages(), "DEFPKG", filt);
    dump(d->TopPackages(), "ELABPKG", filt);
    dump(d->AllModules(), "DEFMOD", filt);
    dump(d->TopModules(), "ELABMOD", filt);
    return 0;
}
