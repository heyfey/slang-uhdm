// v125 verifier — INDEPENDENT scanner.  Two reports, both id-free:
//  OP82  <nops> <parentkind@span> <span> <operand0 kind(name)> <operand0 parent kind@span>
//        for every operation with VpiOpType == vpiAssignmentOp (82), anywhere.
//  ARG   <callkind|callname|callspan> <idx> <argkind(argname)|argspan|argparentkind@span>
//        for every Tf_call_args element of every tf_call.
//  KIND  <kind> <count>  over the whole serializer.
// MEASUREMENT ONLY.  usage: v125scan <db.uhdm> [OP82|ARG|KIND]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <map>
#include <string>
#include <vector>
using namespace UHDM;

static std::string sp(const any* p) {
  if (!p) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", (unsigned)p->VpiLineNo(), (unsigned)p->VpiColumnNo(),
           (unsigned)p->VpiEndLineNo(), (unsigned)p->VpiEndColumnNo());
  return b;
}
static std::string kindOf(const any* p) {
  if (!p) return "<null>";
  std::string e(UhdmName(p->UhdmType()));
  if (p->UhdmType() == uhdmoperation)
    e += "#" + std::to_string(((const operation*)p)->VpiOpType());
  if (!p->VpiName().empty()) e += "(" + std::string(p->VpiName()) + ")";
  return e;
}
static std::string par(const any* p) {
  const any* q = p ? p->VpiParent() : nullptr;
  if (!q) return "<noparent>";
  return kindOf(q) + "@" + sp(q);
}

int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: v125scan <db> [OP82|ARG|KIND]\n"); return 2; }
  const char* what = argc > 2 ? argv[2] : "ALL";
  bool wOp = !strcmp(what, "ALL") || !strcmp(what, "OP82");
  bool wArg = !strcmp(what, "ALL") || !strcmp(what, "ARG");
  bool wKind = !strcmp(what, "ALL") || !strcmp(what, "KIND");
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE-FAIL %s\n", argv[1]); return 3; }
  std::map<std::string, long> kinds;
  for (auto& kv : s.AllObjects()) {
    const any* o = kv.first;
    if (!o) continue;
    std::string k(UhdmName(o->UhdmType()));
    if (o->UhdmType() == uhdmoperation)
      k += "#" + std::to_string(((const operation*)o)->VpiOpType());
    kinds[k]++;
    if (wOp && o->UhdmType() == uhdmoperation) {
      const operation* op = (const operation*)o;
      if (op->VpiOpType() != 82) continue;
      auto* ov = op->Operands();
      size_t n = ov ? ov->size() : 0;
      std::string o0 = n ? kindOf((*ov)[0]) : std::string("-");
      std::string o0p = n ? par((*ov)[0]) : std::string("-");
      printf("OP82\tnops=%zu\tparent=%s\tspan=%s\top0=%s\top0parent=%s\n", n, par(o).c_str(),
             sp(o).c_str(), o0.c_str(), o0p.c_str());
    }
    if (wArg) {
      const VectorOfany* args = nullptr;
      if (o->UhdmType() == uhdmfunc_call) args = ((const func_call*)o)->Tf_call_args();
      else if (o->UhdmType() == uhdmtask_call) args = ((const task_call*)o)->Tf_call_args();
      else if (o->UhdmType() == uhdmmethod_func_call) args = ((const method_func_call*)o)->Tf_call_args();
      else if (o->UhdmType() == uhdmmethod_task_call) args = ((const method_task_call*)o)->Tf_call_args();
      else if (o->UhdmType() == uhdmsys_func_call) args = ((const sys_func_call*)o)->Tf_call_args();
      else if (o->UhdmType() == uhdmsys_task_call) args = ((const sys_task_call*)o)->Tf_call_args();
      if (!args) continue;
      for (size_t i = 0; i < args->size(); i++) {
        const any* a = (*args)[i];
        printf("ARG\t%s|%s\t%zu\t%s|%s|%s\n", std::string(UhdmName(o->UhdmType())).c_str(), sp(o).c_str(), i,
               kindOf(a).c_str(), sp(a).c_str(), par(a).c_str());
      }
    }
  }
  if (wKind) for (auto& kv : kinds) printf("KIND\t%s\t%ld\n", kv.first.c_str(), kv.second);
  return 0;
}
