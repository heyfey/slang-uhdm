// r10earl117 — sig117: the SELECT-INDEX RENDERING census.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per SELECT BOUND (a bit_select index, a var_select dimension, a
// part_select left/right bound, an indexed_part_select base/width, and the
// same four carried by a hier_path element) reachable from a cont_assign's
// Lhs/Rhs or from a process statement, ANYWHERE in the design (the DEF
// listing via AllModules + the ELAB tree via TopModules; the view is NOT
// keyed, per RESUME §9's census law).
//
// COLUMNS  (S|LABEL|<-------- KEY -------->|<---- PAYLOAD ---->)
//   SPAN     line:col-line:col of the SELECT BOUND EXPRESSION   (key spine)
//   SK       the select object kind                              (key)
//   SNAME    the select object's VpiName                         (key)
//   CAR      cont_assign / assignment / <stmt kind>              (key)
//   SC       the carrier scope kind (module_inst / gen_scope)    (key)
//   GD       generate depth                                      (key)
//   PAT      pattern-operand-value depth of this bound: 0 = not  (key)
//            inside an assignment pattern, N = N patterns deep
//   SIDE     L (carrier Lhs) or R (carrier Rhs)                  (key)
//   POS      which bound: idx / dim<k> / left / right / base / width  (key)
//   IK       the bound object kind (constant / ref_obj / operation / ...)
//   IT       the RENDERING: for a constant  "<decompile>#<size>#<constType>"
//            for a ref_obj "<name>@<actual kind>", else "-"
//
// usage: sig117 <db.uhdm> <label>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

static const char* LABEL = "";

static std::string K(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string span(const BaseClass* o) {
    if (!o) return "-";
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
             o->VpiEndLineNo(), o->VpiEndColumnNo());
    return b;
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
// the RENDERING of a select bound — everything the judge reads about it that
// this pass can move, and nothing else.
static std::string rend(const any* ix) {
    if (!ix) return "-";
    if (ix->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)ix;
        char b[160];
        snprintf(b, sizeof b, "%s#%d#%d", std::string(c->VpiDecompile()).c_str(),
                 (int)c->VpiSize(), (int)c->VpiConstType());
        return b;
    }
    if (ix->UhdmType() == uhdmref_obj) {
        auto* r = (const ref_obj*)ix;
        return std::string(r->VpiName()) + "@" + K(r->Actual_group());
    }
    return "-";
}

struct Ctx {
    std::string sc;   // carrier scope kind
    int gd = 0;       // generate depth
    std::string car;  // carrier kind
    int pat = 0;      // assignment-pattern operand-value depth
    char side = 'R';  // L or R of the carrier
};

static void row(const any* selObj, const any* bound, const char* pos,
                const Ctx& c) {
    printf("S|%s|%s|%s|%s|%s|%s|%d|%d|%c|%s|%s|%s\n", LABEL,
           span(bound).c_str(), K(selObj).c_str(),
           std::string(selObj->VpiName()).c_str(), c.car.c_str(), c.sc.c_str(),
           c.gd, c.pat, c.side, pos, K(bound).c_str(), rend(bound).c_str());
}

static void walkExpr(const any* e, Ctx c);

static void walkVec(const VectorOfany* v, const Ctx& c) {
    if (!v) return;
    for (auto* e : *v) walkExpr(e, c);
}

// record the bounds of ONE select object (and recurse into the bound
// expressions themselves, which may carry further selects).
static void selBounds(const any* e, const Ctx& c) {
    switch (e->UhdmType()) {
        case uhdmbit_select: {
            auto* b = (const bit_select*)e;
            row(e, b->VpiIndex(), "idx", c);
            walkExpr(b->VpiIndex(), c);
            break;
        }
        case uhdmvar_select: {
            auto* v = (const var_select*)e;
            int k = 0;
            if (v->Exprs())
                for (auto* x : *v->Exprs()) {
                    char p[16];
                    snprintf(p, sizeof p, "dim%d", k++);
                    row(e, x, p, c);
                    walkExpr(x, c);
                }
            break;
        }
        case uhdmpart_select: {
            auto* p = (const part_select*)e;
            row(e, p->Left_range(), "left", c);
            row(e, p->Right_range(), "right", c);
            walkExpr(p->Left_range(), c);
            walkExpr(p->Right_range(), c);
            break;
        }
        case uhdmindexed_part_select: {
            auto* p = (const indexed_part_select*)e;
            row(e, p->Base_expr(), "base", c);
            row(e, p->Width_expr(), "width", c);
            walkExpr(p->Base_expr(), c);
            walkExpr(p->Width_expr(), c);
            break;
        }
        default: break;
    }
}

static void walkExpr(const any* e, Ctx c) {
    if (!e) return;
    switch (e->UhdmType()) {
        case uhdmbit_select:
        case uhdmvar_select:
        case uhdmpart_select:
        case uhdmindexed_part_select:
            selBounds(e, c);
            break;
        case uhdmhier_path: {
            auto* hp = (const hier_path*)e;
            if (hp->Path_elems())
                for (auto* pe : *hp->Path_elems()) selBounds(pe, c);
            break;
        }
        case uhdmoperation: {
            auto* op = (const operation*)e;
            Ctx c2 = c;
            if (op->VpiOpType() == vpiAssignmentPatternOp) c2.pat = c.pat + 1;
            walkVec(op->Operands(), c2);
            break;
        }
        case uhdmtagged_pattern: {
            auto* tp = (const tagged_pattern*)e;
            walkExpr(tp->Pattern(), c);
            break;
        }
        case uhdmfunc_call: {
            auto* f = (const func_call*)e;
            walkVec(f->Tf_call_args(), c);
            break;
        }
        case uhdmsys_func_call: {
            auto* f = (const sys_func_call*)e;
            walkVec(f->Tf_call_args(), c);
            break;
        }
        default: break;
    }
}

static void walkStmt(const any* st, Ctx c);

static void walkStmt(const any* st, Ctx c) {
    if (!st) return;
    switch (st->UhdmType()) {
        case uhdmassignment: {
            auto* a = (const assignment*)st;
            Ctx cl = c;
            cl.car = "assignment";
            cl.side = 'L';
            walkExpr(a->Lhs(), cl);
            cl.side = 'R';
            walkExpr(a->Rhs(), cl);
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
            Ctx cc = c;
            cc.car = "if_cond";
            walkExpr(i->VpiCondition(), cc);
            walkStmt(i->VpiStmt(), c);
            break;
        }
        case uhdmif_else: {
            auto* i = (const if_else*)st;
            Ctx cc = c;
            cc.car = "if_cond";
            walkExpr(i->VpiCondition(), cc);
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
        for (auto* ca : *sc->Cont_assigns()) {
            Ctx cc = c;
            cc.car = "cont_assign";
            cc.side = 'L';
            walkExpr(ca->Lhs(), cc);
            cc.side = 'R';
            walkExpr(ca->Rhs(), cc);
        }
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
        fprintf(stderr, "usage: sig117 <db.uhdm> <label>\n");
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
    if (d->AllModules())
        for (auto* m : *d->AllModules()) {
            Ctx mc;
            mc.sc = "module_inst";
            mc.gd = 0;
            walkScope(m, mc);
            walkGenScopeArrays(m->Gen_scope_arrays(), mc);
        }
    Ctx c;
    if (d->TopModules())
        for (auto* m : *d->TopModules()) walkModule(m, c);
    // an accounting line every caller asserts on: a census that RAN prints it,
    // a census that crashed does not.
    printf("CENRC 0\n");
    return 0;
}
