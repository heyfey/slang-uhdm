// r10uvm82 — MEASUREMENT-ONLY: are a class_defn's Param_assigns' Lhs objects
// exactly the objects in its Parameters vector?
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
    std::set<const class_defn*> seen;
    std::vector<const class_defn*> all;
    std::function<void(const class_defn*)> add = [&](const class_defn* c) {
        if (!c || !seen.insert(c).second) return;
        all.push_back(c);
        if (auto* ts = c->Class_typespecs()) for (auto* t : *ts) if (t) add(t->Class_defn());
        if (auto* dv = c->Deriveds()) for (auto* t : *dv) add(t);
    };
    if (auto* v = d->AllClasses()) for (auto* c : *v) add(c);
    if (auto* v = d->AllPackages()) for (auto* p : *v) if (auto* cs = p->Class_defns()) for (auto* c : *cs) add(c);
    if (auto* v = d->TopPackages()) for (auto* p : *v) if (auto* cs = p->Class_defns()) for (auto* c : *cs) add(c);
    for (auto* c : all) {
        auto* ps = c->Parameters();
        auto* pas = c->Param_assigns();
        if (!ps || !pas) continue;
        std::set<const BaseClass*> pset(ps->begin(), ps->end());
        size_t in = 0, out = 0, nullLhs = 0;
        for (auto* pa : *pas) {
            auto* l = pa->Lhs();
            if (!l) { nullLhs++; continue; }
            if (pset.count(l)) in++; else out++;
        }
        printf("CLS %-40s params=%-4zu pas=%-4zu LhsIN=%zu LhsOUT=%zu LhsNULL=%zu\n",
               std::string(c->VpiName()).c_str(), ps->size(), pas->size(), in, out, nullLhs);
    }
    return 0;
}
