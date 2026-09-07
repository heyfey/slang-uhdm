// r10v186 (VERIFIER) — PRE-SEED THE HEAD ITSELF INTO THE VISITED SET.
// MEASUREMENT ONLY; the official uhdm-cmp is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// r10uvm186's arm A moves the ELAB cmp from 31 lines to 9212 and calls the
// new head "a pre-existing difference the cleared mask was hiding".  That is
// a claim about a MASK CASCADE (RESUME §9: masks cascade, the count is a
// lower bound, and the arbiter is the whole-dump diff and the census), and it
// is testable directly: pre-seed the PRISTINE head object into a fresh
// CompareContext::m_visited (every generated Compare opens with
// `if (!context->m_visited.insert(this).second) return r;`) and re-run the
// OFFICIAL Compare on the PRISTINE pair.  If the pristine head then lands on
// the same object the PATCHED head does, the patched head was already there
// and merely masked.
//
// build: g++ -O2 -std=c++17 ct186vmask.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186vmask
// usage: ct186vmask <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign) return (const design*)kv.first;
    return nullptr;
}
int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct186vmask <golden> <ours>\n"); return 2; }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg); const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c0;
    int r = dg->Compare(dou, &c0);
    printf("head0 r=%d LHS=%s  RHS=%s\n", r, ident(c0.m_failedLhs).c_str(),
           ident(c0.m_failedRhs).c_str());
    // cascade: keep masking the current head and re-running, up to 12 steps
    CompareContext c;
    for (int i = 1; i <= 12 && c0.m_failedLhs; ++i) {
        c.m_visited.insert(c0.m_failedLhs);
        CompareContext cn;
        cn.m_visited = c.m_visited;
        int rn = dg->Compare(dou, &cn);
        printf("mask%-2d r=%d LHS=%s  RHS=%s\n", i, rn,
               ident(cn.m_failedLhs).c_str(), ident(cn.m_failedRhs).c_str());
        if (cn.m_failedLhs == c0.m_failedLhs) break;
        c0.m_failedLhs = cn.m_failedLhs; c0.m_failedRhs = cn.m_failedRhs;
        if (rn == 1 || !cn.m_failedLhs) break;
    }
    return 0;
}
