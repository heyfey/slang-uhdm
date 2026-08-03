// r10bbp7d: CMP-RELEVANT projection of every param_assign in every top-level
// view — the fields uhdm-cmp actually reads (UhdmType / VpiName / VpiDefName,
// plus constant's VpiConstType / VpiDecompile / VpiSize) and the Rhs's
// typespec chain.  Line-diffable between golden and ours.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp7d.cpp -o /tmp/r10bbp7dq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp7dq <db.uhdm> [view-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;

static std::string tsOf(const any* n) {
    if (!n) return "-";
    const ref_typespec* rt = nullptr;
    if (n->UhdmType() == uhdmconstant) rt = ((const constant*)n)->Typespec();
    else if (n->UhdmType() == uhdmoperation) rt = ((const operation*)n)->Typespec();
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

static std::string rhsOf(const any* r) {
    if (!r) return "NULL";
    std::string s(UhdmName(r->UhdmType()));
    if (r->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)r;
        s += " ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) +
             " dec=" + std::string(c->VpiDecompile()) +
             " val=" + std::string(c->VpiValue());
    }
    else if (r->UhdmType() == uhdmoperation) {
        auto* o = (const operation*)r;
        s += " op=" + std::to_string(o->VpiOpType()) +
             " nops=" +
             std::to_string(o->Operands() ? o->Operands()->size() : 0);
    }
    else {
        std::string nm(r->VpiName());
        if (!nm.empty()) s += "(" + nm + ")";
    }
    s += " ts=" + tsOf(r);
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
        if (!p->Param_assigns()) continue;
        int i = 0;
        for (auto* pas : *p->Param_assigns())
            std::cout << full << " A " << i++ << " "
                      << (pas->Lhs() ? pas->Lhs()->VpiName() : "?") << " | "
                      << rhsOf(pas->Rhs()) << "\n";
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
