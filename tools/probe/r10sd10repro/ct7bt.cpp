// r10sd7 — THE BACKTRACE, WITH THE OWNER READ INSTEAD OF SCRAPED.
//
// sd4's `ct4bt` puts a hardware watchpoint on `CompareContext::m_failedRhs` and
// then scrapes the stopped frame's REGISTERS and 4096 STACK WORDS through a
// pointer-identity oracle.  That names the frames correctly — but the objects it
// prints are whatever happens to still be lying on the stack, and this pass
// caught that costing an answer: the scrape named
// `array_var(uvm_random_seed_table_lookup)`, and a full order-preserving census
// of every `class_defn` listing on both sides (`ct7own`) proves that object
// AGREES cell for cell.  It was a dead word from an earlier, SUCCESSFUL compare.
//
// So this version does not scrape.  It BREAKS on the frames the backtrace names
// and records their ARGUMENTS at entry, where the SysV ABI guarantees
// `this`=$rdi and `other`=$rsi.  At the watchpoint stop the LAST recorded pair
// for each frame is the owner chain, read rather than inferred.
//
//   g++ -O0 -g -std=c++17 ct7bt.cpp -I ~/.local/include \
//       -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7bt
//   gdb -q -x ct7bt.gdb --args ct7bt <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <filesystem>
#include <set>
#include <string>

using namespace UHDM;

static std::set<const void*> g_objsG, g_objsO;
static std::string identOf(const BaseClass* p) {
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo()) + "-" +
         std::to_string(p->VpiEndLineNo()) + ":" +
         std::to_string(p->VpiEndColumnNo());
    s += " file=" + std::string(p->VpiFile());
    return s;
}
// LABELLED oracle.  ct4bt's gdb script printed its labels with gdb's own
// `printf` (unbuffered, straight to the terminal) while the oracle printed with
// the INFERIOR's `printf` (buffered, flushed at exit) — so every label landed
// before every value and no value could be attributed to the register it came
// from.  One function, one stream, labels included.
extern "C" void SHOWL(const char* lbl, const void* p) {
    if (g_objsG.count(p))
        printf("   %-10s GOLDEN %p  %s\n", lbl, p, identOf((const BaseClass*)p).c_str());
    else if (g_objsO.count(p))
        printf("   %-10s OURS   %p  %s\n", lbl, p, identOf((const BaseClass*)p).c_str());
    else
        printf("   %-10s (not a live UHDM object) %p\n", lbl, p);
    fflush(stdout);   // the inferior is KILLED at the stop; an unflushed
                      // buffer prints nothing and reads as "no output"
}

// A breakpoint that records "the last call I saw" is STALE whenever a deeper
// call of the same function was entered and returned between that entry and the
// stop — which is exactly what `scope::Compare`'s earlier vectors do to
// `class_defn::Compare`.  The object's OWN `vpiParent` chain cannot go stale, so
// the owner is read off the object rather than off the breakpoint.
extern "C" void SHOWCHAIN(const char* lbl, const void* p) {
    if (!g_objsG.count(p) && !g_objsO.count(p)) {
        printf("   %-10s (not a live UHDM object) %p\n", lbl, p);
        fflush(stdout);
        return;
    }
    const char* side = g_objsG.count(p) ? "GOLDEN" : "OURS  ";
    const BaseClass* q = (const BaseClass*)p;
    for (int i = 0; i < 8 && q; i++) {
        printf("   %-10s %s [%d] %s\n", lbl, side, i, identOf(q).c_str());
        q = q->VpiParent();
    }
    fflush(stdout);
}
// The failing arm itself: a typespec's singular vpiInstance.
extern "C" void SHOWINST(const char* lbl, const void* p) {
    if (!g_objsG.count(p) && !g_objsO.count(p)) {
        printf("   %-10s (not a live UHDM object) %p\n", lbl, p);
        fflush(stdout);
        return;
    }
    const char* side = g_objsG.count(p) ? "GOLDEN" : "OURS  ";
    auto* t = (const typespec*)p;
    const instance* in = t->Instance();
    printf("   %-10s %s %s   Instance=%s\n", lbl, side, identOf(t).c_str(),
           in ? identOf(in).c_str() : "<null>");
    fflush(stdout);
}

const void** g_watch = nullptr;
const void* g_target = nullptr;

extern "C" void MARK() {}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct7bt <golden> <ours>\n"); return 2; }
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* DA = (design*)((uhdm_handle*)ha[0])->object;
    auto* DB = (design*)((uhdm_handle*)hb[0])->object;

    for (const auto& [q, i] : sa.AllObjects()) if (q) g_objsG.insert(q);
    for (const auto& [q, i] : sb.AllObjects()) if (q) g_objsO.insert(q);
    printf("oracle: golden=%zu ours=%zu objects\n", g_objsG.size(), g_objsO.size());
    fflush(stdout);

    {
        CompareContext c;
        int r = DA->Compare(DB, &c);
        g_target = (const void*)c.m_failedRhs;
        printf("pass1 r=%d failedLhs=%p failedRhs=%p\n", r, (const void*)c.m_failedLhs,
               g_target);
        fflush(stdout);
    }
    static CompareContext ctx;
    g_watch = (const void**)&ctx.m_failedRhs;
    printf("g_watch=%p\n", (void*)g_watch);
    fflush(stdout);
    MARK();
    int r = DA->Compare(DB, &ctx);
    printf("pass2 r=%d failedRhs=%p\n", r, (const void*)ctx.m_failedRhs);
    return 0;
}
