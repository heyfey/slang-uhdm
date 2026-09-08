// r10earl122 — THE OWNER-FINDER for a `LHS: <logic_var>` / `RHS: <null>` head.
//
// MEASUREMENT ONLY.  The official `uhdm-cmp` (~/.local/bin/uhdm-cmp) stays the
// sole acceptance judge; nothing here decides acceptance.  slang is NOT patched
// by this file.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// WHY.  Two DIFFERENT `SafeCompare` overloads can print `RHS: <null>`, and
// which one fired is the whole question (~/.local/include/uhdm/BaseClass.h):
//
//   SINGULAR  SafeCompare(lhs, rhs, ctx)                         (:187-199)
//       lhs != nullptr && rhs == nullptr -> m_failedLhs = THE POINTEE
//   VECTOR    SafeCompare(lhs_obj, lhs_vec, rhs_obj, rhs_vec, ctx)  (:202-225)
//       lhs_vec non-empty && rhs_vec == nullptr -> m_failedLhs = THE CONTAINER
//       size mismatch                          -> BOTH containers set
//       equal sizes, element i -> the SINGULAR overload on the two elements
//
// A `logic_var` LHS with an unset RHS is therefore NOT "our scope has no
// Variables vector" (that would name the gen_scope, not the variable): it is
// either a SINGULAR relation that golden fills and we leave null, or a vector
// SLOT holding a null pointer on our side.  This program tells the two apart
// and then names the owner, and it does NOT conclude "we never emit the
// object" without searching the WHOLE database for our counterpart BY
// IDENTITY (kind + name + fullname + span).
//
// WHAT IT PRINTS
//   [0] the official head (design::Compare, the same call uhdm-cmp makes)
//   [1] the head LHS's parent chain, and OUR counterpart of that parent
//   [2] the two scopes' container table, in the GENERATED Compare order
//       (scope::Compare then gen_scope::Compare), each container's arity on
//       both sides with NULL and EMPTY told apart, and each container's own
//       SafeCompare verdict in a FRESH CompareContext
//   [3] the whole-database identity search for the head target on OUR side
//       (every object with that name, and every object with that fullname)
//   [4] the SINGULAR field scan: every golden object holding a COMPARED
//       singular edge to the head target, by field, with parent chains — and
//       the same scan on OUR counterpart object.  The field table is DERIVED
//       from UHDM's own generated Compare bodies by gen_pointsat122.sh, not
//       hand-typed
//   [5] the VECTOR slot scan: any compared vector on either side holding the
//       target, with the slot index and the container's arity
//
// GUARD: `--calib` compares golden against itself and must print NO HEAD.
//
// build: g++ -O2 -std=c++17 own122.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o own122
// usage: own122 <golden.uhdm> <ours.uhdm> [--calib]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
// UhdmName() returns a string_view that is NOT guaranteed NUL-terminated:
// always go through std::string before "%s" (r10earl60's lesson).
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[1024];
    const std::string kind = kindOf(o);
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%s:%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             base(o->VpiFile()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static std::string fullOf(const BaseClass* o) {
    if (!o) return "";
    const any* a = (const any*)o;
#define FULLTRY(K)                                                            \
    if (const K* p = any_cast<const K*>(a)) return std::string(p->VpiFullName());
    FULLTRY(scope) FULLTRY(nets) FULLTRY(variables) FULLTRY(ref_obj)
    FULLTRY(ref_typespec) FULLTRY(hier_path) FULLTRY(parameter)
    FULLTRY(type_parameter) FULLTRY(gen_var) FULLTRY(gen_scope_array)
    FULLTRY(instance_array) FULLTRY(primitive) FULLTRY(named_event)
    FULLTRY(constraint) FULLTRY(concurrent_assertions) FULLTRY(property_decl)
    FULLTRY(sequence_decl)
#undef FULLTRY
    return "";
}

static std::string chainOf(const BaseClass* o, int n = 12) {
    std::string s;
    for (int i = 0; i < n && o; i++) {
        s += (i ? "\n        < " : "") + ident(o);
        o = o->VpiParent();
    }
    return s;
}

// ------------------------------------------------------- SINGULAR field scan
// DERIVED, not hand-written: gen_pointsat122.sh reads every generated
// `<kind>::Compare` and keeps the singular compared fields whose DECLARED type
// can hold a `variables` (`any`, `expr`, `variables`).
static const char* pointsAt(const BaseClass* o, const BaseClass* tgt) {
    const any* a = (const any*)o;
#include "pointsat122.inc"
    return nullptr;
}

struct Head {
    const BaseClass* lhs = nullptr;
    const BaseClass* rhs = nullptr;
    int32_t r = 0;
};
template <typename T>
static Head cmpPair(const T* a, const T* b) {
    CompareContext c;
    Head h;
    h.r = (a && b) ? a->Compare(b, &c) : (a ? 1 : (b ? -1 : 0));
    h.lhs = c.m_failedLhs;
    h.rhs = c.m_failedRhs;
    return h;
}
static void printHead(const char* tag, const Head& h) {
    printf("%s r=%d\n     LHS: %s\n     RHS: %s\n", tag, h.r,
           ident(h.lhs).c_str(), ident(h.rhs).c_str());
}

// arity with NULL and EMPTY told apart, exactly as the VECTOR overload sees it
template <typename T>
static std::string arity(const std::vector<T*>* v) {
    if (!v) return "<null>";
    char b[32];
    snprintf(b, sizeof b, "%zu", v->size());
    return b;
}
template <typename T>
static Head contHead(const BaseClass* lo, const std::vector<T*>* lv,
                     const BaseClass* ro, const std::vector<T*>* rv) {
    CompareContext c;
    Head h;
    // BaseClass::SafeCompare is `protected`; this is the VECTOR overload
    // TRANSCRIBED VERBATIM from ~/.local/include/uhdm/BaseClass.h:202-225 so
    // the arity table reads exactly what the judge reads.
    h.r = 0;
    if ((lv != nullptr) && (rv != nullptr)) {
        if ((h.r = static_cast<int32_t>(lv->size() - rv->size())) != 0) {
            c.m_failedLhs = lo;
            c.m_failedRhs = ro;
            h.r = 1;
        }
        else {
            for (size_t i = 0, n = lv->size(); i < n; ++i) {
                const BaseClass* a = lv->at(i);
                const BaseClass* b = rv->at(i);
                if ((a != nullptr) && (b != nullptr)) {
                    if ((h.r = a->Compare(b, &c)) != 0) break;
                }
                else if ((a != nullptr) && (b == nullptr)) {
                    c.m_failedLhs = a;
                    h.r = 1;
                    break;
                }
                else if ((a == nullptr) && (b != nullptr)) {
                    c.m_failedRhs = b;
                    h.r = -1;
                    break;
                }
            }
        }
    }
    else if ((lv != nullptr) && !lv->empty() && (rv == nullptr)) {
        c.m_failedLhs = lo;
        h.r = 1;
    }
    else if ((lv == nullptr) && (rv != nullptr) && !rv->empty()) {
        c.m_failedRhs = ro;
        h.r = -1;
    }
    h.lhs = c.m_failedLhs;
    h.rhs = c.m_failedRhs;
    return h;
}
#define CONT(BASE, F)                                                        \
    {                                                                        \
        auto* lv = ((const BASE*)lg)->F();                                   \
        auto* rv = ro ? ((const BASE*)ro)->F() : nullptr;                    \
        Head hh = contHead(lg, lv, ro, rv);                                  \
        printf("   %-24s golden=%-8s ours=%-8s r=%-3d LHS=%s RHS=%s\n", #F,  \
               arity(lv).c_str(), arity(rv).c_str(), hh.r,                   \
               ident(hh.lhs).c_str(), ident(hh.rhs).c_str());                \
        if (lv && (!rv || lv->size() != rv->size())) {                       \
            for (size_t i = 0; i < lv->size(); i++)                          \
                printf("        golden[%zu] %s\n", i,                        \
                       ident(lv->at(i)).c_str());                            \
            if (rv)                                                          \
                for (size_t i = 0; i < rv->size(); i++)                      \
                    printf("        ours  [%zu] %s\n", i,                    \
                           ident(rv->at(i)).c_str());                        \
        }                                                                    \
    }

// ---------------------------------------------------------- VECTOR slot scan
// Any compared vector on `scope`/`gen_scope`/`instance` holding `tgt`.
template <typename T>
static void slotScan(const char* what, const BaseClass* owner,
                     const std::vector<T*>* v, const BaseClass* tgt) {
    if (!v) return;
    for (size_t i = 0; i < v->size(); i++)
        if ((const BaseClass*)v->at(i) == tgt)
            printf("   SLOT %s[%zu/%zu] of %s\n", what, i, v->size(),
                   ident(owner).c_str());
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: own122 <golden.uhdm> <ours.uhdm> [--calib]\n");
        return 2;
    }
    bool calib = false;
    for (int i = 3; i < argc; i++)
        if (!strcmp(argv[i], "--calib")) calib = true;

    Serializer sg, so;
    auto hg = sg.Restore(std::string(argv[1]));
    auto ho = so.Restore(std::string(calib ? argv[1] : argv[2]));
    if (hg.empty() || ho.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
    const design* dg = (const design*)((const uhdm_handle*)hg[0])->object;
    const design* dou = (const design*)((const uhdm_handle*)ho[0])->object;
    printf("golden objs=%zu   ours objs=%zu%s\n", sg.AllObjects().size(),
           so.AllObjects().size(), calib ? "   [CALIB: ours := golden]" : "");

    Head h0 = cmpPair(dg, dou);
    printf("\n== [0] THE OFFICIAL HEAD (design::Compare)\n");
    printHead("  ", h0);
    if (h0.r == 0) { printf("NO HEAD (databases compare equal)\n"); return 0; }
    if (calib) { printf("CALIB FAILED: a database must compare equal to itself\n"); return 4; }
    printf("   SHAPE: %s\n",
           (h0.lhs && !h0.rhs)
               ? "LHS set, RHS UNSET -> either the SINGULAR overload's "
                 "rhs==nullptr branch (m_failedLhs = the POINTEE) or the "
                 "VECTOR overload's rhs_vec==nullptr branch (m_failedLhs = "
                 "the CONTAINER).  [1] tells them apart by KIND."
               : "both sides present or LHS unset");
    printf("   HEAD LHS KIND = %s  -> %s\n", kindOf(h0.lhs).c_str(),
           (kindOf(h0.lhs) == "gen_scope" || kindOf(h0.lhs) == "module_inst")
               ? "could be a CONTAINER name"
               : "NOT a scope: this is a SINGULAR pointee (or a null vector "
                 "SLOT); [4]/[5] name the owner");

    const std::string tgtName(h0.lhs ? h0.lhs->VpiName() : "");
    const std::string tgtFull(h0.lhs ? fullOf(h0.lhs) : "");
    const std::string tgtKind = kindOf(h0.lhs);

    // ------------------------------------------------------ [1] parent chain
    printf("\n== [1] HEAD LHS PARENT CHAIN (golden)\n        %s\n",
           chainOf(h0.lhs).c_str());
    const BaseClass* lg = h0.lhs ? h0.lhs->VpiParent() : nullptr;
    const BaseClass* ro = nullptr;
    if (lg) {
        const std::string pf(fullOf(lg));
        const std::string pk = kindOf(lg);
        for (const auto& [obj, id] : so.AllObjects())
            if (kindOf(obj) == pk && std::string(fullOf(obj)) == pf) {
                ro = obj;
                break;
            }
    }
    printf("   golden parent : %s\n   OUR  parent   : %s\n", ident(lg).c_str(),
           ident(ro).c_str());
    if (lg && ro) printHead("   parent-pair Compare (fresh ctx):",
                            cmpPair((const any*)lg, (const any*)ro));

    // -------------------------------------------------- [2] container table
    if (lg && any_cast<const gen_scope*>((const any*)lg)) {
        printf("\n== [2] CONTAINER TABLE — scope::Compare order, then "
               "gen_scope::Compare order\n");
        printf("   (arity <null> = the vector pointer itself is null; the "
               "VECTOR overload only fails on a null side when the OTHER side "
               "is NON-EMPTY)\n");
        CONT(scope, Property_decls)
        CONT(scope, Sequence_decls)
        CONT(scope, Concurrent_assertions)
        CONT(scope, Named_events)
        CONT(scope, Named_event_arrays)
        CONT(scope, Variables)
        CONT(scope, Virtual_interface_vars)
        CONT(scope, Logic_vars)
        CONT(scope, Array_vars)
        CONT(scope, Array_var_mems)
        CONT(scope, Parameters)
        CONT(scope, Param_assigns)
        CONT(scope, Scopes)
        CONT(scope, Typespecs)
        CONT(scope, Instance_items)
        CONT(scope, Let_decls)
        CONT(scope, Attributes)
        CONT(gen_scope, Nets)
        CONT(gen_scope, Array_nets)
        CONT(gen_scope, Process)
        CONT(gen_scope, Cont_assigns)
        CONT(gen_scope, Modules)
        CONT(gen_scope, Module_arrays)
        CONT(gen_scope, Primitives)
        CONT(gen_scope, Primitive_arrays)
        CONT(gen_scope, Def_params)
        CONT(gen_scope, Gen_scope_arrays)
        CONT(gen_scope, Programs)
        CONT(gen_scope, Program_arrays)
        CONT(gen_scope, Assertions)
        CONT(gen_scope, Interfaces)
        CONT(gen_scope, Interface_arrays)
        CONT(gen_scope, Alias_stmts)
        CONT(gen_scope, Clocking_blocks)
        CONT(gen_scope, Task_funcs)
        CONT(gen_scope, Elab_tasks)
    }

    // ------------------------------------------- [3] identity search on OURS
    printf("\n== [3] WHOLE-DATABASE IDENTITY SEARCH for the head target on OUR "
           "side\n   target: %s\n   fullname: %s\n",
           ident(h0.lhs).c_str(), tgtFull.c_str());
    size_t byName = 0, byFull = 0;
    for (const auto& [obj, id] : so.AllObjects()) {
        bool nm = !tgtName.empty() && std::string(obj->VpiName()) == tgtName;
        bool fl = !tgtFull.empty() && std::string(fullOf(obj)) == tgtFull;
        if (!nm && !fl) continue;
        if (nm) byName++;
        if (fl) byFull++;
        printf("   OURS %-6s %s\n        parent: %s\n", fl ? "[FULL]" : "[name]",
               ident(obj).c_str(), ident(obj->VpiParent()).c_str());
    }
    printf("   OURS name-matches=%zu fullname-matches=%zu\n", byName, byFull);
    size_t gByFull = 0;
    for (const auto& [obj, id] : sg.AllObjects())
        if (!tgtFull.empty() && std::string(fullOf(obj)) == tgtFull) {
            gByFull++;
            printf("   GOLD [FULL] %s\n        parent: %s\n", ident(obj).c_str(),
                   ident(obj->VpiParent()).c_str());
        }
    printf("   GOLDEN fullname-matches=%zu\n", gByFull);

    // ------------------------------------------------- [4] singular edge scan
    printf("\n== [4] SINGULAR FIELD SCAN — GOLDEN objects holding a COMPARED "
           "singular edge to the head target\n");
    std::map<std::string, size_t> byField;
    std::vector<const BaseClass*> pool;
    for (const auto& [obj, id] : sg.AllObjects())
        if (const char* f = pointsAt(obj, h0.lhs)) {
            pool.push_back(obj);
            byField[std::string(f) + "  owner=" + kindOf(obj)]++;
        }
    if (byField.empty()) printf("   (none)\n");
    for (const auto& [k, n] : byField) printf("   %-52s %6zu\n", k.c_str(), n);
    printf("   POOL total = %zu\n", pool.size());
    for (size_t i = 0; i < pool.size() && i < 12; i++)
        printf("   [%zu] %s   via %s\n        %s\n", i, ident(pool[i]).c_str(),
               pointsAt(pool[i], h0.lhs), chainOf(pool[i]).c_str());

    // and the same scan around OUR counterpart, if we have one
    const BaseClass* ourTgt = nullptr;
    for (const auto& [obj, id] : so.AllObjects())
        if (!tgtFull.empty() && std::string(fullOf(obj)) == tgtFull &&
            kindOf(obj) == tgtKind) {
            ourTgt = obj;
            break;
        }
    if (!ourTgt)
        for (const auto& [obj, id] : so.AllObjects())
            if (!tgtFull.empty() &&
                std::string(fullOf(obj)) == tgtFull) {
                ourTgt = obj;
                break;
            }
    printf("\n== [4'] OUR counterpart of the head target: %s\n",
           ident(ourTgt).c_str());
    std::map<std::string, size_t> ourByField;
    size_t ourPool = 0;
    if (ourTgt)
        for (const auto& [obj, id] : so.AllObjects())
            if (const char* f = pointsAt(obj, ourTgt)) {
                ourPool++;
                ourByField[std::string(f) + "  owner=" + kindOf(obj)]++;
            }
    if (ourByField.empty()) printf("   (none)\n");
    for (const auto& [k, n] : ourByField) printf("   %-52s %6zu\n", k.c_str(), n);
    printf("   POOL total = %zu\n", ourPool);
    if (ourTgt) {
        size_t i = 0;
        for (const auto& [obj, id] : so.AllObjects())
            if (const char* f = pointsAt(obj, ourTgt))
                printf("   [%zu] %s   via %s\n        %s\n", i++,
                       ident(obj).c_str(), f, chainOf(obj).c_str());
    }
    // [4''] THE PAIRING: for every GOLDEN owner of the edge, OUR object at the
    // same kind + name + span inside our counterpart parent scope, and what
    // ITS Actual_group actually holds.  "We do not emit it" is only ever a
    // conclusion of a search that LOOKED.
    printf("\n== [4''] EDGE PAIRING — golden owner vs OUR object at the same "
           "kind+name+span\n");
    for (const BaseClass* gp : pool) {
        const std::string gk = kindOf(gp), gn(gp->VpiName());
        printf("   GOLD %s -> %s\n", ident(gp).c_str(),
               ident((const BaseClass*)((const ref_obj*)any_cast<const ref_obj*>(
                         (const any*)gp))
                         ->Actual_group())
                   .c_str());
        size_t hits = 0;
        for (const auto& [obj, id] : so.AllObjects()) {
            if (kindOf(obj) != gk || std::string(obj->VpiName()) != gn) continue;
            if (obj->VpiLineNo() != gp->VpiLineNo() ||
                obj->VpiColumnNo() != gp->VpiColumnNo() ||
                obj->VpiEndLineNo() != gp->VpiEndLineNo() ||
                obj->VpiEndColumnNo() != gp->VpiEndColumnNo())
                continue;
            // keep only the ones under OUR counterpart gen_scope
            bool under = false;
            for (const BaseClass* q = obj; q; q = q->VpiParent())
                if (q == ro) { under = true; break; }
            if (!under) continue;
            hits++;
            const ref_obj* r = any_cast<const ref_obj*>((const any*)obj);
            printf("   OURS %s -> Actual_group %s\n", ident(obj).c_str(),
                   r ? ident((const BaseClass*)r->Actual_group()).c_str()
                     : "<not a ref_obj>");
            printf("        %s\n", chainOf(obj, 4).c_str());
        }
        if (!hits) printf("   OURS (no object of that kind+name+span under our "
                          "counterpart scope)\n");
    }

    // ---------------------------------------------------- [5] vector slots
    printf("\n== [5] VECTOR SLOT SCAN — compared scope containers holding the "
           "target\n");
    for (const auto& [obj, id] : sg.AllObjects()) {
        if (const scope* sc = any_cast<const scope*>((const any*)obj)) {
            slotScan("Variables", obj, sc->Variables(), h0.lhs);
            slotScan("Logic_vars", obj, sc->Logic_vars(), h0.lhs);
            slotScan("Array_vars", obj, sc->Array_vars(), h0.lhs);
            slotScan("Instance_items", obj, sc->Instance_items(), h0.lhs);
        }
    }
    if (ourTgt)
        for (const auto& [obj, id] : so.AllObjects())
            if (const scope* sc = any_cast<const scope*>((const any*)obj)) {
                slotScan("OURS.Variables", obj, sc->Variables(), ourTgt);
                slotScan("OURS.Logic_vars", obj, sc->Logic_vars(), ourTgt);
                slotScan("OURS.Instance_items", obj, sc->Instance_items(), ourTgt);
            }
    return 0;
}
