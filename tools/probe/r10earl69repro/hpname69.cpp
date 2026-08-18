// r10earl69 — HIER_PATH NAME CENSUS, read straight from a .uhdm database.
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// One line per hier_path reachable from the cont_assign / port High_conn /
// param_assign / variable-init sites tscen69 already walks, keyed on the
// SECTION + owner instance path + site + positional route (never a span), with
// a payload that carries
//   * the hier_path's own VpiName (the field `hier_path::Compare` reads last),
//   * the name RE-RENDERED by a faithful re-implementation of Surelog's
//     `CompileHelper::decompileHelper` (CompileHelper.cpp:2544) over the
//     EMITTED Path_elems — the hypothesis this pass tests,
//   * per element: kind, VpiName, and for the index / base / width objects the
//     judge-visible fields (kind, VpiValue, VpiSize, VpiConstType,
//     VpiDecompile, typespec presence) and span PRESENCE + span (payload only).
//
//   build: g++ -O2 -std=c++17 hpname69.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o hpname69
//   usage: hpname69 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/ExprEval.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
using namespace UHDM;

static const char* SEC = "DEF";
static std::string OWN, INST;
static char SITE[256];

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
static bool located(const any* o) {
  return o->VpiLineNo() != 0 || o->VpiColumnNo() != 0;
}

// ---------------------------------------------------------------------------
// A faithful transcription of Surelog's CompileHelper::decompileHelper
// (Surelog/src/DesignCompile/CompileHelper.cpp:2544).  The dispatch is CLOSED:
// every kind not listed renders as the EMPTY STRING.
// ---------------------------------------------------------------------------
static std::string decompileHelper(const any* sel) {
  std::string out;
  ExprEval eval;
  if (sel == nullptr) return "";
  if (sel->UhdmType() == uhdmconstant) {
    out.append(((const expr*)sel)->VpiDecompile());
  } else if (sel->UhdmType() == uhdmref_obj) {
    out.append(((const expr*)sel)->VpiName());
  } else if (sel->UhdmType() == uhdmoperation) {
    out.append(eval.prettyPrint(sel));
  } else if (sel->UhdmType() == uhdmbit_select) {
    const expr* index = ((const bit_select*)sel)->VpiIndex();
    if (index == nullptr) {
    } else if (index->UhdmType() == uhdmconstant) {
      out.append("[").append(index->VpiDecompile()).append("]");
    } else if (index->UhdmType() == uhdmref_obj) {
      out.append("[").append(index->VpiName()).append("]");
    } else if (index->UhdmType() == uhdmoperation) {
      out.append("[" + eval.prettyPrint(index) + "]");
    }
  } else if (const part_select* p = any_cast<const part_select*>(sel)) {
    out += "[" + decompileHelper(p->Left_range()) + ":" +
           decompileHelper(p->Right_range()) + "]";
  } else if (const indexed_part_select* p =
                 any_cast<const indexed_part_select*>(sel)) {
    out += "[" + decompileHelper(p->Base_expr()) +
           ((p->VpiIndexedPartSelectType() == vpiPosIndexed) ? "+" : "-") +
           ":" + decompileHelper(p->Width_expr()) + "]";
  } else if (const var_select* p = any_cast<const var_select*>(sel)) {
    std::string sr;
    if (p->Exprs())
      for (auto* ex : *p->Exprs()) {
        std::string tmp = decompileHelper(ex);
        if (!tmp.empty() && tmp[0] != '[') sr += "[";
        sr += tmp;
        if (!tmp.empty() && tmp[0] != '[') sr += "]";
      }
    out += sr;
  }
  return out;
}

// Surelog assembles the hier_path name as: element0's NAME, then for each
// following element "." + its NAME + its own decompileHelper bracket text,
// EXCEPT that a bit_select / part_select / indexed_part_select / var_select
// element carries the field name in VpiName and its own brackets come from
// decompileHelper.  Reproduce that from the objects alone.
static std::string renderPathName(const hier_path* h) {
  std::string out;
  if (!h->Path_elems()) return out;
  bool first = true;
  for (auto* e : *h->Path_elems()) {
    std::string nm(e->VpiName());
    std::string brackets;
    switch (e->UhdmType()) {
      case uhdmref_obj: break;
      case uhdmbit_select:
      case uhdmpart_select:
      case uhdmindexed_part_select:
      case uhdmvar_select: brackets = decompileHelper(e); break;
      default: break;
    }
    if (first) { out = nm + brackets; first = false; }
    else if (nm.empty()) out += brackets;      // a trailing bare range element
    else out += "." + nm + brackets;
  }
  return out;
}

static std::string fieldsOf(const any* e) {
  char b[900];
  if (!e) return "-";
  if (e->UhdmType() == uhdmconstant) {
    auto* c = (const constant*)e;
    std::string ts = "none";
    if (auto* rt = c->Typespec()) {
      ts = "REF_NO_ACTUAL";
      if (auto* at = rt->Actual_typespec()) ts = std::string(UhdmName(at->UhdmType()));
    }
    snprintf(b, sizeof b, "constant:ct=%d,sz=%d,val=%s,dec=%s,ts=%s,loc=%d,span=%s",
             c->VpiConstType(), c->VpiSize(), esc(c->VpiValue()).c_str(),
             esc(c->VpiDecompile()).c_str(), ts.c_str(), located(c) ? 1 : 0,
             span(c).c_str());
  } else if (e->UhdmType() == uhdmref_obj) {
    auto* r = (const ref_obj*)e;
    std::string ak = "-";
    if (const any* a = r->Actual_group()) ak = std::string(UhdmName(a->UhdmType()));
    snprintf(b, sizeof b, "ref_obj:name=%s,actual=%s,loc=%d,span=%s",
             esc(r->VpiName()).c_str(), ak.c_str(), located(r) ? 1 : 0,
             span(r).c_str());
  } else {
    snprintf(b, sizeof b, "%s:name=%s,loc=%d,span=%s",
             std::string(UhdmName(e->UhdmType())).c_str(),
             esc(e->VpiName()).c_str(), located(e) ? 1 : 0, span(e).c_str());
  }
  return b;
}

static void emitHp(const std::string& path, const hier_path* h) {
  std::string elems;
  int n = 0;
  if (h->Path_elems())
    for (auto* e : *h->Path_elems()) {
      elems += (n ? "|" : "");
      elems += "e" + std::to_string(n) + "=" +
               std::string(UhdmName(e->UhdmType())) + ":" + esc(e->VpiName());
      switch (e->UhdmType()) {
        case uhdmbit_select:
          elems += "{idx=" + fieldsOf(((const bit_select*)e)->VpiIndex()) + "}";
          break;
        case uhdmpart_select:
          elems += "{l=" + fieldsOf(((const part_select*)e)->Left_range()) +
                   ";r=" + fieldsOf(((const part_select*)e)->Right_range()) + "}";
          break;
        case uhdmindexed_part_select:
          elems += "{b=" + fieldsOf(((const indexed_part_select*)e)->Base_expr()) +
                   ";w=" + fieldsOf(((const indexed_part_select*)e)->Width_expr()) + "}";
          break;
        case uhdmvar_select: {
          auto* vs = (const var_select*)e;
          if (vs->Exprs()) { int k = 0;
            for (auto* x : *vs->Exprs())
              elems += "{v" + std::to_string(k++) + "=" + fieldsOf(x) + "}"; }
          break; }
        default: break;
      }
      n++;
    }
  std::string rendered = renderPathName(h);
  printf("HP %s %s %s %s name=%s rendered=%s match=%d nelem=%d loc=%d span=%s %s\n",
         SEC, INST.c_str(), SITE, path.c_str(), esc(h->VpiName()).c_str(),
         esc(rendered).c_str(),
         (std::string(h->VpiName()) == rendered) ? 1 : 0, n, located(h) ? 1 : 0,
         span(h).c_str(), elems.empty() ? "-" : elems.c_str());
}

static void walk(const any* e, const std::string& path, int depth) {
  if (!e || depth > 40) return;
  switch (e->UhdmType()) {
    case uhdmbit_select:
      walk(((const bit_select*)e)->VpiIndex(), path + "/idx", depth + 1);
      return;
    case uhdmpart_select: {
      auto* p = (const part_select*)e;
      walk(p->Left_range(), path + "/l", depth + 1);
      walk(p->Right_range(), path + "/r", depth + 1);
      return; }
    case uhdmindexed_part_select: {
      auto* p = (const indexed_part_select*)e;
      walk(p->Base_expr(), path + "/b", depth + 1);
      walk(p->Width_expr(), path + "/w", depth + 1);
      return; }
    case uhdmvar_select: {
      auto* p = (const var_select*)e;
      if (p->Exprs()) { int i = 0;
        for (auto* x : *p->Exprs()) walk(x, path + "/e[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmhier_path: {
      auto* h = (const hier_path*)e;
      emitHp(path, h);
      if (h->Path_elems()) { int i = 0;
        for (auto* p : *h->Path_elems()) walk(p, path + "/hp[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmoperation: {
      auto* op = (const operation*)e;
      std::string me = path + "/op" + std::to_string(op->VpiOpType());
      if (op->Operands()) { int i = 0;
        for (auto* o : *op->Operands()) walk(o, me + "[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmtagged_pattern: {
      auto* tp = (const tagged_pattern*)e;
      std::string nm;
      if (auto* rt = tp->Typespec())
        if (auto* at = rt->Actual_typespec()) nm = std::string(at->VpiName());
      walk(tp->Pattern(), path + "/tp:" + nm, depth + 1);
      return; }
    case uhdmfunc_call: {
      auto* f = (const func_call*)e;
      if (f->Tf_call_args()) { int i = 0;
        for (auto* a : *f->Tf_call_args()) walk(a, path + "/arg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmsys_func_call: {
      auto* f = (const sys_func_call*)e;
      if (f->Tf_call_args()) { int i = 0;
        for (auto* a : *f->Tf_call_args()) walk(a, path + "/sarg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    default: return;
  }
}

static void do_ca(const VectorOfcont_assign* cas) {
  if (!cas) return;
  for (auto* ca : *cas) {
    snprintf(SITE, sizeof SITE, "CA_L%u:%u", ca->VpiLineNo(), ca->VpiColumnNo());
    walk(ca->Lhs(), "LHS", 0);
    walk(ca->Rhs(), "RHS", 0);
  }
}
static void do_ports(const VectorOfport* ps) {
  if (!ps) return;
  for (auto* p : *ps) {
    if (!p->High_conn()) continue;
    snprintf(SITE, sizeof SITE, "HC_%s_L%u:%u", esc(p->VpiName()).c_str(),
             p->VpiLineNo(), p->VpiColumnNo());
    walk(p->High_conn(), "HC", 0);
  }
}
static void do_pa(const VectorOfparam_assign* pas) {
  if (!pas) return;
  for (auto* pa : *pas) {
    if (!pa) continue;
    std::string nm = pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : std::string("-");
    snprintf(SITE, sizeof SITE, "PA_%s", esc(nm).c_str());
    walk(pa->Rhs(), "PA", 0);
  }
}
static void do_vars(const VectorOfvariables* vs) {
  if (!vs) return;
  for (auto* v : *vs) {
    if (!v->Expr()) continue;
    snprintf(SITE, sizeof SITE, "VAR_%s", esc(v->VpiName()).c_str());
    walk(v->Expr(), "VE", 0);
  }
}
static void do_nets(const VectorOfnet* ns) {
  if (!ns) return;
  for (auto* n : *ns) {
    if (!n || !n->Exprs()) continue;
    snprintf(SITE, sizeof SITE, "NET_%s", esc(n->VpiName()).c_str());
    int i = 0;
    for (auto* x : *n->Exprs())
      walk(x, "NE[" + std::to_string(i++) + "]", 0);
  }
}

static void do_scope(const scope* sc);
static void do_inst(const instance* in);

static void do_gsa(const VectorOfgen_scope_array* gsas) {
  if (!gsas) return;
  for (auto* ga : *gsas)
    if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) do_scope(g);
}
static void do_inst(const instance* in) {
  std::string saved = OWN, savedI = INST;
  if (!in->VpiDefName().empty()) OWN = std::string(in->VpiDefName());
  if (!in->VpiFullName().empty()) INST = std::string(in->VpiFullName());
  if (auto* m = any_cast<const module_inst*>(in)) {
    do_ca(m->Cont_assigns()); do_ports(m->Ports()); do_pa(m->Param_assigns());
    do_vars(m->Variables()); do_nets(m->Nets()); do_gsa(m->Gen_scope_arrays());
    if (m->Modules()) for (auto* c : *m->Modules()) do_inst(c);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) do_inst(c);
  } else if (auto* i = any_cast<const interface_inst*>(in)) {
    do_ca(i->Cont_assigns()); do_ports(i->Ports()); do_pa(i->Param_assigns());
    do_vars(i->Variables()); do_nets(i->Nets()); do_gsa(i->Gen_scope_arrays());
  }
  OWN = saved; INST = savedI;
}
static void do_scope(const scope* sc) {
  auto* g = any_cast<const gen_scope*>(sc);
  if (!g) return;
  std::string saved = INST;
  if (!g->VpiFullName().empty()) INST = std::string(g->VpiFullName());
  do_ca(g->Cont_assigns());
  do_pa(g->Param_assigns());
  do_vars(g->Variables());
  do_nets(g->Nets());
  if (g->Modules()) for (auto* c : *g->Modules()) do_inst(c);
  if (g->Interfaces()) for (auto* c : *g->Interfaces()) do_inst(c);
  do_gsa(g->Gen_scope_arrays());
  INST = saved;
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: hpname69 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    auto* d = any_cast<const design*>(o);
    if (!d) continue;
    SEC = "DEF";
    if (d->AllModules()) for (auto* m : *d->AllModules()) {
      OWN = std::string(m->VpiDefName()); INST = OWN;
      do_ca(m->Cont_assigns()); do_ports(m->Ports()); do_pa(m->Param_assigns());
      do_vars(m->Variables()); do_nets(m->Nets()); do_gsa(m->Gen_scope_arrays()); }
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) {
      OWN = std::string(m->VpiDefName()); INST = OWN;
      do_ca(m->Cont_assigns()); do_ports(m->Ports()); do_pa(m->Param_assigns());
      do_vars(m->Variables()); do_nets(m->Nets()); do_gsa(m->Gen_scope_arrays()); }
    SEC = "ELAB";
    if (d->TopModules()) for (auto* m : *d->TopModules()) do_inst(m);
  }
  return 0;
}
