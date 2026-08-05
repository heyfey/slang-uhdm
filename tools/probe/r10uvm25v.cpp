// r10uvm25v — the vpiAutomatic census on PACKAGE-scope variables (both views),
// the distinguisher uhdm-cmp stops on first for the UVM-4
// (`variables::Compare` compares VpiAutomatic, generated/src/variables.cpp:256).
//   r10uvm25v <file.uhdm> [pkgFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string tn(const BaseClass* o) { return std::string(UhdmName(o->UhdmType())); }

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    std::string filt = argc > 2 ? argv[2] : "";
    auto go = [&](const VectorOfpackage* v, const char* tag) {
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
    };
    go(d->AllPackages(), "DEFPKG");
    go(d->TopPackages(), "ELABPKG");
    return 0;
}
