// r10uvm163 — ct163own: THE OWNER-FINDER.  It answers the brief's FIRST
// question — is the `RHS: <null>` head the SINGULAR `Typespec` edge of the
// class_var (a typespec we do not emit at all), or a NULL VECTOR inside a
// class_typespec we DO emit, and at which index?  `uhdm-cmp` cannot say: its
// vector `SafeCompare` (~/.local/include/uhdm/BaseClass.h) sets the OWNER as
// LHS and leaves RHS UNSET on a null/size mismatch, which prints byte for byte
// the same text a missing singular object prints (RESUME.md §9, head decoding).
//
// MEASUREMENT ONLY.  The judge is ~/git-repos/UHDM/build/bin/uhdm-cmp; this
// tool links the SAME generated `Compare` and only reports.
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
//
// It runs the OFFICIAL whole-design Compare, prints the head, then — when the
// head is a class_typespec — recovers OUR counterpart by (kind, VpiName,
// line:col, holder VpiName) and walks `class_typespec::Compare`'s own field
// order (~/git-repos/UHDM/build/generated/src/class_typespec.cpp:206-234)
// against the two objects, marking the FIRST field that can make SafeCompare
// return.  It ALSO reports whether the holder's singular Typespec edge is
// present on both sides, which is the competing reading.
//
// GUARDS:
//   * the counterpart recovery must find EXACTLY ONE match; 0 or >1 is printed
//     and the walk is refused rather than reported on the wrong object;
//   * a head that is not a class_typespec is said so, not silently skipped.
//
// build: g++ -O2 -std=c++17 ct163own.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct163own
// usage: ct163own <golden.uhdm> <ours.uhdm>
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
static void vrow(const char* nm, const V* l, const V* r, bool& done) {
    const char* mark = "  ";
    bool ln = (l == nullptr), rn = (r == nullptr);
    size_t ls = ln ? 0 : l->size(), rs = rn ? 0 : r->size();
    // BaseClass.h's vector SafeCompare: a null/EMPTY on one side against a
    // NON-EMPTY other side returns immediately, and so does a size mismatch.
    bool fires = ((ln || ls == 0) != (rn || rs == 0)) || (ls != rs);
    if (fires && !done) { mark = "->"; done = true; }
    printf("%s VECTOR %-22s LHS=%-8s RHS=%-8s\n", mark, nm,
           ln ? "null" : std::to_string(ls).c_str(),
           rn ? "null" : std::to_string(rs).c_str());
}

static void srow(const char* nm, const BaseClass* l, const BaseClass* r, bool& done) {
    const char* mark = "  ";
    bool fires = ((l == nullptr) != (r == nullptr));
    if (fires && !done) { mark = "->"; done = true; }
    printf("%s SINGLE %-22s LHS=%-40s RHS=%s\n", mark, nm,
           ident(l).c_str(), ident(r).c_str());
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct163own <golden> <ours>\n"); return 2; }
    Serializer sg, so;
    if (sg.Restore(std::string(argv[1])).empty()) { printf("RESTORE_FAIL golden\n"); return 3; }
    if (so.Restore(std::string(argv[2])).empty()) { printf("RESTORE_FAIL ours\n"); return 3; }
    const design* dg = topDesign(sg);
    const design* dou = topDesign(so);
    if (!dg || !dou) { printf("NO_DESIGN\n"); return 3; }
    CompareContext c;
    int32_t r = dg->Compare(dou, &c);
    printf("design::Compare r=%d\n", (int)r);
    printf("HEAD LHS = %s\n", ident(c.m_failedLhs).c_str());
    printf("HEAD RHS = %s\n", ident(c.m_failedRhs).c_str());
    const BaseClass* L = c.m_failedLhs;
    if (!L) {
        // THE MIRROR CASE.  `LHS: <null>` with a printed RHS is the vector
        // overload firing the other way round: the owner is on OUR side and the
        // object is one GOLDEN does not carry at that index.  The head object's
        // own fields say nothing about which vector fired, so walk its PARENT's
        // field order against golden's counterpart parent.
        const BaseClass* R = c.m_failedRhs;
        if (!R) return 0;
        const BaseClass* rp = R->VpiParent();
        printf("MIRROR: the head is OURS; parent = %s\n", ident(rp).c_str());
        const class_defn* rcd = any_cast<const class_defn*>(rp);
        if (!rcd) { printf("parent is not a class_defn — walk it by hand\n"); return 0; }
        std::vector<const class_defn*> gh;
        for (auto& kv : sg.AllObjects()) {
            const BaseClass* o = kv.first;
            if (!o || o->UhdmType() != uhdmclass_defn) continue;
            if (o->VpiName() == rcd->VpiName()) gh.push_back((const class_defn*)o);
        }
        printf("golden counterpart class_defn candidates: %zu\n", gh.size());
        if (gh.size() != 1) { printf("REFUSING to walk: not unique\n"); return 0; }
        const class_defn* lcd = gh[0];
        bool done2 = false;
        // A class_defn's Compare runs its BASE (`scope`) FIRST
        // (generated/src/class_defn.cpp:144), so scope's own vectors are walked
        // before the four class_defn ones — a walk that started at `Extends`
        // printed "no field fires" while the real owner was a scope vector.
        printf("scope::Compare field order first "
               "(generated/src/scope.cpp:335-351):\n");
        vrow("Property_decls", lcd->Property_decls(), rcd->Property_decls(), done2);
        vrow("Sequence_decls", lcd->Sequence_decls(), rcd->Sequence_decls(), done2);
        vrow("Concurrent_assertions", lcd->Concurrent_assertions(),
             rcd->Concurrent_assertions(), done2);
        vrow("Named_events", lcd->Named_events(), rcd->Named_events(), done2);
        vrow("Named_event_arrays", lcd->Named_event_arrays(),
             rcd->Named_event_arrays(), done2);
        vrow("Variables", lcd->Variables(), rcd->Variables(), done2);
        vrow("Virtual_interface_vars", lcd->Virtual_interface_vars(),
             rcd->Virtual_interface_vars(), done2);
        vrow("Logic_vars", lcd->Logic_vars(), rcd->Logic_vars(), done2);
        vrow("Array_vars", lcd->Array_vars(), rcd->Array_vars(), done2);
        vrow("Array_var_mems", lcd->Array_var_mems(), rcd->Array_var_mems(), done2);
        vrow("Parameters", lcd->Parameters(), rcd->Parameters(), done2);
        vrow("Param_assigns", lcd->Param_assigns(), rcd->Param_assigns(), done2);
        vrow("Scopes", lcd->Scopes(), rcd->Scopes(), done2);
        vrow("Typespecs", lcd->Typespecs(), rcd->Typespecs(), done2);
        vrow("Instance_items", lcd->Instance_items(), rcd->Instance_items(), done2);
        vrow("Let_decls", lcd->Let_decls(), rcd->Let_decls(), done2);
        vrow("Attributes", lcd->Attributes(), rcd->Attributes(), done2);
        printf("class_defn::Compare field order "
               "(generated/src/class_defn.cpp:159-163):\n");
        srow("Extends", lcd->Extends(), rcd->Extends(), done2);
        vrow("Task_funcs", lcd->Task_funcs(), rcd->Task_funcs(), done2);
        vrow("Constraints", lcd->Constraints(), rcd->Constraints(), done2);
        vrow("Deriveds", lcd->Deriveds(), rcd->Deriveds(), done2);
        vrow("Class_typespecs", lcd->Class_typespecs(), rcd->Class_typespecs(), done2);
        if (!done2) printf("NO FIELD of the parent fires — the head is elsewhere\n");
        return 0;
    }
    printf("HEAD LHS parent chain:\n");
    for (const BaseClass* p = L->VpiParent(); p; p = p->VpiParent())
        printf("    < %s\n", ident(p).c_str());
    if (L->UhdmType() != uhdmclass_typespec) {
        printf("HEAD is not a class_typespec — nothing to walk here\n");
        return 0;
    }
    const class_typespec* lc = (const class_typespec*)L;
    const BaseClass* lh = lc->VpiParent();
    // Recover OUR counterpart: same kind, same VpiName, same start line:col, and
    // the same holder NAME.  Exactly one must match.
    std::vector<const class_typespec*> hits;
    for (auto& kv : so.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmclass_typespec) continue;
        const class_typespec* oc = (const class_typespec*)o;
        if (oc->VpiName() != lc->VpiName()) continue;
        if (oc->VpiLineNo() != lc->VpiLineNo()) continue;
        if (oc->VpiColumnNo() != lc->VpiColumnNo()) continue;
        const BaseClass* oh = oc->VpiParent();
        if ((oh == nullptr) != (lh == nullptr)) continue;
        if (oh && lh && oh->VpiName() != lh->VpiName()) continue;
        hits.push_back(oc);
    }
    printf("counterpart candidates in OURS: %zu\n", hits.size());
    if (hits.size() != 1) {
        printf("REFUSING to walk: the counterpart is not unique\n");
        return 0;
    }
    const class_typespec* rc = hits[0];
    printf("OUR counterpart = %s\n", ident(rc).c_str());
    // THE COMPETING READING, answered explicitly: is the HOLDER's singular
    // Typespec edge present on both sides?  If ours were missing, the head
    // would be that singular edge and not a vector inside this object.
    const variables* lv = any_cast<const variables*>(lh);
    const variables* rv = any_cast<const variables*>(rc->VpiParent());
    printf("holder Typespec edge: golden=%s ours=%s\n",
           lv ? (lv->Typespec() ? "present" : "NULL") : "holder-not-a-variable",
           rv ? (rv->Typespec() ? "present" : "NULL") : "holder-not-a-variable");
    printf("class_typespec::Compare field order (generated/src/class_typespec.cpp:206-234):\n");
    bool done = false;
    printf("  NAME  VpiName                LHS=%-20s RHS=%s\n",
           std::string(lc->VpiName()).c_str(), std::string(rc->VpiName()).c_str());
    srow("Typedef_alias", lc->Typedef_alias(), rc->Typedef_alias(), done);
    srow("Instance", lc->Instance(), rc->Instance(), done);
    srow("Extends", lc->Extends(), rc->Extends(), done);
    vrow("Variables", lc->Variables(), rc->Variables(), done);
    vrow("Task_funcs", lc->Task_funcs(), rc->Task_funcs(), done);
    vrow("Constraints", lc->Constraints(), rc->Constraints(), done);
    vrow("Parameters", lc->Parameters(), rc->Parameters(), done);
    vrow("Param_assigns", lc->Param_assigns(), rc->Param_assigns(), done);
    vrow("Virtual_interface_vars", lc->Virtual_interface_vars(),
         rc->Virtual_interface_vars(), done);
    vrow("Named_events", lc->Named_events(), rc->Named_events(), done);
    vrow("Named_event_arrays", lc->Named_event_arrays(), rc->Named_event_arrays(), done);
    vrow("Scopes", lc->Scopes(), rc->Scopes(), done);
    srow("Class_defn", lc->Class_defn(), rc->Class_defn(), done);
    if (!done)
        printf("NO FIELD of this object fires — the head is elsewhere\n");
    if (lc->Parameters()) {
        printf("golden Parameters (%zu):\n", lc->Parameters()->size());
        size_t i = 0;
        for (const any* p : *lc->Parameters()) {
            printf("   [%zu] %s", i++, ident(p).c_str());
            if (p && p->UhdmType() == uhdmtype_parameter) {
                const ref_typespec* rt = ((const type_parameter*)p)->Typespec();
                printf("  actual=%s",
                       ident(rt ? rt->Actual_typespec() : nullptr).c_str());
            }
            printf("\n");
        }
    }
    return 0;
}
