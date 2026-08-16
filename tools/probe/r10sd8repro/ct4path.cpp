// r10sd4 — THE TRAVERSAL PATH TO THE HEAD, and the object at the END of it.
//
// Every earlier localizer in this campaign asked "did the head's SIGNATURE go
// away?".  That question has a blind spot these databases walk into: Surelog
// emits every package TWICE (def view + elab view), so a failure suppressed in
// one view RECURS with the same shape — and the same `m_failedRhs` POINTER — in
// the other.  Measured: suppressing golden's ALL-view `uvm_pkg` leaves
// `r=-1 lhs=<null> rhs=package(uvm_pkg)` byte for byte and only `m_visited`
// moves (1613 -> 2143).  sd2 read that as "the vector arm is ruled out"; it is
// really "the signature test is blind here".
//
// THE FIX: compare the WHOLE OUTCOME TUPLE — (r, m_failedLhs, m_failedRhs,
// |m_visited|).  `m_visited`'s SIZE is the traversal's own progress counter, and
// it separates the two cases the signature merges:
//
//   * X is NOT on the path to the failure -> suppressing X only skips work that
//     compared equal; the tuple's r/lhs/rhs are unchanged and |m_visited| can
//     only SHRINK.
//   * X IS on the path -> the failing call is skipped, `Compare` ADVANCES, and
//     |m_visited| GROWS.
//
// The path objects are then ordered by the same `m_visited` oracle (B is BELOW A
// iff suppressing A stops B being visited), and the OWNER is the DEEPEST — the
// object whose own `Compare` body issues `SafeCompare(nullptr, package)`.
//
// The candidate pool is `m_visited` after the baseline run: every generated
// `Compare` opens with `m_visited.insert(this)`, so the owner is necessarily in
// it.  1613 objects on SeqDriver — the whole scan is seconds.
//
// build: g++ -O2 -std=c++17 ct4path.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4path
// usage: ct4path <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static design *DA, *DB;

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
struct Out {
    int r = 0;
    const BaseClass* lhs = nullptr;
    const BaseClass* rhs = nullptr;
    size_t vis = 0;
    bool sameTriple(const Out& o) const {
        return r == o.r && lhs == o.lhs && rhs == o.rhs;
    }
    std::string str() const {
        return "r=" + std::to_string(r) + " lhs=" + ident(lhs) +
               " rhs=" + ident(rhs) + " vis=" + std::to_string(vis);
    }
};
static Out run(const std::vector<const BaseClass*>& seed,
               std::set<const BaseClass*>* vis = nullptr) {
    CompareContext c;
    for (auto* s : seed) c.m_visited.insert(s);
    Out o;
    o.r = DA->Compare(DB, &c);
    o.lhs = c.m_failedLhs;
    o.rhs = c.m_failedRhs;
    o.vis = c.m_visited.size();
    if (vis) *vis = c.m_visited;
    return o;
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct4path <golden> <ours>\n"; return 2; }
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    DA = (design*)((uhdm_handle*)ha[0])->object;
    DB = (design*)((uhdm_handle*)hb[0])->object;

    std::set<const BaseClass*> V0;
    Out base = run({}, &V0);
    std::cout << "[B] BASELINE " << base.str() << "\n";
    std::vector<const BaseClass*> pool(V0.begin(), V0.end());
    std::cout << "[P] pool = m_visited after baseline: " << pool.size() << "\n";

    std::vector<const BaseClass*> path;
    std::vector<Out> pout;
    for (const BaseClass* x : pool) {
        Out o = run({x});
        if (!o.sameTriple(base) || o.vis > base.vis) {
            path.push_back(x);
            pout.push_back(o);
        }
    }
    std::cout << "[P] ON THE PATH (tuple changed or traversal ADVANCED): "
              << path.size() << "\n";

    // order them
    std::vector<std::set<const BaseClass*>> vs(path.size());
    for (size_t i = 0; i < path.size(); i++) run({path[i]}, &vs[i]);
    std::vector<int> below(path.size(), 0);
    for (size_t i = 0; i < path.size(); i++)
        for (size_t j = 0; j < path.size(); j++)
            if (i != j && V0.count(path[j]) && !vs[i].count(path[j])) below[j]++;

    std::vector<size_t> ord(path.size());
    for (size_t i = 0; i < ord.size(); i++) ord[i] = i;
    std::sort(ord.begin(), ord.end(),
              [&](size_t a, size_t b) { return below[a] < below[b]; });
    std::cout << "\n[O] PATH, SHALLOWEST FIRST (belowCount = how many path "
                 "objects contain it)\n";
    for (size_t k : ord)
        printf("  below=%-3d %-70s -> %s\n", below[k], ident(path[k]).c_str(),
               pout[k].str().c_str());

    size_t deep = ord.back();
    std::cout << "\n>>> DEEPEST PATH OBJECT (the OWNER of the failing "
                 "SafeCompare): "
              << ident(path[deep]) << "  file="
              << std::filesystem::path(std::string(path[deep]->VpiFile()))
                     .filename()
                     .string()
              << "\n    suppressing it yields: " << pout[deep].str() << "\n";
    return 0;
}
