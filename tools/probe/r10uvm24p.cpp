// r10uvm24p — PACKAGE-level Typespecs listing dump (def + elab views), plus
// class_typespec targets, so golden's DataTypeMap order can be read directly.
//   r10uvm24p <file.uhdm> [pkgNameFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string tn(const BaseClass* o) { return std::string(UhdmName(o->UhdmType())); }

static void row(const std::string& view, const VectorOftypespec* v) {
    if (!v) return;
    size_t i = 0;
    for (auto* t : *v) {
        std::cout << view << " ts[" << i++ << "] ";
        if (!t) { std::cout << "<null>\n"; continue; }
        std::cout << tn(t) << " '" << t->VpiName() << "'";
        if (t->UhdmType() == uhdmclass_typespec) {
            auto* ct = (const class_typespec*)t;
            if (auto* cd = ct->Class_defn())
                std::cout << " ->" << cd->VpiName();
        }
        if (auto* p = t->VpiParent())
            std::cout << " par=" << tn(p) << ":" << p->VpiName();
        std::cout << "\n";
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    std::string filt = argc > 2 ? argv[2] : "";
    auto pkgs = [&](const VectorOfpackage* v, const char* tag) {
        if (!v) return;
        for (auto* p : *v) {
            std::string nm(p->VpiName());
            if (!filt.empty() && nm.find(filt) == std::string::npos) continue;
            row(std::string(tag) + "[" + nm + "]", p->Typespecs());
        }
    };
    pkgs(d->AllPackages(), "DEFPKG");
    pkgs(d->TopPackages(), "ELABPKG");
    return 0;
}
