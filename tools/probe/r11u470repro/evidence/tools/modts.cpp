// modts <db> <module name>: list Typespecs() of every module_inst of that name (all + top views)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static void lst(const module_inst* m,const char* v){ std::cout<<"== "<<v<<" "<<m->VpiName()<<" id"<<m->UhdmId()<<"\n"; if(!m->Typespecs())return; int i=0;
  for(auto*t:*m->Typespecs()){ std::cout<<i++<<" "<<t->UhdmType()<<" "<<t->VpiName()<<" L"<<t->VpiLineNo()<<":"<<t->VpiColumnNo()<<" par="<<(t->VpiParent()?std::to_string(t->VpiParent()->UhdmType())+":"+std::string(t->VpiParent()->VpiName())+"#"+std::to_string(t->VpiParent()->UhdmId()):"null")<<" id"<<t->UhdmId()<<" inst="<<(t->Instance()?std::string(t->Instance()->VpiName()):"null")<<"\n";}}
static void walk(const module_inst* m,const std::string&n){ if(m->VpiName()==n||m->VpiDefName()==n) lst(m,"top"); if(m->Modules()) for(auto*c:*m->Modules()) walk(c,n);}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string n=argv[2];
  if(d->AllModules()) for(auto*m:*d->AllModules()) if(m->VpiName()==n||m->VpiDefName()==n) lst(m,"all");
  if(d->TopModules()) for(auto*m:*d->TopModules()) walk(m,n);}
