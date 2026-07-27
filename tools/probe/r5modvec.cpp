// module_inst container-vector localiser (r5modvec family).
//
// r3fail.cpp reports `failLhs=module_inst()` and prints the *instance*-level
// vectors, but a module_inst carries ~20 more of its own (Ports, Cont_assigns,
// Process, Modules, Gen_scope_arrays, Ref_modules, Primitives, ...), and when
// the mismatch is a NULL-vs-empty container form, BaseClass leaves failedRhs
// unset so r3fail cannot pair the two sides at all.
//
// This probe pairs modules by VpiDefName across the two designs (AllModules
// then TopModules) and prints EVERY differing vector side by side for the
// pairs that differ.  Usage:  r5modvec <golden.uhdm> <slang.uhdm> [defname]
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>
using namespace UHDM;

static std::string nm(const BaseClass* o) {
    if (!o) return "<null>";
    return std::string(UhdmName(o->UhdmType())) + "(" + std::string(o->VpiName()) +
           ")@" + std::to_string(o->VpiLineNo()) + ":" +
           std::to_string(o->VpiColumnNo());
}

static bool gDiff = false;

template <typename V>
static void row(const char* tag, const V* a, const V* b) {
    size_t sa = a ? a->size() : 0, sb = b ? b->size() : 0;
    bool nulla = !a, nullb = !b;
    // NOTE: SafeCompare treats null and EMPTY as equal (see BaseClass.h) --
    // only a size difference is cmp-relevant.
    if (sa == sb) return;
    gDiff = true;
    std::cout << "  DIFF " << tag << ": lhs=" << (nulla ? -1 : (int)sa)
              << " rhs=" << (nullb ? -1 : (int)sb) << "\n";
    size_t n = sa > sb ? sa : sb;
    for (size_t i = 0; i < n; i++) {
        std::cout << "        [" << i << "] "
                  << (a && i < sa ? nm((*a)[i]) : std::string("-")) << "  |  "
                  << (b && i < sb ? nm((*b)[i]) : std::string("-")) << "\n";
    }
}

#define SCAL(x)                                                              \
    if (a->x != b->x) {                                                      \
        gDiff = true;                                                        \
        std::cout << "  DIFF " #x " " << a->x << " / " << b->x << "\n";      \
    }

static void dumpMod(const module_inst* a, const module_inst* b) {
    // scalars, in module_inst/instance/scope Compare order
    SCAL(VpiName()) SCAL(VpiDefName()) SCAL(VpiArrayMember())
    SCAL(VpiCellInstance()) SCAL(VpiDefNetType()) SCAL(VpiDefDelayMode())
    SCAL(VpiProtected()) SCAL(VpiTimePrecision()) SCAL(VpiTimeUnit())
    SCAL(VpiUnconnDrive()) SCAL(VpiLibrary()) SCAL(VpiCell()) SCAL(VpiConfig())
    SCAL(VpiAutomatic()) SCAL(VpiTop()) SCAL(VpiIndex()) SCAL(VpiType())
    SCAL(VpiTopModule()) SCAL(VpiDefDecayTime()) SCAL(VpiEndLabel())
    auto ptr = [&](const char* t, const BaseClass* p, const BaseClass* q) {
        if (!!p != !!q) {
            gDiff = true;
            std::cout << "  DIFF " << t << " " << nm(p) << " / " << nm(q) << "\n";
        }
    };
    ptr("Global_clocking", a->Global_clocking(), b->Global_clocking());
    ptr("Default_clocking", a->Default_clocking(), b->Default_clocking());
    ptr("Expr_dist", a->Expr_dist(), b->Expr_dist());
    ptr("Module_array", a->Module_array(), b->Module_array());
    ptr("Instance_array", a->Instance_array(), b->Instance_array());
    ptr("Module_inst", a->Module_inst(), b->Module_inst());
    ptr("Instance", a->Instance(), b->Instance());
    // scope
    row("Typespecs", a->Typespecs(), b->Typespecs());
    row("Parameters", a->Parameters(), b->Parameters());
    row("ParamAssigns", a->Param_assigns(), b->Param_assigns());
    row("Variables", a->Variables(), b->Variables());
    row("ArrayVars", a->Array_vars(), b->Array_vars());
    row("LogicVars", a->Logic_vars(), b->Logic_vars());
    row("InstanceItems", a->Instance_items(), b->Instance_items());
    row("Scopes", a->Scopes(), b->Scopes());
    row("NamedEvents", a->Named_events(), b->Named_events());
    row("Attributes", a->Attributes(), b->Attributes());
    row("LetDecls", a->Let_decls(), b->Let_decls());
    row("PropertyDecls", a->Property_decls(), b->Property_decls());
    row("SequenceDecls", a->Sequence_decls(), b->Sequence_decls());
    row("ConcurrentAssertions", a->Concurrent_assertions(), b->Concurrent_assertions());
    row("VirtualInterfaceVars", a->Virtual_interface_vars(), b->Virtual_interface_vars());
    row("NamedEventArrays", a->Named_event_arrays(), b->Named_event_arrays());
    row("ArrayVarMems", a->Array_var_mems(), b->Array_var_mems());
    // instance
    row("Nets", a->Nets(), b->Nets());
    row("ArrayNets", a->Array_nets(), b->Array_nets());
    row("TaskFuncs", a->Task_funcs(), b->Task_funcs());
    row("ClassDefns", a->Class_defns(), b->Class_defns());
    row("SpecParams", a->Spec_params(), b->Spec_params());
    row("Assertions", a->Assertions(), b->Assertions());
    row("Programs", a->Programs(), b->Programs());
    row("ProgramArrays", a->Program_arrays(), b->Program_arrays());
    // module_inst
    row("Ports", a->Ports(), b->Ports());
    row("IoDecls", a->Io_decls(), b->Io_decls());
    row("ContAssigns", a->Cont_assigns(), b->Cont_assigns());
    row("Process", a->Process(), b->Process());
    row("Modules", a->Modules(), b->Modules());
    row("ModuleArrays", a->Module_arrays(), b->Module_arrays());
    row("RefModules", a->Ref_modules(), b->Ref_modules());
    row("Interfaces", a->Interfaces(), b->Interfaces());
    row("InterfaceArrays", a->Interface_arrays(), b->Interface_arrays());
    row("Primitives", a->Primitives(), b->Primitives());
    row("PrimitiveArrays", a->Primitive_arrays(), b->Primitive_arrays());
    row("GenScopeArrays", a->Gen_scope_arrays(), b->Gen_scope_arrays());
    row("GenStmts", a->Gen_stmts(), b->Gen_stmts());
    row("DefParams", a->Def_params(), b->Def_params());
    row("ModPaths", a->Mod_paths(), b->Mod_paths());
    row("Tchks", a->Tchks(), b->Tchks());
    row("AliasStmts", a->Alias_stmts(), b->Alias_stmts());
    row("ClockingBlocks", a->Clocking_blocks(), b->Clocking_blocks());
    row("ElabTasks", a->Elab_tasks(), b->Elab_tasks());
    if (a->VpiTop() != b->VpiTop())
        std::cout << "  DIFF VpiTop " << a->VpiTop() << "/" << b->VpiTop() << "\n";
}

static void index(const design* d, std::map<std::string, const module_inst*>& m,
                  std::vector<const module_inst*>& order) {
    std::function<void(const module_inst*)> add = [&](const module_inst* mi) {
        std::string k = std::string(mi->VpiDefName()) + "|" +
                        std::string(mi->VpiFullName()) + "|" +
                        std::to_string(mi->VpiTop());
        if (!m.emplace(k, mi).second) return;
        order.push_back(mi);
        if (mi->Modules())
            for (auto* c : *mi->Modules()) add(c);
        if (mi->Module_arrays())
            for (auto* ma : *mi->Module_arrays())
                if (ma->Modules())
                    for (auto* c : *ma->Modules()) add(c);
    };
    if (d->AllModules())
        for (auto* mi : *d->AllModules()) add(mi);
    if (d->TopModules())
        for (auto* mi : *d->TopModules()) add(mi);
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    std::string only = argc > 3 ? argv[3] : "";

    // Compare-driven view first: the object pair design::Compare actually
    // stopped on, with the FULL module_inst vector set.
    {
        CompareContext c;
        int r = da->Compare(db, &c);
        std::cout << "design r=" << r << "  failLhs " << nm(c.m_failedLhs)
                  << "  failRhs " << nm(c.m_failedRhs) << "\n";
        const BaseClass* x = c.m_failedLhs;
        const BaseClass* y = c.m_failedRhs;
        if (x && x->UhdmType() == uhdmmodule_array) {
            auto* p = (const module_array*)x;
            auto* q = (y && y->UhdmType() == uhdmmodule_array)
                          ? (const module_array*)y
                          : nullptr;
            std::cout << "-- module_array lhs name='" << p->VpiName()
                      << "' size=" << p->VpiSize() << " ranges="
                      << (p->Ranges() ? (int)p->Ranges()->size() : -1)
                      << " ports="
                      << (p->Ports() ? (int)p->Ports()->size() : -1)
                      << " modules="
                      << (p->Modules() ? (int)p->Modules()->size() : -1)
                      << " insts="
                      << (p->Instances() ? (int)p->Instances()->size() : -1)
                      << " ets=" << (p->Elem_typespec() ? 1 : 0) << "\n";
            if (q) {
                std::cout << "-- module_array rhs name='" << q->VpiName()
                          << "' size=" << q->VpiSize() << " ranges="
                          << (q->Ranges() ? (int)q->Ranges()->size() : -1)
                          << " ports="
                          << (q->Ports() ? (int)q->Ports()->size() : -1)
                          << " modules="
                          << (q->Modules() ? (int)q->Modules()->size() : -1)
                          << " insts="
                          << (q->Instances() ? (int)q->Instances()->size() : -1)
                          << " ets=" << (q->Elem_typespec() ? 1 : 0) << "\n";
                row("MA.Ranges", p->Ranges(), q->Ranges());
                row("MA.Ports", p->Ports(), q->Ports());
                row("MA.Modules", p->Modules(), q->Modules());
                row("MA.Instances", p->Instances(), q->Instances());
                row("MA.ParamAssigns", p->Param_assigns(), q->Param_assigns());
            }
        }
        if (x && y && x->UhdmType() == uhdmmodule_inst &&
            y->UhdmType() == uhdmmodule_inst) {
            std::cout << "-- failing pair: " << ((const module_inst*)x)->VpiFullName()
                      << " / " << ((const module_inst*)y)->VpiFullName() << "\n";
            dumpMod((const module_inst*)x, (const module_inst*)y);
        }
    }

    std::map<std::string, const module_inst*> ma, mb;
    std::vector<const module_inst*> oa, ob;
    index(da, ma, oa);
    index(db, mb, ob);

    for (auto* mi : oa) {
        std::string k = std::string(mi->VpiDefName()) + "|" +
                        std::string(mi->VpiFullName()) + "|" +
                        std::to_string(mi->VpiTop());
        if (!only.empty() && std::string(mi->VpiDefName()).find(only) ==
                                 std::string::npos)
            continue;
        auto it = mb.find(k);
        if (it == mb.end()) {
            std::cout << "== " << k << " : MISSING on rhs\n";
            gDiff = true;
            continue;
        }
        gDiff = false;
        std::cout.flush();
        std::string hdr = "== " + k + " (top=" + std::to_string(mi->VpiTop()) +
                          ")\n";
        // buffer: only print header when something differs
        std::streambuf* old = std::cout.rdbuf();
        std::ostringstream buf;
        std::cout.rdbuf(buf.rdbuf());
        dumpMod(mi, it->second);
        std::cout.rdbuf(old);
        if (gDiff) std::cout << hdr << buf.str();
    }
    for (auto* mi : ob) {
        std::string k = std::string(mi->VpiDefName()) + "|" +
                        std::string(mi->VpiFullName()) + "|" +
                        std::to_string(mi->VpiTop());
        if (ma.find(k) == ma.end())
            std::cout << "== " << k << " : EXTRA on rhs\n";
    }
    return 0;
}
