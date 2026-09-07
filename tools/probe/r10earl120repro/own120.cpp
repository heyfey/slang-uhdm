// r10earl120 — THE OWNER-FINDER for a `LHS: <package>` / `RHS: <null>` head.
//
// MEASUREMENT ONLY.  The official `uhdm-cmp` stays the sole acceptance judge.
// slang is NOT patched here and no acceptance number comes out of this file.
//
// WHY.  `BaseClass::SafeCompare(lhs, rhs, ctx)` with `rhs == nullptr`
// (BaseClass.h:187-193) sets ONLY `m_failedLhs`, and sets it to the POINTEE.
// So the Earlgrey_0_1/default head `LHS: package top_pkg` / `RHS: <null>`
// names the TARGET of a golden edge and HIDES the owner that holds it.
// r10earl119's `r0next119` already proved the edge is NOT a
// `design::AllPackages` / `design::TopPackages` vector slot (both 40 entries,
// no nulls, identical pairing) and NOT anything inside the package (the
// isolated `top_pkg` pair `Compare`s to 0 with every container equal).
// Therefore it is a SINGULAR relation somewhere else in the design.
//
// HOW.  Two independent instruments that must agree:
//
//  (A) FIELD SCAN.  Every generated `<kind>::Compare` was read
//      (`~/git-repos/UHDM/build/generated/src/*.cpp`) and every SINGULAR
//      `SafeCompare(lhs->F(), rhs->F(), …)` field whose declared type can
//      hold a `package` was enumerated:
//        instance::Instance, typespec::Instance, variables::Instance,
//        variables::Scope, ports::Instance, task_func::Instance,
//        clocking_block::Instance, clocking_block::Actual,
//        tf_call::Scope, ref_obj::Actual_group, ref_var::Actual_group,
//        ref_module::Actual_group, chandle_var::Actual_group,
//        gen_scope_array::VpiInstance, import_typespec::Item.
//      The scan reports, for BOTH databases, every object holding each such
//      edge to the named package — the census that answers "which owner kind".
//
//  (B) MASK-AND-RERUN.  Every generated `Compare` opens with
//        if (!context->m_visited.insert(this).second) return r;   // LHS-keyed
//      so seeding a golden object into a FRESH context's `m_visited` makes its
//      whole `Compare` return 0.  Seeding the field-scan pool must MOVE the
//      head (else the pool is inert and the answer is elsewhere); bisecting
//      the pool names the FIRST owner the official walk reaches.  Each rerun
//      uses a fresh `CompareContext` seeded with the mask only; the located
//      object is re-verified ALONE.
//
// GUARDS: `--calib` compares golden against itself and must print NO HEAD;
// POOL-INERT is printed instead of bisecting to an arbitrary answer; a
// single-object mask that fails to move the head prints NOT-SINGLE.
//
// build: g++ -O2 -std=c++17 own120.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own120
// usage: own120 <golden.uhdm> <ours.uhdm> [--calib] [--nobisect]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
// UhdmName() returns a string_view that is NOT guaranteed NUL-terminated:
// always go through std::string before "%s" (r10earl60's lesson).
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[512];
    const std::string kind = kindOf(o);
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             base(o->VpiFile()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static std::string chainOf(const BaseClass* o, int n = 12) {
    std::string s;
    for (int i = 0; i < n && o; i++) {
        s += (i ? "\n        < " : "") + ident(o);
        o = o->VpiParent();
    }
    return s;
}

// ---------------------------------------------------------------- field scan
// Returns the name of the singular COMPARED field of `o` that points at `tgt`,
// or nullptr.  Only fields whose declared type can hold a `package` are read.
static const char* pointsAt(const BaseClass* o, const BaseClass* tgt) {
    const any* a = (const any*)o;
    if (const typespec* t = any_cast<const typespec*>(a))
        if ((const BaseClass*)t->Instance() == tgt) return "typespec::Instance";
    if (const variables* v = any_cast<const variables*>(a)) {
        if ((const BaseClass*)v->Instance() == tgt) return "variables::Instance";
        if ((const BaseClass*)v->Scope() == tgt) return "variables::Scope";
    }
    if (const ports* p = any_cast<const ports*>(a))
        if ((const BaseClass*)p->Instance() == tgt) return "ports::Instance";
    if (const task_func* tf = any_cast<const task_func*>(a))
        if ((const BaseClass*)tf->Instance() == tgt) return "task_func::Instance";
    if (const clocking_block* c = any_cast<const clocking_block*>(a)) {
        if ((const BaseClass*)c->Instance() == tgt) return "clocking_block::Instance";
        if ((const BaseClass*)c->Actual() == tgt) return "clocking_block::Actual";
    }
    if (const instance* i = any_cast<const instance*>(a))
        if ((const BaseClass*)i->Instance() == tgt) return "instance::Instance";
    if (const tf_call* tc = any_cast<const tf_call*>(a))
        if ((const BaseClass*)tc->Scope() == tgt) return "tf_call::Scope";
    if (const ref_obj* r = any_cast<const ref_obj*>(a))
        if ((const BaseClass*)r->Actual_group() == tgt) return "ref_obj::Actual_group";
    if (const ref_var* r = any_cast<const ref_var*>(a))
        if ((const BaseClass*)r->Actual_group() == tgt) return "ref_var::Actual_group";
    if (const ref_module* r = any_cast<const ref_module*>(a))
        if ((const BaseClass*)r->Actual_group() == tgt) return "ref_module::Actual_group";
    if (const chandle_var* r = any_cast<const chandle_var*>(a))
        if ((const BaseClass*)r->Actual_group() == tgt) return "chandle_var::Actual_group";
    if (const gen_scope_array* g = any_cast<const gen_scope_array*>(a))
        if ((const BaseClass*)g->VpiInstance() == tgt) return "gen_scope_array::VpiInstance";
    if (const import_typespec* it = any_cast<const import_typespec*>(a))
        if ((const BaseClass*)it->Item() == tgt) return "import_typespec::Item";
    return nullptr;
}

struct Head {
    const BaseClass* lhs = nullptr;
    const BaseClass* rhs = nullptr;
    int32_t r = 0;
};
static Head runCompare(const design* dg, const design* dou,
                       const std::vector<const BaseClass*>& mask) {
    CompareContext c;
    for (const BaseClass* m : mask) c.m_visited.insert(m);
    Head h;
    h.r = dg->Compare(dou, &c);
    h.lhs = c.m_failedLhs;
    h.rhs = c.m_failedRhs;
    return h;
}
static bool sameHead(const Head& a, const Head& b) {
    return a.r == b.r && a.lhs == b.lhs && a.rhs == b.rhs;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: own120 <golden.uhdm> <ours.uhdm> [--calib] [--nobisect]\n");
        return 2;
    }
    bool calib = false, nobisect = false;
    for (int i = 3; i < argc; i++) {
        if (!strcmp(argv[i], "--calib")) calib = true;
        if (!strcmp(argv[i], "--nobisect")) nobisect = true;
    }
    Serializer sg, so;
    auto hg = sg.Restore(std::string(argv[1]));
    auto ho = so.Restore(std::string(calib ? argv[1] : argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dou = (const design*)((const uhdm_handle*)ho[0])->object;
    printf("golden objs=%zu   ours objs=%zu%s\n", sg.AllObjects().size(),
           so.AllObjects().size(), calib ? "   [CALIB: ours := golden]" : "");

    Head h0 = runCompare(dg, dou, {});
    printf("HEAD r=%d\n  LHS: %s\n  RHS: %s\n", h0.r, ident(h0.lhs).c_str(),
           ident(h0.rhs).c_str());
    if (h0.r == 0) { printf("NO HEAD (databases compare equal)\n"); return 0; }
    if (calib) { printf("CALIB FAILED: a database must compare equal to itself\n"); return 4; }
    printf("BOTH SIDES PRESENT: %s   (a <null> RHS is the SINGULAR overload's\n"
           "  lhs!=null && rhs==null branch: m_failedLhs is the POINTEE)\n",
           (h0.lhs && h0.rhs) ? "yes" : "no");

    const std::string tgtName(h0.lhs ? h0.lhs->VpiName() : "");
    const std::string tgtKind = kindOf(h0.lhs);

    // ------------------------------------------------------- (A) FIELD SCAN
    // golden: every object holding a compared singular edge to the head target
    std::vector<const BaseClass*> pool;
    std::map<std::string, size_t> byField;
    for (const auto& [obj, id] : sg.AllObjects()) {
        if (const char* f = pointsAt(obj, h0.lhs)) {
            pool.push_back(obj);
            byField[std::string(f) + "  owner=" + kindOf(obj)]++;
        }
    }
    printf("\n== (A) FIELD SCAN — GOLDEN objects holding a compared singular edge to %s\n",
           ident(h0.lhs).c_str());
    if (byField.empty()) printf("   (none)\n");
    for (const auto& [k, n] : byField) printf("   %-52s %6zu\n", k.c_str(), n);
    printf("   POOL total = %zu\n", pool.size());

    // ours: find OUR object of the same kind and name, then the same scan
    const BaseClass* ourTgt = nullptr;
    for (const auto& [obj, id] : so.AllObjects()) {
        if (kindOf(obj) == tgtKind && std::string(obj->VpiName()) == tgtName) {
            ourTgt = obj;
            break;
        }
    }
    printf("\n== OUR counterpart of the head target: %s\n", ident(ourTgt).c_str());
    std::map<std::string, size_t> ourByField;
    size_t ourPool = 0;
    if (ourTgt) {
        for (const auto& [obj, id] : so.AllObjects()) {
            if (const char* f = pointsAt(obj, ourTgt)) {
                ourPool++;
                ourByField[std::string(f) + "  owner=" + kindOf(obj)]++;
            }
        }
    }
    printf("== (A') FIELD SCAN — OURS, same edges to OUR %s\n", tgtName.c_str());
    if (ourByField.empty()) printf("   (none)\n");
    for (const auto& [k, n] : ourByField) printf("   %-52s %6zu\n", k.c_str(), n);
    printf("   POOL total = %zu\n", ourPool);

    // the ten first golden pool members, with their parent chains
    printf("\n== GOLDEN pool members (first 10, with parent chain)\n");
    for (size_t i = 0; i < pool.size() && i < 10; i++)
        printf("   [%zu] %s   via %s\n        %s\n", i, ident(pool[i]).c_str(),
               pointsAt(pool[i], h0.lhs), chainOf(pool[i]).c_str());

    if (nobisect) return 0;
    if (pool.empty()) { printf("\nPOOL-EMPTY: no compared singular edge in the scanned set\n"); return 0; }

    // -------------------------------------------------- (B) MASK-AND-RERUN
    Head hp = runCompare(dg, dou, pool);
    printf("\n== (B) MASK-AND-RERUN\n");
    if (sameHead(hp, h0)) {
        printf("   POOL-INERT: masking the whole pool did NOT move the head.\n"
               "   The owner is not in the scanned field set.\n");
        return 0;
    }
    printf("   whole pool masked -> head MOVES: r=%d LHS=%s RHS=%s\n", hp.r,
           ident(hp.lhs).c_str(), ident(hp.rhs).c_str());

    std::vector<const BaseClass*> cur = pool;
    while (cur.size() > 1) {
        size_t half = cur.size() / 2;
        std::vector<const BaseClass*> a(cur.begin(), cur.begin() + half);
        if (!sameHead(runCompare(dg, dou, a), h0)) { cur = a; continue; }
        std::vector<const BaseClass*> b(cur.begin() + half, cur.end());
        if (!sameHead(runCompare(dg, dou, b), h0)) { cur = b; continue; }
        // Every owner of this family produces the SAME head (LHS = the package,
        // RHS = null), so masking one owner just uncovers the next: the bisect
        // converges on the SET of owners the official walk actually reaches,
        // not on a single one.  Print the whole residual set.
        printf("   BISECT-SPLIT: neither half alone moves the head — the walk\n"
               "   reaches MORE THAN ONE owner of this family; residual set = %zu\n",
               cur.size());
        for (size_t i = 0; i < cur.size(); i++)
            printf("   REACHED[%zu] %s   via %s\n        %s\n", i, ident(cur[i]).c_str(),
                   pointsAt(cur[i], h0.lhs), chainOf(cur[i]).c_str());
        break;
    }
    if (cur.size() == 1) {
        Head hs = runCompare(dg, dou, cur);
        if (sameHead(hs, h0)) { printf("   NOT-SINGLE: re-verification failed\n"); return 0; }
        printf("\n   OWNER (verified ALONE): %s\n", ident(cur[0]).c_str());
        printf("   FIELD: %s\n", pointsAt(cur[0], h0.lhs));
        printf("   parent chain:\n        %s\n", chainOf(cur[0]).c_str());
        printf("   next head after masking it: r=%d LHS=%s RHS=%s\n", hs.r,
               ident(hs.lhs).c_str(), ident(hs.rhs).c_str());
    }
    return 0;
}
