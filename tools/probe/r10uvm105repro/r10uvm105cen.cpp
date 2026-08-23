// r10uvm105 — THE DECLARATION-TYPESPEC CENSUS.  MEASUREMENT ONLY; nothing here
// is an acceptance judge (the official uhdm-cmp and scripts/verify_golden.py
// are).  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per DECLARATION that carries a `ref_typespec`, keyed on what BOTH
// sides can spell: the listing VIEW, the OWNER (nearest enclosing task/func
// fullname, else the nearest named ancestor), and the declaration's own
// LINE:COL span.  Our expression nodes carry an EMPTY VpiFile (buvm16's trap),
// so the file is never part of the key.
//
// Columns (tab separated)
//   TAG   the caller's tag (G / O)
//   SITE  FORMAL   an io_decl of a task/func
//         RET      the task/func's Return variable
//         LOCAL    a variables inside a task/func
//         PROP     a variables directly under a class_defn
//         MEMBER   a typespec_member
//         PARAM    a parameter / type_parameter
//         VAR      any other variables
//   VIEW  DEFCLASS / DEFPKG / ELABPKG / TOPMOD / DEFMOD / …
//   OOB   OOB when the owning task/func's VpiName contains "::" (Surelog names
//         an OUT-OF-BODY definition `cls::meth`), IB otherwise, "-" when there
//         is no task/func owner.
//   CLS   nearest enclosing class_defn VpiDefName (the owner class)
//   OWNER task/func fullname (or the nearest named ancestor)
//   LC    <line>:<col>-<endline>:<endcol> of the DECLARED object
//   NM    the declared object's own VpiName (grid readability only -- it is
//         part of NO join key, because a key that reads a NAME cannot see a
//         rename)
//   TSK   the ref_typespec's Actual_typespec KIND
//   TSN   its VpiName
//   TSI   its Instance()'s VpiName (or "-")
//   TSLC  its own span
//
// The census ALSO emits, before the declaration rows, one line per class TYPE
// PARAMETER:
//   <tag>\tTP\t<class VpiDefName>\t<parameter VpiName>
// so a reader can ask "is this written name a type parameter of the owner
// class?" -- the discriminator § oobClassTypeParamLocalUnsupported105 turns on
// -- without re-reading the source.
//
// usage: r10uvm105cen <file.uhdm> [tag]
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
static std::string fnm(const any* t) {
    if (!t) return "-";
    if (const scope* sc = any_cast<const scope*>(t)) {
        std::string f(sc->VpiFullName());
        if (!f.empty()) return f;
    }
    return std::string(t->VpiName());
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10uvm105cen <file.uhdm> [tag]\n"; return 2; }
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
    // Every class_defn's own TYPE PARAMETERS, by class def-name.
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmclass_defn) continue;
        const class_defn* cd = (const class_defn*)o;
        if (auto* ps = cd->Parameters())
            for (auto* p0 : *ps)
                if (p0 && p0->UhdmType() == uhdmtype_parameter)
                    std::cout << tag << "\tTP\t"
                              << esc(cd->VpiDefName().empty()
                                         ? std::string(cd->VpiName())
                                         : std::string(cd->VpiDefName()))
                              << "\t" << esc(std::string(p0->VpiName())) << "\n";
    }
    // The RETURN variable of every task_func, so SITE=RET is read off the
    // carrier and not guessed from the parent kind.
    std::set<const any*> retVars;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmfunction)
            if (auto* r = ((const function*)o)->Return()) retVars.insert(r);
    }
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        const ref_typespec* rt = nullptr;
        std::string site;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        if (const variables* v = any_cast<const variables*>(o)) {
            rt = v->Typespec(); site = "VAR";
        } else if (t == uhdmio_decl) {
            rt = ((const io_decl*)o)->Typespec(); site = "FORMAL";
        } else if (t == uhdmtypespec_member) {
            rt = ((const typespec_member*)o)->Typespec(); site = "MEMBER";
        } else if (t == uhdmparameter) {
            rt = ((const parameter*)o)->Typespec(); site = "PARAM";
        } else if (t == uhdmtype_parameter) {
            rt = ((const type_parameter*)o)->Typespec(); site = "TPARAM";
        }
        if (!rt) continue;
        const typespec* ats = rt->Actual_typespec();

        // owner walk
        const any* owner = nullptr; const any* root = nullptr; const any* cls = nullptr;
        const any* p = o->VpiParent();
        int d = 0;
        while (p && d++ < 300) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (!owner && (pt == uhdmfunction || pt == uhdmtask)) owner = p;
            if (!cls && pt == uhdmclass_defn) cls = p;
            auto it = rootView.find(p);
            if (it != rootView.end()) { root = p; break; }
            if (pt == uhdmdesign) break;
            if (!owner && (pt == uhdmmodule_inst || pt == uhdmpackage)) owner = p;
            p = p->VpiParent();
        }
        if (site == "VAR" && owner &&
            (owner->UhdmType() == uhdmfunction || owner->UhdmType() == uhdmtask))
            site = retVars.count(o) ? "RET" : "LOCAL";
        else if (site == "VAR" && cls && o->VpiParent() == cls)
            site = "PROP";
        std::string oob = "-";
        if (owner && (owner->UhdmType() == uhdmfunction || owner->UhdmType() == uhdmtask)) {
            std::string on(owner->VpiName());
            oob = (on.find("::") != std::string::npos) ? "OOB" : "IB";
        }
        std::cout << tag << "\t" << site << "\t"
                  << (root ? rootView[root] : std::string("OTHER")) << "\t"
                  << oob << "\t"
                  << (cls ? esc(std::string(((const class_defn*)cls)->VpiDefName())) : std::string("-"))
                  << "\t" << esc(fnm(owner)) << "\t" << span(o) << "\t"
                  << esc(std::string(o->VpiName())) << "\t"
                  << kd(ats) << "\t" << (ats ? esc(std::string(ats->VpiName())) : std::string("-"))
                  << "\t"
                  << (ats && ats->Instance() ? esc(std::string(ats->Instance()->VpiName())) : std::string("-"))
                  << "\t" << span(ats) << "\n";
    }
    return 0;
}
