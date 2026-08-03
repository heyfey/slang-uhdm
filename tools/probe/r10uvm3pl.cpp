// r10uvm3pl: print one package's listing (by name, ALL or TOP view).
//   r10uvm3pl <file.uhdm> <pkgname> <all|top> <var|ts|tf|par|cls>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string par(const BaseClass* o) {
    auto* p = o->VpiParent();
    if (!p) return "<null>";
    return std::string(UhdmName(p->UhdmType())) + "(" + std::string(p->VpiName()) + ")";
}

template <typename V>
static void show(const V* v) {
    if (!v) { std::cout << "<null>\n"; return; }
    long i = 0;
    for (auto* e : *v) {
        std::cout << "[" << i++ << "] " << UhdmName(e->UhdmType()) << " '"
                  << e->VpiName() << "' def='" << e->VpiDefName() << "' @"
                  << e->VpiLineNo() << ":" << e->VpiColumnNo()
                  << " parent=" << par(e) << "\n";
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::string want = argv[2], view = argv[3], what = argv[4];
    auto* lst = (view == "all") ? d->AllPackages() : d->TopPackages();
    if (!lst) return 1;
    for (auto* p : *lst) {
        if (p->VpiName() != want) continue;
        if (what == "var") show(p->Variables());
        else if (what == "ts") show(p->Typespecs());
        else if (what == "tf") show(p->Task_funcs());
        else if (what == "par") show(p->Parameters());
        else if (what == "cls") show(p->Class_defns());
        return 0;
    }
    return 1;
}
