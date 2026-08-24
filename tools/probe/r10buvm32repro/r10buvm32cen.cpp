// r10buvm32 — THE SCOPED-CALL CENSUS.  MEASUREMENT ONLY; nothing here is an
// acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// FAMILY `SCALL` — one row per object that CARRIES A `::` IN ITS VpiName and
// is one of the four kinds a `C::m(...)` written call can land on:
// `func_call` / `task_call` / `method_func_call` / `ref_obj`.  That is the
// whole population the two producers disagree over: Surelog's class_scope arm
// (CompileExpression.cpp ~5253) either builds a tf_call — when
// `getTaskFunc("<first written segment>::<final identifier>")` HITS — or falls
// through to `compileExpression` on the scoped name, which yields a bare
// `ref_obj`.  Both sides are enumerated by the SAME rule so the join is
// symmetric and neither producer's vocabulary decides the key.
//
// COLUMNS (the key is LOC + NAME + HOME; everything else is payload):
//   * LOC   — `line:col-endline:endcol`, the span.  Our expression nodes carry
//             an EMPTY VpiFile (buvm16's trap), so no file enters the key.
//   * KIND  — the UHDM object kind.  THE column this pass is about.
//   * NAME  — VpiName, which for this family is the WRITTEN scoped text
//             (`this_type::add_typewide_sequence`) on both sides.
//   * LINK  — `vpiFunction` / `vpiTask` for a tf_call, `Actual_group` for a
//             ref_obj, as `<kind>:<fullname>`; `-` when unbound.  `ref_obj::
//             Compare` DOES read Actual_group (RESUME §9), so this is a
//             judge-visible field, not a decoration.
//   * NARG  — size of `Tf_call_args` (`-1` for a ref_obj, which has none).
//             tf_call::Compare reads the argument vector.
//   * HOME  — nearest enclosing function / task / class_defn / package /
//             module_inst, as `<kind>:<fullname>` — the "out-of-body method /
//             in-body / static / package function / module" split the pass
//             brief asks for, read off the tree instead of guessed.
//   * POS   — the vpiParent's KIND.  `begin` / `named_begin` / `function` is
//             STATEMENT position; `assignment` / `if_stmt` / `operation` /
//             `func_call` / `sys_func_call` are the EXPRESSION positions.
//             Payload only (no generated Compare reads VpiParent).
//   * REACH — Y when the object is reachable from a design root (buvm23's
//             verifier lesson: `Serializer::AllObjects` counts ORPHANS, and an
//             orphan is invisible to the judge).
//
// usage: r10buvm32cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string kd(const any* t) {
    return t ? std::string(UhdmName(t->UhdmType())) : "NULL";
}
static std::string esc(std::string s) {
    for (auto& c : s)
        if (c == '\t' || c == '\n' || c == '|') c = ' ';
    return s;
}
static std::string span(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}
static std::string fnm(const any* t) {
    if (!t) return "-";
    if (const scope* sc = any_cast<const scope*>(t))
        if (!sc->VpiFullName().empty()) return std::string(sc->VpiFullName());
    if (!t->VpiName().empty()) return std::string(t->VpiName());
    return "-";
}
static std::string lnk(const any* t) {
    return t ? kd(t) + ":" + esc(fnm(t)) : std::string("-");
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10buvm32cen <file.uhdm> [tag]\n";
        return 2;
    }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        std::cout << "RESTORE_FAIL " << tag << "\n";
        return 3;
    }
    std::set<const any*> roots;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* dd = (const design*)o;
        if (auto* v = dd->TopPackages())   for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->TopModules())    for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->AllPackages())   for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->AllModules())    for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->AllClasses())    for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->AllPrograms())   for (auto* p : *v) roots.insert(p);
        if (auto* v = dd->AllInterfaces()) for (auto* p : *v) roots.insert(p);
    }
    long n = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        if (t != uhdmfunc_call && t != uhdmtask_call &&
            t != uhdmmethod_func_call && t != uhdmmethod_task_call &&
            t != uhdmref_obj)
            continue;
        std::string nm(o->VpiName());
        if (nm.find("::") == std::string::npos) continue;
        std::string link = "-";
        int narg = -1;
        if (t == uhdmfunc_call) {
            link = lnk(((const func_call*)o)->Function());
            if (auto* a = ((const func_call*)o)->Tf_call_args())
                narg = (int)a->size();
            else
                narg = 0;
        } else if (t == uhdmtask_call) {
            link = lnk(((const task_call*)o)->Task());
            if (auto* a = ((const task_call*)o)->Tf_call_args())
                narg = (int)a->size();
            else
                narg = 0;
        } else if (t == uhdmmethod_func_call || t == uhdmmethod_task_call) {
            if (auto* a = ((const tf_call*)o)->Tf_call_args())
                narg = (int)a->size();
            else
                narg = 0;
        } else {
            link = lnk(((const ref_obj*)o)->Actual_group());
        }
        const any* owner = nullptr;
        bool reach = false;
        const any* p = o->VpiParent();
        std::string pos = p ? kd(p) : std::string("-");
        int d = 0;
        while (p && d++ < 300) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (!owner && (pt == uhdmfunction || pt == uhdmtask ||
                           pt == uhdmclass_defn || pt == uhdmmodule_inst ||
                           pt == uhdmpackage))
                owner = p;
            if (roots.count(p)) { reach = true; break; }
            if (pt == uhdmdesign) { reach = true; break; }
            p = p->VpiParent();
        }
        std::cout << tag << "\tSCALL\t" << span(o) << "\t" << kd(o) << "\t"
                  << esc(nm) << "\tlink=" << esc(link) << "\tnarg=" << narg
                  << "\thome=" << (owner ? kd(owner) : std::string("-")) << ":"
                  << esc(fnm(owner)) << "\tpos=" << pos
                  << "\treach=" << (reach ? "Y" : "N") << "\n";
        n++;
    }
    std::cerr << "ROWS " << tag << " SCALL " << n << "\n";
    return 0;
}
