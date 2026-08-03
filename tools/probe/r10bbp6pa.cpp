// r10bbp6pa: every param_assign in the design for one LHS name — parent chain,
// Rhs kind/value, and the Lhs object's own parent.  A cmp head of the form
// "failLhs=constant@L rhsNULL under param_assign@L" means one COPY of that
// param_assign lost its Rhs; a name-keyed listing census cannot see which.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp6pa.cpp -o /tmp/r10bbp6paq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp6paq <db.uhdm> <lhs-name>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 8;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty()) out += "(" + nm + ")";
        if (p->UhdmType() == uhdmpackage)
            out += ((const package*)p)->VpiTop() ? "[TOP]" : "[DEF]";
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
    std::vector<std::string> lines;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmparam_assign) continue;
        auto* pa = (const param_assign*)obj;
        if (!pa->Lhs() || std::string(pa->Lhs()->VpiName()) != want) continue;
        std::string r = "NULL";
        if (auto* rh = pa->Rhs()) {
            r = std::string(UhdmName(rh->UhdmType()));
            if (rh->UhdmType() == uhdmconstant)
                r += "{" + std::string(((const constant*)rh)->VpiValue()) + "}";
        }
        lines.push_back("PA rhs=" + r + " || " + chain(pa) +
                        "  [lhs: " + chain(pa->Lhs()) + "]");
    }
    std::sort(lines.begin(), lines.end());
    for (auto& l : lines) std::cout << l << "\n";
    return 0;
}
