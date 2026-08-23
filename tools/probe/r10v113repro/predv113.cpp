// r10v113 — INDEPENDENT A-PRIORI MOVER PREDICTOR, evaluated on PRISTINE
// databases only.  A database moves iff it holds a REACHABLE func_call with a
// NULL vpiFunction whose owner chain is  package > class_defn > (function|task)
// and whose enclosing PACKAGE declares a task_func of the call's name.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <set>
#include <map>
#include <vector>
using namespace UHDM;
int main(int argc, char** argv) {
    if (argc < 2) return 2;
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { printf("RESTORE_FAIL\t%s\n", argv[1]); return 3; }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;
    if (!d) return 3;
    // package -> set of its task_func names
    std::map<const BaseClass*, std::set<std::string>> pkgSubs;
    auto addPkg = [&](const package* p) {
        auto& S = pkgSubs[(const BaseClass*)p];
        if (p->Task_funcs()) for (auto* tf : *p->Task_funcs()) S.insert(std::string(tf->VpiName()));
    };
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) addPkg(p);
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) addPkg(p);
    std::map<std::string,int> hits;
    for (const auto& [obj, id] : s.AllObjects()) {
        if (obj->UhdmType() != uhdmfunc_call) continue;
        const func_call* fc = (const func_call*)obj;
        if (fc->Function()) continue;
        bool inClass = false, inSub = false;
        const BaseClass* pkg = nullptr; const BaseClass* root = nullptr;
        std::string home;
        for (const BaseClass* p = obj->VpiParent(); p; p = p->VpiParent()) {
            UHDM_OBJECT_TYPE t = p->UhdmType();
            if (t == uhdmfunction || t == uhdmtask) { if (!inClass) inSub = true; if (home.empty()) home = std::string(p->VpiName()); }
            if (t == uhdmclass_defn) { inClass = true; home = std::string(p->VpiName()) + "::" + home; }
            if (t == uhdmpackage && !pkg) pkg = p;
            root = p;
        }
        if (!root || root->UhdmType() != uhdmdesign) continue;
        if (!inClass || !inSub || !pkg) continue;
        auto it = pkgSubs.find(pkg);
        if (it == pkgSubs.end()) continue;
        std::string nm(fc->VpiName());
        if (!it->second.count(nm)) continue;
        hits[std::string(pkg->VpiName()) + "|" + home + "|" + nm]++;
    }
    if (hits.empty()) { printf("NOMOVE\t%s\n", argv[1]); return 0; }
    int tot = 0; for (auto& kv : hits) tot += kv.second;
    printf("PREDICT\t%s\tcells=%zu\tobjs=%d\n", argv[1], hits.size(), tot);
    for (auto& kv : hits) printf("  CELL\t%s\tn=%d\n", kv.first.c_str(), kv.second);
    return 0;
}
