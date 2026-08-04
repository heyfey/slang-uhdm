// r10uvm9c: reference-binding census WITH the reference's syntactic ROLE —
// the kind of its immediate parent object and, when that parent is an
// operation/method call, which slot it fills.  r10uvm7r proved the binding gap
// is real (golden SETs an io_decl, we leave null) but PARTIAL inside one body
// (uvm_leaf_scope binds at the bare `full_name` and not at `full_name[pos]`),
// so the discriminator is positional, not a per-body suppression flag.
//   r10uvm9c <file.uhdm>
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
        const BaseClass* p = o->VpiParent();
        std::string role = p ? std::string(UhdmName(p->UhdmType())) : "<none>";
        if (p && p->UhdmType() == uhdmmethod_func_call) {
            auto* m = (const method_func_call*)p;
            role += (m->Prefix() == (const any*)o) ? ":prefix" : ":arg";
        }
        else if (p && p->UhdmType() == uhdmbit_select) {
            auto* b = (const bit_select*)p;
            role += (b->VpiIndex() == (const any*)o) ? ":index" : ":base";
        }
        else if (p && p->UhdmType() == uhdmoperation) {
            role += ":" + std::to_string(((const operation*)p)->VpiOpType());
        }
        std::cout << (act ? "SET" : "null") << "|" << o->VpiName() << "|"
                  << (act ? UhdmName(act->UhdmType()) : "-") << "|" << role
                  << "|" << ownerOf(o->VpiParent()) << "|" << o->VpiLineNo()
                  << "\n";
    }
    return 0;
}
