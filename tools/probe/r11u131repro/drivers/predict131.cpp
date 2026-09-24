// predict131: reads a PRISTINE slang-uhdm database and prints which of the
// r11u131 laws would write something in it (one token per law with a
// count), so every byte mover of the law sweep is predicted by name before
// it is seen.  Read-only mirrors of each law's trigger (a predicate may be
// WIDER than its law; it is never narrower):
//   IPSSPAN  indexed_part_select under a param_assign whose source text does
//            not start with its name (range-only span)
//   QCALL    func_call `pkg::f` under a param_assign spanning the package token
//   PAREN    param_assign Rhs constant written inside parentheses
//   INETFILE a definition's wire (vpiNetType 1) with a file and no typespec
//            whose span and name equal a ref_obj's (the mint copies its
//            reference's span), or named after a named block (`disable`)
//   OVRMD    overridden elaborated param_assign, constant Rhs, 2-D typespec
//   PATTS    package / elaborated-import assignment-pattern op with a ref_typespec
//            (the law swaps in a fresh reference, so it moves bytes even where
//            the old reference already computed no name)
//   KWSYS    sys_func_call / constant whose text is `$f(<keyword type>)`
//   PTSSEP   ref_obj named `pkg::P.N` (a `::` before the first `.`)
//   CASTLOC  cast operation typespec on line 1 of an include or after a macro
// Measurement only (r11u131).
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <regex>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
static std::map<std::string, std::vector<std::string>> fileCache;
static const std::vector<std::string>& lines(const std::string& f) {
  auto it = fileCache.find(f);
  if (it == fileCache.end()) {
    std::vector<std::string> ls; std::ifstream in(f); std::string l;
    while (std::getline(in, l)) ls.push_back(l);
    it = fileCache.emplace(f, ls).first;
  }
  return it->second;
}
static std::string lineOf(const BaseClass* o) {
  std::string f(o->VpiFile());
  if (f.empty() || !o->VpiLineNo()) return "";
  auto& ls = lines(f);
  if (o->VpiLineNo() > ls.size()) return "";
  return ls[o->VpiLineNo() - 1];
}
static std::string srcText(const BaseClass* o) {
  if (o->VpiLineNo() != o->VpiEndLineNo()) return "";
  std::string l = lineOf(o);
  size_t a = o->VpiColumnNo() ? o->VpiColumnNo() - 1 : 0, b = o->VpiEndColumnNo() ? o->VpiEndColumnNo() - 1 : 0;
  if (l.empty() || a > l.size() || b > l.size() || b < a) return "";
  return l.substr(a, b - a);
}
static bool multiDim(const typespec* ts) {
  if (!ts) return false;
  auto many = [](const VectorOfrange* r) { return r && r->size() > 1; };
  switch (ts->UhdmType()) {
    case uhdmlogic_typespec: return many(((const logic_typespec*)ts)->Ranges());
    case uhdmbit_typespec: return many(((const bit_typespec*)ts)->Ranges());
    case uhdmarray_typespec: return many(((const array_typespec*)ts)->Ranges());
    case uhdmpacked_array_typespec: return true;
    default: return false;
  }
}
struct P : VpiListener {
  std::map<std::string, int> n;
  std::set<const any*> defs, pkgs;
  bool under(UHDM_OBJECT_TYPE t) const {
    for (size_t i = 0; i + 1 < callstack.size(); ++i) if (callstack[i]->UhdmType() == t) return true;
    return false;
  }
  void enterDesign(const design* d, vpiHandle) override {
    if (d->AllModules()) for (auto* m : *d->AllModules()) defs.insert(m);
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) defs.insert(m);
    for (auto* v : {d->AllPackages(), d->TopPackages()}) if (v) for (auto* p : *v) pkgs.insert(p);
  }
  void enterIndexed_part_select(const indexed_part_select* o, vpiHandle) override {
    if (!under(uhdmparam_assign)) return;
    std::string t = srcText(o);
    if (!t.empty() && t.rfind(std::string(o->VpiName()), 0) != 0) n["IPSSPAN"]++;
  }
  void enterFunc_call(const func_call* o, vpiHandle) override {
    std::string nm(o->VpiName());
    auto q = nm.find("::");
    if (q == std::string::npos || !under(uhdmparam_assign)) return;
    if (o->VpiLineNo() == o->VpiEndLineNo() && o->VpiEndColumnNo() - o->VpiColumnNo() == q) n["QCALL"]++;
  }
  void enterParam_assign(const param_assign* pa, vpiHandle) override {
    const any* r = pa->Rhs();
    const any* sc = pa->VpiParent();
    bool isPkg = sc && pkgs.count(sc);
    bool isElab = sc && !isPkg && !defs.count(sc) &&
                  (sc->UhdmType() == uhdmmodule_inst || sc->UhdmType() == uhdminterface_inst || sc->UhdmType() == uhdmgen_scope);
    if (r && r->UhdmType() == uhdmconstant) {
      std::string l = lineOf(r);
      size_t a = r->VpiColumnNo(), b = r->VpiEndColumnNo();
      if (r->VpiLineNo() == r->VpiEndLineNo() && a >= 2 && b >= 1 && b - 1 < l.size()) {
        size_t i = a - 2; while (i > 0 && isspace((unsigned char)l[i])) --i;
        size_t j = b - 1; while (j < l.size() && isspace((unsigned char)l[j])) ++j;
        if (l[i] == '(' && j < l.size() && l[j] == ')') n["PAREN"]++;
      }
      if (isElab && pa->VpiOverriden()) {
        const typespec* ts = nullptr;
        if (auto* rt = ((const constant*)r)->Typespec()) ts = rt->Actual_typespec();
        if (!ts && pa->Lhs() && pa->Lhs()->UhdmType() == uhdmparameter)
          if (auto* lrt = ((const parameter*)pa->Lhs())->Typespec()) ts = lrt->Actual_typespec();
        if (multiDim(ts)) n["OVRMD"]++;
      }
    }
    if (r && r->UhdmType() == uhdmoperation && ((const operation*)r)->VpiOpType() == vpiAssignmentPatternOp) {
      auto* rt = ((const operation*)r)->Typespec();
      auto* l = pa->Lhs();
      bool imp = l && l->UhdmType() == uhdmparameter && !((const parameter*)l)->VpiImported().empty();
      if (rt && (isPkg || (isElab && imp))) n["PATTS"]++;
    }
  }
  std::set<std::string> refSpans;
  std::vector<std::string> netCand;
  static std::string key(const BaseClass* o) {
    return std::string(o->VpiName()) + "|" + std::to_string(o->VpiLineNo()) + ":" + std::to_string(o->VpiColumnNo()) +
           "-" + std::to_string(o->VpiEndLineNo()) + ":" + std::to_string(o->VpiEndColumnNo());
  }
  void enterLogic_net(const logic_net* o, vpiHandle) override {
    const any* p = o->VpiParent();
    if (p && defs.count(p) && !o->VpiFile().empty() && !o->Typespec() && o->VpiNetType() == 1)
      netCand.push_back(key(o)), netNames.push_back(std::string(o->VpiName()));
  }
  std::vector<std::string> netNames;
  std::set<std::string> blockNames;
  void enterNamed_begin(const named_begin* o, vpiHandle) override { blockNames.insert(std::string(o->VpiName())); }
  void enterNamed_fork(const named_fork* o, vpiHandle) override { blockNames.insert(std::string(o->VpiName())); }
  void finish() {
    for (size_t i = 0; i < netCand.size(); ++i)
      if (refSpans.count(netCand[i]) || blockNames.count(netNames[i])) n["INETFILE"]++;
  }
  void enterSys_func_call(const sys_func_call* o, vpiHandle) override { kw(o); }
  void enterConstant(const constant* o, vpiHandle) override { kw(o); }
  void kw(const BaseClass* o) {
    std::string l = lineOf(o);
    if (l.empty() || !o->VpiColumnNo() || o->VpiColumnNo() > l.size()) return;
    static const std::regex re("^\\$[a-z_0-9]+\\s*\\(\\s*(int|byte|shortint|longint|integer|time|logic|bit|reg)\\s*[,)]");
    if (std::regex_search(l.substr(o->VpiColumnNo() - 1), re)) n["KWSYS"]++;
  }
  void enterRef_obj(const ref_obj* o, vpiHandle) override {
    refSpans.insert(key(o));
    std::string f(o->VpiFullName());
    auto c = f.find("::"), d = f.find('.');
    if (c != std::string::npos && d != std::string::npos && c < d && f.find("::", d) == std::string::npos) n["PTSSEP"]++;
  }
  void enterOperation(const operation* o, vpiHandle) override {
    if (o->VpiOpType() != vpiCastOp) return;
    auto* rt = o->Typespec();
    const typespec* ts = rt ? rt->Actual_typespec() : nullptr;
    if (!ts || !ts->VpiLineNo()) return;
    std::string l = lineOf(ts);
    bool mac = l.find('`') != std::string::npos && l.find('`') < ts->VpiColumnNo();
    std::string f(ts->VpiFile());
    bool incFirst = ts->VpiLineNo() == 1 && f.size() > 4 && (f.substr(f.size() - 4) == ".svh" || f.substr(f.size() - 3) == ".vh");
    if (mac || incFirst) n["CASTLOC"]++;
  }
};
int main(int argc, char** argv) {
  for (int i = 1; i < argc; ++i) {
    auto ser = std::make_unique<Serializer>();
    auto h = ser->Restore(std::string(argv[i]));
    P p; p.listenDesigns(h); p.finish();
    std::cout << argv[i];
    for (auto& [k, v] : p.n) std::cout << ' ' << k << '=' << v;
    std::cout << '\n';
  }
}
