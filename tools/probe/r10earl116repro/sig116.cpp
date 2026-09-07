// r10earl116 — sig116: the ASSIGNMENT-PATTERN FLATTENED-NESS census.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per assignment-pattern `operation` that is the Rhs of a cont_assign
// or of an assignment statement, ANYWHERE in the design (module_inst tree +
// gen_scope_array/gen_scope tree, both the DEF listing and the ELAB tree —
// the VIEW is supplied by the caller, never keyed here, per RESUME §9).
//
// COLUMNS
//   SPAN     line:col-line:col of the operation       (the join key's spine)
//   LNAME    the Lhs's base name                      (key)
//   LK       the Lhs object kind                      (key)
//   LACT     the Lhs's Actual_group kind               (key)  <- the flatten gate
//   SC       the carrier scope kind (module_inst/gen_scope/...)  (key)
//   GD       generate depth                           (key)
//   CAR      the carrier kind (cont_assign / assignment / ...)   (key)
//   NOPS     operand count                            (payload)
//   TAG      tagged_pattern operand count             (payload)
//   FLAT     TAGGED | FLAT | MIXED | EMPTY            (payload)
//   OPK      the sorted operand-kind multiset         (payload)
//
// usage: sig116 <db.uhdm> <label>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string K(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static const any* actOf(const BaseClass* e) {
    if (!e) return nullptr;
    switch (e->UhdmType()) {
        case uhdmref_obj: return ((const ref_obj*)e)->Actual_group();
        case uhdmbit_select: return ((const bit_select*)e)->Actual_group();
        case uhdmvar_select: return ((const var_select*)e)->Actual_group();
        default: return nullptr;
    }
}
static std::string span(const BaseClass* o) {
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
             o->VpiEndLineNo(), o->VpiEndColumnNo());
    return b;
}
// the Lhs's BASE name: strip the select/member chain down to the root ref.
static std::string baseName(const any* l) {
    if (!l) return "<null>";
    std::string n(l->VpiName());
    if (l->UhdmType() == uhdmhier_path) {
        auto* hp = (const hier_path*)l;
        if (hp->Path_elems() && !hp->Path_elems()->empty())
            n = std::string(hp->Path_elems()->front()->VpiName());
    }
    return n.empty() ? std::string("<anon>") : n;
}

struct Ctx {
    std::string sc;  // carrier scope kind
    int gd = 0;      // generate depth
};

static const char* LABEL = "";

static void emit(const operation* op, const any* lhs, const char* car,
                 const Ctx& c) {
    if (!op) return;
    if (op->VpiOpType() != vpiAssignmentPatternOp) return;
    int nops = 0, tag = 0;
    std::vector<std::string> ks;
    if (op->Operands())
        for (auto* o : *op->Operands()) {
            nops++;
            if (o->UhdmType() == uhdmtagged_pattern) tag++;
            ks.push_back(K(o));
        }
    std::sort(ks.begin(), ks.end());
    std::string opk;
    for (size_t i = 0; i < ks.size(); i++) opk += (i ? "," : "") + ks[i];
    const char* flat = nops == 0     ? "EMPTY"
                       : tag == nops ? "TAGGED"
                       : tag == 0    ? "FLAT"
                                     : "MIXED";
    printf("R|%s|%s|%s|%s|%s|%s|%d|%s|%d|%d|%s|%s\n", LABEL, span(op).c_str(),
           baseName(lhs).c_str(), K(lhs).c_str(), K(actOf(lhs)).c_str(),
           c.sc.c_str(), c.gd, car, nops, tag, flat, opk.c_str());
}

static void walkStmt(const any* st, const Ctx& c);

static void walkExprAsRhs(const any* lhs, const any* rhs, const char* car,
                          const Ctx& c) {
    if (rhs && rhs->UhdmType() == uhdmoperation)
        emit((const operation*)rhs, lhs, car, c);
}

static void walkStmt(const any* st, const Ctx& c) {
    if (!st) return;
    switch (st->UhdmType()) {
        case uhdmassignment: {
            auto* a = (const assignment*)st;
            walkExprAsRhs(a->Lhs(), a->Rhs(), "assignment", c);
            break;
        }
        case uhdmbegin: {
            auto* b = (const begin*)st;
            if (b->Stmts())
                for (auto* s2 : *b->Stmts()) walkStmt(s2, c);
            break;
        }
        case uhdmnamed_begin: {
            auto* b = (const named_begin*)st;
            if (b->Stmts())
                for (auto* s2 : *b->Stmts()) walkStmt(s2, c);
            break;
        }
        case uhdmif_stmt: {
            auto* i = (const if_stmt*)st;
            walkStmt(i->VpiStmt(), c);
            break;
        }
        case uhdmif_else: {
            auto* i = (const if_else*)st;
            walkStmt(i->VpiStmt(), c);
            walkStmt(i->VpiElseStmt(), c);
            break;
        }
        case uhdmfor_stmt: {
            auto* f = (const for_stmt*)st;
            walkStmt(f->VpiStmt(), c);
            break;
        }
        case uhdmalways: {
            auto* a = (const always*)st;
            walkStmt(a->Stmt(), c);
            break;
        }
        case uhdminitial: {
            auto* a = (const initial*)st;
            walkStmt(a->Stmt(), c);
            break;
        }
        default: break;
    }
}

template <typename T>
static void walkScope(const T* sc, Ctx c) {
    if (sc->Cont_assigns())
        for (auto* ca : *sc->Cont_assigns())
            walkExprAsRhs(ca->Lhs(), ca->Rhs(), "cont_assign", c);
    if (sc->Process())
        for (auto* p : *sc->Process()) walkStmt(p, c);
}

static void walkGenScope(const gen_scope* gs, Ctx c);

static void walkGenScopeArrays(const VectorOfgen_scope_array* v, Ctx c) {
    if (!v) return;
    for (auto* gsa : *v) {
        if (!gsa->Gen_scopes()) continue;
        Ctx c2 = c;
        c2.gd = c.gd + 1;
        c2.sc = "gen_scope";
        for (auto* gs : *gsa->Gen_scopes()) walkGenScope(gs, c2);
    }
}

static void walkGenScope(const gen_scope* gs, Ctx c) {
    walkScope(gs, c);
    walkGenScopeArrays(gs->Gen_scope_arrays(), c);
}

static void walkModule(const module_inst* m, Ctx c) {
    Ctx mc;
    mc.sc = "module_inst";
    mc.gd = 0;
    walkScope(m, mc);
    walkGenScopeArrays(m->Gen_scope_arrays(), mc);
    if (m->Modules())
        for (auto* ch : *m->Modules()) walkModule(ch, mc);
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: sig116 <db.uhdm> <label>\n");
        return 2;
    }
    LABEL = argv[2];
    Serializer s;
    auto h = s.Restore(std::string(argv[1]));
    if (h.empty()) {
        fprintf(stderr, "RESTORE-FAIL %s\n", argv[1]);
        return 3;
    }
    const design* d = (const design*)((const uhdm_handle*)h[0])->object;
    Ctx c;
    if (d->AllModules())
        for (auto* m : *d->AllModules()) {
            // the DEF listing: each definition once, no recursion into
            // instances (AllModules already lists them).
            Ctx mc;
            mc.sc = "module_inst";
            mc.gd = 0;
            walkScope(m, mc);
            walkGenScopeArrays(m->Gen_scope_arrays(), mc);
        }
    if (d->TopModules())
        for (auto* m : *d->TopModules()) walkModule(m, c);
    // an accounting line every caller asserts on: a census that RAN prints it,
    // a census that crashed does not.
    printf("CENRC 0\n");
    return 0;
}
