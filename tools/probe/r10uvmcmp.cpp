// r10uvmcmp: narrow a whole-design Compare failure to the sub-object that
// fails, by running Compare on each design-level list element separately.
//   r10uvmcmp <a.uhdm> <b.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string brief(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo());
}

template <typename V>
static void run(const char* tag, const V* a, const V* b) {
    if (!a || !b || a->size() != b->size()) {
        std::cout << tag << ": size " << (a ? (long)a->size() : -1) << " vs "
                  << (b ? (long)b->size() : -1) << "\n";
        return;
    }
    for (size_t i = 0; i < a->size(); i++) {
        CompareContext ctx;
        if ((*a)[i]->Compare((*b)[i], &ctx) != 0) {
            std::cout << tag << "[" << i << "] " << brief((*a)[i]) << " FAILS\n";
            std::cout << "   failLhs=" << brief(ctx.m_failedLhs)
                      << "  failRhs=" << brief(ctx.m_failedRhs) << "\n";
            if (ctx.m_failedLhs)
                std::cout << "   lhsParent=" << brief(ctx.m_failedLhs->VpiParent()) << "\n";
            if (ctx.m_failedRhs)
                std::cout << "   rhsParent=" << brief(ctx.m_failedRhs->VpiParent()) << "\n";
        }
    }
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    if (da->AllPackages() && db->AllPackages() &&
        da->AllPackages()->size() == db->AllPackages()->size())
        for (size_t i = 0; i < da->AllPackages()->size(); i++) {
            auto* a = (*da->AllPackages())[i];
            auto* b = (*db->AllPackages())[i];
            std::string t = "pkg[" + std::string(a->VpiName()) + "]";
            run((t + ".Variables").c_str(), a->Variables(), b->Variables());
            run((t + ".Nets").c_str(), a->Nets(), b->Nets());
            run((t + ".Typespecs").c_str(), a->Typespecs(), b->Typespecs());
            run((t + ".Parameters").c_str(), a->Parameters(), b->Parameters());
            run((t + ".Param_assigns").c_str(), a->Param_assigns(), b->Param_assigns());
            run((t + ".Task_funcs").c_str(), a->Task_funcs(), b->Task_funcs());
            run((t + ".Class_defns").c_str(), a->Class_defns(), b->Class_defns());
        }
    // TOP-package class_defns: the package classes live only here.
    if (da->TopPackages() && db->TopPackages() &&
        da->TopPackages()->size() == db->TopPackages()->size())
        for (size_t i = 0; i < da->TopPackages()->size(); i++) {
            auto* pa = (*da->TopPackages())[i];
            auto* pb = (*db->TopPackages())[i];
            if (!pa->Class_defns() || !pb->Class_defns() ||
                pa->Class_defns()->size() != pb->Class_defns()->size())
                continue;
            for (size_t j = 0; j < pa->Class_defns()->size(); j++) {
                auto* ca = (*pa->Class_defns())[j];
                auto* cb = (*pb->Class_defns())[j];
                std::string t = "cls[" + std::string(ca->VpiName()) + "]";
                run((t + ".Variables").c_str(), ca->Variables(), cb->Variables());
                run((t + ".Task_funcs").c_str(), ca->Task_funcs(), cb->Task_funcs());
                run((t + ".Typespecs").c_str(), ca->Typespecs(), cb->Typespecs());
                run((t + ".Parameters").c_str(), ca->Parameters(), cb->Parameters());
                run((t + ".Param_assigns").c_str(), ca->Param_assigns(), cb->Param_assigns());
                run((t + ".Deriveds").c_str(), ca->Deriveds(), cb->Deriveds());
                run((t + ".Constraints").c_str(), ca->Constraints(), cb->Constraints());
                run((t + ".Named_events").c_str(), ca->Named_events(), cb->Named_events());
            }
        }
    run("AllPackages", da->AllPackages(), db->AllPackages());
    run("TopPackages", da->TopPackages(), db->TopPackages());
    run("AllClasses", da->AllClasses(), db->AllClasses());
    run("AllModules", da->AllModules(), db->AllModules());
    run("TopModules", da->TopModules(), db->TopModules());
    run("Typespecs", da->Typespecs(), db->Typespecs());
    run("Task_funcs", da->Task_funcs(), db->Task_funcs());
    std::cout << "done\n";
    return 0;
}
