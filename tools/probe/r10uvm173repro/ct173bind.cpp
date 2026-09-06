// r10uvm173 — THE CALLEE-LISTING CENSUS.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden (Surelog), RHS is ALWAYS ours.
//
// The r10uvm173 head is NOT a typespec defect (the SimpleUVM `uvm_is_match`
// argument cells agree edge-for-edge between the two producers, DEF and ELAB
// alike — see CENSUS.r10uvm173.txt).  It is a CALLEE-LISTING CROSSING: a
// `func_call` that lives in the package's DEF listing (design->AllPackages)
// binds `vpiFunction` to the ELABORATED twin of the callee
// (design->TopPackages) where golden binds the DEF twin, and the judge then
// pairs golden's DEF-listing body against OUR elaborated body.
//
// One row per tf_call that carries a bound callee:
//
//   BIND <callview>-><calleeview> <callkind> <callee> <file-less line:col> <homeview>
//
//   callview   the design listing the CALL lives in (walk VpiParent to the
//              root container, then test membership in TopPackages / AllPackages
//              / TopModules / AllModules / AllClasses).
//   calleeview the listing the CALLEE object lives in, same test.
//
// `<callview>-><calleeview>` is the whole law in one column: golden's package
// rows are DEF->DEF and ELAB->ELAB, ours are DEF->ELAB and ELAB->ELAB.
//
// build: g++ -O2 -std=c++17 ct173bind.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct173bind
// usage: ct173bind <db.uhdm> [--rows]      (--rows lists every cell, else counts)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static const BaseClass* rootOf(const BaseClass* o) {
    const BaseClass* r = o;
    int g = 0;
    while (r && r->VpiParent() && r->VpiParent()->UhdmType() != uhdmdesign && g++ < 1024)
        r = r->VpiParent();
    return r;
}
static std::string viewOf(const BaseClass* o, const design* d) {
    const BaseClass* root = rootOf(o);
    if (!root) return "NOROOT";
    if (d->TopPackages())
        for (auto* p : *d->TopPackages()) if ((const BaseClass*)p == root) return "PKGELAB";
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) if ((const BaseClass*)p == root) return "PKGDEF";
    if (d->TopModules())
        for (auto* m : *d->TopModules()) if ((const BaseClass*)m == root) return "MODTOP";
    if (d->AllModules())
        for (auto* m : *d->AllModules()) if ((const BaseClass*)m == root) return "MODALL";
    if (d->AllClasses())
        for (auto* c : *d->AllClasses()) if ((const BaseClass*)c == root) return "CLSALL";
    if (root->UhdmType() == uhdmdesign) return "DESIGN";
    return std::string("OTHER:") + std::string(UhdmName(root->UhdmType()));
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct173bind <db.uhdm> [--rows]\n"); return 2; }
    bool rows = false;
    for (int i = 2; i < argc; ++i) if (!strcmp(argv[i], "--rows")) rows = true;
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { printf("NO_DESIGN\n"); return 3; }

    std::map<std::string, int> counts;
    std::vector<std::string> out;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const tf_call* c = any_cast<const tf_call*>(o);
        if (!c) continue;
        const BaseClass* callee = nullptr;
        const char* kind = "?";
        if (o->UhdmType() == uhdmfunc_call) {
            callee = ((const func_call*)o)->Function();
            kind = "func_call";
        } else if (o->UhdmType() == uhdmtask_call) {
            callee = ((const task_call*)o)->Task();
            kind = "task_call";
        } else if (o->UhdmType() == uhdmmethod_func_call) {
            callee = ((const method_func_call*)o)->Function();
            kind = "method_func_call";
        } else if (o->UhdmType() == uhdmmethod_task_call) {
            callee = ((const method_task_call*)o)->Task();
            kind = "method_task_call";
        } else {
            continue;
        }
        if (!callee) continue;
        const std::string cv = viewOf(o, d);
        const std::string ev = viewOf(callee, d);
        counts[cv + "->" + ev + " " + kind]++;
        // THE PREDICTION COLUMN.  A cell this pass's gate would move, read off
        // a PRISTINE database: the call lives in a package's DEF listing, it is
        // bound to the ELABORATED twin, that twin belongs to the SAME package
        // (by name — the two listings are two objects), and the written
        // spelling is NOT `<that package>::<name>`.  Every mover the patched
        // sweep produces must be one of these, named in advance.
        bool wouldMove = false;
        if (cv == "PKGDEF" && ev == "PKGELAB" && o->UhdmType() == uhdmfunc_call) {
            const std::string cn(c->VpiName());
            const size_t sep = cn.find("::");
            bool pkgQual = false;
            if (sep != std::string::npos && d->AllPackages()) {
                const std::string q = cn.substr(0, sep);
                for (auto* p : *d->AllPackages())
                    if (std::string(p->VpiName()) == q) { pkgQual = true; break; }
            }
            wouldMove = !pkgQual;
        }
        if (wouldMove) counts["WOULDMOVE"]++;
        if (rows) {
            char b[900];
            snprintf(b, sizeof b, "BIND %s->%s %s %s %u:%u%s", cv.c_str(), ev.c_str(), kind,
                     std::string(c->VpiName()).c_str(), o->VpiLineNo(),
                     (unsigned)o->VpiColumnNo(), wouldMove ? " WOULDMOVE" : "");
            out.push_back(b);
        }
    }
    std::sort(out.begin(), out.end());
    for (auto& r : out) printf("%s\n", r.c_str());
    for (auto& kv : counts) printf("COUNT %-46s %d\n", kv.first.c_str(), kv.second);
    return 0;
}
