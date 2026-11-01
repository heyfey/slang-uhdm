// tsc <db> <kind-substr> <line> <col>: objects of kind at line:col; print parent chain + ref_typespec actual + alias chain (names, parents, inst)
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
  std::string kind=argv[2]; int line=atoi(argv[3]), col=atoi(argv[4]); int n=argc>5?atoi(argv[5]):6;
  std::map<std::string,int> agg;
  for(auto&[o,id]: s.AllObjects()){ const any*a=(const any*)o; std::string kk(UhdmName(a->UhdmType())); if(kk.find(kind)==std::string::npos) continue; if((int)a->VpiLineNo()!=line||(int)a->VpiColumnNo()!=col) continue;
    const ref_typespec* rt=nullptr;
    if(auto*v=any_cast<const variables*>(a)) rt=v->Typespec(); else if(auto*e=any_cast<const expr*>(a)) rt=e->Typespec(); else if(auto*io=any_cast<const io_decl*>(a)) rt=io->Typespec(); else if(auto*p=any_cast<const parameter*>(a)) rt=p->Typespec();
    std::string out=ch(a,n);
    const typespec* t=rt?rt->Actual_typespec():nullptr; int d=0;
    while(t && d<6){ out+="\n    ts "+one(t)+" par="+ch(t->VpiParent(),3)+" inst="+one(t->Instance()); if(!t->Typedef_alias()) break; t=t->Typedef_alias()->Actual_typespec(); out+="\n    (alias)"; d++; }
    agg[out]++; }
  for(auto&[k,v]:agg) std::cout<<v<<"x "<<k<<"\n";
}
