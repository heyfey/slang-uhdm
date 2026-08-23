// r10uvm107 — THE REFERENCE-ACTUAL CENSUS.  MEASUREMENT ONLY; nothing here is
// an acceptance judge (the official uhdm-cmp and scripts/verify_golden.py are).
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// One row per `ref_obj`, keyed on what BOTH sides can spell: the listing VIEW,
// whether the owning task/func is an OUT-OF-BODY definition, the owner's
// fullname and the reference's own LINE:COL span.  Our expression nodes carry
// an EMPTY VpiFile (buvm16's trap), so the file is never part of the key.
//
// Columns (tab separated)
//   TAG    the caller's tag (G / O)
//   REF    literal row kind
//   VIEW   DEFCLASS / DEFPKG / ELABPKG / TOPMOD / DEFMOD / ...
//   OOB    OOB when the owning task/func's VpiName contains "::" (Surelog
//          names an OUT-OF-BODY definition `cls::meth`), IB otherwise, "-"
//          when there is no task/func owner
//   OWNER  task/func fullname (or the nearest named ancestor)
//   LC     <line>:<col>-<endline>:<endcol> of the REFERENCE
//   NM     the reference's own VpiName (readability + the RV join, never a
//          span key on its own)
//   ACT    the Actual_group's KIND ("NONE" when unbound)
//   ACTNM  the Actual_group's VpiName
//   PAR    the reference's vpiParent KIND
//   PARNM  the reference's vpiParent VpiName
//   ACTIMPL  IMPL when the Actual_group is an IMPLICIT MODULE WIRE (a logic_net
//          with vpiNetType 1 parented at a module_inst), "-" otherwise
//   NEWLHS NEWLHS when this reference is the FIRST element of a hier_path that
//          is the Lhs of an assignment whose Rhs is a `new` method_func_call --
//          the `p = new(...)` lvalue shape, spelled identically on both sides
//
// The census ALSO emits, before the reference rows, one line per `ref_var`
// DECLARATION that is a task/func LOCAL:
//   <tag>\tRV\t<VIEW>\t<OOB>\t<owner fullname>\t<name>
// so a reader can ask "is this reference naming a `ref_var` local of an
// out-of-body method?" -- the population § oobRefVarLocalHoistNet107 moves --
// without re-reading the source.
//
// usage: r10uvm109cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;

static std::string kd(const any* t) {
    return t ? std::string(UhdmName(t->UhdmType())) : std::string("NONE");
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
    if (argc < 2) { std::cerr << "usage: r10uvm109cen <file.uhdm> [tag]\n"; return 2; }
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
    // The owner walk, shared by both row kinds.
    auto walk = [&](const any* o, const any** owner, const any** root) {
        *owner = nullptr; *root = nullptr;
        const any* p = o->VpiParent();
        int d = 0;
        while (p && d++ < 300) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (!*owner && (pt == uhdmfunction || pt == uhdmtask)) *owner = p;
            auto it = rootView.find(p);
            if (it != rootView.end()) { *root = p; break; }
            if (pt == uhdmdesign) break;
            if (!*owner && (pt == uhdmmodule_inst || pt == uhdmpackage)) *owner = p;
            p = p->VpiParent();
        }
    };
    auto oobOf = [](const any* owner) {
        if (!owner) return std::string("-");
        if (owner->UhdmType() != uhdmfunction && owner->UhdmType() != uhdmtask)
            return std::string("-");
        std::string on(owner->VpiName());
        return std::string(on.find("::") != std::string::npos ? "OOB" : "IB");
    };
    // The RETURN variable of every function, so a return name is never counted
    // as a body local.
    std::set<const any*> retVars;
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmfunction)
            if (auto* r = ((const function*)kv.first)->Return()) retVars.insert(r);

    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmref_var || retVars.count(o)) continue;
        const any *owner = nullptr, *root = nullptr;
        walk(o, &owner, &root);
        if (!owner || (owner->UhdmType() != uhdmfunction &&
                       owner->UhdmType() != uhdmtask))
            continue;
        std::cout << tag << "\tRV\t" << (root ? rootView[root] : std::string("OTHER"))
                  << "\t" << oobOf(owner) << "\t" << esc(fnm(owner)) << "\t"
                  << esc(std::string(o->VpiName())) << "\n";
    }
    // NET rows: every net owned by a module_inst, keyed on the OWNER module's
    // fullname, the net's own name and its span.  `IMPL` marks the shape this
    // pass is about -- a `logic_net` with vpiNetType 1 whose span lies in a
    // file that is NOT the module's own (an implicit wire minted for a
    // late-bound reference, UhdmWriter.cpp:3982-4004).
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmmodule_inst) continue;
        const module_inst* mi = (const module_inst*)o;
        auto it = rootView.find(o);
        std::string view = it != rootView.end() ? it->second : std::string("OTHER");
        if (auto* nv = mi->Nets()) for (auto* n : *nv) {
            if (!n) continue;
            std::cout << tag << "\tNET\t" << view << "\t"
                      << (n->UhdmType() == uhdmlogic_net &&
                          n->VpiNetType() == 1 ? "IMPL" : "OTH")
                      << "\t" << esc(std::string(mi->VpiFullName())) << "\t"
                      << span(n) << "\t" << esc(std::string(n->VpiName()))
                      << "\t" << kd(n) << "\t" << n->VpiNetType() << "\n";
        }
    }
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmref_obj) continue;
        const ref_obj* r = (const ref_obj*)o;
        const any *owner = nullptr, *root = nullptr;
        walk(o, &owner, &root);
        const any* act = r->Actual_group();
        const any* par = o->VpiParent();
        // ACTIMPL: the actual is an IMPLICIT MODULE WIRE -- a `logic_net` with
        // vpiNetType 1 whose vpiParent is a module_inst.  That, and not "the
        // actual is a logic_net", is the shape Surelog's late-binding mint
        // (UhdmWriter.cpp:3982-4004) and our hoisted-net pool both produce.
        std::string actimpl = "-";
        if (act && act->UhdmType() == uhdmlogic_net &&
            ((const net*)act)->VpiNetType() == 1 && act->VpiParent() &&
            act->VpiParent()->UhdmType() == uhdmmodule_inst)
            actimpl = "IMPL";
        // NEWLHS: this reference is the FIRST element of a hier_path that is the
        // Lhs of an assignment whose Rhs is a `new` method_func_call -- exactly
        // the `p = new(...)` lvalue shape of law classPropNewLhsNoHoist109,
        // spelled the same way in BOTH databases.
        std::string newlhs = "-";
        if (par && par->UhdmType() == uhdmhier_path) {
            const hier_path* hp = (const hier_path*)par;
            bool first = hp->Path_elems() && !hp->Path_elems()->empty() &&
                         hp->Path_elems()->at(0) == o;
            const any* gp = par->VpiParent();
            if (first && gp && gp->UhdmType() == uhdmassignment) {
                const assignment* asg = (const assignment*)gp;
                const any* rh = asg->Rhs();
                if ((asg->Lhs() == par || asg->Lhs() == o) && rh &&
                    rh->UhdmType() == uhdmmethod_func_call &&
                    rh->VpiName() == "new")
                    newlhs = "NEWLHS";
            }
        }
        std::cout << tag << "\tREF\t" << (root ? rootView[root] : std::string("OTHER"))
                  << "\t" << oobOf(owner) << "\t" << esc(fnm(owner)) << "\t"
                  << span(o) << "\t" << esc(std::string(o->VpiName())) << "\t"
                  << kd(act) << "\t"
                  << (act ? esc(std::string(act->VpiName())) : std::string("-"))
                  << "\t" << kd(par) << "\t"
                  << (par ? esc(std::string(par->VpiName())) : std::string("-"))
                  << "\t" << actimpl << "\t" << newlhs
                  << "\n";
    }
    return 0;
}
