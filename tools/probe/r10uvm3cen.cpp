// r10uvm3cen: census of design-level and package-level listing sizes, both
// AllPackages and TopPackages, plus design Task_funcs/Typespecs.
//   r10uvm3cen <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

template <typename V>
static long sz(const V* v) {
    return v ? (long)v->size() : -1;
}

static void pkgline(const char* tag, const package* p) {
    std::cout << tag << " " << p->VpiName() << " top=" << p->VpiTop()
              << " Var=" << sz(p->Variables()) << " Nets=" << sz(p->Nets())
              << " Ts=" << sz(p->Typespecs()) << " Par=" << sz(p->Parameters())
              << " PA=" << sz(p->Param_assigns()) << " TF=" << sz(p->Task_funcs())
              << " Cls=" << sz(p->Class_defns()) << "\n";
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::cout << "design Task_funcs=" << sz(d->Task_funcs())
              << " Typespecs=" << sz(d->Typespecs())
              << " AllPackages=" << sz(d->AllPackages())
              << " TopPackages=" << sz(d->TopPackages())
              << " AllClasses=" << sz(d->AllClasses())
              << " AllModules=" << sz(d->AllModules())
              << " TopModules=" << sz(d->TopModules()) << "\n";
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) pkgline("ALL", p);
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) pkgline("TOP", p);
    if (argc > 2 && std::string(argv[2]) == "-tf" && d->Task_funcs()) {
        long i = 0;
        for (auto* t : *d->Task_funcs()) {
            std::cout << "dTF[" << i++ << "] " << UhdmName(t->UhdmType()) << " '"
                      << t->VpiName() << "' @" << t->VpiLineNo() << " parent="
                      << (t->VpiParent() ? UhdmName(t->VpiParent()->UhdmType())
                                         : "<null>")
                      << "(" << (t->VpiParent() ? t->VpiParent()->VpiName() : "")
                      << ")\n";
        }
    }
    if (argc > 2 && std::string(argv[2]) == "-dts" && d->Typespecs()) {
        long i = 0;
        for (auto* t : *d->Typespecs())
            std::cout << "dTS[" << i++ << "] " << UhdmName(t->UhdmType()) << " '"
                      << t->VpiName() << "' @" << t->VpiLineNo() << "\n";
    }
    return 0;
}
