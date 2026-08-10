// r10uvm38t — every object NAMED `this` in a database, with its kind, id,
// parent chain, fullname and (for nets) net type, plus a count of the
// references that bind each one.  Pass 37 left `this -> logic_net:this` as the
// biggest single MISS bucket and a KIND:NAME census cannot say WHICH object is
// bound nor WHERE it lives; this answers both.
//   r10uvm38t <file.uhdm>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    (void)h;
    auto all = s.AllObjects();
    std::map<const BaseClass*, unsigned> id;
    for (auto& [o, i] : all) id[o] = i;
    // count binders
    std::map<const BaseClass*, int> binders;
    for (auto& [o, i] : all) {
        const any* act = nullptr;
        if (auto* r = any_cast<const ref_obj*>(o)) act = r->Actual_group();
        else if (auto* r = any_cast<const ref_var*>(o)) act = r->Actual_group();
        else if (auto* r = any_cast<const bit_select*>(o)) act = r->Actual_group();
        if (act) binders[act]++;
    }
    for (auto& [o, i] : all) {
        if (o->VpiName() != "this") continue;
        std::string chain;
        const BaseClass* p = o->VpiParent();
        for (int k = 0; p && k < 6; ++k) {
            chain += std::string(UhdmName(p->UhdmType())) + ":" +
                     std::string(p->VpiName()) + "#" +
                     std::to_string(id.count(p) ? id[p] : 0) + " < ";
            p = p->VpiParent();
        }
        std::string full;
        if (auto* nn = any_cast<const nets*>(o)) full = nn->VpiFullName();
        else if (auto* vv = any_cast<const variables*>(o)) full = vv->VpiFullName();
        std::cout << UhdmName(o->UhdmType()) << "#" << i << " full='" << full
                  << "'";
        if (auto* n = any_cast<const nets*>(o))
            std::cout << " netType=" << n->VpiNetType();
        if (auto* n = any_cast<const net*>(o))
            std::cout << " ts=" << (n->Typespec() ? "y" : "n");
        std::cout << " loc=" << o->VpiLineNo() << ":" << o->VpiColumnNo()
                  << " binders=" << binders[o] << " parents=" << chain << "\n";
    }
    return 0;
}
