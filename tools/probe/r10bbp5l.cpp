// r10bbp5l: param_assign LHS-clone census — for every package/module
// param_assign, print the Lhs object's kind/name and whether it carries a
// vpiTypespec (and what it points at).  uhdm-cmp reports a bare
// `ref_typespec < parameter(X) < package(Y)` with no LHS counterpart when a
// def-view Lhs CLONE carries a typespec golden leaves off; the Parameters()
// census cannot see those objects at all.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp5l.cpp -o /tmp/r10bbp5lq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string tsDesc(const ref_typespec* r) {
    if (!r) return "noref";
    auto* a = r->Actual_typespec();
    if (!a) return "refnull";
    return std::string(UhdmName(a->UhdmType())) + " '" +
           std::string(a->VpiName()) + "' @" + std::to_string(a->VpiLineNo()) +
           ":" + std::to_string(a->VpiColumnNo()) + " inst=" +
           (a->Instance() ? std::string(a->Instance()->VpiName())
                          : std::string("-"));
}

template <typename V>
static void doInst(const std::string& tag, V* v) {
    if (!v) return;
    for (auto* p : *v) {
        if (!p->Param_assigns()) continue;
        for (auto* pa : *p->Param_assigns()) {
            auto* l = pa->Lhs();
            if (!l) continue;
            const ref_typespec* rt = nullptr;
            if (l->UhdmType() == uhdmparameter)
                rt = ((const parameter*)l)->Typespec();
            std::cout << tag << "/" << p->VpiName() << " " << l->VpiName()
                      << " lhs=" << UhdmName(l->UhdmType()) << " -> "
                      << tsDesc(rt) << "\n";
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    doInst("ALLPKG", d->AllPackages());
    doInst("TOPPKG", d->TopPackages());
    doInst("ALLMOD", d->AllModules());
    doInst("TOPMOD", d->TopModules());
    return 0;
}
