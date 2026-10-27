#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
  for(int top=0;top<2;top++){ auto*l=top?d->TopPackages():d->AllPackages(); if(!l) continue; for(auto*p:*l){
    std::cout<<(top?"TOP ":"DEF ")<<p->VpiName()<<" tf="<<(p->Task_funcs()?p->Task_funcs()->size():0)<<" cls="<<(p->Class_defns()?p->Class_defns()->size():0)<<" ts="<<(p->Typespecs()?p->Typespecs()->size():0)<<" vars="<<(p->Variables()?p->Variables()->size():0)<<" params="<<(p->Parameters()?p->Parameters()->size():0)<<"\n";
    if(argc>2 && p->VpiName()==argv[2] && p->Task_funcs()) for(auto*t:*p->Task_funcs()) std::cout<<"   "<<t->VpiName()<<" @"<<t->VpiLineNo()<<" inst="<<(t->Instance()?std::string(t->Instance()->VpiName()):"null")<<" par="<<(t->VpiParent()?std::string(t->VpiParent()->VpiName()):"null")<<"\n"; }}
}
