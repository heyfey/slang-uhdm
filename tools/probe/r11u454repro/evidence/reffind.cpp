// reffind <db> <kind-substr> <line> <col>: every ref_typespec whose actual matches, with parent chain
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static std::string desc(const BaseClass*o){ if(!o) return "null"; std::string s=std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); auto*p=o->VpiParent(); for(int i=0;i<7&&p;i++,p=p->VpiParent()) s+=" < "+std::string(UhdmName(p->UhdmType()))+":"+std::string(p->VpiName())+"@"+std::to_string(p->VpiLineNo()); return s;}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
 std::string k=argv[2]; int L=atoi(argv[3]), C=atoi(argv[4]);
 for(auto& [o,id]: s.AllObjects()){ (void)id; auto*b=(const BaseClass*)o; if(b->UhdmType()!=uhdmref_typespec) continue; auto*r=(const ref_typespec*)b; auto*a=r->Actual_typespec(); if(!a) continue;
  if(std::string(UhdmName(a->UhdmType())).find(k)==std::string::npos) continue; if(a->VpiLineNo()!=L||a->VpiColumnNo()!=C) continue;
  std::cout<<desc(r)<<"  ACT="<<desc(a)<<"\n"; } }
