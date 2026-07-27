// Package-container localiser.  `failLhs=package(X) failRhs=<null>` is the
// SafeCompare(vector) NULL form: golden has a non-empty vector where ours is
// a null pointer, so r3fail (which needs both sides) bails.  Match packages by
// NAME across the two designs and print every scope/instance vector in
// Compare order with null distinguished from empty, so the exact container
// that is null-on-one-side is named.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

template <typename V>
static void row(const char* tag, const V* a, const V* b) {
    int sa = a ? (int)a->size() : -1, sb = b ? (int)b->size() : -1;
    if (sa == sb) return;
    std::cout << "    DIFF " << tag << ": lhs=" << sa << " rhs=" << sb << "\n";
    size_t n = (sa > sb ? sa : sb) > 0 ? (size_t)(sa > sb ? sa : sb) : 0;
    for (size_t i = 0; i < n; i++)
        std::cout << "          [" << i << "] "
                  << (a && i < a->size() ? nm((*a)[i]) : std::string("-"))
                  << "  |  "
                  << (b && i < b->size() ? nm((*b)[i]) : std::string("-"))
                  << "\n";
}

template <typename T>
static void dumpInst(const T* a, const T* b) {
    if (a->VpiTop() != b->VpiTop())
        std::cout << "    DIFF VpiTop: lhs=" << a->VpiTop()
                  << " rhs=" << b->VpiTop() << "\n";
    // scope::Compare order
    row("PropertyDecls", a->Property_decls(), b->Property_decls());
    row("SequenceDecls", a->Sequence_decls(), b->Sequence_decls());
    row("ConcurrentAssertions", a->Concurrent_assertions(),
        b->Concurrent_assertions());
    row("NamedEvents", a->Named_events(), b->Named_events());
    row("NamedEventArrays", a->Named_event_arrays(), b->Named_event_arrays());
    row("Variables", a->Variables(), b->Variables());
    row("VirtualInterfaceVars", a->Virtual_interface_vars(),
        b->Virtual_interface_vars());
    row("LogicVars", a->Logic_vars(), b->Logic_vars());
    row("ArrayVars", a->Array_vars(), b->Array_vars());
    row("ArrayVarMems", a->Array_var_mems(), b->Array_var_mems());
    row("Parameters", a->Parameters(), b->Parameters());
    row("ParamAssigns", a->Param_assigns(), b->Param_assigns());
    row("Scopes", a->Scopes(), b->Scopes());
    row("Typespecs", a->Typespecs(), b->Typespecs());
    row("InstanceItems", a->Instance_items(), b->Instance_items());
    row("LetDecls", a->Let_decls(), b->Let_decls());
    row("Attributes", a->Attributes(), b->Attributes());
    // instance::Compare order
    row("Programs", a->Programs(), b->Programs());
    row("ProgramArrays", a->Program_arrays(), b->Program_arrays());
    row("ClassDefns", a->Class_defns(), b->Class_defns());
    row("TaskFuncs", a->Task_funcs(), b->Task_funcs());
    row("Nets", a->Nets(), b->Nets());
    row("ArrayNets", a->Array_nets(), b->Array_nets());
    row("SpecParams", a->Spec_params(), b->Spec_params());
    row("Assertions", a->Assertions(), b->Assertions());
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    // key = name + '|' + (top?1:0): the DEF and TOP views share a name.
    std::map<std::string, const package*> mb;
    if (db->AllPackages())
        for (auto* p : *db->AllPackages())
            mb[std::string(p->VpiName()) + "|" +
               (p->VpiTop() ? "top" : "def")] = p;
    if (db->TopPackages())
        for (auto* p : *db->TopPackages())
            mb[std::string(p->VpiName()) + "|" +
               (p->VpiTop() ? "top" : "def")] = p;
    auto visit = [&](const package* p) {
        std::string k =
            std::string(p->VpiName()) + "|" + (p->VpiTop() ? "top" : "def");
        auto it = mb.find(k);
        std::cout << "  pkg " << k << (it == mb.end() ? " MISSING-RHS" : "")
                  << "\n";
        if (it != mb.end()) dumpInst(p, it->second);
    };
    if (da->AllPackages())
        for (auto* p : *da->AllPackages()) visit(p);
    if (da->TopPackages())
        for (auto* p : *da->TopPackages()) visit(p);
    return 0;
}
