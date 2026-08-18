// r10rgg11/pcensus11.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is judge.
//
// THE CENSUS THIS PASS IS DECIDED BY: every INSTANCE PORT CONNECTION actual
// (`port->High_conn()`) in a database, in BOTH views
//   DEF  = uhdmallModules + uhdmallInterfaces (definition instances)
//   ELAB = uhdmtopModules (elaborated tree, gen scopes walked)
// keyed  (view, OWNING instance FULL PATH, port index, port name)
// and reporting the actual expression's SHAPE — for a constant that is
//   constant(<VpiValue>,sz=<VpiSize>,ct=<VpiConstType>,dec=<VpiDecompile>)
// which is exactly the field set `constant::Compare` reads, plus /LOC|/LL.
//
// Also censused, for the same read-site question:
//   CA:  every cont_assign Rhs in the same scopes (rgg8/rgg9's 64-bit path)
//   PA:  every param_assign Rhs on an instance (the OVERRIDE actual)
//
// LHS IS ALWAYS GOLDEN.  One database per run; the join is done in join11.py.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <cstdio>
#include <string>
#include <vector>
#include <map>
#include <algorithm>

using namespace UHDM;

static std::string eshape(const any* e) {
  if (!e) return "<null>";
  char b[1024];
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (constant*)e;
    snprintf(b, sizeof b, "constant(%s,sz=%d,ct=%d,dec=%s)%s",
             std::string(c->VpiValue()).c_str(), c->VpiSize(),
             c->VpiConstType(), std::string(c->VpiDecompile()).c_str(),
             (c->VpiLineNo() == 0 ? "/LL" : "/LOC"));
    if (getenv("R10RGG11_IDS")) {
      std::string r(b);
      r += "#" + std::to_string((unsigned long long)(const void*)c % 100000);
      return r;
    }
    return b;
  }
  if (e->UhdmType() == uhdmref_obj) {
    snprintf(b, sizeof b, "ref_obj(%s)", std::string(e->VpiName()).c_str());
    return b;
  }
  if (e->UhdmType() == uhdmoperation) {
    snprintf(b, sizeof b, "operation(op=%d,n=%zu)", ((operation*)e)->VpiOpType(),
             ((operation*)e)->Operands() ? ((operation*)e)->Operands()->size() : 0);
    return b;
  }
  // NOTE: UhdmName() returns a string_view; passing it to printf's %s wrote
  // the raw bytes plus NULs and turned the census file BINARY, which made grep
  // silently print NOTHING.  Always materialise a std::string first.
  snprintf(b, sizeof b, "%s(%s)", std::string(UhdmName(e->UhdmType())).c_str(),
           std::string(e->VpiName()).c_str());
  return b;
}

struct Row { std::string key, val; };
static std::vector<Row> rows;

static void emitPorts(const std::string& view, const std::string& path,
                      const VectorOfport* ports) {
  if (!ports) return;
  int i = 0;
  for (auto* p : *ports) {
    char k[4096];
    snprintf(k, sizeof k, "%s|PORT|%s|%d|%s", view.c_str(), path.c_str(), i,
             std::string(p->VpiName()).c_str());
    rows.push_back({k, eshape(p->High_conn())});
    ++i;
  }
}

static void emitCA(const std::string& view, const std::string& path,
                   const VectorOfcont_assign* cas) {
  if (!cas) return;
  int i = 0;
  for (auto* c : *cas) {
    char k[4096];
    snprintf(k, sizeof k, "%s|CA|%s|%d|%s", view.c_str(), path.c_str(), i,
             c->Lhs() ? std::string(c->Lhs()->VpiName()).c_str() : "-");
    rows.push_back({k, eshape(c->Rhs())});
    ++i;
  }
}

static void emitPA(const std::string& view, const std::string& path,
                   const VectorOfparam_assign* pas) {
  if (!pas) return;
  for (auto* pa : *pas) {
    char k[4096];
    snprintf(k, sizeof k, "%s|PA|%s|%s", view.c_str(), path.c_str(),
             pa->Lhs() ? std::string(pa->Lhs()->VpiName()).c_str() : "-");
    rows.push_back({k, eshape(pa->Rhs())});
  }
}

static void walkScope(const std::string& view, const any* o);

static void walkInstance(const std::string& view, const instance* in) {
  std::string path(in->VpiFullName());
  emitPA(view, path, in->Param_assigns());
  if (in->UhdmType() == uhdmmodule_inst) {
    auto* m = (module_inst*)in;
    emitPorts(view, path, m->Ports());
    emitCA(view, path, m->Cont_assigns());
    if (m->Modules()) for (auto* c : *m->Modules()) walkInstance(view, c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) walkInstance(view, c);
    if (m->Gen_scope_arrays())
      for (auto* ga : *m->Gen_scope_arrays()) walkScope(view, ga);
  } else if (in->UhdmType() == uhdminterface_inst) {
    auto* m = (interface_inst*)in;
    emitPorts(view, path, m->Ports());
    emitCA(view, path, m->Cont_assigns());
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) walkInstance(view, c);
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
    std::string path(g->VpiFullName());
    emitPA(view, path, g->Param_assigns());
    emitCA(view, path, g->Cont_assigns());
    if (g->Modules()) for (auto* c : *g->Modules()) walkInstance(view, c);
    if (g->Interfaces()) for (auto* c : *g->Interfaces()) walkInstance(view, c);
    if (g->Gen_scope_arrays())
      for (auto* ga : *g->Gen_scope_arrays()) walkScope(view, ga);
    return;
  }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pcensus11 <db>\n"); return 2; }
  Serializer s;
  auto restored = s.Restore(std::filesystem::path(argv[1]));
  if (restored.empty()) { fprintf(stderr, "FATAL: no design\n"); return 3; }
  for (auto h : restored) {
    auto* d = (design*)((const uhdm_handle*)h)->object;
    if (d->AllModules())
      for (auto* m : *d->AllModules()) walkInstance("DEF", m);
    if (d->AllInterfaces())
      for (auto* m : *d->AllInterfaces()) walkInstance("DEF", m);
    if (d->TopModules())
      for (auto* m : *d->TopModules()) walkInstance("ELAB", m);
  }
  std::sort(rows.begin(), rows.end(),
            [](const Row& a, const Row& b) { return a.key < b.key; });
  for (auto& r : rows) printf("%s\t%s\n", r.key.c_str(), r.val.c_str());
  fprintf(stderr, "rows=%zu\n", rows.size());
  return 0;
}
