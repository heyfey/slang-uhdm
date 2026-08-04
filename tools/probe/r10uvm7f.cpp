// r10uvm7f: for every func_call/task_call, print whether the callee pointer is
// set, the callee's OWNER (class/package), and the CALL SITE's owner.  The
// same NAME is sometimes bound and sometimes not in the golden, so the
// discriminator is contextual — this projects onto the only two contexts a
// name-keyed census cannot see.
//   r10uvm7f <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string ownerOf(const BaseClass* o) {
    int guard = 0;
    while (o && guard++ < 40) {
        switch (o->UhdmType()) {
            case uhdmclass_defn:
                return "class:" + std::string(o->VpiName());
            case uhdmpackage:
                return "pkg:" + std::string(o->VpiName());
            case uhdmmodule_inst:
                return "mod:" + std::string(o->VpiName());
            case uhdmdesign:
                return "design";
            default:
                break;
        }
        o = o->VpiParent();
    }
    return "?";
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    for (auto& kv : s.AllObjects()) {
        auto* o = (const BaseClass*)kv.first;
        if (!o) continue;
        const BaseClass* callee = nullptr;
        const char* kind = nullptr;
        if (o->UhdmType() == uhdmfunc_call) {
            kind = "fc";
            callee = ((const func_call*)o)->Function();
        } else if (o->UhdmType() == uhdmtask_call) {
            kind = "tc";
            callee = ((const task_call*)o)->Task();
        } else
            continue;
        std::cout << kind << "|" << (callee ? "SET" : "null") << "|"
                  << o->VpiName() << "|site=" << ownerOf(o->VpiParent())
                  << "|callee=" << (callee ? ownerOf(callee->VpiParent()) : "-")
                  << "|" << o->VpiFile() << ":" << o->VpiLineNo() << "\n";
    }
    return 0;
}
