#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string ts(const ref_typespec* rt){ if(!rt) return "none"; auto*t=rt->Actual_typespec(); if(!t) return "null"; std::string s=std::string(UhdmName(t->UhdmType()))+"#"+std::to_string(t->UhdmId()); if(t->Instance()) s+="@"+std::string(t->Instance()->VpiName())+"#"+std::to_string(t->Instance()->UhdmId()); return s+" rt="+std::string(rt->VpiFullName()); }
int main(int c,char**v){ Serializer s; auto h=s.Restore(std::filesystem::path(v[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 for(int vw=0;vw<2;vw++){ auto*l=vw?d->TopPackages():d->AllPackages(); for(auto*p:*l){ std::cout<<(vw?"TOP ":"DEF ")<<p->VpiName()<<"#"<<p->UhdmId()<<"\n"; if(p->Param_assigns()) for(auto*pa:*p->Param_assigns()){ std::cout<<"  pa "<<pa->Lhs()->VpiName()<<" lhs "<<ts(((parameter*)pa->Lhs())->Typespec()); auto*r=pa->Rhs(); if(r->UhdmType()==uhdmconstant) std::cout<<" rhsC "<<ts(((constant*)r)->Typespec()); if(r->UhdmType()==uhdmoperation){ for(auto*o:*((operation*)r)->Operands()) if(o->UhdmType()==uhdmconstant) std::cout<<" opC "<<ts(((constant*)o)->Typespec()); } std::cout<<"\n"; } } } }
