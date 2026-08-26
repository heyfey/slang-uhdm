// r10earl95 -- THE CENSUS (MEASUREMENT ONLY; the official uhdm-cmp is the judge).
//
// § genCaParamFoldOneHopPool95 moves ONE kind of cell: a VALUE SLOT of an
// expression that lives in an ELABORATED GENERATE SCOPE flips between a
// `constant` (we folded a parameter) and a `ref_obj` (golden kept it).  The
// census is therefore keyed by the SLOT and carries the child's
// COMPARE-VISIBLE payload, so a kind flip cannot hide (earl60's attrv60.py
// lesson), and it is DEPTH-KEYED by the GENERATE NESTING DEPTH -- the very
// quantity the law reads.
//
//   SL  every value slot of every operation and every select that lives in a
//       gen scope.
//       KEY  SL|VIEW|GDEPTH|CTX|DINST|INST|OWNERKIND|OWNERSPAN|SLOT
//       PAY  the child's kind + (name+Actual | VpiValue/VpiSize/VpiConstType/
//            VpiDecompile)
//   RF  every ref_obj in a gen scope (so a ref that APPEARS is counted even
//       where no owner slot enumerates it).
//       KEY  RF|VIEW|GDEPTH|CTX|NAME|SPAN|PARENTKIND|PARENTSPAN
//       PAY  ACT=<kind>@<span>
//   GA  the GLOBAL tripwire over EVERY ref_obj and EVERY constant in the
//       database, gen scope or not, so a move outside this law's population
//       cannot hide below the family filters.
//       KEY  GA|VIEW|GEN|CTX|KIND   PAY  .
//
// VIEW   ELAB  an ancestor is one of design->TopModules(); DEF otherwise.
// GDEPTH the number of gen_scope levels in the parent chain (gen_scope_array
//        wrappers are NOT counted -- they are not a hop, exactly as the law
//        skips a GenerateBlockArray).
// CTX    IDX (under a select), CA, PROC, CONN, OTHER.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>
#include <map>
#include <set>
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
      r += "[" + std::string(c->VpiValue()) + "|sz" +
           std::to_string(c->VpiSize()) + "|ct" +
           std::to_string(c->VpiConstType()) + "|" +
           std::string(c->VpiDecompile()) + "]";
      break;
    }
    case uhdmoperation:
      r += "[op" + std::to_string(((const operation*)o)->VpiOpType()) + "]";
      break;
    default:
      r += "[" + std::string(((const any*)o)->VpiName()) + "]";
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
    bool isCst = (t == uhdmconstant);
    bool isOp = (t == uhdmoperation);
    bool isSel = (t == uhdmbit_select || t == uhdmpart_select ||
                  t == uhdmindexed_part_select || t == uhdmvar_select);
    if (!isRef && !isCst && !isOp && !isSel) continue;
    bool inTop = tops.count(bo) != 0;
    const BaseClass* inst = nullptr;
    int gdepth = 0, depth = 0, dInst = -1;
    std::string ctx = "OTHER";
    for (const BaseClass* p = bo->VpiParent(); p; p = p->VpiParent()) {
      depth++;
      UHDM_OBJECT_TYPE pt = p->UhdmType();
      if (pt == uhdmgen_scope) gdepth++;
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
        else if (pt == uhdmalways || pt == uhdminitial || pt == uhdmfinal_stmt)
          ctx = "PROC";
      }
      if (tops.count(p)) inTop = true;
      if (depth > 64) break;
    }
    const char* view = inTop ? "ELAB" : "DEF";
    std::string ip = inst ? std::string(((const any*)inst)->VpiName())
                          : std::string("-");
    if (isRef || isCst) {
      char g1[512];
      snprintf(g1, sizeof g1, "GA|%s|%d|%s|%s", view, gdepth ? 1 : 0,
               ctx.c_str(), kn(bo).c_str());
      cells[std::string(g1) + " => ."]++;
    }
    if (isRef && gdepth) {
      const ref_obj* x = (const ref_obj*)bo;
      char k[2048];
      snprintf(k, sizeof k, "RF|%s|%d|%s|%s|%s|%s|%s", view, gdepth,
               ctx.c_str(), std::string(x->VpiName()).c_str(), sp(bo).c_str(),
               kn(bo->VpiParent()).c_str(), sp(bo->VpiParent()).c_str());
      cells[std::string(k) + " => " + kn(x->Actual_group()) + "@" +
            sp(x->Actual_group())]++;
    }
    if ((isOp || isSel) && gdepth) {
      std::vector<std::pair<std::string, const any*>> slots;
      if (isOp) {
        const operation* op = (const operation*)bo;
        if (op->Operands()) {
          int i = 0;
          for (auto* c : *op->Operands())
            slots.push_back({"op" + std::to_string(op->VpiOpType()) + "#" +
                                 std::to_string(i++), c});
        }
      } else if (t == uhdmbit_select) {
        slots.push_back({"idx", ((const bit_select*)bo)->VpiIndex()});
      } else if (t == uhdmpart_select) {
        slots.push_back({"lr", ((const part_select*)bo)->Left_range()});
        slots.push_back({"rr", ((const part_select*)bo)->Right_range()});
      } else if (t == uhdmindexed_part_select) {
        slots.push_back({"base", ((const indexed_part_select*)bo)->Base_expr()});
        slots.push_back({"width", ((const indexed_part_select*)bo)->Width_expr()});
      } else if (t == uhdmvar_select) {
        const var_select* vs = (const var_select*)bo;
        if (vs->Exprs()) {
          int i = 0;
          for (auto* c : *vs->Exprs())
            slots.push_back({"vs#" + std::to_string(i++), c});
        }
      }
      for (auto& [slot, child] : slots) {
        char k[2048];
        snprintf(k, sizeof k, "SL|%s|%d|%s|%d|%s|%s|%s|%s", view, gdepth,
                 ctx.c_str(), dInst, ip.c_str(), kn(bo).c_str(), sp(bo).c_str(),
                 slot.c_str());
        cells[std::string(k) + " => " + pay(child)]++;
      }
    }
  }
  for (auto& [k, n] : cells) printf("%s #%d\n", k.c_str(), n);
  return 0;
}
