// r10earl76 — HEAD DECODE for a `module_inst` head whose LHS and RHS are the
// SAME object: `BaseClass::SafeCompare`'s VECTOR overload sets BOTH containers
// on a SIZE MISMATCH and names the OWNER on both sides (RESUME §9), so the
// failing field is one of the module's vectors and the cmp log cannot say
// which.  This prints every vector's SIZE, in `module_inst::Compare` ORDER,
// for one named instance out of one database — run it on golden and on ours
// and read the first row that differs.  MEASUREMENT ONLY.
//   build: g++ -O2 -std=c++17 mvec76.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o mvec76
//   usage: mvec76 <db.uhdm> <vpiFullName>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/Serializer.h>
#include <cstdio>
#include <string>
using namespace UHDM;
#define ROW(f) printf("%-22s %zu\n", #f, m->f() ? m->f()->size() : (size_t)0)
int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: mvec76 <db> <fullname>\n"); return 2; }
  Serializer s;
  if (s.Restore(std::string(argv[1])).empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  int found = 0;
  for (const auto& [obj, id] : s.AllObjects()) {
    const module_inst* m = any_cast<const module_inst*>(obj);
    if (!m || m->VpiFullName() != argv[2]) continue;
    found++;
    printf("== %s  (copy %d)  def=%s\n", argv[2], found,
           std::string(m->VpiDefName()).c_str());
    ROW(Ports); ROW(Interfaces); ROW(Interface_arrays); ROW(Process);
    ROW(Modules); ROW(Module_arrays); ROW(Gen_scope_arrays); ROW(Cont_assigns);
    ROW(Primitives); ROW(Primitive_arrays); ROW(Mod_paths); ROW(Tchks);
    ROW(Def_params); ROW(Io_decls); ROW(Alias_stmts); ROW(Clocking_blocks);
    ROW(Elab_tasks); ROW(Ref_modules); ROW(Gen_stmts);
    ROW(Nets); ROW(Variables); ROW(Array_nets); ROW(Named_events);
    ROW(Parameters); ROW(Param_assigns); ROW(Typespecs); ROW(Task_funcs);
    ROW(Assertions); ROW(Let_decls); ROW(Instance_items);
    if (argc > 3) {   // --names: the Nets and Variables by name and kind
      if (m->Nets())
        for (auto* n : *m->Nets())
          printf("  NET %-28s %s\n", std::string(n->VpiName()).c_str(),
                 UhdmName(n->UhdmType()).data());
      if (m->Variables())
        for (auto* v : *m->Variables())
          printf("  VAR %-28s %s\n", std::string(v->VpiName()).c_str(),
                 UhdmName(v->UhdmType()).data());
    }
  }
  if (!found) fprintf(stderr, "NOT FOUND: %s\n", argv[2]);
  return 0;
}
