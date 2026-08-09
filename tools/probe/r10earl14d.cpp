// r10earl14d — compare the two halves of ONE param_assign row SEPARATELY (Lhs
// alone, Rhs alone) with fresh contexts, and print the row's Lhs parameter's
// vectors.  A whole-row compare that names the row's OWN Rhs as failLhs with a
// null failRhs cannot say whether the null is a member of the Rhs subtree or a
// pointer somewhere else that happens to reach it; splitting the row does.
// Build: bash tools/probe/r10earl14build.sh r10earl14d
// Usage: r10earl14d <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Name> [row]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string at(const BaseClass* n) {
    if (!n)
        return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " + std::to_string(n->VpiLineNo()) +
                    ":" + std::to_string(n->VpiColumnNo()) + " uid=" +
                    std::to_string(n->UhdmId());
    if (n->UhdmType() == uhdmoperation) {
        auto* o = (const operation*)n;
        s += " {op=" + std::to_string(o->VpiOpType()) + " nops=" +
             (o->Operands() ? std::to_string(o->Operands()->size())
                            : std::string("NULLVEC")) +
             " attrs=" +
             (o->Attributes() ? std::to_string(o->Attributes()->size())
                              : std::string("NULLVEC")) +
             "}";
    }
    if (n->UhdmType() == uhdmsys_func_call) {
        auto* c = (const sys_func_call*)n;
        s += " {args=" +
             (c->Tf_call_args() ? std::to_string(c->Tf_call_args()->size())
                                : std::string("NULLVEC")) +
             "}";
    }
    if (const instance* in = any_cast<const instance*>((const any*)n))
        s += " {top=" + std::to_string((int)in->VpiTop()) + "}";
    return s;
}

template <class V>
static const instance* pick(V* v, const std::string& want) {
    if (v)
        for (auto* x : *v) {
            std::string n(x->VpiName()), dn(x->VpiDefName());
            if (n == want || dn == want || ("def:" + dn) == want)
                return x;
        }
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 5)
        return 1;
    std::string vec = argv[3], want = argv[4];
    long only = argc > 5 ? std::stol(argv[5]) : -1;
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty())
        return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    const instance* ia = nullptr;
    const instance* ib = nullptr;
    if (vec == "all") {
        ia = pick(da->AllModules(), want);
        ib = pick(db->AllModules(), want);
    }
    else if (vec == "top") {
        ia = pick(da->TopModules(), want);
        ib = pick(db->TopModules(), want);
    }
    else if (vec == "allpkg") {
        ia = pick(da->AllPackages(), want);
        ib = pick(db->AllPackages(), want);
    }
    else {
        ia = pick(da->TopPackages(), want);
        ib = pick(db->TopPackages(), want);
    }
    if (!ia || !ib) {
        std::cout << "not found\n";
        return 3;
    }
    auto* va = ia->Param_assigns();
    auto* vb = ib->Param_assigns();
    if (!va || !vb)
        return 4;
    for (size_t i = 0; i < va->size() && i < vb->size(); i++) {
        if (only >= 0 && (long)i != only)
            continue;
        const param_assign* a = (*va)[i];
        const param_assign* b = (*vb)[i];
        std::cout << "[" << i << "] " << (a->Lhs() ? a->Lhs()->VpiName() : "?") << "\n";
        {
            CompareContext c;
            int r = a->Lhs()->Compare(b->Lhs(), &c);
            std::cout << "   LHS r=" << r << " failLhs=" << at(c.m_failedLhs)
                      << " failRhs=" << at(c.m_failedRhs) << "\n";
        }
        {
            CompareContext c;
            int r = a->Rhs()->Compare(b->Rhs(), &c);
            std::cout << "   RHS r=" << r << " failLhs=" << at(c.m_failedLhs)
                      << " failRhs=" << at(c.m_failedRhs) << "\n";
        }
        std::cout << "   A.rhs " << at(a->Rhs()) << "\n   B.rhs " << at(b->Rhs())
                  << "\n";
    }
    return 0;
}
