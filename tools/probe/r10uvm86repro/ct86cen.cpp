// r10uvm86 — MEASUREMENT-ONLY.  The § negLitPkgRetFold86 census.
//
// Walks EVERY object of ONE database (Serializer::AllObjects, so each object is
// counted ONCE — uhdm-dump reprints an object at every reference) and counts the
// three populations this pass is about, all of them anchored on a return_stmt:
//
//   GHEAD  a return_stmt whose vpiCondition is a `constant` with
//          vpiConstType==7 (vpiIntConst) whose decompile starts with '-'.  This
//          is Surelog's REDUCED negated literal — the object golden has and a
//          PRISTINE build of ours has none of.
//   OHEAD  a return_stmt whose vpiCondition is an `operation` with
//          vpiOpType==vpiMinusOp(1) over exactly ONE `constant` operand: the
//          shape our emitter writes.  This is the PREDICTOR — OHEAD_pristine
//          minus OHEAD_patched is the mover count, and every site is listed by
//          FILE:LINE:COL with the enclosing subroutine's fullname so the movers
//          can be predicted BY NAME before any patched build exists.
//   DIRECT the OHEAD subset whose return_stmt's vpiParent is a task_func, or a
//          `begin` whose own vpiParent is a task_func: Surelog's "direct
//          statement of the body" test (the function's own Stmt, or a member of
//          the synthetic begin a multi-statement body gets).  A return one level
//          down — explicit begin/end, if, for, while, case, fork, named block —
//          is compiled with Reduce::No and must NOT move.  DIRECT is therefore
//          the UPPER BOUND on this law's movers; it over-counts only by
//          returns whose enclosing subroutine is not package-scope-elaborated
//          and by EXPLICIT begin/end bodies, both of which are listed so they
//          can be read off by hand.
//
// usage: ct86cen <db.uhdm> [--list]
// build: g++ -O2 -std=c++17 ct86cen.cpp -I ~/.local/include \
//        -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o ct86cen
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <map>
#include <vector>
using namespace UHDM;
static std::string ownerOf(const BaseClass* o) {
  // Nearest enclosing task_func, by fullname; plus the parent-kind chain that
  // decides DIRECTness.
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 12 && p; i++) {
    if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask)
      return std::string(((const task_func*)p)->VpiFullName());
    p = p->VpiParent();
  }
  return std::string("<none>");
}
static bool directBody(const BaseClass* rs) {
  const BaseClass* p = rs ? rs->VpiParent() : nullptr;
  if (!p) return false;
  if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) return true;
  if (p->UhdmType() == uhdmbegin) {
    const BaseClass* g = p->VpiParent();
    return g && (g->UhdmType() == uhdmfunction || g->UhdmType() == uhdmtask);
  }
  return false;
}
// The LISTING a return_stmt's subroutine is reached from: DEFPKG
// (uhdmallPackages), TOPPKG (uhdmtopPackages), DEFMOD / TOPMOD, or "-".  This is
// the def/elab split Surelog's two package compiles produce.
typedef std::map<const BaseClass*, std::string> ViewMap;
static void tagScopes(const std::vector<package*>* ps, const char* tag,
                      ViewMap& v) {
  if (!ps) return;
  for (auto* p : *ps) {
    if (!p) continue;
    if (p->Task_funcs())
      for (auto* f : *p->Task_funcs()) if (f) v.emplace(f, tag);
    if (p->Class_defns())
      for (auto* c : *p->Class_defns())
        if (c && c->Task_funcs())
          for (auto* f : *c->Task_funcs()) if (f) v.emplace(f, tag);
  }
}
static void tagMods(const std::vector<module_inst*>* ms, const char* tag,
                    ViewMap& v) {
  if (!ms) return;
  for (auto* m : *ms) {
    if (!m) continue;
    if (m->Task_funcs())
      for (auto* f : *m->Task_funcs()) if (f) v.emplace(f, tag);
    if (m->Class_defns())
      for (auto* c : *m->Class_defns())
        if (c && c->Task_funcs())
          for (auto* f : *c->Task_funcs()) if (f) v.emplace(f, tag);
  }
}
static std::string viewOf(const BaseClass* o, const ViewMap& v) {
  const BaseClass* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 12 && p; i++) {
    if (p->UhdmType() == uhdmfunction || p->UhdmType() == uhdmtask) {
      auto it = v.find(p);
      return it == v.end() ? std::string("-") : it->second;
    }
    p = p->VpiParent();
  }
  return std::string("-");
}
int main(int argc, char** argv) {
  if (argc < 2) { printf("usage: ct86cen <db.uhdm> [--list]\n"); return 2; }
  bool list = false;
  for (int i = 2; i < argc; i++) if (!strcmp(argv[i], "--list")) list = true;
  Serializer s; s.Restore(std::string(argv[1]));
  ViewMap views;
  for (auto& kv : s.AllObjects())
    if (kv.first && ((const BaseClass*)kv.first)->UhdmType() == uhdmdesign) {
      const design* d = (const design*)kv.first;
      tagScopes(d->AllPackages(), "DEFPKG", views);
      tagScopes(d->TopPackages(), "TOPPKG", views);
      tagMods(d->AllModules(), "DEFMOD", views);
      tagMods(d->TopModules(), "TOPMOD", views);
    }
  auto all = s.AllObjects();
  size_t objs = 0, ghead = 0, ohead = 0, direct = 0;
  for (auto& kv : all) {
    const BaseClass* o = (const BaseClass*)kv.first;
    if (!o) continue;
    objs++;
    if (o->UhdmType() != uhdmreturn_stmt) continue;
    const return_stmt* r = (const return_stmt*)o;
    const any* c = r->VpiCondition();
    if (!c) continue;
    if (c->UhdmType() == uhdmconstant) {
      const constant* k = (const constant*)c;
      std::string d(k->VpiDecompile());
      if (k->VpiConstType() == vpiIntConst && !d.empty() && d[0] == '-') {
        ghead++;
        if (list)
          printf("GHEAD\t%u:%u-%u:%u\tsz=%d\tval=%s\tdec=%s\t%s\t%s\n",
                 k->VpiLineNo(), (unsigned)k->VpiColumnNo(), k->VpiEndLineNo(),
                 (unsigned)k->VpiEndColumnNo(), k->VpiSize(),
                 std::string(k->VpiValue()).c_str(), d.c_str(),
                 viewOf(r, views).c_str(), ownerOf(r).c_str());
      }
      continue;
    }
    if (c->UhdmType() != uhdmoperation) continue;
    const operation* op = (const operation*)c;
    if (op->VpiOpType() != vpiMinusOp) continue;
    auto* ops = op->Operands();
    if (!ops || ops->size() != 1) continue;
    if ((*ops)[0]->UhdmType() != uhdmconstant) continue;
    ohead++;
    bool d0 = directBody(r);
    if (d0) direct++;
    if (list) {
      const constant* k = (const constant*)(*ops)[0];
      printf("OHEAD\t%u:%u-%u:%u\t%s\tsz=%d\tval=%s\t%s\t%s\n",
             op->VpiLineNo(), (unsigned)op->VpiColumnNo(), op->VpiEndLineNo(),
             (unsigned)op->VpiEndColumnNo(), d0 ? "DIRECT" : "nested",
             k->VpiSize(), std::string(k->VpiValue()).c_str(),
             viewOf(r, views).c_str(), ownerOf(r).c_str());
    }
  }
  printf("DB\t%s\tobjs=%zu\tGHEAD=%zu\tOHEAD=%zu\tOHEAD_DIRECT=%zu\n",
         argv[1], objs, ghead, ohead, direct);
  return 0;
}
