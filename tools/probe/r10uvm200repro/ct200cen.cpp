// r10uvm200 — the COMPARE-VISIBLE census of `ref_obj::Actual_group` inside the
// listings of every package / module / interface / program of a database.
//
// MEASUREMENT ONLY.  The official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Why a ref_obj census and not a param_assign one: the r10uvm200 head is a
// MIRROR head (`LHS: <null>` over OUR constant), and the edge the judge walked
// is `ref_obj::Actual_group` — the constant's own param_assign compares EQUAL
// on both sides (`ct200own --norhs`: 0 param_assign with a null Rhs in either
// database).  `ref_obj::Compare` reads `Actual_group` (generated
// `ref_obj.cpp`), so the payload here is exactly what the judge reads.
//
// KEY      LISTING | scope | subroutine | holder | refname | refspan
// PAYLOAD  the ACTUAL's kind + its span, or `NONE`
//
// The walk starts at each of the design's own listing vectors and follows the
// official Compare field table (`r10ladder1repro/ctfields.inc`) — never
// VpiParent, which no generated Compare reads.  DEF vs ELAB is IN the key here
// only as the LISTING the scope came out of, which both producers label the
// same way (they are different vectors of `design`, not a property).
//
// build: g++ -O2 -std=c++17 ct200cen.cpp -I ~/.local/include \
//            -I ../r10ladder1repro -L ~/.local/lib64 -L ~/.local/lib \
//            -luhdm -lcapnp -lkj -o ct200cen
// usage: ct200cen <db.uhdm> <tag>          (one CEN| row per ref_obj cell)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

enum FKind { F_TYPE = 0, F_PROP = 1, F_REL1 = 2, F_RELV = 3 };
struct Field { const char* name; int sel; FKind kind; };
static const std::map<std::string, std::vector<Field>> kFields = {
#include "ctfields.inc"
};

[[maybe_unused]] static std::string base(std::string_view p) {
    size_t i = p.find_last_of('/');
    return std::string(i == std::string_view::npos ? p : p.substr(i + 1));
}
// NO FILE in the key: our producer leaves `VpiFile` EMPTY on these objects
// (a long-standing campaign fact), so a file-bearing key can never join.  The
// judge does not read VpiFile either (RESUME §9).
static std::string spanOf(const BaseClass* o) {
    if (!o) return "-";
    char b[64];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string kindName(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}

struct Walker {
    std::set<const BaseClass*> seen;
    std::string listing, scope;
    // the innermost subroutine and the innermost declaration holder seen on
    // the way down — the two names that make a cell identifiable across the
    // two producers without using an id or a pointer.
    void walk(const BaseClass* o, const std::string& sub,
              const std::string& holder, int depth) {
        if (!o || depth > 40) return;
        const UHDM_OBJECT_TYPE t0 = o->UhdmType();
        if (depth > 0 &&
            (t0 == uhdmpackage || t0 == uhdmmodule_inst ||
             t0 == uhdminterface_inst || t0 == uhdmprogram || t0 == uhdmdesign))
            return;
        if (!seen.insert(o).second) return;
        const UHDM_OBJECT_TYPE t = o->UhdmType();
        std::string sub2 = sub, holder2 = holder;
        if (t == uhdmfunction || t == uhdmtask)
            sub2 = kindName(o) + "(" + std::string(o->VpiName()) + ")";
        else if (t == uhdmio_decl || t == uhdmclass_defn)
            holder2 = kindName(o) + "(" + std::string(o->VpiName()) + ")";
        else if (kindName(o).size() > 4 &&
                 kindName(o).rfind("_var") == kindName(o).size() - 4)
            holder2 = kindName(o) + "(" + std::string(o->VpiName()) + ")";
        if (t == uhdmref_obj) {
            const any* a = ((const ref_obj*)o)->Actual_group();
            printf("CEN|%s|%s|%s|%s|%s|%s|%s|%s\n", listing.c_str(),
                   scope.c_str(), sub2.c_str(), holder2.c_str(),
                   std::string(o->VpiName()).c_str(), spanOf(o).c_str(),
                   a ? kindName((const BaseClass*)a).c_str() : "NONE",
                   a ? spanOf((const BaseClass*)a).c_str() : "-");
        }
        auto it = kFields.find(kindName(o));
        if (it == kFields.end()) return;
        for (const Field& f : it->second) {
            if (!f.sel) continue;
            // CENSUS TRAP (RESUME §9): following a cross-scope pointer
            // attributes another listing's cells to this one — golden's clone
            // SHARES the home's Return variable, so a naive walk reported the
            // home's bound range cells a second time under the importing
            // package and manufactured phantom disagreements.  The payload of
            // an `Actual_group` / `Instance` edge is RECORDED, never entered,
            // and a nested scope object ends the walk.
            if (!strcmp(f.name, "Actual_group") || !strcmp(f.name, "Instance"))
                continue;
            if (f.kind == F_REL1) {
                if (const BaseClass* c =
                        std::get<0>(o->GetByVpiType(f.sel)))
                    walk(c, sub2, holder2, depth + 1);
            } else if (f.kind == F_RELV) {
                if (auto* v = std::get<2>(o->GetByVpiType(f.sel)))
                    for (auto* e : *v)
                        if (e) walk((const BaseClass*)e, sub2, holder2,
                                    depth + 1);
            }
        }
    }
};

template <typename V>
static void doListing(const char* name, const V* v) {
    if (!v) return;
    for (auto* sc : *v) {
        if (!sc) continue;
        Walker w;
        w.listing = name;
        w.scope = kindName(sc) + "(" + std::string(sc->VpiName()) + ")";
        w.walk((const BaseClass*)sc, "-", "-", 0);
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: ct200cen <db.uhdm> [tag]\n");
        return 2;
    }
    Serializer s;
    if (s.Restore(std::string(argv[1])).empty()) {
        fprintf(stderr, "RESTORE_FAIL %s\n", argv[1]);
        return 3;
    }
    const design* d = topDesign(s);
    if (!d) { fprintf(stderr, "NO_DESIGN\n"); return 3; }
    doListing("defpkg", d->AllPackages());
    doListing("elabpkg", d->TopPackages());
    doListing("defmod", d->AllModules());
    doListing("elabmod", d->TopModules());
    doListing("defiface", d->AllInterfaces());
    doListing("defprog", d->AllPrograms());
    return 0;
}
