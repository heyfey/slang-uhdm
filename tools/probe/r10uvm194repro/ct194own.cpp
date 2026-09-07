// r10uvm194 — THE OWNER-FINDER for an `RHS: <null>` head (r10uvm164's
// `ct164own.cpp` / r10uvm192's `ct192own.cpp` mirror form).  MEASUREMENT ONLY;
// the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is
// ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// `BaseClass.h`'s SINGULAR `SafeCompare` names the VALUE with `RHS: <null>`
// (RESUME §9), so the head object printed by uhdm-cmp is NOT the owner: the
// owner is whatever object holds a singular edge onto it that our side leaves
// null.  The head's own `vpiParent` is printed by the dump beside it and is a
// TRAP — no generated `Compare` reads `VpiParent`, so the parent can never be
// the failing edge.  This tool answers WHICH edge it is, from the judge's own
// kind-agnostic accessor:
//
//   STEP 1  every GOLDEN object holding an edge (singular or vector) onto the
//           head named by <line> <col> [kind], with the vpiType of that edge;
//   STEP 2  for each such owner, OUR counterpart — matched on KIND + NAME +
//           SPAN, never on identity — and what OUR same-numbered edge holds.
//           An owner whose edge is present on golden and null on ours is the
//           head's owner; the tool prints `<<< THE OWNER` on it.
//
// build: g++ -O2 -std=c++17 ct194own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct194own
// usage: ct194own <golden.uhdm> <ours.uhdm> <line> <col> [kindsubstr]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
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
static std::string chain(const BaseClass* o) {
    std::string s;
    int g = 0;
    for (const BaseClass* p = o->VpiParent(); p && g < 32;
         p = p->VpiParent(), ++g) {
        const UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t != uhdmpackage && t != uhdmclass_defn && t != uhdmmodule_inst &&
            t != uhdmfunction && t != uhdmtask)
            continue;
        s += " <";
        s += UhdmName(t);
        s += ":";
        s += std::string(p->VpiName());
    }
    return s;
}
// KIND + NAME + SPAN + named-ancestor chain.  Never identity: the two
// databases share no pointers and no ids.
static const BaseClass* twin(Serializer& S, const BaseClass* g) {
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X || X->UhdmType() != g->UhdmType()) continue;
        if (X->VpiLineNo() != g->VpiLineNo()) continue;
        if (X->VpiColumnNo() != g->VpiColumnNo()) continue;
        if (X->VpiName() != g->VpiName()) continue;
        if (chain(X) != chain(g)) continue;
        return X;
    }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 5) {
        fprintf(stderr,
                "usage: ct194own <golden> <ours> <line> <col> [kindsubstr]\n");
        return 2;
    }
    const unsigned wl = (unsigned)atoi(argv[3]);
    const unsigned wc = (unsigned)atoi(argv[4]);
    const char* wk = argc > 5 ? argv[5] : nullptr;
    Serializer G, O;
    if (G.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (O.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }

    std::vector<const BaseClass*> heads;
    for (auto& kv : G.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X || X->VpiLineNo() != wl || X->VpiColumnNo() != wc) continue;
        if (wk && std::string(UhdmName(X->UhdmType())).find(wk) == std::string::npos)
            continue;
        heads.push_back(X);
    }
    printf("HEADS matching %u:%u%s%s : %zu\n", wl, wc, wk ? " kind~" : "",
           wk ? wk : "", heads.size());
    for (const BaseClass* H : heads) {
        printf("HEAD %s%s\n", ident(H).c_str(), chain(H).c_str());
        printf("  (its vpiParent, which no generated Compare reads: %s)\n",
               ident(H->VpiParent()).c_str());
        int owners = 0, real = 0;
        for (auto& kv : G.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X || X == H) continue;
            for (int t = 1; t <= 2100; ++t) {
                auto tup = X->GetByVpiType(t);
                const BaseClass* one = std::get<0>(tup);
                const std::vector<const BaseClass*>* vec = std::get<2>(tup);
                bool hitOne = (one == H);
                bool hitVec = false;
                size_t vi = 0;
                if (vec)
                    for (size_t i = 0; i < vec->size(); ++i)
                        if ((*vec)[i] == H) { hitVec = true; vi = i; break; }
                if (!hitOne && !hitVec) continue;
                ++owners;
                const BaseClass* T = twin(O, X);
                const BaseClass* ourEdge = nullptr;
                bool ourHasVec = false;
                size_t ourVecN = 0;
                if (T) {
                    auto tt = T->GetByVpiType(t);
                    ourEdge = std::get<0>(tt);
                    if (const auto* v2 = std::get<2>(tt)) {
                        ourHasVec = true;
                        ourVecN = v2->size();
                    }
                }
                printf("  OWNER %s%s\n", ident(X).c_str(), chain(X).c_str());
                if (hitOne)
                    printf("      edge vpiType=%d SINGULAR   golden -> %s\n", t,
                           ident(H).c_str());
                else
                    printf("      edge vpiType=%d VECTOR[%zu/%zu]\n", t, vi,
                           vec->size());
                if (!T) {
                    printf("      ours: NO TWIN OBJECT\n");
                }
                else if (hitOne) {
                    printf("      ours  -> %s%s\n", ident(ourEdge).c_str(),
                           ourEdge ? "" : "   <<< THE OWNER (singular edge null on ours)");
                    if (!ourEdge) ++real;
                }
                else {
                    printf("      ours vector size %zu%s\n", ourVecN,
                           ourHasVec ? "" : " (absent)");
                }
            }
        }
        printf("  -- owners=%d  null-on-ours=%d\n", owners, real);
    }
    return 0;
}
