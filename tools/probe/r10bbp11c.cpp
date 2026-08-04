// r10bbp11c: CMP-projection census of every RANGE BOUND in the arena at a
// given source line — the constant fields uhdm-cmp actually reads
// (VpiConstType / VpiDecompile / VpiSize) plus whether the bound carries a
// vpiTypespec, tallied with the holder typespec kind and its parent chain.
// Written for the § pkgParamOwnDefRange follow-on head, where golden and ours
// both hold a CONSTANT and differ only in VpiSize (32 vs 64).
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp11c.cpp -o /tmp/r10bbp11cq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp11cq <db.uhdm> <line> [line2 ...]
#include <uhdm/UhdmListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <set>
#include <string>
using namespace UHDM;

static std::set<uint32_t> lines;
static std::map<std::string, int> tally;

static std::string proj(const expr* e) {
    if (!e) return "<null>";
    if (e->UhdmType() != uhdmconstant)
        return std::string(UhdmName(e->UhdmType()));
    auto* c = (const constant*)e;
    return "constant{ct=" + std::to_string(c->VpiConstType()) +
           " sz=" + std::to_string(c->VpiSize()) + " dec=" +
           std::string(c->VpiDecompile()) +
           " ts=" + (c->Typespec() ? "y" : "n") + "}";
}

class L : public UhdmListener {
 public:
    void enterRange(const range* const r) override {
        if (lines.find(r->VpiLineNo()) == lines.end()) return;
        std::string path;
        int i = 0;
        for (auto it = getCallstack().crbegin(); it != getCallstack().crend();
             ++it) {
            const any* p = *it;
            if (p == (const any*)r) continue;
            if (!path.empty()) path += " < ";
            path += UhdmName(p->UhdmType());
            if (!std::string(p->VpiName()).empty())
                path += "(" + std::string(p->VpiName()) + ")";
            if (++i >= 4) break;
        }
        tally[std::to_string(r->VpiLineNo()) + ":" +
              std::to_string(r->VpiColumnNo()) + " L=" + proj(r->Left_expr()) +
              " R=" + proj(r->Right_expr()) + "  up: " + path]++;
    }
};

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    for (int i = 2; i < argc; i++) lines.insert((uint32_t)atoll(argv[i]));
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    L l;
    l.listenAny(d);
    for (auto& [k, n] : tally) std::cout << "x" << n << "  " << k << "\n";
    return 0;
}
