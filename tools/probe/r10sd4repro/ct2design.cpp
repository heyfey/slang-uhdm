// r10uvm67 — WHICH FIELD OF THE DESIGN FAILS, and at which ELEMENT?
//
// `uhdm-cmp` and `cmptool` both print the DEEPEST failing pair of a whole-design
// Compare, and that is not enough to name the SLOT: this pass's head printed
// `constant@410:30 < param_assign@410:11 < package(uvm_pkg)` while BOTH package
// views compared EQUAL, which is only possible if the design reaches that object
// through some OTHER field.  This tool compares the design's own vectors field
// by field, element by element, and prints the first failing element of each —
// so the slot is READ, not inferred.
//
// build: g++ -O2 -std=c++17 ct67design.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct67design
// usage: ct67design <golden.uhdm> <ours.uhdm>          (LHS ALWAYS GOLDEN)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <string>

using namespace UHDM;

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 24;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty())
            out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty())
            out += "(" + nm + ")";
        if (p->VpiLineNo())
            out += "@" + std::to_string(p->VpiLineNo()) + ":" +
                   std::to_string(p->VpiColumnNo());
    }
    return out;
}

static void one(const std::string& tag, const BaseClass* x, const BaseClass* y) {
    CompareContext c;
    int r = (x && y) ? x->Compare(y, &c) : ((x && !y) ? 1 : ((!x && y) ? -1 : 0));
    if (r == 0)
        return;
    std::cout << "  FAIL " << tag << " r=" << r;
    if (c.m_failedLhs)
        std::cout << " lhs=" << UhdmName(c.m_failedLhs->UhdmType()) << "@"
                  << c.m_failedLhs->VpiLineNo() << ":"
                  << c.m_failedLhs->VpiColumnNo()
                  << " nm=" << c.m_failedLhs->VpiName();
    if (c.m_failedLhs && !c.m_failedRhs)
        std::cout << " rhsNULL";
    else if (c.m_failedRhs)
        std::cout << " rhs=" << UhdmName(c.m_failedRhs->UhdmType()) << "@"
                  << c.m_failedRhs->VpiLineNo() << ":"
                  << c.m_failedRhs->VpiColumnNo();
    std::cout << "\n";
    if (c.m_failedLhs)
        std::cout << "    lhsPath: " << chain(c.m_failedLhs) << "\n";
    if (c.m_failedRhs)
        std::cout << "    rhsPath: " << chain(c.m_failedRhs) << "\n";
}

template <typename V>
static void vecfield(const std::string& tag, V* a, V* b) {
    int na = a ? (int)a->size() : -1, nb = b ? (int)b->size() : -1;
    std::cout << tag << ": golden=" << na << " ours=" << nb
              << (na != nb ? "   <-- SIZE MISMATCH" : "") << "\n";
    if (!a)
        return;
    for (size_t i = 0; i < a->size(); i++) {
        const BaseClass* x = (*a)[i];
        const BaseClass* y = (b && i < b->size()) ? (*b)[i] : nullptr;
        one(tag + "[" + std::to_string(i) + "]", x, y);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        std::cerr << "usage: ct67design <golden.uhdm> <ours.uhdm>\n";
        return 2;
    }
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::cout << "LHS(golden)=" << argv[1] << "\nRHS(ours)  =" << argv[2] << "\n";
    CompareContext c0;
    int rd = da->Compare(db, &c0);
    std::cout << "DESIGN r=" << rd;
    if (c0.m_failedLhs)
        std::cout << " lhs=" << UhdmName(c0.m_failedLhs->UhdmType()) << "@"
                  << c0.m_failedLhs->VpiLineNo() << ":"
                  << c0.m_failedLhs->VpiColumnNo();
    if (c0.m_failedLhs && !c0.m_failedRhs)
        std::cout << " rhsNULL";
    std::cout << "\n";
    if (c0.m_failedLhs)
        std::cout << "  lhsPath: " << chain(c0.m_failedLhs) << "\n";

    vecfield("design.Param_assigns", da->Param_assigns(), db->Param_assigns());
    vecfield("design.Parameters", da->Parameters(), db->Parameters());
    vecfield("design.Typespecs", da->Typespecs(), db->Typespecs());
    vecfield("design.Task_funcs", da->Task_funcs(), db->Task_funcs());
    vecfield("design.AllPackages", da->AllPackages(), db->AllPackages());
    vecfield("design.TopPackages", da->TopPackages(), db->TopPackages());
    vecfield("design.AllModules", da->AllModules(), db->AllModules());
    vecfield("design.TopModules", da->TopModules(), db->TopModules());
    vecfield("design.AllClasses", da->AllClasses(), db->AllClasses());
    vecfield("design.AllInterfaces", da->AllInterfaces(), db->AllInterfaces());
    vecfield("design.AllPrograms", da->AllPrograms(), db->AllPrograms());
    vecfield("design.AllUdps", da->AllUdps(), db->AllUdps());
    vecfield("design.Let_decls", da->Let_decls(), db->Let_decls());
    return 0;
}
