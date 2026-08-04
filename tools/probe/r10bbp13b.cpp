// r10bbp13b: whole-design census of integer_typespec Expr occupancy.  Surelog
// uses integer_typespec::Expr for a CAST SIZE expression; the pass-13 R2 head
// is a slot golden leaves empty and we fill with the folded constant.  This
// lists every integer_typespec in the arena with its location, whether it has
// an Expr, the Expr's CMP projection, and the immediate ownership frames --
// so the G-vs-S diff answers "when does Surelog populate the slot at all".
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp13b.cpp -o /tmp/r10bbp13bq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp13bq <db.uhdm> [onlyWithExpr]
#include <uhdm/UhdmListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <string>
using namespace UHDM;

static bool onlyExpr = false;
static std::map<std::string, int> tally;

static std::string proj(const any* e) {
    if (!e) return "<null>";
    if (e->UhdmType() != uhdmconstant)
        return std::string(UhdmName(e->UhdmType())) + "(" +
               std::string(e->VpiName()) + ")";
    auto* c = (const constant*)e;
    return "constant{ct=" + std::to_string(c->VpiConstType()) +
           " sz=" + std::to_string(c->VpiSize()) + " dec=" +
           std::string(c->VpiDecompile()) +
           " ts=" + (c->Typespec() ? "y" : "n") + "}";
}

class L : public UhdmListener {
 public:
    void enterInteger_typespec(const integer_typespec* const t) override {
        if (onlyExpr && !t->Expr()) return;
        std::string path;
        int i = 0;
        for (auto it = getCallstack().crbegin(); it != getCallstack().crend();
             ++it) {
            const any* p = *it;
            if (p == (const any*)t) continue;
            if (!path.empty()) path += " < ";
            path += UhdmName(p->UhdmType());
            if (++i >= 3) break;
        }
        tally[std::to_string(t->VpiLineNo()) + ":" +
              std::to_string(t->VpiColumnNo()) + " val='" +
              std::string(t->VpiValue()) + "' Expr=" + proj(t->Expr()) +
              "  up: " + path]++;
    }
};

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    if (argc > 2) onlyExpr = true;
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    L l;
    l.listenAny(d);
    for (auto& [k, n] : tally) std::cout << "x" << n << "  " << k << "\n";
    return 0;
}
