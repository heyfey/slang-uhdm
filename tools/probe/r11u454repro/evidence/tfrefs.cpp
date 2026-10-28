// tfrefs <db> <taskname>: each ref_obj under a task/function of that name: line:col name -> actual fullname
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <vector>
#include <algorithm>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::string tn=argv[2];
 std::vector<std::string> out;
 for(auto& [o,id]: s.AllObjects()){ (void)id; auto*b=(const BaseClass*)o; if(b->UhdmType()!=uhdmref_obj) continue;
  const BaseClass* p=b->VpiParent(); const BaseClass* tf=nullptr; for(int i=0;p&&i<40;i++,p=p->VpiParent()) if((p->UhdmType()==uhdmtask||p->UhdmType()==uhdmfunction)&&p->VpiName()==tn){tf=p;break;}
  if(!tf) continue; auto*r=(const ref_obj*)b; auto*a=r->Actual_group(); auto*own=tf->VpiParent();
  std::string ln=std::to_string(b->VpiLineNo())+":"+std::to_string(b->VpiColumnNo())+" "+std::string(b->VpiName())+" in "+(own?std::string(UhdmName(own->UhdmType()))+":"+std::string(own->VpiName()):"?")+" -> "+(a?std::string(UhdmName(a->UhdmType()))+":"+std::string(a->VpiName())+"@"+std::to_string(a->VpiLineNo())+":"+std::to_string(a->VpiColumnNo())+" P="+(a->VpiParent()?std::string(a->VpiParent()->VpiName()):"null"):"NULL");
  out.push_back(ln);} std::sort(out.begin(),out.end()); for(auto&x:out) std::cout<<x<<"\n"; }
