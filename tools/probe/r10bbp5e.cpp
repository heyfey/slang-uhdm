// r10bbp5e: enum_const census for one named enum_typespec — the CMP-relevant
// fields (VpiName / VpiDecompile / VpiSize; VpiValue is Compare-skipped) per
// copy, with the copy's parent chain.  uhdm-cmp names the enum_const but not
// which of the design's copies of the enum carries the bad field.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp5e.cpp -o /tmp/r10bbp5eq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp5eq <db.uhdm> <enum-typespec-name>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 6;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty()) out += "(" + nm + ")";
        if (p->UhdmType() == uhdmpackage)
            out += ((const package*)p)->VpiTop() ? "[TOP]" : "[DEF]";
    }
    return out;
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::string want = argv[2];
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmenum_typespec) continue;
        auto* et = (const enum_typespec*)obj;
        if (std::string(et->VpiName()) != want) continue;
        std::cout << "enum_typespec #" << et->UhdmId() << " inst="
                  << (et->Instance() ? std::string(et->Instance()->VpiName())
                                     : std::string("-"))
                  << " parent: " << chain((const BaseClass*)et->VpiParent())
                  << "\n";
        if (!et->Enum_consts()) continue;
        for (auto* ec : *et->Enum_consts())
            std::cout << "    #" << ec->UhdmId() << " " << ec->VpiName()
                      << " size=" << ec->VpiSize()
                      << " dec='" << ec->VpiDecompile() << "' val='"
                      << ec->VpiValue() << "'\n";
    }
    return 0;
}
