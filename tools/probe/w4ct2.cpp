// Localiser: per-container, per-task_func, per-typespec Compare breakdown.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string chain(const BaseClass* n) {
    std::string out;
    int guard = 0;
    for (const BaseClass* p = n; p && guard < 24;
         p = (const BaseClass*)p->VpiParent(), guard++) {
        if (!out.empty()) out += " < ";
        out += UhdmName(p->UhdmType());
        std::string nm2(p->VpiName());
        if (!nm2.empty()) out += "(" + nm2 + ")";
        if (p->VpiLineNo())
            out += "@" + std::to_string(p->VpiLineNo()) + ":" +
                   std::to_string(p->VpiColumnNo());
    }
    return out;
}

static int show(const std::string& nm, const BaseClass* x, const BaseClass* y) {
    CompareContext c;
    int r = (x && y) ? x->Compare(y, &c) : ((x && !y) ? 1 : ((!x && y) ? -1 : 0));
    if (!r) return 0;
    std::cout << nm << " r=" << r << "\n";
    if (c.m_failedLhs) std::cout << "  lhs: " << chain(c.m_failedLhs) << "\n";
    if (c.m_failedRhs) std::cout << "  rhs: " << chain(c.m_failedRhs) << "\n";
    return r;
}

template <typename V>
static void doInst(const std::string& tag, V* a, V* b) {
    if (!a || !b) return;
    for (size_t i = 0; i < a->size() && i < b->size(); i++) {
        auto* pa = (*a)[i];
        auto* pb = (*b)[i];
        std::string t0 = tag + "[" + std::to_string(i) + ":" +
                         std::string(pa->VpiName()) + "]";
        show(t0, pa, pb);
        auto* ta = pa->Typespecs();
        auto* tb = pb->Typespecs();
        if (ta && tb && ta->size() == tb->size())
            for (size_t j = 0; j < ta->size(); j++)
                show(t0 + ".ts[" + std::string((*ta)[j]->VpiName()) + "]",
                     (*ta)[j], (*tb)[j]);
        auto* fa = pa->Task_funcs();
        auto* fb = pb->Task_funcs();
        if (fa && fb && fa->size() == fb->size())
            for (size_t j = 0; j < fa->size(); j++)
                show(t0 + ".tf[" + std::string((*fa)[j]->VpiName()) + "]",
                     (*fa)[j], (*fb)[j]);
        auto elem = [&](const std::string& w, auto* xa, auto* xb) {
            if (!xa || !xb || xa->size() != xb->size()) {
                if ((xa ? xa->size() : 0) != (xb ? xb->size() : 0))
                    std::cout << t0 << "." << w << " SIZE "
                              << (xa ? (int)xa->size() : -1) << " vs "
                              << (xb ? (int)xb->size() : -1) << "\n";
                return;
            }
            for (size_t j = 0; j < xa->size(); j++)
                show(t0 + "." + w + "[" + std::to_string(j) + ":" +
                         std::string((*xa)[j]->VpiName()) + "]",
                     (*xa)[j], (*xb)[j]);
        };
        elem("var", pa->Variables(), pb->Variables());
        elem("param", pa->Parameters(), pb->Parameters());
        elem("passign", pa->Param_assigns(), pb->Param_assigns());
        elem("net", pa->Nets(), pb->Nets());
        elem("item", pa->Instance_items(), pb->Instance_items());
        elem("cls", pa->Class_defns(), pb->Class_defns());
        elem("scope", pa->Scopes(), pb->Scopes());
        elem("attr", pa->Attributes(), pb->Attributes());
        elem("arrvar", pa->Array_vars(), pb->Array_vars());
        elem("logicvar", pa->Logic_vars(), pb->Logic_vars());
    }
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::cout << "DESIGN r=" << (show("DESIGN", da, db) ? "fail" : "0") << "\n";
    doInst("Pkg", da->AllPackages(), db->AllPackages());
    doInst("TopPkg", da->TopPackages(), db->TopPackages());
    doInst("AllMod", da->AllModules(), db->AllModules());
    doInst("TopMod", da->TopModules(), db->TopModules());
    return 0;
}
