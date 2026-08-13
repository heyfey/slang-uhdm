// r10sd4 — IS IT THE VECTOR ARM ON THE PACKAGE ITSELF?  Null OUR package's own
// vectors, one at a time, and watch the head.
//
// `ct4mut2` eliminated the SINGULAR arm by mutation: nulling each of OUR 6818
// `vpiInstance` slots that hold the failing package changed nothing.  `ct4ref`
// showed those slots plus `design.uhdmtopPackages[]` are the ONLY references to
// it anywhere in our database.  That leaves exactly one reading:
//
//     VECTOR arm — the failing package IS the object being compared
//     (`m_failedRhs == rhs_obj`, the CONTAINER), and one of its own vectors is
//     NULL in golden and NON-EMPTY in ours.
//
// This tool tests that reading the only way that settles it: null OUR package's
// vector, re-run the whole-design `Compare`, restore, and report which vector's
// removal moves the head.  Every vector `package::Compare` walks is covered —
// scope's 17 (generated/src/scope.cpp:335-351) then instance's 8 + 2 singulars
// (generated/src/instance.cpp:332-341) — and BOTH package views are tested,
// because the two views are different objects and only one of them is the RHS.
//
// build: g++ -O2 -std=c++17 ct4vec.cpp -I ~/.local/include \
//          -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct4vec
// usage: ct4vec <golden.uhdm> <ours.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <uhdm/vhpi_user.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
#include <vector>

using namespace UHDM;

static design *DA, *DB;

static std::string ident(const BaseClass* p) {
    if (!p) return "<null>";
    std::string s = UhdmName(p->UhdmType());
    std::string nm(p->VpiName());
    if (!nm.empty()) s += "(" + nm + ")";
    s += "@" + std::to_string(p->VpiLineNo()) + ":" +
         std::to_string(p->VpiColumnNo()) + "-" +
         std::to_string(p->VpiEndLineNo()) + ":" +
         std::to_string(p->VpiEndColumnNo());
    return s;
}
struct Out {
    int r = 0;
    const BaseClass* lhs = nullptr;
    const BaseClass* rhs = nullptr;
    size_t vis = 0;
    bool operator==(const Out& o) const {
        return r == o.r && lhs == o.lhs && rhs == o.rhs && vis == o.vis;
    }
    std::string str() const {
        return "r=" + std::to_string(r) + " lhs=" + ident(lhs) +
               " rhs=" + ident(rhs) + " visited=" + std::to_string(vis);
    }
};
static Out run() {
    CompareContext c;
    Out o;
    o.r = DA->Compare(DB, &c);
    o.lhs = c.m_failedLhs;
    o.rhs = c.m_failedRhs;
    o.vis = c.m_visited.size();
    return o;
}

static Out g_base;
#define TRY(OBJ, NAME)                                                        \
    do {                                                                      \
        auto* keep = (OBJ)->NAME();                                           \
        if (keep == nullptr) {                                                \
            printf("  %-24s %8s %s\n", #NAME, "NULL", "(already null)");      \
        } else {                                                              \
            (OBJ)->NAME(nullptr);                                             \
            Out o = run();                                                    \
            (OBJ)->NAME(keep);                                                \
            printf("  %-24s %8ld %s\n", #NAME, (long)keep->size(),            \
                   (o == g_base) ? "unchanged"                                \
                                 : ("<== MOVES THE HEAD: " + o.str()).c_str());\
        }                                                                     \
    } while (0)

static void probe(const char* tag, package* p) {
    if (!p) return;
    printf("\n=== %s %s vpiTop=%d\n", tag, ident(p).c_str(), (int)p->VpiTop());
    TRY(p, Property_decls); TRY(p, Sequence_decls); TRY(p, Concurrent_assertions);
    TRY(p, Named_events); TRY(p, Named_event_arrays); TRY(p, Variables);
    TRY(p, Virtual_interface_vars); TRY(p, Logic_vars); TRY(p, Array_vars);
    TRY(p, Array_var_mems); TRY(p, Parameters); TRY(p, Param_assigns);
    TRY(p, Scopes); TRY(p, Typespecs); TRY(p, Instance_items); TRY(p, Let_decls);
    TRY(p, Attributes); TRY(p, Programs); TRY(p, Program_arrays);
    TRY(p, Class_defns); TRY(p, Task_funcs); TRY(p, Nets); TRY(p, Array_nets);
    TRY(p, Spec_params); TRY(p, Assertions);
}

int main(int argc, char** argv) {
    if (argc < 3) { std::cerr << "usage: ct4vec <golden> <ours>\n"; return 2; }
    static Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    DA = (design*)((uhdm_handle*)ha[0])->object;
    DB = (design*)((uhdm_handle*)hb[0])->object;
    g_base = run();
    std::cout << "[B] BASELINE " << g_base.str() << "\n";
    if (!g_base.rhs) return 1;

    package* target = nullptr;
    if (DB->TopPackages())
        for (auto* p : *DB->TopPackages())
            if ((const BaseClass*)p == g_base.rhs) target = p;
    if (DB->AllPackages())
        for (auto* p : *DB->AllPackages())
            if ((const BaseClass*)p == g_base.rhs) target = p;
    std::cout << "[T] the failing RHS IS one of our design's package objects: "
              << (target ? "YES" : "NO") << "\n";
    probe("OURS RHS", target);

    // the other view, as a control: nulling ITS vectors must NOT move the head
    if (DB->AllPackages())
        for (auto* p : *DB->AllPackages())
            if (p != target && p->VpiName() == g_base.rhs->VpiName())
                probe("OURS other-view CONTROL", p);
    Out ctl = run();
    std::cout << "\n[C] RESTORE CONTROL (must equal BASELINE): " << ctl.str()
              << (ctl == g_base ? "   OK" : "   *** MISMATCH ***") << "\n";
    return 0;
}
