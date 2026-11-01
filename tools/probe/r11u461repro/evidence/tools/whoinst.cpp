// whoinst <db> <pkgname>: every typespec whose Instance is a package named pkgname; reports DEF(all)/TOP and the parent chain
#include <uhdm/uhdm.h>
#include <uhdm/vpi_uhdm.h>
#include <filesystem>
#include <iostream>
#include <set>
using namespace UHDM;
static std::string d1(const BaseClass*o){ std::string fn; if(auto*i=dynamic_cast<const instance*>(o)) fn=" fn="+std::string(i->VpiFullName()); return std::string(UhdmName(o->UhdmType()))+":"+std::string(o->VpiName())+fn+"@"+std::to_string(o->VpiLineNo())+":"+std::to_string(o->VpiColumnNo());}
int main(int argc,char**argv){ Serializer s; auto h=s.Restore(std::filesystem::path(argv[1])); auto*d=(design*)((uhdm_handle*)h[0])->object; std::string want=argv[2];
 std::set<const any*> defs, tops; if(d->AllPackages()) for(auto*p:*d->AllPackages()) defs.insert(p); if(d->TopPackages()) for(auto*p:*d->TopPackages()) tops.insert(p);
 for(auto&[o,id]:s.AllObjects()){ auto*b=(const BaseClass*)o; auto*t=dynamic_cast<const typespec*>(b); if(!t||!t->Instance()) continue; auto*i=t->Instance(); if(i->VpiName()!=want) continue; std::string k=defs.count(i)?"DEF":tops.count(i)?"TOP":"OTHER"; std::string s=k+" "+d1(b); int n=0; for(auto*p=b->VpiParent();p&&n<8;p=p->VpiParent(),n++) s+=" < "+d1(p); std::cout<<s<<"\n";}}
