// r11u121 census: per database, the two signatures of this pass's laws.
//   TPI  = cast operations whose target typespec is a VALUE-LESS integer_typespec
//          with no vpiExpr (the failed-bind mint § genScopeTypeParamCastTs121
//          replaces), split by whether a gen_scope is on the parent chain (TPI_G)
//   TPR  = cast operations whose target is a logic/bit/int/byte/... typespec that
//          ALSO serves a type_parameter (the resolved shape golden writes)
//   QSEL = hier_paths whose FIRST element is a ref_obj written `pkg::NAME` in the
//          source (span text contains "::") and that carry a select element
//          (part_select / bit_select / indexed_part_select / var_select)
//   PVR  = ref_objs named `pkg::NAME` bound to a package VARIABLE (§ pkgQualVarRefScopeSpan121 reach)
//   QHP  = hier_paths whose first element ref_obj is NAMED `pkg::NAME` (golden's
//          erased shape) and that carry no select
// usage: cen121 <file.uhdm>   -> one line "TPI_G=a TPI_M=b TPR=c QSEL=d QHP=e"
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
static std::map<std::string, std::vector<std::string>> fcache;
static std::string text(const BaseClass* o) {
  std::string f(o->VpiFile());
  if (f.empty() || o->VpiLineNo() == 0 || o->VpiLineNo() != o->VpiEndLineNo()) return "";
  auto& L = fcache[f];
  if (L.empty()) { std::ifstream in(f); std::string l; while (std::getline(in, l)) L.push_back(l); L.push_back(""); }
  if (o->VpiLineNo() > L.size()) return "";
  auto& l = L[o->VpiLineNo() - 1];
  size_t a = o->VpiColumnNo() ? o->VpiColumnNo() - 1 : 0, b = o->VpiEndColumnNo() ? o->VpiEndColumnNo() - 1 : 0;
  if (a >= l.size() || b <= a) return "";
  return l.substr(a, std::min(b, l.size()) - a);
}
static const std::string fileOf(const BaseClass* o) {
  for (const BaseClass* p = o; p; p = p->VpiParent())
    if (!p->VpiFile().empty()) return std::string(p->VpiFile());
  return "";
}
int main(int argc, char** argv) {
  Serializer s;
  s.Restore(std::filesystem::path(argv[1]));
  std::set<const BaseClass*> tpTs;
  for (auto& [obj, id] : s.AllObjects())
    if (obj && obj->UhdmType() == uhdmtype_parameter) {
      auto tp = (const type_parameter*)obj;
      if (tp->Typespec() && tp->Typespec()->Actual_typespec()) tpTs.insert(tp->Typespec()->Actual_typespec());
    }
  int tpig = 0, tpim = 0, tpr = 0, qsel = 0, qhp = 0, pvr = 0;
  for (auto& [obj, id] : s.AllObjects()) {
    if (!obj) continue;
    if (obj->UhdmType() == uhdmoperation && ((const operation*)obj)->VpiOpType() == vpiCastOp) {
      auto op = (const operation*)obj;
      const typespec* t = op->Typespec() ? op->Typespec()->Actual_typespec() : nullptr;
      if (!t) continue;
      if (t->UhdmType() == uhdminteger_typespec && ((const integer_typespec*)t)->VpiValue().empty() &&
          !((const integer_typespec*)t)->Expr()) {
        bool g = false;
        for (const BaseClass* p = op->VpiParent(); p; p = p->VpiParent())
          if (p->UhdmType() == uhdmgen_scope) g = true;
        (g ? tpig : tpim)++;
      } else if (tpTs.count(t)) tpr++;
    }
    if (obj->UhdmType() == uhdmref_obj) {
      auto ro = (const ref_obj*)obj;
      const any* a = ro->Actual_group();
      if (a && std::string(ro->VpiName()).find("::") != std::string::npos && a->VpiParent() &&
          a->VpiParent()->UhdmType() == uhdmpackage) {
        std::string an(UhdmName(a->UhdmType()));
        if (an.size() > 4 && an.compare(an.size() - 4, 4, "_var") == 0) pvr++;
      }
    }
    if (obj->UhdmType() == uhdmhier_path) {
      auto hp = (const hier_path*)obj;
      if (!hp->Path_elems() || hp->Path_elems()->empty()) continue;
      auto e0 = hp->Path_elems()->at(0);
      if (e0->UhdmType() != uhdmref_obj) continue;
      bool sel = false;
      for (auto e : *hp->Path_elems()) {
        auto k = e->UhdmType();
        if (k == uhdmpart_select || k == uhdmbit_select || k == uhdmindexed_part_select || k == uhdmvar_select) sel = true;
      }
      std::string nm(e0->VpiName());
      if (sel) {
        // the written text of the base reference: the ref_obj's own span
        std::string f = fileOf(e0);
        const_cast<BaseClass*>(e0);
        std::string t;
        if (!f.empty()) {
          auto& L = fcache[f];
          if (L.empty()) { std::ifstream in(f); std::string l; while (std::getline(in, l)) L.push_back(l); L.push_back(""); }
          if (e0->VpiLineNo() && e0->VpiLineNo() == e0->VpiEndLineNo() && e0->VpiLineNo() <= L.size()) {
            auto& l = L[e0->VpiLineNo() - 1];
            size_t a = e0->VpiColumnNo() - 1, b = e0->VpiEndColumnNo() - 1;
            if (a < l.size() && b > a) t = l.substr(a, std::min(b, l.size()) - a);
          }
        }
        if (t.find("::") != std::string::npos || nm.find("::") != std::string::npos) qsel++;
      } else if (nm.find("::") != std::string::npos && hp->Path_elems()->size() >= 2) qhp++;
    }
  }
  std::cout << "TPI_G=" << tpig << " TPI_M=" << tpim << " TPR=" << tpr << " QSEL=" << qsel << " QHP=" << qhp << " PVR=" << pvr << "\n";
}
