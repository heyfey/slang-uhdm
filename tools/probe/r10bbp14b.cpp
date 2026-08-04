// r10bbp14b: design top-level vector census (names + sizes) for both sides.
// design::Compare walks Include_file_infos, AllPackages, TopPackages,
// AllClasses, AllInterfaces, AllUdps, AllPrograms, AllModules, Typespecs,
// Let_decls, Task_funcs, Parameters, Param_assigns, TopModules IN THAT ORDER,
// and SafeCompare reports a SIZE mismatch as failLhs=<the design> -- which is
// why uhdm-cmp dumps the whole design and names nothing.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp14b.cpp -o /tmp/r10bbp14bq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp14bq <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

template <typename V>
static void rep(const char* tag, const V* a, const V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    std::cout << tag << ": " << na << " vs " << nb << (na == nb ? "" : "  <<< SIZE")
              << "\n";
    for (size_t i = 0; i < na; i++)
        std::cout << "   L[" << i << "] id" << (*a)[i]->UhdmId() << " '"
                  << std::string((*a)[i]->VpiName()) << "' @"
                  << (*a)[i]->VpiLineNo() << "\n";
    for (size_t i = 0; i < nb; i++)
        std::cout << "   R[" << i << "] id" << (*b)[i]->UhdmId() << " '"
                  << std::string((*b)[i]->VpiName()) << "' @"
                  << (*b)[i]->VpiLineNo() << "\n";
}

template <typename V>
static void sz(const char* tag, const V* a, const V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    std::cout << tag << ": " << na << " vs " << nb
              << (na == nb ? "" : "  <<< SIZE") << "\n";
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    const design* a = (const design*)((uhdm_handle*)ha[0])->object;
    const design* b = (const design*)((uhdm_handle*)hb[0])->object;
    sz("Include_file_infos", a->Include_file_infos(), b->Include_file_infos());
    rep("AllPackages", a->AllPackages(), b->AllPackages());
    rep("TopPackages", a->TopPackages(), b->TopPackages());
    sz("AllClasses", a->AllClasses(), b->AllClasses());
    sz("AllInterfaces", a->AllInterfaces(), b->AllInterfaces());
    sz("AllUdps", a->AllUdps(), b->AllUdps());
    sz("AllPrograms", a->AllPrograms(), b->AllPrograms());
    rep("AllModules", a->AllModules(), b->AllModules());
    sz("Typespecs", a->Typespecs(), b->Typespecs());
    sz("Let_decls", a->Let_decls(), b->Let_decls());
    sz("Task_funcs", a->Task_funcs(), b->Task_funcs());
    sz("Parameters", a->Parameters(), b->Parameters());
    sz("Param_assigns", a->Param_assigns(), b->Param_assigns());
    rep("TopModules", a->TopModules(), b->TopModules());
    return 0;
}
