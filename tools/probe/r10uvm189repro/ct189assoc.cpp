// r10uvm189 — THE ASSOCIATIVE-ARRAY RANGE-BOUND CENSUS AND OWNER-FINDER.
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge;
// this tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// MODE `own <golden> <ours>`  — decode the judge:
//   run the OFFICIAL design::Compare, print the head on both sides with its
//   full parent chain, then scan BOTH databases for every edge that lands on
//   the head object (`GetByVpiType`, the generated kind-agnostic edge
//   accessor, so no field is named by hand and none can be missed), and print
//   the head's owner declaration on both sides.
//
// MODE `cen <db> [name-substr]` — one row per RANGE that is an
//   ARRAY-DECLARATION DIMENSION BOUND, i.e. a `range` whose right bound is
//   either
//     * the ASSOCIATIVE MARKER — `constant STRING:associative`, vpiConstType 6,
//       optionally carrying the dimension's index typespec through a
//       `ref_typespec`; or
//     * the SIZE MODEL — `operation vpiSubOp(11)` over a `ref_obj` and an
//       `INT:1` constant, which is what Surelog's `compileRanges` leaves when
//       the bracket text compiled as a constant_expression and `reduce` was
//       `Reduce::No` (`CompileExpression.cpp:4096-4150`); or
//     * the QUEUE / UNSIZED markers, carried so the population's neighbours
//       are visible and cannot be confused with a mover.
//
// THE OWNER INDEX (pass 1).  A declaration range hangs off either the
// `array_var` (a class property, § emitAssocDims) or the `array_typespec`
// (a subroutine local, § assocLocalArrayVar40), and an `array_typespec`
// carries NO VpiParent on our side, so a bottom-up walk from the range dies.
// Pass 1 therefore maps every `array_typespec` back to the `array_var` /
// `typespec_member` / `variables` object that owns it through its
// `ref_typespec`, and the LISTING is read off THAT object's parent chain.
// Without the index every listing collapses into one bucket and a residue in
// one listing masquerades as a mover in another (RESUME §9, uvm186's note).
//
// KEY (id-free, and SPAN-FREE ON THE RANGE ITSELF — the two producers span the
// promoted range at the whole bracket and the size range at the selector, so a
// range-span key cannot join the two forms it exists to compare):
//
//     LISTING | OWNER-KIND | OWNER-LINE:COL | OWNER-NAME | DIM#
//
// VALUE (the full compared shape at identity granularity — never a
// three-valued verdict, so a move between two WRONG shapes cannot hide):
//
//     arrayType=<n> idxTs=<face> | <right-bound form>
//
// Values are joined as a MULTISET per key: a wildcard-import clone is listed
// TWICE under one root and a dictionary keyed by position alone drops the
// second copy (RESUME §9).
//
// build: g++ -O2 -std=c++17 ct189assoc.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct189assoc
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <map>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u", kindOf(o).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static std::string face(const BaseClass* o) {
    if (!o) return "NONE";
    char b[600];
    snprintf(b, sizeof b, "%s(%s)@%u:%u", kindOf(o).c_str(),
             std::string(o->VpiName()).c_str(), o->VpiLineNo(),
             (unsigned)o->VpiColumnNo());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
// THE VIEW a package object belongs to.  Surelog compiles a package TWICE —
// the elaborated `Package` with `Reduce::Yes` (design.TopPackages) and the
// `getUnElabPackage()` twin with `Reduce::No` (design.AllPackages)
// (`CompilePackage.cpp` FunctorCompilePackage; § pkgRetTsListing127) — and the
// whole question this pass asks is which of the two a listing is, so the census
// must never merge them.
static std::map<const BaseClass*, std::string> g_pkgView;
static void indexPkgViews(Serializer& S) {
    const design* d = nullptr;
    for (auto& kv : S.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign) d = (const design*)kv.first;
    if (!d) return;
    if (auto* v = d->TopPackages())
        for (auto* p : *v) g_pkgView[p] = "ELAB";
    if (auto* v = d->AllPackages())
        for (auto* p : *v)
            g_pkgView[p] = g_pkgView.count(p) ? "BOTH" : "DEF";
}
static std::string parentPath(const BaseClass* o) {
    std::string s;
    int guard = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && guard < 64;
         p = p->VpiParent(), ++guard) {
        s += "<";
        s += UhdmName(p->UhdmType());
        s += ":";
        s += p->VpiName();
        auto it = g_pkgView.find(p);
        if (it != g_pkgView.end()) { s += "/"; s += it->second; }
    }
    return s.empty() ? "<noparent" : s;
}
static const typespec* actualTs(const ref_typespec* rt) {
    return rt ? rt->Actual_typespec() : nullptr;
}

// ---- the right-bound form ------------------------------------------------
// Returns "" when this range is not an array-declaration dimension bound.
static std::string boundForm(const range* r) {
    const expr* re = r->Right_expr() ? any_cast<const expr*>(r->Right_expr())
                                     : nullptr;
    if (!re) return "";
    if (const constant* c = any_cast<const constant*>(re)) {
        const std::string v(c->VpiValue());
        if (v == "STRING:associative") {
            std::string s = "ASSOC ct=" + std::to_string(c->VpiConstType()) +
                            " idx=" + face(actualTs(c->Typespec()));
            return s;
        }
        if (v == "STRING:$") return "QUEUE ct=" + std::to_string(c->VpiConstType());
        if (v == "STRING:unsized")
            return "UNSIZED ct=" + std::to_string(c->VpiConstType());
        return "";
    }
    if (const operation* op = any_cast<const operation*>(re)) {
        if (op->VpiOpType() != vpiSubOp) return "";
        auto* ops = op->Operands();
        if (!ops || ops->size() != 2) return "";
        const BaseClass* a0 = ops->at(0);
        const BaseClass* a1 = ops->at(1);
        const constant* one = any_cast<const constant*>(a1);
        if (!one || std::string(one->VpiValue()) != "INT:1") return "";
        if (a0->UhdmType() != uhdmref_obj) return "";
        const ref_obj* ro = (const ref_obj*)a0;
        std::string s = "SIZE(" + std::string(ro->VpiName()) + ")-1 bound=" +
                        (ro->Actual_group() ? face(ro->Actual_group())
                                            : std::string("BARE"));
        return s;
    }
    return "";
}

struct Owner {
    const BaseClass* obj = nullptr;  // array_var / variables / typespec_member
    int arrayType = 0;
    std::string idxTs = "NONE";
};

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct189assoc own <golden.uhdm> <ours.uhdm>\n"
                "       ct189assoc cen <db.uhdm> [name-substr]\n");
        return 2;
    }
    const std::string mode(argv[1]);

    // ================= MODE own ==========================================
    if (mode == "own") {
        if (argc < 4) return 2;
        Serializer sg, so;
        if (sg.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
        if (so.Restore(std::string(argv[3])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
        const design* dg = topDesign(sg);
        const design* dou = topDesign(so);
        if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
        indexPkgViews(sg);
        indexPkgViews(so);
        CompareContext c;
        int r = dg->Compare(dou, &c);
        printf("design::Compare r=%d\n", r);
        printf("HEAD LHS(golden) = %s\n", ident(c.m_failedLhs).c_str());
        printf("HEAD RHS(ours)   = %s\n", ident(c.m_failedRhs).c_str());
        for (int side = 0; side < 2; ++side) {
            const BaseClass* H = side ? c.m_failedRhs : c.m_failedLhs;
            Serializer& S = side ? so : sg;
            if (!H) continue;
            printf("---- %s ----\n", side ? "OURS" : "GOLDEN");
            printf("  parent chain:\n");
            int guard = 0;
            for (const BaseClass* p = H->VpiParent(); p && guard < 32;
                 p = p->VpiParent(), ++guard)
                printf("    < %s\n", ident(p).c_str());
            printf("  edges landing on the head:\n");
            for (auto& kv : S.AllObjects()) {
                const BaseClass* X = kv.first;
                if (!X) continue;
                for (int t = 1; t <= 2100; ++t) {
                    auto tup = X->GetByVpiType(t);
                    const BaseClass* one = std::get<0>(tup);
                    const std::vector<const BaseClass*>* vec = std::get<2>(tup);
                    int idx = -1;
                    if (one == H) idx = -2;
                    if (vec)
                        for (size_t i = 0; i < vec->size(); ++i)
                            if (vec->at(i) == H) idx = (int)i;
                    if (idx == -1) continue;
                    printf("    %s   edge vpiType=%d %s\n", ident(X).c_str(), t,
                           idx == -2 ? "(singular)"
                                     : ("[" + std::to_string(idx) + "]").c_str());
                    printf("        X parent chain: %s\n", parentPath(X).c_str());
                }
            }
        }
        return 0;
    }

    // ================= MODE skip =========================================
    // r10uvm184's VISITED-SET SKIP, carried forward.  Every generated
    // `Compare` opens with
    //     if (!context->m_visited.insert(this).second) return r;
    // so PRE-SEEDING a golden object into `CompareContext::m_visited` makes
    // the judge SKIP it and keep walking, WITH NO EDIT TO EITHER DATABASE.
    // Re-running with the previous head seeded therefore enumerates the heads
    // BEHIND the first one — which is how "the cell the law fixed is now equal"
    // is proved rather than assumed: if a promoted sentinel were still
    // unequal, it would surface here.
    if (mode == "skip") {
        if (argc < 4) return 2;
        int rounds = argc > 4 ? atoi(argv[4]) : 8;
        Serializer sg, so;
        if (sg.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
        if (so.Restore(std::string(argv[3])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
        indexPkgViews(sg);
        indexPkgViews(so);
        const design* dg = topDesign(sg);
        const design* dou = topDesign(so);
        if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
        std::vector<const BaseClass*> seeds;
        for (int i = 0; i < rounds; ++i) {
            CompareContext c;
            for (auto* s : seeds) c.m_visited.insert(s);
            int r = dg->Compare(dou, &c);
            if (r == 0) { printf("round %d: EQUAL (r=0)\n", i); break; }
            printf("round %d: r=%d LHS=%s  RHS=%s\n", i, r,
                   ident(c.m_failedLhs).c_str(), ident(c.m_failedRhs).c_str());
            printf("         LHS listing %s\n", parentPath(c.m_failedLhs).c_str());
            if (!c.m_failedLhs) break;
            seeds.push_back(c.m_failedLhs);
        }
        return 0;
    }

    // ================= MODE pred =========================================
    // THE A-PRIORI MOVER PREDICTOR, read off OUR PRISTINE DATABASE ALONE —
    // no golden, no patched binary.  A cell this law can move is a
    // declaration-dimension range still in the SIZE form (a NAME-written
    // associative index that was not promoted) whose owner `array_var` is a
    // body local of a task_func listed under a `package`, where the SAME owner
    // face (name @ line:col) also occurs under a DIFFERENT package name — the
    // database-visible signature of an IMPORT CLONE listing, since the home
    // listing and its class_defn twin live under one package and only a clone
    // adds a second.
    //
    // It is a deliberate SUPERSET in one direction: it cannot tell a WILDCARD
    // import from an EXPLICIT one (`import P::fn;`), and the law fires only on
    // the wildcard (residue R1).  A cell it names that does not move is
    // therefore reported, not hidden.
    if (mode == "pred") {
        Serializer S;
        if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
        indexPkgViews(S);
        // face -> set of package names it is listed under
        std::map<std::string, std::set<std::string>> pkgsOf;
        std::vector<std::pair<std::string, std::string>> sizeCells;  // face, listing
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            const array_var* av = any_cast<const array_var*>(X);
            if (!av) continue;
            std::string pkg;
            bool underPkg = false;
            int guard = 0;
            for (const BaseClass* p = av->VpiParent(); p && guard < 64;
                 p = p->VpiParent(), ++guard)
                if (p->UhdmType() == uhdmpackage) { pkg = p->VpiName(); underPkg = true; break; }
            char fb[400];
            snprintf(fb, sizeof fb, "%s@%u:%u", std::string(av->VpiName()).c_str(),
                     av->VpiLineNo(), (unsigned)av->VpiColumnNo());
            if (underPkg) pkgsOf[fb].insert(pkg);
            const typespec* ts = actualTs(av->Typespec());
            if (!underPkg || !ts || ts->UhdmType() != uhdmarray_typespec) continue;
            const array_typespec* ats = (const array_typespec*)ts;
            if (auto* rs = ats->Ranges())
                for (auto* r : *rs)
                    if (boundForm(r).rfind("SIZE(", 0) == 0)
                        sizeCells.push_back({fb, pkg});
        }
        int pred = 0;
        std::set<std::string> named;
        for (auto& c : sizeCells) {
            auto it = pkgsOf.find(c.first);
            if (it == pkgsOf.end() || it->second.size() < 2) continue;
            ++pred;
            named.insert(c.first + " in package:" + c.second);
        }
        for (auto& n : named) printf("CELL %s\n", n.c_str());
        printf("PREDICT cells=%d faces=%zu\n", pred, named.size());
        return 0;
    }

    // ================= MODE refs =========================================
    // Every reference NAMED <name>, with its listing and its `vpiActual` at
    // IDENTITY granularity — the one instrument that tells a BARE reference
    // apart from one bound to a different object, which a three-valued
    // verdict would hide.
    if (mode == "refs") {
        Serializer S;
        if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
        indexPkgViews(S);
        const char* w = argc > 3 ? argv[3] : nullptr;
        std::vector<std::string> rows;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            const BaseClass* act = nullptr;
            if (const ref_obj* r = any_cast<const ref_obj*>(X)) act = r->Actual_group();
            else if (const ref_var* r = any_cast<const ref_var*>(X)) act = r->Actual_group();
            else if (const bit_select* r = any_cast<const bit_select*>(X)) act = r->Actual_group();
            else continue;
            const std::string nm(X->VpiName());
            if (w && nm.find(w) == std::string::npos) continue;
            char b[2400];
            snprintf(b, sizeof b, "%s | %s | %u:%u | %s | -> %s", parentPath(X).c_str(),
                     kindOf(X).c_str(), X->VpiLineNo(), (unsigned)X->VpiColumnNo(),
                     nm.c_str(), act ? ident(act).c_str() : "BARE");
            rows.push_back(b);
        }
        std::sort(rows.begin(), rows.end());
        for (auto& s : rows) printf("%s\n", s.c_str());
        fprintf(stderr, "REFS %zu\n", rows.size());
        return 0;
    }

    // ================= MODE var ==========================================
    // One row per ARRAY_VAR — the declaration side of the same population,
    // so a SHARED array_typespec (several declarations, one range vector)
    // cannot hide a listing the range-keyed census merged away.
    if (mode == "var") {
        Serializer S;
        if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
        indexPkgViews(S);
        const char* w = argc > 3 ? argv[3] : nullptr;
        std::vector<std::string> rows;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            const array_var* av = any_cast<const array_var*>(X);
            if (!av) continue;
            const std::string nm(av->VpiName());
            if (w && nm.find(w) == std::string::npos) continue;
            const typespec* ts = actualTs(av->Typespec());
            std::string dims;
            std::string atsdesc = "NOATS";
            if (ts && ts->UhdmType() == uhdmarray_typespec) {
                const array_typespec* ats = (const array_typespec*)ts;
                char ab[300];
                snprintf(ab, sizeof ab, "ats#%u@%u:%u-%u:%u at=%d idxTs=%s",
                         ats->UhdmId(), ats->VpiLineNo(),
                         (unsigned)ats->VpiColumnNo(), ats->VpiEndLineNo(),
                         (unsigned)ats->VpiEndColumnNo(), ats->VpiArrayType(),
                         face(actualTs(ats->Index_typespec())).c_str());
                atsdesc = ab;
                if (auto* rs = ats->Ranges())
                    for (size_t i = 0; i < rs->size(); ++i) {
                        if (i) dims += " ; ";
                        std::string f = boundForm(rs->at(i));
                        char rb[128];
                        snprintf(rb, sizeof rb, "[r@%u:%u-%u:%u]",
                                 rs->at(i)->VpiLineNo(),
                                 (unsigned)rs->at(i)->VpiColumnNo(),
                                 rs->at(i)->VpiEndLineNo(),
                                 (unsigned)rs->at(i)->VpiEndColumnNo());
                        dims += (f.empty() ? std::string("NUMERIC") : f) + rb;
                    }
            }
            std::string own;
            if (auto* rs = av->Ranges())
                for (size_t i = 0; i < rs->size(); ++i) {
                    if (i) own += " ; ";
                    std::string f = boundForm(rs->at(i));
                    own += f.empty() ? std::string("NUMERIC") : f;
                }
            char b[3000];
            snprintf(b, sizeof b,
                     "%s | %u:%u | %s | avArrayType=%d | %s | atsdims=[%s] | "
                     "avranges=[%s]",
                     parentPath(av).c_str(), av->VpiLineNo(),
                     (unsigned)av->VpiColumnNo(), nm.c_str(),
                     av->VpiArrayType(), atsdesc.c_str(), dims.c_str(),
                     own.c_str());
            rows.push_back(b);
        }
        std::sort(rows.begin(), rows.end());
        for (auto& s : rows) printf("%s\n", s.c_str());
        fprintf(stderr, "VARS %zu\n", rows.size());
        return 0;
    }

    // ================= MODE cen ==========================================
    if (mode != "cen") return 2;
    Serializer S;
    if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
    indexPkgViews(S);
    const char* want = argc > 3 ? argv[3] : nullptr;

    // ---- pass 1 — the OWNER INDEX ---------------------------------------
    // array_typespec  ->  the declaration object that points at it, and that
    // object's own compared array fields.
    std::map<const BaseClass*, Owner> owner;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        const ref_typespec* rt = nullptr;
        int at = 0;
        std::string its = "NONE";
        if (const array_var* av = any_cast<const array_var*>(X)) {
            rt = av->Typespec();
            at = av->VpiArrayType();
        }
        else if (const variables* v = any_cast<const variables*>(X))
            rt = v->Typespec();
        else if (const typespec_member* tm = any_cast<const typespec_member*>(X))
            rt = tm->Typespec();
        else if (const parameter* p = any_cast<const parameter*>(X))
            rt = p->Typespec();
        else if (const nets* n = any_cast<const nets*>(X))
            rt = n->Typespec();
        else
            continue;
        const typespec* ts = actualTs(rt);
        if (!ts || ts->UhdmType() != uhdmarray_typespec) continue;
        const array_typespec* ats = (const array_typespec*)ts;
        if (ats->Index_typespec()) its = face(actualTs(ats->Index_typespec()));
        Owner o;
        o.obj = X;
        o.arrayType = at ? at : ats->VpiArrayType();
        o.idxTs = its;
        // First writer wins; a shared typespec is reported under its first
        // owner and the count of sharers is printed separately below.
        if (!owner.count(ats)) owner[ats] = o;
    }
    // How many declarations share one array_typespec (a real question here:
    // the index typespec is often the ONE shared object of a typedef).
    std::map<const BaseClass*, int> sharers;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        const ref_typespec* rt = nullptr;
        if (const array_var* av = any_cast<const array_var*>(X)) rt = av->Typespec();
        else if (const variables* v = any_cast<const variables*>(X)) rt = v->Typespec();
        else if (const typespec_member* tm = any_cast<const typespec_member*>(X)) rt = tm->Typespec();
        else continue;
        if (const typespec* ts = actualTs(rt))
            if (ts->UhdmType() == uhdmarray_typespec) sharers[ts]++;
    }

    // ---- pass 2 — one row per declaration dimension bound ---------------
    std::vector<std::string> rows;
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X || X->UhdmType() != uhdmrange) continue;
        const range* r = (const range*)X;
        std::string form = boundForm(r);
        if (form.empty()) continue;
        const BaseClass* par = r->VpiParent();
        Owner ow;
        int dim = -1;
        if (par && par->UhdmType() == uhdmarray_typespec) {
            const array_typespec* ats = (const array_typespec*)par;
            auto it = owner.find(ats);
            if (it != owner.end()) ow = it->second;
            if (ow.arrayType == 0) ow.arrayType = ats->VpiArrayType();
            if (ow.idxTs == "NONE" && ats->Index_typespec())
                ow.idxTs = face(actualTs(ats->Index_typespec()));
            if (auto* rs = ats->Ranges())
                for (size_t i = 0; i < rs->size(); ++i)
                    if (rs->at(i) == r) dim = (int)i;
            if (!ow.obj) ow.obj = ats;  // orphan typespec — its own bucket
        }
        else if (par && any_cast<const array_var*>(par)) {
            const array_var* av = (const array_var*)par;
            ow.obj = av;
            ow.arrayType = av->VpiArrayType();
            if (const typespec* ts = actualTs(av->Typespec()))
                if (ts->UhdmType() == uhdmarray_typespec)
                    if (((const array_typespec*)ts)->Index_typespec())
                        ow.idxTs = face(actualTs(
                            ((const array_typespec*)ts)->Index_typespec()));
            if (auto* rs = av->Ranges())
                for (size_t i = 0; i < rs->size(); ++i)
                    if (rs->at(i) == r) dim = (int)i;
            // An array_var range vector is the INNER dimensions (§ emitAssocDims);
            // mark it so it never joins an array_typespec dim of the same number.
            if (dim >= 0) dim += 100;
        }
        else
            continue;
        if (!ow.obj) continue;
        const std::string onm(ow.obj->VpiName());
        if (want && onm.find(want) == std::string::npos) continue;
        char b[2400];
        snprintf(b, sizeof b,
                 "%s | %s | %u:%u | %s | dim%d || arrayType=%d idxTs=%s | %s "
                 "|| sharers=%d",
                 parentPath(ow.obj).c_str(), kindOf(ow.obj).c_str(),
                 ow.obj->VpiLineNo(), (unsigned)ow.obj->VpiColumnNo(),
                 onm.c_str(), dim, ow.arrayType, ow.idxTs.c_str(), form.c_str(),
                 par->UhdmType() == uhdmarray_typespec
                     ? (sharers.count(par) ? sharers[par] : 0)
                     : -1);
        rows.push_back(b);
    }
    std::sort(rows.begin(), rows.end());
    for (auto& s : rows) printf("%s\n", s.c_str());
    fprintf(stderr, "ROWS %zu\n", rows.size());
    return 0;
}
