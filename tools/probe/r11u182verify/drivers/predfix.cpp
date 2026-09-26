// predfix.cpp <db.uhdm>...: the prediction census of § castUnionCloneKeepsCastParent182v, read from HEAD databases:
// a union_typespec that a cast operation's ref_typespec binds (the cast union clone) and that carries NO parent is
// the object the refinement re-parents.  Prints "<db> <count>" for every database with at least one (r11u182).
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <set>
using namespace UHDM;
int main(int argc, char** argv) {
  for (int i = 1; i < argc; i++) {
    Serializer s; auto designs = s.Restore(std::string(argv[i]));
    std::set<const BaseClass*> hit;
    for (auto& kv : s.AllObjects()) {
      const BaseClass* o = (const BaseClass*)kv.first;
      if (o->UhdmType() != uhdmoperation) continue;
      auto* op = (const operation*)o;
      if (op->VpiOpType() != vpiCastOp || !op->Typespec()) continue;
      const typespec* t = op->Typespec()->Actual_typespec();
      if (t && t->UhdmType() == uhdmunion_typespec && t->VpiParent() == nullptr) hit.insert(t);
    }
    if (!hit.empty()) std::cout << argv[i] << " " << hit.size() << "\n";
  }
}
