// r10earl78 — WHOLE-Rhs CONT_ASSIGN CENSUS, one line per cont_assign, read
// straight from a .uhdm database (never uhdm-dump: Earlgrey's dump is >1 GB).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// Emits, for EVERY cont_assign in the DEF listing (AllModules/AllInterfaces)
// and in the ELABORATED tree (TopModules, recursing through gen scopes, child
// module_insts and interface_insts):
//
//   CA <sec> <home> <owner> <caspan> lhs=<kind>/<name> rhs=<KINDDESC> \
//      ct=<n> sz=<n> val=<v> dec=<d> ts=<kind> tsval=<v> tssgn=<0|1>
//
//   <home>  = MOD when the cont_assign hangs off a module_inst / interface_inst,
//             GEN when it hangs off a gen_scope.  THIS is the gen-scope /
//             module-body split the pass is about.
//   <owner> = the instance-or-gen-scope vpiFullName (DEF: the defName).
//   <KINDDESC> for an operation is `op<T>(<a0>,<a1>,...)` one level deep, with
//             each operand rendered as its kind, or `c<ct>:<val>` for a
//             constant operand and `op<T>` for a nested operation — enough to
//             separate {N{1'b1}} / {N{1'b0}} / {N{multi-bit}} / {N{expr}} /
//             concat-containing-a-replication / nested replications from the
//             non-replication controls, WITHOUT reading any span into the key.
//
// Payload fields are exactly the ones a generated `Compare` reads on a
// constant (VpiConstType / VpiSize / VpiValue / VpiDecompile / Typespec) plus
// the typespec's own kind and value.  NO span is carried in the payload
// (earl60's attrv60.py lesson); the span is in the KEY only.
//
//   build: g++ -O2 -std=c++17 cacen78.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cacen78
//   usage: cacen78 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static const char* SEC = "DEF";
static std::string OWN;
static const char* HOME = "MOD";

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += (c == ' ' ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string base(std::string_view f) {
  std::string s(f);
  size_t sl = s.find_last_of('/');
  if (sl != std::string::npos) s = s.substr(sl + 1);
  if (s.empty()) s = "-";
  return s;
}
static std::string span(const any* o) {
  char b[256];
  snprintf(b, sizeof b, "%s:%u:%u-%u:%u", base(o->VpiFile()).c_str(),
           o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(),
           o->VpiEndColumnNo());
  return b;
}
// One-level operand rendering: enough to name the SHAPE, never a span.
static std::string operandDesc(const any* e, int depth) {
  if (!e) return "-";
  switch (e->UhdmType()) {
    case uhdmconstant: {
      auto* c = (const constant*)e;
      return "c" + std::to_string(c->VpiConstType()) + ":" +
             esc(c->VpiValue()) + ":" + std::to_string(c->VpiSize());
    }
    case uhdmref_obj:
      return "ref:" + esc(e->VpiName());
    case uhdmoperation: {
      auto* op = (const operation*)e;
      std::string r = "op" + std::to_string(op->VpiOpType());
      if (depth > 0 && op->Operands()) {
        r += "(";
        bool first = true;
        for (auto* o : *op->Operands()) {
          if (!first) r += ",";
          first = false;
          r += operandDesc(o, depth - 1);
        }
        r += ")";
      }
      return r;
    }
    default:
      return std::string(UhdmName(e->UhdmType()));
  }
}
static void emitCa(const cont_assign* ca) {
  const expr* r = ca->Rhs();
  const expr* l = ca->Lhs();
  std::string lhs = "-";
  if (l) lhs = std::string(UhdmName(l->UhdmType())) + "/" + esc(l->VpiName());
  std::string rd = "-";
  std::string pay = "ct=- sz=- val=- dec=- ts=- tsval=- tssgn=-";
  if (r) {
    rd = operandDesc(r, 2);
    if (r->UhdmType() == uhdmconstant) {
      auto* c = (const constant*)r;
      std::string ts = "-", tsv = "-";
      int tssgn = -1;
      if (auto* rt = c->Typespec()) {
        ts = "REF_NO_ACTUAL";
        if (auto* at = rt->Actual_typespec()) {
          ts = std::string(UhdmName(at->UhdmType()));
          if (at->UhdmType() == uhdmint_typespec) {
            tsv = esc(((const int_typespec*)at)->VpiValue());
            tssgn = ((const int_typespec*)at)->VpiSigned() ? 1 : 0;
          } else if (at->UhdmType() == uhdminteger_typespec) {
            tssgn = ((const integer_typespec*)at)->VpiSigned() ? 1 : 0;
          }
        }
      }
      char b[1200];
      snprintf(b, sizeof b, "ct=%d sz=%d val=%s dec=%s ts=%s tsval=%s tssgn=%d",
               c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
               esc(c->VpiDecompile()).c_str(), ts.c_str(), tsv.c_str(), tssgn);
      pay = b;
    }
  }
  printf("CA %s %s %s %s lhs=%s rhs=%s %s\n", SEC, HOME, OWN.c_str(),
         span(ca).c_str(), lhs.c_str(), rd.c_str(), pay.c_str());
}
static void do_ca(const VectorOfcont_assign* cas, const char* home) {
  if (!cas) return;
  const char* saved = HOME;
  HOME = home;
  for (auto* ca : *cas) emitCa(ca);
  HOME = saved;
}
static void do_scope(const scope* sc);
static void do_inst(const instance* in);
static void do_gsa(const VectorOfgen_scope_array* gsas) {
  if (!gsas) return;
  for (auto* ga : *gsas)
    if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) do_scope(g);
}
static void do_inst(const instance* in) {
  std::string saved = OWN;
  OWN = esc(in->VpiFullName());
  if (OWN == "-") OWN = esc(in->VpiDefName());
  if (auto* m = any_cast<const module_inst*>(in)) {
    do_ca(m->Cont_assigns(), "MOD");
    do_gsa(m->Gen_scope_arrays());
    if (m->Modules()) for (auto* c : *m->Modules()) do_inst(c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) do_inst(c);
  } else if (auto* i = any_cast<const interface_inst*>(in)) {
    do_ca(i->Cont_assigns(), "MOD");
    do_gsa(i->Gen_scope_arrays());
  }
  OWN = saved;
}
static void do_scope(const scope* sc) {
  auto* g = any_cast<const gen_scope*>(sc);
  if (!g) return;
  std::string saved = OWN;
  if (!g->VpiFullName().empty()) OWN = esc(g->VpiFullName());
  do_ca(g->Cont_assigns(), "GEN");
  if (g->Modules()) for (auto* c : *g->Modules()) do_inst(c);
  if (g->Interfaces()) for (auto* c : *g->Interfaces()) do_inst(c);
  do_gsa(g->Gen_scope_arrays());
  OWN = saved;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cacen78 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    auto* d = any_cast<const design*>(o);
    if (!d) continue;
    SEC = "DEF";
    if (d->AllModules()) for (auto* m : *d->AllModules()) {
      OWN = esc(m->VpiDefName());
      do_ca(m->Cont_assigns(), "MOD");
      do_gsa(m->Gen_scope_arrays()); }
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) {
      OWN = esc(m->VpiDefName());
      do_ca(m->Cont_assigns(), "MOD");
      do_gsa(m->Gen_scope_arrays()); }
    SEC = "ELAB";
    if (d->TopModules()) for (auto* m : *d->TopModules()) do_inst(m);
  }
  return 0;
}
