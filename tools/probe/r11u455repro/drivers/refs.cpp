// refs <db> <name> : every ref_obj/ref_var named <name>: parent chain and actual's chain, in walk order (vpi_visitor-ish via allObjects)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static std::string ch(const BaseClass*o,int n=8){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"#"+std::to_string(o->UhdmId()); return s;}
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::string nm=argv[2];
  for(auto& [o,id] : s.AllObjects()){ (void)id; if(o->UhdmType()==uhdmref_obj){ auto*r=(const ref_obj*)o; if(r->VpiName()==nm){ std::cout<<"REF "<<ch(r)<<"\n   -> "<<ch(r->Actual_group())<<"\n"; } } }
}
