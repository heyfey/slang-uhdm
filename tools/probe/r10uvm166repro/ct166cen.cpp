// r10uvm166 — THE DECLARATION-KIND + TYPESPEC-KIND CENSUS (verbatim
// r10uvm115repro/ct166cen.cpp, renamed; the columns this head needs — VK, the
// declared object's own UHDM kind, and TSK/TSN/TSI/TSLC, the bound typespec's
// kind / name / vpiInstance / span — are exactly the ones that census already
// prints, and re-deriving them would only risk a different bug).
//
// build: g++ -O2 -std=c++17 ct166cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct166cen
//
// r10uvm115 — THE DECLARATION-KIND + TYPESPEC-KIND CENSUS.  MEASUREMENT ONLY;
// nothing here is an acceptance judge (the official uhdm-cmp and
// scripts/verify_golden.py are).  LHS is ALWAYS golden (Surelog); RHS is
// ALWAYS ours.
//
// Descended from r10uvm105repro/r10uvm105cen.cpp with TWO columns added that
// THIS head needs and that census could not see:
//   VK  the DECLARED OBJECT's own UHDM kind (`ref_var` vs `class_var` IS the
//       head: `BaseClass::Compare`'s first test is VpiType), and
//   PK  its vpiParent's kind (the head's `begin`), so a re-parenting shows.
// A third block censuses every CALL (`func_call` / `method_func_call` /
// `tf_call` / `sys_func_call`) so `process::self()` and `p.status()` are
// visible without re-reading the source.
//
// One row per DECLARATION that carries a `ref_typespec`, keyed on what BOTH
// sides can spell: the listing VIEW, the OWNER (nearest enclosing task/func
// fullname, else the nearest named ancestor), and the declaration's own
// LINE:COL span.  Our objects carry an EMPTY VpiFile (buvm16 / uvm113), so the
// file is NEVER part of the key.
//
// Columns (tab separated), row type DECL:
//   TAG SITE VIEW OOB CLS OWNER LC NM VK PK TSK TSN TSI TSLC
// row type CALL:
//   TAG "CALL" VIEW OOB CLS OWNER LC NM KIND PK - - - -
// row type REF (every reference object), so the SECOND conjunct of the law —
// golden binds NO `ref_obj` to a `ref_var` local — is measurable:
//   TAG "REF" VIEW OOB CLS OWNER LC NM KIND <actual kind> <actual span> - - -
// row type TP (a class's own type parameters), unchanged from 105:
//   TAG "TP" <class VpiDefName> <parameter VpiName>
//
// usage: ct166cen <file.uhdm> [tag]
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
    if (argc < 2) { std::cerr << "usage: ct166cen <file.uhdm> [tag]\n"; return 2; }
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
    std::set<const any*> retVars;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmfunction)
            if (auto* r = ((const function*)o)->Return()) retVars.insert(r);
    }
    // the owner walk, shared by DECL and CALL rows
    auto walk = [&](const any* o, const any** owner, const any** root,
                    const any** cls) {
        const any* p = o->VpiParent();
        int d = 0;
        while (p && d++ < 300) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (!*owner && (pt == uhdmfunction || pt == uhdmtask)) *owner = p;
            if (!*cls && pt == uhdmclass_defn) *cls = p;
            auto it = rootView.find(p);
            if (it != rootView.end()) { *root = p; break; }
            if (pt == uhdmdesign) break;
            if (!*owner && (pt == uhdmmodule_inst || pt == uhdmpackage)) *owner = p;
            p = p->VpiParent();
        }
    };
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        const ref_typespec* rt = nullptr;
        std::string site;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        bool isCall = (t == uhdmfunc_call || t == uhdmmethod_func_call ||
                       t == uhdmtask_call || t == uhdmmethod_task_call ||
                       t == uhdmsys_func_call || t == uhdmsys_task_call);
        bool isRef = (t == uhdmref_obj);
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
        if (!rt && !isCall && !isRef) continue;
        const any* owner = nullptr; const any* root = nullptr; const any* cls = nullptr;
        walk(o, &owner, &root, &cls);
        std::string oob = "-";
        if (owner && (owner->UhdmType() == uhdmfunction || owner->UhdmType() == uhdmtask)) {
            std::string on(owner->VpiName());
            oob = (on.find("::") != std::string::npos) ? "OOB" : "IB";
        }
        if (isRef && !rt) {
            const any* act = ((const ref_obj*)o)->Actual_group();
            std::cout << tag << "\tREF\t"
                      << (root ? rootView[root] : std::string("OTHER")) << "\t"
                      << oob << "\t"
                      << (cls ? esc(std::string(((const class_defn*)cls)->VpiDefName())) : std::string("-"))
                      << "\t" << esc(fnm(owner)) << "\t" << span(o) << "\t"
                      << esc(std::string(o->VpiName())) << "\t"
                      << kd(o) << "\t" << kd(o->VpiParent()) << "\t"
                      << kd(act) << "\t" << (act ? esc(std::string(act->VpiName())) : std::string("-"))
                      << "\t-\t" << span(act) << "\n";
            continue;
        }
        if (isCall) {
            std::cout << tag << "\tCALL\t"
                      << (root ? rootView[root] : std::string("OTHER")) << "\t"
                      << oob << "\t"
                      << (cls ? esc(std::string(((const class_defn*)cls)->VpiDefName())) : std::string("-"))
                      << "\t" << esc(fnm(owner)) << "\t" << span(o) << "\t"
                      << esc(std::string(o->VpiName())) << "\t"
                      << kd(o) << "\t" << kd(o->VpiParent()) << "\t-\t-\t-\t-\n";
            continue;
        }
        const typespec* ats = rt->Actual_typespec();
        if (site == "VAR" && owner &&
            (owner->UhdmType() == uhdmfunction || owner->UhdmType() == uhdmtask))
            site = retVars.count(o) ? "RET" : "LOCAL";
        else if (site == "VAR" && cls && o->VpiParent() == cls)
            site = "PROP";
        std::cout << tag << "\t" << site << "\t"
                  << (root ? rootView[root] : std::string("OTHER")) << "\t"
                  << oob << "\t"
                  << (cls ? esc(std::string(((const class_defn*)cls)->VpiDefName())) : std::string("-"))
                  << "\t" << esc(fnm(owner)) << "\t" << span(o) << "\t"
                  << esc(std::string(o->VpiName())) << "\t"
                  << kd(o) << "\t" << kd(o->VpiParent()) << "\t"
                  << kd(ats) << "\t" << (ats ? esc(std::string(ats->VpiName())) : std::string("-"))
                  << "\t"
                  // r10uvm166: a NULL vpiInstance and an instance with an
                  // EMPTY name are DIFFERENT answers and `esc` collapses both
                  // to "-", so the null case gets its own token.
                  << (!ats ? std::string("-")
                           : (ats->Instance()
                                  ? esc(std::string(ats->Instance()->VpiName()))
                                  : std::string("<noinst>")))
                  << "\t" << span(ats) << "\n";
    }
    return 0;
}
