// prm <db> <name-substr>: every class_typespec whose name contains substr: id, name, parent, inst, #params, #param_assigns, alias target
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"/"+std::string(o->VpiDefName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"#"+std::to_string(o->UhdmId()); }
int main(int argc,char**argv){
  Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::string nm=argv[2];
  for(auto&[o,i]: s.AllObjects()){ const any*a=(const any*)o; if(a->UhdmType()!=uhdmclass_typespec) continue; if(std::string(a->VpiName()).find(nm)==std::string::npos) continue;
    auto*t=(const class_typespec*)a; std::cout<<one(t)<<" par="<<one(t->VpiParent())<<" inst="<<one(t->Instance())<<" P="<<(t->Parameters()?t->Parameters()->size():0)<<" PA="<<(t->Param_assigns()?t->Param_assigns()->size():0)<<" alias="<<(t->Typedef_alias()?one(t->Typedef_alias()->Actual_typespec()):"-")<<" cd="<<one(t->Class_defn())<<"\n"; }
}
