// r10uvm114 — A-PRIORI MOVER PREDICTOR, run on PRISTINE databases before the
// patched sweep.  MEASUREMENT ONLY.
//
// A database can move under § enumBaseTdCloneElabRanges114 only if it holds an
// `enum_typespec` whose `Base_typespec` actual is a bit/logic typespec with an
// OPERATION range bound (the DEF-view form) AND the design also holds a
// same-named, same-span twin of that typespec whose bounds are all folded (the
// TOP-view listing object the design-final pass would re-point it at).  Both
// halves are required: without the folded twin the pass refuses.
//
//   build: g++ -O2 -std=c++17 pred114.cpp -I ~/.local/include \
//              -L ~/.local/lib64 -L ~/.local/lib -luhdm -lcapnp -lkj -o pred114
//   usage: pred114 <db.uhdm>     (prints one CAND line per candidate clone)
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <map>
#include <set>
#include <string>
using namespace UHDM;
static const VectorOfrange* rangesOf(const any* a) {
  if (a->UhdmType() == uhdmbit_typespec) return ((const bit_typespec*)a)->Ranges();
  if (a->UhdmType() == uhdmlogic_typespec) return ((const logic_typespec*)a)->Ranges();
  return nullptr;
}
static bool hasOp(const VectorOfrange* rv) {
  if (!rv) return false;
  for (auto* r : *rv)
    for (auto* b : {r->Left_expr(), r->Right_expr()})
      if (b && b->UhdmType() == uhdmoperation) return true;
  return false;
}
static std::string key(const any* a) {
  std::string n(a->VpiName());
  auto p = n.rfind("::");
  if (p != std::string::npos) n = n.substr(p + 2);
  char b[200];
  snprintf(b, sizeof b, "%s@%u:%u-%u:%u|%d", n.c_str(), (unsigned)a->VpiLineNo(),
           a->VpiColumnNo(), (unsigned)a->VpiEndLineNo(), a->VpiEndColumnNo(),
           (int)a->UhdmType());
  return b;
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pred114 <db.uhdm>\n"); return 2; }
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY %s\n", argv[1]); return 3; }
  auto all = s.AllObjects();
  std::set<std::string> foldedTwin;
  for (auto& kv : all) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    auto* rv = rangesOf(a);
    if (!rv || rv->empty()) continue;
    if (!hasOp(rv)) foldedTwin.insert(key(a));
  }
  int n = 0;
  for (auto& kv : all) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmenum_typespec) continue;
    auto* bt = ((const enum_typespec*)a)->Base_typespec();
    if (!bt || !bt->Actual_typespec()) continue;
    const any* base = bt->Actual_typespec();
    auto* rv = rangesOf(base);
    if (!rv || !hasOp(rv)) continue;
    bool twin = foldedTwin.count(key(base)) > 0;
    printf("CAND enum=%s base=%s%s\n", std::string(a->VpiName()).c_str(),
           std::string(base->VpiName()).c_str(), twin ? " TWIN=yes" : " TWIN=no");
    if (twin) n++;
  }
  printf("PRED movers=%d\n", n);
  return 0;
}
