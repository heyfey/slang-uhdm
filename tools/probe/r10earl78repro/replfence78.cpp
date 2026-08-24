// r10earl78 — THE CORPUS FENCE SCAN for § genCaReplWholeFold78.
// Reads a .uhdm database DIRECTLY (never uhdm-dump) and reports every
// ELABORATED cont_assign whose WHOLE Rhs is a `vpiMultiConcatOp` operation
// (opType 34) -- i.e. every cell the new gen-scope replication fold could
// move -- tagged GEN when the cont_assign hangs off a gen_scope and MOD when
// it hangs off a module_inst / interface_inst.  A database with no GEN line
// cannot move under this law; the MOD lines are printed as the CONTROL
// population the law must NOT touch.
//
// It ALSO prints, as CASTCAND, every gen-scope cont_assign whose whole Rhs is
// a vpiCastOp (67) -- padctrl's `AttrDw'(6'h3F)`, the sibling residue named in
// PREDICT_R0.txt -- so the next pass has its reach measured too.  MEASUREMENT
// ONLY; nothing in this pass acts on a CASTCAND.
//
//   build: g++ -O2 -std=c++17 replfence78.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o replfence78
//   usage: replfence78 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;
static void do_scope(const scope* sc);
static void do_inst(const instance* in);
static std::string opdesc(const any* e) {
  if (!e) return "-";
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    return "c" + std::to_string(c->VpiConstType()) + ":" +
           std::string(c->VpiValue()) + ":" + std::to_string(c->VpiSize());
  }
  if (e->UhdmType() == uhdmref_obj) return "ref:" + std::string(e->VpiName());
  if (e->UhdmType() == uhdmoperation)
    return "op" + std::to_string(((const operation*)e)->VpiOpType());
  return std::string(UhdmName(e->UhdmType()));
}
static void do_ca(const VectorOfcont_assign* cas, const char* home,
                  const std::string& who) {
  if (!cas) return;
  for (auto* ca : *cas) {
    const expr* r = ca->Rhs();
    if (!r || r->UhdmType() != uhdmoperation) continue;
    int32_t ot = ((const operation*)r)->VpiOpType();
    if (ot != 34 && ot != 67) continue;
    std::string ops;
    if (auto* v = ((const operation*)r)->Operands())
      for (auto* o : *v) { if (!ops.empty()) ops += ","; ops += opdesc(o); }
    printf("%s %s %s ca=%u:%u lhs=%s(%s) rhs=op%d(%s)\n",
           ot == 34 ? "REPL" : "CASTCAND", home, who.c_str(), ca->VpiLineNo(),
           ca->VpiColumnNo(),
           ca->Lhs() ? UhdmName(ca->Lhs()->UhdmType()).data() : "-",
           ca->Lhs() ? std::string(ca->Lhs()->VpiName()).c_str() : "-", ot,
           ops.c_str());
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
  do_ca(g->Cont_assigns(), "GEN", who);
  if (g->Modules()) for (auto* c : *g->Modules()) do_inst(c);
  if (g->Interfaces()) for (auto* c : *g->Interfaces()) do_inst(c);
  do_gsa(g->Gen_scope_arrays());
}
static void do_inst(const instance* in) {
  std::string who(in->VpiFullName());
  if (auto* m = any_cast<const module_inst*>(in)) {
    do_ca(m->Cont_assigns(), "MOD", who);
    do_gsa(m->Gen_scope_arrays());
    if (m->Modules()) for (auto* c : *m->Modules()) do_inst(c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) do_inst(c);
  } else if (auto* i = any_cast<const interface_inst*>(in)) {
    do_ca(i->Cont_assigns(), "MOD", who);
    do_gsa(i->Gen_scope_arrays());
  }
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: replfence78 <db.uhdm>\n"); return 2; }
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
