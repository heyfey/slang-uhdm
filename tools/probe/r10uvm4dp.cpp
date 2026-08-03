// r10uvm4dp: the design's package vectors, element by element — which view
// each entry is (vpiTop) and how big its listings are.
//   r10uvm4dp <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::map<const void*, long> ids;
    auto id = [&](const void* p) {
        auto it = ids.find(p);
        if (it != ids.end()) return it->second;
        long n = (long)ids.size();
        ids[p] = n;
        return n;
    };
    for (int top = 0; top < 2; top++) {
        auto* l = top ? d->TopPackages() : d->AllPackages();
        std::cout << (top ? "TopPackages" : "AllPackages") << ": "
                  << (l ? l->size() : 0) << "\n";
        if (!l) continue;
        long i = 0;
        for (auto* p : *l)
            std::cout << "  [" << i++ << "] #" << id((const void*)p) << " '"
                      << p->VpiName() << "' top=" << p->VpiTop()
                      << " tf=" << (p->Task_funcs() ? p->Task_funcs()->size() : 0)
                      << " ts=" << (p->Typespecs() ? p->Typespecs()->size() : 0)
                      << " cls=" << (p->Class_defns() ? p->Class_defns()->size() : 0)
                      << " var=" << (p->Variables() ? p->Variables()->size() : 0)
                      << "\n";
    }
    return 0;
}
