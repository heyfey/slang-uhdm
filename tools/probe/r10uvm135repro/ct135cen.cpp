// r10uvm135 — THE ASSOCIATIVE-INDEX-NAME CENSUS.
// MEASUREMENT ONLY.  Nothing here is an acceptance judge: the official
// `uhdm-cmp` (~/git-repos/UHDM/build/bin/uhdm-cmp) and scripts/verify_golden.py
// are the authorities.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// The family is § assocIdxNameHoistNet135: an associative-array dimension whose
// INDEX TYPE is written as a NAME (`bit a[uvm_phase]`) is compiled by Surelog as
// a constant_expression -- an EXPRESSION -- so it mints a `ref_obj`, registers it
// for late binding, and (in the elaborated listing, where `compileTypespec`
// succeeds) then THROWS THE RANGE AND THE REFERENCE AWAY.  The discarded
// reference still mints the module's implicit wire.  A type KEYWORD
// (`[string]`, `[int]`, `[*]`) never takes that road at all.
//
// So a database spells the family in TWO shapes, and BOTH producers spell BOTH:
//   SIZE  a `ref_obj` that is operand 0 of an `operation` vpiOpType vpiSubOp
//         whose parent is a `range` -- the `<name> - 1` decrement.  It is the
//         shape that can carry an Actual_group, and the only one the judge can
//         see bound.
//   PROM  a `range` whose Right_expr is a `constant` valued
//         `STRING:associative` and whose ref_typespec's actual typespec has a
//         NON-EMPTY VpiName -- the PROMOTED form.  Its Surelog-side reference is
//         orphaned; nothing in the database points at it, so the row exists to
//         say WHICH NAME the site would hoist, not to be joined on an actual.
//
// Rows (tab separated), one per line:
//   <tag> NET  <view> IMPL|OTH <module fullname> <span> <name> <kind> <netType>
//   <tag> AIDX <view> SIZE|PROM <OOB|IB|-> <CLS|PKG|MOD|...> <owner> <span>
//              <name> <actual kind> <IMPL|->
// `view` is the design collection the object's parent chain reaches
// (ELABPKG / DEFPKG / TOPMOD / DEFMOD / DEFCLASS / ... / OTHER); rows whose
// chain reaches no collection read OTHER, and the WEAKLY-REFERENCED tail lands
// there too -- keep the view OUT of any key that must join across producers
// (RESUME §9) and use it only to read a row.
//
// usage: ct135cen <file.uhdm> [tag]
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
    for (auto& c : s)
        if (c == '\t' || c == '\n') c = ' ';
    return s.empty() ? std::string("-") : s;
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
    if (const scope* sc = any_cast<const scope*>(t)) {
        std::string f(sc->VpiFullName());
        if (!f.empty()) return f;
    }
    return std::string(t->VpiName());
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "usage: ct135cen <file.uhdm> [tag]\n";
        return 2;
    }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        std::cout << "RESTORE_FAIL\t" << tag << "\n";
        return 3;
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
    auto walk = [&](const any* o, const any** owner, const any** root) {
        *owner = nullptr;
        *root = nullptr;
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
    auto homeOf = [](const any* owner) {
        if (!owner) return std::string("-");
        if (owner->UhdmType() != uhdmfunction && owner->UhdmType() != uhdmtask)
            return std::string("-");
        const any* p = owner->VpiParent();
        for (int d = 0; p && d < 300; ++d, p = p->VpiParent()) {
            switch (p->UhdmType()) {
                case uhdmclass_defn:     return std::string("CLS");
                case uhdmpackage:        return std::string("PKG");
                case uhdmmodule_inst:    return std::string("MOD");
                case uhdminterface_inst: return std::string("IFACE");
                case uhdmprogram:        return std::string("PROG");
                case uhdmdesign:         return std::string("OTHER");
                default: break;
            }
        }
        return std::string("OTHER");
    };
    auto viewOf = [&](const any* o) {
        const any *owner = nullptr, *root = nullptr;
        walk(o, &owner, &root);
        return root ? rootView[root] : std::string("OTHER");
    };
    auto emitAidx = [&](const any* anchor, const char* shape,
                        const std::string& nm, const any* act) {
        const any *owner = nullptr, *root = nullptr;
        walk(anchor, &owner, &root);
        std::string actimpl = "-";
        if (act && act->UhdmType() == uhdmlogic_net &&
            ((const net*)act)->VpiNetType() == 1 && act->VpiParent() &&
            act->VpiParent()->UhdmType() == uhdmmodule_inst)
            actimpl = "IMPL";
        std::cout << tag << "\tAIDX\t"
                  << (root ? rootView[root] : std::string("OTHER")) << "\t"
                  << shape << "\t" << oobOf(owner) << "\t" << homeOf(owner)
                  << "\t" << esc(fnm(owner)) << "\t" << span(anchor) << "\t"
                  << esc(nm) << "\t" << kd(act) << "\t" << actimpl << "\n";
    };
    // NET rows.
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmmodule_inst) continue;
        const module_inst* mi = (const module_inst*)o;
        std::string view = viewOf(o);
        auto it = rootView.find(o);
        if (it != rootView.end()) view = it->second;
        if (auto* nv = mi->Nets())
            for (auto* n : *nv) {
                if (!n) continue;
                std::cout << tag << "\tNET\t" << view << "\t"
                          << (n->UhdmType() == uhdmlogic_net &&
                                      n->VpiNetType() == 1
                                  ? "IMPL"
                                  : "OTH")
                          << "\t" << esc(std::string(mi->VpiFullName())) << "\t"
                          << span(n) << "\t" << esc(std::string(n->VpiName()))
                          << "\t" << kd(n) << "\t" << n->VpiNetType() << "\n";
            }
    }
    // AIDX SIZE rows -- the `<name> - 1` decrement's ref_obj.
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmref_obj) continue;
        const any* par = o->VpiParent();
        if (!par || par->UhdmType() != uhdmoperation) continue;
        if (((const operation*)par)->VpiOpType() != vpiSubOp) continue;
        const any* gp = par->VpiParent();
        if (!gp || gp->UhdmType() != uhdmrange) continue;
        auto* ops = ((const operation*)par)->Operands();
        if (!ops || ops->empty() || ops->at(0) != o) continue;
        emitAidx(o, "SIZE", std::string(o->VpiName()),
                 ((const ref_obj*)o)->Actual_group());
    }
    // AIDX PROM rows -- the promoted `[UINT:0 : STRING:associative]` range whose
    // index typespec carries a NAME (a class / typedef / enum name written in
    // the brackets); a type KEYWORD leaves that name empty and is NOT the family.
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmrange) continue;
        const expr* re = ((const range*)o)->Right_expr();
        if (!re || re->UhdmType() != uhdmconstant) continue;
        if (std::string(((const constant*)re)->VpiValue()) != "STRING:associative")
            continue;
        const ref_typespec* rt = ((const constant*)re)->Typespec();
        if (!rt) continue;
        const typespec* ats = rt->Actual_typespec();
        if (!ats) continue;
        std::string nm(ats->VpiName());
        if (nm.empty()) continue;
        // Surelog names a class typespec `uvm_phase`, a typedef `myint`; a
        // package-qualified spelling reaches us as written.  Strip nothing.
        emitAidx(o, "PROM", nm, nullptr);
    }
    return 0;
}
