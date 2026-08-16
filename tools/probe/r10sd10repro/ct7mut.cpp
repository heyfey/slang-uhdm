// r10sd7 — SINGLE-SLOT MUTATION, TARGETED AT THE HEAD'S OWN RHS POINTER.
//
// The head is `LHS:<null>` / `RHS: package(uvm_pkg)` and the package is the
// TOP-view object (`UhdmId 6040`, measured — the def view is `146`).
// `SafeCompare` writes `m_failedRhs` with `m_failedLhs` left unset in exactly
// one branch (`lhs==nullptr && rhs!=nullptr`, `BaseClass.h`:194), and the only
// singular slot in these databases that can hold a package is `vpiInstance`.
//
// So the owner is one of OUR objects whose `vpiInstance` IS that exact package
// pointer.  This tool nulls them ONE AT A TIME, re-runs the whole-design
// compare, restores, and reports every object whose removal MOVES the head.
//
// Judged by the head MOVING, not by the head vanishing.  sd4's `ct4mut2`
// classified a slot as `INTRODUCED` whenever nulling it created an earlier
// failure and therefore missed a SHARED object that is compared at two
// positions — the mechanism of both walls it studied.  A move is a move: any
// change of `m_failedRhs` names an object the head depends on, and the report
// says which kind of change it was instead of discarding it.
//
// GUARD: the baseline head is asserted PRESENT before any candidate is mutated,
// and the candidate pool is asserted NON-EMPTY.  A scanner that cannot see the
// head reports every mutation as a kill, silently.
//
// build: g++ -O2 -std=c++17 ct7mut.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7mut
// usage: ct7mut <golden.uhdm> <ours.uhdm> [max-candidates]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

using namespace UHDM;

static std::string span(const BaseClass* p) {
    return std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) + "-" +
           std::to_string(p->VpiEndLineNo()) + ":" + std::to_string(p->VpiEndColumnNo());
}
static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s + "@" + span(p);
}
static std::string chain(const BaseClass* p) {
    std::string s;
    const BaseClass* q = p ? p->VpiParent() : nullptr;
    for (int i = 0; i < 3 && q; i++) { s += " <- " + ident(q); q = q->VpiParent(); }
    return s.empty() ? " <- <no-parent>" : s;
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct7mut <golden> <ours> [max]\n"; return 2; }
    size_t maxc = argc > 3 ? (size_t)atol(argv[3]) : (size_t)-1;
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* DA = (design*)((uhdm_handle*)ha[0])->object;
    auto* DB = (design*)((uhdm_handle*)hb[0])->object;

    const BaseClass* base = nullptr;
    {
        CompareContext c;
        int r = DA->Compare(DB, &c);
        base = c.m_failedRhs;
        std::cout << "BASELINE r=" << r << "  failedLhs=" << ident(c.m_failedLhs)
                  << "  failedRhs=" << ident(base) << "  visited=" << c.m_visited.size()
                  << "\n";
        if (r == 0 || !base) {
            std::cerr << "REFUSING TO REPORT: no baseline head to move\n";
            return 5;
        }
    }
    // The candidate pool: OUR objects whose singular vpiInstance IS the head's
    // own RHS pointer.
    // The pool is taken from `ct4ref`'s 154-relation sweep of THIS pair, which
    // reports every class that references the failing package: the typespec
    // family, `variables`, and — the one an earlier run of this tool MISSED —
    // `function`/`task`, i.e. `task_func`, 787 + 107 slots on our side.  A pool
    // assembled from memory instead of from the sweep is how a scan returns
    // "no candidates move" while the owner sits outside it.
    std::vector<typespec*> ts;
    std::vector<variables*> vr;
    std::vector<task_func*> tf;
    for (const auto& [obj, id] : sb.AllObjects()) {
        if (!obj) continue;
        if (auto* t = any_cast<typespec*>((any*)obj)) {
            if (t->Instance() == (const instance*)base) ts.push_back(t);
        } else if (auto* v = any_cast<variables*>((any*)obj)) {
            if (v->Instance() == (const instance*)base) vr.push_back(v);
        } else if (auto* f = any_cast<task_func*>((any*)obj)) {
            if (f->Instance() == (const instance*)base) tf.push_back(f);
        }
    }
    std::cout << "candidates: typespec=" << ts.size() << " variables=" << vr.size()
              << " task_func=" << tf.size() << "\n";
    if (ts.empty() && vr.empty() && tf.empty()) {
        std::cerr << "REFUSING TO REPORT: empty candidate pool\n";
        return 5;
    }
    size_t moved = 0, tried = 0;
    auto probe = [&](BaseClass* owner, auto setter, auto getter) {
        if (tried >= maxc) return;
        tried++;
        auto save = getter();
        setter(nullptr);
        CompareContext c;
        int r = DA->Compare(DB, &c);
        setter(save);
        if (c.m_failedRhs != base) {
            moved++;
            std::cout << "MOVER " << ident(owner) << chain(owner) << "\n"
                      << "      new r=" << r << " lhs=" << ident(c.m_failedLhs)
                      << " rhs=" << ident(c.m_failedRhs) << "\n";
        }
    };
    for (auto* t : ts)
        probe(t, [&](instance* v) { t->Instance(v); }, [&] { return t->Instance(); });
    for (auto* v : vr)
        probe(v, [&](instance* x) { v->Instance(x); }, [&] { return v->Instance(); });
    for (auto* f : tf)
        probe(f, [&](instance* x) { f->Instance(x); }, [&] { return f->Instance(); });
    std::cout << "[S] tried=" << tried << " MOVERS=" << moved << "\n";
    return 0;
}
