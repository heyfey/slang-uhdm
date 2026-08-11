// r10uvm55repro/ctsfield.cpp — for every class_typespec whose vpiName matches a
// filter, print EXACTLY the fields `class_typespec::Compare` reads, IN COMPARE
// ORDER, plus the dump-only ones (file/span/parent/instance/alias) kept in a
// SEPARATE trailing group so the two are never confused.
//
// WHY: `LHS: <obj> / RHS: <null>` from uhdm-cmp is AMBIGUOUS.  BaseClass.h's
// VECTOR SafeCompare sets `m_failedLhs = lhs_obj` (the CONTAINER) and leaves
// m_failedRhs UNSET when the LHS vector is non-empty and the RHS vector is
// nullptr — so a MISSING VECTOR on our side prints as a MISSING OBJECT.  This
// probe names the field.  Compare order is transcribed from
// UHDM/build/generated/src/class_typespec.cpp `int32_t class_typespec::Compare`
// (VpiClassType, VpiAutomatic, Extends, Variables, Task_funcs, Constraints,
// Parameters, Param_assigns, Virtual_interface_vars, Named_events,
// Named_event_arrays, Scopes, Class_defn), preceded by BaseClass::Compare
// (VpiType, VpiName, VpiDefName ONLY — file and line are NOT cmp-visible).
//
// LHS is ALWAYS golden(Surelog); RHS is ALWAYS ours.
//
//   usage: ctsfield <db.uhdm> <nameSubstring>
//
// GUARDS:
//   * zero matching objects is `UNMEASURED: 0 class_typespec matched` + exit 4,
//     so a typo'd filter can never read as "the field is absent".
//   * a NULL vector prints `null` and an EMPTY vector prints `0`; the two are
//     DIFFERENT to SafeCompare (null-vs-empty compares EQUAL, non-empty-vs-null
//     does not) and this probe never collapses them.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "-";
    std::string s(o->VpiName());
    if (s.empty()) s = "<anon>";
    return s;
}
static std::string kindOf(const BaseClass* o) {
    return o ? std::string(UhdmName(o->UhdmType())) : std::string("-");
}
template <typename T>
static std::string vc(const std::vector<T*>* v) {
    return v ? std::to_string(v->size()) : std::string("null");
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ctsfield <db.uhdm> <nameSubstring>\n"; return 2; }
    std::string want = argv[2];
    Serializer s;
    const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
    if (restored.empty()) { std::cout << "UNMEASURED: no design\n"; return 4; }
    std::set<const class_typespec*> seen;
    // Reach every class_typespec through the Serializer's own object map: no
    // traversal order can hide one.
    int n = 0;
    for (auto& kv : s.AllObjects()) {
        const BaseClass* o = kv.first;
        if (!o || o->UhdmType() != uhdmclass_typespec) continue;
        {
            const class_typespec* t = (const class_typespec*)o;
            std::string name(t->VpiName());
            if (name.find(want) == std::string::npos) continue;
            if (!seen.insert(t).second) continue;
            n++;
            std::cout << "CTS " << name << " @" << t->VpiLineNo() << ":"
                      << t->VpiColumnNo() << "-" << t->VpiEndLineNo() << ":"
                      << t->VpiEndColumnNo()
                      << "\n  CMP  classType=" << t->VpiClassType()
                      << " automatic=" << (t->VpiAutomatic() ? 1 : 0)
                      << " extends=" << (t->Extends() ? 1 : 0)
                      << " variables=" << vc(t->Variables())
                      << " taskfuncs=" << vc(t->Task_funcs())
                      << " constraints=" << vc(t->Constraints())
                      << " parameters=" << vc(t->Parameters())
                      << " paramassigns=" << vc(t->Param_assigns())
                      << " vifvars=" << vc(t->Virtual_interface_vars())
                      << " namedevents=" << vc(t->Named_events())
                      << " namedeventarrays=" << vc(t->Named_event_arrays())
                      << " scopes=" << vc(t->Scopes())
                      << " classdefn=" << nm(t->Class_defn())
                      << "\n  DUMPONLY file=" << t->VpiFile()
                      << " parent=" << (t->VpiParent() ? UhdmName(t->VpiParent()->UhdmType()) : "-")
                      << ":" << nm(t->VpiParent())
                      << " instance=" << nm((const BaseClass*)t->Instance())
                      << " alias=" << (t->Typedef_alias() ? 1 : 0) << "\n";
            // Parameters/Param_assigns detail: printed ONLY when present, so a
            // side with a null vector prints no PARAM line at all and the two
            // sides' PARAM-line COUNTS are themselves a census.
            if (t->Parameters())
                for (auto* p : *t->Parameters()) {
                    std::cout << "  PARAM kind=" << kindOf(p) << " name=" << nm(p)
                              << " @" << p->VpiLineNo()
                              << ":" << p->VpiColumnNo() << "-" << p->VpiEndLineNo()
                              << ":" << p->VpiEndColumnNo();
                    if (p->UhdmType() == uhdmtype_parameter) {
                        const type_parameter* tp = (const type_parameter*)p;
                        const ref_typespec* rt = tp->Typespec();
                        const typespec* act = rt ? rt->Actual_typespec() : nullptr;
                        std::cout << " full=" << tp->VpiFullName()
                                  << " ts=" << (rt ? 1 : 0)
                                  << " tsfull=" << (rt ? std::string(rt->VpiFullName()) : std::string(""))
                                  << " actual=" << kindOf(act) << ":" << nm(act)
                                  << " actualspan=" << (act ? act->VpiLineNo() : 0) << ":"
                                  << (act ? act->VpiColumnNo() : 0) << "-"
                                  << (act ? act->VpiEndLineNo() : 0) << ":"
                                  << (act ? act->VpiEndColumnNo() : 0);
                    }
                    std::cout << "\n";
                }
            if (t->Param_assigns())
                for (auto* pa : *t->Param_assigns()) {
                    const any* l = pa->Lhs();
                    const any* r = pa->Rhs();
                    std::cout << "  PASSIGN lhs=" << kindOf(l) << ":" << nm(l)
                              << " lhsfull=" << (l ? std::string(((const BaseClass*)l)->VpiName()) : std::string("-"))
                              << " lhsspan=" << (l ? ((const BaseClass*)l)->VpiLineNo() : 0) << ":"
                              << (l ? ((const BaseClass*)l)->VpiColumnNo() : 0)
                              << " lhsparent=" << kindOf(l ? ((const BaseClass*)l)->VpiParent() : nullptr)
                              << ":" << nm(l ? ((const BaseClass*)l)->VpiParent() : nullptr)
                              << " rhs=" << kindOf(r) << ":" << nm(r)
                              << " rhsIsParam0=" << (t->Parameters() && !t->Parameters()->empty() &&
                                                     r == (const any*)(*t->Parameters())[0] ? 1 : 0)
                              << " override=" << (pa->VpiOverriden() ? 1 : 0) << "\n";
                }
        }
    }
    if (n == 0) { std::cout << "UNMEASURED: 0 class_typespec matched '" << want << "'\n"; return 4; }
    std::cout << "matched=" << n << "\n";
    return 0;
}
