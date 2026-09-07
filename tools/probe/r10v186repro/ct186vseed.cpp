// r10v186 (VERIFIER) — MASK THE WHOLE LAW WINDOW AND RE-RUN THE OFFICIAL
// COMPARE ON BOTH BINARIES.  MEASUREMENT ONLY; uhdm-cmp is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE QUESTION.  r10uvm186's arm A moves the ELAB cmp from 31 lines to 9212
// and calls the new head "a pre-existing difference the cleared mask was
// hiding".  A bigger number after a patch is exactly the shape a REGRESSION
// also has, and RESUME §9 says a cmp line count is not comparable across a
// change that removes a cascade mask.  So ask the judge itself:
//
//   pre-seed into CompareContext::m_visited EVERY golden ref_obj / ref_var
//   whose VpiParent chain reaches a `new` method_func_call — i.e. the ENTIRE
//   window this law can touch, cells it fixes and cells it does not — and
//   re-run the OFFICIAL design::Compare against BOTH our databases.
//
// With the whole window masked, the two runs see a design in which nothing
// the patch wrote can be reached.  If they then report the SAME head, the
// patched binary's head is PRE-EXISTING and was merely unmasked; if they
// differ, the patch wrote something outside the window.
//
// build: g++ -O2 -std=c++17 ct186vseed.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186vseed
// usage: ct186vseed <golden.uhdm> <pristine.uhdm> <patched.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign) return (const design*)kv.first;
    return nullptr;
}
static bool inNewWindow(const BaseClass* o) {
    int d = 0;
    for (const BaseClass* p = o->VpiParent(); p && d < 40; p = p->VpiParent(), ++d)
        if (p->UhdmType() == uhdmmethod_func_call) {
            const method_func_call* m = (const method_func_call*)p;
            if (m->VpiName() == "new" && !m->Function()) return true;
        }
    return false;
}
int main(int argc, char** argv) {
    if (argc < 4) { fprintf(stderr, "usage: ct186vseed <golden> <pristine> <patched>\n"); return 2; }
    Serializer sg, sa, sb;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (sa.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL pristine\n"); return 3; }
    if (sb.Restore(std::string(argv[3])).empty()) { printf("RESTORE_FAIL patched\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* da = topDesign(sa);
    const design* db = topDesign(sb);
    if (!dg || !da || !db) { printf("NO_DESIGN\n"); return 3; }
    std::vector<const BaseClass*> seed;
    for (auto& kv : sg.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() != uhdmref_obj && o->UhdmType() != uhdmref_var) continue;
        if (inNewWindow(o)) seed.push_back(o);
    }
    printf("SEED %zu golden refs inside a `new[...]` window\n", seed.size());
    {
        CompareContext c; int r = dg->Compare(da, &c);
        printf("UNMASKED pristine r=%d head %s / %s\n", r,
               ident(c.m_failedLhs).c_str(), ident(c.m_failedRhs).c_str());
    }
    {
        CompareContext c; int r = dg->Compare(db, &c);
        printf("UNMASKED patched  r=%d head %s / %s\n", r,
               ident(c.m_failedLhs).c_str(), ident(c.m_failedRhs).c_str());
    }
    {
        CompareContext c; for (auto* x : seed) c.m_visited.insert(x);
        int r = dg->Compare(da, &c);
        printf("MASKED   pristine r=%d head %s / %s\n", r,
               ident(c.m_failedLhs).c_str(), ident(c.m_failedRhs).c_str());
    }
    {
        CompareContext c; for (auto* x : seed) c.m_visited.insert(x);
        int r = dg->Compare(db, &c);
        printf("MASKED   patched  r=%d head %s / %s\n", r,
               ident(c.m_failedLhs).c_str(), ident(c.m_failedRhs).c_str());
    }
    return 0;
}
