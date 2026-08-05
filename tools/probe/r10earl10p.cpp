// r10earl10p: the Parameters() and Param_assigns() VECTORS of one def-listing
// module, side by side.  An "r=1 failLhs=parameter 'X' ^ module_inst" head is
// a vector SIZE mismatch on the instance itself; this names which entries are
// missing and in what order.
// Usage: r10earl10p <a.uhdm> <b.uhdm> <defNameSubstring>
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
    if (n->UhdmType() == uhdmref_obj)
        std::cout << " actual="
                  << (((const ref_obj*)n)->Actual_group()
                          ? UhdmName(((const ref_obj*)n)->Actual_group()->UhdmType())
                          : "<null>");
    if (auto* e = any_cast<const expr*>(n))
        if (auto* r = e->Typespec()) {
            auto* a = r->Actual_typespec();
            std::cout << " ts=" << (a ? UhdmName(a->UhdmType()) : "<null>") << "'"
                      << (a ? a->VpiName() : "") << "'";
            if (a && a->UhdmType() == uhdmint_typespec) {
                auto* ce = ((const int_typespec*)a)->Cast_to_expr();
                std::cout << " cast2="
                          << (ce ? std::string(UhdmName(ce->UhdmType())) + "'" +
                                       std::string(ce->VpiName()) + "'" +
                                       (ce->UhdmType() == uhdmref_obj
                                            ? (((const ref_obj*)ce)->Actual_group()
                                                   ? "->BOUND"
                                                   : "->null")
                                            : "")
                                 : "<null>");
            }
        }
    std::cout << "\n";
    if (n->UhdmType() == uhdmoperation)
        if (auto* ops = ((const operation*)n)->Operands())
            for (auto* o : *ops) walk(o, ind + "  ");
}

static void one(const design* d, const char* side, const std::string& f) {
    auto* am = d->AllModules();
    if (!am) return;
    for (auto* m : *am) {
        if (std::string(m->VpiDefName()).find(f) == std::string::npos) continue;
        std::cout << "[" << side << "] " << m->VpiDefName() << " top="
                  << (int)m->VpiTop() << "\n";
        std::cout << "   Parameters:";
        if (auto* v = m->Parameters())
            for (auto* p : *v)
                std::cout << " " << p->VpiName() << "(" << UhdmName(p->UhdmType())
                          << "@" << p->VpiLineNo() << ")";
        std::cout << "\n";
        if (auto* v = m->Parameters())
            for (auto* p : *v) {
                std::cout << "   PARAM " << p->VpiName() << " ";
                walk(p, "");
            }
        if (auto* v = m->Param_assigns())
            for (auto* p : *v) {
                std::cout << "   PA " << (p->Lhs() ? p->Lhs()->VpiName() : "?")
                          << "\n";
                walk(p->Rhs(), "     ");
            }
    }
}

int main(int argc, char** argv) {
    if (argc < 4) return 1;
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    one((const design*)((uhdm_handle*)ha[0])->object, "G", argv[3]);
    one((const design*)((uhdm_handle*)hb[0])->object, "O", argv[3]);
    return 0;
}
