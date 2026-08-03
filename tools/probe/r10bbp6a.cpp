// r10bbp6a: WHOLE-DESIGN range-fold census.  One sorted line per ranged
// typespec: parent chain (with the package DEF/TOP discriminator, ids
// stripped) + the KIND of each range bound (constant = folded, operation =
// unfolded).  diff golden-vs-ours to enumerate EVERY remaining fold
// divergence at once instead of chasing the cmp head one object at a time.
// Build:
//   g++ -std=c++20 -O0 tools/probe/r10bbp6a.cpp -o /tmp/r10bbp6aq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp6aq <db.uhdm>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>
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
        default: return nullptr;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    std::vector<std::string> lines;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj) continue;
        const typespec* t = dynamic_cast<const typespec*>(obj);
        if (!t) continue;
        auto* rs = rangesOf(t);
        if (!rs || rs->empty()) continue;
        std::string dims;
        for (auto* r : *rs)
            dims += std::string("[") +
                    (r->Left_expr() ? UhdmName(r->Left_expr()->UhdmType())
                                    : "-") +
                    ":" +
                    (r->Right_expr() ? UhdmName(r->Right_expr()->UhdmType())
                                     : "-") +
                    "]";
        std::string inst = "-";
        if (auto* i = t->Instance()) {
            inst = std::string(i->VpiName());
            if (i->UhdmType() == uhdmpackage)
                inst += ((const package*)i)->VpiTop() ? "[TOP]" : "[DEF]";
        }
        lines.push_back(chain((const BaseClass*)t->VpiParent()) + " || " +
                        UhdmName(t->UhdmType()) + " '" +
                        std::string(t->VpiName()) + "' @" +
                        std::to_string(t->VpiLineNo()) + ":" +
                        std::to_string(t->VpiColumnNo()) + " inst=" + inst +
                        " dims=" + dims);
    }
    std::sort(lines.begin(), lines.end());
    for (auto& l : lines) std::cout << l << "\n";
    return 0;
}
