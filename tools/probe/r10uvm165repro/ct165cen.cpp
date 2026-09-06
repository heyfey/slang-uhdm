// r10uvm165 — THE CAST-OPERAND CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden (Surelog), RHS is ALWAYS ours.
//
// Descended from r10v161repro/ctv161cen.cpp, which it is a strict SUPERSET of:
// the five families that tool emits (REF / TYP / VAR / CNT / OBJ) are reproduced
// byte-for-byte so the must-not-move check is the same check the verifier of
// r10uvm161 ran, and ONE new family is added:
//
//   CAS| every reference (`ref_obj` and its IS-A selects, `ref_var`,
//        `chandle_var`, `ref_module`) keyed by
//            CTX   the STATEMENT ROLE the reference plays, found by walking up
//                  the parent chain and asking each parent which of ITS OWN
//                  EDGES the child sits on — ifcond / casecond / caseitem /
//                  assertcond / assign_lhs / assign_rhs / arg / return /
//                  ifbody / body / other.  Operations, casts and selects are
//                  TRANSPARENT on that walk, so `int'(a) == b` in an `if`
//                  scores `ifcond` for `a` exactly as a bare `a` does.
//            CAST  the cast wrapper between the reference and its context, if
//                  any:  none / castop (`type'()` and `size'()`, vpiOpType 67)
//                  / signcast (`$signed`/`$unsigned` MINTED BY THE CAST ARM) /
//                  a nested chain, innermost first.  `$cast(...)` is a SYSTEM
//                  TASK/FUNCTION CALL and is deliberately NOT a cast here: its
//                  arguments score CAST=none, CTX=arg.
//            HOME  the enclosing subroutine kind and the container that
//                  subroutine finally hangs off — function/task/process ×
//                  class_defn / package / module_inst — which is exactly the
//                  discriminator Surelog's `else if (instance)` fallback needs.
//        and the value BOUND=<kind:name> / BARE.
//
// build: g++ -O2 -std=c++17 ct165cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct165cen
// usage: ct165cen <db.uhdm> <tag> [--nospan]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static bool NOSPAN = false;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string actOf(const BaseClass* a) {
    if (!a) return "NONE";
    return kindOf(a) + ":" + std::string(a->VpiName());
}
static std::string spanOf(const BaseClass* o) {
    if (NOSPAN) return "";
    char b[64];
    snprintf(b, sizeof b, "%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}
static std::string homeChain(const BaseClass* o) {
    std::string s;
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 64; p = p->VpiParent(), ++guard) {
        s += "/";
        s += UhdmName(p->UhdmType());
        if (const operation* op = any_cast<const operation*>(p)) {
            char ob[24];
            snprintf(ob, sizeof ob, "#%d", (int)op->VpiOpType());
            s += ob;
        }
        const std::string n(p->VpiName());
        if (!n.empty()) { s += ":"; s += n; }
    }
    return s;
}

// ---------------------------------------------------------------------------
// CAS helpers
// ---------------------------------------------------------------------------

// THE CONTEXT MAP.  A CONDITION EXPRESSION DOES NOT PARENT AT ITS STATEMENT:
// Surelog (and our emitter, deliberately — StmtEmit.cpp "Like if conditions,
// the case condition parents at the enclosing scope") gives an `if` / `case`
// condition the ENCLOSING SCOPE as its `vpiParent`, so a parent-chain walk from
// a condition reference NEVER reaches the `if_stmt` and scores every condition
// cell as "other".  The context is therefore read the other way round: every
// statement's NAMED EDGES are registered by POINTER in `edgeRole`, and the walk
// up from a reference asks, at each step, whether THIS object is a registered
// edge top.  Cast wrappers and operations on the way up are transparent and
// accumulate into the CAST chain.
typedef std::map<const BaseClass*, std::string> rolemap_t;

static void regOne(rolemap_t& m, const BaseClass* e, const char* role) {
    if (e && !m.count(e)) m[e] = role;
}
static void regVec(rolemap_t& m, const VectorOfany* v, const char* role) {
    if (!v) return;
    for (auto* e : *v) regOne(m, (const BaseClass*)e, role);
}

static void buildRoles(Serializer& s, rolemap_t& m) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        switch (o->UhdmType()) {
            case uhdmif_stmt:
                regOne(m, ((const if_stmt*)o)->VpiCondition(), "ifcond"); break;
            case uhdmif_else:
                regOne(m, ((const if_else*)o)->VpiCondition(), "ifcond"); break;
            case uhdmcase_stmt:
                regOne(m, ((const case_stmt*)o)->VpiCondition(), "casecond"); break;
            case uhdmcase_item:
                regVec(m, ((const case_item*)o)->VpiExprs(), "caseitem"); break;
            case uhdmimmediate_assert:
                regOne(m, ((const immediate_assert*)o)->Expr(), "assertcond"); break;
            case uhdmimmediate_assume:
                regOne(m, ((const immediate_assume*)o)->Expr(), "assertcond"); break;
            case uhdmimmediate_cover:
                regOne(m, ((const immediate_cover*)o)->Expr(), "assertcond"); break;
            case uhdmassignment:
                regOne(m, ((const assignment*)o)->Lhs(), "assign_lhs");
                regOne(m, ((const assignment*)o)->Rhs(), "assign_rhs"); break;
            case uhdmcont_assign:
                regOne(m, ((const cont_assign*)o)->Lhs(), "assign_lhs");
                regOne(m, ((const cont_assign*)o)->Rhs(), "assign_rhs"); break;
            case uhdmreturn_stmt:
                regOne(m, ((const return_stmt*)o)->VpiCondition(), "return"); break;
            case uhdmwhile_stmt:
                regOne(m, ((const while_stmt*)o)->VpiCondition(), "loopcond"); break;
            case uhdmdo_while:
                regOne(m, ((const do_while*)o)->VpiCondition(), "loopcond"); break;
            case uhdmrepeat:
                regOne(m, ((const repeat*)o)->VpiCondition(), "loopcond"); break;
            case uhdmfor_stmt:
                regOne(m, ((const for_stmt*)o)->VpiCondition(), "loopcond"); break;
            case uhdmevent_control:
                regOne(m, ((const event_control*)o)->VpiCondition(), "evctrl"); break;
            case uhdmwait_stmt:
                regOne(m, ((const wait_stmt*)o)->VpiCondition(), "waitcond"); break;
            // A CALL ARGUMENT is its own context — EXCEPT for the two calls the
            // cast arm MINTS (`$signed`/`$unsigned`), which are cast WRAPPERS
            // and must stay transparent so the reference keeps the context of
            // the statement position the cast sits in.  NOTE, and this is a
            // limit of ANY database-side census: Surelog renders the CAST
            // spelling `signed'(x)` and the SYSTEM-CALL spelling `$signed(x)`
            // as the SAME `sys_func_call`, so the two are separated only by
            // their SOURCE SPAN (r10v161 arm E measured golden BOUND for the
            // system call and BARE for the cast).
            case uhdmfunc_call:
            case uhdmtask_call:
            case uhdmmethod_func_call:
            case uhdmmethod_task_call:
            case uhdmsys_task_call:
                regVec(m, ((const tf_call*)o)->Tf_call_args(), "arg"); break;
            case uhdmsys_func_call: {
                const std::string n(o->VpiName());
                if (n != "$signed" && n != "$unsigned")
                    regVec(m, ((const tf_call*)o)->Tf_call_args(), "arg");
                break;
            }
            default: break;
        }
    }
}

// Objects the upward walk may pass THROUGH on its way to an edge top.
static bool transparentUp(const BaseClass* p) {
    switch (p->UhdmType()) {
        case uhdmoperation:
        case uhdmbit_select:
        case uhdmpart_select:
        case uhdmindexed_part_select:
        case uhdmvar_select:
        case uhdmhier_path:
        case uhdmref_obj:
        case uhdmsys_func_call:
        case uhdmfunc_call:
        case uhdmmethod_func_call:
            return true;
        default:
            return false;
    }
}

// The cast wrapper chain between a reference and its context, innermost first.
// Two spellings, exactly the two Surelog's `paCast` arm can mint:
//   castop    the `vpiCastOp` (67) operation — `int'()`, `4'()`, `ed_t'()`
//   signcast  a `sys_func_call` named `$signed` / `$unsigned` minted BY THAT
//             SAME ARM (CompileExpression.cpp:2649-2661) — the operand is
//             compiled with `pexpr == nullptr` before the wrapper exists.
// `$cast(a,b)` is an ORDINARY system call and is NOT one of these.
static bool isCastWrapper(const BaseClass* p, std::string& what) {
    if (const operation* op = any_cast<const operation*>(p)) {
        if (op->VpiOpType() == vpiCastOp) { what = "castop"; return true; }
        return false;
    }
    if (p->UhdmType() == uhdmsys_func_call) {
        const std::string n(p->VpiName());
        if (n == "$signed" || n == "$unsigned") { what = "signcast"; return true; }
    }
    return false;
}

// The HOME of a reference: the enclosing subroutine (or process) and the
// container that subroutine finally hangs off.
static std::string homeOf(const BaseClass* o) {
    const BaseClass* sub = nullptr;
    int guard = 0;
    for (const BaseClass* p = o->VpiParent(); p && guard < 128; p = p->VpiParent(), ++guard) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (!sub && (t == uhdmfunction || t == uhdmtask || t == uhdminitial ||
                     t == uhdmalways || t == uhdmfinal_stmt)) {
            sub = p;
            continue;
        }
        if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst ||
            t == uhdmmodule_typespec || t == uhdmdesign) {
            std::string s = sub ? std::string(UhdmName(sub->UhdmType())) : std::string("none");
            s += "@";
            s += UhdmName(t);
            return s;
        }
    }
    return sub ? std::string(UhdmName(sub->UhdmType())) + "@none" : std::string("none@none");
}

// ---- r10uvm165's ARG family helpers -------------------------------------
// A CONTROL BODY for § controlBodyNoBind28's purposes; a `begin`,
// `named_begin`, `fork` and `named_fork` are deliberately absent (they raise no
// depth, and golden binds through them).
static bool isCtrlBody(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmif_stmt: case uhdmif_else: case uhdmfor_stmt:
        case uhdmforeach_stmt: case uhdmwhile_stmt: case uhdmdo_while:
        case uhdmrepeat: case uhdmforever_stmt: case uhdmcase_item:
            return true;
        default: return false;
    }
}
// STATEMENT position for a call: the parent HOLDS statements.
static bool isStmtHolder(UHDM_OBJECT_TYPE t) {
    switch (t) {
        case uhdmbegin: case uhdmnamed_begin: case uhdmfork_stmt:
        case uhdmnamed_fork: case uhdmfunction: case uhdmtask:
        case uhdmif_stmt: case uhdmif_else: case uhdmfor_stmt:
        case uhdmforeach_stmt: case uhdmwhile_stmt: case uhdmdo_while:
        case uhdmrepeat: case uhdmforever_stmt: case uhdmcase_item:
        case uhdminitial: case uhdmalways:
            return true;
        default: return false;
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct165cen <db> <tag> [--nospan]\n"); return 2; }
    for (int i = 3; i < argc; ++i)
        if (!strcmp(argv[i], "--nospan")) NOSPAN = true;
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        fprintf(stderr, "RESTORE_FAIL %s\n", argv[1]);
        return 3;
    }
    const std::string tag(argv[2]);
    rolemap_t ROLES;
    buildRoles(s, ROLES);
    std::vector<std::string> out;
    char b[4096];
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;

        // ---- REF: everything that can carry a vpiActual ------------------
        const BaseClass* act = nullptr;
        bool isRef = false;
        if (const ref_obj* r = any_cast<const ref_obj*>(o)) { isRef = true; act = r->Actual_group(); }
        else if (const ref_var* r = any_cast<const ref_var*>(o)) { isRef = true; act = r->Actual_group(); }
        else if (const chandle_var* r = any_cast<const chandle_var*>(o)) { isRef = true; act = r->Actual_group(); }
        else if (const ref_module* r = any_cast<const ref_module*>(o)) { isRef = true; act = r->Actual_group(); }
        if (isRef) {
            snprintf(b, sizeof b, "REF|%s|%s|%s|%s|%s|ACT=%s", tag.c_str(),
                     kindOf(o).c_str(), std::string(o->VpiName()).c_str(),
                     spanOf(o).c_str(), homeChain(o).c_str(), actOf(act).c_str());
            out.push_back(b);

            // ---- CAS: the same reference, keyed by CONTEXT x CAST x HOME --
            std::string ctx = "body", casts;
            {
                int guard = 0;
                const BaseClass* cur = o;
                while (cur && guard++ < 128) {
                    auto it = ROLES.find(cur);
                    if (it != ROLES.end()) { ctx = it->second; break; }
                    const BaseClass* p = cur->VpiParent();
                    if (!p || !transparentUp(p)) { ctx = "body"; break; }
                    std::string w;
                    if (isCastWrapper(p, w)) {
                        if (!casts.empty()) casts += ">";
                        casts += w;
                    }
                    cur = p;
                }
            }
            snprintf(b, sizeof b, "CAS|%s|CTX=%s|CAST=%s|HOME=%s|%s|%s|%s|%s",
                     tag.c_str(), ctx.c_str(),
                     casts.empty() ? "none" : casts.c_str(), homeOf(o).c_str(),
                     kindOf(o).c_str(), std::string(o->VpiName()).c_str(),
                     spanOf(o).c_str(), act ? "BOUND" : "BARE");
            out.push_back(b);

            // ---- ARG: r10uvm165's own family — every CALL ARGUMENT keyed by
            // the WINDOW SHAPE the law is written in: the call's POSITION
            // (statement vs expression), its RECEIVER kind, the CONTROL-BODY
            // DEPTH between it and the enclosing subroutine, and that
            // subroutine's HOME.  A `begin` / `named_begin` / `fork` raises no
            // depth (§ controlBodyNoBind28), so it is transparent here too.
            if (ctx == "arg") {
                const BaseClass* call = nullptr;
                for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
                    if (any_cast<const tf_call*>(p)) { call = p; break; }
                    if (!transparentUp(p)) break;
                }
                if (call) {
                    const BaseClass* cp = call->VpiParent();
                    const char* pos = (cp && isStmtHolder(cp->UhdmType()))
                                          ? "stmt" : "expr";
                    const char* recv = "none";
                    if (call->UhdmType() == uhdmmethod_func_call) {
                        recv = ((const method_func_call*)call)->Prefix() ? "prefix" : "bare";
                    } else if (call->UhdmType() == uhdmmethod_task_call) {
                        recv = ((const method_task_call*)call)->Prefix() ? "prefix" : "bare";
                    } else if (call->UhdmType() == uhdmsys_func_call ||
                               call->UhdmType() == uhdmsys_task_call) {
                        recv = "syscall";
                    }
                    if (cp && cp->UhdmType() == uhdmhier_path) recv = "hierpath";
                    int depth = 0;
                    for (const BaseClass* p = cp; p; p = p->VpiParent()) {
                        UHDM_OBJECT_TYPE t = p->UhdmType();
                        if (t == uhdmfunction || t == uhdmtask) break;
                        if (isCtrlBody(t)) ++depth;
                    }
                    snprintf(b, sizeof b,
                             "ARG|%s|POS=%s|RECV=%s|D=%d|HOME=%s|%s|%s|%s|%s",
                             tag.c_str(), pos, recv, depth, homeOf(o).c_str(),
                             kindOf(o).c_str(),
                             std::string(o->VpiName()).c_str(),
                             spanOf(o).c_str(), act ? "BOUND" : "BARE");
                    out.push_back(b);
                }
            }
        }
        // ---- TYP: every ref_typespec's actual ----------------------------
        if (const ref_typespec* rt = any_cast<const ref_typespec*>(o)) {
            snprintf(b, sizeof b, "TYP|%s|%s|%s|%s|ACT=%s", tag.c_str(),
                     std::string(rt->VpiName()).c_str(), spanOf(rt).c_str(),
                     homeChain(rt).c_str(), actOf(rt->Actual_typespec()).c_str());
            out.push_back(b);
        }
        // ---- VAR / CNT: the listings -------------------------------------
        if (const scope* sc = any_cast<const scope*>(o)) {
            if (auto* v = sc->Variables())
                for (auto* var : *v) {
                    if (!var) continue;
                    snprintf(b, sizeof b, "VAR|%s|%s:%s@%u|%s|%s|%s|auto=%d",
                             tag.c_str(), kindOf(sc).c_str(),
                             std::string(sc->VpiName()).c_str(), sc->VpiLineNo(),
                             kindOf(var).c_str(),
                             std::string(var->VpiName()).c_str(),
                             spanOf(var).c_str(), (int)var->VpiAutomatic());
                    out.push_back(b);
                }
            snprintf(b, sizeof b, "CNT|%s|%s:%s@%s|vars=%zu", tag.c_str(),
                     kindOf(sc).c_str(), std::string(sc->VpiName()).c_str(),
                     spanOf(sc).c_str(),
                     sc->Variables() ? sc->Variables()->size() : 0);
            out.push_back(b);
        }
        // ---- OBJ: the identity census of EVERY object --------------------
        snprintf(b, sizeof b, "OBJ|%s|%s|%s|%s|%s", tag.c_str(),
                 kindOf(o).c_str(), std::string(o->VpiName()).c_str(),
                 spanOf(o).c_str(), homeChain(o).c_str());
        out.push_back(b);
    }
    std::sort(out.begin(), out.end());
    for (auto& l : out) printf("%s\n", l.c_str());
    return 0;
}
