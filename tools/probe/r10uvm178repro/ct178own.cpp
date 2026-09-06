// r10uvm178 — THE OWNER-FINDER, MIRROR FORM + THE PER-LISTING COPY MAP.
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole judge.  This tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// STEP 1 is r10uvm164's MIRROR scan verbatim (the head this pass owns is
// `LHS: <null>` with a full RHS — BaseClass.h's SINGULAR SafeCompare naming
// OUR value — so the object the judge stopped on lives in OUR database and the
// edge scan runs from ours to golden).
//
// STEP 2 is NEW and is the question this pass exists to answer: EVERY COPY of
// a named reference, PER LISTING, on both sides, with its binding.  A UVM
// package exists TWICE in each database (the design's `AllPackages` listing and
// its `TopPackages` listing), and a package that wildcard-imports another
// carries a CLONE of that package's listing, so "the reference" is really N
// copies and the judge pairs them listing by listing.  The listing key is the
// design-level vector membership of the reference's ancestor package plus that
// package object's own id — never a face, because the two listings' packages
// have identical faces.
//
// build: g++ -O2 -std=c++17 ct178own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct178own
// usage: ct178own <golden.uhdm> <ours.uhdm> [<reference-name substring>] [<fn substring>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[900];
    const std::string kind(UhdmName(o->UhdmType()));
    const std::string nm(o->VpiName());
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u", kind.c_str(), nm.c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static std::string parentPath(const BaseClass* o) {
    std::string s;
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        s += "<";
        s += UhdmName(p->UhdmType());
        s += ":";
        s += p->VpiName();
        s += ":";
        s += std::to_string(p->VpiLineNo());
    }
    return s;
}
static bool sameFace(const BaseClass* a, const BaseClass* b) {
    return a->UhdmType() == b->UhdmType() &&
           std::string(a->VpiName()) == std::string(b->VpiName()) &&
           a->VpiLineNo() == b->VpiLineNo() &&
           a->VpiColumnNo() == b->VpiColumnNo() &&
           a->VpiEndLineNo() == b->VpiEndLineNo() &&
           a->VpiEndColumnNo() == b->VpiEndColumnNo();
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (auto* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
static bool isRef(const BaseClass* o) {
    return any_cast<const ref_obj*>(o) || any_cast<const ref_var*>(o);
}
// the chain of enclosing kinds, innermost first, up to the owning package
static std::string castChain(const BaseClass* o) {
    std::string s;
    int n = 0;
    for (const BaseClass* p = o->VpiParent(); p && n < 4; p = p->VpiParent(), ++n) {
        if (!s.empty()) s += "/";
        s += UhdmName(p->UhdmType());
    }
    return s;
}

// ---- THE LISTING KEY -------------------------------------------------------
// design::AllPackages and design::TopPackages are the two package listings
// Surelog writes; a package appearing in both is the same OBJECT only when the
// pointers match, which they do not for the UVM rows.  The map is built from
// the design vectors, never from a face.
struct Listings {
    std::map<const BaseClass*, std::string> pkgTag;
    void build(const design* d) {
        if (auto* v = d->AllPackages())
            for (size_t i = 0; i < v->size(); ++i)
                pkgTag[(const BaseClass*)v->at(i)] +=
                    (pkgTag.count((const BaseClass*)v->at(i)) ? "+" : "") +
                    ("ALL[" + std::to_string(i) + "]");
        if (auto* v = d->TopPackages())
            for (size_t i = 0; i < v->size(); ++i)
                pkgTag[(const BaseClass*)v->at(i)] +=
                    (pkgTag.count((const BaseClass*)v->at(i)) &&
                             !pkgTag[(const BaseClass*)v->at(i)].empty()
                         ? "+"
                         : "") +
                    ("TOP[" + std::to_string(i) + "]");
    }
    // the listing an object belongs to = the design-vector tag of its
    // outermost package ancestor, plus that package's own id
    std::string of(const BaseClass* o) const {
        const BaseClass* pkg = nullptr;
        for (const BaseClass* p = o; p; p = p->VpiParent())
            if (p->UhdmType() == uhdmpackage) pkg = p;
        if (!pkg) return "<no-package-ancestor>";
        auto it = pkgTag.find(pkg);
        std::string tag = it == pkgTag.end() ? "UNLISTED" : it->second;
        return tag + " " + std::string(pkg->VpiName()) + "#" +
               std::to_string(pkg->UhdmId());
    }
};

// the innermost enclosing subroutine/class, for the HOME column
static std::string homeOf(const BaseClass* o) {
    std::string fn = "-", cl = "-";
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent()) {
        if (fn == "-" &&
            (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask))
            fn = std::string(p->VpiName());
        if (cl == "-" && p->UhdmType() == uhdmclass_defn)
            cl = std::string(p->VpiName());
    }
    return cl + "::" + fn;
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct178own <golden> <ours> [refname] [fn]\n");
        return 2;
    }
    const char* refWant = argc > 3 ? argv[3] : nullptr;
    const char* fnWant = argc > 4 ? argv[4] : nullptr;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    Listings lg, lo;
    lg.build(dg);
    lo.build(dou);

    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS(golden) = %s\n", ident(c.m_failedLhs).c_str());
    printf("HEAD RHS(ours)   = %s\n", ident(c.m_failedRhs).c_str());
    const BaseClass* HR = c.m_failedRhs;
    const BaseClass* HL = c.m_failedLhs;

    // ---- STEP 1 — THE MIRROR SCAN (r10uvm164's, verbatim) ---------------
    if (HR) {
        printf("HEAD RHS parent chain:\n");
        for (const BaseClass* p = HR->VpiParent(); p; p = p->VpiParent())
            printf("    < %s\n", ident(p).c_str());
        printf("HEAD RHS listing: %s\n", lo.of(HR).c_str());
        printf("MIRROR REFERENCE SCAN — every edge of OURS that lands on the head, and golden's:\n");
        for (auto& kv : so.AllObjects()) {
            const BaseClass* X = kv.first;
            if (!X) continue;
            for (int t = 1; t <= 2100; ++t) {
                auto tup = X->GetByVpiType(t);
                const BaseClass* one = std::get<0>(tup);
                const std::vector<const BaseClass*>* vec = std::get<2>(tup);
                int idx = -1;
                if (one == HR) idx = -2;
                if (vec)
                    for (size_t i = 0; i < vec->size(); ++i)
                        if (vec->at(i) == HR) idx = (int)i;
                if (idx == -1) continue;
                printf("  ours   %s  [%s]\n      edge vpiType=%d %s\n",
                       ident(X).c_str(), lo.of(X).c_str(), t,
                       idx == -2 ? "(singular)"
                                 : ("(vector index " + std::to_string(idx) + ")").c_str());
                int nm = 0;
                for (auto& kv2 : sg.AllObjects()) {
                    const BaseClass* Y = kv2.first;
                    if (!Y || !sameFace(X, Y) || parentPath(X) != parentPath(Y)) continue;
                    ++nm;
                    auto tu2 = Y->GetByVpiType(t);
                    const BaseClass* o2 = std::get<0>(tu2);
                    const std::vector<const BaseClass*>* v2 = std::get<2>(tu2);
                    if (idx == -2)
                        printf("      golden %s [%s] -> singular %s\n",
                               ident(Y).c_str(), lg.of(Y).c_str(), ident(o2).c_str());
                    else
                        printf("      golden %s [%s] -> vector %s size %zu, [%d] = %s\n",
                               ident(Y).c_str(), lg.of(Y).c_str(),
                               v2 ? "present" : "NULL", v2 ? v2->size() : 0, idx,
                               (v2 && (size_t)idx < v2->size()) ? ident(v2->at(idx)).c_str()
                                                                : "-");
                }
                if (!nm) printf("      golden NO COUNTERPART for the referrer\n");
            }
        }
    }
    if (HL && !HR) {
        printf("HEAD LHS parent chain:\n");
        for (const BaseClass* p = HL->VpiParent(); p; p = p->VpiParent())
            printf("    < %s\n", ident(p).c_str());
        printf("HEAD LHS listing: %s\n", lg.of(HL).c_str());
    }

    // ---- STEP 2 — THE PER-LISTING COPY MAP ------------------------------
    if (refWant) {
        printf("COPY MAP for reference name containing \"%s\"%s%s — golden then ours\n",
               refWant, fnWant ? ", function containing " : "",
               fnWant ? fnWant : "");
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            const Listings& L = side ? lo : lg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || !isRef(o)) continue;
                const std::string nm(o->VpiName());
                if (nm.find(refWant) == std::string::npos) continue;
                std::string home = homeOf(o);
                if (fnWant && home.find(fnWant) == std::string::npos) continue;
                char b[2000];
                const BaseClass* a = actualOf(o);
                snprintf(b, sizeof b,
                         "    %-46s | home %-40s | %4u:%-3u | %-22s | %s",
                         L.of(o).c_str(), home.c_str(), o->VpiLineNo(),
                         (unsigned)o->VpiColumnNo(), castChain(o).c_str(),
                         a ? ("BOUND -> " + ident(a)).c_str() : "BARE");
                rows.push_back(b);
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s : rows) printf("%s\n", s.c_str());
            printf("    (%zu copies)\n", rows.size());
        }
    }
    return 0;
}
