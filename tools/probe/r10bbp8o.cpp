// r10bbp8o: print the OPERANDS of every param_assign Rhs operation in every
// top-level view — r10bbp8's Kmac residue is an operand-width difference
// (golden sz 64 vs ours 32) that the op-summary projection (r10bbp7d /
// r10bbp8p) cannot see.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp8o.cpp -o /tmp/r10bbp8oq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp8oq <db.uhdm> [param-name]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;

static std::string one(const any* n) {
    if (!n) return "NULL";
    std::string s(UhdmName(n->UhdmType()));
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += "{ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) +
             " dec=" + std::string(c->VpiDecompile()) +
             " par=" + std::string(c->VpiParent() ? "y" : "n") + "}";
    }
    else if (n->UhdmType() == uhdmoperation) {
        auto* o = (const operation*)n;
        s += "{op=" + std::to_string(o->VpiOpType()) + " n=" +
             std::to_string(o->Operands() ? o->Operands()->size() : 0) + "}";
    }
    else {
        std::string nm(n->VpiName());
        if (!nm.empty()) s += "(" + nm + ")";
    }
    return s;
}

template <typename V>
static void doInst(const std::string& tag, V* v) {
    if (!v) return;
    for (auto* p : *v) {
        std::string vw(p->VpiName());
        if (p->UhdmType() == uhdmpackage)
            vw += ((const package*)p)->VpiTop() ? "[TOP]" : "[DEF]";
        if (!p->Param_assigns()) continue;
        for (auto* pas : *p->Param_assigns()) {
            std::string nm = pas->Lhs() ? std::string(pas->Lhs()->VpiName()) : "?";
            if (!want.empty() && nm != want) continue;
            auto* r = pas->Rhs();
            std::cout << tag << "/" << vw << " " << nm << " " << one(r);
            if (r && r->UhdmType() == uhdmoperation)
                if (auto* ops = ((const operation*)r)->Operands())
                    for (auto* o : *ops) std::cout << "\n      " << one(o);
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
