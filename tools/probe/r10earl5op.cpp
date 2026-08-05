// r10earl5op: print the WHOLE Rhs expression tree of one param_assign row in a
// named package listing, on both sides, with every ref_typespec-valued field
// spelled out.  CompareContext names a PARENTLESS ref_typespec as failLhs and
// stops; typespec::Compare recurses Instance(), so a package's typespec heads
// are really its param_assign heads.  This is the projection that says WHICH
// node under the assignment-pattern operation carries the ts ref.
// Usage: r10earl5op <a.uhdm> <b.uhdm> <PkgName> [top|all] [paramIndex]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string rt(const ref_typespec* r) {
    if (!r) return "<null>";
    const typespec* a = r->Actual_typespec();
    return "rts'" + std::string(r->VpiName()) + "'@" +
           std::to_string(r->VpiLineNo()) + ":" +
           std::to_string(r->VpiColumnNo()) +
           (r->VpiParent() ? "" : "(PARENTLESS)") + "->" +
           (a ? std::string(UhdmName(a->UhdmType())) + "'" +
                    std::string(a->VpiName()) + "'@" + std::to_string(a->VpiLineNo())
              : std::string("<null>"));
}

static void walk(const any* n, const std::string& ind) {
    if (!n) { std::cout << ind << "<null>\n"; return; }
    std::cout << ind << UhdmName(n->UhdmType()) << " '" << n->VpiName() << "' "
              << n->VpiLineNo() << ":" << n->VpiColumnNo();
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        std::cout << " {ct=" << c->VpiConstType() << " sz=" << c->VpiSize()
                  << " dec='" << c->VpiDecompile() << "' val='" << c->VpiValue()
                  << "'}";
    }
    if (n->UhdmType() == uhdmoperation)
        std::cout << " op=" << ((const operation*)n)->VpiOpType();
    if (auto* e = any_cast<const expr*>(n)) std::cout << " ts=" << rt(e->Typespec());
    if (n->UhdmType() == uhdmref_obj) {
        auto* r = (const ref_obj*)n;
        std::cout << " full='" << r->VpiFullName() << "' actual="
                  << (r->Actual_group() ? UhdmName(r->Actual_group()->UhdmType())
                                        : "<null>");
    }
    std::cout << "\n";
    if (n->UhdmType() == uhdmoperation) {
        auto* ops = ((const operation*)n)->Operands();
        if (ops)
            for (auto* o : *ops) walk(o, ind + "  ");
    }
    else if (n->UhdmType() == uhdmtagged_pattern) {
        auto* tp = (const tagged_pattern*)n;
        std::cout << ind << "  .name ts=" << rt(tp->Typespec()) << "\n";
        walk(tp->Pattern(), ind + "  ");
    }
}

static const package* find(const design* d, const std::string& nm, bool top) {
    auto* v = top ? d->TopPackages() : d->AllPackages();
    if (v)
        for (auto* p : *v)
            if (std::string(p->VpiName()) == nm) return p;
    return nullptr;
}

int main(int argc, char** argv) {
    if (argc < 4) return 1;
    bool top = argc > 4 && std::string(argv[4]) == "top";
    long only = argc > 5 ? std::stol(argv[5]) : -1;
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    if (ha.empty() || hb.empty()) return 2;
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    const package* pa = find(da, argv[3], top);
    const package* pb = find(db, argv[3], top);
    if (!pa || !pb) { std::cout << "package not found\n"; return 3; }
    auto* va = pa->Param_assigns();
    auto* vb = pb->Param_assigns();
    if (!va || !vb) return 4;
    for (size_t i = 0; i < std::min(va->size(), vb->size()); i++) {
        if (only >= 0 && (long)i != only) continue;
        CompareContext ctx;
        int r = (*va)[i]->Compare((*vb)[i], &ctx);
        std::cout << (r ? "DIFF " : "ok   ") << i << " ["
                  << ((*va)[i]->Lhs() ? (*va)[i]->Lhs()->VpiName() : "?") << "]\n";
        std::cout << "  --- A\n";
        walk((*va)[i]->Rhs(), "  ");
        std::cout << "  --- B\n";
        walk((*vb)[i]->Rhs(), "  ");
    }
    return 0;
}
