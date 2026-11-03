// pkgsz <db> <pkg>: per view, the sizes of each vector of package pkg
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string P=argv[2];
 for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(l) for(auto*p:*l) if(p->VpiName()==P){
  auto n=[](auto*v){return v?(int)v->size():-1;};
  std::cout<<(k?"top":"all")<<" typedef="<<n(p->Typespecs())<<" vars="<<n(p->Variables())<<" params="<<n(p->Parameters())<<" pa="<<n(p->Param_assigns())<<" tf="<<n(p->Task_funcs())<<" cls="<<n(p->Class_defns())<<" nets="<<n(p->Nets())<<"\n";
  if(argc>3 && p->Typespecs()) for(auto*t:*p->Typespecs()) std::cout<<"   "<<UhdmName(t->UhdmType())<<" "<<t->VpiName()<<"\n"; }}}
