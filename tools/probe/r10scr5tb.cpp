// r10scr5tb: find every ref_obj in the whole serialized design whose
// Actual_group is NULL (dangling), print it with its parent chain.  Surelog
// leaves some def-view references unbound and Compare treats a bound-vs-null
// Actual as a mismatch, so "which refs are dangling" is the whole question.
// Optionally filter by name substring.
//   r10scr5tb <file.uhdm> [name-substring]
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10scr5tb.cpp -o /tmp/r10scr5tb \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer ser;
    ser.Restore(std::filesystem::path(argv[1]));
    int nd = 0, nb = 0;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmref_obj) continue;
        auto* r = (const ref_obj*)obj;
        if (!filt.empty() && std::string(r->VpiName()).find(filt) == std::string::npos)
            continue;
        // "unit-bound" = actual is a parameter parented directly at the design
        // ($unit-scope parameter object), the case at issue.
        bool unitBound = r->Actual_group() &&
                         r->Actual_group()->UhdmType() == uhdmparameter &&
                         r->Actual_group()->VpiParent() &&
                         r->Actual_group()->VpiParent()->UhdmType() == uhdmdesign;
        if (r->Actual_group() && !unitBound) { nb++; continue; }
        nd++;
        std::cout << (unitBound ? "UNITBOUND " : "DANGLING ") << nm(r)
                  << " full=" << r->VpiFullName() << "\n";
        int depth = 0;
        for (const BaseClass* p = r->VpiParent(); p && depth < 6;
             p = p->VpiParent(), depth++)
            std::cout << "    up: " << nm(p) << "\n";
    }
    std::cout << "dangling=" << nd << " bound=" << nb << "\n";
    return 0;
}
