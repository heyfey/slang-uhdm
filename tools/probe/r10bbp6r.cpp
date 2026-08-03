// r10bbp6r: WHICH-COPY referrer scan — for a named typespec (any kind), list
// every copy with its parent chain, then every ref_typespec pointing at one of
// them with the REFERRER's chain and the target copy id.  Answers "the two
// designs bind different COPIES of the right-named typespec in this slot",
// which a name-only listing diff cannot see.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp6r.cpp -o /tmp/r10bbp6rq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp6rq <db.uhdm> <typespec-name>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 12;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty()) out += "(" + nm + ")";
        if (p->UhdmType() == uhdmpackage)
            out += ((const package*)p)->VpiTop() ? "[TOP]" : "[DEF]";
        if (p->VpiLineNo()) out += "@" + std::to_string(p->VpiLineNo());
    }
    if (out.empty()) out = "<noparent>";
    return out;
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::string want = argv[2];
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    auto all = ser.AllObjects();
    // copy id -> a stable label ("C0", "C1", ...) in parent-chain order
    std::vector<const typespec*> copies;
    for (auto& [obj, id] : all) {
        if (!obj) continue;
        auto* t = dynamic_cast<const typespec*>(obj);
        if (!t || std::string(t->VpiName()) != want) continue;
        copies.push_back(t);
    }
    std::sort(copies.begin(), copies.end(),
              [](const typespec* a, const typespec* b) {
                  return chain(a) < chain(b);
              });
    std::map<const BaseClass*, std::string> lbl;
    for (size_t i = 0; i < copies.size(); i++) {
        lbl[copies[i]] = "C" + std::to_string(i);
        std::cout << "C" << i << " " << UhdmName(copies[i]->UhdmType()) << " @"
                  << copies[i]->VpiLineNo() << " inst=";
        if (auto* in = copies[i]->Instance()) {
            std::cout << in->VpiName();
            if (in->UhdmType() == uhdmpackage)
                std::cout << (((const package*)in)->VpiTop() ? "[TOP]"
                                                             : "[DEF]");
        } else
            std::cout << "-";
        std::cout << " || " << chain(copies[i]) << "\n";
    }
    std::vector<std::string> refs;
    for (auto& [obj, id] : all) {
        if (!obj || obj->UhdmType() != uhdmref_typespec) continue;
        auto* r = (const ref_typespec*)obj;
        auto it = lbl.find((const BaseClass*)r->Actual_typespec());
        if (it == lbl.end()) continue;
        refs.push_back("REF -> " + it->second + " :: " + chain(r));
    }
    std::sort(refs.begin(), refs.end());
    for (auto& l : refs) std::cout << l << "\n";
    return 0;
}
