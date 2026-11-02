// carhs <db>: for each module (both views) each cont_assign rhs constant: parent kind, typespec actual id/name/instance; and module param typespec ids
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string ts(const ref_typespec* rt){ if(!rt) return "none"; auto*t=rt->Actual_typespec(); if(!t) return "rt->null"; std::string s=std::string(UhdmName(t->UhdmType()))+"#"+std::to_string(t->UhdmId())+"("+std::string(t->VpiName())+")"; if(t->Instance()) s+="@"+std::string(t->Instance()->VpiName())+"#"+std::to_string(t->Instance()->UhdmId()); if(auto*a=t->Typedef_alias()) if(a->Actual_typespec()) s+=" alias#"+std::to_string(a->Actual_typespec()->UhdmId()); s+=" rtfn="+std::string(rt->VpiFullName()); return s; }
template<class M> static void one(const char*v, M*m){
  std::cout<<v<<" "<<m->VpiName()<<"#"<<m->UhdmId()<<"\n";
  if(m->Parameters()) for(auto*a:*m->Parameters()) if(a->UhdmType()==uhdmparameter) std::cout<<"  param "<<a->VpiName()<<"#"<<a->UhdmId()<<" ts "<<ts(((parameter*)a)->Typespec())<<"\n";
  if(m->Param_assigns()) for(auto*pa:*m->Param_assigns()){ std::cout<<"  pa#"<<pa->UhdmId()<<" "<<(pa->Lhs()?pa->Lhs()->VpiName():"?")<<" lhs#"<<(pa->Lhs()?pa->Lhs()->UhdmId():0); if(pa->Rhs()&&pa->Rhs()->UhdmType()==uhdmconstant) std::cout<<" rhs#"<<pa->Rhs()->UhdmId()<<" ts "<<ts(((constant*)pa->Rhs())->Typespec()); std::cout<<"\n"; }
  if(m->Cont_assigns()) for(auto*ca:*m->Cont_assigns()){ auto*r=ca->Rhs(); if(!r) continue; std::cout<<"  ca#"<<ca->UhdmId()<<" rhs "<<UhdmName(r->UhdmType())<<"#"<<r->UhdmId()<<" par="<<(r->VpiParent()?UhdmName(r->VpiParent()->UhdmType()):"null")<<"#"<<(r->VpiParent()?r->VpiParent()->UhdmId():0); if(r->UhdmType()==uhdmconstant) std::cout<<" ts "<<ts(((constant*)r)->Typespec()); std::cout<<"\n"; }
}
int main(int c,char**v){ Serializer s; auto h=s.Restore(std::filesystem::path(v[1])); if(h.empty()) return 1; auto*d=(design*)((uhdm_handle*)h[0])->object;
 if(d->AllModules()) for(auto*p:*d->AllModules()) one("modDEF",p);
 if(d->TopModules()) for(auto*p:*d->TopModules()) one("modTOP",p);
}
