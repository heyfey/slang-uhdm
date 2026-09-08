// r10uvm206 — ct206vec.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the
// sole judge.  LHS is ALWAYS golden (Surelog), RHS is ALWAYS ours.
//
// Prints, for one named instance in AllModules (the DEF view) and in
// TopModules (the ELABORATED view), the SIZE of every listing `module_inst::
// Compare` walks, in the generated Compare's own order
// (~/git-repos/UHDM/build/generated/src/module_inst.cpp).  A vector that is
// NULL on one side and non-empty on the other is exactly the shape the vector
// SafeCompare overload reports as `LHS: <null>` / `RHS: <owner>`
// (~/.local/include/uhdm/BaseClass.h:202-224) — this tool NAMES the field that
// cmp only points at.
//
// build: g++ -O2 -std=c++17 ct206vec.cpp -I ~/.local/include \
//            -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct206vec
// usage: ct206vec <db.uhdm> <instance VpiName>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <cstdio>
#include <string>
#include <vector>

using namespace UHDM;

#define SZ(f) printf("  %-24s %s\n", #f, m->f() ? std::to_string(m->f()->size()).c_str() : "<null>")

static void dumpMod(const char* view, const module_inst* m) {
    printf("%s %s (%s) id:%u\n", view, std::string(m->VpiName()).c_str(),
           std::string(m->VpiDefName()).c_str(), (unsigned)m->UhdmId());
    SZ(Ports); SZ(Nets); SZ(Array_nets); SZ(Cont_assigns); SZ(Process);
    SZ(Interfaces); SZ(Interface_arrays); SZ(Ref_modules); SZ(Modules);
    SZ(Primitives); SZ(Primitive_arrays); SZ(Gen_scope_arrays); SZ(Programs);
    SZ(Program_arrays); SZ(Def_params); SZ(Io_decls); SZ(Alias_stmts);
    SZ(Clocking_blocks); SZ(Variables); SZ(Assertions); SZ(Named_events);
    SZ(Named_event_arrays); SZ(Virtual_interface_vars); SZ(Parameters);
    SZ(Param_assigns); SZ(Instance_items); SZ(Scopes); SZ(Typespecs);
    SZ(Class_defns); SZ(Task_funcs); SZ(Property_decls); SZ(Sequence_decls);
    SZ(Concurrent_assertions); SZ(Let_decls); SZ(Attributes);
}

int main(int argc, char** argv) {
    if (argc < 3) { fprintf(stderr, "usage: ct206vec <db.uhdm> <name>\n"); return 2; }
    std::string want(argv[2]);
    Serializer s;
    auto designs = s.Restore(std::string(argv[1]));
    if (designs.empty()) { fprintf(stderr, "FATAL: no design in %s\n", argv[1]); return 3; }
    for (auto dh : designs) {
        const design* d = (const design*)((const uhdm_handle*)dh)->object;
        if (d->AllModules())
            for (auto* m : *d->AllModules())
                if (std::string(m->VpiName()) == want) dumpMod("DEF", m);
        if (d->TopModules())
            for (auto* m : *d->TopModules())
                if (std::string(m->VpiName()) == want) dumpMod("ELAB", m);
    }
    return 0;
}
