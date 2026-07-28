// r9pkgv: package-container vector census across two designs.
//
// `design r=1 failLhs=package(X) failRhs=<null>` means SafeCompare found a
// vector present on the golden side and NULL on ours — the failing pair is
// reported as (container, nothing), so the dump cannot name which vector.
// This walks AllPackages/TopPackages of both files, matches by name, and
// prints every instance vector's size side by side plus the member names of
// any vector that differs.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

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
static void row(const char* pkg, const char* view, const char* tag, const V* a,
                const V* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (sa == sb && (!a == !b)) return;
    std::cout << "  " << pkg << " [" << view << "] " << tag
              << ": lhs=" << (a ? (int)sa : -1) << " rhs=" << (b ? (int)sb : -1)
              << "\n";
    size_t n = sa > sb ? sa : sb;
    for (size_t i = 0; i < n && i < 40; i++)
        std::cout << "        [" << i << "] "
                  << (a && i < sa ? nm((*a)[i]) : std::string("-")) << "  |  "
                  << (b && i < sb ? nm((*b)[i]) : std::string("-")) << "\n";
}

static void cmpPkg(const char* view, const package* a, const package* b) {
    std::string n(a->VpiName());
    const char* p = n.c_str();
    row(p, view, "Typespecs", a->Typespecs(), b->Typespecs());
    row(p, view, "TaskFuncs", a->Task_funcs(), b->Task_funcs());
    row(p, view, "Parameters", a->Parameters(), b->Parameters());
    row(p, view, "ParamAssigns", a->Param_assigns(), b->Param_assigns());
    row(p, view, "Variables", a->Variables(), b->Variables());
    row(p, view, "Nets", a->Nets(), b->Nets());
    row(p, view, "ArrayNets", a->Array_nets(), b->Array_nets());
    row(p, view, "ArrayVars", a->Array_vars(), b->Array_vars());
    row(p, view, "LogicVars", a->Logic_vars(), b->Logic_vars());
    row(p, view, "InstanceItems", a->Instance_items(), b->Instance_items());
    row(p, view, "ClassDefns", a->Class_defns(), b->Class_defns());
    row(p, view, "Scopes", a->Scopes(), b->Scopes());
    row(p, view, "NamedEvents", a->Named_events(), b->Named_events());
    row(p, view, "Attributes", a->Attributes(), b->Attributes());
    row(p, view, "SpecParams", a->Spec_params(), b->Spec_params());
    row(p, view, "PropertyDecls", a->Property_decls(), b->Property_decls());
    row(p, view, "ConcAssertions", a->Concurrent_assertions(),
        b->Concurrent_assertions());
    row(p, view, "NamedEventArrays", a->Named_event_arrays(),
        b->Named_event_arrays());
    row(p, view, "VirtIfaceVars", a->Virtual_interface_vars(),
        b->Virtual_interface_vars());
    row(p, view, "ArrayVarMems", a->Array_var_mems(), b->Array_var_mems());
    row(p, view, "Programs", a->Programs(), b->Programs());
    row(p, view, "ProgramArrays", a->Program_arrays(), b->Program_arrays());
    row(p, view, "Assertions", a->Assertions(), b->Assertions());
    if (!!a->Instance() != !!b->Instance())
        std::cout << "  " << p << " [" << view << "] Instance: lhs="
                  << nm(a->Instance()) << " rhs=" << nm(b->Instance()) << "\n";
    if (!!a->Module_inst() != !!b->Module_inst())
        std::cout << "  " << p << " [" << view << "] Module_inst: lhs="
                  << nm(a->Module_inst()) << " rhs=" << nm(b->Module_inst())
                  << "\n";
    if (!a->VpiDefName().compare(b->VpiDefName()) == 0 ||
        a->VpiTop() != b->VpiTop() ||
        a->VpiEndLabel().compare(b->VpiEndLabel()) != 0)
        std::cout << "  " << p << " [" << view << "] SCALAR def='"
                  << a->VpiDefName() << "'/'" << b->VpiDefName() << "' top="
                  << a->VpiTop() << "/" << b->VpiTop() << " endlbl='"
                  << a->VpiEndLabel() << "'/'" << b->VpiEndLabel() << "'\n";
    row(p, view, "SequenceDecls", a->Sequence_decls(), b->Sequence_decls());
    row(p, view, "LetDecls", a->Let_decls(), b->Let_decls());
}

static void doVec(const char* view, const VectorOfpackage* av,
                  const VectorOfpackage* bv) {
    if (!av) return;
    std::map<std::string, const package*> bm;
    if (bv)
        for (auto* p : *bv) bm[std::string(p->VpiName())] = p;
    for (auto* p : *av) {
        auto it = bm.find(std::string(p->VpiName()));
        if (it == bm.end()) {
            std::cout << "  MISSING package [" << view << "] " << p->VpiName()
                      << "\n";
            continue;
        }
        cmpPkg(view, p, it->second);
    }
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    doVec("def", da->AllPackages(), db->AllPackages());
    doVec("top", da->TopPackages(), db->TopPackages());
    return 0;
}
