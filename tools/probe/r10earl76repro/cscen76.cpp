// r10earl76 — CONSTANT **and REF_OBJ** census over cont_assigns, param_assigns,
// port High_conns and PROCESS BODIES, read straight out of a `.uhdm`
// (Earlgrey's uhdm-dump is >1 GB and is never produced).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// r10earl75repro/cscen75.cpp is the ancestor and answered "which folded
// CONSTANTS carry a ref_typespec".  r10earl76's head is a KIND flip, not a
// field flip — golden keeps a `ref_obj` bound to an `enum_const` where we emit
// a `constant` — so a constant-only census is structurally blind to it: our
// cell exists and golden's does not, which reads as "no golden cell" rather
// than as the over-fold it is.  This census emits BOTH kinds at the same
// (site, route, span) key, so the flip joins as one cell whose PAYLOAD begins
// with the object KIND.
//
// TWO ROUTE CHANGES vs cscen75, both required by question 2 (position split):
//   * every statement descent is TAGGED with the statement kind, so a `/c` in
//     a for header (`for:c`), a while condition (`whl:c`), a do-while
//     condition (`dow:c`), a repeat count (`rpt:c`) and an `if` condition
//     (`if:c`) are distinguishable ROUTES rather than the same one;
//   * the for statement's init / condition / step / body are `for:i[k]`,
//     `for:c`, `for:n[k]`, `for:b`.
//   (Routes therefore do NOT join with a cscen75 census.  Both sides of every
//   join in this pass are produced by THIS instrument.)
//
// THE TWO KEYING TRAPS cscen75 records are still avoided and still matter:
//  1. the object's own VpiParent is NOT a key (golden re-parents a fold at the
//     package parameter's param_assign; no generated Compare reads VpiParent);
//  2. UhdmListener::getCallstack() is NOT a key (it is the FIRST-VISIT route
//     through the typespec graph and differs between databases for reasons
//     unrelated to position).
//
// PAYLOAD = the JUDGE-VISIBLE fields only.  For a constant: VpiConstType,
// VpiSize, VpiValue, VpiDecompile and the ref_typespec / Actual_typespec kind,
// name, defname, signedness.  For a ref_obj / ref_var: VpiName, VpiDefName and
// the Actual_group's KIND, name, value, decompile and size — `ref_obj::Compare`
// reads Actual_group (RESUME §9), so an unbound ref and one bound to an
// enum_const are different cells.  earl60's lesson: a span-carrying PAYLOAD
// hides a flip, so the span is a KEY field and is never scored.
//
//   build: g++ -O2 -std=c++17 cscen76.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cscen76
//   usage: cscen76 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
using namespace UHDM;

static std::string OWN, SITE, OWNER;

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
// The SITE's VpiParent walk, kinds and names only (no span).  The DEF listing
// (ref_module <- named_begin <- gen_for) and the ELABORATED tree (module_inst
// <- gen_scope <- gen_scope_array) separate by construction, and a second live
// copy under the same chain joins as a multiset duplicate.
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o->VpiParent();
  for (int i = 0; i < 40 && p; i++) {
    std::string e(UhdmName(p->UhdmType()).data());
    if (!p->VpiName().empty()) e += "(" + esc(p->VpiName()) + ")";
    r = r.empty() ? e : (e + "/" + r);
    p = p->VpiParent();
  }
  if (r.empty()) r = "-";
  return r;
}
// HOME, read off the SITE's chain: generate nesting depth and DEF/ELAB section.
struct Ctx { int gendepth = 0; int genarray = 0; int sect = 0; };
static Ctx ctxOf(const any* o) {
  Ctx c;
  for (const any* p = o->VpiParent(); p; p = p->VpiParent()) {
    UHDM_OBJECT_TYPE t = p->UhdmType();
    if (t == uhdmgen_scope) c.gendepth++;
    if (t == uhdmgen_scope_array) c.genarray++;
    if (t == uhdmref_module) c.sect = 1;
  }
  return c;
}

static Ctx CTX;

static void emit(const std::string& path, const constant* c) {
  std::string ts = "-", tsp = "-", tsn = "-", tsdn = "-", rtn = "-";
  int tssgn = -1;
  if (auto* rt = c->Typespec()) {
    rtn = esc(rt->VpiName());
    ts = "REF_NO_ACTUAL";
    if (auto* at = rt->Actual_typespec()) {
      ts = std::string(UhdmName(at->UhdmType()).data());
      tsp = span(at);
      tsn = esc(at->VpiName());
      tsdn = esc(at->VpiDefName());
      if (at->UhdmType() == uhdmint_typespec)
        tssgn = ((const int_typespec*)at)->VpiSigned() ? 1 : 0;
      else if (at->UhdmType() == uhdminteger_typespec)
        tssgn = ((const integer_typespec*)at)->VpiSigned() ? 1 : 0;
    }
  }
  const any* par = c->VpiParent();
  printf("C %s %s %s %s gd=%d ga=%d %s span=%s | kind=constant ct=%d sz=%d val=%s dec=%s "
         "ts=%s tsname=%s tsdef=%s tssgn=%d rtname=%s || par=%s tsspan=%s\n",
         OWN.c_str(), OWNER.c_str(), SITE.c_str(), path.c_str(),
         CTX.gendepth, CTX.genarray, CTX.sect ? "DEF" : "ELAB",
         span(c).c_str(), c->VpiConstType(), c->VpiSize(),
         esc(c->VpiValue()).c_str(), esc(c->VpiDecompile()).c_str(),
         ts.c_str(), tsn.c_str(), tsdn.c_str(), tssgn, rtn.c_str(),
         par ? UhdmName(par->UhdmType()).data() : "-", tsp.c_str());
}

// A REF_OBJ / REF_VAR cell.  `ref_obj::Compare` walks Actual_group through
// BaseClass::SafeCompare, so the bound object's KIND and its own judged fields
// are payload; VpiFullName is NOT (no generated Compare reads it).
static void emitRef(const std::string& path, const any* r) {
  std::string kind(UhdmName(r->UhdmType()).data());
  std::string nm = esc(r->VpiName()), dn = "-", full = "-";
  const any* act = nullptr;
  if (r->UhdmType() == uhdmref_obj) {
    auto* ro = (const ref_obj*)r;
    dn = esc(ro->VpiDefName());
    full = esc(ro->VpiFullName());
    act = ro->Actual_group();
  } else if (r->UhdmType() == uhdmref_var) {
    auto* rv = (const ref_var*)r;
    dn = esc(rv->VpiDefName());
    full = esc(rv->VpiFullName());
    act = rv->Actual_group();
  }
  std::string ak = "<null>", an = "-", av = "-", ad = "-";
  int asz = -1;
  if (act) {
    ak = std::string(UhdmName(act->UhdmType()).data());
    an = esc(act->VpiName());
    // enum_const derives from BaseClass, NOT from expr, so an `expr` cast
    // MISSES IT and prints an empty payload for exactly the object this pass
    // is about (measured: `actval=- actdec=- actsz=-1` on cells whose
    // enum_const really carries `UINT:4` / `4` / 32).  Its judged fields are
    // VpiName, VpiDecompile and VpiSize (UHDM/build/generated/src/enum_const.cpp
    // + BaseClass::Compare); VpiValue is NOT judged and rides as evidence.
    if (act->UhdmType() == uhdmenum_const) {
      auto* ec = (const enum_const*)act;
      av = esc(ec->VpiValue());
      ad = esc(ec->VpiDecompile());
      asz = ec->VpiSize();
    } else if (auto* e2 = any_cast<const expr*>(act)) {
      av = esc(e2->VpiValue());
      ad = esc(e2->VpiDecompile());
      asz = e2->VpiSize();
    }
  }
  printf("R %s %s %s %s gd=%d ga=%d %s span=%s | kind=%s name=%s def=%s "
         "act=%s actname=%s actval=%s actdec=%s actsz=%d || full=%s\n",
         OWN.c_str(), OWNER.c_str(), SITE.c_str(), path.c_str(),
         CTX.gendepth, CTX.genarray, CTX.sect ? "DEF" : "ELAB",
         span(r).c_str(), kind.c_str(), nm.c_str(), dn.c_str(), ak.c_str(),
         an.c_str(), av.c_str(), ad.c_str(), asz,
         full.c_str());
}

static void walk(const any* e, const std::string& path, int depth);

static void walkStmt(const any* st, const std::string& path, int depth);

static void walk(const any* e, const std::string& path, int depth) {
  if (!e || depth > 40) return;
  switch (e->UhdmType()) {
    case uhdmconstant: emit(path, (const constant*)e); return;
    case uhdmref_obj: case uhdmref_var: emitRef(path, e); return;
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
        for (auto* x : *p->Exprs())
          walk(x, path + "/e[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmhier_path: {
      auto* h = (const hier_path*)e;
      if (h->Path_elems()) { int i = 0;
        for (auto* p : *h->Path_elems())
          walk(p, path + "/hp[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmoperation: {
      auto* op = (const operation*)e;
      std::string me = path + "/op" + std::to_string(op->VpiOpType());
      if (op->Operands()) { int i = 0;
        for (auto* o : *op->Operands())
          walk(o, me + "[" + std::to_string(i++) + "]", depth + 1); }
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
        for (auto* a : *f->Tf_call_args())
          walk(a, path + "/arg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmsys_func_call: {
      auto* f = (const sys_func_call*)e;
      if (f->Tf_call_args()) { int i = 0;
        for (auto* a : *f->Tf_call_args())
          walk(a, path + "/sarg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    default:
      // Anything else that is still a STATEMENT (a for-loop's init/incr are
      // assignments, an if's then/else are statements) descends as one.
      walkStmt(e, path, depth);
      return;
  }
}

// Statement descent.  Every UHDM statement kind that can hold an expression is
// listed; an unhandled kind is a SILENT HOLE, so the default arm prints nothing
// and the arm list below is the whole contract of this census.
static void walkStmt(const any* st, const std::string& path, int depth) {
  if (!st || depth > 40) return;
  switch (st->UhdmType()) {
    case uhdmbegin: {
      auto* b = (const begin*)st;
      if (b->Stmts()) { int i = 0;
        for (auto* s : *b->Stmts())
          walkStmt(s, path + "/s[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmnamed_begin: {
      auto* b = (const named_begin*)st;
      if (b->Stmts()) { int i = 0;
        for (auto* s : *b->Stmts())
          walkStmt(s, path + "/s[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmfork_stmt: {
      auto* b = (const fork_stmt*)st;
      if (b->Stmts()) { int i = 0;
        for (auto* s : *b->Stmts())
          walkStmt(s, path + "/s[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmnamed_fork: {
      auto* b = (const named_fork*)st;
      if (b->Stmts()) { int i = 0;
        for (auto* s : *b->Stmts())
          walkStmt(s, path + "/s[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmassignment: {
      auto* a = (const assignment*)st;
      walk(a->Lhs(), path + "/L", depth + 1);
      walk(a->Rhs(), path + "/R", depth + 1);
      walkStmt(a->Delay_control(), path + "/dc", depth + 1);
      return; }
    case uhdmassign_stmt: {
      auto* a = (const assign_stmt*)st;
      walk(a->Lhs(), path + "/L", depth + 1);
      walk(a->Rhs(), path + "/R", depth + 1);
      return; }
    case uhdmif_stmt: {
      auto* i = (const if_stmt*)st;
      walk(i->VpiCondition(), path + "/if:c", depth + 1);
      walkStmt(i->VpiStmt(), path + "/if:t", depth + 1);
      return; }
    case uhdmif_else: {
      auto* i = (const if_else*)st;
      walk(i->VpiCondition(), path + "/ie:c", depth + 1);
      walkStmt(i->VpiStmt(), path + "/ie:t", depth + 1);
      walkStmt(i->VpiElseStmt(), path + "/ie:e", depth + 1);
      return; }
    case uhdmcase_stmt: {
      auto* c = (const case_stmt*)st;
      walk(c->VpiCondition(), path + "/cs:c", depth + 1);
      if (c->Case_items()) { int i = 0;
        for (auto* ci : *c->Case_items()) {
          std::string p = path + "/cs:ci[" + std::to_string(i++) + "]";
          if (ci->VpiExprs()) { int j = 0;
            for (auto* x : *ci->VpiExprs())
              walk(x, p + "/x[" + std::to_string(j++) + "]", depth + 1); }
          walkStmt(ci->Stmt(), p + "/s", depth + 1);
        } }
      return; }
    case uhdmfor_stmt: {
      auto* f = (const for_stmt*)st;
      if (f->VpiForInitStmts()) { int i = 0;
        for (auto* s : *f->VpiForInitStmts())
          walkStmt(s, path + "/for:i[" + std::to_string(i++) + "]", depth + 1); }
      walkStmt(f->VpiForInitStmt(), path + "/for:i", depth + 1);
      walk(f->VpiCondition(), path + "/for:c", depth + 1);
      if (f->VpiForIncStmts()) { int i = 0;
        for (auto* s : *f->VpiForIncStmts())
          walkStmt(s, path + "/for:n[" + std::to_string(i++) + "]", depth + 1); }
      walkStmt(f->VpiForIncStmt(), path + "/for:n", depth + 1);
      walkStmt(f->VpiStmt(), path + "/for:b", depth + 1);
      return; }
    case uhdmforeach_stmt: {
      auto* f = (const foreach_stmt*)st;
      walkStmt(f->VpiStmt(), path + "/fe:b", depth + 1);
      return; }
    case uhdmwhile_stmt: {
      auto* w = (const while_stmt*)st;
      walk(w->VpiCondition(), path + "/whl:c", depth + 1);
      walkStmt(w->VpiStmt(), path + "/whl:b", depth + 1);
      return; }
    case uhdmdo_while: {
      auto* w = (const do_while*)st;
      walk(w->VpiCondition(), path + "/dow:c", depth + 1);
      walkStmt(w->VpiStmt(), path + "/dow:b", depth + 1);
      return; }
    case uhdmrepeat: {
      auto* r = (const repeat*)st;
      walk(r->VpiCondition(), path + "/rpt:c", depth + 1);
      walkStmt(r->VpiStmt(), path + "/rpt:b", depth + 1);
      return; }
    case uhdmforever_stmt:
      walkStmt(((const forever_stmt*)st)->VpiStmt(), path + "/fv:b", depth + 1);
      return;
    case uhdmevent_control: {
      auto* e = (const event_control*)st;
      walk(e->VpiCondition(), path + "/ev:ec", depth + 1);
      walkStmt(e->Stmt(), path + "/ev:b", depth + 1);
      return; }
    case uhdmdelay_control:
      walkStmt(((const delay_control*)st)->Stmt(), path + "/b", depth + 1);
      return;
    case uhdmcase_item:
      walkStmt(((const case_item*)st)->Stmt(), path + "/s", depth + 1);
      return;
    case uhdmimmediate_assert: {
      auto* a = (const immediate_assert*)st;
      walk(a->Expr(), path + "/x", depth + 1);
      walkStmt(a->Stmt(), path + "/b", depth + 1);
      walkStmt(a->Else_stmt(), path + "/e", depth + 1);
      return; }
    case uhdmimmediate_assume: {
      auto* a = (const immediate_assume*)st;
      walk(a->Expr(), path + "/x", depth + 1);
      walkStmt(a->Stmt(), path + "/b", depth + 1);
      walkStmt(a->Else_stmt(), path + "/e", depth + 1);
      return; }
    case uhdmimmediate_cover: {
      auto* a = (const immediate_cover*)st;
      walk(a->Expr(), path + "/x", depth + 1);
      walkStmt(a->Stmt(), path + "/b", depth + 1);
      return; }
    case uhdmtf_call: case uhdmfunc_call: case uhdmtask_call:
    case uhdmsys_func_call: case uhdmsys_task_call: {
      auto* t = (const tf_call*)st;
      if (t->Tf_call_args()) { int i = 0;
        for (auto* a : *t->Tf_call_args())
          walk(a, path + "/carg[" + std::to_string(i++) + "]", depth + 1); }
      return; }
    case uhdmreturn_stmt:
      walk(((const return_stmt*)st)->VpiCondition(), path + "/r", depth + 1);
      return;
    case uhdmoperation: case uhdmconstant: case uhdmbit_select:
    case uhdmpart_select: case uhdmindexed_part_select: case uhdmvar_select:
    case uhdmhier_path: case uhdmref_obj: case uhdmref_var:
      walk(st, path, depth);
      return;
    default: return;
  }
}

struct Cen : public UhdmListener {
  void site(const any* o, const char* kind, const std::string& s) {
    OWN = chainOf(o); OWNER = kind; SITE = s; CTX = ctxOf(o);
  }
  void enterPort(const port* const p) final {
    if (!p->High_conn()) return;
    char b[256];
    snprintf(b, sizeof b, "HC_%s_L%u:%u", esc(p->VpiName()).c_str(),
             p->VpiLineNo(), p->VpiColumnNo());
    site(p, "port_highconn", b);
    walk(p->High_conn(), "HC", 0);
  }
  void enterCont_assign(const cont_assign* const ca) final {
    char b[256];
    snprintf(b, sizeof b, "CA_L%u:%u", ca->VpiLineNo(), ca->VpiColumnNo());
    site(ca, "cont_assign", b);
    walk(ca->Lhs(), "LHS", 0);
    walk(ca->Rhs(), "RHS", 0);
  }
  void enterParam_assign(const param_assign* const pa) final {
    char b[256];
    snprintf(b, sizeof b, "PA_%s", pa->Lhs()
                 ? esc(pa->Lhs()->VpiName()).c_str() : "-");
    site(pa, "param_assign", b);
    walk(pa->Rhs(), "PA", 0);
  }
  void enterAlways(const always* const a) final {
    char b[256];
    snprintf(b, sizeof b, "AL%d_L%u:%u", a->VpiAlwaysType(), a->VpiLineNo(),
             a->VpiColumnNo());
    site(a, "always", b);
    walkStmt(a->Stmt(), "ST", 0);
  }
  void enterInitial(const initial* const a) final {
    char b[256];
    snprintf(b, sizeof b, "IN_L%u:%u", a->VpiLineNo(), a->VpiColumnNo());
    site(a, "initial", b);
    walkStmt(a->Stmt(), "ST", 0);
  }
  void enterFinal_stmt(const final_stmt* const a) final {
    char b[256];
    snprintf(b, sizeof b, "FI_L%u:%u", a->VpiLineNo(), a->VpiColumnNo());
    site(a, "final", b);
    walkStmt(a->Stmt(), "ST", 0);
  }
  void enterFunction(const function* const f) final {
    char b[256];
    snprintf(b, sizeof b, "FN_%s_L%u:%u", esc(f->VpiName()).c_str(),
             f->VpiLineNo(), f->VpiColumnNo());
    site(f, "function", b);
    walkStmt(f->Stmt(), "ST", 0);
  }
  void enterTask(const task* const f) final {
    char b[256];
    snprintf(b, sizeof b, "TK_%s_L%u:%u", esc(f->VpiName()).c_str(),
             f->VpiLineNo(), f->VpiColumnNo());
    site(f, "task", b);
    walkStmt(f->Stmt(), "ST", 0);
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cscen76 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  Cen c;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    if (auto* d = any_cast<const design*>(o)) c.listenDesign(d);
  }
  return 0;
}
