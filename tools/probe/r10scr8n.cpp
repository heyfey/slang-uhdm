// r10scr8n: list one instance's Nets (index, uhdm kind, name, span) so a
// golden/ours size mismatch resolves to the missing or extra element.
//   r10scr8n <file.uhdm> <instance-fullname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmmodule_inst) continue;
        auto* m = (const module_inst*)o;
        if (std::string(m->VpiFullName()) != argv[2]) continue;
        if (m->Nets()) {
            int i = 0;
            for (auto* n : *m->Nets())
                std::cout << "net " << (i++) << " " << UhdmName(n->UhdmType())
                          << " " << n->VpiName() << " @" << n->VpiLineNo() << ":"
                          << n->VpiColumnNo() << "\n";
        }
        if (m->Gen_scope_arrays()) {
            int i = 0;
            for (auto* g : *m->Gen_scope_arrays())
                std::cout << "gsa " << (i++) << " " << g->VpiName() << " @"
                          << g->VpiLineNo() << ":" << g->VpiColumnNo() << "\n";
        }
        return 0;
    }
    return 0;
}
