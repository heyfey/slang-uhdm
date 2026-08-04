// r10fsv3t: TYPESPEC-OBJECT / INSTANCE census.  typespec::Compare recurses
// Instance(), so WHICH typespec object a parameter resolves to -- and which
// package VIEW that object is instanced at -- decides where a whole-design
// Compare walks next.  Surelog shares one typespec object across views; we tend
// to mint a per-view copy.  This prints, per package view (def = uhdmall*,
// elab = uhdmtop*), every parameter / typespec-listing / function-io_decl
// typespec: the object id, its span, and the VIEW its Instance() names.
//   g++ -std=c++17 -I$HOME/.local/include r10fsv3t.cpp -o r10fsv3t \
//       -L$HOME/.local/lib64 -luhdm -lcapnp -lkj
//   r10fsv3t <a.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::map<const BaseClass*, std::string> g_view;

static std::string viewOf(const BaseClass* o) {
    if (!o) return "<none>";
    auto it = g_view.find(o);
    if (it != g_view.end()) return it->second;
    return std::string(UhdmName(o->UhdmType())) + "#" +
           std::to_string(o->UhdmId());
}

static std::string tsdesc(const typespec* t) {
    if (!t) return "<null-ts>";
    return std::string(UhdmName(t->UhdmType())) + " id" +
           std::to_string(t->UhdmId()) + " '" + std::string(t->VpiName()) +
           "' @" + std::to_string(t->VpiLineNo()) + ":" +
           std::to_string(t->VpiColumnNo()) + " inst=" + viewOf(t->Instance());
}

static const typespec* act(const ref_typespec* r) {
    return r ? r->Actual_typespec() : nullptr;
}

static void doInst(const std::string& tag, const instance* in) {
    if (in->Typespecs())
        for (auto* t : *in->Typespecs())
            std::cout << tag << " TSLIST " << tsdesc(t) << "\n";
    if (in->Parameters())
        for (auto* p : *in->Parameters()) {
            const typespec* t = nullptr;
            if (p->UhdmType() == uhdmparameter)
                t = act(((const parameter*)p)->Typespec());
            std::cout << tag << " PARAM " << p->VpiName() << " -> " << tsdesc(t)
                      << "\n";
        }
    if (in->Task_funcs())
        for (auto* tf : *in->Task_funcs()) {
            if (tf->Io_decls())
                for (auto* io : *tf->Io_decls())
                    std::cout << tag << " IODECL " << tf->VpiName() << "."
                              << io->VpiName() << " -> "
                              << tsdesc(act(io->Typespec())) << "\n";
            if (tf->UhdmType() == uhdmfunction)
                std::cout << tag << " FNRET " << tf->VpiName() << " -> "
                          << tsdesc(act(((const function*)tf)->Return()
                                            ? ((const function*)tf)
                                                  ->Return()
                                                  ->Typespec()
                                            : nullptr))
                          << "\n";
        }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    auto label = [&](const char* pfx, auto* v) {
        if (!v) return;
        for (auto* e : *v)
            g_view[e] = std::string(pfx) + ":" + std::string(e->VpiName()) +
                        "#" + std::to_string(e->UhdmId());
    };
    label("DEFPKG", d->AllPackages());
    label("ELABPKG", d->TopPackages());
    label("DEFMOD", d->AllModules());
    label("ELABMOD", d->TopModules());
    auto run = [&](auto* v) {
        if (!v) return;
        for (auto* e : *v) doInst(viewOf(e), e);
    };
    run(d->AllPackages());
    run(d->TopPackages());
    run(d->AllModules());
    run(d->TopModules());
    return 0;
}
