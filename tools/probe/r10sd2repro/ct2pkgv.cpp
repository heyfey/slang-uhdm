// r10sd2 — THE DESIGN'S PACKAGE VECTORS, READ OUT OF ONE DATABASE.
//
// The head this pass owns is `LHS: <null>` / `RHS: package uvm_pkg` under the
// DESIGN object, and the standing law is: a missing/surplus VECTOR ENTRY prints
// exactly like a missing singular object.  So before any theory, both sides'
// FULL package vectors get censused BY NAME AND ORDER — that is what this tool
// prints, one line per entry, for `AllPackages` and `TopPackages` separately.
//
// It also prints, per entry, the child-collection SIZES that a package's
// Compare walks, so a size divergence inside a shared entry is visible without
// running a 1.4M-line cmp.
//
// build: g++ -O2 -std=c++17 ct2pkgv.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2pkgv
// usage: ct2pkgv <file.uhdm> [tag]
#include <uhdm/uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>

using namespace UHDM;

template <typename V>
static int sz(V* v) {
    return v ? (int)v->size() : -1;
}

static void dumpvec(const std::string& tag, const std::string& which,
                    VectorOfpackage* v) {
    if (!v) {
        std::cout << tag << " " << which << " NULLVEC\n";
        return;
    }
    std::cout << tag << " " << which << " size=" << v->size() << "\n";
    for (size_t i = 0; i < v->size(); i++) {
        const package* p = (*v)[i];
        std::cout << tag << " " << which << "[" << i << "] name=" << p->VpiName()
                  << " defname=" << p->VpiDefName()
                  << " full=" << p->VpiFullName() << " file="
                  << std::filesystem::path(std::string(p->VpiFile())).filename().string()
                  << " @" << p->VpiLineNo() << ":" << p->VpiColumnNo() << "-"
                  << p->VpiEndLineNo() << ":" << p->VpiEndColumnNo()
                  << " top=" << p->VpiTop() << " parent="
                  << (p->VpiParent() ? UhdmName(p->VpiParent()->UhdmType())
                                     : std::string("<null>"))
                  // scope::Compare order (-1 means the vector pointer is NULL,
                  // which is NOT the same as 0 and is the whole point here)
                  << " Property_decls=" << sz(p->Property_decls())
                  << " Sequence_decls=" << sz(p->Sequence_decls())
                  << " Concurrent_assertions=" << sz(p->Concurrent_assertions())
                  << " Named_events=" << sz(p->Named_events())
                  << " Named_event_arrays=" << sz(p->Named_event_arrays())
                  << " Variables=" << sz(p->Variables())
                  << " Virtual_interface_vars=" << sz(p->Virtual_interface_vars())
                  << " Logic_vars=" << sz(p->Logic_vars())
                  << " Array_vars=" << sz(p->Array_vars())
                  << " Array_var_mems=" << sz(p->Array_var_mems())
                  << " Parameters=" << sz(p->Parameters())
                  << " Param_assigns=" << sz(p->Param_assigns())
                  << " Scopes=" << sz(p->Scopes())
                  << " Typespecs=" << sz(p->Typespecs())
                  << " Instance_items=" << sz(p->Instance_items())
                  << " Let_decls=" << sz(p->Let_decls())
                  << " Attributes=" << sz(p->Attributes())
                  // instance::Compare order
                  << " Programs=" << sz(p->Programs())
                  << " Program_arrays=" << sz(p->Program_arrays())
                  << " Class_defns=" << sz(p->Class_defns())
                  << " Task_funcs=" << sz(p->Task_funcs())
                  << " Nets=" << sz(p->Nets())
                  << " Array_nets=" << sz(p->Array_nets())
                  << " Spec_params=" << sz(p->Spec_params())
                  << " Assertions=" << sz(p->Assertions())
                  << " Module_inst=" << (p->Module_inst() ? 1 : 0)
                  << " Instance=" << (p->Instance() ? 1 : 0)
                  << " vpiUnit=" << p->VpiUnit()
                  << " endLabel=" << p->VpiEndLabel() << "\n";
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: ct2pkgv <file.uhdm> [tag]\n";
        return 2;
    }
    std::string tag = argc > 2 ? argv[2] : "DB";
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) {
        std::cerr << "RESTORE_FAIL " << argv[1] << "\n";
        return 3;
    }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::cout << tag << " design name=" << d->VpiName()
              << " Param_assigns=" << sz(d->Param_assigns())
              << " Parameters=" << sz(d->Parameters())
              << " Typespecs=" << sz(d->Typespecs())
              << " Task_funcs=" << sz(d->Task_funcs())
              << " AllModules=" << sz(d->AllModules())
              << " TopModules=" << sz(d->TopModules())
              << " AllClasses=" << sz(d->AllClasses())
              << " AllInterfaces=" << sz(d->AllInterfaces())
              << " AllPrograms=" << sz(d->AllPrograms())
              << " AllUdps=" << sz(d->AllUdps())
              << " Let_decls=" << sz(d->Let_decls()) << "\n";
    dumpvec(tag, "AllPackages", d->AllPackages());
    dumpvec(tag, "TopPackages", d->TopPackages());
    return 0;
}
