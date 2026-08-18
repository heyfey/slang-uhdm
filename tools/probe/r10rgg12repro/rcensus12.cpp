// r10rgg12/rcensus12.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is judge.
//
// THE CENSUS THIS PASS IS DECIDED BY: every RANGE BOUND reachable from a
// declaration in a database, in BOTH views
//   DEF  = uhdmallModules + uhdmallInterfaces (definition instances)
//   ELAB = uhdmtopModules (elaborated tree, gen scopes walked)
// keyed  (view, OWNING instance FULL PATH, owner kind:name, container, dim
//         index, L|R side)
// and reporting the bound expression's SHAPE, recursively, printing for a
// constant exactly the field set `constant::Compare` reads
//   const(<VpiValue>,sz=<VpiSize>,ct=<VpiConstType>,dec=<VpiDecompile>)
// so a census row that differs is a row uhdm-cmp can see.
//
// Also censused for the discriminator question of § elabVarRangeCallScopeDecl12
//   PA: every param_assign Rhs in the same scopes (the SHAPE of the Rhs of the
//       parameter a bound may read: constant / operation / func_call / ...)
//
// LHS IS ALWAYS GOLDEN.  One database per run; the join is done in shell.
//
// TRAP THIS INSTRUMENT INHERITS FROM r10rgg11: `UhdmName()` returns a
// string_view; handing it straight to printf("%s") writes raw bytes plus NULs
// and turns the census file BINARY, after which grep prints NOTHING AT ALL for
// patterns that DO match.  Every name is materialised into a std::string.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
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
static std::string nameOf(const any* o) {
  if (!o) return "";
  return std::string(o->VpiName());
}

// The Compare-visible shape of a bound expression, printed recursively.
static std::string eshape(const any* e, int depth = 0) {
  if (!e) return "<null>";
  if (depth > 6) return "...";
  char b[2048];
  switch (e->UhdmType()) {
    case uhdmconstant: {
      auto* c = (constant*)e;
      std::string v(c->VpiValue()), d(c->VpiDecompile());
      // A 400-bit BIN value is unreadable and irrelevant to the JOIN; keep the
      // full value only when short, otherwise its length and its tail.
      if (v.size() > 48) v = v.substr(0, 12) + "..[" + std::to_string(v.size()) + "].." +
                             v.substr(v.size() - 8);
      if (d.size() > 48) d = d.substr(0, 12) + "..[" + std::to_string(d.size()) + "].." +
                             d.substr(d.size() - 8);
      snprintf(b, sizeof b, "const(%s,sz=%d,ct=%d,dec=%s)", v.c_str(),
               c->VpiSize(), c->VpiConstType(), d.c_str());
      return b;
    }
    case uhdmoperation: {
      auto* op = (operation*)e;
      std::string r = "op" + std::to_string(op->VpiOpType()) + "[";
      if (op->Operands()) {
        bool first = true;
        for (auto* o : *op->Operands()) {
          if (!first) r += ",";
          first = false;
          r += eshape(o, depth + 1);
        }
      }
      return r + "]";
    }
    case uhdmfunc_call: {
      auto* fc = (func_call*)e;
      std::string r = "fcall:" + nameOf(fc) + "(";
      if (fc->Tf_call_args()) {
        bool first = true;
        for (auto* a : *fc->Tf_call_args()) {
          if (!first) r += ",";
          first = false;
          r += eshape(a, depth + 1);
        }
      }
      return r + ")";
    }
    case uhdmsys_func_call: {
      auto* fc = (sys_func_call*)e;
      std::string r = "sfcall:" + nameOf(fc) + "(";
      if (fc->Tf_call_args()) {
        bool first = true;
        for (auto* a : *fc->Tf_call_args()) {
          if (!first) r += ",";
          first = false;
          r += eshape(a, depth + 1);
        }
      }
      return r + ")";
    }
    case uhdmref_obj:
      return "ref(" + nameOf(e) + ")";
    default:
      return kindOf(e) + "(" + nameOf(e) + ")";
  }
}

struct Row { std::string key, val; };
static std::vector<Row> rows;

static const VectorOfrange* rangesOf(const any* o) {
  if (!o) return nullptr;
  switch (o->UhdmType()) {
    case uhdmlogic_typespec:  return ((logic_typespec*)o)->Ranges();
    case uhdmbit_typespec:    return ((bit_typespec*)o)->Ranges();
    case uhdmint_typespec:    return ((int_typespec*)o)->Ranges();
    case uhdmarray_typespec:  return ((array_typespec*)o)->Ranges();
    case uhdmpacked_array_typespec: return ((packed_array_typespec*)o)->Ranges();
    case uhdmunsupported_typespec:  return ((unsupported_typespec*)o)->Ranges();
    case uhdmlogic_var:       return ((logic_var*)o)->Ranges();
    case uhdmbit_var:         return ((bit_var*)o)->Ranges();
    case uhdmarray_var:       return ((array_var*)o)->Ranges();
    case uhdmpacked_array_var:return ((packed_array_var*)o)->Ranges();
    case uhdmlogic_net:       return ((logic_net*)o)->Ranges();
    case uhdmarray_net:       return ((array_net*)o)->Ranges();
    case uhdmpacked_array_net:return ((packed_array_net*)o)->Ranges();
    case uhdmparameter:       return ((parameter*)o)->Ranges();
    case uhdmio_decl:         return ((io_decl*)o)->Ranges();
    default: return nullptr;
  }
}

static const typespec* tsOf(const any* o) {
  if (!o) return nullptr;
  if (auto* e = any_cast<const expr*>(o))
    if (auto* rt = e->Typespec()) return rt->Actual_typespec();
  if (auto* v = any_cast<const variables*>(o))
    if (auto* rt = v->Typespec()) return rt->Actual_typespec();
  if (auto* n = any_cast<const nets*>(o))
    if (auto* rt = n->Typespec()) return rt->Actual_typespec();
  if (auto* p = any_cast<const ports*>(o))
    if (auto* rt = p->Typespec()) return rt->Actual_typespec();
  if (auto* i = any_cast<const io_decl*>(o))
    if (auto* rt = i->Typespec()) return rt->Actual_typespec();
  return nullptr;
}

static void emitRanges(const std::string& view, const std::string& path,
                       const std::string& ownerkey, const char* container,
                       const VectorOfrange* rs) {
  if (!rs) return;
  int i = 0;
  for (auto* r : *rs) {
    char k[6144];
    snprintf(k, sizeof k, "%s|RANGE|%s|%s|%s|%d|L", view.c_str(), path.c_str(),
             ownerkey.c_str(), container, i);
    rows.push_back({k, eshape(r->Left_expr())});
    snprintf(k, sizeof k, "%s|RANGE|%s|%s|%s|%d|R", view.c_str(), path.c_str(),
             ownerkey.c_str(), container, i);
    rows.push_back({k, eshape(r->Right_expr())});
    ++i;
  }
}

// The declaration's own ranges, then the ranges of its typespec chain (one
// packed level of elem typespec is followed; deeper nesting is out of the
// family this pass names and would only add unjoinable keys).
static void emitDecl(const std::string& view, const std::string& path,
                     const any* o) {
  if (!o) return;
  std::string ownerkey = kindOf(o) + ":" + nameOf(o);
  emitRanges(view, path, ownerkey, "SELF", rangesOf(o));
  if (const typespec* ts = tsOf(o)) {
    emitRanges(view, path, ownerkey, "TS", rangesOf(ts));
    if (ts->UhdmType() == uhdmpacked_array_typespec) {
      if (auto* rt = ((packed_array_typespec*)ts)->Elem_typespec())
        emitRanges(view, path, ownerkey, "TSELEM", rangesOf(rt->Actual_typespec()));
    }
    if (ts->UhdmType() == uhdmarray_typespec) {
      if (auto* rt = ((array_typespec*)ts)->Elem_typespec())
        emitRanges(view, path, ownerkey, "TSELEM", rangesOf(rt->Actual_typespec()));
    }
  }
}

static void emitPA(const std::string& view, const std::string& path,
                   const VectorOfparam_assign* pas) {
  if (!pas) return;
  for (auto* pa : *pas) {
    char k[6144];
    snprintf(k, sizeof k, "%s|PA|%s|%s", view.c_str(), path.c_str(),
             pa->Lhs() ? nameOf(pa->Lhs()).c_str() : "-");
    rows.push_back({k, eshape(pa->Rhs())});
  }
}

static void walkScope(const std::string& view, const any* o);

template <class T>
static void declsOf(const std::string& view, const std::string& path, T* m) {
  if (m->Variables()) for (auto* v : *m->Variables()) emitDecl(view, path, v);
  if (m->Nets())      for (auto* v : *m->Nets())      emitDecl(view, path, v);
  if (m->Array_nets())for (auto* v : *m->Array_nets())emitDecl(view, path, v);
  if (m->Parameters())for (auto* v : *m->Parameters())emitDecl(view, path, v);
}

static void walkInstance(const std::string& view, const instance* in) {
  std::string path(in->VpiFullName());
  emitPA(view, path, in->Param_assigns());
  if (in->UhdmType() == uhdmmodule_inst) {
    auto* m = (module_inst*)in;
    declsOf(view, path, m);
    if (m->Ports()) for (auto* p : *m->Ports()) emitDecl(view, path, p);
    if (m->Modules())    for (auto* c : *m->Modules())    walkInstance(view, c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) walkInstance(view, c);
    if (m->Gen_scope_arrays())
      for (auto* ga : *m->Gen_scope_arrays()) walkScope(view, ga);
  } else if (in->UhdmType() == uhdminterface_inst) {
    auto* m = (interface_inst*)in;
    declsOf(view, path, m);
    if (m->Ports()) for (auto* p : *m->Ports()) emitDecl(view, path, p);
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
    declsOf(view, path, g);
    if (g->Modules())    for (auto* c : *g->Modules())    walkInstance(view, c);
    if (g->Interfaces()) for (auto* c : *g->Interfaces()) walkInstance(view, c);
    if (g->Gen_scope_arrays())
      for (auto* ga : *g->Gen_scope_arrays()) walkScope(view, ga);
    return;
  }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: rcensus12 <db>\n"); return 2; }
  Serializer s;
  auto restored = s.Restore(std::filesystem::path(argv[1]));
  if (restored.empty()) { fprintf(stderr, "FATAL: no design\n"); return 3; }
  for (auto h : restored) {
    auto* d = (design*)((const uhdm_handle*)h)->object;
    if (d->AllModules())    for (auto* m : *d->AllModules())    walkInstance("DEF", m);
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) walkInstance("DEF", m);
    if (d->TopModules())    for (auto* m : *d->TopModules())    walkInstance("ELAB", m);
  }
  std::sort(rows.begin(), rows.end(),
            [](const Row& a, const Row& b) { return a.key < b.key; });
  for (auto& r : rows) printf("%s\t%s\n", r.key.c_str(), r.val.c_str());
  fprintf(stderr, "rows=%zu\n", rows.size());
  return 0;
}
