// A module/package's Task_funcs vector, in order: name, span and the owner
// the object is actually parented at. A cmptool "function(a) vs function(b)"
// mismatch is an ORDER or MEMBERSHIP difference in this vector — which entry
// is missing, extra or swapped only shows in the full listing.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void dump(const char* tag, const std::string& owner,
                 const VectorOftask_func* tfs) {
    if (!tfs) return;
    std::cout << tag << " " << owner << "  Task_funcs " << tfs->size() << "\n";
    for (auto* tf : *tfs) {
        std::cout << "    " << tf->VpiName() << " @" << tf->VpiLineNo() << ":"
                  << tf->VpiColumnNo() << " parent=";
        if (auto* p = tf->VpiParent())
            std::cout << UhdmName(p->UhdmType()) << "(" << p->VpiName() << ")";
        std::cout << "\n";
    }
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: w4tflist <uhdm>\n"; return 2; }
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    if (auto* v = d->AllModules())
        for (auto* m : *v)
            dump("DEFMOD", std::string(m->VpiDefName()), m->Task_funcs());
    if (auto* v = d->TopModules())
        for (auto* m : *v)
            dump("TOPMOD", std::string(m->VpiName()), m->Task_funcs());
    if (auto* v = d->AllPackages())
        for (auto* p : *v)
            dump("DEFPKG", std::string(p->VpiName()), p->Task_funcs());
    if (auto* v = d->TopPackages())
        for (auto* p : *v)
            dump("TOPPKG", std::string(p->VpiName()), p->Task_funcs());
    return 0;
}
