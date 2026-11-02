#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
#define SZ(f) std::cout<<"  " #f " "<<(p->f()?p->f()->size():0)<<"\n";
int main(int argc,char**argv){ Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto*da=(design*)((uhdm_handle*)ha[0])->object; std::string pn=argv[2];
 for(int k=0;k<2;k++){ auto*l=k?da->TopPackages():da->AllPackages(); if(!l) continue; for(auto*p:*l) if(p->VpiName()==pn){ std::cout<<(k?"TOP":"DEF")<<"\n"; SZ(Variables) SZ(Parameters) SZ(Param_assigns) SZ(Typespecs) SZ(Task_funcs) SZ(Class_defns) SZ(Named_events) SZ(Let_decls) SZ(Property_decls) SZ(Sequence_decls) SZ(Assertions) SZ(Array_vars) SZ(Logic_vars) SZ(Instance_items) SZ(Spec_params) SZ(Concurrent_assertions) SZ(Virtual_interface_vars) SZ(Typespecs) SZ(Scopes) SZ(Attributes)
  if(argc>3 && p->Variables()) for(auto*v:*p->Variables()) std::cout<<"   v "<<UhdmName(v->UhdmType())<<" "<<v->VpiName()<<" @"<<v->VpiLineNo()<<"\n"; }}
}
