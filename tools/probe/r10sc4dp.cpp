// r10sc4dp: design-level Parameters/Param_assigns/Typespecs census, side by
// side. The Scr1 histogram's dominant vector (47 of 132) is a port Compare
// that fails with (lhs=<null>, rhs=parameter(...)@design) -- a design-level
// container size divergence surfacing through typespec Instance() recursion.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10sc4dp.cpp -o /tmp/r10sc4dp \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    std::string r = std::string(UhdmName(o->UhdmType())) + "(" +
                    std::string(o->VpiName()) + ")@" +
                    std::to_string(o->VpiLineNo()) + ":" +
                    std::to_string(o->VpiColumnNo());
    if (o->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)o;
        r += "{ct=" + std::to_string(c->VpiConstType()) + ",sz=" +
             std::to_string(c->VpiSize()) + ",v=" + std::string(c->VpiValue()) +
             ",dc=" + std::string(c->VpiDecompile()) + "}";
    }
    return r;
}

// Element-wise Compare over a design-level vector: names the FIRST index whose
// Compare fails and the (lhs,rhs) pair the walk stopped on.
template <typename V>
static void cmpv(const char* tag, const V* a, const V* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (sa != sb) { std::cout << tag << " CMP: size " << sa << " vs " << sb << "\n"; return; }
    int nfail = 0;
    for (size_t i = 0; i < sa; i++) {
        CompareContext c;
        c.m_failedLhs = nullptr; c.m_failedRhs = nullptr;
        int r = (*a)[i]->Compare((*b)[i], &c);
        if (r) {
            if (nfail < 60)
                std::cout << tag << " CMP[" << i << "] r=" << r << " " << nm((*a)[i])
                          << " vs " << nm((*b)[i]) << "  failLhs=" << nm(c.m_failedLhs)
                          << " failRhs=" << nm(c.m_failedRhs) << "\n";
            nfail++;
        }
    }
    std::cout << tag << " CMP: " << nfail << " / " << sa << " elements differ\n";
}

template <typename V>
static void row(const char* tag, const V* a, const V* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    std::cout << tag << ": lhs=" << (a ? (int)sa : -1) << " rhs=" << (b ? (int)sb : -1)
              << (sa == sb ? "" : "   <-- SIZE DIFF") << "\n";
    size_t n = sa > sb ? sa : sb;
    for (size_t i = 0; i < n; i++) {
        std::string l = (a && i < sa) ? nm((*a)[i]) : std::string("-");
        std::string r = (b && i < sb) ? nm((*b)[i]) : std::string("-");
        std::string lc = l.substr(0, l.find('@')), rc = r.substr(0, r.find('@'));
        std::cout << (lc == rc ? "    " : " *  ") << "[" << i << "] " << l
                  << "  |  " << r << "\n";
    }
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    {
        CompareContext c;
        int r = da->Compare(db, &c);
        std::cout << "DESIGN r=" << r << " failLhs=" << nm(c.m_failedLhs)
                  << " failRhs=" << nm(c.m_failedRhs) << "\n";
    }
    cmpv("design.Parameters", da->Parameters(), db->Parameters());
    cmpv("design.Param_assigns", da->Param_assigns(), db->Param_assigns());
    cmpv("design.Typespecs", da->Typespecs(), db->Typespecs());
    row("design.Parameters", da->Parameters(), db->Parameters());
    row("design.Param_assigns", da->Param_assigns(), db->Param_assigns());
    row("design.Typespecs", da->Typespecs(), db->Typespecs());
    row("design.Task_funcs", da->Task_funcs(), db->Task_funcs());
    return 0;
}
