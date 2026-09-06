// r10uvm180 — THE CLONE-BODY **ref_typespec** CENSUS (the wide form).
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// WHY A DOWNWARD WALK, AND WHY A LISTENER.  Our `ref_typespec` objects are
// unparented — climbing `VpiParent` from one reaches no package — so an upward
// key is unusable and an arena scan cannot tell a clone body's ref from a home
// body's.  UHDM's own `UhdmListener` walks the design ONCE (its `visited` set
// makes it O(N)) and hands every callback the CALLSTACK, which is exactly the
// downward path.  Each `ref_typespec` is keyed on the path from the enclosing
// package + subroutine down to the ref — `kind@line:col` per step, plus an
// occurrence counter for exact repeats.  Producer-private ids are printed,
// never keyed on.
//
// For every key it reports the two names `typespec::Compare` reads first: the
// bound typespec's `VpiName` and its `Typedef_alias` target's `VpiName`.
//
// build: g++ -O2 -std=c++17 ct180ref.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct180ref
// usage: ct180ref <golden.uhdm> <ours.uhdm> [<package-name filter>]
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static bool scalarTdKind(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmlogic_typespec: case uhdmbit_typespec: case uhdmint_typespec:
        case uhdminteger_typespec: case uhdmbyte_typespec:
        case uhdmshort_int_typespec: case uhdmlong_int_typespec: return true;
        default: return false;
    }
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
struct Cell { std::string ts, alias, kind; };

class RefCensus final : public UhdmListener {
  public:
    const char* pkgFilt = nullptr;
    std::map<std::string, int> occ;
    std::map<std::string, Cell> out;

    void enterRef_typespec(const ref_typespec* const o) override {
        const typespec* at = o->Actual_typespec();
        if (!at || !scalarTdKind(at->UhdmType())) return;
        const auto& cs = getCallstack();
        // find the innermost package and the subroutine under it
        int pkgAt = -1;
        for (int i = (int)cs.size() - 1; i >= 0; --i)
            if (cs[i]->UhdmType() == uhdmpackage) { pkgAt = i; break; }
        if (pkgAt < 0) return;
        std::string pn(cs[pkgAt]->VpiName());
        if (pkgFilt && pn.find(pkgFilt) == std::string::npos) return;
        // ONLY the package's own subroutine bodies — the region a wildcard
        // import CLONES.  A path that dives through a class_defn or through
        // another typespec is the shared class world, whose objects the two
        // producers reach by different routes and which no path key can pair.
        for (size_t i = (size_t)pkgAt + 1; i < cs.size(); ++i)
            if (cs[i]->UhdmType() == uhdmclass_defn ||
                any_cast<const typespec*>(cs[i]))
                return;
        std::string key = pn;
        char e[200];
        for (size_t i = (size_t)pkgAt + 1; i < cs.size(); ++i) {
            snprintf(e, sizeof e, "/%s@%u:%u",
                     UhdmName(cs[i]->UhdmType()).data(), cs[i]->VpiLineNo(),
                     (unsigned)cs[i]->VpiColumnNo());
            key += e;
        }
        int k = ++occ[key];
        key += "#" + std::to_string(k);
        Cell c;
        c.kind = UhdmName(at->UhdmType());
        c.ts = std::string(at->VpiName());
        const ref_typespec* al = at->Typedef_alias();
        const typespec* tg = al ? al->Actual_typespec() : nullptr;
        c.alias = tg ? std::string(tg->VpiName()) : std::string("-");
        out.emplace(key, c);
    }
};

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct180ref <golden> <ours> [pkgfilter]\n"); return 2; }
    const char* pf = argc > 3 ? argv[3] : nullptr;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    RefCensus cg, co;
    cg.pkgFilt = pf; co.pkgFilt = pf;
    cg.listenDesign(dg);
    co.listenDesign(dou);
    auto& G = cg.out; auto& O = co.out;
    std::set<std::string> keys;
    for (auto& [k, v] : G) keys.insert(k);
    for (auto& [k, v] : O) keys.insert(k);
    size_t agree = 0, differ = 0, og = 0, oo = 0;
    for (auto& k : keys) {
        auto gi = G.find(k), oi = O.find(k);
        if (gi == G.end()) { printf("ONLY-OURS   %s   ours=%s[%s -> %s]\n", k.c_str(),
            oi->second.kind.c_str(), oi->second.ts.c_str(), oi->second.alias.c_str()); ++oo; continue; }
        if (oi == O.end()) { printf("ONLY-GOLDEN %s   gold=%s[%s -> %s]\n", k.c_str(),
            gi->second.kind.c_str(), gi->second.ts.c_str(), gi->second.alias.c_str()); ++og; continue; }
        bool same = gi->second.ts == oi->second.ts && gi->second.alias == oi->second.alias &&
                    gi->second.kind == oi->second.kind;
        if (same) { ++agree; printf("AGREE       %s   %s[%s -> %s]\n", k.c_str(),
            gi->second.kind.c_str(), gi->second.ts.c_str(), gi->second.alias.c_str()); }
        else { ++differ; printf("DIFFER      %s   gold=%s[%s -> %s]  ours=%s[%s -> %s]\n", k.c_str(),
            gi->second.kind.c_str(), gi->second.ts.c_str(), gi->second.alias.c_str(),
            oi->second.kind.c_str(), oi->second.ts.c_str(), oi->second.alias.c_str()); }
    }
    printf("REFCENSUS agree=%zu differ=%zu only-golden=%zu only-ours=%zu total=%zu\n",
           agree, differ, og, oo, keys.size());
    return 0;
}
