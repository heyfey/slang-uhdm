// r10bbp6t: RANGE-FOLD census by source line — for every typespec in the design
// whose VpiLineNo matches, print its type/id, its parent chain (with the
// package DEF/TOP discriminator), and the KIND of each range bound
// (constant = folded, operation = unfolded).  This is the DEF-vs-ELAB
// discriminating view of the RA residue: golden and ours disagree on which
// COPY of a typedef member range folds.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp6t.cpp -o /tmp/r10bbp6tq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp6tq <db.uhdm> <line> [line2 ...]
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <set>
#include <string>
using namespace UHDM;

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 10;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty()) out += "(" + nm + ")";
        if (p->UhdmType() == uhdmpackage)
            out += ((const package*)p)->VpiTop() ? "[TOP]" : "[DEF]";
        if (p->VpiLineNo()) out += "@" + std::to_string(p->VpiLineNo());
    }
    if (out.empty()) out = "<noparent>";
    return out;
}

static const VectorOfrange* rangesOf(const typespec* t) {
    switch (t->UhdmType()) {
        case uhdmbit_typespec: return ((const bit_typespec*)t)->Ranges();
        case uhdmlogic_typespec: return ((const logic_typespec*)t)->Ranges();
        case uhdmint_typespec: return ((const int_typespec*)t)->Ranges();
        case uhdmpacked_array_typespec:
            return ((const packed_array_typespec*)t)->Ranges();
        case uhdmarray_typespec: return ((const array_typespec*)t)->Ranges();
        case uhdmenum_typespec: return nullptr;
        default: return nullptr;
    }
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    std::set<uint32_t> want;
    for (int i = 2; i < argc; i++) want.insert((uint32_t)atoi(argv[i]));
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj) continue;
        const BaseClass* b = obj;
        if (!want.count(b->VpiLineNo())) continue;
        const typespec* t = dynamic_cast<const typespec*>(b);
        if (!t) continue;
        auto* rs = rangesOf(t);
        std::cout << UhdmName(t->UhdmType()) << " #" << t->UhdmId() << " '"
                  << t->VpiName() << "' @" << t->VpiLineNo() << ":"
                  << t->VpiColumnNo() << " inst=";
        if (auto* i = t->Instance()) {
            std::cout << i->VpiName();
            if (i->UhdmType() == uhdmpackage)
                std::cout << (((const package*)i)->VpiTop() ? "[TOP]" : "[DEF]");
        } else
            std::cout << "-";
        std::cout << " dims=";
        if (!rs)
            std::cout << "-";
        else
            for (auto* r : *rs)
                std::cout << "["
                          << (r->Left_expr()
                                  ? UhdmName(r->Left_expr()->UhdmType())
                                  : "-")
                          << ":"
                          << (r->Right_expr()
                                  ? UhdmName(r->Right_expr()->UhdmType())
                                  : "-")
                          << "]";
        std::cout << "\n    up: " << chain((const BaseClass*)t->VpiParent())
                  << "\n";
    }
    return 0;
}
