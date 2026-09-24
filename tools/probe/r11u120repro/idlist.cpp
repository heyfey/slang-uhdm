// r11u120 idlist: every object of a UHDM database in RESTORED ADDRESS order —
// the order uhdm2rtlil's pointer-keyed std::map<const any*, ...> containers
// iterate — one row per object:
//   <addr-rank> <serializer id> <UhdmId> <type> <name> <line.col-endline.endcol> <- parent
// Within one UHDM type, restored addresses follow the serialized per-type index,
// which is the producer's per-type CREATION order (Serializer::Save numbers each
// factory in allocation order).  So two producers' rows of one type, filtered
// by name, compare their creation orders directly.
//   idlist <file.uhdm> [type-regex] [name-regex]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <regex>
#include <string>
using namespace UHDM;

static std::string span(const BaseClass* o) {
    return std::to_string(o->VpiLineNo()) + "." + std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + "." + std::to_string(o->VpiEndColumnNo());
}
int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: idlist <file.uhdm> [type-regex] [name-regex]\n";
        return 2;
    }
    std::regex tre(argc > 2 ? argv[2] : ".*"), nre(argc > 3 ? argv[3] : ".*");
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    uint64_t rank = 0;
    for (auto& [obj, id] : s.AllObjects()) {
        rank++;
        if (!obj) continue;
        std::string t(UhdmName(obj->UhdmType())), n(obj->VpiName());
        if (!std::regex_search(t, tre) || !std::regex_search(n, nre)) continue;
        const BaseClass* p = obj->VpiParent();
        std::cout << rank << " " << id << " " << obj->UhdmId() << " " << t << " "
                  << (n.empty() ? "-" : n) << " " << span(obj);
        if (obj->UhdmType() == uhdmconstant)
            std::cout << " val=" << ((const constant*)obj)->VpiValue();
        if (p)
            std::cout << " <- " << UhdmName(p->UhdmType()) << "(" << p->VpiName() << ")@"
                      << p->VpiLineNo() << "." << p->VpiColumnNo();
        std::cout << "\n";
    }
    return 0;
}
