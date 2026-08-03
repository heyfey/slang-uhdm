// r10yoopts: print every module parameter's typespec RANGE BOUNDS in compact
// form (folded constant vs symbolic operation/ref), so the "which untyped
// ranged param bounds does Surelog reduce" law can be read off a golden.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10yoopts.cpp -o /tmp/r10yoopts \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string ex(const any* e) {
    if (!e) return "<null>";
    switch (e->UhdmType()) {
        case uhdmconstant: {
            auto* c = (const constant*)e;
            return "const{" + std::string(c->VpiValue()) + " ct=" +
                   std::to_string(c->VpiConstType()) + " sz=" +
                   std::to_string(c->VpiSize()) + "}";
        }
        case uhdmref_obj:
            return "ref(" + std::string(((const ref_obj*)e)->VpiName()) + "|" +
                   std::string(((const ref_obj*)e)->VpiFullName()) + ")";
        case uhdmoperation: {
            auto* o = (const operation*)e;
            std::string s = "op" + std::to_string(o->VpiOpType()) + "[";
            if (o->Operands())
                for (auto* x : *o->Operands()) s += ex(x) + " ";
            return s + "]";
        }
        default: return UhdmName(e->UhdmType());
    }
}

static void rng(const typespec* ts) {
    const VectorOfrange* rv = nullptr;
    if (!ts) { std::cout << " ts=<null>"; return; }
    std::cout << " " << UhdmName(ts->UhdmType()) << "@" << ts->VpiLineNo() << ":"
              << ts->VpiColumnNo() << "-" << ts->VpiEndLineNo() << ":"
              << ts->VpiEndColumnNo();
    switch (ts->UhdmType()) {
        case uhdmint_typespec: rv = ((const int_typespec*)ts)->Ranges(); break;
        case uhdmlogic_typespec: rv = ((const logic_typespec*)ts)->Ranges(); break;
        case uhdmbit_typespec: rv = ((const bit_typespec*)ts)->Ranges(); break;
        case uhdmpacked_array_typespec:
            rv = ((const packed_array_typespec*)ts)->Ranges();
            break;
        default: break;
    }
    if (!rv) { std::cout << " [no ranges]"; return; }
    for (auto* r : *rv)
        std::cout << " [" << ex(r->Left_expr()) << " : " << ex(r->Right_expr())
                  << "]";
}

static void one(const module_inst* m, const char* view) {
    std::cout << view << " " << m->VpiDefName() << " / " << m->VpiFullName()
              << " top=" << m->VpiTop() << "\n";
    if (m->Parameters())
        for (auto* p : *m->Parameters()) {
            std::cout << "  param " << p->VpiName();
            const ref_typespec* rt =
                p->UhdmType() == uhdmparameter ? ((const parameter*)p)->Typespec()
                                               : nullptr;
            rng(rt ? rt->Actual_typespec() : nullptr);
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
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) {
            std::cout << "PKG " << p->VpiName() << " top=" << p->VpiTop() << "\n";
            if (p->Parameters())
                for (auto* pa : *p->Parameters()) {
                    std::cout << "  param " << pa->VpiName();
                    const ref_typespec* rt =
                        pa->UhdmType() == uhdmparameter
                            ? ((const parameter*)pa)->Typespec()
                            : nullptr;
                    rng(rt ? rt->Actual_typespec() : nullptr);
                    std::cout << "\n";
                }
        }
    return 0;
}
