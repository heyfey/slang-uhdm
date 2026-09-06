// r10uvm173 — THE REFERRER SCAN.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden (Surelog), RHS is ALWAYS ours.
//
// Lists every object in ONE database that has an edge landing on a named
// object, using the generated kind-agnostic accessor `GetByVpiType`, so no
// edge can be missed by omission.  Run on the two `uvm_is_match` listings it
// prints this pass's whole law as two referrer sets:
//
//   golden  DEF listing #60224  <- 13 func_calls, every one of them in the
//                                  DEF listing
//           ELAB listing #812   <- 15 func_calls, every one of them elaborated
//   ours    DEF listing #2837   <- NOTHING
//           ELAB listing #5776  <- all of them
//
// build: g++ -O2 -std=c++17 ct173who.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct173who
// usage: ct173who <db.uhdm> <uhdm id>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u", std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
int main(int argc, char** argv) {
    Serializer s;
    s.Restore(std::string(argv[1]));
    unsigned want = atoi(argv[2]);
    const BaseClass* T = nullptr;
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmId() == want) T = kv.first;
    if (!T) { printf("MISSING\n"); return 3; }
    printf("TARGET %s parent=%s\n", ident(T).c_str(), ident(T->VpiParent()).c_str());
    for (auto& kv : s.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X || X == T) continue;
        for (int t = 1; t <= 2100; ++t) {
            auto tup = X->GetByVpiType(t);
            const BaseClass* one = std::get<0>(tup);
            const std::vector<const BaseClass*>* vec = std::get<2>(tup);
            if (one == T) printf("  %s  --edge %d singular-->\n", ident(X).c_str(), t);
            if (vec)
                for (size_t i = 0; i < vec->size(); ++i)
                    if (vec->at(i) == T)
                        printf("  %s  --edge %d [%zu]-->\n", ident(X).c_str(), t, i);
        }
    }
    return 0;
}
