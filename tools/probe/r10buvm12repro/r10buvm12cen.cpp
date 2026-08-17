// r10buvm12cen — THE CENSUS INSTRUMENT for the CALLEE-LINK family
// (`func_call::Function()` / `method_func_call::Function()` /
//  `task_call::Task()` / `method_task_call::Task()`).
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the acceptance judge.
// LHS is ALWAYS golden; this tool reads ONE database and tags its rows, so the
// caller joins golden rows against ours.
//
// Reads a .uhdm and prints, out of Serializer::AllObjects() (never dump TEXT),
// one row per tf_call:
//
//   TC <tag> key=<view>|<parent-chain kinds+names>|<kind>|<name>@<line:col>
//      lnk=<0|1> tgt=<kind>:<fullname>@<line:col> nargs=<n> scope=<0|1>
//      home=<kind(name) of the nearest class_defn/package ancestor>
//
// The KEY is ID-blind and ADDRESS-blind on purpose: it is the join key for
// cenjoin12.py, so two databases written by two different producers can be
// compared cell by cell.
//
// usage: r10buvm12cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string nm(const any* t) {
    if (!t) return "-";
    std::string n(t->VpiName());
    return n.empty() ? "<anon>" : n;
}
static std::string fn(const any* t) {
    if (!t) return "-";
    std::string n;
    if (auto* tf = dynamic_cast<const task_func*>(t)) n = std::string(tf->VpiFullName());
    if (n.empty()) n = std::string(t->VpiName());
    return n.empty() ? "<anon>" : n;
}
static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}
static std::string chainOf(const any* o) {
    std::string r;
    int guard = 0;
    for (const any* p = o ? o->VpiParent() : nullptr; p && guard < 14;
         p = p->VpiParent(), guard++) {
        if (!r.empty()) r += "<";
        r += std::string(UhdmName(p->UhdmType())) + "(" + nm(p) + ")";
    }
    return r.empty() ? "-" : r;
}
// the nearest class_defn ancestor's NAME, or "-"
static std::string clsOf(const any* o) {
    int guard = 0;
    for (const any* p = o ? o->VpiParent() : nullptr; p && guard < 24;
         p = p->VpiParent(), guard++)
        if (p->UhdmType() == uhdmclass_defn) return nm(p);
    return "-";
}
// The innermost enclosing task_func, and whether IT is an OUT-OF-BODY
// definition.  A UHDM database spells out-of-body-ness structurally: Surelog
// (and we) parent the DEFINITION listing at the PACKAGE in the def view and
// name it `<class>::<method>`, while an in-body method is parented at the
// class_defn.  A call with NO enclosing task_func at all is a class-PROPERTY
// initializer, and the law reaches those (eline=0).
static const any* enclTf(const any* o) {
    int guard = 0;
    for (const any* p = o ? o->VpiParent() : nullptr; p && guard < 24;
         p = p->VpiParent(), guard++) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmfunction || t == uhdmtask) return p;
        if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst)
            return nullptr;
    }
    return nullptr;
}
// the nearest class_defn / package / module ancestor -- the call's HOME
static std::string homeOf(const any* o) {
    int guard = 0;
    for (const any* p = o ? o->VpiParent() : nullptr; p && guard < 24;
         p = p->VpiParent(), guard++) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmmodule_inst)
            return std::string(UhdmName(t)) + "(" + nm(p) + ")";
    }
    return "-";
}
static std::string viewOf(const any* o, const std::map<const any*, std::string>& mv) {
    const any* last = o;
    int guard = 0;
    for (const any* p = o; p && guard < 40; p = p->VpiParent(), guard++) {
        if (p->UhdmType() == uhdmdesign) break;
        last = p;
        auto it = mv.find(p);
        if (it != mv.end()) return it->second;
    }
    auto it = mv.find(last);
    return it == mv.end() ? "OTHER" : it->second;
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm12cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : "T";
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cout << "RESTORE_FAIL " << tag << "\n"; return 3; }

    std::map<const any*, std::string> mv;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        auto* d = (const design*)o;
        if (auto* v = d->TopPackages()) for (auto* p : *v) mv[p] = "ELAB";
        if (auto* v = d->TopModules()) for (auto* p : *v) mv[p] = "ELAB";
        if (auto* v = d->AllPackages()) for (auto* p : *v) if (!mv.count(p)) mv[p] = "DEF";
        if (auto* v = d->AllModules()) for (auto* p : *v) if (!mv.count(p)) mv[p] = "DEF";
        if (auto* v = d->AllClasses()) for (auto* p : *v) if (!mv.count(p)) mv[p] = "DEF";
    }

    long n = 0, nl = 0;
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE ut = o->UhdmType();
        const any* tgt = nullptr;
        const any* scope = nullptr;
        const VectorOfany* args = nullptr;
        switch (ut) {
            case uhdmfunc_call: {
                auto* c = (const func_call*)o;
                tgt = c->Function(); scope = c->Scope(); args = c->Tf_call_args(); break; }
            case uhdmmethod_func_call: {
                auto* c = (const method_func_call*)o;
                tgt = c->Function(); scope = c->Scope(); args = c->Tf_call_args(); break; }
            case uhdmtask_call: {
                auto* c = (const task_call*)o;
                tgt = c->Task(); scope = c->Scope(); args = c->Tf_call_args(); break; }
            case uhdmmethod_task_call: {
                auto* c = (const method_task_call*)o;
                tgt = c->Task(); scope = c->Scope(); args = c->Tf_call_args(); break; }
            default: continue;
        }
        n++;
        if (tgt) nl++;
        const any* encl = enclTf(o);
        bool oobCaller = false;
        // THE ELAB VIEW HIDES OUT-OF-BODY-NESS IN THE PARENT (Surelog MOVES the
        // definition listing into the class_defn there -- uvm86), so the parent
        // test alone reads every ELAB out-of-body body as in-body.  The other
        // shadow is exact and view-independent: an out-of-body DEFINITION
        // listing carries vpiMethod 0 and no vpiAccessType, while an in-body
        // method listing carries vpiMethod 1 (our own TaskFuncEmit says so at
        // the site that writes them).  BOTH are recorded.
        bool enclMeth = false;
        if (encl) {
            const any* ep = encl->VpiParent();
            oobCaller = ep && ep->UhdmType() == uhdmpackage;
            if (auto* etf = dynamic_cast<const task_func*>(encl))
                enclMeth = etf->VpiMethod();
        }
        std::string row = "TC " + tag + " key=" + viewOf(o, mv) + "|" + chainOf(o) +
            "|" + std::string(UhdmName(ut)) + "|" + nm(o) + "@" + loc(o) +
            " lnk=" + (tgt ? "1" : "0") +
            " tgt=" + (tgt ? std::string(UhdmName(tgt->UhdmType())) + ":" + fn(tgt) +
                             "@" + loc(tgt) : std::string("-")) +
            " nargs=" + std::to_string(args ? args->size() : 0) +
            " scope=" + (scope ? "1" : "0") +
            " tv=" + (tgt ? viewOf(tgt, mv) : std::string("-")) +
            " tl=" + (tgt ? std::string(UhdmName(tgt->UhdmType())) + "@" + loc(tgt)
                          : std::string("-")) +
            " home=" + homeOf(o) +
            " cls=" + clsOf(o) +
            " eline=" + std::to_string(encl ? encl->VpiLineNo() : 0) +
            " oob=" + (oobCaller ? "1" : "0") +
            " emeth=" + (enclMeth ? "1" : "0");
        rows.push_back(row);
    }
    // PR rows -- one per class_defn method LISTING, so a caller can tell a
    // PROTOTYPE listing (no Stmt, vpiAccessType 2 = vpiExternAcc, or
    // vpiDPIPure for a pure virtual) from an ordinary in-body method.  This is
    // what makes the mover PREDICTION readable out of a PRISTINE database
    // alone: `extern` / `pure virtual` is a slang flag, but its UHDM shadow is
    // right here.
    long npr = 0;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmclass_defn) continue;
        auto* cd = (const class_defn*)o;
        if (auto* v = cd->Task_funcs())
            for (auto* tf : *v) {
                if (!tf) continue;
                bool isFn = tf->UhdmType() == uhdmfunction;
                bool hasStmt = tf->Stmt() != nullptr;
                bool proto = !hasStmt && (tf->VpiAccessType() == 2 ||
                                          tf->VpiDPIPure());
                npr++;
                std::cout << "PR " << tag << " cls=" << nm(o)
                          << " name=" << nm(tf) << " loc=" << loc(tf)
                          << " kind=" << (isFn ? "function" : "task")
                          << " proto=" << (proto ? "1" : "0")
                          << " acc=" << tf->VpiAccessType()
                          << " pure=" << (tf->VpiDPIPure() ? "1" : "0")
                          << " stmt=" << (hasStmt ? "1" : "0") << "\n";
            }
    }
    for (auto& r : rows) std::cout << r << "\n";
    std::cout << "SUMMARY " << tag << " tf_calls=" << n << " linked=" << nl
              << " unlinked=" << (n - nl) << " listings=" << npr << "\n";
    return 0;
}
