// pchain <db>: for every package view, every parameter and param_assign Lhs/Rhs: typespec chain with Instance (DEF/TOP) per hop
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static design* D;
static std::string inst(const BaseClass*i){ if(!i) return "null"; if((const void*)i==(const void*)D) return "design"; std::string v="?"; if(D->TopPackages()) for(auto*p:*D->TopPackages()) if((const void*)p==(const void*)i) v="TOP"; if(D->AllPackages()) for(auto*p:*D->AllPackages()) if((const void*)p==(const void*)i) v="DEF"; return std::string(i->VpiName())+"!"+v;}
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"#"+std::to_string(o->UhdmId());}
static std::string chain(const ref_typespec* rt){ std::string s; std::set<const void*> seen; while(rt){ auto*t=rt->Actual_typespec(); s+=" -> rt'"+std::string(rt->VpiName())+"' "+one(t); if(!t||!seen.insert(t).second) break; s+=" inst="+inst(t->Instance()); rt=t->Typedef_alias(); } return s; }
int main(int argc,char**argv){
  Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); D=(design*)((uhdm_handle*)ha[0])->object;
  for(int k=0;k<2;k++){ auto*l=k?D->TopPackages():D->AllPackages(); if(!l) continue; for(auto*p:*l){ std::string tag=std::string(k?"TOP ":"DEF ")+std::string(p->VpiName());
    if(p->Parameters()) for(auto*x:*p->Parameters()) if(x->UhdmType()==uhdmparameter){ auto*pp=(const parameter*)x; std::cout<<tag<<" param"<<(pp->VpiImported().empty()?"":"[imp]")<<" "<<one(pp)<<chain(pp->Typespec())<<"\n"; }
    if(p->Param_assigns()) for(auto*pa:*p->Param_assigns()){ auto*r=pa->Rhs(); if(r&&r->UhdmType()==uhdmconstant) std::cout<<tag<<" pa-rhs "<<one(r)<<chain(((const constant*)r)->Typespec())<<"\n"; auto*lh=pa->Lhs(); if(lh&&lh->UhdmType()==uhdmparameter) std::cout<<tag<<" pa-lhs "<<one(lh)<<chain(((const parameter*)lh)->Typespec())<<"\n"; }
  } }
}
