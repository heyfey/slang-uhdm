// r10uvm193 — THE ARRAY-RECEIVER BUILT-IN-METHOD ARGUMENT CENSUS, OWNER-FINDER
// AND MINT-FINDER.
//
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge;
// this tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// The containment index, the DEF/ELAB package-view index, the listing walk and
// the DYN-`new` classifier are r10uvm191's `ct191hpb` carried forward
// unchanged (a dynamic-array `new[...]` call has NO VpiParent, so a parent
// walk from underneath it reaches no listing; the hop is taken ONLY where the
// parent chain is dead).  What is new here is everything about the MINT.
//
// MODE `own <golden> <ours>`   — decode the judge: run the OFFICIAL
//   design::Compare, print the head on both sides with its parent chain and
//   its full field dump, then scan BOTH databases with `GetByVpiType` (the
//   generated kind-agnostic edge accessor, so no field is named by hand and
//   none can be missed) for every edge that lands on the head object.
//
// MODE `skip <golden> <ours> [rounds]` — r10uvm184's VISITED-SET skip:
//   pre-seeding a golden object into `CompareContext::m_visited` makes every
//   generated `Compare` return early on it, so the heads BEHIND the first one
//   are enumerated WITH NO EDIT TO EITHER DATABASE.
//
// MODE `mfc <db> [name-substr]` — ONE ROW PER BUILT-IN METHOD CALL written on
//   a receiver, in every listing: the receiver element (kind / name / actual),
//   the method name, and EVERY `Tf_call_args` entry with its own kind, name,
//   span and actual.  This is the grid instrument.
//
// MODE `mint <db>` — ONE ROW PER MINTED VARIABLE: a `variables` object whose
//   VpiParent is a `method_func_call` (or a `hier_path`), i.e. an object that
//   is NOT a declaration in any scope's Variables() list but hangs off a CALL.
//   Every field the generated Compare reads is printed.
//
// MODE `at <db> <line>` — every object whose START LINE is that line, with its
//   kind, name, span, parent and EVERY edge.  The instrument that says what
//   Surelog wrote at a declaration: it is what showed that
//   `array_var (visited) @1896:9` carries `vpiVariables[1] = int_var()
//   @1896:9-1896:16` on BOTH sides, i.e. that the head's mint is a RENAMED
//   COPY of the array's own element variable.
//
// MODE `cenall <db>` — THE WHOLE-DATABASE CENSUS at identity granularity:
//   one row per bindable reference (`ref_obj` / `ref_var` / `bit_select` —
//   exactly `bindable37`'s set) keyed by
//       LISTING | SUBROUTINE | FACE | CTX | LINE:COL | NAME
//   and valued by `act=<face of the vpiActual, or BARE>` plus, when the actual
//   is a MINT, the mint's whole shape (kind, span, the call it hangs off).
//   Values are joined as a MULTISET per key (a wildcard-import clone is listed
//   TWICE under one root and a last-writer dict drops the second copy,
//   RESUME §9).  A MINT IS DELIBERATELY NOT KEYED ON ITS OWN LISTING: golden
//   parents its mint at the HOME listing's call and we parent ours at the
//   clone's own call, so a mint-keyed row does not join and scores a PHANTOM
//   AWAY (measured on arm D: golden 9 mints, pristine 7, patched 9, the same
//   multiset of REFERRERS on golden and patched, and a 2-count "AWAY" purely
//   from the key).  The orphan-mint count is reported on the trailing `--`
//   line instead, so a mint no reference binds still cannot hide.
//
// MODE `pred <golden> <ours>` — THE A-PRIORI MOVER PREDICTOR over a
//   GOLDEN / PRISTINE pair alone (no patched binary, no source): is there an
//   argument of a built-in method call on an ARRAY receiver where golden's
//   actual is a MINT (a variable parented at the call) and ours is not?  A row
//   with no such key cannot move.  A SUPERSET of the shipped gate — a database
//   cannot say whether a listing is a WILDCARD-import clone or an
//   EXPLICIT-import copy — so it can OVER-name and never under-name.
//
// build: g++ -O2 -std=c++17 ct193arg.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct193arg
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
        char lb[64];
        snprintf(lb, sizeof lb, ":%u", p->VpiLineNo());
        s += lb;
        auto it = g_pkgView.find(p);
        if (it != g_pkgView.end()) { s += "/"; s += it->second; }
    }
    return s.empty() ? "<noparent" : s;
}
// ---------------------------------------------------------------- DYN index
static std::set<std::string> g_dynPos;
static std::string posKey(const BaseClass* o) {
    char b[128];
    snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(),
             (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
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
        p->UhdmType() == uhdmindexed_part_select ||
        p->UhdmType() == uhdmvar_select)
        return "SELBASE";
    return "NAME";
}
static const BaseClass* actualOf(const BaseClass* R) {
    if (!R) return nullptr;
    if (R->UhdmType() == uhdmref_obj) return ((const ref_obj*)R)->Actual_group();
    if (R->UhdmType() == uhdmref_var) return ((const ref_var*)R)->Actual_group();
    if (R->UhdmType() == uhdmbit_select)
        return ((const bit_select*)R)->Actual_group();
    return nullptr;
}
static bool isRef(const BaseClass* X) {
    return X && (X->UhdmType() == uhdmref_obj || X->UhdmType() == uhdmref_var);
}
// A VARIABLE is a MINT when it hangs off a CALL or a PATH rather than off a
// scope: no declaration in any Variables() list has a `method_func_call` or a
// `hier_path` for a parent.  This is the shape r10uvm184's R2 named and the
// only shape this pass can produce or destroy.
static bool isMint(const BaseClass* X) {
    if (!X) return false;
    // `variables` is an abstract UHDM base; the generated any_cast is IS-A.
    if (!any_cast<const variables*>((const any*)X)) return false;
    const BaseClass* p = X->VpiParent();
    if (!p) return false;
    UHDM_OBJECT_TYPE t = p->UhdmType();
    return t == uhdmmethod_func_call || t == uhdmhier_path ||
           t == uhdmfunc_call || t == uhdmmethod_task_call ||
           t == uhdmtask_call;
}
// The RECEIVER of a built-in method call written as `recv.meth(args)`: the
// element written immediately BEFORE the call in the enclosing hier_path.
static const BaseClass* recvOf(const BaseClass* M) {
    const BaseClass* p = M ? M->VpiParent() : nullptr;
    if (!p || p->UhdmType() != uhdmhier_path) return nullptr;
    auto* el = ((const hier_path*)p)->Path_elems();
    if (!el) return nullptr;
    for (size_t i = 0; i < el->size(); ++i)
        if (el->at(i) == M) return i ? el->at(i - 1) : nullptr;
    return nullptr;
}
// The DECLARED KIND of a receiver, read off its actual: `array_var`,
// `string_var`, `packed_array_var`, ... or `?` when it is bare.
static std::string recvKind(const BaseClass* R) {
    const BaseClass* a = actualOf(R);
    return a ? kindOf(a) : std::string("?");
}
// Print every field the generated Compare can read, plus the parent chain.
// `depth` levels of SINGULAR edges are followed (the typespec chain is two
// links long — ref_typespec then the actual typespec — and the mint's whole
// question is what sits at the end of it).
static void dumpFields(const BaseClass* X, int depth = 2, const char* pad = "      ") {
    if (!X) { printf("%s<null>\n", pad); return; }
    printf("%s%s\n", pad, ident(X).c_str());
    if (depth == 2) printf("%sparents: %s\n", pad, parentPath(X).c_str());
    for (int t = 1; t <= 2100; ++t) {
        auto tup = X->GetByVpiType(t);
        const BaseClass* one = std::get<0>(tup);
        const std::vector<const BaseClass*>* vec = std::get<2>(tup);
        if (one) {
            printf("%sedge %d -> %s\n", pad, t, ident(one).c_str());
            if (depth > 0 && one != X->VpiParent())
                dumpFields(one, depth - 1, (std::string(pad) + "    ").c_str());
        }
        if (vec) {
            printf("%sedge %d [%zu]", pad, t, vec->size());
            for (auto* e : *vec) printf(" %s", face(e).c_str());
            printf("\n");
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr,
                "usage: ct193arg own    <golden.uhdm> <ours.uhdm>\n"
                "       ct193arg skip   <golden.uhdm> <ours.uhdm> [rounds]\n"
                "       ct193arg mfc    <db.uhdm> [name-substr]\n"
                "       ct193arg mint   <db.uhdm>\n"
                "       ct193arg cenall <db.uhdm>\n"
                "       ct193arg pred   <golden.uhdm> <ours.uhdm>\n");
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
            if (!H) { printf("---- %s ---- <null>\n", side ? "OURS" : "GOLDEN"); continue; }
            indexDyn(S);
            indexContainment(S);
            printf("---- %s ----\n", side ? "OURS" : "GOLDEN");
            dumpFields(H);
            printf("  listing: %s   sub: %s   ctx: %s   face: %s  MINT=%d\n",
                   listingOf(H).c_str(), subName(H).c_str(), ctxOf(H).c_str(),
                   faceOf(H).c_str(), (int)isMint(H));
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
                    printf("        listing %s  sub %s  face=%s ctx=%s\n",
                           listingOf(X).c_str(), subName(X).c_str(),
                           faceOf(X).c_str(), ctxOf(X).c_str());
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
        indexContainment(sg);
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
            printf("         LHS listing %s | sub %s | %s\n",
                   listingOf(c.m_failedLhs).c_str(),
                   subName(c.m_failedLhs).c_str(),
                   parentPath(c.m_failedLhs).c_str());
            if (!c.m_failedLhs) break;
            seeds.push_back(c.m_failedLhs);
        }
        return 0;
    }

    // ================= MODE mfc ==========================================
    // ONE ROW PER built-in method call written on a receiver.
    if (mode == "mfc") {
        Serializer S;
        if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
        indexPkgViews(S);
        indexDyn(S);
        indexContainment(S);
        const std::string sub = argc > 3 ? argv[3] : "";
        std::vector<std::string> rows;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X || X->UhdmType() != uhdmmethod_func_call) continue;
            const BaseClass* R = recvOf(X);
            if (!R) continue;
            std::string sn = subName(X);
            std::string ls = listingOf(X);
            if (!sub.empty() && sn.find(sub) == std::string::npos &&
                ls.find(sub) == std::string::npos)
                continue;
            char b[2400];
            snprintf(b, sizeof b,
                     "%-42s | %-46s | %u:%-3u | meth=%-14s | recv=%-26s rk=%-16s |",
                     ls.c_str(), sn.c_str(), X->VpiLineNo(),
                     (unsigned)X->VpiColumnNo(),
                     std::string(X->VpiName()).c_str(), face(R).c_str(),
                     recvKind(R).c_str());
            std::string line = b;
            auto* ar = ((const method_func_call*)X)->Tf_call_args();
            if (ar)
                for (size_t i = 0; i < ar->size(); ++i) {
                    const BaseClass* A = ar->at(i);
                    snprintf(b, sizeof b, " a%zu=%s->%s%s", i,
                             face(A).c_str(), face(actualOf(A)).c_str(),
                             isMint(A) ? "[MINT]" : "");
                    line += b;
                }
            else
                line += " <noargs>";
            rows.push_back(line);
        }
        std::sort(rows.begin(), rows.end());
        for (auto& r : rows) printf("%s\n", r.c_str());
        printf("-- calls=%zu\n", rows.size());
        return 0;
    }

    // ================= MODE mint =========================================
    // Every MINT in the database, with every reference that binds to it.  One
    // forward pass builds the actual -> referrers map, so this is linear.
    if (mode == "mint") {
        Serializer S;
        if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
        indexPkgViews(S);
        indexDyn(S);
        indexContainment(S);
        std::map<const BaseClass*, std::vector<const BaseClass*>> back;
        std::vector<const BaseClass*> mints;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            if (isMint(X)) mints.push_back(X);
            auto t = X->UhdmType();
            if (t == uhdmref_obj || t == uhdmref_var || t == uhdmbit_select)
                if (const BaseClass* a = actualOf(X)) back[a].push_back(X);
        }
        std::sort(mints.begin(), mints.end(),
                  [](const BaseClass* a, const BaseClass* b) {
                      return ident(a) < ident(b);
                  });
        for (auto* X : mints) {
            printf("MINT %-46s | %-42s | %-46s | ctx=%-8s under=%s\n",
                   ident(X).c_str(), listingOf(X).c_str(), subName(X).c_str(),
                   ctxOf(X).c_str(), face(X->VpiParent()).c_str());
            dumpFields(X);
            auto it = back.find(X);
            if (it != back.end()) {
                std::vector<std::string> rs;
                for (auto* Y : it->second) {
                    char b[1400];
                    snprintf(b, sizeof b,
                             "      <- %-34s listing %-40s sub %-40s face=%s ctx=%s",
                             ident(Y).c_str(), listingOf(Y).c_str(),
                             subName(Y).c_str(), faceOf(Y).c_str(),
                             ctxOf(Y).c_str());
                    rs.push_back(b);
                }
                std::sort(rs.begin(), rs.end());
                for (auto& r : rs) printf("%s\n", r.c_str());
            } else {
                printf("      <- (no reference binds it)\n");
            }
        }
        printf("-- mints=%zu\n", mints.size());
        return 0;
    }

    // ================= MODE at ===========================================
    // Every object whose START LINE is N: kind, name, span, parent, typespec.
    // The instrument that says WHAT Surelog wrote at a declaration.
    if (mode == "at") {
        if (argc < 4) return 2;
        Serializer S;
        if (S.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL\n"); return 3; }
        indexPkgViews(S);
        indexDyn(S);
        indexContainment(S);
        const unsigned want = (unsigned)atoi(argv[3]);
        std::vector<std::string> rows;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X || X->VpiLineNo() != want) continue;
            char b[2400];
            snprintf(b, sizeof b, "%-44s | %-40s | %-42s | parent=%-30s",
                     ident(X).c_str(), listingOf(X).c_str(), subName(X).c_str(),
                     face(X->VpiParent()).c_str());
            std::string line = b;
            for (int t = 1; t <= 2100; ++t) {
                auto tup = X->GetByVpiType(t);
                const BaseClass* one = std::get<0>(tup);
                const std::vector<const BaseClass*>* vec = std::get<2>(tup);
                if (one) {
                    snprintf(b, sizeof b, " e%d->%s", t, face(one).c_str());
                    line += b;
                }
                if (vec) {
                    snprintf(b, sizeof b, " e%d[%zu]", t, vec->size());
                    line += b;
                    for (auto* e : *vec) { line += " "; line += face(e); }
                }
            }
            rows.push_back(line);
        }
        std::sort(rows.begin(), rows.end());
        for (auto& r : rows) printf("%s\n", r.c_str());
        printf("-- objects=%zu\n", rows.size());
        return 0;
    }

    // ================= MODE cenall =======================================
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
            snprintf(key, sizeof key,
                     "%-42s | %-46s | %-7s | %-8s | %u:%u | %s",
                     listingOf(X).c_str(), subName(X).c_str(),
                     faceOf(X).c_str(), ctxOf(X).c_str(), X->VpiLineNo(),
                     (unsigned)X->VpiColumnNo(),
                     std::string(X->VpiName()).c_str());
            // THE VALUE carries the ACTUAL at identity granularity plus, when
            // the actual is a MINT, the whole shape of the mint: its kind, its
            // span and the CALL it hangs off.  A MINT IS NOT KEYED ON ITS OWN
            // LISTING, and this is the measurement that says why: golden
            // parents its mint at the HOME listing's call
            // (`method_func_call::DeepClone` writes `obj->VpiParent()`, the
            // ORIGINAL argument's parent) and we parent ours at the CLONE's
            // own call, so a mint row keyed on the mint's own listing does not
            // join and scores a phantom AWAY (measured on arm D: golden 9
            // mints, pristine 7, patched 9 — the same multiset of REFERRERS on
            // golden and patched, and a 2-count "AWAY" purely from the key).
            // Keyed on the REFERENCE, as here, the parenting residue is
            // invisible to the census exactly as it is to the judge (no
            // generated `Compare` reads `VpiParent`, RESUME §9).
            const BaseClass* act = actualOf(X);
            std::string val = "act=" + face(act);
            if (isMint(act)) {
                char mb[600];
                snprintf(mb, sizeof mb, " MINT[%s@%u:%u-%u:%u under %s]",
                         kindOf(act).c_str(), act->VpiLineNo(),
                         (unsigned)act->VpiColumnNo(), act->VpiEndLineNo(),
                         (unsigned)act->VpiEndColumnNo(),
                         std::string(act->VpiParent()->VpiName()).c_str());
                val += mb;
            }
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
        // The ORPHAN count is reported OUTSIDE the keyed census (a `--` line,
        // which score193.py skips): a mint no reference binds is invisible to
        // the judge but would be a manufactured object, so it is counted.
        size_t mints = 0, orphans = 0;
        {
            std::set<const BaseClass*> bound;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* X = kv.first;
                if (!X) continue;
                auto t = X->UhdmType();
                if (t == uhdmref_obj || t == uhdmref_var ||
                    t == uhdmbit_select)
                    if (const BaseClass* a = actualOf(X)) bound.insert(a);
            }
            for (auto& kv : S.AllObjects())
                if (isMint(kv.first)) {
                    ++mints;
                    if (!bound.count(kv.first)) ++orphans;
                }
        }
        printf("-- keys=%zu cells=%zu mints=%zu orphan_mints=%zu\n",
               cen.size(), rows, mints, orphans);
        return 0;
    }

    // ================= MODE pred =========================================
    if (mode == "pred") {
        if (argc < 4) return 2;
        Serializer sg, so;
        if (sg.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
        if (so.Restore(std::string(argv[3])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
        // Key: listing | sub | call line:col | method | arg index | arg name.
        // Value: "MINT" when the argument's actual is a variable parented at
        // the call (r10uvm184's R2 shape), else "OTHER"/"BARE".
        auto collect = [](Serializer& S,
                          std::map<std::string, std::vector<std::string>>& out) {
            g_pkgView.clear();
            indexPkgViews(S);
            indexDyn(S);
            indexContainment(S);
            for (auto& kv : S.AllObjects()) {
                const BaseClass* X = kv.first;
                if (!X || X->UhdmType() != uhdmmethod_func_call) continue;
                const BaseClass* R = recvOf(X);
                if (!R) continue;
                auto* ar = ((const method_func_call*)X)->Tf_call_args();
                if (!ar) continue;
                for (size_t i = 0; i < ar->size(); ++i) {
                    const BaseClass* A = ar->at(i);
                    if (!A) continue;
                    char key[2400];
                    snprintf(key, sizeof key, "%s | %s | %u:%u | %s | a%zu | %s",
                             listingOf(X).c_str(), subName(X).c_str(),
                             X->VpiLineNo(), (unsigned)X->VpiColumnNo(),
                             std::string(X->VpiName()).c_str(), i,
                             std::string(A->VpiName()).c_str());
                    const BaseClass* act = actualOf(A);
                    out[key].push_back(isMint(act) ? "MINT"
                                                   : (act ? "OTHER" : "BARE"));
                }
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
            size_t gm = 0, om = 0;
            for (auto& v : kv.second) if (v == "MINT") gm++;
            for (auto& v : it->second) if (v == "MINT") om++;
            if (gm > om) {
                printf("CELL %s   golden MINT=%zu ours MINT=%zu\n",
                       kv.first.c_str(), gm, om);
                cells += gm - om;
            }
        }
        printf("PREDICTED_CELLS=%zu\n", cells);
        return 0;
    }

    fprintf(stderr, "unknown mode %s\n", mode.c_str());
    return 2;
}
