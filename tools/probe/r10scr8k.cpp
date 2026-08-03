// r10scr8k: WHOLE-DESIGN CONSTANT census.  One sorted line per constant with
// the CMP-relevant projection (VpiConstType / VpiSize / VpiValue /
// VpiDecompile) plus enough context to find it again (enclosing instance,
// span, parent-kind chain).  uhdm-cmp compares exactly those four fields on a
// constant, so `diff golden ours` is the complete list of constant-encoding
// disagreements in the design — one command instead of chasing echo heads one
// at a time.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr8k.cpp -o /tmp/r10scr8_k \
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
    std::string want = argc > 2 ? argv[2] : "";
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmconstant) continue;
        auto* c = (const constant*)o;
        std::string encl = "<none>";
        std::string chain;
        int d = 0;
        for (const BaseClass* p = o->VpiParent(); p && d < 9;
             p = p->VpiParent(), d++) {
            if (p->UhdmType() == uhdmmodule_inst && encl == "<none>") {
                encl = std::string(((const module_inst*)p)->VpiFullName());
                break;
            }
            if (p->UhdmType() == uhdmpackage && encl == "<none>") {
                encl = std::string(((const package*)p)->VpiFullName());
                break;
            }
            chain += std::string(UhdmName(p->UhdmType())) + "<";
        }
        // The parent CHAIN is deliberately NOT part of the key: vpiParent is
        // not a CMP-compared field, and threading it through made every
        // re-parenting difference look like a constant difference.
        (void)chain;
        std::string row = encl + " | " + std::to_string(o->VpiLineNo()) + ":" +
                          std::to_string(o->VpiColumnNo()) +
                          " | ct=" + std::to_string(c->VpiConstType()) +
                          ",sz=" + std::to_string(c->VpiSize()) + ",v=" +
                          std::string(c->VpiValue()) + ",dc=" +
                          std::string(c->VpiDecompile());
        if (!want.empty() && row.find(want) == std::string::npos) continue;
        rows.push_back(row);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
