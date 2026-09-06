// r10uvm173 — THE CALL-ARGUMENT TYPESPEC-EDGE CENSUS — **THE PROBE THAT
// REFUTED THIS PASS'S BRIEF**.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.  LHS is ALWAYS
// golden (Surelog), RHS is ALWAYS ours.
//
// The brief read the SimpleUVM head as "ours hangs a ref_typespec on the
// string-formal reference at 403:24 where golden leaves the edge unset" and
// asked for a typespec law.  This census says there is no typespec defect:
// keyed by view x home x callee x callee-kind x arg-kind x binding x type,
// the `uvm_is_match` cells read
//
//   golden  DEF  403:24 TS=0   403:27 TS=0      ours  DEF  403:24 TS=0  403:27 TS=0
//   golden  ELAB 403:24 TS=1   403:27 TS=1      ours  ELAB 403:24 TS=1  403:27 TS=1
//
// — edge for edge the same, in BOTH listings.  What differs is WHICH LISTING
// the judge was holding: see ct173seed.cpp (the pairing prover) and
// ct173bind.cpp (the law's own census).
//
// For every `tf_call` argument in a database it prints ONE row:
//
//   CELL <view>|<home>|<callee>|<dpi>|<argkind>|<bind>|<type>|<line:col>|<name> TS=<0|1>
//
//   view    ELAB / DEF / MOD / OTHER — which design listing the object lives in,
//           decided by walking VpiParent to the root container and testing
//           membership in design->TopPackages (ELAB) / AllPackages (DEF) /
//           TopModules / AllModules.  The DEF/ELAB label is IN the key here
//           deliberately: this pass's law IS a view split, so the two views
//           must be separate cells (RESUME §9's "keep the view out of the key"
//           applies to censuses whose law is view-blind).
//   home    the enclosing function / task / class_defn kind + name.
//   callee  the called subroutine's name.
//   dpi     DPI / PLAIN / NOFN — whether the callee object is a DPI import
//           (task_func::VpiDPIContext or a DPIC identifier), a plain
//           subroutine, or the call carries no bound callee at all.
//   argkind the UHDM kind of the actual (ref_obj, constant, operation, ...).
//   bind    what the actual's `Actual_group` lands on: FORMAL (io_decl),
//           VAR (variables), PARAM, OTHER, BARE.
//   type    the actual's own declared typespec kind (string/int/logic/...),
//           read through the bound object, NOT through the ts edge under test.
//   TS      1 when the actual carries a `vpiTypespec` edge, 0 when it does not.
//
// Run it on the two databases and `diff` the sorted outputs: a one-sided row
// is a cell one producer has and the other does not, and a row that differs
// only in its `TS=` column is a typespec mover.  On SimpleUVM the DPI-call
// section diffs to NOTHING.
//
// build: g++ -O2 -std=c++17 ct173cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct173cen
// usage: ct173cen <db.uhdm> [--tag TAG]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

static std::string viewOf(const BaseClass* o, const design* d) {
    const BaseClass* root = o;
    int guard = 0;
    while (root && root->VpiParent() &&
           root->VpiParent()->UhdmType() != uhdmdesign && guard++ < 512)
        root = root->VpiParent();
    if (!root) return "NOROOT";
    if (d->TopPackages())
        for (auto* p : *d->TopPackages())
            if ((const BaseClass*)p == root) return "ELAB";
    if (d->AllPackages())
        for (auto* p : *d->AllPackages())
            if ((const BaseClass*)p == root) return "DEF";
    if (d->TopModules())
        for (auto* m : *d->TopModules())
            if ((const BaseClass*)m == root) return "MODTOP";
    if (d->AllModules())
        for (auto* m : *d->AllModules())
            if ((const BaseClass*)m == root) return "MODALL";
    if (d->AllClasses())
        for (auto* c : *d->AllClasses())
            if ((const BaseClass*)c == root) return "CLSALL";
    return std::string("OTHER:") + UhdmName(root->UhdmType());
}

// The enclosing subroutine / class, innermost first.
static std::string homeOf(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        switch (p->UhdmType()) {
            case uhdmfunction:
                return std::string("FUNC:") + std::string(p->VpiName());
            case uhdmtask:
                return std::string("TASK:") + std::string(p->VpiName());
            case uhdmclass_defn:
                return std::string("CLASS:") + std::string(p->VpiName());
            case uhdmpackage:
                return std::string("PKGBODY");
            case uhdmmodule_inst:
                return std::string("MODBODY");
            default:
                break;
        }
    }
    return "NOHOME";
}

// Is the enclosing subroutine a CLASS METHOD?  (a function whose parent chain
// hits a class_defn before a package/module)
static bool inClassMethod(const BaseClass* o) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (p->UhdmType() == uhdmclass_defn) return true;
        if (p->UhdmType() == uhdmpackage || p->UhdmType() == uhdmmodule_inst)
            return false;
    }
    return false;
}

static const ref_typespec* tsEdge(const BaseClass* o) {
    if (const expr* e = any_cast<const expr*>(o)) return e->Typespec();
    return nullptr;
}

static const BaseClass* actualOf(const BaseClass* o) {
    if (const ref_obj* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (const ref_var* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}

static std::string bindOf(const BaseClass* a) {
    const BaseClass* act = actualOf(a);
    if (!act) return "BARE";
    switch (act->UhdmType()) {
        case uhdmio_decl: return "FORMAL";
        case uhdmparam_assign: return "PARAM";
        default: break;
    }
    if (any_cast<const variables*>(act)) return "VAR";
    if (any_cast<const nets*>(act)) return "NET";
    return std::string("OTHER:") + UhdmName(act->UhdmType());
}

// The actual's OWN declared type, read through what it is bound to — never
// through the edge under test.
static std::string typeOf(const BaseClass* a) {
    const BaseClass* act = actualOf(a);
    const ref_typespec* rt = nullptr;
    if (act) {
        if (act->UhdmType() == uhdmio_decl)
            rt = ((const io_decl*)act)->Typespec();
        else if (const variables* v = any_cast<const variables*>(act))
            rt = v->Typespec();
        else if (const nets* n = any_cast<const nets*>(act))
            rt = n->Typespec();
    }
    if (rt && rt->Actual_typespec())
        return UhdmName(rt->Actual_typespec()->UhdmType());
    if (!act) {
        // an unbound actual: fall back to its own kind
        return std::string("-") + std::string(UhdmName(a->UhdmType())).c_str();
    }
    return "unbound_ts";
}

static std::string calleeKind(const tf_call* c) {
    const function* f = nullptr;
    if (c->UhdmType() == uhdmfunc_call) f = ((const func_call*)c)->Function();
    if (!f) {
        if (c->UhdmType() == uhdmtask_call) {
            const task* t = ((const task_call*)c)->Task();
            if (!t) return "NOFN";
            if (t->VpiDPIContext() || t->VpiDPIPure() ||
                !t->VpiDPICIdentifier().empty())
                return "DPI";
            return "PLAIN";
        }
        return "NOFN";
    }
    if (f->VpiDPIContext() || f->VpiDPIPure() || !f->VpiDPICIdentifier().empty())
        return "DPI";
    return "PLAIN";
}

int main(int argc, char** argv) {
    if (argc < 2) { fprintf(stderr, "usage: ct173cen <db.uhdm> [--tag T]\n"); return 2; }
    const char* tag = "";
    for (int i = 2; i + 1 < argc; ++i)
        if (!strcmp(argv[i], "--tag")) tag = argv[i + 1];
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    const design* d = topDesign(s);
    if (!d) { printf("NO_DESIGN\n"); return 3; }

    std::vector<std::string> rows;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const tf_call* c = any_cast<const tf_call*>(o);
        if (!c) continue;
        const VectorOfany* args = c->Tf_call_args();
        if (!args) continue;
        const std::string view = viewOf(o, d);
        const std::string home = homeOf(o);
        const std::string ck = calleeKind(c);
        const std::string cname(c->VpiName());
        const bool meth = inClassMethod(o);
        for (size_t i = 0; i < args->size(); ++i) {
            const BaseClass* a = (*args)[i];
            if (!a) continue;
            char b[1400];
            snprintf(b, sizeof b,
                     "CELL %s|%s|%s|%s|%s|%s|%s|%s|%u:%u|%zu|%s TS=%d",
                     view.c_str(), meth ? "METHOD" : "FREE", home.c_str(),
                     cname.c_str(), ck.c_str(), std::string(UhdmName(a->UhdmType())).c_str(),
                     bindOf(a).c_str(), typeOf(a).c_str(), a->VpiLineNo(),
                     (unsigned)a->VpiColumnNo(), i,
                     std::string(a->VpiName()).c_str(),
                     tsEdge(a) ? 1 : 0);
            rows.push_back(b);
        }
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) printf("%s%s\n", tag[0] ? (std::string(tag) + " ").c_str() : "", r.c_str());
    printf("TOTALCELLS %zu\n", rows.size());
    return 0;
}
