// r10uvm186 — THE OWNER-FINDER for the function-local-static LISTING head.
// MEASUREMENT ONLY.  `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge;
// this tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Descendant of r10uvm164repro/ct164own.cpp (the MIRROR form, LHS null) and
// r10uvm182repro/ct182own.cpp (LHS present, RHS null).  This one runs BOTH
// scans — whichever side of the head is non-null is the one scanned — because
// the head's overload is exactly what has to be decoded and not assumed.
//
// STEP 1  the head, its parent chain, and every edge that lands on it, with
//         the counterpart edge on the other side printed by FACE match
//         (kind + name + span) plus ancestor FACE PATH.  For a VECTOR edge
//         BOTH sizes and the element at the index are printed — that is what
//         separates "our element is null" from "our vector is one short".
// STEP 2  for every scope object (task/function/begin/named_begin/fork/...)
//         whose VpiName contains a substring, the FULL `vpiVariables` listing
//         on both sides, in order, with each entry's compared fields.
// STEP 3  every `variables` object anywhere whose VpiName matches a second
//         substring, on both sides, with its owner edge.
//
// build: g++ -O2 -std=c++17 ct186own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct186own
// usage: ct186own <golden.uhdm> <ours.uhdm> [scope-name-substr] [var-name-substr]
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
    char b[1200];
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
// The fields `variables::Compare` and its bases actually read, plus the
// dump-only ones marked so.
static std::string varFields(const BaseClass* o) {
    char b[1600];
    const variables* v = any_cast<const variables*>(o);
    std::string ts = "-";
    if (v && v->Typespec()) {
        const ref_typespec* rt = v->Typespec();
        ts = std::string(UhdmName(rt->UhdmType()));
        if (rt->Actual_typespec())
            ts += "->" + std::string(UhdmName(rt->Actual_typespec()->UhdmType()));
        else
            ts += "->" + std::string("<null>");
    }
    const nets* n = nullptr;
    (void)n;
    snprintf(b, sizeof b,
             "auto=%d const=%d sgn=%d ts=%s | DUMPONLY parent=%s",
             v ? (int)v->VpiAutomatic() : -1, v ? (int)v->VpiConstantVariable() : -1,
             v ? (int)v->VpiSigned() : -1, ts.c_str(),
             ident(o->VpiParent()).c_str());
    return b;
}
static void dumpScope(const BaseClass* sc) {
    printf("  SCOPE %s  parentchain %s\n", ident(sc).c_str(), parentPath(sc).c_str());
    const scope* s = any_cast<const scope*>(sc);
    const VectorOfvariables* vars = s ? s->Variables() : nullptr;
    printf("    vpiVariables: %s n=%zu\n", vars ? "present" : "NULL",
           vars ? vars->size() : 0);
    if (vars)
        for (size_t i = 0; i < vars->size(); ++i)
            printf("      [%zu] %s  %s\n", i, ident(vars->at(i)).c_str(),
                   varFields(vars->at(i)).c_str());
    // statements, so the listing question can be told from the ordering one
    if (const begin* b = any_cast<const begin*>(sc)) {
        const VectorOfany* st = b->Stmts();
        printf("    vpiStmt: n=%zu\n", st ? st->size() : 0);
        if (st)
            for (size_t i = 0; i < st->size(); ++i)
                printf("      s[%zu] %s\n", i, ident(st->at(i)).c_str());
    }
    if (const named_begin* b = any_cast<const named_begin*>(sc)) {
        const VectorOfany* st = b->Stmts();
        printf("    vpiStmt: n=%zu\n", st ? st->size() : 0);
        if (st)
            for (size_t i = 0; i < st->size(); ++i)
                printf("      s[%zu] %s\n", i, ident(st->at(i)).c_str());
    }
    if (const task_func* t = any_cast<const task_func*>(sc)) {
        printf("    vpiStmt(single): %s\n", ident(t->Stmt()).c_str());
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: ct186own <golden> <ours> [scope-substr] [var-substr]\n");
        return 2;
    }
    const char* scopeWant = argc > 3 ? argv[3] : nullptr;
    const char* varWant = argc > 4 ? argv[4] : nullptr;
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

    // ---- STEP 1 — the edge scan, run on whichever side is present -------
    for (int side = 0; side < 2; ++side) {
        const BaseClass* H = side ? c.m_failedRhs : c.m_failedLhs;
        if (!H) continue;
        Serializer& S = side ? so : sg;
        Serializer& O = side ? sg : so;
        printf("HEAD %s parent chain:\n", side ? "RHS(ours)" : "LHS(golden)");
        for (const BaseClass* p = H->VpiParent(); p; p = p->VpiParent())
            printf("    < %s\n", ident(p).c_str());
        printf("EDGE SCAN over %s — every edge landing on the head, and the other side's:\n",
               side ? "OURS" : "GOLDEN");
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
                printf("  %s %s\n      edge vpiType=%d %s (this side's vector size %zu)\n",
                       side ? "ours  " : "golden", ident(X).c_str(), t,
                       idx == -2 ? "(singular)"
                                 : ("(vector index " + std::to_string(idx) + ")").c_str(),
                       vec ? vec->size() : 0);
                int nm = 0;
                for (auto& kv2 : O.AllObjects()) {
                    const BaseClass* Y = kv2.first;
                    if (!Y || !sameFace(X, Y) || parentPath(X) != parentPath(Y)) continue;
                    ++nm;
                    auto tu2 = Y->GetByVpiType(t);
                    const BaseClass* o2 = std::get<0>(tu2);
                    const std::vector<const BaseClass*>* v2 = std::get<2>(tu2);
                    if (idx == -2)
                        printf("      %s %s -> singular %s\n", side ? "golden" : "ours  ",
                               ident(Y).c_str(), ident(o2).c_str());
                    else {
                        printf("      %s %s -> vector %s size %zu, [%d] = %s\n",
                               side ? "golden" : "ours  ", ident(Y).c_str(),
                               v2 ? "present" : "NULL", v2 ? v2->size() : 0, idx,
                               (v2 && (size_t)idx < v2->size())
                                   ? ident(v2->at(idx)).c_str() : "-");
                        if (v2)
                            for (size_t i = 0; i < v2->size(); ++i)
                                printf("          [%zu] %s\n", i, ident(v2->at(i)).c_str());
                    }
                }
                if (!nm) printf("      NO COUNTERPART for the referrer on the other side\n");
            }
        }
    }

    // ---- STEP 2 — every named scope's variable listing, both sides ------
    if (scopeWant) {
        printf("SCOPE LISTINGS matching \"%s\" — golden then ours:\n", scopeWant);
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<const BaseClass*> hits;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || !any_cast<const scope*>(o)) continue;
                if (std::string(o->VpiName()).find(scopeWant) == std::string::npos)
                    continue;
                hits.push_back(o);
            }
            std::sort(hits.begin(), hits.end(),
                      [](const BaseClass* a, const BaseClass* b) {
                          if (a->VpiLineNo() != b->VpiLineNo())
                              return a->VpiLineNo() < b->VpiLineNo();
                          return a->UhdmId() < b->UhdmId();
                      });
            for (auto* h : hits) dumpScope(h);
            if (hits.empty()) printf("    (no scope matched)\n");
        }
    }

    // ---- STEP 3 — every variables object of a given name, both sides ----
    if (varWant) {
        printf("VARIABLE OBJECTS matching \"%s\" — golden then ours:\n", varWant);
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o || !any_cast<const variables*>(o)) continue;
                if (std::string(o->VpiName()).find(varWant) == std::string::npos)
                    continue;
                char b[3000];
                snprintf(b, sizeof b, "    %s\n        %s\n        chain %s",
                         ident(o).c_str(), varFields(o).c_str(),
                         parentPath(o).c_str());
                rows.push_back(b);
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s : rows) printf("%s\n", s.c_str());
            if (rows.empty()) printf("    (none)\n");
        }
    }
    // ---- STEP 4 — every REFERENCE-like object of that name, both sides --
    if (varWant) {
        printf("REFERENCE OBJECTS matching \"%s\" — golden then ours:\n", varWant);
        for (int side = 0; side < 2; ++side) {
            Serializer& S = side ? so : sg;
            printf("  ---- %s ----\n", side ? "OURS" : "GOLDEN");
            std::vector<std::string> rows;
            for (auto& kv : S.AllObjects()) {
                const BaseClass* o = kv.first;
                if (!o) continue;
                const UHDM_OBJECT_TYPE k = o->UhdmType();
                if (k != uhdmref_obj && k != uhdmref_var && k != uhdmhier_path &&
                    k != uhdmmethod_func_call && k != uhdmfunc_call &&
                    k != uhdmbit_select && k != uhdmvar_select)
                    continue;
                if (std::string(o->VpiName()).find(varWant) == std::string::npos)
                    continue;
                const BaseClass* act = nullptr;
                if (const ref_obj* r = any_cast<const ref_obj*>(o)) act = r->Actual_group();
                if (const ref_var* r = any_cast<const ref_var*>(o)) act = r->Actual_group();
                char b[3000];
                snprintf(b, sizeof b, "    %s\n        actual=%s\n        chain %s",
                         ident(o).c_str(), ident(act).c_str(), parentPath(o).c_str());
                rows.push_back(b);
            }
            std::sort(rows.begin(), rows.end());
            for (auto& s : rows) printf("%s\n", s.c_str());
            if (rows.empty()) printf("    (none)\n");
        }
    }
    return 0;
}
