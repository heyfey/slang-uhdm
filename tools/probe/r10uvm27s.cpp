// r10uvm27s — the task_func BODY-SHAPE census.  For every task_func reachable
// from AllPackages/TopPackages/AllClasses (and every class_defn's Task_funcs),
// print the statement SHAPE: the Stmt kind, and when it is a begin, the ordered
// kinds+names of its Stmts.  This is the projection that makes the
// constructor-body laws (super.new dropping, port-list-shifted statement
// lists) visible without reading an 11 MB dump.
//   r10uvm27s <file.uhdm> [nameFilter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string tn(const BaseClass* o) {
    return std::string(UhdmName(o->UhdmType()));
}

static std::string filt;
static std::set<const task_func*> seen;

static void one(const char* tag, const std::string& owner, const task_func* tf) {
    if (!tf) return;
    std::string nm = std::string(tf->VpiFullName());
    if (nm.empty()) nm = owner + "::" + std::string(tf->VpiName());
    if (!filt.empty() && nm.find(filt) == std::string::npos) return;
    if (!seen.insert(tf).second) return;
    const any* st = tf->Stmt();
    std::cout << tag << " " << nm << " stmt=" << (st ? tn(st) : "<none>");
    if (st && st->UhdmType() == uhdmbegin) {
        const begin* b = (const begin*)st;
        std::cout << " [";
        if (b->Stmts())
            for (auto* c : *b->Stmts())
                std::cout << tn(c) << (c->VpiName().empty()
                                           ? ""
                                           : "(" + std::string(c->VpiName()) + ")")
                          << " ";
        std::cout << "]";
    } else if (st && !st->VpiName().empty()) {
        std::cout << " (" << st->VpiName() << ")";
    }
    std::cout << " io=" << (tf->Io_decls() ? tf->Io_decls()->size() : 0) << "\n";
}

static void doClass(const char* tag, const class_defn* c) {
    if (!c) return;
    std::string owner(c->VpiName());
    if (c->Task_funcs())
        for (auto* tf : *c->Task_funcs()) one(tag, owner, tf);
}

template <typename V>
static void doScope(const char* tag, const V* v) {
    if (!v) return;
    for (auto* p : *v) {
        std::string owner(p->VpiName());
        if (p->Task_funcs())
            for (auto* tf : *p->Task_funcs()) one(tag, owner, tf);
        if (p->Class_defns())
            for (auto* cd : *p->Class_defns()) doClass(tag, cd);
    }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    filt = argc > 2 ? argv[2] : "";
    doScope("DEFPKG", d->AllPackages());
    doScope("ELABPKG", d->TopPackages());
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) doClass("ALLCLS", c);
    doScope("DEFMOD", d->AllModules());
    doScope("ELABMOD", d->TopModules());
    return 0;
}
