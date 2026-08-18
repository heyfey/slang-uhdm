// r10rgg13/acensus13.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is judge.
//
// THE CENSUS THIS PASS IS DECIDED BY: every CONSTANT (and every other operand)
// that sits at a CALL-ARGUMENT position inside a `param_assign` Rhs, in every
// view
//   DEF  = uhdmallModules + uhdmallInterfaces
//   ELAB = uhdmtopModules (gen scopes walked)
//   PKG  = uhdmallPackages (the verifier's view, r10vrgg11)
// keyed  (view, ARG, owning-instance FULL PATH, param_assign Lhs name,
//         callee name, argument index)
// and reporting, for each argument, exactly what decides § genLpPaCallArgCopy13:
//   * the argument's Compare-visible SHAPE (constant::Compare reads
//     VpiDecompile / VpiSize / Typespec / VpiConstType — VpiValue is NOT read
//     but is printed anyway, it is the human-readable half),
//   * `/P:<parent kind>@<l:c>` — THE COPY MARKER.  Surelog's
//     CompileExpression.cpp:2880-2883 sets `result->VpiParent(param_ass)` on
//     the CLONE of a parameter's own Rhs, so an argument whose parent is a
//     `param_assign` (and not the `func_call` that holds it) IS a copy of that
//     parameter's declaration constant.  vpiParent is invisible to uhdm-cmp;
//     it is a perfect census witness precisely because nothing else reads it.
//   * `/T:<typespec kind>@<l:c>` — the typespec IDENTITY by location: the
//     parameter's own declared typespec, or a fresh formal-typed one.
//
// Also censused, so the read positions can be RANKED against each other:
//   PA    every param_assign Rhs (shape + parent + typespec)
//   PORT  every instance port High_conn        (r10rgg11's position)
//   CA    every cont_assign Rhs                (r10rgg11's position)
//   POV   every parameter-override actual is the child instance's own PA row
//   RANGE every declaration range bound        (r10rgg12's position, R-A)
//
// LHS IS ALWAYS GOLDEN.  One database per run; the join is done in shell.
//
// TRAP INHERITED FROM r10rgg11/12: `UhdmName()` returns a string_view; handing
// it straight to printf("%s") writes raw bytes plus NULs and turns the census
// file BINARY, after which grep prints NOTHING AT ALL for patterns that DO
// match.  Every name is materialised into a std::string first.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <cstdio>
#include <string>
#include <vector>
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
static std::string locOf(const any* o) {
  if (!o) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u", o->VpiLineNo(), (unsigned)o->VpiColumnNo());
  return b;
}
static const typespec* actualTs(const any* o) {
  if (!o) return nullptr;
  if (auto* e = any_cast<const expr*>(o))
    if (auto* rt = e->Typespec()) return rt->Actual_typespec();
  return nullptr;
}
// parent kind + location: THE COPY MARKER (see the header).
static std::string parentTag(const any* o) {
  if (!o) return "-";
  const any* p = o->VpiParent();
  if (!p) return "P:<null>";
  return "P:" + kindOf(p) + "@" + locOf(p);
}
static std::string tsTag(const any* o) {
  const typespec* t = actualTs(o);
  if (!t) return "T:<none>";
  return "T:" + kindOf(t) + "@" + locOf(t);
}

static std::string eshape(const any* e, int depth = 0) {
  if (!e) return "<null>";
  if (depth > 6) return "...";
  char b[2048];
  switch (e->UhdmType()) {
    case uhdmconstant: {
      auto* c = (constant*)e;
      std::string v(c->VpiValue()), d(c->VpiDecompile());
      if (v.size() > 48) v = v.substr(0, 12) + "..[" + std::to_string(v.size()) +
                             "].." + v.substr(v.size() - 8);
      if (d.size() > 48) d = d.substr(0, 12) + "..[" + std::to_string(d.size()) +
                             "].." + d.substr(d.size() - 8);
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
    case uhdmbit_select:
      return "bitsel(" + nameOf(e) + ")";
    case uhdmpart_select:
      return "partsel(" + nameOf(e) + ")";
    case uhdmhier_path:
      return "hier(" + nameOf(e) + ")";
    default:
      return kindOf(e) + "(" + nameOf(e) + ")";
  }
}

struct Row { std::string key, val; };
static std::vector<Row> rows;

// Walk an expression; for every call node emit one ARG row per argument.
static void emitArgs(const std::string& view, const std::string& path,
                     const std::string& paName, const any* e, int depth,
                     const std::string& callPath) {
  if (!e || depth > 8) return;
  auto doCall = [&](const std::string& callee, const VectorOfany* args) {
    std::string cp = callPath.empty() ? callee : callPath + ">" + callee;
    if (!args) return;
    int i = 0;
    for (auto* a : *args) {
      char k[8192];
      snprintf(k, sizeof k, "%s|ARG|%s|%s|%s|%d", view.c_str(), path.c_str(),
               paName.c_str(), cp.c_str(), i);
      rows.push_back({k, eshape(a) + "/" + parentTag(a) + "/" + tsTag(a)});
      emitArgs(view, path, paName, a, depth + 1, cp);
      ++i;
    }
  };
  switch (e->UhdmType()) {
    case uhdmfunc_call:
      doCall("fc:" + nameOf(e), ((func_call*)e)->Tf_call_args());
      return;
    case uhdmsys_func_call:
      doCall("sfc:" + nameOf(e), ((sys_func_call*)e)->Tf_call_args());
      return;
    case uhdmoperation: {
      auto* op = (operation*)e;
      if (op->Operands())
        for (auto* o : *op->Operands())
          emitArgs(view, path, paName, o, depth + 1, callPath);
      return;
    }
    default:
      return;
  }
}

static void emitPA(const std::string& view, const std::string& path,
                   const VectorOfparam_assign* pas) {
  if (!pas) return;
  for (auto* pa : *pas) {
    std::string nm = pa->Lhs() ? nameOf(pa->Lhs()) : "-";
    char k[8192];
    snprintf(k, sizeof k, "%s|PA|%s|%s", view.c_str(), path.c_str(), nm.c_str());
    const any* r = pa->Rhs();
    rows.push_back({k, eshape(r) + "/" + parentTag(r) + "/" + tsTag(r)});
    emitArgs(view, path, nm, r, 0, "");
  }
}

static void emitPorts(const std::string& view, const std::string& path,
                      const VectorOfport* ps) {
  if (!ps) return;
  int i = 0;
  for (auto* p : *ps) {
    char k[8192];
    snprintf(k, sizeof k, "%s|PORT|%s|%d|%s", view.c_str(), path.c_str(), i,
             nameOf(p).c_str());
    const any* hc = p->High_conn();
    rows.push_back({k, eshape(hc) + "/" + parentTag(hc) + "/" + tsTag(hc)});
    ++i;
  }
}

static void emitCA(const std::string& view, const std::string& path,
                   const VectorOfcont_assign* cas) {
  if (!cas) return;
  int i = 0;
  for (auto* ca : *cas) {
    char k[8192];
    snprintf(k, sizeof k, "%s|CA|%s|%d|%s", view.c_str(), path.c_str(), i,
             ca->Lhs() ? nameOf(ca->Lhs()).c_str() : "-");
    const any* r = ca->Rhs();
    rows.push_back({k, eshape(r) + "/" + parentTag(r) + "/" + tsTag(r)});
    ++i;
  }
}

// ---- range bounds (r10rgg12's family, kept so R-A can be RANKED here) ----
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
    char k[8192];
    snprintf(k, sizeof k, "%s|RANGE|%s|%s|%s|%d|L", view.c_str(), path.c_str(),
             ownerkey.c_str(), container, i);
    rows.push_back({k, eshape(r->Left_expr())});
    snprintf(k, sizeof k, "%s|RANGE|%s|%s|%s|%d|R", view.c_str(), path.c_str(),
             ownerkey.c_str(), container, i);
    rows.push_back({k, eshape(r->Right_expr())});
    ++i;
  }
}
static void emitDecl(const std::string& view, const std::string& path,
                     const any* o) {
  if (!o) return;
  std::string ownerkey = kindOf(o) + ":" + nameOf(o);
  emitRanges(view, path, ownerkey, "SELF", rangesOf(o));
  if (const typespec* ts = tsOf(o)) {
    emitRanges(view, path, ownerkey, "TS", rangesOf(ts));
    if (ts->UhdmType() == uhdmpacked_array_typespec)
      if (auto* rt = ((packed_array_typespec*)ts)->Elem_typespec())
        emitRanges(view, path, ownerkey, "TSELEM", rangesOf(rt->Actual_typespec()));
    if (ts->UhdmType() == uhdmarray_typespec)
      if (auto* rt = ((array_typespec*)ts)->Elem_typespec())
        emitRanges(view, path, ownerkey, "TSELEM", rangesOf(rt->Actual_typespec()));
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
    emitPorts(view, path, m->Ports());
    emitCA(view, path, m->Cont_assigns());
    if (m->Ports()) for (auto* p : *m->Ports()) emitDecl(view, path, p);
    if (m->Modules())    for (auto* c : *m->Modules())    walkInstance(view, c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) walkInstance(view, c);
    if (m->Gen_scope_arrays())
      for (auto* ga : *m->Gen_scope_arrays()) walkScope(view, ga);
  } else if (in->UhdmType() == uhdminterface_inst) {
    auto* m = (interface_inst*)in;
    declsOf(view, path, m);
    emitPorts(view, path, m->Ports());
    emitCA(view, path, m->Cont_assigns());
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
    emitCA(view, path, g->Cont_assigns());
    if (g->Modules())    for (auto* c : *g->Modules())    walkInstance(view, c);
    if (g->Interfaces()) for (auto* c : *g->Interfaces()) walkInstance(view, c);
    if (g->Gen_scope_arrays())
      for (auto* ga : *g->Gen_scope_arrays()) walkScope(view, ga);
    return;
  }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: acensus13 <db>\n"); return 2; }
  Serializer s;
  auto restored = s.Restore(std::filesystem::path(argv[1]));
  if (restored.empty()) { fprintf(stderr, "FATAL: no design\n"); return 3; }
  for (auto h : restored) {
    auto* d = (design*)((const uhdm_handle*)h)->object;
    if (d->AllModules())    for (auto* m : *d->AllModules())    walkInstance("DEF", m);
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) walkInstance("DEF", m);
    if (d->TopModules())    for (auto* m : *d->TopModules())    walkInstance("ELAB", m);
    if (d->AllPackages())
      for (auto* p : *d->AllPackages()) {
        std::string path(p->VpiFullName());
        emitPA("PKG", path, p->Param_assigns());
      }
  }
  std::sort(rows.begin(), rows.end(),
            [](const Row& a, const Row& b) { return a.key < b.key; });
  for (auto& r : rows) printf("%s\t%s\n", r.key.c_str(), r.val.c_str());
  fprintf(stderr, "rows=%zu\n", rows.size());
  return 0;
}
