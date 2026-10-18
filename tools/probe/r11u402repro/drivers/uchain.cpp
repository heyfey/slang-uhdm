// usage: uchain <db> <param-name-at-design>  : print the typespec chain of a design-level parameter
#include <uhdm/Serializer.h>
#include <uhdm/uhdm.h>
#include <iostream>
using namespace UHDM;
static std::string d(const any* o){ if(!o) return "<null>"; std::string s=UhdmName(o->UhdmType()); s+="("+std::string(o->VpiName())+")#"+std::to_string(o->UhdmId()); return s; }
static void chain(const ref_typespec* rt,int dep){
  if(!rt||dep>6) return; std::string ind(dep*2,' ');
  std::cout<<ind<<"ref "<<rt->VpiFullName()<<" #"<<rt->UhdmId()<<" parent="<<d(rt->VpiParent())<<"\n";
  const typespec* a=rt->Actual_typespec(); if(!a){std::cout<<ind<<"  actual null\n";return;}
  std::cout<<ind<<"  -> "<<d(a)<<" parent="<<d(a->VpiParent())<<" inst="<<d(a->Instance())<<" line="<<a->VpiLineNo()<<"\n";
  chain(a->Typedef_alias(),dep+1);
}
int main(int c,char**v){ Serializer s; auto h=s.Restore(std::string(v[1])); if(h.empty()) return 1;
  design* dsn=(design*)((uhdm_handle*)h[0])->object;
  if(dsn->Parameters()) for(auto* p: *dsn->Parameters()) if(p->VpiName()==v[2]){
    std::cout<<"design param "<<d(p)<<"\n"; if(p->UhdmType()==uhdmparameter) chain(((parameter*)p)->Typespec(),1); }
  if(dsn->Param_assigns()) for(auto* pa:*dsn->Param_assigns()) if(pa->Lhs() && pa->Lhs()->VpiName()==v[2]){
    std::cout<<"design pa lhs "<<d(pa->Lhs())<<"\n"; if(pa->Lhs()->UhdmType()==uhdmparameter) chain(((parameter*)pa->Lhs())->Typespec(),1);
    if(pa->Rhs()) { std::cout<<"  rhs "<<d(pa->Rhs())<<"\n"; if(pa->Rhs()->UhdmType()==uhdmconstant) chain(((constant*)pa->Rhs())->Typespec(),2);} }
  if(c>3 && dsn->AllPackages()) for(auto* pk:*dsn->AllPackages()) if(pk->Parameters()) for(auto* p:*pk->Parameters()) if(p->VpiName()==v[2]){
    std::cout<<"pkg param "<<d(p)<<" in "<<d(pk)<<"\n"; if(p->UhdmType()==uhdmparameter) chain(((parameter*)p)->Typespec(),1);}
  if(c>3 && dsn->TopPackages()) for(auto* pk:*dsn->TopPackages()) if(pk->Parameters()) for(auto* p:*pk->Parameters()) if(p->VpiName()==v[2]){
    std::cout<<"toppkg param "<<d(p)<<" in "<<d(pk)<<"\n"; if(p->UhdmType()==uhdmparameter) chain(((parameter*)p)->Typespec(),1);}
}
