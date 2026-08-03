// r10uvm3ec: print every enum_const of a given NAME with the fields Compare
// looks at (VpiConstType / VpiDecompile / VpiSize / VpiValue).
//   r10uvm3ec <file.uhdm> <name>
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
    long n = 0;
    for (auto& pr : s.AllObjects()) {
        if (!pr.first || pr.first->UhdmType() != UHDM::uhdmenum_const)
            continue;
        auto* c = (enum_const*)pr.first;
        if (c->VpiName() != want) continue;
        if (n++ > 6) break;
        std::cout << "enum_const '" << c->VpiName() << "' @" << c->VpiLineNo()
                  << ":" << c->VpiColumnNo() << " "
                  << " size=" << c->VpiSize() << " decompile='" << c->VpiDecompile()
                  << "' value='" << c->VpiValue() << "' parent="
                  << (c->VpiParent() ? UhdmName(c->VpiParent()->UhdmType()) : "<null>")
                  << "(" << (c->VpiParent() ? c->VpiParent()->VpiName() : "") << ")\n";
    }
    std::cout << "total matches scanned=" << n << "\n";
    return 0;
}
