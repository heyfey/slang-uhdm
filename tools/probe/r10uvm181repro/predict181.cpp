// r10uvm181 — THE MOVER PREDICTOR.  Reads ONE PRISTINE database and answers:
// would § cloneBodyIsAScopeEvenWithNoOwnLocals181 change anything here?
// MEASUREMENT ONLY; the official `uhdm-cmp` is the sole judge.
//
// The prediction must come from PRISTINE databases BEFORE the patched sweep
// (RESUME.md §7), so it cannot look at the patched output: it SIMULATES the
// predicate instead.  A cell moves exactly when all of these hold in OUR
// pristine database:
//
//   1. the reference (`ref_obj` / `ref_var` / `bit_select`) is BARE;
//   2. its enclosing subroutine has NEITHER an `Io_decls` entry NOR a
//      `Variables` entry of its own — the shape whose `lm9` is empty and whose
//      registration the guard skipped;
//   3. that subroutine is a WILDCARD-IMPORT CLONE — modelled as: it is listed
//      by a package that does NOT itself declare the class the method belongs
//      to (`A::b` under a package with no `class_defn` A), or, for a free
//      subroutine, the same name is listed by more than one package;
//   4. the innermost-out climb from the reference to the subroutine finds the
//      name — an enclosing `foreach_stmt`'s `VpiLoopVars` `ref_var` with a
//      non-null `vpiActual` (`loopVar37`), or an enclosing block's
//      `Variables` (`blockVar9`).
//
// Condition 3 is deliberately the loose half: over-predicting a DATABASE costs
// nothing (the gate requires every MOVER to have been named, not every name to
// move), while under-predicting one would hide a mover.
//
// build: g++ -O2 -std=c++17 predict181.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o predict181
// usage: predict181 <ours.uhdm> <label>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>

using namespace UHDM;

static const BaseClass* actualOf(const BaseClass* o) {
    if (auto* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const bit_select*>(o)) return r->Actual_group();
    return nullptr;
}
static bool isRef(const BaseClass* o) {
    auto t = o->UhdmType();
    return t == uhdmref_obj || t == uhdmref_var || t == uhdmbit_select;
}
static const BaseClass* blockVars(const BaseClass* b, std::string_view nm) {
    const VectorOfvariables* vs = nullptr;
    if (b->UhdmType() == uhdmbegin) vs = ((const begin*)b)->Variables();
    else if (b->UhdmType() == uhdmnamed_begin) vs = ((const named_begin*)b)->Variables();
    else if (b->UhdmType() == uhdmfork_stmt) vs = ((const fork_stmt*)b)->Variables();
    else if (b->UhdmType() == uhdmnamed_fork) vs = ((const named_fork*)b)->Variables();
    if (!vs) return nullptr;
    for (auto* v : *vs) if (v && v->VpiName() == nm) return v;
    return nullptr;
}
static const BaseClass* loopVar(const BaseClass* b, std::string_view nm) {
    if (b->UhdmType() != uhdmforeach_stmt) return nullptr;
    auto* lv = ((const foreach_stmt*)b)->VpiLoopVars();
    if (!lv) return nullptr;
    for (auto* v : *lv)
        if (v && v->UhdmType() == uhdmref_var && v->VpiName() == nm)
            return ((const ref_var*)v)->Actual_group();
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: predict181 <ours.uhdm> <label>\n"); return 2; }
    const std::string label = argv[2];
    Serializer S;
    if (S.Restore(std::string(argv[1])).empty()) { printf("%s RESTORE_FAIL\n", label.c_str()); return 3; }
    // package -> class names it declares; tf full name -> packages listing it
    std::map<const BaseClass*, std::set<std::string>> pkgClasses;
    std::map<std::string, std::set<const BaseClass*>> tfPkgs;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmpackage) continue;
        auto* p = (const package*)o;
        if (p->Class_defns())
            for (auto* c : *p->Class_defns())
                if (c) pkgClasses[o].insert(std::string(c->VpiName()));
        if (p->Task_funcs())
            for (auto* t : *p->Task_funcs())
                if (t) tfPkgs[std::string(t->VpiName())].insert(o);
    }
    long lv = 0, bv = 0;
    std::set<std::string> bodies;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || !isRef(o) || actualOf(o) || o->VpiName().empty()) continue;
        const std::string nm(o->VpiName());
        const task_func* tf = nullptr;
        const BaseClass* pkg = nullptr;
        for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
            if (!tf && (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask))
                tf = (const task_func*)p;
            if (p->UhdmType() == uhdmpackage) { pkg = p; break; }
        }
        if (!tf || !pkg) continue;
        if (tf->Io_decls() && !tf->Io_decls()->empty()) continue;
        if (tf->Variables() && !tf->Variables()->empty()) continue;
        // condition 3 — is this listing a CLONE?
        const std::string tn(tf->VpiName());
        bool clone = false;
        size_t cc = tn.find("::");
        if (cc != std::string::npos)
            clone = !pkgClasses[pkg].count(tn.substr(0, cc));
        else {
            auto it = tfPkgs.find(tn);
            clone = it != tfPkgs.end() && it->second.size() > 1;
        }
        if (!clone) continue;
        for (const BaseClass* a = o; a && a != (const BaseClass*)tf; a = a->VpiParent()) {
            if (loopVar(a, nm)) { lv++; bodies.insert(tn); break; }
            if (blockVars(a, nm)) { bv++; bodies.insert(tn); break; }
        }
    }
    printf("%s PREDICT loopvar=%ld blockvar=%ld bodies=%zu %s\n", label.c_str(),
           lv, bv, bodies.size(), (lv + bv) ? "MOVER" : "-");
    return 0;
}
