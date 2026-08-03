// r10scr8c: WHOLE-DESIGN container census.  One sorted line per
// (module_inst fullname + defname, vector name, size), so `diff golden ours`
// names every container whose SIZE disagrees — the exact class of failure
// Compare reports as `failLhs == failRhs == <the instance>` and that a dump
// diff buries.  Both views are covered (a def listing and its elaborated
// instances have different fullnames).
// Build:
//   g++ -std=c++20 -O1 tools/probe/r10scr8c.cpp -o /tmp/r10scr8_c \
//       -I$HOME/.local/include -L$HOME/.local/lib64 -luhdm -lcapnp -lkj -lfmt
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>

#include <algorithm>
#include <filesystem>
#include <iostream>
#include <string>
#include <vector>
using namespace UHDM;

int main(int argc, char** argv) {
    if (argc < 2) return 1;
    Serializer s;
    s.Restore(std::filesystem::path(argv[1]));
    std::vector<std::string> rows;
    for (auto& [o, id] : s.AllObjects()) {
        if (!o || o->UhdmType() != uhdmmodule_inst) continue;
        auto* m = (const module_inst*)o;
        std::string key = std::string(m->VpiFullName()) + " [" +
                          std::string(m->VpiDefName()) + "] ";
        auto add = [&](const char* n, long v) {
            rows.push_back(key + n + "=" + std::to_string(v));
        };
#define ROW(F) add(#F, m->F() ? (long)m->F()->size() : -1)
        ROW(Ports); ROW(Interfaces); ROW(Process); ROW(Modules);
        ROW(Module_arrays); ROW(Gen_scope_arrays); ROW(Cont_assigns);
        ROW(Primitives); ROW(Def_params); ROW(Io_decls); ROW(Elab_tasks);
        ROW(Ref_modules); ROW(Gen_stmts); ROW(Task_funcs); ROW(Nets);
        ROW(Array_nets); ROW(Assertions); ROW(Property_decls);
        ROW(Concurrent_assertions); ROW(Named_events); ROW(Variables);
        ROW(Logic_vars); ROW(Array_vars); ROW(Parameters); ROW(Param_assigns);
        ROW(Scopes); ROW(Typespecs); ROW(Instance_items); ROW(Attributes);
#undef ROW
    }
    std::sort(rows.begin(), rows.end());
    for (auto& r : rows) std::cout << r << "\n";
    return 0;
}
