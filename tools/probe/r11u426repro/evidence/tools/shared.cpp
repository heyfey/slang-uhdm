// for a typedef name, list all package/module listings holding each object (by pointer)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
int main(int argc,char**argv){
  std::string want=argv[2]; Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
  std::map<const any*, std::string> where; int idn=0; std::map<const any*,int> ids;
  auto add=[&](const char*tag, const BaseClass* owner, VectorOftypespec* v){ if(!v) return; for(auto*t:*v) if(t->VpiName()==want){ if(!ids.count(t)) ids[t]=idn++; where[t]+=std::string(" ")+tag+":"+std::string(owner->VpiName()); }};
  for(int top=0;top<2;top++){ auto*l=top?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) add(top?"TOPPKG":"DEFPKG",p,p->Typespecs());
    auto*m=top?d->TopModules():d->AllModules(); if(m) for(auto*x:*m) add(top?"TOPMOD":"DEFMOD",x,x->Typespecs()); }
  for(auto&[t,w]:where){ auto*ts=(typespec*)t; std::cout<<"obj#"<<ids[t]<<" inst="<<(ts->Instance()?ts->Instance()->VpiName():"null")<<" parent="<<(t->VpiParent()?t->VpiParent()->VpiName():"null")<<" in"<<w<<"\n";}
}
