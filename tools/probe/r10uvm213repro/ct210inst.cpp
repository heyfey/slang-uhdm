// r10uvm210 — THE VIEW-CROSSING READER.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole acceptance judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// WHY IT EXISTS.  `typespec::Compare` (generated typespec.cpp) reads
// `Instance()` — a typespec points BACK at the scope it belongs to — so a
// database's DEF-view listing can drag the judge into a package, and if the two
// writers' back-pointers name DIFFERENT VIEWS of the same package the judge ends
// up comparing golden's DEF listing against our ELABORATED one.  Nothing in the
// cmp log says that happened: it prints the failed pair and no route.  These
// modes read the back-pointers directly.
//
//   --tsinst <db>            every typespec with a non-null Instance, as a
//                            joinable key `<kind>|<name>|<line:col> -> <view>:<pkg>`
//   --pa-inst <db> <scopeId> every param_assign of that scope with the Rhs
//                            constant's typespec and the Instance that typespec
//                            names (this is what makes a cell RECURSE)
//   --rhsof <db> <id>        every listing whose param_assign Rhs (or the
//                            param_assign itself) is that UhdmId — the sharing
//                            map the cmp log cannot show
//   --refto <db> <tsId>      every ref_typespec whose Actual_typespec is that id,
//                            with its parent and grandparent
//
// build: g++ -O2 -std=c++17 ct210inst.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct210inst
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
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
            for (auto* x : *d->AllPackages()) gView[x] = "ALLPKG";
        if (d->TopPackages())
            for (auto* x : *d->TopPackages())
                gView[x] = gView.count(x) ? "BOTHPKG" : "TOPPKG";
        if (d->AllModules())
            for (auto* x : *d->AllModules()) gView[x] = "ALLMOD";
        if (d->TopModules())
            for (auto* x : *d->TopModules())
                gView[x] = gView.count(x) ? "BOTHMOD" : "TOPMOD";
    }
}

static std::string viewOf(const BaseClass* o) {
    if (!o) return "NONE";
    auto it = gView.find(o);
    return (it == gView.end() ? std::string("-") : it->second) + ":" +
           std::string(o->VpiName());
}

static std::string face(const BaseClass* o) {
    if (!o) return "<null>";
    char b[400];
    snprintf(b, sizeof b, "%s '%s' id=%u @%u:%u",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(), (unsigned)o->UhdmId(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct210inst --tsinst  <db>\n"
                "       ct210inst --pa-inst <db> <scopeId>\n"
                "       ct210inst --rhsof   <db> <uhdmId>\n"
                "       ct210inst --refto   <db> <typespecId>\n");
        return 2;
    }
    std::string mode = argv[1];
    Serializer s;
    if (s.Restore(std::string(argv[2])).empty()) {
        printf("RESTORE_FAIL %s\n", argv[2]);
        return 1;
    }
    markViews(s);
    unsigned want = argc >= 4 ? (unsigned)strtoul(argv[3], nullptr, 10) : 0u;

    if (mode == "--tsinst") {
        long n = 0;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o) continue;
            const typespec* t = any_cast<const typespec*>(o);
            if (!t) continue;
            const BaseClass* in = (const BaseClass*)t->Instance();
            if (!in) continue;
            ++n;
            printf("TSI %s|%s|%u:%u -> %s\n",
                   std::string(UhdmName(t->UhdmType())).c_str(),
                   std::string(t->VpiName()).c_str(), t->VpiLineNo(),
                   (unsigned)t->VpiColumnNo(), viewOf(in).c_str());
        }
        printf("-- TSINST %s n=%ld\n", argv[2], n);
        return 0;
    }

    if (mode == "--pa-inst") {
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || (unsigned)o->UhdmId() != want) continue;
            const scope* sc = any_cast<const scope*>(o);
            if (!sc || !sc->Param_assigns()) continue;
            const auto& V = *sc->Param_assigns();
            long withInst = 0;
            for (size_t i = 0; i < V.size(); ++i) {
                const param_assign* pa = V[i];
                if (!pa) continue;
                const any* r = pa->Rhs();
                const ref_typespec* rt = nullptr;
                if (r && r->UhdmType() == uhdmconstant)
                    rt = ((const constant*)r)->Typespec();
                const typespec* at = rt ? rt->Actual_typespec() : nullptr;
                const BaseClass* in = at ? (const BaseClass*)at->Instance() : nullptr;
                if (in) ++withInst;
                printf("PA[%zu] lhs='%s' rhs=%s actual-ts=%s INSTANCE=%s\n", i,
                       pa->Lhs() ? std::string(pa->Lhs()->VpiName()).c_str() : "?",
                       r ? std::string(UhdmName(r->UhdmType())).c_str() : "none",
                       at ? std::string(UhdmName(at->UhdmType())).c_str() : "none",
                       in ? viewOf(in).c_str() : "NONE");
            }
            printf("-- PA-INST scope=%s cells=%zu WITH-INSTANCE=%ld\n",
                   face(o).c_str(), V.size(), withInst);
        }
        return 0;
    }

    if (mode == "--rhsof") {
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o) continue;
            const scope* sc = any_cast<const scope*>(o);
            if (!sc || !sc->Param_assigns()) continue;
            const auto& V = *sc->Param_assigns();
            for (size_t i = 0; i < V.size(); ++i) {
                const param_assign* pa = V[i];
                if (!pa) continue;
                const any* r = pa->Rhs();
                if (!((r && (unsigned)r->UhdmId() == want) ||
                      (unsigned)pa->UhdmId() == want))
                    continue;
                printf("HIT owner=%s view=%s PA[%zu]/%zu paid=%u lhs='%s' "
                       "rhs=%s rhsid=%u\n",
                       face(o).c_str(), viewOf(o).c_str(), i, V.size(),
                       (unsigned)pa->UhdmId(),
                       pa->Lhs() ? std::string(pa->Lhs()->VpiName()).c_str() : "?",
                       r ? std::string(UhdmName(r->UhdmType())).c_str() : "none",
                       r ? (unsigned)r->UhdmId() : 0u);
            }
        }
        return 0;
    }

    if (mode == "--refto") {
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o) continue;
            const ref_typespec* rt = any_cast<const ref_typespec*>(o);
            if (!rt) continue;
            const typespec* at = rt->Actual_typespec();
            if (!at || (unsigned)at->UhdmId() != want) continue;
            const any* p = rt->VpiParent();
            const any* g = p ? p->VpiParent() : nullptr;
            printf("REFTS id=%u full='%s'\n   parent %s\n   grandp %s\n",
                   (unsigned)rt->UhdmId(),
                   std::string(rt->VpiFullName()).c_str(), face(p).c_str(),
                   face(g).c_str());
        }
        return 0;
    }

    fprintf(stderr, "unknown mode %s\n", mode.c_str());
    return 2;
}
