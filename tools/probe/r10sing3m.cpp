// r10sing3: module/interface/package vector localiser.
// When uhdm-cmp says `LHS: <module_inst X>  RHS: <null>` the mismatch is a
// vector that is non-null and non-empty on one side and nullptr on the other
// (BaseClass::SafeCompare's vector overload).  uhdm-dump does not visit every
// such vector, so the dump can be byte-identical while the compare fails.
// Prints every vector of every module/interface/package side by side.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

template <typename V>
static void row(const std::string& tag, const V* a, const V* b) {
    int sa = a ? (int)a->size() : -1, sb = b ? (int)b->size() : -1;
    static const bool verbose = getenv("R10VERB") != nullptr;
    if (sa == sb) {
        if (verbose && sa > 0)
            std::cout << "  same " << tag << ": " << sa << "\n";
        return;
    }
    // null-vs-empty is NOT a Compare failure; only null-vs-nonempty is.
    bool fail = !((sa <= 0) && (sb <= 0));
    std::cout << (fail ? "  DIFF " : "  nul  ") << tag << ": lhs=" << sa
              << " rhs=" << sb << "\n";
    if (!fail) return;
    int n = sa > sb ? sa : sb;
    for (int i = 0; i < n; i++) {
        std::cout << "        [" << i << "] ";
        if (a && i < sa)
            std::cout << UhdmName((*a)[i]->UhdmType()) << "('"
                      << (*a)[i]->VpiName() << "')@" << (*a)[i]->VpiLineNo();
        else
            std::cout << "-";
        std::cout << "  |  ";
        if (b && i < sb)
            std::cout << UhdmName((*b)[i]->UhdmType()) << "('"
                      << (*b)[i]->VpiName() << "')@" << (*b)[i]->VpiLineNo();
        else
            std::cout << "-";
        std::cout << "\n";
    }
}

static void scopeRows(const std::string& t, const scope* a, const scope* b) {
    row(t + ".Typespecs", a->Typespecs(), b->Typespecs());
    row(t + ".Variables", a->Variables(), b->Variables());
    row(t + ".Scopes", a->Scopes(), b->Scopes());
    row(t + ".Attributes", a->Attributes(), b->Attributes());
    row(t + ".PropertyDecls", a->Property_decls(), b->Property_decls());
    row(t + ".SequenceDecls", a->Sequence_decls(), b->Sequence_decls());
    row(t + ".ConcurrentAssertions", a->Concurrent_assertions(),
        b->Concurrent_assertions());
    row(t + ".NamedEvents", a->Named_events(), b->Named_events());
    row(t + ".NamedEventArrays", a->Named_event_arrays(),
        b->Named_event_arrays());
    row(t + ".VirtualInterfaceVars", a->Virtual_interface_vars(),
        b->Virtual_interface_vars());
    row(t + ".LogicVars", a->Logic_vars(), b->Logic_vars());
    row(t + ".ArrayVars", a->Array_vars(), b->Array_vars());
    row(t + ".ArrayVarMems", a->Array_var_mems(), b->Array_var_mems());
    row(t + ".LetDecls", a->Let_decls(), b->Let_decls());
    row(t + ".Parameters", a->Parameters(), b->Parameters());
    row(t + ".ParamAssigns", a->Param_assigns(), b->Param_assigns());
    row(t + ".InstanceItems", a->Instance_items(), b->Instance_items());
}

static void instRows(const std::string& t, const instance* a,
                     const instance* b) {
    row(t + ".Nets", a->Nets(), b->Nets());
    row(t + ".ArrayNets", a->Array_nets(), b->Array_nets());
    row(t + ".TaskFuncs", a->Task_funcs(), b->Task_funcs());
    row(t + ".SpecParams", a->Spec_params(), b->Spec_params());
    row(t + ".Assertions", a->Assertions(), b->Assertions());
    row(t + ".ClassDefns", a->Class_defns(), b->Class_defns());
    row(t + ".Programs", a->Programs(), b->Programs());
    row(t + ".ProgramArrays", a->Program_arrays(), b->Program_arrays());
    scopeRows(t, a, b);
}

static void modRows(const std::string& t, const module_inst* a,
                    const module_inst* b) {
    row(t + ".Ports", a->Ports(), b->Ports());
    row(t + ".Interfaces", a->Interfaces(), b->Interfaces());
    row(t + ".InterfaceArrays", a->Interface_arrays(), b->Interface_arrays());
    row(t + ".Process", a->Process(), b->Process());
    row(t + ".Modules", a->Modules(), b->Modules());
    row(t + ".ModuleArrays", a->Module_arrays(), b->Module_arrays());
    row(t + ".GenScopeArrays", a->Gen_scope_arrays(), b->Gen_scope_arrays());
    row(t + ".ContAssigns", a->Cont_assigns(), b->Cont_assigns());
    row(t + ".Primitives", a->Primitives(), b->Primitives());
    row(t + ".PrimitiveArrays", a->Primitive_arrays(), b->Primitive_arrays());
    row(t + ".ModPaths", a->Mod_paths(), b->Mod_paths());
    row(t + ".Tchks", a->Tchks(), b->Tchks());
    row(t + ".DefParams", a->Def_params(), b->Def_params());
    row(t + ".IoDecls", a->Io_decls(), b->Io_decls());
    row(t + ".AliasStmts", a->Alias_stmts(), b->Alias_stmts());
    row(t + ".ClockingBlocks", a->Clocking_blocks(), b->Clocking_blocks());
    row(t + ".ElabTasks", a->Elab_tasks(), b->Elab_tasks());
    row(t + ".RefModules", a->Ref_modules(), b->Ref_modules());
    row(t + ".GenStmts", a->Gen_stmts(), b->Gen_stmts());
    instRows(t, a, b);
}

static void ifRows(const std::string& t, const interface_inst* a,
                   const interface_inst* b) {
    row(t + ".InterfaceTfDecls", a->Interface_tf_decls(),
        b->Interface_tf_decls());
    row(t + ".Modports", a->Modports(), b->Modports());
    row(t + ".ModPaths", a->Mod_paths(), b->Mod_paths());
    row(t + ".ContAssigns", a->Cont_assigns(), b->Cont_assigns());
    row(t + ".ClockingBlocks", a->Clocking_blocks(), b->Clocking_blocks());
    row(t + ".Interfaces", a->Interfaces(), b->Interfaces());
    row(t + ".InterfaceArrays", a->Interface_arrays(), b->Interface_arrays());
    row(t + ".Process", a->Process(), b->Process());
    row(t + ".Ports", a->Ports(), b->Ports());
    row(t + ".GenScopeArrays", a->Gen_scope_arrays(), b->Gen_scope_arrays());
    row(t + ".ElabTasks", a->Elab_tasks(), b->Elab_tasks());
    row(t + ".GenStmts", a->Gen_stmts(), b->Gen_stmts());
    instRows(t, a, b);
}

template <typename V, typename F>
static void walk(const char* tag, const V* a, const V* b, F fn) {
    if (!a || !b) return;
    size_t n = a->size() < b->size() ? a->size() : b->size();
    for (size_t i = 0; i < n; i++) {
        std::string t = std::string(tag) + "[" + std::to_string(i) + ":" +
                        std::string((*a)[i]->VpiName()) + "@" +
                        std::to_string((*a)[i]->VpiLineNo()) + "]";
        fn(t, (*a)[i], (*b)[i]);
    }
}

int main(int argc, char** argv) {
    Serializer sa, sb;
    auto ha = sa.Restore(std::filesystem::path(argv[1]));
    auto hb = sb.Restore(std::filesystem::path(argv[2]));
    auto* da = (design*)((uhdm_handle*)ha[0])->object;
    auto* db = (design*)((uhdm_handle*)hb[0])->object;
    walk("AllMod", da->AllModules(), db->AllModules(), modRows);
    walk("TopMod", da->TopModules(), db->TopModules(), modRows);
    walk("AllIf", da->AllInterfaces(), db->AllInterfaces(), ifRows);
    walk("AllPkg", da->AllPackages(), db->AllPackages(),
         [](const std::string& t, const package* a, const package* b) {
             instRows(t, a, b);
         });
    return 0;
}
