// r10scr8v: side-by-side VECTOR-SIZE + scalar-field census of ONE instance,
// selected by VpiFullName, across two databases.  `Compare` reports the
// CONTAINER (failLhs == failRhs == the instance itself) when a vector's SIZE
// differs or one of the instance's own scalar fields does — this probe names
// which one in a single command, instead of diffing two whole dumps.
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr8v.cpp -o /tmp/r10scr8_v \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <filesystem>
#include <iostream>
#include <string>
using namespace UHDM;

static const module_inst* find(Serializer& s, const std::string& fn) {
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmmodule_inst) continue;
        auto* m = (const module_inst*)o;
        if (std::string(m->VpiFullName()) == fn) return m;
    }
    return nullptr;
}

template <typename V>
static size_t sz(const V* v) {
    return v ? v->size() : (size_t)-1;
}

static void row(const char* n, size_t a, size_t b) {
    std::cout << (a == b ? "    " : "*** ") << n << " g=" << (long)a
              << " s=" << (long)b << "\n";
}

int main(int argc, char** argv) {
    if (argc < 4) {
        std::cerr << "usage: r10scr8v <golden.uhdm> <ours.uhdm> <fullname>\n";
        return 1;
    }
    Serializer g, o;
    g.Restore(std::filesystem::path(argv[1]));
    o.Restore(std::filesystem::path(argv[2]));
    const module_inst* a = find(g, argv[3]);
    const module_inst* b = find(o, argv[3]);
    if (!a || !b) {
        std::cerr << "not found: g=" << (void*)a << " s=" << (void*)b << "\n";
        return 2;
    }
#define ROW(F) row(#F, sz(a->F()), sz(b->F()))
    ROW(Ports); ROW(Interfaces); ROW(Interface_arrays); ROW(Process);
    ROW(Modules); ROW(Module_arrays); ROW(Gen_scope_arrays); ROW(Cont_assigns);
    ROW(Primitives); ROW(Primitive_arrays); ROW(Mod_paths); ROW(Tchks);
    ROW(Def_params); ROW(Io_decls); ROW(Alias_stmts); ROW(Clocking_blocks);
    ROW(Elab_tasks); ROW(Ref_modules); ROW(Gen_stmts);
    ROW(Programs); ROW(Program_arrays); ROW(Class_defns); ROW(Task_funcs);
    ROW(Nets); ROW(Array_nets); ROW(Spec_params); ROW(Assertions);
    ROW(Property_decls); ROW(Sequence_decls); ROW(Concurrent_assertions);
    ROW(Named_events); ROW(Named_event_arrays); ROW(Variables);
    ROW(Virtual_interface_vars); ROW(Logic_vars); ROW(Array_vars);
    ROW(Array_var_mems); ROW(Parameters); ROW(Param_assigns); ROW(Scopes);
    ROW(Typespecs); ROW(Instance_items); ROW(Let_decls); ROW(Attributes);
#undef ROW
    row("VpiIndex", (size_t)a->VpiIndex(), (size_t)b->VpiIndex());
    row("VpiTopModule", (size_t)a->VpiTopModule(), (size_t)b->VpiTopModule());
    row("VpiDefDecayTime", (size_t)a->VpiDefDecayTime(),
        (size_t)b->VpiDefDecayTime());
    std::cout << "    VpiDefName g='" << a->VpiDefName() << "' s='"
              << b->VpiDefName() << "'\n";
    std::cout << "    VpiEndLabel g='" << a->VpiEndLabel() << "' s='"
              << b->VpiEndLabel() << "'\n";
    row("Global_clocking", (size_t)!!a->Global_clocking(),
        (size_t)!!b->Global_clocking());
    row("Default_clocking", (size_t)!!a->Default_clocking(),
        (size_t)!!b->Default_clocking());
    row("Expr_dist", (size_t)!!a->Expr_dist(), (size_t)!!b->Expr_dist());
    row("Module_array", (size_t)!!a->Module_array(), (size_t)!!b->Module_array());
    row("Instance_array", (size_t)!!a->Instance_array(),
        (size_t)!!b->Instance_array());
    return 0;
}
