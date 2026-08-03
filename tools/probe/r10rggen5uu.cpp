// r10rggen5uu: census of UNBASED-UNSIZED literals ('0/'1/'x/'z) in a database.
// One row per constant whose decompile starts with a quote and has no base
// digit count: file:line:col, size, const type, decompile.  Run on golden and
// on ours and diff to see where Surelog SIZES the literal.
//   r10rggen5uu <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::map<std::string, std::string> rows;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmconstant) continue;
        auto* c = (const constant*)obj;
        std::string dec(c->VpiDecompile());
        if (dec.size() < 2 || dec[0] != '\'') continue;
        if (dec.size() > 2) continue;  // '0 '1 'x 'z only
        std::string key = std::string(c->VpiFile()) + ":" +
                          std::to_string(c->VpiLineNo()) + ":" +
                          std::to_string(c->VpiColumnNo());
        rows[key] = " sz=" + std::to_string(c->VpiSize()) +
                    " ct=" + std::to_string(c->VpiConstType()) + " dec=" + dec;
    }
    for (auto& [k, v] : rows) std::cout << k << v << "\n";
    return 0;
}
