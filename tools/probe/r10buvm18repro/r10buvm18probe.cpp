// r10buvm18 — THE PARAMETER-PAIR COMPARE PROBE.  MEASUREMENT ONLY.
// LHS is ALWAYS golden, RHS is ALWAYS ours (uhdm-cmp <golden> <ours>).
//
// It answers ONE question the whole-design head cannot: WHICH parameter pairs
// does the official `Compare` actually judge unequal, and in what order does
// the walk reach them?  `CompareContext::m_visited` is keyed on the LHS object
// and every generated `Compare` returns 0 for an already-visited LHS, so a
// mismatch under an object the walk touched earlier is INVISIBLE to the judge.
//
// usage: r10buvm18probe <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <unistd.h>

#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
// UHDM::decompile() STREAMS to stdout and returns only its banner, so the
// failed object is described here by the fields the judge actually reads.
static std::string one(const BaseClass* o) {
    if (!o) return "<null>";
    const any* a = (const any*)o;
    std::string s = kd(a) + "(" + nm(a) + ")@" + std::to_string(a->VpiLineNo()) + ":" +
                    std::to_string(a->VpiColumnNo()) + " id:" + std::to_string(a->UhdmId());
    if (a->VpiParent()) s += " par=" + kd(a->VpiParent()) + "(" + nm(a->VpiParent()) + ")";
    return s;
}

// SafeCompare is protected; this is the same two-null-arm logic, verbatim.
static int32_t cmp2(const BaseClass* l, const BaseClass* r, CompareContext* c) {
    if (l && r) return l->Compare(r, c);
    if (l && !r) { c->m_failedLhs = l; return 1; }
    if (!l && r) { c->m_failedRhs = r; return -1; }
    return 0;
}

static design* load(Serializer& s, const char* f) {
    std::cerr << "LOADING " << f << std::endl;
    auto h = s.Restore(std::string(f));
    std::cerr << "LOADED " << f << " handles=" << h.size() << std::endl;
    if (h.empty()) { std::cerr << "RESTORE-FAILED " << f << "\n"; exit(3); }
    return (design*)((const uhdm_handle*)h[0])->object;
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: r10buvm18probe <golden> <ours>\n"; return 2; }
    Serializer sg, so;
    design* g = load(sg, argv[1]);
    design* o = load(so, argv[2]);

    { CompareContext c;
      int r = g->Compare(o, &c);
      std::cout << "WHOLE-DESIGN r=" << r << "\n  LHS " << one(c.m_failedLhs)
                << "\n  RHS " << one(c.m_failedRhs) << "\n"; }

    auto pkgs = [](design* d) { return d->AllPackages(); };
    if (pkgs(g) && pkgs(o) && pkgs(g)->size() == pkgs(o)->size()) {
        for (size_t i = 0; i < pkgs(g)->size(); ++i) {
            package* pg = pkgs(g)->at(i); package* po = pkgs(o)->at(i);
            { CompareContext c; int r = pg->Compare(po, &c);
              std::cout << "PKG[" << i << "] " << pg->VpiName() << " r=" << r
                        << "\n  LHS " << one(c.m_failedLhs) << "\n  RHS " << one(c.m_failedRhs) << "\n"; }
            auto* vg = pg->Parameters(); auto* vo = po->Parameters();
            if (!vg || !vo || vg->size() != vo->size()) { std::cout << "  PARAM-VECTOR SIZE DIFFERS\n"; continue; }
            for (size_t k = 0; k < vg->size(); ++k) {
                CompareContext c;
                int r = vg->at(k)->Compare(vo->at(k), &c);
                if (r != 0)
                    std::cout << "  PARAM[" << k << "] " << nm(vg->at(k)) << " r=" << r
                              << " | LHS " << one(c.m_failedLhs) << " | RHS " << one(c.m_failedRhs) << "\n";
            }
        }
    }
    // SHARED-CONTEXT WALK: exactly what the judge does inside one package —
    // `scope::Compare` runs Variables/Logic_vars/... BEFORE Parameters, and
    // every generated Compare short-circuits on an already-visited LHS, so the
    // head is the first UNVISITED mismatch, not the first mismatch.
    if (pkgs(g) && pkgs(o)) {
        for (size_t i = 0; i < pkgs(g)->size() && i < pkgs(o)->size(); ++i) {
            package* pg = pkgs(g)->at(i); package* po = pkgs(o)->at(i);
            auto* vg = pg->Parameters(); auto* vo = po->Parameters();
            if (!vg || !vo || vg->size() != vo->size()) continue;
            CompareContext c;   // ONE context for the whole vector
            for (size_t k = 0; k < vg->size(); ++k) {
                int r = vg->at(k)->Compare(vo->at(k), &c);
                if (r != 0) {
                    std::cout << "SHAREDCTX PKG " << pg->VpiName() << " first-fail PARAM[" << k
                              << "] " << nm(vg->at(k)) << " r=" << r
                              << " | LHS " << one(c.m_failedLhs) << " | RHS " << one(c.m_failedRhs) << "\n";
                    break;
                }
            }
        }
    }
    // VECTOR WALK: `scope::Compare` runs its vectors in a FIXED order and the
    // package walk is entered ONCE (its own `m_visited` entry), so the head is
    // the first mismatch the vectors reach in THAT order under ONE context.
    if (pkgs(g) && pkgs(o)) {
        for (size_t i = 0; i < pkgs(g)->size() && i < pkgs(o)->size(); ++i) {
            package* pg = pkgs(g)->at(i); package* po = pkgs(o)->at(i);
            if (pg->VpiName() != po->VpiName()) continue;
            CompareContext c;
            c.m_visited.insert(pg);          // the design walk already entered it
#define VEC(NAME)                                                                  \
            { auto* a = pg->NAME(); auto* b = po->NAME();                          \
              if (a && b && a->size() == b->size()) {                              \
                for (size_t k = 0; k < a->size(); ++k) {                           \
                  if (cmp2(a->at(k), b->at(k), &c) != 0) {        \
                    std::cout << "VECWALK " << pg->VpiName() << " " #NAME "[" << k << "]=" << one(a->at(k)) \
                              << "] LHS " << one(c.m_failedLhs)                     \
                              << " | RHS " << one(c.m_failedRhs) << "\n";           \
                    goto donepkg; } } }                                            \
              else if ((a ? a->size() : 0) != (b ? b->size() : 0))                 \
                { std::cout << "VECWALK " << pg->VpiName() << " " #NAME " SIZE "   \
                            << (a?a->size():0) << " vs " << (b?b->size():0) << "\n"; goto donepkg; } }
            VEC(Property_decls) VEC(Sequence_decls) VEC(Concurrent_assertions)
            VEC(Named_events) VEC(Named_event_arrays) VEC(Variables)
            VEC(Virtual_interface_vars) VEC(Logic_vars) VEC(Array_vars)
            VEC(Array_var_mems) VEC(Parameters) VEC(Param_assigns)
            VEC(Scopes) VEC(Typespecs) VEC(Instance_items) VEC(Let_decls)
            std::cout << "VECWALK " << pg->VpiName() << " NO-FAIL in scope-order vectors\n";
#undef VEC
            donepkg:;
        }
    }
    // Two live Serializers throw from kj at teardown; flush and leave hard.
    std::cout.flush();
    _exit(0);
}
