// predict133: reads a PRISTINE database and prints which r11u133 law's trigger
// it holds (one line per law with a count). Measurement only.
//  LHSCLONE  a definition module/interface or a package whose param_assign Lhs is an
//            imported parameter that is also the scope's own Parameters() entry
//  HPMID     a hier_path over a base select whose MIDDLE ref_obj stores a full name
//  TRAILIDX  a hier_path whose last element is a bit_select holding a ref_obj index
//            (directly or under operations) whose full name lacks the path's name
//  PATQUAL   an elaborated param_assign whose Rhs op75 spans text containing `::`
//            (read from the source file) beyond the qualifier
//  UNKFILE   a located constant with an X/Z binary value and no file under an
//            operation under a param_assign
#include <uhdm/Serializer.h>
#include <uhdm/VpiListener.h>
#include <uhdm/uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <fstream>
#include <iostream>
#include <map>
#include <memory>
#include <set>
#include <string>
#include <vector>
using namespace UHDM;
namespace {
std::map<std::string, int> hits;
std::map<std::string, std::vector<std::string>> files;
std::string lineOf(const std::string& f, int ln) {
  auto it = files.find(f);
  if (it == files.end()) {
    std::vector<std::string> v;
    std::ifstream in(f);
    std::string l;
    while (std::getline(in, l)) v.push_back(l);
    it = files.emplace(f, v).first;
  }
  if (ln <= 0 || ln > (int)it->second.size()) return "";
  return it->second[ln - 1];
}
std::string fileOf(const any* o) {
  for (const any* p = o; p; p = p->VpiParent())
    if (!p->VpiFile().empty()) return std::string(p->VpiFile());
  return "";
}
void scope133(const BaseClass* sc, const VectorOfparam_assign* pas, const VectorOfany* params) {
  if (!pas || !params) return;
  std::set<const any*> listed(params->begin(), params->end());
  for (auto* pa : *pas) {
    auto* l = pa ? pa->Lhs() : nullptr;
    if (!l || l->UhdmType() != uhdmparameter) continue;
    auto* p = (const parameter*)l;
    if (!p->VpiImported().empty() && listed.count(p) && p->VpiParent() == sc) hits["LHSCLONE"]++;
  }
}
class L : public VpiListener {
 public:
  bool topView = false;
  void enterAny(const any* o, vpiHandle h) override {
    if (o->UhdmType() == uhdmhier_path) {
      auto* hp = (const hier_path*)o;
      auto* pe = hp->Path_elems();
      if (!pe || pe->empty()) return;
      int n = pe->size();
      if ((*pe)[0]->UhdmType() == uhdmbit_select)
        for (int i = 1; i + 1 < n; ++i)
          if ((*pe)[i]->UhdmType() == uhdmref_obj && !((const ref_obj*)(*pe)[i])->VpiFullName().empty())
            hits["HPMID"]++;
      auto* last = (*pe)[n - 1];
      if (last->UhdmType() == uhdmbit_select) {
        auto* ix = ((const bit_select*)last)->VpiIndex();
        std::vector<const any*> st;
        if (ix && ix->VpiParent() == last) st.push_back(ix);
        while (!st.empty()) {
          auto* e = st.back(); st.pop_back();
          if (e->UhdmType() == uhdmref_obj) {
            std::string fn(((const ref_obj*)e)->VpiFullName());
            if (fn.find(std::string(hp->VpiName())) == std::string::npos) hits["TRAILIDX"]++;
          } else if (e->UhdmType() == uhdmoperation && ((const operation*)e)->Operands())
            for (auto* x : *((const operation*)e)->Operands()) if (x && x->VpiParent() == e) st.push_back(x);
        }
      }
    }
    if (o->UhdmType() == uhdmparam_assign) {
      auto* pa = (const param_assign*)o;
      auto* r = pa->Rhs();
      if (r && r->UhdmType() == uhdmoperation && ((const operation*)r)->VpiOpType() == 75) {
        std::string ln = lineOf(fileOf(r), r->VpiLineNo());
        if (!ln.empty() && r->VpiLineNo() == r->VpiEndLineNo() && r->VpiEndColumnNo() > r->VpiColumnNo()) {
          std::string t = ln.substr(r->VpiColumnNo() - 1, r->VpiEndColumnNo() - r->VpiColumnNo());
          auto q = t.rfind("::");
          if (q != std::string::npos && q + 2 < t.size()) hits["PATQUAL"]++;
        }
      }
      if (r && r->UhdmType() == uhdmoperation && ((const operation*)r)->Operands())
        for (auto* x : *((const operation*)r)->Operands())
          if (x->UhdmType() == uhdmconstant) {
            auto* c = (const constant*)x;
            std::string v(c->VpiValue());
            if (v.rfind("BIN:", 0) == 0 && v.find_first_of("XZxz", 4) != std::string::npos &&
                c->VpiFile().empty() && c->VpiLineNo() > 0) hits["UNKFILE"]++;
          }
    }
  }
};
}  // namespace
int main(int argc, char** argv) {
  if (argc < 2) return 3;
  auto ser = std::make_unique<Serializer>();
  std::vector<vpiHandle> h = ser->Restore(std::string(argv[1]));
  for (auto dh : h) {
    auto* d = (const design*)((const uhdm_handle*)dh)->object;
    for (auto* pv : {d->AllPackages(), d->TopPackages()})
      if (pv) for (auto* p : *pv) scope133(p, p->Param_assigns(), p->Parameters());
    if (d->AllModules()) for (auto* m : *d->AllModules()) scope133(m, m->Param_assigns(), m->Parameters());
    if (d->AllInterfaces()) for (auto* m : *d->AllInterfaces()) scope133(m, m->Param_assigns(), m->Parameters());
  }
  L l;
  l.listenDesigns(h);
  for (auto& [k, v] : hits) std::cout << k << "=" << v << " ";
  std::cout << "\n";
  return 0;
}
