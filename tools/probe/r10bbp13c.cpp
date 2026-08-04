// r10bbp13c: cross-file object Compare drill.  Given a golden UhdmId and an
// ours UhdmId, restores both databases, locates the two objects and runs UHDM's
// own Compare with a fresh CompareContext -- then prints the failing pair AND,
// for a parameter, the whole typespec chain (ref_typespec -> actual -> its
// Instance) on both sides.  The whole-design cmp names only the outermost
// container; the 10b drill names the vector slot; this names the MEMBER.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp13c.cpp -o /tmp/r10bbp13cq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp13cq <golden.uhdm> <ours.uhdm> <gid>:<sid>[,<gid>:<sid>...]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string at(const BaseClass* n) {
    if (!n) return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " id" +
                    std::to_string(n->UhdmId()) + " '" +
                    std::string(n->VpiName()) + "' " +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    if (n->UhdmType() == uhdmparameter) {
        auto* p = (const parameter*)n;
        s += " {ct=" + std::to_string(p->VpiConstType()) +
             " signed=" + std::to_string(p->VpiSigned()) +
             " local=" + std::to_string(p->VpiLocalParam()) + " imported='" +
             std::string(p->VpiImported()) + "' full='" +
             std::string(p->VpiFullName()) + "' expr=" +
             (p->Expr() ? UhdmName(p->Expr()->UhdmType()) : "null") +
             " ranges=" +
             std::to_string(p->Ranges() ? p->Ranges()->size() : 0) + "}";
    }
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    return s;
}

static void tsChain(const char* tag, const any* o) {
    const ref_typespec* rt = nullptr;
    if (o->UhdmType() == uhdmparameter) rt = ((const parameter*)o)->Typespec();
    else if (o->UhdmType() == uhdmconstant)
        rt = ((const constant*)o)->Typespec();
    if (!rt) { std::cout << "   " << tag << " ts=<null>\n"; return; }
    const typespec* a = rt->Actual_typespec();
    std::cout << "   " << tag << " rt='" << rt->VpiFullName() << "' -> "
              << at(a);
    if (a) std::cout << "  Instance=" << at(a->Instance());
    std::cout << "\n";
}

int main(int argc, char** argv) {
    if (argc < 4) return 1;
    std::vector<std::pair<uint32_t, uint32_t>> pairs;
    {
        std::string in(argv[3]);
        size_t p = 0;
        while (p < in.size()) {
            size_t q = in.find(',', p);
            if (q == std::string::npos) q = in.size();
            std::string one = in.substr(p, q - p);
            size_t c = one.find(':');
            pairs.push_back({(uint32_t)atoll(one.substr(0, c).c_str()),
                             (uint32_t)atoll(one.substr(c + 1).c_str())});
            p = q + 1;
        }
    }
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    std::map<uint32_t, const BaseClass*> ga, gb;
    for (auto& [obj, id] : sa.AllObjects())
        if (obj) ga[obj->UhdmId()] = obj;
    for (auto& [obj, id] : sb.AllObjects())
        if (obj) gb[obj->UhdmId()] = obj;
    for (auto& [gi, si] : pairs) {
        auto ia = ga.find(gi), ib = gb.find(si);
        const BaseClass* a = ia == ga.end() ? nullptr : ia->second;
        const BaseClass* b = ib == gb.end() ? nullptr : ib->second;
        std::cout << "PAIR " << gi << ":" << si << "\n   G " << at(a)
                  << "\n   S " << at(b) << "\n";
        if (!a || !b) continue;
        tsChain("G", (const any*)a);
        tsChain("S", (const any*)b);
        CompareContext c;
        int r = a->Compare(b, &c);
        std::cout << "   r=" << r << " failLhs " << at(c.m_failedLhs)
                  << " failRhs " << at(c.m_failedRhs) << "\n";
    }
    return 0;
}
