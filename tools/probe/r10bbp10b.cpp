// r10bbp10b: FULL scope/instance slot drill for a named package or module
// view.  r10fsv2c only drills five scope slots (Typespecs / Parameters /
// Param_assigns / Task_funcs / Variables); when every one of those is EQUAL
// but the whole-design Compare still fails inside that instance, the failing
// slot is one of the OTHER slots scope::Compare and instance::Compare walk.
// This drills every one of them, each with a FRESH CompareContext.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10bbp10b.cpp -o /tmp/r10bbp10bq \
//       -I$HOME/.local/include $HOME/.local/lib64/libuhdm.a \
//       $HOME/.local/lib64/libcapnp.a $HOME/.local/lib64/libkj.a -lpthread
// Usage: r10bbp10bq <golden.uhdm> <ours.uhdm> [view-substring]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static std::string want;

static std::string at(const BaseClass* n) {
    if (!n) return "<null>";
    return std::string(UhdmName(n->UhdmType())) + " id" +
           std::to_string(n->UhdmId()) + " '" + std::string(n->VpiName()) +
           "' " + std::to_string(n->VpiLineNo()) + ":" +
           std::to_string(n->VpiColumnNo());
}

static void rep(const std::string& tag, const BaseClass* a,
                const BaseClass* b) {
    if (!a && !b) return;
    if (!a || !b) {
        std::cout << tag << ": ONE SIDE NULL golden=" << (a ? "obj" : "null")
                  << " ours=" << (b ? "obj" : "null") << "\n";
        return;
    }
    CompareContext ctx;
    if (a->Compare(b, &ctx) == 0) return;  // only print failures
    std::cout << tag << ": DIFF\n    failLhs " << at(ctx.m_failedLhs)
              << "\n    failRhs " << at(ctx.m_failedRhs) << "\n";
}

template <typename V>
static void repVec(const std::string& tag, const V* a, const V* b) {
    size_t na = a ? a->size() : 0, nb = b ? b->size() : 0;
    if (na != nb) {
        std::cout << tag << ": SIZE " << na << " vs " << nb << "\n";
        return;
    }
    for (size_t i = 0; i < na; i++) {
        std::string nm((*a)[i]->VpiName());
        rep(tag + "[" + std::to_string(i) + "]" +
                (nm.empty() ? "" : "(" + nm + ")"),
            (*a)[i], (*b)[i]);
    }
}

static void drill(const std::string& tag, const instance* a,
                  const instance* b) {
    // scope slots, in scope::Compare order
    repVec(tag + ".Property_decls", a->Property_decls(), b->Property_decls());
    repVec(tag + ".Sequence_decls", a->Sequence_decls(), b->Sequence_decls());
    repVec(tag + ".Concurrent_assertions", a->Concurrent_assertions(),
           b->Concurrent_assertions());
    repVec(tag + ".Named_events", a->Named_events(), b->Named_events());
    repVec(tag + ".Named_event_arrays", a->Named_event_arrays(),
           b->Named_event_arrays());
    repVec(tag + ".Variables", a->Variables(), b->Variables());
    repVec(tag + ".Virtual_interface_vars", a->Virtual_interface_vars(),
           b->Virtual_interface_vars());
    repVec(tag + ".Logic_vars", a->Logic_vars(), b->Logic_vars());
    repVec(tag + ".Array_vars", a->Array_vars(), b->Array_vars());
    repVec(tag + ".Array_var_mems", a->Array_var_mems(), b->Array_var_mems());
    repVec(tag + ".Parameters", a->Parameters(), b->Parameters());
    repVec(tag + ".Param_assigns", a->Param_assigns(), b->Param_assigns());
    repVec(tag + ".Scopes", a->Scopes(), b->Scopes());
    repVec(tag + ".Typespecs", a->Typespecs(), b->Typespecs());
    repVec(tag + ".Instance_items", a->Instance_items(), b->Instance_items());
    repVec(tag + ".Let_decls", a->Let_decls(), b->Let_decls());
    repVec(tag + ".Attributes", a->Attributes(), b->Attributes());
    // instance slots
    repVec(tag + ".Programs", a->Programs(), b->Programs());
    repVec(tag + ".Program_arrays", a->Program_arrays(), b->Program_arrays());
    repVec(tag + ".Class_defns", a->Class_defns(), b->Class_defns());
    repVec(tag + ".Task_funcs", a->Task_funcs(), b->Task_funcs());
    repVec(tag + ".Nets", a->Nets(), b->Nets());
    repVec(tag + ".Array_nets", a->Array_nets(), b->Array_nets());
    repVec(tag + ".Spec_params", a->Spec_params(), b->Spec_params());
    repVec(tag + ".Assertions", a->Assertions(), b->Assertions());
    rep(tag + ".Instance", a->Instance(), b->Instance());
    rep(tag + ".Module_inst", a->Module_inst(), b->Module_inst());
}

template <typename V>
static void doList(const std::string& lbl, const V* pa, const V* pb) {
    if (!pa || !pb) return;
    if (pa->size() != pb->size()) {
        std::cout << lbl << ": SIZE " << pa->size() << " vs " << pb->size()
                  << "\n";
        return;
    }
    for (size_t i = 0; i < pa->size(); i++) {
        std::string vw(lbl + "[" + std::string((*pa)[i]->VpiName()) + "]");
        if (!want.empty() && vw.find(want) == std::string::npos) continue;
        drill(vw, (*pa)[i], (*pb)[i]);
    }
}

int main(int argc, char** argv) {
    if (argc < 3) return 1;
    if (argc > 3) want = argv[3];
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    const design* da = (const design*)((uhdm_handle*)ha[0])->object;
    const design* db = (const design*)((uhdm_handle*)hb[0])->object;
    doList("ALLPKG", da->AllPackages(), db->AllPackages());
    doList("TOPPKG", da->TopPackages(), db->TopPackages());
    doList("ALLMOD", da->AllModules(), db->AllModules());
    doList("TOPMOD", da->TopModules(), db->TopModules());
    std::cout << "== done\n";
    return 0;
}
