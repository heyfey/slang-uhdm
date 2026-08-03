// r10uvm3mtf: print a module's Task_funcs listing (ALL or TOP view).
//   r10uvm3mtf <file.uhdm> <all|top> [modname]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    auto* l = (std::string(argv[2]) == "all") ? d->AllModules() : d->TopModules();
    if (!l) return 1;
    for (auto* m : *l) {
        if (argc > 3 && m->VpiName() != argv[3]) continue;
        if (!m->Task_funcs()) { std::cout << "# " << m->VpiName() << " <null>\n"; continue; }
        long i = 0;
        for (auto* t : *m->Task_funcs()) {
            auto* p = t->VpiParent();
            std::cout << "[" << i++ << "] " << UhdmName(t->UhdmType()) << " '"
                      << t->VpiName() << "' @" << t->VpiLineNo() << " parent="
                      << (p ? UhdmName(p->UhdmType()) : "<null>") << "("
                      << (p ? p->VpiName() : "") << ")\n";
        }
    }
    return 0;
}
