// ct111id.cpp — r10uvm111 IDENTITY oracle (measurement only; the official
// uhdm-cmp remains the judge).
//
// Answers, off ONE database, the questions the text dump cannot: WHICH object
// a package-scope variable initializer's func_call binds, BY UhdmId, against
// the Task_funcs listing entries of the DEF-view (uhdmallPackages) and the
// ELABORATED-view (uhdmtopPackages) copies of the SAME package.
//
//   usage: ct111id <design.uhdm> [callNameSubstring]
//
// Prints one row per (view, package, variable, call) cell:
//   VIEW pkg#<id> var=<name> call=<name> fn#<id> fn.name=<..> fn.parent=<kind#id>
//   DEFLIST <pkg> <tf name> #<id>          (the listing entry with that name)
//   TOPLIST <pkg> <tf name> #<id>
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_user.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static const char* kindName(const any* o) {
    return o ? UHDM::UhdmName(o->UhdmType()).data() : "<null>";
}

static void scanExpr(const any* e, const package* pk, const char* view,
                     const char* varName, const std::string& filt) {
    if (!e)
        return;
    if (e->UhdmType() == uhdmfunc_call) {
        auto* fc = (const func_call*)e;
        std::string cn(fc->VpiName());
        if (filt.empty() || cn.find(filt) != std::string::npos) {
            const function* f = fc->Function();
            printf("CALL %-4s pkg=%s#%u var=%s call=%s fn=#%u fn.name=%s "
                   "fn.parent=%s#%u\n",
                   view, std::string(pk->VpiName()).c_str(), pk->UhdmId(),
                   varName, cn.c_str(), f ? f->UhdmId() : 0,
                   f ? std::string(f->VpiName()).c_str() : "<null>",
                   f ? kindName(f->VpiParent()) : "-",
                   (f && f->VpiParent()) ? f->VpiParent()->UhdmId() : 0);
        }
        if (auto* as = fc->Tf_call_args())
            for (auto* a : *as)
                scanExpr(a, pk, view, varName, filt);
        return;
    }
    if (e->UhdmType() == uhdmoperation) {
        if (auto* os = ((const operation*)e)->Operands())
            for (auto* o : *os)
                scanExpr(o, pk, view, varName, filt);
    }
}

static void doPkg(const package* pk, const char* view, const std::string& filt) {
    if (auto* vs = pk->Variables())
        for (auto* v : *vs)
            scanExpr(v->Expr(), pk, view, std::string(v->VpiName()).c_str(),
                     filt);
    if (auto* pas = pk->Param_assigns())
        for (auto* pa : *pas)
            scanExpr(pa->Rhs(), pk, view, "<param_assign>", filt);
    if (auto* tfs = pk->Task_funcs())
        for (auto* tf : *tfs) {
            std::string n(tf->VpiName());
            if (!filt.empty() && n.find(filt) == std::string::npos)
                continue;
            printf("LIST %-4s pkg=%s#%u tf=%s #%u parent=%s#%u\n", view,
                   std::string(pk->VpiName()).c_str(), pk->UhdmId(), n.c_str(),
                   tf->UhdmId(), kindName(tf->VpiParent()),
                   tf->VpiParent() ? tf->VpiParent()->UhdmId() : 0);
        }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct111id <design.uhdm> [callNameSubstring]\n");
        return 2;
    }
    std::string filt = argc > 2 ? argv[2] : "";
    Serializer s;
    std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) {
        fprintf(stderr, "FATAL: nothing restored from %s\n", argv[1]);
        return 3;
    }
    for (auto h : restored) {
        auto* d = (design*)((uhdm_handle*)h)->object;
        if (auto* ps = d->AllPackages())
            for (auto* p : *ps)
                doPkg(p, "DEF", filt);
        if (auto* ps = d->TopPackages())
            for (auto* p : *ps)
                doPkg(p, "TOP", filt);
    }
    return 0;
}
