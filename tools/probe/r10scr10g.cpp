// r10scr10g: gen_scope_array census — one sorted row per array, by fullname.
// Ranks the "which generate arm elaborated" class (§ genIfUnitMisevalFalse).
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr10g.cpp -o /tmp/r10scr10_g2 \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmgen_scope_array) continue;
        auto* g = (const gen_scope_array*)o;
        rows.push_back(std::string(g->VpiFullName()) + " @" +
                       std::to_string(g->VpiLineNo()));
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
