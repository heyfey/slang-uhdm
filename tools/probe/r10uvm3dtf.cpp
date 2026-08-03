// r10uvm3dtf: which objects is design->Task_funcs made of?  Reports pointer
// overlap with each package's ALL/TOP listing and with each module's listing.
//   r10uvm3dtf <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

template <typename V>
static void overlap(const char* tag, const std::set<const void*>& d, const V* v) {
    if (!v) return;
    long n = 0;
    for (auto* e : *v) if (d.count((const void*)e)) n++;
    std::cout << "  " << tag << ": " << n << "/" << v->size() << " of design's list\n";
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* dz = (design*)((uhdm_handle*)h[0])->object;
    if (!dz->Task_funcs()) { std::cout << "design Task_funcs null\n"; return 0; }
    std::set<const void*> d;
    for (auto* e : *dz->Task_funcs()) d.insert((const void*)e);
    std::cout << "design Task_funcs size=" << dz->Task_funcs()->size() << "\n";
    if (dz->AllPackages())
        for (auto* p : *dz->AllPackages())
            overlap((std::string("ALL ") + std::string(p->VpiName())).c_str(), d, p->Task_funcs());
    if (dz->TopPackages())
        for (auto* p : *dz->TopPackages())
            overlap((std::string("TOP ") + std::string(p->VpiName())).c_str(), d, p->Task_funcs());
    if (dz->AllModules())
        for (auto* m : *dz->AllModules())
            overlap((std::string("ALLmod ") + std::string(m->VpiName())).c_str(), d, m->Task_funcs());
    if (dz->TopModules())
        for (auto* m : *dz->TopModules())
            overlap((std::string("TOPmod ") + std::string(m->VpiName())).c_str(), d, m->Task_funcs());
    return 0;
}
