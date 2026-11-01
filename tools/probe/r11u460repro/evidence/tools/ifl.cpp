// ifl <db> <defname>: for every interface_inst with that defname: typedef names and task_func names (with parent kind)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; s.Restore(std::filesystem::path(argv[1])); std::string dn=argv[2];
 for(auto&[o,i]:s.AllObjects()){ auto*a=(const any*)o; if(a->UhdmType()!=uhdminterface_inst) continue; auto*m=(const interface_inst*)a; if(m->VpiDefName()!=dn) continue;
  std::cout<<"IFACE "<<m->VpiName()<<"\n TD:"; if(m->Typespecs()) for(auto*t:*m->Typespecs()) std::cout<<" "<<t->VpiName(); std::cout<<"\n TF:"; if(m->Task_funcs()) for(auto*t:*m->Task_funcs()) std::cout<<" "<<t->VpiFullName(); std::cout<<"\n"; } }
