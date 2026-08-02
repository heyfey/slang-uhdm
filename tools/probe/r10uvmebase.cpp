// r10uvmebase: dump one package enum typespec's vpiBaseTypespec in full.
//   r10uvmebase <db.uhdm> <pkgname> <enum-typespec-name>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
    Serializer sa;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto* d = (design*)((uhdm_handle*)ha[0])->object;
    std::string pn = argv[2], tn = argv[3];
    auto scan = [&](const VectorOfpackage* pv) {
        if (!pv) return;
        for (auto* p : *pv) {
            if (p->VpiName() != pn || !p->Typespecs()) continue;
            for (auto* t : *p->Typespecs()) {
                if (t->VpiName() != tn) continue;
                auto* et = any_cast<enum_typespec*>(t);
                if (!et) continue;
                std::cout << "enum " << t->VpiName() << " @" << t->VpiLineNo() << ":"
                          << t->VpiColumnNo() << "\n";
                auto* br = et->Base_typespec();
                if (!br) { std::cout << "  base ref: <none>\n"; continue; }
                auto* b = br->Actual_typespec();
                if (!b) { std::cout << "  base: <null>\n"; continue; }
                std::cout << "  base " << UhdmName(b->UhdmType()) << " '" << b->VpiName()
                          << "' @" << b->VpiLineNo() << ":" << b->VpiColumnNo() << "-"
                          << b->VpiEndLineNo() << ":" << b->VpiEndColumnNo() << "\n";
                if (auto* bt = any_cast<bit_typespec*>(b)) {
                    std::cout << "    vec=" << bt->VpiVector() << " signed=" << bt->VpiSigned()
                              << " ranges=" << (bt->Ranges() ? (int)bt->Ranges()->size() : -1)
                              << "\n";
                    auto show = [&](const char* n, const ref_typespec* r) {
                        std::cout << "    " << n << ": ";
                        if (!r) { std::cout << "<none>\n"; return; }
                        auto* a = r->Actual_typespec();
                        std::cout << "ref -> "
                                  << (a ? UhdmName(a->UhdmType()) : "<null>") << "("
                                  << (a ? a->VpiName() : "") << ")@"
                                  << (a ? a->VpiLineNo() : 0) << ":"
                                  << (a ? a->VpiColumnNo() : 0) << "\n";
                    };
                    show("Bit_typespec", bt->Bit_typespec());
                    show("Typespec", bt->Typespec());
                    std::cout << "    Left=" << (bt->Left_expr() ? "yes" : "no")
                              << " Right=" << (bt->Right_expr() ? "yes" : "no") << "\n";
                    if (bt->Ranges())
                        for (auto* r : *bt->Ranges())
                            std::cout << "    range @" << r->VpiLineNo() << ":"
                                      << r->VpiColumnNo() << " L="
                                      << (r->Left_expr() ? UhdmName(r->Left_expr()->UhdmType()) : "-")
                                      << " R="
                                      << (r->Right_expr() ? UhdmName(r->Right_expr()->UhdmType()) : "-")
                                      << "\n";
                }
            }
        }
    };
    scan(d->TopPackages());
    scan(d->AllPackages());
    return 0;
}
