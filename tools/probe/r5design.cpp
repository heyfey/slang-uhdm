// Design-level container localiser: when design::Compare reports
// `r=1 failLhs=package(X) failRhs=<null>`, the mismatch is a SIZE difference
// in one of the design's own vectors (AllPackages / TopPackages / AllModules
// / TopModules / ...), not anything inside the named package.  Print every
// design vector side by side so the missing/extra entry is named directly.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo());
}

template <typename V>
static void row(const char* tag, const V* a, const V* b, bool always) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    if (!always && sa == sb && (!a) == (!b)) return;
    std::cout << "  " << (sa == sb ? "same " : "DIFF ") << tag
              << ": lhs=" << (a ? (int)sa : -1) << " rhs=" << (b ? (int)sb : -1)
              << "\n";
    if (sa == sb && !always) return;
    size_t n = sa > sb ? sa : sb;
    for (size_t i = 0; i < n; i++)
        std::cout << "        [" << i << "] "
                  << (a && i < sa ? nm((*a)[i]) : std::string("-")) << "  |  "
                  << (b && i < sb ? nm((*b)[i]) : std::string("-")) << "\n";
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    bool always = argc > 3;
    row("AllPackages", da->AllPackages(), db->AllPackages(), always);
    row("TopPackages", da->TopPackages(), db->TopPackages(), always);
    row("AllModules", da->AllModules(), db->AllModules(), always);
    row("TopModules", da->TopModules(), db->TopModules(), always);
    row("AllInterfaces", da->AllInterfaces(), db->AllInterfaces(), always);
    row("AllPrograms", da->AllPrograms(), db->AllPrograms(), always);
    row("AllClasses", da->AllClasses(), db->AllClasses(), always);
    row("AllUdps", da->AllUdps(), db->AllUdps(), always);
    row("TypedefTypespecs", da->Typespecs(), db->Typespecs(), always);
    row("TaskFuncs", da->Task_funcs(), db->Task_funcs(), always);
    row("Parameters", da->Parameters(), db->Parameters(), always);
    row("ParamAssigns", da->Param_assigns(), db->Param_assigns(), always);
    return 0;
}
