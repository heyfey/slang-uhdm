// insts <uhdm>: every typespec object with its Instance and its alias, sorted
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
    const any* o = (const any*)kv.first; if(!o) continue;
    auto* t = any_cast<const typespec*>(o); if(!t) continue;
    std::ostringstream os;
    os << UhdmName(o->UhdmType()) << " '" << t->VpiName() << "' " << o->VpiLineNo() << ":" << o->VpiColumnNo() << "-" << o->VpiEndLineNo() << ":" << o->VpiEndColumnNo();
    if (auto* i = t->Instance()) os << " inst=" << UhdmName(i->UhdmType()) << ":" << i->VpiName() << "/" << ((const any*)i)->VpiLineNo() << (defs.count((const any*)i) ? "DEF" : "ELAB:" + std::string(((const any*)i)->VpiName()));
    if (auto* a = t->Typedef_alias()) os << " alias";
    if (auto* p = o->VpiParent()) os << " par=" << UhdmName(p->UhdmType()); else os << " par=-";
    out.insert(os.str());
  }
  for (auto& l : out) std::cout << l << "\n";
}
