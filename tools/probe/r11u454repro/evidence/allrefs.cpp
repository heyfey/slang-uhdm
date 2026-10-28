// allrefs <db>: every ref_obj: loc, name, owner chain (kind:name up to 6) -> actual (kind name line:col parent-name); sorted
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <vector>
#include <algorithm>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::vector<std::string> out;
 for(auto& [o,id]: s.AllObjects()){ (void)id; auto*b=(const BaseClass*)o; if(b->UhdmType()!=uhdmref_obj) continue; auto*r=(const ref_obj*)b; auto*a=r->Actual_group();
  std::string ln=std::to_string(b->VpiLineNo())+":"+std::to_string(b->VpiColumnNo())+" "+std::string(b->VpiName());
  const BaseClass*p=b->VpiParent(); for(int i=0;p&&i<6;i++,p=p->VpiParent()) ln+=" < "+std::string(UhdmName(p->UhdmType()))+":"+std::string(p->VpiName());
  ln+=" -> "+(a?std::string(UhdmName(a->UhdmType()))+":"+std::string(a->VpiName())+"@"+std::to_string(a->VpiLineNo())+":"+std::to_string(a->VpiColumnNo())+" P="+(a->VpiParent()?std::string(a->VpiParent()->VpiName()):"null"):"NULL");
  out.push_back(ln);} std::sort(out.begin(),out.end()); for(auto&x:out) std::cout<<x<<"\n"; }
