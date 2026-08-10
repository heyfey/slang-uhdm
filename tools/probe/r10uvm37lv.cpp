// r10uvm37lv — foreach LOOP-VARIABLE identity inside a WILDCARD-IMPORT CLONE.
//
// r10uvm28g prints an Actual_group's KIND:NAME, which cannot distinguish "the
// body reference binds the loop's own listing object" from "it binds a second
// object of the same kind and name".  Pass 37's whole § pkgCloneLoopVarBind
// question is exactly that distinction, so this probe prints the serializer
// OBJECT ID of every foreach_stmt's Variable() and VpiLoopVars() entries and
// of every reference's Actual_group, under the same VIEW tag r10uvm28g uses.
//   r10uvm37lv <file.uhdm>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::map<const BaseClass*, std::string> g_view;
static std::map<const BaseClass*, unsigned long> g_id;

template <typename S>
static void tagScope(const S* p, const char* tag) {
    auto add = [&](const BaseClass* o) {
        auto it = g_view.find(o);
        if (it == g_view.end())
            g_view[o] = tag;
        else if (it->second != tag)
            it->second = "BOTH";
    };
    if (p->Task_funcs())
        for (auto* f : *p->Task_funcs()) add(f);
    if (p->Class_defns())
        for (auto* c : *p->Class_defns())
            if (c->Task_funcs())
                for (auto* f : *c->Task_funcs()) add(f);
}

static std::string tag(const BaseClass* o) {
    if (!o) return "-";
    return std::string(UhdmName(o->UhdmType())) + ":" +
           std::string(o->VpiName()) + "#" + std::to_string(g_id[o]);
}

int main(int argc, char** argv) {
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) tagScope(p, "DEFPKG");
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) tagScope(p, "ELABPKG");
    if (d->AllModules())
        for (auto* m : *d->AllModules()) tagScope(m, "DEFMOD");
    if (d->TopModules())
        for (auto* m : *d->TopModules()) tagScope(m, "ELABMOD");
    for (auto& [o, id] : s.AllObjects()) g_id[o] = (unsigned long)id;
    auto owner = [](const BaseClass* o) {
        const BaseClass* p = o->VpiParent();
        for (int i = 0; p && i < 32; ++i) {
            if (auto* tf = any_cast<const task_func*>(p)) {
                auto vi = g_view.find(tf);
                return (vi == g_view.end() ? std::string("?") : vi->second) +
                       " " + std::string(tf->VpiFullName());
            }
            p = p->VpiParent();
        }
        return std::string("<none>");
    };
    std::vector<std::string> out;
    for (auto& [o, id] : s.AllObjects()) {
        if (auto* f = any_cast<const foreach_stmt*>(o)) {
            std::string l = owner(f) + " | foreach#" + std::to_string(id) +
                            " " + std::to_string(f->VpiLineNo()) + " var=" +
                            tag(f->Variable());
            if (f->VpiLoopVars())
                for (auto* v : *f->VpiLoopVars()) l += " lv=" + tag(v);
            out.push_back(l);
        }
        const any* act = nullptr;
        if (auto* r = any_cast<const ref_obj*>(o)) act = r->Actual_group();
        else if (auto* r = any_cast<const ref_var*>(o)) act = r->Actual_group();
        else if (auto* r = any_cast<const bit_select*>(o)) act = r->Actual_group();
        else continue;
        out.push_back(owner(o) + " | ref " + tag(o) + " " +
                      std::to_string(o->VpiLineNo()) + ":" +
                      std::to_string(o->VpiColumnNo()) + " -> " + tag(act));
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) std::cout << l << "\n";
    return 0;
}
