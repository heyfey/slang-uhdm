// r10uvm206 — ct206pred.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the
// sole judge; this tool only reports.
//
// THE PREDICTOR, run on PRISTINE databases BEFORE the patched sweep.
//
// § importedClassTsRideTheFileUnit206 can only move a database in which ALL of
//   (a) some package carries `Class_defns`,
//   (b) some class of such a package has a REPRESENTATIVE class_typespec
//       (the § classRep25 stamp: the first class_typespec whose Class_defn is
//       that class, scanning packages by name, then modules, then classes),
//   (c) that representative is NOT already held by an alphabetically-earlier
//       key in the design's listing
// hold at once.  The design listing may be EMPTY and still gain one (a package
// with classes and no top-level typedef), so emptiness is NOT a discharge.
// (a)-(c) are all readable from the pristine database; the one
// condition this tool CANNOT read is the file-scope `import pkg::*` itself, so
// what it prints is an UPPER BOUND — a database it calls CLEAN cannot move,
// and every real mover must appear in its MAYBE list.
//
// build: g++ -O2 -std=c++17 ct206pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct206pred
// usage: ct206pred <db.uhdm>      -> one line: "CLEAN <n>" or "MAYBE <n> ..."
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct206pred <db.uhdm>\n"); return 2; }
    Serializer s;
    auto designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) { printf("NODESIGN\n"); return 0; }
    for (auto dh : designs) {
        const design* d = (const design*)((const uhdm_handle*)dh)->object;
        auto* tv = d->Typespecs();

        // classRep25, read back off the database in the same order the emitter
        // builds it: packages by name, then modules by name, then classes.
        std::map<const class_defn*, const typespec*> rep;
        auto scan = [&](const VectorOftypespec* v) {
            if (!v) return;
            for (auto* t : *v) {
                if (!t || t->UhdmType() != uhdmclass_typespec) continue;
                if (auto* cd = ((const class_typespec*)t)->Class_defn())
                    rep.emplace(cd, t);
            }
        };
        std::map<std::string, const package*> pkgs;
        auto claimP = [&](const VectorOfpackage* v) {
            if (!v) return;
            for (auto* p : *v)
                if (p && p->Class_defns() && !p->Class_defns()->empty())
                    pkgs.emplace(std::string(p->VpiName()), p);
        };
        claimP(d->TopPackages()); claimP(d->AllPackages());
        for (auto& kv : pkgs) scan(kv.second->Typespecs());
        std::map<std::string, const module_inst*> mods;
        auto claimM = [&](const VectorOfmodule_inst* v) {
            if (!v) return;
            for (auto* m : *v)
                if (m && m->Class_defns() && !m->Class_defns()->empty())
                    mods.emplace(std::string(m->VpiName()), m);
        };
        claimM(d->TopModules()); claimM(d->AllModules());
        for (auto& kv : mods) scan(kv.second->Typespecs());
        std::map<std::string, const class_defn*> cls;
        for (auto& kv : pkgs)
            for (auto* c : *kv.second->Class_defns())
                if (c && !c->VpiName().empty())
                    cls.emplace(kv.first + "::" + std::string(c->VpiName()), c);
        for (auto& kv : mods)
            for (auto* c : *kv.second->Class_defns())
                if (c && !c->VpiName().empty())
                    cls.emplace(kv.first + "::" + std::string(c->VpiName()), c);
        if (d->AllClasses())
            for (auto* c : *d->AllClasses())
                if (c && !c->VpiName().empty())
                    cls.emplace(std::string(c->VpiName()), c);
        for (auto& kv : cls) scan(kv.second->Typespecs());

        // what the design listing already holds, by object
        std::set<const typespec*> held;
        if (tv) for (auto* t : *tv) held.insert(t);

        std::vector<std::string> why;
        for (auto& kv : pkgs) {
            for (auto* c : *kv.second->Class_defns()) {
                if (!c || c->VpiName().empty()) continue;
                auto it = rep.find(c);
                if (it == rep.end()) continue;
                std::string k(c->VpiName());
                if (auto p = k.rfind("::"); p != std::string::npos) k = k.substr(p + 2);
                if (held.count(it->second)) {
                    // an object already in the listing can still MOVE, to the
                    // class key, when that key sorts earlier than the name the
                    // listing holds it under.
                    std::string cur(it->second->VpiName());
                    if (auto p = cur.rfind("::"); p != std::string::npos) cur = cur.substr(p + 2);
                    if (k < cur) why.push_back(kv.first + ":MOVE:" + cur + "->" + k);
                } else {
                    why.push_back(kv.first + ":ADD:" + k);
                }
            }
        }
        size_t tvn = tv ? tv->size() : 0;
        if (why.empty()) { printf("CLEAN listing=%zu\n", tvn); continue; }
        printf("MAYBE listing=%zu n=%zu", tvn, why.size());
        for (size_t i = 0; i < why.size() && i < 60; i++) printf(" %s", why[i].c_str());
        printf("\n");
    }
    return 0;
}
