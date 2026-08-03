// r10scr9a: NAMED int_typespec census, projected onto CMP-relevant + the
// Cast_to_expr feature.  One sorted line per object:
//   <name> ce=<0|1> ceact=<0|1|-> val=<VpiValue> loc=<line:col>
// aggregated into "count x row" so `diff golden ours` names the class that
// disagrees without drowning in arena copies.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr9a.cpp -o /tmp/r10scr9_a \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    std::string filter = argc > 2 ? argv[2] : "";
    bool withLoc = argc > 3;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::map<std::string, int> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmint_typespec) continue;
        auto* t = (const int_typespec*)o;
        std::string nm(t->VpiName());
        if (nm.empty()) continue;
        if (!filter.empty() && nm.find(filter) == std::string::npos) continue;
        const expr* ce = t->Cast_to_expr();
        std::string r = nm;
        r += " ce=" + std::string(ce ? "1" : "0");
        if (ce) {
            r += " cekind=" + std::string(UhdmName(ce->UhdmType()));
            r += " cename=" + std::string(ce->VpiName());
            if (ce->UhdmType() == uhdmref_obj) {
                auto* ro = (const ref_obj*)ce;
                r += " ceact=" + std::string(ro->Actual_group() ? "1" : "0");
                if (ro->Actual_group())
                    r += ":" + std::string(UhdmName(ro->Actual_group()->UhdmType()));
            }
        }
        r += " val=" + std::string(t->VpiValue());
        if (withLoc)
            r += " loc=" + std::to_string(t->VpiLineNo()) + ":" +
                 std::to_string(t->VpiColumnNo());
        rows[r]++;
    }
    for (auto& [r, c] : rows) std::cout << c << " x " << r << "\n";
    return 0;
}
