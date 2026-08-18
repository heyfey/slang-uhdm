// r10vrgg16/vcensus16.cpp — MEASUREMENT ONLY (official uhdm-cmp is the judge).
//
// VIEW-GENERAL interface_inst census, written by the VERIFIER independently of
// the implementer's pvcensus16.cpp.  Differences that matter:
//   * it walks PROGRAMS, MODULE ARRAYS and INTERFACE ARRAYS as well as
//     modules / interfaces / gen scopes, so a port view that migrates into a
//     container the implementer's walker does not visit cannot hide;
//   * it does NOT dedup rows (a `sort -u` over rows hides a MULTIPLICITY
//     change, which is exactly what a vector-size head is) -- object identity
//     is deduped, row text is not;
//   * the payload carries the param_assign CONTENTS (lhs name, rhs kind, the
//     vpiOverriden stamp and the decompiled rhs) and the parameter list, all of
//     them fields `scope::Compare` / `param_assign::Compare` actually read.
//     NO span, NO file/line, NO fullname-only keys.
//
// key   = <view>\t<vpiFullName>\t<vpiDefName>
// value = the payload after the key
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <set>
#include <algorithm>

using namespace UHDM;

static std::string kindOf(const any* o) {
  if (!o) return "-";
  return std::string(UhdmName(o->UhdmType()));
}
static std::string S(std::string_view v) { return std::string(v); }

static std::vector<std::string> rows;
static std::set<const void*> seen;

static void emitIface(const char* view, const interface_inst* ii) {
  const any* p = ii->VpiParent();
  const any* g = p ? p->VpiParent() : nullptr;
  std::string f = S(ii->VpiFullName());
  if (f.empty()) f = S(ii->VpiName());
  std::string pa;
  size_t npa = 0;
  if (auto* v = ii->Param_assigns()) {
    npa = v->size();
    for (auto* a : *v) {
      pa += "{";
      pa += a->Lhs() ? S(a->Lhs()->VpiName()) : "-";
      pa += ":";
      pa += a->Rhs() ? kindOf(a->Rhs()) : "-";
      pa += ":";
      if (a->Rhs() && a->Rhs()->UhdmType() == uhdmconstant)
        pa += S(((const constant*)a->Rhs())->VpiDecompile());
      pa += a->VpiOverriden() ? ":OV" : ":-";
      pa += "}";
    }
  } else {
    pa = "<null>";
  }
  std::string pl;
  size_t npar = 0;
  if (auto* v = ii->Parameters()) {
    npar = v->size();
    for (auto* a : *v) {
      pl += "{" + S(a->VpiName());
      if (a->UhdmType() == uhdmparameter)
        pl += ":" + S(((const parameter*)a)->VpiValue());
      pl += "}";
    }
  }
  char b[8192];
  snprintf(b, sizeof b,
           "%s\t%s\t%s\tPV=%d\tpar=%zu\tpa=%zu\tmp=%zu\tvar=%zu\ttf=%zu\t"
           "cb=%zu\tport=%zu\tPK=%s\tGK=%s\tPA=%s\tPL=%s",
           view, f.c_str(), S(ii->VpiDefName()).c_str(),
           ii->Instance() == nullptr ? 1 : 0, npar, npa,
           ii->Modports() ? ii->Modports()->size() : 0,
           ii->Variables() ? ii->Variables()->size() : 0,
           ii->Interface_tf_decls() ? ii->Interface_tf_decls()->size() : 0,
           ii->Clocking_blocks() ? ii->Clocking_blocks()->size() : 0,
           ii->Ports() ? ii->Ports()->size() : 0,
           kindOf(p).c_str(), kindOf(g).c_str(), pa.c_str(), pl.c_str());
  rows.push_back(b);
}

static void walkAny(const char* view, const any* o);

static void walkIfaceArrays(const char* view, const VectorOfinterface_array* v) {
  if (!v) return;
  for (auto* a : *v)
    if (auto* iv = a->Instances())
      for (auto* e : *iv) walkAny(view, e);
}
static void walkModArrays(const char* view, const VectorOfmodule_array* v) {
  if (!v) return;
  for (auto* a : *v) {
    if (auto* iv = a->Instances())
      for (auto* e : *iv) walkAny(view, e);
    if (auto* mv = a->Modules())
      for (auto* e : *mv) walkAny(view, e);
  }
}
static void walkGsa(const char* view, const VectorOfgen_scope_array* v) {
  if (!v) return;
  for (auto* a : *v)
    if (auto* gv = a->Gen_scopes())
      for (auto* g : *gv) walkAny(view, g);
}

static void walkAny(const char* view, const any* o) {
  if (!o) return;
  if (!seen.insert(o).second) return;
  switch (o->UhdmType()) {
    case uhdminterface_inst: {
      auto* ii = (const interface_inst*)o;
      emitIface(view, ii);
      if (auto* v = ii->Interfaces()) for (auto* c : *v) walkAny(view, c);
      walkIfaceArrays(view, ii->Interface_arrays());
      walkGsa(view, ii->Gen_scope_arrays());
      break;
    }
    case uhdmmodule_inst: {
      auto* m = (const module_inst*)o;
      if (auto* v = m->Interfaces()) for (auto* c : *v) walkAny(view, c);
      walkIfaceArrays(view, m->Interface_arrays());
      if (auto* v = m->Modules()) for (auto* c : *v) walkAny(view, c);
      walkModArrays(view, m->Module_arrays());
      walkGsa(view, m->Gen_scope_arrays());
      break;
    }
    case uhdmgen_scope: {
      auto* gs = (const gen_scope*)o;
      if (auto* v = gs->Interfaces()) for (auto* c : *v) walkAny(view, c);
      walkIfaceArrays(view, gs->Interface_arrays());
      if (auto* v = gs->Modules()) for (auto* c : *v) walkAny(view, c);
      walkModArrays(view, gs->Module_arrays());
      if (auto* v = gs->Programs()) for (auto* c : *v) walkAny(view, c);
      walkGsa(view, gs->Gen_scope_arrays());
      break;
    }
    case uhdmprogram: {
      auto* pr = (const program*)o;
      if (auto* v = pr->Interfaces()) for (auto* c : *v) walkAny(view, c);
      walkIfaceArrays(view, pr->Interface_arrays());
      walkGsa(view, pr->Gen_scope_arrays());
      break;
    }
    default:
      break;
  }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: vcensus16 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (auto h : restored) {
    auto* d = (design*)((uhdm_handle*)h)->object;
    seen.clear();
    if (auto* v = d->TopModules()) for (auto* m : *v) walkAny("ELAB", m);
    seen.clear();
    if (auto* v = d->AllModules()) for (auto* m : *v) walkAny("DEF", m);
    if (auto* v = d->AllInterfaces()) for (auto* i : *v) walkAny("DEF", i);
    if (auto* v = d->AllPrograms()) for (auto* p : *v) walkAny("DEF", p);
  }
  std::sort(rows.begin(), rows.end());          // ORDER-BLIND, but NOT deduped
  for (auto& r : rows) printf("%s\n", r.c_str());
  return 0;
}
