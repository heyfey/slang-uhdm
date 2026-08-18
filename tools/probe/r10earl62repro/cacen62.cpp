// r10earl62 — CONT_ASSIGN REFERENCE-BINDING CENSUS, read straight from a .uhdm
// database (no uhdm-dump: Earlgrey's dumps are >1 GB and take hours —
// earl61's hccen61.cpp lesson, reused).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// Emits ONE keyed line per Compare-visible reference slot under a cont_assign:
//
//   CA <sec> <owner-defname> L<line>:<col> <path> <refkind>:<name> = <actualkind>(<actualname>)
//
// where <path> is the POSITIONAL route from the cont_assign's Rhs/Lhs to the
// reference (op<type>[i] / tp:<member> / hp[i] / arg[i]), so the key is stable
// across the 10 elaborated copies of one module and carries NO span and NO
// fullname of the target.  design::Compare reads the Actual's VpiType/VpiName
// and nothing else there.
//
// <sec> is DEF (module/package definition listing) or ELAB (the instance tree).
// Keys are deduped by the census script, which counts occurrences.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <set>
using namespace UHDM;

static std::string kindname(const any* o) {
  if (!o) return "-";
  return std::string(UhdmName(o->UhdmType()));
}
static std::string nameof(const any* o) {
  if (!o) return "";
  return std::string(o->VpiName());
}

static const char* SEC = "DEF";
static std::string OWN;
static std::string INST;
static bool WITHINST = false;
static char CAKEY[256];

static void emit(const std::string& path, const any* self, const any* act) {
  printf("CA %s %s %s %s %s:%s = %s(%s)\n", SEC,
         (WITHINST ? INST : OWN).c_str(), CAKEY, path.c_str(),
         kindname(self).c_str(), nameof(self).c_str(),
         kindname(act).c_str(), nameof(act).c_str());
}

static void walk(const any* e, const std::string& path, int depth) {
  if (!e || depth > 32) return;
  switch (e->UhdmType()) {
    case uhdmref_obj:
      emit(path, e, ((const ref_obj*)e)->Actual_group());
      return;
    case uhdmref_var:
      emit(path, e, ((const ref_var*)e)->Actual_group());
      return;
    case uhdmbit_select:
      emit(path, e, ((const bit_select*)e)->Actual_group());
      walk(((const bit_select*)e)->VpiIndex(), path + "/idx", depth + 1);
      return;
    case uhdmpart_select: {
      auto* p = (const part_select*)e;
      emit(path, e, p->Actual_group());
      walk(p->Left_range(), path + "/l", depth + 1);
      walk(p->Right_range(), path + "/r", depth + 1);
      return; }
    case uhdmindexed_part_select: {
      auto* p = (const indexed_part_select*)e;
      emit(path, e, p->Actual_group());
      walk(p->Base_expr(), path + "/b", depth + 1);
      walk(p->Width_expr(), path + "/w", depth + 1);
      return; }
    case uhdmvar_select: {
      auto* p = (const var_select*)e;
      emit(path, e, p->Actual_group());
      if (p->Exprs()) { int i = 0;
        for (auto* x : *p->Exprs()) walk(x, path + "/e[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmhier_path: {
      auto* h = (const hier_path*)e;
      if (h->Path_elems()) { int i = 0;
        for (auto* p : *h->Path_elems())
          walk(p, path + "/hp[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmoperation: {
      auto* op = (const operation*)e;
      std::string me = path + "/op" + std::to_string(op->VpiOpType());
      if (op->Operands()) { int i = 0;
        for (auto* o : *op->Operands())
          walk(o, me + "[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmtagged_pattern: {
      auto* tp = (const tagged_pattern*)e;
      std::string nm;
      if (auto* rt = tp->Typespec()) {
        if (auto* at = rt->Actual_typespec()) nm = std::string(at->VpiName());
      }
      walk(tp->Pattern(), path + "/tp:" + nm, depth + 1);
      return; }
    case uhdmfunc_call: {
      auto* f = (const func_call*)e;
      if (f->Tf_call_args()) { int i = 0;
        for (auto* a : *f->Tf_call_args())
          walk(a, path + "/arg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmsys_func_call: {
      auto* f = (const sys_func_call*)e;
      if (f->Tf_call_args()) { int i = 0;
        for (auto* a : *f->Tf_call_args())
          walk(a, path + "/sarg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    default: return;
  }
}

static void do_ca(const VectorOfcont_assign* cas) {
  if (!cas) return;
  for (auto* ca : *cas) {
    snprintf(CAKEY, sizeof CAKEY, "L%u:%u", ca->VpiLineNo(), ca->VpiColumnNo());
    walk(ca->Lhs(), "LHS", 0);
    walk(ca->Rhs(), "RHS", 0);
  }
}

static void do_scope(const scope* sc);

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
    do_gsa(m->Gen_scope_arrays());
    if (m->Modules()) for (auto* c : *m->Modules()) do_inst(c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) do_inst(c);
  } else if (auto* i = any_cast<const interface_inst*>(in)) {
    do_ca(i->Cont_assigns());
    do_gsa(i->Gen_scope_arrays());
  }
  OWN = saved; INST = savedI;
}

static void do_scope(const scope* sc) {
  auto* g = any_cast<const gen_scope*>(sc);
  if (!g) return;
  do_ca(g->Cont_assigns());
  if (g->Modules()) for (auto* c : *g->Modules()) do_inst(c);
  if (g->Interfaces()) for (auto* c : *g->Interfaces()) do_inst(c);
  do_gsa(g->Gen_scope_arrays());
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cacen62 <db.uhdm>\n"); return 2; }
  WITHINST = getenv("R10E62_INST") != nullptr;
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    auto* d = any_cast<const design*>(o);
    if (!d) continue;
    SEC = "DEF";
    if (d->AllModules()) for (auto* m : *d->AllModules()) { OWN = std::string(m->VpiDefName()); do_ca(m->Cont_assigns()); do_gsa(m->Gen_scope_arrays()); }
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) { OWN = std::string(m->VpiDefName()); do_ca(m->Cont_assigns()); do_gsa(m->Gen_scope_arrays()); }
    SEC = "ELAB";
    if (d->TopModules()) for (auto* m : *d->TopModules()) do_inst(m);
  }
  return 0;
}
