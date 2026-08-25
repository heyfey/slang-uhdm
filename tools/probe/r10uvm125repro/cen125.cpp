// r10uvm125 — CALL-ARGUMENT census.  For every tf_call in the database, one
// CELL per Tf_call_args element:
//     CELL \t SITE \t CALL \t IDX \t PAYLOAD
// SITE   = the call's parent chain (kinds + names + spans, NO object ids —
//          ids are not comparable across the two producers).
// CALL   = call kind | call name | call span
// PAYLOAD= arg kind [| op<T> nops=N | inner kind(name) | innerparent kind@span]
//          | arg span | formal direction (when the callee is linked)
// LHS IS ALWAYS GOLDEN.  MEASUREMENT ONLY — the official uhdm-cmp is the judge.
//   usage: cen125 <db.uhdm> [call-name-substr]
#include <uhdm/uhdm.h>
#include <uhdm/Serializer.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <string>
#include <vector>
using namespace UHDM;

static std::string sp(const any* p) {
  if (!p) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", (unsigned)p->VpiLineNo(),
           (unsigned)p->VpiColumnNo(), (unsigned)p->VpiEndLineNo(),
           (unsigned)p->VpiEndColumnNo());
  return b;
}
static std::string node(const any* p) {
  std::string e(UhdmName(p->UhdmType()));
  if (!p->VpiName().empty()) e += "(" + std::string(p->VpiName()) + ")";
  if (p->UhdmType() == uhdmoperation)
    e += "{op" + std::to_string(((const operation*)p)->VpiOpType()) + "}";
  if (p->VpiLineNo()) e += "@" + sp(p);
  return e;
}
static std::string chainOf(const any* o) {
  std::string r;
  const any* p = o ? o->VpiParent() : nullptr;
  for (int i = 0; i < 12 && p; i++) {
    r = r.empty() ? node(p) : (node(p) + "/" + r);
    p = p->VpiParent();
  }
  return r.empty() ? "-" : r;
}
static const VectorOfany* argsOf(const any* a) {
  switch (a->UhdmType()) {
    case uhdmfunc_call:        return ((const func_call*)a)->Tf_call_args();
    case uhdmtask_call:        return ((const task_call*)a)->Tf_call_args();
    case uhdmmethod_func_call: return ((const method_func_call*)a)->Tf_call_args();
    case uhdmmethod_task_call: return ((const method_task_call*)a)->Tf_call_args();
    case uhdmsys_func_call:    return ((const sys_func_call*)a)->Tf_call_args();
    case uhdmsys_task_call:    return ((const sys_task_call*)a)->Tf_call_args();
    default: return nullptr;
  }
}
// The callee's io_decls, when the call carries a link.
static const VectorOfio_decl* iosOf(const any* a) {
  const any* cal = nullptr;
  switch (a->UhdmType()) {
    case uhdmfunc_call:        cal = ((const func_call*)a)->Function(); break;
    case uhdmtask_call:        cal = ((const task_call*)a)->Task(); break;
    case uhdmmethod_func_call: cal = ((const method_func_call*)a)->Function(); break;
    case uhdmmethod_task_call: cal = ((const method_task_call*)a)->Task(); break;
    default: return nullptr;
  }
  if (!cal) return nullptr;
  return ((const task_func*)cal)->Io_decls();
}
static const char* dirName(int d) {
  switch (d) {
    case vpiInput: return "in";
    case vpiOutput: return "out";
    case vpiInout: return "inout";
    case vpiRef: return "ref";
    default: return "?";
  }
}
int main(int argc, char** argv) {
  if (argc < 2) { fprintf(stderr, "usage: cen125 <db> [substr]\n"); return 2; }
  std::string filt = (argc > 2) ? argv[2] : "";
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "EMPTY\n"); return 3; }
  for (auto& kv : s.AllObjects()) {
    const any* a = (const any*)kv.first;
    if (!a) continue;
    const VectorOfany* args = argsOf(a);
    if (!args) continue;
    if (!filt.empty() &&
        std::string(a->VpiName()).find(filt) == std::string::npos) continue;
    const VectorOfio_decl* ios = iosOf(a);
    std::string site = chainOf(a);
    std::string call = std::string(UhdmName(a->UhdmType())) + "|" +
                       std::string(a->VpiName()) + "|" + sp(a);
    for (size_t i = 0; i < args->size(); i++) {
      const any* g = (*args)[i];
      std::string pay;
      if (!g) { pay = "<null>"; }
      else {
        pay = std::string(UhdmName(g->UhdmType()));
        if (!g->VpiName().empty()) pay += "(" + std::string(g->VpiName()) + ")";
        if (g->UhdmType() == uhdmoperation) {
          auto* op = (const operation*)g;
          pay += "|op" + std::to_string(op->VpiOpType());
          auto* ops = op->Operands();
          pay += " nops=" + std::to_string(ops ? ops->size() : 0);
          if (ops && !ops->empty()) {
            const any* in0 = (*ops)[0];
            pay += "|inner=" + std::string(UhdmName(in0->UhdmType()));
            if (!in0->VpiName().empty())
              pay += "(" + std::string(in0->VpiName()) + ")";
            pay += "|innerparent=" +
                   (in0->VpiParent()
                        ? std::string(UhdmName(in0->VpiParent()->UhdmType())) +
                              "@" + sp(in0->VpiParent())
                        : std::string("<null>"));
            pay += "|innerspan=" + sp(in0);
          }
        }
        pay += "|parent=" +
               (g->VpiParent()
                    ? std::string(UhdmName(g->VpiParent()->UhdmType())) + "@" +
                          sp(g->VpiParent())
                    : std::string("<null>"));
        pay += "|span=" + sp(g);
      }
      std::string dir = "-";
      if (ios && i < ios->size()) dir = dirName((*ios)[i]->VpiDirection());
      printf("CELL\t%s\t%s\t%zu\t%s\tdir=%s\n", site.c_str(), call.c_str(), i,
             pay.c_str(), dir.c_str());
    }
  }
  return 0;
}
