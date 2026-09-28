// v11u193: predictor for the three refinements, read from a LAW-binary (pre-refinement) database only.
//   NESTPKGQ  an object a nested definition owns whose stored full name (after § nestedDefChainName193) carries,
//             after the definition's name, a `.`-separated token that names a package followed by `.`
//             (the `::` the law rewrote; § nestChainKeepsPkgQual193v)
//   NESTSEL   a bit/part/indexed-part/var select a nested definition owns whose stored full name starts with the
//             definition's name (§ nestChainSelects193v)
//   UCRANGE   an elaborated cont_assign (parent an elaborated instance) whose Lhs is a part or indexed part select,
//             whose Rhs holds an unsized constant, and whose range / width holds a reference whose stored full name
//             starts with the instance's DEFINITION name + "." (§ ucCloneUnnamesRanges193v)
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
    case uhdmoperation: if (auto* os = ((const operation*)x)->Operands()) for (auto* o : *os) if (hasUnsized(o, d + 1)) return true; return false;
    case uhdmsys_func_call: if (auto* as = ((const sys_func_call*)x)->Tf_call_args()) for (auto* a : *as) if (hasUnsized(a, d + 1)) return true; return false;
    case uhdmfunc_call: if (auto* as = ((const func_call*)x)->Tf_call_args()) for (auto* a : *as) if (hasUnsized(a, d + 1)) return true; return false;
    case uhdmbit_select: return hasUnsized(((const bit_select*)x)->VpiIndex(), d + 1);
    case uhdmpart_select: return hasUnsized(((const part_select*)x)->Left_range(), d + 1) || hasUnsized(((const part_select*)x)->Right_range(), d + 1);
    case uhdmindexed_part_select: return hasUnsized(((const indexed_part_select*)x)->Base_expr(), d + 1) || hasUnsized(((const indexed_part_select*)x)->Width_expr(), d + 1);
    default: return false;
  }
}
static bool defRef(const any* x, const std::string& pfx, int d = 0) {
  if (!x || d > 64) return false;
  switch (x->UhdmType()) {
    case uhdmref_obj: { std::string f(((const ref_obj*)x)->VpiFullName()); return f.compare(0, pfx.size(), pfx) == 0 && f.size() > pfx.size(); }
    case uhdmoperation: if (auto* os = ((const operation*)x)->Operands()) for (auto* o : *os) if (defRef(o, pfx, d + 1)) return true; return false;
    case uhdmconstant: return false;
    default: return false;
  }
}
int main(int argc, char** argv) {
  Serializer s; s.Restore(std::string(argv[1]));
  const design* dz = nullptr;
  for (auto& kv : s.AllObjects()) { const any* o = (const any*)kv.first; if (o && o->UhdmType() == uhdmdesign) dz = (const design*)o; }
  if (!dz) return 2;
  std::set<std::string> pk; for (auto* pv : {dz->AllPackages(), dz->TopPackages()}) if (pv) for (auto* p : *pv) if (p) pk.insert(std::string(p->VpiName()));
  std::set<const any*> nested;
  if (dz->AllModules()) for (auto* m : *dz->AllModules()) if (m && m->VpiParent() && m->VpiParent()->UhdmType() == uhdmmodule_inst) nested.insert(m);
  int npk = 0, nsel = 0, ucr = 0;
  for (auto& kv : s.AllObjects()) {
    const any* o = (const any*)kv.first; if (!o) continue;
    if (!nested.empty()) {
      const any* own = nullptr;
      for (const any* a = o->VpiParent(); a; a = a->VpiParent()) { auto t = a->UhdmType();
        if (t == uhdmclass_defn || t == uhdmpackage || t == uhdmdesign || t == uhdminterface_inst || t == uhdmprogram) break;
        if (t == uhdmmodule_inst) { own = a; break; } }
      if (own && nested.count(own)) {
        std::string def(((const module_inst*)own)->VpiDefName());
        auto t = o->UhdmType();
        if (t == uhdmbit_select || t == uhdmpart_select || t == uhdmindexed_part_select || t == uhdmvar_select) {
          std::string f(((const ref_obj*)o)->VpiFullName()); if (f.compare(0, def.size(), def) == 0) ++nsel; }
        std::string f;
        if (t == uhdmref_obj) f = std::string(((const ref_obj*)o)->VpiFullName());
        else if (t == uhdmref_typespec) f = std::string(((const ref_typespec*)o)->VpiFullName());
        else if (t == uhdmhier_path) f = std::string(((const hier_path*)o)->VpiFullName());
        else if (t == uhdmparameter) f = std::string(((const parameter*)o)->VpiFullName());
        else if (auto* n = any_cast<const nets*>(o)) f = std::string(n->VpiFullName());
        else if (auto* v = any_cast<const variables*>(o)) f = std::string(v->VpiFullName());
        else if (auto* sc = any_cast<const scope*>(o)) f = std::string(sc->VpiFullName());
        size_t at = f.find("." + def + ".");
        if (at != std::string::npos) { std::string rest = f.substr(at + def.size() + 2); size_t b = 0;
          while (b < rest.size()) { size_t e = rest.find('.', b); if (e == std::string::npos) break; if (pk.count(rest.substr(b, e - b))) { ++npk; break; } b = e + 1; } }
      }
    }
    if (o->UhdmType() == uhdmcont_assign) {
      auto* ca = (const cont_assign*)o; auto* p = ca->VpiParent();
      if (!p || p->UhdmType() != uhdmmodule_inst) continue;
      bool isDef = false; if (dz->AllModules()) for (auto* m : *dz->AllModules()) if (m == p) isDef = true;
      if (isDef) continue;
      auto* l = ca->Lhs(); if (!l || !hasUnsized(ca->Rhs())) continue;
      std::string def(((const module_inst*)p)->VpiDefName()); std::string pfx = def + ".";
      bool hit = false;
      if (l->UhdmType() == uhdmpart_select) hit = defRef(((const part_select*)l)->Left_range(), pfx) || defRef(((const part_select*)l)->Right_range(), pfx);
      else if (l->UhdmType() == uhdmindexed_part_select) hit = defRef(((const indexed_part_select*)l)->Width_expr(), pfx);
      if (hit) ++ucr;
    }
  }
  if (npk) printf("NESTPKGQ=%d\n", npk); if (nsel) printf("NESTSEL=%d\n", nsel); if (ucr) printf("UCRANGE=%d\n", ucr);
  if (!nested.empty()) printf("NESTED_DEFS=%zu\n", nested.size());
  return 0;
}
