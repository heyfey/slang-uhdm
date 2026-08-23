// r10uvm103 — THE DOTTED-CALL CENSUS.  MEASUREMENT ONLY; nothing here is an
// acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per DOTTED CALL SITE, in either of the two carrier shapes the two
// compilers use for `a.b(...)` / `a.b.c(...)` / `a.b.c.d(...)`:
//
//   FAM=MFC     a `method_func_call` / `func_call` / `task_call` that carries a
//               vpiPrefix (Surelog's compileTfCall shape).
//   FAM=HPCALL  a `hier_path` whose LAST Path_elem is a call (our receiver
//               builder's shape).
//   FAM=BARESTMT  an object occupying a STATEMENT slot that is not a statement
//               at all — a `ref_obj` / `bit_select` / bare `hier_path` /
//               `constant` / `operation`.  MEASURED, not assumed: golden holds
//               PLENTY of them (242 in SimpleUVM/default, 404 in SeqDriver) —
//               `a++;`, an event trigger, a `constant` statement — so the
//               family is NOT a fossil marker on its own.  What it ranks is the
//               DELTA: ours holds 2 to 4 FEWER per UVM database, which is where
//               a call the emitter dropped to a bare receiver would show up
//               (§ droppedCall14's residue, arm g103_a3 cell G3rcv).
//
// Columns
//   VIEW   root listing the object hangs under (DEFCLASS / DEFPKG / ELABPKG /
//          TOPMOD / DEFMOD / …) — buvm17/21/22's classifier.
//   OWNER  nearest enclosing function/task fullname, else nearest named
//          ancestor.  Our expression nodes carry an EMPTY VpiFile (buvm16's
//          trap) so the key is OWNER + LINE, never the file.
//   LINE   VpiLineNo of the carrier.
//   POS    STMT when the object IS the value of an enclosing statement slot
//          (task_func::Stmt, begin::Stmts, if::VpiStmt, …), else EXPR.
//   NC     component count: for MFC 1 + (prefix?1:0); for HPCALL Path_elems.
//   SHAPE  the judge-visible payload — kind, VpiName, prefix kind/name/col,
//          per-element kind:name, and the ARGUMENT kinds.
//
// usage: r10uvm103cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string esc(std::string s) {
    for (auto& c : s) if (c == '\t' || c == '\n') c = ' ';
    return s;
}
static std::string col(const any* o) {
    return o ? std::to_string(o->VpiColumnNo()) : "-";
}
static std::string fnm(const any* t) {
    if (!t) return "-";
    if (const scope* sc = any_cast<const scope*>(t)) return std::string(sc->VpiFullName());
    if (const ref_obj* r = any_cast<const ref_obj*>(t)) return std::string(r->VpiFullName());
    return std::string(t->VpiName());
}

// ---- the statement slots of every carrier this corpus uses -----------------
static void stmtSlots(const any* p, std::vector<const any*>& out) {
    if (!p) return;
    switch (p->UhdmType()) {
        case uhdmfunction: case uhdmtask:
            out.push_back(((const task_func*)p)->Stmt()); break;
        case uhdminitial: case uhdmalways: case uhdmfinal_stmt:
            out.push_back(((const process_stmt*)p)->Stmt()); break;
        case uhdmbegin:
            if (auto* v = ((const begin*)p)->Stmts()) for (auto* x : *v) out.push_back(x);
            break;
        case uhdmnamed_begin:
            if (auto* v = ((const named_begin*)p)->Stmts()) for (auto* x : *v) out.push_back(x);
            break;
        case uhdmfork_stmt:
            if (auto* v = ((const fork_stmt*)p)->Stmts()) for (auto* x : *v) out.push_back(x);
            break;
        case uhdmnamed_fork:
            if (auto* v = ((const named_fork*)p)->Stmts()) for (auto* x : *v) out.push_back(x);
            break;
        case uhdmif_stmt: out.push_back(((const if_stmt*)p)->VpiStmt()); break;
        case uhdmif_else:
            out.push_back(((const if_else*)p)->VpiStmt());
            out.push_back(((const if_else*)p)->VpiElseStmt());
            break;
        case uhdmfor_stmt:     out.push_back(((const for_stmt*)p)->VpiStmt()); break;
        case uhdmforeach_stmt: out.push_back(((const foreach_stmt*)p)->VpiStmt()); break;
        case uhdmwhile_stmt:   out.push_back(((const while_stmt*)p)->VpiStmt()); break;
        case uhdmdo_while:     out.push_back(((const do_while*)p)->VpiStmt()); break;
        case uhdmrepeat:       out.push_back(((const repeat*)p)->VpiStmt()); break;
        case uhdmforever_stmt: out.push_back(((const forever_stmt*)p)->VpiStmt()); break;
        case uhdmcase_item:    out.push_back(((const case_item*)p)->Stmt()); break;
        default: break;
    }
}

static const any* lastElem(const hier_path* h) {
    auto* v = h->Path_elems();
    if (!v || v->empty()) return nullptr;
    return v->back();
}

static std::string argKinds(const VectorOfany* v) {
    if (!v || v->empty()) return "-";
    std::string r;
    for (auto* a : *v) { if (!r.empty()) r += ","; r += kd(a) + "(" + esc(nm(a)) + ")"; }
    return r;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10uvm103cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    std::map<const any*, std::string> rootView;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (auto* v = d->TopPackages())  for (auto* p : *v) rootView.emplace(p, "ELABPKG");
        if (auto* v = d->TopModules())   for (auto* p : *v) rootView.emplace(p, "TOPMOD");
        if (auto* v = d->AllPackages())  for (auto* p : *v) rootView.emplace(p, "DEFPKG");
        if (auto* v = d->AllModules())   for (auto* p : *v) rootView.emplace(p, "DEFMOD");
        if (auto* v = d->AllClasses())   for (auto* p : *v) rootView.emplace(p, "DEFCLASS");
        if (auto* v = d->AllPrograms())  for (auto* p : *v) rootView.emplace(p, "DEFPROG");
        if (auto* v = d->AllInterfaces())for (auto* p : *v) rootView.emplace(p, "DEFIFACE");
    }

    // Everything that occupies a STATEMENT slot, so POS is read off the
    // CARRIER and not guessed from the parent's kind.
    std::set<const any*> inStmtSlot;
    for (auto& kv : s.AllObjects()) {
        std::vector<const any*> sl;
        stmtSlots(kv.first, sl);
        for (auto* x : sl) if (x) inStmtSlot.insert(x);
    }

    long mfc = 0, hpc = 0, bare = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        bool isCall = (t == uhdmmethod_func_call || t == uhdmfunc_call ||
                       t == uhdmtask_call || t == uhdmmethod_task_call);
        const hier_path* hp = (t == uhdmhier_path) ? (const hier_path*)o : nullptr;
        const any* le = hp ? lastElem(hp) : nullptr;
        bool isHpCall = le && (le->UhdmType() == uhdmmethod_func_call ||
                               le->UhdmType() == uhdmfunc_call ||
                               le->UhdmType() == uhdmtask_call ||
                               le->UhdmType() == uhdmmethod_task_call);
        // --- FAMILY BARESTMT ----------------------------------------------
        if (!isCall && !isHpCall && inStmtSlot.count(o) &&
            (t == uhdmref_obj || t == uhdmbit_select || t == uhdmhier_path ||
             t == uhdmconstant || t == uhdmoperation || t == uhdmvar_select ||
             t == uhdmpart_select || t == uhdmindexed_part_select)) {
            const any* pp = o->VpiParent();
            std::cout << tag << "\tBARESTMT\t-\t" << (pp ? kd(pp) : "NULL")
                      << "\t" << o->VpiLineNo() << "\tPOS=STMT\tNC=0\t"
                      << kd(o) << ":" << esc(nm(o)) << "@c" << col(o)
                      << "\telems=-\targs=-\n";
            bare++;
        }
        if (!isCall && !isHpCall) continue;

        const any* pfx = nullptr;
        const VectorOfany* args = nullptr;
        if (isCall) {
            const tf_call* c = (const tf_call*)o;
            args = c->Tf_call_args();
            if (t == uhdmmethod_func_call) pfx = ((const method_func_call*)o)->Prefix();
            else if (t == uhdmmethod_task_call) pfx = ((const method_task_call*)o)->Prefix();
        }
        // A prefix-less plain call is not a dotted call site.
        if (isCall && !pfx) continue;

        // view + owner
        const any* owner = nullptr; const any* root = nullptr;
        const any* p = o->VpiParent();
        int d = 0;
        while (p && d++ < 300) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (!owner && (pt == uhdmfunction || pt == uhdmtask)) owner = p;
            auto it = rootView.find(p);
            if (it != rootView.end()) { root = p; break; }
            if (pt == uhdmdesign) break;
            if (!owner && (pt == uhdmclass_defn || pt == uhdmmodule_inst || pt == uhdmpackage))
                owner = p;
            p = p->VpiParent();
        }
        std::string view = root ? rootView[root] : "OTHER";
        std::string own = owner ? fnm(owner) : std::string("-");
        if (own.empty()) own = "-";
        std::string pos = inStmtSlot.count(o) ? "STMT" : "EXPR";

        if (isCall) {
            std::cout << tag << "\tMFC\t" << view << "\t" << own << "\t"
                      << o->VpiLineNo() << "\tPOS=" << pos << "\tNC=2\t"
                      << kd(o) << ":" << esc(nm(o)) << "@c" << col(o)
                      << "\tpfx=" << kd(pfx) << ":" << esc(nm(pfx)) << "@c" << col(pfx)
                      << "\targs=" << esc(argKinds(args)) << "\n";
            mfc++;
        } else {
            const tf_call* lc = (const tf_call*)le;
            std::string elems;
            int nel = 0;
            if (auto* v = hp->Path_elems()) {
                nel = (int)v->size();
                for (auto* e : *v) {
                    if (!elems.empty()) elems += " | ";
                    elems += kd(e) + ":" + esc(nm(e));
                }
            }
            std::cout << tag << "\tHPCALL\t" << view << "\t" << own << "\t"
                      << o->VpiLineNo() << "\tPOS=" << pos << "\tNC=" << nel << "\t"
                      << kd(o) << ":" << esc(std::string(hp->VpiName())) << "@c" << col(o)
                      << "\telems=" << elems
                      << "\targs=" << esc(argKinds(lc->Tf_call_args())) << "\n";
            hpc++;
        }
    }
    std::cerr << "ROWS " << tag << " MFC " << mfc << " HPCALL " << hpc
              << " BARESTMT " << bare << "\n";
    return 0;
}
