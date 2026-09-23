// r11u110 -- CENSUS of the face-2 variable shapes (measurement only).  Walks
// the elaborated tree (module_inst, interface_inst, gen scopes) and prints a
// cell per variable of these shapes:
//   PAV_EXPR   packed_array_var carrying vpiExpr
//   PAV_IFACE  packed_array_var owned by an interface_inst
//   PAV_ATTR   packed_array_var carrying vpiAttribute
//   AV_PAVREG  array_var whose reg (vpiReg) is a packed_array_var
// and "TOTAL <n>".
// build: g++ -O2 -std=c++17 cenv110.cpp -I ~/.local/include -L ~/.local/lib64 \
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o cenv110
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static int total = 0;
static void vars(const VectorOfvariables* vs, bool iface) {
  if (!vs) return;
  for (auto* v : *vs) {
    std::string fn(v->VpiFullName());
    if (v->UhdmType() == uhdmpacked_array_var) {
      if (v->Expr()) { printf("PAV_EXPR %s\n", fn.c_str()); total++; }
      if (iface) { printf("PAV_IFACE %s\n", fn.c_str()); total++; }
      if (v->Attributes() && !v->Attributes()->empty()) { printf("PAV_ATTR %s\n", fn.c_str()); total++; }
    }
    if (v->UhdmType() == uhdmarray_var) {
      auto* av = (const array_var*)v;
      if (av->Variables())
        for (auto* r : *av->Variables())
          if (r->UhdmType() == uhdmpacked_array_var) { printf("AV_PAVREG %s\n", fn.c_str()); total++; }
    }
  }
}
static void walk(const any* o) {
  if (!o) return;
  if (o->UhdmType() == uhdmmodule_inst) {
    auto* mi = (const module_inst*)o;
    vars(mi->Variables(), false);
    if (mi->Modules()) for (auto* m : *mi->Modules()) walk(m);
    if (mi->Interfaces()) for (auto* m : *mi->Interfaces()) walk(m);
    if (mi->Gen_scope_arrays()) for (auto* g : *mi->Gen_scope_arrays()) walk(g);
  } else if (o->UhdmType() == uhdminterface_inst) {
    auto* ii = (const interface_inst*)o;
    vars(ii->Variables(), true);
    if (ii->Interfaces()) for (auto* m : *ii->Interfaces()) walk(m);
    if (ii->Gen_scope_arrays()) for (auto* g : *ii->Gen_scope_arrays()) walk(g);
  } else if (o->UhdmType() == uhdmgen_scope_array) {
    auto* ga = (const gen_scope_array*)o;
    if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) walk(g);
  } else if (o->UhdmType() == uhdmgen_scope) {
    auto* g = (const gen_scope*)o;
    vars(g->Variables(), false);
    if (g->Modules()) for (auto* m : *g->Modules()) walk(m);
    if (g->Interfaces()) for (auto* m : *g->Interfaces()) walk(m);
    if (g->Gen_scope_arrays()) for (auto* x : *g->Gen_scope_arrays()) walk(x);
  }
}
int main(int argc, char** argv) {
  Serializer s;
  auto hs = s.Restore(std::string(argv[1]));
  for (auto h : hs) {
    auto* d = (const design*)((uhdm_handle*)h)->object;
    if (d->UhdmType() != uhdmdesign || !d->TopModules()) continue;
    for (auto* t : *d->TopModules()) walk(t);
  }
  printf("TOTAL %d\n", total);
  return 0;
}
