// pkgs <db>: AllPackages and TopPackages names in order, plus AllModules/TopModules
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
  std::cout<<"All:"; if(d->AllPackages()) for(auto*p:*d->AllPackages()) std::cout<<" "<<p->VpiName()<<"#"<<p->UhdmId(); std::cout<<"\nTop:"; if(d->TopPackages()) for(auto*p:*d->TopPackages()) std::cout<<" "<<p->VpiName()<<"#"<<p->UhdmId();
  std::cout<<"\nAllMod:"; if(d->AllModules()) for(auto*p:*d->AllModules()) std::cout<<" "<<p->VpiDefName(); std::cout<<"\nTopMod:"; if(d->TopModules()) for(auto*p:*d->TopModules()) std::cout<<" "<<p->VpiName(); std::cout<<"\n"; }
