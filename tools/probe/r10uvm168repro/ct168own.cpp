// r10uvm168 — THE OWNER-FINDER + JUDGE DECODER for a BOTH-SIDES-PRESENT head.
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole judge.  This tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// r10uvm164/165's owner-finders answer "who points at the head" when ONE side
// is null.  THIS head has both sides present, so the question is different and
// has two halves:
//
//   (1) THE OWNER CHAIN — walk `VpiParent` up from each side and print the
//       faces, so the head is attributed to a named `param_assign` in a named
//       package and not to "a constant somewhere".
//   (2) WHICH OWN FIELD THE JUDGE READ — `constant::Compare`
//       (UHDM/build/generated/src/constant.cpp:58-71) tests exactly ONE field
//       of its own, `VpiConstType`, after `expr::Compare` has tested
//       VpiDecompile, VpiSize and Typespec.  The tool PROVES that on the live
//       objects instead of trusting the read: it prints all four, then runs an
//       IN-MEMORY ABLATION — set OUR constant's VpiConstType to golden's and
//       re-run the WHOLE `design::Compare`.  If the head moves elsewhere, the
//       const type was the whole head; if it does not, the framing is refuted.
//       (Nothing is written back; the databases on disk are untouched.)
//
// build: g++ -O2 -std=c++17 ct168own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct168own
// usage: ct168own <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static void chain(const char* tag, const BaseClass* o) {
    printf("  %s owner chain:\n", tag);
    int g = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && g < 24;
         p = p->VpiParent(), ++g)
        printf("      < %s\n", ident(p).c_str());
}
// The four fields `constant::Compare` + its `expr::Compare` base actually read.
static void fields(const char* tag, const constant* c) {
    if (!c) { printf("  %s <null>\n", tag); return; }
    const ref_typespec* rt = c->Typespec();
    const typespec* act = rt ? rt->Actual_typespec() : nullptr;
    printf("  %s constType=%-3d size=%-4d decompile=%-12s value=%-14s "
           "ts=%s -> %s\n",
           tag, c->VpiConstType(), c->VpiSize(),
           std::string(c->VpiDecompile()).c_str(),
           std::string(c->VpiValue()).c_str(),
           rt ? ident(rt).c_str() : "<none>", act ? ident(act).c_str() : "<none>");
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct168own <golden> <ours>\n"); return 2; }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }

    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS(golden) = %s\n", ident(c.m_failedLhs).c_str());
    printf("HEAD RHS(ours)   = %s\n", ident(c.m_failedRhs).c_str());
    const BaseClass* HL = c.m_failedLhs;
    const BaseClass* HR = c.m_failedRhs;
    if (!HL || !HR) { printf("ONE SIDE NULL — this is the singular/vector form, not this tool's head\n"); return 0; }

    chain("golden", HL);
    chain("ours  ", HR);

    const constant* cl = any_cast<const constant*>(HL);
    constant* cr = (constant*)any_cast<const constant*>(HR);
    if (!cl || !cr) { printf("HEAD IS NOT A CONSTANT — %s / %s\n",
                             UhdmName(HL->UhdmType()), UhdmName(HR->UhdmType()));
                      return 0; }
    printf("THE FOUR FIELDS constant::Compare + expr::Compare READ:\n");
    fields("golden", cl);
    fields("ours  ", cr);
    printf("  agree: decompile=%d size=%d constType=%d\n",
           std::string(cl->VpiDecompile()) == std::string(cr->VpiDecompile()),
           cl->VpiSize() == cr->VpiSize(),
           cl->VpiConstType() == cr->VpiConstType());

    // ---- THE ABLATION: is VpiConstType the WHOLE head? ------------------
    const int32_t was = cr->VpiConstType();
    cr->VpiConstType(cl->VpiConstType());
    CompareContext c2;
    int r2 = dg->Compare(dou, &c2);
    printf("ABLATION (ours constType %d -> %d, in memory only):\n", was,
           cl->VpiConstType());
    printf("  design::Compare r=%d\n", r2);
    printf("  NEXT LHS(golden) = %s\n", ident(c2.m_failedLhs).c_str());
    printf("  NEXT RHS(ours)   = %s\n", ident(c2.m_failedRhs).c_str());
    printf("  VERDICT: %s\n",
           (c2.m_failedLhs != HL || c2.m_failedRhs != HR)
               ? "THE CONST TYPE WAS THE WHOLE HEAD (the judge moved on)"
               : "REFUTED — the judge stopped on the same pair again");
    cr->VpiConstType(was);
    return 0;
}
