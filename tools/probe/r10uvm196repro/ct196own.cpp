// r10uvm196 — THE OWNER-FINDER + VIEW LOCATOR for the SimpleUVM design-root
// head.  MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole
// judge.  This tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The head is `LHS: module_inst work@top / RHS: <null>` — the whole design
// root, 664681 cmp lines of DECOMPILE, not a distance.  So the tool must
// DESCEND: STEP 1 walks the golden head's own parent chain top-down asking
// each pair whether its OWN Compare reproduces the design-level head, STEP 2
// descends child pair by child pair, and STEP 3 asks EVERY edge of the pair
// that stops the descent (generically, through `GetByVpiType`, so no field is
// named by hand) which one reproduces it.  STEP 4 then LOCATES the two objects
// the failing edge names inside the design's package views — `AllPackages`
// (the DEF view) and `TopPackages` (the ELAB view) — with the listing index,
// so "which twin does each side bind" is answered by position, not by guess.
// STEP 5 is the VIEW MAP (VpiTop, listing sizes, qualified-entry counts).
//
// build: g++ -O2 -std=c++17 ct196own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct196own
// usage: ct196own <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
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
typedef std::map<const BaseClass*, std::vector<const BaseClass*>> kidmap_t;
static void buildKids(Serializer& s, kidmap_t& m) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (const BaseClass* p = o->VpiParent()) m[p].push_back(o);
    }
}
static std::string parentPath(const BaseClass* o) {
    std::string s;
    int g = 0;
    for (const BaseClass* p = o->VpiParent(); p && g < 64; p = p->VpiParent(), ++g) {
        s += "<";
        s += UhdmName(p->UhdmType());
        s += ":";
        s += p->VpiName();
        s += ":";
        s += std::to_string(p->VpiLineNo());
    }
    return s;
}
static bool sameFace(const BaseClass* a, const BaseClass* b) {
    return a->UhdmType() == b->UhdmType() &&
           std::string(a->VpiName()) == std::string(b->VpiName()) &&
           a->VpiLineNo() == b->VpiLineNo() &&
           a->VpiColumnNo() == b->VpiColumnNo() &&
           a->VpiEndLineNo() == b->VpiEndLineNo() &&
           a->VpiEndColumnNo() == b->VpiEndColumnNo();
}
static bool reproduces(const BaseClass* L, const BaseClass* R,
                       const BaseClass* HL, const BaseClass* HR) {
    if (!L || !R) return false;
    CompareContext c;
    L->Compare(R, &c);
    return c.m_failedLhs == HL && c.m_failedRhs == HR;
}

// ---- STEP 4's locator: where does an object sit in the design's views? ----
struct Loc {
    std::string where;  // "AllPackages[i].Task_funcs[j]" etc, joined
};
static std::string locate(Serializer& S, const design* d, const BaseClass* o) {
    if (!o) return "<null>";
    std::string out;
    auto scanPkgVec = [&](const VectorOfpackage* v, const char* tag) {
        if (!v) return;
        for (size_t i = 0; i < v->size(); ++i) {
            const package* p = (*v)[i];
            if (!p) continue;
            if ((const BaseClass*)p == o) {
                out += std::string(tag) + "[" + std::to_string(i) + "] ITSELF; ";
                continue;
            }
            if (p->Task_funcs())
                for (size_t j = 0; j < p->Task_funcs()->size(); ++j)
                    if ((const BaseClass*)p->Task_funcs()->at(j) == o)
                        out += std::string(tag) + "[" + std::to_string(i) + "](" +
                               std::string(p->VpiName()) + ").Task_funcs[" +
                               std::to_string(j) + "]/" +
                               std::to_string(p->Task_funcs()->size()) + "; ";
            if (p->Class_defns())
                for (auto* c : *p->Class_defns())
                    if (c && c->Task_funcs())
                        for (size_t j = 0; j < c->Task_funcs()->size(); ++j)
                            if ((const BaseClass*)c->Task_funcs()->at(j) == o)
                                out += std::string(tag) + "[" + std::to_string(i) +
                                       "](" + std::string(p->VpiName()) +
                                       ").class_defn(" + std::string(c->VpiName()) +
                                       ").Task_funcs[" + std::to_string(j) + "]; ";
        }
    };
    scanPkgVec(d->AllPackages(), "AllPackages");
    scanPkgVec(d->TopPackages(), "TopPackages");
    // generic: every edge that lands on it
    int n = 0;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        for (int t = 1; t <= 2100; ++t) {
            auto tup = X->GetByVpiType(t);
            if (std::get<0>(tup) == o) { ++n; }
            const std::vector<const BaseClass*>* v = std::get<2>(tup);
            if (v)
                for (size_t i = 0; i < v->size(); ++i)
                    if (v->at(i) == o) ++n;
        }
    }
    out += "inbound-edges=" + std::to_string(n);
    return out;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct196own <golden> <ours>\n"); return 2; }
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
    if (!HL) return 0;

    kidmap_t kg, ko;
    buildKids(sg, kg);
    buildKids(so, ko);

    std::vector<const BaseClass*> chain;
    for (const BaseClass* p = HL; p; p = p->VpiParent()) chain.push_back(p);
    printf("\n== STEP 1 — PARENT-CHAIN PROBE (top down; REPRO = same head) ==\n");
    const BaseClass* L = dg;
    const BaseClass* R = dou;
    for (size_t i = chain.size(); i-- > 0;) {
        const BaseClass* lc = chain[i];
        const BaseClass* match = nullptr;
        int nm = 0, nrep = 0;
        for (auto& kv : so.AllObjects()) {
            const BaseClass* rc = kv.first;
            if (!rc || !sameFace(lc, rc)) continue;
            if (parentPath(lc) != parentPath(rc)) continue;
            ++nm;
            if (reproduces(lc, rc, HL, HR)) { ++nrep; if (!match) match = rc; }
        }
        printf("  %-58s ourMatches=%d repro=%d %s\n", ident(lc).c_str(), nm, nrep,
               nm == 0 ? "NO COUNTERPART" : (nrep ? "REPRO" : "no-repro"));
        if (nrep) { L = lc; R = match; }
    }

    printf("\n== STEP 2 — DESCENT (child pair whose own Compare reproduces) ==\n");
    printf("  [0] %s\n      vs %s\n", ident(L).c_str(), ident(R).c_str());
    for (int depth = 1; depth < 64; ++depth) {
        const BaseClass* nl = nullptr;
        const BaseClass* nr = nullptr;
        int ambiguous = 0;
        for (const BaseClass* lc : kg[L]) {
            for (const BaseClass* rc : ko[R]) {
                if (!sameFace(lc, rc)) continue;
                if (!reproduces(lc, rc, HL, HR)) continue;
                if (nl) { ++ambiguous; continue; }
                nl = lc; nr = rc;
            }
        }
        if (!nl) {
            printf("  STOP: no child pair reproduces -> the edge is a FIELD of the pair above\n");
            break;
        }
        printf("  [%d] %s\n      vs %s%s\n", depth, ident(nl).c_str(),
               ident(nr).c_str(), ambiguous ? "   (AMBIGUOUS)" : "");
        L = nl; R = nr;
    }

    printf("\n== STEP 3 — THE FAILING FIELD OF THE STOPPING PAIR (generic) ==\n");
    printf("  PAIR L=%s\n       R=%s\n", ident(L).c_str(), ident(R).c_str());
    const BaseClass* fl = nullptr;
    const BaseClass* fr = nullptr;
    for (int t = 1; t <= 2100; ++t) {
        auto tl = L->GetByVpiType(t);
        auto tr = R->GetByVpiType(t);
        const BaseClass* ol = std::get<0>(tl);
        const BaseClass* orr = std::get<0>(tr);
        const std::vector<const BaseClass*>* vl = std::get<2>(tl);
        const std::vector<const BaseClass*>* vr = std::get<2>(tr);
        if (ol || orr) {
            int rr = 2;
            if (ol && orr) { CompareContext cc; rr = ol->Compare(orr, &cc); }
            printf("  edge vpiType=%-4d SINGULAR  LHS=%-58s RHS=%-58s r=%s%s\n", t,
                   ident(ol).c_str(), ident(orr).c_str(),
                   rr == 2 ? "n/a" : std::to_string(rr).c_str(),
                   (ol && orr && rr != 0) ? "   <== FAILS" : "");
            if (ol && orr && rr != 0 && !fl) { fl = ol; fr = orr; }
        }
        if (vl || vr) {
            size_t n = vl ? vl->size() : 0, m = vr ? vr->size() : 0;
            printf("  edge vpiType=%-4d VECTOR    LHSsize=%zu RHSsize=%zu\n", t, n, m);
            for (size_t i = 0; i < n && i < m; ++i) {
                CompareContext cc;
                int rr = vl->at(i) && vr->at(i) ? vl->at(i)->Compare(vr->at(i), &cc) : 2;
                if (rr != 0)
                    printf("      [%zu] LHS=%-58s RHS=%-58s r=%s   <== FAILS\n", i,
                           ident(vl->at(i)).c_str(), ident(vr->at(i)).c_str(),
                           rr == 2 ? "n/a" : std::to_string(rr).c_str());
            }
        }
    }

    printf("\n== STEP 4 — LOCATE THE TWO OBJECTS THE FAILING EDGE NAMES ==\n");
    if (fl && fr) {
        printf("  GOLDEN %s\n", ident(fl).c_str());
        printf("      parent chain: %s\n", parentPath(fl).c_str());
        printf("      location: %s\n", locate(sg, dg, fl).c_str());
        printf("  OURS   %s\n", ident(fr).c_str());
        printf("      parent chain: %s\n", parentPath(fr).c_str());
        printf("      location: %s\n", locate(so, dou, fr).c_str());
        // the TWIN test: every same-face object of that kind on each side
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            const design* D = side ? dou : dg;
            const BaseClass* H = side ? fr : fl;
            printf("  ---- TWINS on %s (same kind, same name, same span) ----\n",
                   side ? "OURS" : "GOLDEN");
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || !sameFace(o, H)) continue;
                printf("      %s  parent=%s\n         loc=%s\n", ident(o).c_str(),
                       parentPath(o).c_str(), locate(S, D, o).c_str());
            }
        }
        // and re-compare the two twin objects field by field
        printf("  ---- the two bound objects, compared ----\n");
        CompareContext cc;
        int rr = fl->Compare(fr, &cc);
        printf("      r=%d  failedLHS=%s\n              failedRHS=%s\n", rr,
               ident(cc.m_failedLhs).c_str(), ident(cc.m_failedRhs).c_str());
    } else {
        printf("  (no singular field mismatch found)\n");
    }

    printf("\n== STEP 5 — THE VIEW MAP ==\n");
    for (int side = 0; side < 2; ++side) {
        const design* D = side ? dou : dg;
        printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
        auto dumpv = [&](const VectorOfpackage* v, const char* tag) {
            if (!v) { printf("    %s: <null>\n", tag); return; }
            for (size_t i = 0; i < v->size(); ++i) {
                const package* p = (*v)[i];
                if (!p) continue;
                size_t tf = p->Task_funcs() ? p->Task_funcs()->size() : 0;
                size_t cd = p->Class_defns() ? p->Class_defns()->size() : 0;
                size_t q = 0;
                if (p->Task_funcs())
                    for (auto* t : *p->Task_funcs())
                        if (std::string(t->VpiName()).find("::") != std::string::npos) ++q;
                printf("    %s[%zu] %s #%u VpiTop=%d Task_funcs=%zu qualified=%zu Class_defns=%zu\n",
                       tag, i, std::string(p->VpiName()).c_str(), p->UhdmId(),
                       (int)p->VpiTop(), tf, q, cd);
            }
        };
        dumpv(D->AllPackages(), "AllPackages");
        dumpv(D->TopPackages(), "TopPackages");
    }
    return 0;
}
