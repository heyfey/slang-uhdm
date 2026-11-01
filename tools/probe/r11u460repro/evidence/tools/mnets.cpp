// mnets <db>: for every module_inst in AllModules and TopModules: name: net names in order
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
void pr(const module_inst*m, std::string tag){ std::cout<<tag<<" "<<m->VpiDefName()<<"/"<<m->VpiName()<<":"; if(m->Nets()) for(auto*n:*m->Nets()) std::cout<<" "<<n->VpiName()<<"@"<<n->VpiLineNo(); std::cout<<"\n"; if(m->Modules()) for(auto*c:*m->Modules()) pr((module_inst*)c, tag+">"); }
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 if(d->AllModules()) for(auto*m:*d->AllModules()) if(m->UhdmType()==uhdmmodule_inst) pr((module_inst*)m,"DEF"); if(d->TopModules()) for(auto*m:*d->TopModules()) if(m->UhdmType()==uhdmmodule_inst) pr((module_inst*)m,"TOP"); }
