// r10pkgnull: null/size census of EVERY vector package::Compare reads, on
// both sides. `failLhs=<container> failRhs=<null>` from SafeCompare means one
// vector is non-null-non-empty on the lhs and NULL on the rhs — no Compare
// call can name it, because the recursion reports the container.
//   r10pkgnull <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

template <typename V>
static void row(const std::string& tag, const char* what, const V* a,
                const V* b) {
    int sa = a ? (int)a->size() : -1;
    int sb = b ? (int)b->size() : -1;
    if (sa == sb) return;
    std::cout << tag << "." << what << ": lhs=" << sa << " rhs=" << sb << "\n";
    const V* big = (sa > sb) ? a : b;
    if (big)
        for (auto* o : *big)
            std::cout << "      " << UhdmName(o->UhdmType()) << "("
                      << o->VpiName() << ")@" << o->VpiLineNo() << ":"
                      << o->VpiColumnNo() << "\n";
}

static void pkg(const std::string& t, const package* a, const package* b) {
    row(t, "Property_decls", a->Property_decls(), b->Property_decls());
    row(t, "Sequence_decls", a->Sequence_decls(), b->Sequence_decls());
    row(t, "Concurrent_assertions", a->Concurrent_assertions(),
        b->Concurrent_assertions());
    row(t, "Named_events", a->Named_events(), b->Named_events());
    row(t, "Named_event_arrays", a->Named_event_arrays(), b->Named_event_arrays());
    row(t, "Variables", a->Variables(), b->Variables());
    row(t, "Virtual_interface_vars", a->Virtual_interface_vars(),
        b->Virtual_interface_vars());
    row(t, "Logic_vars", a->Logic_vars(), b->Logic_vars());
    row(t, "Array_vars", a->Array_vars(), b->Array_vars());
    row(t, "Array_var_mems", a->Array_var_mems(), b->Array_var_mems());
    row(t, "Parameters", a->Parameters(), b->Parameters());
    row(t, "Param_assigns", a->Param_assigns(), b->Param_assigns());
    row(t, "Scopes", a->Scopes(), b->Scopes());
    row(t, "Typespecs", a->Typespecs(), b->Typespecs());
    row(t, "Instance_items", a->Instance_items(), b->Instance_items());
    row(t, "Let_decls", a->Let_decls(), b->Let_decls());
    row(t, "Attributes", a->Attributes(), b->Attributes());
    row(t, "Programs", a->Programs(), b->Programs());
    row(t, "Program_arrays", a->Program_arrays(), b->Program_arrays());
    row(t, "Class_defns", a->Class_defns(), b->Class_defns());
    row(t, "Task_funcs", a->Task_funcs(), b->Task_funcs());
    row(t, "Nets", a->Nets(), b->Nets());
    row(t, "Array_nets", a->Array_nets(), b->Array_nets());
    row(t, "Spec_params", a->Spec_params(), b->Spec_params());
    row(t, "Assertions", a->Assertions(), b->Assertions());
    std::cout << t << ": Module_inst " << (a->Module_inst() ? 1 : 0) << "/"
              << (b->Module_inst() ? 1 : 0) << " Instance "
              << (a->Instance() ? 1 : 0) << "/" << (b->Instance() ? 1 : 0) << "\n";
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    auto walk = [&](const VectorOfpackage* pa, const VectorOfpackage* pb,
                    const char* v) {
        if (!pa || !pb || pa->size() != pb->size()) return;
        for (size_t i = 0; i < pa->size(); i++)
            pkg(std::string(v) + ":" + std::string(pa->at(i)->VpiName()),
                pa->at(i), pb->at(i));
    };
    walk(da->AllPackages(), db->AllPackages(), "AllPkg");
    walk(da->TopPackages(), db->TopPackages(), "TopPkg");
    return 0;
}
