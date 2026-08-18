// r10rgg9/gridscan9.cpp (derived from r10rgg8/gridscan.cpp) — MEASUREMENT ONLY.  uhdm-cmp remains the sole judge.
//
// Reports the SHAPE of every value-bearing slot a user function call can sit
// in, per VIEW and per INSTANCE PATH, so a golden and a slang database can be
// joined role-for-role:
//
//   CA     cont_assign        vpiRhs
//   PA     param_assign       vpiRhs
//   ASSIGN assignment (proc)  vpiRhs
//   PORT   port               vpiHighConn
//   VAR    variable           vpiExpr (var-decl init)
//
// The KEY is (view, scope path, role, line:col, name); the VALUE is the kind
// and — for a constant — its vpiConstType / vpiSize / value / decompile and its
// OWN line:col, because THIS pass's discriminator is precisely whether the
// folded constant carries the RETURN LITERAL's location or the call site's.
//
// `VpiFile` is deliberately NOT in the key: our databases leave it unset on
// cont_assign objects while golden's carries the path, and `Compare` reads
// neither a file nor a span.
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <set>
#include <algorithm>
#include <filesystem>

using namespace UHDM;

static std::string lc(const any* o) {
  if (!o) return "-";
  char b[128];
  snprintf(b, sizeof b, "%u:%u", (unsigned)o->VpiLineNo(),
           (unsigned)o->VpiColumnNo());
  return b;
}

static std::string shape(const any* r) {
  if (!r) return "<null>";
  UHDM_OBJECT_TYPE t = r->UhdmType();
  char b[1024];
  if (t == uhdmfunc_call) {
    auto* f = (func_call*)r;
    std::string as;
    if (f->Tf_call_args())
      for (auto* a : *f->Tf_call_args()) {
        if (!as.empty()) as += "+";
        as += std::string(UhdmName(a->UhdmType()));
      }
    snprintf(b, sizeof b, "func_call(%s)[%s]@%s",
             std::string(f->VpiName()).c_str(), as.c_str(), lc(r).c_str());
    return b;
  }
  if (t == uhdmconstant) {
    auto* c = (constant*)r;
    snprintf(b, sizeof b, "constant(ct=%d,sz=%d,%s,dec=%s)@%s%s",
             c->VpiConstType(), c->VpiSize(), std::string(c->VpiValue()).c_str(),
             std::string(c->VpiDecompile()).c_str(), lc(r).c_str(),
             (r->VpiLineNo() == 0 ? "[LOCLESS]" : ""));
    return b;
  }
  if (t == uhdmoperation) {
    auto* o = (operation*)r;
    std::string os;
    if (o->Operands())
      for (auto* a : *o->Operands()) {
        if (!os.empty()) os += "|";
        UHDM_OBJECT_TYPE at = a->UhdmType();
        if (at == uhdmconstant) {
          auto* c2 = (constant*)a;
          char t2[256];
          snprintf(t2, sizeof t2, "const(ct=%d,sz=%d,%s)", c2->VpiConstType(),
                   c2->VpiSize(), std::string(c2->VpiValue()).c_str());
          os += t2;
        } else if (at == uhdmoperation) {
          char t2[64];
          snprintf(t2, sizeof t2, "op%d", ((operation*)a)->VpiOpType());
          os += t2;
        } else {
          os += std::string(UhdmName(at));
          if (!a->VpiName().empty()) { os += ":"; os += std::string(a->VpiName()); }
        }
      }
    snprintf(b, sizeof b, "operation(op=%d,n=%zu)[%s]", o->VpiOpType(),
             o->Operands() ? o->Operands()->size() : 0, os.c_str());
    return b;
  }
  snprintf(b, sizeof b, "%s(%s)", std::string(UhdmName(t)).c_str(),
           std::string(r->VpiName()).c_str());
  return b;
}

static std::vector<std::string> rows;
static void row(const char* view, const std::string& path, const char* role,
                const any* holder, const std::string& name, const any* val) {
  char b[8192];
  snprintf(b, sizeof b, "%s\t%s\t%s\t%s\t%s\t%s", view, path.c_str(), role,
           lc(holder).c_str(), name.c_str(), shape(val).c_str());
  rows.push_back(b);
}

static void walkStmt(const char* view, const std::string& path, const any* st) {
  if (!st) return;
  UHDM_OBJECT_TYPE t = st->UhdmType();
  if (t == uhdmbegin || t == uhdmnamed_begin) {
    auto* b = (begin*)st;
    if (b->Stmts()) for (auto* s2 : *b->Stmts()) walkStmt(view, path, s2);
  } else if (t == uhdmassignment) {
    auto* a = (assignment*)st;
    std::string n = a->Lhs() ? std::string(a->Lhs()->VpiName()) : "-";
    row(view, path, "ASSIGN", a, n, a->Rhs());
  } else if (t == uhdmif_stmt || t == uhdmif_else) {
    auto* i = (if_stmt*)st;
    walkStmt(view, path, i->VpiStmt());
    if (t == uhdmif_else) walkStmt(view, path, ((if_else*)st)->VpiElseStmt());
  } else if (t == uhdmfor_stmt) {
    walkStmt(view, path, ((for_stmt*)st)->VpiStmt());
  } else if (t == uhdmcase_stmt) {
    auto* c = (case_stmt*)st;
    if (c->Case_items()) for (auto* ci : *c->Case_items()) walkStmt(view, path, ci->Stmt());
  }
}

static void walkScope(const char* view, const any* sc, std::set<const any*>& seen);

static void common(const char* view, const std::string& path, const scope* sc) {
  // param_assigns
  if (auto* m = any_cast<const instance*>(sc)) {
    if (m->Param_assigns())
      for (auto* pa : *m->Param_assigns())
        row(view, path, "PA", pa, pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : "-",
            pa->Rhs());
  }
  if (auto* g = any_cast<const gen_scope*>(sc)) {
    if (g->Param_assigns())
      for (auto* pa : *g->Param_assigns())
        row(view, path, "PA", pa, pa->Lhs() ? std::string(pa->Lhs()->VpiName()) : "-",
            pa->Rhs());
  }
  if (auto* v = any_cast<const scope*>(sc)) {
    if (v->Variables())
      for (auto* vr : *v->Variables())
        if (vr->Expr()) row(view, path, "VAR", vr, std::string(vr->VpiName()), vr->Expr());
  }
}

static void walkScope(const char* view, const any* sc, std::set<const any*>& seen) {
  if (!sc || !seen.insert(sc).second) return;
  std::string path;
  if (auto* sco = any_cast<const scope*>(sc)) path = std::string(sco->VpiFullName());
  if (path.empty()) path = std::string(sc->VpiName());
  UHDM_OBJECT_TYPE t = sc->UhdmType();
  const VectorOfcont_assign* cas = nullptr;
  const VectorOfprocess_stmt* prs = nullptr;
  const VectorOfgen_scope_array* gsa = nullptr;
  if (t == uhdmmodule_inst) {
    auto* m = (module_inst*)sc;
    cas = m->Cont_assigns(); prs = m->Process(); gsa = m->Gen_scope_arrays();
    common(view, path, m);
    if (m->Ports())
      for (auto* p : *m->Ports())
        if (p->High_conn()) row(view, path, "PORT", p, std::string(p->VpiName()),
                                p->High_conn());
    if (m->Modules()) for (auto* c : *m->Modules()) walkScope(view, c, seen);
    if (m->Interfaces()) for (auto* c : *m->Interfaces()) walkScope(view, c, seen);
  } else if (t == uhdmgen_scope) {
    auto* g = (gen_scope*)sc;
    cas = g->Cont_assigns(); prs = g->Process(); gsa = g->Gen_scope_arrays();
    common(view, path, g);
    if (g->Modules()) for (auto* c : *g->Modules()) walkScope(view, c, seen);
    if (g->Interfaces()) for (auto* c : *g->Interfaces()) walkScope(view, c, seen);
  } else if (t == uhdminterface_inst) {
    auto* i = (interface_inst*)sc;
    cas = i->Cont_assigns(); prs = i->Process(); gsa = i->Gen_scope_arrays();
    common(view, path, i);
  } else if (t == uhdmpackage) {
    auto* p = (package*)sc;
    common(view, path, p);
  }
  if (cas)
    for (auto* ca : *cas)
      row(view, path, "CA", ca, ca->Lhs() ? std::string(ca->Lhs()->VpiName()) : "-",
          ca->Rhs());
  if (prs) for (auto* p : *prs) walkStmt(view, path, p->Stmt());
  if (gsa)
    for (auto* g : *gsa)
      if (g->Gen_scopes()) for (auto* gs : *g->Gen_scopes()) walkScope(view, gs, seen);
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: gridscan <db.uhdm>\n"); return 2; }
  Serializer s;
  auto h = s.Restore(std::filesystem::path(argv[1]));
  if (h.empty()) { fprintf(stderr, "FATAL: restore failed\n"); return 3; }
  for (auto hh : h) {
    auto* d = (design*)((const uhdm_handle*)hh)->object;
    std::set<const any*> a, tp;
    if (d->AllModules()) for (auto* m : *d->AllModules()) walkScope("DEF", m, a);
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) walkScope("DEF", m, a);
    if (d->AllPackages()) for (auto* m : *d->AllPackages()) walkScope("DEF", m, a);
    if (d->TopModules()) for (auto* m : *d->TopModules()) walkScope("ELAB", m, tp);
  }
  std::sort(rows.begin(), rows.end());
  rows.erase(std::unique(rows.begin(), rows.end()), rows.end());
  for (auto& r : rows) printf("%s\n", r.c_str());
  fprintf(stderr, "rows=%zu\n", rows.size());
  return 0;
}
