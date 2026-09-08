// r10earl122 — THE CENSUS: every `ref_obj` / `ref_var` in a database, keyed by
// WHERE it stands, payloaded with WHETHER IT IS BOUND and to what.
//
// MEASUREMENT ONLY.  The official `uhdm-cmp` (~/.local/bin/uhdm-cmp) and
// `scripts/verify_golden.py` are the sole acceptance judges.  slang is NOT
// patched by this file and no acceptance number comes out of it.
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// WHY THIS SHAPE.  The Earlgrey_0_1/default head is
//   LHS: logic_var(...gen_host_fifo[0].shifted_id) @tlul_socket_m1.sv:94:21
//   RHS: <null>
// and `own122` proved the edge is `ref_obj::Actual_group`
// (`ref_obj::Compare` reads it through the SINGULAR `SafeCompare`, so a null
// on our side names the GOLDEN POINTEE and hides the owner).  The owner is the
// ref_obj at `:113:19-113:29`, the `a_source: shifted_id` member VALUE of the
// gen-scope assignment-pattern continuous assign at `:108`.  The variable
// itself is emitted by both sides in the SAME slot of the SAME container
// (`gen_scope::Variables[2/4]`) — this is a BINDING law, not a listing law.
//
// KEYING (the traps this pass had to respect, RESUME.md §9):
//  * our objects carry an EMPTY `VpiFile`, so the FILE is never in a key —
//    only `line:col-endline:endcol`;
//  * `Serializer::AllObjects` also holds objects no relation reaches, so
//    every row is stamped `live=` from `UhdmListener`'s own visited set;
//  * no generated `Compare` reads `VpiParent`, so the parent CHAIN is used
//    only as a FORM axis (evidence about which slot an object sits in), never
//    as an acceptance term.
//
// ROWS
//   CELL <key> \t <payload>
//     key     = <home scope fullname> | <ref name> | <span> | <pos>
//     pos     = the KIND chain from the ref up to (and including) its
//               enclosing scope, e.g. `cont_assign.Lhs<gen_scope` or
//               `operation<tagged_pattern<operation<cont_assign<gen_scope`
//     payload = BOUND|<actual kind>|<actual span>   or   UNBOUND
//   LIST <scope fullname>|<name>|<span> \t <container>|<idx/arity>|<kind>\n//     every object a gen_scope LISTS, so the net-vs-var SPLIT and the
//     slot index are measured, not inferred (the head's first framing —
//     "golden lists it and we list none" — was REFUTED this way)
//   FORM <form-key> \t <count>
//     form-key = scope kind × position class × bound/unbound, the grid axes
//   DEAD <same>  with `--with-dead`: the rows `UhdmListener` never
//             reaches (AllObjects holds objects no relation points at —
//             a SUPERSEDED emission, for instance).  Never counted as a
//             census cell; printed so a "missing" object can be told
//             from an ORPHANED one.
//   V <...>   with `--verbose <substr>`: every CELL under a home scope whose
//             fullname contains <substr>, with its full parent chain.
//
// build: g++ -O2 -std=c++17 cen122.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cen122
// usage: cen122 <file.uhdm> [--verbose <substr>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/UhdmListener.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string spanOf(const BaseClass* o) {
    if (!o) return "-";
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
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
static bool isScopeKind(const BaseClass* o) {
    if (!o) return false;
    switch (o->UhdmType()) {
        case uhdmgen_scope:
        case uhdmmodule_inst:
        case uhdminterface_inst:
        case uhdmpackage:
        case uhdmprogram:
        case uhdmclass_defn:
        case uhdmfunction:
        case uhdmtask:
        case uhdmbegin:
        case uhdmnamed_begin:
        case uhdmfork_stmt:
        case uhdmnamed_fork:
            return true;
        default:
            return false;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: cen122 <file.uhdm> [--verbose <substr>]\n");
        return 2;
    }
    std::string verbose;
    bool withDead = false;
    for (int i = 2; i < argc; i++)
        if (!strcmp(argv[i], "--with-dead")) withDead = true;
    for (int i = 2; i + 1 < argc; i++)
        if (!strcmp(argv[i], "--verbose")) verbose = argv[i + 1];

    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) { fprintf(stderr, "FATAL: restore failed %s\n", argv[1]); return 3; }

    // `live` — the objects a RELATION actually reaches (cen121's guard).
    UhdmListener lis;
    for (const auto& [o, id] : s.AllObjects())
        if (o && o->UhdmType() == uhdmdesign)
            lis.listenDesign((const design*)o);
    std::set<const BaseClass*> live;
    for (const any* a : lis.getVisited()) live.insert((const BaseClass*)a);

    std::map<std::string, size_t> forms;
    size_t cells = 0, dead = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        const any* a = (const any*)obj;
        const ref_obj* r = any_cast<const ref_obj*>(a);
        const ref_var* rv = any_cast<const ref_var*>(a);
        if (!r && !rv) continue;
        const bool isLive = live.count(obj) != 0;
        if (!isLive) dead++;
        if (!isLive && !withDead) continue;
        const BaseClass* actual =
            r ? (const BaseClass*)r->Actual_group()
              : (const BaseClass*)rv->Actual_group();

        // position: the KIND chain up to and including the enclosing scope
        std::string pos;
        const BaseClass* home = nullptr;
        {
            const BaseClass* q = obj->VpiParent();
            for (int i = 0; i < 10 && q; i++) {
                pos += (i ? "<" : "") + kindOf(q);
                if (isScopeKind(q)) { home = q; break; }
                q = q->VpiParent();
            }
            if (!home)
                for (const BaseClass* q2 = obj->VpiParent(); q2;
                     q2 = q2->VpiParent())
                    if (isScopeKind(q2)) { home = q2; break; }
        }
        const std::string homeFull = home ? fullOf(home) : std::string("<none>");
        const std::string nm(obj->VpiName());
        char key[2048];
        snprintf(key, sizeof key, "%s|%s|%s|%s", homeFull.c_str(), nm.c_str(),
                 spanOf(obj).c_str(), pos.c_str());
        std::string payload =
            actual ? ("BOUND|" + kindOf(actual) + "|" + spanOf(actual))
                   : std::string("UNBOUND");
        printf("%s\t%s\t%s\n", isLive ? "CELL" : "DEAD", key,
               payload.c_str());
        cells++;
        forms[kindOf(home) + "\t" + pos + "\t" + (actual ? "BOUND" : "UNBOUND")]++;

        if (!verbose.empty() && homeFull.find(verbose) != std::string::npos) {
            printf("V\t%s(%s)@%s#%u  -> %s\n", kindOf(obj).c_str(), nm.c_str(),
                   spanOf(obj).c_str(), obj->UhdmId(), payload.c_str());
            const BaseClass* q = obj->VpiParent();
            for (int i = 0; i < 8 && q; i++) {
                printf("V\t    < %s(%s)@%s#%u\n", kindOf(q).c_str(),
                       std::string(q->VpiName()).c_str(), spanOf(q).c_str(),
                       q->UhdmId());
                q = q->VpiParent();
            }
        }
    }

    // ------------------------------------------------------------- LIST rows
    // The SCOPE LISTING half.  The head's first framing was "golden lists the
    // gen-local under the scope's variables where we list none"; `own122`
    // REFUTED it (`gen_scope::Variables` is 4 on both sides and the object sits
    // at the SAME slot 2), and these rows are what makes that checkable across
    // the whole corpus rather than at one scope: one row per LISTED object of
    // every gen_scope, keyed by the scope and the object's name+span, payload
    // = which CONTAINER it is in, at which INDEX, of what arity, as what KIND.
    // The net-vs-var SPLIT is therefore part of the row, not an inference.
    size_t lists = 0;
    for (const auto& [obj, id] : s.AllObjects()) {
        const gen_scope* gs = any_cast<const gen_scope*>((const any*)obj);
        if (!gs || !live.count(obj)) continue;
        const std::string home = fullOf(obj);
#define LISTV(NAME, GETTER)                                                   \
        if (auto* v = gs->GETTER())                                           \
            for (size_t i = 0; i < v->size(); i++) {                          \
                printf("LIST\t%s|%s|%s\t%s|%zu/%zu|%s\n", home.c_str(),      \
                       std::string(v->at(i)->VpiName()).c_str(),              \
                       spanOf(v->at(i)).c_str(), NAME, i, v->size(),          \
                       kindOf(v->at(i)).c_str());                             \
                lists++;                                                      \
            }
        LISTV("Variables", Variables)
        LISTV("Nets", Nets)
        LISTV("Array_nets", Array_nets)
        LISTV("Array_vars", Array_vars)
        LISTV("Logic_vars", Logic_vars)
        LISTV("Parameters", Parameters)
#undef LISTV
    }
    fprintf(stderr, "listrows=%zu\n", lists);
    for (const auto& [k, n] : forms) printf("FORM\t%s\t%zu\n", k.c_str(), n);
    fprintf(stderr, "cells=%zu dead=%zu forms=%zu\n", cells, dead, forms.size());
    return 0;
}
