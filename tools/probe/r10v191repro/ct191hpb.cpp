// r10uvm191 — THE CLONE hier_path-BASE BINDING CENSUS AND OWNER-FINDER.
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge;
// this tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// MODE `own <golden> <ours>`  — decode the judge: run the OFFICIAL
//   design::Compare, print the head on both sides with its parent chain, then
//   scan BOTH databases for every edge that lands on the head object
//   (`GetByVpiType`, the generated kind-agnostic edge accessor, so no field is
//   named by hand and none can be missed).
//
// MODE `skip <golden> <ours> [rounds]` — r10uvm184's VISITED-SET skip, carried
//   forward: pre-seeding a golden object into `CompareContext::m_visited`
//   makes every generated `Compare` return early on it, so the heads BEHIND
//   the first one are enumerated WITH NO EDIT TO EITHER DATABASE.
//
// MODE `refs <db> <name>` — every `ref_obj` / `ref_var` with that name, its
//   span, its LISTING (parent chain with the package DEF/ELAB view), its
//   FACE (hier_path base / hier_path inner element / plain name / select
//   base), whether it sits under a DYNAMIC-ARRAY `new[...]`, and its actual.
//
// MODE `cenall <db>` — THE WHOLE-DATABASE REFERENCE CENSUS: one row per
//   BINDABLE reference (`ref_obj` / `ref_var` / `bit_select` — exactly
//   `bindable37`'s set, the objects `pkgCloneHierBind9` can write), keyed by
//
//     LISTING | SUBROUTINE | FACE | CTX | LINE:COL | NAME
//
//   and valued by the FULL compared shape at identity granularity
//   (`act=<face of the vpiActual, or BARE>`), never a three-valued verdict, so
//   a move between two WRONG shapes cannot hide.  Values are joined as a
//   MULTISET per key: a wildcard-import clone is listed TWICE under one root
//   and a dictionary keyed by position alone drops the second copy
//   (RESUME §9).  `score191.py` joins golden, pristine and patched.
//
// MODE `newhp <db>` — one row per `hier_path` whose context is a
//   DYNAMIC-ARRAY `new[...]` argument, listing EVERY element with its own
//   actual: the base is § 9's name bind and the elements after it belong to
//   § pkgCloneMember10 and § builtinArrayReadBindsMintedFuncCall182.
//
// MODE `cen <db> [name-substr]` — the same, restricted to hier_path BASES.
//
// MODE `pred <golden> <ours>` — THE A-PRIORI MOVER PREDICTOR over a
//   GOLDEN/PRISTINE pair alone (no patched binary): is there a hier_path BASE
//   under a dynamic-array `new[...]` argument that golden BINDS and the
//   pristine database leaves BARE?  A SUPERSET of the shipped gate, so it can
//   OVER-name and never under-name.
//
// THE CONTAINMENT HOP.  A dynamic-array `new[...]` call carries NO VpiParent
// on either side in the home listing and on OUR side in every listing
// (§ newArray11 models Surelog's unparented `fcall`), so a parent walk from
// anything underneath it reaches NO LISTING AT ALL and the home listing, both
// clone copies and the elaborated module collapse into one unattributable
// bucket.  Every mode here walks `VpiParent` where it exists and hops a
// CONTAINMENT index only where the chain is dead.  Taking the containment root
// outright was measured and rejected: it put golden's four HOME-listing
// `predecessors` references under `adpcm_pkg/ELAB`.
//
// A dynamic-array `new[...]` call is classified exactly as r10uvm186's
// ct186new did: a `method_func_call` named `new` is DYN when ANY instance of
// that POSITION (line:col span) in the database carries NO VpiParent — the
// unparented `fcall` is § newArrayArgNoBind16's whole producer decode, and the
// classifier separates `d = new[n]` from `h = new(args)` on both sides at once.
//
// build: g++ -O2 -std=c++17 ct191hpb.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct191hpb
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
    if (!o) return "BARE";
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
// the elaborated `Package` (design.TopPackages) and the `getUnElabPackage()`
// twin (design.AllPackages) — and a listing law must never merge the two.
static std::map<const BaseClass*, std::string> g_pkgView;
static void indexPkgViews(Serializer& S) {
    const design* d = topDesign(S);
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
// The LISTING ROOT: the outermost package / module_inst / class_defn on the
// chain, with its DEF/ELAB view.  This is the bucket every census row is keyed
// on; without it the home listing and the two clone copies collapse into one.
static std::string listingRoot(const BaseClass* o) {
    std::string last = "<none>";
    int guard = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && guard < 64;
         p = p->VpiParent(), ++guard) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        // `design` is DELIBERATELY not a listing root: every chain ends there
        // and keeping it collapses the home listing and both clone copies into
        // one bucket.
        if (t == uhdmpackage || t == uhdmmodule_inst || t == uhdmclass_defn) {
            std::string s = std::string(UhdmName(t)) + ":" +
                            std::string(p->VpiName());
            auto it = g_pkgView.find(p);
            if (it != g_pkgView.end()) { s += "/" + it->second; }
            last = s;
        }
    }
    return last;
}
// The nearest enclosing subroutine (function / task) — the HOME whose
// declaration a clone-listed body would bind.
static const BaseClass* enclosingSub(const BaseClass* o) {
    int guard = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && guard < 64;
         p = p->VpiParent(), ++guard) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmfunction || t == uhdmtask) return p;
    }
    return nullptr;
}

// ---------------------------------------------------------------- DYN index
// A `method_func_call` named `new` is a DYNAMIC-ARRAY new[...] when ANY
// instance at that POSITION carries no VpiParent (r10uvm186's classifier).
static std::set<std::string> g_dynPos;
static std::string posKey(const BaseClass* o) {
    char b[128];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
             o->VpiEndLineNo(), (unsigned)o->VpiEndColumnNo());
    return b;
}
static void indexDyn(Serializer& S) {
    g_dynPos.clear();
    for (auto& kv : S.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X || X->UhdmType() != uhdmmethod_func_call) continue;
        if (std::string(X->VpiName()) != "new") continue;
        if (X->VpiParent() == nullptr) g_dynPos.insert(posKey(X));
    }
}
static bool isDynNew(const BaseClass* X) {
    return X && X->UhdmType() == uhdmmethod_func_call &&
           std::string(X->VpiName()) == "new" && g_dynPos.count(posKey(X));
}

// ------------------------------------------------------ THE CONTAINMENT HOP
// A dynamic-array `new[...]` call carries NO VpiParent — on BOTH sides in the
// home listing, and on OUR side in every listing (§ newArray11 models
// Surelog's unparented `fcall`).  So a parent walk from anything underneath it
// reports NO LISTING AT ALL, and the home listing, both clone copies and the
// elaborated module collapse into one unattributable bucket.  THIS PASS'S
// CENSUS CANNOT BE KEYED WITHOUT FIXING THAT.
//
// The fix is a CONTAINMENT index, not a replacement for the parent walk: one
// top-down pass from `design` over the generated edge accessors records, for
// every object, the object that CONTAINS it.  The listing walk then uses
// `VpiParent` wherever it exists and hops the containment edge ONLY where the
// chain is dead — which is exactly the one link the unparented `new` punches.
// Everything above that link is walked by the true parent chain, so a shared
// ELAB listing cannot steal a home-listing row (measured: taking the
// containment root outright put golden's four HOME-listing `predecessors`
// references under `adpcm_pkg/ELAB`).
static std::map<const BaseClass*, const BaseClass*> g_cparent;
static void containWalk(const BaseClass* X, int depth) {
    if (!X || depth > 300) return;
    for (int ty = 1; ty <= 2100; ++ty) {
        auto tup = X->GetByVpiType(ty);
        const BaseClass* one = std::get<0>(tup);
        const std::vector<const BaseClass*>* vec = std::get<2>(tup);
        if (one && g_cparent.emplace(one, X).second) containWalk(one, depth + 1);
        if (vec)
            for (auto* e : *vec)
                if (e && g_cparent.emplace(e, X).second) containWalk(e, depth + 1);
    }
}
static void indexContainment(Serializer& S) {
    g_cparent.clear();
    const design* d = topDesign(S);
    if (!d) return;
    g_cparent.emplace(d, nullptr);
    containWalk(d, 0);
}
static const BaseClass* upOf(const BaseClass* X) {
    if (!X) return nullptr;
    if (const BaseClass* p = X->VpiParent()) return p;
    auto it = g_cparent.find(X);
    return it == g_cparent.end() ? nullptr : it->second;
}
// The LISTING: outermost package / module_inst (or a design-level class_defn),
// walked with the containment hop.
static std::string listingOf(const BaseClass* o) {
    std::string last = "<none>";
    int guard = 0;
    for (const BaseClass* p = upOf(o); p && guard < 128; p = upOf(p), ++guard) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmpackage || t == uhdmmodule_inst || t == uhdmclass_defn) {
            std::string s = std::string(UhdmName(t)) + ":" +
                            std::string(p->VpiName());
            auto it = g_pkgView.find(p);
            if (it != g_pkgView.end()) s += "/" + it->second;
            last = s;
        }
    }
    return last;
}
// The enclosing subroutine, walked with the containment hop.
static const BaseClass* subOf(const BaseClass* o) {
    int guard = 0;
    for (const BaseClass* p = upOf(o); p && guard < 128; p = upOf(p), ++guard) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmfunction || t == uhdmtask) return p;
    }
    return nullptr;
}
static std::string subName(const BaseClass* o) {
    const BaseClass* tf = subOf(o);
    return tf ? std::string(UhdmName(tf->UhdmType())) + ":" +
                    std::string(tf->VpiName())
              : std::string("<nosub>");
}

// The CONTEXT of a reference: walk up to the first construct that names a
// binding window.
//   NEWARG   — under a dynamic-array `new[...]` argument list
//   CALLARG  — under any other call's argument list
//   FOREACH  — the loop variable list of a foreach_stmt
//   PLAIN    — anything else
static std::string ctxOf(const BaseClass* o) {
    int guard = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && guard < 64;
         p = p->VpiParent(), ++guard) {
        UHDM_OBJECT_TYPE t = p->UhdmType();
        if (t == uhdmmethod_func_call || t == uhdmfunc_call ||
            t == uhdmmethod_task_call || t == uhdmtask_call ||
            t == uhdmsys_func_call || t == uhdmsys_task_call)
            return isDynNew(p) ? "NEWARG" : "CALLARG";
        if (t == uhdmforeach_stmt) return "FOREACH";
        if (t == uhdmfunction || t == uhdmtask || t == uhdmpackage ||
            t == uhdmclass_defn || t == uhdmmodule_inst)
            break;
    }
    return "PLAIN";
}

// The FACE of a reference: what structural slot it occupies.
//   HPBASE   — Path_elems[0] of a hier_path
//   HPINNER  — a later Path_elems entry
//   SELBASE  — the base of a bit/part/var select
//   NAME     — a plain name
static std::string faceOf(const BaseClass* R) {
    const BaseClass* p = R ? R->VpiParent() : nullptr;
    if (!p) return "NAME";
    if (p->UhdmType() == uhdmhier_path) {
        const hier_path* hp = (const hier_path*)p;
        if (auto* el = hp->Path_elems())
            if (!el->empty()) return el->at(0) == R ? "HPBASE" : "HPINNER";
        return "HPINNER";
    }
    if (p->UhdmType() == uhdmbit_select || p->UhdmType() == uhdmpart_select ||
        p->UhdmType() == uhdmindexed_part_select || p->UhdmType() == uhdmvar_select)
        return "SELBASE";
    return "NAME";
}
static const BaseClass* actualOf(const BaseClass* R) {
    if (!R) return nullptr;
    if (R->UhdmType() == uhdmref_obj) return ((const ref_obj*)R)->Actual_group();
    if (R->UhdmType() == uhdmref_var) return ((const ref_var*)R)->Actual_group();
    return nullptr;
}
static bool isRef(const BaseClass* X) {
    return X && (X->UhdmType() == uhdmref_obj || X->UhdmType() == uhdmref_var);
}

// The BASE KIND: what the reference's own declaration is, read off the actual
// when there is one, else "?" .  Used only as a census column.
static std::string baseKindOf(const BaseClass* act) {
    if (!act) return "?";
    return std::string(UhdmName(act->UhdmType()));
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct191hpb own  <golden.uhdm> <ours.uhdm>\n"
                "       ct191hpb skip <golden.uhdm> <ours.uhdm> [rounds]\n"
                "       ct191hpb refs <db.uhdm> <name>\n"
                "       ct191hpb cen  <db.uhdm> [name-substr]\n"
                "       ct191hpb pred <db.uhdm>\n");
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
            indexDyn(S);   // the DYN classifier is PER DATABASE
            indexContainment(S);
            printf("---- %s ----\n", side ? "OURS" : "GOLDEN");
            printf("  parent chain: %s\n", parentPath(H).c_str());
            printf("  listing root: %s (parent-walk) / %s (ownership walk)\n",
                   listingRoot(H).c_str(), listingOf(H).c_str());
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
                    printf("        listing %s  face=%s ctx=%s\n",
                           listingOf(X).c_str(), faceOf(X).c_str(),
                           ctxOf(X).c_str());
                }
            }
        }
        return 0;
    }

    // ================= MODE skip =========================================
    if (mode == "skip") {
        if (argc < 4) return 2;
        int rounds = argc > 4 ? atoi(argv[4]) : 8;
        Serializer sg, so;
        if (sg.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
        if (so.Restore(std::string(argv[3])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
        indexPkgViews(sg);
        indexPkgViews(so);
        indexDyn(sg);
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
            printf("         LHS listing %s | %s\n",
                   listingRoot(c.m_failedLhs).c_str(),
                   parentPath(c.m_failedLhs).c_str());
            if (!c.m_failedLhs) break;
            seeds.push_back(c.m_failedLhs);
        }
        return 0;
    }

    // ================= MODE refs =========================================
    if (mode == "refs") {
        if (argc < 4) return 2;
        Serializer S;
        if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
        indexPkgViews(S);
        indexDyn(S);
        indexContainment(S);
        const std::string want(argv[3]);
        std::vector<std::string> rows;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!isRef(X)) continue;
            if (std::string(X->VpiName()) != want) continue;
            char b[2400];
            snprintf(b, sizeof b, "%-30s | %-8s | %-8s | %-42s | act=%s",
                     ident(X).c_str(), faceOf(X).c_str(), ctxOf(X).c_str(),
                     listingOf(X).c_str(), face(actualOf(X)).c_str());
            rows.push_back(b);
        }
        std::sort(rows.begin(), rows.end());
        for (auto& r : rows) printf("%s\n", r.c_str());
        printf("-- refs=%zu\n", rows.size());
        return 0;
    }

    // ================= MODE cen ==========================================
    // ONE ROW PER hier_path BASE ELEMENT.  Multiset-joined per key.
    if (mode == "cen") {
        Serializer S;
        if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
        indexPkgViews(S);
        indexDyn(S);
        indexContainment(S);
        const std::string sub = argc > 3 ? argv[3] : "";
        std::map<std::string, std::vector<std::string>> cen;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!isRef(X)) continue;
            std::string f = faceOf(X);
            if (f != "HPBASE") continue;
            std::string nm(X->VpiName());
            if (!sub.empty() && nm.find(sub) == std::string::npos) continue;
            char key[2000];
            snprintf(key, sizeof key, "%-42s | %-46s | %-6s | %-8s | %u:%u | %s",
                     listingOf(X).c_str(), subName(X).c_str(),
                     f.c_str(), ctxOf(X).c_str(), X->VpiLineNo(),
                     (unsigned)X->VpiColumnNo(), nm.c_str());
            const BaseClass* act = actualOf(X);
            char val[900];
            snprintf(val, sizeof val, "act=%s kind=%s", face(act).c_str(),
                     baseKindOf(act).c_str());
            cen[key].push_back(val);
        }
        size_t rows = 0;
        for (auto& kv : cen) {
            std::vector<std::string> v = kv.second;
            std::sort(v.begin(), v.end());
            std::string j;
            for (size_t i = 0; i < v.size(); ++i) { if (i) j += " ;; "; j += v[i]; }
            printf("%s || %s\n", kv.first.c_str(), j.c_str());
            rows += v.size();
        }
        printf("-- keys=%zu cells=%zu\n", cen.size(), rows);
        return 0;
    }

    // ================= MODE cenall =======================================
    // THE WHOLE-DATABASE REFERENCE CENSUS.  One row per BINDABLE reference
    // (`ref_obj` / `ref_var` / `bit_select` — exactly `bindable37`'s set, the
    // objects `pkgCloneHierBind9` can write), keyed by
    //
    //     LISTING | SUBROUTINE | FACE | CTX | LINE:COL | NAME
    //
    // and valued by the FULL compared shape at identity granularity
    // (`act=<face of the actual>`), never a three-valued verdict — so a move
    // between two WRONG shapes cannot hide.  Values are joined as a MULTISET
    // per key: one key can hold several cells and a last-writer dict drops
    // them (RESUME §9).  This is the instrument that proves NOTHING BUT the
    // law's own cells moved: run it on golden, on the pristine database and
    // on the patched one and join the three (score191.py).
    if (mode == "cenall") {
        Serializer S;
        if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
        indexPkgViews(S);
        indexDyn(S);
        indexContainment(S);
        std::map<std::string, std::vector<std::string>> cen;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            auto t = X->UhdmType();
            if (t != uhdmref_obj && t != uhdmref_var && t != uhdmbit_select)
                continue;
            char key[2400];
            snprintf(key, sizeof key, "%-42s | %-46s | %-7s | %-8s | %u:%u | %s",
                     listingOf(X).c_str(), subName(X).c_str(),
                     faceOf(X).c_str(), ctxOf(X).c_str(), X->VpiLineNo(),
                     (unsigned)X->VpiColumnNo(),
                     std::string(X->VpiName()).c_str());
            const BaseClass* act = nullptr;
            if (t == uhdmref_obj) act = ((const ref_obj*)X)->Actual_group();
            else if (t == uhdmref_var) act = ((const ref_var*)X)->Actual_group();
            else act = ((const bit_select*)X)->Actual_group();
            cen[key].push_back("act=" + face(act));
        }
        size_t rows = 0;
        for (auto& kv : cen) {
            std::vector<std::string> v = kv.second;
            std::sort(v.begin(), v.end());
            std::string j;
            for (size_t i = 0; i < v.size(); ++i) { if (i) j += " ;; "; j += v[i]; }
            printf("%s || %s\n", kv.first.c_str(), j.c_str());
            rows += v.size();
        }
        printf("-- keys=%zu cells=%zu\n", cen.size(), rows);
        return 0;
    }

    // ================= MODE newhp ========================================
    // THE WHOLE PATH, not just its base: one row per `hier_path` whose
    // context is a DYNAMIC-ARRAY `new[...]` argument, listing EVERY element
    // with its own actual.  This is what decides how far the law may reach —
    // the base is § 9's name bind, and the elements after it belong to
    // § pkgCloneMember10 and § builtinArrayReadBindsMintedFuncCall182, which
    // are asked through the SAME owning-subroutine test.
    if (mode == "newhp") {
        Serializer S;
        if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
        indexPkgViews(S);
        indexDyn(S);
        indexContainment(S);
        std::vector<std::string> rows;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X || X->UhdmType() != uhdmhier_path) continue;
            if (ctxOf(X) != "NEWARG") continue;
            std::string line;
            char b[1200];
            snprintf(b, sizeof b, "%-42s | %-46s | %u:%u | %-28s |",
                     listingOf(X).c_str(), subName(X).c_str(), X->VpiLineNo(),
                     (unsigned)X->VpiColumnNo(),
                     std::string(X->VpiName()).c_str());
            line = b;
            if (auto* el = ((const hier_path*)X)->Path_elems())
                for (size_t i = 0; i < el->size(); ++i) {
                    const BaseClass* e = el->at(i);
                    snprintf(b, sizeof b, " [%zu]%s(%s)->%s", i,
                             kindOf(e).c_str(),
                             std::string(e->VpiName()).c_str(),
                             face(actualOf(e)).c_str());
                    line += b;
                }
            rows.push_back(line);
        }
        std::sort(rows.begin(), rows.end());
        for (auto& r : rows) printf("%s\n", r.c_str());
        printf("-- newarg_hier_paths=%zu\n", rows.size());
        return 0;
    }

    // ================= MODE pred =========================================
    // THE A-PRIORI MOVER PREDICTOR, over a GOLDEN / PRISTINE pair and nothing
    // else (no patched binary, no source).  The question is the law's own,
    // asked of the two databases: IS THERE A hier_path BASE UNDER A
    // DYNAMIC-ARRAY `new[...]` ARGUMENT THAT GOLDEN BINDS AND THE PRISTINE
    // DATABASE LEAVES BARE?  A row with no such key cannot move.
    //
    // The predicate is a SUPERSET of the shipped gate — a database cannot say
    // whether a listing is a WILDCARD-import clone or an EXPLICIT-import copy
    // (R1), and this asks nothing about the symbol half — so it can OVER-name
    // and never under-name, which is what a prediction has to do.
    if (mode == "pred") {
        if (argc < 4) return 2;
        Serializer sg, so;
        if (sg.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
        if (so.Restore(std::string(argv[3])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
        auto collect = [](Serializer& S,
                          std::map<std::string, std::vector<std::string>>& out) {
            g_pkgView.clear();
            indexPkgViews(S);
            indexDyn(S);
            indexContainment(S);
            for (auto& kv : S.AllObjects()) {
                const BaseClass* X = kv.first;
                if (!isRef(X)) continue;
                if (faceOf(X) != "HPBASE") continue;
                if (ctxOf(X) != "NEWARG") continue;
                char key[2400];
                snprintf(key, sizeof key, "%s | %s | %u:%u | %s",
                         listingOf(X).c_str(), subName(X).c_str(),
                         X->VpiLineNo(), (unsigned)X->VpiColumnNo(),
                         std::string(X->VpiName()).c_str());
                out[key].push_back(actualOf(X) ? "BOUND" : "BARE");
            }
            for (auto& kv : out) std::sort(kv.second.begin(), kv.second.end());
        };
        std::map<std::string, std::vector<std::string>> G, O;
        collect(sg, G);
        collect(so, O);
        size_t cells = 0;
        for (auto& kv : G) {
            auto it = O.find(kv.first);
            if (it == O.end()) continue;
            size_t gb = 0, ob = 0;
            for (auto& v : kv.second) if (v == "BOUND") gb++;
            for (auto& v : it->second) if (v == "BOUND") ob++;
            if (gb > ob) {
                printf("CELL %s   golden BOUND=%zu ours BOUND=%zu\n",
                       kv.first.c_str(), gb, ob);
                cells += gb - ob;
            }
        }
        printf("PREDICTED_CELLS=%zu\n", cells);
        return 0;
    }

    fprintf(stderr, "unknown mode %s\n", mode.c_str());
    return 2;
}
