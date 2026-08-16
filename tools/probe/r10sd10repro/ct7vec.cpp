// r10sd7 — THE VECTOR CENSUS ON THE HEAD'S OWN OWNER.
//
// THE DECISIVE READ OF `SafeCompare`.  The head is `LHS:<null>` /
// `RHS: package(uvm_pkg)` and `ct7bt` reports `m_failedLhs` UNSET.  There are
// exactly two branches in `BaseClass.h` that write `m_failedRhs` and leave
// `m_failedLhs` alone:
//
//   :194  SafeCompare(lhs, rhs)                 lhs==nullptr && rhs!=nullptr
//         -> m_failedRhs is the ELEMENT (an instance, i.e. a vpiInstance slot)
//   :220  SafeCompare(lhs_obj, lhs_vec, rhs_obj, rhs_vec)
//         lhs_vec==nullptr && rhs_vec!=nullptr && !rhs_vec->empty()
//         -> m_failedRhs is the OWNER OBJECT, and the owner here IS the package
//
// The first branch was tested exhaustively and REFUTED: `ct7mut` nulls all 5934
// of our objects whose `vpiInstance` is that exact package pointer, one at a
// time, and NONE of them moves the head (all 15 that move at all move it
// BACKWARDS, r=1, by introducing an earlier failure).  So the head is the SECOND
// branch, and the question is which VECTOR of the package golden leaves NULL
// while ours is non-empty.
//
// The vectors are the ones `package::Compare` reaches through `instance::Compare`
// and `scope::Compare`, in their compare order — the order matters, because the
// FIRST such vector is the one that fires.
//
// GUARD: a package that matches nothing is a hard error.
//
// build: g++ -O2 -std=c++17 ct7vec.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct7vec
// usage: ct7vec <db.uhdm> <package-name>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

using namespace UHDM;

#define V(name)                                                            \
    do {                                                                   \
        auto* v = p->name();                                               \
        std::cout << "    " << (#name) << " = "                            \
                  << (v ? ("size " + std::to_string(v->size())) : std::string("<NULL VECTOR>")) \
                  << "\n";                                                 \
    } while (0)

static void dumpPkg(const char* view, package* p) {
    std::cout << "  [" << view << "] package " << p->VpiName() << " id=" << p->UhdmId()
              << "\n";
    // instance::Compare order
    V(Programs); V(Program_arrays); V(Class_defns); V(Task_funcs); V(Nets);
    V(Array_nets); V(Spec_params); V(Assertions);
    // scope::Compare order
    V(Property_decls); V(Sequence_decls); V(Concurrent_assertions); V(Named_events);
    V(Named_event_arrays); V(Variables); V(Virtual_interface_vars); V(Logic_vars);
    V(Array_vars); V(Array_var_mems); V(Parameters); V(Param_assigns); V(Scopes);
    V(Typespecs); V(Instance_items); V(Let_decls); V(Attributes);
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct7vec <db> <pkgname>\n"; return 2; }
    std::string want = argv[2];
    Serializer s;
    auto h = s.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) { std::cerr << "RESTORE FAILED\n"; return 3; }
    auto* d = (design*)((uhdm_handle*)h[0])->object;
    int n = 0;
    if (auto* v = d->AllPackages())
        for (auto* p : *v)
            if (p->VpiName() == want) { dumpPkg("ALL", p); n++; }
    if (auto* v = d->TopPackages())
        for (auto* p : *v)
            if (p->VpiName() == want) { dumpPkg("TOP", p); n++; }
    if (n == 0) { std::cerr << "REFUSING TO REPORT: no package named " << want << "\n"; return 5; }
    return 0;
}
