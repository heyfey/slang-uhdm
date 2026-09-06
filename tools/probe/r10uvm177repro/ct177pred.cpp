// r10uvm177 — THE MOVER PREDICTOR.  MEASUREMENT ONLY; run over PRISTINE
// databases BEFORE the patched sweep, so the mover set is named in advance
// (RESUME.md §6 gate 5).  LHS is ALWAYS golden (Surelog); this tool reads ONE
// database at a time and never compares.
//
// A candidate is a FUNCTION RETURN VARIABLE that § ownNamedAliasRetIsRefVar177
// can re-kind, expressed in terms a database can answer:
//
//   * the variable is NOT already a `ref_var`;
//   * its typespec carries a NON-NULL `Typedef_alias` — the UHDM marker that
//     the typedef's own written base was a NAMED TYPE (our emitter builds a
//     clone with a `Typedef_alias` ref exactly there, and so does Surelog's
//     `ElaborationStep::bindTypedefs_`);
//   * the LISTING is one the law can fire in: a package's DEF listing
//     (`PKGDEF:`), a module listing (`MODDEF:` / `MODELAB:`) or a class body —
//     never a package's ELAB listing (`PKGELAB:` with a PKGLIST home), which
//     Surelog recompiles after the bind;
//   * the typespec's NAME is scoped to the listing's own component: `P::x`
//     under `PKGDEF:P`, and an UNQUALIFIED name under a class body or a module.
//
// The predicate is deliberately a SUPERSET of the emitter gate (it cannot see
// a `$unit` alias's home, an inherited class alias, or an import clone), so
// every real mover must appear here; a name that appears here and does not
// move is an over-prediction and is reported as such, never the reverse.
//
// build: g++ -O2 -std=c++17 ct177pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct177pred
// usage: ct177pred <db.uhdm>          (prints one CAND line per candidate)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct177pred <db.uhdm>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { printf("NO_DESIGN\n"); return 3; }

    std::map<const BaseClass*, std::string> tag;
    if (auto* v = d->AllPackages())
        for (auto* o : *v) tag[o] = "PKGDEF:" + std::string(o->VpiName());
    if (auto* v = d->TopPackages())
        for (auto* o : *v) tag[o] = "PKGELAB:" + std::string(o->VpiName());
    if (auto* v = d->AllModules())
        for (auto* o : *v) tag[o] = "MODDEF:" + std::string(o->VpiDefName());
    if (auto* v = d->TopModules())
        for (auto* o : *v) tag[o] = "MODELAB:" + std::string(o->VpiDefName());
    if (auto* v = d->AllClasses())
        for (auto* o : *v) tag[o] = "CLASSDEF:" + std::string(o->VpiName());

    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmfunction) continue;
        const function* f = (const function*)o;
        const variables* rv = f->Return();
        if (!rv || rv->UhdmType() == uhdmref_var) continue;
        const ref_typespec* rt = rv->Typespec();
        if (!rt) continue;
        const typespec* ts = rt->Actual_typespec();
        if (!ts || !ts->Typedef_alias()) continue;

        std::string listing = "-";
        bool crossedClass = false;
        int g = 0;
        for (const BaseClass* p = o->VpiParent(); p && g < 128;
             p = p->VpiParent(), ++g) {
            auto it = tag.find(p);
            if (it != tag.end()) { listing = it->second; break; }
            if (p->UhdmType() == uhdmclass_defn) crossedClass = true;
        }
        std::string tsn(ts->VpiName());
        bool qualified = tsn.find("::") != std::string::npos;
        bool fire = false;
        if (crossedClass) {
            fire = !qualified;                       // a class-scope alias
        } else if (listing.rfind("PKGDEF:", 0) == 0) {
            fire = qualified &&
                   tsn.rfind(listing.substr(7) + "::", 0) == 0;
        } else if (listing.rfind("MODDEF:", 0) == 0 ||
                   listing.rfind("MODELAB:", 0) == 0) {
            fire = !qualified;
        }
        if (!fire) continue;
        char b[2400];
        snprintf(b, sizeof b, "CAND\t%s\t%s\t%s\t%u:%u\t%s\t%s",
                 listing.c_str(), crossedClass ? "CLASSBODY" : "PKGLIST",
                 std::string(f->VpiName()).c_str(), rv->VpiLineNo(),
                 (unsigned)rv->VpiColumnNo(),
                 std::string(UhdmName(rv->UhdmType())).c_str(), tsn.c_str());
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s\n", r.c_str());
    printf("CANDS=%zu\n", rows.size());
    return 0;
}
