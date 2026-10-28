// refat <db> <name> <line>: every ref_obj name@line: chain and actual chain
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static std::string desc(const BaseClass*o,int n=6){ if(!o) return "null"; std::string s; for(int i=0;i<n&&o;i++,o=o->VpiParent()) s+=(i?" < ":"")+std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::to_string(o->VpiLineNo()); return s;}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); std::multiset<std::string> out;
 for(auto&kv:s.AllObjects()){ auto*o=(any*)kv.first; if(!o||o->UhdmType()!=uhdmref_obj) continue; auto*r=(ref_obj*)o; if(r->VpiName()!=argv[2]||r->VpiLineNo()!=(uint32_t)atoi(argv[3])) continue; out.insert(desc(r)+"\n     -> "+desc(r->Actual_group(),5)); }
 for(auto&x:out) std::cout<<x<<"\n"; }
