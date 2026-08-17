// r10buvm8cen — THE CENSUS INSTRUMENT for the call-argument ref_typespec family.
//
// Reads ONE .uhdm database and reports EVERY tf_call (func_call / task_call /
// method_func_call / method_task_call / sys_func_call / sys_task_call) argument
// the serializer holds, keyed by the ARGUMENT's own line:col so GOLDEN and OURS
// join on source position.  Objects come from Serializer::AllObjects() and not
// from the dump text, because the dump reprints an object at every reference
// (a shape census over dump TEXT multiplies) and never prints an orphan.
//
//   ARG <tag> <line>:<col>-<eline>:<ecol> call=<callkind> callee=<vpiName>
//       cfun=<Function()!=null> pos=<0-based arg index>/<nargs>
//       arg=<uhdm kind> aname=<vpiName> TS=<yes|no>
//       tsname=<ref_typespec VpiName> tsdef=<VpiDefName>
//       act=<actual typespec kind> actname=<name> actloc=<l:c-l:c>
//       file=<the ARG's VpiFile>
//
// TOTALS is printed ALWAYS, including on RESTORE_FAIL, because a run that
// reached nothing must never read as perfection.
//
// usage: r10buvm8cen <file.uhdm> [tag]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdlib>
#include <iostream>
#include <map>
#include <set>
#include <string>

using namespace UHDM;

static std::string nameOf(const any* o) {
    if (!o) return "-";
    if (auto* r = dynamic_cast<const ref_obj*>(o)) return std::string(r->VpiName());
    if (auto* h = dynamic_cast<const hier_path*>(o)) return std::string(h->VpiName());
    if (auto* b = dynamic_cast<const bit_select*>(o)) return std::string(b->VpiName());
    if (auto* p = dynamic_cast<const part_select*>(o)) return std::string(p->VpiName());
    if (auto* v = dynamic_cast<const var_select*>(o)) return std::string(v->VpiName());
    if (auto* c = dynamic_cast<const constant*>(o)) return std::string(c->VpiDecompile());
    if (auto* t = dynamic_cast<const tf_call*>(o)) return std::string(t->VpiName());
    return "-";
}
static std::string tsName(const typespec* t) {
    if (!t) return "-";
    std::string n(t->VpiName());
    return n.empty() ? "<anon>" : n;
}
static std::string loc(const any* o) {
    if (!o) return "-";
    return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) +
           "-" + std::to_string(o->VpiEndLineNo()) + ":" +
           std::to_string(o->VpiEndColumnNo());
}

// The ancestor chain, root LAST: the ONE thing that separates golden's DEF
// listing from its ELABORATED listing when both hold the same source position.
static std::string chainOf(const any* o) {
    std::string r;
    int guard = 0;
    for (const any* p = o ? o->VpiParent() : nullptr; p && guard < 30; p = p->VpiParent(), guard++) {
        if (!r.empty()) r += "<";
        r += std::string(UhdmName(p->UhdmType())) + "#" + std::to_string((long)p->UhdmId());
    }
    return r.empty() ? "-" : r;
}

// THE CELL of a call argument — the law's own predicate, computed from the
// database so GOLDEN can be censused against it before any emitter code exists.
//   view  : ELAB when the nearest package ancestor is in design.TopPackages,
//           DEF when it is in AllPackages, MOD/CLS/OTHER otherwise.
//   reach : RETTOP when the call is reached from the expression of a return_stmt
//           that is a DIRECT statement of the enclosing function's body (the
//           function's own Stmt, or a member of the synthetic multi-statement
//           `begin`) — climbing only through operation / func_call /
//           sys_func_call ancestors.  NESTED when a return_stmt is reached but
//           an if/for/while/case/fork/explicit-begin sits between it and the
//           function.  NORET otherwise.
static std::string cellOf(const any* call, bool cfun,
                          const std::set<const any*>& topPkgs,
                          const std::set<const any*>& allPkgs) {
    // climb the expression spine
    const any* p = call ? call->VpiParent() : nullptr;
    int guard = 0;
    while (p && guard++ < 40) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmoperation || t == uhdmfunc_call || t == uhdmsys_func_call ||
            t == uhdmmethod_func_call || t == uhdmtagged_pattern)
            p = p->VpiParent();
        else
            break;
    }
    std::string reach = "NORET";
    std::string owner = "-";
    if (p && p->UhdmType() == uhdmreturn_stmt) {
        const any* q = p->VpiParent();
        int nbegin = 0;
        while (q && q->UhdmType() == uhdmbegin) { nbegin++; q = q->VpiParent(); }
        if (q && (q->UhdmType() == uhdmfunction || q->UhdmType() == uhdmtask) &&
            nbegin <= 1) {
            reach = "RETTOP";
            const any* o = q->VpiParent();
            if (!o) owner = "NOPARENT";
            else if (o->UhdmType() == uhdmpackage) owner = "PKGFN";
            else if (o->UhdmType() == uhdmclass_defn) owner = "CLSFN";
            else if (o->UhdmType() == uhdmmodule_inst) owner = "MODFN";
            else owner = std::string(UhdmName(o->UhdmType()));
        }
        else
            reach = "NESTED";
    }
    // the OUTERMOST package ancestor decides the view
    std::string view = "NOPKG";
    const any* r = call;
    guard = 0;
    while (r && guard++ < 80) {
        if (r->UhdmType() == uhdmpackage)
            view = topPkgs.count(r) ? "ELABPKG" : (allPkgs.count(r) ? "DEFPKG" : "PKG?");
        r = r->VpiParent();
    }
    return view + "/" + reach + "/" + owner + "/" + (cfun ? "BOUND" : "UNBOUND");
}

int main(int argc, char** argv) {
    if (argc < 2) { std::cerr << "usage: r10buvm8cen <file.uhdm> [tag]\n"; return 2; }
    std::string tag = argc > 2 ? argv[2] : argv[1];
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        std::cout << "RESTORE_FAIL " << tag << "\n";
        // The FORMAL side of the join: every task_func's io_decls with the identity
    // of the typespec object they point at, so "shared vs fresh" is a MEASURED
    // fact and not an assumption.  A rule that hangs a CLONE where golden
    // shares would read identical in the dump and differ in ref_typespec::Compare.
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        auto* tf = dynamic_cast<const task_func*>(o);
        if (!tf) continue;
        auto* v = tf->Io_decls();
        if (!v) continue;
        size_t i = 0;
        for (auto* io : *v) {
            const ref_typespec* rt = io->Typespec();
            const typespec* act = rt ? rt->Actual_typespec() : nullptr;
            std::cout << "IODECL " << tag << " " << loc(io) << " tf=" << tf->VpiName()
                      << " tfid=" << (long)tf->UhdmId()
                      << " pos=" << i++ << " io=" << io->VpiName()
                      << " dir=" << io->VpiDirection()
                      << " act=" << (act ? std::string(UhdmName(act->UhdmType())) : "-")
                      << " actname=" << tsName(act)
                      << " actloc=" << loc(act)
                      << " actid=" << (act ? (long)act->UhdmId() : -1L)
                      << " rtid=" << (rt ? (long)rt->UhdmId() : -1L) << "\n";
        }
    }
    std::cout << "TOTALS " << tag << " calls=0 args=0 TS=0 noTS=0\n";
        return 3;
    }
    std::set<const any*> topPkgs, allPkgs;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        auto* d = (const design*)o;
        if (auto* v = d->TopPackages()) for (auto* p : *v) topPkgs.insert(p);
        if (auto* v = d->AllPackages()) for (auto* p : *v) allPkgs.insert(p);
    }
    std::map<std::string, long> cellTally;
    long ncalls = 0, nargs = 0, nts = 0, nnots = 0;
    std::map<std::string, long> byCallKindTS, byCallKindNo, byActKind;
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        auto* call = dynamic_cast<const tf_call*>(o);
        if (!call) continue;
        ncalls++;
        std::string ck(UhdmName(o->UhdmType()));
        auto* v = call->Tf_call_args();
        size_t n = v ? v->size() : 0;
        bool cfun = false;
        if (auto* fc = dynamic_cast<const func_call*>(o)) cfun = fc->Function() != nullptr;
        if (auto* tc = dynamic_cast<const task_call*>(o)) cfun = tc->Task() != nullptr;
        for (size_t i = 0; i < n; i++) {
            const any* a = (*v)[i];
            nargs++;
            const ref_typespec* rt = nullptr;
            if (auto* e = dynamic_cast<const expr*>(a)) rt = e->Typespec();
            const typespec* act = rt ? rt->Actual_typespec() : nullptr;
            const std::string cell8 = cellOf(call, cfun, topPkgs, allPkgs);
            cellTally[std::string(UhdmName(o->UhdmType())) + "|" +
                      cell8 + "|" +
                      std::string(a ? UhdmName(a->UhdmType()) : "<null>") + "|" +
                      (rt ? "TS" : "noTS")]++;
            if (rt) { nts++; byCallKindTS[ck]++; byActKind[act ? std::string(UhdmName(act->UhdmType())) : "<null-actual>"]++; }
            else { nnots++; byCallKindNo[ck]++; }
            std::cout << "ARG " << tag << " " << loc(a)
                      << " call=" << ck << " callee=" << call->VpiName()
                      << " cfun=" << (cfun ? 1 : 0)
                      << " pos=" << i << "/" << n
                      << " arg=" << (a ? std::string(UhdmName(a->UhdmType())) : "<null>")
                      << " aname=" << nameOf(a)
                      << " TS=" << (rt ? "yes" : "no")
                      << " tsname=" << (rt ? std::string(rt->VpiName()) : std::string("-"))
                      << " tsdef=" << (rt ? std::string(rt->VpiDefName()) : std::string("-"))
                      << " act=" << (act ? std::string(UhdmName(act->UhdmType())) : "-")
                      << " actname=" << tsName(act)
                      << " actloc=" << loc(act)
                      << " actid=" << (act ? (long)act->UhdmId() : -1L)
                      << " cell=" << cell8
                      << " callloc=" << loc(call)
                      << " argid=" << (a ? (long)a->UhdmId() : -1L)
                      << " callid=" << (long)call->UhdmId()
                      << " chain=" << chainOf(a)
                      << " file=" << (a ? a->VpiFile() : "-") << "\n";
        }
    }
    // The FORMAL side of the join: every task_func's io_decls with the identity
    // of the typespec object they point at, so "shared vs fresh" is a MEASURED
    // fact and not an assumption.  A rule that hangs a CLONE where golden
    // shares would read identical in the dump and differ in ref_typespec::Compare.
    for (auto& kv : s.AllObjects()) {
        const any* o = kv.first;
        if (!o) continue;
        auto* tf = dynamic_cast<const task_func*>(o);
        if (!tf) continue;
        auto* v = tf->Io_decls();
        if (!v) continue;
        size_t i = 0;
        for (auto* io : *v) {
            const ref_typespec* rt = io->Typespec();
            const typespec* act = rt ? rt->Actual_typespec() : nullptr;
            std::cout << "IODECL " << tag << " " << loc(io) << " tf=" << tf->VpiName()
                      << " tfid=" << (long)tf->UhdmId()
                      << " pos=" << i++ << " io=" << io->VpiName()
                      << " dir=" << io->VpiDirection()
                      << " act=" << (act ? std::string(UhdmName(act->UhdmType())) : "-")
                      << " actname=" << tsName(act)
                      << " actloc=" << loc(act)
                      << " actid=" << (act ? (long)act->UhdmId() : -1L)
                      << " rtid=" << (rt ? (long)rt->UhdmId() : -1L) << "\n";
        }
    }
    std::cout << "TOTALS " << tag << " calls=" << ncalls << " args=" << nargs
              << " TS=" << nts << " noTS=" << nnots << "\n";
    for (auto& p : byCallKindTS) std::cout << "BYCALL_TS " << tag << " " << p.first << " " << p.second << "\n";
    for (auto& p : byCallKindNo) std::cout << "BYCALL_NOTS " << tag << " " << p.first << " " << p.second << "\n";
    for (auto& p : cellTally)
        std::cout << "CELL " << tag << " " << p.first << " " << p.second << "\n";
    for (auto& p : byActKind) std::cout << "BYACT " << tag << " " << p.first << " " << p.second << "\n";
    return 0;
}
