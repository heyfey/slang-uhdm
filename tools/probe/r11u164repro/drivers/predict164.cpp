// r11u164 predict164: the objects of a PRISTINE database the r11u164 landing's laws can move (a superset).
// The r11u161 half is tools/probe/r11u161gen/drivers/predict161.cpp verbatim (alias / route / port); r11u164 adds
//   rangeq  § rangeQueryFoldUnconverted164 + § rangeQueryDeclNetSize164: a cont_assign whose Rhs is the system
//           call $high / $low / $left / $right (the definition view keeps the call; the elaborated fold moves);
//   cadelay § caDelayFirstOnly164: two or more cont_assigns with a Delay under one parent at the same span (a
//           comma list gives every cont_assign the whole list's span);
//   pview   § modportPortViewParamDef164 + § portViewParamShared164: a port-view interface_inst (column 0, no end
//           line) whose param_assign Lhs is a parameter and Rhs a constant.
//   selbase § defGenSelBaseLeafAtIndex164: a definition-view generate cont_assign target hier_path whose base is a
//           bit_select with a named index and whose leaf is a bit_select;
//   bindpath § bindUnresolvedPathNoName164: a port High_conn hier_path whose elements are all ref_obj and whose
//           first element stores a full name other than its own name (the unresolved bind path's scoped names);
//   genndahp § genNetDeclAssignLhsShared164: a net-declaration cont_assign under a gen_scope whose Rhs is a hier_path;
//   dlyparam § caDelayParamElabFresh164: a cont_assign whose Delay is a ref_obj (a parameter-named delay).
// Prints  <law>\t<name>\t<line:col>\t<route>  per candidate and "TOTAL <n>".
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <fstream>
#include <iostream>
#include <map>
#include <regex>
#include <string>
#include <tuple>
#include <vector>
using namespace UHDM;
static bool underDefGen(const BaseClass* p) {
  for (; p; p = p->VpiParent()) {
    switch (p->UhdmType()) {
      case uhdmgen_if: case uhdmgen_if_else: case uhdmgen_for: case uhdmgen_case: case uhdmgen_region: return true;
      case uhdmcase_item: if (!p->VpiParent()) return true; break;
      case uhdmmodule_inst: case uhdminterface_inst: case uhdmprogram: case uhdmdesign:
      case uhdmgen_scope: case uhdmgen_scope_array: return false;
      default: break;
    }
  }
  return false;
}
static char route(const BaseClass* hp) {
  const BaseClass* child = hp;
  for (const BaseClass* p = hp->VpiParent(); p; child = p, p = p->VpiParent()) {
    switch (p->UhdmType()) {
      case uhdmoperation: {
        int ot = ((const operation*)p)->VpiOpType();
        if (ot == vpiConditionOp || ot == vpiAssignmentPatternOp || ot == vpiMultiAssignmentPatternOp ||
            ot == vpiConcatOp || ot == vpiMultiConcatOp) return 0;
        continue;
      }
      case uhdmcont_assign:
        if (!underDefGen(p)) return 0;
        return ((const cont_assign*)p)->Lhs() == child ? 'S' : 'C';
      case uhdmgen_if: case uhdmgen_if_else: case uhdmgen_case: case uhdmgen_for: return 'S';
      case uhdmcase_item: return (!p->VpiParent() || p->VpiParent()->UhdmType() == uhdmgen_case) ? 'S' : 0;
      case uhdmassignment: return (p->VpiParent() && p->VpiParent()->UhdmType() == uhdmgen_for) ? 'S' : 0;
      default: return 0;
    }
  }
  return 0;
}
static std::map<std::string, std::vector<std::string>> files;
static std::string text(const BaseClass* o) {
  std::string f(o->VpiFile());
  if (f.empty() || !o->VpiLineNo()) return "";
  auto it = files.find(f);
  if (it == files.end()) {
    std::vector<std::string> v; std::ifstream in(f); std::string l;
    while (std::getline(in, l)) v.push_back(l);
    it = files.emplace(f, v).first;
  }
  auto& v = it->second; std::string t;
  for (unsigned ln = o->VpiLineNo(); ln <= o->VpiEndLineNo() && ln <= v.size(); ln++) {
    std::string l = v[ln - 1];
    unsigned b = ln == o->VpiLineNo() ? o->VpiColumnNo() - 1 : 0;
    unsigned e = ln == o->VpiEndLineNo() ? o->VpiEndColumnNo() - 1 : l.size();
    if (b <= l.size()) t += l.substr(b, e > b ? e - b : 0);
    t += ' ';
  }
  return t;
}
int main(int argc, char** argv) {
  Serializer s;
  auto h = s.Restore(std::string(argv[1]));
  if (h.empty()) return 3;
  static const std::regex aliasRe(R"(^\s*typedef\s+[A-Za-z_$][\w$]*(\s*::\s*[A-Za-z_$][\w$]*)?\s+[A-Za-z_$][\w$]*\s*;?\s*$)");
  size_t n = 0;
  for (auto& kv : s.AllObjects()) {
    const BaseClass* o = kv.first;
    if (o->UhdmType() == uhdmenum_typespec) {
      auto* ets = (const enum_typespec*)o;
      const BaseClass* inst = ets->Instance();
      bool listed = inst && (inst->UhdmType() == uhdmmodule_inst || inst->UhdmType() == uhdminterface_inst ||
                             inst->UhdmType() == uhdmdesign || inst->UhdmType() == uhdmprogram);
      if (listed && std::regex_match(text(o), aliasRe)) {
        std::cout << "alias\t" << ets->VpiName() << "\t" << o->VpiLineNo() << ":" << o->VpiColumnNo() << "\t-\n"; n++;
      }
    }
    if (o->UhdmType() == uhdmhier_path) {
      auto* hp = (const hier_path*)o;
      if (!hp->Path_elems() || hp->Path_elems()->size() < 2) continue;
      if (!underDefGen(hp)) continue;
      char r = route(hp);
      if (!r) continue;
      // CFC: only a selected FIELD (element > 0) with a plain-name index moves (the genvar arm's span and names).
      if (r == 'C') {
        bool sel = false;
        for (size_t i = 1; i < hp->Path_elems()->size(); i++) {
          auto* e = hp->Path_elems()->at(i);
          if (e->UhdmType() == uhdmbit_select && ((const bit_select*)e)->VpiIndex() &&
              ((const bit_select*)e)->VpiIndex()->UhdmType() == uhdmref_obj) sel = true;
        }
        if (!sel) continue;
      }
      std::cout << "route\t" << hp->VpiName() << "\t" << o->VpiLineNo() << ":" << o->VpiColumnNo() << "\t" << r << "\n"; n++;
    }
  }
  for (auto& kv : s.AllObjects()) {
    const BaseClass* o = kv.first;
    if (o->UhdmType() != uhdmmodule_inst && o->UhdmType() != uhdminterface_inst && o->UhdmType() != uhdmprogram)
      continue;
    auto* inst = (const instance*)o;
    const VectorOfport* ports = nullptr;
    if (o->UhdmType() == uhdmmodule_inst) ports = ((const module_inst*)o)->Ports();
    else if (o->UhdmType() == uhdminterface_inst) ports = ((const interface_inst*)o)->Ports();
    else ports = ((const program*)o)->Ports();
    (void)inst;
    if (!ports || ports->size() < 2) continue;
    auto* p0 = ports->at(0);
    auto* hc = p0->High_conn();
    if (!hc || hc->UhdmType() != uhdmhier_path) continue;
    auto* hp = (const hier_path*)hc;
    if (!hp->Path_elems() || hp->Path_elems()->size() < 2) continue;
    bool plain = true;
    for (auto* e : *hp->Path_elems()) if (e->UhdmType() != uhdmref_obj) plain = false;
    if (!plain) continue;
    // named `.f(` before the actual -> not ordered (only when the line text is readable)
    bool named = false;
    std::string f(hc->VpiFile());
    auto it = files.find(f);
    if (it == files.end()) { std::vector<std::string> v; std::ifstream in(f); std::string l; while (std::getline(in, l)) v.push_back(l); it = files.emplace(f, v).first; }
    if (hc->VpiLineNo() && hc->VpiLineNo() <= it->second.size()) {
      std::string l = it->second[hc->VpiLineNo() - 1].substr(0, hc->VpiColumnNo() ? hc->VpiColumnNo() - 1 : 0);
      while (!l.empty() && isspace((unsigned char)l.back())) l.pop_back();
      if (!l.empty() && l.back() == '(') {
        l.pop_back();
        while (!l.empty() && isspace((unsigned char)l.back())) l.pop_back();
        while (!l.empty() && (isalnum((unsigned char)l.back()) || l.back() == '_' || l.back() == '$')) l.pop_back();
        while (!l.empty() && isspace((unsigned char)l.back())) l.pop_back();
        if (!l.empty() && l.back() == '.') named = true;
      }
    }
    if (named) continue;
    std::cout << "port\t" << hp->VpiName() << "\t" << hc->VpiLineNo() << ":" << hc->VpiColumnNo() << "\tS\n"; n++;
  }
  for (auto& kv : s.AllObjects()) {
    const BaseClass* o = kv.first;
    if (o->UhdmType() == uhdmcont_assign) {
      auto* ca = (const cont_assign*)o;
      if (auto* r = ca->Rhs(); r && r->UhdmType() == uhdmsys_func_call) {
        std::string nm(r->VpiName());
        if (nm == "$high" || nm == "$low" || nm == "$left" || nm == "$right") {
          std::cout << "rangeq\t" << nm << "\t" << o->VpiLineNo() << ":" << o->VpiColumnNo() << "\t-\n"; n++;
        }
      }
    }
    if (o->UhdmType() == uhdminterface_inst) {
      auto* ii = (const interface_inst*)o;
      if (ii->VpiColumnNo() == 0 && ii->VpiEndLineNo() == 0 && ii->Param_assigns())
        for (auto* pa : *ii->Param_assigns())
          if (pa->Lhs() && pa->Lhs()->UhdmType() == uhdmparameter && pa->Rhs() &&
              pa->Rhs()->UhdmType() == uhdmconstant) {
            std::cout << "pview\t" << ii->VpiFullName() << "." << pa->Lhs()->VpiName() << "\t" << o->VpiLineNo()
                      << ":0\t-\n"; n++;
          }
    }
  }
  {
    std::map<std::tuple<const BaseClass*, unsigned, unsigned, unsigned, unsigned>, int> spans;
    for (auto& kv : s.AllObjects()) {
      const BaseClass* o = kv.first;
      if (o->UhdmType() != uhdmcont_assign || !((const cont_assign*)o)->Delay()) continue;
      spans[{o->VpiParent(), o->VpiLineNo(), o->VpiColumnNo(), o->VpiEndLineNo(), o->VpiEndColumnNo()}]++;
    }
    for (auto& [k, c] : spans)
      if (c >= 2) { std::cout << "cadelay\t-\t" << std::get<1>(k) << ":" << std::get<2>(k) << "\t-\n"; n++; }
  }
  for (auto& kv : s.AllObjects()) {
    const BaseClass* o = kv.first;
    if (o->UhdmType() == uhdmcont_assign) {
      auto* ca = (const cont_assign*)o;
      if (ca->Lhs() && ca->Lhs()->UhdmType() == uhdmhier_path && underDefGen(ca)) {
        auto* hp = (const hier_path*)ca->Lhs();
        if (hp->Path_elems() && hp->Path_elems()->size() >= 2 &&
            hp->Path_elems()->front()->UhdmType() == uhdmbit_select &&
            hp->Path_elems()->back()->UhdmType() == uhdmbit_select) {
          std::cout << "selbase\t" << hp->VpiName() << "\t" << o->VpiLineNo() << ":" << o->VpiColumnNo() << "\t-\n"; n++;
        }
      }
      if (ca->Delay() && ca->Delay()->UhdmType() == uhdmref_obj) {
        std::cout << "dlyparam\t" << ca->Delay()->VpiName() << "\t" << o->VpiLineNo() << ":" << o->VpiColumnNo() << "\t-\n"; n++;
      }
      if (ca->VpiNetDeclAssign() && ca->VpiParent() && ca->VpiParent()->UhdmType() == uhdmgen_scope && ca->Rhs() &&
          ca->Rhs()->UhdmType() == uhdmhier_path) {
        std::cout << "genndahp\t" << ca->Rhs()->VpiName() << "\t" << o->VpiLineNo() << ":" << o->VpiColumnNo() << "\t-\n"; n++;
      }
    }
    if (o->UhdmType() == uhdmport) {
      auto* hc = ((const port*)o)->High_conn();
      if (hc && hc->UhdmType() == uhdmhier_path) {
        auto* hp = (const hier_path*)hc;
        bool plain = hp->Path_elems() && hp->Path_elems()->size() >= 2;
        if (plain) for (auto* e : *hp->Path_elems()) if (e->UhdmType() != uhdmref_obj) plain = false;
        if (plain && !((const ref_obj*)hp->Path_elems()->front())->VpiFullName().empty() &&
            ((const ref_obj*)hp->Path_elems()->front())->VpiFullName() != hp->Path_elems()->front()->VpiName()) {
          std::cout << "bindpath\t" << hp->VpiName() << "\t" << hc->VpiLineNo() << ":" << hc->VpiColumnNo() << "\t-\n"; n++;
        }
      }
    }
  }
  std::cout << "TOTAL " << n << "\n";
  return 0;
}
