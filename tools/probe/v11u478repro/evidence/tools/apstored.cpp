// apstored <db>: for every class_typespec owned by a ref_typespec, each param_assign's parameter Lhs
// (parented by the param_assign or the copy): whether a full name is STORED in the database (the
// symbol id read through an explicit instantiation, as ParamEmit's r215StoredFullName does) and the
// stored name.  Counts: candidates, stored, unstored.  § aliasCopyParamUnnamed478's getter audit.
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
namespace { template <typename Tag, typename Tag::type M> struct Rob { friend typename Tag::type get(Tag) { return M; } };
struct PF { typedef SymbolId parameter::*type; friend type get(PF); }; }
template struct Rob<PF, &parameter::vpiFullName_>;
int main(int argc, char** argv) {
  Serializer s; auto h = s.Restore(std::filesystem::path(argv[1])); (void)h;
  long cand = 0, stored = 0; bool verbose = argc > 2;
  for (auto& kv : s.AllObjects()) {
    auto* o = (const any*)kv.first;
    if (o->UhdmType() != uhdmclass_typespec || !o->VpiParent() || o->VpiParent()->UhdmType() != uhdmref_typespec) continue;
    auto* c = (const class_typespec*)o; if (!c->Param_assigns()) continue;
    for (auto* pa : *c->Param_assigns()) {
      auto* l = pa ? pa->Lhs() : nullptr;
      if (!l || l->UhdmType() != uhdmparameter || (l->VpiParent() != pa && l->VpiParent() != c)) continue;
      auto* p = (const parameter*)l; ++cand; bool st = (bool)(p->*get(PF()));
      if (st) ++stored;
      if (verbose) std::cout << (st ? "STORED " : "unstored ") << c->VpiName() << "." << p->VpiName() << " " << (st ? std::string(p->VpiFullName()) : std::string("")) << "\n";
    }
  }
  std::cout << "candidates " << cand << " stored " << stored << " unstored " << cand - stored << "\n";
}
