// r10bbp8c: enumerate every typespec that carries a Cast_to_expr (int/logic/
// bit/byte/short/long/integer), with the expr projected onto the CMP-relevant
// fields.  The r10bbp8 uhdm-cmp head is "golden holds constant 64 @14986:34
// where ours holds nullptr", reached from EVERY view root, and neither the
// param_assign census (r10bbp7d) nor the parameter projection (r10bbp8p) can
// see it — Cast_to_expr is the only nullable `constant` child on the typespec
// chain those roots recurse through (typespec::Compare follows Instance()).
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp8c.cpp -o /tmp/r10bbp8cq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp8cq <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::string one(const any* n) {
    if (!n) return "NULL";
    std::string s(UhdmName(n->UhdmType()));
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += "{ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) +
             " dec=" + std::string(c->VpiDecompile()) + "}";
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

static std::string at(const any* n) {
    return std::to_string(n->VpiLineNo()) + ":" + std::to_string(n->VpiColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    // Count by (typespec kind, span, expr projection) so the two databases
    // line-diff without depending on arena order.
    std::map<std::string, int> tally;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj) continue;
        const expr* ce = nullptr;
        switch (obj->UhdmType()) {
            case uhdmint_typespec: ce = ((int_typespec*)obj)->Cast_to_expr(); break;
            default: break;
        }
        if (!ce) continue;
        tally[std::string(UhdmName(obj->UhdmType())) + "@" + at(obj) + " cast=" +
              one(ce) + "@" + at(ce)]++;
    }
    for (auto& [k, n] : tally) std::cout << n << "  " << k << "\n";
    return 0;
}
