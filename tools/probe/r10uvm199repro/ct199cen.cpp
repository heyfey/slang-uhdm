// r10uvm199 — THE MATERIALIZED-COPY TYPESPEC-PRESENCE CENSUS and MOVER
// PREDICTOR.  MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE CELL.  One `parameter` carrying a non-empty `vpiImported` (a
// MATERIALIZED IMPORT COPY), in one of TWO SLOTS:
//
//   slot P  — an element of the owning scope's `Parameters` vector
//   slot L  — the `Lhs` of an element of the owning scope's `Param_assigns`
//
// The two slots are kept APART in the key because they are two distinct
// objects on our side (`up` and `upLhs9` in `src/ParamEmit.cpp`) and the
// judge walks both vectors (`scope::Compare`: `Parameters` is the eleventh
// vector, `Param_assigns` the twelfth).
//
// The PAYLOAD is the parameter's TYPESPEC KIND — "-" when
// `parameter::Typespec()` is null, "<unbound>" when the ref has no actual,
// else the actual typespec's UHDM kind name.  `parameter::Compare` reads
// `Typespec` through the generated singular `SafeCompare` overload, so a
// present-vs-absent typespec is a one-field head naming the side that HAS it.
//
// THE DECLARED-TYPE KIND is carried alongside every L cell as
// `<constType>/<rhsSize>` of the `param_assign` Rhs constant, which is how a
// database shows the declaration shape: an UNSIZED BASED literal reduces to
// `VpiSize -1` (§ unsizedBasedParamRhsSize106) while a sized/typed one
// carries its real width.
//
// TWO MODES.
//
//   --pred <ours.uhdm> <rowtag>
//       OURS-ONLY, so it runs on every database our binary produces, golden
//       or no golden.  It prints every cell this pass's law can move: a
//       DEF-view materialized copy whose slot-L parameter CARRIES a typespec
//       while its own slot-P twin (same owner, same name) carries NONE.
//       That asymmetry is the exact signature of `upLhs9`'s ungated
//       `Typespec(prtLhs9)` running past § implicitUnsizedBasedNoTs102's
//       decline on `up`.  A database with any such cell is a PREDICTED MOVER.
//
//   --cen <golden.uhdm> <ours.uhdm> <rowtag>
//       THE COMPARE-VISIBLE CENSUS.  Cells are joined as MULTISETS on
//       (view, owner face, param name, vpiImported, slot, declared-type kind)
//       — ids, spans and fullnames are NOT in the key (no generated Compare
//       reads them), and the TYPESPEC KIND is deliberately NOT in the key so
//       a typespec disagreement shows up as a TS row rather than as two
//       one-sided keys.  Keys present on one side only are reported as
//       GOLDEN-ONLY / OURS-ONLY.
//
// VIEW.  Taken from the design's own listings — AllModules/AllPackages are
// the DEFINITION listings, TopModules/TopPackages the ELABORATED ones — never
// guessed from a name.  An object reachable from neither is tagged `other`.
//
// build: g++ -O2 -std=c++17 ct199cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct199cen
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

// The typespec KIND behind a parameter's ref_typespec, or "-" when absent.
static std::string tsKind(const parameter* p) {
    if (!p) return "-";
    const ref_typespec* rt = p->Typespec();
    if (!rt) return "-";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "<unbound>";
    return std::string(UhdmName(a->UhdmType()));
}

// The declared-type kind as a DATABASE can show it: the Rhs constant's
// const type and its size.  `-1` size on a based literal IS the
// unsized-based declaration shape.
static std::string declKind(const any* rhs) {
    if (!rhs) return "norhs";
    if (rhs->UhdmType() != uhdmconstant)
        return std::string("rhs:") + std::string(UhdmName(rhs->UhdmType()));
    const constant* c = (const constant*)rhs;
    char b[64];
    snprintf(b, sizeof b, "ct%d/sz%d", (int)c->VpiConstType(),
             (int)c->VpiSize());
    return b;
}

struct Cell {
    std::string key;  // view|owner|name|imported|slot|declKind
    std::string ts;   // payload
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

// Every materialized-import parameter cell in one database, both slots.
// `pOnly` collects, per (owner,name), the slot-P typespec kinds — the
// predictor needs the twin.
static void harvest(Serializer& s, std::vector<Cell>& out,
                    std::map<std::string, std::multiset<std::string>>* pTwin,
                    std::map<std::string, std::string>* viewOf) {
    std::map<const BaseClass*, std::string> view;
    markViews(s, view);
    // Slot P: the scope's own Parameters vector.
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const VectorOfany* pars = nullptr;
        const VectorOfparam_assign* pas = nullptr;
        if (const scope* sc = any_cast<const scope*>(o)) {
            if (const instance* in = any_cast<const instance*>(o)) {
                pars = (const VectorOfany*)in->Parameters();
            }
            pas = sc->Param_assigns();
        }
        std::string vw = "other";
        {
            auto it = view.find(o);
            if (it != view.end()) vw = it->second;
        }
        if (pars) {
            for (const any* a : *pars) {
                if (!a || a->UhdmType() != uhdmparameter) continue;
                const parameter* p = (const parameter*)a;
                if (p->VpiImported().empty()) continue;
                Cell c;
                c.key = vw + "|" + ownerKey(o) + "|" +
                        std::string(p->VpiName()) + "|" +
                        std::string(p->VpiImported()) + "|P|-";
                c.ts = tsKind(p);
                out.push_back(c);
                if (pTwin)
                    (*pTwin)[ownerKey(o) + "|" + std::string(p->VpiName())]
                        .insert(c.ts);
                if (viewOf)
                    (*viewOf)[ownerKey(o) + "|" + std::string(p->VpiName())] = vw;
            }
        }
        if (pas) {
            for (const param_assign* pa : *pas) {
                if (!pa) continue;
                const any* l = pa->Lhs();
                if (!l || l->UhdmType() != uhdmparameter) continue;
                const parameter* p = (const parameter*)l;
                if (p->VpiImported().empty()) continue;
                Cell c;
                c.key = vw + "|" + ownerKey(o) + "|" +
                        std::string(p->VpiName()) + "|" +
                        std::string(p->VpiImported()) + "|L|" +
                        declKind(pa->Rhs());
                c.ts = tsKind(p);
                out.push_back(c);
            }
        }
    }
}

static int predMode(const char* db, const char* tag) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) {
        printf("PRED-RESTORE_FAIL %s\n", tag);
        return 3;
    }
    std::map<const BaseClass*, std::string> view;
    markViews(s, view);
    long cells = 0, moved = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const instance* in = any_cast<const instance*>(o);
        if (!in) continue;
        std::string vw = "other";
        {
            auto it = view.find(o);
            if (it != view.end()) vw = it->second;
        }
        // Slot-P typespec presence, by name.
        std::map<std::string, bool> pHasTs;
        std::map<std::string, bool> pSeen;
        if (in->Parameters())
            for (const any* a : *in->Parameters()) {
                if (!a || a->UhdmType() != uhdmparameter) continue;
                const parameter* p = (const parameter*)a;
                if (p->VpiImported().empty()) continue;
                std::string n(p->VpiName());
                pSeen[n] = true;
                if (p->Typespec()) pHasTs[n] = true;
            }
        if (!in->Param_assigns()) continue;
        for (const param_assign* pa : *in->Param_assigns()) {
            if (!pa) continue;
            const any* l = pa->Lhs();
            if (!l || l->UhdmType() != uhdmparameter) continue;
            const parameter* p = (const parameter*)l;
            if (p->VpiImported().empty()) continue;
            ++cells;
            std::string n(p->VpiName());
            if (!p->Typespec()) continue;
            if (!pSeen.count(n)) continue;   // no twin to mirror
            if (pHasTs.count(n)) continue;   // twin has one too: not ours
            ++moved;
            printf("PRED %s TSASYM key=%s|%s|%s|%s|L|%s\n", tag, vw.c_str(),
                   ownerKey(o).c_str(), n.c_str(),
                   std::string(p->VpiImported()).c_str(),
                   declKind(pa->Rhs()).c_str());
        }
    }
    printf("PREDSUM %s cells=%ld ts-asym-cells=%ld %s\n", tag, cells, moved,
           moved ? "PREDICTED-MOVER" : "no-move");
    return 0;
}

static int cenMode(const char* gdb, const char* odb, const char* tag) {
    Serializer sg, so;
    if (sg.Restore(std::string(gdb)).empty()) { printf("CEN-RESTORE_FAIL golden %s\n", tag); return 3; }
    if (so.Restore(std::string(odb)).empty()) { printf("CEN-RESTORE_FAIL ours %s\n", tag); return 3; }
    std::vector<Cell> G, O;
    harvest(sg, G, nullptr, nullptr);
    harvest(so, O, nullptr, nullptr);
    // MULTISET, key -> ts-kind multiset.  Keys collide by construction (a
    // file-scope import materialises each item TWICE, and a generate-loop
    // instance array puts many owners behind one face), so the payloads are
    // aggregated per key on both sides and joined as multisets.
    std::map<std::string, std::map<std::string, int>> Gm, Om;
    for (auto& c : G) Gm[c.key][c.ts]++;
    for (auto& c : O) Om[c.key][c.ts]++;
    long agree = 0, tsDiff = 0, gOnly = 0, oOnly = 0;
    std::set<std::string> keys;
    for (auto& [k, v] : Gm) keys.insert(k);
    for (auto& [k, v] : Om) keys.insert(k);
    for (const auto& k : keys) {
        auto gi = Gm.find(k);
        auto oi = Om.find(k);
        if (gi == Gm.end()) {
            long n = 0; for (auto& [t, c] : oi->second) n += c;
            oOnly += n;
            printf("ONLY-OURS %s key=%s n=%ld\n", tag, k.c_str(), n);
            continue;
        }
        if (oi == Om.end()) {
            long n = 0; for (auto& [t, c] : gi->second) n += c;
            gOnly += n;
            printf("ONLY-GOLDEN %s key=%s n=%ld\n", tag, k.c_str(), n);
            continue;
        }
        std::set<std::string> ts;
        for (auto& [t, c] : gi->second) ts.insert(t);
        for (auto& [t, c] : oi->second) ts.insert(t);
        for (const auto& t : ts) {
            const int g = gi->second.count(t) ? gi->second[t] : 0;
            const int o = oi->second.count(t) ? oi->second[t] : 0;
            agree += g < o ? g : o;
            if (g != o) {
                tsDiff += (g > o ? g - o : o - g);
                printf("TS %s key=%s ts=%s G=%d O=%d\n", tag, k.c_str(),
                       t.c_str(), g, o);
            }
        }
    }
    printf("CENSUM %s cellsG=%zu cellsO=%zu AGREE=%ld TS-DIFF=%ld "
           "ONLY-GOLDEN=%ld ONLY-OURS=%ld %s\n",
           tag, G.size(), O.size(), agree, tsDiff, gOnly, oOnly,
           (tsDiff || gOnly || oOnly) ? "UNEQUAL" : "equal");
    return 0;
}

int main(int argc, char** argv) {
    if (argc >= 4 && std::string(argv[1]) == "--pred")
        return predMode(argv[2], argv[3]);
    if (argc >= 5 && std::string(argv[1]) == "--cen")
        return cenMode(argv[2], argv[3], argv[4]);
    fprintf(stderr,
            "usage: ct199cen --pred <ours.uhdm> <tag>\n"
            "       ct199cen --cen <golden.uhdm> <ours.uhdm> <tag>\n");
    return 2;
}
