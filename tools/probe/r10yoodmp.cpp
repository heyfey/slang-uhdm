// r10yoodmp: dump the uhdm-dump subtree of one object addressed as
//   <all|top>[<defname>].<vector>[<index>]
// so the two designs can be diffed at exactly the object a Compare walk
// failed on.  Adds the vectors r10sc4po lacks (cont_assigns, process,
// task_funcs, param_assigns, variables).
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10yoodmp.cpp -o /tmp/r10yoodmp \
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
    if (argc < 6) {
        std::cerr << "usage: r10yoodmp <file.uhdm> <all|top> <defname> "
                     "<ports|nets|params|typespecs|contassigns|process|"
                     "taskfuncs|paramassigns|variables> <idx>\n";
        return 1;
    }
    Serializer ser;
    auto hs = ser.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    bool top = std::string(argv[2]) == "top";
    std::string want = argv[3], vec = argv[4];
    int idx = atoi(argv[5]);
    auto* mods = top ? d->TopModules() : d->AllModules();
    if (!mods) return 3;
    for (auto* m : *mods) {
        if (std::string(m->VpiDefName()) != want) continue;
        const BaseClass* obj = nullptr;
        auto pick = [&](auto* v) {
            if (v && idx < (int)v->size()) obj = (*v)[idx];
        };
        if (vec == "ports") pick(m->Ports());
        else if (vec == "nets") pick(m->Nets());
        else if (vec == "params") pick(m->Parameters());
        else if (vec == "typespecs") pick(m->Typespecs());
        else if (vec == "contassigns") pick(m->Cont_assigns());
        else if (vec == "process") pick(m->Process());
        else if (vec == "taskfuncs") pick(m->Task_funcs());
        else if (vec == "paramassigns") pick(m->Param_assigns());
        else if (vec == "variables") pick(m->Variables());
        if (!obj) { std::cerr << "no such object\n"; return 2; }
        uhdm_handle h(obj->UhdmType(), obj);
        visit_object((vpiHandle)&h, std::cout);
        return 0;
    }
    std::cerr << "no such module\n";
    return 3;
}
