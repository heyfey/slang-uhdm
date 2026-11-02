// tsl <db> <pkg> [all]: a package's typespec listing (TOP view; both views with 'all'): kind, name, location, id, parent, instance
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
using namespace UHDM;
static std::string nm(const BaseClass*o){ if(!o) return "null"; return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+"#"+std::to_string(o->UhdmId()); }
int main(int argc,char**argv){ Serializer sa; auto ha=sa.Restore(std::filesystem::path(argv[1])); auto*da=(design*)((uhdm_handle*)ha[0])->object; std::string pn=argv[2]; bool all=argc>3;
 for(int k=all?0:1;k<2;k++){ auto*l=k?da->TopPackages():da->AllPackages(); if(!l) continue; for(auto*p:*l) if(p->VpiName()==pn && p->Typespecs()) { if(all) std::cout<<(k?"TOP\n":"DEF\n"); for(auto*t:*p->Typespecs()) std::cout<<UhdmName(t->UhdmType())<<" "<<t->VpiName()<<" @"<<t->VpiLineNo()<<":"<<t->VpiColumnNo()<<(all?std::string(" id=")+std::to_string(t->UhdmId())+" par="+nm(t->VpiParent())+" inst="+nm(t->Instance()):std::string(""))<<"\n"; }}}
