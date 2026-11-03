// tflist <db.uhdm> <funcname-substring>: per listing owner (package, class_defn, design), every task_func whose
// name contains the substring: object id, and per io_decl the bound typespec (kind name line:col, parent)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo());}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::string sub=argv[2];
  auto dump=[&](std::string owner, VectorOftask_func* v){ if(!v) return; for(auto*t:*v){ if(std::string(t->VpiName()).find(sub)==std::string::npos) continue;
      std::cout<<owner<<" tf#"<<t->UhdmId()<<" "<<one(t)<<" par="<<one(t->VpiParent());
      if(t->Io_decls()) for(auto*io:*t->Io_decls()){ std::cout<<" | "<<io->VpiName()<<"->"; if(auto*rt=io->Typespec()){ auto*a=rt->Actual_typespec(); std::cout<<one(a)<<"#"<<(a?a->UhdmId():0)<<" par="<<(a?one(a->VpiParent()):"-");} }
      std::cout<<"\n"; } };
  for(auto& kv: s.AllObjects()){ auto*o=(BaseClass*)kv.first;
    if(o->UhdmType()==uhdmclass_defn){ auto*c=(class_defn*)o; dump("class "+std::string(c->VpiName()), c->Task_funcs()); }
    else if(o->UhdmType()==uhdmpackage){ auto*c=(package*)o; dump("package "+std::string(c->VpiName())+"#"+std::to_string(c->UhdmId()), c->Task_funcs()); }
    else if(o->UhdmType()==uhdmdesign){ auto*c=(design*)o; dump("design", c->Task_funcs()); } }
}
