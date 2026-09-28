// r11u193: the byte-mover predictor, read from a PRISTINE database only.  Prints one line per law whose trigger
// the database carries (derived from each law's condition, not from the grid):
//   CONN   an elaborated port HighConn (an instance below a top) whose tree, through operations, holds a cast
//          operation or a system call (castOperandLeafElab193 / connCastTsNamedByPort193 / connSysCallArgDefNet193)
//   NDA    an elaborated net-declaration cont_assign whose Rhs holds a cast operation (castOperandLeafElab193)
//   NEST   a definition module_inst parented at another module_inst (nestedDefChainName193)
//   TFILL  a definition cont_assign whose Rhs is a conditional with an unsized constant (vpiSize -1) arm
//          (caTernFillArmKept193)
//   UCLONE a definition cont_assign with a non-reference Lhs whose Rhs holds an unsized constant
//          (caUnsizedRhsClonePerInst193)
//   COPY   a typespec a TOP package lists whose location lies outside that package's span: a typedef an
//          outside writer moved (tfArgOutsideCopyOrder193)
// usage: predict <db.uhdm>
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_user.h>
#include <cstdio>
#include <functional>
#include <set>
#include <string>
using namespace UHDM;
static bool hasUnsized(const any* x, int d = 0) {
  if (!x || d > 64) return false;
  switch (x->UhdmType()) {
    case uhdmconstant: return ((const constant*)x)->VpiSize() == -1;
    case uhdmoperation:
      if (auto* os = ((const operation*)x)->Operands())
        for (auto* o : *os) if (hasUnsized(o, d + 1)) return true;
      return false;
    case uhdmsys_func_call:
      if (auto* as = ((const sys_func_call*)x)->Tf_call_args())
        for (auto* a : *as) if (hasUnsized(a, d + 1)) return true;
      return false;
    case uhdmfunc_call:
      if (auto* as = ((const func_call*)x)->Tf_call_args())
        for (auto* a : *as) if (hasUnsized(a, d + 1)) return true;
      return false;
    case uhdmbit_select: return hasUnsized(((const bit_select*)x)->VpiIndex(), d + 1);
    case uhdmpart_select:
      return hasUnsized(((const part_select*)x)->Left_range(), d + 1) ||
             hasUnsized(((const part_select*)x)->Right_range(), d + 1);
    case uhdmindexed_part_select:
      return hasUnsized(((const indexed_part_select*)x)->Base_expr(), d + 1) ||
             hasUnsized(((const indexed_part_select*)x)->Width_expr(), d + 1);
    default: return false;
  }
}
static bool castOrSys(const any* x, bool castOnly, int d = 0) {
  if (!x || d > 64) return false;
  if (x->UhdmType() == uhdmsys_func_call) {
    if (!castOnly) return true;
    if (auto* as = ((const sys_func_call*)x)->Tf_call_args())
      for (auto* a : *as) if (castOrSys(a, castOnly, d + 1)) return true;
    return false;
  }
  if (x->UhdmType() != uhdmoperation) return false;
  auto* op = (const operation*)x;
  if (op->VpiOpType() == vpiCastOp) return true;
  if (auto* os = op->Operands())
    for (auto* o : *os) if (castOrSys(o, castOnly, d + 1)) return true;
  return false;
}
int main(int argc, char** argv) {
  if (argc < 2) return 2;
  Serializer s;
  s.Restore(std::string(argv[1]));
  std::set<std::string> fired;
  std::set<const any*> defMods;
  for (auto& kv : s.AllObjects()) {
    auto* o = (const any*)kv.first;
    if (o && o->UhdmType() == uhdmdesign) {
      auto* d = (const design*)o;
      if (auto* tp = d->TopPackages())
        for (auto* p : *tp) {
          if (!p || !p->Typespecs()) continue;
          for (auto* t : *p->Typespecs())
            if (t && !t->VpiName().empty() && (t->VpiFile() != p->VpiFile() || t->VpiLineNo() < p->VpiLineNo() ||
                                               t->VpiLineNo() > p->VpiEndLineNo()))
              fired.insert("COPY");
        }
      if (auto* am = d->AllModules())
        for (auto* m : *am) {
          defMods.insert(m);
          if (m->UhdmType() == uhdmmodule_inst && m->VpiParent() &&
              m->VpiParent()->UhdmType() == uhdmmodule_inst)
            fired.insert("NEST");
        }
    }
  }
  auto isDef = [&](const any* o) {
    for (const any* a = o; a; a = a->VpiParent())
      if (defMods.count(a)) return true;
    return false;
  };
  for (auto& kv : s.AllObjects()) {
    auto* o = (const any*)kv.first;
    if (!o) continue;
    if (o->UhdmType() == uhdmport) {
      auto* p = (const port*)o;
      const any* inst = p->VpiParent();
      if (!inst || isDef(inst)) continue;
      if (!inst->VpiParent() || inst->VpiParent()->UhdmType() == uhdmdesign) continue;  // a top
      if (castOrSys(p->High_conn(), false)) fired.insert("CONN");
    }
    if (o->UhdmType() == uhdmcont_assign) {
      auto* ca = (const cont_assign*)o;
      bool def = isDef(ca);
      if (!def && ca->VpiNetDeclAssign() && castOrSys(ca->Rhs(), true)) fired.insert("NDA");
      if (def && ca->Rhs() && ca->Rhs()->UhdmType() == uhdmoperation &&
          ((const operation*)ca->Rhs())->VpiOpType() == vpiConditionOp && hasUnsized(ca->Rhs()))
        fired.insert("TFILL");
      if (def && ca->Lhs() && ca->Lhs()->UhdmType() != uhdmref_obj && hasUnsized(ca->Rhs()))
        fired.insert("UCLONE");
    }
  }
  for (auto& f : fired) printf("%s\n", f.c_str());
  return 0;
}
