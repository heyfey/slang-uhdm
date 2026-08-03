// r10bbp5i: int_typespec-at-a-line census — every int_typespec whose
// VpiLineNo matches, with its VpiExpr (the paren-cast width expression
// Surelog hangs off a `(P)'(x)` cast typespec), Instance, parent chain and
// referrers.  uhdm-cmp names the ref_obj under an int_typespec but not which
// int_typespec copy carries it.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp5i.cpp -o /tmp/r10bbp5iq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp5iq <db.uhdm> <line>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
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
        if (p->VpiLineNo())
            out += "@" + std::to_string(p->VpiLineNo()) + ":" +
                   std::to_string(p->VpiColumnNo());
    }
    return out;
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    uint32_t want = (uint32_t)atoi(argv[2]);
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    auto all = ser.AllObjects();
    for (auto& [obj, id] : all) {
        if (!obj || obj->UhdmType() != uhdmint_typespec) continue;
        auto* it = (const int_typespec*)obj;
        if (it->VpiLineNo() != want) continue;
        std::cout << "int_typespec #" << it->UhdmId() << " @"
                  << it->VpiLineNo() << ":" << it->VpiColumnNo() << "-"
                  << it->VpiEndLineNo() << ":" << it->VpiEndColumnNo()
                  << " name='" << it->VpiName() << "'"
                  << " inst="
                  << (it->Instance() ? std::string(it->Instance()->VpiName())
                                     : std::string("-"))
                  << (it->Instance() &&
                              it->Instance()->UhdmType() == uhdmpackage
                          ? (((const package*)it->Instance())->VpiTop()
                                 ? "[TOP]"
                                 : "[DEF]")
                          : "")
                  << " cast_to_expr=";
        if (auto* e = it->Cast_to_expr())
            std::cout << UhdmName(e->UhdmType()) << "('" << e->VpiName()
                      << "')#" << e->UhdmId();
        else
            std::cout << "-";
        std::cout << " nranges="
                  << (it->Ranges() ? (int)it->Ranges()->size() : -1);
        std::cout << "\n    parent: " << chain((const BaseClass*)it->VpiParent())
                  << "\n";
    }
    return 0;
}
