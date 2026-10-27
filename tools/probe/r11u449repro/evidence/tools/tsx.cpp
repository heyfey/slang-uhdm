// tsx <uhdm> top|def <pkg> <tfname>: io_decl typespec chains with object ids
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string D(const any*o){ if(!o) return "null"; std::string s=std::string(UhdmName(o->UhdmType()))+"#"+std::to_string(o->UhdmId())+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo());
  if(auto*t=any_cast<const typespec*>(o)) { s+=" inst="; s+= t->Instance()? std::string(t->Instance()->VpiName())+"#"+std::to_string(t->Instance()->UhdmId()) : "null"; }
  s+=" par="; s+= o->VpiParent()? std::string(UhdmName(o->VpiParent()->UhdmType()))+"#"+std::to_string(o->VpiParent()->UhdmId()):"null"; return s;}
static void ts(const typespec*t,int ind,int depth){ std::string pad(ind,' '); std::cout<<pad<<D(t)<<"\n"; if(!t||depth>4) return;
  if(auto*a=any_cast<const array_typespec*>(t)){ if(a->Elem_typespec()) ts(a->Elem_typespec()->Actual_typespec(),ind+2,depth+1); if(a->Index_typespec()) {std::cout<<pad<<" idx:\n"; ts(a->Index_typespec()->Actual_typespec(),ind+2,depth+1);} }
  if(auto*st=any_cast<const struct_typespec*>(t)) if(st->Members()) for(auto*m:*st->Members()){ std::cout<<pad<<"  mem "<<D(m)<<"\n"; if(m->Typespec()) ts(m->Typespec()->Actual_typespec(),ind+4,depth+1);} 
  if(t->Typedef_alias()) { std::cout<<pad<<" alias:\n"; ts(t->Typedef_alias()->Actual_typespec(),ind+2,depth+1);} }
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  auto*d=(design*)((uhdm_handle*)h[0])->object; bool top=std::string(argv[2])=="top";
  auto*l=top?d->TopPackages():d->AllPackages(); if(!l) return 1;
  for(auto*p:*l) if(p->VpiName()==argv[3] && p->Task_funcs()) for(auto*t:*p->Task_funcs()) if(t->VpiName()==argv[4]){
    std::cout<<"TF "<<D(t)<<"\n"; if(t->Io_decls()) for(auto*io:*t->Io_decls()){ std::cout<<" io "<<D(io)<<"\n"; if(io->Typespec()) ts(io->Typespec()->Actual_typespec(),4,0);} }
}
