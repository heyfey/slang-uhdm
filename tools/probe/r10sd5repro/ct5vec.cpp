// r10sd5 — WHICH LISTING IS THE SURPLUS IN?  Vector LENGTHS, both sides.
//
// A `LHS: <null>` head is a VECTOR-LENGTH difference, not a content one: golden's
// vector ran out where ours still had an element.  The dump of the failing RHS
// names the OBJECT but never the CONTAINER, and the object's `vpiParent` is a
// red herring — a shared object's parent is whoever made it, not whoever listed
// it (that confusion is the whole subject of this pass).
//
// So this prints the `Variables` vector LENGTH of every container that has one,
// keyed by container kind + name, for one database.  Run it on both sides and
// diff: the container whose length differs is the one the head sits in.
//
// GUARD: zero containers is a hard error.
//
// build: g++ -O2 -std=c++17 ct5vec.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct5vec
// usage: ct5vec <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::map<std::string, std::string> out;  // key -> "len:names..."

static void note(const std::string& key, VectorOfvariables* v) {
    size_t n = v ? v->size() : 0;
    // The key must survive both sides, so it is kind+name+SPAN, never an id.
    auto& slot = out[key];
    slot += (slot.empty() ? "" : ",") + std::to_string(n);
}
static std::string ident(const BaseClass* b) {
    if (!b) return "<null>";
    return std::string(UhdmName(b->UhdmType())) + "(" + std::string(b->VpiName()) + ")@" +
           std::to_string(b->VpiLineNo()) + ":" + std::to_string(b->VpiColumnNo());
}
int32_t main(int32_t argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct5vec <db.uhdm>\n");
        return 2;
    }
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        fprintf(stderr, "FATAL: could not restore %s\n", argv[1]);
        return 3;
    }
    design* d = (design*)((const uhdm_handle*)restored[0])->object;
    long conts = 0;
    std::set<const class_defn*> seenC;
    auto doClass = [&](const class_defn* c, const std::string& view) {
        if (!c || !seenC.insert(c).second) return;
        note(view + " " + ident(c), c->Variables());
        conts++;
    };
    auto doPkgs = [&](VectorOfpackage* v, const char* view) {
        if (!v) return;
        for (auto* p : *v) {
            if (!p) continue;
            note(std::string(view) + " " + ident(p), p->Variables());
            conts++;
            if (p->Class_defns())
                for (auto* c : *p->Class_defns()) doClass(c, view);
        }
    };
    auto doMods = [&](VectorOfmodule_inst* v, const char* view) {
        if (!v) return;
        for (auto* m : *v) {
            if (!m) continue;
            note(std::string(view) + " " + ident(m), m->Variables());
            conts++;
            if (m->Class_defns())
                for (auto* c : *m->Class_defns()) doClass(c, view);
        }
    };
    doPkgs(d->AllPackages(), "ALLPKG");
    doPkgs(d->TopPackages(), "TOPPKG");
    doMods(d->AllModules(), "ALLMOD");
    doMods(d->TopModules(), "TOPMOD");
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) doClass(c, "ALLCLS");
    for (auto& [k, v] : out) printf("%-70s %s\n", k.c_str(), v.c_str());
    fprintf(stderr, "-- containers=%ld\n", conts);
    if (conts == 0) {
        fprintf(stderr, "REFUSING TO REPORT: zero containers\n");
        return 5;
    }
    return 0;
}
