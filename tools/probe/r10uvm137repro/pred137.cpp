// r10uvm137 — A-PRIORI MOVER PREDICTOR.  MEASUREMENT ONLY.
//
// Reads a PRISTINE `slang.uhdm` and counts the cells § dottedForeach-
// LoopVarBaseMustDrill137 can reach: a `foreach_stmt` whose `Variable()` is a
// `hier_path` whose FIRST `Path_elems` entry names a loop variable of an
// ENCLOSING `foreach_stmt` (exactly `UHDM::ExprEval::getObject`'s walk,
// ExprEval.cpp:417-427) whose emitted kind is NOT `class_var` (the one kind
// `hierarchicalSelector` can drill).  It deliberately IGNORES the emitter's
// home gate, so the list it prints is an OVER-approximation: a database it
// does not name cannot move.
//
//   build: g++ -O2 -std=c++17 pred137.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred137
//   usage: pred137 <db.uhdm>
#include <uhdm/uhdm.h>
#include <uhdm/UhdmListener.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <set>
#include <string>
using namespace UHDM;

struct Pred : public UhdmListener {
  std::set<unsigned> seen;
  int cand = 0, dotted = 0, foreaches = 0;
  void enterForeach_stmt(const foreach_stmt* o) override {
    if (!seen.insert((unsigned)o->UhdmId()).second) return;
    foreaches++;
    const any* var = o->Variable();
    if (!var || var->UhdmType() != uhdmhier_path) return;
    auto* pe = ((const hier_path*)var)->Path_elems();
    if (!pe || pe->empty()) return;
    dotted++;
    const std::string base(pe->at(0)->VpiName());
    if (base.empty()) return;
    for (const any* p = o->VpiParent(); p; p = p->VpiParent()) {
      if (p->UhdmType() != uhdmforeach_stmt) continue;
      auto* lvs = ((const foreach_stmt*)p)->VpiLoopVars();
      if (!lvs) continue;
      for (const any* lv : *lvs)
        if (lv->VpiName() == base) {
          if (lv->UhdmType() != uhdmclass_var) {
            cand++;
            printf("CAND base=%s kind=%s at=%u:%hu\n", base.c_str(),
                   std::string(UhdmName(lv->UhdmType())).c_str(),
                   (unsigned)o->VpiLineNo(), o->VpiColumnNo());
          }
          return;
        }
    }
  }
};

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pred137 <db.uhdm>\n"); return 2; }
  Serializer s;
  const std::vector<vpiHandle> restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  Pred c;
  for (vpiHandle h : restored) {
    const any* o = (const any*)((const uhdm_handle*)h)->object;
    const design* d = any_cast<const design*>(o);
    if (!d) continue;
    if (d->AllPackages()) for (auto* p : *d->AllPackages()) c.listenAny(p);
    if (d->TopPackages()) for (auto* p : *d->TopPackages()) c.listenAny(p);
    if (d->AllClasses())  for (auto* p : *d->AllClasses())  c.listenAny(p);
    if (d->TopModules())  for (auto* p : *d->TopModules())  c.listenAny(p);
    if (d->AllModules())  for (auto* p : *d->AllModules())  c.listenAny(p);
  }
  printf("SUMMARY foreach=%d dottedpaths=%d candidates=%d\n", c.foreaches,
         c.dotted, c.cand);
  return 0;
}
