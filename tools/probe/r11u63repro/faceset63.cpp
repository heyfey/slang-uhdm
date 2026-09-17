// r11u63 — THE LAW'S FACE, by name: does this database hold an ELABORATED
// port-connection hier_path at all?  (parent is a `port`, or an `operation`
// whose own chain reaches a `port`).  Prints FACE <n> when it does.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc, char** argv) {
    Serializer s; auto h = s.Restore(std::filesystem::path(argv[1])); (void)h;
    int n = 0;
    for (auto& [obj, id] : s.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmhier_path) continue;
        for (const BaseClass* p = obj->VpiParent(); p; p = p->VpiParent()) {
            if (p->UhdmType() == uhdmport) { n++; break; }
            if (p->UhdmType() != uhdmoperation) break;
        }
    }
    if (n) std::cout << "FACE " << (argc > 2 ? argv[2] : argv[1]) << " " << n << "\n";
    return 0;
}
