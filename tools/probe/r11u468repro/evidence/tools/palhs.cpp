// palhs <db>: for every class_typespec whose param_assigns' Lhs is a parameter (not a type_parameter): Lhs id, parent, listed?
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; s.Restore(std::filesystem::path(argv[1]));
  for(auto& kv: s.AllObjects()){ auto*o=(BaseClass*)kv.first; if(o->UhdmType()!=uhdmclass_typespec) continue; auto*c=(class_typespec*)o; if(!c->Param_assigns()) continue;
    for(auto*pa:*c->Param_assigns()){ auto*l=pa->Lhs(); if(!l||l->UhdmType()!=uhdmparameter) continue; bool listed=false; auto*cd=c->Class_defn();
      if(cd&&cd->Parameters()) for(auto*p:*cd->Parameters()) if(p==l) listed=true;
      std::cout<<"cts#"<<c->UhdmId()<<" "<<c->VpiName()<<" lhs#"<<l->UhdmId()<<" "<<l->VpiName()<<" par="<<(l->VpiParent()?std::string(l->VpiParent()->VpiName()):"null")<<" listed="<<listed<<"\n"; } } }
