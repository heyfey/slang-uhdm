// r10earl10k: one named param_assign's Rhs tree in EVERY listing (packages
// and modules), both sides, with ts refs and operand kinds.
// Usage: r10earl10k <a.uhdm> <b.uhdm> <ParamName>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void walk(const any* n, const std::string& ind) {
    if (!n) { std::cout << ind << "<null>\n"; return; }
    std::cout << ind << UhdmName(n->UhdmType()) << " '" << n->VpiName() << "' @"
              << n->VpiLineNo() << ":" << n->VpiColumnNo();
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        std::cout << " {ct=" << c->VpiConstType() << " sz=" << c->VpiSize()
                  << " dec='" << c->VpiDecompile() << "'}";
    }
    if (n->UhdmType() == uhdmoperation)
        std::cout << " op=" << ((const operation*)n)->VpiOpType();
    if (auto* e = any_cast<const expr*>(n)) {
        auto* r = e->Typespec();
        if (r) {
            auto* a = r->Actual_typespec();
            std::cout << " ts=" << (a ? UhdmName(a->UhdmType()) : "<null>") << "'"
                      << (a ? a->VpiName() : "") << "'";
        }
    }
    std::cout << "\n";
    if (n->UhdmType() == uhdmoperation) {
        if (auto* ops = ((const operation*)n)->Operands())
            for (auto* o : *ops) walk(o, ind + "  ");
    }
    else if (n->UhdmType() == uhdmtagged_pattern) {
        auto* tp = (const tagged_pattern*)n;
        if (auto* r = tp->Typespec())
            std::cout << ind << "  .key ts="
                      << (r->Actual_typespec()
                              ? std::string(UhdmName(
                                    r->Actual_typespec()->UhdmType())) +
                                    "'" +
                                    std::string(r->Actual_typespec()->VpiName()) +
                                    "'"
                              : "<null>")
                      << "\n";
        walk(tp->Pattern(), ind + "  ");
    }
}

static std::string want;

static void listing(const char* tag, const std::string& nm, const instance* in,
                    const char* side) {
    if (!in->Param_assigns()) return;
    for (auto* pa : *in->Param_assigns()) {
        if (!pa->Lhs() || std::string(pa->Lhs()->VpiName()) != want) continue;
        std::cout << "[" << side << "] " << tag << " " << nm
                  << " top=" << (int)in->VpiTop() << "\n";
        walk(pa->Rhs(), "     ");
    }
}

static void scan(const design* d, const char* side) {
    if (auto* v = d->AllPackages())
        for (auto* p : *v) listing("AllPkg", std::string(p->VpiName()), p, side);
    if (auto* v = d->TopPackages())
        for (auto* p : *v) listing("TopPkg", std::string(p->VpiName()), p, side);
    if (auto* v = d->AllModules())
        for (auto* m : *v) listing("AllMod", std::string(m->VpiDefName()), m, side);
}

int main(int argc, char** argv) {
    if (argc < 4) return 1;
    want = argv[3];
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    scan((const design*)((uhdm_handle*)ha[0])->object, "G");
    scan((const design*)((uhdm_handle*)hb[0])->object, "O");
    return 0;
}
