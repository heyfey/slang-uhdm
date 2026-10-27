// pkgnames <uhdm> <pkg> def|top <Variables|Param_assigns>: names in order
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; bool top=std::string(argv[3])=="top"; std::string w=argv[4];
  auto*l=top?d->TopPackages():d->AllPackages(); for(auto*p:*l) if(p->VpiName()==argv[2]){
    if(w=="Variables"&&p->Variables()) for(auto*v:*p->Variables()) std::cout<<UhdmName(v->UhdmType())<<" "<<v->VpiName()<<" @"<<v->VpiLineNo()<<":"<<v->VpiColumnNo()<<"\n";
    if(w=="Param_assigns"&&p->Param_assigns()) for(auto*v:*p->Param_assigns()) std::cout<<(v->Lhs()?std::string(v->Lhs()->VpiName()):"?")<<" @"<<v->VpiLineNo()<<":"<<v->VpiColumnNo()<<"\n";
    if(w=="Nets"&&p->Nets()) for(auto*v:*p->Nets()) std::cout<<UhdmName(v->UhdmType())<<" "<<v->VpiName()<<" @"<<v->VpiLineNo()<<"\n";
  }}
