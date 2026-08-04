// r10rggen6loc: locate objects of a given UHDM type by line:col — prints file,
// name, and the parent chain, so a shape-probe row that says only
// `logic_typespec()@72:5` can be named.
//   r10rggen6loc <file.uhdm> <line> <col> [uhdmtype-name-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string chain(const BaseClass* o) {
    std::string s;
    int d = 0;
    for (const BaseClass* p = o->VpiParent(); p && d < 8; p = p->VpiParent(), d++)
        s += " <- " + std::string(UhdmName(p->UhdmType())) + "(" +
             std::string(p->VpiName()) + ")@" + std::to_string(p->VpiLineNo());
    return s;
}

int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    int wl = std::stoi(argv[2]), wc = std::stoi(argv[3]);
    std::string want = argc > 4 ? argv[4] : "";
    std::set<std::string> seen;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj) continue;
        std::string tn(UhdmName(obj->UhdmType()));
        if (!want.empty() && tn.find(want) == std::string::npos) continue;
        if ((int)obj->VpiLineNo() != wl) continue;
        if (wc >= 0 && (int)obj->VpiColumnNo() != wc) continue;
        std::string row = tn + "(" + std::string(obj->VpiName()) + ") " +
                          std::string(obj->VpiFile()) + ":" +
                          std::to_string(obj->VpiLineNo()) + ":" +
                          std::to_string(obj->VpiColumnNo()) + chain(obj);
        if (seen.insert(row).second) std::cout << row << "\n";
    }
    return 0;
}
