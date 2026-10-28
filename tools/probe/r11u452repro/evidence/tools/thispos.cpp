#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*de=(design*)((uhdm_handle*)h[0])->object;
 if(de->AllModules()) for(auto*m:*de->AllModules()){ if(!m->Nets()) continue; int i=0; for(auto*n:*m->Nets()){ if(n->VpiName()=="this") std::cout<<m->VpiDefName()<<" this@"<<n->VpiLineNo()<<":"<<n->VpiColumnNo()<<" index "<<i<<" of "<<m->Nets()->size()<<"\n"; i++; } } }
