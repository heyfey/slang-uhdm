// r10uvm192 — THE OWNER-FINDER for a head whose BOTH sides are PRESENT.
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole judge.  This tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// r10uvm190's `ct190own.cpp` is the MIRROR scan for an `LHS: <null>` head: it
// walks OUR edges only.  THIS head has a full LHS *and* a full RHS (a VpiName
// mismatch inside `BaseClass::Compare`), so the failing edge is a VECTOR pair
// and BOTH sides must be scanned: the question is WHICH listing's vector, at
// WHICH index, and what the neighbours are on each side.  `GetByVpiType` is the
// generated, kind-agnostic edge accessor, so no field is named by hand.
//
// STEP 1   every edge of GOLDEN landing on the golden head; every edge of OURS
//          landing on our head; for a vector edge the index, the size and the
//          three neighbours idx-1/idx/idx+1 on that same side.
// STEP 2   THE TWIN TEST — every task/function object in each database whose
//          SPAN matches the head's, with id, kind, name, parent: this answers
//          "one object listed twice, or two distinct objects".
// STEP 3   THE LISTING CENSUS — for one named scope (package or class_defn),
//          the whole Task_funcs vector with index, id, kind and name, both
//          sides side by side, so the first differing index is visible.
//
// build: g++ -O2 -std=c++17 ct192own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct192own
// usage: ct192own <golden.uhdm> <ours.uhdm> [<scope name for STEP 3>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <string>
#include <algorithm>
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
static bool isSub(const BaseClass* o) {
    return o && (o->UhdmType() == uhdmfunction || o->UhdmType() == uhdmtask);
}

// Every edge of `S` that lands on `H`; for vector edges also the neighbours.
static void scanEdges(Serializer& S, const BaseClass* H, const char* side) {
    if (!H) { printf("  %s head is null\n", side); return; }
    printf("  ---- %s: edges landing on %s ----\n", side, ident(H).c_str());
    printf("  parent chain:\n");
    for (const BaseClass* p = H->VpiParent(); p; p = p->VpiParent())
        printf("      < %s\n", ident(p).c_str());
    int found = 0;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        for (int t = 1; t <= 2100; ++t) {
            auto tup = X->GetByVpiType(t);
            const BaseClass* one = std::get<0>(tup);
            const std::vector<const BaseClass*>* vec = std::get<2>(tup);
            if (one == H) {
                printf("    OWNER %s\n        edge vpiType=%d (singular)\n",
                       ident(X).c_str(), t);
                ++found;
            }
            if (!vec) continue;
            for (size_t i = 0; i < vec->size(); ++i) {
                if (vec->at(i) != H) continue;
                printf("    OWNER %s\n        edge vpiType=%d (vector index %zu of %zu)\n",
                       ident(X).c_str(), t, i, vec->size());
                for (long j = (long)i - 1; j <= (long)i + 1; ++j) {
                    if (j < 0 || (size_t)j >= vec->size()) continue;
                    printf("          [%ld] %s%s\n", j, ident(vec->at(j)).c_str(),
                           (size_t)j == i ? "   <== HEAD" : "");
                }
                ++found;
            }
        }
    }
    if (!found) printf("    NO EDGE LANDS ON THE HEAD\n");
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct192own <golden> <ours> [scope]\n"); return 2; }
    const char* scopeWant = argc > 3 ? argv[3] : nullptr;
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

    printf("\n== STEP 1 — THE FAILING EDGE, BOTH SIDES ==\n");
    scanEdges(sg, HL, "GOLDEN");
    scanEdges(so, HR, "OURS");

    printf("\n== STEP 2 — THE TWIN TEST (every task/function at the head's span) ==\n");
    if (HL) {
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            const BaseClass* H = side ? HR : HL;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!isSub(o)) continue;
                if (o->VpiLineNo() != H->VpiLineNo() ||
                    o->VpiColumnNo() != H->VpiColumnNo() ||
                    o->VpiEndLineNo() != H->VpiEndLineNo() ||
                    o->VpiEndColumnNo() != H->VpiEndColumnNo())
                    continue;
                const scope* sc = any_cast<const scope*>(o);
                char b[1600];
                snprintf(b, sizeof b, "    %s  parent=%s  fullname=%s", ident(o).c_str(),
                         parentPath(o).c_str(),
                         sc ? std::string(sc->VpiFullName()).c_str() : "-");
                rows.push_back(b);
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s : rows) printf("%s\n", s.c_str());
            if (rows.empty()) printf("    (none)\n");
        }
    }

    printf("\n== STEP 3 — THE LISTING CENSUS ==\n");
    if (scopeWant) {
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s : Task_funcs of scopes named containing \"%s\" ----\n",
                   side ? "OURS" : "GOLDEN", scopeWant);
            for (auto& kv : S.AllObjects()) {
                const BaseClass* X = kv.first;
                if (!X) continue;
                if (X->UhdmType() != uhdmpackage && X->UhdmType() != uhdmclass_defn &&
                    X->UhdmType() != uhdmmodule_inst)
                    continue;
                if (std::string(X->VpiName()).find(scopeWant) == std::string::npos) continue;
                printf("    SCOPE %s\n", ident(X).c_str());
                for (int t = 1; t <= 2100; ++t) {
                    auto tup = X->GetByVpiType(t);
                    const std::vector<const BaseClass*>* v = std::get<2>(tup);
                    if (!v || v->empty()) continue;
                    bool anysub = false;
                    for (auto* e : *v) if (isSub(e)) { anysub = true; break; }
                    if (!anysub) continue;
                    printf("      LISTING vpiType=%d size=%zu\n", t, v->size());
                    for (size_t i = 0; i < v->size(); ++i)
                        printf("        [%4zu] %s\n", i, ident(v->at(i)).c_str());
                }
            }
        }
    } else {
        printf("  (no scope requested)\n");
    }

    // ---- STEP 4 — WHICH EDGE DID THE JUDGE TAKE? ------------------------
    // Every owner of the golden head is paired with every owner of our head
    // that has the SAME FACE, and the pair is compared in a FRESH context.
    // The pair that reproduces the head is the edge the judge descended.
    printf("\n== STEP 4 — THE DESCENT TEST (fresh CompareContext per owner pair) ==\n");
    if (HL && HR) {
        std::vector<const BaseClass*> og, oo;
        for (auto& kv : sg.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            for (int t = 1; t <= 2100; ++t) {
                auto tup = X->GetByVpiType(t);
                if (std::get<0>(tup) == HL) { og.push_back(X); break; }
                const std::vector<const BaseClass*>* v = std::get<2>(tup);
                bool hit = false;
                if (v) for (auto* e : *v) if (e == HL) { hit = true; break; }
                if (hit) { og.push_back(X); break; }
            }
        }
        for (auto& kv : so.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            for (int t = 1; t <= 2100; ++t) {
                auto tup = X->GetByVpiType(t);
                if (std::get<0>(tup) == HR) { oo.push_back(X); break; }
                const std::vector<const BaseClass*>* v = std::get<2>(tup);
                bool hit = false;
                if (v) for (auto* e : *v) if (e == HR) { hit = true; break; }
                if (hit) { oo.push_back(X); break; }
            }
        }
        for (const BaseClass* X : og)
            for (const BaseClass* Y : oo) {
                if (X->UhdmType() != Y->UhdmType()) continue;
                if (std::string(X->VpiName()) != std::string(Y->VpiName())) continue;
                if (X->VpiLineNo() != Y->VpiLineNo() || X->VpiColumnNo() != Y->VpiColumnNo())
                    continue;
                CompareContext cc;
                int rr = X->Compare(Y, &cc);
                printf("    PAIR golden %s\n         ours   %s\n         r=%d head LHS=%s\n"
                       "                     head RHS=%s   %s\n",
                       ident(X).c_str(), ident(Y).c_str(), rr,
                       ident(cc.m_failedLhs).c_str(), ident(cc.m_failedRhs).c_str(),
                       (cc.m_failedLhs == HL && cc.m_failedRhs == HR) ? "<== REPRODUCES THE HEAD"
                                                                     : "");
            }
    }
    return 0;
}
