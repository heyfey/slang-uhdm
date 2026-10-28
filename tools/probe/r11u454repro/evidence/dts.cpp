// dts <db>: print design->Typespecs() in order (kind name line:col-endl:endc parent instance)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
 auto*d=(design*)((uhdm_handle*)h[0])->object; if(!d->Typespecs()) return 0; int i=0;
 for(auto*t:*d->Typespecs()){ std::cout<<i++<<" "<<UhdmName(t->UhdmType())<<" "<<t->VpiName()<<" "<<t->VpiLineNo()<<":"<<t->VpiColumnNo()<<"-"<<t->VpiEndLineNo()<<":"<<t->VpiEndColumnNo();
  auto*p=t->VpiParent(); std::cout<<" P="<<(p?std::string(UhdmName(p->UhdmType()))+":"+std::string(p->VpiName()):"null");
  auto*in=t->Instance(); std::cout<<" I="<<(in?std::string(in->VpiName()):"null")<<"\n"; } }
