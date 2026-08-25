// r10uvm130 — THE REFERENCE-ACTUAL + IMPLICIT-NET CENSUS WITH THE CALL-CONTEXT
// AND DECLARATION-KIND COLUMNS (r10uvm117repro/ct117cen.cpp with three columns
// added).  MEASUREMENT ONLY; nothing here is an acceptance judge (the official
// uhdm-cmp and scripts/verify_golden.py are).
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
//   HOME   the KIND of the scope the owning task/func is DECLARED IN: CLS /
//          PKG / MOD / IFACE / PROG.  A FREE PACKAGE FUNCTION is (IB, PKG); an
//          IN-BODY class method is (IB, CLS); an out-of-body class method is
//          (OOB, CLS).
//   OWNER  task/func fullname (or the nearest named ancestor)
//   LC     <line>:<col>-<endline>:<endcol> of the REFERENCE
//   NM     the reference's own VpiName
//   ACT    the Actual_group's KIND ("NONE" when unbound)
//   ACTNM  the Actual_group's VpiName
//   PAR    the reference's vpiParent KIND
//   PARNM  the reference's vpiParent VpiName
//   ACTIMPL  IMPL when the Actual_group is an IMPLICIT MODULE WIRE (a logic_net
//          with vpiNetType 1 parented at a module_inst), "-" otherwise
//   NEWLHS NEWLHS when this reference is the FIRST element of a hier_path that
//          is the Lhs of an assignment whose Rhs is a `new` method_func_call
//   CTX    *** THE COLUMN THIS PASS EXISTS FOR ***  The EXPRESSION CONTEXT,
//          read by walking the reference's OWN vpiParent chain to its TOP and
//          asking what that top is:
//            NEWARG   the chain ends at an UNPARENTED `method_func_call` named
//                     `new` — the DYNAMIC-ARRAY `new[size](init)` argument
//                     list.  Surelog's CompileHelper::compileBlockingAssignment
//                     (CompileHelper.cpp:4482-4497) builds that call WITHOUT a
//                     VpiParent (the class `= new` arm at :4543 does set one),
//                     so both the compile-time bind walk
//                     (CompileHelper::bindVariable, CompileStmt.cpp:3089-3147)
//                     and the WRITE-TIME walk (UhdmWriter::lateBinding,
//                     UhdmWriter.cpp:3359-3360) die on the first hop.
//            RANDARG  the chain ends at an UNPARENTED `method_func_call` named
//                     `randomize` — CompileHelper::compileRandomizeCall
//                     (CompileStmt.cpp:3152-3175) has the same missing line.
//            CALLARG  the chain ends at any OTHER unparented call
//            ROOTED   the chain reaches a function/task/module/package/class
//            DANGLE   the chain ends unparented at something else
//          Both producers spell this identically: our own NewArray arm
//          (src/ExprEmit.cpp `case ExpressionKind::NewArray`) also leaves the
//          `method_func_call` named "new" unparented, by § newArray11.
//   TOPK   the kind of that chain top (readability; never a key on its own)
//
// The census ALSO emits, before the reference rows, one line per task/func
// LOCAL or FORMAL declaration:
//   <tag>\tRV\t<VIEW>\t<OOB>\t<HOME>\t<owner fullname>\t<name>     (ref_var only,
//          kept byte-compatible with ct117cen so § 117's joins still run)
//   <tag>\tLV\t<VIEW>\t<OOB>\t<HOME>\t<owner fullname>\t<name>\t<kind>\t<DECL>
//          for EVERY local/formal, with DECL = LOCAL (Variables) or
//          FORMAL (Io_decls), and the OWNER'S OWN SPAN as the last column, so a
//          NEWARG reference — whose vpiParent chain is dead and which therefore
//          has no owner column of its own — can be attributed to the subroutine
//          whose line range CONTAINS it.
//
// usage: ct130cen <file.uhdm> [tag]
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
    if (argc < 2) { std::cerr << "usage: ct130cen <file.uhdm> [tag]\n"; return 2; }
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
    auto homeOf = [](const any* owner) {
        if (!owner) return std::string("-");
        if (owner->UhdmType() != uhdmfunction && owner->UhdmType() != uhdmtask)
            return std::string("-");
        const any* p = owner->VpiParent();
        for (int d = 0; p && d < 300; ++d, p = p->VpiParent()) {
            switch (p->UhdmType()) {
                case uhdmclass_defn:  return std::string("CLS");
                case uhdmpackage:     return std::string("PKG");
                case uhdmmodule_inst: return std::string("MOD");
                case uhdminterface_inst: return std::string("IFACE");
                case uhdmprogram:     return std::string("PROG");
                case uhdmdesign:      return std::string("OTHER");
                default: break;
            }
        }
        return std::string("OTHER");
    };
    // THE CONTEXT COLUMN.  Walk the reference's OWN parent chain to its TOP and
    // classify what the chain ends on.  A chain that ENDS (no VpiParent) on a
    // `method_func_call` is exactly what makes Surelog's two bind walks fail.
    auto ctxOf = [&](const any* o, std::string* topk) {
        const any* p = o->VpiParent();
        const any* last = nullptr;
        int d = 0;
        while (p && d++ < 300) {
            UHDM_OBJECT_TYPE pt = p->UhdmType();
            if (pt == uhdmfunction || pt == uhdmtask || pt == uhdmmodule_inst ||
                pt == uhdmpackage || pt == uhdmclass_defn || pt == uhdmdesign ||
                pt == uhdmbegin || pt == uhdmnamed_begin) {
                *topk = kd(p);
                return std::string("ROOTED");
            }
            last = p;
            p = p->VpiParent();
        }
        if (!last) { *topk = "-"; return std::string("DANGLE"); }
        *topk = kd(last);
        if (last->UhdmType() == uhdmmethod_func_call ||
            last->UhdmType() == uhdmfunc_call ||
            last->UhdmType() == uhdmmethod_task_call ||
            last->UhdmType() == uhdmtask_call) {
            std::string nm(last->VpiName());
            if (nm == "new") return std::string("NEWARG");
            if (nm == "randomize") return std::string("RANDARG");
            return std::string("CALLARG");
        }
        return std::string("DANGLE");
    };
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
                  << "\t" << oobOf(owner) << "\t" << homeOf(owner) << "\t"
                  << esc(fnm(owner)) << "\t"
                  << esc(std::string(o->VpiName())) << "\n";
    }
    // LV rows: EVERY task/func local (Variables) and formal (Io_decls), with the
    // DECLARATION OBJECT'S KIND.  This is the axis § oobRefVarLocalHoistNet107's
    // `ref_var` conjunct keys on, and the one this pass's population sits OUTSIDE
    // of (int_var / bit_var / array_var / class_var …).
    auto lvDump = [&](const any* ownr, const VectorOfany* v, const char* dk) {
        if (!v) return;
        const any *owner = nullptr, *root = nullptr;
        walk(ownr, &owner, &root);
        std::string view = root ? rootView[root] : std::string("OTHER");
        for (auto* d : *v) {
            if (!d || retVars.count(d)) continue;
            std::cout << tag << "\tLV\t" << view << "\t" << oobOf(ownr) << "\t"
                      << homeOf(ownr) << "\t" << esc(fnm(ownr)) << "\t"
                      << esc(std::string(d->VpiName())) << "\t" << kd(d)
                      << "\t" << dk << "\t" << span(ownr) << "\n";
        }
    };
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmfunction) {
            const function* f = (const function*)o;
            lvDump(o, (const VectorOfany*)f->Variables(), "LOCAL");
            lvDump(o, (const VectorOfany*)f->Io_decls(), "FORMAL");
        } else if (o->UhdmType() == uhdmtask) {
            const task* f = (const task*)o;
            lvDump(o, (const VectorOfany*)f->Variables(), "LOCAL");
            lvDump(o, (const VectorOfany*)f->Io_decls(), "FORMAL");
        }
    }
    // BLOCK LOCALS.  `int n;` written inside a `begin ... end` is in the
    // BLOCK's Variables(), not the subroutine's -- and two of this pass's six
    // corpus sites (uvm_reg_map.svh:1427 and :1491, both `n`) name exactly
    // such a local.  The row is attributed to the ENCLOSING task/func (so the
    // OOB/HOME columns are the subroutine's) but keeps the BLOCK's own span,
    // which is the range that actually contains the reference.
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        const VectorOfvariables* bv = nullptr;
        if (o->UhdmType() == uhdmbegin) bv = ((const begin*)o)->Variables();
        else if (o->UhdmType() == uhdmnamed_begin) bv = ((const named_begin*)o)->Variables();
        else continue;
        if (!bv) continue;
        const any *owner = nullptr, *root = nullptr;
        walk(o, &owner, &root);
        if (!owner || (owner->UhdmType() != uhdmfunction &&
                       owner->UhdmType() != uhdmtask)) continue;
        std::string view = root ? rootView[root] : std::string("OTHER");
        for (auto* d : *bv) {
            if (!d) continue;
            std::cout << tag << "\tLV\t" << view << "\t" << oobOf(owner) << "\t"
                      << homeOf(owner) << "\t" << esc(fnm(owner)) << "\t"
                      << esc(std::string(d->VpiName())) << "\t" << kd(d)
                      << "\tBLOCK\t" << span(o) << "\n";
        }
    }
    // NET rows: every net owned by a module_inst.
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
        std::string actimpl = "-";
        if (act && act->UhdmType() == uhdmlogic_net &&
            ((const net*)act)->VpiNetType() == 1 && act->VpiParent() &&
            act->VpiParent()->UhdmType() == uhdmmodule_inst)
            actimpl = "IMPL";
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
        std::string topk = "-";
        std::string ctx = ctxOf(o, &topk);
        std::cout << tag << "\tREF\t" << (root ? rootView[root] : std::string("OTHER"))
                  << "\t" << oobOf(owner) << "\t" << homeOf(owner) << "\t"
                  << esc(fnm(owner)) << "\t"
                  << span(o) << "\t" << esc(std::string(o->VpiName())) << "\t"
                  << kd(act) << "\t"
                  << (act ? esc(std::string(act->VpiName())) : std::string("-"))
                  << "\t" << kd(par) << "\t"
                  << (par ? esc(std::string(par->VpiName())) : std::string("-"))
                  << "\t" << actimpl << "\t" << newlhs
                  << "\t" << ctx << "\t" << topk
                  << "\n";
    }
    return 0;
}
