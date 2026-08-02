// r10sc4po: print the uhdm-dump subtree of ONE object selected by
// AllModules[<defname>].<vector>[<index>], so two designs can be diffed at
// exactly the object a Compare walk failed on (uhdm-dump alone prints the
// whole design and buries it).
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10sc4po.cpp -o /tmp/r10sc4po \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 5) {
        std::cerr << "usage: r10sc4po <file.uhdm> <defname> <ports|nets|params|typespecs> <idx>\n";
        return 1;
    }
    Serializer ser;
    auto hs = ser.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    std::string want = argv[2], vec = argv[3];
    int idx = atoi(argv[4]);
    for (auto* m : *d->AllModules()) {
        if (std::string(m->VpiDefName()) != want) continue;
        const BaseClass* obj = nullptr;
        if (vec == "ports" && m->Ports() && idx < (int)m->Ports()->size())
            obj = (*m->Ports())[idx];
        else if (vec == "nets" && m->Nets() && idx < (int)m->Nets()->size())
            obj = (*m->Nets())[idx];
        else if (vec == "params" && m->Parameters() && idx < (int)m->Parameters()->size())
            obj = (*m->Parameters())[idx];
        else if (vec == "typespecs" && m->Typespecs() && idx < (int)m->Typespecs()->size())
            obj = (*m->Typespecs())[idx];
        if (!obj) { std::cerr << "no such object\n"; return 2; }
        uhdm_handle h(obj->UhdmType(), obj);
        visit_object((vpiHandle)&h, std::cout);
        return 0;
    }
    std::cerr << "no such module\n";
    return 3;
}
