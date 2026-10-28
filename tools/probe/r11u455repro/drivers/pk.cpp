#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object;
 if(d->AllPackages()) for(auto*p:*d->AllPackages()) std::cout<<"ALL "<<p->VpiName()<<" #"<<p->UhdmId()<<"\n";
 if(d->TopPackages()) for(auto*p:*d->TopPackages()) std::cout<<"TOP "<<p->VpiName()<<" #"<<p->UhdmId()<<"\n"; }
