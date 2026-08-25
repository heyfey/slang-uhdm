// r10earl94 — THE CENSUS (MEASUREMENT ONLY; the official uhdm-cmp is the judge).
//
// Two deduped, depth-keyed identity families with a COMPARE-VISIBLE payload
// (earl60's attrv60.py lesson: a span-carrying payload can HIDE a kind flip, so
// the payload here is exactly what the generated Compares read):
//
//   RF  every ref_obj.        KEY  VIEW|GEN|CTX|DEPTH|INST|NAME|SPAN|PK|PS
//                             PAY  ACT=<kind>@<span>
//   SL  every OPERAND SLOT of every operation, and every select's index.
//                             KEY  VIEW|GEN|CTX|DEPTH|INST|PSPAN|OPTYPE|IDX
//                             PAY  the child's kind + (name | VpiValue/VpiSize/
//                                  VpiConstType/VpiDecompile)   <- the KIND FLIP
//
// VIEW  DEF   the outermost ancestor is NOT one of design->TopModules()
//       ELAB  it is (the elaborated instance tree)
// GEN   the parent chain passes through a gen_scope / gen_scope_array
// CTX   CAST   the ref is the OPERAND of a vpiCastOp operation
//       IDX    the ref is under a bit_select / part_select / var_select index
//       CA     under a cont_assign, otherwise
//       PROC   under a process_stmt
//       CONN   under a port / High_conn
//       OTHER
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <map>
#include <set>
#include <algorithm>
using namespace UHDM;

static std::string sp(const BaseClass* o) {
  if (!o) return "-";
  char b[64];
  snprintf(b, sizeof b, "%u:%u-%u:%u", o->VpiLineNo(), o->VpiColumnNo(),
           o->VpiEndLineNo(), o->VpiEndColumnNo());
  return b;
}
static std::string kn(const BaseClass* o) {
  return o ? std::string(UHDM::UhdmName(o->UhdmType())) : std::string("-");
}
// The COMPARE-VISIBLE payload of one node.
static std::string pay(const BaseClass* o) {
  if (!o) return "<null>";
  std::string r = kn(o);
  switch (o->UhdmType()) {
    case uhdmref_obj: {
      const ref_obj* x = (const ref_obj*)o;
      r += "[" + std::string(x->VpiName()) + "|" + kn(x->Actual_group()) + "@" +
           sp(x->Actual_group()) + "]";
      break;
    }
    case uhdmconstant: {
      const constant* c = (const constant*)o;
      r += "[" + std::string(c->VpiValue()) + "|sz" + std::to_string(c->VpiSize()) +
           "|ct" + std::to_string(c->VpiConstType()) + "|" +
           std::string(c->VpiDecompile()) + "]";
      break;
    }
    case uhdmoperation:
      r += "[op" + std::to_string(((const operation*)o)->VpiOpType()) + "]";
      break;
    default:
      r += "[" + std::string(o->VpiName()) + "]";
      break;
  }
  return r;
}
int main(int argc, char** argv) {
  Serializer s;
  auto restored = s.Restore(std::string(argv[1]));
  if (restored.empty()) { fprintf(stderr, "RESTORE_FAILED\n"); return 3; }
  std::set<const BaseClass*> tops;
  for (auto& pr0 : s.AllObjects()) {
    const BaseClass* d = pr0.first;
    if (!d || d->UhdmType() != uhdmdesign) continue;
    const design* dz = (const design*)d;
    if (dz->TopModules())
      for (auto* m : *dz->TopModules()) tops.insert(m);
  }
  std::map<std::string, int> cells;
  for (auto& pr : s.AllObjects()) {
    const BaseClass* bo = pr.first;
    if (!bo) continue;
    UHDM_OBJECT_TYPE t = bo->UhdmType();
    bool isRef = (t == uhdmref_obj);
    bool isOp = (t == uhdmoperation);
    if (!isRef && !isOp) continue;
    // ---- walk the parent chain once: view, gen, ctx, depth, instance
    bool inTop = tops.count(bo) != 0;
    const BaseClass* inst = nullptr;
    bool gen = false;
    std::string ctx = "OTHER";
    int depth = 0, dInst = -1;
    for (const BaseClass* p = bo->VpiParent(); p; p = p->VpiParent()) {
      depth++;
      UHDM_OBJECT_TYPE pt = p->UhdmType();
      if (pt == uhdmgen_scope || pt == uhdmgen_scope_array) gen = true;
      if (!inst && (pt == uhdmmodule_inst || pt == uhdminterface_inst ||
                    pt == uhdmprogram || pt == uhdmpackage)) {
        inst = p; dInst = depth;
      }
      if (ctx == "OTHER") {
        if (pt == uhdmbit_select || pt == uhdmpart_select ||
            pt == uhdmindexed_part_select || pt == uhdmvar_select)
          ctx = "IDX";
        else if (pt == uhdmcont_assign) ctx = "CA";
        else if (pt == uhdmport) ctx = "CONN";
        else if (pt == uhdmalways || pt == uhdminitial ||
                 pt == uhdmfinal_stmt) ctx = "PROC";
      }
      if (tops.count(p)) inTop = true;
    }
    // CAST wins over everything: the immediate parent is a vpiCastOp
    if (bo->VpiParent() && bo->VpiParent()->UhdmType() == uhdmoperation &&
        ((const operation*)bo->VpiParent())->VpiOpType() == vpiCastOp)
      ctx = "CAST";
    const char* view = inTop ? "ELAB" : "DEF";
    std::string ip = inst ? std::string(((const any*)inst)->VpiName()) : std::string("-");
    if (isRef) {
      const ref_obj* x = (const ref_obj*)bo;
      // GA -- the GLOBAL tripwire, over EVERY ref_obj in the database, so a
      // binding that appears anywhere outside this law's population cannot hide
      // below the family filters below.
      {
        char g1[512];
        snprintf(g1, sizeof g1, "GA|%s|%d|%s|%s", view, gen ? 1 : 0, ctx.c_str(),
                 kn(x->Actual_group()).c_str());
        cells[std::string(g1) + " => ."]++;
      }
      if (!gen && ctx != "CAST") continue;
      char k[2048];
      snprintf(k, sizeof k, "RF|%s|%d|%s|%d|%s|%s|%s|%s|%s", view, gen ? 1 : 0,
               ctx.c_str(), dInst, ip.c_str(), std::string(x->VpiName()).c_str(),
               sp(bo).c_str(), kn(bo->VpiParent()).c_str(),
               sp(bo->VpiParent()).c_str());
      cells[std::string(k) + " => " + kn(x->Actual_group()) + "@" +
            sp(x->Actual_group())]++;
      // RL -- the LOOSE key: no instance and no depth, so it is BLIND-SPOT-FREE
      // for the objects Surelog leaves with a NULL VpiParent (an elaborated
      // select-LHS gen cont_assign is an orphan in golden), which the strict
      // key cannot reach.  Multiplicity carries the per-instance replication.
      char kl[2048];
      snprintf(kl, sizeof kl, "RL|%s|%s|%s|%s|%s", ctx.c_str(),
               std::string(x->VpiName()).c_str(), sp(bo).c_str(),
               kn(bo->VpiParent()).c_str(), sp(bo->VpiParent()).c_str());
      cells[std::string(kl) + " => " + kn(x->Actual_group()) + "@" +
            sp(x->Actual_group())]++;
    } else {
      const operation* op = (const operation*)bo;
      if (!gen) continue;
      if (!op->Operands()) continue;
      int i = 0;
      for (auto* c : *op->Operands()) {
        char k[2048];
        snprintf(k, sizeof k, "SL|%s|%d|%s|%d|%s|%s|%d|%d", view, gen ? 1 : 0,
                 ctx.c_str(), dInst, ip.c_str(), sp(bo).c_str(),
                 op->VpiOpType(), i);
        cells[std::string(k) + " => " + pay(c)]++;
        i++;
      }
    }
  }
  for (auto& [k, n] : cells) printf("%s #%d\n", k.c_str(), n);
  return 0;
}
