// r10uvm195 — THE MIRROR OWNER-FINDER for a `LHS: <null>` head (r10uvm164's
// `ct164own.cpp` / r10uvm192's / r10uvm194's `ct194own.cpp` form, with the two
// sides SWAPPED because this head is on OUR side).  MEASUREMENT ONLY; the
// official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is
// ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// `BaseClass.h`'s SINGULAR `SafeCompare` (BaseClass.h:194-197) sets
// `m_failedRhs` and leaves `m_failedLhs` unset when the GOLDEN pointer is null
// and ours is not — uhdm-cmp then prints `LHS: <null>` above OUR object.  The
// printed object is therefore NOT the owner: the owner is whatever object holds
// a SINGULAR edge onto it that GOLDEN leaves null.  The head's own `vpiParent`
// is a TRAP (no generated `Compare` reads `VpiParent`, RESUME §9).
//
//   STEP 1  every OURS object holding an edge (singular or vector) onto the
//           head named by <line> <col> [kind], with the vpiType of that edge;
//   STEP 2  for each such owner, GOLDEN's counterpart — matched on KIND + NAME
//           + SPAN + named-ancestor chain, never on identity — and what
//           GOLDEN's same-numbered edge holds.  An owner whose edge is present
//           on ours and null on golden is the head's owner; the tool prints
//           `<<< THE OWNER` on it.
//
// build: g++ -O2 -std=c++17 ct195own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct195own
// usage: ct195own <golden.uhdm> <ours.uhdm> <line> <col> [kindsubstr]
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
                "usage: ct195own <golden> <ours> <line> <col> [kindsubstr]\n");
        return 2;
    }
    const unsigned wl = (unsigned)atoi(argv[3]);
    const unsigned wc = (unsigned)atoi(argv[4]);
    const char* wk = argc > 5 ? argv[5] : nullptr;
    Serializer G, O;
    if (G.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (O.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }

    // The head lives on OUR side.
    std::vector<const BaseClass*> heads;
    for (auto& kv : O.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X || X->VpiLineNo() != wl || X->VpiColumnNo() != wc) continue;
        if (wk && std::string(UhdmName(X->UhdmType())).find(wk) == std::string::npos)
            continue;
        heads.push_back(X);
    }
    printf("HEADS(OURS) matching %u:%u%s%s : %zu\n", wl, wc, wk ? " kind~" : "",
           wk ? wk : "", heads.size());
    for (const BaseClass* H : heads) {
        printf("HEAD %s%s\n", ident(H).c_str(), chain(H).c_str());
        printf("  (its vpiParent, which no generated Compare reads: %s)\n",
               ident(H->VpiParent()).c_str());
        const BaseClass* HT = twin(G, H);
        printf("  (golden twin of the head itself: %s)\n", ident(HT).c_str());
        int owners = 0, real = 0;
        for (auto& kv : O.AllObjects()) {
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
                const BaseClass* T = twin(G, X);
                const BaseClass* gEdge = nullptr;
                bool gHasVec = false;
                size_t gVecN = 0;
                if (T) {
                    auto tt = T->GetByVpiType(t);
                    gEdge = std::get<0>(tt);
                    if (const auto* v2 = std::get<2>(tt)) {
                        gHasVec = true;
                        gVecN = v2->size();
                    }
                }
                printf("  OWNER %s%s\n", ident(X).c_str(), chain(X).c_str());
                if (hitOne)
                    printf("      edge vpiType=%d SINGULAR   ours -> %s\n", t,
                           ident(H).c_str());
                else
                    printf("      edge vpiType=%d VECTOR[%zu/%zu]\n", t, vi,
                           vec->size());
                if (!T) {
                    printf("      golden: NO TWIN OBJECT\n");
                }
                else if (hitOne) {
                    printf("      golden -> %s%s\n", ident(gEdge).c_str(),
                           gEdge ? "" : "   <<< THE OWNER (singular edge null on GOLDEN)");
                    if (!gEdge) ++real;
                }
                else {
                    printf("      golden vector size %zu%s\n", gVecN,
                           gHasVec ? "" : " (absent)");
                }
            }
        }
        printf("  -- owners=%d  null-on-golden=%d\n", owners, real);
    }
    return 0;
}
