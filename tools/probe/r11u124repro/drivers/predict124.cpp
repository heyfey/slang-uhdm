// predict124: reads a PRISTINE slang-uhdm database and prints which of the
// r11u124 laws would write something in it (one line per law with a count),
// so every byte mover of the law sweep is predicted by name before it is
// seen.  Read-only mirrors of each law's trigger:
//   LHSFILE   imported param_assign Lhs parented at the param_assign, located, no VpiFile
//   LHSCLONE  def-module imported param_assign whose Lhs is NOT parented at it (shared)
//   AGGRNG    unlocated range (line 0) of a package packed_array_typespec that has a Typedef_alias
//   PVAL      a parameter the value law would rewrite (same algorithm, no writes)
//   REALTXT   real constant whose value is not "REAL:" + its decompile
//   CASTFILE  typespec under an operation's ref_typespec, located, no VpiFile
//   QSPAN     param_assign Rhs constant whose source text holds `::` (def/elab view)
//   INCDEC    hier_path operand of ++/-- whose base ref span != first member span
// Measurement only (r11u124).
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <optional>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
static std::map<std::string, std::vector<std::string>> fileCache;
static std::string srcText(const BaseClass* o) {
  std::string f(o->VpiFile());
  if (f.empty() || !o->VpiLineNo() || o->VpiLineNo() != o->VpiEndLineNo()) return "";
  auto it = fileCache.find(f);
  if (it == fileCache.end()) {
    std::vector<std::string> ls; std::ifstream in(f); std::string l;
    while (std::getline(in, l)) ls.push_back(l);
    it = fileCache.emplace(f, ls).first;
  }
  auto& ls = it->second;
  if (o->VpiLineNo() > ls.size()) return "";
  auto& l = ls[o->VpiLineNo() - 1];
  size_t a = o->VpiColumnNo() ? o->VpiColumnNo() - 1 : 0, b = o->VpiEndColumnNo() ? o->VpiEndColumnNo() - 1 : 0;
  if (a > l.size() || b > l.size() || b < a) return "";
  return l.substr(a, b - a);
}
struct P : VpiListener {
  std::map<std::string, int> n;
  std::set<const any*> defs;
  void enterDesign(const design* d, vpiHandle) override {
    if (d->AllModules()) for (auto* m : *d->AllModules()) defs.insert(m);
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) defs.insert(m);
  }
  void enterParam_assign(const param_assign* pa, vpiHandle) override {
    const any* l = pa->Lhs();
    const BaseClass* sc = pa->VpiParent();
    bool defMod = sc && defs.count((const any*)sc) && sc->UhdmType() == uhdmmodule_inst;
    if (l && l->UhdmType() == uhdmparameter) {
      auto* p = (const parameter*)l;
      if (!p->VpiImported().empty() && p->VpiParent() == pa && p->VpiFile().empty() && p->VpiLineNo()) n["LHSFILE"]++;
      if (defMod && !p->VpiImported().empty() && p->VpiParent() != pa) n["LHSCLONE"]++;
    }
    if (auto* r = pa->Rhs(); r && r->UhdmType() == uhdmconstant) {
      std::string t = srcText(r);
      bool inPkg = sc && sc->UhdmType() == uhdmpackage;
      if (!inPkg && sc && sc->UhdmType() == uhdmmodule_inst) {
        if (defs.count((const any*)sc) && t.find("::") != std::string::npos && t.size() > t.rfind("::") + 2) n["QSPAN-def"]++;
        if (!defs.count((const any*)sc) && t.size() >= 2 && t.compare(t.size() - 2, 2, "::") == 0) n["QSPAN-elab"]++;
      }
    }
  }
  void enterRange(const range* r, vpiHandle) override {
    const any* p = r->VpiParent();
    if (p && p->UhdmType() == uhdmpacked_array_typespec && ((const packed_array_typespec*)p)->Typedef_alias() && r->VpiLineNo() == 0) n["AGGRNG"]++;
  }
  void enterConstant(const constant* c, vpiHandle) override {
    if (c->VpiConstType() == vpiRealConst && std::string(c->VpiValue()) != "REAL:" + std::string(c->VpiDecompile())) n["REALTXT"]++;
  }
  void enterAny(const any* o, vpiHandle) override {
    if (auto* t = dynamic_cast<const typespec*>(o)) {
      const any* rt = t->VpiParent();
      if (rt && rt->UhdmType() == uhdmref_typespec && rt->VpiParent() && rt->VpiParent()->UhdmType() == uhdmoperation &&
          t->VpiLineNo() && t->VpiFile().empty()) n["CASTFILE"]++;
    }
  }
  void enterHier_path(const hier_path* h, vpiHandle) override {
    const any* p = h->VpiParent();
    if (!p || p->UhdmType() != uhdmoperation) return;
    int op = ((const operation*)p)->VpiOpType();
    if (op < 62 || op > 65) return;
    auto* es = h->Path_elems();
    if (!es || es->size() < 2) return;
    auto* a = es->at(0); auto* b = es->at(1);
    if (a->VpiName() == "this") return;
    if (a->VpiColumnNo() != b->VpiColumnNo() || a->VpiLineNo() != b->VpiLineNo()) n["INCDEC"]++;
  }
};
// PVAL: the law's algorithm, read-only.
static int pval(const design* d) {
  int changes = 0;
  auto key = [](const parameter* p) { return std::string(p->VpiName()) + '\x01' + std::string(p->VpiImported()); };
  auto defValue = [](const param_assign* pa) -> std::string {
    const any* r = pa->Rhs();
    if (r && r->UhdmType() == uhdmconstant && !((const constant*)r)->VpiValue().empty()) return std::string(((const constant*)r)->VpiValue());
    return "";
  };
  std::map<std::string, std::map<std::string, std::string>> defVals;
  auto scope = [&](const BaseClass* sc, const VectorOfparam_assign* pas, const VectorOfany* params,
                   std::map<std::string, std::string>* rec, const std::map<std::string, std::string>* elab) {
    if (!pas) return;
    std::map<std::string, std::string> vals; std::map<std::string, int> seen; std::set<const any*> lhs;
    for (auto* pa : *pas) {
      auto* l = pa->Lhs();
      if (!l || l->UhdmType() != uhdmparameter) continue;
      lhs.insert(l);
      auto* p = (const parameter*)l;
      std::optional<std::string> v;
      if (elab) { auto it = elab->find(key(p)); if (it != elab->end()) v = it->second; }
      else v = defValue(pa);
      if (!v) continue;
      if ((p->VpiParent() == pa || p->VpiParent() == sc) && p->VpiValue() != *v) changes++;
      if (seen[key(p)]++ == 0) vals.emplace(key(p), *v); else vals.erase(key(p));
      if (rec) rec->emplace(key(p), *v);
    }
    if (params)
      for (auto* a : *params) {
        if (a->UhdmType() != uhdmparameter || a->VpiParent() != sc || lhs.count(a)) continue;
        auto k = key((const parameter*)a);
        std::optional<std::string> ev;
        auto it = vals.find(k);
        if (it != vals.end()) ev = it->second;
        else if (elab) { auto e = elab->find(k); if (e != elab->end()) ev = e->second; }
        if (ev && ((const parameter*)a)->VpiValue() != *ev) changes++;
      }
  };
  auto dn = [](const BaseClass* m) { return std::string(m->VpiDefName().empty() ? m->VpiName() : m->VpiDefName()); };
  if (d->AllModules()) for (auto* m : *d->AllModules()) scope(m, m->Param_assigns(), m->Parameters(), &defVals[dn(m)], nullptr);
  if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) scope(m, m->Param_assigns(), m->Parameters(), &defVals[dn(m)], nullptr);
  std::set<const any*> done;
  auto cls = [&](const VectorOfclass_defn* cs) { if (cs) for (auto* c : *cs) if (done.insert(c).second) scope(c, c->Param_assigns(), c->Parameters(), nullptr, nullptr); };
  for (auto* pv : {d->AllPackages(), d->TopPackages()}) if (pv) for (auto* pk : *pv) { scope(pk, pk->Param_assigns(), pk->Parameters(), nullptr, nullptr); cls(pk->Class_defns()); }
  cls(d->AllClasses());
  std::function<void(const any*)> el = [&](const any* o) {
    auto inst = [&](const auto* m) { auto it = defVals.find(dn(m)); if (it != defVals.end()) scope(m, m->Param_assigns(), m->Parameters(), nullptr, &it->second); };
    auto kids = [&](const auto* m) {
      if (m->Interfaces()) for (auto* c : *m->Interfaces()) el(c);
      if (m->Gen_scope_arrays()) for (auto* ga : *m->Gen_scope_arrays()) if (ga->Gen_scopes()) for (auto* g : *ga->Gen_scopes()) el(g);
    };
    if (o->UhdmType() == uhdmmodule_inst) { auto* m = (const module_inst*)o; inst(m); if (m->Modules()) for (auto* c : *m->Modules()) el(c); kids(m); }
    else if (o->UhdmType() == uhdminterface_inst) { auto* m = (const interface_inst*)o; inst(m); kids(m); }
    else if (o->UhdmType() == uhdmgen_scope) { auto* m = (const gen_scope*)o; if (m->Modules()) for (auto* c : *m->Modules()) el(c); kids(m); }
  };
  if (d->TopModules()) for (auto* t : *d->TopModules()) el(t);
  return changes;
}
int main(int argc, char** argv) {
  if (argc < 2) return 3;
  auto ser = std::make_unique<Serializer>();
  std::vector<vpiHandle> h = ser->Restore(std::string(argv[1]));
  P p; p.listenDesigns(h);
  for (auto hh : h) { int c = pval((const design*)((const uhdm_handle*)hh)->object); if (c) p.n["PVAL"] += c; }
  for (auto& [k, v] : p.n) std::cout << k << "=" << v << " ";
  std::cout << "\n";
  return 0;
}
