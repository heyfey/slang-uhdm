// r11u161 predict161: the objects of a PRISTINE database the r11u161 laws can move (a superset).
//   alias   § enumAliasClone161: an enum_typespec listed as a module / interface typedef or a design ($unit) typespec
//           whose source text at its span is a typedef of a NAMED type (`typedef [pkg::]name alias;`) — the pristine
//           listing object of a non-package enum alias (spanned at its declaration);
//   route   § defGenPathSel161: a hier_path of two or more elements inside a definition-view generate statement
//           (the parent chain reaches gen_if / gen_if_else / gen_for / gen_case / gen_region or a parentless
//           case_item before an instance or a gen_scope) whose position decides a route (the mirror of
//           defGenRoute161: a cont_assign target -> SEL, its right side -> CFC, a generate condition / case item /
//           gen-for header -> SEL; a ?:, pattern or concatenation on the way abstains);
//   port    § firstOrderedPathSel161: an elaborated port's high_conn that is a plain dotted hier_path (every element a
//           ref_obj), on the FIRST port of an instance with two or more ports, whose source text is not a named
//           connection (the character before the actual's `(` is not preceded by `.name`) — a superset of the first
//           actual of an ordered list.
// Prints  <law>\t<name>\t<line:col>\t<route>  per candidate and "TOTAL <n>".
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <fstream>
#include <iostream>
#include <map>
#include <regex>
#include <string>
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
  std::cout << "TOTAL " << n << "\n";
  return 0;
}
