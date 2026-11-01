// whopa <db> <id>: every scope whose Param_assigns or Parameters vector holds object id
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string d1(const BaseClass*o){ std::string fn; if(auto*i=dynamic_cast<const instance*>(o)) fn=" fn="+std::string(i->VpiFullName()); return std::string(UhdmName(o->UhdmType()))+"#"+std::to_string(o->UhdmId())+":"+std::string(o->VpiName())+fn+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo());}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); unsigned long want=atol(argv[2]);
 for(auto&[o,id]:s.AllObjects()){ auto*b=(const BaseClass*)o; auto*sc=dynamic_cast<const scope*>(b); if(!sc) continue; bool hit=false; if(sc->Param_assigns()) for(auto*x:*sc->Param_assigns()) if(x->UhdmId()==want) hit=true; if(sc->Parameters()) for(auto*x:*sc->Parameters()) if(x->UhdmId()==want) hit=true; if(!hit) continue; std::string s=d1(b); for(auto*p=b->VpiParent();p;p=p->VpiParent()) s+=" < "+d1(p); std::cout<<s<<"\n";}}
