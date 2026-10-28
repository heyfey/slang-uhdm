#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::map<std::string,int> cnt;
 for(auto& kv: s.AllObjects()){ auto*o=(any*)kv.first; if(!o||o->UhdmType()!=uhdmref_obj) continue; auto*r=(ref_obj*)o; if(r->VpiName()!=argv[2]) continue;
  const any* tf=r->VpiParent(); while(tf && tf->UhdmType()!=uhdmfunction && tf->UhdmType()!=uhdmtask) tf=tf->VpiParent();
  std::string own; for(const any*q=tf?tf->VpiParent():nullptr;q;q=q->VpiParent()) { own=std::string(UhdmName(q->UhdmType()))+":"+std::string(q->VpiName()); if(q->UhdmType()==uhdmpackage||q->UhdmType()==uhdmmodule_inst) break; }
  std::string a=r->Actual_group()? (std::string(UhdmName(r->Actual_group()->UhdmType()))+":"+std::string(r->Actual_group()->VpiParent()?r->Actual_group()->VpiParent()->VpiDefName():"")+"."+std::string(r->Actual_group()->VpiName())+"@"+std::to_string(r->Actual_group()->VpiLineNo())) : "null";
  cnt[std::to_string(r->VpiLineNo())+":"+std::to_string(r->VpiColumnNo())+" tf="+(tf?std::string(tf->VpiName()):"-")+" in="+own+" -> "+a]++; }
 for(auto&[k,v]:cnt) std::cout<<v<<" "<<k<<"\n"; }
