// r10sd4 — EXHAUSTIVE SINGLETON SUPPRESSION SCAN.  The instrument that replaces
// ddmin entirely.
//
// sd2 built a ddmin because it assumed a whole-design `Compare` was expensive.
// MEASURED HERE: one `design::Compare` over the SeqDriver pair costs ~1.5 ms,
// because `Compare` ABORTS AT THE FIRST FAILURE — the 1.4 M cmp lines are the
// SUBTREE DUMP of the failing object, not a traversal count (the standing
// campaign law "head = SUBTREE", now with a cost model attached).  So the whole
// candidate pool can be tested ONE OBJECT AT A TIME:
//
//     34290 reachable golden objects with a NULL singular Instance()
//       x 1.5 ms  =  ~50 seconds.
//
// A linear scan is EXHAUSTIVE where a ddmin is a search: it cannot converge into
// an ancestor cut (sd2's 34-chokepoint stall), it cannot be defeated by parallel
// paths, and it returns EVERY singleton killer rather than one.  The owner is
// then the DEEPEST killer — the one with no killer below it — and this tool
// prints the killers with their parent chains so that ordering can be read off.
//
// MODES (argv[3]):
//   nullinst  (default) — golden objects whose singular Instance() is NULL.
//                         The candidate class implied by an `LHS:<null>` head on
//                         a package-valued slot, given that `vpiInstance` is the
//                         only relation in these databases that can hold a
//                         package (sd2 §4.2, 154-relation census).
//   all                 — every reachable golden object, ~317 k, ~8 min.  The
//                         mode that does not assume the relation, used to prove
//                         the `nullinst` pool is not begging the question.
//   serial              — EVERY object in `Serializer::AllObjects()`, reachable
//                         or not.  The mode that does not assume the WALK
//                         either: `ct2rels.inc` is generated from
//                         `vpi_visitor.cpp` and does NOT cover every relation
//                         `Compare` descends (`Instance_items` and
//                         `Deriveds` have no listed relation id), so a BFS over
//                         VPI relations can MISS the owner.  Measured here: the
//                         `all` mode's deepest killer is a `class_defn`, whose
//                         `Compare` body (generated/src/class_defn.cpp:159-163
//                         plus scope's 17 vectors) contains NO singular slot
//                         that can hold a package — proof by itself that the
//                         real owner lies below a relation the BFS did not
//                         follow.
//   visited             — THE POOL THAT CANNOT MISS AND CANNOT BE PADDED.
//                         Every generated `Compare` body OPENS with
//                         `m_visited.insert(this)`, keyed on the LHS.  So the
//                         owner — the object whose OWN body issues the failing
//                         `SafeCompare` — is necessarily IN `m_visited` when the
//                         baseline `Compare` returns.  On SeqDriver that set is
//                         1613 objects out of 316922 reachable and ~400 k
//                         serialized: a 2-second exhaustive scan, and it needs
//                         no assumption about relations, reachability, or which
//                         slot holds the package.
//
// GUARD: the head is asserted PRESENT with an empty seed before any candidate is
// tested.  A scanner that cannot see the head reports every suppression as a
// kill, and that failure mode is silent.
//
// build: g++ -O2 -std=c++17 ct4scan.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4scan
// usage: ct4scan <golden.uhdm> <ours.uhdm> [nullinst|all|serial|visited]
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <chrono>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

struct Rel { int id; const char* name; };
static const Rel kRels[] = {
#include "ct2rels.inc"
};
static const int kNRels = sizeof(kRels) / sizeof(kRels[0]);

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

static bool aliveSeed(const std::vector<const BaseClass*>& seed) {
    CompareContext c;
    for (const BaseClass* s : seed) c.m_visited.insert(s);
    int r = DA->Compare(DB, &c);
    return r != 0 && c.m_failedLhs == nullptr && c.m_failedRhs &&
           c.m_failedRhs->UhdmType() == UHDM_OBJECT_TYPE::uhdmpackage;
}

static void reach(design* d, std::set<const BaseClass*>& out) {
    std::vector<const BaseClass*> stack{d};
    out.insert(d);
    while (!stack.empty()) {
        const BaseClass* a = stack.back();
        stack.pop_back();
        vpiHandle ah = NewVpiHandle(a);
        for (int k = 0; k < kNRels; k++) {
            const int rel = kRels[k].id;
            if (vpiHandle x = vpi_handle(rel, ah)) {
                const BaseClass* ch = (const BaseClass*)((uhdm_handle*)x)->object;
                if (ch && out.insert(ch).second) stack.push_back(ch);
            }
            if (vpiHandle it = vpi_iterate(rel, ah)) {
                while (vpiHandle e = vpi_scan(it)) {
                    const BaseClass* ch =
                        (const BaseClass*)((uhdm_handle*)e)->object;
                    if (ch && out.insert(ch).second) stack.push_back(ch);
                }
            }
        }
    }
}

static bool carriesInstance(const BaseClass* p) {
    return any_cast<const typespec*>(p) || any_cast<const variables*>(p) ||
           any_cast<const task_func*>(p) || any_cast<const ports*>(p) ||
           any_cast<const clocking_block*>(p) || any_cast<const instance*>(p);
}
static const instance* instOf(const BaseClass* p) {
    if (auto* t = any_cast<const typespec*>(p)) return t->Instance();
    if (auto* v = any_cast<const variables*>(p)) return v->Instance();
    if (auto* f = any_cast<const task_func*>(p)) return f->Instance();
    if (auto* q = any_cast<const ports*>(p)) return q->Instance();
    if (auto* cb = any_cast<const clocking_block*>(p)) return cb->Instance();
    if (auto* in = any_cast<const instance*>(p)) return in->Instance();
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct4scan <golden.uhdm> <ours.uhdm> [nullinst|all|serial|visited]\n";
        return 2;
    }
    std::string mode = argc > 3 ? argv[3] : "nullinst";
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    DA = (design*)((uhdm_handle*)ha[0])->object;
    DB = (design*)((uhdm_handle*)hb[0])->object;

    // negative control FIRST
    {
        CompareContext c;
        int r = DA->Compare(DB, &c);
        std::cout << "BASELINE r=" << r << " lhs=" << ident(c.m_failedLhs)
                  << " rhs=" << ident(c.m_failedRhs) << "\n";
        std::cout << "  m_visited after baseline = " << c.m_visited.size()
                  << " objects\n";
        // which VIEW is the RHS?
        if (c.m_failedRhs) {
            std::string view = "NEITHER-VECTOR";
            if (DB->AllPackages())
                for (auto* p : *DB->AllPackages())
                    if ((const BaseClass*)p == c.m_failedRhs) view = "ours AllPackages";
            if (DB->TopPackages())
                for (auto* p : *DB->TopPackages())
                    if ((const BaseClass*)p == c.m_failedRhs) view = "ours TopPackages";
            std::cout << "  RHS view = " << view << "\n";
        }
    }
    if (!aliveSeed({})) { std::cout << "HEAD ABSENT — abort\n"; return 1; }

    std::set<const BaseClass*> R;
    reach(DA, R);
    std::vector<const BaseClass*> cand;
    if (mode == "visited") {
        CompareContext c;
        DA->Compare(DB, &c);
        for (const BaseClass* p : c.m_visited) cand.push_back(p);
    } else if (mode == "serial") {
        for (const auto& [p, i] : sa.AllObjects())
            if (p) cand.push_back(p);
    } else {
        for (const BaseClass* p : R) {
            if (mode == "all") { cand.push_back(p); continue; }
            if (!carriesInstance(p)) continue;
            if (instOf(p) == nullptr) cand.push_back(p);
        }
    }
    std::cout << "golden reachable=" << R.size() << "  candidates(" << mode
              << ")=" << cand.size() << "\n";

    auto t0 = std::chrono::steady_clock::now();
    std::vector<const BaseClass*> killers;
    for (size_t i = 0; i < cand.size(); i++) {
        if (!aliveSeed({cand[i]})) killers.push_back(cand[i]);
        if ((i % 5000) == 4999) {
            auto dt = std::chrono::duration_cast<std::chrono::seconds>(
                          std::chrono::steady_clock::now() - t0)
                          .count();
            std::cout << "  ... " << (i + 1) << "/" << cand.size() << "  killers="
                      << killers.size() << "  " << dt << "s\n"
                      << std::flush;
        }
    }
    std::cout << "\n>>> SINGLETON KILLERS: " << killers.size() << "\n";

    // The killers form the ancestor chain(s) plus the owner.  Print each with
    // its parent chain; the OWNER is the killer that has no other killer below
    // it, which the chains make readable.
    std::set<const BaseClass*> KS(killers.begin(), killers.end());
    for (const BaseClass* k : killers) {
        int ancestorKillers = 0;
        const BaseClass* q = k->VpiParent();
        for (int d = 0; d < 64 && q; d++) {
            if (KS.count(q)) ancestorKillers++;
            q = q->VpiParent();
        }
        std::cout << "KILLER " << ident(k) << "  file="
                  << std::filesystem::path(std::string(k->VpiFile()))
                         .filename()
                         .string()
                  << "  killerAncestors=" << ancestorKillers << "\n";
        q = k->VpiParent();
        std::cout << "   chain:";
        for (int d = 0; d < 8 && q; d++) {
            std::cout << " <- " << ident(q);
            q = q->VpiParent();
        }
        std::cout << "\n";
    }
    return 0;
}
