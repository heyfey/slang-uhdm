// r10uvm3en: list the enum_consts of every enum_typespec of a given NAME,
// with the fields Compare reads.
//   r10uvm3en <file.uhdm> <enum-typespec-name>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string want = argv[2];
    long seen = 0;
    for (auto& pr : s.AllObjects()) {
        if (!pr.first || pr.first->UhdmType() != UHDM::uhdmenum_typespec)
            continue;
        auto* e = (enum_typespec*)pr.first;
        if (e->VpiName() != want) continue;
        if (seen++ > 1) break;
        std::cout << "### enum_typespec '" << e->VpiName() << "' @" << e->VpiLineNo()
                  << " consts=" << (e->Enum_consts() ? (long)e->Enum_consts()->size() : -1)
                  << "\n";
        if (!e->Enum_consts()) continue;
        long i = 0;
        for (auto* c : *e->Enum_consts())
            std::cout << "[" << i++ << "] '" << c->VpiName() << "' @" << c->VpiLineNo()
                      << ":" << c->VpiColumnNo() << " size=" << c->VpiSize()
                      << " dec='" << c->VpiDecompile() << "' val='" << c->VpiValue() << "'\n";
    }
    return 0;
}
