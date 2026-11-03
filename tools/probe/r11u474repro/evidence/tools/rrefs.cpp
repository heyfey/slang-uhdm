// rrefs <db> <name>: every ref_obj named <name>: stored full name, parent chain up to the net and its module, and whether that module is an elaborated instance
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string N=argv[2];
 std::set<const any*> defs; if(d->AllModules()) for(auto*m:*d->AllModules()) defs.insert(m);
 for(auto& kv: s.AllObjects()){ auto*o=(const any*)kv.first; if(o->UhdmType()!=uhdmref_obj||o->VpiName()!=N) continue;
  std::cout<<"ref_obj "<<o->VpiName()<<" id="<<o->UhdmId()<<" full='"<<((ref_obj*)o)->VpiFullName()<<"' chain:";
  for(auto*p=o->VpiParent();p;p=p->VpiParent()){ std::cout<<" < "<<UhdmName(p->UhdmType())<<":"<<p->VpiName(); if(p->UhdmType()==uhdmmodule_inst){ std::cout<<(defs.count(p)?"[def]":"[elab]"); break;} }
  std::cout<<"\n"; } }
