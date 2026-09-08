// r10uvm209 — ct209pred.cpp — THE PREDICTOR.  MEASUREMENT ONLY; the official
// uhdm-cmp is the sole judge.  LHS is ALWAYS golden (Surelog), RHS is ALWAYS
// ours — this tool reads only OUR PRISTINE databases, and it must be run
// BEFORE the patched binary exists.
//
// § `hoistedLocalKeepsItsLifetime209` makes ONE decision function —
// `emitPackageVar` / `emitPkgArrayVar` — the sole author of a materialised
// variable's `vpiAutomatic`, for the package's own listing, for the class
// import copies (which are `clone_tree` copies of it) and for the module's
// ELABORATED copy alike.  A database therefore MOVES iff, in it, a module's
// elaborated `vpiVariables` entry disagrees with the home package listing entry
// it is a copy of — matched by (kind, name, span), which the two share because
// they are two objects built from ONE source declaration.
//
// The one arm this predicate does not see is a hoisted constructor local
// written `static`: that changes the PACKAGE listing itself, and nothing in a
// database records the written qualifier.  Grid arm B is the only instance of
// that shape known to either corpus, and the byteverify mover set is what
// confirms it: a mover this predicate did not name would be one.
//
// build: g++ -O2 -std=c++17 ct209pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct209pred
// usage: ct209pred <db.uhdm>          -> prints one FIRE line per moving entry
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>

using namespace UHDM;

static std::string face(const BaseClass* o) {
    // `UhdmName` and `VpiName` hand back string_views; materialise both before
    // `%s` sees them — a raw view through printf is undefined behaviour and it
    // silently produced a face that matched nothing (FIRES=0 on a database the
    // census proved has ten moving cells).
    const std::string k(UhdmName(o->UhdmType()));
    const std::string n(o->VpiName());
    char b[512];
    snprintf(b, sizeof b, "%s|%s|%u:%u-%u:%u", k.c_str(), n.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct209pred <db.uhdm>\n"); return 2; }
    Serializer s;
    auto designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) { fprintf(stderr, "NO-DESIGN %s\n", argv[1]); return 3; }
    int fires = 0;
    for (auto dh : designs) {
        const design* d = (const design*)((const uhdm_handle*)dh)->object;
        // Every package listing entry, by face.  A face that repeats with
        // DISAGREEING values is dropped rather than last-writer-wins (RESUME
        // §9's multiset-join trap): it cannot predict anything either way.
        std::map<std::string, int> pk;
        std::map<std::string, bool> ambiguous;
        auto addPkgs = [&](const VectorOfpackage* v) {
            if (!v) return;
            for (auto* p : *v) {
                if (!p || !p->Variables()) continue;
                for (auto* x : *p->Variables()) {
                    if (!x) continue;
                    std::string f = face(x);
                    int a = x->VpiAutomatic() ? 1 : 0;
                    auto it = pk.find(f);
                    if (it == pk.end()) pk[f] = a;
                    else if (it->second != a) ambiguous[f] = true;
                }
            }
        };
        addPkgs(d->TopPackages());
        addPkgs(d->AllPackages());
        if (!d->TopModules()) continue;
        for (auto* m : *d->TopModules()) {
            if (!m || !m->Variables()) continue;
            for (auto* x : *m->Variables()) {
                if (!x) continue;
                std::string f = face(x);
                auto it = pk.find(f);
                if (it == pk.end() || ambiguous.count(f)) continue;
                int a = x->VpiAutomatic() ? 1 : 0;
                if (a == it->second) continue;
                const std::string mn(m->VpiName());
                printf("FIRE %s pkg=A%d mod=A%d owner=%s\n", f.c_str(),
                       it->second, a, mn.c_str());
                fires++;
            }
        }
    }
    printf("FIRES=%d\n", fires);
    return 0;
}
