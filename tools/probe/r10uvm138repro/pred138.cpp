// r10uvm138 — A-PRIORI MOVER PREDICTOR over the PRISTINE databases.
//
// § pkgRetBareEnumConstFold138 can only move a database that contains a
// `return_stmt` whose `vpiCondition` is a `ref_obj` — every cell the law
// touches is one of those, and nothing else in the emitter changed.  This is a
// deliberate OVER-approximation (it does not test the view, the
// direct-statement window, the package home or the enum's typedef-ness), so a
// database it does not name CANNOT move; the ones it does name are the set the
// byte-mover audit must be a subset of.
//
// Rows:  CAND <db> <refname> <act-kind>
// Tail:  TOTAL <db> cands=<n> enumcands=<n>
//
// MEASUREMENT ONLY — the judge is the official uhdm-cmp.
//   usage: pred138 <db.uhdm> [<label>]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pred138 <db> [label]\n"); return 2; }
  std::string label = argc > 2 ? argv[2] : argv[1];
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { printf("EMPTY %s\n", label.c_str()); return 3; }
  int cands = 0, enumcands = 0;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmreturn_stmt) continue;
    const any* c = ((const return_stmt*)a)->VpiCondition();
    if (!c || c->UhdmType() != uhdmref_obj) continue;
    const any* act = ((const ref_obj*)c)->Actual_group();
    std::string ak = act ? std::string(UhdmName(act->UhdmType())) : std::string("-");
    cands++;
    if (act && act->UhdmType() == uhdmenum_const) enumcands++;
    printf("CAND\t%s\t%s\t%s\n", label.c_str(),
           std::string(c->VpiName()).c_str(), ak.c_str());
  }
  printf("TOTAL\t%s\tcands=%d\tenumcands=%d\n", label.c_str(), cands, enumcands);
  return 0;
}
