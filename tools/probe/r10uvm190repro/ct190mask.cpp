// r10uvm190 — THE OWNER FINDER FOR A HEAD WITH MANY IDENTICAL CANDIDATES.
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole judge; this tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// WHY IT EXISTS.  r10uvm164's mirror owner-finder answers "which of OUR edges
// lands on the head", and r10earl60's `tsinst60.cpp` masks ONE golden object
// and re-runs the official `design::Compare`.  Neither settles a head whose
// owner has THIRTY interchangeable twins: masking any single one lets the walk
// pair our object against the NEXT twin and the head comes back UNCHANGED, so a
// single-object mask reads as "not the owner" for every one of them.
//
// Two modes, both of which re-run the OFFICIAL `design::Compare` in a
// CompareContext whose `m_visited` has been pre-seeded (a seeded object's
// `Compare` returns 0 immediately, i.e. it is treated as equal):
//
//   FAMILY   mask EVERY golden object of a kind at a line at once.  If the head
//            changes, the owner is in that family; if it does not, it is not.
//   LEAVEOUT mask the WHOLE family EXCEPT one member, for each member in turn.
//            The members that still produce the head ALONE are the only ones
//            the judge can have stopped on — usually one or two, and the walk
//            order picks the first.
//
// Masking only ever SUPPRESSES comparisons, so it can never reveal an EARLIER
// head; a head that survives a mask was produced by something the mask did not
// cover.  That is what makes the leave-one-out reading sound.
//
// build: g++ -O2 -std=c++17 ct190mask.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct190mask
// usage: ct190mask <golden.uhdm> <ours.uhdm> <mode:family|leaveout> <kind|*> <line>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
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
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 6) {
        fprintf(stderr,
                "usage: ct190mask <golden> <ours> <family|leaveout> <kind|*> <line>\n");
        return 2;
    }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }

    const BaseClass *HL = nullptr, *HR = nullptr;
    {
        CompareContext c;
        int r = dg->Compare(dou, &c);
        HL = c.m_failedLhs; HR = c.m_failedRhs;
        printf("BASE r=%d LHS(golden)=%s RHS(ours)=%s\n", r, ident(HL).c_str(),
               ident(HR).c_str());
    }

    const char* mode = argv[3];
    const char* kind = argv[4];
    unsigned L = (unsigned)atoi(argv[5]);
    std::vector<const BaseClass*> fam;
    for (auto& kv : sg.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->VpiLineNo() != L) continue;
        if (strcmp(kind, "*") != 0 &&
            std::string(UhdmName(o->UhdmType())) != kind) continue;
        fam.push_back(o);
    }
    printf("family kind=%s line=%u size=%zu\n", kind, L, fam.size());
    if (fam.empty()) { printf("EMPTY FAMILY\n"); return 0; }

    if (strcmp(mode, "family") == 0) {
        CompareContext c;
        for (auto* x : fam) c.m_visited.insert(x);
        int r = dg->Compare(dou, &c);
        bool same = (c.m_failedLhs == HL && c.m_failedRhs == HR);
        printf("MASK-WHOLE-FAMILY r=%d head %s  LHS=%s RHS=%s\n", r,
               same ? "SAME (owner is NOT in this family)"
                    : "CHANGED (the owner IS in this family)",
               ident(c.m_failedLhs).c_str(), ident(c.m_failedRhs).c_str());
        return 0;
    }
    if (strcmp(mode, "leaveout") == 0) {
        for (size_t k = 0; k < fam.size(); ++k) {
            CompareContext c;
            for (size_t i = 0; i < fam.size(); ++i)
                if (i != k) c.m_visited.insert(fam[i]);
            dg->Compare(dou, &c);
            bool same = (c.m_failedLhs == HL && c.m_failedRhs == HR);
            printf("KEEP %-58s head %s\n", ident(fam[k]).c_str(),
                   same ? "SAME  <== this object ALONE produces the head" : "changed");
        }
        return 0;
    }
    fprintf(stderr, "unknown mode %s\n", mode);
    return 2;
}
