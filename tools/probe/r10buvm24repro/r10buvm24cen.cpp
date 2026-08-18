// r10buvm24 — THE CALL-ARGUMENT CENSUS.  MEASUREMENT ONLY; nothing here is an
// acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// FAMILY `CALL` — one row per tf_call-family object (func_call, task_call,
// method_func_call, method_task_call, sys_func_call, sys_task_call), carrying
//   * LOC   — line:col of the CALL, the only key stable across the two sides
//             (our expression nodes carry an EMPTY VpiFile — buvm16's trap —
//             and owner FULLNAMES are naming-context dependent, so neither is
//             in the key).
//   * KIND  — the UHDM object kind of the call.
//   * NAME  — VpiName.
//   * NARG  — argument count.
//   * ARGSIG — the JUDGE-VISIBLE payload of every argument, "|"-joined:
//             for a `constant`, `C:ct=<n>:sz=<n>:dc=<decompile>:ts=<kind>`
//             (`constant::Compare` reads BaseClass VpiType/VpiName/VpiDefName,
//             then expr's VpiDecompile / VpiSize / Typespec, then
//             VpiConstType ONLY — VpiValue is NOT compared);
//             for anything else, `<kind>:<VpiName>`.
//   * ARGX  — the NON-judge-visible companion: per argument
//             `v=<VpiValue>:l=<line:col>:p=<parent kind>`, so the
//             re-encode-vs-clone question (unparented, at the call site, vs a
//             clone of the declaration's literal parented at the call) is
//             visible without ever entering a key.
//   * OWNER — nearest enclosing function/task/class/package/module fullname,
//             payload only.
//   * REACH — Y when the call is reachable from a design root (buvm23's
//             verifier lesson: Serializer::AllObjects counts ORPHANS).
//
// usage: r10buvm24cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <set>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string esc(std::string s) {
    for (auto& c : s) if (c == '\t' || c == '\n' || c == '|') c = ' ';
    return s;
}
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) : "-";
}
static std::string fnm(const any* t) {
    if (!t) return "-";
    if (const scope* sc = any_cast<const scope*>(t)) return std::string(sc->VpiFullName());
    return std::string(t->VpiName());
}

static bool isCall(const any* o) {
    switch (o->UhdmType()) {
        case uhdmfunc_call: case uhdmtask_call:
        case uhdmmethod_func_call: case uhdmmethod_task_call:
        case uhdmsys_func_call: case uhdmsys_task_call:
            return true;
        default: return false;
    }
}

static std::string argSig(const any* a) {
    if (!a) return "NULL";
    if (a->UhdmType() == uhdmconstant) {
        const constant* c = (const constant*)a;
        return "C:ct=" + std::to_string(c->VpiConstType()) +
               ":sz=" + std::to_string(c->VpiSize()) +
               ":dc=" + esc(std::string(c->VpiDecompile())) +
               ":ts=" + (c->Typespec() ? kd(c->Typespec()) : std::string("-"));
    }
    return kd(a) + ":" + esc(std::string(a->VpiName()));
}
static std::string argX(const any* a) {
    if (!a) return "NULL";
    std::string v = "-";
    if (const expr* e = any_cast<const expr*>(a)) v = esc(std::string(e->VpiValue()));
    return "v=" + v + ":l=" + loc(a) + ":p=" + (a->VpiParent() ? kd(a->VpiParent()) : std::string("NONE"));
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm24cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    // reachability: an object is REACHABLE when a parent chain from it lands on
    // a design-root listing member.  (Cheap and view-FREE: the label is a
    // boolean, never a view name.)
    std::set<const any*> roots;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (auto* v = d->TopPackages())  for (auto* p : *v) roots.insert(p);
        if (auto* v = d->TopModules())   for (auto* p : *v) roots.insert(p);
        if (auto* v = d->AllPackages())  for (auto* p : *v) roots.insert(p);
        if (auto* v = d->AllModules())   for (auto* p : *v) roots.insert(p);
        if (auto* v = d->AllClasses())   for (auto* p : *v) roots.insert(p);
        if (auto* v = d->AllPrograms())  for (auto* p : *v) roots.insert(p);
        if (auto* v = d->AllInterfaces())for (auto* p : *v) roots.insert(p);
    }

    long n = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || !isCall(o)) continue;
        const tf_call* tc = (const tf_call*)o;
        const VectorOfany* av = nullptr;
        if (const sys_func_call* f = any_cast<const sys_func_call*>(o)) av = f->Tf_call_args();
        else if (const sys_task_call* t = any_cast<const sys_task_call*>(o)) av = t->Tf_call_args();
        else av = tc->Tf_call_args();

        const any* owner = nullptr; bool reach = false;
        const any* p = o->VpiParent(); int d = 0;
        while (p && d++ < 300) {
            UHDM_OBJECT_TYPE t = p->UhdmType();
            if (!owner && (t == uhdmfunction || t == uhdmtask)) owner = p;
            if (roots.count(p)) { reach = true; break; }
            if (t == uhdmdesign) { reach = true; break; }
            if (!owner && (t == uhdmclass_defn || t == uhdmmodule_inst || t == uhdmpackage)) owner = p;
            p = p->VpiParent();
        }

        std::string sig, xs;
        int na = 0;
        if (av) for (auto* a : *av) {
            if (na++) { sig += "|"; xs += "|"; }
            sig += argSig(a); xs += argX(a);
        }
        std::cout << tag << "\tCALL\t" << loc(o) << "\t" << kd(o) << "\t"
                  << esc(std::string(o->VpiName())) << "\tnarg=" << na
                  << "\t" << (sig.empty() ? "-" : sig)
                  << "\t" << (xs.empty() ? "-" : xs)
                  << "\towner=" << esc(fnm(owner))
                  << "\treach=" << (reach ? "Y" : "N") << "\n";
        n++;
    }
    std::cerr << "ROWS " << tag << " CALL " << n << "\n";
    return 0;
}
