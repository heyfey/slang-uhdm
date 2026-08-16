// r10sd4 — WHICH KILLER IS THE OWNER, and what does OUR twin hold?
//
// `ct4scan` returns EVERY golden object whose suppression removes the head.
// They are not alternatives: `Compare` aborts at the FIRST failure, so an object
// whose suppression changes the outcome must lie on the traversal path to that
// failure.  The killers are therefore a CHAIN, and the OWNER — the object whose
// own `Compare` body issues `SafeCompare(lhs->Instance(), rhs->Instance())` with
// a null LHS — is the DEEPEST of them.
//
// THE ORDERING TEST.  `CompareContext::m_visited` is the traversal's own record.
// For killers A and B:  B is BELOW A  iff  suppressing A stops B being visited.
// That is a direct read of the traversal, not an inference from `VpiParent` —
// and `VpiParent` is the WRONG chain here: `Compare` descends by relation, and
// two of SeqDriver's four killers have no `VpiParent` at all.
//
// Then the OURS side: the owner's twin is found by span key among OUR reachable
// objects, and its `Instance()` is printed with its package VIEW.  That closes
// the head: golden NULL vs ours <a package>.
//
// *** KEPT AS THE RECORD OF A WRONG METHOD — READ THIS BEFORE REUSING IT. ***
// Its answer for SeqDriver is `class_defn(adpcm_seq_item)`, and that is WRONG.
// `class_defn::Compare` (generated/src/class_defn.cpp:159-163, plus scope's 17
// vectors) contains NO singular slot that can hold a package, so it cannot
// possibly issue `SafeCompare(nullptr, package)`.  The ordering test is sound;
// the KILL test underneath it is not, because Surelog emits every package TWICE
// and the head's shape RECURS in the other view with the SAME `m_failedRhs`
// POINTER — so an object that IS on the path can read as "not a killer".
// The real owner is a `bit_typespec`, read off a gdb watchpoint by `ct4bt`.
//
// THE CHEAP CHECK this failure suggests, for any suppression-derived answer:
// can the named class's `Compare` body even ISSUE the arm you claim?
//
// build: g++ -O2 -std=c++17 ct4own.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4own
// usage: ct4own <golden.uhdm> <ours.uhdm> [nullinst|all]
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

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
static bool aliveSeed(const std::vector<const BaseClass*>& seed,
                      std::set<const BaseClass*>* vis = nullptr) {
    CompareContext c;
    for (const BaseClass* s : seed) c.m_visited.insert(s);
    int r = DA->Compare(DB, &c);
    if (vis) *vis = c.m_visited;
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
static std::map<const BaseClass*, std::string> pkgStateOf(design* d) {
    std::map<const BaseClass*, std::string> m;
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) m[p] = "ALL:" + std::string(p->VpiName());
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) m[p] = "TOP:" + std::string(p->VpiName());
    return m;
}
static std::string classify(const std::map<const BaseClass*, std::string>& ps,
                            const instance* v) {
    if (!v) return "<null>";
    auto it = ps.find((const BaseClass*)v);
    if (it != ps.end()) return it->second;
    return "OTHER:" + std::string(UhdmName(v->UhdmType())) + "(" +
           std::string(v->VpiName()) + ")";
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct4own <golden> <ours> [nullinst|all]\n";
        return 2;
    }
    std::string mode = argc > 3 ? argv[3] : "all";
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    DA = (design*)((uhdm_handle*)ha[0])->object;
    DB = (design*)((uhdm_handle*)hb[0])->object;
    if (!aliveSeed({})) { std::cout << "HEAD ABSENT — abort\n"; return 1; }

    std::set<const BaseClass*> RG, RO;
    reach(DA, RG);
    reach(DB, RO);
    auto psG = pkgStateOf(DA), psO = pkgStateOf(DB);

    std::vector<const BaseClass*> cand;
    for (const BaseClass* p : RG) {
        if (mode == "all") { cand.push_back(p); continue; }
        if (carriesInstance(p) && instOf(p) == nullptr) cand.push_back(p);
    }
    std::cout << "candidates(" << mode << ")=" << cand.size() << "\n";
    std::vector<const BaseClass*> K;
    for (const BaseClass* p : cand)
        if (!aliveSeed({p})) K.push_back(p);
    std::cout << "singleton killers: " << K.size() << "\n";

    // ORDERING: B is BELOW A iff suppressing A stops B being visited.
    std::cout << "\n[O] TRAVERSAL ORDER (rows = suppressed A; '.' = B no longer "
                 "visited => B is BELOW A)\n";
    std::vector<std::set<const BaseClass*>> vis(K.size());
    for (size_t i = 0; i < K.size(); i++) aliveSeed({K[i]}, &vis[i]);
    std::set<const BaseClass*> visBase;
    aliveSeed({}, &visBase);
    std::vector<int> below(K.size(), 0);
    for (size_t i = 0; i < K.size(); i++) {
        std::cout << "  A=" << ident(K[i]) << "\n";
        for (size_t j = 0; j < K.size(); j++) {
            if (i == j) continue;
            bool wasVisited = visBase.count(K[j]) > 0;
            bool stillVisited = vis[i].count(K[j]) > 0;
            if (wasVisited && !stillVisited) {
                below[j]++;
                std::cout << "      BELOW: " << ident(K[j]) << "\n";
            }
        }
    }
    size_t deepest = 0;
    for (size_t i = 0; i < K.size(); i++)
        if (below[i] > below[deepest]) deepest = i;
    std::cout << "\n>>> DEEPEST KILLER (the OWNER): " << ident(K[deepest])
              << "  file="
              << std::filesystem::path(std::string(K[deepest]->VpiFile()))
                     .filename()
                     .string()
              << "   (below-count " << below[deepest] << ")\n";

    // OURS twin, by span key.
    for (size_t i = 0; i < K.size(); i++) {
        std::cout << "\n[T] " << (i == deepest ? "OWNER " : "      ")
                  << ident(K[i]) << "  file="
                  << std::filesystem::path(std::string(K[i]->VpiFile()))
                         .filename()
                         .string()
                  << "  belowCount=" << below[i] << "\n";
        std::cout << "    golden Instance = " << classify(psG, instOf(K[i]))
                  << "\n";
        std::string key = spanKey(K[i]);
        int n = 0;
        for (const BaseClass* p : RO) {
            if (!carriesInstance(p) || spanKey(p) != key) continue;
            std::cout << "    ours[" << n++ << "] " << ident(p)
                      << "  Instance = " << classify(psO, instOf(p))
                      << "  parent = " << ident(p->VpiParent()) << "\n";
        }
        if (!n) std::cout << "    ours: NO OBJECT WITH THIS KEY IS REACHABLE\n";
    }
    return 0;
}
