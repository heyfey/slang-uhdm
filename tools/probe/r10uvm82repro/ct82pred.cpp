// r10uvm82 — MEASUREMENT-ONLY PREDICTOR, run on PRISTINE databases only.
// § classImportParamStamped82 touches exactly the objects that
// classInheritsContainerImports23 shared by pointer: an entry of a class_defn's
// vpiParameter listing whose vpiParent is a PACKAGE (a body-declared class
// parameter is parented to the class), and the Lhs of an inherited
// param_assign, which is that same package object.
// prints: PRED <n_params> <n_pas> <file>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <functional>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
int main(int argc, char** argv) {
    Serializer s;
    auto restored = s.Restore(std::string(argv[1]));
    design* d = nullptr;
    for (auto h : restored) {
        auto* o = (const BaseClass*)((const uhdm_handle*)h)->object;
        if (o->UhdmType() == uhdmdesign) d = (design*)o;
    }
    if (!d) { printf("PRED -1 -1 %s\n", argv[1]); return 0; }
    std::set<const class_defn*> seen; std::vector<const class_defn*> all;
    std::function<void(const class_defn*)> add = [&](const class_defn* c) {
        if (!c || !seen.insert(c).second) return; all.push_back(c);
        if (auto* ts = c->Class_typespecs()) for (auto* t : *ts) if (t) add(t->Class_defn());
        if (auto* dv = c->Deriveds()) for (auto* t : *dv) add(t);
    };
    if (auto* v = d->AllClasses()) for (auto* c : *v) add(c);
    if (auto* v = d->AllPackages()) for (auto* p : *v) if (auto* cs = p->Class_defns()) for (auto* c : *cs) add(c);
    if (auto* v = d->TopPackages()) for (auto* p : *v) if (auto* cs = p->Class_defns()) for (auto* c : *cs) add(c);
    if (auto* v = d->AllModules()) for (auto* m : *v) if (auto* cs = m->Class_defns()) for (auto* c : *cs) add(c);
    if (auto* v = d->TopModules()) for (auto* m : *v) if (auto* cs = m->Class_defns()) for (auto* c : *cs) add(c);
    size_t np = 0, na = 0;
    for (auto* c : all) {
        if (auto* ps = c->Parameters())
            for (auto* p : *ps)
                if (p && p->UhdmType() == uhdmparameter && p->VpiParent() &&
                    p->VpiParent()->UhdmType() == uhdmpackage)
                    np++;
        if (auto* pas = c->Param_assigns())
            for (auto* pa : *pas)
                if (pa && pa->Lhs() && pa->Lhs()->UhdmType() == uhdmparameter &&
                    pa->VpiParent() && pa->VpiParent()->UhdmType() == uhdmpackage)
                    na++;
    }
    printf("PRED %zu %zu %s\n", np, na, argv[1]);
    return 0;
}
