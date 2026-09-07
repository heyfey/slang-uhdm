// r10earl119 -- THE CENSUS: every CONTINUOUS ASSIGN's Rhs SHAPE (folded
// constant vs unfolded operation) with its COMPARE-VISIBLE constant fields,
// keyed by the matrix this pass's law is stated in.  MEASUREMENT ONLY; the
// official uhdm-cmp is the judge.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.  ("Lhs" below, unless
// spelled `cont_assign::Lhs`, never means a side of the comparison.)
//
// The head r10earl119 decodes is `cont_assign::Rhs`: golden's DEFAULT-view
// database SUBSTITUTES the folded, `adjustSize`-re-encoded constant where we
// keep the unfolded cast `operation`.  `constant::Compare`
// (~/git-repos/UHDM/build/generated/src/constant.cpp) reads VpiDecompile,
// VpiSize, VpiValue and VpiConstType -- so those four ARE the payload, and
// VpiFile/line/column are NOT (they go on the diagnostic LOCCELL row instead,
// because byte identity of the dumps still has to be predicted).
//
// WHAT IS WALKED: the design's `AllModules`/`AllInterfaces` (the DEF view) and
// `TopModules` (the ELAB view) recursively -- NOT `Serializer::AllObjects`:
// the arena's weaklyReferenced tail is unreachable to the judge (RESUME.md
// section 9) and counting it manufactures phantom movers.
//
// THE KEY deliberately EXCLUDES the DEF/ELAB view (the two producers label it
// differently -- RESUME.md section 9) and excludes VpiFile (OUR objects carry
// an EMPTY VpiFile).  Key =
//     home-defname | scope-kind | gen-depth | lhs-kind | lhs-name | ca-span
// PAYLOAD (compare-visible) = the Rhs shape:
//     op<opType>                      an unfolded operation
//     const|<constType>|<size>|<decompile>|<value>    a folded constant
//
// build:
//   g++ -O2 -std=c++17 cen119.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen119
// usage:  cen119 <db.uhdm> <tag>   (prints CELL / VIEWCELL / LOCCELL / CENRC)
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
static std::map<std::string, int> loccells;   // key \t payload \t loc -> count
static std::set<const BaseClass*> visited;

// THE PAYLOAD -- compare-visible only.
static std::string rhsPayload(const cont_assign* ca) {
    const any* r = ca->Rhs();
    if (!r) return "<null>";
    if (auto* op = any_cast<const operation*>(r))
        return "op" + std::to_string(op->VpiOpType());
    if (auto* c = any_cast<const constant*>(r)) {
        return "const|" + std::to_string(c->VpiConstType()) + "|" +
               std::to_string(c->VpiSize()) + "|" +
               std::string(c->VpiDecompile()) + "|" +
               std::string(c->VpiValue());
    }
    return kindOf(r);
}

// DIAGNOSTIC column: does the Rhs carry a LOCATION?  Not compare-visible, so
// never in the scored payload -- but a byte mover has to be predicted, and a
// folded constant that is LOCATED where golden's is LOCATION-LESS is exactly
// the kind of difference the dump column sees and the judge does not.
static std::string locOf(const cont_assign* ca) {
    const any* r = ca->Rhs();
    if (!r) return "-";
    return (r->VpiLineNo() || r->VpiColumnNo()) ? spanOf(r) : "LOCLESS";
}

// DIAGNOSTIC column: the Rhs operation's own operand shape and the CAST
// TYPESPEC's kind, so the cells `applyCaCastFoldDef119` can reach (a single
// CONSTANT operand under a typespec `ExprEval`'s `vpiCastOp` arm has a branch
// for) are computable from a PRISTINE census alone -- which is what
// predict119.py does.
static std::string operandShape(const cont_assign* ca) {
    const any* r = ca->Rhs();
    auto* op = any_cast<const operation*>(r);
    if (!op || !op->Operands() || op->Operands()->empty()) return "-";
    std::string s = kindOf(op->Operands()->at(0));
    s += "/";
    const typespec* ts = nullptr;
    if (const ref_typespec* rt = op->Typespec()) ts = rt->Actual_typespec();
    s += ts ? std::string(UhdmName(ts->UhdmType())) : std::string("<null>");
    if (op->Operands()->size() != 1) s += "/nops" + std::to_string(op->Operands()->size());
    return s;
}

static void record(const char* view, const std::string& home,
                   const char* scopeKind, int gendepth,
                   const cont_assign* ca) {
    const any* lhs = ca->Lhs();
    std::string key = home + "|" + scopeKind + "|g" + std::to_string(gendepth) +
                      "|" + kindOf(lhs) + "|" +
                      (lhs ? std::string(lhs->VpiName()) : std::string("-")) +
                      "|" + spanOf(ca);
    std::string pay = rhsPayload(ca);
    cells[key + "\t" + pay]++;
    viewcells[std::string(view) + "\t" + key + "\t" + pay]++;
    loccells[key + "\t" + pay + "\t" + locOf(ca) + "\t" + operandShape(ca)]++;
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
                record(view, h, "module_inst", gendepth, c);
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
                record(view, home, "gen_scope", gendepth, c);
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
                record(view, h, "interface_inst", gendepth, c);
        walkGenArrays(view, h, i->Gen_scope_arrays(), gendepth);
        return;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: cen119 <db.uhdm> [tag]\n");
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

    // DEF view first, then ELAB.  `visited` is CLEARED between the two: the
    // two views legitimately share objects and a single set would silently
    // drop the second view's cells.
    visited.clear();
    if (d->AllModules())
        for (auto* m : *d->AllModules()) walkScope("DEF", "", m, 0);
    if (d->AllInterfaces())
        for (auto* i : *d->AllInterfaces()) walkScope("DEF", "", i, 0);
    visited.clear();
    if (d->TopModules())
        for (auto* m : *d->TopModules()) walkScope("ELAB", "", m, 0);

    for (const auto& kv : cells)
        printf("CELL\t%d\t%s\n", kv.second, kv.first.c_str());
    for (const auto& kv : viewcells)
        printf("VIEWCELL\t%d\t%s\n", kv.second, kv.first.c_str());
    for (const auto& kv : loccells)
        printf("LOCCELL\t%d\t%s\n", kv.second, kv.first.c_str());
    printf("CENRC 0\n");
    return 0;
}
