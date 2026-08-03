// r10uvm4inst: for every package (both views), every task_func's vpiInstance
// and vpiParent projected onto WHICH PACKAGE VIEW they name (def vs top).
// A DEF-vs-TOP view pointer is the classic uhdm-cmp "same name, wrong object"
// failure, and the dump cannot show it.
//   r10uvm4inst <file.uhdm> [pkgname]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    std::map<const void*, std::string> tag;
    for (int t = 0; t < 2; t++) {
        auto* l = t ? d->TopPackages() : d->AllPackages();
        if (!l) continue;
        for (auto* p : *l)
            tag[(const void*)p] = std::string(p->VpiName()) + (t ? "#TOP" : "#DEF");
    }
    auto nameOf = [&](const BaseClass* o) -> std::string {
        if (!o) return "<null>";
        auto it = tag.find((const void*)o);
        if (it != tag.end()) return it->second;
        return std::string(UhdmName(o->UhdmType())) + "(" +
               std::string(o->VpiName()) + ")";
    };
    for (int t = 0; t < 2; t++) {
        auto* l = t ? d->TopPackages() : d->AllPackages();
        if (!l) continue;
        for (auto* p : *l) {
            if (argc > 2 && p->VpiName() != argv[2]) continue;
            std::cout << "== " << tag[(const void*)p]
                      << " inst=" << nameOf(p->Instance())
                      << " modinst=" << nameOf(p->Module_inst())
                      << " parent=" << nameOf(p->VpiParent()) << "\n";
            if (p->Task_funcs())
                for (auto* f : *p->Task_funcs()) {
                    std::cout << "  tf '" << f->VpiName()
                              << "' inst=" << nameOf(f->Instance())
                              << " parent=" << nameOf(f->VpiParent()) << "\n";
                    if (f->UhdmType() == uhdmfunction) {
                        auto* rv = ((function*)f)->Return();
                        const typespec* a =
                            rv && rv->Typespec() ? rv->Typespec()->Actual_typespec()
                                                 : nullptr;
                        std::cout << "    ret ts inst="
                                  << (a ? nameOf(a->Instance()) : "<none>")
                                  << "\n";
                    }
                }
            if (p->Class_defns())
                for (auto* c : *p->Class_defns()) {
                    std::cout << "  cls '" << c->VpiName()
                              << "' parent=" << nameOf(c->VpiParent()) << "\n";
                    if (c->Task_funcs())
                        for (auto* f : *c->Task_funcs())
                            std::cout << "    m '" << f->VpiName()
                                      << "' inst=" << nameOf(f->Instance())
                                      << " parent=" << nameOf(f->VpiParent())
                                      << "\n";
                    if (c->Typespecs())
                        for (auto* ts : *c->Typespecs())
                            std::cout << "    cts '" << ts->VpiName()
                                      << "' inst=" << nameOf(ts->Instance())
                                      << "\n";
                }
            if (p->Typespecs())
                for (auto* ts : *p->Typespecs())
                    std::cout << "  ts '" << ts->VpiName()
                              << "' inst=" << nameOf(ts->Instance())
                              << " parent=" << nameOf(ts->VpiParent()) << "\n";
            if (p->Variables())
                for (auto* v : *p->Variables())
                    std::cout << "  var '" << v->VpiName()
                              << "' parent=" << nameOf(v->VpiParent()) << "\n";
        }
    }
    // ...and the same projection for every module's hoisted listing, where a
    // DEF-vs-TOP package pointer shows up as an out-of-order group.
    for (int t = 0; t < 2; t++) {
        auto* l = t ? d->TopModules() : d->AllModules();
        if (!l) continue;
        for (auto* m : *l) {
            std::cout << "== module " << m->VpiName() << (t ? "#TOP" : "#DEF")
                      << "\n";
            if (m->Task_funcs())
                for (auto* f : *m->Task_funcs())
                    std::cout << "  tf '" << f->VpiName()
                              << "' inst=" << nameOf(f->Instance())
                              << " parent=" << nameOf(f->VpiParent()) << "\n";
        }
    }
    if (d->AllClasses()) {
        std::cout << "== design.AllClasses\n";
        for (auto* c : *d->AllClasses())
            std::cout << "  cls '" << c->VpiName()
                      << "' parent=" << nameOf(c->VpiParent()) << "\n";
    }
    if (d->Typespecs()) {
        std::cout << "== design.Typespecs\n";
        for (auto* ts : *d->Typespecs())
            std::cout << "  ts '" << ts->VpiName()
                      << "' inst=" << nameOf(ts->Instance()) << "\n";
    }
    if (d->Task_funcs()) {
        std::cout << "== design\n";
        for (auto* f : *d->Task_funcs())
            std::cout << "  tf '" << f->VpiName()
                      << "' inst=" << nameOf(f->Instance())
                      << " parent=" << nameOf(f->VpiParent()) << "\n";
    }
    return 0;
}
