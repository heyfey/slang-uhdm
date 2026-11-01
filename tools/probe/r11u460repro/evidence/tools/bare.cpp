// bare <db>: typespecs whose typedef alias target is itself named without '::' and has no alias and no parent; print alias-holder's referrer chain (via ref_typespec) aggregated
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); }
static std::string ch(const BaseClass*o,int n){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+one(o); return s;}
int main(int argc,char**argv){ Serializer s; s.Restore(std::filesystem::path(argv[1]));
  std::map<const any*,const any*> refBy; for(auto&[o,i]:s.AllObjects()){ auto*a=(const any*)o; if(a->UhdmType()==uhdmref_typespec){ auto*r=(const ref_typespec*)a; if(r->Actual_typespec() && r->VpiParent() && r->VpiParent()->UhdmType()!=uhdmclass_typespec) refBy[r->Actual_typespec()]=r->VpiParent(); } }
  std::map<std::string,int> agg;
  for(auto&[o,i]:s.AllObjects()){ auto*a=(const any*)o; auto*t=any_cast<const typespec*>(a); if(!t||!t->Typedef_alias()) continue; auto*y=t->Typedef_alias()->Actual_typespec(); if(!y) continue; std::string yn(y->VpiName()); if(yn.empty()||yn.find("::")!=std::string::npos||y->Typedef_alias()||y->VpiParent()) continue;
    auto it=refBy.find(t); agg[one(t)+" -> "+one(y)+" | used by "+(it==refBy.end()?std::string("-"):ch(it->second,4))]++; }
  for(auto&[k,v]:agg) std::cout<<v<<"x "<<k<<"\n"; }
