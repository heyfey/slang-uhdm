// r10uvm179 (r10uvm176's, reused) — THE OWNER-FINDER.  MEASUREMENT ONLY.
// `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge; this tool links the
// SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Taken VERBATIM from r10uvm175repro/ct175own.cpp (itself r10uvm172's, itself
// r10uvm171/161's) — only the pass name changes.  It is used here for TWO
// heads and both of its two report modes earn their keep:
//   * the head this pass CLEARS is `LHS: io_decl(a_test_name) / RHS: <null>`,
//     the SINGULAR `ref_obj::Actual_group` arm (BaseClass.h:186-190) — the
//     REFERENCE SCAN names the edge without any walk at all;
//   * the head it LEAVES (R0) is the MIRROR, `LHS: <null> / RHS: constant`,
//     so the object the judge stopped on lives in OUR database and the scan
//     runs the other way round.
//
// build: g++ -O2 -std=c++17 ct179own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct179own
// usage: ct179own <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
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
typedef std::map<const BaseClass*, std::vector<const BaseClass*>> kidmap_t;
static void buildKids(Serializer& s, kidmap_t& m) {
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o) continue;
        if (const BaseClass* p = o->VpiParent()) m[p].push_back(o);
    }
}
// `VpiFullName` is NOT on BaseClass (and RESUME.md §9: the judge never reads
// it anyway).  The counterpart match therefore keys on the object's own face
// plus the FACE SEQUENCE of its ancestors — kind + name + start line, which is
// what distinguishes two same-named methods in two different classes.
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
// Re-run the generated Compare on ONE pair with a FRESH context and report the
// head it produces.  Returns true when it is the SAME head the whole-design
// Compare produced (same failed LHS pointer, same failed RHS pointer).
static bool reproduces(const BaseClass* L, const BaseClass* R,
                       const BaseClass* HL, const BaseClass* HR) {
    if (!L || !R) return false;
    CompareContext c;
    L->Compare(R, &c);
    return c.m_failedLhs == HL && c.m_failedRhs == HR;
}

template <class V>
static void row(const char* nm, const V* l, const V* r) {
    bool ln = (l == nullptr), rn = (r == nullptr);
    printf("    %-24s LHS=%-6s RHS=%-6s\n", nm,
           ln ? "null" : std::to_string(l->size()).c_str(),
           rn ? "null" : std::to_string(r->size()).c_str());
    size_t n = ln ? 0 : l->size();
    size_t m = rn ? 0 : r->size();
    for (size_t i = 0; i < n || i < m; ++i)
        printf("        [%zu] LHS=%-58s RHS=%s\n", i,
               i < n ? ident(l->at(i)).c_str() : "-",
               i < m ? ident(r->at(i)).c_str() : "-");
}
static void sing(const char* nm, const BaseClass* l, const BaseClass* r) {
    printf("    %-24s LHS=%-58s RHS=%s\n", nm, ident(l).c_str(),
           ident(r).c_str());
}

// Print the fields of a pair, in the generated Compare's own order, for every
// kind this head's path can reach.  Anything else prints its scope vectors (if
// it is a scope) and nothing more — and SAYS so.
static void fields(const BaseClass* L, const BaseClass* R) {
    printf("  FIELDS of %s\n         vs %s\n", ident(L).c_str(), ident(R).c_str());
    if (auto* ls = any_cast<const scope*>(L)) {
        auto* rs = any_cast<const scope*>(R);
        printf("    -- scope::Compare vector order --\n");
        row("Property_decls", ls->Property_decls(), rs->Property_decls());
        row("Sequence_decls", ls->Sequence_decls(), rs->Sequence_decls());
        row("Concurrent_assertions", ls->Concurrent_assertions(), rs->Concurrent_assertions());
        row("Named_events", ls->Named_events(), rs->Named_events());
        row("Named_event_arrays", ls->Named_event_arrays(), rs->Named_event_arrays());
        row("Variables", ls->Variables(), rs->Variables());
        row("Virtual_interface_vars", ls->Virtual_interface_vars(), rs->Virtual_interface_vars());
        row("Logic_vars", ls->Logic_vars(), rs->Logic_vars());
        row("Array_vars", ls->Array_vars(), rs->Array_vars());
        row("Array_var_mems", ls->Array_var_mems(), rs->Array_var_mems());
        row("Parameters", ls->Parameters(), rs->Parameters());
        row("Param_assigns", ls->Param_assigns(), rs->Param_assigns());
        row("Scopes", ls->Scopes(), rs->Scopes());
        row("Typespecs", ls->Typespecs(), rs->Typespecs());
        row("Instance_items", ls->Instance_items(), rs->Instance_items());
        row("Let_decls", ls->Let_decls(), rs->Let_decls());
        row("Attributes", ls->Attributes(), rs->Attributes());
    }
    if (auto* lb = any_cast<const begin*>(L))
        row("begin::Stmts", lb->Stmts(), ((const begin*)R)->Stmts());
    if (auto* lb = any_cast<const named_begin*>(L))
        row("named_begin::Stmts", lb->Stmts(), ((const named_begin*)R)->Stmts());
    if (auto* lo = any_cast<const operation*>(L))
        row("operation::Operands", lo->Operands(), ((const operation*)R)->Operands());
    if (auto* la = any_cast<const assignment*>(L)) {
        auto* ra = (const assignment*)R;
        sing("assignment::Lhs", la->Lhs(), ra->Lhs());
        sing("assignment::Rhs", la->Rhs(), ra->Rhs());
    }
    if (auto* li = any_cast<const if_stmt*>(L)) {
        auto* ri = (const if_stmt*)R;
        sing("if_stmt::VpiCondition", li->VpiCondition(), ri->VpiCondition());
        sing("if_stmt::VpiStmt", li->VpiStmt(), ri->VpiStmt());
    }
    if (auto* li = any_cast<const if_else*>(L)) {
        auto* ri = (const if_else*)R;
        sing("if_else::VpiCondition", li->VpiCondition(), ri->VpiCondition());
        sing("if_else::VpiStmt", li->VpiStmt(), ri->VpiStmt());
        sing("if_else::VpiElseStmt", li->VpiElseStmt(), ri->VpiElseStmt());
    }
    if (auto* lr = any_cast<const ref_obj*>(L)) {
        auto* rr = (const ref_obj*)R;
        sing("ref_obj::Actual_group", lr->Actual_group(), rr->Actual_group());
        sing("ref_obj::Typespec", lr->Typespec(), rr->Typespec());
    }
    if (auto* lr = any_cast<const ref_var*>(L)) {
        auto* rr = (const ref_var*)R;
        sing("ref_var::Actual_group", lr->Actual_group(), rr->Actual_group());
    }
    if (auto* lr = any_cast<const ref_typespec*>(L)) {
        auto* rr = (const ref_typespec*)R;
        sing("ref_typespec::Actual_typespec", lr->Actual_typespec(),
             rr->Actual_typespec());
    }
    if (auto* lv = any_cast<const variables*>(L)) {
        auto* rv = (const variables*)R;
        sing("variables::Typespec", lv->Typespec(), rv->Typespec());
        sing("variables::Expr", lv->Expr(), rv->Expr());
    }
    if (auto* lt = any_cast<const task_func*>(L)) {
        auto* rt = (const task_func*)R;
        sing("task_func::Stmt", lt->Stmt(), rt->Stmt());
        sing("task_func::Return", lt->Return(), rt->Return());
        row("task_func::Io_decls", lt->Io_decls(), rt->Io_decls());
    }
    if (auto* lc = any_cast<const class_defn*>(L)) {
        auto* rc = (const class_defn*)R;
        row("class_defn::Task_funcs", lc->Task_funcs(), rc->Task_funcs());
    }
    if (auto* lt = any_cast<const tf_call*>(L))
        row("tf_call::Tf_call_args", lt->Tf_call_args(), ((const tf_call*)R)->Tf_call_args());
    if (auto* lf = any_cast<const func_call*>(L)) {
        if (auto* rf = any_cast<const func_call*>(R))
            sing("func_call::Function", lf->Function(), rf->Function());
        else
            printf("    %-24s LHS=%-58s RHS=<DIFFERENT KIND>\n",
                   "func_call::Function", ident(lf->Function()).c_str());
    }
    if (auto* lt2 = any_cast<const task_call*>(L)) {
        if (auto* rt2 = any_cast<const task_call*>(R))
            sing("task_call::Task", lt2->Task(), rt2->Task());
        else
            printf("    %-24s LHS=%-58s RHS=<DIFFERENT KIND>\n",
                   "task_call::Task", ident(lt2->Task()).c_str());
    }
    if (auto* lm = any_cast<const method_func_call*>(L)) {
        if (auto* rm = any_cast<const method_func_call*>(R)) {
            sing("method_func_call::Prefix", lm->Prefix(), rm->Prefix());
            sing("method_func_call::Function", lm->Function(), rm->Function());
        }
    }
    if (auto* lh = any_cast<const hier_path*>(L)) {
        if (auto* rh = any_cast<const hier_path*>(R))
            row("hier_path::Path_elems", lh->Path_elems(), rh->Path_elems());
        else
            printf("    %-24s LHS=vector size %zu RHS=<DIFFERENT KIND>\n",
                   "hier_path::Path_elems",
                   lh->Path_elems() ? lh->Path_elems()->size() : 0);
    }
    if (auto* lb2 = any_cast<const bit_select*>(L)) {
        if (auto* rb2 = any_cast<const bit_select*>(R))
            sing("bit_select::VpiIndex", lb2->VpiIndex(), rb2->VpiIndex());
        else
            printf("    %-24s LHS=%-58s RHS=<DIFFERENT KIND>\n",
                   "bit_select::VpiIndex", ident(lb2->VpiIndex()).c_str());
    }
    if (auto* la = any_cast<const assert_stmt*>(L)) {
        auto* ra = (const assert_stmt*)R;
        sing("assert_stmt::VpiProperty", la->VpiProperty(), ra->VpiProperty());
        sing("assert_stmt::Stmt", la->Stmt(), ra->Stmt());
    }
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct179own <golden> <ours>\n"); return 2; }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS = %s\n", ident(c.m_failedLhs).c_str());
    printf("HEAD RHS = %s\n", ident(c.m_failedRhs).c_str());
    if (c.m_failedLhs && c.m_failedRhs)
        printf("HEAD KINDS: LHS=%s RHS=%s  %s\n",
               std::string(UhdmName(c.m_failedLhs->UhdmType())).c_str(),
               std::string(UhdmName(c.m_failedRhs->UhdmType())).c_str(),
               c.m_failedLhs->UhdmType() == c.m_failedRhs->UhdmType()
                   ? "(same kind -> a per-kind field failed)"
                   : "(DIFFERENT KIND -> BaseClass::Compare's VpiType line "
                     "failed FIRST; no field beyond it was read)");
    const BaseClass* HL = c.m_failedLhs;
    const BaseClass* HR = c.m_failedRhs;
    // r10uvm179 — THE MIRROR REFERENCE SCAN.  This pass's head is
    // `LHS: <null>` with a full RHS: the object the judge stopped on lives in
    // OUR database, so the scan runs the other way round — every edge of OURS
    // that lands on the head, printed beside the SAME edge of golden's
    // counterpart.  (r10uvm176's OWNER.next.* is the same reading; the tool it
    // was copied from returned here without printing it.)
    if (!HL && HR) {
        kidmap_t kg0, ko0;
        buildKids(sg, kg0);
        buildKids(so, ko0);
        printf("HEAD RHS parent chain:\n");
        for (const BaseClass* p = HR->VpiParent(); p; p = p->VpiParent())
            printf("    < %s\n", ident(p).c_str());
        printf("MIRROR REFERENCE SCAN — every edge of OURS that lands on the "
               "head, and golden's:\n");
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
                printf("  ours   %s\n      edge vpiType=%d %s\n",
                       ident(X).c_str(), t,
                       idx == -2 ? "(singular)"
                                 : ("(vector index " + std::to_string(idx) +
                                    ")").c_str());
                int nm = 0;
                for (auto& kv2 : sg.AllObjects()) {
                    const BaseClass* Y = kv2.first;
                    if (!Y || !sameFace(X, Y) ||
                        parentPath(X) != parentPath(Y))
                        continue;
                    ++nm;
                    auto tu2 = Y->GetByVpiType(t);
                    const BaseClass* o2 = std::get<0>(tu2);
                    const std::vector<const BaseClass*>* v2 = std::get<2>(tu2);
                    if (idx == -2)
                        printf("      golden %s -> singular %s\n",
                               ident(Y).c_str(), ident(o2).c_str());
                    else
                        printf("      golden %s -> vector %s size %zu, [%d] = %s\n",
                               ident(Y).c_str(), v2 ? "present" : "NULL",
                               v2 ? v2->size() : 0, idx,
                               (v2 && (size_t)idx < v2->size())
                                   ? ident(v2->at(idx)).c_str()
                                   : "-");
                }
                if (!nm) printf("      golden NO COUNTERPART for the referrer\n");
            }
        }
        return 0;
    }
    if (!HL) return 0;
    printf("HEAD LHS parent chain:\n");
    for (const BaseClass* p = HL->VpiParent(); p; p = p->VpiParent())
        printf("    < %s\n", ident(p).c_str());

    kidmap_t kg, ko;
    buildKids(sg, kg);
    buildKids(so, ko);

    // STEP 1 — the head's OWN golden parent chain, top down, each level matched
    // GLOBALLY (a package/class_defn need not be a VpiParent-child of the
    // design in either database) and each pair asked whether its own Compare
    // reproduces the design-level head.  The DEEPEST level that reproduces it
    // is where the generic child descent starts.
    std::vector<const BaseClass*> chain;
    for (const BaseClass* p = HL; p; p = p->VpiParent()) chain.push_back(p);
    printf("PARENT-CHAIN PROBE (top down; REPRO = this pair's own Compare gives the same head):\n");
    const BaseClass* L = dg;
    const BaseClass* R = dou;
    for (size_t i = chain.size(); i-- > 0;) {
        const BaseClass* lc = chain[i];
        // A UVM package exists TWICE on our side (the DEF and the ELABORATED
        // view), so a counterpart match is not unique and "exactly one" would
        // throw the real one away.  EVERY candidate is asked instead, and the
        // one that reproduces the head is the one the judge walked.
        const BaseClass* match = nullptr;
        int nm = 0, nrep = 0;
        for (auto& kv : so.AllObjects()) {
            const BaseClass* rc = kv.first;
            if (!rc || !sameFace(lc, rc)) continue;
            if (parentPath(lc) != parentPath(rc)) continue;
            ++nm;
            if (reproduces(lc, rc, HL, HR)) { ++nrep; if (!match) match = rc; }
        }
        printf("  %-58s ourMatches=%d repro=%d %s\n", ident(lc).c_str(), nm, nrep,
               nm == 0 ? "NO COUNTERPART" : (nrep ? "REPRO" : "no-repro"));
        if (nrep) { L = lc; R = match; }
    }

    // STEP 2 — the generic child descent from the deepest reproducing pair.
    printf("DESCENT (each step = a child pair whose own Compare reproduces the head):\n");
    printf("  [0] %s\n      vs %s\n", ident(L).c_str(), ident(R).c_str());
    for (int depth = 1; depth < 64; ++depth) {
        const BaseClass* nl = nullptr;
        const BaseClass* nr = nullptr;
        int ambiguous = 0;
        for (const BaseClass* lc : kg[L]) {
            int nm = 0;
            for (const BaseClass* rc : ko[R]) {
                if (!sameFace(lc, rc)) continue;
                ++nm;
                if (!reproduces(lc, rc, HL, HR)) continue;
                if (nl) { ++ambiguous; continue; }
                nl = lc; nr = rc;
            }
            if (nm == 0 && lc == HL)
                printf("      (golden child %s has NO counterpart under our owner)\n",
                       ident(lc).c_str());
        }
        if (!nl) {
            printf("  STOP: no child pair reproduces the head -> the edge is a FIELD of the pair above\n");
            break;
        }
        printf("  [%d] %s\n      vs %s%s\n", depth, ident(nl).c_str(),
               ident(nr).c_str(), ambiguous ? "   (AMBIGUOUS: more than one child reproduces)" : "");
        L = nl; R = nr;
    }
    printf("OWNER PAIR:\n");
    fields(L, R);

    // STEP 3 — THE REFERENCE SCAN, which needs no walk at all.  `RHS: <null>`
    // on a VALUE is BaseClass.h's SINGULAR SafeCompare, so SOME edge holds
    // golden's head object and holds nothing on our side.  `GetByVpiType` is
    // the generated, kind-agnostic edge accessor (a switch over the vpi
    // relation constants), so every edge of every object can be enumerated
    // without naming a single field by hand.  Every golden edge that lands ON
    // the head is printed together with the SAME edge of our counterpart.
    printf("REFERENCE SCAN — every golden edge that lands on the head, and ours:\n");
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
                   idx == -2 ? "(singular)" : ("(vector index " + std::to_string(idx) + ")").c_str());
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
    return 0;
}
