// r10uvm163 — ct163cen: the CENSUS of every class-PROPERTY class_typespec and
// the specialization listing it carries.  MEASUREMENT ONLY; the judge is
// ~/git-repos/UHDM/build/bin/uhdm-cmp and nothing else.  This tool links the
// SAME UHDM library and only READS.
//
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
//
// WHAT IT PRINTS, one row per class_typespec whose VpiParent is a VARIABLE
// (a class property / a package or module variable / a method local — the
// declaration sites where Surelog's `compileTypespec` slStringConst arm runs):
//
//   CELL <key> | nparam=<n> | params=<name:actualkind:actualname,...>
//              | npa=<n> | holder=<kind> | cdefn=<the target class_defn's
//              VpiFullName, i.e. Surelog's registry spelling> | cdp=<that
//              class_defn's own formal count> | home=<the parent chain>
//
// THE KEY is (typespec VpiName, VpiLineNo, VpiColumnNo, holder VpiName, holder
// VpiLineNo:VpiColumnNo).  It is deliberately NOT the end column: r10uvm53's
// § classPkgGenericSpecListing53 narrows the END of the span at listing sites
// and leaves it wide elsewhere, so an end-column-keyed census would refuse to
// pair exactly the cells this pass measures.  It is deliberately NOT
// VpiFullName either: the uhdm dump SYNTHESIZES that from the parent chain
// (RESUME.md §9) and the two sides parent their objects differently in places.
//
// EVERY ROW IS PRINTED — there is NO dedup here.  Golden clones a package
// variable's declaration typespec once per elaborated copy (25 keys in
// Scoreboard's golden carry 2-4 identical rows), so a last-writer map would
// DROP rows and a set join would then manufacture ONLY-G phantoms
// (RESUME.md §9, census traps).  `score163.py` does the MULTISET join.
//
// GUARDS (each one an ops trap this campaign has paid for):
//   * refuses to report on a database it restored to ZERO class_typespec —
//     an instrument that reaches nothing must never read as clean;
//   * prints the object COUNTS it walked so a truncated restore is visible;
//   * `--selftest` asserts the reader on a hand-built in-memory database with
//     one 2-parameter and one null-vector cell, a non-variable holder that must
//     be SKIPPED, and a repeated key that must appear TWICE.
//
// build: g++ -O2 -std=c++17 ct163cen.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct163cen
// usage: ct163cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <cstring>
#include <algorithm>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindName(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}

// The actual typespec behind a type_parameter's ref_typespec.
static const typespec* actualOf(const type_parameter* tp) {
    if (!tp) return nullptr;
    const ref_typespec* rt = tp->Typespec();
    return rt ? rt->Actual_typespec() : nullptr;
}

static bool isVariable(const BaseClass* o) {
    return o && any_cast<const variables*>(o) != nullptr;
}

struct Row {
    std::string key, params, holder, chain, cdefn;
    int nparam = -1;  // -1 = the vector is NULL
    int npa = -1;
    int cdp = 0;      // the TARGET class_defn's own formal count
};

// `all=false` keeps only the DECLARATION-site typespecs whose holder is a
// variable — the class-property / package-variable census this pass scores.
// `all=true` keeps EVERY class_typespec, holder or none: at MODULE scope our
// emitter (and Surelog) leave the object UNPARENTED (measured on
// ClassParamAsParam: `\_class_typespec: (config_db)` with no vpiParent on both
// sides), so the mover PREDICTION has to see those too or it would be blind to
// a whole declaration site.
static void collect(Serializer& s, std::vector<Row>& out,
                    size_t& nCts, size_t& nAll, bool all = false) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        ++nAll;
        if (o->UhdmType() != uhdmclass_typespec) continue;
        ++nCts;
        const class_typespec* cts = (const class_typespec*)o;
        const BaseClass* par = cts->VpiParent();
        if (!all && !isVariable(par)) continue;  // only DECLARATION-site typespecs
        char kb[1200];
        snprintf(kb, sizeof kb, "%s@%u:%u|%s@%u:%u", std::string(cts->VpiName()).c_str(),
                 cts->VpiLineNo(), (unsigned)cts->VpiColumnNo(),
                 par ? std::string(par->VpiName()).c_str() : "-",
                 par ? par->VpiLineNo() : 0u,
                 par ? (unsigned)par->VpiColumnNo() : 0u);
        Row r;
        r.key = kb;
        r.holder = par ? (isVariable(par) ? kindName(par)
                                          : std::string("!") + kindName(par))
                       : std::string("-");
        std::string chain;
        for (const BaseClass* p = par; p; p = p->VpiParent()) {
            chain += "<";
            chain += kindName(p);
            chain += "(";
            chain += std::string(p->VpiName());
            chain += ")";
        }
        r.chain = chain;
        if (const VectorOfany* ps = cts->Parameters()) {
            r.nparam = (int)ps->size();
            for (const any* p : *ps) {
                if (!r.params.empty()) r.params += ",";
                if (!p) { r.params += "<null>"; continue; }
                if (p->UhdmType() != uhdmtype_parameter) {
                    r.params += kindName(p);
                    continue;
                }
                const type_parameter* tp = (const type_parameter*)p;
                const typespec* a = actualOf(tp);
                r.params += std::string(tp->VpiName());
                r.params += ":";
                r.params += a ? kindName(a) : std::string("<noact>");
                r.params += ":";
                r.params += a ? std::string(a->VpiName()) : std::string("-");
            }
        }
        if (const VectorOfparam_assign* pa = cts->Param_assigns())
            r.npa = (int)pa->size();
        // The TARGET generic class, as the database itself records it: its
        // VpiFullName carries Surelog's registry spelling (`<pkg>::<name>` for
        // a package class, `work@<name>` for a $unit one), and its own
        // Parameters vector says whether it is parameterized at all.  These are
        // what pred163.py needs to name the movers a priori.
        if (const class_defn* cd = cts->Class_defn()) {
            r.cdefn = std::string(cd->VpiFullName());
            if (r.cdefn.empty()) r.cdefn = std::string(cd->VpiName());
            r.cdp = cd->Parameters() ? (int)cd->Parameters()->size() : 0;
        }
        out.push_back(r);
    }
}

static int selftest() {
    Serializer s;
    class_defn* cd = s.MakeClass_defn();
    cd->VpiName("gsel");
    class_var* v1 = s.MakeClass_var();
    v1->VpiName("p_two");
    class_typespec* t1 = s.MakeClass_typespec();
    t1->VpiName("gsel");
    t1->VpiLineNo(7);
    t1->VpiColumnNo(3);
    t1->VpiParent(v1);
    t1->Class_defn(cd);
    VectorOfany* ps = s.MakeAnyVec();
    for (const char* n : {"TA", "TB"}) {
        type_parameter* tp = s.MakeType_parameter();
        tp->VpiName(n);
        tp->VpiParent(t1);
        ref_typespec* rt = s.MakeRef_typespec();
        int_typespec* its = s.MakeInt_typespec();
        rt->Actual_typespec(its);
        tp->Typespec(rt);
        ps->push_back(tp);
    }
    t1->Parameters(ps);
    t1->Param_assigns(s.MakeParam_assignVec());
    class_var* v2 = s.MakeClass_var();
    v2->VpiName("p_none");
    class_typespec* t2 = s.MakeClass_typespec();
    t2->VpiName("gsel");
    t2->VpiLineNo(9);
    t2->VpiColumnNo(3);
    t2->VpiParent(v2);
    // a class_typespec parented by something that is NOT a variable must be
    // SKIPPED — this is the negative half of the control.
    class_typespec* t3 = s.MakeClass_typespec();
    t3->VpiName("gsel");
    t3->VpiLineNo(11);
    t3->VpiColumnNo(3);
    t3->VpiParent(cd);
    // t4 REPEATS t2's key exactly — the NO-DEDUP half of the control.
    class_var* v4 = s.MakeClass_var();
    v4->VpiName("p_none");
    class_typespec* t4 = s.MakeClass_typespec();
    t4->VpiName("gsel");
    t4->VpiLineNo(9);
    t4->VpiColumnNo(3);
    t4->VpiParent(v4);
    std::vector<Row> m;
    size_t nc = 0, na = 0;
    collect(s, m, nc, na);
    int rc = 0;
    if (m.size() != 3) { printf("SELFTEST FAIL: rows=%zu want 3\n", m.size()); rc = 1; }
    std::vector<Row> ma;
    size_t nca = 0, naa = 0;
    collect(s, ma, nca, naa, /*all=*/true);
    if (ma.size() != 4) {
        printf("SELFTEST FAIL: --all rows=%zu want 4\n", ma.size());
        rc = 1;
    }
    int nTwo = 0, nNone = 0;
    for (const Row& r : m) {
        if (r.key == "gsel@7:3|p_two@0:0") {
            ++nTwo;
            if (r.nparam != 2 || r.params != "TA:int_typespec:,TB:int_typespec:") {
                printf("SELFTEST FAIL: two-param row wrong (%s)\n", r.params.c_str());
                rc = 1;
            }
        }
        else if (r.key == "gsel@9:3|p_none@0:0") {
            ++nNone;
            if (r.nparam != -1) {
                printf("SELFTEST FAIL: null-vector row not reported as nparam=-1\n");
                rc = 1;
            }
        }
        else { printf("SELFTEST FAIL: unexpected key %s\n", r.key.c_str()); rc = 1; }
    }
    if (nTwo != 1 || nNone != 2) {
        printf("SELFTEST FAIL: multiset lost a row (two=%d none=%d want 1/2)\n",
               nTwo, nNone);
        rc = 1;
    }
    if (nc != 4) { printf("SELFTEST FAIL: walked %zu class_typespec want 4\n", nc); rc = 1; }
    printf(rc ? "SELFTEST FAIL\n"
              : "SELFTEST PASS rows=3 repeated-key-kept=2 skipped-nonvariable=1 "
                "all-rows=4\n");
    return rc;
}

int main(int argc, char** argv) {
    if (argc >= 2 && strcmp(argv[1], "--selftest") == 0) return selftest();
    bool all = false;
    int ai = 1;
    if (argc >= 2 && strcmp(argv[1], "--all") == 0) { all = true; ai = 2; }
    if (argc <= ai) { fprintf(stderr, "usage: ct163cen [--all] <db.uhdm> | --selftest\n"); return 2; }
    Serializer s;
    if (s.Restore(std::string(argv[ai])).empty()) { printf("RESTORE_FAIL %s\n", argv[ai]); return 3; }
    std::vector<Row> m;
    size_t nc = 0, na = 0;
    collect(s, m, nc, na, all);
    if (nc == 0) { printf("FATAL: 0 class_typespec in %s\n", argv[ai]); return 4; }
    // Sorted so two runs of the same database print in the same order; the
    // MULTISET join in score163.py does not depend on it, but a stable order
    // makes a plain `diff` of two listings readable.
    std::sort(m.begin(), m.end(), [](const Row& a, const Row& b) {
        if (a.key != b.key) return a.key < b.key;
        if (a.nparam != b.nparam) return a.nparam < b.nparam;
        return a.params < b.params;
    });
    for (const Row& r : m)
        printf("CELL %s | nparam=%d | params=%s | npa=%d | holder=%s | cdefn=%s | cdp=%d | home=%s\n",
               r.key.c_str(), r.nparam, r.params.c_str(), r.npa, r.holder.c_str(),
               r.cdefn.c_str(), r.cdp, r.chain.c_str());
    printf("-- objects=%zu class_typespec=%zu rows=%zu\n", na, nc, m.size());
    return 0;
}
