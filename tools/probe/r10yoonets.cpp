// r10yoonets: for every module view (AllModules = def view, TopModules =
// elaborated view) list each net/variable with whether it carries a
// vpiTypespec, so the "port net has no typespec in the elab view" law can be
// read off a golden directly.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10yoonets.cpp -o /tmp/r10yoonets \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void one(const module_inst* m, const char* view) {
    std::cout << view << " " << m->VpiDefName() << " / " << m->VpiFullName()
              << " top=" << m->VpiTop() << "\n";
    if (m->Nets())
        for (auto* n : *m->Nets()) {
            const ref_typespec* rt = n->Typespec();
            std::cout << "  net " << n->VpiName() << "@" << n->VpiLineNo() << ":"
                      << n->VpiColumnNo() << " ts="
                      << (rt ? (rt->Actual_typespec()
                                    ? UhdmName(rt->Actual_typespec()->UhdmType())
                                    : "ref<null>")
                             : "<null>")
                      << " netType=" << n->VpiNetType() << "\n";
        }
    if (m->Variables())
        for (auto* v : *m->Variables()) {
            const ref_typespec* rt = v->Typespec();
            std::cout << "  var " << v->VpiName() << "@" << v->VpiLineNo() << ":"
                      << v->VpiColumnNo() << " ts="
                      << (rt ? (rt->Actual_typespec()
                                    ? UhdmName(rt->Actual_typespec()->UhdmType())
                                    : "ref<null>")
                             : "<null>")
                      << "\n";
        }
    if (m->Modules())
        for (auto* s : *m->Modules()) one(s, view);
}

int main(int argc, char** argv) {
    Serializer ser;
    auto hs = ser.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    std::string want = argc > 2 ? argv[2] : "";
    if (d->AllModules())
        for (auto* m : *d->AllModules())
            if (want.empty() || std::string(m->VpiDefName()).find(want) !=
                                    std::string::npos)
                one(m, "DEF");
    if (d->TopModules())
        for (auto* m : *d->TopModules())
            if (want.empty() || std::string(m->VpiDefName()).find(want) !=
                                    std::string::npos)
                one(m, "TOP");
    return 0;
}
