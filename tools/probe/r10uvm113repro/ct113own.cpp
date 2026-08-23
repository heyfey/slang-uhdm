// r10uvm113 — OWNER LOCATOR for the `RHS: <null>` function-binding head.
//
// MEASUREMENT ONLY.  The official `uhdm-cmp` stays the sole acceptance judge.
// Derived verbatim in method from r10earl60repro/tsinst60.cpp: seed golden
// objects into a FRESH CompareContext's `m_visited` (every generated
// `<kind>::Compare` opens with an LHS-keyed visited-insert and returns 0 on a
// hit), re-run the OFFICIAL `design::Compare`, and bisect for the single
// object whose masking moves the head.
//
// The pool here is every golden object carrying a SINGULAR edge that can point
// at a `function`/`task`: func_call::Function, method_func_call::Function,
// task_call::Task, method_task_call::Task, ref_obj::Actual_group.
//
// build: g++ -O2 -std=c++17 ct113own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct113own
// usage: ct113own <golden.uhdm> <ours.uhdm> [--calib]
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
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             base(o->VpiFile()).c_str(), o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static std::string chainOf(const BaseClass* o, int n = 12) {
    std::string s;
    for (int i = 0; i < n && o; i++) {
        s += (i ? "\n      < " : "") + ident(o);
        o = o->VpiParent();
    }
    return s;
}
struct Head { const BaseClass* lhs = nullptr; const BaseClass* rhs = nullptr; int r = 0; };
static Head runCompare(const design* dg, const design* dou,
                       const std::vector<const BaseClass*>& mask) {
    CompareContext c;
    for (const BaseClass* m : mask) c.m_visited.insert(m);
    Head h; h.r = dg->Compare(dou, &c);
    h.lhs = c.m_failedLhs; h.rhs = c.m_failedRhs; return h;
}
static bool sameHead(const Head& a, const Head& b) {
    return a.r == b.r && a.lhs == b.lhs && a.rhs == b.rhs;
}
// every singular edge that can hold a function/task
static const BaseClass* tfEdge(const BaseClass* obj, const char** what) {
    const any* a = (const any*)obj;
    if (const func_call* f = any_cast<const func_call*>(a)) {
        if (f->UhdmType() == uhdmfunc_call) { *what = "func_call::Function"; return (const BaseClass*)f->Function(); }
    }
    if (const method_func_call* f = any_cast<const method_func_call*>(a)) {
        *what = "method_func_call::Function"; return (const BaseClass*)f->Function();
    }
    if (const task_call* t = any_cast<const task_call*>(a)) {
        if (t->UhdmType() == uhdmtask_call) { *what = "task_call::Task"; return (const BaseClass*)t->Task(); }
    }
    if (const method_task_call* t = any_cast<const method_task_call*>(a)) {
        *what = "method_task_call::Task"; return (const BaseClass*)t->Task();
    }
    if (const ref_obj* r = any_cast<const ref_obj*>(a)) {
        *what = "ref_obj::Actual_group"; return (const BaseClass*)r->Actual_group();
    }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct113own <golden> <ours> [--calib]\n"); return 2; }
    bool calib = false;
    for (int i = 3; i < argc; i++) if (!strcmp(argv[i], "--calib")) calib = true;
    Serializer sg, so;
    auto hg = sg.Restore(std::string(argv[1]));
    auto ho = so.Restore(std::string(calib ? argv[1] : argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dou = (const design*)((const uhdm_handle*)ho[0])->object;
    printf("golden objs=%zu ours objs=%zu%s\n", sg.AllObjects().size(),
           so.AllObjects().size(), calib ? "  [CALIB]" : "");
    Head h0 = runCompare(dg, dou, {});
    printf("HEAD r=%d\n  LHS: %s\n  RHS: %s\n", h0.r, ident(h0.lhs).c_str(), ident(h0.rhs).c_str());
    if (h0.r == 0) { printf("NO HEAD\n"); return 0; }
    if (calib) { printf("CALIB FAILED\n"); return 4; }

    std::vector<const BaseClass*> pool;
    for (const auto& [obj, id] : sg.AllObjects()) {
        const char* what = nullptr;
        const BaseClass* tgt = tfEdge(obj, &what);
        if (tgt && tgt == h0.lhs) pool.push_back(obj);
    }
    printf("POOL objects with a singular tf-edge == head-LHS: %zu\n", pool.size());
    for (const BaseClass* p : pool) {
        const char* what = nullptr; tfEdge(p, &what);
        printf("  CAND %-28s %s\n     parent: %s\n", what, ident(p).c_str(), chainOf(p, 6).c_str());
    }
    if (pool.empty()) { printf("POOL-EMPTY\n"); return 0; }
    Head hp = runCompare(dg, dou, pool);
    if (sameHead(hp, h0)) { printf("POOL-INERT\n"); return 0; }
    printf("POOL masked -> head MOVES (r=%d LHS=%s RHS=%s)\n", hp.r,
           ident(hp.lhs).c_str(), ident(hp.rhs).c_str());
    std::vector<const BaseClass*> cur = pool;
    while (cur.size() > 1) {
        size_t half = cur.size() / 2;
        std::vector<const BaseClass*> a(cur.begin(), cur.begin() + half);
        if (!sameHead(runCompare(dg, dou, a), h0)) { cur = a; continue; }
        std::vector<const BaseClass*> b(cur.begin() + half, cur.end());
        if (!sameHead(runCompare(dg, dou, b), h0)) { cur = b; continue; }
        printf("BISECT-SPLIT: neither half alone moves the head (%zu left)\n", cur.size());
        break;
    }
    if (cur.size() == 1) {
        Head hs = runCompare(dg, dou, cur);
        if (sameHead(hs, h0)) { printf("NOT-SINGLE\n"); return 0; }
        const char* what = nullptr; tfEdge(cur[0], &what);
        printf("\nOWNER (verified alone): %s   FIELD=%s\n", ident(cur[0]).c_str(), what);
        printf("  parent chain:\n      %s\n", chainOf(cur[0]).c_str());
        printf("  next head after masking it: r=%d LHS=%s RHS=%s\n", hs.r,
               ident(hs.lhs).c_str(), ident(hs.rhs).c_str());
    }
    return 0;
}
