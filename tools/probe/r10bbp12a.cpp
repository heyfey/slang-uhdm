// r10bbp12a: CMP-projection census of every CONSTANT (and its non-constant
// siblings) at a given source line — the fields uhdm-cmp actually reads
// (VpiConstType / VpiDecompile / VpiSize) plus the 4-deep ownership path.
// Written for the § derived-config struct-pattern fold head (BlackBePipeInt
// pass 12), where golden and ours both hold a CONSTANT at 2053:16 and differ
// only in VpiSize (32 vs 64).
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp12a.cpp -o /tmp/r10bbp12aq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp12aq <db.uhdm> <line> [line2 ...]
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

static std::string path4(const UhdmListener* l, const any* self) {
    std::string path;
    int i = 0;
    for (auto it = l->getCallstack().crbegin(); it != l->getCallstack().crend();
         ++it) {
        const any* p = *it;
        if (p == self) continue;
        if (!path.empty()) path += " < ";
        path += UhdmName(p->UhdmType());
        if (!std::string(p->VpiName()).empty())
            path += "(" + std::string(p->VpiName()) + ")";
        if (++i >= 5) break;
    }
    return path;
}

class L : public UhdmListener {
 public:
    void enterConstant(const constant* const c) override {
        if (lines.find(c->VpiLineNo()) == lines.end()) return;
        tally[std::to_string(c->VpiLineNo()) + ":" +
              std::to_string(c->VpiColumnNo()) + " constant{ct=" +
              std::to_string(c->VpiConstType()) +
              " sz=" + std::to_string(c->VpiSize()) +
              " dec=" + std::string(c->VpiDecompile()) +
              " val=" + std::string(c->VpiValue()) +
              " ts=" + (c->Typespec() ? "y" : "n") + "}  up: " +
              path4(this, (const any*)c)]++;
    }
    void enterOperation(const operation* const o) override {
        if (lines.find(o->VpiLineNo()) == lines.end()) return;
        tally[std::to_string(o->VpiLineNo()) + ":" +
              std::to_string(o->VpiColumnNo()) + " operation{op=" +
              std::to_string(o->VpiOpType()) +
              " sz=" + std::to_string(o->VpiSize()) + " n=" +
              std::to_string(o->Operands() ? o->Operands()->size() : 0) +
              "}  up: " + path4(this, (const any*)o)]++;
    }
    void enterTagged_pattern(const tagged_pattern* const t) override {
        if (lines.find(t->VpiLineNo()) == lines.end()) return;
        tally[std::to_string(t->VpiLineNo()) + ":" +
              std::to_string(t->VpiColumnNo()) + " tagged_pattern  up: " +
              path4(this, (const any*)t)]++;
    }
    void enterHier_path(const hier_path* const h) override {
        if (lines.find(h->VpiLineNo()) == lines.end()) return;
        tally[std::to_string(h->VpiLineNo()) + ":" +
              std::to_string(h->VpiColumnNo()) + " hier_path(" +
              std::string(h->VpiFullName()) + ")  up: " +
              path4(this, (const any*)h)]++;
    }
};

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    for (int i = 2; i < argc; i++) lines.insert(atoi(argv[i]));
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    L l;
    l.listenAny(d);
    for (auto& kv : tally) std::cout << "x" << kv.second << "  " << kv.first << "\n";
    return 0;
}
