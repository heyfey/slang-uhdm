// tsmem <db> <structname-suffix>: for each struct_typespec named ..suffix, print its instance and each member's typespec actual instance
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string nm=argv[2];
  auto in=[&](const BaseClass*i){ if(!i) return std::string("null"); std::string tag="?"; for(int top=0;top<2;top++){ auto*l=top?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) if(p==i) tag=top?"TOP":"DEF"; auto*m=top?d->TopModules():d->AllModules(); if(m) for(auto*p:*m) if(p==i) tag=top?"TOPM":"DEFM";} if(i==d) tag="design"; return std::string(i->VpiName())+"#"+tag;};
  for(auto&[o,id]: s.AllObjects()){ const any*a=(const any*)o; if(a->UhdmType()!=uhdmstruct_typespec) continue; std::string n(a->VpiName()); if(n.size()<nm.size()||n.substr(n.size()-nm.size())!=nm) continue; auto*st=(const struct_typespec*)a;
    std::string par="null"; if(auto*p=a->VpiParent()){ par=UhdmName(p->UhdmType()); if(p->VpiParent()) par+=std::string("<")+std::string(UhdmName(p->VpiParent()->UhdmType()))+":"+std::string(p->VpiParent()->VpiName());}
    std::cout<<n<<" @"<<a->VpiLineNo()<<":"<<a->VpiColumnNo()<<" inst="<<in(st->Instance())<<" par="<<par<<" members:";
    if(st->Members()) for(auto*m:*st->Members()){ auto*rt=m->Typespec(); auto*t=rt?rt->Actual_typespec():nullptr; std::cout<<" "<<m->VpiName()<<"="<<(t?std::string(UhdmName(t->UhdmType()))+"/"+in(t->Instance()):"none"); }
    std::cout<<"\n"; }
}
