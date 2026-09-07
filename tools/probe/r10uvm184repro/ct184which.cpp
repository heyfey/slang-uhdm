// r10uvm184 — WHICH REFERRER DID THE JUDGE STOP ON?  MEASUREMENT ONLY; the
// official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is
// ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// When several golden objects hold a SINGULAR edge onto the head object, the
// owner-finder cannot say which of them the walk reached first — a fresh
// sub-Compare is no proxy either, because `typespec::Compare` walks
// `Typedef_alias`/`Instance` and re-enters the whole package (RESUME.md §9), so
// a greedy descent cascades.
//
// THE EXPERIMENT.  Every candidate referrer is a golden `ref_obj`/`ref_var`
// whose `Actual_group()` IS the head.  Null that one edge IN MEMORY (the file
// on disk is never written) and re-run `design::Compare` with a FRESH
// CompareContext.  If the head moves, that referrer is on the walk BEFORE the
// head's other referrers — the judge stopped there.  Repeated one referrer at a
// time, the surviving head names the next one, so the whole ORDER is exhibited
// rather than assumed.
//
// build: g++ -O2 -std=c++17 ct184which.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184which
// usage: ct184which <golden.uhdm> <ours.uhdm> [maxsteps]
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
    if (argc < 3) { fprintf(stderr, "usage: ct184which <golden> <ours> [maxsteps]\n"); return 2; }
    const int maxSteps = argc > 3 ? atoi(argv[3]) : 12;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }

    for (int step = 0; step < maxSteps; ++step) {
        CompareContext c;
        int r = dg->Compare(dou, &c);
        printf("STEP %d  design::Compare r=%d\n", step, r);
        printf("   HEAD LHS(golden) = %s\n", ident(c.m_failedLhs).c_str());
        printf("   HEAD RHS(ours)   = %s\n", ident(c.m_failedRhs).c_str());
        if (r == 0) break;
        const BaseClass* H = c.m_failedLhs;
        if (!H || c.m_failedRhs) {
            printf("   (not a singular-null head; stopping)\n");
            break;
        }
        // Candidate referrers: golden ref_obj / ref_var whose Actual_group IS H.
        std::vector<BaseClass*> cand;
        for (auto& kv : sg.AllObjects()) {
            BaseClass* X = const_cast<BaseClass*>(kv.first);
            if (!X) continue;
            if (ref_obj* ro = any_cast<ref_obj*>(X))
                if (ro->Actual_group() == H) cand.push_back(X);
            if (ref_var* rv = any_cast<ref_var*>(X))
                if (rv->Actual_group() == H) cand.push_back(X);
        }
        printf("   %zu golden referrer(s) hold a singular vpiActual onto the head\n",
               cand.size());
        // Null them one at a time; the FIRST one whose removal moves the head is
        // the one the walk reached.
        bool moved = false;
        for (BaseClass* X : cand) {
            any* saved = nullptr;
            if (ref_obj* ro = any_cast<ref_obj*>(X)) { saved = ro->Actual_group(); ro->Actual_group(nullptr); }
            else if (ref_var* rv = any_cast<ref_var*>(X)) { saved = rv->Actual_group(); rv->Actual_group(nullptr); }
            CompareContext c2;
            dg->Compare(dou, &c2);
            const bool same = (c2.m_failedLhs == c.m_failedLhs &&
                               c2.m_failedRhs == c.m_failedRhs);
            printf("     null %-58s -> head %s : %s\n", ident(X).c_str(),
                   same ? "UNCHANGED" : "MOVED",
                   same ? "" : (ident(c2.m_failedLhs) + " / " + ident(c2.m_failedRhs)).c_str());
            if (!same) {
                printf("     ==> THE JUDGE STOPPED HERE.  referrer chain %s\n",
                       chain(X).c_str());
                moved = true;
                break;  // leave it nulled and re-run the outer loop
            }
            // restore and try the next
            if (ref_obj* ro = any_cast<ref_obj*>(X)) ro->Actual_group(saved);
            else if (ref_var* rv = any_cast<ref_var*>(X)) rv->Actual_group(saved);
        }
        if (!moved) {
            printf("   NO referrer's removal moved the head — the edge is not a "
                   "ref_obj/ref_var vpiActual.\n");
            break;
        }
    }
    return 0;
}
