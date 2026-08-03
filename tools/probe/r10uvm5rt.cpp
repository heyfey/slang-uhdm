// r10uvm5rt: for every package view's Task_funcs listing AND every class_defn
// method, project the function's RETURN typespec onto (uhdm type, name, object
// identity, vpiInstance-as-a-view-tag).  Answers "which copy of which package
// does each return typespec name, and is the typespec object shared between
// listings" — neither of which the decompile dump can show.
//   r10uvm5rt <file.uhdm> [pkgname]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::map<const void*, std::string> tag;
static std::map<const void*, long> ids;

static long idOf(const void* p) {
    auto it = ids.find(p);
    if (it != ids.end()) return it->second;
    long n = (long)ids.size();
    ids[p] = n;
    return n;
}

static std::string nameOf(const BaseClass* o) {
    if (!o) return "<null>";
    auto it = tag.find((const void*)o);
    if (it != tag.end()) return it->second;
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) + ")";
}

static void emitRet(const std::string& where, const task_func* f) {
    if (f->UhdmType() != uhdmfunction) return;
    auto* rv = ((function*)f)->Return();
    if (!rv) { std::cout << where << " | " << f->VpiName() << " | <norv>\n"; return; }
    auto* rt = rv->Typespec();
    const typespec* a = rt ? rt->Actual_typespec() : nullptr;
    std::cout << where << " | " << f->VpiName() << " | rv#" << idOf((const void*)rv)
              << " | ref#" << (rt ? idOf((const void*)rt) : -1) << " | "
              << (a ? UhdmName(a->UhdmType()) : "<none>") << " '"
              << (a ? std::string(a->VpiName()) : std::string()) << "' ts#"
              << (a ? idOf((const void*)a) : -1) << " inst="
              << (a ? nameOf(a->Instance()) : std::string("-")) << "\n";
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    for (int t = 0; t < 2; t++) {
        auto* l = t ? d->TopPackages() : d->AllPackages();
        if (!l) continue;
        for (auto* p : *l)
            tag[(const void*)p] = std::string(p->VpiName()) + (t ? "#TOP" : "#DEF");
        auto* ml = t ? d->TopModules() : d->AllModules();
        if (ml)
            for (auto* m : *ml)
                tag[(const void*)m] = std::string("mod ") + std::string(m->VpiName()) +
                                      (t ? "#TOP" : "#DEF");
    }
    for (int t = 0; t < 2; t++) {
        auto* l = t ? d->TopPackages() : d->AllPackages();
        if (!l) continue;
        for (auto* p : *l) {
            if (argc > 2 && p->VpiName() != argv[2]) continue;
            std::string pv = tag[(const void*)p];
            if (p->Task_funcs())
                for (auto* f : *p->Task_funcs()) emitRet(pv + " tf", f);
            if (p->Class_defns())
                for (auto* c : *p->Class_defns()) {
                    std::string cv = pv + " cls " + std::string(c->VpiName());
                    if (c->Task_funcs())
                        for (auto* f : *c->Task_funcs()) emitRet(cv, f);
                }
        }
    }
    for (int t = 0; t < 2; t++) {
        auto* l = t ? d->TopModules() : d->AllModules();
        if (!l) continue;
        for (auto* m : *l) {
            std::string mv = tag[(const void*)m];
            if (m->Task_funcs())
                for (auto* f : *m->Task_funcs()) emitRet(mv + " tf", f);
        }
    }
    if (d->Task_funcs())
        for (auto* f : *d->Task_funcs()) emitRet("design tf", f);
    return 0;
}
