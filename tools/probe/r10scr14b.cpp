// r10scr14b: PROCESS-BODY leaf census — every constant / ref_obj reached
// through a design's processes, printed with its span and (for constants) the
// CMP-relevant encoding.  Built for § genProcParamFold questions, where the
// whole answer is "constant or ref_obj, and at what width".
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr14b.cpp -o /tmp/r10scr14_c \
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
        if (!o) continue;
        std::string sp = "@" + std::to_string(o->VpiLineNo()) + ":" +
                         std::to_string(o->VpiColumnNo()) + "-" +
                         std::to_string(o->VpiEndLineNo()) + ":" +
                         std::to_string(o->VpiEndColumnNo());
        if (o->UhdmType() == uhdmconstant) {
            auto* c = (const constant*)o;
            rows.push_back(sp + " constant{ct=" +
                           std::to_string(c->VpiConstType()) +
                           ",sz=" + std::to_string(c->VpiSize()) + ",v=" +
                           std::string(c->VpiValue()) + "}");
        }
        else if (o->UhdmType() == uhdmref_obj) {
            auto* r = (const ref_obj*)o;
            rows.push_back(sp + " ref_obj(" + std::string(r->VpiName()) + ")");
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
