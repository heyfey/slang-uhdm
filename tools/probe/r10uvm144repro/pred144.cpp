// r10uvm144 -- A-PRIORI MOVER PREDICTOR over the PRISTINE databases.
//
// LAW scopedCallArgsBindsLikeBareCall144 opens the § classArgBind12 window in
// exactly one arm: the § classScopeCallOfOutOfBodyMethodIsFuncCall26 arm, which
// is the ONLY producer of a tf_call whose VpiName carries a `::` qualifier
// written at the CALL SITE and which owns Tf_call_args.  A database with no
// such call, or one whose every scoped-call argument already carries a
// vpiActual, CANNOT move.  Deliberate OVER-approximation: it does not test the
// caller's scope, the statement position or the control depth, only
// "a `::`-named tf_call owning a BARE ref_obj argument".
//
// Rows:  CAND <db> <call-name> <arg-name> line=<n>
// Tail:  TOTAL <db> cands=<n>
//
// MEASUREMENT ONLY -- the judge is the official uhdm-cmp.
//   build: g++ -O2 -std=c++17 pred144.cpp -I ~/.local/include -L ~/.local/lib64 \
//              -L ~/.local/lib -luhdm -lcapnp -lkj -o pred144
//   usage: pred144 <db.uhdm> [<label>]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
using namespace UHDM;

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: pred144 <db> [label]\n"); return 2; }
  std::string label = argc > 2 ? argv[2] : argv[1];
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { printf("EMPTY\t%s\n", label.c_str()); return 3; }
  int cands = 0;
  // ARM A of the predicate — the WINDOW half.  A `::`-named tf_call owning a
  // BARE ref_obj argument is the only object § 144's window can change.
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    UHDM_OBJECT_TYPE t = a->UhdmType();
    if (t != uhdmfunc_call && t != uhdmtask_call) continue;
    const tf_call* c = (const tf_call*)a;
    std::string nm(c->VpiName());
    if (nm.find("::") == std::string::npos) continue;
    auto* args = c->Tf_call_args();
    if (!args) continue;
    for (auto* ar : *args) {
      if (!ar || ar->UhdmType() != uhdmref_obj) continue;
      const ref_obj* r = (const ref_obj*)ar;
      if (r->Actual_group()) continue;
      cands++;
      printf("CAND-A\t%s\t%s\t%s\tline=%d\n", label.c_str(), nm.c_str(),
             std::string(r->VpiName()).c_str(), (int)r->VpiLineNo());
    }
  }
  // ARM B of the predicate — the FENCE half.  A BOUND ref_obj sitting inside a
  // class-parented CONSTRUCTOR (`vpiName == "new"`) is the only object
  // § ctorSubLocalIsUnlistedNoBind144 can UNBIND.  Deliberately wider than the
  // law: it does not check where the actual is declared, only that a bound
  // reference lives inside a constructor.
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a || a->UhdmType() != uhdmref_obj) continue;
    const ref_obj* r = (const ref_obj*)a;
    if (!r->Actual_group()) continue;
    const any* p = r->VpiParent();
    for (int guard = 0; p && guard < 64; ++guard, p = p->VpiParent()) {
      UHDM_OBJECT_TYPE pt = p->UhdmType();
      if (pt != uhdmfunction && pt != uhdmtask) continue;
      if (p->VpiName() != "new") break;
      const any* cp = p->VpiParent();
      if (!cp || cp->UhdmType() != uhdmclass_defn) break;
      cands++;
      printf("CAND-B\t%s\t%s\t%s\tline=%d\n", label.c_str(),
             std::string(((const class_defn*)cp)->VpiFullName()).c_str(),
             std::string(r->VpiName()).c_str(), (int)r->VpiLineNo());
      break;
    }
  }
  printf("TOTAL\t%s\tcands=%d\n", label.c_str(), cands);
  return 0;
}
