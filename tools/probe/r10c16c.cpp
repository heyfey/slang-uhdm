// r10c16c: design-level package/module vector census — name, VpiTop, and the
// sizes of the per-package vectors uhdm-cmp walks, for BOTH AllPackages and
// TopPackages.  A `RHS: <null>` from uhdm-cmp against a package LHS is a
// VECTOR SIZE mismatch somewhere in these lists; this prints which one.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10c16c.cpp -o /tmp/r10c16cq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

template <typename V>
static size_t sz(V* v) {
    return v ? v->size() : 0;
}

static void row(const std::string& tag, package* p) {
    std::cout << tag << " " << p->VpiName() << " top=" << p->VpiTop()
              << " params=" << sz(p->Parameters())
              << " passign=" << sz(p->Param_assigns())
              << " typespecs=" << sz(p->Typespecs())
              << " taskfunc=" << sz(p->Task_funcs())
              << " variables=" << sz(p->Variables())
              << " nets=" << sz(p->Nets())
              << " classdefs=" << sz(p->Class_defns())
              << " named_events=" << sz(p->Named_events())
              << " propdecls=" << sz(p->Property_decls()) << "\n";
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    std::vector<vpiHandle> restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    std::cout << "allPackages=" << sz(d->AllPackages())
              << " topPackages=" << sz(d->TopPackages())
              << " allModules=" << sz(d->AllModules())
              << " topModules=" << sz(d->TopModules())
              << " allClasses=" << sz(d->AllClasses())
              << " allInterfaces=" << sz(d->AllInterfaces())
              << " allPrograms=" << sz(d->AllPrograms())
              << " allUdps=" << sz(d->AllUdps()) << "\n";
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) row("ALL", p);
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) row("TOP", p);
    auto mrow = [&](const std::string& tag, module_inst* m) {
        std::cout << tag << " " << m->VpiName() << " top=" << m->VpiTop()
                  << " params=" << sz(m->Parameters())
                  << " passign=" << sz(m->Param_assigns())
                  << " typespecs=" << sz(m->Typespecs()) << "\n";
        if (m->Typespecs())
            for (auto* t : *m->Typespecs())
                std::cout << "   ts " << UhdmName(t->UhdmType()) << " '"
                          << t->VpiName() << "' @" << t->VpiLineNo() << ":"
                          << t->VpiColumnNo() << " inst="
                          << (t->Instance() ? std::string(t->Instance()->VpiName())
                                            : std::string("-"))
                          << "\n";
    };
    if (d->AllModules())
        for (auto* m : *d->AllModules()) mrow("ALLMOD", m);
    if (d->TopModules())
        for (auto* m : *d->TopModules()) mrow("TOPMOD", m);
    return 0;
}
