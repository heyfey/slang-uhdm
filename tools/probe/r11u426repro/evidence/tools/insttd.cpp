// list package typedefs whose Instance is a different package than the listing package
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){
  for(int k=1;k<argc;k++){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[k])); auto*d=(design*)((uhdm_handle*)h[0])->object;
   int n=0;
   for(int top=0;top<2;top++){ auto*l=top?d->TopPackages():d->AllPackages(); if(!l) continue;
    for(auto*p:*l){ if(!p->Typespecs()) continue; for(auto*t:*p->Typespecs()){ auto*i=t->Instance(); if(i && i!=p){ n++; std::cout<<argv[k][0]<<" "<<(top?"TOP ":"DEF ")<<p->VpiName()<<" lists "<<t->VpiName()<<" inst="<<i->VpiName()<<(i->VpiName()==p->VpiName()?"(same-name other obj)":"")<<"\n";}}}}
   std::cout<<"count "<<n<<"  "<<argv[k]<<"\n"; }
}
