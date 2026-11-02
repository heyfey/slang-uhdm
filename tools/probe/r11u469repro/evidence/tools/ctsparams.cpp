// ctsparams <db> <name> : class_typespecs named so: params and param_assigns
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"-"+std::to_string(o->VpiEndLineNo())+":"+std::to_string(o->VpiEndColumnNo());}
static std::string ch(const BaseClass*o,int n=4){ std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=(i?" < ":"")+one(o); return s;}
int main(int argc,char**argv){
  Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); std::string nm=argv[2];
  for(auto& kv: sa.AllObjects()){ const BaseClass* o=kv.first; if(o->UhdmType()!=uhdmclass_typespec) continue; auto*c=(const class_typespec*)o; if(c->VpiName()!=nm) continue;
    std::cout<<ch(c)<<" cdef="<<one(c->Class_defn())<<"\n";
    if(c->Parameters()) for(auto*p:*c->Parameters()){ std::cout<<"  param "<<ch(p,2); std::cout<<"\n"; }
    if(c->Param_assigns()) for(auto*pa:*c->Param_assigns()){ std::cout<<"  pa lhs="<<one(pa->Lhs())<<" rhs="<<one(pa->Rhs())<<"\n"; }
  }
}
