// tdown <uhdm> <tsname>: which package listings (DEF/TOP) hold a typespec named tsname (by id)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1]));
  auto*d=(design*)((uhdm_handle*)h[0])->object; std::string nm=argv[2];
  for(int k=0;k<2;k++){ auto*l=k?d->TopPackages():d->AllPackages(); if(!l) continue; for(auto*p:*l){ if(!p->Typespecs()) continue; for(auto*t:*p->Typespecs()) if(t->VpiName()==nm) std::cout<<(k?"TOP ":"DEF ")<<p->VpiName()<<"#"<<p->UhdmId()<<" "<<UhdmName(t->UhdmType())<<"#"<<t->UhdmId()<<"@"<<t->VpiLineNo()<<":"<<t->VpiColumnNo()<<" inst="<<(t->Instance()?std::string(t->Instance()->VpiName())+"#"+std::to_string(t->Instance()->UhdmId()):"null")<<"\n"; } }
}
