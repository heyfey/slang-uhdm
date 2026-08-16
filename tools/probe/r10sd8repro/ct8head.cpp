// r10sd8 — THE HEAD LOCALIZER.  `m_visited` IS the search space.
//
// ct8bis's whole-pool probe REFUTED the obvious bisection: nulling all 10 304
// `vpiInstance` slots that point at `uvm_pkg` moves the compare BACKWARDS
// (r=-1 visited=1653 -> r=1 visited=150), because the pool is mostly CORRECT
// stamps and removing them creates an earlier failure.  So "|visited| is
// monotone in the pool" is false and a set-bisection cannot be driven by it.
//
// What is true is much stronger: `design::Compare` gives up at the first
// failure, so only the ~1653 objects in `CompareContext::m_visited` are on the
// path at all.  Every other object in the database is irrelevant BY
// CONSTRUCTION.  This tool takes the baseline `m_visited` as the candidate set
// and tests its members ONE AT A TIME, which is affordable precisely because
// the set is three orders of magnitude smaller than the database.
//
// Each probe is judged by the whole tuple `(r, failedLhs, failedRhs,
// |visited|)` — sd7 R8's rule — and every slot is restored before the next.
//
// Modes:
//   --dump    print every visited object of OURS with its stamp and chain
//   --probe   null each visited object's vpiInstance in turn and report the
//             tuple, flagging any that ADVANCES the walk
//
// GUARD: an empty visited set, or a baseline that compares equal, is a hard
// error; a probe that does not restore the baseline aborts.
//
// build: g++ -O2 -std=c++17 ct8head.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct8head
// usage: ct8head <golden.uhdm> <ours.uhdm> [--dump|--probe]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static instance* getInst(const any* o) {
    if (auto* t = any_cast<const typespec*>(o))       return (instance*)t->Instance();
    if (auto* v = any_cast<const variables*>(o))      return (instance*)v->Instance();
    if (auto* f = any_cast<const task_func*>(o))      return (instance*)f->Instance();
    if (auto* p = any_cast<const ports*>(o))          return (instance*)p->Instance();
    if (auto* c = any_cast<const clocking_block*>(o)) return (instance*)c->Instance();
    if (auto* i = any_cast<const instance*>(o))       return (instance*)i->Instance();
    return nullptr;
}
static void setInst(any* o, instance* v) {
    if (auto* t = any_cast<typespec*>(o))       { t->Instance(v); return; }
    if (auto* x = any_cast<variables*>(o))      { x->Instance(v); return; }
    if (auto* f = any_cast<task_func*>(o))      { f->Instance(v); return; }
    if (auto* p = any_cast<ports*>(o))          { p->Instance(v); return; }
    if (auto* c = any_cast<clocking_block*>(o)) { c->Instance(v); return; }
    if (auto* i = any_cast<instance*>(o))       { i->Instance(v); return; }
}
static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    return s + "@" + std::to_string(p->VpiLineNo()) + ":" + std::to_string(p->VpiColumnNo()) +
           "-" + std::to_string(p->VpiEndLineNo()) + ":" + std::to_string(p->VpiEndColumnNo());
}
static std::string chainOf(const BaseClass* p) {
    std::string s;
    for (int i = 0; i < 7 && p; i++) { s += (i ? " < " : "") + ident(p); p = p->VpiParent(); }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct8head <golden> <ours> [--dump|--probe]\n"; return 2; }
    std::string mode = argc > 3 ? argv[3] : "--dump";
    Serializer sg, so;
    auto hg = sg.Restore(std::filesystem::path(argv[1]));
    auto ho = so.Restore(std::filesystem::path(argv[2]));
    if (hg.empty() || ho.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }
    auto* dg = (design*)((uhdm_handle*)hg[0])->object;
    auto* dobj = (design*)((uhdm_handle*)ho[0])->object;

    std::set<const BaseClass*> oursAll;
    for (const auto& [obj, id] : so.AllObjects()) if (obj) oursAll.insert(obj);
    std::set<const BaseClass*> allp, topp;
    if (auto* v = dobj->AllPackages()) for (auto* p : *v) allp.insert(p);
    if (auto* v = dobj->TopPackages()) for (auto* p : *v) topp.insert(p);
    auto view = [&](const instance* i) {
        if (!i) return std::string("<null>");
        std::string nm(i->VpiName());
        if (topp.count(i)) return "TOP:" + nm;
        if (allp.count(i)) return "ALL:" + nm;
        return "OTHER:" + nm;
    };

    CompareContext c0;
    int r0 = dg->Compare(dobj, &c0);
    size_t v0 = c0.m_visited.size();
    std::cout << "BASELINE r=" << r0 << " visited=" << v0
              << " failedLhs=" << (c0.m_failedLhs ? ident(c0.m_failedLhs) : "<null>")
              << " failedRhs=" << (c0.m_failedRhs ? ident(c0.m_failedRhs) : "<null>") << "\n";
    if (r0 == 0) { std::cerr << "REFUSING: baseline equal\n"; return 5; }
    if (v0 == 0) { std::cerr << "REFUSING: empty visited set\n"; return 5; }

    std::vector<const BaseClass*> vis(c0.m_visited.begin(), c0.m_visited.end());
    size_t nOurs = 0, nGold = 0;
    std::map<std::string, int> byKind;
    for (auto* o : vis) {
        bool mine = oursAll.count(o) != 0;
        mine ? nOurs++ : nGold++;
        byKind[std::string(mine ? "OURS " : "GOLD ") + UhdmName(o->UhdmType())]++;
    }
    std::cout << "visited: ours=" << nOurs << " golden=" << nGold << "\n";
    for (auto& [k, n] : byKind) std::cout << "   " << n << "\t" << k << "\n";

    if (mode == "--dump") {
        for (auto* o : vis) {
            if (!oursAll.count(o)) continue;
            auto* in = getInst((const any*)o);
            std::cout << "OURS " << (in ? view(in) : std::string("-")) << "\t" << chainOf(o) << "\n";
        }
        return 0;
    }

    if (mode == "--cand") {
        // `m_visited` holds LHS (GOLDEN) objects only — measured, not assumed:
        // the ours/golden split above prints ours=0.  So the search runs from
        // golden's side: every visited golden object whose own vpiInstance is
        // NULL is a possible LHS of the failing `SafeCompare(nullptr, rhs)`.
        // Its twin of ours is found by the ct8cens key, and a twin that IS
        // stamped is a candidate.  Each candidate is then PROBED — nulled, the
        // whole design re-compared — so the report is a measurement and not a
        // join.
        std::map<std::string, std::vector<BaseClass*>> ourByKey;
        for (const auto& [obj, id] : so.AllObjects()) {
            if (!obj) continue;
            const any* a = (const any*)obj;
            if (!any_cast<const typespec*>(a) && !any_cast<const variables*>(a) &&
                !any_cast<const task_func*>(a) && !any_cast<const ports*>(a) &&
                !any_cast<const clocking_block*>(a) && !any_cast<const instance*>(a))
                continue;
            ourByKey[chainOf(obj)].push_back((BaseClass*)obj);
        }
        size_t cand = 0, adv = 0;
        for (auto* o : vis) {
            const any* a = (const any*)o;
            if (!any_cast<const typespec*>(a) && !any_cast<const variables*>(a) &&
                !any_cast<const task_func*>(a) && !any_cast<const ports*>(a) &&
                !any_cast<const clocking_block*>(a) && !any_cast<const instance*>(a))
                continue;
            if (getInst(a)) continue;  // golden stamped: not an LHS-null pair
            auto it = ourByKey.find(chainOf(o));
            if (it == ourByKey.end()) continue;
            for (auto* mine : it->second) {
                auto* in = getInst((const any*)mine);
                if (!in) continue;
                cand++;
                setInst((any*)mine, nullptr);
                CompareContext c;
                int r = dg->Compare(dobj, &c);
                size_t v = c.m_visited.size();
                setInst((any*)mine, in);
                const char* tag = (v > v0) ? "ADVANCE" : (r == r0 && v == v0) ? "inert  " : "REGRESS";
                if (v > v0) adv++;
                std::cout << tag << " r=" << r << " visited=" << v << "  ours=" << view(in)
                          << "  " << chainOf(mine) << "\n";
            }
        }
        std::cout << "[S] CANDIDATES=" << cand << " ADVANCING=" << adv << "\n";
        if (cand == 0) {
            std::cerr << "REFUSING TO REPORT: zero candidates — golden's visited set has no "
                         "null-instance object with a stamped twin of ours\n";
            return 5;
        }
        return 0;
    }

    if (mode == "--brute") {
        // THE EXHAUSTIVE ONE.  `--cand` depends on a KEY JOIN to find our twin
        // of a golden object, and a join that misses reports "no candidate"
        // exactly like "no defect".  This mode uses no key at all: it nulls
        // EVERY stamped vpiInstance slot in our database in turn and re-runs
        // the whole-design Compare.  Affordable because Compare bails at the
        // first failure — the baseline walks 1653 objects, not 300 000.
        std::vector<std::pair<BaseClass*, instance*>> pool;
        for (const auto& [obj, id] : so.AllObjects()) {
            if (!obj) continue;
            auto* in = getInst((const any*)obj);
            if (in) pool.push_back({(BaseClass*)obj, in});
        }
        std::cout << "brute pool=" << pool.size() << "\n";
        if (pool.empty()) { std::cerr << "REFUSING: empty pool\n"; return 5; }
        size_t adv = 0, reg = 0;
        for (auto& [o, in] : pool) {
            setInst((any*)o, nullptr);
            CompareContext c;
            int r = dg->Compare(dobj, &c);
            size_t v = c.m_visited.size();
            setInst((any*)o, in);
            if (v > v0) {
                adv++;
                std::cout << "ADVANCE r=" << r << " visited=" << v << "  ours=" << view(in)
                          << "  " << chainOf(o) << "\n";
            } else if (r != r0 || v != v0)
                reg++;
        }
        CompareContext cz;
        int rz = dg->Compare(dobj, &cz);
        if (rz != r0 || cz.m_visited.size() != v0) {
            std::cerr << "REFUSING: baseline not restored after probing\n";
            return 6;
        }
        std::cout << "[S] BRUTE_PROBED=" << pool.size() << " ADVANCING=" << adv
                  << " REGRESSING=" << reg << " (baseline restored)\n";
        return 0;
    }

    // --probe: null each visited object's own vpiInstance, one at a time.
    size_t tried = 0, movers = 0;
    for (auto* o : vis) {
        if (!oursAll.count(o)) continue;
        auto* in = getInst((const any*)o);
        if (!in) continue;
        tried++;
        setInst((any*)o, nullptr);
        CompareContext c;
        int r = dg->Compare(dobj, &c);
        size_t v = c.m_visited.size();
        setInst((any*)o, in);
        if (r == r0 && v == v0) continue;
        movers++;
        std::cout << (v > v0 ? "ADVANCE " : "REGRESS ") << "r=" << r << " visited=" << v
                  << "  slot=" << view(in) << "  " << chainOf(o) << "\n";
    }
    CompareContext cz;
    int rz = dg->Compare(dobj, &cz);
    if (rz != r0 || cz.m_visited.size() != v0) {
        std::cerr << "REFUSING: baseline not restored after probing\n";
        return 6;
    }
    std::cout << "[S] PROBED=" << tried << " MOVERS=" << movers << " (baseline restored)\n";
    return 0;
}
