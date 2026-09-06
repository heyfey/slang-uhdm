// r10uvm181 — THE OWNER-FINDER, DIRECT FORM (LHS present, `RHS: <null>`).
// MEASUREMENT ONLY; `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge.
// This tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// r10uvm164's `ct164own.cpp` is the MIRROR (`LHS: <null>` with a full RHS): it
// scans OURS for the edge landing on the head and prints golden's same edge.
// THIS head is the other half of BaseClass.h's SINGULAR SafeCompare
// (`:191-193`, `lhs != null && rhs == null` -> `m_failedLhs = lhs`), so the
// object the judge stopped on lives in GOLDEN and the scan runs the other way:
// enumerate every edge of every object in GOLDEN that lands on the head, then
// print the SAME edge of our counterpart, matched by face (kind + name + span)
// and ancestor-face path.  `GetByVpiType` is the generated, kind-agnostic edge
// accessor, so no field is named by hand and no edge can be missed by omission.
//
// STEP 2 prints, for a named subroutine substring, EVERY foreach loop variable
// on both sides with its typespec edge and the array the loop iterates — the
// question this pass exists to answer.
//
// build: g++ -O2 -std=c++17 ct181own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct181own
// usage: ct181own <golden.uhdm> <ours.uhdm> [<subroutine name substring>]
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
// The typespec edge of any object that can carry one, plus what it points at.
static std::string tsEdge(const BaseClass* o) {
    const ref_typespec* rt = nullptr;
    if (auto* v = any_cast<const variables*>(o)) rt = v->Typespec();
    else if (auto* r = any_cast<const ref_obj*>(o)) rt = r->Typespec();
    if (!rt) return "TS=<null>";
    std::string s = "TS=" + ident(rt) + " -> " + ident(rt->Actual_typespec());
    return s;
}
static const BaseClass* actualOf(const BaseClass* o) {
    if (auto* r = any_cast<const ref_obj*>(o)) return r->Actual_group();
    if (auto* r = any_cast<const ref_var*>(o)) return r->Actual_group();
    return nullptr;
}
static const BaseClass* enclosingTf(const BaseClass* o, const char* want) {
    for (const BaseClass* p = o->VpiParent(); p; p = p->VpiParent())
        if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) {
            const std::string n(p->VpiName());
            if (!want || n.find(want) != std::string::npos) return p;
            return nullptr;
        }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct181own <golden> <ours> [tf]\n"); return 2; }
    const char* fnWant = argc > 3 ? argv[3] : nullptr;
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

    // ---- STEP 1 — THE DIRECT SCAN --------------------------------------
    if (HL) {
        printf("HEAD LHS parent chain:\n");
        for (const BaseClass* p = HL->VpiParent(); p; p = p->VpiParent())
            printf("    < %s\n", ident(p).c_str());
        printf("DIRECT REFERENCE SCAN — every edge of GOLDEN that lands on the head, and ours:\n");
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
                printf("  golden %s\n      edge vpiType=%d %s\n",
                       ident(X).c_str(), t,
                       idx == -2 ? "(singular)"
                                 : ("(vector index " + std::to_string(idx) + ")").c_str());
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
                }
                if (!nm) printf("      ours   NO COUNTERPART for the referrer\n");
            }
        }
        // Who ELSE in golden points at the head's own typespec target?  (the
        // SHARERS question: is #323101 the declaration's own array_typespec?)
        if (auto* hv = any_cast<const variables*>(HL))
            if (const ref_typespec* hrt = hv->Typespec())
                if (const BaseClass* tgt = hrt->Actual_typespec()) {
                    printf("SHARERS of the head's typespec target %s:\n",
                           ident(tgt).c_str());
                    int n = 0;
                    for (auto& kv : sg.AllObjects()) {
                        const BaseClass* X = kv.first;
                        if (!X) continue;
                        for (int t = 1; t <= 2100; ++t) {
                            auto tup = X->GetByVpiType(t);
                            if (std::get<0>(tup) != tgt) continue;
                            printf("    %s edge=%d  under %s\n", ident(X).c_str(), t,
                                   ident(X->VpiParent()).c_str());
                            ++n;
                        }
                    }
                    printf("    (%d sharer edges)\n", n);
                }
    }

    // ---- STEP 2 — EVERY FOREACH LOOP VARIABLE IN A NAMED SUBROUTINE -----
    printf("FOREACH LOOP VARIABLES%s%s — golden then ours:\n",
           fnWant ? " IN SUBROUTINES MATCHING " : " (WHOLE DESIGN)",
           fnWant ? fnWant : "");
    for (int side = 0; side < 2; ++side) {
        Serializer& S = side ? so : sg;
        printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
        std::vector<std::string> rows;
        for (auto& kv : S.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || o->UhdmType() != uhdmforeach_stmt) continue;
            auto* fs = (const foreach_stmt*)o;
            if (fnWant && !enclosingTf(o, fnWant)) continue;
            const BaseClass* tf = enclosingTf(o, nullptr);
            char b[1600];
            std::string lvs;
            if (auto* lv = fs->VpiLoopVars())
                for (auto* v : *lv) {
                    lvs += "  [ " + ident(v) + " " + tsEdge(v);
                    if (const BaseClass* a = actualOf(v))
                        lvs += " ACTUAL=" + ident(a);
                    lvs += " ]";
                }
            else
                lvs = "  <no loopvars vector>";
            snprintf(b, sizeof b, "    %5u:%-3u tf=%-52s arr=%s\n%s",
                     o->VpiLineNo(), (unsigned)o->VpiColumnNo(),
                     tf ? std::string(tf->VpiName()).c_str() : "-",
                     fs->Variables() && !fs->Variables()->empty()
                         ? ident(fs->Variables()->at(0)).c_str()
                         : "-",
                     lvs.c_str());
            rows.push_back(b);
        }
        std::sort(rows.begin(), rows.end());
        for (auto& s : rows) printf("%s\n", s.c_str());
        if (rows.empty()) printf("    (none)\n");
    }
    return 0;
}
