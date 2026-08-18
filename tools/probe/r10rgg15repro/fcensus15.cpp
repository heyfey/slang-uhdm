// r10rgg15/fcensus15.cpp — MEASUREMENT ONLY.  The official uhdm-cmp is judge.
//
// THE CENSUS THIS PASS IS DECIDED BY: every `param_assign` in a database, in
// every view
//   DEF  = uhdmallModules + uhdmallInterfaces (definition instances)
//   ELAB = uhdmtopModules (elaborated tree, gen scopes walked)
//   PKG  = uhdmallPackages
// keyed  (view, OWNING scope FULL PATH, param_assign Lhs name)
// and reporting BOTH halves of the question this pass asks:
//   * the Rhs's Compare-visible SHAPE — `constant::Compare` reads VpiSize /
//     VpiConstType / VpiDecompile / VpiValue-through-expr (VpiValue itself is
//     printed for the human), so the payload is exactly the deciding field
//     set, plus `/LOC` vs `/LL` (does the constant carry a span at all?),
//   * the DECLARED TYPE of the parameter it initialises — kind, width,
//     signedness and whether the width came from a parameter — because THAT
//     is the axis the brief's law (a) is stated on.
//
// The `L:` tag carries the Rhs's own line:col so a DEFAULT (written in the
// module's own file) can be told apart from an OVERRIDE actual (written at the
// instantiation site) WITHOUT a second instrument.  vpiFile is printed as its
// BASENAME only, so the key survives a workdir move (dump paths embed the
// workdir — RESUME §9).
//
// TRAP INHERITED FROM r10rgg11/12/13: `UhdmName()` returns a string_view;
// handing it straight to printf("%s") writes raw bytes plus NULs and turns the
// census file BINARY, after which grep prints NOTHING AT ALL.  Every name is
// materialised into a std::string first.
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
static std::string baseName(std::string_view p) {
  auto s = p.rfind('/');
  return std::string(s == std::string_view::npos ? p : p.substr(s + 1));
}
static std::string locOf(const any* o) {
  if (!o) return "-";
  char b[256];
  snprintf(b, sizeof b, "%s:%u:%u", baseName(o->VpiFile()).c_str(),
           o->VpiLineNo(), (unsigned)o->VpiColumnNo());
  return b;
}
static const typespec* actualTs(const any* o) {
  if (!o) return nullptr;
  if (auto* e = any_cast<const expr*>(o))
    if (auto* rt = e->Typespec()) return rt->Actual_typespec();
  return nullptr;
}

static const VectorOfrange* rangesOf(const any* o) {
  if (!o) return nullptr;
  switch (o->UhdmType()) {
    case uhdmlogic_typespec:  return ((logic_typespec*)o)->Ranges();
    case uhdmbit_typespec:    return ((bit_typespec*)o)->Ranges();
    case uhdmint_typespec:    return ((int_typespec*)o)->Ranges();
    case uhdmarray_typespec:  return ((array_typespec*)o)->Ranges();
    case uhdmpacked_array_typespec: return ((packed_array_typespec*)o)->Ranges();
    case uhdmparameter:       return ((parameter*)o)->Ranges();
    default: return nullptr;
  }
}
static bool tsSigned(const typespec* t) {
  if (!t) return false;
  switch (t->UhdmType()) {
    case uhdmint_typespec:   return ((int_typespec*)t)->VpiSigned();
    case uhdmlogic_typespec: return ((logic_typespec*)t)->VpiSigned();
    case uhdmbit_typespec:   return ((bit_typespec*)t)->VpiSigned();
    case uhdminteger_typespec: return true;
    default: return false;
  }
}

static std::string eshape(const any* e, int depth = 0) {
  if (!e) return "<null>";
  if (depth > 5) return "...";
  char b[2048];
  switch (e->UhdmType()) {
    case uhdmconstant: {
      auto* c = (constant*)e;
      std::string v(c->VpiValue()), d(c->VpiDecompile());
      if (v.size() > 40) v = v.substr(0, 10) + "..[" + std::to_string(v.size()) +
                             "].." + v.substr(v.size() - 6);
      if (d.size() > 40) d = d.substr(0, 10) + "..[" + std::to_string(d.size()) +
                             "].." + d.substr(d.size() - 6);
      snprintf(b, sizeof b, "const(%s,sz=%d,ct=%d,dec=%s)%s", v.c_str(),
               c->VpiSize(), c->VpiConstType(), d.c_str(),
               (c->VpiLineNo() == 0 ? "/LL" : "/LOC"));
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
    case uhdmref_obj:    return "ref(" + nameOf(e) + ")";
    case uhdmbit_select: return "bitsel(" + nameOf(e) + ")";
    case uhdmhier_path:  return "hier(" + nameOf(e) + ")";
    case uhdmfunc_call:  return "fcall(" + nameOf(e) + ")";
    case uhdmsys_func_call: return "sfcall(" + nameOf(e) + ")";
    default: return kindOf(e) + "(" + nameOf(e) + ")";
  }
}

// The DECLARED TYPE of the parameter a param_assign writes: kind, width,
// signedness, range-bound shapes.  The range bounds are printed because the
// brief's axis "bit[N-1:0] with N a parameter" vs "bit[7:0] literal width" is
// only visible in them.
static std::string declTag(const any* lhs) {
  if (!lhs) return "D:<nolhs>";
  const typespec* t = actualTs(lhs);
  std::string r = "D:" + kindOf(t) + (tsSigned(t) ? ":S" : ":U");
  if (auto* p = any_cast<const parameter*>(lhs)) {
    r += ":lsz=" + std::to_string(p->VpiSize());
    r += p->VpiLocalParam() ? ":LP" : ":PP";
  }
  const VectorOfrange* rs = rangesOf(t);
  if (!rs) rs = rangesOf(lhs);
  if (rs) {
    r += ":R[";
    for (auto* q : *rs)
      r += eshape(q->Left_expr(), 4) + ".." + eshape(q->Right_expr(), 4) + ";";
    r += "]";
  }
  if (t) r += ":T@" + locOf(t);
  return r;
}

struct Row { std::string key, val; };
static std::vector<Row> rows;

static void emitPA(const std::string& view, const std::string& path,
                   const VectorOfparam_assign* pas) {
  if (!pas) return;
  for (auto* pa : *pas) {
    const any* lhs = pa->Lhs();
    std::string nm = lhs ? nameOf(lhs) : "-";
    char k[8192];
    snprintf(k, sizeof k, "%s|PA|%s|%s", view.c_str(), path.c_str(),
             nm.c_str());
    const any* r = pa->Rhs();
    rows.push_back({k, eshape(r) + "\t" + declTag(lhs) + "\tL:" + locOf(r) +
                           "\tPAL:" + locOf(pa) +
                           (pa->VpiOverriden() ? "\tOV:1" : "\tOV:0")});
  }
}

static void walkScope(const std::string& view, const any* o);

static void walkInstance(const std::string& view, const instance* in) {
  std::string path(in->VpiFullName());
  emitPA(view, path, in->Param_assigns());
  if (in->UhdmType() == uhdmmodule_inst) {
    auto* m = (module_inst*)in;
    if (m->Modules())    for (auto* c : *m->Modules())    walkInstance(view, c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) walkInstance(view, c);
    if (m->Gen_scope_arrays())
      for (auto* ga : *m->Gen_scope_arrays()) walkScope(view, ga);
  } else if (in->UhdmType() == uhdminterface_inst) {
    auto* m = (interface_inst*)in;
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
    if (g->Modules())    for (auto* c : *g->Modules())    walkInstance(view, c);
    if (g->Interfaces()) for (auto* c : *g->Interfaces()) walkInstance(view, c);
    if (g->Gen_scope_arrays())
      for (auto* ga : *g->Gen_scope_arrays()) walkScope(view, ga);
    return;
  }
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: fcensus15 <db>\n"); return 2; }
  Serializer s;
  auto restored = s.Restore(std::filesystem::path(argv[1]));
  if (restored.empty()) { fprintf(stderr, "FATAL: no design\n"); return 3; }
  for (auto h : restored) {
    auto* d = (design*)((const uhdm_handle*)h)->object;
    if (d->AllModules())    for (auto* m : *d->AllModules())    walkInstance("DEF", m);
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) walkInstance("DEF", m);
    if (d->TopModules())    for (auto* m : *d->TopModules())    walkInstance("ELAB", m);
    if (d->AllPackages())
      for (auto* p : *d->AllPackages())
        emitPA("PKG", std::string(p->VpiFullName()), p->Param_assigns());
  }
  std::sort(rows.begin(), rows.end(),
            [](const Row& a, const Row& b) { return a.key < b.key; });
  for (auto& r : rows) printf("%s\t%s\n", r.key.c_str(), r.val.c_str());
  fprintf(stderr, "rows=%zu\n", rows.size());
  return 0;
}
