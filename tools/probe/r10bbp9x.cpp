// r10bbp9x: WHOLE-ARENA object census by (type, line:col, parent type,
// parent line:col) — the coarse instrument for "golden holds an object where
// ours holds nullptr" when the per-slot probes (r10bbp8x) come back clean:
// an extra OBJECT in golden's arena shows up here even when the slot that
// holds it is one the slot probe does not walk.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp9x.cpp -o /tmp/r10bbp9xxq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp9xxq <db.uhdm> [line]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static std::string at(const any* n) {
    if (!n) return "NULL";
    return std::string(UhdmName(n->UhdmType())) + "@" +
           std::to_string(n->VpiLineNo()) + ":" +
           std::to_string(n->VpiColumnNo());
}

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    int wantLine = argc > 2 ? atoi(argv[2]) : 0;
    Serializer ser;
    auto restored = ser.Restore(std::string(argv[1]));
    if (restored.empty()) return 2;
    std::map<std::string, int> tally;
    for (auto& [obj, id] : ser.AllObjects()) {
        if (!obj) continue;
        if (wantLine && (int)obj->VpiLineNo() != wantLine) continue;
        std::string k = at(obj);
        if (obj->UhdmType() == uhdmconstant) {
            auto* c = (const constant*)obj;
            k += "{ct=" + std::to_string(c->VpiConstType()) +
                 " sz=" + std::to_string(c->VpiSize()) +
                 " dec=" + std::string(c->VpiDecompile()) + "}";
        }
        else {
            std::string nm(obj->VpiName());
            if (!nm.empty())
                k += "(" + nm + ")";
        }
        k += "  par=" + at(obj->VpiParent());
        tally[k]++;
    }
    for (auto& [k, n] : tally) std::cout << n << "  " << k << "\n";
    return 0;
}
