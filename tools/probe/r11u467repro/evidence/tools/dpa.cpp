// dpa <db> <name>: design-level param_assigns/parameters named <name>: lhs, its ref_typespec id, parent chain, stored full name
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string ch(const BaseClass*o,int n=5){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"#"+std::to_string(o->UhdmId()); return s;}
int main(int argc,char**argv){ Serializer sa; auto v=sa.Restore(std::filesystem::path(argv[1])); std::string nm=argv[2];
 for(auto* h: v){ design* d=(design*)((uhdm_handle*)h)->object;
  if(d->Param_assigns()) { int i=0; for(auto*pa:*d->Param_assigns()){ i++; auto*l=pa->Lhs(); if(!l||l->VpiName()!=nm) continue; auto*p=(parameter*)l; auto*rt=p->Typespec();
   std::cout<<"PA#"<<i<<" lhs#"<<l->UhdmId()<<" imp="<<p->VpiImported()<<" rt="<<ch(rt)<<" rtFull="<<(rt?std::string(rt->VpiFullName()):"")<<" act="<<(rt&&rt->Actual_typespec()?ch(rt->Actual_typespec(),2):"")<<"\n"; } }
  if(d->Parameters()) { int i=0; for(auto*l:*d->Parameters()){ i++; if(l->VpiName()!=nm) continue; const ref_typespec* rt=nullptr; if(l->UhdmType()==uhdmparameter) rt=((parameter*)l)->Typespec();
   std::cout<<"P#"<<i<<" #"<<l->UhdmId()<<" rt="<<ch(rt)<<" rtFull="<<(rt?std::string(rt->VpiFullName()):"")<<"\n"; } }
 }
}
