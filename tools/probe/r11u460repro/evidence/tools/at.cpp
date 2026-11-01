// at <db> <kind-substr> <line> <col>: matching objects with parent chain (8) and file
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <map>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); }
static std::string ch(const BaseClass*o,int n){ std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=std::string(i?" < ":"")+one(o); return s;}
int main(int argc,char**argv){ Serializer s; s.Restore(std::filesystem::path(argv[1])); std::string k=argv[2]; int l=atoi(argv[3]), c=atoi(argv[4]); std::map<std::string,int> agg;
 for(auto&[o,i]:s.AllObjects()){ auto*a=(const any*)o; if(std::string(UhdmName(a->UhdmType())).find(k)==std::string::npos) continue; if((int)a->VpiLineNo()!=l||(int)a->VpiColumnNo()!=c) continue; std::string sz; if(auto*e=any_cast<const expr*>(a)) sz=" size="+std::to_string(e->VpiSize()); agg[ch(a,9)+sz+" file="+std::string(a->VpiFile())]++; }
 for(auto&[k2,v]:agg) std::cout<<v<<"x "<<k2<<"\n"; }
