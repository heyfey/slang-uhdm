// r10earl14c — the PARAMETER-object fields of one listing, side by side.
// A "failLhs <the Rhs expression> / failRhs <null>" head is SafeCompare's
// single-pointer null branch, so the difference is a MEMBER that golden sets and
// we leave null — and for a package parameter the only such members are
// Typespec() / Expr() / Ranges().  The param_assign probes only ever print the
// param_assign's own Rhs, which is equal on both sides in exactly these heads.
// Build: bash tools/probe/r10earl14build.sh r10earl14c
// Usage: r10earl14c <a.uhdm> <b.uhdm> <all|top|allpkg|toppkg> <Name>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string at(const BaseClass* n) {
    if (!n)
        return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " + std::to_string(n->VpiLineNo()) +
                    ":" + std::to_string(n->VpiColumnNo()) + " uid=" +
                    std::to_string(n->UhdmId());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    if (n->UhdmType() == uhdmoperation)
        s += " op=" + std::to_string(((const operation*)n)->VpiOpType());
    return s;
}

static std::string rts(const ref_typespec* r) {
    if (!r)
        return "<null>";
    return "rts->" + at(r->Actual_typespec());
}

static void row(const char* tag, const parameter* p) {
    if (!p) {
        std::cout << "  " << tag << " <null>\n";
        return;
    }
    std::cout << "  " << tag << " " << at(p) << "\n      ts=" << rts(p->Typespec())
              << "\n      Expr=" << at(p->Expr()) << "\n      ranges="
              << (p->Ranges() ? std::to_string(p->Ranges()->size()) : std::string("-"))
              << " imported='" << p->VpiImported() << "'\n";
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
    auto* va = ia->Parameters();
    auto* vb = ib->Parameters();
    size_t na = va ? va->size() : 0, nb = vb ? vb->size() : 0;
    std::cout << "parameters " << na << " vs " << nb << "\n";
    for (size_t i = 0; i < na || i < nb; i++) {
        const parameter* pa =
            i < na ? any_cast<const parameter*>((*va)[i]) : nullptr;
        const parameter* pb =
            i < nb ? any_cast<const parameter*>((*vb)[i]) : nullptr;
        std::cout << "[" << i << "]\n";
        row("A", pa);
        row("B", pb);
    }
    return 0;
}
