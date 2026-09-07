// r10uvm184 — WHICH REFERRER IS THE HEAD, WITHOUT MUTATING EITHER DATABASE.
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE INSTRUMENT.  Every generated `ref_obj::Compare` opens with
//     if (!context->m_visited.insert(this).second) return r;
// (`UHDM/build/generated/src/ref_obj.cpp:129`) — so PRE-SEEDING a golden object
// into `CompareContext::m_visited` makes the judge SKIP that object's own
// comparison and keep walking, with no edit to either database.  That turns
// "which of the fifteen referrers did the walk stop on" into an experiment:
//
//   * skip a referrer that is reached BEFORE the head  -> the head is UNCHANGED
//     (the walk still arrives at the real one);
//   * skip THE head's own referrer                     -> the head MOVES.
//
// This is the discriminator the nulling experiment does not have: nulling an
// EARLIER referrer manufactures a NEW failure at that referrer and moves the
// head too, which says nothing about which one the judge stopped on.
//
// build: g++ -O2 -std=c++17 ct184skip.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184skip
// usage: ct184skip <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

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
static std::string chain(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        s += "<";
        s += std::string(UhdmName(p->UhdmType()));
        s += ":";
        s += std::string(p->VpiName());
        s += ":";
        s += std::to_string(p->VpiLineNo());
    }
    return s;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct184skip <golden> <ours>\n"); return 2; }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }

    CompareContext c0;
    printf("design::Compare r=%d\n", dg->Compare(dou, &c0));
    const BaseClass* H = c0.m_failedLhs;
    printf("HEAD LHS(golden) = %s\nHEAD RHS(ours)   = %s\n", ident(H).c_str(),
           ident(c0.m_failedRhs).c_str());
    if (!H) return 0;

    std::vector<const BaseClass*> cand;
    for (auto& kv : sg.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        if (const ref_obj* ro = any_cast<const ref_obj*>(X))
            if (ro->Actual_group() == H) cand.push_back(X);
        if (const ref_var* rv = any_cast<const ref_var*>(X))
            if (rv->Actual_group() == H) cand.push_back(X);
    }
    printf("%zu golden referrers hold a singular vpiActual onto the head\n", cand.size());
    for (const BaseClass* X : cand) {
        CompareContext c;
        c.m_visited.insert(X);
        dg->Compare(dou, &c);
        const bool same = (c.m_failedLhs == c0.m_failedLhs &&
                           c.m_failedRhs == c0.m_failedRhs);
        printf("  skip %-56s -> head %s\n", ident(X).c_str(),
               same ? "UNCHANGED (this referrer is walked BEFORE the head, or not at all)"
                    : ("MOVED to " + ident(c.m_failedLhs) + " / " +
                       ident(c.m_failedRhs)).c_str());
        if (!same) printf("       ==> THE JUDGE STOPS HERE.  chain %s\n", chain(X).c_str());
    }
    return 0;
}
