// r10sd4 — THE LOCALIZER.  Set-valued suppression driven by a REACHABILITY-
// FILTERED, span-keyed MULTISET census, instead of a blind ddmin over 34299
// golden objects.
//
// WHY THIS TOOL EXISTS (read r10sd2repro/README.md §4.3 first):
//   sd2's single-object ddmin (`ct2owner.cpp`) STALLS at 34 `class_typespec`
//   chokepoints.  Its search only ever tests SUBSETS of the current candidate
//   set, never COMPLEMENTS, so it can converge into an ANCESTOR CUT — a set of
//   objects that together block every path to the defect — instead of onto the
//   defect's OWNER.  A cut of size >= 2 exists whenever the owner is reachable
//   by two disjoint routes, and once ddmin is inside a cut it can no longer see
//   the owner at all.  Widening that search is one option; this tool takes the
//   cheaper one.
//
//   The owner is characterised EXACTLY: some object X that `Compare` REACHES
//   has `Instance() == nullptr` in golden and `Instance() == a package` in
//   ours.  That is a statement about CONTENT, so it can be read off a census
//   directly — no search — provided the census
//     (a) keeps the whole MULTISET per key (Surelog emits one copy of every
//         package-homed object PER PACKAGE VIEW; a one-value-per-key census
//         collapses them — sd2 §4.5, and that collapse is exactly what made
//         sd1 R1 report "0 typespecs where golden is null and ours is
//         uvm_pkg"), and
//     (b) is restricted to objects `Compare` can REACH.  sd3-verifier F3 proved
//         the `weaklyReferenced` pool is cmp-INERT: 428 slots changed there and
//         not one cmp head moved.  An unfiltered census is mostly that pool.
//
//   Then each candidate key is CONFIRMED by suppression — `m_visited` seeded
//   with golden's objects at that key — which is the same operator sd2 proved
//   sound (`m_visited.insert(this)` is keyed on the LHS, so suppressing X
//   removes every comparison in which X is the LHS, by whatever path it is
//   reached).  Census PROPOSES, suppression DISPOSES.
//
// NOT by nulling our side: nulling `Instance()` on our objects INTRODUCES an
// earlier `RHS:<null>` failure (sd2 §4.4.2), so a null-mutation bisect converges
// on the first typespec in traversal order and looks like a result.
//
// *** SECTIONS [S] AND [K] ARE KEPT AS THE RECORD OF A WRONG METHOD. ***
// The per-key package SURPLUS is NOT the pairing `Compare` makes: `Compare`
// walks two trees positionally, while a span key groups a whole multiset, so an
// owner whose key shows no surplus (golden has an extra copy at the same key) is
// invisible to it.  Measured: 1205 candidate keys, 1501 surplus slots, and
// ZERO killers — while the owner was in the database all along.  Section [A],
// the reachability-filtered state census, IS sound and is this pass's mover
// scoreboard; only the CANDIDATE SELECTION below it is the wrong idea.
//
// build: g++ -O2 -std=c++17 ct4reach.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4reach
// usage: ct4reach <golden.uhdm> <ours.uhdm> [maxkeys]
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <sstream>
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

static std::string spanKey(const BaseClass* p) {
    std::ostringstream k;
    k << UhdmName(p->UhdmType()) << "|" << p->VpiName() << "|" << p->VpiLineNo()
      << ":" << p->VpiColumnNo() << "-" << p->VpiEndLineNo() << ":"
      << p->VpiEndColumnNo();
    return k.str();
}

// The head under test: the SINGULAR SafeCompare(lhs=nullptr, rhs=package) arm.
// GUARD: this must be checked with an EMPTY seed before anything else, or a
// tool that cannot see the head at all reports every suppression as a kill.
static bool aliveSeed(const std::vector<const BaseClass*>& seed) {
    CompareContext c;
    for (const BaseClass* s : seed) c.m_visited.insert(s);
    int r = DA->Compare(DB, &c);
    return r != 0 && c.m_failedLhs == nullptr && c.m_failedRhs &&
           c.m_failedRhs->UhdmType() == UHDM_OBJECT_TYPE::uhdmpackage;
}

// ---- reachability: BFS from the design over every relation the VPI layer
// exposes.  `vpiParent` is NOT in ct2rels.inc, deliberately: including it makes
// every object reachable from any object and the filter degenerates.
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

static const instance* instOf(const BaseClass* p) {
    const typespec* t = any_cast<const typespec*>(p);
    if (t) return t->Instance();
    const variables* v = any_cast<const variables*>(p);
    if (v) return v->Instance();
    const task_func* f = any_cast<const task_func*>(p);
    if (f) return f->Instance();
    const ports* q = any_cast<const ports*>(p);
    if (q) return q->Instance();
    const clocking_block* cb = any_cast<const clocking_block*>(p);
    if (cb) return cb->Instance();
    return nullptr;
}
static bool carriesInstance(const BaseClass* p) {
    return any_cast<const typespec*>(p) || any_cast<const variables*>(p) ||
           any_cast<const task_func*>(p) || any_cast<const ports*>(p) ||
           any_cast<const clocking_block*>(p);
}

struct Side {
    Serializer ser;
    design* d = nullptr;
    std::set<const BaseClass*> reach;
    std::map<std::string, std::map<std::string, int>> byKey;   // key->state->n
    std::map<std::string, std::vector<const BaseClass*>> objs; // key->objects
    std::map<const BaseClass*, std::string> pkgState;
    long total = 0, withInst = 0;
};

static std::string classify(const Side& s, const instance* val) {
    if (!val) return "<null>";
    auto it = s.pkgState.find((const BaseClass*)val);
    if (it != s.pkgState.end()) return it->second;
    return "OTHER:" + std::string(UhdmName(val->UhdmType())) + "(" +
           std::string(val->VpiName()) + ")";
}

static void load(Side& s, const char* path) {
    auto h = s.ser.Restore(std::filesystem::path(path));
    if (h.empty()) { std::cerr << "RESTORE_FAIL " << path << "\n"; exit(3); }
    s.d = (design*)((uhdm_handle*)h[0])->object;
    if (s.d->AllPackages())
        for (auto* p : *s.d->AllPackages())
            s.pkgState[p] = "ALL:" + std::string(p->VpiName());
    if (s.d->TopPackages())
        for (auto* p : *s.d->TopPackages())
            s.pkgState[p] = "TOP:" + std::string(p->VpiName());
    reach(s.d, s.reach);
    for (const BaseClass* p : s.reach) {
        s.total++;
        if (!carriesInstance(p)) continue;
        s.withInst++;
        std::string k = spanKey(p);
        s.byKey[k][classify(s, instOf(p))]++;
        s.objs[k].push_back(const_cast<BaseClass*>(p));
    }
}

static bool isPkgState(const std::string& st) {
    return st.rfind("ALL:", 0) == 0 || st.rfind("TOP:", 0) == 0;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct4reach <golden.uhdm> <ours.uhdm> [maxkeys]\n";
        return 2;
    }
    int maxkeys = argc > 3 ? atoi(argv[3]) : 40;
    static Side G, O;
    load(G, argv[1]);
    load(O, argv[2]);
    DA = G.d;
    DB = O.d;

    std::cout << "[R] REACHABLE from design (154 relations, vpiParent excluded)\n";
    printf("    golden reachable=%ld  with singular Instance()=%ld  keys=%zu\n",
           G.total, G.withInst, G.byKey.size());
    printf("    ours   reachable=%ld  with singular Instance()=%ld  keys=%zu\n",
           O.total, O.withInst, O.byKey.size());

    // Whole-reachable state totals — the sd2 §1.1 table, reachability-filtered.
    std::map<std::string, int> gt, ot;
    for (auto& [k, m] : G.byKey) for (auto& [st, n] : m) gt[st] += n;
    for (auto& [k, m] : O.byKey) for (auto& [st, n] : m) ot[st] += n;
    std::cout << "\n[A] vpiInstance state totals, REACHABLE ONLY\n";
    printf("%-46s %9s %9s %9s\n", "state", "GOLDEN", "OURS", "DELTA");
    std::set<std::string> sts;
    for (auto& [k, v] : gt) sts.insert(k);
    for (auto& [k, v] : ot) sts.insert(k);
    for (const auto& st : sts)
        printf("%-46s %9d %9d %+9d\n", st.c_str(), gt[st], ot[st],
               ot[st] - gt[st]);

    if (!aliveSeed({})) {
        std::cout << "\nHEAD ABSENT (empty seed) — nothing to localize\n";
        return 1;
    }
    std::cout << "\nHEAD PRESENT with an empty seed (negative control passed)\n";

    // [S] the candidate keys: OURS holds a package state that golden does not
    // hold as often, i.e. a per-key SURPLUS of a package-valued vpiInstance.
    struct Cand { std::string key; std::string state; int surplus; };
    std::vector<Cand> cands;
    for (const auto& [k, om] : O.byKey) {
        auto git = G.byKey.find(k);
        for (const auto& [st, n] : om) {
            if (!isPkgState(st)) continue;
            int g = 0;
            if (git != G.byKey.end()) {
                auto i2 = git->second.find(st);
                if (i2 != git->second.end()) g = i2->second;
            }
            if (n > g) cands.push_back({k, st, n - g});
        }
    }
    std::sort(cands.begin(), cands.end(),
              [](const Cand& a, const Cand& b) { return a.surplus > b.surplus; });
    std::cout << "\n[S] KEYS WHERE OURS HAS A PACKAGE-VALUED vpiInstance SURPLUS: "
              << cands.size() << "\n";
    long tot = 0;
    for (auto& c : cands) tot += c.surplus;
    std::cout << "    total surplus slots = " << tot << "\n";

    // [K] confirm by suppression, key by key, most-surplus first.
    std::cout << "\n[K] SUPPRESSION TEST (seed = golden's objects at the key)\n";
    int shown = 0;
    std::vector<std::string> killers;
    for (auto& c : cands) {
        if (shown++ >= maxkeys) break;
        auto git = G.objs.find(c.key);
        std::vector<const BaseClass*> seed;
        if (git != G.objs.end()) seed = git->second;
        bool kill = !seed.empty() && !aliveSeed(seed);
        std::ostringstream g, o;
        auto gm = G.byKey.find(c.key);
        if (gm != G.byKey.end())
            for (auto& [st, n] : gm->second) g << st << "=" << n << " ";
        else
            g << "<key absent>";
        for (auto& [st, n] : O.byKey[c.key]) o << st << "=" << n << " ";
        printf("%-6s surplus=%-4d %s\n", kill ? "KILLS" : "-", c.surplus,
               c.key.c_str());
        printf("        golden: %s\n        ours  : %s\n", g.str().c_str(),
               o.str().c_str());
        if (kill) killers.push_back(c.key);
    }
    std::cout << "\n>>> KILLER KEYS: " << killers.size() << "\n";
    for (auto& k : killers) std::cout << "    " << k << "\n";

    // [P] parent chains of the killer keys' objects, both sides.
    for (auto& k : killers) {
        std::cout << "\n[P] " << k << "\n";
        for (int side = 0; side < 2; side++) {
            Side& S = side ? O : G;
            std::cout << (side ? "  OURS:\n" : "  GOLDEN:\n");
            for (const BaseClass* p : S.objs[k]) {
                std::cout << "    " << ident(p)
                          << "  inst=" << classify(S, instOf(p)) << "\n      chain:";
                const BaseClass* q = p->VpiParent();
                for (int d = 0; d < 8 && q; d++) {
                    std::cout << " <- " << ident(q);
                    q = q->VpiParent();
                }
                std::cout << "\n";
            }
        }
    }
    return 0;
}
