// r10uvm196 — THE MATERIALIZED-IMPORT LISTING PRINTER.  MEASUREMENT ONLY;
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Prints, IN VECTOR ORDER, an instance's `Parameters` and `Param_assigns` with
// everything the generated `Compare`s actually read — VpiName, VpiImported,
// VpiLocalParam, the typespec's kind and name, and the right side's kind,
// decompile and value — so the ORDER KEY and the SHAPE of a materialized
// import copy can be read off a golden instead of guessed.  It also prints a
// package's own Parameters vector for the same reason.
//
// build: g++ -O2 -std=c++17 ct196imp.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct196imp
// usage: ct196imp <db.uhdm> <tag> [<instance-or-package name substring>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static std::string face(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    const std::string k(UhdmName(o->UhdmType()));
    const std::string n(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%u:%u", k.c_str(), n.c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo());
    return b;
}
static std::string fileOf(const BaseClass* o) {
    if (!o) return "-";
    std::string f(o->VpiFile());
    size_t p = f.rfind('/');
    return p == std::string::npos ? f : f.substr(p + 1);
}
static std::string tsOf(const any* t) {
    if (!t) return "-";
    if (t->UhdmType() == uhdmref_typespec) {
        const any* a = ((const ref_typespec*)t)->Actual_typespec();
        return "ref->" + (a ? face(a) : std::string("<null>"));
    }
    return face(t);
}
static std::string rhsOf(const any* e) {
    if (!e) return "-";
    std::string s = face(e);
    if (e->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)e;
        s += " ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " val=" +
             std::string(c->VpiValue()) + " dec=" + std::string(c->VpiDecompile());
    }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct196imp <db> <tag> [name]\n"); return 2; }
    const char* tag = argv[2];
    const char* want = argc > 3 ? argv[3] : nullptr;
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const UHDM_OBJECT_TYPE k = o->UhdmType();
        if (k != uhdmmodule_inst && k != uhdminterface_inst && k != uhdmprogram &&
            k != uhdmpackage)
            continue;
        const std::string nm(o->VpiName());
        const std::string dn(o->VpiDefName());
        if (want && nm.find(want) == std::string::npos &&
            dn.find(want) == std::string::npos)
            continue;
        const scope* sc = (const scope*)o;
        auto* P = sc->Parameters();
        auto* A = sc->Param_assigns();
        printf("%s SCOPE %s name='%s' defname='%s' #%u  Parameters=%zu Param_assigns=%zu\n",
               tag, UhdmName(k), nm.c_str(), dn.c_str(), o->UhdmId(),
               P ? P->size() : 0, A ? A->size() : 0);
        if (P)
            for (size_t i = 0; i < P->size(); ++i) {
                const any* p = (*P)[i];
                std::string imp = "-", loc = "-", tsp = "-";
                if (p && p->UhdmType() == uhdmparameter) {
                    const parameter* pp = (const parameter*)p;
                    imp = std::string(pp->VpiImported());
                    loc = pp->VpiLocalParam() ? "local" : "param";
                    tsp = tsOf(pp->Typespec());
                }
                printf("%s   PARAM[%4zu] %-44s file=%-28s imported='%s' %s ts=%s\n",
                       tag, i, face(p).c_str(), fileOf(p).c_str(), imp.c_str(),
                       loc.c_str(), tsp.c_str());
            }
        if (A)
            for (size_t i = 0; i < A->size(); ++i) {
                const param_assign* pa = (*A)[i];
                printf("%s   PASSGN[%4zu] lhs=%-44s file=%-28s rhs=%s\n", tag, i,
                       pa ? face(pa->Lhs()).c_str() : "-",
                       pa ? fileOf(pa->Lhs()).c_str() : "-",
                       pa ? rhsOf(pa->Rhs()).c_str() : "-");
            }
    }
    return 0;
}
