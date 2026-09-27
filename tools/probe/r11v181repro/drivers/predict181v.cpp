// predict181v — the v11u181 refinements' byte-mover predictor, run on the r11u181 LAW databases (the
// refinements' pristine) before the refined sweep.  predict181v <db.uhdm>... prints "<db> <TAG,...>" or "-".
//   NESTRD  a hier_path nested (through expressions) in the index of another hier_path H1 that is itself
//           nested in an assignment's left side or an inc/dec operand without being that side (H1 = the path
//           § lvIdxMixedPathIsRead181 builds as a read);
//   RDCALL  a func_call below such an H1;
//   LVCALLPS a func_call whose parent is a part_select, below an assignment's left side;
//   DECBIG  a constant of vpiDecConst whose decompile holds an underscore.
// Reads no source file.  Fence: the caller never passes a fenced database (predict181v.sh, fail closed).
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <iostream>
#include <set>
#include <string>
using namespace UHDM;
static bool isIncDec(const any* a) {
  if (!a || a->UhdmType() != uhdmoperation) return false;
  int ot = ((const operation*)a)->VpiOpType();
  return ot == vpiPostIncOp || ot == vpiPreIncOp || ot == vpiPostDecOp || ot == vpiPreDecOp;
}
// walk up from o through expressions; collect hier_paths met; return true when an lvalue root is reached
// through its left side (or an inc/dec operand); root = the object that IS that left side / operand.
static bool lvChain(const any* o, std::vector<const any*>& hps, const any*& root) {
  const any* c = o;
  for (const any* a = o->VpiParent(); a; c = a, a = a->VpiParent()) {
    auto t = a->UhdmType();
    if (t == uhdmassignment) { root = c; return ((const assignment*)a)->Lhs() == c; }
    if (t == uhdmcont_assign) return false;
    if (isIncDec(a)) { root = c; return true; }
    if (t == uhdmhier_path) hps.push_back(a);
    if (!dynamic_cast<const expr*>(a)) return false;
  }
  return false;
}
int main(int argc, char** argv) {
  for (int ai = 1; ai < argc; ai++) {
    Serializer s; auto designs = s.Restore(std::string(argv[ai])); (void)designs;
    std::set<std::string> tags;
    for (auto& kv : s.AllObjects()) {
      const BaseClass* o = kv.first; if (!o) continue; auto t = o->UhdmType();
      if (t == uhdmconstant) {
        auto* c = (const constant*)o;
        if (c->VpiConstType() == vpiDecConst && c->VpiDecompile().find('_') != std::string_view::npos) tags.insert("DECBIG");
      }
      if (t != uhdmhier_path && t != uhdmfunc_call) continue;
      std::vector<const any*> hps; const any* root = nullptr;
      if (!lvChain((const any*)o, hps, root)) continue;
      // H1 candidates: a met hier_path that is not the lvalue root itself
      int nonRoot = 0; for (auto* h : hps) if (h != root) nonRoot++;
      if (t == uhdmhier_path && nonRoot >= 1) tags.insert("NESTRD");
      if (t == uhdmfunc_call) {
        if (nonRoot >= 1) tags.insert("RDCALL");
        if (o->VpiParent() && o->VpiParent()->UhdmType() == uhdmpart_select) tags.insert("LVCALLPS");
      }
    }
    std::string out; for (auto& l : tags) out += (out.empty() ? "" : ",") + l;
    std::cout << argv[ai] << " " << (out.empty() ? "-" : out) << "\n";
  }
  return 0;
}
