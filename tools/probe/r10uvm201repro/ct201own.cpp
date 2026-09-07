// r10uvm201 — THE OWNER-FINDER for the Rhs half.  MEASUREMENT ONLY; the
// official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance
// judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// `uhdm-cmp` names the head as a `ref_typespec` of GOLDEN's whose `vpiParent`
// is a bare `constant:` with a span but no name (`RHS: <null>`).  That is
// `BaseClass.h`'s SINGULAR `SafeCompare` overload in its normal direction: it
// names the VALUE only one side carries and never prints the owner.  A
// database holds MANY constants at one span (the `Parameters`-listing twin,
// the `Param_assigns` Lhs clone's Rhs, the elaborated copy, the package-side
// original), so "which `param_assign` is it" cannot be read off the cmp log.
// This tool answers it by POSITION.
//
//   --slots <db> <paramName>
//       every `param_assign` in the database whose Lhs `parameter` has that
//       name, with its LISTING named by owner and INDEX, the Lhs parameter's
//       id / span / `vpiImported` / typespec, and the Rhs's kind, id, span,
//       const type, size, value AND TYPESPEC.  Also every `Parameters`-vector
//       entry of that name, so the two slots line up index for index.
//
//   --pkg <db> <paramName>
//       the same, restricted to package owners — the `clone_tree` SOURCE the
//       materialized copies are made from.
//
//   --anchor <db> <paramName>
//       the SPANS only: the Rhs constant's span, its typespec's span and the
//       Lhs parameter's span, which is how the whole-declaration-line anchor
//       Surelog mints (`fC->populateCoreMembers(nodeId, nodeId, its)`) is
//       told apart from a value-site anchor.
//
// build: g++ -O2 -std=c++17 ct201own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct201own
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

static std::string tsOf(const ref_typespec* rt) {
    if (!rt) return "NO-TYPESPEC";
    const typespec* a = rt->Actual_typespec();
    char b[300];
    snprintf(b, sizeof b, "ref#%u(%s)->%s#%u@%u:%u-%u:%u",
             (unsigned)rt->UhdmId(), std::string(rt->VpiFullName()).c_str(),
             a ? std::string(UhdmName(a->UhdmType())).c_str() : "<unbound>",
             a ? (unsigned)a->UhdmId() : 0u, a ? a->VpiLineNo() : 0u,
             a ? (unsigned)a->VpiColumnNo() : 0u, a ? a->VpiEndLineNo() : 0u,
             a ? (unsigned)a->VpiEndColumnNo() : 0u);
    return b;
}

static std::string rhsOf(const any* r) {
    if (!r) return "NO-RHS";
    char b[900];
    if (r->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)r;
        snprintf(b, sizeof b,
                 "constant#%u@%u:%u-%u:%u ct=%d sz=%d val=%s ts=%s",
                 (unsigned)c->UhdmId(), c->VpiLineNo(),
                 (unsigned)c->VpiColumnNo(), c->VpiEndLineNo(),
                 (unsigned)c->VpiEndColumnNo(), (int)c->VpiConstType(),
                 (int)c->VpiSize(), std::string(c->VpiValue()).c_str(),
                 tsOf(c->Typespec()).c_str());
        return b;
    }
    snprintf(b, sizeof b, "%s#%u@%u:%u",
             std::string(UhdmName(r->UhdmType())).c_str(),
             (unsigned)r->UhdmId(), r->VpiLineNo(),
             (unsigned)r->VpiColumnNo());
    return b;
}

static void markViews(Serializer& s,
                      std::map<const BaseClass*, std::string>& v) {
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

static void report(const char* db, const char* want, bool pkgOnly,
                   bool anchorOnly) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) {
        printf("RESTORE_FAIL %s\n", db);
        return;
    }
    std::map<const BaseClass*, std::string> view;
    markViews(s, view);
    long n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const scope* sc = any_cast<const scope*>(o);
        if (!sc) continue;
        if (pkgOnly && o->UhdmType() != uhdmpackage) continue;
        std::string vw = "other";
        {
            auto it = view.find(o);
            if (it != view.end()) vw = it->second;
        }
        if (const instance* in = any_cast<const instance*>(o))
            if (in->Parameters() && !anchorOnly) {
                const auto& V = *in->Parameters();
                for (size_t i = 0; i < V.size(); ++i) {
                    const any* a = V[i];
                    if (!a || a->UhdmType() != uhdmparameter) continue;
                    const parameter* p = (const parameter*)a;
                    if (std::string(p->VpiName()) != want) continue;
                    ++n;
                    printf("SLOT %-8s %-46s Parameters[%zu]/%zu  #%u "
                           "@%u:%u-%u:%u imported=%-14s PARAM-TS=%s\n",
                           vw.c_str(), face(o).c_str(), i, V.size(),
                           (unsigned)p->UhdmId(), p->VpiLineNo(),
                           (unsigned)p->VpiColumnNo(), p->VpiEndLineNo(),
                           (unsigned)p->VpiEndColumnNo(),
                           p->VpiImported().empty()
                               ? "-"
                               : std::string(p->VpiImported()).c_str(),
                           tsOf(p->Typespec()).c_str());
                }
            }
        if (!sc->Param_assigns()) continue;
        const auto& V = *sc->Param_assigns();
        for (size_t i = 0; i < V.size(); ++i) {
            const param_assign* pa = V[i];
            if (!pa) continue;
            const any* l = pa->Lhs();
            if (!l || l->UhdmType() != uhdmparameter) continue;
            const parameter* p = (const parameter*)l;
            if (std::string(p->VpiName()) != want) continue;
            ++n;
            if (anchorOnly) {
                const any* r = pa->Rhs();
                const constant* c =
                    (r && r->UhdmType() == uhdmconstant) ? (const constant*)r
                                                         : nullptr;
                const typespec* a =
                    c && c->Typespec() ? c->Typespec()->Actual_typespec()
                                       : nullptr;
                printf("ANCHOR %-8s %-46s PA[%zu] param@%u:%u-%u:%u "
                       "const@%u:%u-%u:%u ts@%u:%u-%u:%u\n",
                       vw.c_str(), face(o).c_str(), i, p->VpiLineNo(),
                       (unsigned)p->VpiColumnNo(), p->VpiEndLineNo(),
                       (unsigned)p->VpiEndColumnNo(),
                       c ? c->VpiLineNo() : 0u,
                       c ? (unsigned)c->VpiColumnNo() : 0u,
                       c ? c->VpiEndLineNo() : 0u,
                       c ? (unsigned)c->VpiEndColumnNo() : 0u,
                       a ? a->VpiLineNo() : 0u,
                       a ? (unsigned)a->VpiColumnNo() : 0u,
                       a ? a->VpiEndLineNo() : 0u,
                       a ? (unsigned)a->VpiEndColumnNo() : 0u);
                continue;
            }
            printf("SLOT %-8s %-46s Param_assigns[%zu]/%zu.Lhs  #%u "
                   "@%u:%u-%u:%u imported=%-14s PARAM-TS=%s\n"
                   "                                                      "
                   "     %*sRHS=%s\n",
                   vw.c_str(), face(o).c_str(), i, V.size(),
                   (unsigned)p->UhdmId(), p->VpiLineNo(),
                   (unsigned)p->VpiColumnNo(), p->VpiEndLineNo(),
                   (unsigned)p->VpiEndColumnNo(),
                   p->VpiImported().empty()
                       ? "-"
                       : std::string(p->VpiImported()).c_str(),
                   tsOf(p->Typespec()).c_str(), 0, "",
                   rhsOf(pa->Rhs()).c_str());
        }
    }
    printf("-- SLOTS %s %s n=%ld\n", want, db, n);
}

int main(int argc, char** argv) {
    if (argc >= 4 && std::string(argv[1]) == "--slots") {
        report(argv[2], argv[3], false, false);
        return 0;
    }
    if (argc >= 4 && std::string(argv[1]) == "--pkg") {
        report(argv[2], argv[3], true, false);
        return 0;
    }
    if (argc >= 4 && std::string(argv[1]) == "--anchor") {
        report(argv[2], argv[3], false, true);
        return 0;
    }
    fprintf(stderr,
            "usage: ct201own --slots  <db> <paramName>\n"
            "       ct201own --pkg    <db> <paramName>\n"
            "       ct201own --anchor <db> <paramName>\n");
    return 2;
}
