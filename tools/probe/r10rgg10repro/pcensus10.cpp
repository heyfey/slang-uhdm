// r10rgg10/pcensus10.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is judge.
//
// THE CENSUS THIS PASS IS DECIDED BY: every `parameter` object in a database,
// in BOTH views (DEF = uhdmallModules + uhdmallInterfaces + uhdmallPackages,
// ELAB = uhdmtopModules), keyed
//   (view, owning-scope FULL PATH, scope KIND, parameter name)
// and reporting, for the two typespec-bearing places `Compare` reads:
//   P: the parameter's own vpiTypespec -> Actual  (kind, LOCLESS?, ranges)
//   C: the param_assign's vpiRhs constant's vpiTypespec -> Actual (ditto)
// plus the Rhs shape (constType/size/value/decompile) and vpiLocalParam.
//
// A typespec's SHAPE string is exactly what `Compare` walks for the kinds this
// head touches: the VpiType name, whether it has a location at all, and each
// range's Left/Right constant as (value, size, constType, decompile) — a BARE
// bound prints `bare` because Surelog's ExprEval mints bounds with the value
// field ONLY.
//
// LHS IS ALWAYS GOLDEN.  One database per run; the join is done in pcensus10.py.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <cstdio>
#include <string>
#include <vector>
#include <set>
#include <map>
#include <algorithm>

using namespace UHDM;

static std::string cshape(const any* e) {
  if (!e) return "-";
  if (e->UhdmType() != uhdmconstant) return std::string(UhdmName(e->UhdmType()));
  auto* c = (constant*)e;
  char b[512];
  bool bare = c->VpiSize() == 0 && c->VpiConstType() == 0 &&
              c->VpiDecompile().empty();
  snprintf(b, sizeof b, "%s%s%s", std::string(c->VpiValue()).c_str(),
           bare ? "/bare" : "", (c->VpiLineNo() == 0 ? "/LL" : "/LOC"));
  if (!bare) {
    char b2[512];
    snprintf(b2, sizeof b2, "%s[sz=%d,ct=%d,dec=%s]", b, c->VpiSize(),
             c->VpiConstType(), std::string(c->VpiDecompile()).c_str());
    return b2;
  }
  return b;
}

static std::string tsshape(const typespec* t) {
  if (!t) return "<null>";
  std::string s = std::string(UhdmName(t->UhdmType()));
  s += (t->VpiLineNo() == 0) ? "/LOCLESS" : "/LOC";
  const VectorOfrange* rg = nullptr;
  if (t->UhdmType() == uhdmlogic_typespec) rg = ((logic_typespec*)t)->Ranges();
  else if (t->UhdmType() == uhdmbit_typespec) rg = ((bit_typespec*)t)->Ranges();
  else if (t->UhdmType() == uhdmint_typespec) rg = ((int_typespec*)t)->Ranges();
  else if (t->UhdmType() == uhdmarray_typespec) rg = ((array_typespec*)t)->Ranges();
  else if (t->UhdmType() == uhdmpacked_array_typespec)
    rg = ((packed_array_typespec*)t)->Ranges();
  if (rg) {
    s += "{";
    for (auto* r : *rg) {
      s += "[" + cshape(r->Left_expr()) + ":" + cshape(r->Right_expr()) + "]";
    }
    s += "}";
  }
  if (!t->VpiName().empty()) s += "(named:" + std::string(t->VpiName()) + ")";
  return s;
}

static const typespec* actual(const ref_typespec* rt) {
  return rt ? rt->Actual_typespec() : nullptr;
}

struct Row { std::string key, val; };
static std::vector<Row> rows;

static std::string rhsShape(const any* r) {
  if (!r) return "-";
  if (r->UhdmType() != uhdmconstant) return std::string(UhdmName(r->UhdmType()));
  auto* c = (constant*)r;
  char b[512];
  snprintf(b, sizeof b, "constant(%s,sz=%d,ct=%d,dec=%s)%s",
           std::string(c->VpiValue()).c_str(), c->VpiSize(), c->VpiConstType(),
           std::string(c->VpiDecompile()).c_str(),
           (c->VpiLineNo() == 0 ? "/LL" : "/LOC"));
  return b;
}

// Walk any scope-ish object that can own Parameters/Param_assigns.
static void emit(const std::string& view, const std::string& path,
                 const char* kindName, const VectorOfany* params,
                 const VectorOfparam_assign* pas) {
  std::map<std::string, const param_assign*> byName;
  if (pas)
    for (auto* pa : *pas) {
      const any* l = pa->Lhs();
      if (l) byName[std::string(l->VpiName())] = pa;
    }
  if (!params) return;
  for (auto* p : *params) {
    if (p->UhdmType() != uhdmparameter) continue;
    auto* pp = (parameter*)p;
    std::string nm(pp->VpiName());
    const typespec* pts = actual(pp->Typespec());
    std::string cts = "-", rhs = "-";
    auto it = byName.find(nm);
    if (it != byName.end()) {
      const any* r = it->second->Rhs();
      rhs = rhsShape(r);
      if (r && r->UhdmType() == uhdmconstant) {
        cts = tsshape(actual(((constant*)r)->Typespec()));
      } else if (r && r->UhdmType() == uhdmoperation) {
        cts = tsshape(actual(((operation*)r)->Typespec()));
      }
    }
    char b[4096];
    snprintf(b, sizeof b, "%s|%s|%s|%s", view.c_str(), path.c_str(), kindName,
             nm.c_str());
    char v[4096];
    snprintf(v, sizeof v, "lp=%d P=%s C=%s RHS=%s", pp->VpiLocalParam(),
             tsshape(pts).c_str(), cts.c_str(), rhs.c_str());
    rows.push_back({b, v});
  }
}

static void walkScope(const std::string& view, const any* o);

static void walkInstance(const std::string& view, const instance* in,
                         const char* kind) {
  std::string path(in->VpiFullName());
  emit(view, path, kind, in->Parameters(), in->Param_assigns());
  if (in->UhdmType() == uhdmmodule_inst) {
    auto* m = (module_inst*)in;
    if (m->Modules()) for (auto* c : *m->Modules()) walkInstance(view, c, "module");
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) walkInstance(view, c, "interface");
    if (m->Gen_scope_arrays())
      for (auto* ga : *m->Gen_scope_arrays()) walkScope(view, ga);
  } else if (in->UhdmType() == uhdminterface_inst) {
    auto* m = (interface_inst*)in;
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) walkInstance(view, c, "interface");
    if (m->Gen_scope_arrays())
      for (auto* ga : *m->Gen_scope_arrays()) walkScope(view, ga);
  }
}

static void walkScope(const std::string& view, const any* o) {
  if (o->UhdmType() == uhdmgen_scope_array) {
    auto* ga = (gen_scope_array*)o;
    if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) walkScope(view, g);
    return;
  }
  if (o->UhdmType() == uhdmgen_scope) {
    auto* g = (gen_scope*)o;
    emit(view, std::string(g->VpiFullName()), "gen_scope", g->Parameters(),
         g->Param_assigns());
    if (g->Modules()) for (auto* c : *g->Modules()) walkInstance(view, c, "module");
    if (g->Interfaces()) for (auto* c : *g->Interfaces()) walkInstance(view, c, "interface");
    if (g->Gen_scope_arrays())
      for (auto* ga : *g->Gen_scope_arrays()) walkScope(view, ga);
    return;
  }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pcensus10 <db>\n"); return 2; }
  Serializer s;
  auto restored = s.Restore(std::filesystem::path(argv[1]));
  if (restored.empty()) { fprintf(stderr, "FATAL: no design\n"); return 3; }
  for (auto h : restored) {
    auto* d = (design*)((const uhdm_handle*)h)->object;
    if (d->AllPackages())
      for (auto* p : *d->AllPackages())
        emit("DEF", std::string(p->VpiFullName()), "package", p->Parameters(),
             p->Param_assigns());
    if (d->AllModules())
      for (auto* m : *d->AllModules()) walkInstance("DEF", m, "module");
    if (d->AllInterfaces())
      for (auto* m : *d->AllInterfaces()) walkInstance("DEF", m, "interface");
    if (d->TopModules())
      for (auto* m : *d->TopModules()) walkInstance("ELAB", m, "module");
  }
  std::sort(rows.begin(), rows.end(),
            [](const Row& a, const Row& b) { return a.key < b.key; });
  for (auto& r : rows) printf("%s\t%s\n", r.key.c_str(), r.val.c_str());
  fprintf(stderr, "rows=%zu\n", rows.size());
  return 0;
}
