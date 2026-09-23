// r11u110 -- CENSUS of the law's shape (measurement only).  For every
// elaborated module_inst port (TopModules tree) whose vpiTypedef is a
// packed_array_typespec with a NAMED element ref, prints
//   CELL <port path> parent=<kind of the array's vpiParent> elem=<ref name>
//        elemts=<element kind>(<name>) <line:col of element>
// and a final "PORTS=<n> SHAPE=<n>".  On a GOLDEN database the rebuilt
// arrays read parent=type_parameter; on ours the definition's original
// array reads parent=type_parameter as well — the element span tells the
// default from the override.
// build: g++ -O2 -std=c++17 cen110.cpp -I ~/.local/include -L ~/.local/lib64 \
//        -L ~/.local/lib -luhdm -lcapnp -lkj -o cen110
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static int nports = 0, nshape = 0;
static void walk(const any* o) {
  if (!o) return;
  if (o->UhdmType() == uhdmmodule_inst) {
    auto* mi = (const module_inst*)o;
    if (mi->Ports())
      for (auto* p : *mi->Ports()) {
        nports++;
        if (!p->Typespec()) continue;
        auto* a = p->Typespec()->Actual_typespec();
        if (!a || a->UhdmType() != uhdmpacked_array_typespec) continue;
        auto* er = ((const packed_array_typespec*)a)->Elem_typespec();
        if (!er || er->VpiName().empty()) continue;
        nshape++;
        auto* e = er->Actual_typespec();
        printf("CELL %s.%s parent=%s elem=%s elemts=%s(%s) %u:%u\n",
               std::string(mi->VpiFullName()).c_str(), std::string(p->VpiName()).c_str(),
               a->VpiParent() ? UhdmName(a->VpiParent()->UhdmType()).data() : "<null>",
               std::string(er->VpiName()).c_str(),
               e ? UhdmName(e->UhdmType()).data() : "<null>",
               e ? std::string(e->VpiName()).c_str() : "",
               e ? e->VpiLineNo() : 0, e ? (unsigned)e->VpiColumnNo() : 0);
      }
    if (mi->Modules()) for (auto* m : *mi->Modules()) walk(m);
    if (mi->Gen_scope_arrays()) for (auto* g : *mi->Gen_scope_arrays()) walk(g);
  } else if (o->UhdmType() == uhdmgen_scope_array) {
    auto* ga = (const gen_scope_array*)o;
    if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) walk(g);
  } else if (o->UhdmType() == uhdmgen_scope) {
    auto* g = (const gen_scope*)o;
    if (g->Modules()) for (auto* m : *g->Modules()) walk(m);
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
  printf("PORTS=%d SHAPE=%d\n", nports, nshape);
  return 0;
}
