// r10uvm199 — THE OWNER-FINDER.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// `uhdm-cmp` names the head as `LHS: <null>` against a `ref_typespec` of ours
// whose `vpiParent` is a `parameter (work@top.UVM_RADIX)`.  That is
// `BaseClass.h`'s SINGULAR `SafeCompare` overload MIRRORED (RESUME §9): it
// names the VALUE that only one side has, not the owner.  Two DISTINCT
// `parameter` objects on our side carry that same name, span and fullname —
// the element of the scope's `Parameters` vector and the `Lhs` of the
// matching `param_assign` — so "which object is it" cannot be read off the
// cmp log at all.  This tool answers it by POSITION.
//
//   --slots <db> <paramName>
//       every `parameter` of that name in the database, with its id, span,
//       `vpiImported` tag, typespec kind, and the LISTING it sits in named by
//       OWNER and INDEX: `<view> <ownerface>.Parameters[i]/n` or
//       `<view> <ownerface>.Param_assigns[i].Lhs/n`.  Run it on golden and on
//       ours and the slots line up index for index.
//
//   --pkg <db> <paramName>
//       the same, restricted to package owners — the ORIGINAL declaration the
//       materialized copies are `clone_tree`d from.
//
// build: g++ -O2 -std=c++17 ct199own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct199own
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <string>

using namespace UHDM;

static std::string face(const BaseClass* o) {
    if (!o) return "<null>";
    char b[600];
    snprintf(b, sizeof b, "%s(%s/%s)@%u:%u",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(),
             std::string(o->VpiDefName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo());
    return b;
}

static std::string tsKind(const parameter* p) {
    if (!p) return "-";
    const ref_typespec* rt = p->Typespec();
    if (!rt) return "NO-TYPESPEC";
    const typespec* a = rt->Actual_typespec();
    char b[200];
    snprintf(b, sizeof b, "ref_typespec#%u -> %s", (unsigned)rt->UhdmId(),
             a ? std::string(UhdmName(a->UhdmType())).c_str() : "<unbound>");
    return b;
}

static void markViews(Serializer& s, std::map<const BaseClass*, std::string>& v) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (d->AllModules())    for (auto* x : *d->AllModules())    v[x] = "def";
        if (d->TopModules())    for (auto* x : *d->TopModules())    v[x] = "elab";
        if (d->AllPackages())   for (auto* x : *d->AllPackages())   v[x] = "defpkg";
        if (d->TopPackages())   for (auto* x : *d->TopPackages())   v[x] = "elabpkg";
        if (d->AllInterfaces()) for (auto* x : *d->AllInterfaces()) v[x] = "defif";
        if (d->AllPrograms())   for (auto* x : *d->AllPrograms())   v[x] = "defprog";
    }
}

static void report(const char* db, const char* want, bool pkgOnly) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) { printf("RESTORE_FAIL %s\n", db); return; }
    std::map<const BaseClass*, std::string> view;
    markViews(s, view);
    long n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const scope* sc = any_cast<const scope*>(o);
        if (!sc) continue;
        const bool isPkg = o->UhdmType() == uhdmpackage;
        if (pkgOnly && !isPkg) continue;
        std::string vw = "other";
        { auto it = view.find(o); if (it != view.end()) vw = it->second; }
        if (sc->Parameters()) {
            const auto& V = *sc->Parameters();
            for (size_t i = 0; i < V.size(); ++i) {
                const any* a = V[i];
                if (!a || a->UhdmType() != uhdmparameter) continue;
                const parameter* p = (const parameter*)a;
                if (std::string(p->VpiName()) != want) continue;
                ++n;
                printf("SLOT %-8s %-46s Parameters[%zu]/%zu  #%u @%u:%u-%u:%u "
                       "imported=%-14s %s\n",
                       vw.c_str(), face(o).c_str(), i, V.size(),
                       (unsigned)p->UhdmId(), p->VpiLineNo(),
                       (unsigned)p->VpiColumnNo(), p->VpiEndLineNo(),
                       (unsigned)p->VpiEndColumnNo(),
                       p->VpiImported().empty()
                           ? "-"
                           : std::string(p->VpiImported()).c_str(),
                       tsKind(p).c_str());
            }
        }
        if (sc->Param_assigns()) {
            const auto& V = *sc->Param_assigns();
            for (size_t i = 0; i < V.size(); ++i) {
                const param_assign* pa = V[i];
                if (!pa) continue;
                const any* l = pa->Lhs();
                if (!l || l->UhdmType() != uhdmparameter) continue;
                const parameter* p = (const parameter*)l;
                if (std::string(p->VpiName()) != want) continue;
                ++n;
                const any* r = pa->Rhs();
                char rh[200] = "-";
                if (r && r->UhdmType() == uhdmconstant) {
                    const constant* c = (const constant*)r;
                    snprintf(rh, sizeof rh, "constType=%d size=%d %s",
                             (int)c->VpiConstType(), (int)c->VpiSize(),
                             std::string(c->VpiValue()).c_str());
                }
                printf("SLOT %-8s %-46s Param_assigns[%zu]/%zu.Lhs  #%u "
                       "@%u:%u-%u:%u imported=%-14s %s   RHS[%s]\n",
                       vw.c_str(), face(o).c_str(), i, V.size(),
                       (unsigned)p->UhdmId(), p->VpiLineNo(),
                       (unsigned)p->VpiColumnNo(), p->VpiEndLineNo(),
                       (unsigned)p->VpiEndColumnNo(),
                       p->VpiImported().empty()
                           ? "-"
                           : std::string(p->VpiImported()).c_str(),
                       tsKind(p).c_str(), rh);
            }
        }
    }
    printf("-- SLOTS %s %s n=%ld\n", want, db, n);
}

int main(int argc, char** argv) {
    if (argc >= 4 && std::string(argv[1]) == "--slots") {
        report(argv[2], argv[3], false);
        return 0;
    }
    if (argc >= 4 && std::string(argv[1]) == "--pkg") {
        report(argv[2], argv[3], true);
        return 0;
    }
    fprintf(stderr,
            "usage: ct199own --slots <db> <paramName>\n"
            "       ct199own --pkg   <db> <paramName>\n");
    return 2;
}
