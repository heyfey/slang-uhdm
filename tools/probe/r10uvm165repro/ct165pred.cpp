// r10uvm165 — THE A-PRIORI PREDICTOR.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the judge.  Reads ONE **PRISTINE**
// database and prints every cell § droppedCallArgTakesTheOrdinaryWindow165 can
// move, so the mover set is named BY NAME BEFORE any patched database exists
// (RESUME.md §6).  Descended from r10uvm164repro/ct164pred.cpp.
//
// A cell qualifies when ALL of these hold, each read off the database itself:
//
//   1. it is a reference (`ref_obj` and its IS-A selects, `ref_var`) whose
//      `vpiActual` is NON-NULL.  The law only ever REMOVES a binding, so a
//      bare reference can never move;
//   2. it is a DIRECT element of a `method_func_call`'s `Tf_call_args`.
//      § droppedCall14's re-emitter accepts only plain identifiers and plain
//      dotted pairs as actuals (`droppedCallArgsOk14`), so the reference it
//      binds is always a direct element and never nested in an operation;
//   3. that call is in STATEMENT position — its `VpiParent` is a statement
//      container (a `begin` / `named_begin` / `fork` / `function` / `task` /
//      an `if`, loop or `case_item`), never a `hier_path`, an `operation`, an
//      `assignment` or a `return_stmt`.  The EXPRESSION arm of § droppedCall14
//      binds nothing already (`bind = false`) and is out of this law's reach;
//   4. the enclosing subroutine is a `function`/`task` whose `VpiParent` is a
//      `class_defn` AND whose own SPAN lies INSIDE that class's span — the
//      IN-BODY test (TaskFuncEmit.cpp `classMethodNoBind = classScope && !oob`,
//      and this law's `!curSubOob9`).  An OUT-OF-BODY definition binds its
//      arguments at every depth in golden (arm B h61/h62), so it is INERT-OOB
//      here: counted, never predicted;
//   5. the CONTROL-BODY DEPTH between the reference and that subroutine is
//      > 0 — an `if` / `if_else` / `for` / `foreach` / `while` / `do-while` /
//      `repeat` / `forever` body or a `case_item` clause on the parent chain.
//      A plain `begin`, a NAMED block and a `fork` arm raise NO depth
//      (§ controlBodyNoBind28; arm B h07/h21/h22 are golden-BOUND).  Depth 0
//      cells are the MUST-STAY column and print as INERT-D0;
//   6. the ACTUAL is listed DIRECTLY on that subroutine — a member of its
//      `Io_decls()` or its `Variables()`, by POINTER.  That is exactly what
//      `currentSubSym->find(name)` can reach, and it is what makes the
//      prediction EXACT rather than an upper bound: the ordinary path's own
//      gate leaves no other way for a call argument to be BOUND at depth > 0
//      in an in-body class method.  § blockLocalSameCtrlDepthArgBinds57's
//      carve-out binds a variable declared in an unnamed `begin`, which is
//      listed on that `begin` and not on the subroutine, so it is excluded
//      here and prints as INERT-BLK.
//
// build: g++ -O2 -std=c++17 ct165pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct165pred
// usage: ct165pred <db.uhdm> <row-name>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
static bool isRef(const BaseClass* o) {
    return any_cast<const ref_obj*>(o) || any_cast<const ref_var*>(o);
}
// A CONTROL BODY for § controlBodyNoBind28's purposes.  A `begin`,
// `named_begin`, `fork` and `named_fork` are deliberately NOT here: they raise
// no depth, and golden binds through them (arm B h07/h21/h22).
static bool isCtrlBody(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmif_stmt:
        case uhdmif_else:
        case uhdmfor_stmt:
        case uhdmforeach_stmt:
        case uhdmwhile_stmt:
        case uhdmdo_while:
        case uhdmrepeat:
        case uhdmforever_stmt:
        case uhdmcase_item:
            return true;
        default:
            return false;
    }
}
// STATEMENT position for a call: the parent is something that HOLDS statements.
static bool isStmtHolder(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmbegin:
        case uhdmnamed_begin:
        case uhdmfork_stmt:
        case uhdmnamed_fork:
        case uhdmfunction:
        case uhdmtask:
        case uhdmif_stmt:
        case uhdmif_else:
        case uhdmfor_stmt:
        case uhdmforeach_stmt:
        case uhdmwhile_stmt:
        case uhdmdo_while:
        case uhdmrepeat:
        case uhdmforever_stmt:
        case uhdmcase_item:
        case uhdminitial:
        case uhdmalways:
            return true;
        default:
            return false;
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct165pred <db> <row>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const std::string row(argv[2]);

    // ---- every reference that is a DIRECT argument of a method_func_call ---
    std::map<const BaseClass*, const BaseClass*> argOf;   // ref -> the call
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmmethod_func_call) continue;
        if (auto* v = ((const tf_call*)o)->Tf_call_args())
            for (auto* k : *v)
                if (k) argOf[(const BaseClass*)k] = o;
    }

    // ---- per-subroutine: the IN-BODY test and the DIRECT listing ----------
    std::map<const BaseClass*, bool> inBody;
    std::map<const BaseClass*, std::set<const BaseClass*>> listed;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() != uhdmfunction && o->UhdmType() != uhdmtask) continue;
        const task_func* tf = (const task_func*)o;
        std::set<const BaseClass*> l;
        if (const scope* sc = any_cast<const scope*>(o))
            if (auto* v = sc->Variables())
                for (auto* var : *v) if (var) l.insert((const BaseClass*)var);
        if (auto* v = tf->Io_decls())
            for (auto* d : *v) if (d) l.insert((const BaseClass*)d);
        listed[o] = l;
        const BaseClass* p = o->VpiParent();
        bool inb = false;
        if (p && p->UhdmType() == uhdmclass_defn) {
            const std::string fo(o->VpiFile()), fp(p->VpiFile());
            inb = (fo.empty() || fp.empty() || fo == fp) &&
                  o->VpiLineNo() >= p->VpiLineNo() &&
                  o->VpiEndLineNo() <= p->VpiEndLineNo();
        }
        inBody[o] = inb;
    }

    std::vector<std::string> lines;
    int pred = 0, oob = 0, d0 = 0, blk = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || !isRef(o)) continue;
        const BaseClass* act = actualOf(o);
        if (!act) continue;                       // (1) already bare
        auto ai = argOf.find(o);
        if (ai == argOf.end()) continue;          // (2) not a direct call arg
        const BaseClass* call = ai->second;
        const BaseClass* cp = call->VpiParent();
        if (!cp || !isStmtHolder(cp->UhdmType())) continue;   // (3)
        // walk from the CALL up to the enclosing subroutine, counting control
        // bodies (5) and finding the subroutine (4).
        int depth = 0;
        const BaseClass* fn = nullptr;
        for (const BaseClass* p = cp; p; p = p->VpiParent()) {
            if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) {
                fn = p;
                break;
            }
            if (isCtrlBody(p->UhdmType())) ++depth;
        }
        if (!fn) continue;
        bool inb = inBody.count(fn) && inBody[fn];
        bool direct = listed.count(fn) && listed[fn].count(act);
        char b[1400];
        const char* tag = !inb      ? "INERT-OOB"
                        : depth == 0 ? "INERT-D0"
                        : !direct    ? "INERT-BLK"
                                     : "PRED";
        snprintf(b, sizeof b,
                 "%s\t%s\t%s:%u:%u\t%s\tdepth=%d\tfn=%s@%u-%u\tinbody=%d\tdirect=%d\tact=%s@%u",
                 tag, row.c_str(), std::string(o->VpiName()).c_str(),
                 o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                 std::string(o->VpiFile()).c_str(), depth,
                 std::string(fn->VpiName()).c_str(), fn->VpiLineNo(),
                 fn->VpiEndLineNo(), (int)inb, (int)direct,
                 kindOf(act).c_str(), act->VpiLineNo());
        lines.push_back(b);
        if (!inb) ++oob;
        else if (depth == 0) ++d0;
        else if (!direct) ++blk;
        else ++pred;
    }
    std::sort(lines.begin(), lines.end());
    for (auto& l : lines) printf("%s\n", l.c_str());
    printf("TOTAL\t%s\t%d\toob=%d\td0=%d\tblk=%d\n", row.c_str(), pred, oob, d0, blk);
    return 0;
}
