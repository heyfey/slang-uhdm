#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string one(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"@"+std::string(o->VpiFile())+":"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo())+"-"+std::to_string(o->VpiEndLineNo())+":"+std::to_string(o->VpiEndColumnNo());}
template<class V> static std::string sz(V*v){ return v? std::to_string(v->size()):"null"; }
int main(int argc,char**argv){
  Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); std::string nm=argv[2];
  for(auto& kv: sa.AllObjects()){ const BaseClass* o=kv.first; if(o->UhdmType()!=uhdmclass_defn) continue; auto*c=(const class_defn*)o; if(c->VpiName()!=nm) continue;
    std::cout<<one(c)<<" vars="<<sz(c->Variables())<<" tds="<<sz(c->Typespecs())<<" tf="<<sz(c->Task_funcs())<<" params="<<sz(c->Parameters())<<" pa="<<sz(c->Param_assigns())<<" named_events="<<sz(c->Named_events())<<"\n";
    if(c->Variables()) for(auto*v:*c->Variables()) std::cout<<"  var "<<one(v)<<"\n";
    if(c->Typespecs()) for(auto*v:*c->Typespecs()) std::cout<<"  td "<<one(v)<<"\n";
  }
}
