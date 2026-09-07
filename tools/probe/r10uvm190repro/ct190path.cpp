// r10uvm190 — THE OWNER **PATH** FINDER.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge; this tool links the
// SAME generated `Compare` and only reports.  LHS is ALWAYS golden (Surelog),
// RHS is ALWAYS ours.
//
// r10uvm164's mirror owner-finder answers "which of OUR edges lands on the
// head".  It does NOT answer "which pair of objects was the judge comparing
// when it stopped", and for a head whose every referrer has a non-null golden
// counterpart that is the question that has to be answered.  This tool
// descends the two databases in lock step from the `design` pair: at each
// step it runs the SAME generated `Compare` on each corresponding child pair
// in a FRESH `CompareContext` (so no `m_visited` state is carried) and follows
// the first child pair that REPRODUCES the head recorded by the whole-design
// run.  The last pair on that chain is the OWNER — the pair whose own
// `Compare` body, not a descendant's, set `m_failedLhs`/`m_failedRhs`.
//
// Correspondence between children is POSITIONAL, exactly as
// `BaseClass::SafeCompare`'s vector overload walks them, so a listing whose
// order or length differs shows up as the descent's own verdict rather than
// being papered over by a face match.
//
// build: g++ -O2 -std=c++17 ct190path.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct190path
// usage: ct190path <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <utility>
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
    if (argc < 3) { fprintf(stderr, "usage: ct190path <golden> <ours>\n"); return 2; }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }

    CompareContext c0;
    int r0 = dg->Compare(dou, &c0);
    const BaseClass* HL = c0.m_failedLhs;
    const BaseClass* HR = c0.m_failedRhs;
    printf("design::Compare r=%d\n", r0);
    printf("HEAD LHS(golden) = %s\n", ident(HL).c_str());
    printf("HEAD RHS(ours)   = %s\n", ident(HR).c_str());

    const BaseClass* G = dg;
    const BaseClass* O = dou;
    // A cycle guard.  `GetByVpiType` also hands back UPWARD edges (an object's
    // own parent, and on some kinds its owner's listing), so an unguarded
    // descent walks design -> package -> param_assign -> parameter -> package
    // for ever.  A pair already on the chain is never followed twice.
    std::vector<std::pair<const BaseClass*, const BaseClass*>> chain;
    auto onChain = [&](const BaseClass* a, const BaseClass* b) {
        for (auto& p : chain)
            if (p.first == a && p.second == b) return true;
        return false;
    };
    chain.push_back({G, O});
    printf("DESCENT (each step: a FRESH CompareContext on the child pair)\n");
    for (int depth = 0; depth < 400; ++depth) {
        printf("  [%d] golden %s\n      ours   %s\n", depth, ident(G).c_str(),
               ident(O).c_str());
        const BaseClass* nG = nullptr;
        const BaseClass* nO = nullptr;
        int nT = 0, nIdx = -1;
        for (int t = 1; t <= 2100 && !nG; ++t) {
            auto tg = G->GetByVpiType(t);
            auto to = O->GetByVpiType(t);
            const BaseClass* g1 = std::get<0>(tg);
            const BaseClass* o1 = std::get<0>(to);
            const std::vector<const BaseClass*>* gv = std::get<2>(tg);
            const std::vector<const BaseClass*>* ov = std::get<2>(to);
            if (g1 && o1 && g1 != G && o1 != O && g1 != G->VpiParent() &&
                o1 != O->VpiParent() && !onChain(g1, o1)) {
                CompareContext c;
                if (g1->Compare(o1, &c) != 0 && c.m_failedLhs == HL &&
                    c.m_failedRhs == HR) {
                    nG = g1; nO = o1; nT = t; nIdx = -2;
                }
            }
            if (nG || !gv || !ov) continue;
            size_t n = gv->size() < ov->size() ? gv->size() : ov->size();
            for (size_t i = 0; i < n; ++i) {
                const BaseClass* a = gv->at(i);
                const BaseClass* b = ov->at(i);
                if (!a || !b || a == G || b == O) continue;
                if (a == G->VpiParent() || b == O->VpiParent()) continue;
                if (onChain(a, b)) continue;
                CompareContext c;
                if (a->Compare(b, &c) != 0 && c.m_failedLhs == HL &&
                    c.m_failedRhs == HR) {
                    nG = a; nO = b; nT = t; nIdx = (int)i;
                    break;
                }
            }
        }
        if (!nG) {
            printf("  OWNER PAIR (no child pair reproduces the head):\n");
            printf("      golden %s\n      ours   %s\n", ident(G).c_str(),
                   ident(O).c_str());
            // Print every edge of the owner pair side by side, so the field
            // that diverged is read off the data and not guessed.
            for (int t = 1; t <= 2100; ++t) {
                auto tg = G->GetByVpiType(t);
                auto to = O->GetByVpiType(t);
                const BaseClass* g1 = std::get<0>(tg);
                const BaseClass* o1 = std::get<0>(to);
                const std::vector<const BaseClass*>* gv = std::get<2>(tg);
                const std::vector<const BaseClass*>* ov = std::get<2>(to);
                if (g1 || o1)
                    printf("      edge %4d singular  golden %s\n"
                           "                         ours   %s\n",
                           t, ident(g1).c_str(), ident(o1).c_str());
                if (gv || ov)
                    printf("      edge %4d vector    golden %s size %zu   "
                           "ours %s size %zu\n",
                           t, gv ? "present" : "NULL", gv ? gv->size() : 0,
                           ov ? "present" : "NULL", ov ? ov->size() : 0);
            }
            break;
        }
        printf("      via edge vpiType=%d %s\n", nT,
               nIdx == -2 ? "(singular)"
                          : ("(vector index " + std::to_string(nIdx) + ")").c_str());
        G = nG; O = nO;
        chain.push_back({G, O});
    }
    return 0;
}
