// fcalls <db> <name>: every func_call/task_call named <name>: chain and the linked subroutine's chain
#include <uhdm/uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static bool gIds = false; // argv[3] == "ids" prints object ids
static std::string ch(const BaseClass*o,int n=9){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+(gIds?"#"+std::to_string(o->UhdmId()):""); return s;}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::string nm=argv[2]; gIds = argc > 3;
 for(auto& [o,id]: s.AllObjects()){ (void)id; if(o->UhdmType()==uhdmfunc_call){ auto*f=(const func_call*)o; if(f->VpiName()==nm) std::cout<<"FC "<<ch(f)<<"\t-> "<<ch(f->Function(),4)<<"\n"; } } }
