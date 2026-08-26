// r10uvm157 — THE OWNER-FINDER for the statement-scope TYPESPEC-LISTING head.
// MEASUREMENT ONLY.  `~/git-repos/UHDM/build/bin/uhdm-cmp` is the sole judge;
// this tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden (Surelog); RHS is ALWAYS ours.
//
// Descended from r10uvm146repro/ct146own.cpp and r10uvm113repro/ct113own.cpp.
// It answers the question the brief asks FIRST: WHICH VECTOR did SafeCompare
// print the null for, and at WHICH INDEX.  `uhdm-cmp` prints `RHS: <null>`
// for a vector whose RHS pointer is null and names the OWNER as LHS
// (~/.local/include/uhdm/BaseClass.h, the vector overload), so the field is
// NOT in the cmp log — it has to be read off `scope::Compare`'s own order
// (~/git-repos/UHDM/build/generated/src/scope.cpp:335-351) against the two
// objects.  This prints every one of those vectors, in that order, with both
// sides' sizes, and marks the FIRST that can make `SafeCompare` return.
//
// build: g++ -O2 -std=c++17 ct157own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct157own
// usage: ct157own <golden.uhdm> <ours.uhdm>
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
template <class V>
static void row(const char* nm, const V* l, const V* r, bool& done) {
    const char* mark = "  ";
    bool ln = (l == nullptr), rn = (r == nullptr);
    size_t ls = ln ? 0 : l->size(), rs = rn ? 0 : r->size();
    // BaseClass.h's vector SafeCompare: a null/empty on one side with a
    // NON-EMPTY other side returns immediately; two present vectors of
    // DIFFERENT size return; equal sizes descend element by element.
    bool fires = ((ln || ls == 0) != (rn || rs == 0)) || (ls != rs);
    if (fires && !done) { mark = "->"; done = true; }
    printf("%s %-24s LHS=%-8s RHS=%-8s\n", mark, nm,
           ln ? "null" : std::to_string(ls).c_str(),
           rn ? "null" : std::to_string(rs).c_str());
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct157own <golden> <ours>\n"); return 2; }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c;
    int r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", r);
    printf("HEAD LHS = %s\n", ident(c.m_failedLhs));
    printf("HEAD RHS = %s\n", ident(c.m_failedRhs));
    const BaseClass* L = c.m_failedLhs;
    if (!L) return 0;
    printf("HEAD LHS parent chain:\n");
    for (const BaseClass* p = L->VpiParent(); p; p = p->VpiParent())
        printf("    < %s\n", ident(p).c_str());
    const scope* ls = any_cast<const scope*>(L);
    if (!ls) { printf("HEAD LHS is not a scope\n"); return 0; }
    // Find OUR counterpart by kind + VpiFullName + span.  `uhdm-cmp` never
    // prints it (the vector overload leaves RHS unset), so it is recovered
    // here and the recovery is CHECKED: exactly one match must exist.
    std::vector<const scope*> hits;
    const std::string lf(ls->VpiFullName());
    for (auto& kv : so.AllObjects()) {
        const any* o = kv.first;
        if (!o || o->UhdmType() != L->UhdmType()) continue;
        const scope* os = any_cast<const scope*>(o);
        if (!os) continue;
        if (std::string(os->VpiFullName()) != lf) continue;
        if (os->VpiLineNo() != L->VpiLineNo() ||
            os->VpiColumnNo() != L->VpiColumnNo() ||
            os->VpiEndLineNo() != L->VpiEndLineNo() ||
            os->VpiEndColumnNo() != L->VpiEndColumnNo()) continue;
        hits.push_back(os);
    }
    printf("OUR counterparts by kind+fullname+span: %zu\n", hits.size());
    if (hits.size() != 1) { for (auto* h : hits) printf("    %s\n", ident(h).c_str()); return 0; }
    const scope* rs = hits[0];
    printf("OUR counterpart = %s\n", ident(rs).c_str());
    printf("scope::Compare vector order (generated/src/scope.cpp:335-351):\n");
    bool done = false;
    row("Property_decls",        ls->Property_decls(),        rs->Property_decls(),        done);
    row("Sequence_decls",        ls->Sequence_decls(),        rs->Sequence_decls(),        done);
    row("Concurrent_assertions", ls->Concurrent_assertions(), rs->Concurrent_assertions(), done);
    row("Named_events",          ls->Named_events(),          rs->Named_events(),          done);
    row("Named_event_arrays",    ls->Named_event_arrays(),    rs->Named_event_arrays(),    done);
    row("Variables",             ls->Variables(),             rs->Variables(),             done);
    row("Virtual_interface_vars",ls->Virtual_interface_vars(),rs->Virtual_interface_vars(),done);
    row("Logic_vars",            ls->Logic_vars(),            rs->Logic_vars(),            done);
    row("Array_vars",            ls->Array_vars(),            rs->Array_vars(),            done);
    row("Array_var_mems",        ls->Array_var_mems(),        rs->Array_var_mems(),        done);
    row("Parameters",            ls->Parameters(),            rs->Parameters(),            done);
    row("Param_assigns",         ls->Param_assigns(),         rs->Param_assigns(),         done);
    row("Scopes",                ls->Scopes(),                rs->Scopes(),                done);
    row("Typespecs",             ls->Typespecs(),             rs->Typespecs(),             done);
    row("Instance_items",        ls->Instance_items(),        rs->Instance_items(),        done);
    row("Let_decls",             ls->Let_decls(),             rs->Let_decls(),             done);
    row("Attributes",            ls->Attributes(),            rs->Attributes(),            done);
    if (auto* tv = ls->Typespecs()) {
        size_t i = 0;
        for (auto* t : *tv) {
            printf("  LHS Typespecs[%zu] = %s\n", i++, ident(t).c_str());
        }
    }
    return 0;
}
