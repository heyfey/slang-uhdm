// r10uvm6id: object-identity projection for the SCALAR-TYPEDEF naming law.
// For each package/module view, print the pointer id + name of every Typespecs
// listing entry and of the typespec actually bound by each net/variable/
// io_decl/return.  Sharing (which slots point at the SAME object) is the whole
// question here, and no decompile dump shows it.
//   r10uvm6id <file.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::map<const void*, long> ids;
static long idOf(const void* p) {
    if (!p) return -1;
    auto it = ids.find(p);
    if (it != ids.end()) return it->second;
    long n = (long)ids.size() + 1;
    ids[p] = n;
    return n;
}

static void show(const std::string& tag, const typespec* t) {
    if (!t) return;
    std::string tn(UhdmName(t->UhdmType()));
    auto* al = ((typespec*)t)->Typedef_alias();
    std::cout << tag << " -> #" << idOf((const void*)t) << " " << tn << " '"
              << std::string(t->VpiName()) << "' inst=#"
              << idOf((const void*)t->Instance()) << " alias="
              << (al ? (al->Actual_typespec()
                            ? "#" + std::to_string(idOf((const void*)
                                                        al->Actual_typespec()))
                            : std::string("<empty>"))
                     : std::string("-"))
              << "\n";
}

static const typespec* act(const ref_typespec* r) {
    return r ? r->Actual_typespec() : nullptr;
}

template <typename V>
static void doVars(const std::string& tag, const V* v) {
    if (!v) return;
    for (auto* e : *v) show(tag + "/" + std::string(e->VpiName()), act(e->Typespec()));
}

static void doTf(const std::string& tag, const VectorOftask_func* v) {
    if (!v) return;
    for (auto* f : *v) {
        std::string ft = tag + "/" + std::string(f->VpiName());
        if (f->UhdmType() == uhdmfunction && ((function*)f)->Return())
            show(ft + ".ret", act(((function*)f)->Return()->Typespec()));
        if (f->Io_decls())
            for (auto* io : *f->Io_decls())
                show(ft + ".io(" + std::string(io->VpiName()) + ")",
                     act(io->Typespec()));
        doVars(ft + ".var", f->Variables());
    }
}

static void doInst(const std::string& tag, const instance* p) {
    if (p->Typespecs())
        for (auto* t : *p->Typespecs()) show(tag + ".Typespecs", t);
    doVars(tag + ".Variables", p->Variables());
    doVars(tag + ".Nets", p->Nets());
    doTf(tag + ".tf", p->Task_funcs());
    if (p->Class_defns())
        for (auto* c : *p->Class_defns()) {
            std::string ct = tag + ".cls(" + std::string(c->VpiName()) + ")";
            doVars(ct + ".Variables", c->Variables());
            doTf(ct + ".tf", c->Task_funcs());
        }
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    auto run = [&](const char* lbl, auto* v) {
        if (!v) return;
        for (auto* p : *v)
            doInst(std::string(lbl) + "[" + std::string(p->VpiName()) + "]", p);
    };
    run("DEFPKG", d->AllPackages());
    run("ELABPKG", d->TopPackages());
    run("DEFMOD", d->AllModules());
    run("ELABMOD", d->TopModules());
    return 0;
}
