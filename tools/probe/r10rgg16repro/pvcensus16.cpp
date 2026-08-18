// r10rgg16/pvcensus16.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is judge.
//
// THE CENSUS THIS PASS IS DECIDED BY: every `interface_inst` in a database,
// in both views
//   DEF  = uhdmallModules + uhdmallInterfaces
//   ELAB = uhdmtopModules (gen scopes and nested interfaces walked)
// keyed (view, the interface_inst's FULL PATH), with the payload that decides
// § ifacePortViewActualScopeGate16:
//
//   PV   = is this a PORT VIEW?  (`vpiInstance` unset — Surelog's port copies
//          are built by elab_modport_/elab_interface_ and never carry the
//          back-pointer a DECLARED instance gets; our emitter sets it only on
//          the `!portView` arm, so the flag reads the same on both sides)
//   par  = |vpiParameter|      pa = |vpiParamAssign|   <- THE deciding field
//   mp   = |vpiModport|        var= |vpiVariables|
//   PK   = vpiParent's kind    GK = grandparent's kind  <- gen_scope or not
//
// `pa` is what `interface_inst::Compare` reads through the vector SafeCompare
// overload: golden leaving the vector NULL against ours holding four elements
// is the `lhs == nullptr && rhs != nullptr && !rhs->empty()` arm, which names
// the CONTAINER (the interface_inst) as `m_failedRhs` and leaves `m_failedLhs`
// unset — printing `LHS: <null>` with a whole interface_inst on the right.
// That is this pass's head; it is NOT a spurious object (both sides emit the
// object; see README § 1).
//
// TRAP INHERITED FROM r10rgg11/12/13/15: `UhdmName()` returns a string_view;
// handing it straight to printf("%s") writes raw bytes plus NULs and turns the
// census file BINARY, after which grep prints NOTHING AT ALL.  Every name is
// materialised into a std::string first.
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
static std::string full(const interface_inst* o) {
  if (!o) return "";
  std::string f(o->VpiFullName());
  if (f.empty()) f = std::string(o->VpiName());
  return f;
}
static size_t sz(const VectorOfany* v) { return v ? v->size() : 0; }
static size_t szp(const VectorOfparam_assign* v) { return v ? v->size() : 0; }

static std::vector<std::string> rows;

static void emitIface(const char* view, const interface_inst* ii) {
  const any* p = ii->VpiParent();
  const any* g = p ? p->VpiParent() : nullptr;
  char b[2048];
  snprintf(b, sizeof b, "%s\t%s\t%s\tPV=%d\tpar=%zu\tpa=%zu\tmp=%zu\tvar=%zu\tPK=%s\tGK=%s",
           view, full(ii).c_str(), std::string(ii->VpiDefName()).c_str(),
           ii->Instance() == nullptr ? 1 : 0,
           sz((const VectorOfany*)ii->Parameters()),
           szp(ii->Param_assigns()),
           ii->Modports() ? ii->Modports()->size() : 0,
           ii->Variables() ? ii->Variables()->size() : 0,
           kindOf(p).c_str(), kindOf(g).c_str());
  rows.push_back(b);
}

static std::set<const void*> seen;
static void walkScope(const char* view, const any* o);

static void walkIface(const char* view, const interface_inst* ii) {
  if (!seen.insert(ii).second) return;
  emitIface(view, ii);
  if (auto* v = ii->Interfaces())
    for (auto* c : *v) walkIface(view, c);
  if (auto* v = ii->Interface_arrays())
    for (auto* a : *v)
      if (auto* iv = a->Instances())
        for (auto* e : *iv)
          if (e->UhdmType() == uhdminterface_inst)
            walkIface(view, (const interface_inst*)e);
  if (auto* v = ii->Gen_scope_arrays())
    for (auto* a : *v)
      if (auto* gv = a->Gen_scopes())
        for (auto* gsc : *gv) walkScope(view, gsc);
}

static void walkModule(const char* view, const module_inst* m);

static void walkScope(const char* view, const any* o) {
  if (!o) return;
  if (o->UhdmType() == uhdmgen_scope) {
    auto* gs = (const gen_scope*)o;
    if (auto* v = gs->Interfaces())
      for (auto* c : *v) walkIface(view, c);
    if (auto* v = gs->Interface_arrays())
      for (auto* a : *v)
        if (auto* iv = a->Instances())
          for (auto* e : *iv)
            if (e->UhdmType() == uhdminterface_inst)
              walkIface(view, (const interface_inst*)e);
    if (auto* v = gs->Modules())
      for (auto* c : *v) walkModule(view, c);
    if (auto* v = gs->Gen_scope_arrays())
      for (auto* a : *v)
        if (auto* gv = a->Gen_scopes())
          for (auto* gsc : *gv) walkScope(view, gsc);
  }
}

static void walkModule(const char* view, const module_inst* m) {
  if (!m || !seen.insert(m).second) return;
  if (auto* v = m->Interfaces())
    for (auto* c : *v) walkIface(view, c);
  if (auto* v = m->Interface_arrays())
    for (auto* a : *v)
      if (auto* iv = a->Instances())
        for (auto* e : *iv)
          if (e->UhdmType() == uhdminterface_inst)
            walkIface(view, (const interface_inst*)e);
  if (auto* v = m->Modules())
    for (auto* c : *v) walkModule(view, c);
  if (auto* v = m->Gen_scope_arrays())
    for (auto* a : *v)
      if (auto* gv = a->Gen_scopes())
        for (auto* gsc : *gv) walkScope(view, gsc);
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pvcensus16 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (auto h : restored) {
    auto* d = (design*)((uhdm_handle*)h)->object;
    seen.clear();
    if (auto* v = d->TopModules())
      for (auto* m : *v) walkModule("ELAB", m);
    seen.clear();
    if (auto* v = d->AllModules())
      for (auto* m : *v) walkModule("DEF", m);
    if (auto* v = d->AllInterfaces())
      for (auto* i : *v) walkIface("DEF", i);
  }
  std::sort(rows.begin(), rows.end());
  rows.erase(std::unique(rows.begin(), rows.end()), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  return 0;
}
