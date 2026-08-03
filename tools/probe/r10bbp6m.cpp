// r10bbp6m: per-view PARAMETER / PARAM_ASSIGN materialization census with a
// MULTIPLICITY column — the RB residue is "golden materializes a re-exported
// import copy ONCE PER IMPORT while we materialize one", which a set-valued
// name census cannot see.  Prints one line per (view, param name) with the
// number of listing entries and the distinct declaring parents of each.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp6m.cpp -o /tmp/r10bbp6mq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp6mq <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string viewOf(const BaseClass* p) {
    std::string v(p->VpiName());
    if (p->UhdmType() == uhdmpackage)
        v += ((const package*)p)->VpiTop() ? "[TOP]" : "[DEF]";
    return v;
}

static std::string ownerOf(const any* n) {
    auto* p = n ? n->VpiParent() : nullptr;
    if (!p) return "-";
    std::string o(UhdmName(p->UhdmType()));
    std::string nm(p->VpiName());
    if (!nm.empty()) o += "(" + nm + ")";
    if (p->UhdmType() == uhdmpackage)
        o += ((const package*)p)->VpiTop() ? "[TOP]" : "[DEF]";
    return o;
}

template <typename V>
static void doInst(const std::string& tag, V* v) {
    if (!v) return;
    for (auto* p : *v) {
        std::string vw = viewOf(p);
        std::map<std::string, std::vector<std::string>> byName;
        if (p->Parameters())
            for (auto* pa : *p->Parameters())
                byName[std::string(pa->VpiName())].push_back("P:" +
                                                             ownerOf(pa));
        if (p->Param_assigns())
            for (auto* pas : *p->Param_assigns()) {
                std::string nm = pas->Lhs() ? std::string(pas->Lhs()->VpiName())
                                            : std::string("?");
                byName[nm].push_back("A:" + ownerOf(pas));
            }
        for (auto& [nm, v2] : byName) {
            auto c = v2;
            std::sort(c.begin(), c.end());
            std::cout << tag << "/" << vw << " " << nm << " n=" << c.size();
            for (auto& e : c) std::cout << " " << e;
            std::cout << "\n";
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    doInst("ALLPKG", d->AllPackages());
    doInst("TOPPKG", d->TopPackages());
    doInst("ALLMOD", d->AllModules());
    doInst("TOPMOD", d->TopModules());
    return 0;
}
