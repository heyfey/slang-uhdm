// r10uvm187 — THE PER-PARAMETER TYPESPEC CENSUS (name / span / alias).
// MEASUREMENT ONLY; nothing here is an acceptance judge (the official
// `uhdm-cmp` and `scripts/verify_golden.py` are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Derived from tools/probe/r10buvm18repro/r10buvm18cen.cpp, with three
// additions this head needs:
//   * the actual typespec's FULL SPAN (line:col-endline:endcol), because the
//     head's two sides differ in WHERE the typespec is anchored (golden at the
//     TYPEDEF's own type token, ours at the parameter's declared-type token)
//     even when the kind agrees;
//   * recursion into class_defn (Class_defns of a package / module / class)
//     and into gen_scope arrays, so class- and generate-scoped localparams are
//     gridded too;
//   * VpiSigned on the actual, another field `typespec::Compare` reads.
//
// The VIEW is taken from the design vector the object was reached through
// (AllPackages / TopPackages / AllModules / TopModules / AllClasses), which
// both producers fill the same way; the census is still printed so a
// view-blind join can be made by cutting the first column.
//
// usage: ct187cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kd(const any* t) {
    return t ? std::string(UhdmName(t->UhdmType())) : "NULL";
}
static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
static std::string loc(const any* o) {
    return o ? std::to_string(o->VpiLineNo()) + ":" +
                   std::to_string(o->VpiColumnNo())
             : "-";
}
static std::string span(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo()) + "-" +
           std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}
static std::string full(const any* t) {
    if (!t) return "-";
    switch (t->UhdmType()) {
        case uhdmpackage: return std::string(((const package*)t)->VpiFullName());
        case uhdmclass_defn:
            return std::string(((const class_defn*)t)->VpiFullName());
        case uhdmmodule_inst:
            return std::string(((const module_inst*)t)->VpiFullName());
        case uhdminterface_inst:
            return std::string(((const interface_inst*)t)->VpiFullName());
        case uhdmprogram: return std::string(((const program*)t)->VpiFullName());
        case uhdmgen_scope:
            return std::string(((const gen_scope*)t)->VpiFullName());
        case uhdmfunction:
            return std::string(((const function*)t)->VpiFullName());
        case uhdmtask: return std::string(((const task*)t)->VpiFullName());
        default: return std::string(t->VpiName());
    }
}

static std::map<uint32_t, int> g_sharers;

static std::string tsDesc(const ref_typespec* rt) {
    if (!rt) return "NOREF";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "REF(<null-actual>)";
    std::string s = kd(a) + "(" + nm(a) + ")@" + span(a);
    const ref_typespec* al = a->Typedef_alias();
    if (al) {
        const typespec* at = al->Actual_typespec();
        s += "[alias->" +
             (at ? kd(at) + "(" + nm(at) + ")@" + span(at)
                 : std::string("<null>")) +
             "]";
    }
    else {
        s += "[noalias]";
    }
    int nr = -1;
    bool sgn = false;
    switch (a->UhdmType()) {
        case uhdmbit_typespec: {
            auto* r = ((const bit_typespec*)a)->Ranges();
            nr = r ? (int)r->size() : 0;
            break;
        }
        case uhdmlogic_typespec: {
            auto* r = ((const logic_typespec*)a)->Ranges();
            nr = r ? (int)r->size() : 0;
            break;
        }
        case uhdmint_typespec:
            nr = 0;
            sgn = ((const int_typespec*)a)->VpiSigned();
            break;
        case uhdmbyte_typespec:
            nr = 0;
            sgn = ((const byte_typespec*)a)->VpiSigned();
            break;
        case uhdmshort_int_typespec:
            nr = 0;
            sgn = ((const short_int_typespec*)a)->VpiSigned();
            break;
        case uhdmlong_int_typespec:
            nr = 0;
            sgn = ((const long_int_typespec*)a)->VpiSigned();
            break;
        case uhdminteger_typespec:
            nr = 0;
            sgn = ((const integer_typespec*)a)->VpiSigned();
            break;
        default: break;
    }
    s += " rg=" + std::to_string(nr) + " sgn=" + std::to_string((int)sgn);
    s += " apar=" + kd(a->VpiParent());
    s += " inst=" + (a->Instance() ? kd(a->Instance()) : std::string("-"));
    s += " nsh=" +
         std::to_string(g_sharers.count(a->UhdmId()) ? g_sharers[a->UhdmId()]
                                                     : 0);
    return s;
}

static void emit(const std::string& view, const any* owner,
                 const parameter* p) {
    std::cout << view << "\t" << full(owner) << "\t" << nm(p) << "\t" << loc(p)
              << "\t" << (p->VpiLocalParam() ? "LOCAL" : "PARAM") << "\t"
              << tsDesc(p->Typespec()) << "\n";
}

template <typename V>
static void scanParams(const std::string& view, const any* owner, V* v) {
    if (!v) return;
    for (auto* x : *v)
        if (x && x->UhdmType() == uhdmparameter)
            emit(view, owner, (const parameter*)x);
}

static void scanClass(const std::string& view, const class_defn* c);

static void scanClass(const std::string& view, const class_defn* c) {
    if (!c) return;
    scanParams(view, c, c->Parameters());
    if (c->Task_funcs())
        for (auto* tf : *c->Task_funcs())
            scanParams(view + ".TF", tf, tf->Parameters());
}

static void scanInst(const std::string& view, const instance* in) {
    if (!in) return;
    scanParams(view, in, in->Parameters());
    if (in->Task_funcs())
        for (auto* tf : *in->Task_funcs())
            scanParams(view + ".TF", tf, tf->Parameters());
    if (in->Class_defns())
        for (auto* c : *in->Class_defns()) scanClass(view + ".C", c);
}

static void scanScopeTree(const std::string& view, const scope* sc);

static void scanScopeTree(const std::string& view, const scope* sc) {
    if (!sc) return;
    scanParams(view, sc, sc->Parameters());
}

static void scanModule(const std::string& view, const module_inst* m) {
    scanInst(view, m);
    if (m->Gen_scope_arrays())
        for (auto* ga : *m->Gen_scope_arrays())
            if (ga->Gen_scopes())
                for (auto* g : *ga->Gen_scopes())
                    scanScopeTree(view + ".G", g);
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: ct187cen <file.uhdm> [tag]\n";
        return 2;
    }
    Serializer s;
    std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        std::cerr << "RESTORE-FAILED " << argv[1] << "\n";
        return 3;
    }
    design* d = (design*)((const uhdm_handle*)restored[0])->object;

    for (auto& it : s.AllObjects()) {
        const BaseClass* o = it.first;
        if (o && o->UhdmType() == uhdmref_typespec) {
            const typespec* a = ((const ref_typespec*)o)->Actual_typespec();
            if (a) g_sharers[a->UhdmId()]++;
        }
    }

    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) scanInst("DEFPKG", p);
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) scanInst("ELABPKG", p);
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) scanClass("DEFCLASS", c);
    if (d->AllModules())
        for (auto* m : *d->AllModules()) scanModule("DEFMOD", m);
    if (d->TopModules())
        for (auto* m : *d->TopModules()) scanModule("ELABMOD", m);
    if (d->AllInterfaces())
        for (auto* m : *d->AllInterfaces()) scanInst("DEFIFC", m);
    if (d->AllPrograms())
        for (auto* m : *d->AllPrograms()) scanInst("DEFPRG", m);
    return 0;
}
