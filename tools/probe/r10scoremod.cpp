// r10scoremod: size + per-element name/type census of a module_inst's vectors,
// for the TOP view (design->TopModules) -- the same projection r10scorepkg does
// for packages.  Names only; no Compare, so a first-fail deep inside one vector
// does not hide the others.
//   r10scoremod <golden.uhdm> <ours.uhdm> [modname]
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

template <typename V>
static void cmpv(const char* tag, const V* a, const V* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (!a && !b) return;
    if (sa != sb)
        std::cout << "SIZE " << tag << ": " << (a ? (long)sa : -1) << " vs "
                  << (b ? (long)sb : -1) << "\n";
    size_t n = sa < sb ? sa : sb;
    int shown = 0;
    for (size_t i = 0; i < n; i++) {
        std::string x = nm((*a)[i]), y = nm((*b)[i]);
        if (x != y && shown < 10) {
            std::cout << "  NAME " << tag << "[" << i << "] " << x << "  |  " << y
                      << "\n";
            shown++;
        }
    }
    if (sa != sb) {
        const V* big = sa > sb ? a : b;
        const char* side = sa > sb ? "LHSONLY" : "RHSONLY";
        size_t mx = sa > sb ? sa : sb;
        for (size_t i = n; i < mx && i < n + 16; i++)
            std::cout << "  " << side << " " << tag << "[" << i << "] "
                      << nm((*big)[i]) << "\n";
    }
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    auto pick = [&](const design* d) -> const module_inst* {
        if (!d->TopModules() || d->TopModules()->empty()) return nullptr;
        if (argc > 3)
            for (auto* m : *d->TopModules())
                if (std::string(m->VpiName()).find(argv[3]) != std::string::npos)
                    return m;
        return d->TopModules()->at(0);
    };
    const module_inst* a = pick(da);
    const module_inst* b = pick(db);
    if (!a || !b) {
        std::cout << "module not found\n";
        return 1;
    }
#define V(x) cmpv(#x, a->x(), b->x())
    V(Parameters);
    V(Param_assigns);
    V(Variables);
    V(Nets);
    V(Task_funcs);
    V(Class_defns);
    V(Process);
    V(Cont_assigns);
    V(Modules);
    V(Interfaces);
    V(Gen_scope_arrays);
    V(Named_events);
    V(Ports);
    V(Typespecs);
    V(Instance_items);
    V(Array_vars);
    V(Logic_vars);
    V(Scopes);
#undef V
    std::cout << "done\n";
    return 0;
}
