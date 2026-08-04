// r10fsv2c: LOCALIZING compare.  uhdm-cmp runs one whole-design Compare with a
// single visited memo, so its failLhs/failRhs names the first unequal pair in
// ONE traversal and says nothing about where in the design that traversal was.
// This runs Compare on each top-level design list ENTRY separately, with a
// FRESH CompareContext each time, and prints the per-entry verdict — so a
// failure lands on a named package / module / view instead of on a bare
// constant.  Then, for a failing instance, it re-runs per sub-list
// (typespecs / parameters / param_assigns / task_funcs / variables / modules).
//   g++ -std=c++17 -I$HOME/.local/include r10fsv2c.cpp -o r10fsv2c \
//       -L$HOME/.local/lib64 -luhdm -lcapnp -lkj
//   r10fsv2c <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static void report(const std::string& tag, const BaseClass* a,
                   const BaseClass* b) {
    if (!a && !b) return;
    if (!a || !b) {
        std::cout << tag << ": ONE SIDE NULL (" << (a ? "rhs" : "lhs")
                  << " missing)\n";
        return;
    }
    CompareContext ctx;
    int32_t r = a->Compare(b, &ctx);
    if (r == 0) {
        std::cout << tag << ": EQUAL\n";
        return;
    }
    std::cout << tag << ": DIFF r=" << r << "\n";
    if (ctx.m_failedLhs)
        std::cout << "  failLhs: " << UhdmName(ctx.m_failedLhs->UhdmType())
                  << " id" << ctx.m_failedLhs->UhdmId() << " '"
                  << ctx.m_failedLhs->VpiName() << "' line "
                  << ctx.m_failedLhs->VpiLineNo() << ":"
                  << ctx.m_failedLhs->VpiColumnNo() << "\n";
    else
        std::cout << "  failLhs: <null>\n";
    if (ctx.m_failedRhs)
        std::cout << "  failRhs: " << UhdmName(ctx.m_failedRhs->UhdmType())
                  << " id" << ctx.m_failedRhs->UhdmId() << " '"
                  << ctx.m_failedRhs->VpiName() << "' line "
                  << ctx.m_failedRhs->VpiLineNo() << ":"
                  << ctx.m_failedRhs->VpiColumnNo() << "\n";
    else
        std::cout << "  failRhs: <null>\n";
}

template <typename V>
static void reportVec(const std::string& tag, const V* a, const V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    if (na != nb) {
        std::cout << tag << ": SIZE " << na << " vs " << nb << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++) {
        std::string nm((*a)[i]->VpiName());
        report(tag + "[" + std::to_string(i) + "]" +
                   (nm.empty() ? "" : "(" + nm + ")"),
               (*a)[i], (*b)[i]);
    }
}

static void doInst(const std::string& tag, const instance* a,
                   const instance* b) {
    reportVec(tag + ".Typespecs", a->Typespecs(), b->Typespecs());
    reportVec(tag + ".Parameters", a->Parameters(), b->Parameters());
    reportVec(tag + ".Param_assigns", a->Param_assigns(), b->Param_assigns());
    reportVec(tag + ".Task_funcs", a->Task_funcs(), b->Task_funcs());
    reportVec(tag + ".Variables", a->Variables(), b->Variables());
}

// The VpiParent chain of an object, outermost last — the only cheap way to
// say WHERE in the design a whole-design Compare stopped.
static void chain(const char* lbl, const BaseClass* o) {
    std::cout << lbl << " chain:\n";
    for (int i = 0; o && i < 14; i++) {
        std::cout << "    " << UhdmName(o->UhdmType()) << " id" << o->UhdmId()
                  << " '" << o->VpiName() << "' " << o->VpiLineNo() << ":"
                  << o->VpiColumnNo() << "\n";
        o = o->VpiParent();
    }
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    {
        CompareContext ctx;
        if (da->Compare(db, &ctx) != 0) {
            std::cout << "=== WHOLE-DESIGN first failure ===\n";
            if (ctx.m_failedLhs) chain("LHS", ctx.m_failedLhs);
            else std::cout << "LHS <null>\n";
            if (ctx.m_failedRhs) chain("RHS", ctx.m_failedRhs);
            else std::cout << "RHS <null>\n";
        }
        else
            std::cout << "=== WHOLE-DESIGN EQUAL ===\n";
    }
    reportVec("AllPackages", da->AllPackages(), db->AllPackages());
    reportVec("TopPackages", da->TopPackages(), db->TopPackages());
    reportVec("AllModules", da->AllModules(), db->AllModules());
    reportVec("TopModules", da->TopModules(), db->TopModules());
    // Drill into every instance pair by sub-list.
    auto drill = [&](const char* lbl, const VectorOfpackage* pa,
                     const VectorOfpackage* pb) {
        if (!pa || !pb || pa->size() != pb->size()) return;
        for (size_t i = 0; i < pa->size(); i++)
            doInst(std::string(lbl) + "[" + std::string((*pa)[i]->VpiName()) +
                       "]",
                   (*pa)[i], (*pb)[i]);
    };
    drill("ALLPKG", da->AllPackages(), db->AllPackages());
    drill("TOPPKG", da->TopPackages(), db->TopPackages());
    auto drillM = [&](const char* lbl, const VectorOfmodule_inst* pa,
                      const VectorOfmodule_inst* pb) {
        if (!pa || !pb || pa->size() != pb->size()) return;
        for (size_t i = 0; i < pa->size(); i++)
            doInst(std::string(lbl) + "[" + std::string((*pa)[i]->VpiName()) +
                       "]",
                   (*pa)[i], (*pb)[i]);
    };
    drillM("ALLMOD", da->AllModules(), db->AllModules());
    drillM("TOPMOD", da->TopModules(), db->TopModules());
    return 0;
}
