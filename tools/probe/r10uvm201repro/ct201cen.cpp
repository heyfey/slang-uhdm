// r10uvm201 — THE param_assign Rhs-CONSTANT TYPESPEC CENSUS and MOVER
// PREDICTOR.  MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole acceptance judge.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// THE CELL.  One `param_assign` whose `Lhs` is a `parameter` and whose `Rhs`
// is a `constant`, in any scope of the database.  The PAYLOAD is the pair
//
//      <Rhs constant's typespec kind> / <Lhs parameter's typespec kind>
//
// "-" when the object carries no `ref_typespec` at all, "<unbound>" when the
// ref has no actual, else the actual typespec's UHDM kind name.
//
// WHY THE PAIR.  `constant` derives from `expr`, and `expr::Compare`
// (UHDM/build/generated/src/expr.cpp) reads `Typespec` — so a present-vs-
// absent typespec on a folded Rhs constant is a ONE-FIELD head naming the
// side that has it.  Surelog mints ONE `typespec` per parameter declaration
// and attaches it to BOTH the parameter and the folded constant
// (CompileHelper.cpp: `param->Typespec()->Actual_typespec(ts)` in the
// implicit-type switch, then `c->Typespec()->Actual_typespec(ts)` right
// after), so the two halves are not independent and a census that watched
// only one of them could not tell a repair from a swap.  Carrying both in the
// payload makes r10uvm199's already-converged parameter half a GUARD: any
// movement there shows up as a TS row too.
//
// THE KEY is (view, owner face, parameter name, vpiImported, DEFAULT FORM),
// where the DEFAULT FORM is the Rhs constant's `<constType>/<size>` — how a
// database shows a declaration's shape (an UNSIZED BASED literal reduces to
// `VpiSize -1`, § unsizedBasedParamRhsSize106; a sized or typed one carries
// its real width).  Ids, spans and fullnames are NOT in the key: no generated
// `Compare` reads them.  The typespec kinds are deliberately NOT in the key,
// so a disagreement shows up as a TS row rather than as two one-sided keys.
//
// THREE MODES.
//
//   --pred <ours.uhdm> <rowtag>
//       OURS-ONLY, so it runs on every database our binary produces, golden
//       or no golden.  It prints every cell where the Lhs parameter CARRIES a
//       typespec while its own folded Rhs CONSTANT carries NONE (class
//       `RHSGAP`), and every cell where the reverse holds (class `LHSGAP`).
//       A database with any such cell is a PREDICTED MOVER.
//
//   --list <db> <rowtag>
//       every cell of ONE database with its payload, so a GOLDEN TABLE is
//       READ OFF rather than inferred from a diff.
//
//   --cen <golden.uhdm> <ours.uhdm> <rowtag>
//       THE COMPARE-VISIBLE CENSUS, a MULTISET join (keys collide by
//       construction — a file-scope import materialises each item TWICE and a
//       generate-loop instance array puts many owners behind one face), so
//       payloads are aggregated per key on both sides.  Keys present on one
//       side only are reported as GOLDEN-ONLY / OURS-ONLY.
//
// VIEW.  Taken from the design's own listings — AllModules/AllPackages are
// the DEFINITION listings, TopModules/TopPackages the ELABORATED ones — never
// guessed from a name.  An object reachable from neither is tagged `other`.
//
// build: g++ -O2 -std=c++17 ct201cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct201cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

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

static std::string tsOfParam(const parameter* p) {
    if (!p) return "-";
    const ref_typespec* rt = p->Typespec();
    if (!rt) return "-";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "<unbound>";
    return std::string(UhdmName(a->UhdmType()));
}

static std::string tsOfConst(const constant* c) {
    if (!c) return "-";
    const ref_typespec* rt = c->Typespec();
    if (!rt) return "-";
    const typespec* a = rt->Actual_typespec();
    if (!a) return "<unbound>";
    return std::string(UhdmName(a->UhdmType()));
}

// The DEFAULT FORM as a database can show it.
static std::string declForm(const constant* c) {
    char b[64];
    snprintf(b, sizeof b, "ct%d/sz%d", (int)c->VpiConstType(),
             (int)c->VpiSize());
    return b;
}

struct Cell {
    std::string key;
    std::string pay;
};

static void markViews(Serializer& s,
                      std::map<const BaseClass*, std::string>& v) {
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

static void harvest(Serializer& s, std::vector<Cell>& out) {
    std::map<const BaseClass*, std::string> view;
    markViews(s, view);
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const scope* sc = any_cast<const scope*>(o);
        if (!sc || !sc->Param_assigns()) continue;
        std::string vw = "other";
        {
            auto it = view.find(o);
            if (it != view.end()) vw = it->second;
        }
        for (const param_assign* pa : *sc->Param_assigns()) {
            if (!pa) continue;
            const any* l = pa->Lhs();
            const any* r = pa->Rhs();
            if (!l || l->UhdmType() != uhdmparameter) continue;
            if (!r || r->UhdmType() != uhdmconstant) continue;
            const parameter* p = (const parameter*)l;
            const constant* c = (const constant*)r;
            Cell cell;
            cell.key = vw + "|" + ownerKey(o) + "|" +
                       std::string(p->VpiName()) + "|" +
                       (p->VpiImported().empty()
                            ? std::string("-")
                            : std::string(p->VpiImported())) +
                       "|" + declForm(c);
            cell.pay = tsOfConst(c) + "/" + tsOfParam(p);
            out.push_back(cell);
        }
    }
}

// --list: every cell of ONE database with its payload, so a GOLDEN TABLE can
// be read off directly instead of inferred from a diff.
static int listMode(const char* db, const char* tag) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) {
        printf("LIST-RESTORE_FAIL %s\n", tag);
        return 3;
    }
    std::vector<Cell> C;
    harvest(s, C);
    std::map<std::string, std::map<std::string, int>> M;
    for (auto& c : C) M[c.key][c.pay]++;
    for (auto& [k, v] : M)
        for (auto& [t, n] : v)
            printf("LIST %s key=%s pay=%s n=%d\n", tag, k.c_str(), t.c_str(),
                   n);
    printf("LISTSUM %s cells=%zu keys=%zu\n", tag, C.size(), M.size());
    return 0;
}

static int predMode(const char* db, const char* tag) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) {
        printf("PRED-RESTORE_FAIL %s\n", tag);
        return 3;
    }
    std::map<const BaseClass*, std::string> view;
    markViews(s, view);
    long cells = 0, rhsGap = 0, lhsGap = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        const scope* sc = any_cast<const scope*>(o);
        if (!sc || !sc->Param_assigns()) continue;
        std::string vw = "other";
        {
            auto it = view.find(o);
            if (it != view.end()) vw = it->second;
        }
        for (const param_assign* pa : *sc->Param_assigns()) {
            if (!pa) continue;
            const any* l = pa->Lhs();
            const any* r = pa->Rhs();
            if (!l || l->UhdmType() != uhdmparameter) continue;
            if (!r || r->UhdmType() != uhdmconstant) continue;
            const parameter* p = (const parameter*)l;
            const constant* c = (const constant*)r;
            ++cells;
            const bool pt = p->Typespec() != nullptr;
            const bool ct = c->Typespec() != nullptr;
            if (pt == ct) continue;
            const char* cls = pt ? "RHSGAP" : "LHSGAP";
            if (pt) ++rhsGap; else ++lhsGap;
            printf("PRED %s %s key=%s|%s|%s|%s|%s pay=%s/%s\n", tag, cls,
                   vw.c_str(), ownerKey(o).c_str(),
                   std::string(p->VpiName()).c_str(),
                   p->VpiImported().empty()
                       ? "-"
                       : std::string(p->VpiImported()).c_str(),
                   declForm(c).c_str(), tsOfConst(c).c_str(),
                   tsOfParam(p).c_str());
        }
    }
    printf("PREDSUM %s cells=%ld RHSGAP=%ld LHSGAP=%ld %s\n", tag, cells,
           rhsGap, lhsGap,
           (rhsGap || lhsGap) ? "PREDICTED-MOVER" : "no-move");
    return 0;
}

static int cenMode(const char* gdb, const char* odb, const char* tag) {
    Serializer sg, so;
    if (sg.Restore(std::string(gdb)).empty()) {
        printf("CEN-RESTORE_FAIL golden %s\n", tag);
        return 3;
    }
    if (so.Restore(std::string(odb)).empty()) {
        printf("CEN-RESTORE_FAIL ours %s\n", tag);
        return 3;
    }
    std::vector<Cell> G, O;
    harvest(sg, G);
    harvest(so, O);
    std::map<std::string, std::map<std::string, int>> Gm, Om;
    for (auto& c : G) Gm[c.key][c.pay]++;
    for (auto& c : O) Om[c.key][c.pay]++;
    long agree = 0, tsDiff = 0, gOnly = 0, oOnly = 0;
    std::set<std::string> keys;
    for (auto& [k, v] : Gm) keys.insert(k);
    for (auto& [k, v] : Om) keys.insert(k);
    for (const auto& k : keys) {
        auto gi = Gm.find(k);
        auto oi = Om.find(k);
        if (gi == Gm.end()) {
            long n = 0;
            for (auto& [t, c] : oi->second) n += c;
            oOnly += n;
            printf("ONLY-OURS %s key=%s n=%ld\n", tag, k.c_str(), n);
            continue;
        }
        if (oi == Om.end()) {
            long n = 0;
            for (auto& [t, c] : gi->second) n += c;
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
                printf("TS %s key=%s pay=%s G=%d O=%d\n", tag, k.c_str(),
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
    if (argc >= 4 && std::string(argv[1]) == "--list")
        return listMode(argv[2], argv[3]);
    if (argc >= 5 && std::string(argv[1]) == "--cen")
        return cenMode(argv[2], argv[3], argv[4]);
    fprintf(stderr,
            "usage: ct201cen --pred <ours.uhdm> <tag>\n"
            "       ct201cen --list <db> <tag>\n"
            "       ct201cen --cen <golden.uhdm> <ours.uhdm> <tag>\n");
    return 2;
}
