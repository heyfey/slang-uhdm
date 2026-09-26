// predictv178 <db.uhdm>...: per database, the objects the v11u178 refinements can move, read from the
// r11u178 LAW database (the binary the refinements are applied on).  Measurement only.
//   INCDEC  an inc/dec operation whose operand is a hier_path with a non-trailing bit_select holding a
//           non-constant index (§ hierPathSelIdxCloneKeepsElem178v, R11V178_INCDEC_OFF)
//   ELABCA  a cont_assign under an ELABORATED module_inst (reached from design TopModules) whose Rhs holds
//           such a hier_path (§ hierPathSelIdxCloneKeepsElem178v, R11V178_ELABCA_OFF)
//   DWCOND  a do_while whose end differs from its condition's end (§ doWhileEndsAtCondEnd178v)
// prints: <db> <INCDEC n> <ELABCA n> <DWCOND n>, or <db> - when none.
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/sv_vpi_user.h>
#include <iostream>
#include <set>
using namespace UHDM;
static bool midSel(const any* e) {
  if (!e || e->UhdmType() != uhdmhier_path) return false;
  auto* pe = ((const hier_path*)e)->Path_elems(); if (!pe) return false;
  for (size_t i = 0; i + 1 < pe->size(); i++) {
    auto* x = (*pe)[i];
    if (x->UhdmType() != uhdmbit_select) continue;
    auto* ix = ((const bit_select*)x)->VpiIndex();
    if (ix && ix->UhdmType() != uhdmconstant) return true;
  }
  return false;
}
static int holds(const any* e, int d = 0) {  // count mid-select paths below e (expressions only)
  if (!e || d > 64) return 0;
  int n = midSel(e) ? 1 : 0;
  switch (e->UhdmType()) {
  case uhdmoperation: if (auto* os = ((const operation*)e)->Operands()) for (auto* o : *os) n += holds(o, d + 1); break;
  case uhdmfunc_call: case uhdmsys_func_call: case uhdmmethod_func_call:
    if (auto* as = ((const tf_call*)e)->Tf_call_args()) for (auto* a : *as) n += holds(a, d + 1); break;
  default: break;
  }
  return n;
}
int main(int argc, char** argv) {
  for (int ai = 1; ai < argc; ai++) {
    Serializer s; s.Restore(std::string(argv[ai]));
    std::set<const any*> elab;  // module_insts reachable from TopModules
    for (auto& kv0 : s.AllObjects()) {
      if (!kv0.first || kv0.first->UhdmType() != uhdmdesign) continue;
      auto* d = (const design*)kv0.first;
      std::vector<const module_inst*> st;
      if (d->TopModules()) for (auto* m : *d->TopModules()) st.push_back(m);
      while (!st.empty()) { auto* m = st.back(); st.pop_back(); if (!elab.insert(m).second) continue;
        if (m->Modules()) for (auto* c : *m->Modules()) st.push_back(c); }
    }
    int inc = 0, ca = 0, dw = 0;
    for (auto& kv : s.AllObjects()) {
      auto* o = kv.first; if (!o) continue;
      auto t = o->UhdmType();
      if (t == uhdmoperation) {
        int op = ((const operation*)o)->VpiOpType();
        if (op == vpiPostIncOp || op == vpiPreIncOp || op == vpiPostDecOp || op == vpiPreDecOp)
          if (auto* os = ((const operation*)o)->Operands()) for (auto* x : *os) if (midSel(x)) inc++;
      } else if (t == uhdmcont_assign) {
        auto* c = (const cont_assign*)o;
        if (c->VpiParent() && elab.count(c->VpiParent()) && c->Rhs()) ca += holds(c->Rhs());
      } else if (t == uhdmdo_while) {
        auto* w = (const do_while*)o; auto* c = w->VpiCondition();
        if (c && (c->VpiEndLineNo() != w->VpiEndLineNo() || c->VpiEndColumnNo() != w->VpiEndColumnNo())) dw++;
      }
    }
    if (inc + ca + dw) std::cout << argv[ai] << " INCDEC " << inc << " ELABCA " << ca << " DWCOND " << dw << "\n";
    else std::cout << argv[ai] << " -\n";
  }
}
