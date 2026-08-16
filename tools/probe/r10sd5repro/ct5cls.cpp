// r10sd5 — THE DECODE INSTRUMENT for the class-import VARIABLE listing.
//
// sd4's R1 named the site (`ModuleEmit.cpp:~4097`, the shared push) and read TWO
// cells of golden's answer.  A CLONE patch needs more than two cells: it needs
// the DEPTH.  Specifically it needs, for EVERY variable in EVERY class_defn
// listing, on BOTH sides:
//
//   [V]  the entry itself   — kind, name, span, and whether the entry object is
//                             POINTER-IDENTICAL to a variable the package lists
//                             (that identity IS the defect);
//   [T]  its ref_typespec   — own object or shared with the package's copy?
//   [A]  its actual typespec— own object or shared?  and its `vpiInstance`;
//   [E]  its init expr      — own object or shared?
//
// Sharing is invisible to any span/key census (sd4 §3.4), so every question here
// is answered by POINTER IDENTITY against the set of objects the PACKAGE listings
// own, never by key.  That is the whole point of the tool: "golden nulls the
// instance" and "golden emits a different object whose instance happens to be
// null" are DIFFERENT PATCHES and a key census cannot separate them.
//
// GUARD (measure the measurer): a run that finds ZERO class_defn listings with
// variables is a hard error.  An empty population trivially "agrees" and that is
// precisely the reading that looks like success.
//
// build: g++ -O2 -std=c++17 ct5cls.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct5cls
// usage: ct5cls <db.uhdm> [name-substring-filter]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string span(const BaseClass* p) {
    if (!p) return "-";
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) + "-" +
           std::to_string(p->VpiEndLineNo()) + ":" + std::to_string(p->VpiEndColumnNo());
}
static std::string instName(const instance* i) {
    if (!i) return "<null>";
    return std::string(i->VpiName());
}
// The four PACKAGE listings own the objects the class listings must NOT share.
static void collectPkg(design* d, std::set<const BaseClass*>& own) {
    auto walk = [&](VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v) {
            if (!p || !p->Variables()) continue;
            for (auto* x : *p->Variables()) {
                if (!x) continue;
                own.insert(x);
                if (auto* rt = x->Typespec()) {
                    own.insert(rt);
                    if (auto* at = rt->Actual_typespec()) own.insert(at);
                }
                if (auto* e = x->Expr()) own.insert(e);
            }
        }
    };
    walk(d->AllPackages());
    walk(d->TopPackages());
}
// A SECOND population, and the one that separates "own" from "correct": the
// typespecs a package publishes in its OWN Typespecs listing (its typedefs).
// A class-listing variable whose type is a package-homed TYPEDEF legitimately
// points at that shared object -- which is why golden's class listings are not
// uniformly null-instanced (63 of 1206 carry a package) and why "null the
// instance on every clone" would be a WRONG law.
static void collectPkgTs(design* d, std::set<const BaseClass*>& own) {
    auto walk = [&](VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v) {
            if (!p || !p->Typespecs()) continue;
            for (auto* t : *p->Typespecs())
                if (t) own.insert(t);
        }
    };
    walk(d->AllPackages());
    walk(d->TopPackages());
}
// [S] the summary that IS the law: how many entries share each level, and the
// multiset of `vpiInstance` on the actual typespec.  Printed for both sides so
// the answer is a distribution, never one cell.
static std::map<std::string, long> g_tally;
static bool g_quiet = false;
static std::set<const BaseClass*>* g_pkgTs = nullptr;
static bool named0(const typespec* t) { return t && !t->VpiName().empty(); }
static void doClass(const class_defn* c, const std::set<const BaseClass*>& pkgOwn,
                    const std::string& filt, int& rows) {
    if (!c || !c->Variables()) return;
    for (auto* x : *c->Variables()) {
        if (!x) continue;
        std::string nm(x->VpiName());
        if (!filt.empty() && nm.find(filt) == std::string::npos) continue;
        const ref_typespec* rt = x->Typespec();
        const typespec* at = rt ? rt->Actual_typespec() : nullptr;
        const expr* e = x->Expr();
        auto sh = [&](const BaseClass* o) {
            return !o ? "none" : (pkgOwn.count(o) ? "SHARED" : "own");
        };
        // The instance an `instance`-bearing typespec carries; only typespecs
        // have the slot that fires the head.
        const instance* ai = at ? at->Instance() : nullptr;
        g_tally[std::string("V=") + sh(x)]++;
        g_tally[std::string("T=") + sh(rt)]++;
        g_tally[std::string("A=") + sh(at)]++;
        g_tally[std::string("E=") + sh(e)]++;
        g_tally[std::string("inst=") + instName(ai)]++;
        // NAMED vs ANONYMOUS: does the actual typespec carry a name, and is it
        // one of the package's published typedefs?
        bool named = at && !at->VpiName().empty();
        bool pubTs = at && g_pkgTs && g_pkgTs->count(at);
        // [X] the CROSS the fix needs: is the surplus instance carried by the
        // SHARED entries (the defect) or by entries we already own (a different
        // defect that a clone cannot touch)?
        g_tally[std::string("X ") + sh(x) + " " + (named0(at) ? "named" : "anon") + " " +
                (ai ? "INST" : "null")]++;
        g_tally[std::string("kind=") + (at ? std::string(UhdmName(at->UhdmType())) : "none") +
                (named ? "/named" : "/anon") + (pubTs ? "/pkgTs" : "") +
                (ai ? "/INST" : "/null")]++;
        // The SPAN LAW: is the entry's end column == start column + name length
        // (the NAME span Surelog's populateCoreMembers(id,id) writes), or is it
        // the wider DECLARATOR span the package's own copy carries?
        g_tally[std::string("span=") +
                ((x->VpiEndLineNo() == x->VpiLineNo() &&
                  x->VpiEndColumnNo() == x->VpiColumnNo() + (uint32_t)nm.size())
                     ? "NAME"
                     : "other")]++;
        rows++;
        if (g_quiet) continue;
        printf("  %-24s %-14s %-16s V=%-6s T=%-6s A=%-6s E=%-6s ats=%-14s inst=%s\n",
               std::string(c->VpiName()).c_str(), std::string(UhdmName(x->UhdmType())).c_str(), nm.c_str(), sh(x),
               sh(rt), sh(at), sh(e), at ? span(at).c_str() : "-", instName(ai).c_str());
        printf("      var span=%-14s parent=%s\n", span(x).c_str(),
               x->VpiParent() ? std::string(UhdmName(x->VpiParent()->UhdmType())).c_str() : "<none>");
    }
}
int32_t main(int32_t argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct5cls <db.uhdm> [filter]\n");
        return 2;
    }
    std::string filt = argc > 2 ? argv[2] : "";
    if (filt == "-q") { g_quiet = true; filt.clear(); }
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        fprintf(stderr, "FATAL: could not restore %s\n", argv[1]);
        return 3;
    }
    design* d = (design*)((const uhdm_handle*)restored[0])->object;
    std::set<const BaseClass*> pkgOwn;
    collectPkg(d, pkgOwn);
    std::set<const BaseClass*> pkgTs;
    collectPkgTs(d, pkgTs);
    g_pkgTs = &pkgTs;
    printf("package-published typespecs: %zu\n", pkgTs.size());
    printf("package-owned objects: %zu\n", pkgOwn.size());
    int rows = 0;
    std::set<const class_defn*> seen;
    auto pkgClasses = [&](VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v) {
            if (!p || !p->Class_defns()) continue;
            for (auto* c : *p->Class_defns())
                if (seen.insert(c).second) doClass(c, pkgOwn, filt, rows);
        }
    };
    pkgClasses(d->AllPackages());
    pkgClasses(d->TopPackages());
    if (d->AllClasses())
        for (auto* c : *d->AllClasses())
            if (seen.insert(c).second) doClass(c, pkgOwn, filt, rows);
    printf("\n[S] SUMMARY over %d class-listing variable entries\n", rows);
    for (auto& [k, v] : g_tally) printf("    %-22s %ld\n", k.c_str(), v);
    printf("-- class_defns=%zu rows=%d\n", seen.size(), rows);
    if (rows == 0) {
        printf("REFUSING TO REPORT: zero rows -- an empty population agrees with anything\n");
        return 5;
    }
    return 0;
}
