#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;
int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    bool decomp = getenv("CMP_DECOMPILE") != nullptr;
    // Container path of a node: walk VpiParent up to the design root,
    // printing type(name@line:col) segments innermost-first.
    auto chain = [&](const BaseClass* n) {
        std::string out;
        int guard = 0;
        for (const BaseClass* p = n; p && guard < 24;
             p = (const BaseClass*)p->VpiParent(), guard++) {
            if (!out.empty())
                out += " < ";
            out += UhdmName(p->UhdmType());
            std::string nm2(p->VpiName());
            if (!nm2.empty())
                out += "(" + nm2 + ")";
            if (p->VpiLineNo())
                out += "@" + std::to_string(p->VpiLineNo()) + ":" +
                       std::to_string(p->VpiColumnNo());
        }
        return out;
    };
    auto show = [&](const std::string& nm, const BaseClass* x, const BaseClass* y) {
        CompareContext c;
        int r = (x && y) ? x->Compare(y, &c) : ((x && !y) ? 1 : ((!x && y) ? -1 : 0));
        std::cout << nm << " r=" << r;
        if (r && c.m_failedLhs)
            std::cout << " failLhs=t" << (int)c.m_failedLhs->UhdmType() << "("
                      << UhdmName(c.m_failedLhs->UhdmType()) << ")@"
                      << c.m_failedLhs->VpiLineNo() << ":"
                      << c.m_failedLhs->VpiColumnNo()
                      << " nm=" << c.m_failedLhs->VpiName();
        if (r && !c.m_failedRhs)
            std::cout << " rhsNULL";
        else if (r && c.m_failedRhs)
            std::cout << " failRhs=t" << (int)c.m_failedRhs->UhdmType() << "("
                      << UhdmName(c.m_failedRhs->UhdmType()) << ")";
        std::cout << "\n";
        if (r && c.m_failedLhs)
            std::cout << "  lhsPath: " << chain(c.m_failedLhs) << "\n";
        if (r && c.m_failedRhs)
            std::cout << "  rhsPath: " << chain(c.m_failedRhs) << "\n";
        if (r && decomp) {
            if (c.m_failedLhs)
                std::cerr << "  LHS:\n" << decompile((BaseClass*)c.m_failedLhs);
            if (c.m_failedRhs)
                std::cerr << "  RHS:\n" << decompile((BaseClass*)c.m_failedRhs);
        }
        return r;
    };
    // AUTHORITATIVE whole-design Compare — matches uhdm-cmp (which does
    // design->Compare, covering allModules/topModules/packages/interfaces and
    // ordering). DESIGN r=0 <=> uhdm-cmp PASS_CMP.
    show("DESIGN", da, db);
    // Diagnostic per-module / per-package / per-interface breakdown to LOCALIZE
    // a design-level failure the module views alone would miss.
    auto vec = [&](auto* v) { return v ? (int)v->size() : -1; };
    std::cout << "AllModules " << vec(da->AllModules()) << " vs "
              << vec(db->AllModules()) << " | TopModules "
              << vec(da->TopModules()) << " vs " << vec(db->TopModules())
              << " | AllPackages " << vec(da->AllPackages()) << " vs "
              << vec(db->AllPackages()) << " | AllInterfaces "
              << vec(da->AllInterfaces()) << " vs " << vec(db->AllInterfaces())
              << "\n";
    auto walk = [&](const std::string& tag, auto* va, auto* vb) {
        if (!va || !vb) return;
        for (size_t i = 0; i < va->size() && i < vb->size(); i++)
            show(tag + "[" + std::to_string(i) + "]", (*va)[i], (*vb)[i]);
    };
    walk("AllMod", da->AllModules(), db->AllModules());
    walk("TopMod", da->TopModules(), db->TopModules());
    walk("Pkg", da->AllPackages(), db->AllPackages());
    walk("TopPkg", da->TopPackages(), db->TopPackages());
    walk("Iface", da->AllInterfaces(), db->AllInterfaces());
    if (da->TopPackages() || db->TopPackages())
        std::cout << "TopPackages " << vec(da->TopPackages()) << " vs "
                  << vec(db->TopPackages()) << "\n";
    return 0;
}
