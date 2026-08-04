// r10bbp12b: per-VIEW param_assign Rhs projection for a named parameter.
// Walks the design's own vectors (AllPackages / TopPackages / AllModules /
// TopModules) ONLY -- no Instance/typespec back-links, so each listing is
// visited exactly once and counts are directly comparable between golden and
// ours.  For the matched param_assign it prints the CMP-relevant projection of
// the Rhs and, when the Rhs is an operation, of every operand (recursing one
// level into tagged_patterns).
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp12b.cpp -o /tmp/r10bbp12bq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp12bq <db.uhdm> <param-name> [maxops]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;
static int maxops = 8;

static std::string loc(const any* n) {
    return std::to_string(n->VpiLineNo()) + ":" +
           std::to_string(n->VpiColumnNo());
}

static std::string proj(const any* n) {
    if (!n) return "NULL";
    std::string s(UhdmName(n->UhdmType()));
    s += "#" + std::to_string(n->UhdmId()) + "@" + loc(n);
    switch (n->UhdmType()) {
        case uhdmconstant: {
            auto* c = (const constant*)n;
            s += "{ct=" + std::to_string(c->VpiConstType()) +
                 " sz=" + std::to_string(c->VpiSize()) + " dec=" +
                 std::string(c->VpiDecompile()) + " val=" +
                 std::string(c->VpiValue()) +
                 " ts=" + (c->Typespec() ? "y" : "n") + "}";
            break;
        }
        case uhdmoperation: {
            auto* o = (const operation*)n;
            s += "{op=" + std::to_string(o->VpiOpType()) +
                 " sz=" + std::to_string(o->VpiSize()) + " n=" +
                 std::to_string(o->Operands() ? o->Operands()->size() : 0) +
                 "}";
            break;
        }
        case uhdmhier_path:
            s += "{" + std::string(((const hier_path*)n)->VpiFullName()) + "}";
            break;
        case uhdmref_obj:
            s += "{" + std::string(n->VpiName()) + "}";
            break;
        case uhdmtagged_pattern: {
            auto* t = (const tagged_pattern*)n;
            std::string key;
            if (t->Typespec() && t->Typespec()->Actual_typespec())
                key = std::string(
                          UhdmName(t->Typespec()->Actual_typespec()->UhdmType())) +
                      "(" +
                      std::string(t->Typespec()->Actual_typespec()->VpiName()) +
                      ")";
            s += "{key=" + key + " -> " + proj(t->Pattern()) + "}";
            break;
        }
        default:
            if (!std::string(n->VpiName()).empty())
                s += "{" + std::string(n->VpiName()) + "}";
            break;
    }
    return s;
}

static void dumpPa(const std::string& view, const param_assign* pa) {
    const any* lhs = pa->Lhs();
    if (!lhs) return;
    if (want != "*" && std::string(lhs->VpiName()) != want) return;
    if (want == "*") std::cout << "== " << lhs->VpiName() << "\n";
    std::cout << view << "  param_assign@" << loc(pa) << "  Rhs=" << proj(pa->Rhs())
              << "\n";
    if (pa->Rhs() && pa->Rhs()->UhdmType() == uhdmoperation) {
        auto* ops = ((const operation*)pa->Rhs())->Operands();
        if (ops) {
            int i = 0;
            for (auto* o : *ops) {
                if (i >= maxops) { std::cout << "      ...\n"; break; }
                std::cout << "    [" << i << "] " << proj(o) << "\n";
                i++;
            }
        }
    }
}

static void scanScope(const std::string& view, const scope* sc) {
    if (!sc) return;
    if (sc->Param_assigns())
        for (auto* pa : *sc->Param_assigns()) dumpPa(view, pa);
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    want = argv[2];
    if (argc > 3) maxops = atoi(argv[3]);
    Serializer ser;
    auto h = ser.Restore(std::filesystem::path(argv[1]));
    if (h.empty()) return 2;
    const design* d = (const design*)((uhdm_handle*)h[0])->object;
    auto doVec = [&](const char* tag, auto* v) {
        if (!v) return;
        int i = 0;
        for (auto* e : *v) {
            scanScope(std::string(tag) + "[" + std::to_string(i) + "]" +
                          std::string(e->VpiName()),
                      (const scope*)e);
            i++;
        }
    };
    doVec("AllPkg", d->AllPackages());
    doVec("TopPkg", d->TopPackages());
    doVec("AllMod", d->AllModules());
    doVec("TopMod", d->TopModules());
    return 0;
}
