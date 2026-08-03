// r10scr9b: named int_typespec census WITH the owning parent chain, so each
// copy can be attributed to a view (def listing vs elaborated instance) and a
// site (parameter declaration vs cast).  Diagnostic only -- parents are NOT
// cmp-relevant, this exists to name WHICH emitter site built a copy.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr9b.cpp -o /tmp/r10scr9_b \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string chain(const BaseClass* o) {
    std::string r;
    int n = 0;
    for (const BaseClass* p = o->VpiParent(); p && n < 5; p = p->VpiParent(), n++) {
        r += " <- " + std::string(UhdmName(p->UhdmType()));
        if (!p->VpiName().empty()) r += "'" + std::string(p->VpiName()) + "'";
        if (auto* ip = dynamic_cast<const instance*>(p))
            r += "{" + std::string(ip->VpiFullName()) + "}";
    }
    return r;
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::string filter = argv[2];
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmint_typespec) continue;
        auto* t = (const int_typespec*)o;
        std::string nm(t->VpiName());
        if (nm != filter) continue;
        std::string r = nm + " ce=" + (t->Cast_to_expr() ? "1" : "0") +
                        " val=" + std::string(t->VpiValue()) + " loc=" +
                        std::to_string(t->VpiLineNo()) + ":" +
                        std::to_string(t->VpiColumnNo()) + chain(t);
        rows.push_back(r);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
