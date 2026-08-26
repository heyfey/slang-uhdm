// r10uvm157 — THE STATEMENT-SCOPE TYPESPEC-LISTING CENSUS.  MEASUREMENT ONLY;
// nothing here is an acceptance judge (the official `uhdm-cmp` and
// `scripts/verify_golden.py` are).  LHS is ALWAYS golden (Surelog); RHS is
// ALWAYS ours.
//
// build: g++ -O2 -std=c++17 ct157cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct157cen
//
// ONE ROW PER SCOPE (so a scope that lists NOTHING is still a row — a census
// that only prints listing ENTRIES is blind to the AWAY column, RESUME §9's
// "NODEDUP censuses manufacture AWAY-GOLDEN phantoms" trap read the other way
// round), plus ONE ROW PER LISTING ENTRY carrying its INDEX so the listing
// ORDER is measured and not assumed.
//
// Row types (tab separated):
//   TAG  SCOPE  VIEW  OWNER  SKIND  DEPTH  SKEY  SNAME  NTS  VARS  SSPAN
//   TAG  TSENT  VIEW  OWNER  SKIND  DEPTH  SKEY  IDX  TSKIND  TSNAME  TSSPAN  TSINST  RANGE  ALIAS
//
// The scope KEY is (VIEW, OWNER, SKIND, DEPTH, SKEY), where SKEY is the
// scope's own span EXCEPT for a scope whose vpiParent is the task/function
// itself — a subroutine BODY scope, of which there is at most one — where it
// is the literal token `#body`.  Reason: the SYNTHESISED body `begin` is
// MEASURED on grid arm A, a subroutine body's SYNTHESISED `begin` carries a
// DIFFERENT span on the two producers (Surelog anchors it at the SECOND body
// item, `populateCoreMembers(MoreStatement_or_null, ...)`, CompileStmt.cpp:2046;
// we anchor it at the first EXECUTABLE statement), and in `Roost157::burrow`
// ours collides with the nested written `begin`'s span exactly.  No generated
// `Compare` reads a line or a column (RESUME §9), so the span is a column of
// the row and never part of its key.  DEPTH counts the enclosing statement
// scopes up to the owning subroutine/container; VARS is the scope's own
// `Variables()` names in listed order and is a COLUMN, never part of the key
// or of the compared payload: our `Variables()` list legitimately differs from
// golden's on an array/queue/associative local (the element variable is listed
// too), which has nothing to do with a typedef listing.
//     RANGE  — the listed typespec's range form, spelled so a FOLDED bound and
//              a SYMBOLIC one are different tokens:
//              "-"                       no ranges
//              "<n>:<lkind>[<lval>]/<rkind>[<rval>]"  per range, ';'-joined
//     ALIAS  — the typespec's Typedef_alias actual kind (Surelog's
//              `tpclone->Typedef_alias()` arm), "-" when null.
//
// Scopes censused: every UHDM `scope` that is a STATEMENT scope (begin,
// named_begin, fork_stmt, named_fork, for_stmt, foreach_stmt) and every
// task_func (function / task) — the two families Surelog's
// `compileTypeDef(..., pstmt)` head can push onto.  Instances / class_defns /
// packages / gen_scopes are DELIBERATELY OUT (their listing is a different,
// already-modelled law) but are counted in a trailer so a census run that
// reaches nothing is visible.
//
// usage: ct157cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kd(const any* t) {
    return t ? std::string(UhdmName(t->UhdmType())) : std::string("NULL");
}
static std::string esc(std::string s) {
    for (auto& c : s) if (c == '\t' || c == '\n') c = ' ';
    return s.empty() ? std::string("-") : s;
}
static std::string span(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) +
           "-" + std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}
// The bound of a range, spelled so a folded constant and a symbolic expression
// are DIFFERENT tokens (the head's `$bits(...)-1` must stay symbolic).
static std::string bnd(const any* e) {
    if (!e) return "null";
    std::string k = kd(e);
    if (e->UhdmType() == uhdmconstant)
        return k + "[" + esc(std::string(((const constant*)e)->VpiValue())) + "]";
    if (e->UhdmType() == uhdmoperation)
        return k + "[" + std::to_string(((const operation*)e)->VpiOpType()) + "]";
    std::string n(e->VpiName());
    return k + "[" + esc(n) + "]";
}
static std::string rngOf(const typespec* t) {
    if (!t) return "-";
    const VectorOfrange* rs = nullptr;
    switch (t->UhdmType()) {
        case uhdmbit_typespec:   rs = ((const bit_typespec*)t)->Ranges(); break;
        case uhdmlogic_typespec: rs = ((const logic_typespec*)t)->Ranges(); break;
        case uhdmarray_typespec: rs = ((const array_typespec*)t)->Ranges(); break;
        case uhdmpacked_array_typespec:
            rs = ((const packed_array_typespec*)t)->Ranges(); break;
        case uhdmenum_typespec: break;
        default: break;
    }
    if (!rs || rs->empty()) return "-";
    std::string out;
    int i = 0;
    for (auto* r : *rs) {
        if (i) out += ";";
        out += std::to_string(i) + ":" + bnd(r->Left_expr()) + "/" +
               bnd(r->Right_expr());
        i++;
    }
    return out;
}
static std::string aliasOf(const typespec* t) {
    if (!t) return "-";
    if (const ref_typespec* a = t->Typedef_alias())
        return kd(a->Actual_typespec()) + "|" +
               (a->Actual_typespec()
                    ? esc(std::string(a->Actual_typespec()->VpiName()))
                    : std::string("-"));
    return "-";
}
static bool isStmtScope(UHDM_OBJECT_TYPE t) {
    return t == uhdmbegin || t == uhdmnamed_begin || t == uhdmfork_stmt ||
           t == uhdmnamed_fork || t == uhdmfor_stmt || t == uhdmforeach_stmt;
}
static bool isTaskFunc(UHDM_OBJECT_TYPE t) {
    return t == uhdmfunction || t == uhdmtask;
}
static std::string varsOf(const scope* sc) {
    const VectorOfvariables* v = sc->Variables();
    if (!v || v->empty()) return "-";
    std::string out;
    for (auto* x : *v) {
        if (!out.empty()) out += ",";
        std::string n(x->VpiName());
        out += n.empty() ? std::string("?") : n;
    }
    return esc(out);
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: ct157cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        std::cout << "RESTORE_FAIL\t" << tag << "\n"; return 3;
    }
    std::map<const any*, std::string> rootView;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (auto* v = d->TopPackages())   for (auto* p : *v) rootView.emplace(p, "ELABPKG");
        if (auto* v = d->TopModules())    for (auto* p : *v) rootView.emplace(p, "TOPMOD");
        if (auto* v = d->AllPackages())   for (auto* p : *v) rootView.emplace(p, "DEFPKG");
        if (auto* v = d->AllModules())    for (auto* p : *v) rootView.emplace(p, "DEFMOD");
        if (auto* v = d->AllClasses())    for (auto* p : *v) rootView.emplace(p, "DEFCLASS");
        if (auto* v = d->AllPrograms())   for (auto* p : *v) rootView.emplace(p, "DEFPROG");
        if (auto* v = d->AllInterfaces()) for (auto* p : *v) rootView.emplace(p, "DEFIFACE");
    }
    long scopes = 0, other = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        bool ss = isStmtScope(t), tf = isTaskFunc(t);
        if (!ss && !tf) {
            if (t == uhdmmodule_inst || t == uhdmpackage || t == uhdmclass_defn ||
                t == uhdmgen_scope || t == uhdmprogram || t == uhdminterface_inst)
                other++;
            continue;
        }
        // OWNER: the nearest enclosing task/func, else the nearest named
        // container (class / module / package), spelled with its FULL name so
        // both producers spell the same key.  A `begin`'s own VpiFullName is
        // SYNTHESISED by the dump (RESUME §9) and is NOT used here.
        const any* owner = nullptr;
        const any* root = nullptr;
        {
            const any* p = tf ? o->VpiParent() : o->VpiParent();
            int d = 0;
            while (p && d++ < 300) {
                UHDM_OBJECT_TYPE pt = p->UhdmType();
                if (!owner && (pt == uhdmfunction || pt == uhdmtask)) owner = p;
                auto it = rootView.find(p);
                if (it != rootView.end()) { root = p; break; }
                if (pt == uhdmdesign) break;
                if (!owner && (pt == uhdmmodule_inst || pt == uhdmpackage ||
                               pt == uhdmclass_defn || pt == uhdmprogram ||
                               pt == uhdminterface_inst))
                    owner = p;
                p = p->VpiParent();
            }
        }
        std::string ow = "-";
        if (owner) {
            if (const scope* sc = any_cast<const scope*>(owner)) {
                ow = std::string(sc->VpiFullName());
                if (ow.empty()) ow = std::string(owner->VpiName());
            } else ow = std::string(owner->VpiName());
        }
        if (tf) ow = std::string(((const task_func*)o)->VpiFullName());
        std::string view = root ? rootView[root] : std::string("OTHER");
        const scope* sc = (const scope*)o;
        const VectorOftypespec* tv = sc->Typespecs();
        size_t n = tv ? tv->size() : 0;
        // A NULL vector and an EMPTY vector are different objects but the
        // same ANSWER to `SafeCompare` when the other side is also empty; the
        // count is spelled, and the null case gets its own token so a
        // materialised-but-empty vector is still visible.
        // DEPTH: enclosing statement scopes between this one and its owner.
        int depth = 0;
        {
            const any* p = o->VpiParent();
            int d = 0;
            while (p && d++ < 300 && p != owner) {
                if (isStmtScope(p->UhdmType())) depth++;
                p = p->VpiParent();
            }
        }
        const std::string vars = varsOf(sc);
        // SKEY: `#body` for the ONE scope a subroutine hangs its body on
        // (Surelog anchors a synthesised wrapper at the SECOND body item and
        // we anchor it at the first executable statement — a pre-existing
        // residue of a different law, invisible to every generated Compare).
        std::string skey = span(o);
        if (const any* pp = o->VpiParent())
            if (isTaskFunc(pp->UhdmType())) skey = "#body";
        std::cout << tag << "\tSCOPE\t" << view << "\t" << esc(ow) << "\t"
                  << kd(o) << "\t" << depth << "\t" << skey << "\t"
                  << esc(std::string(o->VpiName())) << "\t"
                  << (tv ? std::to_string(n) : std::string("null")) << "\t"
                  << vars << "\t" << span(o) << "\n";
        scopes++;
        if (!tv) continue;
        size_t i = 0;
        for (auto* ts : *tv) {
            std::cout << tag << "\tTSENT\t" << view << "\t" << esc(ow) << "\t"
                      << kd(o) << "\t" << depth << "\t" << skey << "\t" << i << "\t"
                      << kd(ts) << "\t"
                      << (ts ? esc(std::string(ts->VpiName())) : std::string("-"))
                      << "\t" << span(ts) << "\t"
                      << (!ts ? std::string("-")
                              : (ts->Instance()
                                     ? esc(std::string(ts->Instance()->VpiName()))
                                     : std::string("<noinst>")))
                      << "\t" << rngOf(ts) << "\t" << aliasOf(ts) << "\n";
            i++;
        }
    }
    std::cerr << "ct157cen " << tag << " stmtscopes+tf=" << scopes
              << " containers=" << other << "\n";
    return 0;
}
