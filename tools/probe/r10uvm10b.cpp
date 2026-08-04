// r10uvm10b: ref_var provenance — every ref_var object with its parent chain,
// its Actual_group and its typespec, plus the owning subroutine.  Golden binds
// 314 hier_path elements to ref_var objects in the adpcm_pkg CLONE where we
// have none at all; this says WHAT those objects are and where they are
// listed (a block's Variables? a task_func's Variables?).
//   r10uvm10b <file.uhdm>
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
        if (!o || o->UhdmType() != uhdmref_var) continue;
        auto* r = (const ref_var*)o;
        const BaseClass* p = r->VpiParent();
        std::string chain;
        for (int g = 0; p && g < 4; g++, p = p->VpiParent())
            chain += std::string(UhdmName(p->UhdmType())) + ":" +
                     std::string(p->VpiName()) + ">";
        const typespec* ts = nullptr;
        if (auto* rt = r->Typespec()) ts = rt->Actual_typespec();
        std::cout << r->VpiName() << "|act="
                  << (r->Actual_group()
                          ? std::string(UhdmName(r->Actual_group()->UhdmType()))
                          : std::string("-"))
                  << "|ts="
                  << (ts ? std::string(UhdmName(ts->UhdmType())) + ":" +
                               std::string(ts->VpiName())
                         : std::string("-"))
                  << "|parents=" << chain << "|" << ownerOf(r->VpiParent())
                  << "|" << r->VpiLineNo() << ":" << r->VpiColumnNo() << "\n";
    }
    return 0;
}
