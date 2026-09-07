// r10uvm200 — the A-PRIORI PREDICTOR: which databases § impCloneDeclRangeNoBind200
// can move, decided from a PRISTINE database alone, before the patched binary
// exists.
//
// MEASUREMENT ONLY.  The official `uhdm-cmp` is the sole judge.
//
// The criterion is the one the emitter rewrites, expressed in the database the
// PRISTINE emitter produced:
//
//   a `ref_obj` in the declared TYPE RANGE of an `io_decl` or a body VARIABLE
//   of a subroutine listed under a PACKAGE, where that declaration's own
//   typespec carries `vpiInstance` = a DIFFERENT package (the import-clone
//   stamp our emitter writes as `importCopyTsInst`), and the ref CARRIES an
//   actual.
//
//   STRICT  = those cells (they lose the actual)
//   WIDE    = the same declarations' range refs whatever they bind (the bound
//             the criterion can only UNDER-predict against)
//
// The RETURN variable is deliberately NOT scanned: the clone lists the home
// package's own return object, which the law never touches.
//
// build: g++ -O2 -std=c++17 ct200pred.cpp -I ~/.local/include \
//            -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//            -luhdm -lcapnp -lkj -o ct200pred
// usage: ct200pred <db.uhdm>      -> "STRICT <n> WIDE <m>" plus one line/cell
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <utility>
#include <string>
#include <vector>

using namespace UHDM;

enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field { const char* name; int sel; FKind kind; };
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};

static std::string kindName(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static const BaseClass* rel1(const BaseClass* o, const char* nm) {
    if (!o) return nullptr;
    auto it = kFields.find(kindName(o));
    if (it == kFields.end()) return nullptr;
    for (const Field& f : it->second)
        if (f.kind == F_REL1 && !strcmp(f.name, nm) && f.sel)
            return std::get<0>(o->GetByVpiType(f.sel));
    return nullptr;
}
static void relv(const BaseClass* o, const char* nm,
                 std::vector<const BaseClass*>& out) {
    if (!o) return;
    auto it = kFields.find(kindName(o));
    if (it == kFields.end()) return;
    for (const Field& f : it->second)
        if (f.kind == F_RELV && !strcmp(f.name, nm) && f.sel)
            if (auto* v = std::get<2>(o->GetByVpiType(f.sel)))
                for (auto* e : *v)
                    if (e) out.push_back((const BaseClass*)e);
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

static size_t g_strict = 0, g_wide = 0, g_modCells = 0;
// Task_func objects a MODULE / INTERFACE / PROGRAM listing holds.  Our emitter
// lets an EXPLICIT `import p::f` clone displace the package's elaborated twin
// in `pkgElabSubTf`, so a module importing the same package LISTS that clone
// object — and § impCloneDeclRangeNoBind200 deliberately does NOT reach it
// (the fence in UhdmExporter.h, measured as grid arm D's three AWAY cells).
// Excluding those objects here is what makes the prediction match the law
// rather than the wider clone population.
static std::set<const BaseClass*> g_modListed;
// ...and the (importing package, subroutine name) pairs it convicts: the
// displaced twin is listed in ONE of the package's two views, so both views'
// copies have to be excluded together.
static std::set<std::pair<std::string, std::string>> g_expPairs;
static bool g_mark = false;

// one declaration (io_decl or variable): decide the clone stamp from its own
// typespec, then count its range refs.
static void doDecl(const char* listing, const std::string& pkgName,
                   const std::string& fn, const BaseClass* decl) {
    const BaseClass* rt = rel1(decl, "Typespec");
    const BaseClass* ts = rt ? rel1(rt, "Actual_typespec") : nullptr;
    if (!ts) return;
    const BaseClass* inst = rel1(ts, "Instance");
    if (!inst) return;
    if (inst->UhdmType() != uhdmpackage) return;
    if (std::string(inst->VpiName()) == pkgName) return;  // the home's own copy
    std::vector<const BaseClass*> rgs;
    relv(ts, "Ranges", rgs);
    for (const BaseClass* rg : rgs) {
        for (const char* side : {"Left_expr", "Right_expr"}) {
            // one level of operation nesting is enough for every corpus shape
            // measured (`[P:0]`, `[P-1:0]`, `[P*2:0]`); deeper trees only make
            // the WIDE bound smaller, never the STRICT set wrong, because a
            // missed cell cannot become a predicted mover.
            std::vector<const BaseClass*> cand;
            if (const BaseClass* b = rel1(rg, side)) cand.push_back(b);
            for (size_t i = 0; i < cand.size() && i < 64; i++) {
                const BaseClass* n = cand[i];
                if (n->UhdmType() == uhdmoperation) {
                    std::vector<const BaseClass*> ops;
                    relv(n, "Operands", ops);
                    for (auto* o : ops) cand.push_back(o);
                    continue;
                }
                if (n->UhdmType() != uhdmref_obj) continue;
                const any* a = ((const ref_obj*)n)->Actual_group();
                ++g_wide;
                if (a) ++g_strict;
                printf("%s %-8s pkg=%-24s fn=%-40s decl=%-28s ref=%-24s "
                       "home=%-20s actual=%s\n",
                       a ? "PREDCELL" : "WIDEONLY", listing, pkgName.c_str(),
                       fn.c_str(),
                       (kindName(decl) + "(" + std::string(decl->VpiName()) +
                        ")").c_str(),
                       std::string(n->VpiName()).c_str(),
                       std::string(inst->VpiName()).c_str(),
                       a ? kindName((const BaseClass*)a).c_str() : "-");
            }
        }
    }
}

static void doScope(const char* listing, const BaseClass* pk) {
    const std::string pkgName(pk->VpiName());
    std::vector<const BaseClass*> tfs;
    relv(pk, "Task_funcs", tfs);
    // class methods live under the package's class_defns too
    std::vector<const BaseClass*> cds;
    relv(pk, "Class_defns", cds);
    for (const BaseClass* cd : cds) relv(cd, "Task_funcs", tfs);
    for (const BaseClass* tf : tfs) {
        if (!tf) continue;
        if (g_mark) {
            if (g_modListed.count(tf))
                g_expPairs.emplace(pkgName, std::string(tf->VpiName()));
            continue;
        }
        // REPORTING ONLY (a refuted exclusion, kept as a measurement).  A
        // module-listed clone object was tried as the marker of the EXPLICIT
        // `import p::f` displacement the law is fenced against — and it is
        // NOT one: a module that wildcard-imports a CLONE-BEARING package
        // lists that package's own clones too (`materializedPkgTfGroup`), and
        // golden lists exactly the same objects there, so SeqDriver's whole
        // population is module-listed and legitimately moves.  The count is
        // printed to BOUND the criterion's over-coverage, never to skip a
        // cell.
        g_modCells += g_modListed.count(tf) ||
                      g_expPairs.count({pkgName, std::string(tf->VpiName())})
                          ? 1 : 0;
        const std::string fn(tf->VpiName());
        std::vector<const BaseClass*> decls;
        relv(tf, "Io_decls", decls);
        relv(tf, "Variables", decls);
        // block-item locals hang off the body's begin/named_begin
        std::vector<const BaseClass*> stack;
        if (const BaseClass* st = rel1(tf, "Stmt")) stack.push_back(st);
        for (size_t i = 0; i < stack.size() && i < 4096; i++) {
            const BaseClass* n = stack[i];
            relv(n, "Variables", decls);
            std::vector<const BaseClass*> kids;
            relv(n, "Stmts", kids);
            for (auto* k : kids) stack.push_back(k);
        }
        for (const BaseClass* d : decls) doDecl(listing, pkgName, fn, d);
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct200pred <db.uhdm> [row tag]\n");
        return 2;
    }
    const char* row = argc > 2 ? argv[2] : "-";
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        printf("RESTORE_FAIL %s\n", row);
        return 3;
    }
    const design* d = topDesign(s);
    if (!d) { printf("NO_DESIGN %s\n", row); return 3; }
    auto collect = [&](const auto* v) {
        if (!v) return;
        for (auto* m : *v) {
            std::vector<const BaseClass*> tfs;
            relv((const BaseClass*)m, "Task_funcs", tfs);
            for (auto* t : tfs) g_modListed.insert(t);
        }
    };
    collect(d->AllModules());
    collect(d->TopModules());
    collect(d->AllInterfaces());
    collect(d->AllPrograms());
    g_mark = true;
    if (auto* v = d->AllPackages())
        for (auto* p : *v) doScope("defpkg", p);
    if (auto* v = d->TopPackages())
        for (auto* p : *v) doScope("elabpkg", p);
    g_mark = false;
    if (auto* v = d->AllPackages())
        for (auto* p : *v) doScope("defpkg", p);
    if (auto* v = d->TopPackages())
        for (auto* p : *v) doScope("elabpkg", p);
    printf("PREDCELLS %-28s strict=%zu wide=%zu modlisted-tfs=%zu\n", row,
           g_strict, g_wide, g_modCells);
    return 0;
}
