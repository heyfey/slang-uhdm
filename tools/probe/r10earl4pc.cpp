// r10earl4pc: per-param_assign FRESH-CONTEXT compare inside one named package
// listing, plus the Rhs's own scalars/links.  The design-wide census names one
// head per entry; this one says WHICH row of a package listing fails and what
// the two Rhs objects actually hold.
// Usage: r10earl4pc <a.uhdm> <b.uhdm> <PkgName> [top|all]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string at(const BaseClass* n) {
    if (!n) return "<null>";
    std::string s = std::string(UhdmName(n->UhdmType())) + " '" +
                    std::string(n->VpiName()) + "' " +
                    std::to_string(n->VpiLineNo()) + ":" +
                    std::to_string(n->VpiColumnNo());
    if (n->UhdmType() == uhdmconstant) {
        auto* c = (const constant*)n;
        s += " {ct=" + std::to_string(c->VpiConstType()) +
             " sz=" + std::to_string(c->VpiSize()) + " dec=" +
             std::string(c->VpiDecompile()) + "}";
    }
    std::string f(n->VpiFile());
    auto sl = f.rfind('/');
    s += " [" + (sl == std::string::npos ? f : f.substr(sl + 1)) + "]";
    int i = 0;
    for (const any* p = n->VpiParent(); p && i++ < 5; p = p->VpiParent()) {
        std::string pf(p->VpiFile());
        auto psl = pf.rfind('/');
        s += "\n            ^ " + std::string(UhdmName(p->UhdmType())) + " '" +
             std::string(p->VpiName()) + "' " +
             (psl == std::string::npos ? pf : pf.substr(psl + 1)) + ":" +
             std::to_string(p->VpiLineNo());
        if (auto* in = any_cast<const instance*>(p))
            s += " {top=" + std::to_string((int)in->VpiTop()) + " uid=" +
                 std::to_string(in->UhdmId()) + "}";
    }
    return s;
}

static std::string more(const any* r) {
    if (!r) return "<null>";
    std::string s = at(r);
    if (r->UhdmType() == uhdmref_obj) {
        auto* ro = (const ref_obj*)r;
        s += " full='" + std::string(ro->VpiFullName()) + "' actual=" +
             at(ro->Actual_group()) + " ts=" +
             (ro->Typespec() ? at(ro->Typespec()->Actual_typespec())
                             : std::string("<none>"));
    }
    else if (auto* e = any_cast<const expr*>(r)) {
        s += " ts=" + (e->Typespec()
                           ? at(e->Typespec()->Actual_typespec())
                           : std::string("<none>"));
    }
    return s;
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
    std::cout << "param_assigns " << (va ? va->size() : 0) << " vs "
              << (vb ? vb->size() : 0) << "\n";
    size_t n = va && vb ? std::min(va->size(), vb->size()) : 0;
    for (size_t i = 0; i < n; i++) {
        CompareContext ctx;
        int r = (*va)[i]->Compare((*vb)[i], &ctx);
        std::cout << (r ? "  DIFF " : "  ok   ") << i << " ["
                  << ((*va)[i]->Lhs() ? (*va)[i]->Lhs()->VpiName() : "?")
                  << "]";
        if (r) {
            std::cout << " r=" << r << "\n        failLhs " << at(ctx.m_failedLhs)
                      << "\n        failRhs " << at(ctx.m_failedRhs)
                      << "\n        A.rhs " << more((*va)[i]->Rhs())
                      << "\n        B.rhs " << more((*vb)[i]->Rhs());
        }
        std::cout << "\n";
    }
    // Typespecs vector too (the hmac_pkg shape).
    auto* ta = pa->Typespecs();
    auto* tb = pb->Typespecs();
    std::cout << "typespecs " << (ta ? ta->size() : 0) << " vs "
              << (tb ? tb->size() : 0) << "\n";
    if (ta && tb)
        for (size_t i = 0; i < std::min(ta->size(), tb->size()); i++) {
            CompareContext ctx;
            int r = (*ta)[i]->Compare((*tb)[i], &ctx);
            std::cout << (r ? "  DIFF " : "  ok   ") << i << " " << at((*ta)[i])
                      << " vs " << at((*tb)[i]);
            if (r)
                std::cout << "\n        failLhs " << at(ctx.m_failedLhs)
                          << "\n        failRhs " << at(ctx.m_failedRhs);
            std::cout << "\n";
        }
    return 0;
}
