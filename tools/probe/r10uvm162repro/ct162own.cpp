// r10uvm162 — THE OWNER-FINDER for the bad-operand head.  MEASUREMENT ONLY.
// `~/.local/bin/uhdm-cmp` is the sole judge; this tool links the SAME generated
// `Compare` and only reports.  LHS is ALWAYS golden (Surelog); RHS is ALWAYS
// ours.
//
// Descended from r10uvm157repro/ct157own.cpp.  It answers the brief's first
// question: WHICH `SafeCompare` printed the `RHS: <null>`.  The cmp log cannot
// say — `~/.local/include/uhdm/BaseClass.h:217-219` (the VECTOR overload's
// `(lhs != nullptr) && !lhs->empty() && (rhs == nullptr)` arm) sets
// `m_failedLhs` to the OWNER and leaves `m_failedRhs` UNSET, which prints
// exactly the same two lines as the SINGULAR overload's `rhs == nullptr` arm
// (:191-193) would for `assignment::Rhs`.  This runs the real `design::Compare`,
// names the head, finds OUR counterpart by kind+span+parent-kind, and then
// walks `operation::Compare`'s own field order
// (~/git-repos/UHDM/build/generated/src/operation.cpp:98-129) marking the FIRST
// test that can return — and, for the enclosing `assignment`, whether ITS
// singular `Rhs` edge could have fired first.
//
// build: g++ -O2 -std=c++17 ct162own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct162own
// usage: ct162own <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
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
static bool sameSpan(const BaseClass* a, const BaseClass* b) {
    return a->VpiLineNo() == b->VpiLineNo() && a->VpiColumnNo() == b->VpiColumnNo() &&
           a->VpiEndLineNo() == b->VpiEndLineNo() &&
           a->VpiEndColumnNo() == b->VpiEndColumnNo();
}
template <class V>
static void vrow(const char* nm, const BaseClass* lo, const V* l,
                 const BaseClass* ro, const V* r, bool& done) {
    (void)lo; (void)ro;
    const char* mark = "  ";
    bool ln = (l == nullptr), rn = (r == nullptr);
    size_t ls = ln ? 0 : l->size(), rs = rn ? 0 : r->size();
    bool fires = (l && r) ? (ls != rs) : ((l && !l->empty() && !r) || (!l && r && !r->empty()));
    if (fires && !done) { mark = "->"; done = true; }
    printf("%s %-16s LHS=%-8s RHS=%-8s%s\n", mark, nm,
           ln ? "null" : std::to_string(ls).c_str(),
           rn ? "null" : std::to_string(rs).c_str(),
           (fires && rn) ? "   [VECTOR overload, RHS NULL -> m_failedLhs = the OWNER]" : "");
}
static void irow(const char* nm, int64_t l, int64_t r, bool& done) {
    const char* mark = "  ";
    bool fires = (l != r);
    if (fires && !done) { mark = "->"; done = true; }
    printf("%s %-16s LHS=%-8lld RHS=%-8lld\n", mark, nm, (long long)l, (long long)r);
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct162own <golden> <ours>\n"); return 2; }
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
    const BaseClass* L = c.m_failedLhs;
    if (!L) return 0;
    printf("HEAD LHS parent chain:\n");
    for (const BaseClass* p = L->VpiParent(); p; p = p->VpiParent())
        printf("    < %s\n", ident(p).c_str());
    if (L->UhdmType() != uhdmoperation) {
        printf("HEAD LHS is not an operation; nothing further to walk\n");
        return 0;
    }
    const operation* lo = (const operation*)L;
    // OUR counterpart: same kind, same span, same parent kind, same opType.
    std::vector<const operation*> hits;
    for (auto& kv : so.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != uhdmoperation) continue;
        const operation* oo = (const operation*)o;
        if (!sameSpan(L, o)) continue;
        if (oo->VpiOpType() != lo->VpiOpType()) continue;
        const BaseClass* lp = L->VpiParent();
        const BaseClass* op = o->VpiParent();
        if ((lp == nullptr) != (op == nullptr)) continue;
        if (lp && op && lp->UhdmType() != op->UhdmType()) continue;
        hits.push_back(oo);
    }
    printf("OUR counterparts by kind+span+opType+parent-kind: %zu\n", hits.size());
    if (hits.size() != 1) { for (auto* h : hits) printf("    %s\n", ident(h).c_str()); return 0; }
    const operation* ro = hits[0];
    printf("OUR counterpart = %s\n", ident(ro).c_str());
    // The ENCLOSING assignment's SINGULAR Rhs edge -- the alternative the cmp
    // log cannot rule out.  If OUR assignment has a NULL Rhs, the head would
    // have been printed by the singular overload instead; this proves it did
    // not.
    const BaseClass* lp = L->VpiParent();
    if (lp && lp->UhdmType() == uhdmassignment) {
        const BaseClass* op2 = ro->VpiParent();
        printf("enclosing assignment::Rhs   LHS=%s RHS=%s\n",
               ident(((const assignment*)lp)->Rhs()).c_str(),
               (op2 && op2->UhdmType() == uhdmassignment)
                   ? ident(((const assignment*)op2)->Rhs()).c_str()
                   : "<no assignment parent on our side>");
    }
    printf("operation::Compare field order (generated/src/operation.cpp:98-129):\n");
    bool done = false;
    irow("VpiType",     L->UhdmType(),    ro->UhdmType(),    done);
    irow("VpiOpType",   lo->VpiOpType(),  ro->VpiOpType(),   done);
    irow("VpiReordered",lo->VpiReordered(),ro->VpiReordered(),done);
    irow("VpiFlattened",lo->VpiFlattened(),ro->VpiFlattened(),done);
    irow("VpiOpStrong", lo->VpiOpStrong(), ro->VpiOpStrong(), done);
    vrow("Operands",   lo, lo->Operands(),   ro, ro->Operands(),   done);
    vrow("Attributes", lo, lo->Attributes(), ro, ro->Attributes(), done);
    if (auto* v = lo->Operands()) {
        size_t i = 0;
        for (auto* e : *v) printf("  LHS Operands[%zu] = %s\n", i++, ident(e).c_str());
    }
    if (auto* v = ro->Operands()) {
        size_t i = 0;
        for (auto* e : *v) printf("  RHS Operands[%zu] = %s\n", i++, ident(e).c_str());
    }
    return 0;
}
