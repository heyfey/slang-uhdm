// r10pkgstep: step a PACKAGE's own vectors element by element with one shared
// CompareContext, so `design r=1 failLhs=package(X) failRhs=<null>` names the
// element instead of the container. Sizes matching is not equality: the memo
// makes a whole-package Compare report the package itself.
//   r10pkgstep <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

template <typename T>
static bool step(const std::string& tag, const std::vector<T*>* a,
                 const std::vector<T*>* b, CompareContext& c) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (sa != sb || (!a) != (!b)) {
        std::cout << tag << ": SIZE " << (a ? (int)sa : -1) << " vs "
                  << (b ? (int)sb : -1) << "\n";
        return false;
    }
    for (size_t i = 0; i < sa; i++) {
        c.m_failedLhs = nullptr;
        c.m_failedRhs = nullptr;
        const BaseClass* la = (*a)[i];
        const BaseClass* lb = (*b)[i];
        if (la && lb && la->Compare(lb, &c) != 0) {
            std::cout << tag << "[" << i << "] " << nm(la) << " r=1 failLhs="
                      << nm(c.m_failedLhs) << " failRhs=" << nm(c.m_failedRhs)
                      << "\n";
            return false;
        }
    }
    return true;
}

static void pkg(const std::string& tag, const package* a, const package* b) {
    CompareContext c;
    // Typespecs LAST: element[0]'s Instance() recursion re-compares the whole
    // package, so leading with it hides every other vector.
    if (!step(tag + ".Parameters", a->Parameters(), b->Parameters(), c)) return;
    if (!step(tag + ".ParamAssigns", a->Param_assigns(), b->Param_assigns(), c))
        return;
    if (!step(tag + ".Variables", a->Variables(), b->Variables(), c)) return;
    if (!step(tag + ".Nets", a->Nets(), b->Nets(), c)) return;
    if (!step(tag + ".TaskFuncs", a->Task_funcs(), b->Task_funcs(), c)) return;
    if (!step(tag + ".ClassDefns", a->Class_defns(), b->Class_defns(), c)) return;
    if (!step(tag + ".Named_events", a->Named_events(), b->Named_events(), c))
        return;
    if (!step(tag + ".Property_decls", a->Property_decls(), b->Property_decls(), c))
        return;
    if (!step(tag + ".Let_decls", a->Let_decls(), b->Let_decls(), c)) return;
    if (!step(tag + ".Sequence_decls", a->Sequence_decls(), b->Sequence_decls(), c))
        return;
    if (!step(tag + ".Concurrent_assertions", a->Concurrent_assertions(),
              b->Concurrent_assertions(), c))
        return;
    if (!step(tag + ".Named_event_arrays", a->Named_event_arrays(),
              b->Named_event_arrays(), c))
        return;
    if (!step(tag + ".Virtual_interface_vars", a->Virtual_interface_vars(),
              b->Virtual_interface_vars(), c))
        return;
    if (!step(tag + ".Logic_vars", a->Logic_vars(), b->Logic_vars(), c)) return;
    if (!step(tag + ".Array_vars", a->Array_vars(), b->Array_vars(), c)) return;
    if (!step(tag + ".Array_var_mems", a->Array_var_mems(), b->Array_var_mems(), c))
        return;
    if (!step(tag + ".Scopes", a->Scopes(), b->Scopes(), c)) return;
    if (!step(tag + ".Instance_items", a->Instance_items(), b->Instance_items(), c))
        return;
    if (!step(tag + ".Attributes", a->Attributes(), b->Attributes(), c)) return;
    if (!step(tag + ".Programs", a->Programs(), b->Programs(), c)) return;
    if (!step(tag + ".Program_arrays", a->Program_arrays(), b->Program_arrays(), c))
        return;
    if (!step(tag + ".Array_nets", a->Array_nets(), b->Array_nets(), c)) return;
    if (!step(tag + ".Spec_params", a->Spec_params(), b->Spec_params(), c)) return;
    if (!step(tag + ".Assertions", a->Assertions(), b->Assertions(), c)) return;
    if (!step(tag + ".Typespecs", a->Typespecs(), b->Typespecs(), c)) return;
    CompareContext c2;
    if (a->Compare(b, &c2) != 0)
        std::cout << tag << ".WHOLE r=1 failLhs=" << nm(c2.m_failedLhs)
                  << " failRhs=" << nm(c2.m_failedRhs) << "\n";
    else
        std::cout << tag << ".WHOLE ok\n";
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
