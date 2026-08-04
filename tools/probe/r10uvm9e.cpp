// r10uvm9e: hier_path ELEMENT census — for every hier_path, one line per
// Path_elems entry: element index, element object kind, whether a ref
// element's vpiActual is set and to what, plus the owning subroutine.  The
// role census (r10uvm9c) showed golden binds 5080 hier_path element refs on
// SeqDriver where we bind 172, but leaves 14504 null — so the law is
// positional and this projects the position.
//   r10uvm9e <file.uhdm>
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
        if (!o || o->UhdmType() != uhdmhier_path) continue;
        auto* hp = (const hier_path*)o;
        auto* es = hp->Path_elems();
        if (!es) continue;
        size_t n = es->size();
        for (size_t i = 0; i < n; i++) {
            const any* e = (*es)[i];
            if (!e) continue;
            const any* act = nullptr;
            if (e->UhdmType() == uhdmref_obj)
                act = ((const ref_obj*)e)->Actual_group();
            else if (e->UhdmType() == uhdmref_var)
                act = ((const ref_var*)e)->Actual_group();
            std::cout << "i" << i << "/" << n << "|"
                      << UhdmName(e->UhdmType()) << "|"
                      << (act ? "SET" : "null") << "|"
                      << (act ? UhdmName(act->UhdmType()) : "-") << "|"
                      << e->VpiName() << "|" << ownerOf(hp->VpiParent()) << "|"
                      << e->VpiLineNo() << "\n";
        }
    }
    return 0;
}
