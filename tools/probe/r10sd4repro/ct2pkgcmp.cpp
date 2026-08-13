// r10sd2 — DESCEND INTO ONE PACKAGE PAIR, FIELD BY FIELD, ELEMENT BY ELEMENT.
//
// `design.AllPackages[i]` reports `LHS:<null> RHS: package uvm_pkg`, which by
// BaseClass.h's two SafeCompare arms is EITHER
//   (a) a vector on the uvm_pkg OBJECT that is NULL in golden and non-empty in
//       ours   (vector arm: m_failedRhs = the CONTAINER), OR
//   (b) a SINGULAR field, anywhere in the subtree, that is NULL in golden and
//       points AT uvm_pkg in ours   (singular arm: m_failedRhs = the CHILD).
// ct2pkgv.cpp rules (a) out by censusing every vector `package::Compare` walks.
// This tool finds (b)'s owner: it re-runs each of the package's own vectors with
// a FRESH CompareContext per element (no m_visited masking) and prints the first
// failing element of each field with both parent chains.
//
// build: g++ -O2 -std=c++17 ct2pkgcmp.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct2pkgcmp
// usage: ct2pkgcmp <golden.uhdm> <ours.uhdm> <pkgname> <all|top> [maxreport]
#include <uhdm/uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>

using namespace UHDM;

static int g_max = 6;

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 24;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm(p->VpiName());
        if (!nm.empty()) out += "(" + nm + ")";
        if (p->VpiLineNo())
            out += "@" + std::to_string(p->VpiLineNo()) + ":" +
                   std::to_string(p->VpiColumnNo());
    }
    return out;
}

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo());
    return s;
}

template <typename V>
static void vecfield(const std::string& tag, V* a, V* b) {
    int na = a ? (int)a->size() : -1, nb = b ? (int)b->size() : -1;
    if (na != nb) {
        std::cout << "  " << tag << ": golden=" << na << " ours=" << nb
                  << "   <-- SIZE/NULL MISMATCH\n";
        return;
    }
    if (!a) return;
    int shown = 0, failed = 0;
    for (size_t i = 0; i < a->size(); i++) {
        CompareContext c;
        const BaseClass* x = (*a)[i];
        const BaseClass* y = (*b)[i];
        if (x->Compare(y, &c) == 0) continue;
        failed++;
        if (shown++ >= g_max) continue;
        std::cout << "  FAIL " << tag << "[" << i << "] elem golden=" << ident(x)
                  << " ours=" << ident(y) << "\n";
        std::cout << "        failedLhs=" << ident(c.m_failedLhs)
                  << "  failedRhs=" << ident(c.m_failedRhs) << "\n";
        if (!c.m_failedLhs && c.m_failedRhs)
            std::cout << "        *** LHS:<null> ARM *** rhsPath: "
                      << chain(c.m_failedRhs) << "\n";
    }
    if (failed)
        std::cout << "  " << tag << ": " << failed << " / " << a->size()
                  << " elements FAIL\n";
}

int main(int argc, char** argv) {
    if (argc < 5) {
        std::cerr << "usage: ct2pkgcmp <golden.uhdm> <ours.uhdm> <pkg> <all|top>"
                     " [maxreport]\n";
        return 2;
    }
    std::string want = argv[3], which = argv[4];
    if (argc > 5) g_max = atoi(argv[5]);
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    VectorOfpackage* va = which == "top" ? da->TopPackages() : da->AllPackages();
    VectorOfpackage* vb = which == "top" ? db->TopPackages() : db->AllPackages();
    if (!va || !vb) { std::cerr << "NO_VECTOR\n"; return 3; }
    const package* pa = nullptr; package* pb = nullptr;
    for (size_t i = 0; i < va->size(); i++)
        if (std::string((*va)[i]->VpiName()) == want) { pa = (*va)[i]; break; }
    for (size_t i = 0; i < vb->size(); i++)
        if (std::string((*vb)[i]->VpiName()) == want) { pb = (*vb)[i]; break; }
    if (!pa || !pb) { std::cerr << "PKG_NOT_FOUND " << want << "\n"; return 3; }
    CompareContext c0;
    int r0 = pa->Compare(pb, &c0);
    std::cout << which << "/" << want << " whole-package Compare r=" << r0
              << " failedLhs=" << ident(c0.m_failedLhs)
              << " failedRhs=" << ident(c0.m_failedRhs) << "\n";

    // scope::Compare order
    vecfield("Property_decls", pa->Property_decls(), pb->Property_decls());
    vecfield("Sequence_decls", pa->Sequence_decls(), pb->Sequence_decls());
    vecfield("Concurrent_assertions", pa->Concurrent_assertions(),
             pb->Concurrent_assertions());
    vecfield("Named_events", pa->Named_events(), pb->Named_events());
    vecfield("Named_event_arrays", pa->Named_event_arrays(),
             pb->Named_event_arrays());
    vecfield("Variables", pa->Variables(), pb->Variables());
    vecfield("Virtual_interface_vars", pa->Virtual_interface_vars(),
             pb->Virtual_interface_vars());
    vecfield("Logic_vars", pa->Logic_vars(), pb->Logic_vars());
    vecfield("Array_vars", pa->Array_vars(), pb->Array_vars());
    vecfield("Array_var_mems", pa->Array_var_mems(), pb->Array_var_mems());
    vecfield("Parameters", pa->Parameters(), pb->Parameters());
    vecfield("Param_assigns", pa->Param_assigns(), pb->Param_assigns());
    vecfield("Scopes", pa->Scopes(), pb->Scopes());
    vecfield("Typespecs", pa->Typespecs(), pb->Typespecs());
    vecfield("Instance_items", pa->Instance_items(), pb->Instance_items());
    vecfield("Let_decls", pa->Let_decls(), pb->Let_decls());
    vecfield("Attributes", pa->Attributes(), pb->Attributes());
    // instance::Compare order
    vecfield("Programs", pa->Programs(), pb->Programs());
    vecfield("Program_arrays", pa->Program_arrays(), pb->Program_arrays());
    vecfield("Class_defns", pa->Class_defns(), pb->Class_defns());
    vecfield("Task_funcs", pa->Task_funcs(), pb->Task_funcs());
    vecfield("Nets", pa->Nets(), pb->Nets());
    vecfield("Array_nets", pa->Array_nets(), pb->Array_nets());
    vecfield("Spec_params", pa->Spec_params(), pb->Spec_params());
    vecfield("Assertions", pa->Assertions(), pb->Assertions());
    // SafeCompare is protected; the singular arms are re-implemented here with
    // the SAME three cases BaseClass.h:186-199 uses.
    auto single = [](const std::string& tag, const BaseClass* x,
                     const BaseClass* y) {
        if (!x && !y) return;
        if (x && y) {
            CompareContext c;
            if (x->Compare(y, &c) != 0)
                std::cout << "  FAIL " << tag << " failedLhs="
                          << ident(c.m_failedLhs) << " failedRhs="
                          << ident(c.m_failedRhs) << "\n";
            return;
        }
        std::cout << "  FAIL " << tag << " golden=" << ident(x)
                  << " ours=" << ident(y)
                  << (x ? "   (RHS:<null> arm)" : "   (LHS:<null> arm)") << "\n";
    };
    single("Module_inst", pa->Module_inst(), pb->Module_inst());
    single("Instance", pa->Instance(), pb->Instance());
    return 0;
}
