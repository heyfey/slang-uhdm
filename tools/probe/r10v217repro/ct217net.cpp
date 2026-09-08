// r10uvm217 — ct217net.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the
// sole judge; this tool only reports.  LHS is ALWAYS golden (Surelog), RHS is
// ALWAYS ours.
//
// THE MATERIALIZED-LISTING CENSUS, POSITION-KEYED.
//
// Every `module_inst` / `interface_inst` / `program` / `package` in a database
// is printed with its `Nets()` and `Variables()` vectors IN ORDER, one line
// per element, carrying the judge-visible face only: the element's kind, its
// `VpiName`, and the per-kind scalars `nets::Compare` actually reads
// (`VpiNetType`, `VpiResolvedNetType`, `VpiImplicitDecl`, `VpiSigned`) plus
// the typespec face.  POSITION is part of the key because the vector overload
// of `BaseClass::SafeCompare` (`BaseClass.h:200-224`) walks the two vectors
// INDEX BY INDEX, and `nets::Compare` (generated `nets.cpp`) compares
// `VpiName` — so a permutation of a net listing is NOT judge-invisible.
//
// build: g++ -O2 -std=c++17 ct217net.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct217net
// usage: ct217net <db.uhdm> [--inst=<substring>] [--vars] [--quiet]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>
#include <functional>

using namespace UHDM;

static std::string tsface(const ref_typespec* rt) {
    if (!rt) return "-";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "ref-noactual";
    std::string n(a->VpiName());
    return std::string(UhdmName(a->UhdmType())) + "(" + n + ")";
}

static void emitNets(const char* view, const std::string& key,
                     const std::vector<net*>* v) {
    size_t n = v ? v->size() : 0;
    printf("ARITY|%s|%s|nets|%zu|%s\n", view, key.c_str(), n,
           v ? "vec" : "NULLVEC");
    if (!v) return;
    for (size_t i = 0; i < n; i++) {
        const net* nt = (*v)[i];
        printf("NET|%s|%s|%zu|%s|%s|nt=%d|rnt=%d|impl=%d|sgn=%d|ts=%s\n", view,
               key.c_str(), i, std::string(UhdmName(nt->UhdmType())).c_str(),
               std::string(nt->VpiName()).c_str(), (int)nt->VpiNetType(),
               (int)nt->VpiResolvedNetType(), (int)nt->VpiImplicitDecl(),
               (int)nt->VpiSigned(), tsface(nt->Typespec()).c_str());
    }
}

static void emitVars(const char* view, const std::string& key,
                     const std::vector<variables*>* v) {
    size_t n = v ? v->size() : 0;
    printf("ARITY|%s|%s|vars|%zu|%s\n", view, key.c_str(), n,
           v ? "vec" : "NULLVEC");
    if (!v) return;
    for (size_t i = 0; i < n; i++) {
        const variables* vr = (*v)[i];
        printf("VAR|%s|%s|%zu|%s|%s|auto=%d|vis=%d|ts=%s\n", view, key.c_str(),
               i, std::string(UhdmName(vr->UhdmType())).c_str(),
               std::string(vr->VpiName()).c_str(), (int)vr->VpiAutomatic(),
               (int)vr->VpiVisibility(), tsface(vr->Typespec()).c_str());
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct217net <db.uhdm> [--inst=SUB] [--vars]\n");
        return 2;
    }
    std::string want;
    bool wantVars = false;
    for (int i = 2; i < argc; i++) {
        std::string a(argv[i]);
        if (a.rfind("--inst=", 0) == 0) want = a.substr(7);
        else if (a == "--vars") wantVars = true;
    }
    Serializer s;
    std::vector<vpiHandle> designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) {
        fprintf(stderr, "FATAL: no design in %s\n", argv[1]);
        return 3;
    }
    // The RESTORE HANDLE's design, exactly as uhdm-cmp reads it.
    const design* d = (const design*)((uhdm_handle*)designs[0])->object;

    auto keyOf = [&](const BaseClass* o) {
        return std::string(UhdmName(o->UhdmType())) + ":" +
               std::string(o->VpiDefName()) + ":" + std::string(o->VpiName());
    };
    auto doInst = [&](const char* view, const instance* inst) {
        std::string k = keyOf(inst);
        if (!want.empty() && k.find(want) == std::string::npos) return;
        emitNets(view, k, inst->Nets());
        if (wantVars) emitVars(view, k, inst->Variables());
    };
    std::function<void(const char*, const module_inst*)> walkMod =
        [&](const char* view, const module_inst* m) {
            doInst(view, m);
            if (m->Modules())
                for (auto* c : *m->Modules()) walkMod(view, c);
            if (m->Interfaces())
                for (auto* c : *m->Interfaces()) doInst(view, c);
        };
    if (d->AllModules())
        for (auto* m : *d->AllModules()) doInst("def", m);
    if (d->AllInterfaces())
        for (auto* m : *d->AllInterfaces()) doInst("defif", m);
    if (d->AllPackages())
        for (auto* p : *d->AllPackages()) {
            std::string k = keyOf(p);
            if (!want.empty() && k.find(want) == std::string::npos) continue;
            emitNets("pkg", k, p->Nets());
            if (wantVars) emitVars("pkg", k, p->Variables());
        }
    if (d->TopModules())
        for (auto* m : *d->TopModules()) walkMod("elab", m);
    return 0;
}
