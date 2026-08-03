// r10scr11a: design-level $unit parameter inventory (names, in vector order).
// Ranks the "design.Parameters element missing" head of § genIfUnitMisevalFalse
// follow-on work.  Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr11a.cpp -o /tmp/r10scr11_a \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmdesign) continue;
        auto* d = (design*)o;
        auto* v = d->Parameters();
        std::cout << "design '" << d->VpiName()
                  << "' params n=" << (v ? v->size() : 0) << "\n";
        if (v) {
            int i = 0;
            for (auto* p : *v)
                std::cout << "  [" << i++ << "] "
                          << (p ? std::string(p->VpiName()) : std::string("<null>"))
                          << "\n";
        }
        auto* pa = d->Param_assigns();
        std::cout << " param_assigns n=" << (pa ? pa->size() : 0) << "\n";
    }
    return 0;
}
