// r10bbp10d: ref_obj RESOLUTION census.  For every ref_obj in the arena at a
// requested line (or all lines), print name, loc, VpiParent, and what its
// Actual_group() resolves to — the slot uhdm-cmp walks and the one that shows
// up as "failLhs <constant>, failRhs <null>" when golden resolves a reference
// to a FOLDED CONSTANT and we leave it unresolved.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp10d.cpp -o /tmp/r10bbp10dq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp10dq <db.uhdm> [line] [name-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::string at(const any* n) {
    if (!n) return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + "@" +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    std::string nm(n->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += "{ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    int wantLine = argc > 2 ? atoi(argv[2]) : 0;
    std::string wantName = argc > 3 ? argv[3] : "";
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    std::map<std::string, int> tally;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmref_obj) continue;
        auto* r = (const ref_obj*)obj;
        if (wantLine && (int)r->VpiLineNo() != wantLine) continue;
        std::string nm(r->VpiName());
        if (!wantName.empty() && nm.find(wantName) == std::string::npos)
            continue;
        std::string chain;
        const any* p = r->VpiParent();
        for (int i = 0; p && i < 8; i++) {
            chain += "/" + std::string(UhdmName(p->UhdmType()));
            if (p->UhdmType() == uhdmpackage ||
                p->UhdmType() == uhdmmodule_inst)
                chain += "(" + std::string(p->VpiName()) + ")";
            p = p->VpiParent();
        }
        std::string k = at(r) + "  par=" + at(r->VpiParent()) + "  chain=" +
                        chain + "  actual=" + at(r->Actual_group());
        tally[k]++;
    }
    for (auto& [k, n] : tally) std::cout << n << "  " << k << "\n";
    return 0;
}
