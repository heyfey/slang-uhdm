// r10uvm190 — THE PER-`param_assign` **Rhs-PRESENCE** CENSUS.
// MEASUREMENT ONLY; nothing here is an acceptance judge (the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` and `scripts/verify_golden.py` are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Derived from tools/probe/r10uvm187repro/ct187cen.cpp (the per-parameter
// typespec census), re-keyed onto the object this pass is about: every
// `param_assign` in a database, and whether it carries an `Rhs` at all.
//
// The KEY is the param_assign's identity — owner listing + Lhs name + the
// parameter's own span — and the PAYLOAD is COMPARE-VISIBLE Rhs state (kind,
// decompile, size, value, const type).  `VpiFullName` is NOT a field any
// generated `Compare` reads, so it is used only for the OWNER (a listing
// address), never as a payload field.
//
// The VIEW is the design vector the object was reached through and is printed
// as column 1 so a view-blind join can be made by cutting it — the two
// producers label the views differently and the recorded law is to keep the
// DEF/ELAB view OUT of the join key.  A package's two listings (AllPackages /
// TopPackages) are NEVER merged into one multiset (the recorded listcheck
// lesson): the view column distinguishes them and `score190.py` joins per view
// class.
//
// The MATRIX columns (the axes this pass's law is cut on) are computed here so
// the join can grid on them without re-deriving:
//   KIND   : UNTYPED | TYPED:<ts kind> | TDEF:<ts kind>  (a typespec that
//            carries a Typedef_alias is a typedef'd parameter)
//   LOC    : LOCAL | PARAM  (VpiLocalParam off the WRITTEN keyword)
//   HOME   : the owner's kind (package / module_inst / class_defn / function …)
//   LIST   : which listing vector the param_assign was found in
//   CONS   : CONSUMED | UNCONSUMED — is there any OTHER object in the database
//            whose edges land on this param_assign's Rhs (a shared/copied
//            constant), i.e. is the Rhs read by something else
//
// SECOND SECTION — `TDC`, the per-declaration TYPEDEF-ALIAS CLONE census this
// pass's law is cut on.  Every typespec carrying a `Typedef_alias` is a clone
// Surelog made of a typedef's own typespec at a use site; the row's PAYLOAD is
// the SHAPE of its packed-range bounds, and for every reference inside them
// whether it is BOUND (carries a `vpiActual`) or BARE.  Walked FLAT over
// `Serializer::AllObjects()` — most of these clones hang off a `Base_typespec`
// or an `Elem_typespec` ref and no per-kind recursion reaches them all.
//
// Rows are a MULTISET: one typedef gives many identical clones (BuildUVMPkg's
// `uvm_field_flag_t` gives thirty), so `score190.py` joins with counts and a
// last-writer dict would drop rows.
//
// usage: ct190cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <map>
#include <set>
#include <cstdlib>
#include <string>
#include <vector>
using namespace UHDM;

static std::string kd(const any* t) {
    return t ? std::string(UhdmName(t->UhdmType())) : "NULL";
}
static std::string nm(const any* t) { return t ? std::string(t->VpiName()) : "-"; }
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

// Every object id that is referenced by SOME edge other than its own
// param_assign's Rhs — filled by a flat pre-pass.
static std::map<uint32_t, int> g_inbound;

static std::string escape(const std::string& s) {
    std::string o;
    for (char c : s) {
        if (c == '\t') o += "\\t";
        else if (c == '\n') o += "\\n";
        else o += c;
    }
    return o.empty() ? "-" : o;
}

// The parameter's declared-type axis, read off its ref_typespec.
static std::string kindOf(const parameter* p) {
    if (!p) return "NOPARAM";
    const ref_typespec* rt = p->Typespec();
    if (!rt) return "UNTYPED";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "UNTYPED";
    std::string k = kd(a);
    if (a->Typedef_alias()) return "TDEF:" + k;
    return "TYPED:" + k;
}

// COMPARE-VISIBLE Rhs state.  `expr::Compare` reads VpiDecompile and VpiSize;
// `constant::Compare` adds VpiConstType.  VpiValue is read by NO generated
// Compare (r10uvm188 § 1.1) but is printed because it is the same
// Surelog::Value the size comes from and a half-read payload makes the next
// census unreadable.
static std::string rhsDesc(const param_assign* pa) {
    const any* r = pa->Rhs();
    if (!r) return "RHS=NONE";
    std::string s = "RHS=" + kd(r);
    if (const expr* e = any_cast<const expr*>(r)) {
        s += " dec=" + escape(std::string(e->VpiDecompile()));
        s += " sz=" + std::to_string(e->VpiSize());
        s += " val=" + escape(std::string(e->VpiValue()));
    }
    if (const constant* c = any_cast<const constant*>(r))
        s += " ct=" + std::to_string(c->VpiConstType());
    s += " nin=" +
         std::to_string(g_inbound.count(r->UhdmId()) ? g_inbound[r->UhdmId()]
                                                     : 0);
    return s;
}

static std::string g_tag = "-";

static void emit(const std::string& view, const std::string& list,
                 const any* owner, const param_assign* pa) {
    const any* l = pa->Lhs();
    const parameter* p =
        (l && l->UhdmType() == uhdmparameter) ? (const parameter*)l : nullptr;
    std::cout << g_tag << "\tPA\t" << view << "\t" << list << "\t" << kd(owner) << "\t"
              << full(owner) << "\t" << nm(l) << "\t" << kd(l) << "\t"
              << span(l) << "\t"
              << (p ? (p->VpiLocalParam() ? "LOCAL" : "PARAM") : "NOLHS")
              << "\t" << (p ? kindOf(p) : std::string("NOLHS")) << "\t"
              << span(pa) << "\t" << rhsDesc(pa) << "\n";
}

// The Compare-visible shape of one range bound.
static std::string boundDesc(const any* n) {
    if (!n) return "-";
    switch (n->UhdmType()) {
        case uhdmconstant: {
            auto* c = (const constant*)n;
            return "const(" + escape(std::string(c->VpiDecompile())) + "," +
                   std::to_string(c->VpiSize()) + "," +
                   escape(std::string(c->VpiValue())) + "," +
                   std::to_string(c->VpiConstType()) + ")";
        }
        case uhdmref_obj: {
            auto* r = (const ref_obj*)n;
            return "ref(" + std::string(r->VpiName()) + "," +
                   (r->Actual_group() ? "BOUND:" + kd(r->Actual_group())
                                      : std::string("BARE")) +
                   ")";
        }
        case uhdmoperation: {
            auto* o = (const operation*)n;
            std::string s2 = "op(" + std::to_string(o->VpiOpType()) + ",dec=" +
                             escape(std::string(o->VpiDecompile())) + ",sz=" +
                             std::to_string(o->VpiSize()) + ",[";
            if (auto* ops = o->Operands())
                for (size_t i = 0; i < ops->size(); ++i)
                    s2 += (i ? "|" : "") + boundDesc(ops->at(i));
            return s2 + "])";
        }
        default: return kd(n);
    }
}

static const VectorOfrange* rangesOfTs(const typespec* t) {
    switch (t->UhdmType()) {
        case uhdmbit_typespec: return ((const bit_typespec*)t)->Ranges();
        case uhdmlogic_typespec: return ((const logic_typespec*)t)->Ranges();
        case uhdmarray_typespec: return ((const array_typespec*)t)->Ranges();
        case uhdmpacked_array_typespec:
            return ((const packed_array_typespec*)t)->Ranges();
        default: return nullptr;
    }
}

static void emitTdc(const typespec* t, const char* sect) {
    const ref_typespec* al = t->Typedef_alias();
    const typespec* tgt = al ? al->Actual_typespec() : nullptr;
    std::string payload;
    const VectorOfrange* rv = rangesOfTs(t);
    if (!rv) payload = "RANGES=NONE";
    else {
        payload = "RANGES=" + std::to_string(rv->size());
        for (auto* r : *rv)
            payload += " {L=" + boundDesc(r->Left_expr()) +
                       " R=" + boundDesc(r->Right_expr()) + "}";
    }
    std::cout << g_tag << "\t" << sect << "\t" << kd(t) << "\t" << nm(t) << "\t"
              << span(t) << "\t" << kd(tgt) << "\t" << nm(tgt) << "\t"
              << span(tgt) << "\t"
              << (t->Instance() ? kd(t->Instance()) : std::string("-")) << "\t"
              << payload << "\n";
}

template <typename V>
static void scanPas(const std::string& view, const std::string& list,
                    const any* owner, V* v) {
    if (!v) return;
    for (auto* x : *v)
        if (x) emit(view, list, owner, x);
}

static void scanClass(const std::string& view, const class_defn* c);

static void scanClass(const std::string& view, const class_defn* c) {
    if (!c) return;
    scanPas(view, "class_defn.Param_assigns", c, c->Param_assigns());
    if (c->Task_funcs())
        for (auto* tf : *c->Task_funcs())
            scanPas(view + ".TF", "task_func.Param_assigns", tf,
                    tf->Param_assigns());
}

static void scanInst(const std::string& view, const instance* in) {
    if (!in) return;
    scanPas(view, "instance.Param_assigns", in, in->Param_assigns());
    if (in->Task_funcs())
        for (auto* tf : *in->Task_funcs())
            scanPas(view + ".TF", "task_func.Param_assigns", tf,
                    tf->Param_assigns());
    if (in->Class_defns())
        for (auto* c : *in->Class_defns()) scanClass(view + ".C", c);
}

static void scanScopeTree(const std::string& view, const scope* sc) {
    if (!sc) return;
    scanPas(view, "scope.Param_assigns", sc, sc->Param_assigns());
}

static void scanModule(const std::string& view, const module_inst* m) {
    scanInst(view, m);
    if (m->Gen_scope_arrays())
        for (auto* ga : *m->Gen_scope_arrays())
            if (ga->Gen_scopes())
                for (auto* g : *ga->Gen_scopes()) scanScopeTree(view + ".G", g);
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: ct190cen <file.uhdm> [tag]\n";
        return 2;
    }
    Serializer s;
    std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        std::cerr << "RESTORE-FAILED " << argv[1] << "\n";
        return 3;
    }
    if (argc > 2) g_tag = argv[2];
    design* d = (design*)((const uhdm_handle*)restored[0])->object;

    // The inbound pre-pass is O(objects x 2100) and only fills the PA rows'
    // diagnostic `nin` column, which no generated Compare reads.  It is OFF by
    // default so the corpus-wide census is affordable; both sides are censused
    // by the SAME binary with the SAME setting, so the join stays symmetric.
    if (getenv("R10U190_NIN"))
    // Flat inbound-edge pre-pass: every edge of every object, EXCLUDING a
    // param_assign's own Rhs edge, so `nin` counts CONSUMERS of the Rhs and not
    // the owner itself.  `GetByVpiType` is the generated, kind-agnostic edge
    // accessor, so no field is named by hand and no edge is missed by omission.
    for (auto& it : s.AllObjects()) {
        const BaseClass* o = it.first;
        if (!o) continue;
        const param_assign* pa = any_cast<const param_assign*>(o);
        const any* own = pa ? pa->Rhs() : nullptr;
        for (int t = 1; t <= 2100; ++t) {
            auto tup = o->GetByVpiType(t);
            const BaseClass* one = std::get<0>(tup);
            const std::vector<const BaseClass*>* vec = std::get<2>(tup);
            if (one && one != own) g_inbound[one->UhdmId()]++;
            if (vec)
                for (auto* e : *vec)
                    if (e && e != own) g_inbound[e->UhdmId()]++;
        }
    }

    // FLAT total, so a structured walk that misses a listing is visible.
    long flat = 0;
    for (auto& it : s.AllObjects())
        if (it.first && it.first->UhdmType() == uhdmparam_assign) ++flat;
    std::cerr << "FLAT-param_assign-count " << flat << " " << argv[1] << "\n";

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

    // TDC — flat, so a clone reached only through a Base_typespec ref is seen.
    for (auto& it : s.AllObjects()) {
        const BaseClass* o = it.first;
        if (!o) continue;
        const typespec* t = any_cast<const typespec*>(o);
        if (t && t->Typedef_alias()) emitTdc(t, "TDC");
    }
    // TDCE — the ENUM-BASE clones only, the exact population
    // § enumBaseTdCloneDanglingRange190 writes.  Reached from the enum, so the
    // clone POSITION is known and not inferred from a fan-in count.
    for (auto& it : s.AllObjects()) {
        const BaseClass* o = it.first;
        if (!o || o->UhdmType() != uhdmenum_typespec) continue;
        const ref_typespec* br = ((const enum_typespec*)o)->Base_typespec();
        const typespec* b = br ? br->Actual_typespec() : nullptr;
        if (b && b->Typedef_alias()) emitTdc(b, "TDCE");
    }
    return 0;
}
