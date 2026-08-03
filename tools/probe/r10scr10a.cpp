// r10scr10a: dump the param_assign RHS TREE (op types, constants, refs) for
// every param_assign whose owning instance fullname + Lhs name matches argv[2]
// as a substring.  Used to see what a diverging census row actually holds.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr10a.cpp -o /tmp/r10scr10_a \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void dump(const any* e, int ind) {
    std::string pad(ind * 2, ' ');
    if (!e) {
        std::cout << pad << "<null>\n";
        return;
    }
    std::cout << pad << UhdmName(e->UhdmType());
    if (!e->VpiName().empty()) std::cout << " name=" << e->VpiName();
    if (e->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)e;
        std::cout << " ct=" << c->VpiConstType() << " sz=" << c->VpiSize()
                  << " v=" << c->VpiValue() << " dc=" << c->VpiDecompile();
    }
    if (e->UhdmType() == uhdmoperation)
        std::cout << " op=" << ((const operation*)e)->VpiOpType();
    std::cout << "  @" << e->VpiFile() << ":" << e->VpiLineNo() << ":"
              << e->VpiColumnNo() << "-" << e->VpiEndLineNo() << ":"
              << e->VpiEndColumnNo() << "\n";
    if (e->UhdmType() == uhdmoperation) {
        auto* o = (const operation*)e;
        if (o->Operands())
            for (auto* c : *o->Operands()) dump(c, ind + 1);
    }
    if (e->UhdmType() == uhdmsys_func_call) {
        auto* o = (const sys_func_call*)e;
        if (o->Tf_call_args())
            for (auto* c : *o->Tf_call_args()) dump(c, ind + 1);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::string pat = argv[2];
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    for (auto& [o, id] : s.AllObjects()) {
        if (!o) continue;
        if (o->UhdmType() != uhdmmodule_inst && o->UhdmType() != uhdmpackage &&
            o->UhdmType() != uhdminterface_inst)
            continue;
        auto* inst = (const instance*)o;
        if (!inst->Param_assigns()) continue;
        for (auto* pa : *inst->Param_assigns()) {
            std::string key = std::string(inst->VpiFullName()) + "|" +
                              (pa->Lhs() ? std::string(pa->Lhs()->VpiName())
                                         : std::string("?"));
            if (key.find(pat) == std::string::npos) continue;
            std::cout << "=== " << key << " (top=" << inst->VpiTop() << ")\n";
            dump(pa->Rhs(), 1);
        }
    }
    return 0;
}
