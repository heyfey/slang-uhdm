// r10rgg8/cacensus.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is the judge.
//
// THE CENSUS THIS PASS IS DECIDED BY: every cont_assign in a database, keyed
// (view, instance path, cont_assign file:line:col), reporting the SHAPE of its
// vpiRhs — func_call(name) / constant(ConstType,Size,Value,file:line) / other
// kind — plus the Lhs name.  Rows are printed in a stable sort order so
// golden-vs-golden is provably empty and golden-vs-ours is a pure diff.
//
// LHS IS ALWAYS GOLDEN.  This tool reads ONE database; the join is done in
// cacensus.py so each side's rows are visible on their own.
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

static std::string loc(const any* o) {
  if (!o) return "-";
  char b[512];
  snprintf(b, sizeof b, "%s:%u:%u", std::string(o->VpiFile()).c_str(),
           (unsigned)o->VpiLineNo(), (unsigned)o->VpiColumnNo());
  return b;
}
static std::string base(const std::string& p) {
  auto s = p.rfind('/');
  return s == std::string::npos ? p : p.substr(s + 1);
}
// LINE:COL ONLY.  OUR databases leave `VpiFile` UNSET on cont_assign objects
// while golden's carries the path, so a file-bearing key would report all 7620
// rows as differing and hide the ONE that matters.  `Compare` reads neither a
// file nor a span, so the census key drops the file and keeps line:col, which
// is unique inside a (view, scope path) pair.  The dropped fact is recorded by
// `--files` so it is measured, not forgotten.
static std::string locb(const any* o) {
  if (!o) return "-";
  char b[512];
  snprintf(b, sizeof b, "%u:%u", (unsigned)o->VpiLineNo(),
           (unsigned)o->VpiColumnNo());
  return b;
}

// The SHAPE string of an Rhs.  Only fields Compare reads for the kinds this
// pass touches; never a fullname, never a span EXCEPT the constant's own
// location, which IS the measured discriminator of this head (55:14 vs 40:27).
static std::string shape(const any* r) {
  if (!r) return "<null>";
  UHDM_OBJECT_TYPE t = r->UhdmType();
  char b[1024];
  if (t == uhdmfunc_call) {
    auto* f = (func_call*)r;
    size_t na = f->Tf_call_args() ? f->Tf_call_args()->size() : 0;
    std::string as;
    if (f->Tf_call_args())
      for (auto* a : *f->Tf_call_args()) {
        if (!as.empty()) as += "+";
        as += std::string(UhdmName(a->UhdmType()));
      }
    snprintf(b, sizeof b, "func_call(%s)/args=%zu[%s]@%s",
             std::string(f->VpiName()).c_str(), na, as.c_str(), locb(r).c_str());
    return b;
  }
  if (t == uhdmconstant) {
    auto* c = (constant*)r;
    snprintf(b, sizeof b, "constant(ct=%d,sz=%d,%s,dec=%s)@%s",
             c->VpiConstType(), c->VpiSize(), std::string(c->VpiValue()).c_str(),
             std::string(c->VpiDecompile()).c_str(), locb(r).c_str());
    return b;
  }
  if (t == uhdmoperation) {
    auto* o = (operation*)r;
    snprintf(b, sizeof b, "operation(op=%d,n=%zu)", o->VpiOpType(),
             o->Operands() ? o->Operands()->size() : 0);
    return b;
  }
  snprintf(b, sizeof b, "%s(%s)", std::string(UhdmName(t)).c_str(), std::string(r->VpiName()).c_str());
  return b;
}

static std::string lhsName(const cont_assign* ca) {
  const any* l = ca->Lhs();
  if (!l) return "-";
  return std::string(l->VpiName());
}

// Walk one instance scope (module_inst / gen_scope / interface / package):
// print its own cont_assigns then recurse.  The PATH is vpiFullName of the
// instance, which is the census key's instance component.
static std::vector<std::string> rows;

static void emitCa(const char* view, const std::string& path,
                   const VectorOfcont_assign* cas) {
  if (!cas) return;
  for (auto* ca : *cas) {
    char b[4096];
    snprintf(b, sizeof b, "%s\t%s\t%s\t%s\t%s", view, path.c_str(),
             locb(ca).c_str(), lhsName(ca).c_str(), shape(ca->Rhs()).c_str());
    rows.push_back(b);
  }
}

static void walkScope(const char* view, const any* sc, std::set<const any*>& seen);

static void walkStmts(const char* view, const std::string& path, const any* st,
                      std::set<const any*>& seen);

static void walkGen(const char* view, const VectorOfgen_scope_array* gsa,
                    std::set<const any*>& seen) {
  if (!gsa) return;
  for (auto* g : *gsa)
    if (g->Gen_scopes())
      for (auto* gs : *g->Gen_scopes()) walkScope(view, gs, seen);
}

static void walkScope(const char* view, const any* sc, std::set<const any*>& seen) {
  if (!sc || !seen.insert(sc).second) return;
  std::string path;
  if (auto* sco = any_cast<const scope*>(sc)) path = std::string(sco->VpiFullName());
  if (path.empty()) path = std::string(sc->VpiName());
  UHDM_OBJECT_TYPE t = sc->UhdmType();
  if (t == uhdmmodule_inst) {
    auto* m = (module_inst*)sc;
    emitCa(view, path, m->Cont_assigns());
    walkGen(view, m->Gen_scope_arrays(), seen);
    if (m->Modules())
      for (auto* c : *m->Modules()) walkScope(view, c, seen);
    if (m->Interfaces())
      for (auto* c : *m->Interfaces()) walkScope(view, c, seen);
    if (m->Interface_arrays())
      for (auto* ia : *m->Interface_arrays())
        if (ia->Instances())
          for (auto* c : *ia->Instances()) walkScope(view, c, seen);
    if (m->Module_arrays())
      for (auto* ma : *m->Module_arrays())
        if (ma->Modules())
          for (auto* c : *ma->Modules()) walkScope(view, c, seen);
  } else if (t == uhdmgen_scope) {
    auto* g = (gen_scope*)sc;
    emitCa(view, path, g->Cont_assigns());
    walkGen(view, g->Gen_scope_arrays(), seen);
    if (g->Modules())
      for (auto* c : *g->Modules()) walkScope(view, c, seen);
    if (g->Interfaces())
      for (auto* c : *g->Interfaces()) walkScope(view, c, seen);
  } else if (t == uhdminterface_inst) {
    auto* i = (interface_inst*)sc;
    emitCa(view, path, i->Cont_assigns());
    walkGen(view, i->Gen_scope_arrays(), seen);
  }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cacensus <db.uhdm>\n"); return 2; }
  Serializer s;
  auto restored = s.Restore(std::filesystem::path(argv[1]));
  if (restored.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
  for (auto h : restored) {
    auto* d = (design*)((const uhdm_handle*)h)->object;
    std::set<const any*> seenAll, seenTop;
    if (d->AllModules())
      for (auto* m : *d->AllModules()) walkScope("DEF", m, seenAll);
    if (d->AllInterfaces())
      for (auto* m : *d->AllInterfaces()) walkScope("DEF", m, seenAll);
    if (d->TopModules())
      for (auto* m : *d->TopModules()) walkScope("ELAB", m, seenTop);
  }
  std::sort(rows.begin(), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  fprintf(stderr, "rows=%zu\n", rows.size());
  return 0;
}
