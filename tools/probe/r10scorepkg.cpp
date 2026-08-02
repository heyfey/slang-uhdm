// r10scorepkg: size census of every package vector, then per-element
// name/type diff for the vectors whose sizes match but whose elements differ
// by NAME/TYPE only (no Compare recursion -- Compare on a parameter walks its
// typespec Instance() back to the package and reports the package itself).
//   r10scorepkg <golden.uhdm> <ours.uhdm> <pkgname>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

template <typename V>
static void cmpv(const char* tag, const V* a, const V* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (!a && !b) return;
    if (sa != sb) {
        std::cout << "SIZE " << tag << ": " << (a ? (long)sa : -1) << " vs "
                  << (b ? (long)sb : -1) << "\n";
    }
    size_t n = sa < sb ? sa : sb;
    int shown = 0;
    for (size_t i = 0; i < n; i++) {
        std::string x = nm((*a)[i]), y = nm((*b)[i]);
        if (x != y && shown < 8) {
            std::cout << "  NAME " << tag << "[" << i << "] " << x << "  |  " << y
                      << "\n";
            shown++;
        }
    }
    if (sa != sb) {
        const V* big = sa > sb ? a : b;
        const char* side = sa > sb ? "LHSONLY" : "RHSONLY";
        for (size_t i = n; i < (sa > sb ? sa : sb) && i < n + 12; i++)
            std::cout << "  " << side << " " << tag << "[" << i << "] "
                      << nm((*big)[i]) << "\n";
    }
}

static const package* find(const design* d, const std::string& n) {
    if (!d->AllPackages()) return nullptr;
    for (auto* p : *d->AllPackages())
        if (std::string(p->VpiName()) == n) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    const package* a = find(da, argv[3]);
    const package* b = find(db, argv[3]);
    if (!a || !b) {
        std::cout << "package not found\n";
        return 1;
    }
#define V(x) cmpv(#x, a->x(), b->x())
    V(Parameters);
    V(Param_assigns);
    V(Variables);
    V(Nets);
    V(Task_funcs);
    V(Class_defns);
    V(Named_events);
    V(Property_decls);
    V(Let_decls);
    V(Sequence_decls);
    V(Concurrent_assertions);
    V(Named_event_arrays);
    V(Virtual_interface_vars);
    V(Logic_vars);
    V(Array_vars);
    V(Array_var_mems);
    V(Scopes);
    V(Instance_items);
    V(Attributes);
    V(Programs);
    V(Program_arrays);
    V(Array_nets);
    V(Spec_params);
    V(Assertions);
    V(Typespecs);
#undef V
    std::cout << "done\n";
    return 0;
}
