// r10uvm148 — SHADOWED-NAME REFERENCE-BINDING CENSUS.  MEASUREMENT ONLY.
// The official uhdm-cmp stays the sole acceptance judge; nothing here judges.
//
// The head is a `ref_obj`'s `Actual_group`: golden binds the name `cs` inside
// `uvm_pkg::uvm_component::m_set_cl_verb` to the PACKAGE-scope `class_var
// uvm_pkg::cs` (vpiVisibility 1) while we bind the subroutine's own local.
// This census scores, for EVERY reference inside EVERY subroutine, the facts
// that decide that race:
//
//  ROW=REF (one per ref_obj under a task_func, deduped by UhdmId)
//    HSPAN    the owning subroutine's span                 <- key part 1
//    RSPAN    the reference's own span                     <- key part 2
//    RNAME    the written name                             <- key part 3
//    ROLE     LVALUE / READ / ARG / RECV / HPATH / IDX / COND / OTHER
//    FORK     1 iff a fork_stmt / named_fork stands between the reference and
//             its subroutine (the database-side predictor for this pass's
//             `ParallelBlockStatement` half)
//    PROD     TFITEM / BLOCK / NOLOC   (the SUBROUTINE's production, read off
//             the database alone: a body local listed ONLY on the task_func is
//             the TF-ITEM production; one listed on the body `begin` too is the
//             BLOCK-ITEM production — uvm145's LOWN signature)
//    LOC      where the NAME is declared inside the subroutine:
//             FUNC (task_func Variables only) / BEGIN (body begin Variables) /
//             FORMAL (Io_decls) / NEST (a deeper begin's Variables) / -
//    PKGV     1 iff the subroutine's Instance() is a PACKAGE that lists a
//             variable of this name        <- the shadowing package scope
//    CLSV     1 iff an enclosing class_defn lists a variable of this name
//    MODV     1 iff an enclosing module/program/interface lists one (THE FENCE)
//    APKGV    1 iff ANY package in the design lists a variable of this name —
//             which is what makes a MODULE subroutine's shadow race scoreable
//             in the DEF view, where the def-view module_inst has no Variables
//    BKIND    UHDM kind of Actual_group (none when unbound)   <- SCORED
//    BSK      KIND ALONE of the bound object's nearest scope   <- SCORED
//    BOWN     kind(name) of that scope                        (diagnostic:
//             the DEF and ELAB listings of one package subroutine spell the
//             NAME differently, so only the KIND may be a scored column)
//    BVIS     the bound object's VpiVisibility (0 = unset)    <- SCORED
//    BSPAN    the bound object's span                         (diagnostic)
//    HNAME    the subroutine's name                           (diagnostic)
//    HINST    kind(name) of the subroutine's Instance()        (diagnostic)
//
// Compare-relevance: `ref_obj::Compare` reads VpiName and walks Actual_group;
// `variables::Compare` reads VpiName / VpiAutomatic / VpiVisibility / ... and
// never a span.  SPANS APPEAR ONLY IN KEYS, never as scored columns.
//
//   build: g++ -O2 -std=c++17 ct148cen.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct148cen
//   usage: ct148cen <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
#include <set>
#include <map>
using namespace UHDM;

static std::string esc(std::string_view v) {
  std::string r;
  for (char c : v) r += ((c == ' ' || c == '\t' || c == '|') ? '_' : c);
  if (r.empty()) r = "-";
  return r;
}
static std::string spanOf(const any* o) {
  if (!o) return "-";
  char b[80];
  snprintf(b, sizeof b, "%u:%hu-%u:%hu", (unsigned)o->VpiLineNo(),
           o->VpiColumnNo(), (unsigned)o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static std::string kindName(const any* o) {
  if (!o) return "-";
  std::string e(UhdmName(o->UhdmType()));
  std::string n(o->VpiName());
  if (!n.empty()) e += "(" + esc(n) + ")";
  return e;
}
// The nearest ENCLOSING SCOPE of an object, as kind(name) — never an id.
static std::string ownerOf(const any* o) {
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 80 && p; i++) {
    switch (p->UhdmType()) {
      case uhdmtask: case uhdmfunction: case uhdmclass_defn:
      case uhdmmodule_inst: case uhdmpackage: case uhdmprogram:
      case uhdminterface_inst: case uhdmdesign:
        return kindName(p);
      default: break;
    }
    p = p->VpiParent();
  }
  return "-";
}
// The nearest ENCLOSING SCOPE KIND alone — the producer-neutral half of BOWN
// (the two listings of one package subroutine spell their NAMES differently,
// so the name belongs in a diagnostic column, never in a scored one).
static std::string ownerKindOf(const any* o) {
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 80 && p; i++) {
    switch (p->UhdmType()) {
      case uhdmtask: case uhdmfunction: case uhdmclass_defn:
      case uhdmmodule_inst: case uhdmpackage: case uhdmprogram:
      case uhdminterface_inst: case uhdmdesign:
        return std::string(UhdmName(p->UhdmType()));
      default: break;
    }
    p = p->VpiParent();
  }
  return "-";
}
// The owning subroutine's own scope chain, kinds+names — used only to drop the
// UHDM BUILTIN classes a `-nobuiltin` golden never carries.
static std::string scopeOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 60 && p; i++) {
    switch (p->UhdmType()) {
      case uhdmtask: case uhdmfunction: case uhdmclass_defn:
      case uhdmmodule_inst: case uhdmpackage: case uhdmprogram:
      case uhdminterface_inst: {
        std::string e(UhdmName(p->UhdmType()));
        e += "(" + esc(p->VpiName()) + ")";
        r = r.empty() ? e : (e + "/" + r);
        break;
      }
      default: break;
    }
    p = p->VpiParent();
  }
  if (r.empty()) r = "-";
  return r;
}
static int visOf(const any* o) {
  const variables* v = any_cast<const variables*>(o);
  if (v) return v->VpiVisibility();
  const io_decl* d = any_cast<const io_decl*>(o);
  if (d) return 0;
  return 0;
}

static const char* g_lst = "-";
// Every variable name listed by ANY package in the design.  Producer-neutral,
// and the only way the MODULE fence is scoreable in the DEF view, where
// Surelog's def-view module_inst carries no Variables vector at all.
static std::set<std::string> g_anyPkgVars;
static const design* g_design = nullptr;

// ---- ONE PASS: a listener that remembers the enclosing subroutine ----------
// A nested `listenAny(tf)` per task_func re-walks shared subtrees and does not
// finish on a UVM database; this single walk keeps a STACK of the subroutines
// it is inside and scores each ref_obj against the innermost one.
struct Cen : public UhdmListener {
  std::vector<const task_func*> stack;
  std::set<unsigned> refSeen;
  void enterFunction(const function* o) override { stack.push_back(o); }
  void leaveFunction(const function* o) override { if (!stack.empty()) stack.pop_back(); }
  void enterTask(const task* o) override { stack.push_back(o); }
  void leaveTask(const task* o) override { if (!stack.empty()) stack.pop_back(); }
  void enterRef_obj(const ref_obj* r) override;
};

static const char* roleOf(const ref_obj* r) {
  const any* p = r->VpiParent();
  if (!p) return "NOPARENT";
  switch (p->UhdmType()) {
    case uhdmassignment: {
      const assignment* a = (const assignment*)p;
      return a->Lhs() == (const any*)r ? "LVALUE" : "READ";
    }
    case uhdmassign_stmt: {
      const assign_stmt* a = (const assign_stmt*)p;
      return a->Lhs() == (const any*)r ? "LVALUE" : "READ";
    }
    case uhdmhier_path: return "HPATH";
    case uhdmbit_select: case uhdmpart_select:
    case uhdmindexed_part_select: case uhdmvar_select:
      return "IDX";
    case uhdmfunc_call: case uhdmtask_call:
    case uhdmmethod_func_call: case uhdmmethod_task_call:
    case uhdmsys_func_call: case uhdmsys_task_call: {
      const tf_call* c = (const tf_call*)p;
      const method_func_call* mf = any_cast<const method_func_call*>(p);
      const method_task_call* mt = any_cast<const method_task_call*>(p);
      if (mf && mf->Prefix() == (const expr*)r) return "RECV";
      if (mt && mt->Prefix() == (const expr*)r) return "RECV";
      if (c->Tf_call_args())
        for (auto* a : *c->Tf_call_args())
          if (a == (const any*)r) return "ARG";
      return "OTHER";
    }
    case uhdmif_stmt: case uhdmif_else: case uhdmcase_stmt:
    case uhdmwhile_stmt: case uhdmdo_while: case uhdmrepeat:
      return "COND";
    default: return "READ";
  }
}

void Cen::enterRef_obj(const ref_obj* r) {
  if (stack.empty()) return;
  const task_func* tf = stack.back();
  if (!refSeen.insert((unsigned)r->UhdmId()).second) return;
  std::string nm(r->VpiName());
  if (nm.empty()) return;
  // --- the subroutine's own name tables (cached per task_func) -------------
  static const task_func* cachedTf = nullptr;
  static std::set<std::string> funcVars, beginVars, formals, pkgVars, clsVars,
      modVars;
  static std::string hspan, hinst, hname, hscope;
  static const char* prod = "NOLOC";
  if (tf != cachedTf) {
    cachedTf = tf;
    funcVars.clear(); beginVars.clear(); formals.clear();
    pkgVars.clear(); clsVars.clear(); modVars.clear();
    hspan = spanOf(tf);
    hname = esc(tf->VpiName());
    hinst = kindName(tf->Instance());
    hscope = scopeOf(tf);
    if (tf->Variables())
      for (auto* v : *tf->Variables()) funcVars.insert(std::string(v->VpiName()));
    if (tf->Io_decls())
      for (auto* v : *tf->Io_decls()) formals.insert(std::string(v->VpiName()));
    const begin* bg = any_cast<const begin*>(tf->Stmt());
    if (bg && bg->Variables())
      for (auto* v : *bg->Variables()) beginVars.insert(std::string(v->VpiName()));
    // THE PRODUCTION, read off the database alone (uvm145's LOWN signature):
    // a body local listed ONLY on the task_func is the TF-ITEM production, one
    // dual-listed on the body `begin` is the BLOCK-ITEM production.
    prod = "NOLOC";
    if (!funcVars.empty()) {
      bool dual = false;
      for (const auto& n : funcVars) if (beginVars.count(n)) dual = true;
      prod = dual ? "BLOCK" : "TFITEM";
    } else if (!beginVars.empty()) prod = "BLOCK";
    if (const instance* in = tf->Instance())
      if (in->UhdmType() == uhdmpackage) {
        const package* pk = (const package*)in;
        if (pk->Variables())
          for (auto* v : *pk->Variables()) pkgVars.insert(std::string(v->VpiName()));
      }
    for (const any* p = tf->VpiParent(); p; p = p->VpiParent()) {
      if (p->UhdmType() == uhdmclass_defn) {
        const class_defn* cd = (const class_defn*)p;
        if (cd->Variables())
          for (auto* v : *cd->Variables()) clsVars.insert(std::string(v->VpiName()));
      } else if (p->UhdmType() == uhdmmodule_inst ||
                 p->UhdmType() == uhdmprogram ||
                 p->UhdmType() == uhdminterface_inst) {
        // THE MODULE FENCE: Surelog's late binder reaches an enclosing
        // instance's Variables ONLY through `func->Instance()` guarded by
        // `inst->UhdmType() == uhdmpackage`, so a MODULE variable may never
        // displace a body local.  Scored so the fence is measured, not assumed.
        const scope* sc = (const scope*)p;
        if (sc->Variables())
          for (auto* v : *sc->Variables()) modVars.insert(std::string(v->VpiName()));
      } else if (p->UhdmType() == uhdmpackage) {
        const package* pk = (const package*)p;
        if (pk->Variables())
          for (auto* v : *pk->Variables()) pkgVars.insert(std::string(v->VpiName()));
        break;
      }
    }
  }
  const char* loc = "-";
  if (formals.count(nm)) loc = "FORMAL";
  if (funcVars.count(nm)) loc = beginVars.count(nm) ? "BEGIN" : "FUNC";
  else if (beginVars.count(nm)) loc = "BEGIN";
  int pkgv = pkgVars.count(nm) ? 1 : 0;
  int clsv = clsVars.count(nm) ? 1 : 0;
  int modv = modVars.count(nm) ? 1 : 0;
  int apkgv = g_anyPkgVars.count(nm) ? 1 : 0;
  // THE POPULATION: a name that IS a subroutine-scope declaration AND is also
  // declared in a shadowing outer scope.
  if (loc[0] == '-') return;
  if (!pkgv && !clsv && !modv && !apkgv) return;
  // FORK: does a fork_stmt / named_fork stand between this reference and its
  // subroutine?  The DATABASE-side predictor for the `ParallelBlockStatement`
  // half of this pass (§ 81's shared `condPredEarlyBound81` gate), so the
  // mover set can be named from PRISTINE databases alone.
  int forkd = 0;
  for (const any* a = r->VpiParent(); a && a != (const any*)tf;
       a = a->VpiParent())
    if (a->UhdmType() == uhdmfork_stmt || a->UhdmType() == uhdmnamed_fork) {
      forkd = 1;
      break;
    }
  const any* b = r->Actual_group();
  printf("ROW=REF|HSPAN=%s|RSPAN=%s|RNAME=%s|ROLE=%s|PROD=%s|LOC=%s"
         "|PKGV=%d|CLSV=%d|MODV=%d|APKGV=%d|FORK=%d|BKIND=%s|BSK=%s|BVIS=%d|BOWN=%s|BSPAN=%s"
         "|HNAME=%s|HINST=%s|HSCOPE=%s|SITE=%s\n",
         hspan.c_str(), spanOf(r).c_str(), esc(nm).c_str(), roleOf(r),
         prod, loc, pkgv, clsv, modv, apkgv, forkd,
         b ? std::string(UhdmName(b->UhdmType())).c_str() : "none",
         ownerKindOf(b).c_str(), visOf(b), ownerOf(b).c_str(),
         spanOf(b).c_str(), hname.c_str(), hinst.c_str(), hscope.c_str(),
         g_lst);
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: ct148cen <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    const design* d = any_cast<const design*>(o);
    if (!d) continue;
    // every package variable name in the design, for APKGV
    g_anyPkgVars.clear();
    auto collectPkgVars = [&](auto* vec) {
      if (!vec) return;
      for (auto* p : *vec)
        if (p->Variables())
          for (auto* v : *p->Variables())
            g_anyPkgVars.insert(std::string(v->VpiName()));
    };
    collectPkgVars(d->AllPackages());
    collectPkgVars(d->TopPackages());
    Cen c;
    auto sweep = [&](const char* tag, auto* vec) {
      if (!vec) return;
      g_lst = tag;
      for (auto* p : *vec) { c.stack.clear(); c.listenAny(p); }
    };
    sweep("ALLPKG", d->AllPackages());
    sweep("TOPPKG", d->TopPackages());
    sweep("ALLCLS", d->AllClasses());
    sweep("TOPMOD", d->TopModules());
    sweep("ALLMOD", d->AllModules());
    sweep("ALLPRG", d->AllPrograms());
    sweep("ALLIFC", d->AllInterfaces());
  }
  return 0;
}
