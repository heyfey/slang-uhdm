// r10earl102 -- MEASUREMENT ONLY.  THE UNPACKED-DIMENSION BOUND CENSUS.
//
//   ct102cen <db.uhdm>
//
// Population: every `range` reachable, TOP-DOWN, from a scope root through a
// PARAMETER's own Ranges, through the array_typespec its Typespec() names, and
// through the array_typespec the param_assign's Rhs operation carries -- plus,
// as the MUST-NOT-MOVE control half, every array_var / array_net / io_decl
// Ranges vector in the same roots.  For each range, BOTH bounds are emitted as
// their own row (position L / R) so a one-sided fold is visible.
//
// Keyed TOP-DOWN by the field path, NEVER by VpiParent (the two producers park
// these objects on different parents and no generated Compare reads VpiParent).
//
// The payload is COMPARE-VISIBLE ONLY -- what range::Compare (VpiSize,
// Left_expr, Right_expr) and the bound's own Compare read:
//   constant  : kind|VpiSize|VpiConstType|VpiDecompile|VpiValue
//   operation : kind|VpiOpType|<per-operand payload>
//   ref_obj   : kind|VpiName|actual kind+name
//   other     : kind|VpiName
// It carries NO id, NO fullname and NO span, so object identity, parenting and
// position are invisible to the scorer, as they are to the judge.  The SPAN is
// emitted on a SEPARATE `SPN` row for diagnosis only and is NOT joined.
//
// Row format (tab separated):
//   RNG <view> <ownerkind> <ownerfullname> <site> <signal> <path> <payload>
//   SPN <view> <ownerkind> <ownerfullname> <site> <signal> <path> <span>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
using namespace UHDM;

static std::vector<std::string> rows;

static std::string kn(const BaseClass *o) {
  return o ? std::string(UHDM::UhdmName(o->UhdmType())) : std::string("<null>");
}
static std::string nmv(const BaseClass *o) {
  if (!o) return "-";
  std::string n(((const any *)o)->VpiName());
  return n.empty() ? std::string("~") : n;
}
static std::string spn(const BaseClass *o) {
  if (!o) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
// COMPARE-VISIBLE payload of a bound expression, recursive through operands.
static std::string bpay(const BaseClass *o, int depth) {
  if (!o) return "<null>";
  if (depth > 4) return "...";
  const any *a = (const any *)o;
  switch (o->UhdmType()) {
    case uhdmconstant: {
      const constant *c = (const constant *)o;
      char b[512];
      snprintf(b, sizeof b, "constant|sz=%d|ct=%d|dc=%s|v=%s", c->VpiSize(),
               c->VpiConstType(), std::string(c->VpiDecompile()).c_str(),
               std::string(c->VpiValue()).c_str());
      return b;
    }
    case uhdmoperation: {
      const operation *op = (const operation *)o;
      std::string s = "operation|op=" + std::to_string(op->VpiOpType()) + "|(";
      if (op->Operands()) {
        bool first = true;
        for (auto *x : *op->Operands()) {
          if (!first) s += ",";
          first = false;
          s += bpay(x, depth + 1);
        }
      }
      return s + ")";
    }
    case uhdmref_obj: {
      const ref_obj *r = (const ref_obj *)o;
      const any *act = r->Actual_group();
      return "ref_obj|" + nmv(o) + "|act=" +
             (act ? kn(act) + "[" + nmv(act) + "]" : std::string("-"));
    }
    case uhdmsys_func_call: {
      const sys_func_call *sc = (const sys_func_call *)o;
      std::string s = "sys_func_call|" + std::string(sc->VpiName()) + "|(";
      if (sc->Tf_call_args()) {
        bool first = true;
        for (auto *x : *sc->Tf_call_args()) {
          if (!first) s += ",";
          first = false;
          s += bpay(x, depth + 1);
        }
      }
      return s + ")";
    }
    case uhdmhier_path: {
      const hier_path *h = (const hier_path *)o;
      std::string s = "hier_path|" + std::string(h->VpiName()) + "|(";
      if (h->Path_elems()) {
        bool first = true;
        for (auto *x : *h->Path_elems()) {
          if (!first) s += ",";
          first = false;
          s += kn(x) + "[" + nmv(x) + "]";
        }
      }
      return s + ")";
    }
    default:
      break;
  }
  (void)a;
  return kn(o) + "|" + nmv(o);
}
// FORM: the one-word shape the law is keyed on.
static std::string form(const BaseClass *o) {
  if (!o) return "NONE";
  switch (o->UhdmType()) {
    case uhdmconstant: return "FOLDED";
    case uhdmoperation: return "OP";
    case uhdmref_obj: return "REF";
    case uhdmhier_path: return "HIER";
    case uhdmsys_func_call: return "SYS";
    default: return "OTHER";
  }
}

static std::string ownFull(const BaseClass *root) {
  if (const scope *sc = any_cast<const scope *>((const any *)root)) {
    std::string f(sc->VpiFullName());
    if (!f.empty()) return f;
  }
  return nmv(root);
}

static void emitRanges(const std::string &view, const BaseClass *root, const char *site,
                       const std::string &sig, const std::string &pathPfx,
                       const VectorOfrange *rs) {
  if (!rs) return;
  std::string rf = ownFull(root);
  int i = 0;
  for (auto *r : *rs) {
    const expr *bs[2] = {r->Left_expr(), r->Right_expr()};
    const char *pos[2] = {"L", "R"};
    for (int k = 0; k < 2; k++) {
      char p[256];
      snprintf(p, sizeof p, "%s[%d]%s", pathPfx.c_str(), i, pos[k]);
      char b[8192];
      snprintf(b, sizeof b, "RNG\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s", view.c_str(),
               kn(root).c_str(), rf.c_str(), site, sig.c_str(), p,
               form(bs[k]).c_str(), bpay(bs[k], 0).c_str());
      rows.push_back(b);
      char b2[4096];
      snprintf(b2, sizeof b2, "SPN\t%s\t%s\t%s\t%s\t%s\t%s\t%s\trange=%s", view.c_str(),
               kn(root).c_str(), rf.c_str(), site, sig.c_str(), p,
               spn(bs[k]).c_str(), spn(r).c_str());
      rows.push_back(b2);
    }
    i++;
  }
}

// Walk an array_typespec chain (an N-dim unpacked array is nested elems).
static void tsRanges(const std::string &view, const BaseClass *root, const char *site,
                     const std::string &sig, const std::string &pfx, const typespec *ts,
                     int depth) {
  if (!ts || depth > 4) return;
  if (ts->UhdmType() == uhdmarray_typespec) {
    const array_typespec *at = (const array_typespec *)ts;
    emitRanges(view, root, site, sig, pfx + ">ats", at->Ranges());
    if (const ref_typespec *e = at->Elem_typespec())
      tsRanges(view, root, site, sig, pfx + ">e", e->Actual_typespec(), depth + 1);
  }
}

static void doParam(const std::string &view, const BaseClass *root, const parameter *p) {
  std::string sig(p->VpiName());
  emitRanges(view, root, "PARAM", sig, "own", p->Ranges());
  if (const ref_typespec *rt = p->Typespec())
    tsRanges(view, root, "PARAM", sig, "ts", rt->Actual_typespec(), 0);
}

static void doScope(const std::string &view, const BaseClass *root, const scope *sc) {
  if (!sc) return;
  if (sc->Param_assigns())
    for (auto *pa : *sc->Param_assigns()) {
      const any *l = pa->Lhs();
      std::string sig = l ? std::string(l->VpiName()) : std::string("~");
      if (l && l->UhdmType() == uhdmparameter) doParam(view, root, (const parameter *)l);
      // the RHS's own typespec -- where Surelog parks the folded dim on an
      // assignment-pattern initializer (the r10earl102 head's own owner).
      if (const any *rh = pa->Rhs()) {
        const ref_typespec *rt = nullptr;
        if (rh->UhdmType() == uhdmoperation) rt = ((const operation *)rh)->Typespec();
        else if (rh->UhdmType() == uhdmconstant) rt = ((const constant *)rh)->Typespec();
        if (rt) tsRanges(view, root, "RHS", sig, "rhsts", rt->Actual_typespec(), 0);
      }
    }
  if (sc->Parameters())
    for (auto *p : *sc->Parameters())
      if (p->UhdmType() == uhdmparameter) doParam(view, root, (const parameter *)p);
  if (sc->Variables())
    for (auto *v : *sc->Variables())
      if (v->UhdmType() == uhdmarray_var)
        emitRanges(view, root, "AVAR", std::string(v->VpiName()), "own",
                   ((const array_var *)v)->Ranges());
}

int main(int argc, char **argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct102cen <db.uhdm>\n"); return 2; }
  Serializer s;
  auto r = s.Restore(std::string(argv[1]));
  if (r.empty()) { fprintf(stderr, "RESTORE_FAILED\n"); return 3; }

  std::set<const BaseClass *> defRoots;
  const design *dsn = nullptr;
  for (auto &pr : s.AllObjects()) if (pr.first && pr.first->UhdmType() == uhdmdesign) dsn = (const design *)pr.first;
  if (dsn && dsn->AllModules()) for (auto *m : *dsn->AllModules()) defRoots.insert(m);
  if (dsn && dsn->AllInterfaces()) for (auto *m : *dsn->AllInterfaces()) defRoots.insert(m);
  if (dsn && dsn->AllPrograms()) for (auto *m : *dsn->AllPrograms()) defRoots.insert(m);
  // A PACKAGE appears TWICE in both producers -- once in AllPackages (the DEF
  // listing) and once in TopPackages (the ELABORATED copy) -- under the SAME
  // VpiFullName.  They are DIFFERENT objects with DIFFERENT fold state, so the
  // census MUST key them apart or one silently overwrites the other.
  std::set<const BaseClass *> defPkgs;
  if (dsn && dsn->AllPackages()) for (auto *m : *dsn->AllPackages()) defPkgs.insert(m);

  // ARENA TALLY: every Ranges()-bearing object anywhere, by (ownerkind, form),
  // so a site the top-down walk cannot reach is still COUNTED.
  std::map<std::string, int> tally;

  for (auto &pr : s.AllObjects()) {
    const BaseClass *o = pr.first;
    if (!o) continue;
    const VectorOfrange *rs = nullptr;
    const any *a = (const any *)o;
#define TRY(T) if (!rs) if (const T *x = any_cast<const T *>(a)) rs = x->Ranges();
    TRY(array_net) TRY(array_var) TRY(array_typespec) TRY(bit_var)
    TRY(instance_array) TRY(int_typespec) TRY(packed_array_typespec)
    TRY(packed_array_net) TRY(logic_var) TRY(io_decl) TRY(logic_typespec)
    TRY(packed_array_var) TRY(parameter) TRY(unsupported_typespec)
    TRY(logic_net) TRY(bit_typespec)
#undef TRY
    if (rs)
      for (auto *rg : *rs) {
        tally[kn(o) + "|L|" + form(rg->Left_expr())]++;
        tally[kn(o) + "|R|" + form(rg->Right_expr())]++;
      }
    auto t = o->UhdmType();
    if (t != uhdmmodule_inst && t != uhdminterface_inst && t != uhdmpackage && t != uhdmprogram)
      continue;
    std::string view = (t == uhdmpackage) ? (defPkgs.count(o) ? "PD" : "PE")
                                          : (defRoots.count(o) ? "D" : "E");
    const scope *sc = any_cast<const scope *>((const any *)o);
    doScope(view, o, sc);
    if (const instance *in = any_cast<const instance *>((const any *)o)) {
      if (in->Array_nets())
        for (auto *n : *in->Array_nets())
          emitRanges(view, o, "ANET", std::string(n->VpiName()), "own",
                     ((const array_net *)n)->Ranges());
    }
  }
  std::sort(rows.begin(), rows.end());
  for (auto &l : rows) printf("%s\n", l.c_str());
  for (auto &kv : tally) printf("TALLY\t%s\t%d\n", kv.first.c_str(), kv.second);
  return 0;
}
