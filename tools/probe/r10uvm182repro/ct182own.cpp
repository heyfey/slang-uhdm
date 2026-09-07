// r10uvm182 — THE OWNER-FINDER for a head whose LHS is PRESENT and whose
// RHS is `<null>` (BaseClass.h's SINGULAR SafeCompare, `:191-193`, or the
// VECTOR overload's element loop landing on a null element of OURS).
// MEASUREMENT ONLY.  `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge;
// this tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Direct descendant of r10uvm164repro/ct164own.cpp — the MIRROR of it.  That
// tool scans OUR database for the edges that land on a head whose LHS is null;
// this head is the other half of the same overload, so the scan runs over
// GOLDEN and the counterpart edge is printed from OURS, matched by face
// (kind + name + span) plus the ancestor FACE PATH (`VpiFullName` is not on
// BaseClass and the judge never reads it).
//
// `GetByVpiType` is the generated, kind-agnostic edge accessor, so no field is
// named by hand and no edge can be missed by omission.  BOTH the singular and
// the vector arms are reported, and for a vector the SIZES of both sides are
// printed — that is what separates "our element is null" from "our vector is
// one short" from "our vector holds a different kind at that index".
//
// STEP 2 lists, on both sides, every hier_path whose name matches a substring,
// with its full element list (kind + name + span) — the family census in the
// small.
//
// build: g++ -O2 -std=c++17 ct182own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct182own
// usage: ct182own <golden.uhdm> <ours.uhdm> [<hier_path name substring>]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <cstdio>
#include <cstring>
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
static void printElems(const BaseClass* o) {
    const hier_path* hp = any_cast<const hier_path*>(o);
    if (!hp) return;
    const VectorOfany* v = hp->Path_elems();
    printf("      elems n=%zu :", v ? v->size() : 0);
    if (v)
        for (auto* e : *v) printf(" %s", ident(e).c_str());
    printf("\n");
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct182own <golden> <ours> [hp-name-substr]\n");
        return 2;
    }
    const char* want = argc > 3 ? argv[3] : nullptr;
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS(golden) = %s\n", ident(c.m_failedLhs).c_str());
    printf("HEAD RHS(ours)   = %s\n", ident(c.m_failedRhs).c_str());
    const BaseClass* HL = c.m_failedLhs;
    if (!HL) return 0;
    printf("HEAD LHS parent chain:\n");
    for (const BaseClass* p = HL->VpiParent(); p; p = p->VpiParent())
        printf("    < %s\n", ident(p).c_str());

    printf("EDGE SCAN — every edge of GOLDEN that lands on the head, and ours:\n");
    for (auto& kv : sg.AllObjects()) {
        const BaseClass* X = kv.first;
        if (!X) continue;
        for (int t = 1; t <= 2100; ++t) {
            auto tup = X->GetByVpiType(t);
            const BaseClass* one = std::get<0>(tup);
            const std::vector<const BaseClass*>* vec = std::get<2>(tup);
            int idx = -1;
            if (one == HL) idx = -2;
            if (vec)
                for (size_t i = 0; i < vec->size(); ++i)
                    if (vec->at(i) == HL) idx = (int)i;
            if (idx == -1) continue;
            printf("  golden %s\n      edge vpiType=%d %s\n", ident(X).c_str(), t,
                   idx == -2 ? "(singular)"
                             : ("(vector index " + std::to_string(idx) + ")").c_str());
            printElems(X);
            int nm = 0;
            for (auto& kv2 : so.AllObjects()) {
                const BaseClass* Y = kv2.first;
                if (!Y || !sameFace(X, Y) || parentPath(X) != parentPath(Y)) continue;
                ++nm;
                auto tu2 = Y->GetByVpiType(t);
                const BaseClass* o2 = std::get<0>(tu2);
                const std::vector<const BaseClass*>* v2 = std::get<2>(tu2);
                if (idx == -2)
                    printf("      ours   %s -> singular %s\n", ident(Y).c_str(),
                           ident(o2).c_str());
                else
                    printf("      ours   %s -> vector %s size %zu, [%d] = %s\n",
                           ident(Y).c_str(), v2 ? "present" : "NULL",
                           v2 ? v2->size() : 0, idx,
                           (v2 && (size_t)idx < v2->size()) ? ident(v2->at(idx)).c_str()
                                                            : "-");
                printElems(Y);
            }
            if (!nm) printf("      ours   NO COUNTERPART for the referrer\n");
        }
    }

    if (want) {
        printf("HIER_PATHS matching \"%s\" — golden then ours:\n", want);
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || o->UhdmType() != uhdmhier_path) continue;
                const std::string nm(o->VpiName());
                if (nm.find(want) == std::string::npos) continue;
                const hier_path* hp = (const hier_path*)o;
                std::string row = "    " + ident(o) + " :";
                const VectorOfany* v = hp->Path_elems();
                row += " n=" + std::to_string(v ? v->size() : 0);
                if (v)
                    for (auto* e : *v) row += " " + ident(e);
                rows.push_back(row);
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s : rows) printf("%s\n", s.c_str());
            if (rows.empty()) printf("    (none)\n");
        }
    }
    return 0;
}
