// refs <uhdm>: every ref_typespec: parent kind/name -> actual kind/name alias? inst
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
#include <sstream>
using namespace UHDM;
int main(int argc,char**argv){
  Serializer s; auto hs = s.Restore(std::filesystem::path(argv[1]));
  auto* d=(design*)((uhdm_handle*)hs[0])->object;
  std::set<const any*> defs; if (d->AllModules()) for (auto* m : *d->AllModules()) defs.insert(m);
  std::multiset<std::string> out;
  for (auto& kv : s.AllObjects()) {
    const any* o = (const any*)kv.first; if(!o || o->UhdmType()!=uhdmref_typespec) continue;
    auto* r=(const ref_typespec*)o; std::ostringstream os;
    auto* p=o->VpiParent();
    os << (p?UhdmName(p->UhdmType()):"-") << ":" << (p?std::string(p->VpiName()):"") << " [" << r->VpiFullName() << "] -> ";
    auto* a=r->Actual_typespec();
    if(!a){os<<"null";} else {
      os << UhdmName(a->UhdmType()) << ":" << a->VpiName();
      if (a->Typedef_alias()) os << " alias";
      if (auto* i=a->Instance()) os << " inst=" << (defs.count((const any*)i)?"DEF":"ELAB");
      os << (a->VpiParent()?" parented":" unparented");
    }
    out.insert(os.str());
  }
  for (auto& l : out) std::cout << l << "\n";
}
