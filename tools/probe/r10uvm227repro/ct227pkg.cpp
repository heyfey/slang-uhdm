// r10uvm227 — THE PACKAGE TOPOLOGY READER.  MEASUREMENT ONLY; `uhdm-cmp` is
// the sole judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The head this pass owns is a CLONE-ROUTING head: both databases carry FOUR
// copies of the package free function `uvm_pkg::uvm_report_enabled` (two under
// each of the two `uvm_pkg` objects and the two `svaunit_pkg` objects), and the
// judge stopped because the interface's `func_call` points at a DIFFERENT one
// of them on each side.  To state the law one first has to know what the two
// package objects per name ARE — which of them the design lists as a TOP
// package, which as an ALL package, and in what order.  This probe prints
// exactly that, plus, for every `package` object, the clone of a named function
// it holds.
//
// build: g++ -O2 -std=c++17 ct227pkg.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct227pkg
// usage: ct227pkg <golden.uhdm> <ours.uhdm> [<function name substring>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[600];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%u:%u#%u", kind.c_str(), nm.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->UhdmId());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct227pkg <golden> <ours> [fn]\n"); return 2; }
    const char* fn = argc > 3 ? argv[3] : nullptr;
    printf("# ct227pkg MEASUREMENT-ONLY — uhdm-cmp remains the sole judge\n");
    for (int side = 0; side < 2; ++side) {
        Serializer S;
        if (S.Restore(std::string(argv[side + 1])).empty()) {
            printf("RESTORE_FAIL %s\n", argv[side + 1]);
            return 3;
        }
        printf("---- %s : %s ----\n", side ? "OURS" : "GOLDEN", argv[side + 1]);
        const design* d = topDesign(S);
        if (!d) { printf("NO_DESIGN\n"); continue; }
        auto show = [&](const char* tag, const VectorOfpackage* v) {
            printf("  %s %s size=%zu\n", tag, v ? "present" : "NULL",
                   v ? v->size() : 0);
            if (!v) return;
            for (auto* p : *v) printf("    %s\n", ident(p).c_str());
        };
        show("TopPackages", d->TopPackages());
        show("AllPackages", d->AllPackages());
        // every package object in the database, in AllObjects order, with the
        // named function clone it holds
        printf("  ALL `package` OBJECTS (AllObjects order):\n");
        for (auto& kv : S.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || o->UhdmType() != uhdmpackage) continue;
            const package* p = (const package*)o;
            printf("    %s  Task_funcs=%zu\n", ident(p).c_str(),
                   p->Task_funcs() ? p->Task_funcs()->size() : 0);
            if (!fn || !p->Task_funcs()) continue;
            for (auto* t : *p->Task_funcs())
                if (std::string(t->VpiName()).find(fn) != std::string::npos)
                    printf("        holds %s\n", ident(t).c_str());
        }
    }
    return 0;
}
