// r10earl118 -- THE CENSUS: every CONTINUOUS ASSIGN's LHS TARGET REFERENCE and
// whether its `Actual_group` is BOUND, keyed by the matrix the law is stated
// in.  MEASUREMENT ONLY; the official uhdm-cmp is the judge.
//
// LHS is ALWAYS golden; RHS is ALWAYS ours.  (Note the name collision: this
// file's "lhs" means the ASSIGNMENT's left-hand side, `cont_assign::Lhs`.)
//
// The head r10earl118 decodes is `cont_assign::Lhs -> ref_obj::Actual_group`:
// golden's non-elaborated database leaves a GENERATE-SCOPE assign target's
// reference UNBOUND (`<null>`) and we bind it to the `logic_var`.  The judge
// reads `Actual_group` through `ref_obj::Compare`
// (~/git-repos/UHDM/build/generated/src/ref_obj.cpp) and `bit_select` IS-A
// `ref_obj`, so both kinds are in scope.
//
// WHAT IS WALKED: the design's `AllModules` / `AllInterfaces` (the DEF view)
// and `TopModules` (the ELAB view) recursively -- NOT `Serializer::AllObjects`.
// The arena's weaklyReferenced tail is unreachable to the judge (RESUME.md
// section 9) and counting it manufactures phantom movers.
//
// THE KEY deliberately EXCLUDES the DEF/ELAB view (the two producers label it
// differently -- RESUME.md section 9) and excludes VpiFile (OUR objects carry
// an EMPTY VpiFile).  Key =
//     home-defname | scope-kind | gen-depth | lhs-kind | lhs-name | span
// PAYLOAD (compare-visible) = the Actual_group KIND, or `<null>`.
// A VIEW-tagged line is emitted too, as a DIAGNOSTIC column only.
//
// build:
//   g++ -O2 -std=c++17 cen118.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen118
// usage:  cen118 <db.uhdm> <tag>      (prints CELL / VIEWCELL / CENRC lines)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : "<null>";
}
static std::string spanOf(const BaseClass* o) {
    if (!o) return "-";
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}

static std::map<std::string, int> cells;      // key \t payload -> count
static std::map<std::string, int> viewcells;  // view \t key \t payload -> count
static std::map<std::string, int> rcells;     // key \t rhs \t home -> count
static std::set<const BaseClass*> visited;

// the ACTUAL: `bit_select` IS-A `ref_obj`, so one cast covers both.  A
// `hier_path` carries `Root_value` instead and is reported as its own kind.
static std::string actualOf(const any* lhs) {
    if (!lhs) return "-";
    if (auto* r = any_cast<const ref_obj*>(lhs)) {
        const any* a = r->Actual_group();
        return a ? kindOf(a) : "<null>";
    }
    if (auto* h = any_cast<const hier_path*>(lhs)) {
        const any* a = h->Root_value();
        return std::string("hp:") + (a ? kindOf(a) : "<null>");
    }
    if (auto* op = any_cast<const operation*>(lhs))
        return "op" + std::to_string(op->VpiOpType());
    return "n/a";
}

// THE PREDICTOR COLUMN (diagnostic, emitted as RCELL, never scored): the Rhs
// SHAPE and where the target is DECLARED relative to the assigning scope.
// `own` = the assigning gen_scope's own `Variables()` holds a variable of that
// name; `anc` = some ENCLOSING gen_scope's does; `other` = neither (a module
// body target, a net, a select).  Read off the DATABASE, so it works on the
// golden side and ours alike and needs no AST.
static std::string rhsShape(const cont_assign* ca) {
    const any* r = ca->Rhs();
    if (!r) return "-";
    if (auto* op = any_cast<const operation*>(r))
        return "op" + std::to_string(op->VpiOpType());
    return kindOf(r);
}
static const char* declHome(const BaseClass* from, const any* lhs) {
    if (!lhs) return "other";
    std::string nm(lhs->VpiName());
    if (nm.empty()) return "other";
    int depth = 0;
    for (const BaseClass* q = from; q; q = q->VpiParent()) {
        if (auto* sc = any_cast<const UHDM::scope*>(q)) {
            if (sc->Variables())
                for (auto* v : *sc->Variables())
                    if (std::string(v->VpiName()) == nm)
                        return depth == 0 ? "own" : "anc";
        }
        if (q->UhdmType() == uhdmgen_scope) depth++;
        else if (q->UhdmType() != uhdmgen_scope_array) break;
    }
    return "other";
}

static void record(const char* view, const std::string& home,
                   const char* scopeKind, int gendepth, const cont_assign* ca,
                   const BaseClass* scopeObj) {
    const any* lhs = ca->Lhs();
    std::string key = home + "|" + scopeKind + "|g" + std::to_string(gendepth) +
                      "|" + kindOf(lhs) + "|" +
                      (lhs ? std::string(lhs->VpiName()) : std::string("-")) +
                      "|" + spanOf(lhs);
    std::string pay = actualOf(lhs);
    cells[key + "\t" + pay]++;
    viewcells[std::string(view) + "\t" + key + "\t" + pay]++;
    rcells[key + "\t" + rhsShape(ca) + "\t" + declHome(scopeObj, lhs) + "\t" +
           pay]++;
}

static void walkScope(const char* view, const std::string& home,
                      const BaseClass* s, int gendepth);

static void walkGenArrays(const char* view, const std::string& home,
                          VectorOfgen_scope_array* gsa, int gendepth) {
    if (!gsa) return;
    for (auto* a : *gsa) {
        if (!a || !a->Gen_scopes()) continue;
        for (auto* g : *a->Gen_scopes()) walkScope(view, home, g, gendepth + 1);
    }
}

static void walkScope(const char* view, const std::string& home,
                      const BaseClass* s, int gendepth) {
    if (!s || !visited.insert(s).second) return;
    if (auto* m = any_cast<const module_inst*>(s)) {
        std::string h(m->VpiDefName());
        if (h.empty()) h = std::string(m->VpiName());
        if (m->Cont_assigns())
            for (auto* c : *m->Cont_assigns())
                record(view, h, "module_inst", gendepth, c, m);
        walkGenArrays(view, h, m->Gen_scope_arrays(), gendepth);
        if (m->Modules())
            for (auto* c : *m->Modules()) walkScope(view, h, c, gendepth);
        if (m->Interfaces())
            for (auto* c : *m->Interfaces()) walkScope(view, h, c, gendepth);
        return;
    }
    if (auto* g = any_cast<const gen_scope*>(s)) {
        if (g->Cont_assigns())
            for (auto* c : *g->Cont_assigns())
                record(view, home, "gen_scope", gendepth, c, g);
        walkGenArrays(view, home, g->Gen_scope_arrays(), gendepth);
        if (g->Modules())
            for (auto* c : *g->Modules()) walkScope(view, home, c, gendepth);
        if (g->Interfaces())
            for (auto* c : *g->Interfaces()) walkScope(view, home, c, gendepth);
        return;
    }
    if (auto* i = any_cast<const interface_inst*>(s)) {
        std::string h(i->VpiDefName());
        if (h.empty()) h = std::string(i->VpiName());
        if (i->Cont_assigns())
            for (auto* c : *i->Cont_assigns())
                record(view, h, "interface_inst", gendepth, c, i);
        walkGenArrays(view, h, i->Gen_scope_arrays(), gendepth);
        return;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: cen118 <db.uhdm> [tag]\n");
        printf("CENRC 2\n");
        return 2;
    }
    Serializer s;
    std::vector<vpiHandle> h = s.Restore(std::string(argv[1]));
    if (h.empty()) {
        fprintf(stderr, "FATAL: load failed %s\n", argv[1]);
        printf("CENRC 3\n");
        return 3;
    }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;

    // DEF view first, then ELAB.  `visited` is CLEARED between the two: the two
    // views legitimately share objects and a single set would silently drop the
    // second view's cells.
    visited.clear();
    if (d->AllModules())
        for (auto* m : *d->AllModules()) walkScope("DEF", "", m, 0);
    if (d->AllInterfaces())
        for (auto* i : *d->AllInterfaces()) walkScope("DEF", "", i, 0);
    visited.clear();
    if (d->TopModules())
        for (auto* m : *d->TopModules()) walkScope("ELAB", "", m, 0);

    for (const auto& kv : cells) printf("CELL\t%d\t%s\n", kv.second, kv.first.c_str());
    for (const auto& kv : viewcells)
        printf("VIEWCELL\t%d\t%s\n", kv.second, kv.first.c_str());
    for (const auto& kv : rcells)
        printf("RCELL\t%d\t%s\n", kv.second, kv.first.c_str());
    printf("CENRC 0\n");
    return 0;
}
