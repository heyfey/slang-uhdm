// r10uvm213 — THE ROUTE FINDER.  MEASUREMENT ONLY; the official
// `~/git-repos/UHDM/build/bin/uhdm-cmp` on the whole design is the sole
// acceptance judge, and this tool runs the SAME generated `design::Compare` it
// runs.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// WHY IT EXISTS.  `uhdm-cmp` prints the failed PAIR and never the ROUTE, and
// `CompareContext::m_visited` is keyed on the **LHS** only
// (`if (!context->m_visited.insert(this).second) return r;` at the head of
// every generated Compare), so a golden object reached a second time through a
// different link is SILENTLY EQUAL whatever the right-hand side is.  That makes
// "which link produced this pair" unanswerable by reading the log and
// answerable by MASK-AND-RERUN: seed one golden object into `m_visited` before
// the run and see whether the head changes.
//
//   ct213route --head   <g> <o>              the whole-design compare, the pair
//   ct213route --mask   <g> <o> <id>...      the same with those GOLDEN ids
//                                            pre-seeded into m_visited
//   ct213route --vec    <g> <o>              each design-level vector element
//                                            compared on its OWN fresh context,
//                                            so the entry point can be named
//   ct213route --pair   <g> <o> <gid> <oid>  one arbitrary pair, fresh context
//
// A masked object is NOT removed from the database: masking only tells the
// compare "treat this LHS as already agreed", which is exactly what the second
// visit does anyway.  Counts and heads from a masked run are therefore
// evidence about the ROUTE, never about correctness.
//
// build: g++ -O2 -std=c++17 ct213route.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct213route
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstdlib>
#include <map>
#include <string>
#include <vector>

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

static const design* theDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

static std::string chain(const BaseClass* o) {
    std::vector<const BaseClass*> up;
    for (int d = 0; o && d < 200; ++d, o = (const BaseClass*)o->VpiParent())
        up.push_back(o);
    std::string out;
    for (size_t i = up.size(); i-- > 0;) {
        const BaseClass* x = up[i];
        if (!out.empty()) out += "<";
        out += std::string(UhdmName(x->UhdmType()));
        if (!x->VpiName().empty()) out += ":" + std::string(x->VpiName());
        auto it = gView.find(x);
        if (it != gView.end()) out += "[" + it->second + "]";
    }
    return out.empty() ? std::string("<root>") : out;
}

static void face(const char* tag, const BaseClass* o) {
    if (!o) {
        printf("%s <null>\n", tag);
        return;
    }
    printf("%s %s '%s' id=%u @%u:%u\n   %s\n", tag,
           std::string(UhdmName(o->UhdmType())).c_str(),
           std::string(o->VpiName()).c_str(), (unsigned)o->UhdmId(),
           o->VpiLineNo(), (unsigned)o->VpiColumnNo(), chain(o).c_str());
}

static const BaseClass* byId(Serializer& s, unsigned id) {
    for (auto& kv : s.AllObjects())
        if (kv.first && (unsigned)kv.first->UhdmId() == id) return kv.first;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 4) {
        fprintf(stderr,
                "usage: ct213route --head <g> <o>\n"
                "       ct213route --mask <g> <o> <goldenId>...\n"
                "       ct213route --vec  <g> <o>\n"
                "       ct213route --pair <g> <o> <gid> <oid>\n");
        return 2;
    }
    std::string mode = argv[1];
    Serializer sg, so;
    if (sg.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL g\n"); return 1; }
    if (so.Restore(std::string(argv[3])).empty()) { printf("RESTORE_FAIL o\n"); return 1; }
    markViews(sg);
    markViews(so);
    const design* G = theDesign(sg);
    const design* O = theDesign(so);
    if (!G || !O) { printf("NO_DESIGN\n"); return 1; }

    if (mode == "--pa") {
        // --pa <g|o> <scopeId> [idx] : the param_assign OBJECT ids of a scope,
        // which the cmp log never prints and every mask experiment needs.
        Serializer& s = (std::string(argv[4]) == "g") ? sg : so;
        unsigned scopeId = (unsigned)strtoul(argv[5], nullptr, 10);
        long want = argc >= 7 ? strtol(argv[6], nullptr, 10) : -1;
        for (auto& kv : s.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || (unsigned)o->UhdmId() != scopeId) continue;
            const scope* sc = any_cast<const scope*>(o);
            if (!sc || !sc->Param_assigns()) continue;
            const auto& V = *sc->Param_assigns();
            for (size_t i = 0; i < V.size(); ++i) {
                if (want >= 0 && (size_t)want != i) continue;
                const param_assign* pa = V[i];
                printf("PA[%zu] paid=%u lhs='%s' rhs=%s rhsid=%u\n", i,
                       (unsigned)pa->UhdmId(),
                       pa->Lhs() ? std::string(pa->Lhs()->VpiName()).c_str() : "?",
                       pa->Rhs() ? std::string(UhdmName(pa->Rhs()->UhdmType())).c_str() : "none",
                       pa->Rhs() ? (unsigned)pa->Rhs()->UhdmId() : 0u);
            }
        }
        return 0;
    }

    if (mode == "--pair") {
        const BaseClass* a = byId(sg, (unsigned)strtoul(argv[4], nullptr, 10));
        const BaseClass* b = byId(so, (unsigned)strtoul(argv[5], nullptr, 10));
        if (!a || !b) { printf("NOT_FOUND\n"); return 1; }
        CompareContext c;
        int32_t r = a->Compare(b, &c);
        printf("PAIR r=%d\n", r);
        face("LHS", c.m_failedLhs);
        face("RHS", c.m_failedRhs);
        return 0;
    }

    if (mode == "--vec") {
        auto run = [&](const char* nm, const std::vector<package*>* a,
                       const std::vector<package*>* b) {
            if (!a || !b || a->size() != b->size()) {
                printf("VEC %s SIZE %zu/%zu\n", nm, a ? a->size() : 0,
                       b ? b->size() : 0);
                return;
            }
            for (size_t i = 0; i < a->size(); ++i) {
                CompareContext c;
                int32_t r = (*a)[i]->Compare((*b)[i], &c);
                printf("VEC %s[%zu] '%s' r=%d\n", nm, i,
                       std::string((*a)[i]->VpiName()).c_str(), r);
                if (r) { face("  LHS", c.m_failedLhs); face("  RHS", c.m_failedRhs); }
            }
        };
        run("AllPackages", G->AllPackages(), O->AllPackages());
        run("TopPackages", G->TopPackages(), O->TopPackages());
        auto runc = [&](const char* nm, const std::vector<class_defn*>* a,
                        const std::vector<class_defn*>* b) {
            if (!a || !b || a->size() != b->size()) {
                printf("VEC %s SIZE %zu/%zu\n", nm, a ? a->size() : 0,
                       b ? b->size() : 0);
                return;
            }
            for (size_t i = 0; i < a->size(); ++i) {
                CompareContext c;
                int32_t r = (*a)[i]->Compare((*b)[i], &c);
                if (r) {
                    printf("VEC %s[%zu] '%s' r=%d\n", nm, i,
                           std::string((*a)[i]->VpiName()).c_str(), r);
                    face("  LHS", c.m_failedLhs);
                    face("  RHS", c.m_failedRhs);
                }
            }
        };
        runc("AllClasses", G->AllClasses(), O->AllClasses());
        auto runm = [&](const char* nm, const std::vector<module_inst*>* a,
                        const std::vector<module_inst*>* b) {
            if (!a || !b || a->size() != b->size()) {
                printf("VEC %s SIZE %zu/%zu\n", nm, a ? a->size() : 0,
                       b ? b->size() : 0);
                return;
            }
            for (size_t i = 0; i < a->size(); ++i) {
                CompareContext c;
                int32_t r = (*a)[i]->Compare((*b)[i], &c);
                printf("VEC %s[%zu] '%s' r=%d\n", nm, i,
                       std::string((*a)[i]->VpiName()).c_str(), r);
                if (r) { face("  LHS", c.m_failedLhs); face("  RHS", c.m_failedRhs); }
            }
        };
        runm("AllModules", G->AllModules(), O->AllModules());
        runm("TopModules", G->TopModules(), O->TopModules());
        return 0;
    }

    CompareContext c;
    int nmask = 0;
    if (mode == "--mask")
        for (int i = 4; i < argc; ++i) {
            const BaseClass* a = byId(sg, (unsigned)strtoul(argv[i], nullptr, 10));
            if (!a) { printf("MASK_NOT_FOUND %s\n", argv[i]); continue; }
            c.m_visited.insert(a);
            printf("MASKED %s '%s' id=%s\n",
                   std::string(UhdmName(a->UhdmType())).c_str(),
                   std::string(a->VpiName()).c_str(), argv[i]);
            ++nmask;
        }
    int32_t r = G->Compare(O, &c);
    printf("DESIGN r=%d masked=%d\n", r, nmask);
    face("LHS", c.m_failedLhs);
    face("RHS", c.m_failedRhs);
    return 0;
}
