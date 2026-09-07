// r10uvm184 — THE JUDGE'S DESCENT PATH.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  This tool links the
// SAME generated `Compare` and only reports.  LHS is ALWAYS golden (Surelog),
// RHS is ALWAYS ours.
//
// The owner-finders (r10uvm164's mirror, r10uvm182's forward) answer "who
// POINTS AT the head".  When several objects point at it — the in-body class
// listing, the package out-of-body listing and both clone listings all hold a
// copy of the same subroutine — that is not enough to say WHICH pair the judge
// stopped on.  This tool reconstructs the walk instead:
//
//   start at (design_g, design_o); at each step try every edge `GetByVpiType(t)`
//   in turn, in the SAME order the generated `Compare` bodies read them is NOT
//   assumed — instead each candidate child pair is re-compared with a FRESH
//   CompareContext, and the first pair that reproduces the SAME head
//   (m_failedLhs / m_failedRhs identical to the design-level head) is descended
//   into.  The chain printed is therefore an EXHIBITED failing path: every step
//   is a pair that on its own fails at the same head.
//
// build: g++ -O2 -std=c++17 ct184path.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct184path
// usage: ct184path <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>
#include <utility>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u", std::string(UhdmName(o->UhdmType())).c_str(),
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
    if (argc < 3) { fprintf(stderr, "usage: ct184path <golden> <ours>\n"); return 2; }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c0;
    printf("design::Compare r=%d\n", dg->Compare(dou, &c0));
    const BaseClass* HL = c0.m_failedLhs;
    const BaseClass* HR = c0.m_failedRhs;
    printf("HEAD LHS(golden) = %s\nHEAD RHS(ours)   = %s\n", ident(HL).c_str(),
           ident(HR).c_str());

    std::set<std::pair<const BaseClass*, const BaseClass*>> seen;
    const BaseClass* L = dg;
    const BaseClass* R = dou;
    seen.insert({L, R});
    for (int depth = 0; depth < 64; ++depth) {
        printf("[%2d] %s\n     %s\n", depth, ident(L).c_str(), ident(R).c_str());
        if (L == HL && R == HR) { printf("     == THE HEAD PAIR\n"); break; }
        const BaseClass* nl = nullptr;
        const BaseClass* nr = nullptr;
        int usedT = -1, usedIdx = -1;
        size_t lsz = 0, rsz = 0;
        for (int t = 1; t <= 2100 && !nl; ++t) {
            auto tl = L->GetByVpiType(t);
            auto tr = R->GetByVpiType(t);
            const BaseClass* l1 = std::get<0>(tl);
            const BaseClass* r1 = std::get<0>(tr);
            const std::vector<const BaseClass*>* lv = std::get<2>(tl);
            const std::vector<const BaseClass*>* rv = std::get<2>(tr);
            if (l1 && r1) {
                CompareContext c;
                if (!seen.count({l1, r1}) && l1->Compare(r1, &c) != 0 &&
                    c.m_failedLhs == HL && c.m_failedRhs == HR) {
                    nl = l1; nr = r1; usedT = t; usedIdx = -2;
                }
            }
            if (!nl && l1 && !r1 && l1 == HL && HR == nullptr) {
                printf("     SINGULAR EDGE vpiType=%d : golden %s, OURS <null>\n", t,
                       ident(l1).c_str());
                nl = l1; nr = nullptr; usedT = t; usedIdx = -3;
                break;
            }
            if (!nl && lv && rv) {
                for (size_t i = 0; i < lv->size() && i < rv->size(); ++i) {
                    const BaseClass* a = lv->at(i);
                    const BaseClass* b = rv->at(i);
                    if (a && !b && a == HL && HR == nullptr) {
                        printf("     VECTOR ELEMENT vpiType=%d idx=%zu : golden %s, OURS <null>\n",
                               t, i, ident(a).c_str());
                        nl = a; nr = nullptr; usedT = t; usedIdx = (int)i;
                        break;
                    }
                    if (!a || !b) continue;
                    CompareContext c;
                    if (!seen.count({a, b}) && a->Compare(b, &c) != 0 &&
                        c.m_failedLhs == HL && c.m_failedRhs == HR) {
                        nl = a; nr = b; usedT = t; usedIdx = (int)i;
                        lsz = lv->size(); rsz = rv->size();
                        break;
                    }
                }
            }
        }
        if (!nl) {
            printf("     NO CHILD PAIR REPRODUCES THE HEAD — the failure is IN this pair's\n"
                   "     own fields or in an edge whose two sides are not both present.\n");
            // report every edge whose two sides disagree in presence/size
            for (int t = 1; t <= 2100; ++t) {
                auto tl = L->GetByVpiType(t);
                auto tr = R->GetByVpiType(t);
                const BaseClass* l1 = std::get<0>(tl);
                const BaseClass* r1 = std::get<0>(tr);
                const std::vector<const BaseClass*>* lv = std::get<2>(tl);
                const std::vector<const BaseClass*>* rv = std::get<2>(tr);
                if ((l1 != nullptr) != (r1 != nullptr))
                    printf("     EDGE vpiType=%d singular golden=%s ours=%s\n", t,
                           ident(l1).c_str(), ident(r1).c_str());
                if (lv && rv && lv->size() != rv->size())
                    printf("     EDGE vpiType=%d vector sizes golden=%zu ours=%zu\n", t,
                           lv->size(), rv->size());
                if ((lv && !lv->empty()) && !rv)
                    printf("     EDGE vpiType=%d vector golden=%zu ours=NULL\n", t, lv->size());
                if ((rv && !rv->empty()) && !lv)
                    printf("     EDGE vpiType=%d vector golden=NULL ours=%zu\n", t, rv->size());
            }
            break;
        }
        printf("     -> edge vpiType=%d %s%s\n", usedT,
               usedIdx == -2 ? "(singular)"
                             : ("(index " + std::to_string(usedIdx) + ")").c_str(),
               (lsz || rsz) ? (" sizes " + std::to_string(lsz) + "/" +
                               std::to_string(rsz)).c_str() : "");
        if (usedIdx == -3 || nr == nullptr) {
            printf("[%2d] %s\n     <null>\n     == THE HEAD PAIR (singular/element null on OURS)\n",
                   depth + 1, ident(nl).c_str());
            break;
        }
        seen.insert({nl, nr});
        L = nl; R = nr;
    }
    return 0;
}
