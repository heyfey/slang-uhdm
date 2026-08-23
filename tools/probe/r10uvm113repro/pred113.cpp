// r10uvm113 — A-PRIORI MOVER PREDICTOR for § classOwnLateMethodBindsPkgFn113.
//
// Evaluates the LAW'S OWN PREDICATE on a PRISTINE database, so the mover set can
// be named BEFORE the patched sweep runs.  MEASUREMENT ONLY.
//
// The predicate mirrors the patched arm exactly: a reachable `func_call` with
// NO `vpiFunction`, written inside a CLASS METHOD body, whose enclosing PACKAGE
// VIEW lists a `function` of the same VpiName.
//
//   CELL <TAB> view <TAB> package <TAB> class/method <TAB> callname
//   CELLS <n>            <- the count this database is predicted to move by
//   MAYBE <n>            <- class NOT under a package (a $unit or module class):
//                           some package in the design has the name, but the
//                           import is invisible in UHDM, and the module road
//                           does not bind today (arms d2/d3) — reported apart
//                           so it can never be mistaken for a prediction.
//
// build: g++ -O2 -std=c++17 pred113.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred113
// usage: pred113 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: pred113 <db.uhdm>\n"); return 2; }
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { printf("CELLS ERR\n"); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;

    // package view -> set of FUNCTION names it lists
    std::map<const BaseClass*, std::set<std::string>> pkgFns;
    std::set<std::string> anyPkgFn;
    auto scan = [&](const package* p) {
        if (!p) return;
        auto& set = pkgFns[(const BaseClass*)p];
        if (p->Task_funcs())
            for (auto* tf : *p->Task_funcs())
                if (tf->UhdmType() == uhdmfunction) {
                    set.insert(std::string(tf->VpiName()));
                    anyPkgFn.insert(std::string(tf->VpiName()));
                }
    };
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) scan(p);
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) scan(p);

    size_t cells = 0, maybe = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (obj->UhdmType() != uhdmfunc_call) continue;
        const func_call* fc = (const func_call*)(const any*)obj;
        if (fc->Function()) continue;
        const std::string nm(fc->VpiName());
        if (nm.empty() || nm.find("::") != std::string::npos) continue;
        const BaseClass* cls = nullptr; const BaseClass* pkg = nullptr;
        const BaseClass* meth = nullptr; const BaseClass* root = nullptr;
        for (const BaseClass* p = obj->VpiParent(); p; p = p->VpiParent()) {
            UHDM_OBJECT_TYPE t = p->UhdmType();
            if (!meth && (t == uhdmfunction || t == uhdmtask)) meth = p;
            if (!cls && t == uhdmclass_defn) cls = p;
            if (cls && !pkg && t == uhdmpackage) pkg = p;
            root = p;
        }
        if (!root || root->UhdmType() != uhdmdesign) continue;  // unreachable
        if (!cls || !meth) continue;
        if (pkg) {
            auto it = pkgFns.find(pkg);
            if (it != pkgFns.end() && it->second.count(nm)) {
                cells++;
                printf("CELL\t%s\t%s\t%s::%s\t%s\n",
                       "PKG", std::string(pkg->VpiName()).c_str(),
                       std::string(cls->VpiName()).c_str(),
                       std::string(meth->VpiName()).c_str(), nm.c_str());
            }
        } else if (anyPkgFn.count(nm)) {
            maybe++;
        }
    }
    printf("CELLS %zu\nMAYBE %zu\n", cells, maybe);
    return 0;
}
