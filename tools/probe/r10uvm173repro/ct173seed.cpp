// r10uvm173 — THE PAIRING PROVER.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge; this tool links the
// SAME generated `Compare` and only reports.  LHS is ALWAYS golden (Surelog),
// RHS is ALWAYS ours.
//
// A `LHS: <null>` head names OUR object and leaves golden's side unset
// (BaseClass.h:191-197: the singular SafeCompare records only the side it
// has), so the head log cannot say WHICH golden object the judge was holding
// when it stopped — and that is the whole question when two listings of the
// same source function exist.  `CompareContext::m_visited` is public and is
// keyed on the LHS, so seeding it with a CANDIDATE golden object makes the
// judge skip exactly that pairing: if the head MOVES, the candidate was the
// partner; if it does not, it was not.
//
//   seed golden's DEF-listing  ref_obj(s)@403:24 #82114 -> head moves to the
//                                                          NEXT argument (str)
//   seed golden's ELAB-listing ref_obj(s)@403:24 #22977 -> head UNCHANGED
//
// which is how this pass learned that its `ref_typespec` head was not a
// typespec defect at all but golden's DEF-listing body paired against OUR
// elaborated one.
//
// build: g++ -O2 -std=c++17 ct173seed.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct173seed
// usage: ct173seed <golden.uhdm> <ours.uhdm> [<uhdm id to seed> ...]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u", std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign) return (const design*)kv.first;
    return nullptr;
}
int main(int argc, char** argv) {
    Serializer sg, so;
    sg.Restore(std::string(argv[1]));
    so.Restore(std::string(argv[2]));
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    CompareContext c;
    for (int i = 3; i < argc; ++i) {
        unsigned id = atoi(argv[i]);
        for (auto& kv : sg.AllObjects())
            if (kv.first && kv.first->UhdmId() == id) {
                c.m_visited.insert(kv.first);
                printf("SEEDED %s\n", ident(kv.first).c_str());
            }
    }
    int r = dg->Compare(dou, &c);
    printf("r=%d\n LHS=%s\n RHS=%s\n", r, ident(c.m_failedLhs).c_str(),
           ident(c.m_failedRhs).c_str());
    if (c.m_failedRhs)
        for (const BaseClass* p = c.m_failedRhs; p; p = p->VpiParent())
            printf("   R< %s\n", ident(p).c_str());
    if (c.m_failedLhs)
        for (const BaseClass* p = c.m_failedLhs; p; p = p->VpiParent())
            printf("   L< %s\n", ident(p).c_str());
    return 0;
}
