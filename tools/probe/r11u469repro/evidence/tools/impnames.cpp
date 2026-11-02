#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)ha[0])->object;
 for(int v=0;v<2;v++){ auto*l=v?d->TopPackages():d->AllPackages(); for(auto*pk:*l){ if(pk->Parameters()) for(auto*a:*pk->Parameters()) if(a->UhdmType()==uhdmparameter) std::cout<<(v?"TOP ":"DEF ")<<pk->VpiName()<<" param "<<a->VpiName()<<" #"<<a->UhdmId()<<" imp="<<((const parameter*)a)->VpiImported()<<"\n"; if(pk->Param_assigns()) for(auto*pa:*pk->Param_assigns()) if(pa->Lhs()&&pa->Lhs()->UhdmType()==uhdmparameter) std::cout<<(v?"TOP ":"DEF ")<<pk->VpiName()<<" pa "<<pa->Lhs()->VpiName()<<" #"<<pa->Lhs()->UhdmId()<<" imp="<<((const parameter*)pa->Lhs())->VpiImported()<<"\n"; } } }
