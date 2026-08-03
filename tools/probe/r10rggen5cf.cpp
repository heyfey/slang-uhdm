// r10rggen5cf: locate constants by line:col — prints file, parent chain type
// and value for every constant at the given line/col.  Names the source of a
// shape-probe row that reports only `constant()@L:C`.
//   r10rggen5cf <file.uhdm> <line> <col>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    int wl = std::stoi(argv[2]), wc = std::stoi(argv[3]);
    std::set<std::string> seen;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmconstant) continue;
        auto* c = (const constant*)obj;
        if (c->VpiLineNo() != wl || c->VpiColumnNo() != wc) continue;
        std::string chain;
        const any* p = c->VpiParent();
        for (int i = 0; i < 4 && p; i++) {
            chain += std::string(UhdmName(p->UhdmType())) + "(" +
                     std::string(p->VpiName()) + ")<";
            p = p->VpiParent();
        }
        std::string row = std::string(c->VpiFile()) + " sz=" +
                          std::to_string(c->VpiSize()) + " val=" +
                          std::string(c->VpiValue()) + " dec=" +
                          std::string(c->VpiDecompile()) + " par=" + chain;
        if (seen.insert(row).second) std::cout << row << "\n";
    }
    return 0;
}
