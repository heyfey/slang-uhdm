// clsparams <db> <classname>: print parameters / param_assigns of every class_defn named so (design AllClasses + packages)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"-"+std::to_string(o->VpiEndLineNo())+":"+std::to_string(o->VpiEndColumnNo());}
int main(int argc,char**argv){
  Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); std::string nm=argv[2];
  for(auto& kv: sa.AllObjects()){ const BaseClass* o=kv.first; if(o->UhdmType()!=uhdmclass_defn) continue; auto*c=(const class_defn*)o; if(c->VpiName()!=nm) continue;
    std::cout<<one(c)<<" parent="<<one(c->VpiParent())<<"\n";
    if(c->Parameters()) for(auto*p:*c->Parameters()){ std::cout<<"  param "<<one(p); if(p->UhdmType()==uhdmparameter){ auto*pp=(const parameter*)p; std::cout<<" val="<<pp->VpiValue()<<" imported="<<pp->VpiImported()<<" local="<<pp->VpiLocalParam(); } std::cout<<"\n"; }
    if(c->Param_assigns()) for(auto*pa:*c->Param_assigns()){ std::cout<<"  pa lhs="<<one(pa->Lhs())<<" rhs="<<one(pa->Rhs())<<"\n"; }
  }
}
