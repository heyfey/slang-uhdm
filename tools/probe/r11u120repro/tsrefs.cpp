// r11u120 tsrefs: every ref_typespec of a database whose ACTUAL is a typespec
// at <line>:<col>, with the ref's parent chain (3 levels) and the actual's
// identity (serializer id) — which objects READ which copy of a typespec.
//   tsrefs <file.uhdm> <line> <col>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    auto ids = s.AllObjects();
    int L = std::stoi(argv[2]), C = std::stoi(argv[3]);
    auto tag = [&](const BaseClass* o) {
        return std::string(UhdmName(o->UhdmType())) + "#" + std::to_string(ids[o]) + "(" +
               std::string(o->VpiName()) + ")@" + std::to_string(o->VpiLineNo()) + ":" +
               std::to_string(o->VpiColumnNo());
    };
    for (auto& [o, id] : ids) {
        if (!o || o->UhdmType() != uhdmref_typespec) continue;
        auto* a = ((const ref_typespec*)o)->Actual_typespec();
        if (!a || (int)a->VpiLineNo() != L || (int)a->VpiColumnNo() != C) continue;
        std::cout << "-> " << tag(a) << "  by ";
        int d = 0;
        for (const BaseClass* p = o->VpiParent(); p && d < 4; p = p->VpiParent(), d++)
            std::cout << " <- " << tag(p);
        std::cout << "\n";
    }
}
