// r10uvm7r: census of REFERENCE binding — for every ref_obj/ref_var, whether
// vpiActual is set and what kind of object it names, keyed by the enclosing
// subroutine.  LAW C is a lookup law, so it governs references as well as
// calls; this is the reference-side projection (the call side is r10uvm7f).
//   r10uvm7r <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string ownerOf(const BaseClass* o) {
    int guard = 0;
    std::string sub;
    while (o && guard++ < 40) {
        switch (o->UhdmType()) {
            case uhdmfunction:
            case uhdmtask:
                if (sub.empty()) sub = std::string(o->VpiName());
                break;
            case uhdmclass_defn:
                return "class:" + std::string(o->VpiName()) + "/" + sub;
            case uhdmpackage:
                return "pkg:" + std::string(o->VpiName()) + "/" + sub;
            case uhdmmodule_inst:
                return "mod:" + std::string(o->VpiName()) + "/" + sub;
            default:
                break;
        }
        o = o->VpiParent();
    }
    return "?/" + sub;
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    for (auto& kv : s.AllObjects()) {
        auto* o = (const BaseClass*)kv.first;
        if (!o) continue;
        const any* act = nullptr;
        if (o->UhdmType() == uhdmref_obj)
            act = ((const ref_obj*)o)->Actual_group();
        else if (o->UhdmType() == uhdmref_var)
            act = ((const ref_var*)o)->Actual_group();
        else
            continue;
        std::cout << std::string(UhdmName(o->UhdmType())) << "|"
                  << (act ? "SET" : "null") << "|" << o->VpiName() << "|"
                  << (act ? UhdmName(act->UhdmType()) : "-") << "|"
                  << ownerOf(o->VpiParent()) << "|" << o->VpiLineNo() << "\n";
    }
    return 0;
}
