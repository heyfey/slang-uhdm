#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string nm=argv[2];
  auto in=[&](const BaseClass*i){ if(!i) return std::string("null"); std::string tag="?"; for(int top=0;top<2;top++){ auto*l=top?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) if(p==i) tag=top?"TOP":"DEF"; auto*m=top?d->TopModules():d->AllModules(); if(m) for(auto*p:*m) if(p==i) tag=top?"TOPM":"DEFM";} if(i==d) tag="design"; return std::string(i->VpiName())+"#"+tag;};
  auto par=[&](const BaseClass*a){ auto*p=a->VpiParent(); if(!p) return std::string("null"); std::string s=UhdmName(p->UhdmType()); s+=":"+std::string(p->VpiName()); if(p->VpiParent()) s+="<"+std::string(UhdmName(p->VpiParent()->UhdmType()))+":"+std::string(p->VpiParent()->VpiName()); return s;};
  auto desc=[&](const typespec*t){ return std::string(UhdmName(t->UhdmType()))+" '"+std::string(t->VpiName())+"' @"+std::to_string(t->VpiLineNo())+":"+std::to_string(t->VpiColumnNo())+" inst="+in(t->Instance())+" par="+par(t);};
  std::map<const any*,int> ids; auto id=[&](const any*a){ auto it=ids.find(a); if(it!=ids.end()) return it->second; int n=ids.size(); ids[a]=n; return n;};
  for(auto&[o,_]: s.AllObjects()){ const any*a=(const any*)o; if(a->UhdmType()!=uhdmenum_typespec) continue; std::string n(a->VpiName()); if(n.size()<nm.size()||n.substr(n.size()-nm.size())!=nm) continue;
    auto*e=(const enum_typespec*)a; std::cout<<"#"<<id(e)<<" "<<desc(e)<<"\n";
    const typespec* t=e->Base_typespec()?e->Base_typespec()->Actual_typespec():nullptr; int g=0;
    while(t && g++<6){ std::cout<<"   base #"<<id(t)<<" "<<desc(t)<<"\n"; t=t->Typedef_alias()?t->Typedef_alias()->Actual_typespec():nullptr; if(t) std::cout<<"   alias->"; }
  }
}
