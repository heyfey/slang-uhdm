// r10sd6 — THE MASKING EXPERIMENT: is the NEW head a REGRESSION or the NEXT
// divergence?
//
// After this patch SeqDriver's cmp head goes 43 lines -> 1 421 701 lines.  The
// standing campaign law says head SIZE is the failing object's SUBTREE, not the
// size of the defect (sd4 §3.1) — but "the head got bigger because it advanced"
// is exactly the kind of claim that must be MEASURED, not asserted.
//
// The measurement: every generated `Compare` body opens with
// `m_visited.insert(this)` keyed on the LHS, and an already-visited LHS
// compares EQUAL immediately.  So a head can be SUPPRESSED by seeding
// `m_visited` with its golden-side owner, and the comparison then continues to
// whatever WOULD have been next.
//
// This tool seeds `m_visited` with the golden objects this patch's law is about
// — every `ref_obj`/`ref_var` in the initialiser of every class-listing variable
// (the 52 the census counts) — and then compares golden against the PRISTINE
// database.  If the head that appears is the SAME head the patched binary
// produces, then that head was ALREADY THERE, merely masked, and the patch
// advanced the comparison instead of breaking it.
//
// GUARDS:
//   * the UNSEEDED baseline is printed FIRST, so the seed's effect is visible
//     rather than assumed;
//   * the seed COUNT is printed: a seed that turns out to be empty would make
//     the two runs trivially identical and prove nothing;
//   * both heads are printed with kind+name+span, never summarised.
//
// build: g++ -O2 -std=c++17 ct6mask.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct6mask
// usage: ct6mask <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo()) + "-" +
         std::to_string(p->VpiEndLineNo()) + ":" +
         std::to_string(p->VpiEndColumnNo());
    return s;
}

static std::vector<const BaseClass*> seed;

static void collect(const any* e, int depth) {
    if (!e || depth > 12) return;
    if (auto* ro = any_cast<ref_obj*>((any*)e)) { seed.push_back(ro); return; }
    if (auto* rv = any_cast<ref_var*>((any*)e)) { seed.push_back(rv); return; }
    if (e->UhdmType() == uhdmoperation) {
        if (auto* ops = ((operation*)e)->Operands())
            for (auto* o : *ops) collect(o, depth + 1);
        return;
    }
    if (auto* tc = any_cast<tf_call*>((any*)e))
        if (auto* args = tc->Tf_call_args())
            for (auto* a : *args) collect(a, depth + 1);
}

static std::set<const class_defn*> seen;
static void doClass(const class_defn* cd) {
    if (!cd || !seen.insert(cd).second) return;
    if (cd->Variables())
        for (auto* v : *cd->Variables())
            if (v && v->Expr()) collect(v->Expr(), 0);
    if (cd->Deriveds())
        for (auto* d : *cd->Deriveds()) doClass(d);
}

static void head(const design* a, const design* b, bool seeded) {
    CompareContext c;
    if (seeded)
        for (const BaseClass* s : seed) c.m_visited.insert(s);
    const int32_t r = a->Compare(b, &c);
    printf("%-10s r=%-3d LHS=%-46s RHS=%s\n", seeded ? "SEEDED" : "BASELINE",
           (int)r, ident(c.m_failedLhs).c_str(), ident(c.m_failedRhs).c_str());
}

int32_t main(int32_t argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct6mask <golden.uhdm> <ours.uhdm>\n");
        return 2;
    }
    Serializer sa, sb;
    auto ha = sa.Restore(std::string(argv[1]));
    auto hb = sb.Restore(std::string(argv[2]));
    if (ha.empty() || hb.empty()) { printf("RESTORE-FAIL\n"); return 3; }
    const design* a = (const design*)((const uhdm_handle*)ha[0])->object;
    const design* b = (const design*)((const uhdm_handle*)hb[0])->object;
    head(a, b, false);
    if (a->AllClasses())
        for (auto* c : *a->AllClasses()) doClass(c);
    auto pkgs = [&](VectorOfpackage* v) {
        if (!v) return;
        for (auto* p : *v)
            if (p && p->Class_defns())
                for (auto* c : *p->Class_defns()) doClass(c);
    };
    pkgs(a->AllPackages());
    pkgs(a->TopPackages());
    printf("-- seed (golden class-listing initialiser refs) = %zu objects\n",
           seed.size());
    if (seed.empty()) {
        printf("REFUSING TO REPORT: EMPTY SEED\n");
        return 5;
    }
    head(a, b, true);
    return 0;
}
