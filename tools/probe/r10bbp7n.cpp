// r10bbp7n: find every param_assign in the design whose Rhs is NULL, and
// every param_assign at a given source line, with its owning view — the
// r10bbp7 head residue is "golden has a constant Rhs where ours has none"
// (uhdm-cmp: LHS constant @14986, RHS <null>) and the four top-level listing
// vectors all matched, so the hole is somewhere the ordered probe never
// looked.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp7n.cpp -o /tmp/r10bbp7nq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp7nq <db.uhdm> [line]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static int wantLine = 0;

static std::string chain(const any* n) {
    std::string s;
    int d = 0;
    for (const any* p = n; p && d < 6; p = p->VpiParent(), d++) {
        std::string nm(p->VpiName());
        s += std::string(UhdmName(p->UhdmType()));
        if (!nm.empty()) s += "(" + nm + ")";
        s += "<";
    }
    return s;
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    if (argc > 2) wantLine = atoi(argv[2]);
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    (void)d;
    int nulls = 0, hits = 0;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj || obj->UhdmType() != uhdmparam_assign) continue;
        auto* pa = (param_assign*)obj;
        bool isNull = pa->Rhs() == nullptr;
        bool lineHit = wantLine && (int)pa->VpiLineNo() == wantLine;
        if (!isNull && !lineHit) continue;
        if (isNull) nulls++;
        if (lineHit) hits++;
        std::cout << (isNull ? "NULLRHS " : "LINE    ")
                  << (pa->Lhs() ? pa->Lhs()->VpiName() : "?") << " @"
                  << pa->VpiLineNo() << ":" << pa->VpiColumnNo()
                  << " rhs=" << (pa->Rhs() ? UhdmName(pa->Rhs()->UhdmType())
                                           : "NULL")
                  << " parents=" << chain(pa->VpiParent()) << "\n";
    }
    std::cout << "nulls=" << nulls << " lineHits=" << hits << "\n";
    return 0;
}
