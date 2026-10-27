#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <uhdm/vpi_visitor.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string pn=argv[2]; bool top=std::string(argv[3])=="top"; std::string fn=argv[4];
  auto*l=top?d->TopPackages():d->AllPackages(); for(auto*p:*l) if(p->VpiName()==pn && p->Task_funcs()) for(auto*f:*p->Task_funcs()) if(f->VpiName()==fn){ std::cout<<decompile(f); return 0;} std::cout<<"nf\n"; }
