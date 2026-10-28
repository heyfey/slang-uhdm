// whoref <db> <id>: ref_obj / any with Actual_group == object id; print chain
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string desc(const BaseClass*o){ if(!o) return "null"; std::string s; for(int i=0;i<8&&o;i++,o=o->VpiParent()) s+=(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"#"+std::to_string(o->UhdmId()); return s;}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); uint32_t id=atoi(argv[2]);
 for(auto&kv:s.AllObjects()){ auto*o=(any*)kv.first; if(!o) continue; if(o->UhdmType()==uhdmref_obj){ auto*r=(ref_obj*)o; if(r->Actual_group() && r->Actual_group()->UhdmId()==id) std::cout<<"REF "<<desc(r)<<"\n";} if(o->UhdmId()==id) std::cout<<"OBJ "<<desc(o)<<"\n"; }}
