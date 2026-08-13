// r10sd2 — WHO OWNS THE `LHS:<null>` SLOT?  ddmin over the GOLDEN objects, using
// `CompareContext::m_visited` as the suppression operator.
//
// WHAT IS ALREADY MEASURED (and why this tool exists):
//   * the failing RHS is our **TopPackages** copy of `uvm_pkg` (pointer-checked
//     against both package vectors), not the AllPackages one;
//   * seeding EVERY golden `package` object changes nothing, so the arm is NOT
//     the vector arm — the container is not a package, so `m_failedRhs` is the
//     CHILD and the arm is `SafeCompare(lhs=nullptr, rhs)`;
//   * `ct2ptr.cpp` shows the only relation in these databases that ever holds a
//     `package` is `vpiInstance`.
// Therefore some object X has `Instance()==nullptr` in golden and
// `Instance()==our top-view uvm_pkg` in ours.  Suppressing X — the OWNER, whose
// `Compare` body runs the failing `SafeCompare` — is what removes the head, and
// that is what this tool bisects for.
//
// NOT by nulling our side: nulling `Instance()` on our objects INTRODUCES a new,
// earlier `RHS:<null>` failure (measured — `ct2mut` flips the arm), so a
// null-mutation bisect converges on "the first typespec in traversal order",
// which is not the defect.  Suppression is the only operator that removes a
// comparison without adding one.
//
// build: g++ -O2 -std=c++17 ct2owner.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2owner
// usage: ct2owner <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

using namespace UHDM;

struct Rel { int id; const char* name; };
static const Rel kRels[] = {
#include "ct2rels.inc"
};
static const int kNRels = sizeof(kRels) / sizeof(kRels[0]);

static design *DA, *DB;
static std::string g_class;

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

// true == the `LHS:<null>` / `RHS: package` head SURVIVES this suppression set.
static bool alive(const std::vector<const BaseClass*>& seed) {
    CompareContext c;
    for (const BaseClass* s : seed) c.m_visited.insert(s);
    int r = DA->Compare(DB, &c);
    return r != 0 && c.m_failedLhs == nullptr && c.m_failedRhs &&
           c.m_failedRhs->UhdmType() == UHDM_OBJECT_TYPE::uhdmpackage;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct2owner <golden.uhdm> <ours.uhdm> [ownerClass]\n";
        return 2;
    }
    if (argc > 3) g_class = argv[3];
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    DA = (design*)((uhdm_handle*)ha[0])->object;
    DB = (design*)((uhdm_handle*)hb[0])->object;
    if (!alive({})) { std::cout << "HEAD ABSENT\n"; return 1; }

    // Candidates: golden objects that carry a singular Instance() and leave it
    // NULL — the only shape that can produce this arm.
    std::vector<const BaseClass*> cand;
    for (const auto& [p, i] : sa.AllObjects()) {
        if (!p) continue;
        const typespec* t = any_cast<const typespec*>(p);
        const variables* v = any_cast<const variables*>(p);
        const task_func* f = any_cast<const task_func*>(p);
        const ports* q = any_cast<const ports*>(p);
        const clocking_block* cb = any_cast<const clocking_block*>(p);
        const instance* in = any_cast<const instance*>(p);
        bool has = t || v || f || q || cb || in;
        if (!has) continue;
        // Optional class filter (argv[3]): narrow the candidate class so the
        // chokepoint ddmin lands on is the OWNER and not an ancestor.
        if (!g_class.empty()) {
            const char* kind = t ? "typespec" : v ? "variables"
                               : f ? "task_func" : q ? "ports"
                               : cb ? "clocking_block" : "instance";
            if (g_class != kind) continue;
        }
        const instance* val = t   ? t->Instance()
                              : v ? v->Instance()
                              : f ? f->Instance()
                              : q ? q->Instance()
                              : cb ? cb->Instance()
                                   : in->Instance();
        if (val == nullptr) cand.push_back(p);
    }
    std::cout << "golden objects with a NULL singular Instance(): " << cand.size()
              << "\n";
    if (alive(cand)) {
        std::cout << "SUPPRESSING ALL OF THEM DOES NOT REMOVE THE HEAD — the "
                     "owner is not in this candidate class\n";
        return 3;
    }
    std::cout << "suppressing all of them REMOVES the head: the owner is here\n";

    // ITERATED ddmin WITH EXCLUSION.  One ddmin lands on a CHOKEPOINT — the
    // shallowest golden object every path to the defect passes through — not on
    // the defect.  Excluding that chokepoint and re-running must land on a
    // chokepoint strictly BELOW it (the owner itself always kills the head, so a
    // killer set always exists).  Iterate until no killer remains: the last
    // singleton found is the deepest chokepoint, i.e. the owner.
    std::vector<const BaseClass*> found;
    std::vector<const BaseClass*> pool = cand;
    std::vector<const BaseClass*> c;
    for (int iter = 0; iter < 40; iter++) {
        if (pool.empty() || alive(pool)) {
            std::cout << "no killer left in the pool after " << iter
                      << " iterations\n";
            break;
        }
        c = pool;
        int gran = 2;
        while (c.size() > 1) {
            size_t n = c.size();
            size_t chunk = (n + gran - 1) / gran;
            bool progress = false;
            for (size_t s = 0; s < n; s += chunk) {
                std::vector<const BaseClass*> sub(
                    c.begin() + s, c.begin() + std::min(n, s + chunk));
                if (!alive(sub)) { c = sub; gran = 2; progress = true; break; }
            }
            if (!progress) {
                if (gran >= (int)n) break;
                gran = std::min<size_t>(gran * 2, n);
            }
        }
        if (c.size() != 1) {
            std::cout << "iteration " << iter << " stalled at " << c.size()
                      << " — reporting the set\n";
            for (size_t q = 0; q < c.size(); q++)
                std::cout << "    STALL " << ident(c[q]) << "  file="
                          << std::filesystem::path(std::string(c[q]->VpiFile()))
                                 .filename().string() << "\n";
            break;
        }
        found.push_back(c[0]);
        std::cout << "chokepoint[" << iter << "] " << ident(c[0]) << "  file="
                  << std::filesystem::path(std::string(c[0]->VpiFile()))
                         .filename()
                         .string()
                  << "\n";
        std::vector<const BaseClass*> np;
        for (auto* x : pool)
            if (x != c[0]) np.push_back(x);
        pool.swap(np);
    }
    std::cout << "\n>>> DEEPEST CHOKEPOINT (the owner): "
              << (found.empty() ? std::string("<none>") : ident(found.back()))
              << "\n";
    if (c.size() != 1) return 0;

    // ddmin lands on a CHOKEPOINT — the shallowest golden object every path to
    // the defect goes through — not on the defect.  Descend: a golden child
    // whose suppression alone also removes the head is a deeper chokepoint; when
    // no child qualifies, the failing `SafeCompare` is issued by THIS object's
    // own `Compare` body, and its NULL relations name the slot.
    std::cout << "\n=== DESCENT BY SUPPRESSION ===\n";
    const BaseClass* A = c[0];
    for (int d = 0; d < 60; d++) {
        std::cout << "[" << d << "] " << ident(A) << "\n";
        vpiHandle ah = NewVpiHandle(A);
        const BaseClass* next = nullptr;
        std::string via;
        for (int k = 0; k < kNRels && !next; k++) {
            const int rel = kRels[k].id;
            if (vpiHandle x = vpi_handle(rel, ah)) {
                const BaseClass* ch = (const BaseClass*)((uhdm_handle*)x)->object;
                if (ch != A && !alive({ch})) { next = ch; via = kRels[k].name; }
            }
            if (next) break;
            if (vpiHandle it = vpi_iterate(rel, ah)) {
                int j = 0;
                while (vpiHandle e = vpi_scan(it)) {
                    const BaseClass* ch =
                        (const BaseClass*)((uhdm_handle*)e)->object;
                    if (ch != A && !alive({ch})) {
                        next = ch;
                        via = std::string(kRels[k].name) + "[" +
                              std::to_string(j) + "]";
                        break;
                    }
                    j++;
                }
            }
        }
        if (!next) {
            std::cout << "  >>> NO CHILD IS A CHOKEPOINT — the failing "
                         "SafeCompare is issued by THIS object.\n";
            break;
        }
        std::cout << "  -> ." << via << "\n";
        A = next;
    }
    return 0;
}
