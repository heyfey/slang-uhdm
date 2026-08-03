// r10scr7e: dump every enum_typespec whose name matches a substring, with its
// Base_typespec, Typedef_alias and the full Enum_const list (name, size,
// value, decompile) — the CMP-relevant projection for enum comparison.
//   r10scr7e <file.uhdm> <name-substring>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string want = argv[2];
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmenum_typespec) continue;
        auto* e = (const enum_typespec*)o;
        if (std::string(e->VpiName()).find(want) == std::string::npos) continue;
        std::cout << "enum_typespec(" << e->VpiName() << ")@" << e->VpiLineNo()
                  << ":" << e->VpiColumnNo() << "  parent="
                  << (e->VpiParent() ? UhdmName(e->VpiParent()->UhdmType())
                                     : "<null>")
                  << " base="
                  << (e->Base_typespec() && e->Base_typespec()->Actual_typespec()
                          ? UhdmName(e->Base_typespec()
                                         ->Actual_typespec()
                                         ->UhdmType())
                          : "<none>")
                  << "\n";
        if (!e->Enum_consts()) {
            std::cout << "   <no consts>\n";
            continue;
        }
        int i = 0;
        for (auto* c : *e->Enum_consts())
            std::cout << "   [" << i++ << "] " << c->VpiName() << " @"
                      << c->VpiLineNo() << ":" << c->VpiColumnNo()
                      << " sz=" << c->VpiSize() << " v=" << c->VpiValue()
                      << " dc=" << c->VpiDecompile()
                      << "\n";
    }
    return 0;
}
