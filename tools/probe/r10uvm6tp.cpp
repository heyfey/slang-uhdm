// r10uvm6tp: like r10uvm6ts but adds the OWNER chain.  A typespec is almost
// never reached directly -- it hangs off a ref_typespec whose parent is the
// variable/io_decl/typespec_member/package that actually decides the name.  So
// walk VpiParent up to 3 levels and print the chain; that is what tells bare
// from qualified apart.
//   r10uvm6tp <file.uhdm> [namefilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string d1(const BaseClass* o) {
    if (!o) return "-";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) + ")";
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    std::string filt = argc > 2 ? argv[2] : "";
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const any* a = (const any*)o;
        std::string tn(UhdmName(a->UhdmType()));
        if (tn.find("typespec") == std::string::npos) continue;
        if (tn == "ref_typespec") continue;
        std::string nm(o->VpiName());
        if (nm.empty()) continue;
        std::string bare = nm;
        auto p = bare.rfind("::");
        if (p != std::string::npos) bare = bare.substr(p + 2);
        if (!filt.empty() && bare != filt) continue;
        std::string chain;
        const BaseClass* c = o->VpiParent();
        for (int i = 0; i < 4 && c; i++) {
            chain += " <- " + d1(c);
            c = c->VpiParent();
        }
        std::cout << tn << "|" << (nm == bare ? "B" : "Q") << "|" << nm << "|"
                  << o->VpiLineNo() << ":" << o->VpiColumnNo() << chain << "\n";
    }
    return 0;
}
