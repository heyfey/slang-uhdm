// r10uvm161 — THE A-PRIORI PREDICTOR.  MEASUREMENT ONLY.
// Reads ONE **PRISTINE** database and prints every cell
// § assertCondIsAClassMethodWindow161 can move, so the mover set can be named
// BEFORE any patched database exists (RESUME.md §6).
//
// A cell qualifies when ALL of these hold, each read off the database itself:
//   1. it is a `ref_obj` / `ref_var` / `bit_select` whose `vpiActual` is NULL —
//      which already excludes every OUT-OF-BODY method, package function,
//      module function and process, because those bind in the pristine
//      database already;
//   2. it stands inside an `immediate_assert` / `immediate_assume` /
//      `immediate_cover`'s **`Expr()`** subtree, or inside a `case_item`'s
//      **`VpiExprs()`** subtree.  Both are read as EDGES, never off vpiParent:
//      a case-item reference is re-parented to the enclosing scope by both
//      producers, so its parent chain cannot tell it from an ordinary
//      statement's;
//   3. the owning statement is at CONTROL DEPTH 0 — no `if_stmt` / `if_else` /
//      `case_stmt` / loop stands between it and the enclosing subroutine
//      (§ controlBodyNoBind28; a plain `begin`, a NAMED `begin` and a
//      `fork_stmt` do NOT raise the depth — arm C measures all three);
//   4. the NAME is listed by an enclosing scope the way
//      `CompileHelper::bindVariable` reads it (CompileStmt.cpp:3089-3149):
//      `Variables()` or `Io_decls()` of the `function` / `task`, `Variables()`
//      of a `begin`.
//
// A `case … inside` item is NOT reachable: its members hang off the
// synthesized `inside` operation, not off `VpiExprs()`'s own entries — the
// tool prints those separately as `INSIDE` so the exclusion is visible and not
// merely asserted.
//
// build: g++ -O2 -std=c++17 ct161pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct161pred
// usage: ct161pred <db.uhdm> <row-name>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[600];
    snprintf(b, sizeof b, "%s(%s)@%u:%u",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo());
    return b;
}
// Every edge of an object, kind-agnostic, through the generated
// `GetByVpiType` switch.  Used to walk an expression subtree without naming a
// single field by hand.
static void kids(const BaseClass* o, std::vector<const BaseClass*>& out) {
    for (int t = 1; t <= 2100; ++t) {
        auto tup = o->GetByVpiType(t);
        if (const BaseClass* one = std::get<0>(tup)) out.push_back(one);
        if (const std::vector<const BaseClass*>* v = std::get<2>(tup))
            for (auto* e : *v)
                if (e) out.push_back(e);
    }
}
// The walk must stay INSIDE the expression.  `GetByVpiType` is kind-agnostic
// and would happily step through `vpiActual` into the bound variable and from
// there into its scope and the whole design, so descent is whitelisted to the
// expression containers and the frontier to references and containers.
static bool descendable(const BaseClass* o) {
    switch (o->UhdmType()) {
        case uhdmoperation: case uhdmsys_func_call: case uhdmfunc_call:
        case uhdmmethod_func_call: case uhdmhier_path: case uhdmbit_select:
        case uhdmpart_select: case uhdmindexed_part_select:
        case uhdmvar_select: case uhdmtagged_pattern: case uhdmarray_expr:
        case uhdmsys_task_call: case uhdmmethod_task_call:
            return true;
        default:
            return false;
    }
}
static bool isRefKind(const BaseClass* o) {
    UHDM_OBJECT_TYPE t = o->UhdmType();
    return t == uhdmref_obj || t == uhdmref_var || t == uhdmbit_select;
}
static bool isRef(const BaseClass* o, const BaseClass*& act) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) { act = r->Actual_group(); return true; }
    if (const ref_var* r = any_cast<const ref_var*>(o)) { act = r->Actual_group(); return true; }
    if (const bit_select* r = any_cast<const bit_select*>(o)) { act = r->Actual_group(); return true; }
    return false;
}
// Walk OUT of the owning statement.  Returns the home subroutine (or null) and
// sets `depth0` false when a control statement stands in between.
static const BaseClass* homeOf(const BaseClass* st, bool& depth0) {
    depth0 = true;
    for (const BaseClass* p = st->VpiParent(); p; p = p->VpiParent()) {
        switch (p->UhdmType()) {
            case uhdmif_stmt: case uhdmif_else: case uhdmcase_stmt:
            case uhdmcase_item: case uhdmfor_stmt: case uhdmwhile_stmt:
            case uhdmdo_while: case uhdmrepeat: case uhdmforever_stmt:
            case uhdmforeach_stmt:
                depth0 = false;
                break;
            case uhdmfunction: case uhdmtask:
                return p;
            case uhdmclass_defn: case uhdmpackage: case uhdmmodule_inst:
            case uhdmdesign:
                return nullptr;   // a process / module item, not a subroutine
            default:
                break;
        }
    }
    return nullptr;
}
// `CompileHelper::bindVariable`'s own reading, from the reference outwards.
static bool listedByName(const BaseClass* st, const std::string& nm) {
    for (const BaseClass* p = st; p; p = p->VpiParent()) {
        if (const scope* sc = any_cast<const scope*>(p))
            if (auto* v = sc->Variables())
                for (auto* var : *v)
                    if (var && std::string(var->VpiName()) == nm) return true;
        if (const task_func* tf = any_cast<const task_func*>(p)) {
            if (auto* io = tf->Io_decls())
                for (auto* d : *io)
                    if (d && std::string(d->VpiName()) == nm) return true;
            return false;   // the subroutine is the outermost scope that answers
        }
    }
    return false;
}

static int hits = 0;
static void scanSubtree(const BaseClass* root, const BaseClass* owner,
                        const char* pos, const std::string& row) {
    std::set<const BaseClass*> seen;
    std::vector<const BaseClass*> stack{root};
    while (!stack.empty()) {
        const BaseClass* o = stack.back();
        stack.pop_back();
        if (!o || !seen.insert(o).second) continue;
        const BaseClass* act = nullptr;
        if (isRef(o, act) && act == nullptr) {
            bool d0 = true;
            const BaseClass* home = homeOf(owner, d0);
            const std::string nm(o->VpiName());
            // A hier_path ELEMENT binds NOTHING, in every window and on both
            // sides — Surelog builds the whole dotted name as one `hier_path`
            // and never late-binds its members (the same fact
            // § oobRefVarLocalHoistNet107's `= new` fence rests on).  Without
            // this term the predictor named `FuncStructVal`'s eighteen
            // `Cfg.<field>` assertion operands, and that database is
            // BYTE-IDENTICAL under the two binaries.
            const BaseClass* pp = o->VpiParent();
            const bool inHierPath = pp && pp->UhdmType() == uhdmhier_path;
            if (home && d0 && !inHierPath && listedByName(owner, nm))
                printf("PRED\t%s\t%s\t%s\t%s\t%s\n", row.c_str(), pos,
                       ident(o).c_str(), ident(owner).c_str(),
                       ident(home).c_str()), ++hits;
        }
        if (!descendable(o)) continue;
        std::vector<const BaseClass*> k;
        kids(o, k);
        for (auto* c : k)
            if (isRefKind(c) || descendable(c)) stack.push_back(c);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct161pred <db> <row>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\t%s\n", argv[2]); return 3; }
    const std::string row(argv[2]);
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        switch (o->UhdmType()) {
            case uhdmimmediate_assert:
                if (auto* e = ((const immediate_assert*)o)->Expr())
                    scanSubtree(e, o, "assert-cond", row);
                break;
            case uhdmimmediate_assume:
                if (auto* e = ((const immediate_assume*)o)->Expr())
                    scanSubtree(e, o, "assume-cond", row);
                break;
            case uhdmimmediate_cover:
                if (auto* e = ((const immediate_cover*)o)->Expr())
                    scanSubtree(e, o, "cover-cond", row);
                break;
            // The item expressions are walked from the CASE_STMT, not from the
            // case_item: `compileCaseStmt` compiles them with `pstmt` — the
            // enclosing scope — so the case_stmt and its items are NOT control
            // bodies for them, and starting the depth walk at the case_item
            // would count the case_stmt itself and reject every cell (it did,
            // until arm D's three measured cells said otherwise).
            case uhdmcase_stmt:
                if (auto* items = ((const case_stmt*)o)->Case_items())
                    for (auto* it : *items) {
                        if (!it || !it->VpiExprs()) continue;
                        for (auto* e : *it->VpiExprs()) {
                            if (!e) continue;
                            // A `case … inside` item holds ONE synthesized
                            // `inside` operation whose members are its
                            // operands; it is not a window and is reported,
                            // not scanned.
                            if (e->UhdmType() == uhdmoperation &&
                                ((const operation*)e)->VpiOpType() == vpiInsideOp) {
                                printf("INSIDE\t%s\t%s\n", row.c_str(), ident(e).c_str());
                                continue;
                            }
                            scanSubtree(e, o, "case-item", row);
                        }
                    }
                break;
            default:
                break;
        }
    }
    printf("TOTAL\t%s\t%d\n", row.c_str(), hits);
    return 0;
}
