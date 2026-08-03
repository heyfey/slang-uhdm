// r10bbp8p: CMP-RELEVANT projection of every `parameter` in every top-level
// view.  parameter::Compare reads VpiConstType, VpiSigned, Expr(), Ranges(),
// Left_range(), Right_range(), VpiLocalParam, VpiName, VpiImported (plus the
// basetype's Typespec) -- r10bbp7's param_assign projection (r10bbp7d) never
// looked at any of them, and the r10bbp8 bisect lands on
// `Parameters[i] failLhs=constant()@14986:34 failRhs=-`, i.e. golden holds a
// constant on a parameter child that ours leaves null.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp8p.cpp -o /tmp/r10bbp8pq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp8pq <db.uhdm> [view-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;

static std::string ex(const any* n) {
    if (!n) return "-";
    std::string s(UhdmName(n->UhdmType()));
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += "{ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) +
             " dec=" + std::string(c->VpiDecompile()) + "}";
    }
    else if (n->UhdmType() == uhdmoperation) {
        auto* o = (const operation*)n;
        s += "{op=" + std::to_string(o->VpiOpType()) + " nops=" +
             std::to_string(o->Operands() ? o->Operands()->size() : 0) + "}";
    }
    else {
        std::string nm(n->VpiName());
        if (!nm.empty()) s += "(" + nm + ")";
    }
    return s;
}

static std::string tsOf(const ref_typespec* rt) {
    if (!rt) return "-";
    std::string s = "ref(" + std::string(rt->VpiName()) + ")";
    if (auto* a = rt->Actual_typespec()) {
        s += "->" + std::string(UhdmName(a->UhdmType()));
        std::string an(a->VpiName());
        if (!an.empty()) s += "(" + an + ")";
    }
    else
        s += "->NULL";
    return s;
}

template <typename V>
static void doInst(const std::string& tag, V* v) {
    if (!v) return;
    for (auto* p : *v) {
        std::string vw(p->VpiName());
        if (p->UhdmType() == uhdmpackage)
            vw += ((const package*)p)->VpiTop() ? "[TOP]" : "[DEF]";
        std::string full = tag + "/" + vw;
        if (!want.empty() && full.find(want) == std::string::npos) continue;
        if (!p->Parameters()) continue;
        int i = 0;
        for (auto* pa : *p->Parameters()) {
            std::cout << full << " P " << i++ << " " << pa->VpiName() << " "
                      << UhdmName(pa->UhdmType());
            if (pa->UhdmType() == uhdmparameter) {
                auto* pp = (const parameter*)pa;
                std::cout << " ct=" << pp->VpiConstType()
                          << " sg=" << (pp->VpiSigned() ? 1 : 0)
                          << " lp=" << (pp->VpiLocalParam() ? 1 : 0)
                          << " imp=" << pp->VpiImported()
                          << " expr=" << ex(pp->Expr())
                          << " nrng=" << (pp->Ranges() ? pp->Ranges()->size() : 0)
                          << " lr=" << ex(pp->Left_range())
                          << " rr=" << ex(pp->Right_range())
                          << " ts=" << tsOf(pp->Typespec());
            }
            std::cout << "\n";
        }
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    if (argc > 2) want = argv[2];
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    design* d = (design*)((uhdm_handle*)restored[0])->object;
    doInst("ALLPKG", d->AllPackages());
    doInst("TOPPKG", d->TopPackages());
    doInst("ALLMOD", d->AllModules());
    doInst("TOPMOD", d->TopModules());
    return 0;
}
