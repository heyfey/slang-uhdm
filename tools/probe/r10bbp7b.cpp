// r10bbp7b: BISECT a failing view Compare down to the exact CONTAINER and
// INDEX.  cmptool reports the failing object's PARENT CHAIN, which is not the
// vector that held it (UHDM objects are shared across views), so a whole-view
// r=1 gives no handle on where to look.  This walks each view's member
// vectors element-by-element with UHDM's own Compare and prints the first
// index that fails in each.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp7b.cpp -o /tmp/r10bbp7bq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp7bq <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string loc(const BaseClass* p) {
    if (!p) return "-";
    return std::string(UhdmName(p->UhdmType())) + "(" +
           std::string(p->VpiName()) + ")@" + std::to_string(p->VpiLineNo()) +
           ":" + std::to_string(p->VpiColumnNo());
}

template <typename V>
static void cmpVec(const std::string& tag, V* a, V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    if (na != nb) {
        std::cout << "  " << tag << " SIZE " << na << " vs " << nb << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++) {
        CompareContext c;
        int r = (*a)[i]->Compare((*b)[i], &c);
        if (r) {
            std::cout << "  " << tag << "[" << i << "] r=" << r
                      << " lhs=" << loc((*a)[i])
                      << " failLhs=" << loc(c.m_failedLhs)
                      << " failRhs=" << loc(c.m_failedRhs) << "\n";
            return;
        }
    }
}

template <typename P>
static void doPair(const std::string& tag, P* a, P* b) {
    CompareContext c0;
    if (a->Compare(b, &c0) == 0) return;
    std::cout << tag << " r=1 failLhs=" << loc(c0.m_failedLhs)
              << " failRhs=" << loc(c0.m_failedRhs) << "\n";
    cmpVec("Parameters", a->Parameters(), b->Parameters());
    cmpVec("Param_assigns", a->Param_assigns(), b->Param_assigns());
    cmpVec("Typespecs", a->Typespecs(), b->Typespecs());
    cmpVec("Task_funcs", a->Task_funcs(), b->Task_funcs());
    cmpVec("Variables", a->Variables(), b->Variables());
    cmpVec("Nets", a->Nets(), b->Nets());
}

template <typename V>
static void doView(const std::string& tag, V* a, V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    if (na != nb) {
        std::cout << tag << " SIZE " << na << " vs " << nb << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++)
        doPair(tag + "[" + std::to_string(i) + "]" +
                   std::string((*a)[i]->VpiName()),
               (*a)[i], (*b)[i]);
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    Serializer sa, sb;
    auto ra = sa.Restore(std::string(argv[1]));
    auto rb = sb.Restore(std::string(argv[2]));
    if (ra.empty() || rb.empty()) return 2;
    design* da = (design*)((uhdm_handle*)ra[0])->object;
    design* db = (design*)((uhdm_handle*)rb[0])->object;
    doView("ALLPKG", da->AllPackages(), db->AllPackages());
    doView("TOPPKG", da->TopPackages(), db->TopPackages());
    doView("ALLMOD", da->AllModules(), db->AllModules());
    doView("TOPMOD", da->TopModules(), db->TopModules());
    return 0;
}
