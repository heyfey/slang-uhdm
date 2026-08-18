// r10earl60 — THE HEAD LOCATOR for a `SafeCompare(lhs, rhs=nullptr)` head.
//
// MEASUREMENT ONLY.  The official `uhdm-cmp` stays the sole acceptance judge;
// this tool answers the one question uhdm-cmp cannot: WHICH OBJECT was
// mid-`Compare` when the failure was recorded.
//
// WHY IT IS NEEDED.  `uhdm-cmp` prints `m_failedLhs` / `m_failedRhs`.  For the
// two-argument scalar `SafeCompare(lhs, rhs, ctx)` with `rhs == nullptr`
// (BaseClass.h:187) only `m_failedLhs` is set, and it is set to the POINTEE —
// the object the golden edge points AT — not to the owner that holds the edge.
// So an `RHS: <null>` head names the TARGET and hides the OWNER.  This tool
// finds the owner.
//
// HOW.  Every generated `<kind>::Compare` opens with
//     if (!context->m_visited.insert(this).second) return r;   // LHS-keyed
// so seeding a golden object into a FRESH context's `m_visited` makes its
// whole `Compare` (and subtree) return 0.  Seed a CANDIDATE SET, re-run the
// OFFICIAL `design::Compare`, and if the head MOVES the owner is inside that
// set.  Bisect.  No UHDM source is patched and no compare semantics change:
// the walk order, the field order and the failure points are the shipped ones.
//
// GUARDS (each one is a way this tool could lie):
//   * `--calib` compares a database against ITSELF and MUST report NO HEAD.
//   * masking the WHOLE candidate pool must move the head before any
//     bisection starts; if it does not, the owner is NOT in the pool and the
//     tool says so (POOL-INERT) instead of bisecting to an arbitrary answer.
//   * every rerun uses a FRESH CompareContext seeded with the mask only.
//     Reusing one context returns 0 at the first line (design::Compare inserts
//     the design itself) and would report success for a database never walked.
//   * the located object is re-verified ALONE: masking just that one object
//     must move the head, or the row prints NOT-SINGLE.
//
// build: g++ -O2 -std=c++17 tsinst60.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o tsinst60
// usage: tsinst60 <golden.uhdm> <ours.uhdm> [--calib] [--pool=all|tsinst]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[512];
    // UhdmName() returns a std::string_view over UHDM's table; handing it to
    // "%s" prints garbage because it is NOT guaranteed NUL-terminated.  This
    // cost one confusing run and is the reason for the explicit std::string.
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kind.c_str(),
             nm.c_str(), base(o->VpiFile()).c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static std::string chainOf(const BaseClass* o, int n = 10) {
    std::string s;
    for (int i = 0; i < n && o; i++) {
        s += (i ? "\n      < " : "") + ident(o);
        o = o->VpiParent();
    }
    return s;
}

struct Head {
    const BaseClass* lhs = nullptr;
    const BaseClass* rhs = nullptr;
    int r = 0;
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
    if (argc < 3) { fprintf(stderr, "usage: tsinst60 <golden> <ours> [--calib]\n"); return 2; }
    bool calib = false;
    for (int i = 3; i < argc; i++) if (!strcmp(argv[i], "--calib")) calib = true;
    Serializer sg, so;
    auto hg = sg.Restore(std::string(argv[1]));
    auto ho = so.Restore(std::string(calib ? argv[1] : argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dou = (const design*)((const uhdm_handle*)ho[0])->object;
    printf("golden objs=%zu ours objs=%zu%s\n", sg.AllObjects().size(),
           so.AllObjects().size(), calib ? "  [CALIB: ours := golden]" : "");

    Head h0 = runCompare(dg, dou, {});
    printf("HEAD r=%d\n  LHS: %s\n  RHS: %s\n", h0.r, ident(h0.lhs).c_str(),
           ident(h0.rhs).c_str());
    if (h0.r == 0) { printf("NO HEAD (databases compare equal)\n"); return 0; }
    if (calib) { printf("CALIB FAILED: a database must compare equal to itself\n"); return 4; }

    // Candidate pool: every golden typespec whose Instance() is the object the
    // head names.  That is the exact set of owners that can produce THIS head
    // through `typespec::Compare`'s `SafeCompare(Instance(), ...)`.
    std::vector<const BaseClass*> pool;
    for (const auto& [obj, id] : sg.AllObjects()) {
        const typespec* t = any_cast<const typespec*>((const any*)obj);
        if (t && (const BaseClass*)t->Instance() == h0.lhs) pool.push_back(obj);
    }
    printf("POOL typespecs with Instance()==head-LHS: %zu\n", pool.size());
    if (pool.empty()) { printf("POOL-EMPTY\n"); return 0; }

    Head hp = runCompare(dg, dou, pool);
    if (sameHead(hp, h0)) {
        printf("POOL-INERT: masking the whole pool did not move the head; the\n"
               "owner is NOT a typespec::Instance edge.\n");
        return 0;
    }
    printf("POOL masked -> head MOVES (r=%d LHS=%s)\n", hp.r, ident(hp.lhs).c_str());

    // Bisect for the SMALLEST prefix-free subset that still moves the head.
    std::vector<const BaseClass*> cur = pool;
    while (cur.size() > 1) {
        size_t half = cur.size() / 2;
        std::vector<const BaseClass*> a(cur.begin(), cur.begin() + half);
        Head ha = runCompare(dg, dou, a);
        if (!sameHead(ha, h0)) { cur = a; continue; }
        std::vector<const BaseClass*> b(cur.begin() + half, cur.end());
        Head hb = runCompare(dg, dou, b);
        if (!sameHead(hb, h0)) { cur = b; continue; }
        printf("BISECT-SPLIT: neither half alone moves the head (%zu left)\n", cur.size());
        break;
    }
    if (cur.size() == 1) {
        Head hs = runCompare(dg, dou, cur);
        if (sameHead(hs, h0)) { printf("NOT-SINGLE: re-verification failed\n"); return 0; }
        const BaseClass* owner = cur[0];
        printf("\nOWNER (verified alone): %s\n", ident(owner).c_str());
        printf("  parent chain:\n      %s\n", chainOf(owner).c_str());
        const typespec* t = any_cast<const typespec*>((const any*)owner);
        if (t) {
            printf("  Instance: %s\n", ident(t->Instance()).c_str());
            printf("  Typedef_alias: %s\n", ident(t->Typedef_alias()).c_str());
        }
        printf("  next head after masking it: r=%d LHS=%s RHS=%s\n", hs.r,
               ident(hs.lhs).c_str(), ident(hs.rhs).c_str());
    }
    return 0;
}
