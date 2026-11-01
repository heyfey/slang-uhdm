// who <db> <kind-substr> <name> <line> [maxchain]: ref_typespecs pointing at matching typespecs; print chain of each referrer
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string one(const BaseClass*o){ return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); }
static std::string ch(const BaseClass*o,int n){ std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+one(o); return s;}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  std::string kind=argv[2], nm=argv[3]; int line=atoi(argv[4]); int n=argc>5?atoi(argv[5]):8;
  std::map<const any*,int> tgt; int k=0;
  for(auto&[o,id]: s.AllObjects()){ const any*a=(const any*)o; std::string kk(UhdmName(a->UhdmType())); if(kk.find(kind)==std::string::npos) continue; if(a->VpiName()!=nm|| (line&&(int)a->VpiLineNo()!=line)) continue; tgt[a]=k++; std::cout<<"T"<<tgt[a]<<" "<<ch(a,n)<<"\n"; }
  for(auto&[o,id]: s.AllObjects()){ const any*a=(const any*)o; if(a->UhdmType()!=uhdmref_typespec) continue; auto*r=(const ref_typespec*)a; auto it=tgt.find(r->Actual_typespec()); if(it==tgt.end()) continue; std::cout<<"  ->T"<<it->second<<" "<<ch(r->VpiParent(),n)<<"\n"; }
}
