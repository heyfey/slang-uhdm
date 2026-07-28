// r9step: replay design::Compare step by step with ONE shared CompareContext,
// reporting which top-level vector (and which element index) first diverges.
// design::Compare reports only the outermost owner of the failing container,
// and its m_visited set means the SAME object compared twice is silently
// equal the second time — so a naive per-object diff can show nothing while
// the whole-design Compare returns 1.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

template <typename T>
static bool step(const char* tag, const std::vector<T*>* a,
                 const std::vector<T*>* b, CompareContext& c) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (sa != sb) {
        std::cout << tag << ": SIZE lhs=" << (a ? (int)sa : -1)
                  << " rhs=" << (b ? (int)sb : -1) << "\n";
        for (size_t i = 0; i < (sa > sb ? sa : sb) && i < 60; i++)
            std::cout << "    [" << i << "] "
                      << (a && i < sa ? nm((*a)[i]) : std::string("-")) << "  |  "
                      << (b && i < sb ? nm((*b)[i]) : std::string("-")) << "\n";
        return false;
    }
    for (size_t i = 0; i < sa; i++) {
        c.m_failedLhs = nullptr;
        c.m_failedRhs = nullptr;
        const BaseClass* la = (*a)[i];
        const BaseClass* lb = (*b)[i];
        int r = (la && lb) ? la->Compare(lb, &c) : (la ? 1 : (lb ? -1 : 0));
        if (r != 0) {
            std::cout << tag << "[" << i << "] r=" << r << " "
                      << nm((*a)[i]) << " vs " << nm((*b)[i]) << "\n";
            std::cout << "    failLhs " << nm(c.m_failedLhs) << "\n";
            std::cout << "    failRhs " << nm(c.m_failedRhs) << "\n";
            // A null-rhs failure names the LHS object a pointer accessor
            // returned; its fullname/parent chain is what identifies WHICH
            // slot on the golden side has no counterpart in ours.
            for (const BaseClass* p = c.m_failedLhs; p; p = p->VpiParent()) {
                std::cout << "      up: " << nm(p);
                if (auto* a = any_cast<const any*>(p))
                    (void)a;
                if (p->UhdmType() == uhdmref_typespec)
                    std::cout << " full='"
                              << ((const ref_typespec*)p)->VpiFullName()
                              << "' actual="
                              << nm(((const ref_typespec*)p)->Actual_typespec());
                std::cout << "\n";
            }
            return false;
        }
    }
    std::cout << tag << ": ok (" << sa << ")\n";
    return true;
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    CompareContext c;
    if (!step("AllPackages", da->AllPackages(), db->AllPackages(), c)) return 0;
    if (!step("TopPackages", da->TopPackages(), db->TopPackages(), c)) return 0;
    if (!step("AllClasses", da->AllClasses(), db->AllClasses(), c)) return 0;
    if (!step("AllInterfaces", da->AllInterfaces(), db->AllInterfaces(), c)) return 0;
    if (!step("AllUdps", da->AllUdps(), db->AllUdps(), c)) return 0;
    if (!step("AllPrograms", da->AllPrograms(), db->AllPrograms(), c)) return 0;
    if (!step("AllModules", da->AllModules(), db->AllModules(), c)) return 0;
    if (!step("Typespecs", da->Typespecs(), db->Typespecs(), c)) return 0;
    if (!step("LetDecls", da->Let_decls(), db->Let_decls(), c)) return 0;
    if (!step("TaskFuncs", da->Task_funcs(), db->Task_funcs(), c)) return 0;
    if (!step("Parameters", da->Parameters(), db->Parameters(), c)) return 0;
    if (!step("ParamAssigns", da->Param_assigns(), db->Param_assigns(), c)) return 0;
    if (!step("TopModules", da->TopModules(), db->TopModules(), c)) return 0;
    return 0;
}
