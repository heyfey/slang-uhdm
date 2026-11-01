// alias <db> <kind-substr> <name> <line>: for each matching typespec, print parent chain, instance, and the typedef-alias chain
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); }
static std::string ch(const BaseClass*o,int n){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+one(o); return s;}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  std::string kind=argv[2], nm=argv[3]; int line=atoi(argv[4]);
  std::map<std::string,int> agg;
  for(auto&[o,id]: s.AllObjects()){ const any*a=(const any*)o; std::string kk(UhdmName(a->UhdmType())); if(kk.find(kind)==std::string::npos) continue; if(a->VpiName()!=nm|| (line&&(int)a->VpiLineNo()!=line)) continue;
    auto*t=any_cast<const typespec*>(a); if(!t) continue; std::string s2="par="+ch(t->VpiParent(),3)+" inst="+one(t->Instance());
    const typespec*c=t; int d=0; while(c && c->Typedef_alias() && d<5){ c=c->Typedef_alias()->Actual_typespec(); s2+="\n     alias-> "+one(c)+" par="+ch(c?c->VpiParent():nullptr,3)+" inst="+one(c?c->Instance():nullptr); d++; }
    agg[s2]++; }
  for(auto&[k,v]:agg) std::cout<<v<<"x "<<k<<"\n";
}
