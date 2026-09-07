// r10uvm196 — THE JUDGE CHASER.  MEASUREMENT ONLY; `uhdm-cmp` is the sole
// judge.  This tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// r10uvm179's `ct179own` descends by VpiParent-CHILDREN, which stops dead at a
// `task_call` — the callee `task` is NOT a VpiParent-child of the call, it is a
// LINK.  This chaser descends by the generated edge accessor `GetByVpiType`
// instead, so it follows LINKS as well as containment, and never names a field
// by hand.  At every pair it asks each edge's own `Compare` (fresh context)
// whether it reproduces the design-level head; the first that does is the next
// step.  vpiParent (the edge whose target IS `L->VpiParent()`) is excluded:
// the generated `Compare`s never read it (RESUME §9) and following it walks
// back out of the design.
//
// It STOPS when no edge reproduces, and then prints, for the stopping pair,
// EVERY edge with its LHS/RHS and the vector sizes — which is where a
// `<vector>` present on golden and NULL on ours (BaseClass.h's vector overload
// with `rhs == nullptr`, which sets the OWNER as LHS and leaves RHS unset)
// becomes visible.
//
// build: g++ -O2 -std=c++17 ct196chase.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct196chase
// usage: ct196chase <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
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
static std::string parentPath(const BaseClass* o) {
    std::string s;
    int g = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && g < 64;
         p = p->VpiParent(), ++g) {
        s += "<";
        s += UhdmName(p->UhdmType());
        s += ":";
        s += p->VpiName();
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
static bool reproduces(const BaseClass* L, const BaseClass* R,
                       const BaseClass* HL, const BaseClass* HR) {
    if (!L || !R) return false;
    CompareContext c;
    L->Compare(R, &c);
    return c.m_failedLhs == HL && c.m_failedRhs == HR;
}
static void dumpEdges(const BaseClass* L, const BaseClass* R,
                      const BaseClass* HL, const BaseClass* HR) {
    for (int t = 1; t <= 2100; ++t) {
        auto tl = L->GetByVpiType(t);
        auto tr = R->GetByVpiType(t);
        const BaseClass* ol = std::get<0>(tl);
        const BaseClass* orr = std::get<0>(tr);
        const std::vector<const BaseClass*>* vl = std::get<2>(tl);
        const std::vector<const BaseClass*>* vr = std::get<2>(tr);
        if (ol || orr) {
            const char* tag = "";
            if (ol && L->VpiParent() == ol) tag = "  (vpiParent — not read by Compare)";
            int rr = 2;
            if (ol && orr) { CompareContext cc; rr = ol->Compare(orr, &cc); }
            printf("    edge %-4d SING  L=%-56s R=%-56s r=%s%s\n", t,
                   ident(ol).c_str(), ident(orr).c_str(),
                   rr == 2 ? "n/a" : std::to_string(rr).c_str(), tag);
        }
        if (vl || vr) {
            printf("    edge %-4d VEC   Lsize=%s Rsize=%s%s\n", t,
                   vl ? std::to_string(vl->size()).c_str() : "NULL",
                   vr ? std::to_string(vr->size()).c_str() : "NULL",
                   ((vl && !vl->empty() && !vr) || (!vl && vr && !vr->empty()) ||
                    (vl && vr && vl->size() != vr->size()))
                       ? "   <== SIZE/NULL MISMATCH — the OWNER is the head"
                       : "");
            size_t n = vl ? vl->size() : 0, m = vr ? vr->size() : 0;
            for (size_t i = 0; i < n && i < m; ++i) {
                if (!vl->at(i) || !vr->at(i)) continue;
                CompareContext cc;
                if (vl->at(i)->Compare(vr->at(i), &cc) != 0)
                    printf("        [%zu] L=%-56s R=%-56s   FAILS (head %s / %s)\n", i,
                           ident(vl->at(i)).c_str(), ident(vr->at(i)).c_str(),
                           ident(cc.m_failedLhs).c_str(), ident(cc.m_failedRhs).c_str());
            }
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct196chase <golden> <ours>\n"); return 2; }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c;
    int r = dg->Compare(dou, &c);
    const BaseClass* HL = c.m_failedLhs;
    const BaseClass* HR = c.m_failedRhs;
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS(golden) = %s\n", ident(HL).c_str());
    printf("HEAD RHS(ours)   = %s\n", ident(HR).c_str());
    printf("HEAD LHS parent chain: %s\n", parentPath(HL).c_str());

    // THE HEAD-OWNER DUMP.  `HEAD RHS` is UNSET, so BaseClass.h's overload was
    // either the SINGULAR one (`lhs != null, rhs == null`, m_failedLhs = the
    // VALUE) or the VECTOR one (`rhs == nullptr`, m_failedLhs = the OWNER).
    // Both readings are settled by dumping the head object's OWN edges against
    // its counterpart, and by scanning for a singular edge that lands on it.
    if (argc > 3 && std::string(argv[3]) == "--headowner" && HL) {
        printf("\n== HEAD-OWNER DUMP: the head object's own edges vs its counterpart ==\n");
        const BaseClass* HRc = nullptr;
        int nm = 0;
        for (auto& kv : so.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || o->UhdmType() != HL->UhdmType()) continue;
            if (std::string(o->VpiName()) != std::string(HL->VpiName())) continue;
            if (o->VpiLineNo() != HL->VpiLineNo() ||
                o->VpiEndLineNo() != HL->VpiEndLineNo()) continue;
            if (parentPath(o) != parentPath(HL)) continue;
            ++nm;
            if (!HRc) HRc = o;
        }
        printf("  counterparts on our side: %d -> %s\n", nm, ident(HRc).c_str());
        if (HRc) dumpEdges(HL, HRc, HL, HR);
        printf("\n  SINGULAR EDGES LANDING ON THE GOLDEN HEAD, and ours:\n");
        for (auto& kv : sg.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            for (int t = 1; t <= 2100; ++t) {
                auto tup = X->GetByVpiType(t);
                if (std::get<0>(tup) != HL) continue;
                printf("    golden %s edge %d\n", ident(X).c_str(), t);
            }
        }
        return 0;
    }

    const BaseClass* L = dg;
    const BaseClass* R = dou;
    printf("\n== CHASE (edge by edge, through LINKS as well as containment) ==\n");
    std::set<const BaseClass*> seen;
    for (int depth = 0; depth < 200; ++depth) {
        printf("  [%d] L=%s\n      R=%s\n", depth, ident(L).c_str(), ident(R).c_str());
        if (seen.count(L)) { printf("      (cycle)\n"); break; }
        seen.insert(L);
        const BaseClass* nl = nullptr;
        const BaseClass* nr = nullptr;
        int which = -1;
        long widx = -1;
        for (int t = 1; t <= 2100 && !nl; ++t) {
            auto tl = L->GetByVpiType(t);
            auto tr = R->GetByVpiType(t);
            const BaseClass* ol = std::get<0>(tl);
            const BaseClass* orr = std::get<0>(tr);
            if (ol && orr && ol != L->VpiParent() &&
                reproduces(ol, orr, HL, HR)) {
                nl = ol; nr = orr; which = t; widx = -1; break;
            }
            const std::vector<const BaseClass*>* vl = std::get<2>(tl);
            const std::vector<const BaseClass*>* vr = std::get<2>(tr);
            if (!vl || !vr) continue;
            for (size_t i = 0; i < vl->size() && i < vr->size(); ++i)
                if (vl->at(i) && vr->at(i) && vl->at(i) != L->VpiParent() &&
                    reproduces(vl->at(i), vr->at(i), HL, HR)) {
                    nl = vl->at(i); nr = vr->at(i); which = t; widx = (long)i; break;
                }
        }
        if (!nl) {
            printf("      STOP: no edge of this pair reproduces the head.\n");
            printf("      EVERY EDGE OF THE STOPPING PAIR:\n");
            dumpEdges(L, R, HL, HR);
            break;
        }
        printf("      via edge vpiType=%d%s\n", which,
               widx >= 0 ? (" index " + std::to_string(widx)).c_str() : " (singular)");
        L = nl; R = nr;
    }
    return 0;
}
