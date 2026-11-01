// clsinst <db> <pkg> top|def: for each class_defn of the package, each Typespecs entry whose Instance is not that package: print class, ts name, inst
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string pn=argv[2]; bool top=std::string(argv[3])=="top";
  auto*l=top?d->TopPackages():d->AllPackages(); for(auto*p:*l){ if(p->VpiName()!=pn) continue; if(!p->Class_defns()) continue; for(auto*c:*p->Class_defns()){ if(!c->Typespecs()) continue; for(auto*t:*c->Typespecs()){ auto*i=t->Instance(); if(i==p) continue; std::cout<<c->VpiName()<<" :: "<<t->VpiName()<<" @"<<t->VpiLineNo()<<" inst="<<(i?std::string(i->VpiName()):"null")<<" par="<<(t->VpiParent()?std::string(t->VpiParent()->VpiName()):"null")<<"\n"; } } } }
