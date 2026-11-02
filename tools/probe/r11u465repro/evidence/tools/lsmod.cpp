#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)ha[0])->object; if(d->AllModules()) for(auto*m:*d->AllModules()) std::cout<<UhdmName(m->UhdmType())<<" ["<<m->VpiName()<<"] ["<<m->VpiDefName()<<"]\n"; }
