// r10earl64 — EXPRESSION-CONSTANT ENCODING CENSUS, read straight from a .uhdm
// database (never uhdm-dump: Earlgrey's dump is >1 GB — earl61/62/63's lesson).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// One keyed line per LEAF slot of every cont_assign expression and every port
// High_conn expression:
//
//   EX <sec> <owner> <site> <path> <kind> ct=<n> sz=<n> val=<v> dec=<d> [name=<n>]
//
// <path> is the POSITIONAL route from the site root (op<type>[i] / b / w / idx
// / l / r / arg[i]), so the key carries NO span and NO fullname and is stable
// across the many elaborated copies of one module definition.
// <sec> is DEF (design AllModules/AllInterfaces listing) or ELAB (instance
// tree).  <owner> is the DEFNAME by default, the instance vpiFullName with
// R64_INST=1 (which is what makes each instance its own cell).
//
// constant::Compare reads VpiType, VpiDecompile, VpiSize, Typespec and
// VpiConstType; VpiValue is printed anyway because it names the Value TYPE
// Surelog folded to, which is what the encoding law is about.  A ref_obj leaf
// is printed too (kind=ref_obj), because "golden keeps a reference where we
// mint a constant" is the other half of every fold measurement.
//   build: g++ -O2 -std=c++17 excen64.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o excen64
//   usage: [R64_INST=1] excen64 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
using namespace UHDM;

static const char* SEC = "DEF";
static std::string OWN, INST;
static bool WITHINST = false;
static char SITE[256];

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static void emit(const std::string& path, const any* e) {
  std::string kn = std::string(UhdmName(e->UhdmType()));
  char buf[1024];
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    std::string ts = "-";
    if (auto* rt = c->Typespec())
      if (auto* at = rt->Actual_typespec()) ts = std::string(UhdmName(at->UhdmType()));
    snprintf(buf, sizeof buf, "ct=%d sz=%d val=%s dec=%s ts=%s",
             c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
             esc(c->VpiDecompile()).c_str(), ts.c_str());
  } else {
    snprintf(buf, sizeof buf, "name=%s", esc(e->VpiName()).c_str());
  }
  printf("EX %s %s %s %s %s %s\n", SEC, (WITHINST ? INST : OWN).c_str(), SITE,
         path.c_str(), kn.c_str(), buf);
}

static void walk(const any* e, const std::string& path, int depth) {
  if (!e || depth > 32) return;
  switch (e->UhdmType()) {
    case uhdmconstant:
    case uhdmref_obj:
    case uhdmref_var:
      emit(path, e);
      return;
    case uhdmbit_select:
      emit(path, e);
      walk(((const bit_select*)e)->VpiIndex(), path + "/idx", depth + 1);
      return;
    case uhdmpart_select: {
      auto* p = (const part_select*)e;
      emit(path, e);
      walk(p->Left_range(), path + "/l", depth + 1);
      walk(p->Right_range(), path + "/r", depth + 1);
      return; }
    case uhdmindexed_part_select: {
      auto* p = (const indexed_part_select*)e;
      emit(path, e);
      walk(p->Base_expr(), path + "/b", depth + 1);
      walk(p->Width_expr(), path + "/w", depth + 1);
      return; }
    case uhdmvar_select: {
      auto* p = (const var_select*)e;
      emit(path, e);
      if (p->Exprs()) { int i = 0;
        for (auto* x : *p->Exprs()) walk(x, path + "/e[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmhier_path: {
      auto* h = (const hier_path*)e;
      if (h->Path_elems()) { int i = 0;
        for (auto* p : *h->Path_elems()) walk(p, path + "/hp[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmoperation: {
      auto* op = (const operation*)e;
      std::string me = path + "/op" + std::to_string(op->VpiOpType());
      if (op->Operands()) { int i = 0;
        for (auto* o : *op->Operands()) walk(o, me + "[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmtagged_pattern: {
      auto* tp = (const tagged_pattern*)e;
      std::string nm;
      if (auto* rt = tp->Typespec())
        if (auto* at = rt->Actual_typespec()) nm = std::string(at->VpiName());
      walk(tp->Pattern(), path + "/tp:" + nm, depth + 1);
      return; }
    case uhdmfunc_call: {
      auto* f = (const func_call*)e;
      if (f->Tf_call_args()) { int i = 0;
        for (auto* a : *f->Tf_call_args()) walk(a, path + "/arg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmsys_func_call: {
      auto* f = (const sys_func_call*)e;
      if (f->Tf_call_args()) { int i = 0;
        for (auto* a : *f->Tf_call_args()) walk(a, path + "/sarg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    default: return;
  }
}

static void do_ca(const VectorOfcont_assign* cas) {
  if (!cas) return;
  for (auto* ca : *cas) {
    snprintf(SITE, sizeof SITE, "CA_L%u:%u", ca->VpiLineNo(), ca->VpiColumnNo());
    walk(ca->Lhs(), "LHS", 0);
    walk(ca->Rhs(), "RHS", 0);
  }
}
static void do_ports(const VectorOfport* ps) {
  if (!ps) return;
  for (auto* p : *ps) {
    if (!p->High_conn()) continue;
    snprintf(SITE, sizeof SITE, "HC_%s_L%u:%u", esc(p->VpiName()).c_str(),
             p->VpiLineNo(), p->VpiColumnNo());
    walk(p->High_conn(), "HC", 0);
  }
}

static void do_scope(const scope* sc);
static void do_inst(const instance* in);

static void do_gsa(const VectorOfgen_scope_array* gsas) {
  if (!gsas) return;
  for (auto* ga : *gsas)
    if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) do_scope(g);
}
static void do_inst(const instance* in) {
  std::string saved = OWN, savedI = INST;
  if (!in->VpiDefName().empty()) OWN = std::string(in->VpiDefName());
  INST = std::string(in->VpiFullName());
  if (auto* m = any_cast<const module_inst*>(in)) {
    do_ca(m->Cont_assigns());
    do_ports(m->Ports());
    do_gsa(m->Gen_scope_arrays());
    if (m->Modules()) for (auto* c : *m->Modules()) do_inst(c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) do_inst(c);
  } else if (auto* i = any_cast<const interface_inst*>(in)) {
    do_ca(i->Cont_assigns());
    do_ports(i->Ports());
    do_gsa(i->Gen_scope_arrays());
  }
  OWN = saved; INST = savedI;
}
static void do_scope(const scope* sc) {
  auto* g = any_cast<const gen_scope*>(sc);
  if (!g) return;
  std::string saved = INST;
  if (!g->VpiFullName().empty()) INST = std::string(g->VpiFullName());
  do_ca(g->Cont_assigns());
  if (g->Modules()) for (auto* c : *g->Modules()) do_inst(c);
  if (g->Interfaces()) for (auto* c : *g->Interfaces()) do_inst(c);
  do_gsa(g->Gen_scope_arrays());
  INST = saved;
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: excen64 <db.uhdm>\n"); return 2; }
  WITHINST = getenv("R64_INST") != nullptr;
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    auto* d = any_cast<const design*>(o);
    if (!d) continue;
    SEC = "DEF";
    if (d->AllModules()) for (auto* m : *d->AllModules()) {
      OWN = std::string(m->VpiDefName()); INST = OWN;
      do_ca(m->Cont_assigns()); do_ports(m->Ports()); do_gsa(m->Gen_scope_arrays()); }
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) {
      OWN = std::string(m->VpiDefName()); INST = OWN;
      do_ca(m->Cont_assigns()); do_ports(m->Ports()); do_gsa(m->Gen_scope_arrays()); }
    SEC = "ELAB";
    if (d->TopModules()) for (auto* m : *d->TopModules()) do_inst(m);
  }
  return 0;
}
