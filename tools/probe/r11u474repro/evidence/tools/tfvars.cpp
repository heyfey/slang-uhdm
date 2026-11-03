// tfvars <db> <tfname>: every task_func named tfname (any container): parent chain, its variables (kind name), stmt kind
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::string N=argv[2];
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if((o->UhdmType()!=uhdmfunction&&o->UhdmType()!=uhdmtask)||o->VpiName()!=N) continue; auto*tf=(const task_func*)o;
  std::cout<<"id="<<o->UhdmId()<<" par="<<(o->VpiParent()?std::string(UhdmName(o->VpiParent()->UhdmType()))+":"+std::string(o->VpiParent()->VpiName()):"null")<<" vars:";
  if(tf->Variables()) for(auto*v:*tf->Variables()) std::cout<<" "<<UhdmName(v->UhdmType())<<":"<<v->VpiName()<<"#"<<v->UhdmId();
  std::cout<<" stmt="<<(tf->Stmt()?UhdmName(tf->Stmt()->UhdmType()):"null")<<"\n"; } }
