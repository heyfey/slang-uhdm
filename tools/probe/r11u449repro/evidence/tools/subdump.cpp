// subdump <uhdm> top|def <pkg> <tfname>: full subtree (ids on) of one package subroutine listing entry
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); vpi_show_ids(true);
  auto*d=(design*)((uhdm_handle*)h[0])->object; bool top=std::string(argv[2])=="top";
  auto*l=top?d->TopPackages():d->AllPackages(); if(!l) return 1;
  for(auto*p:*l) if(p->VpiName()==argv[3] && p->Task_funcs()) for(auto*t:*p->Task_funcs()) if(t->VpiName()==argv[4]){
    vpiHandle th=NewVpiHandle(t); visit_object(th,std::cout); std::cout<<"=====\n"; }
}
