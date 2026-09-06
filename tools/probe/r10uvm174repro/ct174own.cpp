// r10uvm174 — THE OWNER-FINDER for a head whose BOTH sides are present.
// MEASUREMENT ONLY; the official `~/git-repos/UHDM/build/bin/uhdm-cmp` is the
// sole judge; this tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// The r10uvm173 R0 head is a `VpiType` mismatch (`BaseClass::Compare`'s FIRST
// test), so `m_failedLhs` and `m_failedRhs` are BOTH set and the question is
// not "who owns the null" but "which EDGE of which owner holds them".  This
// tool answers it symmetrically: for each side it prints the head's parent
// chain and then scans that side's `AllObjects` for every edge (via the
// generated, kind-agnostic `GetByVpiType`) that lands on the head, printing
// the SAME edge of the other side's face-matched counterpart.
//
// STEP 2 lists, on BOTH sides, every `sys_func_call` and every `constant`
// sitting at a named FILE:LINE, with its parent chain — the "what did the
// other producer put here" question, asked of the raw databases.
//
// build: g++ -O2 -std=c++17 ct174own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct174own
// usage: ct174own <golden.uhdm> <ours.uhdm> [<line> [<line> ...]]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
#include <set>
#include <string>
#include <vector>

using namespace UHDM;

static std::string ident(const BaseClass* o) {
    if (!o) return "<null>";
    char b[1200];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u#%u",
             UhdmName(o->UhdmType()).data(), std::string(o->VpiName()).c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo(), o->UhdmId());
    return b;
}
static std::string face(const BaseClass* o) {
    if (!o) return "<null>";
    char b[1200];
    snprintf(b, sizeof b, "%s(%s)@%u:%u-%u:%u",
             UhdmName(o->UhdmType()).data(), std::string(o->VpiName()).c_str(),
             o->VpiLineNo(), (unsigned)o->VpiColumnNo(), o->VpiEndLineNo(),
             (unsigned)o->VpiEndColumnNo());
    return b;
}
static std::string parentPath(const BaseClass* o) {
    std::string s;
    int g = 0;
    for (const BaseClass* p = o->VpiParent(); p && g < 64; p = p->VpiParent(), ++g) {
        s += "<";
        s += UhdmName(p->UhdmType());
        s += ":";
        s += p->VpiName();
        s += ":";
        s += std::to_string(p->VpiLineNo());
    }
    return s;
}
static const design* topDesign(Serializer& s) {
    for (auto& kv : s.AllObjects())
        if (kv.first && kv.first->UhdmType() == uhdmdesign)
            return (const design*)kv.first;
    return nullptr;
}
static void printChain(const char* tag, const BaseClass* o) {
    printf("%s parent chain:\n", tag);
    int g = 0;
    for (const BaseClass* p = o ? o->VpiParent() : nullptr; p && g < 64;
         p = p->VpiParent(), ++g)
        printf("    < %s\n", ident(p).c_str());
}
// Which LISTING does `o` live in?  Structural, so both producers answer the
// same way: walk to the outermost container and ask the design whether that
// package object is in AllPackages (the DEF listing) or TopPackages (the
// ELABORATED listing).
static std::string listingOf(const design* d, const BaseClass* o) {
    const BaseClass* root = o;
    int g = 0;
    for (const BaseClass* p = o; p && g < 128; p = p->VpiParent(), ++g) root = p;
    if (!d) return "?";
    if (auto* ap = d->AllPackages())
        for (auto* p : *ap)
            if ((const BaseClass*)p == root) return "PKGDEF:" + std::string(p->VpiName());
    if (auto* tp = d->TopPackages())
        for (auto* p : *tp)
            if ((const BaseClass*)p == root) return "PKGELAB:" + std::string(p->VpiName());
    if (auto* am = d->AllModules())
        for (auto* m : *am)
            if ((const BaseClass*)m == root) return "MODDEF:" + std::string(m->VpiDefName());
    if (auto* tm = d->TopModules())
        for (auto* m : *tm)
            if ((const BaseClass*)m == root) return "MODELAB:" + std::string(m->VpiDefName());
    if (auto* ac = d->AllClasses())
        for (auto* c : *ac)
            if ((const BaseClass*)c == root) return "CLASSDEF:" + std::string(c->VpiName());
    return std::string("ROOT:") + UhdmName(root->UhdmType()).data() + ":" +
           std::string(root->VpiName());
}

static void edgeScan(Serializer& S, Serializer& O, const design* dOther,
                     const BaseClass* H, const char* sideName,
                     const char* otherName) {
    printf("EDGE SCAN — every edge of %s that lands on the head, and %s's:\n",
           sideName, otherName);
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
            printf("  %s %s\n      edge vpiType=%d %s\n", sideName,
                   ident(X).c_str(), t,
                   idx == -2 ? "(singular)"
                             : ("(vector index " + std::to_string(idx) + ")").c_str());
            int nm = 0;
            for (auto& kv2 : O.AllObjects()) {
                const BaseClass* Y = kv2.first;
                if (!Y) continue;
                if (face(X) != face(Y) || parentPath(X) != parentPath(Y)) continue;
                ++nm;
                auto tu2 = Y->GetByVpiType(t);
                const BaseClass* o2 = std::get<0>(tu2);
                const std::vector<const BaseClass*>* v2 = std::get<2>(tu2);
                if (idx == -2)
                    printf("      %s %s [%s] -> singular %s\n", otherName,
                           ident(Y).c_str(), listingOf(dOther, Y).c_str(),
                           ident(o2).c_str());
                else
                    printf("      %s %s [%s] -> vector %s size %zu, [%d] = %s\n",
                           otherName, ident(Y).c_str(), listingOf(dOther, Y).c_str(),
                           v2 ? "present" : "NULL", v2 ? v2->size() : 0, idx,
                           (v2 && (size_t)idx < v2->size()) ? ident(v2->at(idx)).c_str()
                                                            : "-");
            }
            if (!nm) printf("      %s NO COUNTERPART for the referrer\n", otherName);
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct174own <golden> <ours> [line ...]\n"); return 2; }
    std::set<unsigned> lines;
    for (int i = 3; i < argc; ++i) lines.insert((unsigned)atoi(argv[i]));
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS(golden) = %s  [%s]\n", ident(c.m_failedLhs).c_str(),
           c.m_failedLhs ? listingOf(dg, c.m_failedLhs).c_str() : "-");
    printf("HEAD RHS(ours)   = %s  [%s]\n", ident(c.m_failedRhs).c_str(),
           c.m_failedRhs ? listingOf(dou, c.m_failedRhs).c_str() : "-");
    if (c.m_failedLhs) printChain("HEAD LHS(golden)", c.m_failedLhs);
    if (c.m_failedRhs) printChain("HEAD RHS(ours)", c.m_failedRhs);
    // The head's own field vectors, both sides.
    for (int side = 0; side < 2; ++side) {
        const BaseClass* H = side ? c.m_failedRhs : c.m_failedLhs;
        if (!H) continue;
        printf("FIELDS of HEAD %s:\n", side ? "RHS(ours)" : "LHS(golden)");
        if (auto* sf = any_cast<const sys_func_call*>(H)) {
            printf("    sys_func_call VpiName=%s\n", std::string(sf->VpiName()).c_str());
            if (auto* a = sf->Tf_call_args())
                for (size_t i = 0; i < a->size(); ++i)
                    printf("    arg[%zu] = %s   parent=%s\n", i,
                           ident(a->at(i)).c_str(), ident(a->at(i)->VpiParent()).c_str());
            else
                printf("    Tf_call_args = <null>\n");
        }
        if (auto* k = any_cast<const constant*>(H))
            printf("    constant VpiValue=%s VpiDecompile=%s VpiSize=%d "
                   "VpiConstType=%d Typespec=%s\n",
                   std::string(k->VpiValue()).c_str(),
                   std::string(k->VpiDecompile()).c_str(), (int)k->VpiSize(),
                   (int)k->VpiConstType(),
                   k->Typespec() ? ident(k->Typespec()).c_str() : "<null>");
    }
    if (c.m_failedLhs) edgeScan(sg, so, dou, c.m_failedLhs, "golden", "ours");
    if (c.m_failedRhs) edgeScan(so, sg, dg, c.m_failedRhs, "ours", "golden");

    // ---- STEP 2 — every sys_func_call / constant on the named LINES -------
    if (!lines.empty()) {
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            const design* D = side ? dou : dg;
            printf("---- OBJECTS ON THE NAMED LINES, %s ----\n",
                   side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || !lines.count(o->VpiLineNo())) continue;
                if (o->UhdmType() != uhdmsys_func_call &&
                    o->UhdmType() != uhdmconstant)
                    continue;
                char b[3000];
                std::string extra;
                if (auto* k = any_cast<const constant*>(o))
                    extra = " val=" + std::string(k->VpiValue()) +
                            " size=" + std::to_string(k->VpiSize()) +
                            " ctype=" + std::to_string(k->VpiConstType());
                if (auto* sf = any_cast<const sys_func_call*>(o)) {
                    extra = " args=";
                    if (auto* a = sf->Tf_call_args())
                        for (auto* x : *a) extra += face(x) + " ";
                    else
                        extra += "<null>";
                }
                snprintf(b, sizeof b, "  %-22s %-46s %s%s", listingOf(D, o).c_str(),
                         face(o).c_str(), parentPath(o).c_str(), extra.c_str());
                rows.push_back(b);
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s : rows) printf("%s\n", s.c_str());
            if (rows.empty()) printf("  (none)\n");
        }
    }
    return 0;
}
