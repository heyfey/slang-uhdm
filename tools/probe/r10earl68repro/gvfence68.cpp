// r10earl68 — THE CORPUS FENCE SCAN for § genvarWholeCaRhsFold68.
// Reads a .uhdm database DIRECTLY (never uhdm-dump) and reports every
// ELABORATED gen-scope cont_assign whose WHOLE Rhs is
//   * a `ref_obj`   (CAND: a cell the new distance>0 fold could take), or
//   * a LOCATION-LESS `constant` (FOLD: a cell the pre-existing distance-0
//     fold already minted, whose SIZE this pass re-decides).
// Every affected cell in any database is one of these two, so a database with
// neither line cannot move.  MEASUREMENT ONLY.
//   build: g++ -O2 -std=c++17 gvfence68.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o gvfence68
//   usage: gvfence68 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static void do_scope(const scope* sc);
static void do_inst(const instance* in);
static void do_ca(const VectorOfcont_assign* cas, const std::string& who) {
  if (!cas) return;
  for (auto* ca : *cas) {
    const expr* r = ca->Rhs();
    if (!r) continue;
    if (r->UhdmType() == uhdmref_obj)
      printf("CAND %s ca=%u:%u name=%s\n", who.c_str(), ca->VpiLineNo(),
             ca->VpiColumnNo(), std::string(r->VpiName()).c_str());
    else if (r->UhdmType() == uhdmconstant && r->VpiLineNo() == 0)
      printf("FOLD %s ca=%u:%u sz=%d val=%s\n", who.c_str(), ca->VpiLineNo(),
             ca->VpiColumnNo(), ((const constant*)r)->VpiSize(),
             std::string(((const constant*)r)->VpiValue()).c_str());
  }
}
static void do_gsa(const VectorOfgen_scope_array* gsas) {
  if (!gsas) return;
  for (auto* ga : *gsas)
    if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) do_scope(g);
}
static void do_scope(const scope* sc) {
  auto* g = any_cast<const gen_scope*>(sc);
  if (!g) return;
  std::string who(g->VpiFullName());
  do_ca(g->Cont_assigns(), who);
  if (g->Modules()) for (auto* c : *g->Modules()) do_inst(c);
  if (g->Interfaces()) for (auto* c : *g->Interfaces()) do_inst(c);
  do_gsa(g->Gen_scope_arrays());
}
static void do_inst(const instance* in) {
  if (auto* m = any_cast<const module_inst*>(in)) {
    do_gsa(m->Gen_scope_arrays());
    if (m->Modules()) for (auto* c : *m->Modules()) do_inst(c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) do_inst(c);
  } else if (auto* i = any_cast<const interface_inst*>(in)) {
    do_gsa(i->Gen_scope_arrays());
  }
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: gvfence68 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    auto* d = any_cast<const design*>(o);
    if (!d) continue;
    if (d->TopModules()) for (auto* m : *d->TopModules()) do_inst(m);
  }
  return 0;
}
