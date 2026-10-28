// clsvars <db> <pkg> <class> [top|def]: list the class's variables with typespec actual kind, name, loc, instance
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string d(const any*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"#"+std::to_string(o->UhdmId());}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*de=(design*)((uhdm_handle*)h[0])->object;
  bool top=argc<5||std::string(argv[4])=="top";
  auto*l=top?de->TopPackages():de->AllPackages(); if(!l) return 1;
  for(auto*p:*l){ if(p->VpiName()!=argv[2]) continue;
    if(std::string(argv[3])=="-"){ if(p->Typespecs()) for(auto*t:*p->Typespecs()) std::cout<<"  ptd "<<d(t)<<" inst="<<d(t->Instance())<<"\n"; if(p->Variables()) for(auto*v:*p->Variables()) std::cout<<"  pvar "<<d(v)<<"\n"; continue; }
    if(!p->Class_defns()) continue;
    for(auto*c:*p->Class_defns()){ if(c->VpiName()!=argv[3]) continue;
      std::cout<<"class "<<d(c)<<"\n";
      if(c->Variables()) for(auto*v:*c->Variables()){ std::cout<<"  var "<<d(v); auto*vv=(variables*)v; if(auto*rt=vv->Typespec()){ auto*a=rt->Actual_typespec(); std::cout<<" ts="<<d(a); if(a){ std::cout<<" inst="<<d(a->Instance())<<" par="<<d(a->VpiParent());} } std::cout<<"\n"; }
      if(c->Typespecs()) for(auto*t:*c->Typespecs()) std::cout<<"  td "<<d(t)<<" inst="<<d(t->Instance())<<"\n";
    }}
}
