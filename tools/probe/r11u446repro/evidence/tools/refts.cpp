// refts <db> <kind-substr> <name> <line>: objects of kind with name at line; print their ref_typespec actual + instance + parent chain
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string ch(const BaseClass*o,int n=6){ std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo()); return s;}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
  std::string kind=argv[2], nm=argv[3]; int line=atoi(argv[4]);
  auto in=[&](const BaseClass*i){ if(!i) return std::string("null"); std::string tag="?"; for(int top=0;top<2;top++){ auto*l=top?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) if(p==i) tag=top?"TOP":"DEF";} if(i==d) tag="design"; return std::string(i->VpiName())+"#"+tag;};
  for(auto&[o,id]: s.AllObjects()){ const any*a=(const any*)o; std::string k(UhdmName(a->UhdmType())); if(k.find(kind)==std::string::npos) continue; if(a->VpiName()!=nm || (line && (int)a->VpiLineNo()!=line)) continue;
    const ref_typespec* rt=nullptr;
    if(auto*v=any_cast<const variables*>(a)) rt=v->Typespec(); else if(auto*e=any_cast<const expr*>(a)) rt=e->Typespec(); else if(auto*io=any_cast<const io_decl*>(a)) rt=io->Typespec();
    const typespec* t=rt?rt->Actual_typespec():nullptr;
    std::cout<<ch(a)<<"\n   ts="<<(t?std::string(UhdmName(t->UhdmType()))+":"+std::string(t->VpiName())+"@"+std::to_string(t->VpiLineNo())+":"+std::to_string(t->VpiColumnNo())+" inst="+in(t->Instance())+" par="+ch(t->VpiParent(),2):"none")<<"\n"; }
}
