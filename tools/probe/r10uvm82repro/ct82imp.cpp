// r10uvm82 — MEASUREMENT-ONLY census of vpiImported on scope Parameters.
// build: g++ -O2 -std=c++17 ct82imp.cpp -I ~/.local/include -L ~/.local/lib64
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o ct82imp
// usage: ct82imp <file.uhdm> [--per-class]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>
#include <functional>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct82imp <file.uhdm> [--per-class]\n"); return 2; }
    bool perClass = argc > 2 && std::string(argv[2]) == "--per-class";
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { fprintf(stderr, "restore failed\n"); return 2; }
    // walk every object in the serializer's factories via the design roots
    std::set<const BaseClass*> seen;
    std::vector<const BaseClass*> stack;
    design* d = nullptr;
    for (auto h : restored) {
        const uhdm_handle* uh = (const uhdm_handle*)h;
        const BaseClass* o = (const BaseClass*)uh->object;
        if (o->UhdmType() == uhdmdesign) d = (design*)o;
    }
    if (!d) { fprintf(stderr, "no design\n"); return 2; }

    // Collect every scope by BFS over all children using the generic
    // introspection UHDM offers: use the AllPackages/AllClasses/AllModules etc.
    std::vector<const scope*> scopes;
    std::function<void(const class_defn*)> addCls = [&](const class_defn* c) {
        if (!c || !seen.insert(c).second) return;
        scopes.push_back(c);
        if (auto* ts = c->Class_typespecs())
            for (auto* t : *ts)
                if (t) addCls(t->Class_defn());
        if (auto* dv = c->Deriveds())
            for (auto* t : *dv) addCls(t);
    };
    if (auto* v = d->AllClasses()) for (auto* c : *v) addCls(c);
    if (auto* v = d->AllPackages())
        for (auto* p : *v) {
            if (seen.insert(p).second) scopes.push_back(p);
            if (auto* cs = p->Class_defns()) for (auto* c : *cs) addCls(c);
        }
    if (auto* v = d->TopPackages())
        for (auto* p : *v) {
            if (seen.insert(p).second) scopes.push_back(p);
            if (auto* cs = p->Class_defns()) for (auto* c : *cs) addCls(c);
        }
    if (auto* v = d->AllModules())
        for (auto* m : *v) {
            if (seen.insert(m).second) scopes.push_back(m);
            if (auto* cs = m->Class_defns()) for (auto* c : *cs) addCls(c);
        }
    if (auto* v = d->TopModules())
        for (auto* m : *v) {
            if (seen.insert(m).second) scopes.push_back(m);
            if (auto* cs = m->Class_defns()) for (auto* c : *cs) addCls(c);
        }

    std::map<std::string, size_t> tally;   // "<parentkind>|<imported>" -> count
    size_t nScopeWithParams = 0;
    for (const scope* sc : scopes) {
        auto* ps = sc->Parameters();
        if (!ps || ps->empty()) continue;
        nScopeWithParams++;
        std::map<std::string, size_t> per;
        for (auto* a : *ps) {
            if (!a) continue;
            std::string imp;
            if (a->UhdmType() == uhdmparameter) imp = std::string(((parameter*)a)->VpiImported());
            else if (a->UhdmType() == uhdmtype_parameter) imp = std::string(((type_parameter*)a)->VpiImported());
            else imp = "<other:" + std::string(UhdmName(a->UhdmType())) + ">";
            std::string k = std::string(UhdmName(sc->UhdmType())) + "|" + (imp.empty() ? "<EMPTY>" : imp);
            tally[k]++;
            per[k]++;
        }
        if (perClass) {
            printf("SCOPE %s %s (%s:%u) n=%zu :", UhdmName(sc->UhdmType()),
                   std::string(sc->VpiName()).c_str(), base(sc->VpiFile()).c_str(),
                   sc->VpiLineNo(), ps->size());
            for (auto& [k, c] : per) printf("  %s=%zu", k.c_str(), c);
            printf("\n");
        }
    }
    printf("SCOPES-WITH-PARAMS %zu\n", nScopeWithParams);
    for (auto& [k, c] : tally) printf("TALLY\t%s\t%zu\n", k.c_str(), c);
    return 0;
}
