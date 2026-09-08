// r10v210 — VERIFIER's OWN crossing reader.  MEASUREMENT ONLY.
// For each design package listing (AllPackages = DEF, TopPackages = ELAB),
// print every param_assign cell's Rhs typespec Instance back-pointer with the
// VIEW of the scope it names.  This is the decisive measurement the pass's
// ROUTE.txt summarised but never printed per cell.
//
// build: g++ -O2 -std=c++17 ctv210.cpp -I ~/.local/include -L ~/.local/lib64 \
//            -L ~/.local/lib -luhdm -lcapnp -lkj -o ctv210
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <string>

using namespace UHDM;

static std::map<const BaseClass*, std::string> gView;

static void markViews(Serializer& s) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (d->AllPackages())
            for (auto* x : *d->AllPackages()) gView[x] = "DEFPKG";
        if (d->TopPackages())
            for (auto* x : *d->TopPackages())
                gView[x] = gView.count(x) ? "BOTHPKG" : "ELABPKG";
        if (d->AllModules())
            for (auto* x : *d->AllModules()) gView[x] = "DEFMOD";
        if (d->TopModules())
            for (auto* x : *d->TopModules())
                gView[x] = gView.count(x) ? "BOTHMOD" : "ELABMOD";
    }
}

static std::string viewOf(const BaseClass* o) {
    if (!o) return "NONE";
    auto it = gView.find(o);
    char b[256];
    snprintf(b, sizeof b, "%s:%s(id=%u)",
             it == gView.end() ? "-" : it->second.c_str(),
             std::string(o->VpiName()).c_str(), (unsigned)o->UhdmId());
    return b;
}

// Every param_assign of a named listing, with the Rhs typespec's Instance.
static void paInst(Serializer& s, const char* pkgName, const char* wantView) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmpackage) continue;
        if (std::string(o->VpiName()) != pkgName) continue;
        auto it = gView.find(o);
        std::string vw = it == gView.end() ? "-" : it->second;
        if (strcmp(wantView, vw.c_str()) != 0) continue;
        const scope* sc = (const scope*)(const any*)o;
        if (!sc->Param_assigns()) continue;
        const auto& V = *sc->Param_assigns();
        printf("== listing %s id=%u cells=%zu\n", vw.c_str(),
               (unsigned)o->UhdmId(), V.size());
        for (size_t i = 0; i < V.size(); ++i) {
            const param_assign* pa = V[i];
            if (!pa) continue;
            const any* r = pa->Rhs();
            const ref_typespec* rt = nullptr;
            if (r && r->UhdmType() == uhdmconstant)
                rt = ((const constant*)r)->Typespec();
            const typespec* at = rt ? rt->Actual_typespec() : nullptr;
            const BaseClass* in = at ? (const BaseClass*)at->Instance() : nullptr;
            if (!in) continue;  // only the RECURSING cells
            printf("  PA[%zu] lhs=%-22s rhs=%s tsid=%u ts=%s INSTANCE=%s\n", i,
                   pa->Lhs() ? std::string(pa->Lhs()->VpiName()).c_str() : "?",
                   std::string(UhdmName(r->UhdmType())).c_str(),
                   (unsigned)at->UhdmId(),
                   std::string(UhdmName(at->UhdmType())).c_str(),
                   viewOf(in).c_str());
        }
    }
}

// Every typespec with an Instance, grouped: kind|name|line:col -> view of instance
static void tsInstCensus(Serializer& s) {
    std::map<std::string, long> m;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const typespec* t = any_cast<const typespec*>(o);
        if (!t) continue;
        const BaseClass* in = (const BaseClass*)t->Instance();
        if (!in) continue;
        auto it = gView.find(in);
        char b[512];
        snprintf(b, sizeof b, "%s|%s|%u:%u -> %s:%s",
                 std::string(UhdmName(t->UhdmType())).c_str(),
                 std::string(t->VpiName()).c_str(), t->VpiLineNo(),
                 (unsigned)t->VpiColumnNo(),
                 it == gView.end() ? "-" : it->second.c_str(),
                 std::string(in->VpiName()).c_str());
        m[b]++;
    }
    for (auto& kv : m) printf("TSI %6ld  %s\n", kv.second, kv.first.c_str());
    printf("-- TSI DISTINCT KEYS %zu\n", m.size());
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ctv210 --painst <db> <pkgname> <DEFPKG|ELABPKG>\n"
                "       ctv210 --tsi    <db>\n");
        return 2;
    }
    std::string mode = argv[1];
    Serializer s;
    if (s.Restore(std::string(argv[2])).empty()) {
        printf("RESTORE_FAIL %s\n", argv[2]);
        return 1;
    }
    markViews(s);
    if (mode == "--painst" && argc >= 5) {
        paInst(s, argv[3], argv[4]);
        return 0;
    }
    if (mode == "--tsi") {
        tsInstCensus(s);
        return 0;
    }
    fprintf(stderr, "bad args\n");
    return 2;
}
