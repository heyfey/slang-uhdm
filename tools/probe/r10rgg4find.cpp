// r10rgg4find: locate objects by (uhdm type name, VpiName, line) and print each
// one's PARENT CHAIN — for tracking down "an extra object one side has".
//   r10rgg4find <file.uhdm> <typename> <name> [line]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::string ty = argv[2], want = argv[3];
    int line = argc > 4 ? atoi(argv[4]) : -1;
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o) continue;
        if (std::string(UhdmName(o->UhdmType())) != ty) continue;
        if (std::string(o->VpiName()) != want) continue;
        if (line >= 0 && (int)o->VpiLineNo() != line) continue;
        std::string r = ty + "(" + want + ")@" + std::to_string(o->VpiLineNo()) +
                        ":" + std::to_string(o->VpiColumnNo());
        int depth = 0;
        for (const BaseClass* p = o->VpiParent(); p && depth < 12;
             p = p->VpiParent(), depth++)
            r += " <- " + std::string(UhdmName(p->UhdmType())) + "(" +
                 std::string(p->VpiName()) + ")@" +
                 std::to_string(p->VpiLineNo());
        rows.push_back(r);
    }
    std::sort(rows.begin(), rows.end());
    std::vector<std::string> uniq = rows;
    uniq.erase(std::unique(uniq.begin(), uniq.end()), uniq.end());
    std::cout << "TOTAL " << rows.size() << " (" << uniq.size() << " unique)\n";
    for (auto& r : uniq) std::cout << r << "\n";
    return 0;
}
