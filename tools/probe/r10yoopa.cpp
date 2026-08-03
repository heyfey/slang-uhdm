// r10yoopa: print every module param_assign's Rhs constant and the TYPESPEC
// its ref_typespec resolves to (kind + location), in both views — the
// projection needed to decode "which elab param folds keep the located
// declaration typespec and which take the bare loc-less vector one".
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10yoopa.cpp -o /tmp/r10yoopa \
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
    if (m->Param_assigns())
        for (auto* pa : *m->Param_assigns()) {
            std::cout << "  pa " << (pa->Lhs() ? pa->Lhs()->VpiName() : "?");
            auto* r = pa->Rhs();
            if (!r) { std::cout << " <no rhs>\n"; continue; }
            std::cout << " rhs=" << UhdmName(r->UhdmType());
            if (r->UhdmType() == uhdmconstant) {
                auto* c = (const constant*)r;
                std::cout << "{" << c->VpiValue() << " ct=" << c->VpiConstType()
                          << " sz=" << c->VpiSize() << " dec='"
                          << c->VpiDecompile() << "'}";
                auto* rt = c->Typespec();
                if (!rt) std::cout << " ts=<null>";
                else if (!rt->Actual_typespec()) std::cout << " ts=ref<null>";
                else {
                    auto* a = rt->Actual_typespec();
                    std::cout << " ts=" << UhdmName(a->UhdmType()) << "@"
                              << a->VpiLineNo() << ":" << a->VpiColumnNo()
                              << " tsPar="
                              << (a->VpiParent()
                                      ? UhdmName(a->VpiParent()->UhdmType())
                                      : "<null>");
                }
            }
            std::cout << "\n";
        }
    if (m->Modules())
        for (auto* s : *m->Modules()) one(s, view);
}

int main(int argc, char** argv) {
    Serializer ser;
    auto hs = ser.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)hs[0])->object;
    std::string want = argc > 2 ? argv[2] : "";
    auto ok = [&](const module_inst* m) {
        return want.empty() ||
               std::string(m->VpiDefName()).find(want) != std::string::npos;
    };
    if (d->AllModules())
        for (auto* m : *d->AllModules()) if (ok(m)) one(m, "DEF");
    if (d->TopModules())
        for (auto* m : *d->TopModules()) if (ok(m)) one(m, "TOP");
    return 0;
}
