// consts <db>: every constant with line:col decompile size consttype and parent chain (3)
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo()); }
int main(int argc,char**argv){ Serializer s; s.Restore(std::filesystem::path(argv[1])); std::multiset<std::string> out;
 for(auto&[o,i]:s.AllObjects()){ auto*a=(const any*)o; if(a->UhdmType()!=uhdmconstant) continue; auto*c=(const constant*)a; if(std::string(c->VpiFile()).find("builtin")!=std::string::npos) continue; std::string p; auto*q=a->VpiParent(); for(int k=0;k<3&&q;k++,q=q->VpiParent()) p+=" < "+one(q);
   out.insert(std::to_string(c->VpiLineNo())+":"+std::to_string(c->VpiColumnNo())+" "+std::string(c->VpiDecompile())+" size="+std::to_string(c->VpiSize())+" "+std::string(c->VpiValue())+p); }
 for(auto&x:out) std::cout<<x<<"\n"; }
