// r10buvm13cen — THE CENSUS INSTRUMENT for the FORMAL DEFAULT-VALUE REF family
// (`io_decl::Expr()` subtree -> `ref_obj::Actual_group()`), plus the io_decl
// LISTING census that rules the "short/misordered Io_decls vector" hypothesis
// in or out.
//
// MEASUREMENT ONLY.  The official uhdm-cmp is the acceptance judge.
// LHS is ALWAYS golden; this tool reads ONE database and tags its rows, so the
// caller joins golden rows against ours (cenjoin13.py).
//
// Reads a .uhdm out of Serializer::AllObjects() (never dump TEXT) and prints
//
//   DV <tag> key=<view>|<owner tf kind>|<owner fullname>|<formal idx>|<formal
//            name>|<ref kind>|<ref name>@<line:col>
//      act=<0|1> atgt=<kind>@<line:col> aname=<name> akind=<kind>
//      home=<kind(name)> oob=<0|1> meth=<0|1> earlier=<-1|0|1> depth=<n>
//
//   IOV <tag> key=<view>|<owner tf kind>|<owner fullname> n=<count>
//       names=<a,b,c> dirs=<1,1,..> ndef=<how many carry an Expr>
//
//   ORPH <tag> ... a ref_obj whose owner io_decl could NOT be established and
//       that has no task_func ancestor either -- printed so census LEAKAGE is
//       visible instead of silently dropping rows.
//
// THE OWNER WALK, and why it is not a plain parent walk: OUR emitter builds a
// formal's default-value expression with a NULL parent (TaskFuncEmit's
// `emitExpr(*dv, nullptr, ...)`), so the TOP node of the expression has no
// vpiParent and an upward walk from a ref inside it never reaches the io_decl.
// Surelog parents it at the io_decl.  A census that used the parent chain alone
// would therefore report OUR rows as missing rather than as unbound, and would
// be measuring the wrong field.  So the walk is: from the ref, climb
// vpiParent; at EVERY step (including the ref itself) look the node up in a map
// built from every io_decl's Expr()/Left_expr()/Right_expr() and every one of
// its Ranges' end expressions.  A hit names the owner io_decl on either side.
//
// usage: r10buvm13cen <file.uhdm> [tag]
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

struct IoInfo {
    const task_func* owner = nullptr;
    int idx = -1;
    std::string name;
};

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm13cen <file.uhdm> [tag]\n"; return 2; }
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

    // io_decl -> (owner task_func, index, name), and every io_decl EXPRESSION
    // ROOT -> its io_decl (the owner walk's anchor; see the header).
    std::map<const io_decl*, IoInfo> ioOf;
    std::map<const any*, const io_decl*> rootOf;
    long nIov = 0;
    std::vector<std::string> iovRows;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        UHDM_OBJECT_TYPE t = o->UhdmType();
        if (t != uhdmfunction && t != uhdmtask) continue;
        auto* tf = (const task_func*)o;
        auto* ios = tf->Io_decls();
        std::string names, dirs;
        int ndef = 0, n = 0;
        if (ios) {
            for (auto* io : *ios) {
                if (!io) continue;
                IoInfo ii; ii.owner = tf; ii.idx = n; ii.name = nm(io);
                ioOf[io] = ii;
                if (!names.empty()) { names += ","; dirs += ","; }
                names += ii.name;
                dirs += std::to_string(io->VpiDirection());
                if (io->Expr()) { ndef++; rootOf[io->Expr()] = io; }
                if (io->Left_expr()) rootOf[io->Left_expr()] = io;
                if (io->Right_expr()) rootOf[io->Right_expr()] = io;
                if (auto* rgs = io->Ranges())
                    for (auto* rg : *rgs) {
                        if (!rg) continue;
                        if (rg->Left_expr()) rootOf[rg->Left_expr()] = io;
                        if (rg->Right_expr()) rootOf[rg->Right_expr()] = io;
                    }
                n++;
            }
        }
        nIov++;
        iovRows.push_back("IOV " + tag + " key=" + viewOf(o, mv) + "|" +
                          std::string(UhdmName(t)) + "|" + fn(o) +
                          " n=" + std::to_string(n) + " names=" +
                          (names.empty() ? "-" : names) + " dirs=" +
                          (dirs.empty() ? "-" : dirs) +
                          " ndef=" + std::to_string(ndef) +
                          " home=" + homeOf(o));
    }

    long nref = 0, nact = 0, norph = 0, ninside = 0;
    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        auto* r = dynamic_cast<const ref_obj*>(o);
        if (!r) continue;
        nref++;
        // THE OWNER WALK (see the header): parent-chain climb that also probes
        // the expression-ROOT map at every step, so a NULL-parented expression
        // top does not hide the owner.
        const io_decl* own = nullptr;
        int depth = 0;
        bool sawTf = false;
        {
            const any* p = o;
            for (int g = 0; p && g < 40; p = p->VpiParent(), g++) {
                if (auto it = rootOf.find(p); it != rootOf.end()) { own = it->second; depth = g; break; }
                if (p->UhdmType() == uhdmio_decl) { own = (const io_decl*)p; depth = g; break; }
                UHDM_OBJECT_TYPE pt = p->UhdmType();
                if (g && (pt == uhdmfunction || pt == uhdmtask)) { sawTf = true; break; }
                if (g && (pt == uhdmclass_defn || pt == uhdmpackage ||
                          pt == uhdmmodule_inst || pt == uhdmdesign)) { sawTf = true; break; }
            }
        }
        if (!own) {
            if (!sawTf) {
                norph++;
                if (norph <= 40)
                    rows.push_back("ORPH " + tag + " kind=" +
                                   std::string(UhdmName(o->UhdmType())) +
                                   " name=" + nm(o) + "@" + loc(o) +
                                   " chain=" + (o->VpiParent() ? std::string(UhdmName(o->VpiParent()->UhdmType())) : std::string("<null>")));
            }
            continue;
        }
        ninside++;
        auto ii = ioOf.count(own) ? ioOf[own] : IoInfo{};
        const any* act = r->Actual_group();
        if (act) nact++;
        // EARLIER: is the Actual (or, when unbound, a same-named formal of the
        // owner) a formal DECLARED BEFORE the one holding this default value?
        int earlier = -1;
        if (ii.owner) {
            if (auto* ios = ii.owner->Io_decls()) {
                int k = 0;
                for (auto* io2 : *ios) {
                    if (io2 && nm(io2) == nm(o)) { earlier = (k < ii.idx) ? 1 : 0; break; }
                    k++;
                }
            }
        }
        // THE VIEW IS TAKEN FROM THE OWNER, NOT FROM THE REF.  Same reason as
        // the owner walk: our default-value expression tops out UNPARENTED, so
        // viewOf() climbing from the ref lands nowhere and reports OTHER for
        // every one of our cells -- which would turn a pure BINDING census into
        // 277 spurious ARITY-DIFFs keyed on the view.  The owner task_func is
        // properly parented on BOTH sides.
        rows.push_back("DV " + tag + " key=" +
            (ii.owner ? viewOf(ii.owner, mv) : viewOf(o, mv)) + "|" +
            (ii.owner ? std::string(UhdmName(ii.owner->UhdmType())) : std::string("-")) + "|" +
            (ii.owner ? fn(ii.owner) : std::string("-")) + "|" +
            std::to_string(ii.idx) + "|" + ii.name + "|" +
            std::string(UhdmName(o->UhdmType())) + "|" + nm(o) + "@" + loc(o) +
            " act=" + (act ? "1" : "0") +
            " akind=" + (act ? std::string(UhdmName(act->UhdmType())) : std::string("-")) +
            " atgt=" + (act ? std::string(UhdmName(act->UhdmType())) + "@" + loc(act)
                            : std::string("-")) +
            " aname=" + (act ? nm(act) : std::string("-")) +
            " home=" + (ii.owner ? homeOf(ii.owner) : std::string("-")) +
            " oob=" + ((ii.owner && ii.owner->VpiParent() &&
                        ii.owner->VpiParent()->UhdmType() == uhdmpackage &&
                        fn(ii.owner).find("::") != std::string::npos &&
                        std::string(UhdmName(ii.owner->UhdmType())).size() &&
                        homeOf(ii.owner).rfind("package", 0) == 0 &&
                        std::string(ii.owner->VpiName()).find("::") != std::string::npos)
                       ? "1" : "0") +
            " meth=" + (ii.owner && ii.owner->VpiMethod() ? "1" : "0") +
            " earlier=" + std::to_string(earlier) +
            " depth=" + std::to_string(depth));
    }
    for (auto& r : iovRows) std::cout << r << "\n";
    for (auto& r : rows) std::cout << r << "\n";
    std::cout << "SUMMARY " << tag << " tfs=" << nIov << " io_decls=" << ioOf.size()
              << " ref_objs=" << nref << " in_default=" << ninside
              << " bound=" << nact << " unbound=" << (ninside - nact)
              << " ORPHANS=" << norph << "\n";
    return 0;
}
