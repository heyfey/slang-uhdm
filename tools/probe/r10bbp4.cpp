// r10bbp4: enum-typespec ALIAS census — for every enum_typespec reachable
// through the design's package/module Typespecs lists, print id, name,
// Instance, location, Base_typespec actual, and the Typedef_alias link (the
// field uhdm-cmp recurses but uhdm-dump abbreviates once a repeat visit is
// detected).  Used to decode the enum-alias clone (typedef fwd_e rev_e).
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp4.cpp -o /tmp/r10bbp4q \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string loc(const any* o) {
    if (!o) return "-";
    return "@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

static void tsRow(const std::string& tag, typespec* t) {
    std::cout << tag << " " << UhdmName(t->UhdmType()) << " '" << t->VpiName()
              << "' #" << t->UhdmId() << " " << loc(t)
              << " inst=" << (t->Instance() ? std::string(t->Instance()->VpiName()) : "-")
              << " parent="
              << (t->VpiParent() ? std::string(t->VpiParent()->VpiName()) : "-");
    ref_typespec* alias = nullptr;
    ref_typespec* base = nullptr;
    if (t->UhdmType() == uhdmenum_typespec) {
        auto* e = (enum_typespec*)t;
        alias = e->Typedef_alias();
        base = e->Base_typespec();
    }
    else if (t->UhdmType() == uhdmlogic_typespec) {
        auto* l = (logic_typespec*)t;
        alias = l->Typedef_alias();
    }
    else if (t->UhdmType() == uhdmstruct_typespec) {
        alias = ((struct_typespec*)t)->Typedef_alias();
    }
    if (base) {
        auto* a = base->Actual_typespec();
        std::cout << " base=ref#" << base->UhdmId() << "{" << base->VpiFullName()
                  << "}->"
                  << (a ? std::string(UhdmName(a->UhdmType())) + "#" +
                              std::to_string(a->UhdmId()) + loc(a) + "/inst=" +
                              (a->Instance()
                                   ? std::string(a->Instance()->VpiName())
                                   : std::string("-"))
                        : std::string("null"));
    }
    if (alias) {
        auto* a = alias->Actual_typespec();
        std::cout << " ALIAS=ref#" << alias->UhdmId() << "{"
                  << alias->VpiFullName() << "}->"
                  << (a ? std::string(UhdmName(a->UhdmType())) + " '" +
                              std::string(a->VpiName()) + "'#" +
                              std::to_string(a->UhdmId()) + loc(a)
                        : std::string("null"));
    }
    std::cout << "\n";
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer ser;
    std::vector<vpiHandle> restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    auto walk = [&](const std::string& tag, VectorOftypespec* v) {
        if (!v) return;
        for (auto* t : *v)
            if (filt.empty() || std::string(t->VpiName()).find(filt) !=
                                    std::string::npos)
                tsRow(tag, t);
    };
    auto pkgs = [&](const std::string& tag, VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v) walk(tag + "/" + std::string(p->VpiName()),
                                p->Typespecs());
    };
    pkgs("ALLPKG", d->AllPackages());
    pkgs("TOPPKG", d->TopPackages());
    if (d->AllModules())
        for (auto* m : *d->AllModules())
            walk("ALLMOD/" + std::string(m->VpiName()), m->Typespecs());
    if (d->TopModules())
        for (auto* m : *d->TopModules())
            walk("TOPMOD/" + std::string(m->VpiName()), m->Typespecs());
    return 0;
}
