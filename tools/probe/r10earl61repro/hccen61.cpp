// r10v61 VERIFIER -- RESULT on Earlgrey_0_1, ELAB section, owner-keyed:
//   default   HC 19163 keys  TO-GOLDEN 14  AWAY-GOLDEN 0  STILL-WRONG 0
//             PC  2631 keys  TO-GOLDEN 66  AWAY-GOLDEN 0  STILL-WRONG 0
//   testflags HC 19163 keys  TO-GOLDEN  0  AWAY-GOLDEN 0  STILL-WRONG 0
//             PC  2637 keys  TO-GOLDEN 66  AWAY-GOLDEN 0  STILL-WRONG 0
// i.e. EVERY cell this pass moves lands EXACTLY on golden, and law A is a
// measured NO-OP under -elabuhdm (UHDM's ElaboratorListener re-binds).
// Reads the .uhdm DIRECTLY: Earlgrey's uhdm-dump is >1 GB and takes hours,
// which is why the line-multiset arbiter cannot be run on the real target.
// r10v61 VERIFIER — COMPARE-VISIBLE CENSUS, read straight from a .uhdm database
// (no uhdm-dump: Earlgrey's dumps are gigabytes and take hours).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// Emits ONE keyed line per Compare-visible slot this pass can touch:
//   HC <owner-fullname> <port> <refkind>:<refname>=<actualkind>(<actualname>)
//   PC <cont-assign-file:line> #<i> sz=<n> ct=<n> val=<VpiValue> dec=<decompile>
// Keys carry NO span and NO fullname of the target -- design::Compare reads
// VpiType/VpiName of the Actual and the constant's VpiSize/VpiConstType/
// VpiValue/VpiDecompile, never the fullname or the span.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
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
  if (auto* n = any_cast<const ref_obj*>(o)) return std::string(n->VpiName());
  return std::string(o->VpiName());
}

static void refs_in(const any* e, std::vector<std::string>& out, int depth) {
  if (!e || depth > 24) return;
  UHDM_OBJECT_TYPE t = e->UhdmType();
  auto emit = [&](const any* act, const any* self) {
    out.push_back(kindname(self) + ":" + std::string(self->VpiName()) + "=" +
                  (act ? kindname(act) + "(" + nameof(act) + ")"
                       : std::string("-")));
  };
  switch (t) {
    case uhdmref_obj:   emit(((const ref_obj*)e)->Actual_group(), e); return;
    case uhdmref_var:   emit(((const ref_var*)e)->Actual_group(), e); return;
    case uhdmbit_select:  emit(((const bit_select*)e)->Actual_group(), e); return;
    case uhdmpart_select: emit(((const part_select*)e)->Actual_group(), e); return;
    case uhdmindexed_part_select:
      emit(((const indexed_part_select*)e)->Actual_group(), e); return;
    case uhdmvar_select: emit(((const var_select*)e)->Actual_group(), e); return;
    case uhdmhier_path: {
      auto* h = (const hier_path*)e;
      if (h->Path_elems()) for (auto* p : *h->Path_elems()) refs_in(p, out, depth+1);
      return; }
    case uhdmoperation: {
      auto* op = (const operation*)e;
      if (op->Operands()) for (auto* o : *op->Operands()) refs_in(o, out, depth+1);
      return; }
    case uhdmtagged_pattern:
      refs_in(((const tagged_pattern*)e)->Pattern(), out, depth+1); return;
    case uhdmfunc_call: {
      auto* f = (const func_call*)e;
      if (f->Tf_call_args()) for (auto* a : *f->Tf_call_args()) refs_in(a, out, depth+1);
      return; }
    case uhdmsys_func_call: {
      auto* f = (const sys_func_call*)e;
      if (f->Tf_call_args()) for (auto* a : *f->Tf_call_args()) refs_in(a, out, depth+1);
      return; }
    default: return;
  }
}

static void pat_consts(const any* e, const std::string& key, int& idx, int depth) {
  if (!e || depth > 24) return;
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    printf("PC %s #%d sz=%d ct=%d val=%s dec=%s\n", key.c_str(), idx++,
           c->VpiSize(), c->VpiConstType(), std::string(c->VpiValue()).c_str(),
           std::string(c->VpiDecompile()).c_str());
    return;
  }
  if (e->UhdmType() == uhdmoperation) {
    auto* op = (const operation*)e;
    if (op->Operands()) for (auto* o : *op->Operands()) pat_consts(o, key, idx, depth+1);
  } else if (e->UhdmType() == uhdmtagged_pattern) {
    pat_consts(((const tagged_pattern*)e)->Pattern(), key, idx, depth+1);
  }
}

static void do_scope(const scope* sc, const std::string& own);

static void do_ports(const VectorOfport* ports, const std::string& own) {
  if (!ports) return;
  for (auto* p : *ports) {
    const any* hc = p->High_conn();
    if (!hc) continue;
    std::vector<std::string> rl;
    refs_in(hc, rl, 0);
    std::string s;
    for (auto& r : rl) { if (!s.empty()) s += "|"; s += r; }
    printf("HC %s %s %s %s\n", own.c_str(), std::string(p->VpiName()).c_str(),
           kindname(hc).c_str(), s.empty() ? "<norefs>" : s.c_str());
  }
}

static void do_ca(const VectorOfcont_assign* cas, const std::string& own) {
  if (!cas) return;
  for (auto* ca : *cas) {
    const any* r = ca->Rhs();
    if (!r || r->UhdmType() != uhdmoperation) continue;
    char buf[512];
    snprintf(buf, sizeof buf, "%s@%u", own.c_str(), ca->VpiLineNo());
    // file path is workdir-dependent; strip the directory
    std::string key(buf);
    int idx = 0;
    pat_consts(r, key, idx, 0);
  }
}

static void do_inst(const instance* in) {
  std::string own(in->VpiFullName());
  if (auto* m = any_cast<const module_inst*>(in)) {
    do_ports(m->Ports(), own);
    do_ca(m->Cont_assigns(), own);
    if (m->Modules()) for (auto* c : *m->Modules()) do_inst(c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) do_inst(c);
    if (m->Gen_scope_arrays())
      for (auto* ga : *m->Gen_scope_arrays())
        if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) do_scope(g, own);
  } else if (auto* i = any_cast<const interface_inst*>(in)) {
    do_ports(i->Ports(), own);
    do_ca(i->Cont_assigns(), own);
    
    if (i->Gen_scope_arrays())
      for (auto* ga : *i->Gen_scope_arrays())
        if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) do_scope(g, own);
  }
}

static void do_scope(const scope* sc, const std::string& own) {
  auto* g = any_cast<const gen_scope*>(sc);
  if (!g) return;
  std::string me = own + "." + std::string(g->VpiName());
  do_ca(g->Cont_assigns(), me);
  if (g->Modules()) for (auto* c : *g->Modules()) do_inst(c);
  if (g->Interfaces()) for (auto* c : *g->Interfaces()) do_inst(c);
  if (g->Gen_scope_arrays())
    for (auto* ga : *g->Gen_scope_arrays())
      if (ga->Gen_scopes()) for (auto* s : *ga->Gen_scopes()) do_scope(s, me);
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: hccen61 <db.uhdm>\n"); return 2; }
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
