// r10uvm56repro/retown.cpp — for every `function` object in a database, print
// the facts a RETURN-NAME binding could plausibly key on, next to how many of
// its own return-name references carry a `vpiActual`.
//
// One line per function object:
//   <view> <fullname> | ret=<kind-of-vpiReturn-or-NONE> automatic=<0/1>
//     static=<vpiAutomatic/vpiStatic raw> virt=<vpiVirtual> refs=<n>
//     bound=<n>
//
// The point: golden leaves EVERY return-name reference of a handful of
// routines unbound while binding ~218 elsewhere, and the campaign's
// view-tag census cannot separate them (the tag is unstable across tests).
// This probe reads the FUNCTION object instead of the listing that holds it.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::map<const BaseClass*, std::string> g_view;

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

static std::string lastSeg(std::string s) {
    auto p = s.rfind("::");
    if (p != std::string::npos) s = s.substr(p + 2);
    p = s.rfind('.');
    if (p != std::string::npos) s = s.substr(p + 1);
    return s;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: retown <file.uhdm>\n"; return 2; }
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

    // Per function: return-name refs found under it, and how many are bound.
    std::map<const function*, std::pair<int, int>> tally;
    std::map<const function*, std::set<std::string>> boundKinds;
    for (auto& [o, id] : s.AllObjects()) {
        const any* act = nullptr;
        if (auto* r = any_cast<const ref_obj*>(o)) act = r->Actual_group();
        else if (auto* r = any_cast<const ref_var*>(o)) act = r->Actual_group();
        else if (auto* r = any_cast<const bit_select*>(o)) act = r->Actual_group();
        else continue;
        const function* fn = nullptr;
        const BaseClass* p = o->VpiParent();
        for (int i = 0; p && i < 32; ++i) {
            if (auto* f = any_cast<const function*>(p)) { fn = f; break; }
            if (any_cast<const task*>(p)) break;
            p = p->VpiParent();
        }
        if (!fn) continue;
        if (std::string(o->VpiName()) != lastSeg(std::string(fn->VpiFullName())))
            continue;
        auto& t = tally[fn];
        t.first++;
        if (act) {
            t.second++;
            boundKinds[fn].insert(std::string(UhdmName(act->UhdmType())));
        }
    }
    std::vector<std::string> out;
    for (auto& [fn, t] : tally) {
        auto vi = g_view.find(fn);
        std::string view = vi == g_view.end() ? "?" : vi->second;
        const variables* rv = fn->Return();
        std::string rk = rv ? std::string(UhdmName(rv->UhdmType())) : "NONE";
        std::string rn = rv ? std::string(rv->VpiName()) : "-";
        // The class (if any) the function belongs to, and whether that class
        // carries Parameters (a specialization of a parameterized class).
        std::string cls = "-";
        int clsParams = -1;
        for (const BaseClass* p = fn->VpiParent(); p; p = p->VpiParent())
            if (auto* c = any_cast<const class_defn*>(p)) {
                cls = std::string(c->VpiName());
                clsParams = c->Parameters() ? (int)c->Parameters()->size() : 0;
                break;
            }
        char buf[64];
        snprintf(buf, sizeof(buf), "refs=%2d bound=%2d", t.first, t.second);
        out.push_back(std::string(buf) + " | " + view + " | " +
                      std::string(fn->VpiFullName()) + " | ret=" + rk +
                      "(" + rn + ")" +
                      " automatic=" + std::to_string((int)fn->VpiAutomatic()) +
                      " virtual=" + std::to_string((int)fn->VpiVirtual()) +
                      " visibility=" + std::to_string((int)fn->VpiVisibility()) +
                      " method=" + std::to_string((int)fn->VpiMethod()) +
                      " dpi=" + std::to_string((int)fn->VpiDPIContext()) +
                      " cls=" + cls + " clsParams=" + std::to_string(clsParams) +
                      " stmt=" + (fn->Stmt() ? UhdmName(fn->Stmt()->UhdmType()) : "NONE"));
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) std::cout << l << "\n";
    return 0;
}
