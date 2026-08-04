// r10bbp13a: CMP-projection census of every TYPESPEC whose source line falls in
// a requested set -- its kind, name, whether it carries an Expr (integer /
// int / bit / logic typespecs use that slot for a cast size), its ranges, and
// the first few frames of the LISTENER ownership path.  Written for the
// BlackBePipeInt pass-13 R2 head, where golden's cast typespec has NO Expr in
// the slot our folded constant occupies.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp13a.cpp -o /tmp/r10bbp13aq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp13aq <db.uhdm> <line> [line2 ...]
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

static const expr* tsExpr(const typespec* t) {
    switch (t->UhdmType()) {
        case uhdminteger_typespec: return ((const integer_typespec*)t)->Expr();
        default: return nullptr;
    }
}

class L : public UhdmListener {
 public:
    void enterAny(const any* const o) override {
        if (!o) return;
        const typespec* t = any_cast<const typespec*>(o);
        if (!t) return;
        if (lines.find(t->VpiLineNo()) == lines.end()) return;
        std::string path;
        int i = 0;
        for (auto it = getCallstack().crbegin(); it != getCallstack().crend();
             ++it) {
            const any* p = *it;
            if (p == o) continue;
            if (!path.empty()) path += " < ";
            path += UhdmName(p->UhdmType());
            if (!std::string(p->VpiName()).empty())
                path += "(" + std::string(p->VpiName()) + ")";
            if (++i >= 5) break;
        }
        tally[std::string(UhdmName(t->UhdmType())) + "(" +
              std::string(t->VpiName()) + ") @" +
              std::to_string(t->VpiLineNo()) + ":" +
              std::to_string(t->VpiColumnNo()) +
              " Expr=" + proj(tsExpr(t)) + "  up: " + path]++;
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
