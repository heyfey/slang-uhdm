// r10buvm18 — THE PARAMETER-TYPESPEC CENSUS.  MEASUREMENT ONLY; nothing here
// is an acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per `parameter` (and per `param_assign`-less localparam that still
// shows up in a scope's Parameters vector), carrying
//   * the KEY: VIEW + the owning scope's full name + the parameter's own name
//     + its own line:col.  Locations, not files: our expression nodes carry an
//     EMPTY VpiFile (buvm16 § 4), so a file key joins on nothing.
//   * the VALUE: the parameter's `vpiTypespec` -> `vpiActual` decoded as
//         kind(name)[alias->kind(name)] ranges=N inst=kind sharers=?
//     plus the ACTUAL's own vpiParent kind, which is what separates a
//     per-declaration CLONE (parent == the parameter) from a reference to the
//     SHARED typedef object (parent == the package / the typedef's own home).
//     `typespec::Compare` walks VpiName then Typedef_alias then Instance, and
//     `BaseClass::Compare` walks VpiType first, so those are exactly the
//     fields the judge reads.
//   * `nsh=` how many DISTINCT ref_typespecs in the same database point at the
//     same actual object id — the sharing fan-out.  uhdm-cmp's visited set is
//     keyed on the LHS object, so a SHARED actual is compared ONCE and every
//     later reference to it returns 0 unread: sharing HIDES a kind mismatch
//     from the judge, and that is why the head lands where it lands.
//
// usage: r10buvm18cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kd(const any* t) { return t ? std::string(UhdmName(t->UhdmType())) : "NULL"; }
static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) : "-";
}
static std::string full(const any* t) {
    if (!t) return "-";
    switch (t->UhdmType()) {
        case uhdmpackage: return std::string(((const package*)t)->VpiFullName());
        case uhdmclass_defn: return std::string(((const class_defn*)t)->VpiFullName());
        case uhdmmodule_inst: return std::string(((const module_inst*)t)->VpiFullName());
        case uhdminterface_inst: return std::string(((const interface_inst*)t)->VpiFullName());
        case uhdmprogram: return std::string(((const program*)t)->VpiFullName());
        case uhdmgen_scope: return std::string(((const gen_scope*)t)->VpiFullName());
        case uhdmfunction: return std::string(((const function*)t)->VpiFullName());
        case uhdmtask: return std::string(((const task*)t)->VpiFullName());
        default: return std::string(t->VpiName());
    }
}

// how many ref_typespec objects point at each actual typespec id
static std::map<uint32_t, int> g_sharers;

static void countSharers(const BaseClass* o);

static std::string tsDesc(const ref_typespec* rt) {
    if (!rt) return "NOREF";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "REF(<null-actual>)";
    std::string s = kd(a) + "(" + nm(a) + ")";
    const ref_typespec* al = a->Typedef_alias();
    if (al) {
        const typespec* at = al->Actual_typespec();
        s += "[alias->" +
             (at ? kd(at) + "(" + nm(at) + ")#" + std::to_string(at->UhdmId())
                 : std::string("<null>")) +
             "]";
    } else {
        s += "[noalias]";
    }
    // ranges, where the kind has them
    int nr = -1;
    if (a->UhdmType() == uhdmbit_typespec) { auto* r = ((const bit_typespec*)a)->Ranges(); nr = r ? (int)r->size() : 0; }
    else if (a->UhdmType() == uhdmlogic_typespec) { auto* r = ((const logic_typespec*)a)->Ranges(); nr = r ? (int)r->size() : 0; }
    else if (a->UhdmType() == uhdmint_typespec) { nr = 0; }
    s += " rg=" + std::to_string(nr);
    // BOUND SHAPE: golden either keeps the typedef's SYMBOLIC bound operation
    // or FOLDS it to a constant; the fold's encoding (INT vs UINT, size, span)
    // is what `range::Compare` -> `constant::Compare` reads, so print it.
    if (const auto* rr = (a->UhdmType() == uhdmbit_typespec)
                             ? ((const bit_typespec*)a)->Ranges()
                             : (a->UhdmType() == uhdmlogic_typespec)
                                   ? ((const logic_typespec*)a)->Ranges()
                                   : nullptr) {
        for (const auto* r : *rr) {
            auto one = [&](const any* e) {
                if (!e) return std::string("-");
                std::string t = kd(e) + "@" + loc(e);
                if (e->UhdmType() == uhdmconstant) {
                    const constant* c = (const constant*)e;
                    t += "{" + std::string(c->VpiValue()) + ",sz" +
                         std::to_string(c->VpiSize()) + ",ct" +
                         std::to_string(c->VpiConstType()) + "}";
                }
                return t;
            };
            s += " R[" + loc(r) + " L=" + one(r->Left_expr()) +
                 " R=" + one(r->Right_expr()) + "]";
        }
    }
    s += " apar=" + kd(a->VpiParent());
    s += " id=" + std::to_string(a->UhdmId());
    s += " inst=" + (a->Instance() ? kd(a->Instance()) + "#" +
                                         std::to_string(a->Instance()->UhdmId())
                                   : std::string("-"));
    s += " nsh=" + std::to_string(g_sharers.count(a->UhdmId()) ? g_sharers[a->UhdmId()] : 0);
    return s;
}

static std::string tag;

static void emit(const std::string& view, const any* owner, const parameter* p) {
    std::cout << view << "\t" << full(owner) << "\t" << nm(p) << "\t" << loc(p) << "\t"
              << (p->VpiLocalParam() ? "LOCAL" : "PARAM") << "\t"
              << tsDesc(p->Typespec()) << "\n";
}
static void emit(const std::string& view, const any* owner, const param_assign* pa) {
    // localparams sometimes ride only the Param_assigns vector
    const any* l = pa->Lhs();
    if (!l || l->UhdmType() != uhdmparameter) return;
    emit(view, owner, (const parameter*)l);
}

template <typename V>
static void scanParams(const std::string& view, const any* owner, V* v) {
    if (!v) return;
    for (auto* x : *v) {
        if (x && x->UhdmType() == uhdmparameter) emit(view, owner, (const parameter*)x);
    }
}

static void scanScope(const std::string& view, const any* o);

static void scanInst(const std::string& view, const instance* in) {
    scanParams(view, in, in->Parameters());
    if (in->Task_funcs())
        for (auto* tf : *in->Task_funcs()) scanParams(view + ".TF", tf, tf->Parameters());
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm18cen <file.uhdm> [tag]\n"; return 2; }
    tag = (argc > 2) ? argv[2] : "";
    Serializer s;
    std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cerr << "RESTORE-FAILED " << argv[1] << "\n"; return 3; }
    design* d = (design*)((const uhdm_handle*)restored[0])->object;

    // pass 1: count sharers over EVERY ref_typespec in the database
    for (auto& it : s.AllObjects()) {
        const BaseClass* o = it.first;
        if (o && o->UhdmType() == uhdmref_typespec) {
            const typespec* a = ((const ref_typespec*)o)->Actual_typespec();
            if (a) g_sharers[a->UhdmId()]++;
        }
    }

    if (d->AllPackages()) for (auto* p : *d->AllPackages()) scanInst("DEFPKG", p);
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) scanInst("ELABPKG", p);
    if (d->AllClasses()) for (auto* c : *d->AllClasses()) {
        scanParams("DEFCLASS", c, c->Parameters());
        if (c->Task_funcs()) for (auto* tf : *c->Task_funcs()) scanParams("DEFCLASS.TF", tf, tf->Parameters());
    }
    if (d->AllModules()) for (auto* m : *d->AllModules()) scanInst("DEFMOD", m);
    if (d->TopModules()) for (auto* m : *d->TopModules()) scanInst("ELABMOD", m);
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) scanInst("DEFIFC", m);
    if (d->AllPrograms()) for (auto* m : *d->AllPrograms()) scanInst("DEFPRG", m);
    return 0;
}
