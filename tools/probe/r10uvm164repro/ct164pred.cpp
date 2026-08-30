// r10uvm164 — THE A-PRIORI PREDICTOR.  MEASUREMENT ONLY; `uhdm-cmp` is the
// judge.  Reads ONE **PRISTINE** database and prints every cell
// § castOperandNeverBindsInCondWindow164 can move, so the mover set is named
// BY NAME BEFORE any patched database exists (RESUME.md §6).
//
// A cell qualifies when ALL of these hold, each read off the database itself:
//
//   1. it is a reference (`ref_obj` and its IS-A selects, `ref_var`) whose
//      `vpiActual` is NON-NULL.  The term only ever REMOVES a binding, so a
//      bare reference can never move;
//   2. a CAST stands between it and its context — the `vpiCastOp` (67)
//      operation, or a `$signed`/`$unsigned` `sys_func_call`.  The two
//      spellings of the signedness cast are INDISTINGUISHABLE in the database
//      (r10v161 arm E: golden BINDS the system call `$signed(x)` and leaves the
//      cast `signed'(x)` bare), so a signcast candidate is printed as
//      `PRED-SIGN` and counted SEPARATELY — it is an UPPER bound, not a
//      prediction;
//   3. it stands inside an `if_stmt` / `if_else` / `case_stmt`'s
//      **`VpiCondition()`** subtree, read as an EDGE and never off vpiParent:
//      a condition is re-parented to the ENCLOSING SCOPE by both producers
//      (StmtEmit.cpp "Like if conditions, the case condition parents at the
//      enclosing scope"), so its parent chain cannot tell it from an ordinary
//      statement's;
//   4. the enclosing subroutine is a `function`/`task` whose VpiParent is a
//      `class_defn` AND whose own SPAN lies INSIDE that class's span — the
//      IN-BODY test, and the reason the window ever opens (TaskFuncEmit.cpp
//      `classMethodNoBind = classScope && !oob`).  An OUT-OF-BODY definition
//      (`function void uvm_component::do_print(...)`, uvm_component.svh:3313,
//      outside `class uvm_component`'s own span) never sets the flag, so
//      `MethodWindow161` never lifts it, the depth is never raised and the term
//      is INERT there; those rows print as `INERT-OOB` and are counted, never
//      predicted.  The BIND SIGNATURE is kept as an INDEPENDENT cross-check
//      and printed as `flag=`: in a method where the flag holds, every
//      reference to a name the subroutine itself lists (`Variables()` /
//      `Io_decls()`) that stands OUTSIDE any window is BARE.  It is evidence,
//      not the test — an out-of-body method with no such reference at all
//      (`do_print`'s unread `string v`) leaves it saying `1` with nothing to
//      go on, which is exactly the false positive the span test removes;
//   5. the ACTUAL our pristine database carries is DECLARED IN the enclosing
//      subroutine (its own parent chain reaches that same `function`/`task`).
//      `CompileHelper::bindVariable` reads only `Variables()`/`Io_decls()` of
//      `uhdmfunction` / `uhdmtask` / `uhdmbegin`, so a FORMAL and a
//      subroutine-scope LOCAL are the only two things an eager bind can ever
//      have found — and therefore the only two a null `pexpr` can take away.
//      A CLASS PROPERTY and a PACKAGE variable reach the database through
//      LATE binding, which a cast does not disable (uvm_component.svh:2735 /
//      2797 / 3318 `uvm_verbosity'(recording_detail)`, golden BOUND); those
//      print as `INERT-LATE`.
//
// build: g++ -O2 -std=c++17 ct164pred.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct164pred
// usage: ct164pred <db.uhdm> <row-name>
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

// ---- the CONDITION subtree map, built from EDGES -------------------------
// value: 'c' = an if/case CONDITION subtree (this pass's column)
//        'w' = another binding window (assert condition, case item, call arg)
static void mark(std::map<const BaseClass*, char>& m, const BaseClass* e, char v) {
    if (!e) return;
    auto it = m.find(e);
    if (it != m.end()) return;
    m[e] = v;
    // descend the expression subtree
    if (const operation* op = any_cast<const operation*>(e))
        if (auto* v2 = op->Operands())
            for (auto* k : *v2) mark(m, (const BaseClass*)k, v);
    if (const tf_call* tc = any_cast<const tf_call*>(e))
        if (auto* v2 = tc->Tf_call_args())
            for (auto* k : *v2) mark(m, (const BaseClass*)k, v);
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct164pred <db> <row>\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const std::string row(argv[2]);

    std::map<const BaseClass*, char> win;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        switch (o->UhdmType()) {
            case uhdmif_stmt:  mark(win, ((const if_stmt*)o)->VpiCondition(), 'c'); break;
            case uhdmif_else:  mark(win, ((const if_else*)o)->VpiCondition(), 'c'); break;
            case uhdmcase_stmt:mark(win, ((const case_stmt*)o)->VpiCondition(), 'c'); break;
            case uhdmcase_item:
                if (auto* v = ((const case_item*)o)->VpiExprs())
                    for (auto* k : *v) mark(win, (const BaseClass*)k, 'w');
                break;
            case uhdmimmediate_assert: mark(win, ((const immediate_assert*)o)->Expr(), 'w'); break;
            case uhdmimmediate_assume: mark(win, ((const immediate_assume*)o)->Expr(), 'w'); break;
            case uhdmimmediate_cover:  mark(win, ((const immediate_cover*)o)->Expr(), 'w'); break;
            case uhdmfunc_call:
            case uhdmtask_call:
            case uhdmmethod_func_call:
            case uhdmmethod_task_call:
            case uhdmsys_func_call:
            case uhdmsys_task_call:
                if (auto* v = ((const tf_call*)o)->Tf_call_args())
                    for (auto* k : *v) mark(win, (const BaseClass*)k, 'w');
                break;
            default: break;
        }
    }

    // ---- per-subroutine: the class test and the classMethodNoBind signature
    // A subroutine's own listed names.
    std::map<const BaseClass*, std::set<std::string>> owned;
    std::map<const BaseClass*, bool> isClassSub;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() != uhdmfunction && o->UhdmType() != uhdmtask) continue;
        const task_func* tf = (const task_func*)o;
        std::set<std::string> nm;
        if (const scope* sc = any_cast<const scope*>(o))
            if (auto* v = sc->Variables())
                for (auto* var : *v) if (var) nm.insert(std::string(var->VpiName()));
        if (auto* v = tf->Io_decls())
            for (auto* d : *v) if (d) nm.insert(std::string(d->VpiName()));
        owned[o] = nm;
        // THE IN-BODY TEST, structural: the method's own span inside its
        // class's own span, in the same file.  An out-of-body definition sits
        // outside it and never sets `classMethodNoBind`.
        const BaseClass* p = o->VpiParent();
        bool inb = false;
        if (p && p->UhdmType() == uhdmclass_defn) {
            const std::string fo(o->VpiFile()), fp(p->VpiFile());
            inb = (fo.empty() || fp.empty() || fo == fp) &&
                  o->VpiLineNo() >= p->VpiLineNo() &&
                  o->VpiEndLineNo() <= p->VpiEndLineNo();
        }
        isClassSub[o] = inb;
    }

    // the enclosing subroutine of an object
    auto encl = [](const BaseClass* o) -> const BaseClass* {
        for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
            if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) return p;
        return nullptr;
    };

    // the classMethodNoBind SIGNATURE: no OUT-OF-WINDOW reference to an owned
    // name may be bound.
    std::map<const BaseClass*, bool> flagHeld;
    for (auto& kv : owned) flagHeld[kv.first] = true;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || !isRef(o)) continue;
        if (win.count(o)) continue;              // inside SOME window
        if (!actualOf(o)) continue;              // bare proves nothing here
        const BaseClass* fn = encl(o);
        if (!fn) continue;
        auto it = owned.find(fn);
        if (it == owned.end()) continue;
        if (it->second.count(std::string(o->VpiName()))) flagHeld[fn] = false;
    }

    // the cast wrapper above a reference
    auto castAbove = [](const BaseClass* o) -> std::string {
        for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
            if (const operation* op = any_cast<const operation*>(p)) {
                if (op->VpiOpType() == vpiCastOp) return "castop";
                continue;
            }
            if (p->UhdmType() == uhdmsys_func_call) {
                const std::string n(p->VpiName());
                if (n == "$signed" || n == "$unsigned") return "signcast";
                continue;
            }
            if (p->UhdmType() == uhdmref_obj || p->UhdmType() == uhdmbit_select ||
                p->UhdmType() == uhdmpart_select || p->UhdmType() == uhdmhier_path ||
                p->UhdmType() == uhdmfunc_call || p->UhdmType() == uhdmmethod_func_call)
                continue;
            break;
        }
        return "";
    };

    std::vector<std::string> lines;
    int pred = 0, sign = 0, inert = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || !isRef(o)) continue;
        auto w = win.find(o);
        if (w == win.end() || w->second != 'c') continue;   // if/case CONDITION only
        const BaseClass* act = actualOf(o);
        if (!act) continue;                                  // already bare
        std::string cst = castAbove(o);
        if (cst.empty()) continue;                           // not under a cast
        const BaseClass* fn = encl(o);
        if (!fn) continue;
        bool cls = isClassSub.count(fn) && isClassSub[fn];
        bool held = flagHeld.count(fn) && flagHeld[fn];
        // (5) the actual must be DECLARED IN this subroutine.
        bool subScope = false;
        for (const BaseClass* p = act; p; p = p->VpiParent())
            if (p == fn) { subScope = true; break; }
        char b[1400];
        const char* tag = !cls ? "INERT-OOB"
                        : !subScope ? "INERT-LATE"
                        : (cst == "signcast" ? "PRED-SIGN" : "PRED");
        snprintf(b, sizeof b, "%s\t%s\t%s\t%s:%u:%u\t%s\tfn=%s@%u-%u/cls@%u-%u\tinbody=%d\tflag=%d\tsub=%d\tact=%s",
                 tag, row.c_str(), cst.c_str(), std::string(o->VpiName()).c_str(),
                 o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                 std::string(o->VpiFile()).c_str(), std::string(fn->VpiName()).c_str(),
                 fn->VpiLineNo(), fn->VpiEndLineNo(),
                 fn->VpiParent() ? fn->VpiParent()->VpiLineNo() : 0,
                 fn->VpiParent() ? fn->VpiParent()->VpiEndLineNo() : 0,
                 (int)cls, (int)held, (int)subScope, kindOf(act).c_str());
        lines.push_back(b);
        if (!cls || !subScope) ++inert;
        else if (cst == "signcast") ++sign;
        else ++pred;
    }
    std::sort(lines.begin(), lines.end());
    for (auto& l : lines) printf("%s\n", l.c_str());
    printf("TOTAL\t%s\t%d\tsign=%d\tinert=%d\n", row.c_str(), pred, sign, inert);
    return 0;
}
