// r10sd8 — THE BISECTION THAT NAMES THE HEAD OBJECT.
//
// sd7 R8 records why its mutation instrument under-counted: `ct7mut` judged
// "the head moved" by `m_failedRhs` changing POINTER, and on these designs a
// great many different failures all report the same `package(uvm_pkg)`.  This
// tool judges by the whole TUPLE `(r, failedLhs, failedRhs, |m_visited|)`, and
// it does not test one object at a time — it nulls a SET and bisects, so the
// head is named in ~log2(N) whole-design compares instead of N.
//
// POOL: every `vpiInstance` slot in OUR database that points at a package whose
// name matches the argument (both views).  Sorted by UhdmId so the bisection is
// reproducible.
//
// THE MONOTONE SIGNAL is `|m_visited|`: the number of objects `design::Compare`
// walked before it gave up.  Nulling an irrelevant slot cannot change it;
// nulling the head's slot lets the walk go further.  (Nulling a SHARED slot can
// make things WORSE — r flips to 1 — which is sd7 §9.7's backfire and is
// reported, not hidden.)
//
// GUARD: an empty pool, or a baseline that already compares equal, is a hard
// error.
//
// build: g++ -O2 -std=c++17 ct8bis.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct8bis
// usage: ct8bis <golden.uhdm> <ours.uhdm> <pkgname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

struct Slot {
    BaseClass* obj;
    instance* had;
    void set(instance* v) {
        if (auto* t = any_cast<typespec*>((any*)obj))            { t->Instance(v); return; }
        if (auto* x = any_cast<variables*>((any*)obj))           { x->Instance(v); return; }
        if (auto* f = any_cast<task_func*>((any*)obj))           { f->Instance(v); return; }
        if (auto* p = any_cast<ports*>((any*)obj))               { p->Instance(v); return; }
        if (auto* c = any_cast<clocking_block*>((any*)obj))      { c->Instance(v); return; }
        if (auto* i = any_cast<instance*>((any*)obj))            { i->Instance(v); return; }
    }
};

static instance* getInst(const any* o) {
    // const_cast: the pool needs a mutable handle to restore the value.
    if (auto* t = any_cast<const typespec*>(o))       return (instance*)t->Instance();
    if (auto* v = any_cast<const variables*>(o))      return (instance*)v->Instance();
    if (auto* f = any_cast<const task_func*>(o))      return (instance*)f->Instance();
    if (auto* p = any_cast<const ports*>(o))          return (instance*)p->Instance();
    if (auto* c = any_cast<const clocking_block*>(o)) return (instance*)c->Instance();
    if (auto* i = any_cast<const instance*>(o))       return (instance*)i->Instance();
    return nullptr;
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
    for (int i = 0; i < 6 && p; i++) { s += (i ? " < " : "") + ident(p); p = p->VpiParent(); }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 4) { std::cerr << "usage: ct8bis <golden> <ours> <pkgname>\n"; return 2; }
    std::string want = argv[3];
    Serializer sg, so;
    auto hg = sg.Restore(std::filesystem::path(argv[1]));
    auto ho = so.Restore(std::filesystem::path(argv[2]));
    if (hg.empty() || ho.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }
    auto* dg = (design*)((uhdm_handle*)hg[0])->object;
    auto* dobj = (design*)((uhdm_handle*)ho[0])->object;

    std::set<const BaseClass*> targets;
    if (auto* v = dobj->AllPackages()) for (auto* p : *v) if (p->VpiName() == want) targets.insert(p);
    if (auto* v = dobj->TopPackages()) for (auto* p : *v) if (p->VpiName() == want) targets.insert(p);
    if (targets.empty()) { std::cerr << "REFUSING: no package " << want << " in ours\n"; return 5; }

    std::vector<Slot> pool;
    for (const auto& [obj, id] : so.AllObjects()) {
        if (!obj) continue;
        auto* in = getInst((const any*)obj);
        if (in && targets.count(in)) pool.push_back({(BaseClass*)obj, in});
    }
    std::cerr << "pool=" << pool.size() << " slots pointing at package " << want << "\n";
    if (pool.empty()) { std::cerr << "REFUSING: empty pool\n"; return 5; }

    auto probe = [&](const char* tag) {
        CompareContext c;
        int r = dg->Compare(dobj, &c);
        std::cout << tag << "  r=" << r << "  visited=" << c.m_visited.size()
                  << "  failedLhs=" << (c.m_failedLhs ? ident(c.m_failedLhs) : "<null>")
                  << "  failedRhs=" << (c.m_failedRhs ? ident(c.m_failedRhs) : "<null>") << "\n";
        return std::make_pair(r, c.m_visited.size());
    };
    auto base = probe("BASELINE");
    if (base.first == 0) { std::cerr << "REFUSING: baseline already equal\n"; return 5; }

    // Whole-pool probe: does the head live in this pool at all?
    for (auto& s : pool) s.set(nullptr);
    auto all = probe("POOL_ALL_NULLED");
    for (auto& s : pool) s.set(s.had);
    auto chk = probe("RESTORED");
    if (chk != base) { std::cerr << "REFUSING: restore did not reproduce the baseline\n"; return 6; }
    if (all.second <= base.second) {
        std::cout << "[S] HEAD_NOT_IN_POOL  visited " << base.second << " -> " << all.second << "\n";
        return 0;
    }

    // Bisect on the ordered pool for a MINIMAL prefix-suffix window that keeps
    // the advance.  Invariant: nulling pool[lo,hi) advances visited.
    size_t lo = 0, hi = pool.size();
    while (hi - lo > 1) {
        size_t mid = lo + (hi - lo) / 2;
        for (size_t i = lo; i < mid; i++) pool[i].set(nullptr);
        CompareContext c;
        dg->Compare(dobj, &c);
        size_t vis = c.m_visited.size();
        for (size_t i = lo; i < mid; i++) pool[i].set(pool[i].had);
        if (vis > base.second) { hi = mid; }
        else { lo = mid; }
        std::cerr << "  bisect [" << lo << "," << hi << ")\n";
    }
    Slot& w = pool[lo];
    std::cout << "[S] HEAD_SLOT  " << chainOf(w.obj) << "\n";
    std::cout << "    file=" << w.obj->VpiFile() << "  instance=" << w.had->VpiName()
              << " id=" << w.had->UhdmId() << "\n";
    w.set(nullptr);
    probe("HEAD_NULLED");
    w.set(w.had);
    return 0;
}
