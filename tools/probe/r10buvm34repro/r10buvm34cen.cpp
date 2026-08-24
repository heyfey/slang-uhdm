// r10buvm34 — THE FOREACH LOOP-VARIABLE census.  MEASUREMENT ONLY; nothing
// here is an acceptance judge (uhdm-cmp and scripts/verify_golden.py are).
//
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// ONE family, `FELV` — one row per (foreach_stmt, loop-variable SLOT).  The
// slot index is part of the key so the `[i,j]` and `[,j]` arities join
// position by position and a skipped slot (Surelog's `vpiNullOp` operation)
// is a row of its own rather than a hole.
//
// KEY   = HOME + the foreach_stmt's SPAN + SLOT + the loop variable's NAME.
//         The loop variable's KIND and TYPESPEC are exactly what the two
//         producers disagree about, so they are PAYLOAD and never key
//         (buvm33's rule: a name in the key hides a disagreement as a
//         MISSING/EXTRA pair).  The ARRAY reference's kind and name are
//         payload too — buvm33 moved them, and a change there must not
//         re-key this census.
// HOME  = nearest enclosing function / task / class_defn / package /
//         module_inst as `<kind>:<fullname>`.
// SPLIT columns (payload, the brief's question-1 axes):
//   ASCOPED  Y when the array reference's VpiName carries a `::`
//   AKIND    the array reference object's UHDM kind (class_var after
//            § foreachScopedArrayWrittenClassVar33, hier_path for a dotted
//            reference, ref_var for a plain unresolved one, ...)
//   ATS      the array reference's ACTUAL typespec `<kind>'<name>'@<span>`
//   ARITY    how many slots the loop list has, and NSKIP how many are
//            vpiNullOp placeholders
//   REACH    Y when reachable from a design root (buvm23: AllObjects counts
//            ORPHANS, which the judge never sees)
//
// usage: r10buvm34cen <file.uhdm> [tag]
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
// The ACTUAL typespec behind an object, as `<kind>'<name>'@<span>`; read
// through `ref_typespec::Actual_typespec`, never the ref_typespec itself.
static std::string tsOf(const any* o) {
    const ref_typespec* rt = nullptr;
    if (const variables* v = any_cast<const variables*>(o)) rt = v->Typespec();
    else if (const expr* e = any_cast<const expr*>(o)) rt = e->Typespec();
    if (!rt) return "-";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "ref_typespec'<null>'@-";
    return kd(a) + "'" + esc(std::string(a->VpiName())) + "'@" + span(a);
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: r10buvm34cen <file.uhdm> [tag]\n";
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
    auto ownerOf = [&](const any* o, bool& reach) -> const any* {
        const any* owner = nullptr;
        const any* p = o->VpiParent();
        int d = 0;
        reach = false;
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
        return owner;
    };
    long n = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmforeach_stmt) continue;
        const foreach_stmt* fs = (const foreach_stmt*)o;
        const any* av = fs->Variable();
        bool reach = false;
        const any* owner = ownerOf(o, reach);
        std::string anm = av ? std::string(av->VpiName()) : std::string("-");
        VectorOfany* lv = fs->VpiLoopVars();
        size_t arity = lv ? lv->size() : 0;
        size_t nskip = 0;
        if (lv)
            for (auto* e : *lv)
                if (e && e->UhdmType() == uhdmoperation) nskip++;
        for (size_t i = 0; i < arity; i++) {
            const any* e = (*lv)[i];
            std::string lnm = e ? std::string(e->VpiName()) : std::string("-");
            if (e && e->UhdmType() == uhdmoperation) lnm = "<skip>";
            std::cout << tag << "\tFELV\t"
                      << (owner ? kd(owner) : std::string("-")) << ":"
                      << esc(fnm(owner)) << "\t" << span(o) << "\t" << i
                      << "\t" << esc(lnm)
                      << "\tlvkind=" << (e ? kd(e) : std::string("<none>"))
                      << "\tlvspan=" << span(e)
                      << "\tlvts=" << (e ? tsOf(e) : std::string("-"))
                      << "\takind=" << (av ? kd(av) : std::string("<none>"))
                      << "\taname=" << esc(anm)
                      << "\tascoped="
                      << (anm.find("::") != std::string::npos ? "Y" : "N")
                      << "\tats=" << (av ? tsOf(av) : std::string("-"))
                      << "\tarity=" << arity << "\tnskip=" << nskip
                      << "\treach=" << (reach ? "Y" : "N") << "\n";
            n++;
        }
        if (arity == 0) {
            std::cout << tag << "\tFELV\t"
                      << (owner ? kd(owner) : std::string("-")) << ":"
                      << esc(fnm(owner)) << "\t" << span(o) << "\t0\t<none>"
                      << "\tlvkind=<none>\tlvspan=-\tlvts=-"
                      << "\takind=" << (av ? kd(av) : std::string("<none>"))
                      << "\taname=" << esc(anm)
                      << "\tascoped="
                      << (anm.find("::") != std::string::npos ? "Y" : "N")
                      << "\tats=" << (av ? tsOf(av) : std::string("-"))
                      << "\tarity=0\tnskip=0"
                      << "\treach=" << (reach ? "Y" : "N") << "\n";
            n++;
        }
    }
    std::cerr << "ROWS " << tag << " FELV " << n << "\n";
    return 0;
}
