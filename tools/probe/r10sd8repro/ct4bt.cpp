// r10sd4 — THE BACKTRACE.  Who calls the failing `SafeCompare`?
//
// Every indirect method was exhausted first, and each one produced a real,
// recorded refutation rather than an answer:
//   * suppression by `m_visited` (sd2's ddmin and this pass's exhaustive scans)
//     cannot separate the site from its ancestors, because the head's shape
//     RECURS in the other package view — the signature test is blind here;
//   * single-slot mutation of all 6818 of OUR `Instance()` slots that hold the
//     failing package moved nothing (`ct4mut2`);
//   * nulling each of the failing package's own 25 vectors moved nothing
//     (`ct4vec`), which rules out the vector arm on that container;
//   * a 154-relation sweep of both databases (`ct4ref`) finds only those 6818
//     slots and `design.uhdmtopPackages[]` referencing it at all.
//
// Those four cannot all be true of a SINGULAR `vpiInstance` head, so the
// remaining move is to stop inferring the caller and READ it.
//
// `SafeCompare` is a static inline in `BaseClass.h`, so it has no symbol of its
// own — but `CompareContext::m_failedRhs` is a plain member, and a HARDWARE
// WATCHPOINT on it stops exactly at the store.  The innermost frame that owns
// that store is the generated `X::Compare` whose body issued the call, and that
// is the object class we are looking for.  `libuhdm.a` carries no DWARF, so the
// frames come out as mangled symbol names — which is all that is needed.
//
//   g++ -O0 -g -std=c++17 ct4bt.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4bt
//   gdb -q -x ct4bt.gdb --args ct4bt <golden.uhdm> <ours.uhdm>
//
// `g_watch` is a global in THIS translation unit (which does have debug info),
// so gdb can take its address without needing CompareContext's layout.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <filesystem>
#include <set>
#include <string>

using namespace UHDM;

// A pointer-identity oracle gdb can call.  `libuhdm.a` has no DWARF, so the
// frames above the store carry no named locals — but the callee-saved registers
// at the stop still hold them, and any value that IS a live UHDM object can be
// named by looking it up in the two serializers.  SHOW1 turns a raw register
// value into an identity, or says nothing.
static std::set<const void*> g_objsG, g_objsO;
static std::string identOf(const BaseClass* p) {
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo()) + "-" +
         std::to_string(p->VpiEndLineNo()) + ":" +
         std::to_string(p->VpiEndColumnNo());
    s += "  file=" + std::string(p->VpiFile());
    return s;
}
extern "C" void SHOW1(const void* p) {
    if (g_objsG.count(p))
        printf("   GOLDEN %p  %s\n", p, identOf((const BaseClass*)p).c_str());
    else if (g_objsO.count(p))
        printf("   OURS   %p  %s\n", p, identOf((const BaseClass*)p).c_str());
}

const void** g_watch = nullptr;   // &ctx->m_failedRhs
const void* g_target = nullptr;   // the package pointer we expect to see stored

// gdb breaks here, arms the watchpoint, and continues.
extern "C" void MARK() {}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct4bt <golden> <ours>\n"); return 2; }
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* DA = (design*)((uhdm_handle*)ha[0])->object;
    auto* DB = (design*)((uhdm_handle*)hb[0])->object;

    for (const auto& [q, i] : sa.AllObjects()) if (q) g_objsG.insert(q);
    for (const auto& [q, i] : sb.AllObjects()) if (q) g_objsO.insert(q);
    printf("oracle: golden=%zu ours=%zu objects\n", g_objsG.size(), g_objsO.size());

    // pass 1: learn the target pointer, with a throwaway context
    {
        CompareContext c;
        int r = DA->Compare(DB, &c);
        g_target = (const void*)c.m_failedRhs;
        printf("pass1 r=%d failedRhs=%p\n", r, g_target);
    }
    // pass 2: the watched run
    static CompareContext ctx;
    g_watch = (const void**)&ctx.m_failedRhs;
    printf("g_watch=%p  (address of ctx.m_failedRhs)\n", (void*)g_watch);
    MARK();
    int r = DA->Compare(DB, &ctx);
    printf("pass2 r=%d failedRhs=%p\n", r, (const void*)ctx.m_failedRhs);
    return 0;
}
