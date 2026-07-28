// Per-vector uhdm-cmp bisector.
//
// uhdm-cmp runs ONE CompareContext over the whole design, and that context's
// m_visited memo is keyed on the LHS pointer only.  Two consequences make its
// output nearly unreadable once the trees are close:
//   * the comparison is DIRECTION-ASYMMETRIC — whichever side clones more
//     objects forces more re-comparisons, so cmp(golden, ours) can fail where
//     cmp(ours, golden) exits 0;
//   * a vector mismatch reports the CONTAINER (`m_failedRhs = rhs_obj`), so a
//     difference three typespecs deep prints as "LHS: <null> / RHS: the whole
//     module_inst".
//
// This tool compares each element of each module vector under its OWN fresh
// CompareContext, so the report names the exact Parameters[i] / Param_assigns[i]
// slot and the failing pair's node kinds.  Written while closing
// ParamSubstituteComplex (r9psc), where the reachable dumps were byte-identical
// and the only divergence was typespec::Compare's Instance() recursion.
//
// Build (paths as installed on this machine):
//   g++ -std=c++20 -O0 tools/probe/r9psccmp.cpp -o /tmp/r9psccmp \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Run:  /tmp/r9psccmp <golden.uhdm> <slang.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>

using namespace UHDM;

static void one(const std::string& what, const BaseClass* a, const BaseClass* b) {
    if (!a && !b) return;
    if (!a || !b) {
        std::cout << what << ": NULLNESS lhs=" << (a ? "obj" : "null")
                  << " rhs=" << (b ? "obj" : "null") << "\n";
        return;
    }
    CompareContext c;
    if (a->Compare(b, &c) != 0) {
        auto nm = [](const BaseClass* o) {
            return o ? std::string(UhdmName(o->UhdmType())) + "@" +
                           std::to_string(o->VpiLineNo()) + ":" +
                           std::to_string(o->VpiColumnNo())
                     : std::string("null");
        };
        std::cout << what << ": DIFF lhs=" << nm(c.m_failedLhs)
                  << " rhs=" << nm(c.m_failedRhs) << "\n";
    }
}

template <typename V>
static void vec(const std::string& what, const V* a, const V* b) {
    if (!a && !b) return;
    if (!a || !b) {
        std::cout << what << ": VEC NULLNESS a=" << (a ? (int)a->size() : -1)
                  << " b=" << (b ? (int)b->size() : -1) << "\n";
        return;
    }
    if (a->size() != b->size()) {
        std::cout << what << ": SIZE " << a->size() << " vs " << b->size() << "\n";
        return;
    }
    for (size_t i = 0; i < a->size(); i++)
        one(what + "[" + std::to_string(i) + "]", a->at(i), b->at(i));
}

static void mod(const module_inst* a, const module_inst* b, const std::string& tag) {
    std::cout << "--- " << tag << " " << a->VpiFullName() << "\n";
    vec(tag + ".Parameters", a->Parameters(), b->Parameters());
    vec(tag + ".Param_assigns", a->Param_assigns(), b->Param_assigns());
    vec(tag + ".Typespecs", a->Typespecs(), b->Typespecs());
    vec(tag + ".Gen_scope_arrays", a->Gen_scope_arrays(), b->Gen_scope_arrays());
    vec(tag + ".Nets", a->Nets(), b->Nets());
    vec(tag + ".Variables", a->Variables(), b->Variables());
    vec(tag + ".Instance_items", a->Instance_items(), b->Instance_items());
    vec(tag + ".Modules", a->Modules(), b->Modules());
    vec(tag + ".Cont_assigns", a->Cont_assigns(), b->Cont_assigns());
    vec(tag + ".Process", a->Process(), b->Process());
    vec(tag + ".Ports", a->Ports(), b->Ports());
    vec(tag + ".Task_funcs", a->Task_funcs(), b->Task_funcs());
    one(tag + ".WHOLE", a, b);
}

int main(int argc, char** argv) {
    if (argc != 3) {
        std::cerr << "usage: " << argv[0] << " <lhs.uhdm> <rhs.uhdm>\n";
        return 2;
    }
    Serializer sa, sb;
    auto ha = sa.Restore(std::string(argv[1]));
    auto hb = sb.Restore(std::string(argv[2]));
    if (ha.empty() || hb.empty()) {
        std::cerr << "failed to load\n";
        return 2;
    }
    auto* da = (const design*)((const uhdm_handle*)ha[0])->object;
    auto* db = (const design*)((const uhdm_handle*)hb[0])->object;
    if (da->AllModules() && db->AllModules() &&
        da->AllModules()->size() == db->AllModules()->size())
        for (size_t i = 0; i < da->AllModules()->size(); i++)
            mod(da->AllModules()->at(i), db->AllModules()->at(i),
                "ALL" + std::to_string(i));
    if (da->TopModules() && db->TopModules() &&
        da->TopModules()->size() == db->TopModules()->size())
        for (size_t i = 0; i < da->TopModules()->size(); i++)
            mod(da->TopModules()->at(i), db->TopModules()->at(i),
                "TOP" + std::to_string(i));
    return 0;
}
