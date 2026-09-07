// r10uvm197 — THE MATERIALIZED-PARAMETER CONSTANT-SIZE CENSUS and MOVER
// PREDICTOR.  MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE CELL.  One `param_assign` whose Lhs is a `parameter` carrying a
// non-empty `vpiImported` (a MATERIALIZED IMPORT COPY) and whose Rhs is a
// `constant`.  Its payload is the constant's `VpiSize` — the field
// `expr::Compare` reads ahead of every `constant` field
// (~/git-repos/UHDM/build/generated/src/expr.cpp:95).
//
// TWO MODES.
//
//   --pred <ours.uhdm> <rowtag>
//       OURS-ONLY, so it runs on every database our binary produces, golden
//       or no golden.  Prints every cell whose constant carries VpiSize 0 —
//       the exact signature the def-view type-width stamp leaves on a
//       parameter whose declared type has no width — with its view, its
//       typespec kind, its const type and its value.  A database with any
//       such cell is a PREDICTED MOVER.
//
//   --cen <golden.uhdm> <ours.uhdm> <rowtag>
//       THE COMPARE-VISIBLE CENSUS.  Cells are joined as MULTISETS on
//       (view, owner face, param name, vpiImported, typespec kind, const
//       type, value) — ids and spans are NOT in the key (no generated
//       Compare reads them), and the SIZE is deliberately NOT in the key so
//       a size disagreement shows up as a SIZE row rather than as two
//       one-sided keys.  Keys present on one side only are reported as
//       GOLDEN-ONLY / OURS-ONLY.
//
// VIEW.  Taken from the design's own listings — AllModules/AllPackages are
// the DEFINITION listings, TopModules/TopPackages the ELABORATED ones — never
// guessed from a name.  An object reachable from neither is tagged `other`.
//
// build: g++ -O2 -std=c++17 ct197cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct197cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

// The face the judge reads on the OWNER, plus its span, so the DEF and the
// ELAB object of one module never share a bucket even when their names agree.
static std::string ownerKey(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s|%s|%s|%u:%u",
             std::string(UhdmName(o->UhdmType())).c_str(),
             std::string(o->VpiName()).c_str(),
             std::string(o->VpiDefName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo());
    return b;
}

// The typespec KIND behind a parameter's ref_typespec, or "-" when unbound.
static std::string tsKind(const parameter* p) {
    if (!p) return "-";
    const ref_typespec* rt = p->Typespec();
    if (!rt) return "-";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "<unbound>";
    return std::string(UhdmName(a->UhdmType()));
}

struct Cell {
    std::string key;   // view|owner|name|imported|tsKind|constType|value
    int32_t size = 0;
};

// Mark every instance/package with the design listing it came from.
static void markViews(Serializer& s, std::map<const BaseClass*, std::string>& v) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmdesign) continue;
        const design* d = (const design*)o;
        if (d->AllModules())    for (auto* x : *d->AllModules())    v[x] = "def";
        if (d->TopModules())    for (auto* x : *d->TopModules())    v[x] = "elab";
        if (d->AllPackages())   for (auto* x : *d->AllPackages())   v[x] = "defpkg";
        if (d->TopPackages())   for (auto* x : *d->TopPackages())   v[x] = "elabpkg";
        if (d->AllInterfaces()) for (auto* x : *d->AllInterfaces()) v[x] = "defif";
        if (d->AllPrograms())   for (auto* x : *d->AllPrograms())   v[x] = "defprog";
    }
}

// Every materialized-import cell in one database.
static void harvest(Serializer& s, std::vector<Cell>& out) {
    std::map<const BaseClass*, std::string> view;
    markViews(s, view);
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmparam_assign) continue;
        const param_assign* a = (const param_assign*)o;
        const any* l = a->Lhs();
        const any* r = a->Rhs();
        if (!l || l->UhdmType() != uhdmparameter) continue;
        const parameter* p = (const parameter*)l;
        if (p->VpiImported().empty()) continue;      // not a materialized copy
        if (!r || r->UhdmType() != uhdmconstant) continue;
        const constant* c = (const constant*)r;
        const BaseClass* own = a->VpiParent();
        std::string vw = "other";
        if (own) { auto it = view.find(own); if (it != view.end()) vw = it->second; }
        Cell cell;
        cell.key = vw + "|" + ownerKey(own) + "|" + std::string(p->VpiName()) +
                   "|" + std::string(p->VpiImported()) + "|" + tsKind(p) + "|" +
                   std::to_string(c->VpiConstType()) + "|" +
                   std::string(c->VpiValue());
        cell.size = c->VpiSize();
        out.push_back(cell);
    }
}

static int predMode(const char* db, const char* tag) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) {
        printf("PRED-RESTORE_FAIL %s\n", tag);
        return 3;
    }
    std::vector<Cell> C;
    harvest(s, C);
    long zero = 0;
    std::map<std::string, long> byTs;
    for (auto& c : C) {
        ++byTs["ALL"];
        if (c.size != 0) continue;
        ++zero;
        printf("PRED %s ZEROSIZE key=%s\n", tag, c.key.c_str());
    }
    printf("PREDSUM %s cells=%ld zero-size-cells=%ld %s\n", tag, byTs["ALL"],
           zero, zero ? "PREDICTED-MOVER" : "no-move");
    return 0;
}

static int cenMode(const char* gdb, const char* odb, const char* tag) {
    Serializer sg, so;
    if (sg.Restore(std::string(gdb)).empty()) { printf("CEN-RESTORE_FAIL golden %s\n", tag); return 3; }
    if (so.Restore(std::string(odb)).empty()) { printf("CEN-RESTORE_FAIL ours %s\n", tag); return 3; }
    std::vector<Cell> G, O;
    harvest(sg, G);
    harvest(so, O);
    // MULTISET, key -> size multiset.  Keys collide by construction (a
    // generate-loop instance array puts many owners behind one face), so the
    // sizes are aggregated per key on both sides and joined as multisets.
    std::map<std::string, std::map<int32_t, int>> Gm, Om;
    for (auto& c : G) Gm[c.key][c.size]++;
    for (auto& c : O) Om[c.key][c.size]++;
    long agree = 0, sizeDiff = 0, gOnly = 0, oOnly = 0;
    std::set<std::string> keys;
    for (auto& [k, v] : Gm) keys.insert(k);
    for (auto& [k, v] : Om) keys.insert(k);
    for (const auto& k : keys) {
        auto gi = Gm.find(k);
        auto oi = Om.find(k);
        if (gi == Gm.end()) {
            long n = 0; for (auto& [sz, c] : oi->second) n += c;
            oOnly += n;
            printf("ONLY-OURS %s key=%s n=%ld\n", tag, k.c_str(), n);
            continue;
        }
        if (oi == Om.end()) {
            long n = 0; for (auto& [sz, c] : gi->second) n += c;
            gOnly += n;
            printf("ONLY-GOLDEN %s key=%s n=%ld\n", tag, k.c_str(), n);
            continue;
        }
        // join the size multisets
        std::set<int32_t> sizes;
        for (auto& [sz, c] : gi->second) sizes.insert(sz);
        for (auto& [sz, c] : oi->second) sizes.insert(sz);
        for (int32_t sz : sizes) {
            const int g = gi->second.count(sz) ? gi->second[sz] : 0;
            const int o = oi->second.count(sz) ? oi->second[sz] : 0;
            agree += g < o ? g : o;
            if (g != o) {
                sizeDiff += (g > o ? g - o : o - g);
                printf("SIZE %s key=%s size=%d G=%d O=%d\n", tag, k.c_str(),
                       (int)sz, g, o);
            }
        }
    }
    printf("CENSUM %s cellsG=%zu cellsO=%zu AGREE=%ld SIZE-DIFF=%ld "
           "ONLY-GOLDEN=%ld ONLY-OURS=%ld %s\n",
           tag, G.size(), O.size(), agree, sizeDiff, gOnly, oOnly,
           (sizeDiff || gOnly || oOnly) ? "UNEQUAL" : "equal");
    return 0;
}

int main(int argc, char** argv) {
    if (argc >= 4 && std::string(argv[1]) == "--pred")
        return predMode(argv[2], argv[3]);
    if (argc >= 5 && std::string(argv[1]) == "--cen")
        return cenMode(argv[2], argv[3], argv[4]);
    fprintf(stderr,
            "usage: ct197cen --pred <ours.uhdm> <tag>\n"
            "       ct197cen --cen <golden.uhdm> <ours.uhdm> <tag>\n");
    return 2;
}
