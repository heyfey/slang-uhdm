// r10uvm141 -- A-PRIORI MOVER PREDICTOR over the PRISTINE databases.
//
// LAW qualLifetimeStubListsNoBodyLocals141 removes the vpiVariables vector from
// exactly one shape of object: the pass-46 qualifier+lifetime CLASS-METHOD STUB
// (an unnamed task_func parented at a class_defn).  A database with no such
// object that also carries body locals CANNOT move; the ones this names are the
// superset the byte-mover audit must fall inside.  The predicate is a
// deliberate OVER-approximation: it does not test the view or the qualifier,
// only "unnamed class method WITH variables".
//
// Rows:  CAND <db> <owner-fullname> <kind> nvars=<n>
// Tail:  TOTAL <db> cands=<n>
//
// MEASUREMENT ONLY -- the judge is the official uhdm-cmp.
//   build: g++ -O2 -std=c++17 pred141.cpp -I ~/.local/include -L ~/.local/lib64 \
//              -L ~/.local/lib -luhdm -lcapnp -lkj -o pred141
//   usage: pred141 <db.uhdm> [<label>]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pred141 <db> [label]\n"); return 2; }
  std::string label = argc > 2 ? argv[2] : argv[1];
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { printf("EMPTY\t%s\n", label.c_str()); return 3; }
  int cands = 0;
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    UHDM_OBJECT_TYPE t = a->UhdmType();
    if (t != uhdmfunction && t != uhdmtask) continue;
    const task_func* tf = (const task_func*)a;
    if (!tf->VpiName().empty()) continue;
    const any* p = tf->VpiParent();
    if (!p || p->UhdmType() != uhdmclass_defn) continue;
    auto* vars = tf->Variables();
    if (!vars || vars->empty()) continue;
    cands++;
    printf("CAND\t%s\t%s\t%s\tnvars=%d\n", label.c_str(),
           std::string(((const class_defn*)p)->VpiFullName()).c_str(),
           std::string(UhdmName(t)).c_str(), (int)vars->size());
  }
  printf("TOTAL\t%s\tcands=%d\n", label.c_str(), cands);
  return 0;
}
