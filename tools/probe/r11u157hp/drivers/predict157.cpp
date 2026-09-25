// r11u157 predict157: the objects of a PRISTINE database that the r11u157 laws can move (a superset: the laws fire at
// ExprEmit's three plain-path builders only, and the database does not record which builder minted a path).
// Prints one line per candidate hier_path:  <law> <path name> <line:col> <current form> <route>
// and a final "TOTAL <n>" line. Laws: route (§ hpSelRoute157), this (§ thisPathFormByPosition157),
// foreach (§ foreachArrPathVarForm157), root (§ rootPathOwnNames157), withrecv (§ withRecvOnlyLastScoped157),
// gentgt (§ genTgtLhsLeafOwnName157).
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <iostream>
#include <string>
using namespace UHDM;
static std::string span(const BaseClass* o) {
  return std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) + ":" + std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
}
// the db-level mirror of hpRoute157: 'S', 'C' or 0
static char route(const BaseClass* hp) {
  const BaseClass* child = hp;
  for (const BaseClass* p = hp->VpiParent(); p; child = p, p = p->VpiParent()) {
    switch (p->UhdmType()) {
      case uhdmoperation: {
        auto* op = (const operation*)p;
        int ot = op->VpiOpType();
        if (ot == vpiAssignmentPatternOp || ot == vpiMultiAssignmentPatternOp) return 'C';
        if (ot == vpiConditionOp && op->Operands() && op->Operands()->size() == 3 && op->Operands()->at(1) == child) return 'C';
        // a size cast's WIDTH is parented at the cast operation but is not one of its operands (§ hpSelRoute157's
        // cast-width arm, `inCastSize` at emission)
        if (ot == vpiCastOp) {
          bool isOperand = false;
          if (op->Operands()) for (auto* o : *op->Operands()) if (o == child) isOperand = true;
          if (!isOperand) return 'S';
        }
        continue;
      }
      case uhdmtagged_pattern: return 'C';
      case uhdmbit_select:
      case uhdmvar_select: {
        const BaseClass* q = p->VpiParent();
        if (q && (q->UhdmType() == uhdmcont_assign || q->UhdmType() == uhdmhier_path)) return 0;
        return 'C';
      }
      case uhdmpart_select: return 'S';
      case uhdmindexed_part_select: return ((const indexed_part_select*)p)->Width_expr() == child ? 'S' : 'C';
      case uhdmrange: return 'S';
      case uhdmparam_assign: return 'S';
      case uhdmfunc_call: case uhdmsys_func_call: case uhdmmethod_func_call:
      case uhdmtask_call: case uhdmsys_task_call: case uhdmmethod_task_call: return 'C';
      default:
        if (dynamic_cast<const typespec*>(p)) return 'S';
        return 0;
    }
  }
  return 0;
}
int main(int argc, char** argv) {
  Serializer s;
  auto h = s.Restore(std::string(argv[1]));
  if (h.empty()) return 3;
  size_t n = 0;
  for (auto& kv : s.AllObjects()) {
    const BaseClass* o = (const BaseClass*)kv.first;
    if (o->UhdmType() != uhdmhier_path) continue;
    auto* hp = (const hier_path*)o;
    auto* el = hp->Path_elems();
    if (!el || el->empty()) continue;
    std::string nm(hp->VpiName());
    const any* e0 = el->at(0);
    auto say = [&](const char* law, const std::string& extra) {
      std::cout << law << '\t' << nm << '\t' << span(hp) << '\t' << extra << '\n'; ++n;
    };
    bool allRef = true;
    for (auto* e : *el) if (e->UhdmType() != uhdmref_obj) allRef = false;
    std::string b0(e0->VpiName());
    if (b0 == "this") { say("this", ""); continue; }
    if (hp->VpiParent() && hp->VpiParent()->UhdmType() == uhdmforeach_stmt) { say("foreach", ""); continue; }
    if (b0 == "$root") { say("root", ""); continue; }
    const any* last = el->back();
    if (last->UhdmType() == uhdmmethod_func_call && ((const method_func_call*)last)->With() && el->size() > 2) { say("withrecv", ""); continue; }
    if (hp->VpiParent() && hp->VpiParent()->UhdmType() == uhdmcont_assign && last->UhdmType() == uhdmref_obj &&
        e0->UhdmType() == uhdmref_obj) {   // an INDEXED base (a bit_select) keeps the raw leaf
      vpiHandle lh = NewVpiHandle(last);
      const char* fn = vpi_get_str(vpiFullName, lh);
      if (fn && std::string(fn) == nm) say("gentgt", fn);
      vpi_release_handle(lh);
    }
    // route: a path with at least one ref_obj element beside the base (the laws touch the base anchor and the leaf
    // name; a bit_select element does not stop them)
    if (el->size() < 2) continue;
    char r = route(hp);
    if (!r) continue;
    bool selForm = el->size() > 1 && span(e0) == span(el->at(1));
    bool leafOwn = true;
    if (last->UhdmType() == uhdmref_obj) {
      vpiHandle lh = NewVpiHandle(last);
      const char* fn = vpi_get_str(vpiFullName, lh);
      leafOwn = !fn || !*fn;
      vpi_release_handle(lh);
    }
    if ((r == 'S') != selForm || (r == 'S') != leafOwn)
      say("route", std::string(1, r) + (selForm ? " span=S" : " span=C") + (leafOwn ? " leaf=own" : " leaf=full") + (allRef ? "" : " mixed"));
  }
  std::cout << "TOTAL\t" << n << '\n';
}
