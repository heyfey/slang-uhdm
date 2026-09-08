// r10uvm210 — THE OWNER-FINDER / EDGE-READER for a package `param_assign` Rhs.
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Derived from r10uvm201repro/ct201own.cpp (same SLOT-BY-POSITION idea: the cmp
// log cannot name the owner of a bare `constant:`/`ref_obj:` at a span, because
// a database holds MANY of them at one span — the `Parameters`-listing twin,
// the `Param_assigns` Lhs clone, the elaborated copy, every materialized import
// copy).  What is NEW here is that the Rhs face prints a `ref_obj`'s
// **Actual_group** — which is the whole edge of this pass: golden's Rhs is a
// `ref_obj` whose `vpiActual` is the REFERENCED parameter (def view) or that
// parameter's own `param_assign` Rhs OPERATION (elaborated view, UHDM
// ElaboratorListener paramMap), where we emit a folded `constant`.
//
//   --slots <db> <paramName>      every listing slot of that name, all owners
//   --pkg   <db> <paramName>      package owners only
//   --forms <db>                  EVERY package/module param_assign in the db,
//                                 keyed <ownerkind>|<view>|<rhs-kind>, one line
//                                 each: the CENSUS input of this pass
//   --key   <db> <tag>            the same, printed as bare census KEYS
//                                 (view x owner x rhs-kind x actual-kind) so two
//                                 databases can be joined by a text sort
//
// build: g++ -O2 -std=c++17 ct210own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct210own
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
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
    snprintf(b, sizeof b, "ref(%s)->%s@%u:%u-%u:%u",
             std::string(rt->VpiFullName()).c_str(),
             a ? std::string(UhdmName(a->UhdmType())).c_str() : "<unbound>",
             a ? a->VpiLineNo() : 0u, a ? (unsigned)a->VpiColumnNo() : 0u,
             a ? a->VpiEndLineNo() : 0u, a ? (unsigned)a->VpiEndColumnNo() : 0u);
    return b;
}

// The Rhs face.  A `ref_obj` prints its ACTUAL's kind + span, which is the
// field this pass is about.
static std::string rhsOf(const any* r) {
    if (!r) return "NO-RHS";
    char b[1200];
    if (r->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)r;
        snprintf(b, sizeof b, "constant@%u:%u-%u:%u ct=%d sz=%d val=%s ts=%s",
                 c->VpiLineNo(), (unsigned)c->VpiColumnNo(), c->VpiEndLineNo(),
                 (unsigned)c->VpiEndColumnNo(), (int)c->VpiConstType(),
                 (int)c->VpiSize(), std::string(c->VpiValue()).c_str(),
                 tsOf(c->Typespec()).c_str());
        return b;
    }
    if (r->UhdmType() == uhdmref_obj) {
        const ref_obj* ro = (const ref_obj*)r;
        const any* a = ro->Actual_group();
        snprintf(b, sizeof b,
                 "ref_obj@%u:%u-%u:%u name=%s full=%s ACTUAL=%s@%u:%u-%u:%u",
                 ro->VpiLineNo(), (unsigned)ro->VpiColumnNo(),
                 ro->VpiEndLineNo(), (unsigned)ro->VpiEndColumnNo(),
                 std::string(ro->VpiName()).c_str(),
                 std::string(ro->VpiFullName()).c_str(),
                 a ? std::string(UhdmName(a->UhdmType())).c_str() : "<null>",
                 a ? a->VpiLineNo() : 0u, a ? (unsigned)a->VpiColumnNo() : 0u,
                 a ? a->VpiEndLineNo() : 0u,
                 a ? (unsigned)a->VpiEndColumnNo() : 0u);
        return b;
    }
    if (r->UhdmType() == uhdmoperation) {
        const operation* op = (const operation*)r;
        snprintf(b, sizeof b, "operation@%u:%u-%u:%u opType=%d nops=%zu",
                 op->VpiLineNo(), (unsigned)op->VpiColumnNo(),
                 op->VpiEndLineNo(), (unsigned)op->VpiEndColumnNo(),
                 (int)op->VpiOpType(),
                 op->Operands() ? op->Operands()->size() : (size_t)0);
        return b;
    }
    snprintf(b, sizeof b, "%s@%u:%u-%u:%u",
             std::string(UhdmName(r->UhdmType())).c_str(), r->VpiLineNo(),
             (unsigned)r->VpiColumnNo(), r->VpiEndLineNo(),
             (unsigned)r->VpiEndColumnNo());
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

// The DEFAULT FORM of a param_assign Rhs, as a census key component.
//   REF      a bare `ref_obj` (this pass's population)
//   CONST    a folded `constant`
//   OP       an unreduced `operation`
//   <kind>   anything else, by kind name
static const char* rhsForm(const any* r) {
    if (!r) return "NONE";
    switch (r->UhdmType()) {
        case uhdmref_obj:   return "REF";
        case uhdmconstant:  return "CONST";
        case uhdmoperation: return "OP";
        default:            return "OTHER";
    }
}

static const char* actualForm(const any* r) {
    if (!r || r->UhdmType() != uhdmref_obj) return "-";
    const any* a = ((const ref_obj*)r)->Actual_group();
    if (!a) return "NULL";
    switch (a->UhdmType()) {
        case uhdmparameter:  return "parameter";
        case uhdmoperation:  return "operation";
        case uhdmconstant:   return "constant";
        case uhdmenum_const: return "enum_const";
        default:             return "other";
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
                    printf("SLOT %-8s %-46s Parameters[%zu]/%zu @%u:%u-%u:%u "
                           "imported=%-14s PARAM-TS=%s\n",
                           vw.c_str(), face(o).c_str(), i, V.size(),
                           p->VpiLineNo(), (unsigned)p->VpiColumnNo(),
                           p->VpiEndLineNo(), (unsigned)p->VpiEndColumnNo(),
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
            printf("SLOT %-8s %-46s PA[%zu]/%zu @%u:%u-%u:%u imported=%-10s "
                   "PARAM-TS=%s\n     RHS=%s\n",
                   vw.c_str(), face(o).c_str(), i, V.size(), p->VpiLineNo(),
                   (unsigned)p->VpiColumnNo(), p->VpiEndLineNo(),
                   (unsigned)p->VpiEndColumnNo(),
                   p->VpiImported().empty()
                       ? "-"
                       : std::string(p->VpiImported()).c_str(),
                   tsOf(p->Typespec()).c_str(), rhsOf(pa->Rhs()).c_str());
        }
    }
    printf("-- SLOTS %s %s n=%ld\n", want, db, n);
}

// EVERY param_assign in the database, one line each, printed either as a human
// FORM table or as a bare census KEY.  The key deliberately carries NO id, NO
// span of the owner and NO fullname (RESUME §9: the two producers label views
// and fullnames differently; Compare reads neither).
static void forms(const char* db, const char* tag, bool keyOnly) {
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
        if (!sc || !sc->Param_assigns()) continue;
        std::string vw = "other";
        {
            auto it = view.find(o);
            if (it != view.end()) vw = it->second;
        }
        // NOT `UhdmName(...).data()`: UhdmName hands back a string_view into a
        // table that is NOT null-terminated at the view's end, and printing its
        // .data() with %s emitted one garbage character per row the first time
        // this ran.  Materialise it.
        const std::string ok = std::string(UhdmName(o->UhdmType()));
        const auto& V = *sc->Param_assigns();
        for (size_t i = 0; i < V.size(); ++i) {
            const param_assign* pa = V[i];
            if (!pa) continue;
            const any* l = pa->Lhs();
            if (!l) continue;
            ++n;
            if (keyOnly) {
                // KEY = owner-kind | owner name | view | Lhs name | Lhs span |
                //       Rhs form | ref-actual kind.  The Lhs span pins the
                //       DECLARATION so two databases join cell for cell, and the
                //       OWNER NAME keeps two listings of the same parameter (the
                //       home package, each materialized import copy, the module)
                //       from collapsing onto one another — without it a golden
                //       CONST in one owner and an ours CONST in a DIFFERENT owner
                //       cancel and the census reads clean over a real difference.
                printf("K %s|%s|%s|%s|%u:%u|%s|%s\n", ok.c_str(),
                       std::string(o->VpiName()).c_str(), vw.c_str(),
                       std::string(l->VpiName()).c_str(), l->VpiLineNo(),
                       (unsigned)l->VpiColumnNo(), rhsForm(pa->Rhs()),
                       actualForm(pa->Rhs()));
            } else {
                printf("PA %-14s %-8s %-30s %-34s %s\n", ok.c_str(), vw.c_str(),
                       std::string(l->VpiName()).c_str(), face(o).c_str(),
                       rhsOf(pa->Rhs()).c_str());
            }
        }
    }
    printf("-- FORMS %s %s n=%ld\n", tag ? tag : "", db, n);
}


// --id <db> <uhdmId>: the PARENT CHAIN of one object, by UhdmId.  The cmp log
// prints ids but never the owner; a `param_assign` Rhs at a span exists in many
// listings, so the ONLY way to say which listing the judge stopped in is to
// walk `VpiParent` up from the id the log printed.
static void byId(const char* db, unsigned want) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) {
        printf("RESTORE_FAIL %s\n", db);
        return;
    }
    std::map<const BaseClass*, std::string> view;
    markViews(s, view);
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || (unsigned)o->UhdmId() != want) continue;
        printf("ID %u %s\n", want, face(o).c_str());
        const BaseClass* p = o;
        int d = 0;
        while (p && d < 12) {
            std::string vw;
            auto it = view.find(p);
            if (it != view.end()) vw = " [" + it->second + "]";
            printf("   ^%d %s%s\n", d, face(p).c_str(), vw.c_str());
            const any* q = p->VpiParent();
            p = q;
            ++d;
        }
    }
    printf("-- ID %u %s\n", want, db);
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
    if (argc >= 3 && std::string(argv[1]) == "--forms") {
        forms(argv[2], argc >= 4 ? argv[3] : "", false);
        return 0;
    }
    if (argc >= 4 && std::string(argv[1]) == "--id") {
        byId(argv[2], (unsigned)strtoul(argv[3], nullptr, 10));
        return 0;
    }
    if (argc >= 3 && std::string(argv[1]) == "--key") {
        forms(argv[2], argc >= 4 ? argv[3] : "", true);
        return 0;
    }
    fprintf(stderr,
            "usage: ct210own --slots <db> <paramName>\n"
            "       ct210own --pkg   <db> <paramName>\n"
            "       ct210own --forms <db> [tag]\n"
            "       ct210own --key   <db> [tag]\n"
            "       ct210own --id    <db> <uhdmId>\n");
    return 2;
}
