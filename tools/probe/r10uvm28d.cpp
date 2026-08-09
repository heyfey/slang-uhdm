// r10uvm28d — SUBTREE dump.  uhdm-dump prints an 11 MB text for the UVM
// databases, which is unreadable and unnormalisable; every previous pass paid
// for that with `grep`-around-line-numbers archaeology.  This prints the
// uhdm-dump text of exactly ONE object — a named task_func of a named
// class_defn (or a named package/class task_func) — by handing that object to
// UHDM's own `visit_object`.  Golden and ours can then be diffed directly.
//   r10uvm28d <file.uhdm> <className|-> <tfName>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string g_cls, g_tf;
static bool g_done = false;

static void emit(Serializer& s, const BaseClass* o) {
    if (g_done) return;
    g_done = true;
    vpiHandle h = NewVpiHandle((const any*)o);
    visit_object(h, std::cout);
}

static void doClass(Serializer& s, const class_defn* c) {
    if (!c || g_done) return;
    if (g_cls != "-" && std::string(c->VpiName()) != g_cls) return;
    if (c->Task_funcs())
        for (auto* tf : *c->Task_funcs())
            if (std::string(tf->VpiName()) == g_tf) return emit(s, tf);
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    g_cls = argv[2];
    g_tf = argv[3];
    for (auto* v : {d->AllPackages(), d->TopPackages()}) {
        if (!v) continue;
        for (auto* p : *v) {
            if (g_cls == "-" && p->Task_funcs())
                for (auto* tf : *p->Task_funcs())
                    if (std::string(tf->VpiName()) == g_tf) {
                        emit(s, tf);
                        return 0;
                    }
            if (p->Class_defns())
                for (auto* c : *p->Class_defns()) doClass(s, c);
            if (g_done) return 0;
        }
    }
    if (!g_done) std::cerr << "not found\n";
    return 0;
}
