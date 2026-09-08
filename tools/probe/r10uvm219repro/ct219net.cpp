// r10uvm219 — ct219net.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the
// sole judge; this tool only reports.  LHS is ALWAYS golden (Surelog), RHS is
// ALWAYS ours.
//
// THE NET/VARIABLE LISTING CENSUS, POSITION-KEYED, WITH THE MINT SPAN.
//
// r10uvm217's `ct217net` printed the judge-visible face of every listing
// element in order.  This pass is about the ORDER of the implicit-wire block,
// so this variant adds the element's SOURCE SPAN (file:line:col) — which the
// judge does NOT read, but which is the only way to see WHICH reference minted
// a wire and therefore to decode the writer's ordering rule.
//
// The judge-visible face is printed exactly as ct217net printed it, so a
// position census built on this output is the same census.
//
// build: g++ -O2 -std=c++17 ct219net.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct219net
// usage: ct219net <db.uhdm> [--inst=<substring>] [--vars] [--spans]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <functional>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static bool g_spans = false;

static std::string tsface(const ref_typespec* rt) {
    if (!rt) return "-";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "ref-noactual";
    std::string n(a->VpiName());
    return std::string(UhdmName(a->UhdmType())) + "(" + n + ")";
}

static std::string spanOf(const BaseClass* o) {
    if (!g_spans) return "";
    std::string f(o->VpiFile());
    size_t sl = f.find_last_of('/');
    if (sl != std::string::npos) f = f.substr(sl + 1);
    char buf[512];
    snprintf(buf, sizeof(buf), "|@%s:%u:%u-%u:%u", f.c_str(),
             (unsigned)o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             (unsigned)o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return std::string(buf);
}

static void emitNets(const char* view, const std::string& key,
                     const std::vector<net*>* v) {
    size_t n = v ? v->size() : 0;
    printf("ARITY|%s|%s|nets|%zu|%s\n", view, key.c_str(), n,
           v ? "vec" : "NULLVEC");
    if (!v) return;
    for (size_t i = 0; i < n; i++) {
        const net* nt = (*v)[i];
        printf("NET|%s|%s|%zu|%s|%s|nt=%d|rnt=%d|impl=%d|sgn=%d|ts=%s%s\n",
               view, key.c_str(), i,
               std::string(UhdmName(nt->UhdmType())).c_str(),
               std::string(nt->VpiName()).c_str(), (int)nt->VpiNetType(),
               (int)nt->VpiResolvedNetType(), (int)nt->VpiImplicitDecl(),
               (int)nt->VpiSigned(), tsface(nt->Typespec()).c_str(),
               spanOf(nt).c_str());
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
        printf("VAR|%s|%s|%zu|%s|%s|auto=%d|vis=%d|ts=%s%s\n", view,
               key.c_str(), i, std::string(UhdmName(vr->UhdmType())).c_str(),
               std::string(vr->VpiName()).c_str(), (int)vr->VpiAutomatic(),
               (int)vr->VpiVisibility(), tsface(vr->Typespec()).c_str(),
               spanOf(vr).c_str());
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr,
                "usage: ct219net <db.uhdm> [--inst=SUB] [--vars] [--spans]\n");
        return 2;
    }
    std::string want;
    bool wantVars = false;
    for (int i = 2; i < argc; i++) {
        std::string a(argv[i]);
        if (a.rfind("--inst=", 0) == 0) want = a.substr(7);
        else if (a == "--vars") wantVars = true;
        else if (a == "--spans") g_spans = true;
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
