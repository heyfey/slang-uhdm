// r10uvm196 — THE MATERIALIZED-IMPORT-PARAMETER CENSUS and MOVER PREDICTOR.
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// TWO MODES.
//
//   --pred  <ours.uhdm> <rowtag>
//       OURS-ONLY, so it runs on EVERY database our binary produces, golden or
//       no golden.  For each instance it prints the packages that instance
//       MATERIALIZED (evidence: at least one entry of the instance's own
//       `Task_funcs` is also an entry of that package's listing, or at least
//       one of its nets carries a package variable's name — the two things
//       `collectMaterializedPkgs` already hoists), that package's own
//       `Parameters` count, and how many `VpiImported` copies of it the
//       instance currently lists.  A PRED row with `ourcopies=0 pkgparams>0`
//       is a cell the law will add, so a database with any such row is a
//       PREDICTED MOVER.
//
//   --cen   <golden.uhdm> <ours.uhdm> <rowtag>
//       THE COMPARE-VISIBLE CENSUS.  Instances are matched on the face the
//       judge reads plus the span (kind, VpiName, VpiDefName, line, col) — the
//       DEF and ELAB views of one module differ in VpiName, so the two stay
//       apart without the view ever entering the key.  Within an instance the
//       `Parameters` and `Param_assigns` vectors are joined as MULTISETS on
//       (name, VpiImported, kind) — ids and spans are NOT in the key (no
//       generated Compare reads them) — and every disagreeing key is printed
//       with its golden and ours counts.
//
// build: g++ -O2 -std=c++17 ct196cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct196cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string instKey(const BaseClass* o) {
    char b[900];
    const std::string k(UhdmName(o->UhdmType()));
    const std::string n(o->VpiName());
    const std::string d(o->VpiDefName());
    snprintf(b, sizeof b, "%s|%s|%s|%u:%u", k.c_str(), n.c_str(), d.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo());
    return b;
}
static void collectInst(Serializer& s, std::vector<const instance*>& out) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (o->UhdmType() == uhdmmodule_inst || o->UhdmType() == uhdminterface_inst ||
            o->UhdmType() == uhdmprogram)
            out.push_back((const instance*)o);
    }
}
static void collectPkg(Serializer& s, std::vector<const package*>& out) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmpackage)
            out.push_back((const package*)kv.first);
}

// ------------------------------- PRED -----------------------------------
static int predMode(const char* db, const char* tag) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) { printf("PRED-RESTORE_FAIL %s\n", tag); return 3; }
    std::vector<const instance*> I;
    std::vector<const package*> P;
    collectInst(s, I);
    collectPkg(s, P);
    // package listing membership, and package variable names, by package NAME
    std::map<std::string, std::set<const BaseClass*>> pkgTf;
    std::map<std::string, std::set<std::string>> pkgVarNames;
    std::map<std::string, size_t> pkgParams;
    for (const package* p : P) {
        const std::string pn(p->VpiName());
        if (p->Task_funcs())
            for (auto* t : *p->Task_funcs()) pkgTf[pn].insert(t);
        if (((const scope*)p)->Variables())
            for (auto* v : *((const scope*)p)->Variables())
                pkgVarNames[pn].insert(std::string(v->VpiName()));
        size_t np = ((const scope*)p)->Parameters() ? ((const scope*)p)->Parameters()->size() : 0;
        if (np > pkgParams[pn]) pkgParams[pn] = np;
    }
    size_t movers = 0;
    for (const instance* in : I) {
        std::set<std::string> mat;
        if (in->Task_funcs())
            for (auto* t : *in->Task_funcs())
                for (auto& [pn, set] : pkgTf)
                    if (set.count(t)) mat.insert(pn);
        if (in->Nets())
            for (auto* n : *in->Nets()) {
                const std::string nn(n->VpiName());
                for (auto& [pn, set] : pkgVarNames)
                    if (set.count(nn)) mat.insert(pn);
            }
        if (((const scope*)in)->Variables())
            for (auto* v : *((const scope*)in)->Variables()) {
                const std::string nn(v->VpiName());
                for (auto& [pn, set] : pkgVarNames)
                    if (set.count(nn)) mat.insert(pn);
            }
        if (mat.empty()) continue;
        for (auto& pn : mat) {
            size_t have = 0;
            if (((const scope*)in)->Parameters())
                for (auto* q : *((const scope*)in)->Parameters())
                    if (q->UhdmType() == uhdmparameter &&
                        std::string(((const parameter*)q)->VpiImported()) == pn)
                        ++have;
            printf("PRED %s inst=%s pkg=%s pkgparams=%zu ourcopies=%zu%s\n", tag,
                   instKey(in).c_str(), pn.c_str(), pkgParams[pn], have,
                   (pkgParams[pn] > 0 && have == 0) ? "  <== CELLS THE LAW ADDS" : "");
            if (pkgParams[pn] > 0 && have == 0) ++movers;
        }
    }
    printf("PREDSUM %s candidate-cells=%zu %s\n", tag, movers,
           movers ? "PREDICTED-MOVER" : "no-move");
    return 0;
}

// ------------------------------- CEN ------------------------------------
static void addP(std::map<std::string, int>& m, const any* p) {
    if (!p) return;
    std::string imp;
    if (p->UhdmType() == uhdmparameter) imp = std::string(((const parameter*)p)->VpiImported());
    m[std::string(UhdmName(p->UhdmType())) + "|" + std::string(p->VpiName()) + "|" + imp]++;
}
static void addA(std::map<std::string, int>& m, const param_assign* a) {
    if (!a || !a->Lhs()) return;
    const any* l = a->Lhs();
    std::string imp;
    if (l->UhdmType() == uhdmparameter) imp = std::string(((const parameter*)l)->VpiImported());
    m[std::string(UhdmName(l->UhdmType())) + "|" + std::string(l->VpiName()) + "|" + imp]++;
}
// Two joins, deliberately.  The TAGGED join keys on (kind, name,
// VpiImported) and separates a MISSING COPY from a MIS-TAGGED one; the
// COUNT join drops the tag and keys on (kind, name) alone, so
// `GOLDEN-ONLY-COUNT` is exactly "copies golden has that we do not have at
// all" — the cells THIS law adds.  Earlgrey is why both exist: its module
// HEADER imports already produce the right NUMBER of copies, and only the
// `vpiImported` tag on one `param_assign` lhs of each pair differs (a
// residue of another family, invisible to the judge — that row's testflags
// mode is CMP_EQUAL).  A tag-only census would have called it a mover.
struct Tally { long agree = 0, gImp = 0, oImp = 0, gOwn = 0, oOwn = 0;
               long gCnt = 0, oCnt = 0; };
static bool isImported(const std::string& key) {
    // key = "<kind>|<name>|<vpiImported>"; imported iff the last field is set
    const size_t p = key.rfind('|');
    return p != std::string::npos && p + 1 < key.size();
}
static void joinPrint(const char* tag, const char* rowtag, const std::string& ik,
                      const char* listing, std::map<std::string, int>& G,
                      std::map<std::string, int>& O, Tally& t) {
    // the COUNT join: the same multisets with the tag dropped from the key
    {
        std::map<std::string, int> Gc, Oc;
        for (auto& [k, v] : G) Gc[k.substr(0, k.rfind('|'))] += v;
        for (auto& [k, v] : O) Oc[k.substr(0, k.rfind('|'))] += v;
        std::set<std::string> ck;
        for (auto& [k, v] : Gc) ck.insert(k);
        for (auto& [k, v] : Oc) ck.insert(k);
        for (auto& k : ck) {
            const int g = Gc.count(k) ? Gc[k] : 0;
            const int o = Oc.count(k) ? Oc[k] : 0;
            if (g > o) t.gCnt += g - o;
            if (o > g) t.oCnt += o - g;
            if (g != o)
                printf("COUNT %s %s inst=%s list=%s key=%s G=%d O=%d\n", tag,
                       rowtag, ik.c_str(), listing, k.c_str(), g, o);
        }
    }
    std::set<std::string> keys;
    for (auto& [k, v] : G) keys.insert(k);
    for (auto& [k, v] : O) keys.insert(k);
    for (auto& k : keys) {
        int g = G.count(k) ? G[k] : 0;
        int o = O.count(k) ? O[k] : 0;
        t.agree += g < o ? g : o;
        const bool imp = isImported(k);
        if (g > o) { (imp ? t.gImp : t.gOwn) += g - o; }
        if (o > g) { (imp ? t.oImp : t.oOwn) += o - g; }
        if (g != o)
            printf("CELL %s %s inst=%s list=%s key=%s G=%d O=%d\n", tag, rowtag,
                   ik.c_str(), listing, k.c_str(), g, o);
    }
}
static int cenMode(const char* gdb, const char* odb, const char* tag) {
    Serializer sg, so;
    if (sg.Restore(std::string(gdb)).empty()) { printf("CEN-RESTORE_FAIL golden %s\n", tag); return 3; }
    if (so.Restore(std::string(odb)).empty()) { printf("CEN-RESTORE_FAIL ours %s\n", tag); return 3; }
    std::vector<const instance*> G, O;
    collectInst(sg, G);
    collectInst(so, O);
    // A MULTISET JOIN AT BOTH LEVELS.  A generate-loop instance array puts
    // MANY instances behind one (kind, VpiName, VpiDefName, span) key —
    // Earlgrey's `aes_sbox|work@aes_sbox_lut|16:5` is sixteen of them — so a
    // last-writer `key -> instance` dict would pair every golden copy against
    // one of ours and manufacture phantoms (RESUME §9).  Every instance
    // sharing a key is therefore AGGREGATED into one bucket per side, and the
    // buckets are joined.
    std::map<std::string, std::map<std::string, int>> GP, OP, GA, OA;
    std::map<std::string, int> gCount, oCount;
    for (const instance* g : G) {
        const std::string ik = instKey(g);
        ++gCount[ik];
        if (((const scope*)g)->Parameters()) for (auto* p : *((const scope*)g)->Parameters()) addP(GP[ik], p);
        if (((const scope*)g)->Param_assigns()) for (auto* a : *((const scope*)g)->Param_assigns()) addA(GA[ik], a);
    }
    for (const instance* o : O) {
        const std::string ik = instKey(o);
        ++oCount[ik];
        if (((const scope*)o)->Parameters()) for (auto* p : *((const scope*)o)->Parameters()) addP(OP[ik], p);
        if (((const scope*)o)->Param_assigns()) for (auto* a : *((const scope*)o)->Param_assigns()) addA(OA[ik], a);
    }
    Tally t;
    long nomatch = 0, arity = 0;
    for (auto& [ik, n] : gCount) {
        if (!oCount.count(ik)) { ++nomatch; continue; }
        if (oCount[ik] != n) {
            ++arity;
            printf("ARITY %s inst=%s goldenInstances=%d oursInstances=%d\n", tag,
                   ik.c_str(), n, oCount[ik]);
        }
        joinPrint("P", tag, ik, "Parameters", GP[ik], OP[ik], t);
        joinPrint("A", tag, ik, "Param_assigns", GA[ik], OA[ik], t);
    }
    printf("CENSUM %s AGREE=%ld GOLDEN-ONLY=%ld OURS-ONLY=%ld "
           "GOLDEN-ONLY-IMPORTED=%ld OURS-ONLY-IMPORTED=%ld "
           "GOLDEN-ONLY-OWN=%ld OURS-ONLY-OWN=%ld GOLDEN-ONLY-COUNT=%ld "
           "OURS-ONLY-COUNT=%ld unmatched-golden-keys=%ld arity-mismatches=%ld %s\n",
           tag, t.agree, t.gImp + t.gOwn, t.oImp + t.oOwn, t.gImp, t.oImp,
           t.gOwn, t.oOwn, t.gCnt, t.oCnt, nomatch, arity,
           t.gCnt ? "PREDICTED-MOVER" : "no-move");
    return 0;
}

// ------------------------------- OBJ -----------------------------------
// THE WHOLE-DATABASE OBJECT CENSUS, one row per UHDM kind.  The dump is a poor
// attribution instrument for an ADDITIVE law (a new parameter's block repeats
// field names that appear everywhere), so the honest statement is at the
// OBJECT level: exactly which kinds were created, and how many.  Run on the
// pristine and the patched database, the deltas ARE the law's footprint.
static int objMode(const char* db, const char* tag) {
    Serializer s;
    if (s.Restore(std::string(db)).empty()) { printf("OBJ-RESTORE_FAIL %s\n", tag); return 3; }
    std::map<std::string, long> n;
    long tot = 0;
    for (auto& kv : s.AllObjects()) {
        if (!kv.first) continue;
        ++n[UhdmName(kv.first->UhdmType())];
        ++tot;
    }
    for (auto& [k, v] : n) printf("OBJ %s %s %ld\n", tag, k.c_str(), v);
    printf("OBJTOT %s %ld\n", tag, tot);
    return 0;
}

int main(int argc, char** argv) {
    if (argc >= 4 && std::string(argv[1]) == "--obj")
        return objMode(argv[2], argv[3]);
    if (argc >= 4 && std::string(argv[1]) == "--pred")
        return predMode(argv[2], argv[3]);
    if (argc >= 5 && std::string(argv[1]) == "--cen")
        return cenMode(argv[2], argv[3], argv[4]);
    fprintf(stderr, "usage: ct196cen --pred <ours> <tag> | --cen <golden> <ours> <tag>\n");
    return 2;
}
