// r10earl75 — CONSTANT census over cont_assigns, param_assigns, port High_conns
// AND PROCESS BODIES, read straight out of a `.uhdm` (Earlgrey's uhdm-dump is
// >1 GB and is never produced).
//
// MEASUREMENT ONLY.  The official uhdm-cmp stays the sole judge.
//
// Answers r10earl75 question 1: WHICH folded constants carry a `ref_typespec`
// in golden, keyed so that golden and ours join on the SAME cell —
//   OWNER  the site kind (cont_assign / always / initial / param_assign /
//          port High_conn / task / function)
//   HOME   the site's VpiParent scope chain, which carries the generate
//          nesting (module_inst / gen_scope / gen_scope_array / ref_module)
//   ROUTE  the positional path from the site root down to the constant
//   SPAN   the constant's own file:line:col
//
// TWO KEYING TRAPS THIS INSTRUMENT AVOIDS, each of which cost a measurement:
//
//  1. The CONSTANT's own VpiParent is NOT a key.  Golden RE-PARENTS a
//     replication-count fold at the package parameter's `param_assign`
//     (r10earl14's § caOpFoldTs records the split) while we leave it under its
//     operation.  No generated `Compare` reads VpiParent, so the judge cannot
//     see that; a VpiParent-keyed census would manufacture a phantom AWAY cell
//     for every re-parented constant.  The SITE's chain is used instead.
//  2. `UhdmListener::getCallstack()` is NOT a key either.  It is the route the
//     listener took on FIRST visit, which wanders through the whole typespec
//     graph before it reaches the instance tree, and it differs between the two
//     databases for reasons that have nothing to do with position.
//
// r10earl72repro/tscen72.cpp is the ancestor; it drove off three hand-picked
// CONTAINERS and was therefore BLIND to every constant inside a PROCESS — which
// is exactly where r10earl74's R0 head lives (`prog_data_packed =
// {DataWidth{1'b1}};` in an always_comb of a generate block).
//
// PAYLOAD = the JUDGE-VISIBLE fields only: VpiConstType, VpiSize, VpiValue,
// VpiDecompile, and the ref_typespec / Actual_typespec kind, name, defname and
// signedness.  earl60's lesson: a span-carrying PAYLOAD hides a flip, so the
// span is a key field and is never scored.
//
//   build: g++ -O2 -std=c++17 cscen75.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o cscen75
//   usage: cscen75 <db.uhdm>
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
  printf("C %s %s %s %s gd=%d ga=%d %s span=%s | ct=%d sz=%d val=%s dec=%s "
         "ts=%s tsname=%s tsdef=%s tssgn=%d rtname=%s || par=%s tsspan=%s\n",
         OWN.c_str(), OWNER.c_str(), SITE.c_str(), path.c_str(),
         CTX.gendepth, CTX.genarray, CTX.sect ? "DEF" : "ELAB",
         span(c).c_str(), c->VpiConstType(), c->VpiSize(),
         esc(c->VpiValue()).c_str(), esc(c->VpiDecompile()).c_str(),
         ts.c_str(), tsn.c_str(), tsdn.c_str(), tssgn, rtn.c_str(),
         par ? UhdmName(par->UhdmType()).data() : "-", tsp.c_str());
}

static void walk(const any* e, const std::string& path, int depth);

static void walkStmt(const any* st, const std::string& path, int depth);

static void walk(const any* e, const std::string& path, int depth) {
  if (!e || depth > 40) return;
  switch (e->UhdmType()) {
    case uhdmconstant: emit(path, (const constant*)e); return;
    case uhdmref_obj: case uhdmref_var: return;
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
      walk(i->VpiCondition(), path + "/c", depth + 1);
      walkStmt(i->VpiStmt(), path + "/t", depth + 1);
      return; }
    case uhdmif_else: {
      auto* i = (const if_else*)st;
      walk(i->VpiCondition(), path + "/c", depth + 1);
      walkStmt(i->VpiStmt(), path + "/t", depth + 1);
      walkStmt(i->VpiElseStmt(), path + "/e", depth + 1);
      return; }
    case uhdmcase_stmt: {
      auto* c = (const case_stmt*)st;
      walk(c->VpiCondition(), path + "/c", depth + 1);
      if (c->Case_items()) { int i = 0;
        for (auto* ci : *c->Case_items()) {
          std::string p = path + "/ci[" + std::to_string(i++) + "]";
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
          walkStmt(s, path + "/i[" + std::to_string(i++) + "]", depth + 1); }
      walkStmt(f->VpiForInitStmt(), path + "/i", depth + 1);
      walk(f->VpiCondition(), path + "/c", depth + 1);
      if (f->VpiForIncStmts()) { int i = 0;
        for (auto* s : *f->VpiForIncStmts())
          walkStmt(s, path + "/n[" + std::to_string(i++) + "]", depth + 1); }
      walkStmt(f->VpiForIncStmt(), path + "/n", depth + 1);
      walkStmt(f->VpiStmt(), path + "/b", depth + 1);
      return; }
    case uhdmforeach_stmt: {
      auto* f = (const foreach_stmt*)st;
      walkStmt(f->VpiStmt(), path + "/b", depth + 1);
      return; }
    case uhdmwhile_stmt: {
      auto* w = (const while_stmt*)st;
      walk(w->VpiCondition(), path + "/c", depth + 1);
      walkStmt(w->VpiStmt(), path + "/b", depth + 1);
      return; }
    case uhdmdo_while: {
      auto* w = (const do_while*)st;
      walk(w->VpiCondition(), path + "/c", depth + 1);
      walkStmt(w->VpiStmt(), path + "/b", depth + 1);
      return; }
    case uhdmrepeat: {
      auto* r = (const repeat*)st;
      walk(r->VpiCondition(), path + "/c", depth + 1);
      walkStmt(r->VpiStmt(), path + "/b", depth + 1);
      return; }
    case uhdmforever_stmt:
      walkStmt(((const forever_stmt*)st)->VpiStmt(), path + "/b", depth + 1);
      return;
    case uhdmevent_control: {
      auto* e = (const event_control*)st;
      walk(e->VpiCondition(), path + "/ec", depth + 1);
      walkStmt(e->Stmt(), path + "/b", depth + 1);
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
  if (argc < 2) { fprintf(stderr, "usage: cscen75 <db.uhdm>\n"); return 2; }
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
